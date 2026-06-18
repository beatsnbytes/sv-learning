// uart_tb.sv
// Week 17 UART Tx testbench

module uart_tb;

    uart_tx #(
        .DATA_BITS(DATA_BITS),
        .PARITY_EN(PARITY_EN),
        .BAUD_RATE(BAUD_RATE),
        .FREQ(FREQ)
        ) dut (
        .clk(clk), 
        .rst(rst),
        .initiate(initiate),
        .data_in(data_in),
        .bit_out(bit_out),
        .done(done),
        .bit_out_valid(bit_out_valid),
        .baud_counter(baud_counter)
        );


    localparam int DATA_BITS = 8;
    localparam int PARITY_EN = 0;
    localparam int BAUD_RATE = 10;
    localparam int FREQ = 100;
    localparam int CYCLES_PER_BIT = FREQ/BAUD_RATE;

    logic clk;
    logic rst;
    logic [DATA_BITS-1 : 0] data_in;
    logic initiate;
    logic bit_out_valid;
    logic bit_out;
    logic done;
    logic [(DATA_BITS+2)-1 : 0] received_word;
    logic [($clog2(CYCLES_PER_BIT) + 1) - 1 : 0] baud_counter;

    int success_count, fail_count, cycle_count;

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("../sim/uart_tb.vcd");
        $dumpvars(0, uart_tb);

        success_count = 0;
        fail_count = 0;
        
        rst = 1'b1;
        repeat(3) @(posedge clk); #1;
        rst = 1'b0;

        data_in = 8'hAB; // 1010 1011
        initiate = 1'b1;
        @(posedge clk); #1;
        initiate = 1'b0; //Deassert initiate after 1cc. Can also hold it to see uart tx behaviour

        received_word = 10'b0;

        @(negedge bit_out); #1;
        received_word = {bit_out, received_word[(DATA_BITS+2)-1 : 1]}; // Capture - LSB first sent by UART Tx


        repeat(9) begin // 10 bits 8N1 serial framing format (1 START, 8 DATA, 1 STOP, NO PARITY)
            @(posedge bit_out_valid); #1;
            if (baud_counter != 1) begin
                $display("ERROR: baud_counter has erroneous value. Expected 0 got %d", baud_counter);
                fail_count++;     
            end else begin
                success_count++;
            end
            received_word = {bit_out, received_word[(DATA_BITS+2)-1 : 1]}; // Capture - LSB first sent by UART Tx 
        end


        // cycle_count = 0;
        // @(posedge bit_out_valid); // wait for first pulse
        // received_word = {bit_out, received_word[(DATA_BITS+2)-1 : 1]}; // Capture - LSB first sent by UART Tx 
        // // now start measuring

        // repeat(10) begin

        //     // @(posedge bit_out_valid); // wait for first pulse
        //     // // now start measuring
        //     fork
        //         @(posedge bit_out_valid); // wait for second pulse
        //         received_word = {bit_out, received_word[(DATA_BITS+2)-1 : 1]}; // Capture - LSB first sent by UART Tx 
        //         begin
        //             while(1) begin
        //                 @(posedge clk); #1;
        //                 cycle_count++;
        //             end
        //         end
        //     join_any
        //     // cycle_count now holds cycles between pulse 1 and pulse 2
        //     if (cycle_count != CYCLES_PER_BIT) begin
        //         $display("ERROR: Erroneous cycles for baud rate. Expected %d got %d", CYCLES_PER_BIT, cycle_count);
        //         fail_count++;     
        //     end else begin
        //         success_count++;
        //     end
        //     cycle_count = 0;
        //     // received_word = {bit_out, received_word[(DATA_BITS+2)-1 : 1]}; // Capture - LSB first sent by UART Tx 
        // end

        if (received_word[DATA_BITS : 1] != data_in) begin
            $display("ERROR: Expected %h, got %h", data_in, received_word);
            fail_count++;
        end else begin
            success_count++;
        end

        $display("PASS: %d | FAIL: %d", success_count, fail_count);

    $finish;
    end

    initial begin
        $monitor("time=%t | bit_out=%b | bit_out_valid=%b | baud_counter=%h | received_word=%b",
            $time, bit_out, bit_out_valid, baud_counter, received_word);
    end

endmodule