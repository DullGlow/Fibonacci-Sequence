%include        'functions.asm'

SECTION .data    
    msg db "Enter a positive number: "
    lenMsg equ $ - msg

    startMsg db `Fibonacci Series:\u001b[32m 0, 1, `    ; Printing result in green
    lenStartMsg equ $ - startMsg

    endMsg db `\u001b[2D \n`                            ; Change ", " with " \n"
    lenEndMsg equ $ - endMsg
    

SECTION .bss            ; Section containing uninitialized data
    string resb 11      ; Reserved 11 byte for string

    
SECTION .text           ; Section containing code

global _start
    
    
_start:
    nop
    ; Print: "Enter a positive number: "
    mov eax, msg
    mov ebx, lenMsg
    call print

    ; Get input
    mov eax, 3              ; sys_read
    mov ebx, 0              ; stdin
    mov ecx, string         ; Input will go here
    mov edx, 11             ; Take 11 byte
    int 0x80                ; syscall

    ; Convert input string to int
    mov ebx, string         
    call to_int
    mov ecx, eax            ; Store result in ecx


    ; Print: "Fibonacci Series: 0,1,"
    mov eax, startMsg       ; Message to print
    mov ebx, lenStartMsg    ; Buffer size
    call print

    ; Clear buffer
    mov dword [string], 0
    mov dword [string + 4], 0
    mov word [string + 8], 0

    ; ESI -> n - 1
    ; EBP -> n
    ; EDX -> n + 1
    ; ECX -> Input number
    mov esi, 0
    mov ebp, 1
    mov edx, 1

main_loop:
    ; While nextTerm(EDX) <= input(ecx)
    cmp edx, ecx
    ja end              

    ; Convert nextTerm to string
    mov eax, edx            ; Integer to convert
    mov ebx, [string]
    xor [string], ebx
    mov ebx, string         ; Where to store resulting string
    call to_string

    ; Print nextTerm
    mov eax, string         ; Message to print
    mov ebx, 11             ; Buffer size
    call print

    ; Print: ", "
    mov dword [string], ", "    ; Put ", " in string
    mov eax, string         ; Message to print
    mov ebx, 2              ; Buffer size
    call print

    ; (n-1) = (n)
    mov ebx, ebp
    mov esi, ebx

    ; (n) = nextTerm
    mov ebx, edx
    mov ebp, ebx

    ; nextTerm = (n-1) + (n) | (n) is already stored in ebx
    add ebx, esi
    mov edx, ebx

    jmp main_loop

end:
    ; Do finishing print
    mov eax, endMsg
    mov ebx, lenEndMsg
    call print

    ;exit
    mov eax, 1
    int 0x80
