// axi4_lite_slave_tb.sv
// Testbench for the axi4 lite slave
// Week 9 - AXI 4 LITE 

module axi4_lite_slave_tb;

    logic aclk, aresetn;
    // WA channel
    logic awvalid, awready;
    logic [31:0] awaddr;
    // W channel
    logic wvalid, wready;
    logic [31:0] wdata;
    logic [3:0] wstrb;
    // AR channel
    logic arvalid, arready;
    logic [31:0] araddr;
    // R channel
    logic rvalid, rready; 
    logic [31:0] rdata; 
    logic [1:0] rresp;
    // B channel
    logic bvalid, bready;
    logic [1:0] bresp; 

    logic [3:0] whole_strb;
    logic [3:0] partial_strb;

    axi4_lite_slave dut(
    .aclk(aclk),
    .aresetn(aresetn),  
    .awvalid(awvalid),
    .awready(awready),
    .awaddr(awaddr),
    .wvalid(wvalid),
    .wready(wready),
    .wdata(wdata),
    .wstrb(wstrb),
    .arvalid(arvalid), 
    .arready(arready),
    .araddr(araddr),
    .rvalid(rvalid),
    .rready(rready),
    .rdata(rdata),
    .rresp(rresp),
    .bvalid(bvalid),
    .bready(bready),
    .bresp(bresp)
    );

    // Clock generation
    initial aclk = 1'b0;
    always #5 aclk = ~aclk;


    task axi_write(input logic [31:0] addr, 
                   input logic [3:0] strb, 
                   input logic [31:0] data);
        // Present address and data
        awaddr = addr;
        wdata = data;
        wstrb = strb;
        awvalid = 1'b1;
        wvalid = 1'b1;
        // Wait for slave to accept
        @(posedge aclk); #1;
        // Wait for write response
        while (!bvalid) @(posedge aclk); 
        #1;
        bready = 1'b1;
        @(posedge aclk); #1;
        bready = 1'b0;
        awvalid = 1'b0;
        wvalid = 1'b0;
    endtask

    task axi_read(input logic [31:0] addr,
                  output logic [31:0] data);
        araddr = addr;
        arvalid = 1'b1;
        @(posedge aclk); #1;
        // Wait for read data
        while (!rvalid) @(posedge aclk);
        #1;
        rready = 1'b1;
        data = rdata;
        @(posedge aclk); #1;
        rready = 1'b0;
        arvalid = 1'b0;
    endtask

    initial begin
        $dumpfile("../sim/axi4_lite_slave_tb.vcd");
        $dumpvars(0, axi4_lite_slave_tb);

        awvalid = 0; wvalid = 0; bready = 0;
        arvalid = 0; rready = 0;
        awaddr = 0; wdata = 0; wstrb = 0;
        araddr = 0; 

        // Start in reset (active low = 0 means reset)
        aresetn = 1'b0;
        repeat(2) @(posedge aclk); #1;
        // Release reset
        aresetn = 1'b1;

        whole_strb = 4'b1111;
        partial_strb = 4'b0011;
        // Write 0xDEADBEEF to address 0x00
        $display("--- Write 0xDEADBEEF to address 0x00 ---");
        axi_write(32'h00000000, whole_strb, 32'hDEADBEEF);



        // Write 0xCAFEBABE to address 0x04
        $display("--- Write 0xCAFEBABE to address 0x04 ---");
        axi_write(32'h00000004, whole_strb, 32'hCAFEBABE);

        // Read back 0xDEADBEEF from reg 0
        $display("Reading from address 0x00 - reg0");
        axi_read(32'h00000000, rdata);
        if (rdata != 32'hDEADBEEF) begin
            $display("FAIL: Reading reg0 expected 0xDEADBEEF got %h", rdata);
        end else begin
            $display("Success!");
        end

        // Read back 0xCAFEBABE from reg 1
        $display("Reading from address 0x04 - reg1");
        axi_read(32'h00000004, rdata);
        if (rdata != 32'hCAFEBABE) begin
            $display("FAIL: Reading reg0 expected 0xCAFEBABE got %h", rdata);
        end else begin
            $display("Success!");
        end

        // Write partial
        $display("--- Partial write at address 0x08 - reg2");
        axi_write(32'h00000008, partial_strb, 32'hFFFFFFFF);

        // Read back the partially written reg2
        $display("Reading back the partialy written reg2");
        axi_read(32'h00000008, rdata);
        if (rdata != 32'h0000FFFF) begin
            $display("FAIL: Reading reg0 expected 0x0000FFFF got %h", rdata);
        end else begin
            $display("Success!");
        end
        $finish;
    
    end

endmodule



