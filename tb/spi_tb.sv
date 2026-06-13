// spi_tb.sv
// Week 16 : Testbench for SPI master module

module spi_tb;

    localparam int DATA_WIDTH = 8;
    localparam int CLKDIV = 4;

    logic clk, sclk, rst;
    logic start, done;
    logic cs;
    logic [DATA_WIDTH-1 : 0] data_in;
    logic [DATA_WIDTH-1 : 0] data_out;
    logic miso, mosi;

    integer success_count, fail_count;
    logic [DATA_WIDTH-1 : 0] mosi_data_concat;

    spi_master #(
        .DATA_WIDTH(DATA_WIDTH),
        .CLKDIV(CLKDIV)
    ) dut (
        .clk(clk), 
        .rst(rst), 
        .start(start), 
        .data_in(data_in),
        .data_out(data_out), 
        .done(done),
        .miso(miso),
        .mosi(mosi),
        .sclk(sclk),
        .cs(cs)
    );


    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("../sim/spi_tb.vcd");
        $dumpvars(0, spi_tb);

        success_count = 0;
        fail_count = 0;
        mosi_data_concat = (DATA_WIDTH)'(0);

        // Reset the system
        rst = 1'b1;
        repeat(2) @(posedge clk); #1
        rst = 1'b0;

        // TEST 1 - MOSI send known pattern - verify
        data_in = 8'hAB; // 1010 1011
        start = 1'b1;
        @(posedge clk); #1;
        start = 1'b0;

        @(posedge sclk); #1;
        if (cs == 1'b1) begin
            $display("ERROR: CS should be low by now!");
            fail_count++;
        end else begin
            success_count++;
        end

        
        miso = 1'b1;
        @(negedge sclk); #1;
        mosi_data_concat = {mosi_data_concat[DATA_WIDTH-2 : 0], mosi};
        // miso = 1'b1;
        // Have to wait for 8 * 4 = 32 cc
        // repeat(40) @(posedge clk); #1;
        repeat(7) begin
            @(posedge sclk); #1;
            miso = 1'b1;
            
            @(negedge sclk); #1;
            mosi_data_concat = {mosi_data_concat[DATA_WIDTH-2 : 0], mosi};
            
        end



        // Wait for the assertion of the done signal
        if (!done) @(posedge done); #1;

        if(mosi_data_concat != 8'hAB) begin
            $display("ERROR: Expected 0xAB but got %h", mosi_data_concat);
            fail_count++;
        end else begin
            success_count++;
        end

        if(data_out != 8'hFF) begin
            $display("ERROR: Expected 0xFF but got %h", data_out);
            fail_count++;
        end else begin
            success_count++;
        end

        @(posedge clk); #1;
        if (done == 1'b1) begin
            $display("ERROR: done should be low by now!");
            fail_count++;
        end else begin
            success_count++;
        end

        if (cs == 1'b0) begin
            $display("ERROR: CS should be high by now!");
            fail_count++;
        end else begin
            success_count++;
        end


        $finish;        
    end

    initial begin
    $monitor("time=%0t | miso=%b mosi=%h | data_in=%b data_out=%h | cs=%b, done=%b",
            $time, miso, mosi, data_in, data_out, cs, done);
    end


endmodule