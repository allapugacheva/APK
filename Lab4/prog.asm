.model small
.stack 500h

.data

    NAMEPAR LABEL BYTE
    MAXLEN      db  10
    ACTLEN      db  ?
    TEMPSTR     db  10 dup ('$')

    VARS        db  '1. Get time', 0Dh, 0AH, '2. Set time', 0Dh, 0AH, '3. Delay', 0Dh, 0AH, '4. Alarm', 0Dh, 0AH, '5. Exit', 0Dh, 0AH, '$'
    FREQS       db  '1. 8KHz 2. 4KHz 3. 2KHz 4. 1KHz 5. 512Hz 6. 256Hz', 0Dh, 0Ah, '7. 128Hz 8. 64Hz 9. 32Hz 10. 16Hz 11. 8Hz 12. 4Hz 13. 2Hz', 0Dh, 0Ah, '$'
    
    ENTERHOURS  db  'Enter hours: $'
    ENTERMINS   db  'Enter minutes: $'
    ENTERSECS   db  'Enter seconds: $'
           
    HOURS       db  ?
    MINS        db  ?
    SECS        db  ?

    HOURSSTR    db  3 dup ('$')
    MINSSTR     db  3 dup ('$')
    SECSSTR     db  3 dup ('$')

    COLON  db  ':$'
    NEWSTR      db  0Dh, 0AH, '$'

    MULT        db  1
    TEN         db  10
    SIXTEN      db  16
    EIGHTEN     DB  1001000b
    DIVISOR     DB  125

    RESSTR      db  10 dup('$') 

    OLDINT      DW  2 DUP(?)
    OLDALINT    DW  2 DUP(?)

    ENTERDELAY  db  'Enter delay: $'
    ENDDELAY    db  'End delay', 0Dh, 0AH, '$'
    DELAY       dd  ?
    
    ALARM       DB  0
    ENDALARM    DB  'End alarm', 0Dh, 0Ah, '$'     
        
.code  
   
    MOV     AX,@DATA
    MOV     DS,AX
   
MENU PROC NEAR
   
    CONTINUING:
    MOV     AH,09h
    LEA     DX,VARS
    INT     21h
   
    MOV     AH,0AH
    LEA     DX,NAMEPAR
    INT     21h
   
    CALL    ATOI
   
    CMP     DL,1
    JNE     S1
    CALL    GET_TIME
    JMP     CONTINUING
   
    S1:
    CMP     DL,2
    JNE     S2
    CALL    SET_TIME
    JMP     CONTINUING
   
    S2:
    CMP     DL,3
    JNE     S3
    CALL    MAKEDELAY
    JMP     CONTINUING
     
    S3:
    CMP     DL,4
    JNE     S4
    CALL    MAKEALARM
    JMP     CONTINUING
    
    S4:   
    MOV     AX,4C00h
    INT     21h
    
    RET 
MENU ENDP
  
ENTER_TIME PROC NEAR
    
    PUSHF
    PUSH    DS
    PUSH    ES
    
    MOV     AH,09h
    LEA     DX,ENTERHOURS
    INT     21h
   
    MOV     AH,0AH
    LEA     DX,NAMEPAR
    INT     21h
   
    CALL    ATOI   
    MOV     HOURS,DL
   
    MOV     AH,09h
    LEA     DX,NEWSTR
    INT     21h
   
    MOV     AH,09h
    LEA     DX,ENTERMINS
    INT     21h
   
    MOV     AH,0AH
    LEA     DX,NAMEPAR
    INT     21h
   
    CALL    ATOI
    MOV     MINS,DL
   
    MOV     AH,09h
    LEA     DX,NEWSTR
    INT     21h
   
    MOV     AH,09h
    LEA     DX,ENTERSECS
    INT     21h
   
    MOV     AH,0AH
    LEA     DX,NAMEPAR
    INT     21h
   
    CALL    ATOI
    MOV     SECS,DL
   
    MOV     AH,09h
    LEA     DX,NEWSTR
    INT     21h  
   
    XOR     AX,AX

    POP     ES
    POP     DS
    POPF
    
    RET 
