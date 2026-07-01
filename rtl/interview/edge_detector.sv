// Edge detector module
// Detect both rising and falling edges. Outputs a separate pulse 1cc wide for each

module edge_detector (
    input logic clk,
    input logic signal,
    output logic rising_edge,
    output logic falling_edge
    );

    logic prev_signal;
    logic edge_detected;
    logic [1:0] signal_combined;

    // Limitation : The clock should be faster than the signal changes.


    // Combine previous and current values
    assign signal_combined = {prev_signal, signal};

    // Produce an edge_detected signal.
    always_comb begin
        rising_edge = 1'b0;
        falling_edge = 1'b0;
        case (signal_combined)
            2'b01: rising_edge = 1'b1;
            2'b10: falling_edge = 1'b1;
            default: begin
                rising_edge = 1'b0;
                falling_edge = 1'b0;
            end
        endcase
    end

    // Assert the detection pulse output.
    always_ff @(posedge clk) begin
        prev_signal <= signal;
    end



endmodule