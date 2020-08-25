
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
        # Start pulse counter
        cocotb.fork(pulse_assert("tlast", self.dut.aclk_i, self.dut.m_axis_tlast, active=1))
        cocotb.fork(pulse_assert("tuser", self.dut.aclk_i, self.dut.m_axis_tuser, active=1))

        # start
        await Timer(10, units='ns')
        await RisingEdge(self.dut.aclk_i)

        # Put some data in
        self.dut.trigger_i <= 1
        await RisingEdge(self.dut.aclk_i)
        self.dut.trigger_i <= 0

        # put some random backpressure on tready
        random.seed(10)
        await RisingEdge(self.dut.m_axis_tvalid)
        while self.dut.m_axis_tvalid == 1:
            if random.random() > 0.6:
                self.dut.m_axis_tready <= 0
            else:
                self.dut.m_axis_tready <= 1
            await RisingEdge(self.dut.aclk_i)


        await Timer(100, units='ns')
        await RisingEdge(self.dut.aclk_i)

        # Put some data in
        self.dut.trigger_i <= 1
        await RisingEdge(self.dut.aclk_i)
        self.dut.trigger_i <= 0
        while self.dut.m_axis_tvalid == 0:
            print('here')
            await RisingEdge(self.dut.aclk_i)

        # put backpressure on last/user
        do_run = 1
        while self.dut.m_axis_tvalid == 1:
            if self.dut.m_axis_tlast == 1:
                self.dut.m_axis_tready <= 0
                await RisingEdge(self.dut.aclk_i)
                await RisingEdge(self.dut.aclk_i)
                self.dut.m_axis_tready <= 1
                await RisingEdge(self.dut.aclk_i)
                do_run = 0

            if self.dut.m_axis_tuser == 1:
                self.dut.m_axis_tready <= 0
                await RisingEdge(self.dut.aclk_i)
                await RisingEdge(self.dut.aclk_i)
                await RisingEdge(self.dut.aclk_i)
                await RisingEdge(self.dut.aclk_i)
                self.dut.m_axis_tready <= 1
                await RisingEdge(self.dut.aclk_i)

            # await RisingEdge(self.dut.aclk_i)
            await Timer(1, units='ns')

        await Timer(50, units='ns')
        await RisingEdge(self.dut.aclk_i)

# ---------------------------------------------------------------------------------
# Timing tester
# ---------------------------------------------------------------------------------
@cocotb.coroutine
def pulse_assert(name, clk, signal, active=1, len=-1, count=-1):
    state = 0
    clk_cnt, pulse_cnt = 0, 0
    if signal == active:
        state = 1

    while True:
        yield RisingEdge(clk)
        clk_cnt += 1
        # print("%3d, %d %s" % (clk_cnt, state, signal) )

        # check for rise
        if state == 0 and (signal==active):
            state = 1
            clk_cnt = 0
        # check for fall
        if state == 1 and not (signal==active):
            state = 0
            pulse_cnt += 1
            print("%s : Pulse complete. Duration: %d Count: %d" % (name, clk_cnt, pulse_cnt) )




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