// fifo_if.sv
// SystemVerilog interface for FIFO DUT connections
// Week8 - interface, clocking block

interface fifo_if #(
    parameter int DATA_WIDTH = 8
)(
    input logic clk
);

    logic rst;
    logic wr_en;
    logic rd_en;
    logic [DATA_WIDTH-1 : 0] wr_data;
    logic [DATA_WIDTH-1 : 0] rd_data;
    logic full;
    logic empty;

endinterface