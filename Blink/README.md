# Blink: LED Blinker on the Terasic DE10-Lite (VHDL)

A first FPGA design for the Terasic DE10-Lite board. A clock divider built from a counter turns the 50 MHz board clock into a 1 Hz blink on the first red LED (`LEDR0`).

## Overview

| Item | Value |
|---|---|
| Board | Terasic DE10-Lite |
| FPGA | Intel/Altera MAX 10, `10M50DAF484C7G` |
| Language | VHDL |
| Tool | Quartus Prime Lite Edition 25.1 |
| Simulator | ModelSim (for testbenches) |
| Top-level entity | `Blink` |

## How it works

The board clock runs at 50 MHz, which is 50,000,000 ticks per second. That is far too fast to see, so the design counts clock ticks and flips the LED each time the count reaches a target.

- The LED must change state twice per second (on, then off) for a 1 Hz blink.
- That means one flip every 25,000,000 ticks, which is half a second.
- A counter that runs from 0 to 24,999,999 takes exactly 25,000,000 ticks.
- 25 bits are enough to hold 24,999,999 (2^25 = 33,554,432).

### Design rules used

- **Synchronous design:** everything changes only on the rising edge of `clk`.
- **Internal signal for the output:** an `out` port cannot be read in VHDL-93, so the LED state is kept in `led_reg` and connected to `LED` with `LED <= led_reg;`.
- **`to_unsigned(Max_Count, counter'length)`** converts the integer target into a bit pattern with the same width as the counter, so the two can be compared. The width must be large enough for the value, otherwise the upper bits are silently dropped.

### Useful formulas

```
Bits needed for a count up to N:   n = ceil(log2(N + 1))
Blink frequency:                   f_blink = f_clk / (2 * (MAX_COUNT + 1))
MAX_COUNT for a wanted frequency:  MAX_COUNT = f_clk / (2 * f_blink) - 1
```

Example: for a 2 Hz blink at 50 MHz, `MAX_COUNT = 12,499,999`, which needs 24 bits.

## Source code (`Blink.vhd`)

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Blink is
    port(
        clk : in  std_logic;
        LED : out std_logic
    );
end entity Blink;

architecture rtl of Blink is
    constant Max_Count : natural := 24999999;
    signal counter : unsigned(24 downto 0) := (others => '0');
    signal led_reg : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if counter = to_unsigned(Max_Count, counter'length) then
                counter <= (others => '0');
                led_reg <= not led_reg;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    LED <= led_reg;
end architecture rtl;
```

## Pin assignments

Verified on hardware: `LEDR0` blinks at about 1 Hz with these settings.

| Port | Pin | Board signal | I/O standard |
|---|---|---|---|
| `clk` | `PIN_P11` | 50 MHz clock (`MAX10_CLK1_50`) | 3.3-V LVTTL |
| `LED` | `PIN_A8` | `LEDR0` | 3.3-V LVTTL |

These lines in `Blink.qsf` set them directly:

```
set_location_assignment PIN_P11 -to clk
set_location_assignment PIN_A8 -to LED
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED
```

Optional: unused pins left floating make `LEDR1` to `LEDR9` glow faintly. To drive them low, add this to `Blink.qsf`:

```
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS OUTPUT DRIVING GROUND"
```

## Build and program

1. Open `Blink.qpf` in Quartus Prime Lite 25.1.
2. Compile with **Processing → Start Compilation** (Ctrl+L).
3. Connect the board with the USB cable, and open **Tools → Programmer**.
4. In **Hardware Setup…**, select **USB-Blaster [USB-0]**.
5. Load `output_files/Blink.sof`, tick **Program/Configure**, and click **Start**.
6. `LEDR0` should blink once per second.

The `.sof` file loads the design into the FPGA's RAM, so it is lost when the board loses power. Permanent programming uses the `.pof` file and the on-chip flash.

## Troubleshooting

- **Driver on Windows 11:** the DE10-Lite uses the original USB-Blaster. Install the driver from the Quartus `drivers\usb-blaster` folder via Device Manager. If Windows refuses it, switch off **Memory integrity** (Windows Security → Device security → Core isolation), restart, and try again. Running `DPInst` from that folder as administrator also helps.
- **Programmer shows "No Hardware":** replug the board, reopen **Hardware Setup…**, and double-click the USB-Blaster. If it stays empty, end the `jtagd` process in Task Manager and restart Quartus.
- **Device list in the project wizard:** choose family **MAX 10 (DA/DF/DC/SA/SF/SC)** and device `10M50DAF484C7G`. In the Programmer's chip list, pick `10M50DA`.
- **LED does not blink:** check that the pin assignments are saved and that you recompiled after setting them. The message "No exact pin location assignments" in the compile report means they are missing.
- **Timing warning about a missing `.sdc` file:** harmless for this design. To remove it, add an `.sdc` file with `create_clock -name clk -period 20 [get_ports clk]`.

## Ideas for extending the project

1. Change `Max_Count` for a different blink rate and recompute the bit width.
2. Add a second LED that blinks at another rate.
3. Connect a switch (`SW0`) directly to an LED to see combinational logic on hardware.
4. Add a reset input from a button (the `KEY` buttons are active low).
5. Write a testbench in ModelSim with a short `Max_Count`, so the simulation runs quickly.

## Author

Sabesh Charan Shyam Sundar
