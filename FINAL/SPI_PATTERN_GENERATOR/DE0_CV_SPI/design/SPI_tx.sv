module SPI_tx(
    input logic clk,
    input logic reset,
    input logic start_tx,
    input logic [15:0] data_to_send,
    input logic sclk,
    output logic miso
);

    logic send_trigger;

    logic[15:0] shift_register;
    logic load_shift_register;
    logic reset_shift_register;
    logic shift_shift_register;

    assign miso = shift_register[15]; //送出MSB

    typedef enum{ START, WAIT, SEND, FINISH } state_t;
    state_t current_state, next_state;

    logic[7:0] send_counter;
    logic reset_send_counter;
    logic count_send_counter;

    EDGE_DETECTOR sclk_neg_edge_detector(
		.clk(clk), // clock input
    	.reset(reset), // reset input
    	.detect_signal(sclk), // input signal
    	.neg_edge_detected(send_trigger)
	);

    
    always_ff@(posedge clk or posedge reset) begin
        if(reset) begin 
            // miso <= 1'b0;
            shift_register <= 16'b0;
            current_state <= START;
            send_counter <= 8'b0;
        end 
        else begin
            if(reset_shift_register)
                shift_register <= 16'b0;
            else if(load_shift_register)
                shift_register <= data_to_send;
            else if(shift_shift_register)
                shift_register <= {shift_register[14:0], 1'b0};

            if(reset_send_counter)
                send_counter <= 8'b0;
            else if(count_send_counter)
                send_counter <= send_counter + 1'b1;    

            current_state <= next_state;
            
        end
    end

    always_comb begin : fsm
    
        //default
        next_state = current_state;
        load_shift_register = 1'b0;
        reset_shift_register = 1'b0;
        shift_shift_register = 1'b0;
        reset_send_counter = 1'b0;
        count_send_counter = 1'b0;

        case (current_state)
            START: begin
                next_state = WAIT;
                reset_shift_register = 1'b1;
                reset_send_counter = 1'b1;
            end
            WAIT: begin
                if(start_tx) begin
                    next_state = SEND;
                    load_shift_register = 1'b1;
                end
                    
                
            end 
            SEND: begin
                if(send_trigger) begin
                    count_send_counter = 1'b1;
                    if(send_counter>0)
                        shift_shift_register = 1'b1;
                    if(send_counter == 16)
                        next_state = FINISH;
                end
            end
            FINISH: begin
                next_state = WAIT;
                reset_shift_register = 1'b1;
                reset_send_counter = 1'b1;
            end
            
        endcase

    end




endmodule