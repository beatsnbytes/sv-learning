// counter_tb.sv
// Testbench for 4-bit counter
// Week 3 - testing enable, reset and overflow

module counter_tb;

    logic clk, rst, en;
    logic [3:0] count;

    counter dut(
        .clk(clk),
        .rst(rst),
        .en(en),
        .count(count)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("../sim/counter_tb.vcd");
        $dumpvars(0, counter_tb);

        //Reset
        rst = 1; en = 0;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        // Count up 8 cycles
        en = 1;
        repeat(8) @(posedge clk); #1;

        // Disable for 3 cycles
        en = 0;
        repeat(3) @(posedge clk); #1;

        // Count again - verify that it resumes where it stopped
        en = 1;
        repeat(4) @(posedge clk); #1;

        // Mid - count reset
        rst = 1;
        @(posedge clk); #1;
        rst = 0;

        // Count through overflow = 16 cycles takes up past 15 back to 0
        en = 1;
        repeat(18) @(posedge clk); #1;

        $display("Simulation complete");
        $finish;
    end

    initial begin
        $monitor("t=%0t | rst=%b en=%b | count=%0d",
        $time, rst, en, count);
    end

endmodule