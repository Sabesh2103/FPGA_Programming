--library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tick_gen is
generic(
	TICK_PERIOD: positive:= 10
	);
port(

	clk: in std_logic;
	reset: in std_logic;
	tick: out std_logic;
	count: out unsigned(3 downto 0)
	
);
end entity tick_gen;

architecture rtl of tick_gen is
signal count_i: unsigned(3 downto 0):=(others=>'0');
signal tick_i: std_logic:='0';
signal period_count: integer range 0 to TICK_PERIOD-1:=0;

begin
	process(clk)
		begin
			if rising_edge(clk) then
				if reset='1' then
					period_count<=0;
					tick_i<='0';
					count_i<= (others=> '0');
				else
					tick_i<='0';
					
					if period_count= TICK_PERIOD-1 then
						tick_i<='1';
						count_i<= count_i+1;
						period_count<=0;
					else
						period_count<= period_count+1;
					
				end if;
			end if;
		end if;
	end process;
		
	tick<= tick_i;
	count<= count_i;
	
end architecture rtl;
		

