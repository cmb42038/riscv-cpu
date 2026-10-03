module alu (
    input  wire [31:0] a,      // first number
    input  wire [31:0] b,      // second number
    input  wire [3:0]  op,     // which operation to do
    output reg  [31:0] y,      // the result
    output wire        zero    // 1 when the result is 0
);
    // Names for the ten operation codes
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

    // Recompute y whenever a, b, or op changes
    always @(*) begin
        case (op)
            OP_ADD:  y = a + b;
            OP_SUB:  y = a - b;
            OP_AND:  y = a & b;  
            OP_OR:   y = a | b;  
            OP_XOR:  y = a ^ b;  
            OP_SLL:  y = a << b[4:0];
            OP_SRL:  y = a >> b[4:0];
            OP_SRA:  y = $signed(a) >>> b[4:0];
            OP_SLT:  y = {31'd0, $signed(a) < $signed(b)};
            OP_SLTU: y = {31'd0, a < b};        
            default: y = 32'd0;
        endcase
    end

    assign zero = (y == 32'd0);
endmodule