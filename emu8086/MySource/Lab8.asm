; ����������� ������ [������]
printStr macro str
    push ax
    push dx
    
    mov ah,09h ; ����� ������� DOS   
    lea dx,str ; �������� str � DX   
    int 21h    ; 21 ����������
    
    pop dx
    pop ax     
endm

; ����������� ������ [������]
printSymb macro ascii 
   mov ah,06h
   mov dl,ascii
   int 21h 
endm

; ����������� ������ �� �������� [������]
printStrByOffset macro offset
    push ax
    push dx
    
    mov ah,09h    ; ����� ������� DOS   
    mov dx,offset ; �������� � DX   
    int 21h       ; 21 ����������
    
    pop dx
    pop ax     
endm

; ������� ���� [������]
openFile MACRO nameOffset, id 
    mov dx,nameOffset ; ����� ASCIZ-������ � ������ �����
    mov ah,3Dh        ; ������� DOS 3Dh (������� ������������ ����)  
    mov al,02h        ; 02 - ��� ������ � ������
    int 21h           ; ������� ����    
    mov id,ax         ; ��������� ����������
    
    jc openErrorLabel
endm

; ������� ���� [������]
createFile MACRO nameOffset, id 
    mov ah,3Ch        ; ������� DOS 3Ch (������� ����)
    mov ch,00100000b  ; ������� �����
    mov dx,nameOffset ; ����� ASCIZ-������ � ������ �����
    int 21h           ; ������� ����
    mov id,ax         ; ��������� ����������
    
    jc createErrorLabel  
endm    

; ������� ������� [������]
readChars MACRO id, number, buf
    mov ah,3Fh    ; ������� DOS (������ �� �����)
    mov bx,id     ; �������� �����������
    mov cx,number ; ���������� ����������� ��������
    lea dx,buf    ; �������� ������ 
    int 21h       ; ������� ������
    
    jc readingErrorLabel    
endm
 
; �������� ������� [������]
writeChars MACRO id, number, buf
    mov ah,40h    ; ������� DOS (������ � ����)
    mov bx,id     ; ����������
    mov cx,number ; ���������� ������������ ��������
    lea dx,buf    ; ����� 
    int 21h       ; �������� ������
    
    jc writingErrorLabel
endm
 
; ���������� ������ [������]
setCursor MACRO id, distance, type 
    mov ah,42h      ; ������� DOS (����������� ��������� ������/������)
    mov bx,id       ; �������������
    mov cx,0h       ;
    mov dx,distance ;
    mov al,type     ; ������������ ����
    int 21h         ; ����������� ��������� 
    
    jc cursorErrorLabel 
endm

; ������� ���� [������]
closeFile MACRO id
    mov bx,id  ; ����������
    mov ah,3Eh ; ������� DOS 3Eh
    int 21h    ; ������� ����

    jc closeErrorLabel 
endm 

; ������� ���� [������]
deleteFile MACRO nameOffset, labelGood, labelBad
    mov ah,41h        ; ������� DOS 41h (������� ����)
    mov dx,nameOffset ; ����� ASCIZ-������ � ������ ����� 
    int 21h           ; ������� ����
    
    jc deleteErrorLabel  
endm


    .model tiny
    .code         
    org 100h
