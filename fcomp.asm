.model small
.stack 100h

BUFF_SIZE = 10

.data
    byte1 db 0
    byte2 db 0

    fname1 db 13 dup(?)
    fname2 db 13 dup(?)

    error_msg db 'ERROR OCCURRED', 10, 13, '$'
    mismatch_msg db 'Mismatch: ', '$'
    space db ' , ', '$'
    newline db 10, 13, '$'
    fbuff1 db BUFF_SIZE dup(?)
    fbuff2 db BUFF_SIZE dup(?)
    fbuff1_sym dw 0
    fbuff2_sym dw 0
    fhandle1 dw ?
    fhandle2 dw ?
    dabar_analizuoja_pos dw 0
    index_buffer db 6 dup(0)

.code

start:
    mov ax, @data
    mov es, ax
    mov ds, ax

    mov si, 82h
    lea di, fname1
    mov dabar_analizuoja_pos, 0

incrementer:
    lodsb
    cmp al, 0dh
    je continue1
    cmp al, ' '
    je continue1
    cmp dabar_analizuoja_pos, 11
    ja err_label
    stosb
    inc byte1
    inc dabar_analizuoja_pos
    jmp incrementer

continue1:
    mov byte ptr es:[di], '$'
    xor di, di
    mov dabar_analizuoja_pos, 0
    lea di, fname2

incrementer1:
    lodsb
    cmp al, 0dh
    je continue2
    cmp al, ' '
    je continue2
    stosb
    inc byte2
    inc dabar_analizuoja_pos
    jmp incrementer1

continue2:
    mov byte ptr es:[di], '$'
    mov ax, @data
    mov ds, ax

fopen1:
    mov ah, 3Dh
    mov al, 0
    lea dx, fname1
    int 21h
    jc err_label
    mov fhandle1, ax

fopen2:
    mov ah, 3Dh
    mov al, 0
    lea dx, fname2
    int 21h
    jc err_label
    mov fhandle2, ax
    jmp read_files
errrrr:
    call err_label
read_files:
    mov ah, 42h
    mov al, 0
    mov cx, 0
    mov dx, word ptr dabar_analizuoja_pos
    mov bx, fhandle1
    int 21h
    jc err_label

    mov ah, 3Fh
    mov bx, fhandle1
    lea dx, fbuff1
    mov cx, BUFF_SIZE
    int 21h
    jc err_label
    mov fbuff1_sym, ax

    mov ah, 42h
    mov al, 0
    mov cx, 0
    mov dx, word ptr dabar_analizuoja_pos
    mov bx, fhandle2
    int 21h
    jc err_label

    mov ah, 3Fh
    mov bx, fhandle2
    lea dx, fbuff2
    mov cx, BUFF_SIZE
    int 21h
    jc err_label
    mov fbuff2_sym, ax

    cmp fbuff1_sym, 0
    je check_second_buffer
    cmp fbuff2_sym, 0
    je jump_to_fc_label
    jmp process_buffers

check_second_buffer:
    cmp fbuff2_sym, 0
    je jump_to_fc_label
    jmp process_buffers

err_label:
    lea dx, error_msg
    mov ah, 09h
    int 21h
    jmp close_files

jump_to_fc_label:
    call close_files
    mov ax, 4C00h
    int 21h

process_buffers:
    mov si, 0
    mov di, 0

compare_buffers:
    cmp si, fbuff1_sym
    jae read_next
    cmp di, fbuff2_sym
    jae read_next

    mov al, [fbuff1 + si]
    mov bl, [fbuff2 + di]
    cmp al, bl
    je no_mismatch

    lea dx, mismatch_msg
    mov ah, 09h
    int 21h

    mov dl, al
    mov ah, 02h
    int 21h

    lea dx, space
    mov ah, 09h
    int 21h

    mov dl, bl
    mov ah, 02h
    int 21h

    lea dx, newline
    mov ah, 09h
    int 21h

no_mismatch:
    inc si
    inc di
    inc word ptr dabar_analizuoja_pos
    jmp compare_buffers

read_next:
    jmp read_files

close_files:
    mov ah, 3Eh
    mov bx, fhandle1
    int 21h
    mov ah, 3Eh
    mov bx, fhandle2
    int 21h
    ret

end start
