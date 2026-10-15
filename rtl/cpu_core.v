// cpu core
// the instruction and data memory are in cpu.v
module cpu_core (
    input wire clk,
    input wire rst,

    // instruction memory
    output wire [31:0] pc_out,     // address of the instruction we want
    input wire [31:0] instr,       // the instruction at that address

    // data memory and io
    output wire [31:0] mem_addr,   // address for loads and stores
    output wire [31:0] mem_wdata,  // value to store
    output wire mem_write,         // 1 = this instruction is a store
    output wire [2:0] mem_size,    // byte, half or word (funct3)
    input wire [31:0] mem_rdata    // value that came back from a load
);

    wire [31:0] pc_next;
    
    // control signals from decoder
    wire reg_write;
    wire [2:0] imm_sel;
    wire [1:0] alu_a_sel;
    wire alu_b_sel;
    wire [3:0] alu_op;
    wire [1:0] result_sel;
    wire branch;
    wire jump;

    wire [31:0] imm;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] alu_y;
    wire zero;

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

    // loads and stores go out of the core
    // alu result is the address, rs2 is the value to store
    assign mem_addr = alu_y;
    assign mem_wdata = rs2_data;
    assign mem_size = instr[14:12];

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