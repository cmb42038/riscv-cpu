module alu_tb;
    // Signals that connect to the ALU
    logic [31:0] a, b, y;
    logic [3:0]  op;
    logic        zero;

    // The ALU being tested
    alu dut (.*);

    // Same operation codes as in alu.v
    localparam OP_ADD = 4'd0, OP_SUB = 4'd1, OP_AND = 4'd2, OP_OR  = 4'd3,
               OP_XOR = 4'd4, OP_SLL = 4'd5, OP_SRL = 4'd6, OP_SRA = 4'd7,
               OP_SLT = 4'd8, OP_SLTU = 4'd9;

    int tests_run = 0;

    // Apply one set of inputs and compare the result
    task test(input [3:0] t_op, input [31:0] t_a, input [31:0] t_b, input [31:0] expected);
        op = t_op; a = t_a; b = t_b;
        #1;
        tests_run++;
        if (y !== expected || zero !== (expected == 0)) begin
            $display("FAIL op=%0d a=%h b=%h got=%h expected=%h zero=%b", op, a, b, y, expected, zero);
            $fatal;
        end
    endtask

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars;

        test(OP_ADD,  32'd5,        32'd7,        32'd12);
        test(OP_ADD,  32'hFFFFFFFF, 32'd1,        32'd0);         // -1 + 1 = 0
        test(OP_SUB,  32'd5,        32'd7,        32'hFFFFFFFE);  // 5 - 7 = -2
        test(OP_SUB,  32'd7,        32'd7,        32'd0);
        test(OP_AND,  32'hF0F0F0F0, 32'h0FF00FF0, 32'h00F000F0);
        test(OP_OR,   32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF);
        test(OP_XOR,  32'd5,        32'd7,        32'd2);
        test(OP_XOR,  32'hFFFFFFFF, 32'hFFFFFFFF, 32'd0);
        test(OP_SLL,  32'd5,        32'd1,        32'd10);
        test(OP_SLL,  32'd1,        32'd31,       32'h80000000);
        test(OP_SLL,  32'd1,        32'd32,       32'd1);         // only low 5 bits of b count
        test(OP_SRL,  32'h80000000, 32'd4,        32'h08000000);  // zeros come in
        test(OP_SRA,  32'h80000000, 32'd4,        32'hF8000000);  // sign bit copied in
        test(OP_SRA,  32'h00000040, 32'd2,        32'h00000010);
        test(OP_SLT,  32'd5,        32'd7,        32'd1);
        test(OP_SLT,  32'd7,        32'd5,        32'd0);
        test(OP_SLT,  32'hFFFFFFFF, 32'd1,        32'd1);         // -1 < 1
        test(OP_SLTU, 32'hFFFFFFFF, 32'd1,        32'd0);         // 4294967295 is not < 1
        test(OP_SLTU, 32'd5,        32'd7,        32'd1);

        $display("PASS: %0d tests", tests_run);
        $finish;
    end
endmodule