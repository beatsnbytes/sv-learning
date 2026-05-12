// and_gate.sv
// Simple 2-inut AND gate
// Week 1 - first SystemVerilog module

module and_gate (
	input logic a,
	input logic b, 
	output logic y
);

	assign y = a & b;

endmodule
