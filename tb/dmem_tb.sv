// testbench for dmem.v
module dmem_tb;

    logic clk = 0;
    logic mem_write = 0;
    logic [2:0] funct3;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;

    dmem dut (
        .clk(clk),
        .mem_write(mem_write),
        .funct3(funct3),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    // clock with a period of 10
    always #5 clk = ~clk;

    // funct3 values copied from dmem.v
    localparam BYTE   = 3'b000;
    localparam HALF   = 3'b001;
    localparam WORD   = 3'b010;
    localparam BYTE_U = 3'b100;
    localparam HALF_U = 3'b101;

    int tests = 0;
    int errors = 0;

    // wait for clock edge
    task tick;
        @(posedge clk);
        #1;
    endtask

    // write d to address a
    task store(input logic [2:0] size, input logic [31:0] a, input logic [31:0] d);
        funct3 = size;
        addr = a;
        wdata = d;
        mem_write = 1;
        tick();
        mem_write = 0;
    endtask

    // read address a and see if it matches
    task check(input string name, input logic [2:0] size, input logic [31:0] a, input logic [31:0] expected);
        funct3 = size;
        addr = a;
        #1;
        tests++;
        if (rdata !== expected) begin
            errors++;
            $display("FAIL: %s  got %h, expected %h", name, rdata, expected);
        end
    endtask

    initial begin
        // write a word and read it back with each load type
        store(WORD, 0, 32'hDEADBEEF);
        check("lw", WORD, 0, 32'hDEADBEEF);
        check("lb", BYTE, 0, 32'hFFFFFFEF);
        check("lbu", BYTE_U, 0, 32'h000000EF);
        check("lh", HALF, 0, 32'hFFFFBEEF);
        check("lhu", HALF_U, 0, 32'h0000BEEF);

        // check byte order
        check("byte 1", BYTE_U, 1, 32'h000000BE);
        check("byte 3", BYTE, 3, 32'hFFFFFFDE);

        // sb changes 1 byte
        store(BYTE, 1, 32'h12345678);
        check("sb", WORD, 0, 32'hDEAD78EF);

        // sh changes 2 bytes
        store(HALF, 2, 32'hAAAA1234);
        check("sh", WORD, 0, 32'h123478EF);

        // positive byte should stay positive
        store(BYTE, 8, 32'h0000007F);
        check("lb positive", BYTE, 8, 32'h0000007F);

        // try a different address, make sure address 0 didn't change
        store(WORD, 16, 32'h11223344);
        check("addr 16", WORD, 16, 32'h11223344);
        check("addr 0 same", WORD, 0, 32'h123478EF);

        // mem_write = 0 so shouldn't write
        funct3 = WORD;
        addr = 16;
        wdata = 32'hFFFFFFFF;
        tick();
        check("no write", WORD, 16, 32'h11223344);

        // write shouldn't happen until clock edge
        wdata = 32'hCAFEF00D;
        mem_write = 1;
        check("before edge", WORD, 16, 32'h11223344);
        tick();
        mem_write = 0;
        check("after edge", WORD, 16, 32'hCAFEF00D);

        if (errors == 0)
            $display("PASS: %0d tests", tests);
        else
            $display("FAILED: %0d of %0d tests", errors, tests);
        $finish;
    end

endmodule