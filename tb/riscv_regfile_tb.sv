// riscv_regfile_tb.sv
// Simple testbench for riscv_regfile
// Week10: Towards a riscv processor - Testing the riscv_regfile

module riscv_regfile_tb;

    logic clk, wr_en;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] rd_data;

    riscv_regfile dut (
        .clk(clk),
        .wr_en(wr_en),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_data(rd_data)
    );

    int pass_count, fail_count;

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
    $dumpfile("../sim/riscv_regfile_tb.vcd");
    $dumpvars(0, riscv_regfile_tb);

    pass_count = 0;
    fail_count = 0;

    // Test 1 - Write a value to x1, read it back on rs1 and rs2
    $display("TEST 1: Write 0xCAFEBABE to x1, read it back on rs1 and rs2");
    wr_en = 1'b1;
    rd_addr = 5'b00001;
    rd_data = 32'hCAFEBABE;

    @(posedge clk); #1;

    wr_en = 1'b0;

    rs1_addr = 5'b00001; 
    #1;
    if (rs1_data != 32'hCAFEBABE) begin
        $display(" ERROR in rs1 read. Expected 0xCAFEBABE got %h", rs1_data);
        fail_count++;       
    end else begin
        pass_count++;
    end
    rs2_addr = 5'b00001;
    #1;
    if (rs2_data != 32'hCAFEBABE) begin 
        $display(" ERROR in rs2 read. Expected 0xCAFEBABE got %h", rs2_data);
        fail_count++;
    end else begin
        pass_count++;
    end


    // Test 2 - Write to several registers, verify each reads correctly
    $display("TEST 2: Write to several registers, verify each reads correctly");

    wr_en = 1'b1;

    rd_addr = 5'b00001;
    rd_data = 32'hCAFEBABE;

    @(posedge clk); #1;

    rd_addr = 5'b00010;
    rd_data = 32'hDEADBEEF;

    @(posedge clk); #1;

    rd_addr = 5'b00011;
    rd_data = 32'hCAFE0001;

    @(posedge clk); #1;

    rd_addr = 5'b00100;
    rd_data = 32'hDEAD0001;

    @(posedge clk); #1;

    rd_addr = 5'b00101;
    rd_data = 32'hCAFE0002;

    @(posedge clk); #1;

    rd_addr = 5'b00110;
    rd_data = 32'hDEAD0002;

    @(posedge clk); #1;


    wr_en = 1'b0;

    rs1_addr = 5'b00001;
    #1;
    if (rs1_data != 32'hCAFEBABE) begin
        $display(" ERROR in rs1 read. Expected 0xCAFEBABE got %h", rs1_data);
        fail_count++;       
    end else begin
        pass_count++;
    end

    rs2_addr = 5'b00010;
    #1;
    if (rs2_data != 32'hDEADBEEF) begin
        $display(" ERROR in rs2 read. Expected 0xDEADBEEF got %h", rs2_data);
        fail_count++;       
    end else begin
        pass_count++;
    end

    @(posedge clk); #1;

    rs1_addr = 5'b00011;
    #1;
    if (rs1_data != 32'hCAFE0001) begin
        $display(" ERROR in rs1 read. Expected 0xCAFE0001 got %h", rs1_data);
        fail_count++;       
    end else begin
        pass_count++;
    end

    rs2_addr = 5'b00100;
    #1;
    if (rs2_data != 32'hDEAD0001) begin
        $display(" ERROR in rs2 read. Expected 0xDEAD0001 got %h", rs2_data);
        fail_count++;       
    end else begin
        pass_count++;
    end

    @(posedge clk); #1;

    rs1_addr = 5'b00101;
    #1;
    if (rs1_data != 32'hCAFE0002) begin
        $display(" ERROR in rs1 read. Expected 0xCAFE0002 got %h", rs1_data);
        fail_count++;       
    end else begin
        pass_count++;
    end

    rs2_addr = 5'b00110;
    #1;
    if (rs2_data != 32'hDEAD0002) begin
        $display(" ERROR in rs2 read. Expected 0xDEAD0002 got %h", rs2_data);
        fail_count++;       
    end else begin
        pass_count++;
    end

    @(posedge clk); #1;

    // Test 3 - Write to x0 - verify it still reads as zero

    wr_en = 1'b1;

    rd_addr = 5'b00000;
    rd_data = 32'hCAFEBABE;

    @(posedge clk); #1;

    rs1_addr = 5'b00000;
    #1;
    if (rs1_data != 32'h0) begin
        $display(" ERROR in x0 read. Expected zero got %h", rs1_data);
        fail_count++;       
    end else begin
        pass_count++;
    end


    @(posedge clk); #1;


    // Test 4 - Read x0 directly - verify zero
    rs1_addr = 5'b00000;
    #1;
    if (rs1_data != 32'h0) begin
        $display(" ERROR in x0 read. Expected zero got %h", rs1_data);
        fail_count++;       
    end else begin
        pass_count++;
    end

   @(posedge clk); #1;

    // Test 5 - Write with wr_en = 0 - verify register doesnt change

    wr_en = 0;

    rd_addr = 5'b00010;
    rd_data = 32'hFFFFFFFF;
 
   @(posedge clk); #1;

    rs1_addr = 5'b00010;
    #1;
    if (rs1_data != 32'hDEADBEEF) begin
        $display(" ERROR in x2 read. Expected 0xDEADBEEF got %h", rs1_data);
        fail_count++;       
    end else begin
        pass_count++;
    end

    @(posedge clk); #1;


    // Test 4 - Read x0 directly - verify zero
    rs1_addr = 5'b00000;
    #1;
    if (rs1_data != 32'h0) begin
        $display(" ERROR in x0 read. Expected zero got %h", rs1_data);
        fail_count++;       
    end else begin
        pass_count++;
    end

    $display("Success : %d | Fail : %d", pass_count, fail_count);
        
    $finish;
    end


endmodule