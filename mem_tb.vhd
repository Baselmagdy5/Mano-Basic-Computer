library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_memory_reference is
end tb_memory_reference;

architecture Behavioral of tb_memory_reference is
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
    -- DUT
    uut: ManoComputer 
        port map (
            clk      => clk,
            reset    => reset,
            inpr_val => inpr_val,
            outr_val => outr_val
        );

    -- Clock
    clk_process: process
    begin
        clk <= '0'; 
        wait for clk_period/2;
        clk <= '1'; 
        wait for clk_period/2;
    end process;

    -- Stimulus
    stim: process
    begin
        reset <= '1'; 
        wait for 40 ns;
        reset <= '0';

        wait for 250 ns;

        report "MEMORY-REFERENCE TEST FINISHED" severity note;
        wait;
    end process;
end Behavioral;

