// axi4_lite_slave.sv
// An AXI-4 LITE slave implementation
// Week9 - AXI Interface

module axi4_lite_slave(
    input logic aclk,
    input logic aresetn, // Active low reset - AXI convention
    // Signals for WA channel (Master --> Slave)
    input logic awvalid,
    output logic awready,
    input logic [31:0] awaddr,
    // Signals for W channel (Master --> Slave)
    input logic wvalid,
    output logic wready,
    input logic [31:0] wdata,
    input logic [3:0] wstrb,
    // Signals for RA channel (Master --> Slave)
    input logic arvalid, 
    output logic arready,
    input logic [31:0] araddr,
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

// Make the internal memory (4 32-bit registers)
logic [31:0] regs [3:0]; // 32 bit wide - 4 entries

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
        rdata <= '0;
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
            if (wstrb[0]) regs [awaddr[3:2]][7:0] <= wdata[7:0];
            if (wstrb[1]) regs [awaddr[3:2]][15:8] <= wdata[15:8];
            if (wstrb[2]) regs [awaddr[3:2]][23:16] <= wdata[23:16];
            if (wstrb[3]) regs [awaddr[3:2]][31:24] <= wdata[31:24];
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
            rdata <= regs[araddr[3:2]][31:0];
            rvalid <= 1'b1;// hold rvalid until rready
            arready <= 1'b0; // Hold it low so not to process another read while reading
        end 
    end
end

endmodule