ENTER_TIME ENDP    

ATOI PROC NEAR
    
    PUSHF
    PUSH    DS
    PUSH    ES
    
    MOV     MULT,10
    MOV     DX,0 
    XOR     CH,CH
    MOV     CL,ACTLEN
            
    LEA     SI,TEMPSTR
   
    S0:
    MOV     AX,DX
    MUL     MULT
    
    MOV     BL,0Fh
    AND     [SI],BL
    ADD     AL,[SI]  
    MOV     DX,AX
   
    INC     SI
    LOOP    S0
    
    POP     ES
    POP     DS
    POPF
    
    RET 
ATOI ENDP

GET_TIME PROC NEAR
    
    PUSHF
    PUSH    DS
    PUSH    ES
    
    MOV     AL,00h
    OUT     70h,AL
   
    IN      AL,71h
  
    CALL    BCDTOA
   
    MOV     CX,2
    LEA     SI,RESSTR
    LEA     DI,SECSSTR
   
    CP0:
    MOV     BL,[SI]
    MOV     [DI],BL
    INC     DI
    INC     SI
    LOOP    CP0 
   
    MOV     AL,02h
    OUT     70h,AL
   
    IN      AL,71h
 
    CALL    BCDTOA
   
    MOV     CX,2
    LEA     SI,RESSTR
    LEA     DI,MINSSTR
   
    CP1:
    MOV     BL,[SI]
    MOV     [DI],BL
    INC     DI
    INC     SI
    LOOP    CP1
   
    MOV     AL,04h
    OUT     70h,AL
   
    IN      AL,71h 
   
    CALL    BCDTOA

    MOV     CX,2
    LEA     SI,RESSTR
    LEA     DI,HOURSSTR
   
    CP2:
    MOV     BL,[SI]
    MOV     [DI],BL
    INC     DI
    INC     SI
    LOOP    CP2
   
    MOV     AH,09h
    LEA     DX,HOURSSTR
    INT     21h
   
    MOV     AH,09h
    LEA     DX,COLON
    INT     21h
   
    MOV     AH,09h
    LEA     DX,MINSSTR
    INT     21h
   
    MOV     AH,09h
    LEA     DX,COLON
    INT     21h
   
    MOV     AH,09h
    LEA     DX,SECSSTR
    INT     21h
   
    MOV     AH,09h
    LEA     DX,NEWSTR
    INT     21h 
   
    XOR     AX,AX
    
    POP     ES
    POP     DS
    POPF
    
    RET 
GET_TIME ENDP

BCDTOA PROC NEAR
    
    PUSHF
    PUSH    DS
    PUSH    ES
    
    DIV     SIXTEN
   
    MOV     BH,AH
    MUL     TEN
    ADD     AL,BH
   
    CALL ITOA  
    
    POP     ES
    POP     DS
    POPF
    
    RET 
BCDTOA ENDP

ITOA PROC NEAR 
    
    PUSHF
    PUSH    DS
    PUSH    ES
    
    LEA     SI, RESSTR
    MOV     CX, 2
   
    S40:
    CMP     AL, TEN
    JB      S5
    DIV     TEN
    OR      AH, 30h
    MOV     [SI], AH
    INC     SI
    DEC     CX
    JMP     S40
   
    S5:
    OR      AL, 30h
    MOV     [SI], AL
    DEC     CX
   
    CMP     CX, 0
    JBE     S51
   
    S52:
    INC     SI
    MOV     BL, '0'
    MOV     [SI], BL
    DEC     CX
    JNZ     S52
     
    S51:  
    LEA     DI, RESSTR
   
    S6:
    MOV     AH, [SI]
    MOV     AL, [DI]
    MOV     [SI], AL
    MOV     [DI], AH
    INC     DI
    DEC     SI
    CMP     DI, SI
    JB      S6
   
    XOR     AX, AX 
    
    POP     ES
    POP     DS
    POPF
    
    RET
ITOA ENDP

