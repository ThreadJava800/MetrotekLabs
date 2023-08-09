vlog -sv ../rtl/bit_population_counter.sv
vlog -sv ../tb/bit_population_counter_tb.sv

vsim -c work.bit_population_counter_tb

add log -r *
add wave -r *

run -all