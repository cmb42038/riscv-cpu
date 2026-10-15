// c program testbench
// runs test_c.hex (built from programs/test_c.c) on the whole cpu
// main() returns 285, which ends up in a0 (x10)

module c_tb;

    reg clk = 0;
    reg rst = 1;
    wire [31:0] pc_out;

    integer errors = 0;

    // load the C program instead of test.hex
    cpu #(.HEX_FILE("programs/test_c.hex")) dut (
        .clk(clk),
        .rst(rst),
        .switches(16'd0),   // not used in this test
        .leds(),            // not used in this test
        .pc_out(pc_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("c_tb.vcd");
        $dumpvars(0, c_tb);

        // reset so pc starts at 0
        #20;
        rst = 0;

        // 2000 clock cycles, way more than the program needs
        #20000;

        // a0 holds what main returned
        if (dut.core.regfile_inst.regs[10] != 285) begin
            $display("a0 wrong: got %0d, wanted 285", $signed(dut.core.regfile_inst.regs[10]));
            errors = errors + 1;
        end

        // sp should be back where start.S put it, if every function cleaned up its stack
        if (dut.core.regfile_inst.regs[2] != 32'h400) begin
            $display("sp wrong: got %h, wanted 400", dut.core.regfile_inst.regs[2]);
            errors = errors + 1;
        end

        // the done loop in start.S is at address 12
        if (pc_out != 12) begin
            $display("pc wrong: got %0d, wanted 12", pc_out);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("PASS: 3 tests");
        else
            $display("FAIL: %0d errors", errors);

        $finish;
    end

endmodule
