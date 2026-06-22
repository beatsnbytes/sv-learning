// Week17 matrix_multiplication.sv
// Multiplication of square NxN matrices


module matrix_multiplication #(
    parameter N = 4, // NxN matrix consisting of 32-bit values
    // localparam int ADDR_WIDTH = $clog2((N*N)*3), // The ADDR_WIDTH should be able to address e.g. 48 words for thecase of N=4
    parameter DATA_WIDTH = 32
    )(
    input logic clk,
    input logic rst, 
    input logic start,
    input logic wr_en,
    input logic [ADDR_WIDTH-1 : 0] wr_addr, 
    input logic [DATA_WIDTH-1 : 0] wr_data,
    input logic rd_en, 
    input logic [ADDR_WIDTH-1 :0] rd_addr, 
    output logic [DATA_WIDTH-1 : 0] rd_data,
    output logic done
    );

    localparam int ADDR_WIDTH = $clog2((N*N)*3); // The ADDR_WIDTH should be able to address e.g. 48 words for thecase of N=4
    localparam int MAT_ELEMENTS = N*N;
    localparam int MAT_ADDR_WIDTH = $clog2(MAT_ELEMENTS);
    localparam int COUNTER_WIDTH =  $clog2(N);

    logic [DATA_WIDTH-1 :0] mat_a [MAT_ELEMENTS-1 :0];
    logic [DATA_WIDTH-1 :0] mat_b [MAT_ELEMENTS-1 :0];
    logic [DATA_WIDTH-1 :0] mat_c [MAT_ELEMENTS-1 :0];

    logic [COUNTER_WIDTH - 1 : 0] i, saved_i; // Loop counters
    logic [COUNTER_WIDTH - 1 : 0] j, saved_j; // Loop counters
    logic [COUNTER_WIDTH - 1 : 0] k; // Loop counters

    logic [DATA_WIDTH-1 :0] accum; // Known limitation : overflow
    
    logic [DATA_WIDTH-1 :0] result;
    logic busy, write_result;

    // State encoding
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        MAC = 2'b01,
        STOP = 2'b10
    } state_t;

    state_t current_state, next_state;
 

    // Registered memory write logic
    always_ff @(posedge clk) begin
        if (wr_en) begin
            if (wr_addr < (ADDR_WIDTH)'(MAT_ELEMENTS)) begin
                mat_a[(MAT_ADDR_WIDTH)'(wr_addr)] <= wr_data;     
            end else if ((wr_addr >= (ADDR_WIDTH)'(MAT_ELEMENTS)) && (wr_addr < (ADDR_WIDTH)'(2*MAT_ELEMENTS))) begin
                mat_b[(MAT_ADDR_WIDTH)'(wr_addr-(ADDR_WIDTH)'(MAT_ELEMENTS))] <= wr_data;
            end 
            // Known limitation : Writing on invalid addresses e.g. mat_c
        end
    end

    // Combinational memory read logic
    always_comb begin
        rd_data = '0;
        if (rd_en) begin
            if (rd_addr < (ADDR_WIDTH)'(MAT_ELEMENTS)) begin
                rd_data = mat_a[(MAT_ADDR_WIDTH)'(rd_addr)];
            end else if ((rd_addr >= (ADDR_WIDTH)'(MAT_ELEMENTS)) && (rd_addr < (ADDR_WIDTH)'(2*MAT_ELEMENTS))) begin
                rd_data = mat_b[(MAT_ADDR_WIDTH)'(rd_addr - (ADDR_WIDTH)'(MAT_ELEMENTS))];
            end else if ((rd_addr >= (ADDR_WIDTH)'(2*MAT_ELEMENTS)) && (rd_addr < (ADDR_WIDTH)'(3*MAT_ELEMENTS))) begin
                rd_data = mat_c[(MAT_ADDR_WIDTH)'(rd_addr - (ADDR_WIDTH)'(2*MAT_ELEMENTS))];
            end
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

   // Next state logic - combnational (Moore: depends only on state)
    always_comb begin
        case (current_state)
            IDLE: next_state = busy ? MAC : IDLE;
            MAC: next_state = ((i==(COUNTER_WIDTH)'(N-1)) && (j==(COUNTER_WIDTH)'(N-1)) && (k==(COUNTER_WIDTH)'(N-1))) ? STOP : MAC;
            STOP: next_state =  done ? IDLE : STOP;
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            busy <= 1'b0;
        end else if (start) begin
            busy <= 1'b1;
        end else if (done) begin
            busy <= 1'b0;
        end
    end



    always_ff @(posedge clk) begin
        if (rst) begin
            i <= '0;
            saved_i <= '0;
            j <= '0;
            saved_j <= '0;
            k <= '0;
            accum <= '0;
            result <= '0;
            write_result <= 1'b0;
        end else if (busy) begin
            accum <= accum + mat_a[k + j*N] * mat_b[N*k + i]; 
            if (k==(COUNTER_WIDTH)'(N-1)) begin
                j <= j + (COUNTER_WIDTH)'(1);
                k <= '0;
                write_result <= 1'b1;
                result <= accum + mat_a[k + j*N] * mat_b[N*k + i]; // Use the product to make sure the result will have the right value
                saved_j <= j;
                saved_i <= i;
                accum <= '0;
                
                if (j == (COUNTER_WIDTH)'(N-1)) begin
                    j <= '0;                    
                    i <= i + (COUNTER_WIDTH)'(1);
                    if (i==(COUNTER_WIDTH)'(N-1)) begin
                        i <= '0;
                    end
                end
            end else begin
                k <= k + (COUNTER_WIDTH)'(1);
                write_result <= 1'b0;
            end
            if (write_result) mat_c[saved_j*N+ saved_i] <= result;
        end
    end


    // Below version with less registers but longer combinational timing path. Trades area for frequency. Also one less pipeline cycle. 

    // logic [DATA_WIDTH-1 :0] final_sum; 

    // assign final_sum = accum + mat_a[k + j*N] * mat_b[N*k + i];

    // always_ff @(posedge clk) begin
    //     if (rst) begin
    //         i <= '0;
    //         j <= '0;
    //         k <= '0;
    //         accum <= '0;
    //         // final_sum <= '0;
    //     end else if (busy) begin
    //         accum <= accum + mat_a[k + j*N] * mat_b[N*k + i]; 
    //         if (k==(COUNTER_WIDTH)'(N-1)) begin
    //             j <= j + (COUNTER_WIDTH)'(1);
    //             k <= '0;
    //             mat_c[j*N+ i] <= final_sum;
    //             accum <= '0;
    //             if (j == (COUNTER_WIDTH)'(N-1)) begin
    //                 j <= '0;                    
    //                 i <= i + (COUNTER_WIDTH)'(1);
    //                 if (i==(COUNTER_WIDTH)'(N-1)) begin
    //                     i <= '0;
    //                 end
    //             end
    //         end else begin
    //             k <= k + (COUNTER_WIDTH)'(1);
    //         end
    //     end
    // end



    // Output logic - combnational (Moore: depends only on state)
    always_comb begin
        case (current_state)
            IDLE: done = 1'b0;
            MAC: done = 1'b0;
            STOP: done = 1'b1;
            default: done = 1'b0;
        endcase
    end
    
endmodule








