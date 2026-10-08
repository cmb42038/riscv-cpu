module immgen (
    input  wire [31:0] instr,    // the full 32-bit instruction
    input  wire [2:0]  imm_sel,  // which format to use (set by the decoder)
    output reg  [31:0] imm       // the 32-bit immediate
);
    // Names for the five immediate formats
    localparam IMM_I = 3'd0;
    localparam IMM_S = 3'd1;
    localparam IMM_B = 3'd2;
    localparam IMM_U = 3'd3;
    localparam IMM_J = 3'd4;

    always @(*) begin
        case (imm_sel)
            IMM_I:   imm = {{20{instr[31]}}, instr[31:20]};
            IMM_S:   imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            IMM_B:   imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            IMM_U:   imm = {instr[31:12], 12'd0};
            IMM_J:   imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            default: imm = 32'd0;
        endcase
    end
endmodule