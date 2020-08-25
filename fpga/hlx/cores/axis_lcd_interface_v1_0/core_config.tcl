# Display name of the core
set display_name {LCD Interface}

# Set top module
set_property top lcd_top [current_fileset]

# set core
set core [ipx::current_core]

# set core properties
set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core
set_property VERSION 1.0 $core


# define clock and reset
set clk aclk_i
ipx::infer_bus_interface $clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

set rst rst_ni
ipx::infer_bus_interface $rst xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

# Axi master interface
set bus [ipx::get_bus_interfaces -of_objects $core s_axis]
set_property NAME M_AXIS $bus
set_property INTERFACE_MODE slave $bus
ipx::associate_bus_interfaces -busif S_AXIS -clock aclk_i [ipx::current_core]

