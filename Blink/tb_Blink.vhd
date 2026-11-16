-- Self-checking testbench for the Blink design (DE10-Lite, 50 MHz clock).
--
-- The real design counts to 24,999,999, which takes 25 million clock cycles per
-- LED toggle and is far too slow to simulate comfortably. This testbench
-- therefore overrides MAX_COUNT with a small value through a generic.
-- Blink.vhd therefore has a generic MAX_COUNT (default 24999999), supplied with this file.
--
-- What it checks:
--   1. LED starts at '0'.
--   2. The first toggle happens exactly after (MAX_COUNT + 1) clock cycles.
--   3. Every following toggle is exactly (MAX_COUNT + 1) clock cycles apart.
--   4. LED alternates 1, 0, 1, 0, ... and never glitches.
--
-- ModelSim:
--   vlib work
--   vcom -93 Blink.vhd tb_Blink.vhd
--   vsim work.tb_Blink
--   add wave -r /*
--   run -all

library ieee;
use ieee.std_logic_1164.all;

entity tb_Blink is
end entity tb_Blink;

architecture sim of tb_Blink is

    -- Small target so the simulation finishes quickly.
    -- Expected toggle spacing = (TB_MAX_COUNT + 1) clock cycles.
    constant TB_MAX_COUNT : natural := 9;

    constant CLK_PERIOD   : time := 20 ns;   -- 50 MHz
    constant HALF_PERIOD  : time := (TB_MAX_COUNT + 1) * CLK_PERIOD;
    constant FIRST_TOGGLE : time := CLK_PERIOD / 2 + TB_MAX_COUNT * CLK_PERIOD;

    constant N_TOGGLES    : natural := 6;    -- how many LED toggles to verify

    signal clk      : std_logic := '0';
    signal LED      : std_logic;
    signal sim_done : boolean   := false;

begin

    -- Device under test: Blink with a shortened MAX_COUNT
    dut : entity work.Blink
        generic map (MAX_COUNT => TB_MAX_COUNT)
        port map (
            clk => clk,
            LED => LED
        );

    -- 50 MHz clock; stops when the checks are finished so the simulation ends
    clk_gen : process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process clk_gen;

    -- Checker: look at every LED change and compare it with the expected timing
    check : process
        variable t_prev : time    := 0 ns;
        variable n      : natural := 0;
    begin
        assert LED = '0'
            report "LED should start at '0'"
            severity error;

        while n < N_TOGGLES loop
            wait on LED;
            n := n + 1;

            if n = 1 then
                assert now = FIRST_TOGGLE
                    report "First toggle at wrong time: " & time'image(now) &
                           ", expected " & time'image(FIRST_TOGGLE)
                    severity error;
            else
                assert (now - t_prev) = HALF_PERIOD
                    report "Toggle spacing wrong: " & time'image(now - t_prev) &
                           ", expected " & time'image(HALF_PERIOD)
                    severity error;
            end if;

            -- odd-numbered toggles go to '1', even-numbered toggles go to '0'
            if n mod 2 = 1 then
                assert LED = '1'
                    report "Toggle " & natural'image(n) & ": LED should be '1'"
                    severity error;
            else
                assert LED = '0'
                    report "Toggle " & natural'image(n) & ": LED should be '0'"
                    severity error;
            end if;

            t_prev := now;
        end loop;

        report "Blink testbench finished: " & natural'image(N_TOGGLES) &
               " toggles checked." severity note;
        sim_done <= true;
        wait;
    end process check;

    -- Watchdog: fails the test if the LED never toggles the expected number of times
    watchdog : process
    begin
        wait for (N_TOGGLES + 2) * HALF_PERIOD;
        assert sim_done
            report "TIMEOUT: expected LED toggles did not happen"
            severity failure;
        wait;
    end process watchdog;

end architecture sim;
