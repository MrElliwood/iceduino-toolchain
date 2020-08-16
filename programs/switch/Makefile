CC=riscv64-unknown-elf-gcc
LINK=riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Tlink.ld 
CFLAGS=-march=rv32i -mabi=ilp32 -static -nostdlib -fno-builtin-printf -Os -fPIC -fdata-sections -ffunction-sections
LDFLAGS=-Tlink.ld -Xlinker --gc-sections
# useful additions for LDFLAGS if linking fails: -Xlinker --verbose 

DUMP=riscv64-unknown-elf-objdump
COPY=riscv64-unknown-elf-objcopy


%.bin: %.elf
	$(COPY) -O binary $< $@

%.elf: %.o
	$(CC) $(CFLAGS) -o $@ crt0.s $< $(LDFLAGS)
	$(DUMP) -d $@ > disassembly.dump

%.o: %.c 
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -nostdlib -fno-builtin-printf -Os -fPIC -c $<

%.dat: %.bin
	hexdump -v -e '1/1 "%02x" "\n"' $< > $@

