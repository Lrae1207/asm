#!/bin/bash
echo "Compiling $1.asm"

nasm -gdwarf -f elf64 "$1.asm"
if [ "$?" -eq "0" ]; then
    ld -o "$1" "$1.o"
else
    echo "Compilation failed"
    exit 1
fi

if [ "$?" -eq "0" ]; then
    echo "Compiled and linked successfully"
    echo "Debugging $1"
    gdb "$1" -ex "set disassembly-flavor intel" -ex "break _start" -ex "disassemble _start"
else
    echo "Link failed"
    exit 1
fi
exit 0
