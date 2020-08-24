
# Default to verilog
TOPLEVEL_LANG ?= verilog

SIM = verilator
EXTRA_ARGS += --trace --trace-structs

PWD=$(shell pwd)

export PYTHONPATH := $(PWD)/../cosim:$(PYTHONPATH)

########################################
# for top
########################################

VERILOG_SOURCES  =  $(PWD)/../hdl/axisv_tpg.sv
TOPLEVEL = axisv_tpg
MODULE := test_tpg

include $(shell cocotb-config --makefiles)/Makefile.sim
