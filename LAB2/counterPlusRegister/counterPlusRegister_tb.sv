`timescale 1ns/100ps
module counterPlusRegister_tb;
    //inputs
    reg clk, rst;

    //outputs
    wire [3:0] w;

    counterPlusRegister cpr(.clk(clk), .rst(rst), .w(w));

    always #5 clk = ~clk;

    initial begin
        #0 rst = 1; clk = 0;
        #20 rst = 0;
        #100 $stop;
        #10 $finish;
    end

    initial begin
        $monitor("w = %d", w);
    end

endmodule