START: 
    
    mov end_SP,sp ; ���������� SP
    
    ; ��������� ���������� ��������� ������
   ; printStr paramsMessage     ; "��������� ��������� ������:" 
   ;printStr toNewLine         ; �� ����� ������
    ;printStr paramsFormat      ; ������ ����������
    ;printStr toNewLine      
   ; printStr toNewLine     
   ; printStr paramsYourMessage ; ���� ���������  
   ; printStr toNewLine   
   
   printStr Start_Info_String
   printStr New_Line
      
    call processCommandLine    ; ���������� ��������� ��������� ������
    cmp paramsNumber,03h       ; ���������� ������ ���� ���
    je paramsAreNormal
    
    ; �������� � �����������
    printStr toNewLine
    printStr paramsError ; ������
    jmp exit             ; ����� �� ���������
    
    ; � ����������� �� ���������
    paramsAreNormal:
    openFile source_file_offset, source_file_ID            ; ������� �������� ����      
    lea dx, temp_file_name                                 ; ������ �������� ����� 
    mov temp_file_offset, dx                               ; ���������� ����� 
    createFile temp_file_offset,temp_file_ID               ; ������� ��������� ����    
    createFile destination_file_offset,destination_file_ID ; ������� ���� � �����������
    
   ; printStr started
    
    ; ������� ���� 
    mainWhile:
         
        printStr Load_InfoString
        printStr New_Line
         
        ; ���������� ������ ��������
        readChars source_file_ID, buffer_dose, buffer
       
        ; ����� ������ 0Dh � ��������� ������
        search0Dh:
        mov charsRead,ax
        mov cx,charsRead ; ���������� ��������� ��������   
        mov al,0Dh       ; ������ 0Dh 
        lea di,buffer    ; �������� ������
        repne scasb      ; ����������, ���� �� ����� 
        jz Exists0Dh     ; ZF = 1?  
        
        ; ��������, ���� ��� ������� 0Dh
        NotExists0Dh: 
        
            mov dx,charsRead           ; ����� �������� � ������ = 
            mov charsOfStringInDose,dx ; = ����� ��������� ��������
            mov isEndOfString,00h      ; ����� ������ ���
            
            ; ����� ������� NULL � ��������� ������
            mov cx,charsRead          ; ���������� ��������� ��������  
            mov al,0h                 ; ������ NULL
            lea di,buffer             ; �������� ������
            repne scasb               ; ����������, ���� �� �����
            jnz writeCharsInTempFile  ; ZF <> 0?
         
                ; ��������, ���� ���� ������ NULL
                dec charsOfStringInDose  ; charsOfStringInDose--   
                mov isEndOfString,01h    ; ����� ������
                mov isEndOfFile,01h      ; ����� �����
                jmp writeCharsInTempFile
                 
        ; ��������, ���� ���� ������ 0Dh
        Exists0Dh:
        
            ; ����������� ����� �������� ������ � ������
            ; charsOfStringInDose = charsRead - CX + 1   
            mov dx,charsRead 
            mov charsOfStringInDose,dx
            sub charsOfStringInDose,cx
            inc charsOfStringInDose
            mov isEndOfString,01h
        
            ; ���� ����� .. .. .. .. 0Dh, ������ �����������
            ; �� ���� � ������ �� ������ 0Ah
            mov bx,charsOfStringInDose
            mov buffer[bx-1],0Ah
        
        
        ; ������ �������� �� ��������� ����
        writeCharsInTempFile:  
        writeChars temp_file_ID,charsOfStringInDose,buffer ; �������� ������� 
        mov dx,charsOfStringInDose                         ; charactersInString +=
        add charsInString,dx                               ; += charOfStringInDose 
        
        ; ��������, ����� �� ������
        cmp isEndOfString,0h
        je notEndOfString
        
        ; ��������, ���� � ������ ���� ����� ������
        endOfString:
        
            ; ��������� ������� � source_file
            mov bx,charsRead
            mov cursorOffset,bx
            mov bx,charsOfStringInDose
            sub cursorOffset,bx                       ; cursorOffset =
            neg cursorOffset                          ; = -(charsRead - charsOfStringInDose) 
            setCursor source_file_ID,cursorOffset,01h ; ���������� ������
             
             
  
            ; ��������, �������� �� ������ �� ����� ��� �������
            ; "�� ��������� �� ������ ������� �� ��������"
            setCursor temp_file_ID,00h,00h ; ������ �� ������ �����   
            mov dx,charsInString     ; charsInStringCopy =
            mov charsInStringCopy,dx ; charsInString 
            mov dx,buffer_dose       ; ��������
            cmp charsInStringCopy,dx ; charsInStringCopy � buffer_dose
            jbe skipCheckCycle       ; if charsInStringCopy <= buffer_dose  
            
            ; ���� ��������� ��������
            checkCycle:
                readChars temp_file_ID buffer_dose, buffer ; ������� ������� 
                checkBufferMacro buffer_dose               ; ���������
               
                cmp contains,01h
                je Inc_Result  
                
                cmp contains,00h                           ; ���� ������ �� �������� �������
                je continueCheckInCycle                    ; ���������� ��������� ��������
                mov lastStringWasDeleted,01h               ; ����� � ��������� ������ ���� �������
                jmp resetTempfile                          ; �������� ��������� ����
                
                continueCheckInCycle:
                mov dx,buffer_dose       ;
                sub charsInStringCopy,dx ; charsInStringCopy -= buffer_dose  
               
                mov dx,buffer_dose       ; ��������� charsInStringCopy    
                cmp charsInStringCopy,dx ; � buffer_dose 
            ja checkCycle                ; charsInStringCopy > buffer_dose? 
            
            ; charsInStringCopy <= buffer_dose 
            skipCheckCycle: 
            readChars temp_file_ID charsInStringCopy, buffer ; ������� �������
            checkBufferMacro charsInStringCopy               ; ���������
          
            cmp contains,01h
            ;je resetTempfile
            je Inc_Result
            
            
           ; cmp contains,00h                                 ; ���� ������ �� �������� �������
          ;  je transferString                                ; ��������� ������ � �������� ����
            mov lastStringWasDeleted,01h                     ; ����� � ��������� ������ ���� �������
            jmp resetTempfile                                ; �������� ��������� ����
                  
            
            ; �������� ��������� ����
            resetTempfile:                                                      
            mov charsInString,0h           ; charsInString = 0 
            setCursor temp_file_ID,00h,00h ; ������ �� ������ �����
            
        ; ��������, ���� � ������ ��� ����� ������
        notEndOfString:
            mov isEndOfString,0h ; �� ����� ������
            cmp isEndOfFile,01h  ; ���������
        
    jne mainWhile ; ����� �����?
            
    closeFile temp_file_ID      ; ������� ��������� ����
    deleteFile temp_file_offset ; ������� ��������� ����  
    
    
    ; ��������� ��������, ����� ��������� ������
    ; ���� ������� => �� ��� �������� ������ ������
    ; (�� �������� 0Dh,0Ah ���������� ������)
    cmp lastStringWasDeleted,01d ; ���� �� ���� �������
    jne exitSuccessful                     ; �����
     
    setCursor destination_file_ID,00h,00h    ; ���������� ������ �� ����� �����
    readChars destination_file_ID,02h,buffer ; ������� ��� ������� 
    cmp ax,02h                               ; AX - ����� ���������
    jb exitSuccessful                                  ; AX < 2 => �����
      
    mov cursorOffset,02h                           ; 
    neg cursorOffset                               ; cursorOffset = -2
    setCursor destination_file_ID,cursorOffset,02h ; ���������� ������ �� 2 ������� �� �����
    readChars destination_file_ID,02h,buffer       ; ������� � ����� ��� �������
    cmp buffer,0Dh                                 ; ������ ��������� 0Dh?
    jne exitSuccessful                             ; �� 0Dh => ����� ��������
    lea bx,buffer                                  ; �������� ������ � bx
    mov [bx],' '                                   ; ���������� ������� � �������
    mov [bx + 1],' '                               ; �������� ������
    setCursor destination_file_ID,cursorOffset,02h ; ���������� ������ �� 2 ������� �� �����
    writeChars destination_file_ID,02h,buffer      ; �������� 2 ������� �� ������ � ����  
    jmp exitSuccessful                             ; ����� ��������
    
    
    ; ��������� ������
