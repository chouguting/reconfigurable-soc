`timescale 1ns/100ps
module tx_testbench;

    //inputs
    reg clk, rst, tx_start;
    reg[7:0] data_in;
    //outputs
    wire tx, tx_finish;

    RS232_TX_MODULE tx1(
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .tx_start(tx_start),
        .tx(tx)
        // .tx_finish(tx_finish)
    );

    always #5 clk = ~clk;

    initial begin
        #0 clk=0; rst=1; tx_start=0; data_in=8'h36;
        #10 rst=0;
        #20 tx_start=1;
        #30 tx_start=0;
        #200000 $stop;
        #10 $finish;
    end

endmodule