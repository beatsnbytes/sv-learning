// riscv_execute.sv
// The execute stage of the RISC-V processor
// Week10 - Bringing it all together with the execute stage

module riscv_execute (
    input logic clk,
    input logic rst,
    // From the fetch & decode
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    input logic [4:0] rd_addr,
    input logic reg_wr_en,
    input logic alu_src,
    input logic [3:0] alu_op,
    input logic [31:0] imm,
    input logic [31:0] wb_data,
    // From the ALU
    output logic [31:0] alu_result,
    output logic zero,
    output logic [31:0] rs2_data
);

    // From the regfile
    logic [31:0] rs1_data;
    logic [31:0] rs2_imm;


    riscv_regfile riscv_regfile_inst(
        .clk(clk),
        .wr_en(reg_wr_en),
        .rs1_addr(rs1_addr), // Read port 1 address
        .rs2_addr(rs2_addr), // Read port 2 address
        .rd_addr(rd_addr), // Write address
        .rd_data(wb_data), // Write data
        .rs1_data(rs1_data), // Read port 1 data
        .rs2_data(rs2_data) // Read port 2 data
    );

    assign rs2_imm = alu_src ? imm : rs2_data ;

    riscv_alu riscv_alu_inst(
        .op(alu_op), // Opcode for the operation to be performed
        .a(rs1_data), // First operand
        .b(rs2_imm), // Second operand
        .result(alu_result), 
        .zero(zero) // 1-bit flag - High when result==0 - Used by branch insn
    );

endmodule

