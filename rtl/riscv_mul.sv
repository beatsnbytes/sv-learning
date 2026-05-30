// riscv_mul.sv
// Multiplier for the RISCV-32 core
// Meek12 : implementing and integrating the multiplier

module riscv_mul(
    input logic clk,
    input logic rst,
    input logic start,
    input logic [31:0] op_a,
    input logic [31:0] op_b,
    input logic [2:0] op,
    output logic [31:0] result,
    output logic done
);

    logic [5:0] bit_idx; // To index 32 bit positions
    logic [31:0] op_a_latched, op_b_latched;
    logic [63:0] op_a_shifted;
    logic [63:0] running_total;
    logic busy;

    always_comb begin
        case (op)
            3'b000: result = running_total[31:0];
            3'b001: result = running_total[63:32];
            default: result = 32'b0;
        endcase
    end

    always_ff @(posedge clk) begin
        done <= 1'b0;
        if (rst) begin
            done <= 1'b0;
            busy <= 1'b0;
            bit_idx <= 6'b0;
            running_total <= 64'b0;
            op_a_latched <= 32'b0;
            op_b_latched <= 32'b0;
            op_a_shifted <= 64'b0;
        end else if (start) begin
            // Latch the input operands
            busy <= 1'b1;
            op_a_latched <= op_a;
            op_b_latched <= op_b;
            bit_idx <= 6'b0;
            running_total <= 64'b0;
        end else if (busy && (bit_idx != 6'd32)) begin 
            // Shift and add multiplier
            bit_idx <= bit_idx + 1;
            op_a_shifted <= 64'(op_a_latched) << bit_idx;
            running_total <= op_b_latched[bit_idx[4:0]] ? (running_total + op_a_shifted) : running_total;
        end else if (busy && (bit_idx == 6'd32)) begin
            done <= 1'b1;
            busy <= 1'b0;
        end
    end

endmodule