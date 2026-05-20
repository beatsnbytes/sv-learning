// fifo_scoreboard.sv
// Week 8 — UVM scoreboard

class fifo_scoreboard;
    mailbox #(fifo_seq_item) mbx;
    fifo_seq_item item;
    int pass_count, fail_count;

    task run();
        forever begin
            mbx.get(item);
            if (item.rd_en) begin
                if (item.rd_data !== item.expected_data) begin
                    $display("FAIL: t=%0t expected=%h got=%h",
                              $time, item.expected_data, item.rd_data);
                    fail_count++;
                end else
                    pass_count++;
            end
        end
    endtask

    function void report();
        $display("--- Scoreboard Results ---");
        $display("PASS: %0d  FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("FAILURES DETECTED");
    endfunction

endclass