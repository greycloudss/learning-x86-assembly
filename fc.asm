.model small
.stack 100h

.data
    byte1 db 0                 ; Number of bytes for fname1
    byte2 db 0                 ; Number of bytes for fname2

    fname1 db 13 dup(?)        ; Buffer for first argument
    fname2 db 13 dup(?)        ; Buffer for second argument

    newline db 10, 13          ; Newline for output

    pos db 0                   ; Position counter

.code

start:
    mov ax, @data
    mov es, ax                 ; Load segment for fname1 and fname2

    mov si, 82h                ; Address of command-line arguments in PSP

    ; Process the first argument
    lea di, fname1
    mov pos, 0
incrementer:
    lodsb
    cmp al, 0dh                ; Check for newline
    je _continue
    cmp al, ' '                ; Check for space
    je _continue
    cmp pos, 11                ; Prevent buffer overflow
    ja _error
    stosb
    inc byte1                  ; Increment byte1 counter
    inc pos
    jmp incrementer

_continue:
    mov byte ptr es:[di], 0    ; Null-terminate fname1

    ; Reset variables for second argument
    xor di, di
    mov pos, 0
    lea di, fname2

    ; Process the second argument
incrementer1:
    lodsb
    cmp al, 0dh                ; Check for newline
    je _continue1
    cmp al, ' '                ; Check for space
    je _continue1
    stosb
    inc byte2                  ; Increment byte2 counter
    inc pos
    jmp incrementer1

_continue1:
    mov byte ptr es:[di], 0    ; Null-terminate fname2

    mov ax, @data
    mov ds, ax

    lea dx, fname1
    mov ah, 09h
    int 21h

    lea dx, fname2
    mov ah, 09h
    int 21h

ende:
    mov ax, 4C00h
    int 21h

_error:
    mov ax, 4C01h
    int 21h
end start
