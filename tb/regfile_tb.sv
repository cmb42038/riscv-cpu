module regfile_tb;
    // Signals that connect to the register file
    logic        clk = 0;
    logic        we = 0;
    logic [4:0]  rs1_addr = 0, rs2_addr = 0, rd_addr = 0;
    logic [31:0] rd_data = 0;
    logic [31:0] rs1_data, rs2_data;

    // The register file being tested
    regfile dut (.*);

    // The clock: flip every 5 time units, so one full tick every 10
    always #5 clk = ~clk;

    int tests_run = 0;

    // Write one value into one register
    task write_reg(input [4:0] addr, input [31:0] data);
        @(negedge clk);
        we = 1; rd_addr = addr; rd_data = data;
        @(negedge clk);
        we = 0;
    endtask

    // Read one register on both ports and compare
    task check_reg(input [4:0] addr, input [31:0] expected);
        rs1_addr = addr; rs2_addr = addr;
        #1;
        tests_run++;
        if (rs1_data !== expected || rs2_data !== expected) begin
            $display("FAIL x%0d port1=%h port2=%h expected=%h", addr, rs1_data, rs2_data, expected);
            $fatal;
        end
    endtask

    initial begin
        $dumpfile("regfile.vcd");
        $dumpvars;

        check_reg(5'd0, 32'd0);                  // x0 reads zero from the start

        write_reg(5'd1, 32'hDEADBEEF);
        check_reg(5'd1, 32'hDEADBEEF);           // a write is stored

        write_reg(5'd2, 32'h12345678);
        check_reg(5'd2, 32'h12345678);
        check_reg(5'd1, 32'hDEADBEEF);           // writing x2 didn't disturb x1

        write_reg(5'd0, 32'hFFFFFFFF);
        check_reg(5'd0, 32'd0);                  // writes to x0 are ignored

        write_reg(5'd31, 32'h0000ABCD);
        check_reg(5'd31, 32'h0000ABCD);          // the last register works

        // With write enable off, nothing should be stored
        @(negedge clk);
        we = 0; rd_addr = 5'd1; rd_data = 32'd0;
        @(negedge clk);
        check_reg(5'd1, 32'hDEADBEEF);

        // The two read ports can look at different registers at once
        rs1_addr = 5'd1; rs2_addr = 5'd2;
        #1;
        tests_run++;
        if (rs1_data !== 32'hDEADBEEF || rs2_data !== 32'h12345678) begin
            $display("FAIL two-port read: port1=%h port2=%h", rs1_data, rs2_data);
            $fatal;
        end

        write_reg(5'd1, 32'd5);
        check_reg(5'd1, 32'd5);            // a register can be overwritten

        write_reg(5'd2, 32'd0);
        check_reg(5'd2, 32'd0);            // a stored zero reads back as zero

        write_reg(5'd15, 32'hFFFFFFFF);
        check_reg(5'd15, 32'hFFFFFFFF);    // all 32 bits can hold a 1

        write_reg(5'd16, 32'hCAFEBABE);
        check_reg(5'd16, 32'hCAFEBABE);    // a register in the upper half works

        $display("PASS: %0d tests", tests_run);
        $finish;
    end
endmodule