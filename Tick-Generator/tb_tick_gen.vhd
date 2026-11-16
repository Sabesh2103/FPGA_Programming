library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_tick_gen is
end entity tb_tick_gen;

architecture sim of tb_tick_gen is

    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal tick  : std_logic;
    signal count : unsigned(3 downto 0);

begin

    -- connect the design to these signals
    dut : entity work.tick_gen
        generic map (TICK_PERIOD => 10)
        port map (clk => clk, reset => reset, tick => tick, count => count);

    -- clock: flips every 5 ns, so the period is 10 ns
    clk <= not clk after 5 ns;

    -- reset: held high for 30 ns, then released
    process
    begin
        reset <= '1';
        wait for 30 ns;
        reset <= '0';
        wait;
    end process;

end architecture sim;
