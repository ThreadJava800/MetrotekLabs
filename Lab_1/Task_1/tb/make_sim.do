vlog -sv ../rtl/serializer.sv
vlog -sv ../tb/serializer_tb.sv

vsim -c work.serializer_tb

add log -r *
add wave -r *

run 1500