# ================================================================================
# build_one.tcl
# 
# Synthesizes one single design file
# 
# by Noah Huetter <noahhuetter@gmail.com>
# ================================================================================

# ================================================================================
# Settings
set part_name "xc7z020clg484-1"
set file "cores/core_name/hdl/file.vhd"
set constraints "cores/core_name/constraints/test.xdc"
set top "top"

# ================================================================================

# Create project
create_project -force tmp_proj build/tmp_proj

# Project settings
set_property target_language VHDL [current_project]

# read all design files
# read_verilog -sv ./file.sv
read_vhdl -vhdl2008 -verbose $file
# read_ip ./file.xci

# read constraints
read_xdc $constraints
# read_xdc ../rtl/pblocks.xdc
# read_xdc ../rtl/pins.xdc

# Synthesize Design
synth_design -top $top -part $part_name

# Opt Design 
# opt_design

# Place Design
# place_design 

# Route Design
# route_design

# Write out bitfile
# write_debug_probes -force build/tmp_proj/tmp_proj.ltx
# write_bitstream -force build/tmp_proj/tmp_proj.bit
