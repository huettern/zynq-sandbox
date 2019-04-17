
# ==============================================================================
# ENV
# ==============================================================================
PWD=$(shell pwd)

# ==============================================================================
# USER SETTINGS
# ==============================================================================
# HDL Language
TOPLEVEL_LANG ?= vhdl

# Set simulator
SIM = ghdl

# Sources
VHDL_SOURCES = $(PWD)/../hdl/impulse_generator.vhd

# Top level entity
TOPLEVEL = impulse_generator

# Test module name
MODULE = test_impulse_generator

# ==============================================================================
# cocotb
# ==============================================================================
# get cocotb location
COCOTB=$(PWD)/../../../../cocotb

GHDL_ARGS = --ieee=synopsys
SIM_ARGS  = --wave=$(TOPLEVEL).ghw
SIM_ARGS += --vcd=$(TOPLEVEL).vcd
COCOTB_ANSI_OUTPUT=0
COCOTB_REDUCED_LOG_FMT=1

# Invoke cocotb
include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
# ==============================================================================
