; Programa: Nr. ---
; Užduoties sąlyga: ---
; Atliko: Vardas Pavardė

.model small
.stack 100D
	 
.data
	request		db 'Programa isveda po 1 simbolį visus įvestus simbolius', 0Dh, 0Ah, 'Iveskite simboliu eilute:', 0Dh, 0Ah, '$'
	error_len	db 'Ivesti galite ne daugiau 5 simboliu $'
	result    	db 0Dh, 0Ah, 'Rezultatas:', 0Dh, 0Ah, '$'
	buffer		db 100, ?, 100 dup (0)

.code
 
start:
	MOV ax, @data                   ; perkelti data i registra ax
	MOV ds, ax                      ; perkelti ax (data) i data segmenta
	 
	; Isvesti uzklausa
	MOV ah, 09h
	MOV dx, offset request
	int 21h

	; skaityti eilute
	MOV dx, offset buffer           ; skaityti i buffer offseta 
	MOV ah, 0Ah                     ; eilutes skaitymo subprograma
	INT 21h                         ; dos'o INTeruptas

	; kartoti
	MOV cl, buffer[1]                    ; idedam i bh kiek simboliu is viso

	cmp cl, 0                    ; idedam i bh kiek simboliu is viso
	je error
	 
	; isvesti: rezultatas
	MOV ah, 09h
	MOV dx, offset result
	int 21h
	
	MOV si, offset buffer + 2           ; priskirti source index'ui bufferio koordinates
	xor ch, ch
char:
	LODSB                        	; imti is ds:si stringo dali ir dedame i al 
	 
	MOV ah, 2                    	; isvedimui vieno simbolio
	MOV dl, al                    	; i dl padeti simboli is al
	INT 21h                        	; dos'o INTeruptas

	loop char	 
	JMP ending                      	; jei bh = 0 , programa baigia darba
	 
error:
	MOV ah, 09h
	MOV dx, offset error_len
	INT 21h
	JMP start
	 
ending:
	MOV ax, 4c00h 		        ; griztame i dos'a
	INT 21h                        	; dos'o INTeruptas
	 
end start
