// riscv_alu_tb.sv
// Testbench for the RISC-V ALU
// Week10 - Towards a RISC-V processor. Testing the ALU

module riscv_alu_tb;

    logic [3:0] op;
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] result;
    logic zero;

    riscv_alu dut(
        .op(op),
        .a(a),
        .b(b),
        .result(result),
        .zero(zero)
    );



    initial begin
        $dumpfile("../sim/riscv_alu_tb.vcd");
        $dumpvars(0, riscv_alu_tb);

        // Test 1 - ADD including overflow
        $display("Test 1a - 5 + 15 = 20");
        op = 4'b0000;
        a = 32'd5;
        b = 32'd15;
        #10;
        if (result != 32'd20) $display("FAIL: Expected 20, got %d", result);

        $display("Test 1b - Test overflow 32'hFFFFFFFF + 32'h00000001 = 32'h00000000");
        op = 4'b0000;
        a = 32'h00000001;
        b = 32'hFFFFFFFF;
        #10;
        if (result != 32'd0) $display("FAIL: Expected 0, got %d", result);
        if ((result == 32'b0) && !zero) $display("FAIL: Result = 0 but zero flag deasserted");

        // Test 2 - SUB including underflow
        $display("Test 2a - 20 - 15 = 5");
        op = 4'b0001;
        a = 32'd20;
        b = 32'd15;
        #10;
        if (result != 32'd5) $display("FAIL: Expected 5, got %d", result);

        $display("Test 2b - 0 - 1 = -1");
        op = 4'b0001;
        a = 32'd0;
        b = 32'd1;
        #10;
        if (result != 32'hFFFFFFFF) $display("FAIL: Expected 32'hFFFFFFFF, got %d", result);

        // Test 3 - AND
        $display("Test 3 - 32'h0F0F0F0F AND 32'hF0F00F0F = 32'h0000FFFF");
        op = 4'b0010;
        a = 32'h0F0F0F0F;
        b = 32'hF0F00F0F;
        #10;
        if (result != 32'h00000F0F) $display("FAIL: Expected 32'h00000F0F, got %h", result);

        // Test 4 - OR
        $display("Test 4 - 32'h0F0F0F0F OR 32'hF0F00000 = 32'hFFFF0F0F");
        op = 4'b0011;
        a = 32'h0F0F0F0F;
        b = 32'hF0F00000;
        #10;
        if (result != 32'hFFFF0F0F) $display("FAIL: Expected 32'hFFFF0F0F, got %h", result);

        // Test 5 - XOR
        $display("Test 5 - 32'h0F0F0F0F XOR 32'hF0F00000 = 32'hFFFFF0F0");
        op = 4'b0100;
        a = 32'h0F0F0F0F;
        b = 32'hF0F0FFFF;
        #10;
        if (result != 32'hFFFFF0F0) $display("FAIL: Expected 32'hFFFF0F0F, got %h", result);


        // Test 6 - SLL check shift by 0 and 31
        $display("Test 6a - 32'h0000000F SLL 28 = 32'hF00000000");
        op = 4'b0101;
        a = 32'h0000000F;
        b = 32'd28;
        #10;
        if (result != 32'hF0000000) $display("FAIL: Expected 32'hF0000000, got %h", result);

        $display("Test 6b - 32'h0000000F SLL 0 = 32'h00000000F");
        op = 4'b0101;
        a = 32'h0000000F;
        b = 32'd0;
        #10;
        if (result != 32'h0000000F) $display("FAIL: Expected 32'h0000000F, got %h", result);

        $display("Test 6c - 32'h0000000F SLL 31 = 32'h800000000");
        op = 4'b0101;
        a = 32'h0000000F;
        b = 32'd31;
        #10;
        if (result != 32'h80000000) $display("FAIL: Expected 32'h80000000, got %h", result);


        // Test 7 - SRL check shift by 0 and 31
        $display("Test 7a - 32'hF0000000 SRL 28 = 32'h00000000F");
        op = 4'b0110;
        a = 32'hF0000000;
        b = 32'd28;
        #10;
        if (result != 32'h0000000F) $display("FAIL: Expected 32'h0000000F, got %h", result);

        $display("Test 7b - 32'hF0000000 SLL 0 = 32'hF00000000");
        op = 4'b0110;
        a = 32'hF0000000;
        b = 32'd0;
        #10;
        if (result != 32'hF0000000) $display("FAIL: Expected 32'hF0000000, got %h", result);

        $display("Test 7c - 32'hF0000000 SLL 31 = 32'h00000001");
        op = 4'b0110;
        a = 32'hF0000000;
        b = 32'd31;
        #10;
        if (result != 32'h00000001) $display("FAIL: Expected 32'h00000001, got %h", result);


        // Test 8 - SRA must preserve negative bits - test with negative numbers
        $display("Test 8 - 32'hF0000000 SRA 28 = 32'hFFFFFFFF");
        op = 4'b0111;
        a = 32'hF0000000;
        b = 32'd28;
        #10;
        if (result != 32'hFFFFFFFF) $display("FAIL: Expected 32'hFFFFFFFF, got %h", result);
        
        // Test 9 - SLT test signed  -1 < 1 TRUE, 1< -1 FALSE
        $display("Test 9a - -1 < 1 = 32'h00000001 (TRUE)");
        op = 4'b1000;
        a = 32'hFFFFFFFF;
        b = 32'd1;
        #10;
        if (result != 32'h00000001) $display("FAIL: Expected 32'h00000001, got %h", result);

        $display("Test 9b  1 < -1 = 32'h00000000 (FALSE)");
        op = 4'b1000;
        a = 32'd1;
        b = 32'hFFFFFFFF;
        #10;
        if (result != 32'h00000000) $display("FAIL: Expected 32'h00000000, got %h", result);
        if ((result == 32'b0) && !zero) $display("FAIL: Result = 0 but zero flag deasserted");


        // Test 10 SLTU test unsigned - large unsigned number is not less than small one
        $display("Test 10 - 32'hFFFFFFFF < 32'h00000001 = 32'h00000000 (FALSE)");
        op = 4'b1001;
        a = 32'hFFFFFFFF;
        b = 32'd1;
        #10;
        if (result != 32'h00000000) $display("FAIL: Expected 32'h00000000, got %h", result);
        if ((result == 32'b0) && !zero) $display("FAIL: Result = 0 but zero flag deasserted");
        
        $finish;

    end

endmodule