.model small
.stack 100h

.data
    byte1 db ?
    byte2 db ?

    fname1 db 128 dup('$')
    fname2 db 128 dup('$')
    
    newline db 10, 13, "$"

.code

start:
    mov ax, @data
    mov ds, ax

    mov ah, 62h
    int 21h
    mov bx, dx


    lea di, fname1
    mov es, bx
    mov si, 82h
    inc si
incrementer:
    mov al, es:[si]
    mov [di], al

    
buf1:
    
    inc si
    inc di

    mov al, es:[si]

    cmp al, 0dh
    je ende
    cmp al, ' '
    jne incrementer

    lea di, fname2
incrementer2:
    mov di, es:[si]


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
end start
