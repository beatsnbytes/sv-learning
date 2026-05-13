// shift_reg_tb.sv
// Testbench for 4-bit shift register
// Week 3 - observing data shifting through stages

module shift_reg_tb;

    logic clk, rst, d;
    logic [3:0] q;

    shift_reg dut(
        .clk(clk),
        .rst(rst),
        .d(d),
        .q(q)
    );

    // Clock-generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("../sim/shift_reg_tb.vcd");
        $dumpvars(0, shift_reg_tb);

        // Reset
        rst = 1; d = 0;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst =0;

        // Shift in 1011
        d = 1; @(posedge clk); #1;
        d = 0; @(posedge clk); #1;
        d = 1; @(posedge clk); #1;
        d = 1; @(posedge clk); #1;

        //Keep shifting with 0's to flush data through
        d = 0; @(posedge clk); #1;
        d = 0; @(posedge clk); #1;
        d = 0; @(posedge clk); #1;
        d = 0; @(posedge clk); #1;

        $display("Simulation complete");
        $finish;

    end

    initial begin
        $monitor("t=%0t | d=%b | q=%b",
        $time, d, q);
    end

endmodule
