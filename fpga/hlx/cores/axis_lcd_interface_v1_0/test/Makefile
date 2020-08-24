
# Default to verilog
TOPLEVEL_LANG ?= verilog

SIM = verilator
EXTRA_ARGS += --trace --trace-structs

PWD=$(shell pwd)

export PYTHONPATH := $(PWD)/../cosim:$(PYTHONPATH)

########################################
# for timing generator
########################################

# VERILOG_SOURCES  =  $(PWD)/../hdl/lcd_timing_generator.sv
# TOPLEVEL = lcd_timing_generator
# MODULE := test_timing_gen

########################################
# for fifo
########################################

# VERILOG_SOURCES  =  $(PWD)/../hdl/lcd_fifo.sv
# TOPLEVEL = lcd_fifo
# MODULE := test_fifo

########################################
# for top
########################################

VERILOG_SOURCES  =  $(PWD)/../hdl/lcd_fifo.sv \
					$(PWD)/../hdl/lcd_timing_generator.sv \
					$(PWD)/../hdl/lcd_top.sv
TOPLEVEL = lcd_top
MODULE := test_lcd

include $(shell cocotb-config --makefiles)/Makefile.sim
