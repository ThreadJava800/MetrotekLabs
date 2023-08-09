vlog -sv ../rtl/priority_encoder.sv
vlog -sv ../tb/priority_encoder_tb.sv

vsim -c work.priority_encoder_tb

add log -r *
add wave -r *

run -all