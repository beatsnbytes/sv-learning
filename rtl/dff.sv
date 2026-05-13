// dff.sv
// D flip-flop with synchronous reset
// Week3  - first sequential logic, always ff

module dff (
    input logic clk,
    input logic rst,
    input logic d, 
    output logic q
);

    always_ff @(posedge clk ) begin
        if (rst)
            q <= 1'b0;
        else
            q <= d;
    end

endmodule