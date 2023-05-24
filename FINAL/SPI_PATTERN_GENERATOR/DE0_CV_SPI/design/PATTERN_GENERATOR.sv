module PATTERN_GENERATOR(
    input logic clk,
    input logic rst,
    input logic pg_control, //控制開關
    input logic fifo_empty,
    input logic[15:0] send_speed,  //傳送速度
    input logic[15:0] data_from_fifo, //輸入pattern
    output logic [15:0] pattern_out, //輸出pattern
    output logic fifo_rd_req
);

    logic pg_control_pos_edge_detected;
    logic fifo_rd_req_temp;

    EDGE_DETECTOR pg_control_pos_edge_detector(
		.clk(clk), // clock input
    	.reset(rst), // reset input
    	.detect_signal(pg_control), // input signal
    	.pos_edge_detected(pg_control_pos_edge_detected)
	);

    always_ff@(negedge clk or posedge rst) begin
		if(rst) begin
			fifo_rd_req <= 0;
		end
		else begin
			fifo_rd_req <= fifo_rd_req_temp;
		end
	end

    logic [31:0] cycle_counter;
    logic reset_cycle_counter;
    logic count_cycle_counter;

    typedef enum { START, WAIT, GENERATING, FINISH } state_t;
    state_t current_state, next_state;

    assign pattern_out = data_from_fifo;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            current_state <= START;
            cycle_counter <= 0;
        end
        else begin
            current_state <= next_state;

            if(reset_cycle_counter) cycle_counter <= 0;
            else if(count_cycle_counter) cycle_counter <= cycle_counter + 1;
        end
    end


    always_comb begin : fsm
        //default
        next_state = current_state;
        reset_cycle_counter = 0;
        count_cycle_counter = 0;
        fifo_rd_req_temp = 0;

        case (current_state)
            START: begin
                reset_cycle_counter = 1;
                next_state = WAIT;
            end
            WAIT: begin
                if(pg_control_pos_edge_detected && ~fifo_empty) begin
                    next_state = GENERATING;
                    fifo_rd_req_temp = 1;
                end
            end
            GENERATING: begin
                count_cycle_counter = 1;
                if(cycle_counter == send_speed) begin
                    reset_cycle_counter = 1;
                    
                    if( fifo_empty ) begin
                        next_state = FINISH;
                    end
                    else begin
                        fifo_rd_req_temp = 1;
                    end
                end
                
            end
            FINISH: begin
                next_state = WAIT;
                reset_cycle_counter = 1;
            end
        endcase


    end



    
    
endmodule