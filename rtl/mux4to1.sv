// mux4to1.sv
// 4-to-1 multiplexer
// Week 1 - case statement, multi-bit signals


module mux4to1 (
    input logic [1:0] sel,
    input logic [3:0] in0, in1, in2, in3,
    output logic [3:0] y
); 

always_comb begin
    case (sel)
        2'b00: y = in0;
        2'b01: y = in1;
        2'b10: y = in2;
        2'b11: y = in3;
        default: y = 4'b0;
    endcase
end

endmodule




