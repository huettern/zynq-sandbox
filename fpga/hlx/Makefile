# run 'make' to build everything
# 
# Other targets:
# 	make cores
# 		Packages the IP cores
# 	make TOP=top_tb sim
# 		Run ghdl simulation

# Project name
NAME = pitaya-min

################################################################################
# Build directory
BUILD = build

# Cores to build in the ./cores directory
CORES = impulse_generator_v1_0

# Command line tools
VIVADO = vivado -log build/log.log -journal build/journal.log -mode batch
RM = rm -rf

# FPGA Part number
PART ?= xc7z020clg484-1
include projects/$(NAME)/Makefile.make

################################################################################
# if make is killed or interrupted during the execution of their recipes, 
# the target is not deleted
.PRECIOUS: $(BUILD)/cores/% $(BUILD)/%.xpr $(BUILD)/%.bit
.PHONY: all bit cores clean-cores project clean-project flash sim clean-sim clean impl flashqspi hw-export

all: bit

#
# Bit file
# 
bit: $(BUILD)/$(NAME).bit

# Synth and Impl only
impl: $(BUILD)/projects/$(NAME).runs/impl_1

# Synth only
synth: $(BUILD)/projects/$(NAME).runs/synth_1

# HW def
hw-export: $(BUILD)/$(NAME).sdk/system_wrapper.hdf

#
# Project
# Depends on project sources and cores
#
project: $(addprefix $(BUILD)/cores/, $(CORES)) $(addprefix $(BUILD)/projects/, $(NAME).xpr) hw-export

clean-project:
	$(RM) $(BUILD)/projects/$(NAME)*

$(BUILD)/projects/$(NAME).xpr: projects/$(NAME)/*.tcl
	mkdir -p $(@D)
	$(VIVADO) -source scripts/project.tcl -tclargs $(NAME) $(BUILD)/projects/ $(BUILD)/cores/

#
# Cores
# Depend on core hdl sources
# 
cores: $(addprefix $(BUILD)/cores/, $(CORES))

clean-cores:
	$(RM) $(BUILD)/cores/*

$(BUILD)/cores/%: cores/%/core_config.tcl cores/%/hdl/*.vhd
	mkdir -p $(@D)
	cp cores/$*/*.xml $(BUILD)/cores/  || :
	$(VIVADO) -source scripts/core.tcl -tclargs $* $(PART) $(BUILD)/cores/


#
# Synth and impl
# 
$(BUILD)/projects/$(NAME).runs/impl_1: $(addprefix $(BUILD)/cores/, $(CORES)) $(BUILD)/projects/$(NAME).xpr
	$(VIVADO) -source scripts/synthimpl.tcl -tclargs $(NAME) $(BUILD)/projects/
#
# impl
# 
$(BUILD)/projects/$(NAME).runs/synth_1: $(addprefix $(BUILD)/cores/, $(CORES)) $(BUILD)/projects/$(NAME).xpr
	$(VIVADO) -source scripts/synth.tcl -tclargs $(NAME) $(BUILD)/projects/

#
# Bitstream
# Depends on the project tcl and cores
# This synthesizes and implements the design
# 
$(BUILD)/$(NAME).bit: $(addprefix $(BUILD)/cores/, $(CORES)) $(BUILD)/projects/$(NAME).xpr $(BUILD)/projects/$(NAME).runs/impl_1
	mkdir -p $(@D)
	$(VIVADO) -source scripts/bitstream.tcl -tclargs $(NAME) $(BUILD)/projects/ $(BUILD)/

#
# Flash
# 
flash: $(BUILD)/$(NAME).bit
	$(VIVADO) -source scripts/flash.tcl -tclargs $(NAME) $(BUILD)/projects/ $(BUILD)/

#
# Flash QSPI
# 
flashqspi: $(BUILD)/$(NAME).bit
	$(VIVADO) -source scripts/flashqspi.tcl -tclargs $(NAME) $(BUILD)/projects/ $(BUILD)/

# HW export
$(BUILD)/$(NAME).sdk/system_wrapper.hdf: $(addprefix $(BUILD)/cores/, $(CORES)) $(BUILD)/projects/$(NAME).xpr
	$(VIVADO) -source scripts/export_hw.tcl -tclargs $(NAME) $(BUILD)/projects/ $(BUILD)/

#
# clean
# 
clean:
	$(RM) $(BUILD)
	$(RM) vivado*.jou vivado*.log