module counterPlusRegister(
    input logic clk, rst,
    output logic[3:0] w
);
    //fsm states
    logic[3:0] current_state, next_state; 

    logic[3:0] cnt_1, cnt_2; //counters
    logic cp1, cp2; //counters control
    logic load; //load control

    logic[3:0] addResult;
    assign addResult = cnt_1 + cnt_2;

    always_ff @( posedge clk, posedge rst ) begin : ff_stuff
        if (rst) begin
            //reset
            current_state <= 0;
            cnt_1 <= 4'b0000;
            cnt_2 <= 4'b0000;
            w <= 4'b0000;
        end
        else begin
            current_state <= next_state;
            if(cp1) cnt_1 <= cnt_1 + 1;
            if(cp2) cnt_2 <= cnt_2 + 1;
            if(load) w <= addResult;
        end
    end

    //fsm
    always_comb begin : fsm_1
        //default
        next_state = current_state;
        cp1 = 0;
        cp2 = 0;
        load = 0;

        case (current_state)
            0,1,2: begin
                cp1 = 1;
                cp2 = 1;
                next_state = current_state + 1;
            end
            3: begin
                cp2 = 1;
                next_state = 4;
            end
            4: begin
                load = 1;
                next_state = 5;
            end
            5,6: begin
                cp1 = 1;
                cp2 = 1;
                next_state = current_state + 1;
            end
            7: begin
                cp2 = 1;
                next_state = 8;
            end
            8: begin
                load = 1;
                next_state = 9;
            end
            9: begin
                next_state = current_state;
            end            
        endcase
    end
endmodule