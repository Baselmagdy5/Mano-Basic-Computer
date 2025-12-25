library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IO_Test_tb is
end IO_Test_tb;

architecture Behavioral of IO_Test_tb is
    component ManoComputer
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            inpr_val : in  STD_LOGIC_VECTOR(7 downto 0);
            outr_val : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '0';
    signal inpr_val : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal outr_val : STD_LOGIC_VECTOR(7 downto 0);

    constant clk_period : time := 20 ns;

begin
    uut: ManoComputer port map (clk, reset, inpr_val, outr_val);

    clk_process: process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    stim: process
    begin
        -- 1. Setup Input Value
        inpr_val <= x"55"; 
        
        -- 2. Reset
        reset <= '1'; wait for 40 ns;
        reset <= '0';

        -- 3. Wait for instructions to complete
        -- Total time for INP, OUT, and HLT (approx 6-8 cycles each)
        wait for 400 ns;

        -- 4. Verify Results
        report "Checking if OUTR matches INPR...";
        if (outr_val = x"55") then
            report "I/O TEST PASSED: Value 55 successfully passed through AC";
        else
            report "I/O TEST FAILED: Output register does not match" severity error;
        end if;

        -- 5. End of Process
        report "Simulation Completed Successfully.";
        wait; -- This stops the process from looping without a failure break
    end process;
end Behavioral;
