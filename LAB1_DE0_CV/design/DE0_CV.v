
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module DE0_CV(

	//////////// CLOCK //////////
	input 		          		CLOCK_50,
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	inout 		          		CLOCK4_50,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,
	input 		          		RESET_N,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// microSD Card //////////
	output		          		SD_CLK,
	inout 		          		SD_CMD,
	inout 		     [3:0]		SD_DATA,

	//////////// SW //////////
	input 		     [9:0]		SW
);
//=======================================================
//  REG/WIRE declarations
//=======================================================

//=======================================================
//  Structural coding
//=======================================================	
	student_id id1(
		.clk_50M(CLOCK_50),
		.reset(KEY[0]),
		.reset_div(KEY[1]),
		.out(HEX0)
	);
endmodule