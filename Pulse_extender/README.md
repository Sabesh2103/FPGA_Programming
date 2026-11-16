# Pulse Extender (Verilog / DE10-Lite)

A simple digital design that **stretches a short input pulse into a longer output pulse** of a fixed, configurable duration. Implemented on the Terasic **DE10-Lite** (Intel MAX 10 `10M50DAF484C7G`) FPGA board.

## What it does

A very short input pulse (even a single clock cycle, or a quick button press) is hard to see or use in downstream logic. The pulse extender detects the rising edge of the input and holds the output high for `N` clock cycles, so the pulse becomes long enough to observe, e.g. on an LED.

```
clk      : _|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_
pulse_in : ____|‾‾‾|______________________
pulse_out: ________|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|____
                   |<----- N cycles ---->|
```

## How it works

1. Synchronise the input to the clock (two flip-flops) and detect the rising edge.
2. On a rising edge, load a counter with `N` and set the output high.
3. Count down every clock cycle while the output is high.
4. When the counter reaches 0, clear the output.

If a new pulse arrives while the output is still high, the counter is reloaded (retriggerable).

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `EXTEND_CYCLES` | `50_000_000` | Output length in clock cycles (1 s at 50 MHz) |

Output duration = `EXTEND_CYCLES / f_clk`.

## Ports

| Port | Dir | Width | Description |
|------|-----|-------|-------------|
| `clk` | in | 1 | 50 MHz system clock (`MAX10_CLK1_50`) |
| `rst_n` | in | 1 | Active-low reset |
| `pulse_in` | in | 1 | Short input pulse (e.g. push button `KEY1`) |
| `pulse_out` | out | 1 | Extended output pulse (e.g. `LEDR0`) |

## Pin assignments (DE10-Lite)

| Signal | Board resource | Pin |
|--------|----------------|-----|
| `clk` | `MAX10_CLK1_50` | `PIN_P11` |
| `rst_n` | `KEY0` | `PIN_B8` |
| `pulse_in` | `KEY1` | `PIN_A7` |
| `pulse_out` | `LEDR0` | `PIN_A8` |

## Project structure

```
pulse_extender/
├── pulse_extender.v        # design source
├── tb_pulse_extender.v     # testbench
├── pulse_extender.qsf      # Quartus pin assignments
└── README.md
```

## Tools

- Intel Quartus Prime Lite
- ModelSim / Questa (Intel FPGA Edition)
- Terasic DE10-Lite board + USB-Blaster (built in)

## Simulation

1. Compile `pulse_extender.v` and `tb_pulse_extender.v` in ModelSim.
2. Set `EXTEND_CYCLES` to a small value (e.g. `10`) in the testbench.
3. Run and check that `pulse_out` stays high for exactly `EXTEND_CYCLES` cycles after each `pulse_in` rising edge.

## Build and program

1. Open the project in Quartus Prime and set the device to `10M50DAF484C7G`.
2. Import the pin assignments.
3. Run Processing → Start Compilation.
4. Open Programmer, select USB-Blaster, load the `.sof` file and click Start.

## Testing on the board

1. Press `KEY1`: `LEDR0` lights up and stays on for the configured time.
2. Press `KEY0` to reset the output.

## Possible improvements

- Add a debouncer on `pulse_in`.
- Select the extension length with the slide switches.
- Add a non-retriggerable mode.

## Author

Sabesh Charan Shyam Sundar. Part of my FPGA learning projects on the DE10-Lite.
