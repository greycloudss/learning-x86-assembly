.model small
.stack 100h

.data
    byte1 db 0             
    byte2 db 0             

    fname1 db 13 dup(?)    
    fname2 db 13 dup(?)    

    newline db 10, 13      

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
    ja _error
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

_continue1:
    mov byte ptr es:[di], 0  

    mov ax, @data
    mov ds, ax

    lea dx, fname1
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
