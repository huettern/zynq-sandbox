# ================================================================================
# flash.tcl
# 
# Configures the FPGA with the provided bitstream
# 
# by Noah Huetter <noahhuetter@gmail.com>
# ================================================================================
# Usage
# vivado -nolog -nojournal -mode batch -source \
#   scripts/flash.tcl -tclargs project_name project_location bit_location
# ================================================================================
# @Author: Noah Huetter
# @Date:   2017-11-24 15:21:33
# @Last Modified by:   Noah Huetter
# @Last Modified time: 2019-04-05 12:21:22

set project_name [lindex $argv 0]
set project_location [lindex $argv 1]
set bit_location [lindex $argv 2]

# Get project specific settings
source projects/$project_name/project_config.tcl

open_project $project_location/$project_name.xpr

# open hw
open_hw
connect_hw_server
open_hw_target

# Add debug probes file if exists
if {[file exists $bit_location/$project_name.ltx]} {
    set_property PROBES.FILE $bit_location/$project_name.ltx [get_hw_devices $hw_device]
    set_property FULL_PROBES.FILE $bit_location/$project_name.ltx [get_hw_devices $hw_device]
}

# Add bit file
set_property PROGRAM.FILE $bit_location/$project_name.bit [get_hw_devices $hw_device]

# program hw
program_hw_devices [get_hw_devices $hw_device]
refresh_hw_device [lindex [get_hw_devices $hw_device] 0]

close_project
