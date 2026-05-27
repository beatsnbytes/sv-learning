// riscv_cpu.sv
// The top level module that connects fetch&decode with execute
// Week10 - Towards a simple RISC-V processor

module riscv_cpu (
    input logic clk,
    input logic rst,
    output logic [31:0] pc,
    output logic [31:0] alu_result,
    output logic zero
);

    logic [4:0] rs1_addr, rs2_addr, rd_addr;
    logic [31:0] imm;
    logic [3:0] alu_op;
    logic reg_wr_en;
    logic [31:0] instr;
    logic alu_src;
    logic pc_src;
    logic [2:0] func3;
    logic branch;

    logic mem_read, mem_write, mem_to_reg;
    logic [31:0] dmem [255:0]; // 1KB data memory
    logic [31:0] mem_data; // Data read from memory
    logic [31:0] wb_data; // writeback data - ALU or memory

    logic [31:0] rs2_data;


    assign pc_src = branch && ((func3 == 3'b000 && zero) || (func3 == 3'b001 && !zero));

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 32'd0;
        end else begin
            pc <= pc_src ? (pc + imm) : (pc + 32'd4);
        end
        
    end

    // LOAD - combinational read from the dmem
    assign mem_data = dmem[alu_result[9:2]];

    // Writeback MUX
    assign wb_data = mem_to_reg ? mem_data : alu_result;

    // SW - synchronous write
    always_ff @(posedge clk) begin
        if (mem_write) begin
            dmem[alu_result[9:2]] <= rs2_data;
        end    
    end

    riscv_fetch_decode riscv_fetch_decode_inst(
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
        .alu_src(alu_src),
        .branch(branch),
        .func3(func3),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg)
    );

    riscv_execute riscv_execute_inst (
        .clk(clk),
        .rst(rst),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .reg_wr_en(reg_wr_en),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .imm(imm),
        .wb_data(wb_data),
        .alu_result(alu_result),
        .zero(zero),
        .rs2_data(rs2_data)
    );

endmodule