   # RISC-V CPU

   A 32-bit RISC-V (RV32I) processor written in Verilog, built from scratch
   as a personal project. Work in progress.

   ## Status

   - [x] ALU (Arithmetic Logic Unit): 10 operations, 19 self-checking tests
   - [ ] Register file
   - [ ] Immediate generator
   - [ ] Decoder and control unit
   - [ ] Single-cycle top level

   ## Running the tests

   Requires Verilator 5 or newer.

       verilator --binary --trace -Wall -Wno-fatal --top-module alu_tb rtl/alu.v tb/alu_tb.sv
       ./obj_dir/Valu_tb