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

    logic rx_sigle_byte_finish;
    logic[7:0] rx_sigle_byte_data;

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

    logic package_ready;
    logic[7:0] head;
    logic[7:0] address;
    logic[7:0] data;
    logic[7:0] read_write;
    logic[7:0] check_sum;
    logic[7:0] tail;

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
    
    always_ff@(posedge clk) begin
        if(reg_file_write_enable) begin
            register_file[reg_file_address] <= data;
        end
    end

    assign reg_file_data_to_read = register_file[reg_file_address];


    //TX stuff
    logic[7:0] tx_data_to_send[0:3];
    logic[2:0] tx_counter;
    logic tx_data_load;
    logic tx_counter_count;
    logic tx_counter_reset;
    logic tx_start;
    logic tx_finish;

    RS232_TX_MODULE tx_1(
        .clk(clk),
        .rst(rst),
        .data_in(tx_data_to_send[tx_counter]),
        .tx_start(tx_start),
        .tx(tx),
        .tx_finish(tx_finish)
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
            tx_data_to_send[0] <= 8'h00;
            tx_data_to_send[1] <= 8'h00;
            tx_data_to_send[2] <= 8'h00;
            tx_data_to_send[3] <= 8'h00;

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
                tx_data_to_send[0] <= 8'h02;
                tx_data_to_send[1] <= {4'h3, data[7:4]};
                tx_data_to_send[2] <= {4'h3, data[3:0]};
                tx_data_to_send[3] <= 8'h03;
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
                next_state = WAIT;
            end
            WAIT: begin
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
                package_ready = 1'b1;
                reset_check_sum_counter = 1'b1;
                if(read_write[0] == 1) begin //write
                    next_state = WAIT;
                    reg_file_write_enable = 1'b1;
                end
                else begin //read
                    next_state = TX_SEND;
                    tx_data_load = 1'b1;
                end
            end
            TX_SEND: begin
                tx_start = 1'b1;
                next_state = TX_WAIT;
            end
            TX_WAIT: begin
                if(tx_finish && tx_counter<3) begin
                    tx_counter_count = 1'b1;
                    next_state = TX_SEND;
                end 
                else if(tx_finish && tx_counter==3) begin
                    next_state = WAIT;
                    tx_counter_reset = 1'b1;
                    tx_end_flag = 1'b1;
                end
            end
        endcase
    end


endmodule