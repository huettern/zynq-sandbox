
import random
import logging

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ReadOnly
from cocotb.drivers import BitDriver
from cocotb.drivers.avalon import AvalonSTPkts as AvalonSTDriver
from cocotb.drivers.avalon import AvalonMaster
from cocotb.monitors.avalon import AvalonSTPkts as AvalonSTMonitor
from cocotb.regression import TestFactory
from cocotb.scoreboard import Scoreboard
from cocotb.result import TestFailure

# ---------------------------------------------------------------------------------
# HELPER CLASSES
# ---------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------
# TESTBENCH
# ---------------------------------------------------------------------------------

class TpgTB(object):

    def __init__(self, dut, debug=False):
        self.dut = dut

        
    def model(self, transaction):
        """Model the DUT based on the input transaction"""
        pass

    async def reset(self, duration=20):
        self.dut._log.debug("Resetting DUT")
        self.dut.rst_ni <= 0
        await Timer(duration, units='ns')
        await RisingEdge(self.dut.aclk_i)
        self.dut.rst_ni <= 1
        self.dut._log.debug("Out of reset")

    async def run(self, duration=20):

        # start
        await Timer(10, units='ns')
        await RisingEdge(self.dut.aclk_i)

        # Put some data in
        self.dut.trigger_i <= 1
        await RisingEdge(self.dut.aclk_i)
        self.dut.trigger_i <= 0

        await Timer(400, units='ns')
        await RisingEdge(self.dut.aclk_i)

        # Put some data in
        self.dut.trigger_i <= 1
        await RisingEdge(self.dut.aclk_i)
        self.dut.trigger_i <= 0


        await Timer(400, units='ns')
        await RisingEdge(self.dut.aclk_i)
        



# ---------------------------------------------------------------------------------
# TEST ROUTINE
# ---------------------------------------------------------------------------------

async def run_test(dut):
    # create clock gen and TB
    cocotb.fork(Clock(dut.aclk_i, 10, units='ns').start())
    tb = TpgTB(dut)

    # reset
    await tb.reset()
        
    # run for a while
    await tb.run(200)

    # report results
    # raise tb.scoreboard.result

# ---------------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------------

factory = TestFactory(run_test)
factory.generate_tests()