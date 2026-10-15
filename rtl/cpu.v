// top level - cpu core + memories
module cpu #(
    parameter HEX_FILE = "programs/test.hex"   // program to run, passed to imem
) (
    input wire clk,
    input wire rst,
    output wire [31:0] pc_out
);

    wire [31:0] instr;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire mem_write;
    wire [2:0] mem_size;
    wire [31:0] mem_rdata;

    cpu_core core (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instr(instr),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_write(mem_write),
        .mem_size(mem_size),
        .mem_rdata(mem_rdata)
    );

    imem #(.HEX_FILE(HEX_FILE)) imem_inst (
        .addr(pc_out),
        .instr(instr)
    );

    dmem dmem_inst (
        .clk(clk),
        .mem_write(mem_write),
        .funct3(mem_size),
        .addr(mem_addr),
        .wdata(mem_wdata),
        .rdata(mem_rdata)
    );

endmodule