// vending_machine_tb.sv
// Testbench for vending machine FSM
// Week 4 - multiple coin sequences, change verification

module vending_machine_tb;

    logic clk, rst;
    logic coin10, coin20;
    logic dispense, change;

    vending_machine dut (
        .clk(clk),
        .rst(rst),
        .coin10(coin10),
        .coin20(coin20),
        .dispense(dispense),
        .change(change)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Task to insert a 10c coin
    task insert_10c;
        coin10 = 1'b1;
        @(posedge clk); #1;
        coin10 = 1'b0;
    endtask

    // Task to insert a 20c coin
    task insert_20c;
        coin20 = 1'b1;
        @(posedge clk); #1;
        coin20 = 1'b0;
    endtask

    // Task to wait N cycles doing nothing
    task wait_cycles (input int n);
        repeat(n) @(posedge clk); #1;
    endtask

    initial begin
        $dumpfile("../sim/vending_machine_tb.vcd");
        $dumpvars(0, vending_machine_tb);

        // Reset
        rst = 1;
        coin10 = 0;
        coin20 = 0;
        repeat(2) @(posedge clk); #1;
        rst = 0;

        // Sequence 1: 10c + 20c = 30c -> dispense, no change
        $display("--- Sequence 1: 10c + 20c ---");
        insert_10c;
        wait_cycles(2);
        insert_20c;
        wait_cycles(3);

        // Sequence 2: 20c + 10c = 30c -> dispense, no change
        $display("--- Sequence 2: 20c + 10c ---");
        insert_20c;
        wait_cycles(2);
        insert_10c;
        wait_cycles(3);

        // Sequence 3: 10c + 10c + 10c = 30c -> dispense, no change
        $display("--- Sequence 3: 10c + 10c + 10c ---");
        insert_10c;
        wait_cycles(1);
        insert_10c;
        wait_cycles(1);
        insert_10c;
        wait_cycles(3);

        // Sequence 4: 20c + 20c = 40c -> dispense and change
        $display("--- Sequence 2: 20c + 20c ---");
        insert_20c;
        wait_cycles(2);
        insert_20c;
        wait_cycles(3);

        $display("Simulation complete");
        $finish;
    end

    initial begin
        $monitor("t=%0t | c10=%b c20=%b | dispense=%b change=%b",
        $time, coin10, coin20, dispense, change);
    end

endmodule







