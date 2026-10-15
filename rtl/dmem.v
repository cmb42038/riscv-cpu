// Data memory - 1 KB of RAM for load/store instructions
//
// split into 4 banks, one for each byte of a word. each bank only
// writes one byte at a time
//
// loads and stores need to be aligned
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

    // 256 words, split up by byte
    reg [7:0] bank0 [0:255];   // lowest byte of each word
    reg [7:0] bank1 [0:255];
    reg [7:0] bank2 [0:255];
    reg [7:0] bank3 [0:255];   // highest byte of each word

    wire [7:0] row = addr[9:2];      // which word
    wire [1:0] offset = addr[1:0];   // which byte inside that word

    // ---------- loads ----------
    // read the whole word, lowest byte is at lowest address
    wire [31:0] word = {bank3[row], bank2[row], bank1[row], bank0[row]};

    // slide it down so the byte or half is at the bottom
    wire [31:0] shifted = word >> (offset * 8);

    always @(*) begin
        case (funct3)
            BYTE:   rdata = {{24{shifted[7]}}, shifted[7:0]};     // lb
            HALF:   rdata = {{16{shifted[15]}}, shifted[15:0]};   // lh
            WORD:   rdata = word;                                 // lw
            BYTE_U: rdata = {24'b0, shifted[7:0]};                // lbu
            HALF_U: rdata = {16'b0, shifted[15:0]};               // lhu
            default: rdata = 32'b0;
        endcase
    end

    // ---------- stores ----------
    // which banks a store changes, one bit per bank
    reg [3:0] byte_en;
    always @(*) begin
        case (funct3)
            BYTE:    byte_en = 4'b0001 << offset;   // sb
            HALF:    byte_en = 4'b0011 << offset;   // sh
            WORD:    byte_en = 4'b1111;             // sw
            default: byte_en = 4'b0000;             // not a valid store size
        endcase
    end

    // slide the store value up so each byte lines up with its bank
    wire [31:0] wdata_shifted = wdata << (offset * 8);

    // one write per bank, on the clock edge
    always @(posedge clk) begin
        if (mem_write && byte_en[0])
            bank0[row] <= wdata_shifted[7:0];
    end

    always @(posedge clk) begin
        if (mem_write && byte_en[1])
            bank1[row] <= wdata_shifted[15:8];
    end

    always @(posedge clk) begin
        if (mem_write && byte_en[2])
            bank2[row] <= wdata_shifted[23:16];
    end

    always @(posedge clk) begin
        if (mem_write && byte_en[3])
            bank3[row] <= wdata_shifted[31:24];
    end

endmodule