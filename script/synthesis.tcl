set_svf top.svf

# Import Design
# read_sverilog ../src/top.sv
analyze -format sverilog ../src/cpu_wrap.dc.sv
elaborate cpu_wrap
current_design [get_designs top]
link

source -echo -verbose ../script/DC.sdc

# Compile
set high_fanout_net_threshold 0

uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

set_structure -timing true

compile -map_effort high
compile -map_effort high -inc

# Output
current_design [get_designs top]

remove_unconnected_ports -blast_buses [get_cells -hierarchical *]

set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed {a-z A-Z 0-9 _}   -max_length 255 -type cell
define_name_rules name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule


#write_sdf LEDDC.sdf
write -format ddc -hierarchy -output top.ddc
write_file -format verilog -hierarchy    -output         ../syn/top_syn.v
write_sdf -version 2.0 -context verilog  -load_delay net ../syn/top_syn.sdf
write_sdc -version 2.0 top_syn.sdc
report_area   > area.log
report_timing > timing.log
report_power  > power.log
report_qor    > top.qor
