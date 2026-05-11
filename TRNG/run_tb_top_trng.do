# Clean old work library (optional)
if {[file exists work]} {
    vdel -lib work -all
}

vlib work

vlog -sv clk_divider.v          
vlog -sv dff.v                   
vlog -sv shift_register.v      
vlog -sv top_trng.sv             
vlog -sv comb_d.sv    
vlog -sv comb_d_without_von.sv
vlog -sv ro_simulation.sv                    
vlog -sv vonneuman_corrector.v  

vlog -sv tb_top_trng.sv 
vsim -novopt tb_top_trng

# vsim work.tb_top_trng
# add wave *
do wave_tb_top_trng.do
run -all
