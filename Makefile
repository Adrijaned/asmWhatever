.PHONY: all
all : termUtils.o common.o entry.o game.o
	ld -oo $^

%.o : %.asm
	nasm -felf64 -Fdwarf $< -o $@

.PHONY: clean
clean:
	rm -rf o *.o
