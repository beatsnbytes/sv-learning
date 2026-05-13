// counter.sv
// 4-bit synchronous counter with enable and reset
// Week 3 - feedback, enable signal, overflow

module counter (
    input logic clk, 
    input logic rst,
    input logic en,
    output logic [3:0] count
);

    always_ff @(posedge clk) begin
        if (rst)
            count <= 4'b0;
        else if (en)
            count <= count + 1'b1;
    end

endmodule