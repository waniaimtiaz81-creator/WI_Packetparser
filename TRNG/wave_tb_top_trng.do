onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_top_trng/clk
add wave -noupdate -radix hexadecimal /tb_top_trng/en
add wave -noupdate -radix hexadecimal /tb_top_trng/rst
add wave -noupdate -radix hexadecimal /tb_top_trng/load
add wave -noupdate -radix hexadecimal /tb_top_trng/shift_reg
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/clk
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/en
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/rst
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/load
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/shift_reg
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/out_pre
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/out
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/shift_reg_out
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/i_ro_0/ODD_NO
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/i_ro_0/en
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/i_ro_0/out
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/i_ro_0/no
add wave -noupdate -divider comb_d
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/clk
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/en
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/rst
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/load
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/shift_reg
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/shift_reg_vld
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/out_pre
add wave -noupdate -radix hexadecimal /tb_top_trng/i_comb_d/out
add wave -noupdate -radix hexadecimal -childformat {{{/tb_top_trng/i_comb_d/shift_reg_out[31]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[30]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[29]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[28]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[27]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[26]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[25]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[24]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[23]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[22]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[21]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[20]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[19]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[18]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[17]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[16]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[15]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[14]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[13]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[12]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[11]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[10]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[9]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[8]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[7]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[6]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[5]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[4]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[3]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[2]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[1]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out[0]} -radix hexadecimal}} -subitemconfig {{/tb_top_trng/i_comb_d/shift_reg_out[31]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[30]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[29]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[28]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[27]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[26]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[25]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[24]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[23]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[22]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[21]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[20]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[19]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[18]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[17]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[16]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[15]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[14]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[13]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[12]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[11]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[10]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[9]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[8]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[7]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[6]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[5]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[4]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[3]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[2]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[1]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out[0]} {-radix hexadecimal}} /tb_top_trng/i_comb_d/shift_reg_out
add wave -noupdate -radix hexadecimal -childformat {{{/tb_top_trng/i_comb_d/shift_reg_out_vld[31]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[30]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[29]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[28]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[27]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[26]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[25]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[24]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[23]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[22]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[21]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[20]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[19]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[18]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[17]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[16]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[15]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[14]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[13]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[12]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[11]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[10]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[9]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[8]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[7]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[6]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[5]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[4]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[3]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[2]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[1]} -radix hexadecimal} {{/tb_top_trng/i_comb_d/shift_reg_out_vld[0]} -radix hexadecimal}} -subitemconfig {{/tb_top_trng/i_comb_d/shift_reg_out_vld[31]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[30]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[29]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[28]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[27]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[26]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[25]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[24]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[23]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[22]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[21]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[20]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[19]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[18]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[17]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[16]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[15]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[14]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[13]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[12]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[11]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[10]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[9]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[8]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[7]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[6]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[5]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[4]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[3]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[2]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[1]} {-radix hexadecimal} {/tb_top_trng/i_comb_d/shift_reg_out_vld[0]} {-radix hexadecimal}} /tb_top_trng/i_comb_d/shift_reg_out_vld
add wave -noupdate -divider {block 4}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/dff33/in}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/dff33/clk}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/dff33/outd}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/dff33/out}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/vnc/A}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/vnc/B}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/vnc/F}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/vnc/valid}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/vnc/xor_out}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/i_shift_register/clk}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/i_shift_register/rst}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/i_shift_register/load}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/i_shift_register/processed_bit_valid}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/i_shift_register/processed_bit}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/i_shift_register/shift_reg_out}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/i_shift_register/shift_reg_out_vld}
add wave -noupdate -radix hexadecimal {/tb_top_trng/i_comb_d/genblk1[4]/i_shift_register/bit_count}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12015000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 285
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
WaveRestoreZoom {11917583 ps} {12152021 ps}
