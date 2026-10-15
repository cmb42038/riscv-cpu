// top level - cpu core + memories + leds and switches
//
// memory map
//   0x00000000 - 0x000003FF   data memory (1 KB)
//   0x80000000                leds (store to set, load to read back)
//   0x80000004                switches (load only)
//
// only bit 31 and bit 2 of the address get checked for io,
// other addresses with bit 31 set just repeat these two
module cpu #(
    parameter HEX_FILE = "programs/test.hex"   // program to run, passed down to imem
) (
    input wire clk,
    input wire rst,
    input wire [15:0] switches,
    output reg [15:0] leds,
    output wire [31:0] pc_out
);

    wire [31:0] instr;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire mem_write;
    wire [2:0] mem_size;
    reg [31:0] mem_rdata;
    wire [31:0] ram_rdata;

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

    // top address bit picks io instead of ram
    wire is_io = mem_addr[31];

    // ram only gets written when the store is not for io
    dmem dmem_inst (
        .clk(clk),
        .mem_write(mem_write && !is_io),
        .funct3(mem_size),
        .addr(mem_addr),
        .wdata(mem_wdata),
        .rdata(ram_rdata)
    );

    // a store to 0x80000000 sets the leds
    always @(posedge clk) begin
        if (rst)
            leds <= 16'd0;
        else if (mem_write && is_io && mem_addr[2] == 1'b0)
            leds <= mem_wdata[15:0];
    end

    // loads come from ram, leds, switches
    always @(*) begin
        if (!is_io)
            mem_rdata = ram_rdata;
        else if (mem_addr[2] == 1'b0)
            mem_rdata = {16'd0, leds};       // 0x80000000
        else
            mem_rdata = {16'd0, switches};   // 0x80000004
    end

endmodule