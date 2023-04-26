onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TOP LEVEL INPUTS}
add wave -noupdate -divider LPF
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/rs232_1/rx
add wave -noupdate /testbench/rs232_1/rx_filter
add wave -noupdate -divider RX
add wave -noupdate -radix hexadecimal /testbench/send_data
add wave -noupdate /testbench/rs232_1/rs232_rx_1/rx
add wave -noupdate /testbench/rs232_1/rs232_rx_1/bit_flag
add wave -noupdate /testbench/rs232_1/rs232_rx_1/rx_finish
add wave -noupdate -divider Package
add wave -noupdate -divider TX
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {54920233 ps} 0} {{Cursor 2} {12982041980 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {717942750 ps}
