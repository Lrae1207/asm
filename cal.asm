; Basic ABI for function calls
; eax - input
; edx - return
BITS 64
; Constants
SYS_EXIT    equ 1
SYS_FORK    equ 2
SYS_READ    equ 3
SYS_WRITE   equ 4
SYS_OPEN    equ 5
SYS_CLOSE   equ 6

ASCII_0     equ '0'
ASCII_a     equ 'a'

STDIN   equ 0
STDOUT  equ 1
STDERR  equ 2

BOOL_TRUE   equ 1
BOOL_FALSE  equ 0

; Macros

; Char to int
%macro ctoi 1
    sub %1, ASCII_0
%endmacro

; Prints a string
%macro print_string 2
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

; Reads %2 bytes of user input to %1
%macro read_string 2
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

section .data
    promptStr:      db "~$", 0

    validTerms:     dw "add", "sub", "mult", "div"

section .bss
    inputBuffer:    resb 100
    operandSize     resb 1 ; in bytes
    stringSize      resb 1 
    operand1:       resb 256
    operand2:       resb 256


section .text
    global _start
_start:
    call prompt_user

    mov eax, inputBuffer
    call string_length
    ctoi edx

    mov [stringSize], edx

    print_string [stringSize], 2
    call exit

; Exit the program
exit:
    mov eax, 1
    int 0x80
    ret

; Prompt the user and write input to inputBuffer
prompt_user:
    print_string promptStr, 2
    read_string inputBuffer, 100
    ret

; Get the length of a string pointed to by eax and return it in edx
string_length:
    push rax
    push rcx
    mov ecx, eax
    dec eax
    jmp .loop
.loop: inc eax
    cmp byte [eax], 0
    jne .loop
    sub eax, ecx
    mov edx, eax
    dec edx
    pop rcx
    pop rax
    ret