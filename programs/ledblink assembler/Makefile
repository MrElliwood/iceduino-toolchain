CC=riscv64-unknown-elf-gcc
LINK=riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -O0 -nostdlib -nostartfiles -Tlink.ld -x assembler-with-cpp

DUMP=riscv64-unknown-elf-objdump
COPY=riscv64-unknown-elf-objcopy


%.bin: %.o
	$(DUMP) -d $< >disassembly.dump
	$(COPY) -O binary $< $@

%.o: %.s
	$(LINK) -o $@ $<


%.dat: %.bin
	hexdump -v -e '1/1 "%02x" "\n"' $< > $@

