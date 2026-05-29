// riscv_cpu_tb.sv
// Test all the modules of the CPU connected together
// Week10 - Testing th whole CPU

module riscv_cpu_tb;

    logic clk, rst;
    logic [31:0] pc, alu_result;
    logic zero;

    riscv_cpu dut (
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .alu_result(alu_result),
    .zero(zero)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("../sim/riscv_cpu_tb.vcd");
        $dumpvars(0, riscv_cpu_tb);

        // Reset for 2 cycles
        rst = 1'b1;
        repeat(2) @(posedge clk); #1;
        rst = 1'b0;

        // Wait enough cycles to see the output of the alu
        repeat(40) @(posedge clk); #1;

        $finish;
    end

    initial begin
        $monitor("time=%2t pc=%h | alu_result=%h | zero=%b",
        $time, pc, alu_result, zero);
    end

endmodule