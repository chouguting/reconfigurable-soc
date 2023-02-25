library verilog;
use verilog.vl_types.all;
entity ROM is
    port(
        Rom_data_out    : out    vl_logic_vector(3 downto 0);
        Rom_addr_in     : in     vl_logic_vector(2 downto 0)
    );
end ROM;
