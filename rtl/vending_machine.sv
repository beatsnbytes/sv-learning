// vending_machine.sv
// Moore FSM vending machine controller
// Week 4 - multiple inputs, multiple paths, change logic

module vending_machine (
    input logic clk,
    input logic rst, 
    input logic coin10, 
    input logic coin20, 
    output logic dispense, 
    output logic change 
);

    typedef enum logic [2:0] {
        IDLE = 3'b000,
        TEN = 3'b001,
        TWENTY = 3'b010,
        THIRTY = 3'b011,
        FORTY = 3'b100
    } state_t;

    state_t current_state, next_state;
    
    // State register
    always_ff @(posedge clk) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = current_state; // default: stay in current state
        case (current_state)
            IDLE: begin
                if (coin10) next_state = TEN;
                else if (coin20) next_state = TWENTY;
            end
            TEN: begin
                if (coin10) next_state = TWENTY;
                else if (coin20) next_state = THIRTY;
            end
            TWENTY: begin
                if (coin10) next_state = THIRTY;
                else if (coin20) next_state = FORTY;            
            end
            THIRTY: next_state = IDLE;
            FORTY: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always_comb begin
        dispense = 1'b0;
        change = 1'b0;
        case (current_state)
            THIRTY: dispense = 1'b1;
            FORTY: begin 
                dispense = 1'b1; 
                change = 1'b1;
            end
            default: begin
                dispense = 1'b0; 
                change = 1'b0;                
            end 
        endcase
    end

endmodule