SET_TIME PROC NEAR
    
    PUSHF
    PUSH    DS
    PUSH    ES
    
    CALL    ENTER_TIME
   
    CLI
   
    MOV     AL, 0AH
    OUT     70h, AL
   
    WAITSET:   
    IN      AL, 71h
    AND     AL, 10000000b
    CMP     AL, 0  
    JNE     WAITSET 
   
    MOV     AL, 0BH
    OUT     70h, AL
   
    IN      AL, 71h
    OR      AL, 10000000b
   
    OUT     71h, AL
   
    MOV     AL, 00h
    OUT     70h, AL
    
    MOV     AL, SECS
    CALL    ITOBCD
   
    OUT     71h, AL
   
    MOV     AL, 02h
    OUT     70h, AL
   
    MOV     AL, MINS
    CALL    ITOBCD
   
    OUT     71h, AL
   
    MOV     AL, 04h
    OUT     70h, AL
   
    MOV     AL, HOURS
    CALL    ITOBCD
   
    OUT     71h, AL
   
    MOV     AL, 0BH
    OUT     70h, AL
   
    IN      AL, 71h
    AND     AL, 01111111b
   
    OUT     71h, AL
   
    STI  
    
    POP     ES
    POP     DS
    POPF
    
    RET 
SET_TIME ENDP

ITOBCD PROC NEAR
    
    PUSHF
    PUSH    DS
    PUSH    ES
    
    DIV     TEN
   
    MOV     BH, AH
    MUL     SIXTEN
    ADD     AL, BH
    
    POP     ES
    POP     DS
    POPF
   
    RET 
ITOBCD ENDP

DELAY_HANDLER PROC FAR       

    PUSH    AX
    PUSH    DX
    PUSH    DS
    push    ES

    MOV     AX,@DATA           
    MOV     DS,AX            

    PUSHF
    CALL    DWORD PTR OLDINT
    
    CMP     WORD PTR DELAY+2,0
    JE      SUBLOW
    DEC     WORD PTR DELAY+2
    MOV     WORD PTR DELAY,11111111b
    JMP     ENDINT
    
    SUBLOW:
    DEC     WORD PTR DELAY
    
    ENDINT:
    POP     ES      
    POP     DS
    POP     DX
    POP     AX
    
    MOV     AL,20h
    OUT     20h,AL      
   
    IRET
DELAY_HANDLER ENDP 

PRINT_BIN PROC NEAR
    
    PUSHF
    PUSH    DS
    PUSH    ES
          
    MOV     CX,16
   
    PRINTLOOP:
    ROL     AX,1
    JNC     ZERO
    PUSH    AX
    MOV     AH,02h
    MOV     DL,'1'
    INT     21h
    POP     AX
    JMP     NEXT
   
    ZERO: 
    PUSH    AX
    MOV     AH, 02h
    MOV     DL, '0'
    INT     21h
    POP     AX
    
    NEXT:
    LOOP    PRINTLOOP

    MOV     AH,09h
    LEA     DX,NEWSTR
    INT     21h
    
    POP     ES
    POP     DS
    POPF
    
    RET
PRINT_BIN ENDP

