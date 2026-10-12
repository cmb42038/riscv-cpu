// Data memory - 1 KB of RAM for load and store instructions
module dmem (
    input wire clk,
    input wire mem_write,       // high when instruction is a store
    input wire [2:0] funct3,    // size of the load/store
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output reg [31:0] rdata
);

    // funct3 values
    localparam BYTE   = 3'b000;
    localparam HALF   = 3'b001;
    localparam WORD   = 3'b010;
    localparam BYTE_U = 3'b100;
    localparam HALF_U = 3'b101;

    reg [7:0] mem [0:1023];   // 1024 bytes

    // 10 bits to address 1024 bytes
    wire [9:0] a = addr[9:0];

    // reads happen (no clock)
    // lowest byte is at the lowest address
    always @(*) begin
        case (funct3)
            BYTE:   rdata = {{24{mem[a][7]}}, mem[a]};             // lb
            HALF:   rdata = {{16{mem[a+1][7]}}, mem[a+1], mem[a]}; // lh
            WORD:   rdata = {mem[a+3], mem[a+2], mem[a+1], mem[a]}; // lw
            BYTE_U: rdata = {24'b0, mem[a]};                       // lbu
            HALF_U: rdata = {16'b0, mem[a+1], mem[a]};             // lhu
            default: rdata = 32'b0;
        endcase
    end

    // writes happen on clock edge
    always @(posedge clk) begin
        if (mem_write) begin
            case (funct3)
                BYTE: begin   // sb
                    mem[a] <= wdata[7:0];
                end
                HALF: begin   // sh
                    mem[a]   <= wdata[7:0];
                    mem[a+1] <= wdata[15:8];
                end
                WORD: begin   // sw
                    mem[a]   <= wdata[7:0];
                    mem[a+1] <= wdata[15:8];
                    mem[a+2] <= wdata[23:16];
                    mem[a+3] <= wdata[31:24];
                end
                default: begin
                    // not a valid store size
                end
            endcase
        end
    end

endmodule