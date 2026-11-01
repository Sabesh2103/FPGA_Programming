library ieee;
use ieee.std_logic_1164.all;


entity pulse_extender is
generic( Extended_cycle: positive:= 40 );
port(
	clk: in std_logic;
	rst: in std_logic;
	pulse_in: in std_logic;
	pulse_out: out std_logic
	);
end entity;
	
architecture rtl of pulse_extender is
signal pulse: integer range 0 to Extended_cycle := 0;

begin
	process(clk)
		begin	
			if rising_edge(clk) then
				if rst= '1' then	
					pulse<= 0;
					
				elsif pulse_in='1' then
					pulse<= Extended_cycle;
					
				elsif pulse> 0 then
					pulse<= pulse -1 ;
					
				end if;
			end if
	end process;
	pulse_out<= '1' when pulse> 0 else '0';
	
end architecture rtl;

