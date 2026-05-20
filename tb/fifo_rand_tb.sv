// fifo_rand_tb.sv
// Constrained random self-checking tstbench for FIFO
// Week 6 - classes, rand, constraints, scoreboard

// Transaction class - one FIFO operation
class FifoTransaction;
    rand logic wr_en;
    rand logic rd_en;
    rand logic [7:0] wr_data;

    // Constraint: at least one operation per transaction
    constraint at_least_one_op {
        wr_en || rd_en;
    }

    // Constraint: data is never zero (to make mismatches obvious)
    constraint nonzero_data {
        wr_data != 8'h00;
    }
endclass

module fifo_rand_tb;

    localparam int DATA_WIDTH = 8;
    localparam int DEPTH = 8;

    logic clk, rst;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1 : 0] wr_data;
    logic [DATA_WIDTH-1 : 0] rd_data;
    logic full, empty;

    // Instantiate DUT
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Reference model - software FIFO using a queue
    logic [DATA_WIDTH-1 :0] ref_model[$]; // SystemVerilog queue
    logic [DATA_WIDTH-1 :0] expected_data;
    logic [DATA_WIDTH -1 :0] prev_rd_data;
    int pass_count, fail_count;

    // Scorebard task - checks DUT output against reference model
    task apply_and_check(FifoTransaction txn);
        logic do_write, do_read;

        //Determine actual operations (respect full/empty)
        do_write = txn.wr_en && !full;
        do_read = txn.rd_en && !empty;

        prev_rd_data = rd_data; // capture before the clock edge

        //Drive DUT 
        wr_en = txn.wr_en;
        rd_en = txn.rd_en;
        wr_data = txn.wr_data;
        @(posedge clk); #1;

        // Update reference model
        if (do_write)
            ref_model.push_back(txn.wr_data);

        if (do_read) begin
            expected_data = ref_model.pop_front();
            // Check DUT output against reference
            if (rd_data !== expected_data) begin
                $display("FAIL t=%0t | expected=%h got=%h",
                $time, expected_data, rd_data);
                fail_count++;
            end else begin
                pass_count++;
            end
        end

        // Check idle - nothing should change
        if (!do_write && !do_read) begin
            if (rd_data !== prev_rd_data) begin
                $display("FAIL idle t=%0t | rd_data changed from %h to %h", 
                $time, prev_rd_data, rd_data);
                fail_count++;
            end else begin
                pass_count++;
            end
        end

        // Clear inputs
        wr_en = 0;
        rd_en = 0;
    endtask

    //Main test
    FifoTransaction txn;
    initial begin
        $dumpfile("../sim/fifo_rand_tb.vcd");
        $dumpvars(0, fifo_rand_tb);

        expected_data = '0;
        pass_count = 0;
        fail_count = 0;

        // Reset
        rst = 1; wr_en = 0; rd_en = 0; wr_data = 0;
        repeat(2) @(posedge clk); #1;
        rst = 0;

        // Run 200 random transactions
        txn = new();
        repeat(200) begin
            assert(txn.randomize() == 1)
                else $fatal("Randomization failed");
            apply_and_check(txn);
        end

        // print results
        $display("--- Results ---");
        $display("PASS: %0d  FAIL:%0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("FAILURES DETECTED");

        $finish;
    end
        
endmodule

// Bind assertions to DUT - attaches without modifying the RTL
bind fifo fifo_assertions #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
) fifo_assertions_inst (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .wr_data(wr_data),
    .rd_data(rd_data),
    .full(full),
    .empty(empty),
    .count(count)
);