// fifo_agent.sv
// Packages sequencer, driver, monitor into reusable unit
// Week 8 — UVM agent class

class fifo_agent;
    fifo_sequencer  seqr;
    fifo_driver     drv;
    fifo_monitor    mon;

    mailbox #(fifo_seq_item) seqr_drv_mbx;
    mailbox #(fifo_seq_item) seqr_rsp_mbx;
    mailbox #(fifo_seq_item) mon_scb_mbx;
    virtual fifo_if          vif;

    function void build();
        seqr         = new();
        drv          = new();
        mon          = new();
        seqr_drv_mbx = new();
        seqr_rsp_mbx = new();
        seqr.mbx     = seqr_drv_mbx;
        seqr.rsp_mbx = seqr_rsp_mbx;
        drv.mbx      = seqr_drv_mbx;
        drv.rsp_mbx  = seqr_rsp_mbx;
        mon.mbx      = mon_scb_mbx;
        drv.vif      = vif;
        mon.vif      = vif;
    endfunction

    task run();
        fork
            seqr.run();
            drv.run();
            mon.run();
        join_none
    endtask

endclass