openErrorLabel:  
    printStr openError
    call errorHandler
    jmp exit
    
createErrorLabel: 
    printStr createError
    call errorHandler
    jmp exit
    
readingErrorLabel:  
    printStr readingError
    call errorHandler
    jmp exit
    
writingErrorLabel: 
    printStr writingError
    call errorHandler
    jmp exit
    
cursorErrorLabel:
    printStr cursorError
    call errorHandler
    jmp exit
    
closeErrorLabel:
    printStr closeError
    call errorHandler
    jmp exit 

deleteErrorLabel:
    printStr deleteError
    call errorHandler
    jmp exit  

    ; ���������� ���������
exitSuccessful:
    printStr successfulCompleted
    
exit:
    mov sp,end_SP ; ������������ SP 
    
    
    printStr New_Line
    printStr Result_Info_String 
    Print_Number Result
    
    
    ret           ; ���������� COM-��������� 
    
        
Inc_Result: 
    inc Result
    mov contains, 0d
    jmp resetTempfile
    
    
; [���������] � ��������� � contains
; ���� �� ������� � ������ ������    
checkBuffer PROC near
     ; mov contains,0h 
    
    mov si,0h ; SI = 0 [�������]
    dec si
     for1: 
        inc si
        
        mov isFor1_Or_2, 1
        
        cmp contains, 1d
         je Exit_Loop
         
        cmp si,bufferNumberCheck
        je Exit_Loop    
              
        mov dx,0h         ; DX = 0   
        mov dl,buffer[si] ; DX = ������� ������ �� ������ 
      ;  push si           ; ���������� SI 
      
       ; mov si,0h         ; SI = 0 [�������] 
         
        mov Count_For_FindString, 0d
        mov Count_MainString_Copy, si
        
        push dx
        mov dx,Size_FindString
        mov Size_FindString_Copy, dx
        pop dx
        
        for2: 
           mov Checking_Symbol, dl 
           
           Start_For2: 
            push si
            mov si,Count_For_FindString 
          ;  cmp dl,Find_String[Count_For_FindString]; ��������� ������� �� ������ � 
            
            push dx
            mov dl,Checking_Symbol
            cmp dl,Find_String[si]; 
            pop dx
            
            jne not_equals ; �������� �� ������ ��������   
            
           ;-----���� ������� �����----------------------------  
           
            mov isFor1_Or_2, 2 
           
            pop si
            mov contains,01h   ; contains = 1  
            inc Count_MainString_Copy
            inc Count_For_FindString
            
            push si 
            mov si,Count_MainString_Copy 
           ; mov dl, Find_String[Count_MainString_Copy] 
           
            push dx
           ; mov dl,Checking_Symbol
            mov dl, buffer[si] 
           ; mov dl, Find_String[si]  
            mov Checking_Symbol,dl
            pop dx 
            
            pop si
            
            dec Size_FindString_Copy  ; Size-- �������� �����               
            cmp Size_FindString_Copy,0 ; ���������
            ;jz for1 
            je for1 ; 
            
            jmp Start_For2 
           ;--------------------------------------------------
           
          
                
           ; �� �����
           not_equals:  
           
           cmp isFor1_Or_2, 1
           je  not_eq_For1
                      
           mov contains, 0d 
           pop si       
           
           dec Size_FindString_Copy  ; Size-- �������� �����               
            cmp Size_FindString_Copy,0 ; ���������
            ;jz for1 
            je for1 ;
            
            ;jmp for1
            jmp Start_For2   
                  
          not_eq_For1:
           mov contains, 0d 
           pop si 
           jmp for1

    Exit_Loop:
     ret  
                
