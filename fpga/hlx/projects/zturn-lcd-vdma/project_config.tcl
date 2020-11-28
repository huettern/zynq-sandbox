# @Author: Noah Huetter
# @Date:   2019-04-05 11:22:56
# @Last Modified by:   Noah Huetter
# @Last Modified time: 2020-07-24 21:14:23

# Define config directory for hardware
set hw_config "mys-7z010"
source config/$hw_config/board.tcl

# Define what minimum vivado version is required
set vivado_version "2020.1"

#
# @brief      Is called after project is generated using sctipt
#
# @param      project_name   The project name
#
proc post_proj_gen {project_name} {
  set obj [current_project]

  # Set some project settings
  set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
  set_property -name "enable_vhdl_2008" -value "1" -objects $obj
  set_property -name "ip_cache_permissions" -value "read write" -objects $obj
  set_property -name "target_language" -value "Verilog" -objects $obj

  # Faster flow
	set_property strategy Flow_RuntimeOptimized [get_runs synth_1]
	set_property strategy Flow_RuntimeOptimized [get_runs impl_1]
}
