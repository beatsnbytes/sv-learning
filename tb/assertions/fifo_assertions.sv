// fifo_assertions.sv
// Module containing checks and concurrent assertions for the FIFO verification
// Week7 : assertions

module fifo_assertions #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 8
)(
    input logic clk,
    input logic rst,
    input logic wr_en,
    input logic rd_en,
    input logic [DATA_WIDTH-1 :0] wr_data,
    input logic [DATA_WIDTH-1 :0] rd_data,
    input logic full,
    input logic empty,
    input logic [$clog2(DEPTH):0] count
);

    // localparam logic [$clog2(DEPTH):0] DEPTH_VAL = DEPTH;

    // Assert: full and empty cannot be high at the same time
    a1_full_empty: assert property (@(posedge clk) !(full && empty));

    // Assert: When full is high the count must equal DEPTH
    a2_full_count: assert property (@(posedge clk) (full |-> (count == ($clog2(DEPTH)+1)'(DEPTH))));

    // Assert: when empty is high the count must equal to 0
    a3_high_count: assert property (@(posedge clk) (empty |-> (count == '0)));

    // Assert: Write when full should be ignored
    a4_write_full: assert property (@(posedge clk) (wr_en && full) |=> (count <= $past(count)));
    else $error("A4: count increased after write when full");

    // Assert: Read when empty should be ignored
    a5_read_empty: assert property (@(posedge clk) (rd_en && empty) |=> (count >= $past(count)))
    else $error("A5: count decreased after read when empty");

endmodule
