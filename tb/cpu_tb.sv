// cpu testbench
// runs test.hex and checks x1, x2, x3 and the pc at the end
// program: x1 = 5, x2 = 10, x3 = x1 + x2, then loop forever

module cpu_tb;

    reg clk = 0;
    reg rst = 1;
    wire [31:0] pc_out;

    integer errors = 0;

    cpu dut (
        .clk(clk),
        .rst(rst),
        .switches(16'd0),   // not used in this test
        .leds(),            // not used in this test
        .pc_out(pc_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);

        // reset so pc starts at 0
        #20;
        rst = 0;

        #100;

        if (dut.core.regfile_inst.regs[1] != 5) begin
            $display("x1 wrong: got %0d, wanted 5", dut.core.regfile_inst.regs[1]);
            errors = errors + 1;
        end

        if (dut.core.regfile_inst.regs[2] != 10) begin
            $display("x2 wrong: got %0d, wanted 10", dut.core.regfile_inst.regs[2]);
            errors = errors + 1;
        end

        if (dut.core.regfile_inst.regs[3] != 15) begin
            $display("x3 wrong: got %0d, wanted 15", dut.core.regfile_inst.regs[3]);
            errors = errors + 1;
        end

        // jal x0, 0 is at address 12 so the pc should be stuck there
        if (pc_out != 12) begin
            $display("pc wrong: got %0d, wanted 12", pc_out);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("PASS: 4 tests");
        else
            $display("FAIL: %0d errors", errors);

        $finish;
    end

endmodule