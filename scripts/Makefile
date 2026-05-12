# Makefile for SystemVerilog simulation with Verilator
# Usage: make sim

TOP = and_gate_tb
RTL = ../rtl/and_gate.sv
TB = ../tb/and_gate_tb.sv

sim:
	verilator --binary --sv --trace \
		-o $(TOP) \
		$(RTL) $(TB) \
		--top-module $(TOP)
	./obj_dir/$(TOP)
	gtkwave ../sim/and_gate.vcd

clean:
	rm -rf obj_dir
	rm -f sim/*.vcd
