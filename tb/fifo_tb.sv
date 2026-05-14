// fifo_tb.sv
// Testbench for parametrised FIFO
// Week 5 - testing write, read, full, empty, simultaneous rw

module fifo_tb;

    // Parameters - match or override DUT defaults
    localparam int DATA_WIDTH = 8;
    localparam int DEPTH = 8;

    logic clk, rst;
    logic wr_en, rd_en;
    logic [DATA_WIDTH - 1 : 0] wr_data;
    logic [DATA_WIDTH - 1 : 0] rd_data;
    logic full, empty;

    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Task to write a value
    task write_data(input logic [DATA_WIDTH - 1 :0] data);
        wr_en = 1'b1;
        wr_data = data;
        @(posedge clk); #1;
        wr_en = 1'b0;
    endtask

    // Task to read a value
    task read_data;
        rd_en = 1'b1;
        @(posedge clk); #1;
        rd_en = 1'b0;
    endtask

    initial begin
        $dumpfile("../sim/fifo_tb.vcd");
        $dumpvars(0, fifo_tb);

        // Reset
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        repeat(3) @(posedge clk); #1;
        rst = 0;

        // Test 1: fill FIFO completely
        $display("--- Test 1 : fill FIFO ---");
        write_data(8'hA1);
        write_data(8'hA2);
        write_data(8'hA3);
        write_data(8'hA4);
        write_data(8'hA5);
        write_data(8'hA6);
        write_data(8'hA7);
        write_data(8'hA8);
        $display("full=%b empty=%b", full, empty);

        // Test 2: write when full, should be ignored
        $display("--- Test 2 : Write when full ---");
        write_data(8'hFF);
        $display("full=%b empty=%b", full, empty);

        // Test 3: Drain FIFO completely
        $display("--- Test 3: Drain FIFO ---");
        repeat(8) read_data;
        $display("full=%b empty=%b", full, empty);

        // Test 4: Read when empty, should be ignored
        $display("--- Test 4: Read when empty ---");
        read_data;

        // Test 5: Simultaneous read and write_data
        $display("--- Test 5: Simultaneous read and write ---");
        write_data(8'hB1);
        write_data(8'hB2);
        write_data(8'hB3);
        wr_en = 1'b1;
        rd_en = 1'b1;
        wr_data = 8'hB4;
        @(posedge clk); #1;
        wr_en = 1'b0;
        rd_en = 1'b0;
        @(posedge clk); #1;

        $display("Simulation complete");
        $finish;
    end

    initial begin
        $monitor("time=%0t | wr_en=%b wr_data=%h | rd_en=%b rd_data=%h | full=%b empty=%b",
                $time, wr_en, wr_data, rd_en, rd_data, full, empty);
    end

endmodule