MAKEDELAY PROC NEAR
    
    PUSHF
    PUSH    DS
    PUSH    ES
    
    MOV     AH,09H
    LEA     DX,FREQS
    INT     21H
    
    MOV     AH,0AH
    LEA     DX,NAMEPAR
    INT     21H
    
    CALL    ATOI
    ADD     DL,1
    MOV     CL,DL
    SHR     EIGHTEN,CL
    
    ADD     CL,3
   
    MOV     AL,0AH
    OUT     70h,AL
   
    IN      AL,71h
    AND     AL,11110000b
    OR      AL,CL
    OUT     71h,AL    
    
    MOV     AH,09h
    LEA     DX,ENTERDELAY
    INT     21h
   
    MOV     AH,0AH
    LEA     DX,NAMEPAR
    INT     21h
   
    MOV     AH,09h
    LEA     DX,NEWSTR
    INT     21h
    
    MOV     WORD PTR DELAY,0
    MOV     WORD PTR DELAY+2,0
    
    CMP     ACTLEN,3
    JBE     SETINT
    MOV     AL,ACTLEN
    SUB     AL,3
    MOV     ACTLEN,AL
    CALL    ATOI
    
    MOV     AX,DX
    XOR     DX,DX
    MUL     EIGHTEN
    MOV     WORD PTR DELAY,AX
    MOV     WORD PTR DELAY+2,DX   
    
    SETINT:
    CLI
    
    MOV     AX,351Ch
    INT     21h
   
    MOV     [OLDINT],BX
    MOV     [OLDINT+2],ES

    MOV     DX,OFFSET DELAY_HANDLER
    PUSH    DS
    PUSH    CS
    POP     DS
       
    MOV     AX,251Ch
    INT     21h
    
    POP     DS     
    
    STI
   
    MOV     AL,0BH
    OUT     70h,AL
   
    IN      AL,71h
    OR      AL,01000000b
    OUT     71h,AL
   
    WAITDELAY:
    CMP     WORD PTR DELAY+2,0
    JA      WAITDELAY
    CMP     WORD PTR DELAY,0
    JA      WAITDELAY
    
    MOV     AL,0BH
    OUT     70h,AL
   
    IN      AL,71h
    AND     AL,10111111b
    OUT     71h,AL
    
    CLI
    
    MOV     DX,[OLDINT]
    MOV     BX,[OLDINT+2]
    
    PUSH    DS
    MOV     DS,BX
   
    MOV     AX,2570h
    INT     21h
    
    POP     DS 
    
    STI
    
    MOV     AH,09h
    LEA     DX,ENDDELAY
    INT     21h  
    
    POP     ES
    POP     DS
    POPF
    
    RET
MAKEDELAY ENDP

MAKEALARM PROC NEAR
    
    PUSHF
    PUSH    DS
    PUSH    ES
    
    MOV     ALARM,0
    CALL    ENTER_TIME
    
    MOV     AL,SECS
    CALL    ITOBCD
    MOV     SECS,AL
    
    MOV     AL,MINS
    CALL    ITOBCD
    MOV     MINS,AL
    
    MOV     AL,HOURS
    CALL    ITOBCD
    MOV     HOURS,AL

    CLI
    
    MOV     AX,351Ch
    INT     21h
        
    MOV     [OLDALINT],BX
    MOV     [OLDALINT+2],ES 
    
    MOV     DX, OFFSET ALARM_HANDLER
    PUSH    DS
    PUSH    CS
    POP     DS
    
    MOV     AX, 251Ch
    INT     21h
    
    POP     DS
    
    STI      
    
    POP     ES
    POP     DS
    POPF
    
    RET
MAKEALARM ENDP

ALARM_HANDLER PROC FAR
    
    PUSH    AX
    PUSH    DX
    PUSH    DS
    push    ES

    MOV     AX,@DATA           
    MOV     DS,AX            

    PUSHF
    CALL    DWORD PTR OLDALINT
    
    MOV     AL,00h
    OUT     70h,AL   
    IN      AL,71h
    
    CMP     AL,SECS
    JB      ENDALINT
    
    MOV     AL,02H
    OUT     70H,AL
    IN      AL,71H
    
    CMP     AL,MINS
    JB      ENDALINT
    
    MOV     AL,04H
    OUT     70H,AL
    IN      AL,71H
    
    CMP     AL,HOURS
    JB      ENDALINT    
    
    MOV     AH,09H
    LEA     DX,ENDALARM
    INT     21H
    
    CMP     ALARM,1
    
    CLI
    
    MOV     DX,[OLDALINT]
    MOV     BX,[OLDALINT+2]
    
    PUSH    DS
    MOV     DS,BX
      
    MOV     AX,251Ch
    INT     21h
    
    POP     DS
    
    STI
    
    ENDALINT:             
    
    POP     ES      
    POP     DS
    POP     DX
    POP     AX     

    MOV     AL,20h
    OUT     20h,AL 
    
    IRET
ALARM_HANDLER ENDP
         
END