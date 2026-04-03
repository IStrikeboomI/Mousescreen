create_clock -name clock -period 20 -waveform {5 10} [get_ports{clk}]
report_max_frequency -mod_ins {pll_inst}