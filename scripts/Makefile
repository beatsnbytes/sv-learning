# Makefile for SystemVerilog simulation with Verilator
# Usage: make sim TOP=<testbench_name>

# Default target
TOP ?= and_gate_tb
RTL_DIR = ../rtl
TB_DIR = ../tb

sim:
	verilator --binary --sv --trace \
		-o $(TOP) \
		$(RTL_DIR)/*.sv $(TB_DIR)/$(TOP).sv \
		--top-module $(TOP)
	./obj_dir/$(TOP) +verilator+seed+$(shell data +%s)
	gtkwave ../sim/$(TOP).vcd

synth:
	yosys -p "read_verilog -sv $(RTL_DIR)/$(MODULE).sv; \
		synth -top $(MODULE); \
		write_verilog ../sim/$(MODULE)_synth.v; \
		stat"

clean:
	rm -rf obj_dir
	rm -f sim/*.vcd
