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

section .
    ; Messages/prompts:
    welcomeMessage: db "Welcome to a calculator.", 0xa, 0xd
    welcomeSize:    equ $-welcomeMessage

    promptStr:      db "~$", 0
    promptOperand:   db "Enter operand size(in bytes):", 0
    promptOperandSize: equ $-promptOperand
    promptNotation:     db "Enter notation (x/h/d):", 0
    promptNotationSize: equ $-promptNotation


    validTerms:     dw "add", "sub", "mul", "div"

section .bss
    ; Program info
    
    ; Input/output
    inputBuffer:    resb 256
    outString:      resb 256

    operandSize:    resb 1 ; in bytes
    p_operand1:       resb 1
    p_operand2:       resb 1


    


section .text
    global _start
_start:
    print_string welcomeMessage, welcomeSize
    jmp .l_operandPrompt
.l_operandPrompt: mov rcx, promptOperand
    mov rdx, promptOperandSize
    call prompt_string
    ; check to see if the operand is a number
    
    jmp .l_notationPrompt
.l_notationPrompt: mov rcx, promptNotation
    mov rdx, promptNotationSize
    call prompt_string
    ; Check to see if input is 'x', 'h', or 'd'
    xor rdx, rdx
    mov byte dl, [inputBuffer]
    sub dl, 0x64
    je .l_promptComplete
    sub dl, 0x4
    je .l_promptComplete
    sub dl, 0x10
    je .l_promptComplete
    jmp .l_notationPrompt
.l_promptComplete: call exit
    ;call prompt_user
    ;mov eax, inputBuffer
    ;call string_length
    ;ntoc edx
    ;mov byte [outString], dl
    ;print_string outString, [outStringSize]
    
    ;call prompt_user
    call exit

; Exit the program
exit:
    mov eax, 1
    int 0x80
    ret

; Parse the user's input
parse_input:

    ret

; Print edx bytes of a string starting at ecx then prompt the user
prompt_string:
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    int 0x80
    
    read_string inputBuffer, 256
    ret

; Prompt the user and write input to inputBuffer
prompt_user:
    print_string promptStr, 2
    read_string inputBuffer, 256
    ret

; Get the length of a string pointed to by rax and return it in rSdx
string_length:
    push rax    ; preserve rax
    push rcx    ; preserve rcx
    xor rdx, rdx; clear rdx
    
    mov rcx, rax; rcx contains pointer to the original string
    dec rax     ; fix offset
    jmp string_length.l_loop

.l_loop: inc rax
    cmp byte [rax], 0
    jne string_length.l_loop
    sub rax, rcx; end - start = string length
    mov rdx, rax
    dec rdx     ; fix offset
    pop rcx
    pop rax
    ret

; return the value of the string pointed to by eax from ascii to number
hex_string_to_number:
    call string_length  ; store input length in edx
    mov rbx, rdx        ; transfer input length to ebx
    xor rdx, rdx
    mov rax, inputBuffer; move &inputBuffer to rax
    add rax, rbx        ; &inputBuffer + inputBuffer.size()
    xor rdi, rdi        ; rdi is the amount of times the loop has run 
    xor rsi, rsi        ; rsi assists with multiplying by ten
    xor rcx, rcx        ; rcs stores the sum
    jmp hex_string_to_number.l_loop

    ; Working backwards from &inputBuffer + inputBuffer.size() - 1
.l_loop: dec rax
    inc rdi
    push rdi
    mov byte sil, [rax]
    cton sil
    jmp hex_string_to_number.l_loop2

.l_loop2: mov r8, 0
    dec rdi
    jne hex_string_to_number.l_loop2
    pop rdi
    test rax, rdx
    jne hex_string_to_number.l_loop
    
    ret

; return the value of the string pointed to by eax from ascii to number
dec_string_to_number:
    call string_length  ; store input length in edx
    mov rbx, rdx        ; transfer input length to ebx
    xor rdx, rdx
    mov rax, inputBuffer; move &inputBuffer to rax
    add rax, rbx        ; &inputBuffer + inputBuffer.size()
    xor rdi, rdi        ; rdi is the amount of times the loop has run 
    xor rsi, rsi        ; rsi assists with multiplying by ten
    xor rcx, rcx        ; rcs stores the sum
    jmp hex_string_to_number.l_loop

    ; Working backwards from &inputBuffer + inputBuffer.size() - 1
.l_loop: dec rax
    inc rdi
    push rdi
    mov byte sil, [rax]
    cton sil
    test rdi, rdi 
    je hex_string_to_number.l_loop2
    jmp hex_string_to_number.l_loop

.l_loop2: shl rsi, 1 ; rsi = rsi * 10 ^ rdi
    mov rbx, rsi
    shl rsi, 1
    shl rsi, 1
    add rsi, rbx

    dec rdi
    jne hex_string_to_number.l_loop2
    pop rdi
    test rax, rdx
    jne hex_string_to_number.l_loop
    
    ret
