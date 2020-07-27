
# Default to verilog
TOPLEVEL_LANG ?= verilog

SIM = verilator
EXTRA_ARGS += --trace --trace-structs

PWD=$(shell pwd)

export PYTHONPATH := $(PWD)/../cosim:$(PYTHONPATH)

VERILOG_SOURCES  =  $(PWD)/../hdl/lcd_timing_generator.sv

TOPLEVEL = lcd_timing_generator

MODULE := test_timing_gen

include $(shell cocotb-config --makefiles)/Makefile.sim
