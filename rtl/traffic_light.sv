// traffic_light.sv
// Moore FSM traffic light controller
// Week 4 - typedef enum, state register, next state logic

module traffic_light (
    input logic clk, 
    input logic rst, 
    input logic timer, // high when current state timer expires
    output logic red, 
    output logic amber, 
    output logic green
);

    // State encoding
    typedef enum logic [1:0] {
        RED = 2'b00,
        RED_AMBER = 2'b01,
        GREEN = 2'b10,
        AMBER = 2'b11
    } state_t;

    state_t current_state, next_state;

    // State register - sequential
    always_ff @(posedge clk) begin
        if (rst)
            current_state <= RED;
        else
            current_state <= next_state;
    end

    // Next state logic - combinational
    always_comb begin
        case (current_state)
            RED:        next_state = timer ? RED_AMBER : RED;
            RED_AMBER:  next_state = timer ? GREEN : RED_AMBER;
            GREEN:      next_state = timer ? AMBER : GREEN;
            AMBER:      next_state = timer ? RED : AMBER;
        endcase
    end

    // Output logic - combnational (Moore: depends only on state)
    always_comb begin
        red  = 1'b0;
        amber = 1'b0;
        green = 1'b0;
        case (current_state)
            RED: red = 1'b1;
            RED_AMBER: begin red = 1'b1; amber = 1'b1; end
            GREEN: green = 1'b1;
            AMBER: amber = 1'b1;
        endcase
    end

endmodule


