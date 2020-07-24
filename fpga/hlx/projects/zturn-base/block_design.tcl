# Create processing_system7
cell xilinx.com:ip:processing_system7 ps_0 {} {}
# apply default ps settings
source config/mys-7z010/ps-config.tcl
set_property -dict [apply_preset ps0] [get_bd_cells /ps_0]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Connections

# Connect GP0 port clock to fclk0
connect_bd_net [get_bd_pins ps_0/M_AXI_GP0_ACLK] [get_bd_pins ps_0/FCLK_CLK0]