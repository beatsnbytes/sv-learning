// fifo_env.sv
// Top level UVM environment
// Week 8 — UVM environment class

class fifo_env;
    fifo_agent      agent;
    fifo_scoreboard scb;
    mailbox #(fifo_seq_item) mon_scb_mbx;
    virtual fifo_if vif;

    function void build();
        agent        = new();
        scb          = new();
        mon_scb_mbx  = new();
        agent.mon_scb_mbx = mon_scb_mbx;
        scb.mbx           = mon_scb_mbx;
        agent.vif         = vif;
        agent.build();
    endfunction

    task run();
        fork
            agent.run();
            scb.run();
        join_none
    endtask

    function void report();
        scb.report();
    endfunction

endclass