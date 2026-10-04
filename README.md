# RISC-V CPU

A 32-bit RISC-V (RV32I) processor written in Verilog, built from scratch
as a personal project. Work in progress.

## Status

- [x] ALU (Arithmetic Logic Unit): 10 operations, 29 self-checking tests
- [x] Register file: 32 registers, 12 self-checking tests
- [ ] Immediate generator
- [ ] Decoder and control unit
- [ ] Single-cycle top level

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

Each prints `PASS` with the number of tests when everything is correct.