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

	typedef enum  {   START, WAIT, RECEIVING_ADDRESS, SAVING_ADDRESS,
					  RECEIVING_COMMAND, PROCESS_COMMAND,
					  RECEIVING_DATA, SAVING_DATA, FINISH } state_t;
	state_t current_state, next_state;


	logic shift_the_resigter;
	logic shift_register_reset;
	logic [15:0] shift_register;
	logic[7:0] bit_counter;
	logic bit_counter_count;
	logic bit_counter_reset;
	
	logic save_address;
	logic save_data;

	logic rx_finish;

	logic is_write;
	logic set_is_write;
	logic clear_is_write;

	always_ff @(posedge clk or posedge reset) begin
		if(reset) begin
			current_state <= START;
			shift_register <= 0;
			bit_counter <= 0;
			address <= 0;
			data <= 0;
			is_write <= 0;
		end
		else begin
			current_state <= next_state;

			if(shift_register_reset) shift_register <= 0;
			else if(shift_the_resigter) shift_register <= {shift_register[14:0], mosi};


			

			if(bit_counter_reset) bit_counter <= 0;
			else if(bit_counter_count) bit_counter <= bit_counter + 1;

			if(clear_is_write) is_write <= 0;
			else if(set_is_write) is_write <= 1;

			if(save_address) address <= shift_register[7:0];
			if(save_data) data <= shift_register[15:0];
			
		end
	end


	always_comb begin : fsm
		//default
		next_state = current_state;
		shift_the_resigter = 0;
		bit_counter_count = 0;
		bit_counter_reset = 0;
		shift_register_reset = 0;
		save_address = 0;
		save_data = 0;
		read_en = 0;
		tx_req = 0;
		write_en = 0;
		rx_finish = 0;

		set_is_write = 0;
		clear_is_write = 0;
	

		case (current_state)
			START: begin
				next_state = WAIT;
				shift_register_reset = 1;
				bit_counter_reset = 1;
				clear_is_write = 1;
			end
			WAIT: begin
				if(ssn_neg_edge_detected) begin
					next_state = RECEIVING_ADDRESS;
				end
			end 
			RECEIVING_ADDRESS: begin
				// if(ssn==1) begin
				// 	next_state = WAIT; //ssn=1時，結束接收
				// end

				if(sclk_pos_edge_detected) begin
					shift_the_resigter = 1;
					bit_counter_count = 1;
					if(bit_counter==7) begin
						next_state = SAVING_ADDRESS;
					end
				end

			end
			SAVING_ADDRESS: begin
				next_state = RECEIVING_COMMAND;
				save_address = 1;
			end
			RECEIVING_COMMAND: begin
				if(sclk_pos_edge_detected) begin
					shift_the_resigter = 1;
					bit_counter_count = 1;
					if(bit_counter==15) begin
						next_state = PROCESS_COMMAND;
						bit_counter_reset=1;
					end
				end
			end
			PROCESS_COMMAND: begin
				next_state = RECEIVING_DATA;
				if(shift_register[7]==1) begin //讀取指令，要回傳資料
					read_en = 1;
					tx_req = 1;
					rx_finish = 1;
				end
				else begin //寫入指令
					set_is_write = 1;
				end
			end
			
			RECEIVING_DATA: begin
				if(sclk_pos_edge_detected) begin
					shift_the_resigter = 1;
					bit_counter_count = 1;
					if(bit_counter==15) begin
						next_state = SAVING_DATA;
						bit_counter_reset=1;
					end
				end
				
			end
			SAVING_DATA: begin
				next_state = FINISH;
				if(is_write) begin //寫入指令
					save_data = 1;
				end
			end
			FINISH: begin
				if(is_write) begin //寫入指令
					write_en = 1;
					rx_finish = 1;
				end
				next_state = WAIT;
				clear_is_write = 1;
			end
		endcase
	end


endmodule
