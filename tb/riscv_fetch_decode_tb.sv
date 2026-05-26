// riscv_fetch_decode_tb.sv
// Testbench for the fetch and decode stage
// Week10 : Towards the RISC-V processor

module riscv_fetch_decode_tb;

logic clk, rst;
logic [31:0] pc;
logic [4:0] rs1_addr, rs2_addr, rd_addr;
logic [31:0] imm;
logic [3:0] alu_op;
logic reg_wr_en;
logic [31:0] instr;
logic alu_src;


riscv_fetch_decode dut (
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .rd_addr(rd_addr),
    .imm(imm),
    .alu_op(alu_op),
    .reg_wr_en(reg_wr_en),
    .instr(instr),
    .alu_src(alu_src) // 0 = use rs2, 1 use imm
);

initial clk = 1'b0;
always #5 clk = ~clk;

initial begin
    $dumpfile("../sim/riscv_fetch_decode_tb.vcd");
    $dumpvars(0, riscv_fetch_decode_tb);

    // Reset for 2 cycles
    rst = 1'b1;
    repeat(2) @(posedge clk); #1;
    rst = 1'b0;

    // Add cycles to observe all instructions
    repeat(10) @(posedge clk); #1;
    $finish; 
end

initial begin
    $monitor("time=%t | pc=%h | rs1_addr=%h rs2_addr=%h rd_addr=%h | instr%h | imm=%h | alu_op=%h | reg_wr_en=%b alu_src=%b",
    $time, pc, rs1_addr, rs2_addr, rd_addr, instr, imm, alu_op, reg_wr_en, alu_src);
end

endmodule