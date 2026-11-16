library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Blink is
port(
	clk: in std_logic;
	LED: out std_logic
);
end entity Blink;

architecture rtl of Blink is

constant Max_Count: natural:=24999999;
signal counter: unsigned(24 downto 0):=(others=>'0');
signal led_reg: std_logic:='0';

begin
process(clk)
	begin
		if rising_edge(clk) then
			if counter= to_unsigned(Max_Count, counter'length) then
				counter<=(others=>'0');
				led_reg<= not led_reg;
			else
			
				counter<= counter+1;
				
			end if;
			
		end if;
		
end process;
LED<=led_reg;

end architecture rtl;

		
		