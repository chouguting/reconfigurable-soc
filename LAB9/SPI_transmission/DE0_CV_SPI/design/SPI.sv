//SPI slave
//mode: 0 (閒置時sclk為0，在第一個edge取值)

module SPI(
	//------output--------------------------------
	output logic 		miso,
	output logic [15:0] data_debug,
	
	//------input---------------------------------	
	input 		 		mosi,
	input 		 		sclk,			//傳輸速度: 10MHz
	input 		 		ssn,		
	input 		 		clk,			//系統 clk: 100MHz
	input 		 		reset			//系統 reset

	);

	// logic mosi_filtered;
	// logic sclk_filtered;
	// logic ssn_filtered;
	

	// Low_Pass_Filter lpf_mosi
	// (
	// 	.sig_filter(mosi_filtered),	
	// 	.signal(mosi),	
	// 	.r_LPF_threshold(14'd5),  //	Unit : 0.08us  /// 2^3 = 8,  r_LPF_threshold=0 => By Pass
	// 	.clk(clk), 
	// 	.reset(reset)
	// );

	// Low_Pass_Filter lpf_sclk
	// (
	// 	.sig_filter(sclk_filtered),	
	// 	.signal(sclk),	
	// 	.r_LPF_threshold(14'd5),  //	Unit : 0.08us  /// 2^3 = 8,  r_LPF_threshold=0 => By Pass
	// 	.clk(clk), 
	// 	.reset(reset)
	// );

	// Low_Pass_Filter lpf_ssn
	// (
	// 	.sig_filter(ssn_filtered),	
	// 	.signal(ssn),	
	// 	.r_LPF_threshold(14'd5),  //	Unit : 0.08us  /// 2^3 = 8,  r_LPF_threshold=0 => By Pass
	// 	.clk(clk), 
	// 	.reset(reset)
	// );

	logic tx_req;
	logic read_en;
	logic write_en;
	logic [7:0] address;
	logic [15:0] data;
	assign data_debug = data;
	logic [15:0] data_to_send;

	SPI_rx rx_moule(
		.address(address),	    //8 bits address
    	.data(data),           //16 bits data
    	.read_en(read_en),
    	.write_en(write_en),
    	.tx_req(tx_req),

		//------input---------------------------------	
		.mosi(mosi),	
		.sclk(sclk),           //10MHz
		.ssn(ssn),			
		.clk(clk),  		    //100MHz
		.reset(reset) 	
	);

	SPI_tx tx_module(
		.clk(clk),
    	.reset(reset),
    	.start_tx(tx_req),
    	.data_to_send(data_to_send),
    	.sclk(sclk),
    	.miso(miso)
	);

	REGISTER_FILE register_file_module(
		.clk(clk),
    	.write_en(write_en),
    	.read_en(read_en),
    	.address(address),
    	.data_in(data),
    	.data_out(data_to_send)
	);






endmodule



