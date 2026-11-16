# Tick Generator with Pulse Counter (VHDL, DE10-Lite)

A synchronous tick generator and pulse counter written in VHDL and implemented on the Terasic DE10-Lite board (Intel MAX 10, 10M50DAF484C7G).

## Overview

The design divides the board's 50 MHz clock to produce a one-clock-cycle pulse (`tick`) every `TICK_PERIOD` cycles. A second 4-bit counter increments on each tick and wraps from 15 back to 0. On the board, the counter value is shown in binary on four red LEDs, and with `TICK_PERIOD = 50_000_000` it advances once per second.

## Features

- Parameterised period through the generic `TICK_PERIOD`, so the same block works in simulation (10) and on the board (50,000,000)
- Pulse output that is high for exactly one clock cycle
- 4-bit `unsigned` pulse counter that wraps 15 → 0
- Synchronous, active-high reset that clears both counters
- Top-level wrapper that inverts the active-low push button (`KEY0`) to drive the reset

## Files

| File | Description |
|---|---|
| `tick_gen.vhd` | Tick generator and pulse counter |
| `top.vhd` | Top-level wrapper that maps the design to the board's clock, button and LEDs |
| `tb_tick_gen.vhd` | Testbench for ModelSim |

## How it works

- `period_count` counts clock edges from 0 to `TICK_PERIOD - 1`.
- On the last count, `tick_i` is set to `'1'` for one cycle, `period_count` restarts at 0, and `count_i` increments.
- On every other edge, `tick_i` is forced back to `'0'`, which makes the pulse exactly one cycle wide.
- The 4-bit counter wraps by itself because of `unsigned` arithmetic.

## Simulation (ModelSim)

```
vlib work
vcom -2008 tick_gen.vhd tb_tick_gen.vhd
vsim work.tb_tick_gen
add wave -r *
run 2 us
```

With `TICK_PERIOD = 10` and a 10 ns clock, `tick` pulses every 100 ns and `count` goes up by one on each pulse.

## Hardware (Quartus Prime Lite)

1. Create a project with `top` as the top-level entity and device `10M50DAF484C7G`.
2. Add `tick_gen.vhd` and `top.vhd`.
3. Assign pins (I/O standard 3.3-V LVTTL):

| Signal | Pin |
|---|---|
| `MAX10_CLK1_50` | P11 |
| `KEY[0]` | B8 |
| `LEDR[0]` | A8 |
| `LEDR[1]` | A9 |
| `LEDR[2]` | A10 |
| `LEDR[3]` | B10 |

4. Compile, then program `output_files/top.sof` with the USB-Blaster.

## Result

The four right-most LEDs count up in binary once per second (0000 → 1111) and wrap back to 0000. Holding `KEY0` resets the counter to 0000.

## What I learned

- Synchronous design and clock division
- Reusable blocks with generics
- Type handling with `unsigned` and `std_logic_vector`
- The flow from RTL simulation in ModelSim to a working design on an FPGA in Quartus

## Possible extensions

- Add an enable input (for example, a switch) that pauses counting
- Stretch the tick pulse so it is visible on an LED
- Show the count on the 7-segment display
- Add a self-checking testbench with assertions
