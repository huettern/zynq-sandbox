# Display name of the core
set display_name {Sample and Hold}

# Set top module
set_property top axis_sample_hold_v1_0 [current_fileset]

# set core
set core [ipx::current_core]

# set core properties
set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core
set_property VERSION 1.0 $core
