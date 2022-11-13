# Project setup
BUILD		= ./build
VERILOG     = src/$(app)/main.v
CONSTRAINT  = src/$(app)/main.pcf
FOOTPRINT	= ct256
FPGA_PKG	= cb132
FPGA_TYPE	= hx8k

.PHONY: all clean

all: main

main: $(BUILD)/main.bin

$(BUILD)/main.bin: $(BUILD)/main.asc
	icepack $< $@

$(BUILD)/main.asc: $(BUILD)/main.json
	nextpnr-ice40 --${FPGA_TYPE} --package ${FPGA_PKG} --json $< --pcf $(CONSTRAINT) --asc $@

$(BUILD)/main.json: $(VERILOG)
	yosys -ql logs/main-yosys.log -p 'synth_ice40 -top top -json $@' $(VERILOG)

upload: $(BUILD)/main.bin
	iceprog $<

clean:
	rm $(BUILD)/*
