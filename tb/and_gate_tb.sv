// and_gate_tb.sh
// Testbench for and_gate module
// Week 1 - first SystemVerilog testbench

module and_gate_tb;

	// Declare signals
	logic a, b, y;

	//Instantiate the design under test (DUT)
	and_gate dut (
		.a(a),
		.b(b),
		.y(y)
	);

	// Main test
	initial begin
		// save waveform
		$dumpfile("../sim/and_gate_tb.vcd");
		$dumpvars(0, and_gate_tb);

		// Apply al input combinations
		a = 0; b = 0; #10;
		a = 0; b = 1; #10;
		a = 1; b = 0; #10;
		a = 1; b = 1; #10;

		// print results
		$display("Simulation Complete");
		$finish;
	end

	// Monitor changes and print to terminal
	initial begin
		$monitor("t=%0t | a=%b b=%b | y=%b", $time, a, b, y);
	end

endmodule
