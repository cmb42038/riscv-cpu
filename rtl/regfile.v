module regfile (
    input  wire        clk,       // the clock
    input  wire        we,        // write enable: 1 means "store value this tick"
    input  wire [4:0]  rs1_addr,  // which register to read on port 1
    input  wire [4:0]  rs2_addr,  // which register to read on port 2
    input  wire [4:0]  rd_addr,   // which register to write
    input  wire [31:0] rd_data,   // the value to write
    output wire [31:0] rs1_data,  // value read on port 1
    output wire [31:0] rs2_data   // value read on port 2
);
    // 32 registers, 32 bits wide each
    reg [31:0] regs [0:31];

    // Writing on clock tick
    always @(posedge clk) begin
        if (we == 1 && rd_addr != 0) 
            regs[rd_addr] <= rd_data;
    end

    // Reading, x0 forced to zero
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : regs[rs2_addr]; 
endmodule