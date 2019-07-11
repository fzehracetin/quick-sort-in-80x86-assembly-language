STACKSG SEGMENT PARA STACK 'STACK'
DW 32 DUP(?)
STACKSG ENDS

DATASG SEGMENT PARA 'DATA' 
ELEMAN DW 0
CR EQU 13
LF EQU 10  
DIZI DB 100 DUP(?)
MSG1 DB CR, LF, 'Sayi girininiz: ',0
MSG3 DB CR, LF, 'Dizinizin eleman sayisini giriniz ', 0
MSG4 DB CR, LF, 'Dizinizin elemanlar (-127, 128) araliginda olmalidir!!!  ', 0 
HATA DB CR, LF, 'Dikkat !!! Sayi vermediniz yeniden giris yapiniz.!!! ',0  
BOSLUK DB CR, LF, 'Siralanmis diziniz:  ', 0
DATASG ENDS

CODESG SEGMENT PARA 'CODE'
ASSUME CS:CODESG, DS:DATASG, SS:STACKSG

ANA PROC FAR

    PUSH DS
    XOR AX,AX
    PUSH AX
    MOV AX, DATASG
    MOV DS,AX
 
     
    MOV AX, OFFSET MSG3  ;dizideki eleman sayisini al
    CALL PUT_STR
    CALL GETN
    MOV ELEMAN, AX
    MOV CX, AX
    PUSH CX 
    XOR AX, AX

L1: 
    MOV AX, OFFSET MSG1 ;sayi alma
    CALL PUT_STR
    CALL GETN  
    MOV BX, 127
    CMP AX, BX
    JG FALSE
    
    MOV BX, -128 
    CMP AX, BX
    JNL TRUE
   
FALSE:    
    MOV AX, OFFSET MSG4  ; aralik hatasi
    CALL PUT_STR 
    JMP L1 
    
TRUE:
    MOV DIZI[SI], AL
    INC SI

LOOP L1    

    XOR SI, SI  
    POP CX
     
    XOR AX, AX
    XOR BX, BX
    XOR DX, DX
    DEC CL
    
    CALL Q_SORT

    XOR SI, SI  
    PUSH CX
    MOV AX, OFFSET BOSLUK
    CALL PUT_STR
    
    MOV CX, ELEMAN

L8: 
    XOR AX, AX
    MOV AL, DIZI[SI]  
    CALL PUTN 
    INC SI

LOOP L8
    POP CX


    RETF
ANA ENDP   

Q_SORT PROC NEAR 
    
    CMP AL, CL  ;left >= right
    JNL L3
    
    PUSH AX
    ADD AL, CL  ; left + right
    SHR AL, 1    ;(left + right)/2  
    
    MOV SI, AX
    MOV BL, DIZI[SI]  ;pivot atamasi
    POP AX 
    PUSH AX
    CALL PARTITION 
    MOV  DL, AL       ; index yeni deger   
    POP AX
    PUSH CX
    MOV CL, DL  ;right yerine index-1 gonderme
    DEC CL                           
    
    CALL Q_SORT
    POP CX
    
    PUSH AX
    MOV AL, DL ; left yerine index gonderme
    
    CALL Q_SORT
    
    POP AX

L3: RET
Q_SORT ENDP  

PARTITION PROC NEAR  

    PUSH CX  
L10:CMP AL, CL      ; left <= right
    JG L7

L4:
    MOV SI, AX       ;left
    CMP DIZI[SI], BL ; dizi[left] < pivot
    JNL L5
    INC AL           ; left++ 

    JMP L4
    
L5:
    MOV SI, CX       ;right
    CMP DIZI[SI], BL ; dizi[right] > pivot
    JNG L6
    DEC CL           ; right-- 
    
    JMP L5
    
L6:
    CMP AL, CL       ; left <= right
    JG L10
    MOV SI, AX       ;left
    MOV DI, CX       ;right
    PUSH DX
    PUSH BX
    XOR BX,BX
    XOR DX,DX
    MOV DL,DIZI[SI]      ;ARR[LEFT]->DL
    MOV BL,DIZI[DI]
    MOV DIZI[SI],BL
    MOV DIZI[DI],DL
    POP BX
    POP DX
    
    DEC CL   ;right--
    INC AL   ;left++
    JMP L10
    
L7: 
    POP CX
    
    
    RET 

PARTITION ENDP

GETC PROC NEAR
    MOV AH,1h
    INT 21H
    RET
GETC ENDP

PUTC PROC NEAR
    PUSH AX
    PUSH DX
    MOV DL, AL
    MOV AH,2
    INT 21H
    POP DX
    POP AX
    RET
PUTC ENDP

GETN PROC NEAR
    
    PUSH BX
    PUSH CX
    PUSH DX

GETN_START:
    
    MOV DX,1
    XOR BX,BX
    XOR CX,CX

NEW:
    
    CALL GETC
    CMP AL,CR
    JE FIN_READ
    CMP AL, '-'
    JNE CTRL_NUM

NEGATIVE:
    
    MOV DX, -1
    JMP NEW

CTRL_NUM:
    
    CMP AL, '0'
    JB error
    CMP AL, '9'
    JA error
    SUB AL,'0'
    MOV BL, AL
    MOV AX,10
    PUSH DX
    MUL CX
    POP DX
    MOV CX,AX
    ADD CX,BX
    JMP NEW

ERROR:
    
    MOV AX, OFFSET HATA
    CALL PUT_STR
    JMP GETN_START

FIN_READ:
    
    MOV AX,CX
    CMP DX,1
    JE FIN_GETN
    NEG AX

FIN_GETN:
    
    POP DX
    POP CX
    POP DX
    RET

GETN ENDP

PUTN	PROC NEAR
		
		PUSH CX
		PUSH DX
		XOR DX,DX
		PUSH DX
		MOV CL,10
		CMP AL,0
		JGE CALC_DIGITS
		NEG AL
		PUSH AX
		MOV AL, '-'
		CALL PUTC
		POP AX

CALC_DIGITS:
		
		DIV CL
		ADD AH, '0'
		MOV DL,AH
		PUSH DX
		XOR AH,AH
		CMP AL,0
		JNE CALC_DIGITS

DISP_LOOP:
		
		POP AX
		CMP AL,0
		JE END_DISP_LOOP
		CALL PUTC
		JMP DISP_LOOP

END_DISP_LOOP:
		
		POP DX
		POP CX
		RET

PUTN	ENDP

PUT_STR PROC NEAR
    
    PUSH BX
    MOV BX, AX
    MOV AL, BYTE PTR[BX]

PUT_LOOP:
    
    CMP AL,0
    JE PUT_FIN
    CALL PUTC
    INC BX
    MOV AL, BYTE PTR[BX]
    JMP PUT_LOOP

PUT_FIN:
    
    POP BX
    RET

PUT_STR ENDP

CODESG ENDS
END ANA