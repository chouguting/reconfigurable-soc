module trafficLight(
    input logic clk, rst,
    output logic[1:0] R, Y, G
);
    logic[3:0] current_state, next_state;

    always_ff @( posedge clk, posedge rst ) begin : ff_stuff
        if(rst) begin
            current_state <= 4'b0000;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin : fsm_1
        //default
        next_state = current_state;
        R = 2'b00;
        Y = 2'b00;
        G = 2'b00;

        case (current_state)
            0,1,2,3,4,5:begin
                R[0] = 1'b1;
                G[1] = 1'b1;
                next_state = current_state + 1;
            end
            6,7:begin
                R[0] = 1'b1;
                Y[1] = 1'b1;
                next_state = current_state + 1;
            end
            8,9,10,11,12,13:begin
                G[0] = 1'b1;
                R[1] = 1'b1;
                next_state = current_state + 1;
            end
            14,15:begin
                Y[0] = 1'b1;
                R[1] = 1'b1;
                next_state = current_state + 1;
            end         
        endcase
    end

endmodule