# RISC-V RTL Learning Portfolio

A structured, week-by-week SystemVerilog design and verification portfolio — from basic gates to a pipelined RISC-V CPU with hardware accelerators.

**Author:** Vatistas Kostalabros  
**Goal:** Systematic ramp-up from RTL fundamentals to production-grade digital design techniques targeting RISC-V and high-performance computing.

---

## What's Inside

### RISC-V CPU Pipeline
A fully functional 5-stage pipelined RISC-V CPU implementing the RV32IM ISA:
- **IF/ID → EX → WB** pipeline with pipeline registers
- **Forwarding unit** — resolves RAW hazards without stalling
- **Hazard detection** — load-use stall insertion
- **Branch flushing** — two-bubble penalty on taken branches
- **RV32M Multiplier** — iterative shift-and-add with stall integration
- **CSR registers** — mtvec, mepc, mcause with CSRRW/CSRRS support
- **Exception groundwork** — hardware write ports for future exception handling

### Hardware Accelerators
- **Matrix Multiply Accelerator** — parameterized NxN systolic-style MAC unit
- **AXI4-Lite Wrapper** — memory-mapped register interface for CPU-accelerator integration
- **SPI Master** — Mode 0, MSB-first, parameterized CLKDIV and DATA_WIDTH
- **UART TX** — configurable baud rate, 8N1 framing, send_bit exposed for verification

### Verification
- **UVM Environment** — full FIFO UVM testbench (agent, driver, monitor, scoreboard)
- **SVA Assertions** — bind-based assertion modules for FIFO, register file, multiplier, CPU forwarding
- **Formal Verification** — SymbiYosys k-induction proofs:
  - x0 register always zero
  - MUL busy ⊕ done (never simultaneously asserted)
  - Forwarding unit correctness (fwd_a, fwd_b)
  - CSR forwarding correctness
- **Constrained Random Verification** — FIFO coverage-driven testbench

### Physical Implementation
- **OpenROAD synthesis** — ALU synthesized to sky130hs standard cells
- **Timing analysis** — critical path identified at ~200MHz on sky130
- **Yosys synthesis** — gate-level netlists with Liberty file mapping

---

## Project Structure

```
sv-learning/
├── rtl/                    # RTL source files
│   ├── cpu/                # RISC-V CPU pipeline modules
│   │   ├── riscv_cpu.sv
│   │   ├── riscv_alu.sv
│   │   ├── riscv_regfile.sv
│   │   ├── riscv_fetch_decode.sv
│   │   ├── riscv_execute.sv
│   │   ├── riscv_mul.sv
│   │   └── riscv_csr.sv
│   ├── riscv_alu.sv
│   ├── fifo.sv
│   ├── axi4_lite_slave.sv
│   ├── matrix_multiplication.sv
│   ├── matrix_multiplication_axi_wrapper.sv
│   ├── spi_master.sv
│   └── uart_tx.sv
├── tb/                     # Testbenches
│   ├── assertions/         # SVA bind modules
│   │   ├── fifo_assertions.sv
│   │   ├── regfile_formal.sv
│   │   ├── mul_formal.sv
│   │   └── cpu_fwd_formal.sv
│   └── uvm/                # UVM FIFO environment
├── scripts/                # Makefile and formal verification scripts
│   ├── Makefile
│   ├── regfile_formal.sby
│   ├── mul_formal.sby
│   └── cpu_fwd_formal.sby
├── synth/                  # OpenROAD synthesis scripts and results
│   ├── synth_alu.ys
│   └── sky130/             # sky130hs PDK files
└── sim/                    # Simulation outputs (VCD waveforms)
```

---

## Tools & Environment

| Tool | Version | Purpose |
|------|---------|---------|
| Verilator | 5.x | RTL simulation |
| GTKWave | apt | Waveform viewing |
| Yosys | 0.33 | Synthesis |
| SymbiYosys | 0.66 | Formal verification |
| Z3 / Boolector | — | SMT solvers for formal |
| OpenROAD | 26Q1 | Place, route, STA |
| riscv64-unknown-elf-gcc | — | RISC-V assembly encoding |

**OS:** Ubuntu 24.04

---

## Running Simulations

All simulations are run from the `scripts/` directory:

```bash
cd scripts/

# Run a specific testbench
make TOP=riscv_cpu_tb sim

# Run SPI master testbench
make TOP=spi_master_tb sim

# Run UART testbench
make TOP=uart_tb sim

# Run matrix multiplier AXI wrapper testbench
make TOP=matrix_multiplication_axi_wrapper_tb sim
```

> **Note:** Run simulations from an external terminal — GTKWave has a snap conflict with VS Code integrated terminal.

---

## Running Formal Verification

```bash
cd scripts/

# Prove x0 always zero (k-induction)
sby -f regfile_formal.sby

# Prove MUL busy XOR done
sby -f mul_formal.sby

# Prove forwarding unit correctness
sby -f cpu_fwd_formal.sby
```

All proofs pass by k-induction using Boolector as the SMT backend.

---

## Running Synthesis (OpenROAD)

```bash
cd synth/

# Synthesize ALU with sky130hs standard cell library
yosys synth_alu.ys

# Run OpenROAD floorplan and timing analysis
openroad alu_floorplan.tcl
```

**Result:** ALU critical path 4.91ns → ~200MHz achievable frequency on sky130hs. Critical path identified through ripple-carry adder chain — architectural fix: carry-lookahead adder.

---

## Weekly Progress

| Week | Topic | Status |
|------|-------|--------|
| 1–3 | AND gate through counter | ✓ |
| 4 | FSMs | ✓ |
| 5 | Parameterized FIFO | ✓ |
| 6 | Constrained random verification | ✓ |
| 7 | SVA assertions + bind | ✓ |
| 8 | Full UVM environment | ✓ |
| 9 | AXI4-Lite slave | ✓ |
| 10–12 | RISC-V CPU — ALU, regfile, fetch/decode, execute, pipeline, forwarding, branch flushing | ✓ |
| 13 | RV32M multiplier with stall unit | ✓ |
| 14 | CSR registers + exception groundwork | ✓ |
| 15 | Formal verification suite | ✓ |
| 16 | SPI master + UART TX | ✓ |
| 17 | Matrix multiply accelerator | ✓ |
| 18 | AXI4-Lite wrapper for accelerator | ✓ |
| 19 | OpenROAD synthesis + timing analysis | 🔄 |
| 20 | CDC / Async FIFO | Planned |

---

## Known Limitations

- Exception handling incomplete — mepc/mcause written by hardware not yet implemented
- Misaligned PC and illegal instruction exceptions not implemented
- SPI slave not yet started
- UART RX not yet started
- Matrix multiplier: fixed-width accumulator (potential overflow at high security levels)
- OpenROAD flow: combinational ALU only — sequential module timing pending

---

## License

See [LICENSE](LICENSE) for details.
