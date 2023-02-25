library verilog;
use verilog.vl_types.all;
entity frequency_divider is
    generic(
        n               : integer := 24
    );
    port(
        clk_after       : out    vl_logic;
        clk             : in     vl_logic;
        reset_fd        : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of n : constant is 1;
end frequency_divider;
