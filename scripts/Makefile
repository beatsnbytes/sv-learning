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
	./obj_dir/$(TOP)
	gtkwave ../sim/$(TOP).vcd

clean:
	rm -rf obj_dir
	rm -f sim/*.vcd
