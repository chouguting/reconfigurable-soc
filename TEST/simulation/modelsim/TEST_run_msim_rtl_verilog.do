transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/choug/fpgaProjects/reconfigurable-soc/TEST {C:/Users/choug/fpgaProjects/reconfigurable-soc/TEST/TEST.sv}

