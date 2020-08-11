cpu.blif: ./cpu/cpu.v
	yosys -p "synth_ice40 -blif cpu.blif" ./cpu/cpu.v

cpu.asc: cpu.blif
	arachne-pnr -d 8k -P tq144:4k -o cpu.asc cpu.blif

cpu.bin: cpu.asc
	icetime -d hx8k -t cpu.asc
	icepack cpu.asc cpu.bin

clean:
	-rm *.bin *.asc *.blif
