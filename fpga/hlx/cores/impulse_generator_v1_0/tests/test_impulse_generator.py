
import random

import cocotb
from cocotb.decorators import coroutine
from cocotb.triggers import Timer, RisingEdge, ReadOnly
from cocotb.monitors import Monitor
from cocotb.drivers import BitDriver
from cocotb.binary import BinaryValue
from cocotb.regression import TestFactory
from cocotb.scoreboard import Scoreboard
from cocotb.result import TestFailure, TestSuccess


# ==============================================================================
class BitMonitor(Monitor):
	"""Observes single input or output of DUT."""
	def __init__(self, name, signal, clock, callback=None, event=None):
		self.name = name
		self.signal = signal
		self.clock = clock
		Monitor.__init__(self, callback, event)

	@coroutine
	def _monitor_recv(self):
		clkedge = RisingEdge(self.clock)

		while True:
			# Capture signal at rising edge of clock
			yield clkedge
			vec = self.signal.value
			self._recv(vec)


# ==============================================================================
def input_gen():
	"""Generator for input data applied by BitDriver"""
	while True:
		yield random.randint(1,5), random.randint(1,5)

# ==============================================================================
class ImpulseGeneratorTB(object):
	def __init__(self, dut):
		"""
		Setup testbench.
		"""

		# Some internal state
		self.dut = dut
		self.stopped = False

		# Create input driver and output monitor
		self.input_drv = BitDriver(dut.enable, dut.clk, input_gen())
		dut.enable <= 0
		self.output_mon = BitMonitor("output", dut.impulse, dut.clk)

		# Create a scoreboard on the outputs
		self.expected_output = [ BinaryValue(0,1) ]
		self.scoreboard = Scoreboard(dut)
		self.scoreboard.add_interface(self.output_mon, self.expected_output)

		# Reconstruct the input transactions from the pins
		# and send them to our 'model'
		self.input_mon = BitMonitor("input", dut.enable, dut.clk, callback=self.model)

		# Model variables
		self.triggered = False
		self.counter = 0

	@cocotb.coroutine
	def reset(self, duration=100000):
		self.dut._log.debug("Resetting DUT")
		self.dut.rst <= 1
		yield Timer(duration)
		yield RisingEdge(self.dut.clk)
		self.dut.rst <= 0
		self.dut._log.debug("Out of reset")

	def model(self, transaction):
		""" Model the DUT based on the input transaction. """
		# Do not append an output transaction for the last clock cycle of the
		# simulation, that is, after stop() has been called.
		if not self.stopped:

			print "--- PING"
			print(type(transaction))
			print(transaction.integer)

			if self.triggered:
				print "Appending 1"
				self.expected_output.append( BinaryValue(1,1) )
				self.counter = self.counter + 1
				if self.counter == 21-1:
					self.triggered = False
			else:
				print "Appending 0"
				if transaction.integer == 0:
					self.expected_output.append( BinaryValue(0,1) )
				if transaction.integer == 1:
					self.expected_output.append( BinaryValue(1,1) )
					self.counter = self.counter = 0
					self.triggered = True

		# self.expected_output.append(transaction)

	def start(self):
		"""Start generation of input data."""
		self.input_drv.start()

	def stop(self):
		"""
		Stop generation of input data. 
		Also stop generation of expected output transactions.
		"""
		self.input_drv.stop()
		self.stopped = True

# ==============================================================================
@cocotb.coroutine
def clock_gen(signal):
	"""Generate the clock signal."""
	while True:
		signal <= 0
		yield Timer(5000) # ps
		signal <= 1
		yield Timer(5000) # ps

# ==============================================================================
@cocotb.coroutine
def run_test(dut):
	"""Setup testbench and run a test."""
	cocotb.fork(clock_gen(dut.clk))

	# Instantiate testbench object
	tb = ImpulseGeneratorTB(dut)
	yield tb.reset()
	clkedge = RisingEdge(dut.clk)

	# Apply random input data by input_gen via BitDriver for 100 clock cycle.
	tb.start()
	for i in range(100):
		yield clkedge

	# Stop generation of input data
	tb.stop()
	yield clkedge

	# Print result of scoreboard.
	# raise tb.scoreboard.result

# ==============================================================================
# Register test.
factory = TestFactory(run_test)
factory.generate_tests()

