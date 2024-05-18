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

; Char to num
%macro cton 1
    sub %1, ASCII_0
%endmacro

; Int to num
%macro ntoc 1
    add %1, ASCII_0
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
    welcomeMessage: db "Welcome to big calculator.", 0xa, 0xd
    welcomeSize     equ $-welcomeMessage
    promptStr:      db "~$", 0

    validTerms:     dw "add", "sub", "mult", "div"

section .bss
    ; Input/output
    inputBuffer:    resb 256
    outString:      resb 256
    outStringSize:  resb 1

    operandSize:    resb 1 ; in bytes
    operand1:       resb 256
    operand2:       resb 256


section .text
    global _start
_start:
    print_string welcomeMessage, welcomeSize

    ;call prompt_user
    ;mov eax, inputBuffer
    ;call string_length
    ;ntoc edx
    ;mov byte [outString], dl
    ;print_string outString, [outStringSize]

    ; asm equivalent of while(some condition)
main_loop:
    call prompt_user
    test eax,eax
    je main_loop
    
    call exit

; Exit the program
exit:
    mov eax, 1
    int 0x80
    ret

; Prompt the user and write input to inputBuffer
prompt_user:
    print_string promptStr, 2
    read_string inputBuffer, 256
    ret

parse_input:
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
