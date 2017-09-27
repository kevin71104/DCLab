from PyQt4.QtGui import *
import sys

class Hex(QFrame):
	BORDER = 0.15
	XY = [
		[  BORDER,   BORDER],
		[  BORDER,      0.5],
		[  BORDER, 1-BORDER],
		[1-BORDER,   BORDER],
		[1-BORDER,      0.5],
		[1-BORDER, 1-BORDER],
	]
	BITS = [[0,3], [3,4], [4,5], [5,2], [2,1], [1,0], [1,4]]
	COLORS = [QColor("red"), QColor("gray"), QColor("blue")]

	def __init__(self):
		QFrame.__init__(self)
		self.setFrameShape(QFrame.Box)
		self.setLineWidth(3)
		self.setMinimumSize(100, 150)
		self.s = "0"*7

	def updateString(self, s):
		if s != self.s:
			self.s = s
			self.update()

	def paintEvent(self, e):
		siz = self.size()
		w, h = siz.width(), siz.height()
		p = QPainter(self)
		for i, (src, dst) in enumerate(self.BITS):
			if i >= len(self.s) or self.s[-1-i] == '0':
				c = self.COLORS[0]
			elif self.s[-1-i] == '1':
				c = self.COLORS[1]
			else:
				c = self.COLORS[2]
			p.setPen(QPen(c, 5))
			xs, ys = self.XY[src]
			xd, yd = self.XY[dst]
			p.drawLine(xs*w, ys*h, xd*w, yd*h)
		QFrame.paintEvent(self, e)

class Seven(QWidget):
	def __init__(self):
		QWidget.__init__(self, windowTitle = "Seven")
		self.upper = QHBoxLayout()
		self.lower = QHBoxLayout()
		self.setLayout(QVBoxLayout())
		self.layout().addLayout(self.upper)
		self.layout().addLayout(self.lower)
		self.hexs = [Hex() for i in range(8)]
		for h in self.hexs:
			self.upper.layout().addWidget(h)
		self.buttons = [QPushButton('Key {}'.format(i)) for i in range(4)]
		for b in self.buttons:
			self.lower.layout().addWidget(b)

if __name__ == '__main__':
	app = QApplication(sys.argv)
	s = Seven()
	s.show()
	app.exec_()
