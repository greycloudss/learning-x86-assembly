
.model small
.stack 100

.data
    file1 db "1st file: ", 10, 13, '$'
    file2 db "2nd file: ", 10, 13, '$'
    errr db "error", 10, 13, '$'

    buf1 db 100, ?, 100 dup (0)
    buf2 db 100, ?, 100 dup (0)

.code

start:
    mov ax, @data
    mov ds, ax

    mov ah, 09h
    mov dx, offset file1
    int 21h

    mov dx, offset buf1
    mov ah, 0Ah
    int 21h

    mov ah, 09h
    mov dx, offset file2
    int 21h

    mov dx, offset buf2
    mov al, 0Ah
    int 21h

    lea dx, al
    mov ah, 09h
    int 21h

    jmp exit


exit:
    mov ax, 4c00h
    int 21h
end start