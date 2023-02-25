library verilog;
use verilog.vl_types.all;
entity student_id is
    port(
        clk_50M         : in     vl_logic;
        reset           : in     vl_logic;
        reset_div       : in     vl_logic;
        \out\           : out    vl_logic_vector(6 downto 0)
    );
end student_id;
