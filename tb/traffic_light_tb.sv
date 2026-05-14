// traffic_light_tb.sv
// Testbench for traffic light FSM
// Week4 - Testing state transitions, timer control

module traffic_light_tb;

logic clk, rst, timer;
logic red, amber, green;

    traffic_light dut (
        .clk(clk),
        .rst(rst),
        .timer(timer),
        .red(red), 
        .amber(amber),
        .green(green)
    );

    // Clock generation
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Task to wait N cycles with timer low then pulse timer high
    task wait_then_advance (input int cycles);
        timer = 0;
        repeat(cycles) @(posedge clk); #1;
        timer = 1;
        @(posedge clk) #1;
        timer = 0;
    endtask

    initial begin
        $dumpfile("../sim/traffic_light_tb.vcd");
        $dumpvars(0, traffic_light_tb);

        // Reset
        rst = 1; timer = 0;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        // Cycle through all states
        wait_then_advance(3); //RED -> RED_AMBER
        wait_then_advance(2); //RED_AMBER -> GREEN
        wait_then_advance(4); //GREEN -> AMBER
        wait_then_advance(2); //AMBER -> RED
        wait_then_advance(3); //RED -> RED_AMBER again

        // Test that timer=0 holds state
        timer = 0;
        repeat(5) @(posedge clk); #1;

        $display("Simulation complete");
        $finish;

    end

    initial begin
        $monitor("t=%0t | timer=%b | red=%b amber=%b green=%b",
        $time, timer, red, amber, green);
    end

endmodule

    