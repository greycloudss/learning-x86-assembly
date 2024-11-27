.model small
.stack 100h

BUFF_SIZE = 10

.data
    fname1               db 'f1.txt', 0
    fname2               db 'f2.txt', 0
    error_msg            db 'Error occurred.', 10, 13, '$'
    fbuff1               db BUFF_SIZE dup(?)
    fbuff1_sym           dw 0
    fbuff2               db BUFF_SIZE dup(?)
    fbuff2_sym           dw 0
    fhandle1             dw ?
    fhandle2             dw ?
    read_byte            db ?
    newline              db 10, 13, '$'
    mismatch_msg         db 'Mismatch: ', '$'
    space                db ' and ', '$'
    dabar_analizuoja_pos dw 0
    index_buffer         db 6 dup(0)  ; Buffer for index string

.code

start:
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
    ; Read from the first file
    mov ah, 3Fh
    mov bx, fhandle1
    lea dx, fbuff1
    mov cx, BUFF_SIZE
    int 21h
    jc short err_label
    mov fbuff1_sym, ax

    ; Read from the second file
    mov ah, 3Fh
    mov bx, fhandle2
    lea dx, fbuff2
    mov cx, BUFF_SIZE
    int 21h
    jc short err_label

    mov fbuff2_sym, ax

    ; Reset indices after reading new buffers
    mov si, 0
    mov di, 0

    ; Check if both buffers are empty
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
    ; Start comparing buffers
    jmp short compare_buffers

compare_buffers:
    ; Check if either buffer is exhausted
    cmp si, fbuff1_sym
    jae short check_end_of_buffers
    cmp di, fbuff2_sym
    jae short check_end_of_buffers

    ; Compare bytes at current positions
    mov al, [fbuff1 + si]
    mov bl, [fbuff2 + di]
    cmp al, bl
    je short no_mismatch

    ; Handle mismatch
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

    ; Convert index to string
    mov ax, dabar_analizuoja_pos
    call dw_to_string

    lea dx, index_buffer
    mov ah, 09h
    int 21h

    lea dx, newline
    mov ah, 09h
    int 21h

no_mismatch:
    ; Increment indices and global mismatch counter
    inc si
    inc di
    inc word ptr dabar_analizuoja_pos

    ; Continue comparing
    jmp short compare_buffers

check_end_of_buffers:
    ; Check if buffers are exhausted and read more data if needed
    cmp si, fbuff1_sym
    jae short read_more_data
    cmp di, fbuff2_sym
    jae short read_more_data

    ; Continue comparison if not exhausted
    jmp short compare_buffers

read_more_data:
    ; Re-read data from both files if one or both buffers are empty
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
    mov cx, 10                ; Base 10 (decimal)
    lea si, index_buffer      ; Point to the buffer
    add si, 5                 ; Move to the end of the buffer
    mov byte ptr [si], '$'    ; Null-terminate the string for DOS interrupt 09h
    dec si
    inc di

convert_loop:
    xor dx, dx                ; Clear DX before DIV
    div cx                    ; Divide AX by 10, remainder in DX
    add dl, '0'               ; Convert remainder to ASCII
    mov [si], dl              ; Store the ASCII digit
    dec si
    cmp ax, 0                 ; If AX == 0, we're done
    jne convert_loop
    inc si                    ; Move to the first character
    ret
dw_to_string endp
end start