onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top_trng/clk
add wave -noupdate /tb_top_trng/en
add wave -noupdate /tb_top_trng/rst
add wave -noupdate /tb_top_trng/load
add wave -noupdate /tb_top_trng/shift_reg
add wave -noupdate /tb_top_trng/i_comb_d/clk
add wave -noupdate /tb_top_trng/i_comb_d/en
add wave -noupdate /tb_top_trng/i_comb_d/rst
add wave -noupdate /tb_top_trng/i_comb_d/load
add wave -noupdate /tb_top_trng/i_comb_d/shift_reg
add wave -noupdate /tb_top_trng/i_comb_d/out_pre
add wave -noupdate /tb_top_trng/i_comb_d/out
add wave -noupdate /tb_top_trng/i_comb_d/xor_
add wave -noupdate /tb_top_trng/i_comb_d/mux_in
add wave -noupdate /tb_top_trng/i_comb_d/prev_bit
add wave -noupdate /tb_top_trng/i_comb_d/mux_in_delayed
add wave -noupdate /tb_top_trng/i_comb_d/final_entropy
add wave -noupdate /tb_top_trng/i_comb_d/entropy_valid
add wave -noupdate /tb_top_trng/i_comb_d/shift_reg_out
add wave -noupdate /tb_top_trng/i_comb_d/i_ro_0/ODD_NO
add wave -noupdate /tb_top_trng/i_comb_d/i_ro_0/en
add wave -noupdate /tb_top_trng/i_comb_d/i_ro_0/out
add wave -noupdate /tb_top_trng/i_comb_d/i_ro_0/no
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8989 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 94
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {23095 ns}
