module ARBITRATION(
    input logic clk, reset,
    input logic A, B, C,
    output logic A_out, B_out, C_out
);

    typedef enum  { START, A_FIRST,  B_FIRST, C_FIRST } state_t;

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
                next_state = A_FIRST;
            end
            A_FIRST: begin
                if(A) begin
                    A_out = 1'b1;
                    next_state = B_FIRST;
                end 
                else if(B) begin
                    B_out = 1'b1;
                    next_state = C_FIRST;
                end
                else if(C) begin
                    C_out = 1'b1;
                    next_state = A_FIRST;
                end
            end
            B_FIRST: begin
                if(B) begin
                    B_out = 1'b1;
                    next_state = C_FIRST;
                end
                else if(C) begin
                    C_out = 1'b1;
                    next_state = A_FIRST;
                end
                else if(A) begin
                    A_out = 1'b1;
                    next_state = B_FIRST;
                end
            end
            C_FIRST: begin
                if(C) begin
                    C_out = 1'b1;
                    next_state = A_FIRST;
                end
                else if(A) begin
                    A_out = 1'b1;
                    next_state = B_FIRST;
                end
                else if(B) begin
                    B_out = 1'b1;
                    next_state = C_FIRST;
                end
            end
        endcase
    end

endmodule