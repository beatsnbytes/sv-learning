// spi.sv
// Implementation of the SPI interface (Master)

module spi_master #(
        parameter DATA_WIDTH = 32,
        parameter CLKDIV = 4
    )(
        // CPU-side
        input logic clk, 
        input logic rst, 
        input logic start, 
        input logic [DATA_WIDTH - 1 : 0] data_in,
        output logic [DATA_WIDTH - 1 : 0] data_out, 
        output logic done,
        // SPI-bus side
        input logic miso,
        output logic mosi,
        output logic sclk,
        output logic cs
    );

    localparam DIV_COUNTER_WIDTH = $clog2(CLKDIV);
    

    logic [DIV_COUNTER_WIDTH-1 : 0] clk_div_counter;
    logic [DATA_WIDTH - 1 : 0] shift_reg;
    logic  [$clog2(DATA_WIDTH) : 0] shift_reg_counter;

    logic sclk_reg, rising_edge, falling_edge;
    logic busy;



    // Compute the sclk
    always_ff @(posedge clk) begin
        if (rst || !busy) begin
            sclk <= 1'b0;
            clk_div_counter <= (DIV_COUNTER_WIDTH)'(0);
        end else if (clk_div_counter == (DIV_COUNTER_WIDTH)'(CLKDIV/2 -1)) begin
            sclk <= ~sclk;
            clk_div_counter <= 0;
        end else begin
            clk_div_counter <= clk_div_counter + 1;
        end
    end

    always_ff @(posedge clk) begin
        sclk_reg <= sclk; // separate always block, always lags by one cycle
    end

    assign rising_edge = sclk && !sclk_reg;
    assign falling_edge = !sclk && sclk_reg;


    always_ff @(posedge clk) begin
        if (rst) begin
            mosi <= 1'b0;
            shift_reg_counter <= ($clog2(DATA_WIDTH)+1)'(0);  
            done <= 1'b0;
            busy <= 1'b0;
            cs <= 1'b1;
        end else if (start) begin
            busy <= 1'b1;
            cs <= 1'b0;
            shift_reg <= data_in;  
            mosi <= data_in[DATA_WIDTH -1];
        end else if (busy) begin
            if (rising_edge) begin
                // Sample MISO logic here
                if (shift_reg_counter < DATA_WIDTH) begin
                    shift_reg_counter <= shift_reg_counter + 1;
                    shift_reg <= {shift_reg[DATA_WIDTH - 2 : 0], miso};
                end
            end else if (falling_edge) begin
                // Drive MOSI logic here
                mosi <= shift_reg[DATA_WIDTH -1];
                if (shift_reg_counter == DATA_WIDTH) begin
                    done <= 1'b1;
                    busy <= 1'b0;
                    data_out <= shift_reg;
                    shift_reg_counter <= ($clog2(DATA_WIDTH)+1)'(0);
                    shift_reg <= (DATA_WIDTH)'(0);
                end
            end
        end else if (done) begin
            done <= 1'b0;
            cs <= 1'b1;
        end
    end 

endmodule