checkBuffer endp

; [������] � ���� �� ������� � ������ ������ 
checkBufferMacro MACRO number
    mov dx,number
    mov bufferNumberCheck,dx
    call checkBuffer 
endm 

 ;====================��������� ������ �����====================  

    Print_Number_Proc PROC near 
    
    mov cx,0h ; ���������� ���� � �����
    
    ; ���������� ���� � ���
    pushDigitsWhile:
        mov dx,0h
        mov ax,Number_General ; AX = �����
        div ten              ; DX:AX / ten = DX:AX
   
        mov Number_General,ax ; numberGeneral ��� /= 10

        add dx,48d ; DX += 48 (������� � ASCII)
        push dx ; DX = ������� ����� �����
        
        inc cx ; CX ++  
        
        ; ������� ������ �� �����
        cmp Number_General,0h
    jne pushDigitsWhile 
    
    ; ���������� �� ����� � ������ ����
    printDigitsWhile: 
        mov dx,0h
        mov ax,Number_General ; AX = �����
        div ten              ; DX:AX / ten = DX:AX
   
        mov Number_General,ax ; numberGeneral ��� /= 10

        ; ����� ����� DX 
        ; ���������� ����� ASCII ������� �� DL
        pop dx
        mov ah,06h
        int 21h
        
        
        ; ������� ������ �� �����  
        dec cx
        cmp cx,0h
    jne printDigitsWhile 
  
    ret
    
    Print_Number_Proc endp

   ; ������ - �������� ����� � ��������� [Number_General]  
    Print_Number macro digit    
    
    push ax
    
    mov ax,digit 
    mov Number_General,ax
    call Print_Number_Proc 
                               
    pop ax
    endm      
    ;=================================================================
    
