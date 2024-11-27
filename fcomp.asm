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
    je _continue
    cmp al, ' '  
    je _continue
    cmp pos, 11  
    ja err_label_labely_labelest
    stosb
    inc byte1 
    inc pos
    jmp incrementer

_continue:
    mov byte ptr es:[di], 0 

  
    xor di, di
    mov pos, 0
    lea di, fname2

incrementer1:
    lodsb
    cmp al, 0dh   
    je _continue1
    cmp al, ' '   
    je _continue1
    stosb
    inc byte2     
    inc pos
    jmp incrementer1

err_label_labely_labelest:
    jmp short err_label

_continue1:
    mov byte ptr es:[di], 0

    mov ax, @data
    mov ds, ax

fopen1:
    mov ah, 3Dh
    mov al, 0
    lea dx, fname1
    int 21h
    jc short err_label
    mov fhandle1, ax

fopen2:
    mov ah, 3Dh
    mov al, 0
    lea dx, fname2
    int 21h
    jc short err_label
    mov fhandle2, ax

read_files:
    mov ah, 3Fh
    mov bx, fhandle1
    lea dx, fbuff1
    mov cx, BUFF_SIZE
    int 21h
    jc short err_label
    mov fbuff1_sym, ax

    mov ah, 3Fh
    mov bx, fhandle2
    lea dx, fbuff2
    mov cx, BUFF_SIZE
    int 21h
    jc short err_label

    mov fbuff2_sym, ax

    mov si, 0
    mov di, 0
    cmp fbuff1_sym, 0
    je short check_second_buffer
    cmp fbuff2_sym, 0
    je short fclose_all
    jmp short process_buffers

check_second_buffer:
    cmp fbuff2_sym, 0
    je short fclose_all
    jmp short process_buffers

err_label:
    jmp errr
read_files_label:
    jmp read_files
process_buffers:
    jmp short compare_buffers

compare_buffers:
    cmp si, fbuff1_sym
    jae short check_end_of_buffers
    cmp di, fbuff2_sym
    jae short check_end_of_buffers

    mov al, [fbuff1 + si]
    mov bl, [fbuff2 + di]
    cmp al, bl
    je short no_mismatch


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

    jmp short compare_buffers

check_end_of_buffers:
    cmp si, fbuff1_sym
    jae short read_more_data
    cmp di, fbuff2_sym
    jae short read_more_data

    jmp short compare_buffers

read_more_data:
    jmp short read_files_label

errr:
    lea dx, error_msg
    mov ah, 09h
    int 21h
    jmp short fclose_all

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
