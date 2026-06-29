// matrix_multiplication_axi_wrapper_tb.sv
// Testbench for the AXI4-Lite wrapped matrix multiplication module

module matrix_multiplication_axi_wrapper_tb;

    localparam int N=3;
    localparam int ADDR_WIDTH = $clog2((N*N)*3*4+2); // The ADDR_WIDTH should be able to address e.g. 48 words for thecase of N=4. the *4 is to account for Byte addressing
    localparam int DATA_WIDTH = 32;
    localparam int MAT_ELEMENTS = N*N;
    localparam int MAT_ADDR_WIDTH = $clog2(MAT_ELEMENTS);

    logic aclk;
    logic aresetn; // Active low reset - AXI convention
    // Signals for WA channel (Master --> Slave)
    logic awvalid;
    logic awready;
    logic [ADDR_WIDTH-1 : 0] awaddr;
    // Signals for W channel (Master --> Slave)
    logic wvalid;
    logic wready;
    logic [31:0] wdata;
    logic [3:0] wstrb;
    // Signals for RA channel (Master --> Slave)
    logic arvalid; 
    logic arready;
    logic [ADDR_WIDTH-1 : 0] araddr;
    // Signals for R channel (Slave --> Master)
    logic rvalid;
    logic rready;
    logic [31:0] rdata;
    logic [1:0] rresp;
    // Signals for B channel (Slave --> Master)
    logic bvalid;
    logic bready;
    logic [1:0] bresp;

    int success_count;
    int fail_count;
    logic [MAT_ADDR_WIDTH-1 : 0] idx;

    logic [DATA_WIDTH-1 : 0]result_mat[MAT_ELEMENTS-1 : 0];
    logic done;

    matrix_multiplication_axi_wrapper #(
        .N(N)
        ) dut (
        .aclk(aclk),
        .aresetn(aresetn), // Active low reset - AXI convention
        // Signals for WA channel (Master --> Slave)
        .awvalid(awvalid),
        .awready(awready),
        .awaddr(awaddr),
        // Signals for W channel (Master --> Slave)
        .wvalid(wvalid),
        .wready(wready),
        .wdata(wdata),
        .wstrb(wstrb),
        // Signals for RA channel (Master --> Slave)
        .arvalid(arvalid), 
        .arready(arready),
        .araddr(araddr),
        // Signals for R channel (Slave --> Master)
        .rvalid(rvalid),
        .rready(rready),
        .rdata(rdata),
        .rresp(rresp),
        // Signals for B channel (Slave --> Master)
        .bvalid(bvalid),
        .bready(bready),
        .bresp(bresp)
    );

    initial aclk = 1'b0;
    always #5 aclk = ~aclk;

    initial begin
        $dumpfile("../sim/matrix_multiplication_axi_wrapper_tb.vcd");
        $dumpvars(0, matrix_multiplication_axi_wrapper_tb);

        // Initial AXI master (CPU) signals
        awvalid = 1'b0;
        wvalid = 1'b0;
        arvalid = 1'b0;
        rready = 1'b0;
        bready = 1'b1; // Keep it always asserted

        // Reset the slave and accelerator
        aresetn = 1'b0;
        repeat(2) @(posedge aclk); #1;
        aresetn = 1'b1;

    // Send the matrix A word by word
        
        // Initialize the adddess at the base address of mat_a
        awaddr = (ADDR_WIDTH)'(0);
        wdata = (32)'(awaddr)>>2;


        // Assert the awvalid n' wvalid signals
        awvalid = 1'b1;
        wvalid = 1'b1;



        // Deassert awvalid and wvalid when the handshake finishes
        wait (awready && wready);


        $display("Write to matrix A");
        repeat(MAT_ELEMENTS-1) begin
            // When the slave asserts bvalid the handshake finishes and I can reassert the awvalid and wvalid
            wait (bvalid);
            awaddr = awaddr + (ADDR_WIDTH)'(4); // Increment the address accounting for the byte offset
            wdata = (32)'(awaddr)>>2; // Write the matrix with integers from 0 ascending to 31
            // awvalid = 1'b1;
            // wvalid = 1'b1;
        
            // Keep awvalid and wvalid asserted for all the duration of the write mat phase
            wait (awready && wready);

        end


    // Send the matrix Β word by word
        $display("Write to matrix B");
        repeat(MAT_ELEMENTS) begin


            wait (bvalid);
            awaddr = awaddr + (ADDR_WIDTH)'(4); // Increment the address
            wdata = (32)'(awaddr)>>2; // Write the matrix with integers from 0 ascending to 31
            // awvalid = 1'b1;
            // wvalid = 1'b1;

            // Should wait for both awready and wready and bvalid since while bvalid is high I might do the whole iterations without actually writing anything.
            // awready and wready assertion guarantees that we handshake at the next write data signal
            wait (awready && wready);

            
        end

        $display("Write the start=1 register");
        // Write the done signal
        wait (bvalid);
        awaddr = (ADDR_WIDTH)'((N*N)*3*4) + (ADDR_WIDTH)'(4); // Increment the address to 1 past the matrices. Start
        wdata = 32'd1; // Write done = 1
        // awvalid = 1'b1;
        // wvalid = 1'b1;

        // Deassert awvalid and wvalid when the handshake finishes
        wait (awready && wready);
        // awvalid = 1'b0;
        // wvalid = 1'b0;

        // Just wait for its assertion that signals the last write finalization handshake
        wait (bvalid);
        bready = 1'b0; // Deassert bready


        $display("Poll on the done register");
    // Poll on done assertion

        // Give the done registers address
        araddr = (ADDR_WIDTH)'((N*N)*3*4) + (ADDR_WIDTH)'(8); // Increment the address to 2 past the matrices. Done address
        arvalid = 1'b1;
        rready = 1'b1;
    
        // Poll on the done signal continously
        wait (rdata[0] && rvalid);

      

        // Give the mat_c address
        araddr = (ADDR_WIDTH)'((N*N)*2*4); // Write the address with the base address of result matrix C


        success_count = 0;
        fail_count = 0;
        idx = '0;

        $display("Read the result matrix C");
    // Read the result matric C and compare with  expected results
        repeat(MAT_ELEMENTS) begin

            // Wait on arready assertion which signals mat_c completion
            wait(arready);
            wait (rvalid);

            result_mat[idx] = rdata;
            // arvalid = 1'b0;

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
            araddr = araddr + (ADDR_WIDTH)'(4);
            // arvalid = 1'b1;
            
        end

    $display("PASS:%d | FAIL:%d", success_count, fail_count);   
    $finish;
    end

    //Monitor
    // initial begin
    //     $monitor("t=%0t | arvalid=%b | arready=%b | rvalid=%b | rready=%b | rdata=%h | awvalid=%b | awready=%b | wvalid=%b | wready=%b | wdata=%h | bvalid=%b | bready=%b", 
    //     $time, arvalid, arready, rvalid, rready, rdata, awvalid, awready, wvalid, wready, wdata, bvalid, bready);
    // end


endmodule