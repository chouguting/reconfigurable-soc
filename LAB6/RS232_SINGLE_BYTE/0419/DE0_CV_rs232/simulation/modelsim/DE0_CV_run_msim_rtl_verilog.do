transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB6/RS232_SINGLE_BYTE/0419/DE0_CV_rs232/design {C:/Users/choug/reconfigurable-soc/LAB6/RS232_SINGLE_BYTE/0419/DE0_CV_rs232/design/RS232_SINGLE_BYTE.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB6/RS232_SINGLE_BYTE/0419/DE0_CV_rs232/design {C:/Users/choug/reconfigurable-soc/LAB6/RS232_SINGLE_BYTE/0419/DE0_CV_rs232/design/NEG_EDGE_DETECTOR.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB6/RS232_SINGLE_BYTE/0419/DE0_CV_rs232/design {C:/Users/choug/reconfigurable-soc/LAB6/RS232_SINGLE_BYTE/0419/DE0_CV_rs232/design/Low_Pass_Filter.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB6/RS232_SINGLE_BYTE/0419/DE0_CV_rs232/design {C:/Users/choug/reconfigurable-soc/LAB6/RS232_SINGLE_BYTE/0419/DE0_CV_rs232/design/DE0_CV.sv}

vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB6/RS232_SINGLE_BYTE/0419/DE0_CV_rs232/simulation/tb {C:/Users/choug/reconfigurable-soc/LAB6/RS232_SINGLE_BYTE/0419/DE0_CV_rs232/simulation/tb/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
