module ARBITRATION_tb;
    //inputs
    reg clk, reset, A, B, C;
    //outputs
    wire A_out, B_out, C_out;

    ARBITRATION a1(
        .clk(clk), .reset(reset),
        .A(A), .B(B), .C(C),
        .A_out(A_out), .B_out(B_out), .C_out(C_out)
    );

    always #10 clk = ~clk;

    initial begin
        #0 reset = 1; clk = 0; A = 0; B = 0; C = 0;
        #30 reset = 0; 
        #20 A = 1; B = 1; C = 1;
        #60 A = 0; B = 0; C = 0;
        #60 A = 0; B = 1; C = 0;
        #20 A = 0; B = 0; C = 0;
        #60 A = 1; B = 0; C = 1;
        #40 A = 0; B = 0; C = 0;
        #1000 $stop;
        #10 $finish;
    end

endmodule