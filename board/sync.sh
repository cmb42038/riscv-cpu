#!/bin/bash
# sync.sh - copies the files vivado needs over to windows
#   ./board/sync.sh

set -e   

DEST=/mnt/c/projects/riscv-basys3/src   # C:\projects\riscv-basys3\src on windows

mkdir -p $DEST
cp rtl/*.v $DEST/
cp board/basys3_top.v board/basys3.xdc $DEST/
cp programs/blink.hex $DEST/blink.mem   # memory file

echo "copied to C:\\projects\\riscv-basys3\\src"