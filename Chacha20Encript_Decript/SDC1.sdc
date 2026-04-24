# 10ns ka matlab hai 100MHz. Agar ye fail ho to isay 20ns (50MHz) kar dein.
create_clock -name clk -period 20.000 [get_ports {clk}]

# Automate clock uncertainty (Quartus ko jitter handle karne mein madad milti hai)
derive_clock_uncertainty