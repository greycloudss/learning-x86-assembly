.model small
.stack 100h

.data
    request db 'Input string: ', 10, 13, '$'
    errorr   db 'Invalid input $'
    result  db 10, 13, 'Result: ', 10, 13, '$'
    buffer  db 100, ?, 100 dup (0)
.code

start:
    mov ax, @data
    mov ds, ax

    mov ah, 09h
    mov dx, offset request
    int 21h

    mov dx, offset buffer
    mov ah, 0Ah
    int 21h

    MOV ah, 09h
	MOV dx, offset result
	int 21h

    mov cl, buffer[1]
    
    mov si, offset buffer + 2
    xor ch, ch

char:
    LODSB

    MOV ah, 2
    
    cmp al, 61h
    jb notLwr

    cmp al, 7ah
    ja notLwr

    sub al, 20h
    jmp norLNorH

notLwr:
    cmp al, 41h
    jb norLNorH

    cmp al, 5Ah
    ja norLNorH

    add al, 20h
    
norLNorH:
    mov ah, 2
    mov dl, al
    int 21h

    loop char

exit:
    mov ax, 4c00h
    int 21h
end start