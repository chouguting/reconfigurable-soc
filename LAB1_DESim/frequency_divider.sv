module frequency_divider(
	output logic clk_after,
	input clk,
	input reset_fd
	);
	parameter n = 24;
	
	logic [n-1:0] count;
	
	always_ff @(posedge clk)
	begin
		if(!reset_fd)
			count <= 0;
		else
			count <= count + 1;
	end
	
	assign clk_after = count[16];
endmodule