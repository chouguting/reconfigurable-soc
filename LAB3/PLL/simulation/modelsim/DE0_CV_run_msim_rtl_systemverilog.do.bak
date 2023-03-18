transcript on
if ![file isdirectory DE0_CV_iputf_libs] {
	file mkdir DE0_CV_iputf_libs
}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

###### Libraries for IPUTF cores 
###### End libraries for IPUTF cores 
###### MIF file copy and HDL compilation commands for IPUTF cores 


vlog "C:/Users/choug/reconfigurable-soc/LAB3/PLL/PLL_sim/PLL.vo"

vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB3/PLL/design {C:/Users/choug/reconfigurable-soc/LAB3/PLL/design/DE0_CV.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB3/PLL/design {C:/Users/choug/reconfigurable-soc/LAB3/PLL/design/sub_4bit.sv}

vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/LAB3/PLL/design {C:/Users/choug/reconfigurable-soc/LAB3/PLL/design/PLL_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  PLL_tb

add wave *
view structure
view signals
run -all
