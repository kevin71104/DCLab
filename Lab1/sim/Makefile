TEST=module_name
ifdef SV
	EXT = sv
else
	EXT = v
endif
SRC=../src
INC=../include
# cocotb related variables
RANDOM_SEED?=12345
SIM=ius
EXTRA_ARGS=+incdir+$(SRC) +define+DUT_$(TEST)
COCOTB=/opt/cocotb/
VERILOG_SOURCES=$(INC)/$(TEST)_include.$(EXT)
TOPLEVEL_LANG=verilog
TOPLEVEL?=$(TEST)
MODULE=$(TEST)_test
include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
