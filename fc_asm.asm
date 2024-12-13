.model small
.stack 100h

BUFF_SIZE = 10

.data
    byte1 db 0
    byte2 db 0

    fname1 db 13 dup(?) 
    fname2 db 13 dup(?) 

    error_msg            db 'error', 10, 13, '$'
    fbuff1               db BUFF_SIZE dup(?)
    fbuff1_sym           dw 0
    
    fbuff2               db BUFF_SIZE dup(?)
    fbuff2_sym           dw 0

    fhandle1             dw ?
    fhandle2             dw ?

    newline              db 10, 13, '$'
    mismatch_msg         db 'not matching: ', ' $'
    space                db ' , ', '$'
    dabar_analizuoja_pos dw 0
    index_buffer         db 6 dup(0)

    pos db 0

    ended1 db 0
    ended2 db 0

.code

start:
    mov ax, @data
    mov es, ax 
    mov si, 82h
    lea di, fname1
    mov pos, 0

incrementer:
    lodsb
    cmp al, 0dh  
    je continue_fname1
    cmp al, ' '
    je continue_fname1
    cmp pos, 11  
    ja err_label_labely_labelest
    stosb
    inc byte1 
    inc pos
    jmp incrementer

continue_fname1:
    mov byte ptr es:[di], 0 
    xor di, di
    mov pos, 0
    lea di, fname2

incrementer1:
    lodsb
    cmp al, 0dh   
    je continue_fname2
    cmp al, ' '   
    je continue_fname2
    stosb
    inc byte2     
    inc pos
    jmp incrementer1

err_label_labely_labelest:
    jmp err_label

continue_fname2:
    mov byte ptr es:[di], 0
    mov ax, @data
    mov ds, ax

fopen1:
    mov ah, 3Dh
    mov al, 0
    lea dx, fname1
    int 21h
    jc errjmp
    mov fhandle1, ax

fopen2:
    mov ah, 3Dh
    mov al, 0
    lea dx, fname2
    int 21h
    jc errjmp
    mov fhandle2, ax

read_files:
    cmp ended1,0
    jne skip_read1
    mov ah, 42h
    mov al, 0
    mov cx, 0
    mov dx, word ptr dabar_analizuoja_pos
    mov bx, fhandle1
    int 21h
    jc errjmp
    mov ah, 3Fh
    mov bx, fhandle1
    lea dx, fbuff1
    mov cx, BUFF_SIZE
    int 21h
    jc errjmp
    mov fbuff1_sym, ax
    cmp fbuff1_sym,0
    jne noend1
    mov ended1,1
    mov cx, BUFF_SIZE
    mov di,offset fbuff1
    xor ax,ax
zerofill1:
    mov [di],al
    inc di
    loop zerofill1
noend1:

skip_read1:
    cmp ended1,1
    jne done1
    mov fbuff1_sym, BUFF_SIZE
    jmp done1
errjmp:
    jmp errlvl
done1:

    cmp ended2,0
    jne skip_read2
    mov ah, 42h
    mov al, 0
    mov cx, 0
    mov dx, word ptr dabar_analizuoja_pos
    mov bx, fhandle2
    int 21h
    jc errlvl
    mov ah, 3Fh
    mov bx, fhandle2
    lea dx, fbuff2
    mov cx, BUFF_SIZE
    int 21h
    jc errlvl
    mov fbuff2_sym, ax
    cmp fbuff2_sym,0
    jne noend2
    mov ended2,1
    mov cx, BUFF_SIZE
    mov di,offset fbuff2
    xor ax,ax
zerofill2:
    mov [di],al
    inc di
    loop zerofill2
noend2:

skip_read2:
    cmp ended2,1
    jne done2
    mov fbuff2_sym, BUFF_SIZE
done2:

    cmp ended1,1
    jne c1
    cmp ended2,1
    jne c1
    jmp fclose_all

c1:
    mov si,0
    mov di,0
    jmp process_buffers

process_buffers:
    jmp compare_buffers
errlvl:
    jmp errr
compare_buffers:
    cmp si, fbuff1_sym
    jae read_more_data
    cmp di, fbuff2_sym
    jae read_more_data
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
    mov ax, dabar_analizuoja_pos
    call dw_to_string
    lea dx, index_buffer
    mov ah, 09h
    int 21h
    lea dx, newline
    mov ah, 09h
    int 21h

no_mismatch:
    inc si
    inc di
    inc word ptr dabar_analizuoja_pos
    jmp compare_buffers
erra:
    jmp errr
read_more_data:
    cmp si, fbuff1_sym
    jae more_f1
    cmp di, fbuff2_sym
    jae more_f2
    jmp compare_buffers

more_f1:
    cmp ended1,1
    je more_f2
    jmp read_files_label

more_f2:
    cmp ended2,1
    je fclose_all
    jmp read_files_label

read_files_label:
    jmp read_files

err_label:
    jmp errr

errr:
    lea dx, error_msg
    mov ah, 09h
    int 21h
    jmp fclose_all

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

dw_to_string proc
    mov cx, 10
    lea si, index_buffer
    add si, 5
    mov byte ptr [si], '$'
    dec si
convert_loop:
    xor dx, dx
    div cx
    add dl, '0'
    mov [si], dl
    dec si
    cmp ax, 0
    jne convert_loop
    inc si
    ret
dw_to_string endp

end start
