.model small
.stack 100h

BUFF_SIZE = 10

.data
 fname1      db 'f1.txt', 0
 fname2      db 'f2.txt', 0
 error_msg   db 'error', 10, 13, '$'
 fbuff1      db BUFF_SIZE dup(?)
 fbuff1_sym  dw 0
 fbuff2      db BUFF_SIZE dup(?)
 fbuff2_sym  dw 0
 fhandle1    dw ?
 fhandle2    dw ?
 read_byte   db ?
 newline     db 10, 13, '$'
 comma       db ' , '
 dabar_analizuoja_pos dw 0


.code
start:
    mov ax, @data
    mov ds, ax

fopen1:
    mov ah, 3Dh
    mov al, 0
    lea dx, fname1
    int 21h

    jc errr
    mov fhandle1, ax

fopen2:
    mov ah, 3Dh
    mov al, 0
    lea dx, fname2
    int 21h

    jc fclose_all
    mov fhandle2, ax

read_files:
    mov ah, 3Fh
    mov bx, fhandle1
    lea dx, fbuff1
    mov cx, BUFF_SIZE
    int 21h
    jc error_msg

    ;cmp ax, 0
    ;je fclose_all
    mov buff1_sym, ax
    mov read_byte, al

    mov ah, 3Fh
    mov bx, fhandle2
    lea dx, fbuff2
    mov cx, BUFF_SIZE
    int 21h
    jc error_msg

    ;cmp ax, 0
    ;je fclose_all
    mov buff2_sym, ax

    cmp buff1_sym, 0
    jne ok
    cmp buff2_sym, 0
    jne ok
    jmp fclose_all

ok:
;;;ciklas per simbolius
;;;inc dabar_analizuoja_pos


    mov al, [fbuff1]
    cmp al, [fbuff2]
    jne output_mismatch
    
    jmp read_files

output_mismatch:
    mov dl, [fbuff1]
    mov ah, 02h
    int 21h

    lea dx, comma
    mov ah, 09h
    int 21h

    mov dl, [fbuff2]
    mov ah, 02h
    int 21h

    lea dx, newline
    mov ah, 09h
    int 21h

    jmp read_files

fclose_all:
    mov ah, 3Eh
    mov bx, fhandle1
    int 21h

    mov ah, 3Eh
    mov bx, fhandle2
    int 21h

program_end:
    mov ax, 4C00h
    int 21h

errr:
    lea dx, error_msg
    mov ah, 09h
    int 21h

    jmp program_end
end start
