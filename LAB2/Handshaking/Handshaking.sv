module Handshaking(
    input logic clk, rst,
    output logic [3:0] cnt_1, cnt_2
);
typedef enum { START, PLUS, TRIGGER, WAIT } fsm_state_t;

fsm_state_t fsm1_current_state, fsm1_next_state;
fsm_state_t fsm2_current_state, fsm2_next_state;

logic cp1, cp2; //cnt plus
logic trigger_1, trigger_2; //trigger other fsm

always_ff @( posedge clk, posedge rst ) begin : ff_stuff
    if( rst ) begin
        fsm1_current_state <= START;
        fsm2_current_state <= START;
        cnt_1 <= 0;
        cnt_2 <= 0;
    end
    else begin
        fsm1_current_state <= fsm1_next_state;
        fsm2_current_state <= fsm2_next_state;
        if(cp1) cnt_1 <= cnt_1 + 1;
        if(cp2) cnt_2 <= cnt_2 + 1;
    end
end


//fsm1
always_comb begin : fsm1
    //default
    fsm1_next_state = fsm1_current_state;
    cp1 = 0;
    trigger_2 = 0;
    case ( fsm1_current_state )
        START: begin
            fsm1_next_state = PLUS;
        end
        PLUS: begin
            cp1 = 1;
            if(cnt_1==4'd4) fsm1_next_state = TRIGGER;
        end
        TRIGGER: begin
            trigger_2 = 1;
            fsm1_next_state = WAIT;
        end
        WAIT: begin
            if(trigger_1) fsm1_next_state = PLUS;
        end
    endcase
end


//fsm2
always_comb begin : fsm2
    //default
    fsm2_next_state = fsm2_current_state;
    cp2 = 0;
    trigger_1 = 0;
    case ( fsm2_current_state )
        START: begin
            fsm2_next_state = WAIT;
        end
        WAIT: begin
            if(trigger_2) fsm2_next_state = PLUS;
        end
        PLUS: begin
            cp2 = 1;
            if(cnt_2==4'd5) fsm2_next_state = TRIGGER;
        end
        TRIGGER: begin
            trigger_1 = 1;
            fsm2_next_state = WAIT;
        end
    endcase
end

endmodule