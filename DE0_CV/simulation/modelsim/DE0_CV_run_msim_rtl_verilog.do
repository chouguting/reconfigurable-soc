transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/User/Desktop/DE0_CV/design {C:/Users/User/Desktop/DE0_CV/design/DE0_CV.v}
vlog -sv -work work +incdir+C:/Users/User/Desktop/DE0_CV/design {C:/Users/User/Desktop/DE0_CV/design/student_id.sv}
vlog -sv -work work +incdir+C:/Users/User/Desktop/DE0_CV/design {C:/Users/User/Desktop/DE0_CV/design/seven_segment.sv}
vlog -sv -work work +incdir+C:/Users/User/Desktop/DE0_CV/design {C:/Users/User/Desktop/DE0_CV/design/ROM.sv}
vlog -sv -work work +incdir+C:/Users/User/Desktop/DE0_CV/design {C:/Users/User/Desktop/DE0_CV/design/frequency_divider.sv}
