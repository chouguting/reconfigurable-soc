module trafficLight_tb;
//inputs
reg clk, rst;
//outputs
wire [1:0] R,Y,G;

trafficLight tf(.clk(clk), .rst(rst), .R(R), .Y(Y), .G(G));

always #5 clk = ~clk;

initial begin
    #0 clk=0; rst=1;
    #10 rst=0;
    #400 $stop;
end

initial $monitor("R=%b, Y=%b, G=%b", R, Y, G);
endmodule