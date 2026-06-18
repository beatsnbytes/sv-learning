// uart.sv
// Week 17 UART Tx


module uart_tx #(
        parameter DATA_BITS = 8,
        parameter PARITY_EN = 0,
        parameter BAUD_RATE = 10, //115200,
        parameter FREQ = 100 //50000000,
    )(
        input logic clk, 
        input logic rst,
        input logic initiate,
        input logic [DATA_BITS-1 : 0] data_in,
        output logic bit_out,
        output logic done,
        output logic bit_out_valid, // Monitor signal - Delete @ final design version
        output logic [($clog2(CYCLES_PER_BIT) + 1) - 1 : 0] baud_counter
    );


    // State encoding
    typedef enum logic [2:0] {
        IDLE = 3'b000,
        START = 3'b001,
        SEND = 3'b010,
        PARITY = 3'b011,
        STOP = 3'b100
    } state_t;

    state_t current_state, next_state;
    localparam int CYCLES_PER_BIT = FREQ/BAUD_RATE;
    localparam int BAUD_COUNTER_WIDTH = $clog2(CYCLES_PER_BIT) + 1;
    localparam int BIT_COUNTER_WIDTH = $clog2(DATA_BITS) + 1;
    localparam int BIT_IDX_WIDTH = $clog2(DATA_BITS);
    logic [BIT_COUNTER_WIDTH - 1 : 0] bit_counter;
    // logic [BAUD_COUNTER_WIDTH - 1 : 0] baud_counter;
    logic [BIT_IDX_WIDTH - 1 : 0] bit_idx;
    logic send_bit;
    logic busy;

    always_ff @(posedge clk) begin
        if (rst) begin
            bit_counter <= (BIT_COUNTER_WIDTH)'(0); 
            bit_idx <= (BIT_IDX_WIDTH)'(0);
        end else if (send_bit && (current_state == SEND)) begin
            bit_counter <= bit_counter + (BIT_COUNTER_WIDTH)'(1);
            bit_idx <= bit_idx + (BIT_IDX_WIDTH)'(1);
        end else if (current_state != SEND) begin
            bit_counter <= (BIT_COUNTER_WIDTH)'(0); 
            bit_idx <= (BIT_IDX_WIDTH)'(0);
        end
    end


    // State register - Sequential
    always_ff @(posedge clk) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end


    // Next state logic - combinational
    always_comb begin
        case (current_state)
            IDLE : next_state = busy ? START : IDLE;
            START : next_state = send_bit ? SEND : START;
            SEND : begin
                if (send_bit && (bit_counter == (DATA_BITS - 1))) begin
                    next_state = PARITY_EN ? PARITY : STOP;
                end else begin
                    next_state = SEND;
                end
            end 
            PARITY : next_state = send_bit ? STOP : PARITY;
            STOP : next_state = send_bit ? IDLE : STOP;  
            default : next_state = IDLE;
        endcase
    end

    // Output logic - combnational (Moore: depends only on state)
    always_comb begin
        bit_out  = 1'b0;
        done = 1'b0;
        case (current_state)
            IDLE: begin 
                bit_out = 1'b1;  
                end 
            START: begin 
                bit_out = 1'b0; 
                end
            SEND: begin
                bit_out = data_in[bit_idx];
                end
            PARITY: begin
                bit_out = ^data_in;
                end
            STOP: begin bit_out = 1'b1; 
                done = 1'b1;  
                end
            default: begin 
                bit_out = 1'b0; 
                done = 1'b0;  
                end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            busy <= 1'b0;
        end else if (initiate && (!busy)) begin
            busy <= 1'b1;
        end else if (done) begin
            busy <= 1'b0;
        end
    end

    // Generate the bit_out_valid signal to be synchronous with the valid output bit
    always_ff @(posedge clk) begin
        if (rst) begin
            bit_out_valid <= 1'b0;
        end else if (send_bit) begin
            bit_out_valid <= 1'b1;
        end else begin
            bit_out_valid <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst || !busy) begin
            send_bit <= 1'b0;
            baud_counter <= (BAUD_COUNTER_WIDTH)'(0);
        end else if(baud_counter == (BAUD_COUNTER_WIDTH)'(CYCLES_PER_BIT-1)) begin
            send_bit <= 1'b1;
            baud_counter <= (BAUD_COUNTER_WIDTH)'(0);
        end else if (busy) begin // Enable the counter explicitly when busy or when the initiate is asserted
            baud_counter <= baud_counter + 1'b1;
            send_bit <= 1'b0; // Has to deassert when baud_counter != CYCLES_PER_BIT
        end
    end

endmodule

    //-------------------------------//

    // logic baud_counter = 1'b0;

    // always_ff @(posedge clk) begin
    //     if (baud_rate_counter == CYCLES_PER_BIT) begin
    //         bit_out <= data_in[0];
    //         data_in <= 
    //     end
    // end

    // always_ff @(posedge clk) begin
    //     if (rst) begin
    //         baud_rate <= 1'b0;
    //         bit_out <= 1'b0;
    //         done <= 1'b0;
    //     end
    // end

// endmodule