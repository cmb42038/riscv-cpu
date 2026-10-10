module imem #(
    parameter HEX_FILE = "programs/test.hex"  // program to load
) (
    input  wire [31:0] addr,   // address of instruction
    output wire [31:0] instr   // the instruction stored there
);
    // each holding one 32 bit instruction
    reg [31:0] mem [0:255];

    // Load from file when simulation starts
    initial begin
        $readmemh(HEX_FILE, mem);
    end

    // each instruction is 4 bytes
    // drop bottom 2 bits to get slot number
    assign instr = mem[addr[9:2]];
endmodule