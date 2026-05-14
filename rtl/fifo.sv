// fifo.sv
// Parametrised synchronous FIFO
// Week 5 - parameters, arrays, $clog2, full/empty flags

module fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 8
)(
    input logic clk,
    input logic rst,
    input logic wr_en, 
    input logic rd_en,
    input logic [DATA_WIDTH-1 : 0] wr_data, 
    output logic [DATA_WIDTH-1 : 0] rd_data,
    output logic full, 
    output logic empty
);


    // Local parameter - pointer width derived automatically
    localparam int PTR_WIDTH = $clog2(DEPTH);

    // Memory array
    logic [DATA_WIDTH-1 : 0] mem [0 : DEPTH-1];

    // Pointers and count
    logic [PTR_WIDTH-1 :0] wr_ptr, rd_ptr;
    logic [PTR_WIDTH :0] count; // one bit wider to hold value 0 to depth

    // Full and empty flags
    assign full = (count == (PTR_WIDTH+1)'(DEPTH));
    assign empty = (count == 0);

    // Write logic
    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= '0; // Parametric way to fill everything with zeroes
            rd_ptr <= '0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr <= (wr_ptr == PTR_WIDTH'(DEPTH-1)) ? '0 : wr_ptr + 1'b1;
        end
    end

    // Read logic
    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr];
            rd_ptr <= (rd_ptr == PTR_WIDTH'(DEPTH-1)) ? '0 : rd_ptr + 1'b1;
        end
    end

    // Count logic
    always_ff @(posedge clk) begin
        if (rst)
            count <= '0;
        else begin
            case({wr_en && !full, rd_en && !empty})
                2'b10 : count <= count + 1'b1; // write only
                2'b01 : count <= count - 1'b1; // read only 
                2'b11 : count <= count; // simultaneous read + write
                default: count <= count; // no operation
            endcase
        end
    end

    // Read data output - combinational peek at current rd_ptr
    // (already handled at read always_ff above)

endmodule

