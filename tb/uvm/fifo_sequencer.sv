// fifo_sequencer.sv
// Generate N randm transactions and send them to the driver one by one
// Week8 - UVM sequencer class

class fifo_sequencer;

    parameter int N_TRANSACTIONS = 200;

    fifo_seq_item item;
    mailbox #(fifo_seq_item) mbx;

    mailbox #(fifo_seq_item) rsp_mbx; // Response from driver
    
    task run();
        item = new();
        repeat(N_TRANSACTIONS) begin
            assert(item.randomize() == 1)
                else $fatal("Randomize failed!");
            item.print();
            mbx.put(item);
            rsp_mbx.get(item); // Wait for the driver to finish
        end

    endtask

endclass