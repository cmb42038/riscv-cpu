# RISC-V CPU

A 32-bit RISC-V (RV32I) processor written in Verilog, built from scratch
as a personal project. Work in progress.

## Status

- [x] ALU (Arithmetic Logic Unit): 10 operations, 29 self-checking tests
- [x] Register file: 32 registers, 12 self-checking tests
- [x] Immediate generator: 5 formats, 10 self-checking tests
- [x] Decoder and control unit: 9 instruction types, 17 self-checking tests
- [x] Program counter and instruction memory: 8 self-checking tests
- [x] Data memory: byte, half and word loads and stores, 15 self-checking tests
- [x] Single-cycle top level: 4 self-checking tests
- [x] Core split from memories (`rtl/cpu_core.v`)
- [x] Runs a compiled C program (loops, function calls, byte and word loads and stores)
- [x] Memory-mapped LEDs and switches: 3 self-checking tests
- [ ] Run on the Basys 3 FPGA
- [ ] 5-stage pipeline

## Running the tests

Requires Verilator 5 or newer. Each command builds a testbench and runs it.

ALU:

```
verilator --binary --trace -Wall -Wno-fatal --top-module alu_tb rtl/alu.v tb/alu_tb.sv && ./obj_dir/Valu_tb
```

Register file:

```
verilator --binary --trace -Wall -Wno-fatal --top-module regfile_tb rtl/regfile.v tb/regfile_tb.sv && ./obj_dir/Vregfile_tb
```

Immediate generator:

```
verilator --binary --trace -Wall -Wno-fatal --top-module immgen_tb rtl/immgen.v tb/immgen_tb.sv && ./obj_dir/Vimmgen_tb
```

Decoder and control unit:

```
verilator --binary --trace -Wall -Wno-fatal --top-module decoder_tb rtl/decoder.v tb/decoder_tb.sv && ./obj_dir/Vdecoder_tb
```

Program counter and instruction memory:

```
verilator --binary --trace -Wall -Wno-fatal --top-module fetch_tb rtl/pc.v rtl/imem.v tb/fetch_tb.sv && ./obj_dir/Vfetch_tb
```

Data memory:

```
verilator --binary --trace -Wall -Wno-fatal --top-module dmem_tb rtl/dmem.v tb/dmem_tb.sv && ./obj_dir/Vdmem_tb
```

Full CPU (runs `programs/test.hex` and checks the result):

```
verilator --binary --trace -Wall -Wno-fatal --top-module cpu_tb rtl/*.v tb/cpu_tb.sv && ./obj_dir/Vcpu_tb
```

Each prints `PASS` with the number of tests when everything is correct.

## Running a C program

`programs/test_c.c` is compiled with the RISC-V GCC compiler. `programs/start.S`
sets up the stack and calls `main`, and `programs/link.ld` puts the code at address 0.
To install the compiler on Ubuntu or WSL:

```
sudo apt install gcc-riscv64-unknown-elf
```

Build the program (makes `programs/test_c.hex`):

```
./programs/build.sh test_c
```

Run it on the CPU (checks that `main` returned 285):

```
verilator --binary --trace -Wall -Wno-fatal --top-module c_tb rtl/*.v tb/c_tb.sv && ./obj_dir/Vc_tb
```

## LEDs and switches

`rtl/cpu.v` connects the core to the memories and to two I/O addresses:

| Address | What it is |
|---|---|
| `0x00000000` - `0x000003FF` | Data memory (1 KB) |
| `0x80000000` | LEDs (store to set them, load to read back) |
| `0x80000004` | Switches (load only) |

`programs/io_test.c` sets LEDs, reads back, copies switches to the LEDs.
Build it and run it:

```
./programs/build.sh io_test
verilator --binary --trace -Wall -Wno-fatal --top-module io_tb rtl/*.v tb/io_tb.sv && ./obj_dir/Vio_tb
```
