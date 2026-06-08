// regfile_formal.sv
// Formal verification for the register file x0 register

module regfile_formal;
    bind riscv_regfile regfile_formal_props props_inst (
        .clk(clk),
        .rst(rst)
    );
endmodule

module regfile_formal_props (
    input logic clk,
    input logic rst
);

always @(posedge clk) begin
    if (!rst)
        assert(riscv_regfile.regs[0] == 32'b0);
end

endmodule