; ����������� ����� ���������� [���������] 
printParamsNumber PROC near
    add paramsNumber,48d
    printSymb paramsNumber
    sub paramsNumber,48d
    printSymb ')'
    printSymb ' '    
    ret
printParamsNumber endp 

; [���������] � ��������� ��������� ������
processCommandLine PROC near  
    cld          ; ��� ������ ��������� ���������       
    mov bp,sp    ; ��������� ������� ������� ����� � BP
    mov cl,[80h] ; ������ ��������� ������
    cmp cl,1     ; �������� ����� ��������� ������
    jle end      ; ����� �� ���������
    
    ; ������������� ������ ���������� � PSP ���, �����
    ; ������ �������� ������������ ����� (ASCIZ-������)
    ; ������ ���� ���������� ��������� � ����
    ; � ���������� paramsNumber �������� ����� ����������
    
    mov cx,0FFFFh ; ��� ������ ������ �� ��������
    mov di,81h ; ������ ��������� ������ � ES:DI
    
find_param:
    cmp paramsNumber, 02d
    je thirdParam
    mov al,' '         ; AL = ������
    repz scasb         ; ������ �� ������
    dec di             ; DI = ����� ������ ��������� 
    push di            ; ��������� ����� � ����
    mov paramOffset,di ; ��� ������� �������� ������ ���������
    inc paramsNumber   ; ��������� paramsNumber �� 1
    mov si,di          ; SI = DI ��� ��������� ������� lodsb
    
scan_params:
    lodsb           ; ��������� ������ �� ���������
    cmp al,0Dh      ; ���� 0Dh � ��������� ��������
    je params_ended ; ��������� �����������
    cmp al,20h      ; ��������� � ��������
    jne scan_params ; ������� �������� �� ����������
    
    
   ; call printParamsNumber       ; ����������� ����� ����������  
    dec si                       ; SI = ������ ���� ����� ��������� 
    mov [si],'$'                 ; �������� � ���� $
   ; printStrByOffset paramOffset ; ����������� ��������
    printStr toNewLine           ; ������� �� ����� ������
    mov [si],0                   ; �������� � ���� 0
    mov di,si                    ; DI = SI ��� ������� scasb
    inc di                       ; DI = ��������� ����� ���� ������
    jmp find_param               ; ���������� ������ ��������� ������
    
params_ended:
    dec si                       ; SI = ������ ���� ����� ����� 
                                 ; ���������� ���������
    mov [si],'$'                 ; �������� � ���� $
  ;  printStrByOffset paramOffset ; ����������� ��������
    printStr toNewLine           ; ������� �� ����� ������
    mov [si],0                   ; �������� � ���� 0

