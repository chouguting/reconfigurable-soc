`timescale 1ns/100ps
module Handshaking_tb;
//input
reg clk, rst;
//output
wire [3:0] cnt_1, cnt_2;

Handshaking h_1(.clk(clk), .rst(rst), .cnt_1(cnt_1), .cnt_2(cnt_2));

always #5 clk = ~clk;

initial begin
    #0 rst = 1; clk = 0;
    #20 rst = 0;
    #200 $stop;
    #10 $finish;
end

initial $monitor("cnt_1 = %d, cnt_2 = %d", cnt_1, cnt_2);
endmodule