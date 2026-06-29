// matrix_multiplication_axi_wrapper.sv
// A AXI4 Lite slave wrapper for the matrix multiplication accelerator module

module matrix_multiplication_axi_wrapper
    #(
    parameter N = 4 // NxN matrix consisting of 32-bit values
    )(
    input logic aclk,
    input logic aresetn, // Active low reset - AXI convention
    // Signals for WA channel (Master --> Slave)
    input logic awvalid,
    output logic awready,
    input logic [ADDR_WIDTH-1 : 0] awaddr,
    // Signals for W channel (Master --> Slave)
    input logic wvalid,
    output logic wready,
    input logic [31:0] wdata,
    input logic [3:0] wstrb,
    // Signals for RA channel (Master --> Slave)
    input logic arvalid, 
    output logic arready,
    input logic [ADDR_WIDTH-1 : 0] araddr,
    // Signals for R channel (Slave --> Master)
    output logic rvalid,
    input logic rready,
    output logic [31:0] rdata,
    output logic [1:0] rresp,
    // Signals for B channel (Slave --> Master)
    output logic bvalid,
    input logic bready,
    output logic [1:0] bresp
    );

    localparam int ADDR_WIDTH = $clog2((N*N)*3*4); // The ADDR_WIDTH should be able to address e.g. 48 words for thecase of N=4. the *4 is to account for Byte addressing
    localparam int DATA_WIDTH = 32;
    localparam int MAT_ELEMENTS = N*N;
    localparam int MAT_ADDR_WIDTH = $clog2(MAT_ELEMENTS);
    logic start_accel;
    logic rst_accel;
    logic wr_en_accel;
    logic rd_en_accel;
    logic [DATA_WIDTH-1 :0] rdata_accel;
    logic [ADDR_WIDTH-3 : 0] wr_addr_accel; // The accelerator address does not acount for byte offset so we are stripping 2 bits to match wit the accel addr_width
    logic [DATA_WIDTH-1 :0] wr_data_accel;
    logic done;


    // // Make the internal memory (4 32-bit registers)
    // logic [31:0] regs [ADDR_WIDTH - 1 : 0]; // 32 bit wide - 4 entries

    assign bresp = 2'b00;
    assign rresp = 2'b00;

    // Handle the active low reset
    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            // Reset logic
            awready <= 1'b1; //ready from the start
            wready <= 1'b1; //ready from the start
            arready <= 1'b1; //ready from the start
            rvalid <= 1'b0;
            bvalid <= 1'b0;
        end else begin
            // Clear write response when master accepts
            if (bvalid && bready) begin 
                bvalid <= 1'b0;
                // Not processing a write, so ready to accept new address and data
                awready <= 1'b1;
                wready <=1'b1;
            end
            // Write logic
            if (awvalid && awready && wvalid && wready) begin
                wr_addr_accel <= awaddr[ADDR_WIDTH-1 : 2];
                wr_data_accel <= wdata;
                bvalid <= 1'b1; // hold bvalid until bready
                // While waiting for bready, do not accept new writes
                awready <= 1'b0;
                wready <= 1'b0;
            end 
            // Clear read response when master accepts
            if (rvalid && rready) begin
                rvalid  <= 1'b0;
                arready <= 1'b1;
            end

            // Read logic
            if (arvalid && arready) begin
                if ((araddr[(ADDR_WIDTH-1):2] == (ADDR_WIDTH-2)'(3*MAT_ELEMENTS +2))) begin
                    rdata <= {31'b0, done}; // Start only needs the LSB
                end else begin
                    rdata <= rdata_accel;
                end
                rvalid <= 1'b1;// hold rvalid until rready
                arready <= 1'b0; // Hold it low so not to process another read while reading
            end 
        end
    end


    assign rst_accel = ~aresetn;
    assign rd_en_accel = arvalid && arready;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            wr_en_accel <= 1'b0;
        end else if (awvalid && awready && wvalid && wready) begin
            wr_en_accel <= 1'b1;
        end else begin
            wr_en_accel <= 1'b0;
        end
    end

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            start_accel <= 1'b0;
        end else if (awvalid && awready && wvalid && wready && (awaddr[(ADDR_WIDTH-1):2] == (ADDR_WIDTH-2)'(3*MAT_ELEMENTS +1))) begin
            start_accel <= wdata[0]; // Start only needs the LSB
        end else begin
            start_accel <= 1'b0;
        end
    end

    // Instance of the matrix multiplication accelerator
    matrix_multiplication #(
    .N(N), // NxN matrix consisting of 32-bit values
    // localparam int ADDR_WIDTH = $clog2((N*N)*3), // The ADDR_WIDTH should be able to address e.g. 48 words for thecase of N=4
    .DATA_WIDTH(DATA_WIDTH)
    ) matrix_multiplication_inst (
    .clk(aclk),
    .rst(rst_accel), // This is asynchronous and inverse than the reset used in this module
    .start(start_accel),
    .wr_en(wr_en_accel),
    .wr_addr(wr_addr_accel), // We assume that the whole 32b are getting written. 
    .wr_data(wr_data_accel),
    .rd_en(rd_en_accel), 
    .rd_addr(araddr[ADDR_WIDTH-1 : 2]), 
    .rd_data(rdata_accel),
    .done(done)
    );


endmodule