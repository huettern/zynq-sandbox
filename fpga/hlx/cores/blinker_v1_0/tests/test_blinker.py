# Simple tests for an adder module
import cocotb

from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.result import TestFailure
import random

CLK_PERIOD = 10

@cocotb.test()
def basic_test(dut):

		cocotb.fork(Clock(dut.aclk, CLK_PERIOD).start())
		dut.arstn <= 0
		yield Timer(CLK_PERIOD * 10)
		dut.arstn <= 1
		yield Timer(CLK_PERIOD * 120e3)

