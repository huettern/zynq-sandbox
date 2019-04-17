# ================================================================================
# export_hw.tcl
# 
# Export hardware for SDK
# 
# by Noah Huetter <noahhuetter@gmail.com>
# ================================================================================
# Usage
# vivado -nolog -nojournal -mode batch -source \
#   scripts/export_hw.tcl -tclargs project_name project_location build_location
# ================================================================================
set project_name [lindex $argv 0]
set project_location [lindex $argv 1]
set build_location [lindex $argv 2]

open_project $project_location/$project_name.xpr

# Get board design and generate output products
set bd_path $build_location/$project_name.srcs/sources_1/bd/system
generate_target all [get_files $bd_path/system.bd]

# Export IP user files
export_ip_user_files -of_objects [get_files $bd_path/system.bd] -no_script -sync -force -quiet

# Write hardware definition
file mkdir $build_location/$project_name.sdk
write_hwdef -force  -file $build_location/$project_name.sdk/system_wrapper.hdf

close_project