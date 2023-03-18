`timescale 1ns/100ps
module PLL_tb;

    //inputs
    reg refclk, rst;

    //outputs
    wire outclk0, outclk1, locked;

	PLL p0(.refclk(refclk),   //  refclk.clk
		.rst(rst),      //   reset.reset
		.outclk_0(outclk0), // outclk0.clk
		.outclk_1(outclk1), // outclk1.clk
		.locked(locked) );

    always #5 refclk = ~refclk;

    initial begin
        #0 rst = 1;  refclk = 0;
        #10 rst = 0;
        #1000000 $stop;
        #10 $finish;
    end

endmodule