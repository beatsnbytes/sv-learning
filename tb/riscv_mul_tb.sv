// riscv_mul_tb.sv
// Testbench for the RISCV-32 multiplier
// Week12 : implementing and integrating the multiplier testbench

module riscv_mul_tb;

    logic clk;
    logic rst;
    logic start;
    logic [31:0] op_a;
    logic [31:0] op_b;
    logic [3:0] op;
    logic [31:0] result;
    logic done;
    logic busy;
    integer success_cnt, fail_cnt;

    riscv_mul dut(
    .clk(clk),
    .rst(rst),
    .start(start),
    .op_a(op_a),
    .op_b(op_b),
    .op(op),
    .result(result),
    .done(done), 
    .busy(busy)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("../sim/riscv_mul_tb.vcd");
        $dumpvars(0, riscv_mul_tb);
        
        success_cnt = 0;
        fail_cnt = 0;
        // Reset the multiplier
        rst = 1'b1;
        repeat(3) @(posedge clk); #1;
        rst = 1'b0;

        // TEST 1 : MUL 3 × 5 = 15
        $display("TEST 1 : MUL 3 × 5 = 15");
        op_a = 32'd3;
        op_b = 32'd5;
        op =  4'b1010;
        start = 1'b1;
        @(posedge clk); #1;
        start = 1'b0;

        // Wait until the multiplier acknowledges
        @(posedge done);


        if (result != 32'd15) begin
            $display("Error! Expected result=15 but got %h", result);
            fail_cnt++;
        end else begin
            success_cnt++;
        end


        // TEST 2 : MUL 0 × anything = 0
        $display("TEST 2 : MUL 0 × anything = 0");
        op_a = 32'd0;
        op_b = 32'd53;
        op =  4'b1010;
        start = 1'b1;
        @(posedge clk); #1;
        start = 1'b0;

        // Wait until the multiplier acknowledges
        @(posedge done);

        if (result != 32'd0) begin
            $display("Error! Expected result=0 but got %h", result);
            fail_cnt++;
        end else begin
            success_cnt++;
        end

        // TEST 3 : MUL 0xFFFFFFFF × 2 = 64'h00000001_FFFFFFFE— check lower and upper 32 bits
        $display("TEST 3 : MUL 0xFFFFFFFF × 2 = 64'h00000001_FFFFFFFE— check lower and upper 32 bits");
        op_a = 32'hFFFFFFFF;
        op_b = 32'd2;
        op =  4'b1010;
        start = 1'b1;
        @(posedge clk); #1;
        start = 1'b0;

        // Wait until the multiplier acknowledges
        @(posedge done);

        if (result != 32'hFFFFFFFE) begin
            $display("Error! Expected result=FFFFFFE but got %h", result);
            fail_cnt++;
        end else begin
            success_cnt++;
        end

        op_a = 32'hFFFFFFFF;
        op_b = 32'd2;
        op =  4'b1011;
        start = 1'b1;
        @(posedge clk); #1;
        start = 1'b0;

        // Wait until the multiplier acknowledges
        @(posedge done);

        if (result != 32'h00000001) begin
            $display("Error! Expected result=1 but got %h", result);
            fail_cnt++;
        end else begin
            success_cnt++;
        end

        // TEST 4 : Two back-to-back MUL operations without waiting for done assertion
        $display("TEST 4 : Two back-to-back MUL operations without waiting for done assertion");
        op_a = 32'd10;
        op_b = 32'd5;
        op =  4'b1010;
        start = 1'b1;
        @(posedge clk); #1;
        start = 1'b0;

        // Wait until the multiplier acknowledges
        repeat(10) @(posedge clk);

        op_a = 32'd2;
        op_b = 32'd7;
        op =  4'b1010;
        start = 1'b1;
        @(posedge clk); #1;
        start = 1'b0;

        // Wait until the multiplier acknowledges
        @(posedge done);


        if (result != 32'd50) begin
            $display("Error! Expected result=50 but got %h", result);
            fail_cnt++;
        end else begin
            success_cnt++;
        end



    $display("PASS: %d | FAIL: %d", success_cnt, fail_cnt);
    $finish;
    end

endmodule