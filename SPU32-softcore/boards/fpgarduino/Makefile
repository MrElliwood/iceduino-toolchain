
help:
	@eche "make all               generate iCE40 BIN file in one step"
	@echo "make top.json          generate JSON"
	@echo "make top.asc           generate IceStorm ASCII file"
	@echo "make top.bin           generate iCE40 BIN file"
	@echo "make prog_sram         upload, starts from sram"
	@echo "make prog_flash        upload bin"
	@echo "make clean             remove output files"




top.json: config-local.vh top.v
	cd ../../software/asm && make
	cd ../.. && yosys -p 'synth_ice40 -top top -json ./boards/fpgarduino/top.json' ./boards/fpgarduino/top.v

top.asc: top.json top.pcf
	nextpnr-ice40 --hx8k --package tq144:4k --json top.json --pcf top.pcf --asc top.asc 

top.bin: top.asc
	icepack top.asc top.bin

prog_sram: top.bin
	iceprog -S top.bin

prog_flash: top.bin
	iceprog top.bin

config-local.vh: config-defaults.vh
	tail -n +8 config-defaults.vh > config-local.vh

all: top.json top.asc top.bin
	

clean:
	-rm top.json top.blif top.asc top.bin

.PHONY: prog_sram prog_flash reset_halt reset_boot clean

