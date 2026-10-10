module decoder_tb;
    // Wires connecting to the decoder
    logic [31:0] instr;
    logic        reg_write;
    logic [2:0]  imm_sel;
    logic [1:0]  alu_a_sel;
    logic        alu_b_sel;
    logic [3:0]  alu_op;
    logic        mem_write;
    logic [1:0]  result_sel;
    logic        branch;
    logic        jump;

    // The decoder being tested
    decoder dut (.*);

    // Same names as decoder.v, so the checks below are readable
    localparam OP_ADD  = 4'd0;
    localparam OP_SUB  = 4'd1;
    localparam OP_AND  = 4'd2;
    localparam OP_SRA  = 4'd7;
    localparam OP_SLT  = 4'd8;
    localparam OP_SLTU = 4'd9;

    localparam IMM_I = 3'd0;
    localparam IMM_S = 3'd1;
    localparam IMM_B = 3'd2;
    localparam IMM_U = 3'd3;
    localparam IMM_J = 3'd4;

    localparam A_RS1  = 2'd0;
    localparam A_PC   = 2'd1;
    localparam A_ZERO = 2'd2;

    localparam B_RS2 = 1'b0;
    localparam B_IMM = 1'b1;

    localparam RES_ALU = 2'd0;
    localparam RES_MEM = 2'd1;
    localparam RES_PC4 = 2'd2;

    int tests  = 0;
    int errors = 0;

    // Apply one instruction and compare all nine outputs to what we expect
    task check(
        input string       name,
        input logic [31:0] i,
        input logic        e_reg_write,
        input logic [2:0]  e_imm_sel,
        input logic [1:0]  e_alu_a_sel,
        input logic        e_alu_b_sel,
        input logic [3:0]  e_alu_op,
        input logic        e_mem_write,
        input logic [1:0]  e_result_sel,
        input logic        e_branch,
        input logic        e_jump
    );
        instr = i;
        #1;  // give the outputs time to update
        tests++;
        if (reg_write  !== e_reg_write  || imm_sel   !== e_imm_sel   ||
            alu_a_sel  !== e_alu_a_sel  || alu_b_sel !== e_alu_b_sel ||
            alu_op     !== e_alu_op     || mem_write !== e_mem_write ||
            result_sel !== e_result_sel || branch    !== e_branch    ||
            jump       !== e_jump) begin
            errors++;
            $display("FAIL: %s", name);
            $display("  got:      reg_write=%0d imm_sel=%0d a_sel=%0d b_sel=%0d alu_op=%0d mem_write=%0d result_sel=%0d branch=%0d jump=%0d",
                     reg_write, imm_sel, alu_a_sel, alu_b_sel, alu_op,
                     mem_write, result_sel, branch, jump);
            $display("  expected: reg_write=%0d imm_sel=%0d a_sel=%0d b_sel=%0d alu_op=%0d mem_write=%0d result_sel=%0d branch=%0d jump=%0d",
                     e_reg_write, e_imm_sel, e_alu_a_sel, e_alu_b_sel, e_alu_op,
                     e_mem_write, e_result_sel, e_branch, e_jump);
        end
    endtask

    initial begin
        // Order of the numbers after the instruction:
        // reg_write, imm_sel, alu_a_sel, alu_b_sel, alu_op, mem_write, result_sel, branch, jump

        // R-type
        check("add x3,x1,x2",   32'h002081B3, 1, IMM_I, A_RS1,  B_RS2, OP_ADD,  0, RES_ALU, 0, 0);
        check("sub x3,x1,x2",   32'h402081B3, 1, IMM_I, A_RS1,  B_RS2, OP_SUB,  0, RES_ALU, 0, 0);
        check("sra x3,x1,x2",   32'h4020D1B3, 1, IMM_I, A_RS1,  B_RS2, OP_SRA,  0, RES_ALU, 0, 0);
        check("and x3,x1,x2",   32'h0020F1B3, 1, IMM_I, A_RS1,  B_RS2, OP_AND,  0, RES_ALU, 0, 0);

        // Register-immediate
        check("addi x1,x0,5",   32'h00500093, 1, IMM_I, A_RS1,  B_IMM, OP_ADD,  0, RES_ALU, 0, 0);
        check("addi x1,x0,-1",  32'hFFF00093, 1, IMM_I, A_RS1,  B_IMM, OP_ADD,  0, RES_ALU, 0, 0);
        check("srai x1,x2,3",   32'h40315093, 1, IMM_I, A_RS1,  B_IMM, OP_SRA,  0, RES_ALU, 0, 0);

        // Load and store
        check("lw x2,8(x3)",    32'h0081A103, 1, IMM_I, A_RS1,  B_IMM, OP_ADD,  0, RES_MEM, 0, 0);
        check("sw x2,8(x3)",    32'h0021A423, 0, IMM_S, A_RS1,  B_IMM, OP_ADD,  1, RES_ALU, 0, 0);

        // Branches
        check("beq x1,x2,8",    32'h00208463, 0, IMM_B, A_RS1,  B_RS2, OP_SUB,  0, RES_ALU, 1, 0);
        check("blt x1,x2,8",    32'h0020C463, 0, IMM_B, A_RS1,  B_RS2, OP_SLT,  0, RES_ALU, 1, 0);
        check("bgeu x1,x2,8",   32'h0020F463, 0, IMM_B, A_RS1,  B_RS2, OP_SLTU, 0, RES_ALU, 1, 0);

        // Jumps
        check("jal x1,8",       32'h008000EF, 1, IMM_J, A_PC,   B_IMM, OP_ADD,  0, RES_PC4, 0, 1);
        check("jalr x0,0(x1)",  32'h00008067, 1, IMM_I, A_RS1,  B_IMM, OP_ADD,  0, RES_PC4, 0, 1);

        // Upper immediates
        check("lui x1,0x12345", 32'h123450B7, 1, IMM_U, A_ZERO, B_IMM, OP_ADD,  0, RES_ALU, 0, 0);
        check("auipc x1,0x1",   32'h00001097, 1, IMM_U, A_PC,   B_IMM, OP_ADD,  0, RES_ALU, 0, 0);

        // Unknown opcode: nothing should be written anywhere
        check("unknown (all 0)", 32'h00000000, 0, IMM_I, A_RS1, B_RS2, OP_ADD,  0, RES_ALU, 0, 0);

        if (errors == 0)
            $display("PASS: %0d tests", tests);
        else
            $display("FAILED: %0d of %0d tests", errors, tests);
        $finish;
    end
endmodule