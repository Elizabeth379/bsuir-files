; print string [macros]
Print macro str
    push ax
    push dx
    
    mov ah,09h ; number of DOS function
    lea dx,str ; offset str in DX 
    int 21h    ; 21 interruption
    
    pop dx
    pop ax     
endm
 
; print symbol [macros]
printSymb macro ascii 
   mov ah,06h
   mov dl,ascii
   int 21h 
endm

; macros for output aray elementes in console
Output_Array_In_Console macro       
    
    lea si, Array  ; SI offset array "Array"
    mov Array_Counter, 0d ; variable to null 
    
    dec Array_Size ; for index correction�
    
    Print New_Line 
    Print Output_Array_Str 
    
    Output:    
    Print Probel_Str
    Print_Number [si] ; output numbers of array  
    Print Comma_Str 
    add si,2d 
    mov dx, Array_Size
    cmp dx,Array_Counter
    jz End_Macro 
    inc Array_Counter
    jmp Output 
    
    End_Macro:
    inc Array_Size    
endm 

.model small  
 
.code         

; programm begin
START: 
    
    mov ax,@data  
    mov ds,ax          
    mov es,ax        


    
    ;====max length of input number======
    lea di,String_Number ; offset string in DI
    mov al,06d           ; max input length      
    stosb                ; AL in ES:DI 
    ;========================================================
    
    
    ;=================== Task  ===================  
    Print Task_Str
    Print New_Line 
    ;========================================================
     
     
    ;===================Input array size ( 0 < size < 30) ===================   
    Enter_Array_Size:   
     
    Print Enter_ArraySize_Str  
    call Enter_Number  
    Print New_Line     
     
    ; Array_Size = Main_Number  
    mov dx, Main_Number
    mov Array_Size, dx 
     
    cmp Array_Size, 30d; if > 30 elements
    ja Exeption_Array_Size_More_Than_30
     
    cmp Array_Size, 0d; if 0 elements
    jz Exeption_Array_Size_Less_Than_1         
    ;========================================================
    
     
    ;===================Array filling===================   
    
    Print Enter_Numbers_In_Array_Str
    
    mov Array_Counter, 0d
    lea si, Array
    Enter_Numbers_In_Array_Loop_Start: 
    
    mov dx, Array_Counter
    
    cmp dx, Array_Size
    jz After_Entering_Array
    
    Print New_Line 
    Print_Number Array_Counter   
    push si
    call Enter_Number   ; number in Main_Number 
    pop si
     
    mov dx, Main_Number ; number  Main_Number -> Array[index]
    mov [si], dx
    add si, 2d
                           
    inc Array_Counter  ; Index for output  [0],[1]...
    
    jmp Enter_Numbers_In_Array_Loop_Start
    ;========================================================
      
    After_Entering_Array: 
       
    ; algorythm 
    ;====================Main algorythm====================
    lea si, Array  ; SI offset array Array, SI = array start
   
    mov Array_Counter, 0d
    mov Pod_Array_Counter, 0d   
   
    mov ax, Array_Size ; array size in AX
     
    mov dx, 0d
    While: 
    
    cmp ax, Array_Counter
    jz Out_Of_Algoritm
    
    mov Curr_Address, si; � ������� ����� �������� ������� �������, ��������� 
   ; inc Counter ; ��� ������� ������ ���� ����� ������� 
    push si ; ��������� ����� ��������  �������� 
    
    lea si, Array  
    Inside_While:   
            
      cmp ax, Pod_Array_Counter
      jz After_Inside_While 
    
      inc Pod_Array_Counter   
      
      ;add si,2d ; ������� � ����. �������� ������� 
      mov dx,[si] ; � DX = ����. ������� �������
      
      mov bx, Curr_Address  
      mov bx, [bx]
      cmp dx, bx ; ���� ����� �� �������, �� ���� Counter++  
      jz If_Same_Element
      
      Continue: ; � Counter � ��� ���-�� ���������� ��������� �� ������ Curr_Address
      add si,2d ; ������� � ����. �������� ������� 
      jmp Inside_While
    
    After_Inside_While: 
     pop si
     ; � Max_Counter ������� ������������ ���-�� ���������
    
     mov dx, Max_Counter 
     cmp dx, Counter  
     jl Counter_In_MaxCounter     ; ���� Max_Counter <  Counter => Max_Counter = Counter
     
     Posle_Proverki:
     
     add si, 02d
     inc Array_Counter 
     mov Counter, 0d  
     mov Pod_Array_Counter, 0d
     jmp While  
    ;========================================================   
    
    Out_Of_Algoritm:    
    
   ; � Next_Address �������� ����� ������ ������ ����� ������������� ��������
    mov bx, Next_Address 
    mov dx, [bx] 
    
    ; ����� ����������
    
    Print New_Line
    Print Answer_Str   
    Print_Number dx 
    
    Print New_Line
    Output_Array_In_Console ; ������ ��� ������ ��������� ������� �� �������  
      
    Print New_Line   
    Print End_Programm_Str  
    jmp end 
    
    
    
    ;==================== ������ ��� ��������� ====================
    Counter_In_MaxCounter: 
    mov dx, Counter ;   Max_Counter = Counter
    mov Max_Counter, dx
    mov dx, Curr_Address
    mov Next_Address, dx ; � Next_Address �������� ����� ������������� �������
    jmp Posle_Proverki
          
    If_Same_Element: ; ���� ����� �� ������� 
       inc Counter ; ��������� ������� ����� ���������  
       jmp Continue
    ;========================================================
    
      
    ;====================��������� ����� �����====================    
    
    ; �������� ���������, � Main_Number = �������� �����
    Enter_Number PROC near  
        
    pop bp; ��������� � ���� ����� ����������� 
    Enter_Number_Loop_Start:
      
    ; ���� ����� � ������  
    mov ah,0Ah           ; ������� DOS (������� ������ �������� �� STDIN � �����) 
    lea dx,String_Number; �������� ������ � DX
    int 21h       
       
  
    ; ���������� ����� ��������� ����� 
    lea si, String_Number ; �������� � SI ���� ����� String_Number
    inc si     ; SI++  ; �������� �� ���� !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    mov ax, 0d ; �������� AX
    lodsb      ; DS:SI � AL
    mov cx,ax  ; CX = ����� ��������� ����� 
    
    cmp cx, 0d ; ���� ����� = 0, �� Exeption_NumberIsZero -> 
    jz Exeption_NumberIsZero    
    
    mov Main_Number, 0d; ������� ������� ����� 
    ; ����� � AX ������� ������� 10 (TEN) -> 
    ; 1234 -> 4 * 10^0 + 3 * 10^1 + 2 * 10^2 + 1 * 10^3 = 1234
    mov ax, 01d ; ����� � AX ������� ������� 10
    
    NumberStr_In_Number_Loop:
    mov bx, 0d; ������� BX     
    mov si, cx; SI = CX -> ���� � ����� �����, ����� ���� ��� �� �������� ���� DF(�����������)  
    inc si; 
    mov bl, String_Number[si]
    
    ; �������� �� ��, ��� �������� �����(str) �������� ������(int)
    Proverka_Na_SymbolASCII:
    
    cmp bl, 48d; ������ � ����� [ASCII] 48d = 0 
    jl Exeption_Invalid_Number; bl < 48d
    
    cmp bl, 57d; ������ � 9 [ASCII] 57d = 9 
    jg Exeption_Invalid_Number; bl > 57d  
    
    sub bl, 48d; �������� �������� �����, "N" - 48 = N
    
    push ax; ���������� AX
    
    clc; �������� CF
    mul bx; bl = bl * AX -> �������� ����� * 10^ax  ; BX !!!!!
    
    jc Exeption_OverFlow   ; ���� ���� ���� �������� �� mul 
    add Main_Number, ax    ;  Main_Number + ax = ����������� �����
    jc Exeption_OverFlow   ; ���� ���� ���� �������� �� add
      
    pop ax; �������������� AX   
    
    mul TEN; ����������� AX * 10 
    dec cx; ��������� �������
    
    cmp cx,0d
    
    jne NumberStr_In_Number_Loop    
    
    push bp ; ��������� �� ����� ����� ��� ret
    
    ret ;��������� ����, ������ ���� ������� PROC
    
    Enter_Number endp
    ;=======================================================
    
    
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
    
    Print Index_Array_Start_Str
    
    push ax
    
    mov ax,digit 
    mov Number_General,ax
    call Print_Number_Proc 
                               
    Print Index_Array_End_Str
                               
    pop ax
    endm      
    ;=================================================================
    
    ;====================Exeption_Array_Size_More_Than_30==============
    Exeption_Array_Size_More_Than_30:   
    Print New_Line
    Print Exeption_Array_Size_More_Than_30_Str   
    Print New_Line 
    jmp Enter_Array_Size
    ;=======================================================   
    
    ;====================Exeption_Array_Size_Less_Than_1==============
    Exeption_Array_Size_Less_Than_1:   
    Print New_Line
    Print Exeption_Array_Size_Less_Than_1_Str   
    Print New_Line 
    jmp Enter_Array_Size
    ;=======================================================
    
    ;====================Exeption_NumberIsZero==============
    Exeption_NumberIsZero:       
    Print New_Line
    Print Exeption_NumberIsZero_Str   
    Print New_Line 
    jmp Enter_Number_Loop_Start
    ;=======================================================  
    
    ;====================Exeption_OverFlow==============
    Exeption_OverFlow:         
    pop ax; �������������� AX     
    Print New_Line
    Print Exeption_OverFlow_Str   
    Print New_Line 
    jmp Enter_Number_Loop_Start
    ;=======================================================
    
    ;====================Exeption_Invalid_Number==============
    Exeption_Invalid_Number: 
    Print New_Line
    Print Exeption_Invalid_Number_Str   
    Print New_Line 
    jmp Enter_Number_Loop_Start
    ;=======================================================
    
    ;====================����� ���������====================
    end:
    mov ax,4C00h   ; 4C (����� �� ���������) � AH
                   ; 00 (�������� ���������) � AL 
    int 21h        ; ������� DOS "��������� ���������" 
    ;=======================================================
      
