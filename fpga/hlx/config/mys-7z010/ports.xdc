
### RGB LED
set_property IOSTANDARD LVCMOS33 [get_ports {rgb_led_o[*]}]
set_property SLEW SLOW [get_ports {rgb_led_o[*]}]
set_property DRIVE 4 [get_ports {rgb_led_o[*]}]

set_property PACKAGE_PIN R14 [get_ports {rgb_led_o[0]}]
set_property PACKAGE_PIN Y16 [get_ports {rgb_led_o[1]}]
set_property PACKAGE_PIN Y17 [get_ports {rgb_led_o[2]}]

### DIP Switch
set_property IOSTANDARD LVCMOS33 [get_ports {dip_sw_i[*]}]

set_property PACKAGE_PIN R19 [get_ports {dip_sw_i[0]}]
set_property PACKAGE_PIN T19 [get_ports {dip_sw_i[1]}]
set_property PACKAGE_PIN G14 [get_ports {dip_sw_i[2]}]
set_property PACKAGE_PIN J15 [get_ports {dip_sw_i[3]}]

### Beeper
create_bd_port -dir O beeper_o
set_property IOSTANDARD LVCMOS33 [get_ports beeper_o]
set_property SLEW SLOW [get_ports beeper_o]
set_property DRIVE 4 [get_ports beeper_o]
set_property PACKAGE_PIN P18 [get_ports beeper_o]

### Expansion connector on IO cape
set_property IOSTANDARD LVCMOS33 [get_ports {cape_p_io[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cape_n_io[*]}]
set_property SLEW FAST [get_ports {cape_p_io[*]}]
set_property SLEW FAST [get_ports {cape_n_io[*]}]
set_property DRIVE 8 [get_ports {cape_p_io[*]}]
set_property DRIVE 8 [get_ports {cape_n_io[*]}]


set_property PACKAGE_PIN M18 [get_ports {lcd_dat_o_0[0]}]
set_property PACKAGE_PIN M19 [get_ports {lcd_dat_o_0[1]}]
set_property PACKAGE_PIN M20 [get_ports {lcd_dat_o_0[2]}]
set_property PACKAGE_PIN F16 [get_ports {lcd_dat_o_0[3]}]
set_property PACKAGE_PIN F17 [get_ports {lcd_dat_o_0[4]}]
set_property PACKAGE_PIN E18 [get_ports {lcd_dat_o_0[5]}]
set_property PACKAGE_PIN E19 [get_ports {lcd_dat_o_0[6]}]
set_property PACKAGE_PIN D19 [get_ports {lcd_dat_o_0[7]}]
set_property PACKAGE_PIN D20 [get_ports {lcd_dat_o_0[8]}]
set_property PACKAGE_PIN E17 [get_ports {lcd_dat_o_0[9]}]
set_property PACKAGE_PIN D18 [get_ports {lcd_dat_o_0[10]}]
set_property PACKAGE_PIN B19 [get_ports {lcd_dat_o_0[11]}]
set_property PACKAGE_PIN L17 [get_ports {lcd_dat_o_0[12]}]
set_property PACKAGE_PIN K19 [get_ports {lcd_dat_o_0[13]}]
set_property PACKAGE_PIN J19 [get_ports {lcd_dat_o_0[14]}]
set_property PACKAGE_PIN L19 [get_ports {lcd_dat_o_0[15]}]
set_property PACKAGE_PIN L20 [get_ports {lcd_dat_o_0[16]}]
set_property PACKAGE_PIN M17 [get_ports {lcd_dat_o_0[17]}]
set_property PACKAGE_PIN A20 [get_ports enable_o_0]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_clk}]
set_property SLEW FAST [get_ports {lcd_clk}]
set_property DRIVE 8 [get_ports {lcd_clk}]
set_property PACKAGE_PIN L16 [get_ports {lcd_clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_dat_o_0[*]}]
set_property SLEW FAST [get_ports {lcd_dat_o_0[*]}]
set_property DRIVE 8 [get_ports {lcd_dat_o_0[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports enable_o_0]
set_property SLEW FAST [get_ports enable_o_0]
set_property DRIVE 8 [get_ports enable_o_0]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
