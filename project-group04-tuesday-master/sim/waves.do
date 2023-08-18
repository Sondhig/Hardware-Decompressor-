# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -uns UUT/UART_timer

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data


#add wave -divider -height 10 {Milestone 1}
#add wave -dec UUT//M1_unit/count
#add wave -bin UUT/M1_unit/State
#add wave -dec UUT/M1_unit/U_acc
#add wave -unsigned UUT/M1_unit/U_even
#add wave -dec UUT/M1_unit/U_odd
#add wave -dec UUT/M1_unit/V_acc
#add wave -unsigned UUT/M1_unit/V_even
#add wave -dec UUT/M1_unit/V_odd
#add wave -dec UUT/M1_unit/Y_even
#add wave -dec UUT/M1_unit/Y_odd
#add wave -dec UUT/M1_unit/Red_even
#add wave -dec UUT/M1_unit/Green_even
#add wave -dec UUT/M1_unit/Blue_even
#add wave -dec UUT/M1_unit/Red_odd
#add wave -dec UUT/M1_unit/Green_odd
#add wave -dec UUT/M1_unit/Blue_odd
#add wave -unsigned UUT/M1_unit/clipRedO
#add wave -unsigned UUT/M1_unit/clipRedE
#add wave -hex UUT/M1_unit/V1
#add wave -hex UUT/M1_unit/V2
#add wave -hex UUT/M1_unit/V3
#add wave -hex UUT/M1_unit/V4
#add wave -hex UUT/M1_unit/V5
#add wave -hex UUT/M1_unit/V6
#add wave -hex UUT/M1_unit/Vtemp
#add wave -hex UUT/M1_unit/U1
#add wave -hex UUT/M1_unit/U2
#add wave -hex UUT/M1_unit/U3
#add wave -hex UUT/M1_unit/U4
#add wave -hex UUT/M1_unit/U5
#add wave -hex UUT/M1_unit/U6
#add wave -hex UUT/M1_unit/Utemp

add wave -divider -height 10 {Milestone 2}
add wave  UUT/M2_unit/State
add wave -decimal  UUT/M2_unit/rb
add wave -decimal  UUT/M2_unit/cb
add wave -decimal  UUT/M2_unit/ra
add wave -decimal  UUT/M2_unit/ca
add wave -decimal  UUT/M2_unit/counter
add wave -decimal  UUT/M2_unit/c_counter
add wave -bin  UUT/M2_unit/start
add wave -uns  UUT/write_address_a
add wave -uns  UUT/write_data_a
add wave -uns  UUT/read_data_a
add wave -uns  UUT/M2_unit/acc1
add wave -uns  UUT/M2_unit/acc2
add wave -uns  UUT/M2_unit/acc3
add wave -uns  UUT/M2_unit/acc4
#add wave -uns  UUT/M2_unit/op1
#add wave -uns  UUT/M2_unit/op2
#add wave -uns  UUT/M2_unit/op3
#add wave -uns  UUT/M2_unit/op4
#add wave -uns  UUT/M2_unit/op5
add wave -uns  UUT/write_address_b
add wave -uns  UUT/write_data_b
add wave -uns  UUT/read_data_b
add wave -uns  UUT/write_address_a_2
add wave -uns  UUT/write_data_a_2
add wave -uns  UUT/read_data_a_2
add wave -uns  UUT/write_address_b_2
add wave -uns  UUT/write_data_b_2
add wave -uns  UUT/read_data_b_2
add wave -uns  UUT/write_address_a_3
add wave -uns  UUT/write_data_a_3
add wave -uns  UUT/read_data_a_3
add wave -uns  UUT/write_address_b_3
add wave -uns  UUT/write_data_b_3
add wave -uns  UUT/read_data_b_3

#add wave -divider -height 10 {VGA signals}
#add wave -bin UUT/VGA_unit/VGA_HSYNC_O
#add wave -bin UUT/VGA_unit/VGA_VSYNC_O
#add wave -uns UUT/VGA_unit/pixel_X_pos
#add wave -uns UUT/VGA_unit/pixel_Y_pos
#add wave -hex UUT/VGA_unit/VGA_red
#add wave -hex UUT/VGA_unit/VGA_green
#add wave -hex UUT/VGA_unit/VGA_blue

