// fifo_monitor.sv
// Watch DUT pins, track expected values, send to scoreboard
// Week 8 — UVM monitor with internal reference model

class fifo_monitor;
    mailbox #(fifo_seq_item) mbx;
    virtual fifo_if vif;
    fifo_seq_item item;
    logic [7:0] ref_queue[$];

    task run();
        logic do_write;
        logic do_read;

        forever begin
            @(posedge vif.clk);
            do_write = vif.wr_en && !vif.full;
            do_read  = vif.rd_en && !vif.empty;

            if (do_write || do_read) begin
                item         = new();
                item.wr_en   = do_write;
                item.rd_en   = do_read;
                item.wr_data = vif.wr_data;

                // Pop before push for simultaneous rw
                if (do_read && ref_queue.size() > 0)
                    item.expected_data = ref_queue.pop_front();

                if (do_write)
                    ref_queue.push_back(vif.wr_data);

                // Wait #1 for combinational rd_data to settle
                #1;
                item.rd_data = vif.rd_data;
                mbx.put(item);
            end
        end
    endtask

endclass