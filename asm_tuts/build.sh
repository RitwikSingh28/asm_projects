#!/bin/bash

set -xe

as exit.s -o ./binaries/exit.o
ld ./binaries/exit.o -o ./binaries/exit

as -g maximum.s -o ./binaries/maximum.o
ld ./binaries/maximum.o -o ./binaries/maximum

# generate a 32-bit object file
as -g --32 power.s -o ./binaries/power.o
ld -m elf_i386 ./binaries/power.o -o ./binaries/power

as -g --32 factorial.s -o ./binaries/factorial.o
ld -m elf_i386 ./binaries/factorial.o -o ./binaries/factorial

as -g --32 file_handler.s -o ./binaries/file_handler.o
ld -m elf_i386 ./binaries/file_handler.o -o ./binaries/file_handler
