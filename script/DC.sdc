create_clock -name clk -period 10 [get_ports clk]
set_dont_touch_network      [all_clocks]
set_fix_hold                [all_clocks]
set_clock_uncertainty  0.1  [all_clocks]
set_clock_latency      1.0  [all_clocks]
set_ideal_network           [get_ports clk]

set_input_delay  -max 1.0   -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay  -min 0.0   -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay -max 1.0   -clock clk [all_outputs]
set_output_delay -min 0.0   -clock clk [all_outputs]

set_drive        0.1   [all_inputs]
set_load         0.1   [all_outputs]

set_operating_conditions -max_library fsa0m_a_generic_core_ss1p62v125c -max WCCOM -min_library fsa0m_a_generic_core_ff1p98vm40c -min BCCOM
set auto_wire_load_selection

set_max_fanout 6 [all_inputs]
