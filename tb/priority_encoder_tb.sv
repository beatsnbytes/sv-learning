// priority_encoder_tb.sv
// Testbench for the priority encoder module
// Week 2 - testing priority resolution

module priority_encoder_tb;

logic [3:0] in;
logic [1:0] out;
logic valid;

priority_encoder dut (
    .in(in),
    .out(out),
    .valid(valid)
);

    initial begin
        $dumpfile("../sim/priority_encoder_tb.vcd");
        $dumpvars(0, priority_encoder_tb);

        // No inputs active
        in = 4'b0000; #10;

        // Single inputs
        in = 4'b0001; #10;
        in = 4'b0010; #10;
        in = 4'b0100; #10;
        in = 4'b1000; #10;

        // Multiple inputs - priority should resolve
        in = 4'b0011; #10; // in[1] should win
        in = 4'b0111; #10; // in[2] should win
        in = 4'b1111; #10; // in[3] should win
        in = 4'b1010; #10; // in[3] should win

        $display("Simulation complete");
        $finish;
    end

    initial begin
        $monitor("t=%0t | in=%b | out=%b | valid=%b", 
                    $time, in, out, valid);
    end

endmodule
