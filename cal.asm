BITS 64
; Constants
SYS_EXIT    equ 1
SYS_FORK    equ 2
SYS_READ    equ 3
SYS_WRITE   equ 4
SYS_OPEN    equ 5
SYS_CLOSE   equ 6

STDIN   equ 0
STDOUT  equ 1
STDERR  equ 2

; Macros

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
    stringLen:      resb 4
    operandSize     resb 1 ; in bytes
    operand1:       resb 256
    operand2:       resb 256


section .text
    global _start
_start:
    call prompt_user
    mov eax, inputBuffer
    call string_length
    print_string inputBuffer, stringLen
    call exit



exit:
    mov eax, 1
    int 0x80
    ret

; Prompt the user and write input to inputBuffer
prompt_user:
    print_string promptStr, 2
    read_string inputBuffer, 100
    ret

; Get the length of a string pointed to by eax and return it in stringLen
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
    mov [stringLen], eax
    pop rcx
    pop rax
    ret
