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


vlog "C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/pll_sim/pll.vo"

vlog -vlog01compat -work work +incdir+C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design {C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design/fifo.v}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design {C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design/PATTERN_GENERATOR.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design {C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design/REGISTER_FILE.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design {C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design/SPI_tx.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design {C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design/SPI_rx.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design {C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design/EDGE_DETECTOR.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design {C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design/SPI.sv}
vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design {C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/design/DE0_CV.sv}

vlog -sv -work work +incdir+C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/simulation/tb {C:/Users/choug/reconfigurable-soc/FINAL/SPI_PATTERN_GENERATOR/DE0_CV_SPI/simulation/tb/tb_spi.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_spi

add wave *
view structure
view signals
run -all
