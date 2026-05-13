// priority_encoder.sv
// 4-to-2 priority encoder
// Week 2 - if/else priority chain, valid signal

module priority_encoder (
    input logic [3:0] in,
    output logic [1:0] out, 
    output logic valid
);

always_comb begin
    valid = 1'b1;
    if (in[3]) out = 2'b11;
    else if (in[2]) out = 2'b10;
    else if (in[1]) out = 2'b01;
    else if (in[0]) out = 2'b00;
    else begin
        out = 2'b00;
        valid = 1'b0;
    end
end

endmodule
