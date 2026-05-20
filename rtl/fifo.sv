// fifo.sv
// Parameterised synchronous FIFO
// Week 5 — parameters, arrays, $clog2, full/empty flags

module fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 8
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  wr_en,
    input  logic                  rd_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  full,
    output logic                  empty
);

    localparam int PTR_WIDTH = $clog2(DEPTH);
    localparam logic [PTR_WIDTH:0]   DEPTH_VAL = ($clog2(DEPTH)+1)'(DEPTH);
    localparam logic [PTR_WIDTH-1:0] DEPTH_M1  = (PTR_WIDTH)'(DEPTH-1);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_WIDTH-1:0]  wr_ptr, rd_ptr;
    logic [PTR_WIDTH:0]    count;

    assign full    = (count == DEPTH_VAL);
    assign empty   = (count == 0);
    assign rd_data = mem[rd_ptr];

    // Write logic
    always_ff @(posedge clk) begin
        if (rst)
            wr_ptr <= '0;
        else if (wr_en && !full) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr      <= (wr_ptr == DEPTH_M1) ? '0 : wr_ptr + 1'b1;
        end
    end

    // Read pointer logic
    always_ff @(posedge clk) begin
        if (rst)
            rd_ptr <= '0;
        else if (rd_en && !empty)
            rd_ptr <= (rd_ptr == DEPTH_M1) ? '0 : rd_ptr + 1'b1;
    end

    // Count logic
    always_ff @(posedge clk) begin
        if (rst)
            count <= '0;
        else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                2'b11: count <= count;
                default: count <= count;
            endcase
        end
    end

endmodule