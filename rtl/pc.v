module pc (
    input  wire        clk,      // clock
    input  wire        rst,      // 1 = go back to address 0
    input  wire [31:0] pc_next,  // the address to load on next clock tick
    output reg  [31:0] pc        // the address of current instruction
);
    always @(posedge clk) begin
        if (rst)
            pc <= 32'd0;
        else
            pc <= pc_next;
    end
endmodule