pop_from_stack: 
   ; pop word ptr Find_String 
    
    pop symbolsOffset
    pop destination_file_offset  
    pop source_file_offset 
    
end:     
    mov sp,bp ; ������������ SP  
    ret       ; ����� �� ��������� 
    
thirdParam:    
    cmp [di],0Dh                 ; �������� ������� ������ � ������ ������
    je end                       ; ����� ������ => �����
    push di                      ; �� ����� => ����� ������ symbols
    mov paramOffset,di           ; ��� ������� �������� ������ ��������� 
    mov al,0Dh                   ; ������ ����� ������ ����������
    repnz scasb                  ; ���� ������ ���� �� ������
    dec di                       ; ����� �� ������ 0Dh
    inc paramsNumber             ; ��������� paramsNumber �� 1  
  ;  call printParamsNumber       ; ����������� ����� ����������
    mov [di],'$'                 ; $ ������ 0Dh
  ;  printStrByOffset paramOffset ; ����������� ��������
    printStr toNewLine           ; ������� �� ����� ������
    mov [di],0                   ; 0 ������ $, ������� ������ 0Dh 
    jmp pop_from_stack           ; ������� ��������� �� ����� 
processCommandLine endp   

; ���������-���������� ������
errorHandler PROC near 
    cmp ax,02h
    je open02h 
    cmp ax,03h
    je open03h
    cmp ax,04h
    je open04h
    cmp ax,05h 
    je open05h
    cmp ax,06h
    je open06h
    cmp ax,0Ch
    je open0Ch
    cmp ax,0Fh
    je open0Fh    
    cmp ax,10h
    je open10h
    cmp ax,12h
    je open12h  
    cmp ax,50h
    je open50h        
    jmp errorHandlerExit  
open02h:
    printStr error02hMsg
    jmp errorHandlerExit    
open03h:
    printStr error03hMsg
    jmp errorHandlerExit  
open04h:
    printStr error04hMsg
    jmp errorHandlerExit  
open05h:
    printStr error05hMsg
    jmp errorHandlerExit  
open06h:
    printStr error06hMsg
    jmp errorHandlerExit   
open0Ch:
    printStr error0ChMsg
    jmp errorHandlerExit  
open0Fh:
    printStr error0FhMsg
    jmp errorHandlerExit  
open10h:
    printStr error10hMsg
    jmp errorHandlerExit    
open12h:
    printStr error12hMsg
    jmp errorHandlerExit   
open50h:
    printStr error50hMsg
    jmp errorHandlerExit   
errorHandlerExit:
    ret  
errorHandler endp

