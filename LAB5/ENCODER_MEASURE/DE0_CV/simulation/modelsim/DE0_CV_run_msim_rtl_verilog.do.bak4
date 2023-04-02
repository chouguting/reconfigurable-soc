transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB4/ENCODER_PERIOD/DE0_CV/design {C:/Users/choug/reconfigurable-soc/LAB4/ENCODER_PERIOD/DE0_CV/design/POS_EDGE_DETECTOR.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB4/ENCODER_PERIOD/DE0_CV/design {C:/Users/choug/reconfigurable-soc/LAB4/ENCODER_PERIOD/DE0_CV/design/Low_Pass_Filter_4ENC.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB4/ENCODER_PERIOD/DE0_CV/design {C:/Users/choug/reconfigurable-soc/LAB4/ENCODER_PERIOD/DE0_CV/design/ENCODER_PERIOD.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB4/ENCODER_PERIOD/DE0_CV/design {C:/Users/choug/reconfigurable-soc/LAB4/ENCODER_PERIOD/DE0_CV/design/DE0_CV.sv}

vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB4/ENCODER_PERIOD/DE0_CV/design {C:/Users/choug/reconfigurable-soc/LAB4/ENCODER_PERIOD/DE0_CV/design/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
