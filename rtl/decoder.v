module decoder (
    input  wire [31:0] instr,       // the full 32-bit instruction
    output reg         reg_write,   // 1 = write the result into register rd
    output reg  [2:0]  imm_sel,     // immediate format (goes to immgen)
    output reg  [1:0]  alu_a_sel,   // ALU input a: rs1, PC, or zero
    output reg         alu_b_sel,   // ALU input b: rs2 or immediate
    output reg  [3:0]  alu_op,      // ALU operation (goes to alu)
    output reg         mem_write,   // 1 = store to data memory
    output reg  [1:0]  result_sel,  // what goes to rd: ALU, memory, or PC + 4
    output reg         branch,      // 1 = conditional branch
    output reg         jump         // 1 = unconditional jump
);
    // Fields pulled out of the instruction
    wire [6:0] opcode = instr[6:0];    // what type of instruction
    wire [2:0] funct3 = instr[14:12];  // picks the operation within a type
    wire       alt    = instr[30];     // 1 = the alternate version (sub, sra)

    // The nine instruction types
    localparam OPC_R      = 7'b0110011;  // register-register math: add, sub, and, ...
    localparam OPC_OPIMM  = 7'b0010011;  // register-immediate math: addi, andi, ...
    localparam OPC_LOAD   = 7'b0000011;  // read from memory: lw, lb, ...
    localparam OPC_STORE  = 7'b0100011;  // write to memory: sw, sb, ...
    localparam OPC_BRANCH = 7'b1100011;  // conditional branch: beq, bne, blt, ...
    localparam OPC_JAL    = 7'b1101111;  // jump and link
    localparam OPC_JALR   = 7'b1100111;  // jump and link register
    localparam OPC_LUI    = 7'b0110111;  // load upper immediate
    localparam OPC_AUIPC  = 7'b0010111;  // add upper immediate to PC

    // ALU operation codes (must match alu.v)
    localparam OP_ADD  = 4'd0;
    localparam OP_SUB  = 4'd1;
    localparam OP_AND  = 4'd2;
    localparam OP_OR   = 4'd3;
    localparam OP_XOR  = 4'd4;
    localparam OP_SLL  = 4'd5;
    localparam OP_SRL  = 4'd6;
    localparam OP_SRA  = 4'd7;
    localparam OP_SLT  = 4'd8;
    localparam OP_SLTU = 4'd9;

    // Immediate formats (must match immgen.v)
    localparam IMM_I = 3'd0;
    localparam IMM_S = 3'd1;
    localparam IMM_B = 3'd2;
    localparam IMM_U = 3'd3;
    localparam IMM_J = 3'd4;

    // Choices for ALU input a
    localparam A_RS1  = 2'd0;
    localparam A_PC   = 2'd1;
    localparam A_ZERO = 2'd2;

    // Choices for ALU input b
    localparam B_RS2 = 1'b0;
    localparam B_IMM = 1'b1;

    // Choices for what gets written to rd
    localparam RES_ALU = 2'd0;
    localparam RES_MEM = 2'd1;
    localparam RES_PC4 = 2'd2;

    always @(*) begin
        // Defaults: an instruction that changes nothing
        reg_write  = 1'b0;
        imm_sel    = IMM_I;
        alu_a_sel  = A_RS1;
        alu_b_sel  = B_RS2;
        alu_op     = OP_ADD;
        mem_write  = 1'b0;
        result_sel = RES_ALU;
        branch     = 1'b0;
        jump       = 1'b0;

        case (opcode)
            OPC_R: begin
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_op = alt ? OP_SUB : OP_ADD;
                    3'b001: alu_op = OP_SLL;
                    3'b010: alu_op = OP_SLT;
                    3'b011: alu_op = OP_SLTU;
                    3'b100: alu_op = OP_XOR;
                    3'b101: alu_op = alt ? OP_SRA : OP_SRL;
                    3'b110: alu_op = OP_OR;
                    3'b111: alu_op = OP_AND;
                endcase
            end

            OPC_OPIMM: begin
                reg_write = 1'b1;
                imm_sel   = IMM_I;
                alu_b_sel = B_IMM;
                case (funct3)
                    3'b000: alu_op = OP_ADD;   // addi (there is no subi)
                    3'b001: alu_op = OP_SLL;
                    3'b010: alu_op = OP_SLT;
                    3'b011: alu_op = OP_SLTU;
                    3'b100: alu_op = OP_XOR;
                    3'b101: alu_op = alt ? OP_SRA : OP_SRL;
                    3'b110: alu_op = OP_OR;
                    3'b111: alu_op = OP_AND;
                endcase
            end

            OPC_LOAD: begin
                reg_write  = 1'b1;
                imm_sel    = IMM_I;
                alu_b_sel  = B_IMM;
                result_sel = RES_MEM;
            end

            OPC_STORE: begin
                mem_write = 1'b1;
                imm_sel   = IMM_S;
                alu_b_sel = B_IMM;
            end

            OPC_BRANCH: begin
                branch  = 1'b1;
                imm_sel = IMM_B;
                case (funct3)
                    3'b000:  alu_op = OP_SUB;   // beq
                    3'b001:  alu_op = OP_SUB;   // bne
                    3'b100:  alu_op = OP_SLT;   // blt
                    3'b101:  alu_op = OP_SLT;   // bge
                    3'b110:  alu_op = OP_SLTU;  // bltu
                    3'b111:  alu_op = OP_SLTU;  // bgeu
                    default: alu_op = OP_SUB;   // 010 and 011 are not real branches
                endcase
            end

            OPC_JAL: begin
                reg_write  = 1'b1;
                imm_sel    = IMM_J;
                alu_a_sel  = A_PC;
                alu_b_sel  = B_IMM;
                result_sel = RES_PC4;
                jump       = 1'b1;
            end

            OPC_JALR: begin
                reg_write  = 1'b1;
                imm_sel    = IMM_I;
                alu_a_sel  = A_RS1;
                alu_b_sel  = B_IMM;
                result_sel = RES_PC4;
                jump       = 1'b1;
            end

            OPC_LUI: begin
                reg_write = 1'b1;
                imm_sel   = IMM_U;
                alu_a_sel = A_ZERO;
                alu_b_sel = B_IMM;
            end

            OPC_AUIPC: begin
                reg_write = 1'b1;
                imm_sel   = IMM_U;
                alu_a_sel = A_PC;
                alu_b_sel = B_IMM;
            end

            default: begin
                // unknown opcode: keep the do-nothing defaults
            end
        endcase
    end
endmodule