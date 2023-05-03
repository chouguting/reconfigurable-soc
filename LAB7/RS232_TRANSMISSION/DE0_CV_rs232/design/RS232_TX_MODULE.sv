module RS232_TX_MODULE (
    input logic clk,
    input logic rst,
    input logic [7:0] data_in,
    input logic tx_start,
    output logic tx,
    output logic tx_finish
);

    typedef enum { START, WAIT, SENDING, FINISH } state_t;
    state_t current_state, next_state;

    logic[31:0] counter;
    logic counter_reset;
    logic counter_count;

    logic[5:0] bit_counter;
    logic bit_counter_reset;
    logic bit_counter_count;

    logic[9:0] data_to_send;
    logic pull_data;
    logic send_data_shift;

    logic tx_send;


    always_ff @( posedge clk, posedge rst ) begin
        if(rst) begin
            current_state <= START; 
            counter <= 0;
            bit_counter <= 0;
            data_to_send <= 10'b10_0000_0000;
            tx <= 1'b1; //一開始tx維持在1
        end
        else begin
            current_state <= next_state;

            if(counter_reset) begin
                counter <= 0;
            end
            else if(counter_count)begin
                counter <= counter + 1;
            end

            if(bit_counter_reset) begin
                bit_counter <= 0;
            end
            else if(bit_counter_count)begin
                bit_counter <= bit_counter + 1;
            end

            if(pull_data) begin
                data_to_send <= {1'b1, data_in, 1'b0};
            end 
            else if(send_data_shift) begin
                data_to_send <= {1'b1, data_to_send[9:1]};
            end



            if(tx_send) tx <= data_to_send[0]; //將data_to_send的最右邊的bit傳出去
            else tx <= 1'b1; //如果不是傳送資料的狀態，則tx維持在1
        end
    end

    always_comb begin : fsm1
        //default
        next_state = current_state;
        counter_reset = 0;
        counter_count = 0;
        bit_counter_reset = 0;
        bit_counter_count = 0;
        pull_data = 0;
        tx_send = 0;
        send_data_shift = 0;
        tx_finish = 0;

        case (current_state)
            START: begin
                next_state = WAIT;
            end
            WAIT: begin 
                if(tx_start) begin //如果收到tx_start的訊號，則開始傳送
                    next_state = SENDING;
                    counter_reset = 1;
                    bit_counter_reset = 1;
                    pull_data = 1;
                end
            end
            SENDING: begin
                tx_send = 1;
                counter_count = 1; //計算時間(在指定的baud rate下)
                //1302是baud rate 38400下一個bit的週期維持時間(clk數) (50M/38400=1302)
                if(bit_counter <= 8 && counter == 1302) begin 
                    bit_counter_count = 1; //進到下一個bit (bit_counter+1)
                    counter_reset = 1; //重新計算時間
                    send_data_shift = 1; //將data_to_send往右shift(最右邊的bit是要傳出去的bit)
                    
                end
                else if(bit_counter == 9 && counter == 1302) begin //傳送到最後一個bit(共10個bit)
                    next_state = FINISH; //傳送完畢
                    counter_reset = 1; //重新計算時間
                    bit_counter_reset = 1; //重新計算bit_counter
                end
            end
            FINISH: begin
                tx_finish = 1; //傳送完畢的flag
                next_state = WAIT; //回到等待下一次傳送
            end
        endcase
    end
    
endmodule