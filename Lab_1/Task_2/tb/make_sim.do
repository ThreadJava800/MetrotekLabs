vlog -sv ../rtl/deserializer.sv
vlog -sv ../tb/deserializer_tb.sv

vsim -c work.deserializer_tb

add log -r *
add wave -r *

run 12000