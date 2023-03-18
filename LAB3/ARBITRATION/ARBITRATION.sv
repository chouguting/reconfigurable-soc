module ARBITRATION(
    input logic clk, reset,
    input logic A, B, C,
    output logic A_out, B_out, C_out
);

    typedef enum  { START, WAIT, CHECK_A,  CHECK_B, CHECK_C } state_t;

    state_t current_state, next_state;

    always_ff @( posedge clk, posedge reset ) begin : ff_stuff
        if( reset ) begin
            current_state <= START;
        end
        else begin
            current_state <= next_state;
        end
    end

    always_comb begin : fsm
        //default
        next_state = current_state;
        A_out = 1'b0;
        B_out = 1'b0;
        C_out = 1'b0;

        case (current_state)
            START: begin
                next_state = WAIT;
            end
            WAIT: begin
                if (A) begin
                    next_state = CHECK_B;
                    A_out = 1'b1;
                end
                else if (B) begin
                    next_state = CHECK_C;
                    B_out = 1'b1;
                end
                else if (C) begin
                    next_state = CHECK_A;
                    C_out = 1'b1;
                end
            end 
            CHECK_A: begin
                next_state = CHECK_B;
                if(A) A_out = 1'b1;
            end
            CHECK_B: begin
                next_state = CHECK_C;
                if(B) B_out = 1'b1;
            end
            CHECK_C: begin
                next_state = CHECK_A;
                if(C) C_out = 1'b1;
            end
        endcase
    end

endmodule