// seg7_decoder_tb.sv
// Testbench for seg7 decoder
// Week 2 - testing all BCD digits and invalid inputs

module seg7_decoder_tb;

    logic [3:0] bcd;
    logic [6:0] seg;

    seg7_decoder dut (
        .bcd(bcd),
        .seg(seg)
    );

    initial begin
        
        $dumpfile("../sim/seg7_decoder_tb.vcd");
        $dumpvars(0, seg7_decoder_tb);

        // Test all valid BCD digits
        bcd = 4'd0; #10;
        bcd = 4'd1; #10;
        bcd = 4'd2; #10;
        bcd = 4'd3; #10;
        bcd = 4'd4; #10;
        bcd = 4'd5; #10;
        bcd = 4'd6; #10;
        bcd = 4'd7; #10;
        bcd = 4'd8; #10;
        bcd = 4'd9; #10;

        //Test invalid BCD inputs - should all output 1111111 (all segs off)
        bcd = 4'd10; #10;
        bcd = 4'd11; #10;
        bcd = 4'd12; #10;
        bcd = 4'd13; #10;
        bcd = 4'd14; #10;
        bcd = 4'd15; #10;

        $display("Simulation complete");
        $finish;
    end

        initial begin
            $monitor("t=%0t | bcd=%0d | seg=gfedcba=%b",
            $time, bcd, seg);
        end

endmodule
