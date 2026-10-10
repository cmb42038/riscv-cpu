module fetch_tb;
    logic        clk = 0;
    logic        rst;
    logic [31:0] pc_next;
    logic [31:0] pc_out;
    logic [31:0] instr;

    // address fed into the instruction memory
    pc   pc_dut   (.clk(clk), .rst(rst), .pc_next(pc_next), .pc(pc_out));
    imem imem_dut (.addr(pc_out), .instr(instr));

    // Clock flips every 5 time units  always #5 clk = ~clk;
    always #5 clk = ~clk;

    int tests  = 0;
    int errors = 0;

    // Wait for rising edge and a moment for outputs to settle
    task tick;
        @(posedge clk);
        #1;
    endtask

    // Compare to what we expect
    task check(
        input string       name,
        input logic [31:0] e_pc,
        input logic [31:0] e_instr
    );
        tests++;
        if (pc_out !== e_pc || instr !== e_instr) begin
            errors++;
            $display("FAIL: %s", name);
            $display("  got:      pc=%h instr=%h", pc_out, instr);
            $display("  expected: pc=%h instr=%h", e_pc, e_instr);
        end
    endtask

    initial begin
        // Reset puts the PC at 0
        rst = 1; pc_next = 32'd0;
        tick();
        check("reset",                32'd0,  32'h00500093);

        // Step through 4 bytes at a time
        rst = 0;
        pc_next = 32'd4;  tick();
        check("step to 4",            32'd4,  32'h00A00113);
        pc_next = 32'd8;  tick();
        check("step to 8",            32'd8,  32'h002081B3);
        pc_next = 32'd12; tick();
        check("step to 12",           32'd12, 32'h0000006F);

        pc_next = 32'd4;  tick();
        check("jump back to 4",       32'd4,  32'h00A00113);

        rst = 1; pc_next = 32'd8; tick();
        check("reset wins",           32'd0,  32'h00500093);

        // only changes on a clock edge
        rst = 0; pc_next = 32'd12; #1;
        check("holds until the tick", 32'd0,  32'h00500093);
        tick();
        check("then updates",         32'd12, 32'h0000006F);

        if (errors == 0)
            $display("PASS: %0d tests", tests);
        else
            $display("FAILED: %0d of %0d tests", errors, tests);
        $finish;
    end
endmodule