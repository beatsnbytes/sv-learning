// shift_reg.sv
// 4-bit shift register with synchronous reset
// Week 3 - chained flip-flops, non-blocking assignment

module shift_reg (
    input logic clk, 
    input logic rst, 
    input logic d, 
    output logic [3:0] q
);

    always_ff @(posedge clk) begin
        if (rst)
            q <= 4'b0;
        else begin 
            q[3] <= q[2];
            q[2] <= q[1];
            q[1] <= q[0];
            q[0] <= d;
        end
    end

endmodule