// axi4_lite_slave_tb.sv
// Testbench for the axi4 lite slave
// Week 9 - AXI 4 LITE 

module axi4_lite_slave_tb;

    logic aclk, aresetn;
    // WA channel
    logic awvalid, waready, [31:0] awaddr;
    // W channel
    logic wvalid, wready, [31:0] wdata, [3:0] wstrb;
    // AR channel
    logic arvalid, arready, [31:0] araddr;
    // R channel
    logic rvalid, rready, [31:0] rdata, [1:0] rresp;
    // B channel
    logic bvalid, bready, [1:0] bresp; 

    axi4_lite_slave(

    );

