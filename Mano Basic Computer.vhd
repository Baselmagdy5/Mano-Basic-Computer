library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ManoComputer is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        inpr_val : in  STD_LOGIC_VECTOR(7 downto 0);
        outr_val : out STD_LOGIC_VECTOR(7 downto 0)
    );
end ManoComputer;

architecture Behavioral of ManoComputer is
    -- Memory: 4096 words of 16 bits each
    type ram_type is array (0 to 4095) of STD_LOGIC_VECTOR(15 downto 0);
signal RAM : ram_type := (
    0 => x"7800", -- CLA   : AC <- 0 (Clear AC to start fresh)
    1 => x"5005", -- BSA 5 : Call function at address 5 (Saves return address at 5)
    2 => x"1008", -- ADD 8 : After returning, add the value stored at address 8 (which is 5)
    3 => x"7001", -- HLT   : Stop execution
    
    -- Function Definition starts here
    5 => x"0000", -- Storage for the return address (BSA writes address 2 here)
    6 => x"7020", -- INC   : AC <- AC + 1 (The function logic)
    7 => x"C005", -- BUN I : Indirect Branch to address 5 (Return to address 2)
    
    -- Data Constants
    8 => x"0005", -- The constant value 5 to be added later
    others => x"0000"
);

    -- Internal Registers
    signal AC   : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal DR   : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal IR   : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal AR   : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal PC   : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal INPR : STD_LOGIC_VECTOR(7 downto 0)  := (others => '0');
    signal OUTR : STD_LOGIC_VECTOR(7 downto 0)  := (others => '0');
    
    -- Flip-Flops
    signal E    : STD_LOGIC := '0';
    signal I    : STD_LOGIC := '0';
    signal S    : STD_LOGIC := '1'; -- Run/Halt
    signal IEN  : STD_LOGIC := '0';
    signal FGI  : STD_LOGIC := '0';
    signal FGO  : STD_LOGIC := '1';
    
    -- Timing and Control
    signal SC   : unsigned(3 downto 0) := "0000";
    signal D    : STD_LOGIC_VECTOR(7 downto 0);
    
