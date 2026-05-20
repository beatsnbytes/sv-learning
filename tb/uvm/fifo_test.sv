// fifo_test.sv
// Module that ties everything together
// Week8 - UVM simulation top level

`include "fifo_seq_item.sv"
`include "fifo_sequencer.sv"
`include "fifo_driver.sv"
`include "fifo_monitor.sv"
`include "fifo_scoreboard.sv"
`include "fifo_agent.sv"
`include "fifo_env.sv"

module fifo_test;

    logic clk;

    // Declare anddrive the clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Interface instantiation
    fifo_if #(
        .DATA_WIDTH(8)
    ) vif (
        .clk(clk)
    );

    // DUT connected through interface
    fifo #(
        .DATA_WIDTH(8),
        .DEPTH(8)
    ) dut (
        .clk(vif.clk),
        .rst(vif.rst),
        .wr_en(vif.wr_en),
        .rd_en(vif.rd_en),
        .wr_data(vif.wr_data),
        .rd_data(vif.rd_data),
        .full(vif.full),
        .empty(vif.empty)
    );

    fifo_env env;

    initial begin
        // Create and configure environment
        env = new();
        env.vif = vif;
        env.build();

        // Reset DUT
        vif.rst = 1;
        vif.wr_en = 0;
        vif.rd_en = 0;
        repeat(2) @(posedge clk); #1;
        vif.rst = 0;

        // Wait one more cycle after reset
        @(posedge clk); #1;

        // Run test
        env.run();
        
        // Wait for all transactions to complete
        repeat(500) @(posedge clk); #1;

        // Report results
        env.report();
        $finish;

    end

endmodule
