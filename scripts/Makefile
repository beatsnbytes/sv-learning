# Makefile for SystemVerilog simulation with Verilator
# Usage: make sim TOP=<testbench_name>

# Default target
TOP ?= and_gate_tb
RTL_DIR = ../rtl
TB_DIR = ../tb
TB_ASSERT_DIR = ../tb/assertions
UVM_DIR = ../tb/uvm

sim:
	verilator --binary --sv --trace \
		-o $(TOP) \
		$(RTL_DIR)/*.sv $(TB_DIR)/$(TOP).sv $(TB_ASSERT_DIR)/*.sv \
		--top-module $(TOP)
	./obj_dir/$(TOP) +verilator+seed+$(shell data +%s)
	gtkwave ../sim/$(TOP).vcd

synth:
	yosys -p "read_verilog -sv $(RTL_DIR)/$(MODULE).sv; \
		synth -top $(MODULE); \
		write_verilog ../sim/$(MODULE)_synth.v; \
		stat"

uvm:
	verilator --binary --sv --trace \
		-o fifo_test \
		-I$(UVM_DIR) \
		$(RTL_DIR)/*.sv $(UVM_DIR)/$(TOP)_if.sv $(UVM_DIR)/$(TOP)_test.sv \
		--top-module $(TOP)_test
	./obj_dir/$(TOP)_test +verilator+seed+$(shell date +%s)

clean:
	rm -rf obj_dir
	rm -f sim/*.vcd
