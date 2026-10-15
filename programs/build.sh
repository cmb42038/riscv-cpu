#!/bin/bash
# build.sh - turns test_c.c into test_c.hex for the cpu
# run from the project root: ./programs/build.sh

set -e   # stop if any step fails

CC=${CC:-riscv64-unknown-elf-gcc}
OBJCOPY=${OBJCOPY:-riscv64-unknown-elf-objcopy}

# compile and link
#   -march=rv32i -mabi=ilp32   only use the 32-bit base instructions my cpu has
#   -O0                        no optimizing, so the compiler doesn't just work out the answer itself
#   -nostdlib -ffreestanding   no operating system or C library
#   -mno-relax                 keep the instructions the way they were first picked
#   -T programs/link.ld        put the code at address 0
$CC -march=rv32i -mabi=ilp32 -O0 -nostdlib -ffreestanding -mno-relax \
    -T programs/link.ld programs/start.S programs/test_c.c -o programs/test_c.elf

# pull out just the raw machine code
$OBJCOPY -O binary programs/test_c.elf programs/test_c.bin

# write one 32-bit instruction per line in hex, which is what $readmemh wants
od -An -tx4 -w4 -v programs/test_c.bin > programs/test_c.hex

echo "built programs/test_c.hex ($(wc -l < programs/test_c.hex) instructions)"
