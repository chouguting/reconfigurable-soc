module RS232_SINGLE_BYTE(
    input logic clk,                          
    input logic rst,            
    input logic[13:0] r_LPF_threshold,
    // input logic[1:0] buad_setting,    
    input logic rx,
    // output logic tx,
    output logic rx_finish,
    output logic[7:0] rx_data_out
);

    

    logic rx_filtered;

    Low_Pass_Filter lpf1(
        .sig_filter(rx_filtered),	
	    .signal(rx),	
	    .r_LPF_threshold(r_LPF_threshold),  //	Unit : 0.08us  /// 2^3 = 8,  r_LPF_threshold=0 => By Pass
	    .clk(clk), 
	    .reset(rst)
    );

    logic rx_filtered_neg_edge;

    NEG_EDGE_DETECTOR ned1(
        .clk(clk), // clock input
        .reset(reset), // reset input
        .detect_signal(rx_filtered), // input signal
        .edge_detected(rx_filtered_neg_edge)
    );


    typedef enum  { START, WAIT, RECEIVING, FINISH } state_t;
    state_t current_state, next_state;

    //logic rx_finish;
    logic shift_rx_data;
    logic[7:0] rx_data;

    //assign rx_data_out = rx_data;
    logic load_data_debug;

    logic[31:0] counter;
    logic counter_reset;
    logic counter_count;

    logic[5:0] bit_counter;
    logic bit_counter_reset;
    logic bit_counter_count;

    always_ff@(posedge clk, posedge rst) begin
        if(rst) begin
            current_state <= START;
            counter <= 0;
            bit_counter <= 0;
            rx_data <= 8'b0;
            rx_data_out <= 8'b0;
        end
        else begin
            current_state <= next_state;

            if(load_data_debug) rx_data_out <= {rx_filtered, rx_data[7:1]};

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

            if(shift_rx_data) begin
                rx_data <= {rx_filtered, rx_data[7:1]};
            end

        end
    end


    always_comb begin : fsm
        //default
        next_state = current_state;
        counter_count = 0;
        counter_reset = 0;
        rx_finish = 0;
        shift_rx_data = 0;
        bit_counter_count = 0;
        bit_counter_reset = 0;
        load_data_debug = 0;

        case (current_state)
            START: begin
                next_state = WAIT;
            end
            WAIT: begin
                if(rx_filtered_neg_edge) begin
                    next_state = RECEIVING;
                    counter_reset = 1;
                    bit_counter_reset = 1;
                end
            end
            RECEIVING: begin
                counter_count = 1;
                if(bit_counter == 0 && counter == 1953) begin //1302+651=1953
                    counter_reset = 1;
                    bit_counter_count = 1;
                    shift_rx_data = 1;
                end else if(bit_counter > 0 && bit_counter <= 6 && counter == 1302) begin 
                    counter_reset = 1;
                    bit_counter_count = 1;
                    shift_rx_data = 1;
                end else if(bit_counter == 7 && counter == 1302) begin
                    counter_reset = 1;
                    shift_rx_data = 1;
                    next_state = FINISH;
                    load_data_debug = 1;
                end
            end
            FINISH: begin
                rx_finish = 1;
                next_state = WAIT;
            end 
        endcase
    end




endmodule