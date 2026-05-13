// dff_tb.sv
// Testbench for the D flip-flop
// Week 3 - clock generation, synchronous reset

module dff_tb;

logic clk, rst, q, d;

    dff dut (
        .clk(clk),
        .rst(rst),
        .d(d),
        .q(q)
    );

    // Clock generation - toggles every 5 time units, period = 10
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("../sim/dff_tb.vcd");
        $dumpvars(0, dff_tb);


        // Hold in reset
        rst = 1; d = 0;
        @(posedge clk); #1;
        @(posedge clk); #1;

        // Release reset
        rst = 0;

        // Apply data
        d = 1; @(posedge clk); #1;
        d = 0; @(posedge clk); #1;
        d = 1; @(posedge clk); #1;
        d = 1; @(posedge clk); #1;
        d = 0; @(posedge clk); #1;

        // Assert reset mid-operation
        rst = 1; @(posedge clk); #1;
        rst = 0; d = 1; @(posedge clk); #1;

        $display("Simulation complete");
        $finish;

    end 

    initial begin
        $monitor("t = %0t | clk=%b rst=%b d=%b | q=%b",
        $time, clk, rst , d, q);
    end

endmodule