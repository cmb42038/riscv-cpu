// basys 3 board top
// connects the cpu to the board's clock, center button, switches and leds
module basys3_top (
    input wire clk,            // 100 MHz
    input wire btnC,           // center button = reset
    input wire [15:0] sw,      // switches
    output wire [15:0] led     // leds
);

    // ---------- clock: 100 MHz in, 25 MHz out ----------
    // MMCM makes a 25 MHz clock from the 100 MHz input clock. it multiplies the
    // 100 MHz x 10 = 1000 MHz inside it, then / 40 = 25 MHz
    wire clk_fb;        // feedback, the MMCM watches its own output to stay locked
    wire clk_25_raw;
    wire clk_25;
    wire locked;        // goes high once new clock is stable

    MMCME2_BASE #(
        .CLKIN1_PERIOD(10.0),       // input clock is 10 ns = 100 MHz
        .CLKFBOUT_MULT_F(10.0),     // x10 -> 1000 MHz
        .CLKOUT0_DIVIDE_F(40.0)     // /40 -> 25 MHz
    ) mmcm_inst (
        .CLKIN1(clk),
        .CLKFBIN(clk_fb),
        .CLKFBOUT(clk_fb),
        .CLKOUT0(clk_25_raw),
        .LOCKED(locked),
        .PWRDWN(1'b0),
        .RST(1'b0)
    );

    // puts the clock on the fpga's special clock wires
    BUFG bufg_inst (
        .I(clk_25_raw),
        .O(clk_25)
    );

    // ---------- reset ----------
    // goes through two flip flops
    // cpu stays in reset until the clock is locked
    (* ASYNC_REG = "TRUE" *) reg [1:0] rst_sync = 2'b11;
    always @(posedge clk_25) begin
        rst_sync <= {rst_sync[0], btnC || !locked};
    end
    wire rst = rst_sync[1];

    // ---------- switches ----------
    // a switch can flip right as the clock ticks, and the first
    // flip flop might catch it halfway. the second flip flop gives
    // it a clock cycle to settle before cpu sees it
    (* ASYNC_REG = "TRUE" *) reg [15:0] sw_meta = 16'd0;
    (* ASYNC_REG = "TRUE" *) reg [15:0] sw_sync = 16'd0;
    always @(posedge clk_25) begin
        sw_meta <= sw;
        sw_sync <= sw_meta;
    end

    // ---------- cpu ----------
    cpu #(.HEX_FILE("blink.mem")) cpu_inst (
        .clk(clk_25),
        .rst(rst),
        .switches(sw_sync),
        .leds(led),
        .pc_out()
    );

endmodule