# Display name of the core
set display_name {Video TPG}

# Set top module
set_property top axisv_tpg [current_fileset]

# set core
set core [ipx::current_core]

# set core properties
set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core
set_property VERSION 1.0 $core

# core_parameter AXIS_TDATA_WIDTH {AXIS TDATA WIDTH} {Width of the M_AXIS and S_AXIS data buses.}
# core_parameter AXIS_TDATA_SIGNED {AXIS TDATA SIGNED} {If TRUE, the M_AXIS and S_AXIS data are signed values.}

# define clock and reset
set clk aclk_i
ipx::infer_bus_interface $clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

set rst rst_ni
ipx::infer_bus_interface $rst xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

# Axi master interface
set bus [ipx::get_bus_interfaces -of_objects $core m_axis]
set_property NAME M_AXIS $bus
set_property INTERFACE_MODE master $bus
ipx::associate_bus_interfaces -busif M_AXIS -clock aclk_i [ipx::current_core]
