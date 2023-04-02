module ENCODER_PERIOD(
    input logic system_clk,
    input logic reset,
    input logic count_signal,
    output logic [31:0] encoder_count
);

    logic[31:0] current_count;
    logic counter_enable;
    logic count_load;
    logic counter_reset;

    typedef enum  { START, COUNT, LOAD_AND_RESET } state_t;
    state_t current_state, next_state;

    always_ff@(posedge system_clk or negedge reset) begin :ff_stuff
        if(~reset) begin
            encoder_count <= 0;
            current_count <= 0;
            current_state <= START;
        end
        else begin
            if(counter_reset) current_count <= 0;
            else if(counter_enable)  current_count <= current_count+1;

            if(count_load) encoder_count <= current_count;

            current_state <= next_state; 
        end
    end

    always_comb begin : fsm
        //default
        counter_enable = 0;
        count_load = 0;
        next_state = current_state;
        counter_reset = 0;
        
        case (current_state)
            START: begin
                next_state = COUNT;
            end
            COUNT: begin
                counter_enable = 1;
                if(count_signal) begin
                    counter_enable = 0;
                    next_state = LOAD_AND_RESET;
                end
            end
            LOAD_AND_RESET: begin
                count_load = 1;
                counter_reset = 1;
                next_state = COUNT;
            end
        endcase
    end
endmodule