from PyQt4.QtGui import QApplication
from seven import Seven
from cocotb.triggers import Timer
from cocotb.result import TestSuccess
import cocotb, sys, time

ITER = 1200
TIME_UNIT = 0.01
UNIT_PER_SIM = 10
CYCLE_PER_SLEEP = 1000

@cocotb.coroutine
def SimClock(c, C, p):
	for i in xrange(C):
		c <= 0
		yield p
		c <= 1
		yield p

@cocotb.test()
def LAB1_test(dut):
	clk = dut.CLOCK_50
	keys = dut.KEY
	hexs = [dut.HEX7, dut.HEX6, dut.HEX5, dut.HEX4, dut.HEX3, dut.HEX2, dut.HEX1, dut.HEX0]
	period = Timer(2)

	yield SimClock(clk, 10, period)

	# QT related
	app = QApplication(sys.argv)
	seven = Seven()
	seven.show()
	for i in xrange(ITER):
		for j in xrange(UNIT_PER_SIM):
			time.sleep(TIME_UNIT)
			app.processEvents()
		keys[0] <= (not seven.buttons[0].isDown())
		keys[1] <= (not seven.buttons[1].isDown())
		keys[2] <= (not seven.buttons[2].isDown())
		keys[3] <= (not seven.buttons[3].isDown())
		yield SimClock(clk, CYCLE_PER_SLEEP, period)
		for i, h in enumerate(seven.hexs):
			h.updateString(hexs[i].value.binstr)
		if not seven.isVisible():
			break
	seven.close()
