module TEST(
	input clk, reset,
	output reg[3:0] result,
	output wire clk_div
);

	freq_div f1(.clk_in(clk), .reset(reset), .clk_out(clk_div));
	
	reg[3:0] current_state, next_state;
	
	always@(posedge reset or posedge clk_div)
	begin
		if(reset)
			current_state <= 4'h0;
		else
			current_state <= next_state;
	end
	
	always@(*)
	begin
		case(current_state)
			4'h0:
			begin
				next_state = 4'h1;
				result = 4'd0;
			end
			4'h1:
			begin
				next_state = 4'h2;
				result = 4'd0;
			end
			4'h2:
			begin
				next_state = 4'h3;
				result = 4'd8;
			end
			4'h3:
			begin
				next_state = 4'h4;
				result = 4'd5;
			end
			4'h4:
			begin
				next_state = 4'h5;
				result = 4'd7;
			end
			4'h5:
			begin
				next_state = 4'h6;
				result = 4'd0;
			end
			4'h6:
			begin
				next_state = 4'h7;
				result = 4'd0;
			end
			4'h7:
			begin
				next_state = 4'h0;
				result = 4'd5;
			end
			default:
			begin
				next_state = 4'h0;
				result = 4'd0;
			end
		
		endcase
	end

endmodule

module freq_div(
	input clk_in, reset,
	output reg clk_out
);

	reg[2:0] counter;
	
	always@(posedge reset or posedge clk_in) begin
		if(reset) 
		begin 
			clk_out <= 0;
			counter <= 3'h0;
		end
		else begin
			if(counter==3'h1) 
			begin
				counter <= 3'h0;
				clk_out <= ~clk_out;
			end
			else
			begin
				counter <= counter + 1;
			end
		end
	end


endmodule


