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
    
    output_fname         db 'output.txt', 0
    output_handle        dw ?

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
    je continue1
    cmp al, ' '  
    je continue1
    cmp pos, 11  
    ja jump_to_err_label
    stosb
    inc byte1 
    inc pos
    jmp incrementer

continue1:
    mov byte ptr es:[di], 0 

    xor di, di
    mov pos, 0
    lea di, fname2

incrementer1:
    lodsb
    cmp al, 0dh   
    je continue2
    cmp al, ' '   
    je continue2
    stosb
    inc byte2     
    inc pos
    jmp incrementer1

jump_to_err_label:
    jmp err_label

continue2:
    mov byte ptr es:[di], 0

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

read_files:
    ; Seek to dabar_analizuoja_pos for file 1
    mov ah, 42h       ; Seek function
    mov al, 0         ; Seek from the beginning
    mov cx, 0         ; High word of offset
    mov dx, word ptr dabar_analizuoja_pos ; Low word of offset
    mov bx, fhandle1  ; File handle
    int 21h
    jc err_label ; Handle error

    ; Read data into fbuff1
    mov ah, 3Fh
    mov bx, fhandle1
    lea dx, fbuff1
    mov cx, BUFF_SIZE
    int 21h
    jc err_label
    mov fbuff1_sym, ax ; Store number of bytes read

    ; Seek to dabar_analizuoja_pos for file 2
    mov ah, 42h
    mov al, 0
    mov cx, 0
    mov dx, word ptr dabar_analizuoja_pos
    mov bx, fhandle2
    int 21h
    jc err_label

    ; Read data into fbuff2
    mov ah, 3Fh
    mov bx, fhandle2
    lea dx, fbuff2
    mov cx, BUFF_SIZE
    int 21h
    jc err_label
    mov fbuff2_sym, ax ; Store number of bytes read

    mov si, 0
    mov di, 0
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
    jmp errr
jump_to_fc_label:
    call fclose_all
    jmp program_end
read_files_label:
    jmp read_files
process_buffers:
    jmp compare_buffers

compare_buffers:
    cmp si, fbuff1_sym
    jae check_end_of_buffers_label
    cmp di, fbuff2_sym
    jae check_end_of_buffers_label

    mov al, [fbuff1 + si]
    mov bl, [fbuff2 + di]
    cmp al, bl
    je no_mismatch

    ; Write mismatch message to output.txt
    lea dx, mismatch_msg
    mov ah, 42h        ; Write to file function
    mov bx, output_handle
    mov cx, 15         ; Length of mismatch_msg
    int 21h

    ; Write mismatched character from fbuff1
    mov dl, al
    mov byte ptr [fbuff1], dl
    lea dx, fbuff1
    mov cx, 1
    mov ah, 42h
    mov bx, output_handle
    int 21h

    ; Write separator
    lea dx, space
    mov ah, 42h
    mov bx, output_handle
    mov cx, 3
    int 21h

    ; Write mismatched character from fbuff2
    mov dl, bl
    mov byte ptr [fbuff2], dl
    lea dx, fbuff2
    mov cx, 1
    mov ah, 42h
    mov bx, output_handle
    int 21h
    jmp pos_writing
check_end_of_buffers_label:
    jmp check_end_of_buffers
pos_writing:
    ; Convert position to string and write it
    mov ax, dabar_analizuoja_pos
    call dw_to_string
    lea dx, index_buffer
    mov ah, 40h
    mov bx, output_handle
    mov cx, 6
    int 21h

    ; Write newline
    lea dx, newline
    mov ah, 40h
    mov bx, output_handle
    mov cx, 2
    int 21h

no_mismatch:
    inc si
    inc di
    inc word ptr dabar_analizuoja_pos
    jmp compare_buffers

check_end_of_buffers:
    cmp si, fbuff1_sym
    jae read_more_data
    cmp di, fbuff2_sym
    jae read_more_data

    jmp compare_buffers

read_more_data:
    jmp read_files_label

errr:
    lea dx, error_msg
    mov ah, 09h
    int 21h
    jmp fclose_all

fclose_all proc
    mov ah, 3Eh
    mov bx, fhandle1
    int 21h
    mov ah, 3Eh
    mov bx, fhandle2
    int 21h
fclose_all endp

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