begin

    -----------------------------------------------------------
    -- CONCURRENT ASSIGNMENTS (Must be inside begin)
    -----------------------------------------------------------
    INPR <= inpr_val;
    outr_val <= OUTR;

    -----------------------------------------------------------
    -- Instruction Decoder (D0 to D7)
    -----------------------------------------------------------
    process(IR)
    begin
        D <= (others => '0');
        case IR(14 downto 12) is
            when "000" => D(0) <= '1';
            when "001" => D(1) <= '1';
            when "010" => D(2) <= '1';
            when "011" => D(3) <= '1';
            when "100" => D(4) <= '1';
            when "101" => D(5) <= '1';
            when "110" => D(6) <= '1';
            when "111" => D(7) <= '1';
            when others => null;
        end case;
    end process;

    -----------------------------------------------------------
    -- Main CPU Process
    -----------------------------------------------------------
    process(clk, reset)
        variable temp_add : unsigned(16 downto 0);
    begin
        if reset = '1' then
            PC <= (others => '0');
            SC <= "0000";
            S  <= '1';
            AC <= (others => '0');
            E  <= '0';
        elsif rising_edge(clk) and S = '1' then
            
            case SC is
                -- T0: Fetch Address
                when "0000" =>
                    AR <= PC;
                    SC <= SC + 1;

                -- T1: Fetch Instruction
                when "0001" =>
                    IR <= RAM(to_integer(unsigned(AR)));
                    PC <= std_logic_vector(unsigned(PC) + 1);
                    SC <= SC + 1;

                -- T2: Decode
                when "0010" =>
                    AR <= IR(11 downto 0);
                    I  <= IR(15);
                    SC <= SC + 1;

                -- T3: Execute Reg-Ref/IO or Indirect Addressing
                when "0011" =>
                    if D(7) = '0' then -- Memory Reference
                        if I = '1' then
                            AR <= RAM(to_integer(unsigned(AR)))(11 downto 0); -- Indirect
                        end if;
                        SC <= SC + 1;
                    else -- Register Reference or I/O
                        if I = '0' then -- Register Reference
                            if IR(11) = '1' then AC <= (others => '0'); end if; -- CLA
                            if IR(10) = '1' then E <= '0'; end if;              -- CLE
                            if IR(9)  = '1' then AC <= not AC; end if;          -- CMA
                            if IR(8)  = '1' then E <= not E; end if;            -- CME
                            if IR(7)  = '1' then -- SHR
                                E <= AC(0); AC <= E & AC(15 downto 1);
                            end if;
                            if IR(6)  = '1' then -- SHL
                                E <= AC(15); AC <= AC(14 downto 0) & E;
                            end if;
                            if IR(5)  = '1' then -- INC
                                AC <= std_logic_vector(unsigned(AC) + 1);
                            end if;
                            -- Skip Logic
                            if (IR(4) = '1' and AC(15) = '0' and AC /= x"0000") or -- SPA
                               (IR(3) = '1' and AC(15) = '1') or                    -- SNA
                               (IR(2) = '1' and AC = x"0000") or                    -- SZA
                               (IR(1) = '1' and E = '0') then                      -- SZE
                                 PC <= std_logic_vector(unsigned(PC) + 1);
                            end if;
                            if IR(0) = '1' then S <= '0'; end if; -- HLT
                        else -- I/O Instructions
                            if IR(11) = '1' then AC(7 downto 0) <= INPR; FGI <= '0'; end if; -- INP
                            if IR(10) = '1' then OUTR <= AC(7 downto 0); FGO <= '0'; end if; -- OUT
                            if IR(9)  = '1' and FGI = '1' then PC <= std_logic_vector(unsigned(PC)+1); end if;
                            if IR(8)  = '1' and FGO = '1' then PC <= std_logic_vector(unsigned(PC)+1); end if;
                            if IR(7)  = '1' then IEN <= '1'; end if; -- ION
                            if IR(6)  = '1' then IEN <= '0'; end if; -- IOF
                        end if;
                        SC <= "0000"; -- Reset sequence for Reg-Ref/IO
                    end if;

                -- T4: Memory Reference Execution (Read Operand)
                when "0100" =>
                    if D(0)='1' or D(1)='1' or D(2)='1' or D(6)='1' then
                        DR <= RAM(to_integer(unsigned(AR)));
                    elsif D(3) = '1' then -- STA
                        RAM(to_integer(unsigned(AR))) <= AC;
                        SC <= "0000";
                    elsif D(4) = '1' then -- BUN
                        PC <= AR;
                        SC <= "0000";
                    elsif D(5) = '1' then -- BSA
                        RAM(to_integer(unsigned(AR))) <= "0000" & PC;
                        AR <= std_logic_vector(unsigned(AR) + 1);
                    end if;
                    if D(3)='0' and D(4)='0' then SC <= SC + 1; end if;

                -- T5: Memory Reference Execution (Operation)
                when "0101" =>
                    if D(0) = '1' then AC <= AC and DR; -- AND
                    elsif D(1) = '1' then -- ADD
                        temp_add := unsigned('0' & AC) + unsigned('0' & DR);
                        AC <= std_logic_vector(temp_add(15 downto 0));
                        E <= temp_add(16);
                    elsif D(2) = '1' then AC <= DR; -- LDA
                    elsif D(5) = '1' then PC <= AR; -- BSA (Final step)
                    elsif D(6) = '1' then -- ISZ
                        DR <= std_logic_vector(unsigned(DR) + 1);
                    end if;
                    SC <= SC + 1;

                -- T6: Finalize ISZ
                when "0110" =>
                    if D(6) = '1' then
                        RAM(to_integer(unsigned(AR))) <= DR;
                        if DR = x"0000" then
                            PC <= std_logic_vector(unsigned(PC) + 1);
                        end if;
                    end if;
                    SC <= "0000";

                when others => SC <= "0000";
            end case;
        end if;
    end process;

end Behavioral;