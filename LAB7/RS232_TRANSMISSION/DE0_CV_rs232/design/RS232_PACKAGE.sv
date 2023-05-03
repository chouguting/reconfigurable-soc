module RS232_PACKAGE(
    input logic clk,                          
    input logic rst,            
    input logic[13:0] r_LPF_threshold,
    input logic[1:0] buad_setting,    
    input logic rx,
    output logic tx,
    output logic[7:0] data_debug,
    output logic tx_end_flag
);

    logic rx_sigle_byte_finish;     //rx_sigle_byte_finish是讀取完一個byte的訊號
    logic[7:0] rx_sigle_byte_data;  //rx_sigle_byte_data是讀取到一個byte的資料

    //處理(讀取)一個byte的資料
    RS232_SINGLE_BYTE rs232_single_byte(
        .clk(clk),                          
        .rst(rst),            
        .r_LPF_threshold(r_LPF_threshold),
        .rx(rx),
        .rx_finish(rx_sigle_byte_finish),
        .rx_data_out(rx_sigle_byte_data) 
    );

    logic[7:0] check_sum_counter;
    logic reset_check_sum_counter;
    logic add_check_sum_counter;

    logic package_ready; //package_ready是判斷是否讀取完一個package的訊號
    //一個package的資料包含: head, address, data, read_write, check_sum, tail
    logic[7:0] head;  //head是頭
    logic[7:0] address; //address是地址
    logic[7:0] data; //data是資料
    logic[7:0] read_write; //read_write是讀或寫的訊號(0是讀, 1是寫)
    logic[7:0] check_sum; //check_sum是檢查碼
    logic[7:0] tail; //tail是尾

    //控制目前存的資料
    logic load_head;
    logic load_address_1, load_address_2;
    logic load_data_1, load_data_2;
    logic load_read_write;
    logic load_check_sum;
    logic load_tail;

    typedef enum { START, WAIT, ADDR_1, ADDR_2, DATA_1, DATA_2, 
                    READ_OR_WRITE, CHECK_SUM, TAIL, FINISH_FETCH,
                    TX_SEND, TX_WAIT } state_t;

    state_t current_state, next_state;

    //register file
    logic[8:0] reg_file_address;
    logic reg_file_write_enable;
    
    logic[7:0] register_file[0:255];
    logic[7:0] reg_file_data_to_read;

    assign reg_file_address = address; //將address設為用來存取reg_file的address
    
    always_ff@(posedge clk) begin
        if(reg_file_write_enable) begin
            register_file[reg_file_address] <= data; //將data寫入reg_file
        end
    end

    assign reg_file_data_to_read = register_file[reg_file_address]; //從reg_file讀出來的data


    //TX stuff
    logic[7:0] tx_data_to_send[0:3];
    logic[2:0] tx_counter; //tx_counter是用來記錄現在送到第幾個byte
    logic tx_data_load;
    logic tx_counter_count;  
    logic tx_counter_reset;
    logic tx_start;
    logic tx_finish;

    RS232_TX_MODULE tx_1(
        .clk(clk),
        .rst(rst),
        .data_in(tx_data_to_send[tx_counter]),  //tx_data_to_send[tx_counter]是準備要送出去的資料
        .tx_start(tx_start),  //tx_start用來啟動tx的訊號
        .tx(tx),  //tx是要送出去的資料
        .tx_finish(tx_finish)  //tx_finish是tx送完的訊號
    );

    



    always_ff@(posedge clk, posedge rst) begin
        if(rst) begin
            current_state <= START;
            head <= 8'h00;
            address <= 8'h00;
            data <= 8'h00;
            read_write <= 8'h00;
            check_sum <= 8'h00;
            tail <= 8'h00;
            check_sum_counter <= 8'h00;
            tx_counter <= 3'b000;
            tx_data_to_send[0] <= 8'h02; //將tx_data_to_send[0]設為頭(8'h02)
            tx_data_to_send[1] <= 8'h00; //將tx_data_to_send[1]設為0
            tx_data_to_send[2] <= 8'h00; //將tx_data_to_send[2]設為0
            tx_data_to_send[3] <= 8'h03; //將tx_data_to_send[3]設為尾(8'h03)

        end else begin
            current_state <= next_state;
            if(load_head) head <= rx_sigle_byte_data;
            if(load_address_1) address[7:4] <= rx_sigle_byte_data[3:0];
            if(load_address_2) address[3:0] <= rx_sigle_byte_data[3:0];
            if(load_data_1) data[7:4] <= rx_sigle_byte_data[3:0];
            if(load_data_2) data[3:0] <= rx_sigle_byte_data[3:0];
            if(load_read_write) read_write <= rx_sigle_byte_data;
            if(load_check_sum) check_sum <= rx_sigle_byte_data;
            if(load_tail) tail <= rx_sigle_byte_data;

            if(reset_check_sum_counter) check_sum_counter <= 8'h00;
            else if(add_check_sum_counter) check_sum_counter <= check_sum_counter + rx_sigle_byte_data;

            if(tx_counter_reset) tx_counter <= 3'b000;
            else if(tx_counter_count) tx_counter <= tx_counter + 1'b1;

            if(tx_data_load) begin
                tx_data_to_send[0] <= 8'h02;  //將tx_data_to_send[0]設為頭(8'h02)
                tx_data_to_send[1] <= {4'h3, reg_file_data_to_read[7:4]}; //將reg_file讀出來的資料前半段放進tx_data_to_send[1]
                tx_data_to_send[2] <= {4'h3, reg_file_data_to_read[3:0]}; //將reg_file讀出來的資料後半段放進tx_data_to_send[2]
                tx_data_to_send[3] <= 8'h03;  //將tx_data_to_send[3]設為尾(8'h03)
            end
        end
    end


    always_comb begin : fsm1

        //default
        next_state = current_state;
        load_head = 1'b0;
        load_address_1 = 1'b0;
        load_address_2 = 1'b0;
        load_data_1 = 1'b0;
        load_data_2 = 1'b0;
        load_read_write = 1'b0;
        load_check_sum = 1'b0; 
        load_tail = 1'b0;
        reset_check_sum_counter = 1'b0;
        add_check_sum_counter = 1'b0;
        package_ready = 1'b0;
        reg_file_write_enable = 1'b0;
        tx_counter_count = 1'b0;
        tx_counter_reset = 1'b0;
        tx_data_load = 1'b0;
        tx_start = 1'b0;
        tx_end_flag = 1'b0;

        case (current_state)
            START: begin
                next_state = WAIT;  //一開始就進入WAIT
            end
            WAIT: begin
                //如果現在遇到的是開始符號，就進入ADDR_1
                if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h02) begin 
                    next_state = ADDR_1;
                    load_head = 1'b1;
                    add_check_sum_counter = 1'b1;
                end
            end
            ADDR_1: begin
                //如果現在就遇到結束符號，就直接回到WAIT
                if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h03) begin
                    next_state = WAIT;
                    reset_check_sum_counter = 1'b1;
                end
                //如果現在遇到的是開始符號，就回到ADDR_1，並且重新載入head
                else if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h02) begin
                    next_state = ADDR_1;
                    load_head = 1'b1;
                    reset_check_sum_counter = 1'b1;
                end
                //如果現在遇到的是地址，就進到ADDR_2
                else if(rx_sigle_byte_finish) begin
                    next_state = ADDR_2;
                    load_address_1 = 1'b1;
                    add_check_sum_counter = 1'b1;
                end
            end
            ADDR_2: begin
                //如果現在就遇到結束符號，就直接回到WAIT
                if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h03) begin
                    next_state = WAIT;
                    reset_check_sum_counter = 1'b1;
                end
                //如果現在遇到的是開始符號，就回到ADDR_1，並且重新載入head
                else if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h02) begin
                    next_state = ADDR_1;
                    load_head = 1'b1;
                    reset_check_sum_counter = 1'b1;
                end
                //如果現在遇到的是地址，就進到DATA_1
                else if(rx_sigle_byte_finish) begin
                    next_state = DATA_1;
                    load_address_2 = 1'b1;
                    add_check_sum_counter = 1'b1;
                end
            end
            DATA_1: begin
                //如果現在就遇到結束符號，就直接回到WAIT
                if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h03) begin
                    next_state = WAIT;
                    reset_check_sum_counter = 1'b1;
                end
                //如果現在遇到的是開始符號，就回到ADDR_1，並且重新載入head
                else if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h02) begin
                    next_state = ADDR_1;
                    load_head = 1'b1;
                    reset_check_sum_counter = 1'b1;
                end
                //如果現在遇到的是資料，就進到DATA_2
                else if(rx_sigle_byte_finish) begin
                    next_state = DATA_2;
                    load_data_1 = 1'b1;
                    add_check_sum_counter = 1'b1;
                end
            end
            DATA_2: begin
                //如果現在就遇到結束符號，就直接回到WAIT
                if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h03) begin
                    next_state = WAIT;
                    reset_check_sum_counter = 1'b1;
                end
                //如果現在遇到的是開始符號，就回到ADDR_1，並且重新載入head
                else if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h02) begin
                    next_state = ADDR_1;
                    load_head = 1'b1;
                    reset_check_sum_counter = 1'b1;
                end
                //如果現在遇到的是資料，就進到CHECK_SUM
                else if(rx_sigle_byte_finish) begin
                    next_state = READ_OR_WRITE;
                    load_data_2 = 1'b1;
                    add_check_sum_counter = 1'b1;
                end
            end
            READ_OR_WRITE: begin
                //如果現在就遇到結束符號，就直接回到WAIT
                if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h03) begin
                    next_state = WAIT;
                    reset_check_sum_counter = 1'b1;
                end
                //如果現在遇到的是開始符號，就回到ADDR_1，並且重新載入head
                else if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h02) begin
                    next_state = ADDR_1;
                    load_head = 1'b1;
                    reset_check_sum_counter = 1'b1;
                end
                //將讀取寫入指令寫入，進到CHECK_SUM
                else if(rx_sigle_byte_finish) begin
                    next_state = CHECK_SUM;
                    load_read_write = 1'b1;
                    add_check_sum_counter = 1'b1;
                end
            end
            CHECK_SUM: begin
                //如果現在就遇到結束符號，就直接回到WAIT
                if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h03) begin
                    next_state = WAIT;
                    reset_check_sum_counter = 1'b1;
                end
                //如果現在遇到的是開始符號，就回到ADDR_1，並且重新載入head
                else if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h02) begin
                    next_state = ADDR_1;
                    load_head = 1'b1;
                    reset_check_sum_counter = 1'b1;
                end
                //如果CHECK_SUM跟我們計算出來的不一樣，就回到WAIT
                else if(rx_sigle_byte_finish && check_sum_counter!=rx_sigle_byte_data) begin
                    next_state = WAIT;
                    reset_check_sum_counter = 1'b1;
                end
                //如果CHECK_SUM跟我們計算出來的一樣，就進到TAIL
                else if(rx_sigle_byte_finish) begin
                    next_state = TAIL;
                    load_check_sum = 1'b1;
                end
            end
            TAIL: begin
                //如果現在就遇到結束符號，就代表成功接收完整PACKAGE
                if(rx_sigle_byte_finish && rx_sigle_byte_data == 8'h03) begin
                    next_state = FINISH_FETCH;
                    load_tail = 1'b1;
                end
                //如果有其他情況，就回到WAIT
                else if(rx_sigle_byte_finish)begin
                    next_state = WAIT;
                    reset_check_sum_counter = 1'b1;
                end
            end
            FINISH_FETCH: begin
                // next_state = WAIT;
                package_ready = 1'b1;   //整個package接收完成
                reset_check_sum_counter = 1'b1;  //重置check_sum_counter
                if(read_write[0] == 1) begin //write
                    next_state = WAIT;  //寫入只需要一個clk, 所以直接回到WAIT
                    reg_file_write_enable = 1'b1;  //寫入reg_file
                end
                else begin //read
                    next_state = TX_SEND;  //讀取結果需要回傳, 所以進到TX_SEND
                    tx_data_load = 1'b1; //載入tx_data(準備好要傳送的資料到tx_data_to_send)
                end
            end
            TX_SEND: begin
                tx_start = 1'b1;  //開始傳送(傳送的是tx_data_to_send[tx_counter_count])
                next_state = TX_WAIT;  //等待一個byte傳送完成 進到TX_WAIT
            end
            TX_WAIT: begin
                if(tx_finish && tx_counter<3) begin  //如果傳送完成且還沒傳送完整個package
                    tx_counter_count = 1'b1;  //tx_counter_count+1
                    next_state = TX_SEND; //回到TX_SEND 繼續傳送下一個byte
                end 
                else if(tx_finish && tx_counter==3) begin
                    next_state = WAIT;  //如果傳送完成且已經傳送完整個package, 就回到WAIT
                    tx_counter_reset = 1'b1;  //重置tx_counter
                    tx_end_flag = 1'b1; //全部傳送完成
                end
            end
        endcase
    end


endmodule