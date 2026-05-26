// riscv_execute_tb.sv
// Testbench for the RISC-V execute stage
// Week10 - Bringing it all together with the execute stage

module riscv_execute_tb;


    logic clk, rst;
    
    logic [4:0] rs1_addr, rs2_addr, rd_addr;
    logic reg_wr_en;
    logic alu_src;
    logic [3:0] alu_op;
    logic [31:0] imm;
    
    logic [31:0] alu_result;
    logic zero;

    riscv_execute dut (
        .clk(clk),
        .rst(rst),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .reg_wr_en(reg_wr_en),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .imm(imm),
        .alu_result(alu_result),
        .zero(zero)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("../sim/riscv_execute_tb.vcd");
        $dumpvars(0, riscv_execute_tb);

        // Reset for 2 cycles and deassert
        rst = 1'b1;
        repeat(2) @(posedge clk); #1;
        rst = 1'b0;

        // ADDI x1, x0, 5 
        rs1_addr = 5'd0; // x0
        rs2_addr = 5'd0; // Dont care for I-Type
        rd_addr = 5'd1; // x1
        imm = 32'd5; // 5
        alu_op = 4'b0000; // ADD
        alu_src = 1'b1; // Choose the immediate value
        reg_wr_en = 1'b1;

        @(posedge clk); #1;
        $display("After instruction #1 : Result = %d", alu_result);

        // ADDI x2, x0, 10
        rs1_addr = 5'd0; // x0
        rs2_addr = 5'd0; // Dont care for I-Type
        rd_addr = 5'd2; // x1
        imm = 32'd10; // 5
        alu_op = 4'b0000; // ADD
        alu_src = 1'b1; // Choose the immediate value
        reg_wr_en = 1'b1;

        @(posedge clk); #1;
        $display("After instruction #2 : Result = %d", alu_result);

        // ADD x3, x1, x2 
        rs1_addr = 5'd1; // x0
        rs2_addr = 5'd2; // Dont care for I-Type
        rd_addr = 5'd3; // x1
        imm = 32'd0; // Dont care for R-Type instructions
        alu_op = 4'b0000; // ADD
        alu_src = 1'b0; // Choose the immediate value
        reg_wr_en = 1'b1;

        @(posedge clk); #1;
        $display("After instruction #3 : Result = %d", alu_result);

        // ADD x4, x1, x3 
        rs1_addr = 5'd1; // x0
        rs2_addr = 5'd3; // Dont care for I-Type
        rd_addr = 5'd4; // x1
        imm = 32'd0; // Dont care for R-Type instructions
        alu_op = 4'b0000; // ADD
        alu_src = 1'b0; // Choose the immediate value
        reg_wr_en = 1'b1;

        @(posedge clk); #1;
        $display("After instruction #4 : Result = %d", alu_result);

        $finish;
    end

endmodule