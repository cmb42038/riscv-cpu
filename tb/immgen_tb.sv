module immgen_tb;
    logic [31:0] instr, imm;
    logic [2:0]  imm_sel;
    int tests = 0, fails = 0;

    // The module being tested ("dut" = device under test)
    immgen dut (.instr(instr), .imm_sel(imm_sel), .imm(imm));

    // Feed in one instruction and compare the output to what we expect
    task check(input [2:0] sel, input [31:0] i, input [31:0] expected);
        imm_sel = sel;
        instr   = i;
        #1;                       // wait a moment for the output to settle
        tests++;
        if (imm !== expected) begin
            fails++;
            $display("FAIL: sel=%0d instr=%h got=%h expected=%h", sel, i, imm, expected);
        end
    endtask

    initial begin
        $dumpfile("immgen.vcd");
        $dumpvars(0, immgen_tb);

        // I-type (format 0)
        check(3'd0, 32'h00500093, 32'h00000005);  // addi x1, x0, 5
        check(3'd0, 32'hFFF00093, 32'hFFFFFFFF);  // addi x1, x0, -1

        // S-type (format 1)
        check(3'd1, 32'h0020A423, 32'h00000008);  // sw x2, 8(x1)
        check(3'd1, 32'hFE20AE23, 32'hFFFFFFFC);  // sw x2, -4(x1)

        // B-type (format 2)
        check(3'd2, 32'h00208463, 32'h00000008);  // beq x1, x2, +8
        check(3'd2, 32'hFE208EE3, 32'hFFFFFFFC);  // beq x1, x2, -4

        // U-type (format 3)
        check(3'd3, 32'h123450B7, 32'h12345000);  // lui x1, 0x12345
        check(3'd3, 32'hFFFFF0B7, 32'hFFFFF000);  // lui x1, 0xFFFFF

        // J-type (format 4)
        check(3'd4, 32'h008000EF, 32'h00000008);  // jal x1, +8
        check(3'd4, 32'hFFDFF0EF, 32'hFFFFFFFC);  // jal x1, -4

        if (fails == 0) $display("PASS: %0d tests", tests);
        else            $display("FAILED: %0d of %0d tests", fails, tests);
        $finish;
    end
endmodule