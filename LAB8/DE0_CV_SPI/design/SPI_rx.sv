module SPI_rx(
	//------output--------------------------------
	output logic [7:0]	address,	    //8 bits address
    output logic [15:0] data,           //16 bits data
    output logic        read_en,
    output logic        write_en,
    output logic 		tx_req,
	
	//------input---------------------------------	
	input				mosi,	
	input				sclk,           //10MHz
	input				ssn,			
	input				clk,  		    //100MHz
	input				reset 		    //reset=1時，系統重製	

	);

	


	logic ssn_neg_edge_detected;
	logic sclk_pos_edge_detected;

	EDGE_DETECTOR ssn_neg_edge_detector(
		.clk(clk), // clock input
    	.reset(reset), // reset input
    	.detect_signal(ssn), // input signal
    	.neg_edge_detected(ssn_neg_edge_detected)
	);

	EDGE_DETECTOR sclk_pos_edge_detector(
		.clk(clk), // clock input
    	.reset(reset), // reset input
    	.detect_signal(sclk), // input signal
    	.pos_edge_detected(sclk_pos_edge_detected)
	);

	typedef enum  { START, WAIT, RECEIVING, FINISH } state_t;
	state_t current_state, next_state;


	logic shift_the_resigter;
	logic shift_register_reset;
	logic[7:0] bit_counter;
	logic bit_counter_count;
	logic bit_counter_reset;
	

	always_ff @(posedge clk or posedge reset) begin
		if(reset) begin
			current_state <= START;
			data <= 0;
			bit_counter <= 0;
		end
		else begin
			current_state <= next_state;

			if(shift_register_reset) data <= 0;
			else if(shift_the_resigter) data <= {data[14:0], mosi};


			

			if(bit_counter_reset) bit_counter <= 0;
			else if(bit_counter_count) bit_counter <= bit_counter + 1;
		end
	end


	always_comb begin : fsm
		//default
		next_state = current_state;
		shift_the_resigter = 0;
		bit_counter_count = 0;
		bit_counter_reset = 0;
		shift_register_reset = 0;

		case (current_state)
			START: begin
				next_state = WAIT;
				shift_register_reset = 1;
				bit_counter_reset = 1;
			end
			WAIT: begin
				if(ssn_neg_edge_detected) begin
					next_state = RECEIVING;
				end
			end 
			RECEIVING: begin
				if(ssn==1) begin
					next_state = FINISH;
				end

				if(sclk_pos_edge_detected) begin
					shift_the_resigter = 1;
					bit_counter_count = 1;
					if(bit_counter==15) begin
						next_state = FINISH;
					end
				end

			end
			FINISH: begin
				next_state = WAIT;
				bit_counter_reset=1;
			end
		endcase
	end


endmodule
