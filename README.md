# RISC-V CPU

A 32-bit RISC-V (RV32I) processor written in Verilog, built from scratch
as a personal project. Work in progress.

## Status

- [x] ALU (Arithmetic Logic Unit): 10 operations, 29 self-checking tests
- [x] Register file: 32 registers, 12 self-checking tests
- [x] Immediate generator: 5 formats, 10 self-checking tests
- [x] Decoder and control unit: 9 instruction types, 17 self-checking tests
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

Immediate generator:

```
verilator --binary --trace -Wall -Wno-fatal --top-module immgen_tb rtl/immgen.v tb/immgen_tb.sv && ./obj_dir/Vimmgen_tb
```

Decoder and control unit:

```
verilator --binary --trace -Wall -Wno-fatal --top-module decoder_tb rtl/decoder.v tb/decoder_tb.sv && ./obj_dir/Vdecoder_tb
```

Each prints `PASS` with the number of tests when everything is correct.