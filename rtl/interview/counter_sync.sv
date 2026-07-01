// Counter t MAX-1, synchronous reset, wraps around

module counter_syn #(
    parameter MAX = 10
    )(
    input logic clk,
    input logic rst,
    input logic cnt_en,
    output logic [CNT_WIDTH - 1 : 0] cnt
    );

    localparam int CNT_WIDTH = $clog2(MAX);

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= (CNT_WIDTH)'(0);
        end else if (cnt_en) begin
            if (cnt < (MAX-1)) begin
                cnt <= cnt + (CNT_WIDTH)'(1);
            end else begin
                cnt <= (CNT_WIDTH)'(0); 
            end
        end else begin
            cnt <= cnt; // When not enable hold value. Could be omitted since in an always_ff block but explicitly stating is clearer.
        end        
    end

endmodule