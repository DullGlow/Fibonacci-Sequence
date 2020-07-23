
;---------------------------------------------------------------
; void print  --  Prints message to stdout
;
; IN:
;   EAX: Message to print
;   EBX: Message size
; OUT:
;   None
;
; Notes:
;---------------------------------------------------------------

print:
    ; Save registers
    push eax
    push ebx
    push ecx
    push edx
    
    ; Print message
    mov ecx, eax    ;move message in ecx
    mov edx, ebx    ;move message length in edx
    mov eax, 4      ;sys_write
    mov ebx, 1      ;stdout
    int 0x80        ;call print
    
    ; Recover registers
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret




;---------------------------------------------------------------
; void print_error  --  Prints error message to stdout
;
; IN:
;   None
; OUT:
;   None
;
; Notes:
;   Exits program after printing
;   TODO: Don't loose registers
;---------------------------------------------------------------

print_error:
    mov eax, 4          ; Error
    mov ebx, 1          ; Stdout | or 0?
    mov ecx, errorMsg
    mov edx, lenErrorMsg
    int 0x80            ; Call print

    mov eax, 1
    int 0x80
    ret




;---------------------------------------------------------------
; int slen  --  Finds length of a string
;
; IN:
;   EBX: String
; OUT:
;   EAX: String length
;
; Notes: 
;---------------------------------------------------------------

slen:
    ; Save registers
    push ebx
    push ecx                

    xor ecx, ecx            ; Clear ECX
    
do_slen:
    cmp byte [ebx], 0       ; Is current char empty?
    jz end_slen             ; If yes, jump to end
    
    inc ecx                 ; Increase counter
    inc ebx                 ; Move onto next character
    jmp do_slen             ; Continue loop
    
end_slen:
    mov eax, ecx            ; Place return value in EAX

    ; Recover registers
    pop ecx
    pop ebx
    ret




;---------------------------------------------------------------
; int to_int  --  Converts string into integer
;
; IN:
;   EBX: String
; OUT:
;   EAX: Converted integer
;
; Notes: 
;   It is presumed, that string ends with \n
;   TODO: change where result is stored (?)
;---------------------------------------------------------------

to_int:
    ; Save registers
    push ebx
    push ecx
    push edx

    call slen          ; Get string length
    mov ecx, eax       ; Put length in ecx
    dec ecx            ; For \n
    
    xor eax, eax       ; EAX = 0
    
do_digit:
    ; Check if char is between 0 and 9
    cmp byte [ebx], '0'
    jb print_error
    cmp byte [ebx], '9'
    ja print_error
    
    push eax            ; Save EAX
    push ebx            ; Save EBX
    
    ; Put 10^ECX in eax
    dec ecx             ; Temporarily decrease for next function
    mov ebx, 10
    call power          ; Call function
    inc ecx             ; Increase it back
    
    pop ebx             ; Recover
    
    ; EDX = int(ebx[n])
    xor edx, edx
    mov dl, [ebx]       ; EDX = EBX[0]
    sub edx, '0'        ; EDX = EDX - '0'
    
    ; EAX *= EDX   ->     EAX = EBX[n] * 10^ECX
    mul edx             ; EAX = EDX * i32
    mov edx, eax
    
    pop eax
    
    add eax, edx        ; Result += EBX[0] * 10^ECX
    inc ebx             ; Move on next char
    dec ecx             ; Update counter
    jnz do_digit
    
    ; Recover registers
    pop edx
    pop ecx
    pop ebx
    
    ret




;---------------------------------------------------------------
; int power  --  Calculates power of a number
;
; IN:
;   EBX: Base number
;   ECX: Exponent
; OUT:
;   EAX: Returns EBX^ECX
;
; Notes:
;   Only works for exponent >= 0
;---------------------------------------------------------------

power:
    ; Save registers
    push ecx            ; Save ECX
    push ebx            ; Save EBX

    xor eax, eax        ; Empty result | EAX = 0
    inc eax             ; EAX = 1
    
    cmp ecx, 0          ; Is ECX == 0?
    je end_power        ; If so, end function
    
do_power:
    mul ebx             ; EAX *= EBX
    dec ecx             ; Update counter
    jnz do_power        ; While counter != 0
    
end_power:
    ; Recover registers
    pop ebx             ; Recover EBX
    pop ecx             ; Recover ECX
    
    ret




;---------------------------------------------------------------
; void to_string  --  Converts integer into string
;
; IN:
;   EAX: Integer to convert
;   EBX: Address in memory where string will be stored
; OUT:
;   [EBX]: Resulting string
;
; Notes:
;   Very slow
;---------------------------------------------------------------

to_string:
    ; Save Registers
    push eax
    push edx
    push ecx
    push ebx

    ; Clear return location
    mov ecx, [ebx]
    xor [ebx], ecx

    xor ecx, ecx        ; Set ECX to zero. It will count length of string
    mov ebx, 10         ; This will be the dividend
    
do_character:
    xor edx, edx
    div ebx             ; EAX = EAX / EBX(10). remainder is stored in EDX

    add edx, '0'        ; Add '0' to remainder
    push edx            ; Save character in stack

    inc ecx             ; Length++
    cmp eax, 0          ; Is EAX 0?
    jne do_character    ; If its not, we still have digits left. Continue loop
    
    mov ebx, [esp + ecx*4]      ; Get memory address, which we stored in stack
    
; Now fill result location by taking characters from stack
pop_character:     
    pop edx                     ; Get stored character             
    mov byte [ebx + eax], dl    ; Place the character in memory
    inc eax                     ; Move up index by one
    dec ecx                     ; Decrease counter

    jnz pop_character           ; While ECX != 0: pop_character

    ; Restore old values
    pop ebx
    pop ecx
    pop edx
    pop eax

    ret
    


SECTION .bss            ; Section containing uninitialized data
    i32 resb 4          ; For 4 byte integer

SECTION .data    
    errorMsg db "Undefined error occured.", 0xa
    lenErrorMsg equ $ - errorMsg

