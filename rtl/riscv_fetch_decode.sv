// riscv_fetch_decode.sv
// Fetch and decode stage module for the RISC-V processor pipeline
// Week10 - Fetch and Decode stages

module riscv_fetch_decode (
    input logic clk,
    input logic rst,
    output logic [31:0] pc,
    output logic [4:0] rs1_addr,
    output logic [4:0] rs2_addr,
    output logic [4:0] rd_addr,
    output logic [31:0] imm,
    output logic [3:0] alu_op,
    output logic reg_wr_en,
    output logic [31:0] instr,
    output logic alu_src // 0 = use rs2, 1 use imm
);

    logic [31:0] imem [255:0]; // The 1KB instruction memory
    initial $readmemh("program.hex", imem); // Reading the instructions from a hex file

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 32'd0;
        end else begin
            pc <= pc + 32'd4;
        end
    end

    logic [6:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;

    assign instr = imem[pc[9:2]];
    assign opcode = instr[6:0];
    assign func3 = instr[14:12];
    assign func7 = instr[31:25];
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign rd_addr = instr[11:7];

    always_comb begin

        alu_op = 4'b0000; // Default ADD
        reg_wr_en = 1'b0;
        imm = 32'b0;
        alu_src = 1'b0; // Get value from rs2

        case (opcode) 
            // 7'b0110011 — R-type  (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
            7'b0110011 : begin
                alu_src = 1'b0;
                reg_wr_en = 1'b1;
                case (func3)
                    // ADD/SUB
                    3'b000 : alu_op = (func7 == 7'b0000000) ? 4'b0000 : 4'b0001;
                    // AND
                    3'b111  : alu_op = 4'b0010;
                    // OR
                    3'b110 : alu_op = 4'b0011;
                    // XOR
                    3'b100 : alu_op = 4'b0100;
                    // SLL
                    3'b001 : alu_op = 4'b0101;
                    // SRL/SRA
                    3'b101 : alu_op = func7[5] ? 4'b0111 : 4'b0110;
                    // SLT
                    3'b010 : alu_op = 4'b1000;
                    // SLTU
                    3'b011 : alu_op = 4'b1001;  
                endcase
            end
            // 7'b0010011 — I-type  (ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU)
            7'b0010011: begin
                alu_src = 1'b1;
                reg_wr_en = 1'b1;
                imm = {{20{instr[31]}}, instr[31:20]};
                case(func3)
                    // ADDI
                    3'b000 : alu_op = 4'b0000;
                    // SLLI
                    3'b001 : alu_op = 4'b0101;
                    // SLTI
                    3'b010 : alu_op = 4'b1000;
                    // SLTIU
                    3'b011 : alu_op = 4'b1001;
                    // XORI
                    3'b100 : alu_op = 4'b0100;
                    // SRLI/SRAI
                    3'b101 : alu_op = func7[5] ? 4'b0111 : 4'b0110;
                    // ORI
                    3'b110 : alu_op = 4'b0011; 
                    // ANDI
                    3'b111 : alu_op = 4'b0010;    
                endcase
            end
            default : ; // All signals already set by the top level default
        endcase
    end

endmodule
    