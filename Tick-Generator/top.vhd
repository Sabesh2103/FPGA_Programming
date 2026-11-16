library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        MAX10_CLK1_50 : in  std_logic;
        KEY           : in  std_logic_vector(1 downto 0);
        LEDR          : out std_logic_vector(9 downto 0)
    );
end entity top;

architecture rtl of top is
    signal reset_s : std_logic;
    signal count_s : unsigned(3 downto 0);
begin

    reset_s <= not KEY(0);

    u_tick : entity work.tick_gen
        generic map (TICK_PERIOD => 50_000_000)
        port map (
            clk   => MAX10_CLK1_50,
            reset => reset_s,
            tick  => open,
            count => count_s
        );

    LEDR(3 downto 0) <= std_logic_vector(count_s);
    LEDR(9 downto 4) <= (others => '0');

end architecture rtl;
