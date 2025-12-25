library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_register_reference is
end tb_register_reference;

architecture Behavioral of tb_register_reference is
    component ManoComputer
        port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            inpr_val : in  std_logic_vector(7 downto 0);
            outr_val : out std_logic_vector(7 downto 0)
        );
    end component;

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal inpr_val : std_logic_vector(7 downto 0) := (others => '0');
    signal outr_val : std_logic_vector(7 downto 0);

    constant clk_period : time := 20 ns;
begin
    -- Instantiate DUT
    uut: ManoComputer 
        port map (
            clk      => clk,
            reset    => reset,
            inpr_val => inpr_val,
            outr_val => outr_val
        );

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim: process
    begin
        -- Apply reset
        reset <= '1';
        wait for 40 ns;
        reset <= '0';

        -- Wait long enough for all register-reference instructions
        wait for 600 ns;

        -- Informational message only
        report "REGISTER-REFERENCE TEST FINISHED" severity note;

        -- Stop simulation cleanly
        wait;
    end process;
end Behavioral;

