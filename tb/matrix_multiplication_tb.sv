// matrix_multiplication_tb.sv
// Testing the matrix multiplication module

module matrix_multiplication_tb;

matrix_multiplication #(
    .N(N),
    .DATA_WIDTH(DATA_WIDTH)
    ) dut (
    .clk(clk),
    .rst(rst), 
    .start(start),
    .wr_en(wr_en),
    .wr_addr(wr_addr), 
    .wr_data(wr_data),
    .rd_en(rd_en), 
    .rd_addr(rd_addr), 
    .rd_data(rd_data),
    .done(done)
    );

    localparam int N=3;
    localparam int ADDR_WIDTH = $clog2((N*N)*3); 
    localparam int MAT_ELEMENTS = N*N;
    localparam int MAT_ADDR_WIDTH = $clog2(MAT_ELEMENTS);
    localparam DATA_WIDTH=32;
    logic clk, rst; 
    logic start;
    logic wr_en;
    logic [ADDR_WIDTH-1 : 0] wr_addr; 
    logic [DATA_WIDTH-1 : 0] wr_data;
    logic rd_en;
    logic [ADDR_WIDTH-1 :0] rd_addr;
    logic [DATA_WIDTH-1 : 0] rd_data;
    logic done;

    logic [DATA_WIDTH-1 : 0]result_mat[MAT_ELEMENTS-1 : 0];
    
    logic [MAT_ADDR_WIDTH-1 : 0] idx;

    int fail_count, success_count;

    initial clk=1'b0;
    always #5 clk=~clk;


    initial begin
        $dumpfile("../sim/matrix_multiplication_tb.vcd");
        $dumpvars(0, matrix_multiplication_tb);

        // Reset the module - Hold rst for 2cc
        rst = 1'b1;
        repeat(2) @(posedge clk); #1;
        rst = 1'b0;

        // Write the A and B matrices to the memory maped region of the accelerator
        wr_en = 1'b1;
        wr_addr = (ADDR_WIDTH)'(0);
        wr_data = (DATA_WIDTH)'(wr_addr);

        // Write to mat_a
        repeat(8) begin
            @(posedge clk); #1;
            wr_addr = wr_addr + (ADDR_WIDTH)'(1);
            wr_data = (DATA_WIDTH)'(wr_addr);
        end

        // Write to mat_b
        repeat(9) begin
            @(posedge clk); #1;
            wr_addr = wr_addr + (ADDR_WIDTH)'(1);
            wr_data = (DATA_WIDTH)'(wr_addr);
        end

        @(posedge clk); #1;
        start = 1'b1;
        wr_en = 1'b0;

        @(posedge clk); #1;
        start = 1'b0;

        // Wait untill the module asserts done
        @(posedge done); #1;
        
        rd_en = 1'b1;
        @(posedge clk);
        rd_addr = (ADDR_WIDTH)'(2*MAT_ELEMENTS);
        idx = '0;
        result_mat[idx] = rd_data;

        repeat(8) begin
            // @(posedge clk); 
            #1;
            rd_addr = rd_addr + (ADDR_WIDTH)'(1);
            result_mat[idx] = rd_data;
            idx = idx + 1;
        end

        // @(posedge clk); 
        #1;
        result_mat[idx] = rd_data;

        @(posedge clk); #1;
        rd_en = 1'b0;

        success_count = 0;
        fail_count = 0;
        idx = '0;


        repeat(9) begin
            case(idx)
                (MAT_ADDR_WIDTH)'(0): begin
                    if (result_mat[idx] != (DATA_WIDTH)'(42)) begin
                        $display("ERROR: Expected 42, got %d", result_mat[idx]);
                        fail_count++;
                    end else begin
                        success_count++;
                    end
                end
                (MAT_ADDR_WIDTH)'(1): begin
                    if (result_mat[idx] != (DATA_WIDTH)'(45)) begin
                        $display("ERROR: Expected 45, got %d", result_mat[idx]);
                        fail_count++;
                    end else begin
                        success_count++;
                    end
                end
                (MAT_ADDR_WIDTH)'(2): begin
                    if (result_mat[idx] != (DATA_WIDTH)'(48)) begin
                        $display("ERROR: Expected 48, got %d", result_mat[idx]);
                        fail_count++;
                    end else begin
                        success_count++;
                    end
                end
                (MAT_ADDR_WIDTH)'(3): begin
                    if (result_mat[idx] != (DATA_WIDTH)'(150)) begin
                        $display("ERROR: Expected 150, got %d", result_mat[idx]);
                        fail_count++;
                    end else begin
                        success_count++;
                    end
                end
                (MAT_ADDR_WIDTH)'(4): begin
                    if (result_mat[idx] != (DATA_WIDTH)'(162)) begin
                        $display("ERROR: Expected 162, got %d", result_mat[idx]);
                        fail_count++;
                    end else begin
                        success_count++;
                    end
                end
                (MAT_ADDR_WIDTH)'(5): begin
                    if (result_mat[idx] != (DATA_WIDTH)'(174)) begin
                        $display("ERROR: Expected 174, got %d", result_mat[idx]);
                        fail_count++;
                    end else begin
                        success_count++;
                    end
                end
                (MAT_ADDR_WIDTH)'(6): begin
                    if (result_mat[idx] != (DATA_WIDTH)'(258)) begin
                        $display("ERROR: Expected 258, got %d", result_mat[idx]);
                        fail_count++;
                    end else begin
                        success_count++;
                    end
                end
                (MAT_ADDR_WIDTH)'(7): begin
                    if (result_mat[idx] != (DATA_WIDTH)'(279)) begin
                        $display("ERROR: Expected 279, got %d", result_mat[idx]);
                        fail_count++;
                    end else begin
                        success_count++;
                    end
                end
                (MAT_ADDR_WIDTH)'(8): begin
                    if (result_mat[idx] != (DATA_WIDTH)'(300)) begin
                        $display("ERROR: Expected 300, got %d", result_mat[idx]);
                        fail_count++;
                    end else begin
                        success_count++;
                    end
                end
                default: ;
            endcase
            idx = idx + 1;
        end


        $display("PASS:%d | FAIL:%d", success_count, fail_count);
        $finish;
    end


endmodule

