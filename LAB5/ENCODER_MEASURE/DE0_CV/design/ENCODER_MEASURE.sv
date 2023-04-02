module ENCODER_MEASURE(
    input logic system_clk,
    input logic reset,
    input logic [31:0] encoder_count_measure, //encoder輸出之計數值
    input logic [15:0]  r_distance, 
    output logic step_dist //希望產生之clk
);

    logic[31:0] step_counter;
    logic[31:0] step_cnt;
    assign step_cnt = r_distance*encoder_count_measure/4233;

    
    typedef enum {START, LOAD_CNT, COUNT, PULSE_AND_REPEAT } state_t;
    state_t current_state, next_state;

    logic counter_enable, load_counter; 


    always_ff @(posedge system_clk or negedge reset) begin
        if(~reset) begin
            current_state <= START;
            step_counter <= 0;
        end
        else begin
            current_state <= next_state;
            if(load_counter) 
                step_counter <= step_cnt;
            else if(counter_enable && step_counter!=0) 
                step_counter <= step_counter - 1;
        end
    end

    always_comb begin
        //default
        next_state = current_state;
        step_dist = 0;
        counter_enable = 0;
        load_counter = 0;

        case(current_state)
            START: begin
                if(step_cnt!=0) next_state = LOAD_CNT;
            end
            LOAD_CNT: begin
                load_counter = 1;
                next_state = COUNT;
            end
            COUNT: begin
                counter_enable = 1;
                if(step_counter==0) next_state = PULSE_AND_REPEAT;
            end
            PULSE_AND_REPEAT: begin
                load_counter = 1;
                step_dist = 1;
                next_state = COUNT;
            end
        endcase
    end

endmodule