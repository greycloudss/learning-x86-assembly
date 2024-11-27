.model small
.stack 100h

.data
    byte1 db ?
    byte2 db ?

    fname1 db 13 dup(?)
    fname2 db 128 dup('$')
    
    newline db 10, 13, "$"

    pos db 0

.code

start:
    mov ax, @data
    mov es, ax

    mov si, 82h
    ;inc si
;;;skip empty symbols


    lea di, fname1
incrementer:
    lodsb
    cmp al, 0dh
    je _continue
    cmp al, ' '
    je _continue
    cmp pos, 11
    ja _error
    stosb
    inc pos
    jmp incrementer
_continue:
    mov es:[di], 0



    mov ax, @data
    mov ds, ax
    mov ah, 040h
    mov cx, 13
    mov bx, 1
    mov dx, offset fname1



buf2:
    inc si
    inc di
    mov al, es:[si]
    cmp al, 0h
    jne incrementer

    jmp print_buffer
    

print_buffer:
    lea dx, fname1
    mov ah, 09h
    int 21h

    lea dx, newline
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