; ������� ������  
.data  

   ;Exceptions 
   Exeption_NumberIsZero_Str db "You didn't enter a number, please repeat the input!$"
   Exeption_Invalid_Number_Str db "The number is entered in the wrong format, repeat the input!$"
   Exeption_OverFlow_Str db "Oops, you've caught an overflow(65535), repeat the input!$"
   
   Exeption_Array_Size_More_Than_30_Str db "The size of the array exceeds the allowed size (30)!$"
   Exeption_Array_Size_Less_Than_1_Str db "Array size is less than allowed size(1) !$"
   
   ; Strings
   New_Line db 0Ah, 0Dh, '$'; ������� �� ����� ������
   Enter_ArraySize_Str db "Enter array size ( 1 <= size <= 30):$"
   Enter_Numbers_In_Array_Str db "Enter numbers in array:$"   
   Index_Array_Start_Str db "[$"  
   Index_Array_End_Str db "]$"
   End_Programm_Str db "Programm END.$"   
   
   Task_Str db "Task : Find the most frequently occurring number in the array.$" 
   Answer_Str db "Answer: $"
   ; ������ ��� ��������� ������ �������
   Output_Array_Str db "Array: $"
   Probel_Str db ' $'
   Comma_Str db ',$'
   
   ; ���� �����
   String_Number db 10 DUP(?) ; ������, � ������� ������ �����
   Main_Number dw 0d           ; ��������� ����� (�������������) 
   
   ; ����� ��� �������� � ���������
   Number_General dw 0
   
   ; ������� ��� ����� ����� � ������
   Array_Counter dw 0
   Pod_Array_Counter dw 0
      
   ; ��� ��������� �������� ����� 
   TEN dw 10d 
   
   
   ; ������
   Array_Size dw 10   ; ����������� ����� ��������� �������
   Array dw 40 DUP(?) ; ������ ����� 
   
   
   ; �������� ��������  
   Counter dw 0
   Max_Counter dw 0 
   
   Curr_Address dw 0
   Next_Address dw 0
      
   
   ; ������� �������� �� ����� ������ (v,<)    
   toNewLine db 0Ah, 0Dh, '$' 
   
   ; ������ ��� �������� � ���������
   strGeneral_offset dw 0
   strGeneral_size db 0
      
; ������� ����� (256 ����)      
.stack 100h     

; ����� ���������    
end START     
   