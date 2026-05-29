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

    // Signals for the ID/EX pipeline register
    logic [4:0] id_ex_rs1_addr, id_ex_rs2_addr;
    logic [4:0] id_ex_rd_addr;
    logic [31:0] id_ex_imm;
    logic [3:0] id_ex_alu_op;
    logic id_ex_reg_wr_en;
    logic id_ex_alu_src;
    logic id_ex_mem_read;
    logic id_ex_mem_write;
    logic id_ex_mem_to_reg;

    logic fwd_a, fwd_b;

    logic [31:0] ex_wb_alu_result;
    logic ex_wb_mem_to_reg;
    logic [4:0] ex_wb_rd_addr;
    logic ex_wb_reg_wr_en;

    // Combinational logic for the source of the pc. Either from branch instr or simple pc+4
    assign pc_src = branch && ((func3 == 3'b000 && zero) || (func3 == 3'b001 && !zero));

    // Compute next pc
    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 32'd0;
        end else begin
            pc <= pc_src ? (pc + imm) : (pc + 32'd4);
        end
    end

    always_ff @(posedge clk) begin
        if(rst) begin
            id_ex_rs1_addr <= 5'b0;
            id_ex_rs2_addr <= 5'b0;
            id_ex_rd_addr <= 5'b0;
            id_ex_imm <= 32'b0;
            id_ex_alu_op <= 4'b0;
            id_ex_reg_wr_en <= 1'b0;
            id_ex_alu_src <= 1'b0;
            id_ex_mem_read <= 1'b0;
            id_ex_mem_write  <= 1'b0;
            id_ex_mem_to_reg <= 1'b0;
        end else begin
            id_ex_rs1_addr <= rs1_addr;
            id_ex_rs2_addr <= rs2_addr;
            id_ex_rd_addr <= rd_addr;
            id_ex_imm <= imm;
            id_ex_alu_op <= alu_op;
            id_ex_reg_wr_en <= reg_wr_en;
            id_ex_alu_src <= alu_src;
            id_ex_mem_read <= mem_read;
            id_ex_mem_write  <= mem_write;
            id_ex_mem_to_reg <= mem_to_reg;
        end
    end

    // LOAD - combinational read from the dmem
    assign mem_data = dmem[ex_wb_alu_result[9:2]];

    // Writeback MUX
    assign wb_data = ex_wb_mem_to_reg ? mem_data : ex_wb_alu_result;

    // SW - synchronous write
    always_ff @(posedge clk) begin
        if (id_ex_mem_write) begin
            dmem[alu_result[9:2]] <= rs2_data;
        end    
    end

    // Compare the current source registers with the destination register that just wrote back
    // Also the destination register should not be x0 (which is always zero) ad the wr_en should be high
    assign fwd_a = (ex_wb_reg_wr_en && (id_ex_rs1_addr == ex_wb_rd_addr) 
                    && (ex_wb_rd_addr != 5'b0)) ? 1'b1 : 1'b0;
    assign fwd_b = (ex_wb_reg_wr_en && (id_ex_rs2_addr == ex_wb_rd_addr) 
                    && (ex_wb_rd_addr != 5'b0)) ? 1'b1 : 1'b0;

    // EX/WB pipeline register
    always_ff @(posedge clk) begin
        if (rst) begin
            ex_wb_alu_result <= 32'b0;
            ex_wb_mem_to_reg <= 1'b0;  
            ex_wb_rd_addr <= 5'b0;
            ex_wb_reg_wr_en <= 1'b0;          
        end else begin
            ex_wb_alu_result <= alu_result;
            ex_wb_mem_to_reg <= id_ex_mem_to_reg;
            ex_wb_rd_addr <= id_ex_rd_addr;
            ex_wb_reg_wr_en <= id_ex_reg_wr_en;
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
        .rs1_addr(id_ex_rs1_addr),
        .rs2_addr(id_ex_rs2_addr),
        .rd_addr(id_ex_rd_addr),
        .reg_wr_en(id_ex_reg_wr_en),
        .alu_src(id_ex_alu_src),
        .alu_op(id_ex_alu_op),
        .imm(id_ex_imm),
        .wb_data(wb_data),
        .fwd_a(fwd_a),
        .fwd_b(fwd_b),
        .alu_result(alu_result),
        .zero(zero),
        .rs2_data(rs2_data)
    );

endmodule