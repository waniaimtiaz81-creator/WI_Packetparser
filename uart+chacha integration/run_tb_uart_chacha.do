# Clean old work library (optional)
if {[file exists work]} {
    vdel -lib work -all
}

vlib work

vlog -sv uart_tx.v
vlog -sv baud_gen.v
vlog -sv chacha.v
vlog -sv chacha_core.v
vlog -sv chacha_qr.v
vlog -sv tb_uart_chacha.v
vlog -sv uart_rx.v
vlog -sv uart_top.v
vlog -sv uart_tx.v
vlog -sv uart_rx_to_chacha.sv
vlog -sv chacha_to_uart_tx.sv

vlog -sv tb_uart_chacha.v 
vsim -novopt tb_uart_chacha

# vsim work.tb_uart_chacha
# add wave *
do wave_tb_uart_chacha.do
run -all
