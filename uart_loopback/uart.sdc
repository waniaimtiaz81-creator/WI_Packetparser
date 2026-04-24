# Create Clock constraint (50 MHz = 20ns period)
create_clock -name {clk} -period 20.000 [get_ports {clk}]

# Automatically constrain internal paths
derive_pll_clocks
derive_clock_uncertainty