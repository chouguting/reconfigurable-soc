module REGISTER_FILE(
    input logic clk,
    input logic write_en,
    input logic read_en,
    input logic[7:0] address,
    input logic[15:0] data_in,
    output logic[15:0] data_out,
    output logic pg_control,
    output logic[15:0] pg_speed
);
    logic[15:0] register_file[255:0];

    always_ff @(posedge clk) begin
        if(write_en) begin
            register_file[address] <= data_in;
        end
        if(read_en) begin
            data_out <= register_file[address];
        end
    end

    assign pg_control = register_file[0][0];
    assign pg_speed = register_file[8'h7F];

endmodule