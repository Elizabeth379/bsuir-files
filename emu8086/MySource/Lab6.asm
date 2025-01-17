.model small
.stack 100h

.data

InputStrMsg db "Input string:", 13, 10, '$' 
InputSubstrMsg db 0dh, 0ah, "Enter the substring you want to delete:", 13, 10, '$'
InputNewSubstrMsg db 13, 10, "Enter new substring: $"

ResultMsg db 13, 10, "Result: $" 

LengthErrorMsg db 13, 10, "Length(word) > Length(str)$"

string db 200 dup("$") я
				
sbstrToRemove db 200 dup("$")
sbstrToInsert db 200 dup("$")

capacity EQU 200 
flag dw 0                        

.code
main proc
	mov ax, @data
	mov ds, ax
	mov es, ax 


	lea dx, InputStrMsg
	call print


     lea dx, string
	call scan


     lea dx, InputSubstrMsg
	call print
	lea dx, sbstrToRemove
	call scan

	xor cx, cx ; cx = 0
	mov cl, string[1] ; cx = c high + c low
     sub cl, sbstrToRemove[1] 
     js LengthError 
	
	lea dx, InputNewSubstrMsg
	call print
	lea dx, sbstrToInsert
	call scan

 	mov ah, capacity     
	mov string[0], ah    ; первый байт - максимальный размер строки
	mov sbstrToRemove[0], ah 
	mov sbstrToInsert[0], ah     

	xor cx, cx
	mov cl, string[1]
	sub cl, sbstrToRemove[1]
     jb Return
	inc cl
	cld   ; сброс флага направления DF. Теперь обрабатываем строку
		; слева направо

	lea si, string[2]
	lea di, sbstrToRemove[2]

	call ReplaceSubstring
	jmp Return

LengthError:
	mov dx, offset LengthErrorMsg
     call print
Return:   
	lea dx, ResultMsg
     call print
	lea dx, string[2]
     call print

	mov ah, 4ch
	int 21h

	ret
main endp


; ***********************

ReplaceSubstring proc
; цикл обработки строки
StrLoop:
	mov flag, 1
; Передача состояния регистров. 
; На каждой итерации нам надо смещаться по символу
	push si
	push di
	push cx

; теперь в bx адрес si
	mov bx, si

	xor cx, cx
	mov cl, sbstrToRemove[1] ; длина слова

	repe cmpsb ; ищем в строке слово, в ax запишется номер символа
	je FOUND
	jne NOT_FOUND

FOUND:
	call DeleteSubstring ; удаляем его с позиции
	mov ax, bx
	call InsertSubstring ; сразу вставляем на неё новое слово

; переход к следующему слову
	mov dl, sbstrToInsert[1] 
	add string[1], dl        
	mov flag, dx
NOT_FOUND:
	pop cx
	pop di
	pop si
	add si, flag

	Loop StrLoop

	ret
ReplaceSubstring endp  

DeleteSubstring proc
	push si
	push di
	mov cl, string[1]
	mov di, bx

	repe movsb

	pop di
	pop si

	ret                
DeleteSubstring endp

; ***********************

InsertSubstring proc
	lea cx, string[2]   ; адрес первого символа строки
	add cl, string[1]   ; добавляем длину строки, чтобы 
 ; получить следующий символ после последнего
	mov si, cx          ; последний символ в si 
	dec si              ; предпоследний (чтобы вставить на это место)
	mov bx, si          ; сохраняем его адрес в bx
	add bl, sbstrToInsert[1] ; теперь сохраняем последний 
; символ новой строки
	mov di, bx          ; устанавливаем его в качестве получателя             

	mov dx, ax          ; ax - место, куда вставить
	sub cx, dx          ; после последнего место -= место, куда вставить
	std                 ; обрабатываем строку справа налево (DF = 1)
	repe movsb

	lea si, sbstrToInsert[2] ; 1 символ sbstrToInsert
	mov di, ax          ; di - место, куда вставить
	xor cx, cx          
	mov cl, sbstrToInsert[1] ; длину sbstrToInsert поместить в cx
	cld                 ; читаем строку снова слева направо
	repe movsb            

	ret
InsertSubstring endp               

; ***********************

scan proc   
	mov ah, 0Ah ; номер функции, позволяющей вводить с клавиатуры в буфер
	int 21h
	ret
scan endp

; ***********************

print proc
	mov ah, 9 
	int 21h
	ret
print endp

; ************************

end main
