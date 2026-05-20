// fifo_seq_item.sv
// UVM sequence item — one FIFO transaction
// Week 8 — UVM transaction class

class fifo_seq_item;
    rand logic       wr_en;
    rand logic       rd_en;
    rand logic [7:0] wr_data;
    logic      [7:0] rd_data;
    logic      [7:0] expected_data;

    constraint at_least_one_op {
        wr_en || rd_en;
    }

    constraint nonzero_data {
        wr_data != 8'h00;
    }

    function void print();
        $display("Transaction: time=%0t | wr_en=%b rd_en=%b | wr_data=%h",
                  $time, wr_en, rd_en, wr_data);
    endfunction

endclass