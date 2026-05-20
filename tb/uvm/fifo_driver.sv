// fifo_driver.sv
// Take transactions from sequencer and drive them to the fifo dut
// Week8 - UVM driver

class fifo_driver;

    mailbox #(fifo_seq_item) mbx; // mailbox to receive items
    mailbox #(fifo_seq_item) rsp_mbx; // Response back to sequencer
    virtual fifo_if vif; // interface to the DUT signals
    fifo_seq_item item; // fifo_seq_item handle
    
    task run();
        forever begin
            mbx.get(item); // Get an item from the mailbox

            // Drive the DUT signals from the item fields
            vif.wr_en = item.wr_en; 
            vif.rd_en = item.rd_en;
            vif.wr_data = item.wr_data;

            // Wait one clock edge
            @(posedge vif.clk); #1;

            // Clear signals after the clock edge
            vif.wr_en = 1'b0; 
            vif.rd_en = 1'b0;

            rsp_mbx.put(item); 
        end
    endtask

endclass