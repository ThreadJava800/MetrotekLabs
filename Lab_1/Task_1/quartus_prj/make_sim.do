vlog -sv ../rtl/serializer.sv
vlog -sv ../tb/serializer_tb.sv

vsim -gui -l /dev/null work.serializer_tb

add wave -r *