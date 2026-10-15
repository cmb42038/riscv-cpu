// io testbench
// runs io_test.hex
// sets the switches, checks leds and what main returned

module io_tb;

    reg clk = 0;
    reg rst = 1;
    reg [15:0] switches = 16'hA5A5;
    wire [15:0] leds;
    wire [31:0] pc_out;

    integer errors = 0;

    cpu #(.HEX_FILE("programs/io_test.hex")) dut (
        .clk(clk),
        .rst(rst),
        .switches(switches),
        .leds(leds),
        .pc_out(pc_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("io_tb.vcd");
        $dumpvars(0, io_tb);

        // reset
        #20;
        rst = 0;

        // 1000 clock cycles
        #10000;

        // read leds back after setting to 5
        if (dut.core.regfile_inst.regs[10] != 5) begin
            $display("a0 wrong: got %0d, wanted 5", dut.core.regfile_inst.regs[10]);
            errors = errors + 1;
        end

        // switches plus one
        if (leds != 16'hA5A6) begin
            $display("leds wrong: got %h, wanted a5a6", leds);
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