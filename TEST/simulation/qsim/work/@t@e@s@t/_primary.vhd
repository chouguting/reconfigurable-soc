library verilog;
use verilog.vl_types.all;
entity TEST is
    port(
        a               : in     vl_logic;
        b               : in     vl_logic;
        result          : out    vl_logic
    );
end TEST;
