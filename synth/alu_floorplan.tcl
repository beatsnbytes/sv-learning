read_lef sky130/sky130hs.tlef
read_lef sky130/sky130_fd_sc_hs_merged.lef
read_liberty sky130/sky130_fd_sc_hs__tt_025C_1v80.lib
read_verilog alu_netlist.v
link_design riscv_alu

read_sdc alu_constraints.sdc

initialize_floorplan -utilization 40 -aspect_ratio 1 -core_space 2 -site unit

report_checks
