module NEG_EDGE_DETECTOR(
    input logic clk, // clock input
    input logic reset, // reset input
    input logic detect_signal, // input signal
    output logic edge_detected
);

    logic prev_detect_signal; // previous value of detect_signal
    logic prev_prev_detect_signal; // previous value of prev_detect_signal

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            prev_detect_signal <= 1'b1;
            prev_prev_detect_signal <= 1'b1;
            edge_detected <= 1'b0;
        end else begin
            {prev_prev_detect_signal, prev_detect_signal} <= {prev_detect_signal, detect_signal};
            edge_detected <= (prev_prev_detect_signal==1'b1) & (prev_detect_signal==1'b0);
        end
    end
endmodule