# Clean old work library (optional)
if {[file exists work]} {
    vdel -lib work -all
}

vlib work

vlog -sv ../rtl/top_module.sv
vlog -sv ../rtl/trng_to_chacha.sv
vlog -sv ../rtl/trng_or_uart_to_chacha.sv

vlog -sv ../../TRNG/dff.v                   
vlog -sv ../../TRNG/shift_register.v      
vlog -sv ../../TRNG/comb_d.sv    
vlog -sv ../../TRNG/comb_d_without_von.sv
vlog -sv ../../TRNG/ro.sv                    
vlog -sv ../../TRNG/vonneuman_corrector.v 

vlog -sv ../../uart_plus_chacha_integration/baud_gen.v
vlog -sv ../../uart_plus_chacha_integration/uart_rx.v
vlog -sv ../../uart_plus_chacha_integration/uart_rx_to_chacha.sv
vlog -sv ../../uart_plus_chacha_integration/chacha_core.v
vlog -sv ../../uart_plus_chacha_integration/chacha_qr.v
vlog -sv ../../uart_plus_chacha_integration/chacha_to_uart_tx.sv
vlog -sv ../../uart_plus_chacha_integration/uart_tx.v

vlog -sv tb_top_module.sv 
vsim -novopt tb_top_module

# vsim work.tb_top_module
# add wave *
do wave_tb_top_module.do
run -all
