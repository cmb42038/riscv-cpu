// top level for single cycle cpu
module cpu #(
    parameter HEX_FILE = "programs/test.hex"   // program to run, passed down to imem
) (
    input wire clk,
    input wire rst,
    output wire [31:0] pc_out
);

    wire [31:0] pc_next;
    wire [31:0] instr;

    // control signals from decoder
    wire reg_write;
    wire [2:0] imm_sel;
    wire [1:0] alu_a_sel;
    wire alu_b_sel;
    wire [3:0] alu_op;
    wire mem_write;
    wire [1:0] result_sel;
    wire branch;
    wire jump;

    wire [31:0] imm;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] alu_y;
    wire zero;
    wire [31:0] mem_rdata;

    reg [31:0] alu_a;
    wire [31:0] alu_b;
    reg [31:0] result;
    reg take_branch;

    // fetch
    pc pc_inst (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc_out)
    );

    imem #(.HEX_FILE(HEX_FILE)) imem_inst (
        .addr(pc_out),
        .instr(instr)
    );

    // decode
    decoder decoder_inst (
        .instr(instr),
        .reg_write(reg_write),
        .imm_sel(imm_sel),
        .alu_a_sel(alu_a_sel),
        .alu_b_sel(alu_b_sel),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .result_sel(result_sel),
        .branch(branch),
        .jump(jump)
    );

    immgen immgen_inst (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    // rs1 = bits 19-15
    // rs2 = bits 24-20
    // rd = bits 11-7
    regfile regfile_inst (
        .clk(clk),
        .we(reg_write),
        .rs1_addr(instr[19:15]),
        .rs2_addr(instr[24:20]),
        .rd_addr(instr[11:7]),
        .rd_data(result),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // input a: 0 = rs1, 1 = pc, 2 = zero
    always @(*) begin
        if (alu_a_sel == 2'd1)
            alu_a = pc_out;
        else if (alu_a_sel == 2'd2)
            alu_a = 32'd0;
        else
            alu_a = rs1_data;
    end

    // input b: 1 = immediate, 0 = rs2
    assign alu_b = alu_b_sel ? imm : rs2_data;

    alu alu_inst (
        .a(alu_a),
        .b(alu_b),
        .op(alu_op),
        .y(alu_y),
        .zero(zero)
    );

    // alu result is the address
    dmem dmem_inst (
        .clk(clk),
        .mem_write(mem_write),
        .funct3(instr[14:12]),
        .addr(alu_y),
        .wdata(rs2_data),
        .rdata(mem_rdata)
    );

    // 0 = alu, 1 = memory, 2 = pc+4
    always @(*) begin
        if (result_sel == 2'd1)
            result = mem_rdata;
        else if (result_sel == 2'd2)
            result = pc_out + 4;
        else
            result = alu_y;
    end

    // branches
    // beq/bne = subtract
    // blt/bge/bltu/bgeu = slt
    always @(*) begin
        case (instr[14:12])
            3'b000: take_branch = zero;   // branch if equal
            3'b001: take_branch = !zero;  // branch if not equal
            3'b100: take_branch = !zero;  // branch if less than
            3'b101: take_branch = zero;   // branch if greater or equal
            3'b110: take_branch = !zero;  // branch if less than
            3'b111: take_branch = zero;   // branch if greater or equal
            default: take_branch = 0;
        endcase
    end

    // next pc
    // jump target needs last bit cleared
    // branch target gets own adder
    assign pc_next = jump ? {alu_y[31:1], 1'b0} :
                     (branch && take_branch) ? (pc_out + imm) :
                     (pc_out + 4);

endmodule