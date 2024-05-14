#!/bin/bash
echo "Compiling $1.asm"

nasm -f elf "$1.asm"
if [ "$?" -eq "0" ]; then
    ld -m elf_i386 -s -o "$1" "$1.o"
else
    echo "Compilation failed"
    exit 1
fi

if [ "$?" -eq "0" ]; then
    echo "Compiled and linked successfully"
    echo "Running $1"
    "./$1"
else
    echo "Link failed"
    exit 1
fi
exit 0