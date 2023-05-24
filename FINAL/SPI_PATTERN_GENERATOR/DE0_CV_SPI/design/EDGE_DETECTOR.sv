module EDGE_DETECTOR(
    input logic clk, // clock input
    input logic reset, // reset input
    input logic detect_signal, // input signal
    output logic neg_edge_detected,
    output logic pos_edge_detected
);

    logic prev_detect_signal; // previous value of detect_signal
    logic prev_prev_detect_signal; // previous value of prev_detect_signal

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            prev_detect_signal <= 1'b1;
            prev_prev_detect_signal <= 1'b1;
            neg_edge_detected <= 1'b0;
            pos_edge_detected <= 1'b0;
        end else begin
            {prev_prev_detect_signal, prev_detect_signal} <= {prev_detect_signal, detect_signal};
            neg_edge_detected <= (prev_prev_detect_signal==1'b1) & (prev_detect_signal==1'b0);
            pos_edge_detected <= (prev_prev_detect_signal==1'b0) & (prev_detect_signal==1'b1);

        end
    end
endmodule