; ������ ��������� 
    
    ;****************************************
    ;Info_Strings
    Start_Info_String db 'The program has started execution....$'
    Load_InfoString db 'Loading...Please, wait ^_^$'
    Result_Info_String db 'The number of lines with *WORD*: $'   
    ;Result_Info_String  db 'Result: $'
    ; ������� �������� �� ����� ������ (v,<)    
    New_Line db 0Ah, 0Dh, '$'
   
    ; ����� ��� �������� � ���������
    Number_General dw 0  
    
    isFor1_Or_2 db 0 ; bool - ���������� � ����� 1 - ������ ����, 2 - ������
    
  ;  Find_String db 0 ; ������� ����� 
    Find_String db 'cat' ; ������� ����� 
    
    Count_For_FindString dw 0  ; ������� ��� ����� ������� �� ������������ �����
    Count_MainString_Copy dw 0 ; ������� ��� ��� ����� ������� �� ������
    Size_FindString dw 3 ; ������ �������� �����
    Size_FindString_Copy dw 0
    Result dw 0 ; ���-�� ����� � �������� ������
    
    Checking_Symbol db 0 ; ����������� ������
    ; ��� ��������� �������� ����� 
    TEN dw 10d  
    
    ;****************************************
    
    end_SP dw 0 ; ����� SP ��� ret � �����
    
    ;source_file_name  db 'd:\data.txt',0 ; �������� ����
    source_file_ID     dw 0               ; ����������
    source_file_offset dw 0
    source_file_error  db 0Ah, 0Dh, 'Error opening the source file$' 
    
    ;destination_file_name  db 'd:\result.txt',0 ; ���� � �����������
    destination_file_ID     dw 0                   ; ���������� 
    destination_file_offset dw 0
       
    temp_file_name   db 'temp.txt',0    ; ��������� ����
    temp_file_ID     dw 0               ; ����������    
    temp_file_offset dw 0 
     
    openError    db 0Ah, 0Dh, 'File opening error$' 
    createError  db 0Ah, 0Dh, 'File creation error$' 
    readingError db 0Ah, 0Dh, 'Reading error$'
    writingError db 0Ah, 0Dh, 'Writing error$'
    cursorError  db 0Ah, 0Dh, 'Cursor installation error$'
    closeError   db 0Ah, 0Dh, 'File closing error$'
    deleteError  db 0Ah, 0Dh, 'File deletion error$'
    
    error02hMsg   db 0Ah, 0Dh, '02h - file not found$'  
    error03hMsg   db 0Ah, 0Dh, '03h - path not found$' 
    error04hMsg   db 0Ah, 0Dh, '04h - too much opened files$'
    error05hMsg   db 0Ah, 0Dh, '05h - access denied$'  
    error06hMsg   db 0Ah, 0Dh, '06h - invalid ID$' 
    error0ChMsg   db 0Ah, 0Dh, '0Ch - invalid access mode$'  
    error0FhMsg   db 0Ah, 0Dh, '0Fh - a nonexistent disk is specified$' 
    error10hMsg   db 0Ah, 0Dh, '10h - the current directory cannot be deleted$'       
    error12hMsg   db 0Ah, 0Dh, '12h - invalid access mode$' 
    error50hMsg   db 0Ah, 0Dh, '50h - the file already exists$' 
     
    started             db 0Ah, 0Dh, 'The program has been started$'
    successfulCompleted db 0Ah, 0Dh, 'END PROGRAMM$'  
    
    buffer      db 100 DUP(0) ; ����� ������    
    buffer_dose dw 50d        ; ������ ������
    
    isEndOfFile   db 0 ; [bool] � ����� �� ����� 
    isEndOfString db 0 ; [bool] � ����� �� ������ 
    
    charsRead           dw 0 ; ������� ��������    
    charsOfStringInDose dw 0 ; �������� ������ � ������
    charsInString       dw 0 ; �������� � ������
    
    cursorOffset        dw 0 ; �������� �������
    
    ;symbols           db '0123456789',0 ; �������, ������� ���� �� ������
    symbolsOffset dw 0 ; �������� �� �������, ������� ���� �� ������
    
    bufferNumberCheck    dw 0 ; ���������� �������� �� ������ ��� ��������
    charsInStringCopy    dw 0 ; �������� � ������ (�����)
    contains             db 0 ; [bool] � ���� �� � ������ charsOfStringInDose 
                              ; �������� �� buffer 1 �� �������� symbols     
    lastStringWasDeleted db 0 ; [bool] - ��������� ������ ���� �������                       
                           
    paramsNumber db 0 ; ����� ���������� ��������� ������
    paramOffset  dw 0 ; �������� ��������� 
    
    toNewLine         db 0Ah, 0Dh, '$'                  
    paramsMessage     db 'Command line parameters:$' 
    paramsYourMessage db 'Your parameters:$'     
    paramsError       db 'Please, enter THREE PARAMETERS$' ;
    paramsFormat      db '1 - source file name (exists)',0Ah,0Dh,'2 - destination file name (will be created or overwritten)',0Ah,0Dh,'3 - character set (according to the task condition)$'    
   
end START     

