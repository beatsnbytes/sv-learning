// mux4to1_tb.sv
// Testbench for mux4to1 module
// Week 1 - testing multi-bit signals and case statement

module mux4to1_tb;

    // Declare signals
    logic [1:0] sel;
    logic [3:0] in0, in1, in2, in3;
    logic [3:0] y;

    // Instantiate DUT
    mux4to1 dut (
        .sel(sel),
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .in3(in3),
        .y(y)
    );

    // Main test
    initial begin
       $dumpfile("../sim/mux4to1_tb.vcd");
       $dumpvars(0, mux4to1_tb);

       // Set fixed input values
       in0 = 4'hA;
       in1 = 4'hB;
       in2 = 4'hC;
       in3 = 4'hD;

       // Select each input in turn
       sel = 2'b00; #10;
       sel = 2'b01; #10;
       sel = 2'b10; #10;
       sel = 2'b11; #10;

       $display("simulation complete");
       $finish;
    end

    //Monitor
    initial begin
        $monitor("t=%0t | sel=%b | in0=%h in1=%h in2=%h in3=%h | y=%h", 
        $time, sel, in0, in1, in2, in3, y);
    end

endmodule