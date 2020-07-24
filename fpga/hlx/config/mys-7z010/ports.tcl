
### RGB LED
create_bd_port -dir O -from 2 -to 0 rgb_led_o

### DIP Switch
create_bd_port -dir I -from 3 -to 0 dip_sw_i

### Beeper
create_bd_port -dir O beeper_o

### Expansion connector on IO cape
create_bd_port -dir IO -from 17 -to 0 cape_p_io
create_bd_port -dir IO -from 17 -to 0 cape_n_io
