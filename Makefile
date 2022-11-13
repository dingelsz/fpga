################################################################################
# Reference
################################################################################
# Makefile Reference:
# https://gist.github.com/isaacs/62a2d1825d04437c6f08
# Rules:
#   <target>: <prerequisites...>
#       <commands>
#
# Magic Variables
#  $@   # (target)
#  $<   # (first prerequisite)
#  $^   # (all prerequisites)
################################################################################
# Helpers
################################################################################
BUILD		= ./build
VERILOG     = src/$(app)/main.v
CONSTRAINT  = src/$(app)/main.pcf
FPGA_PKG	= cb132
FPGA_TYPE	= hx8k

check-env:
ifndef app
	$(error app is undefined)
endif

.PHONY: all clean


################################################################################
# Interface
################################################################################
all: check-env upload

build: $(BUILD)/main.bin

clean:
	rm $(BUILD)/*


################################################################################
# CORE
# Building and Uploading
################################################################################
# Upload
# Purpose: Upload the bitstream to the FPGA
# Docs: https://clifford.at/icestorm
upload: $(BUILD)/main.bin
	iceprog $<

# Bitstream
# Purpose: Generate a bitstream file
# Docs: https://clifford.at/icestorm
# Context: The FPGA is programmed by streaming the bitstream file to the
#          configuration port.
$(BUILD)/main.bin: $(BUILD)/main.asc
	icepack $< $@

# Place and Route
# Purpose: Map primitives to physical locations on the hardware
# Docs: https://github.com/YosysHQ/nextpnr
$(BUILD)/main.asc: $(BUILD)/main.json
	nextpnr-ice40 --${FPGA_TYPE} --package ${FPGA_PKG} --json $< --pcf $(CONSTRAINT) --asc $@

# Yosys Open SYnthesis Suite
# Purpose: Synthesize into json
# Docs: https://yosyshq.net/yosys/documentation.html
# Context: Synthesis converts high-level Verilog descriptions to a
#          network of technology-specific primitives (LUT, flip-flip, etc).
$(BUILD)/main.json: $(VERILOG)
	yosys -ql logs/main-yosys.log -p 'synth_ice40 -top top -json $@' $<
