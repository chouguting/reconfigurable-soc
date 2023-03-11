transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/choug/fpgaProjects/reconfigurable-soc/LAB2/counterPlusRegister \
{C:/Users/choug/fpgaProjects/reconfigurable-soc/LAB2/counterPlusRegister/counterPlusRegister.sv}

vlog -sv -work work +incdir+C:/Users/choug/fpgaProjects/reconfigurable-soc/LAB2/counterPlusRegister \
{C:/Users/choug/fpgaProjects/reconfigurable-soc/LAB2/counterPlusRegister/counterPlusRegister_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L \
cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  counterPlusRegister_tb

add wave *
add wave -position end  sim:/counterPlusRegister_tb/cpr/cnt_1
add wave -position end  sim:/counterPlusRegister_tb/cpr/cnt_2

view structure
view signals
run -all
