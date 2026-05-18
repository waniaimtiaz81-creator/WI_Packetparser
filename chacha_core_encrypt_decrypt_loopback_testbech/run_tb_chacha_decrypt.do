# Clean old work library (optional)
if {[file exists work]} {
    vdel -lib work -all
}

vlib work

vlog -sv ../uart_plus_chacha_integration/baud_gen.v
vlog -sv ../uart_plus_chacha_integration/uart_rx.v
vlog -sv ../uart_plus_chacha_integration/uart_rx_to_chacha.sv
vlog -sv ../uart_plus_chacha_integration/chacha_core.v
vlog -sv ../uart_plus_chacha_integration/chacha_qr.v
vlog -sv ../uart_plus_chacha_integration/chacha_to_uart_tx.sv
vlog -sv ../uart_plus_chacha_integration/uart_tx.v

vlog -sv tb_chacha_decrypt.sv 
vsim -novopt tb_chacha_decrypt

# vsim work.tb_chacha_decrypt
add wave *
# do wave_tb_chacha_decrypt.do
run -all
