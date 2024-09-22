.model small
.stack 100h

.data

    OLDINT      DW  2 DUP (?)
    ERRORMSG    DB  'Error$', 13, 10 
    NEWSTR      DB  13, 10, '$'
    EXIT        DB  0
    REPEAT      DB  0

.code

    MOV     AX,@DATA
    MOV     DS,AX
                          
START PROC FAR    
    
    MOV     AX,3509h
    INT     21h
        
    MOV     [OLDINT],BX
    MOV     [OLDINT+2],ES 
    
    MOV     DX, OFFSET NEW_INT
    PUSH    DS
    PUSH    CS
    POP     DS
    
    MOV     AX, 2509h
    INT     21h
    
    POP     DS
    
    CYCLE:     
    
    CALL    DELAY    
    MOV     DL,0EDh
    CALL    LOAD_BITE
    MOV     DL,0100b
    CALL    LOAD_BITE
  
    CALL    DELAY   
    MOV     DL,0EDh
    CALL    LOAD_BITE
    MOV     DL,0
    CALL    LOAD_BITE   
    
    MOV     AH,09h
    LEA     DX, NEWSTR
    INT     21h
    
    CMP     EXIT,1
    JE      ENDINT
          
    jmp cycle
               
    ERROR:
    MOV     AH,09h
    LEA     DX,ERRORMSG
    INT     21h
             
    ENDINT:                         
    
    MOV     DX,[OLDINT]
    MOV     BX,[OLDINT+2]
    
    PUSH    DS
    MOV     DS,BX
      
    MOV     AX,2509h
    INT     21h
    
    POP     DS                      
    
    MOV     AX,4C00h
    INT     21h
        
    RET
START ENDP

LOAD_BITE PROC NEAR
    
    KEYWAIT: 
    IN      AL,64h
    TEST    AL,010b
    JNZ     KEYWAIT  
      
    MOV     CX,3
            
    LOADBITE: 
    MOV     REPEAT, 0  
    DEC     CX
    JZ      ERROR  
            
    MOV     AL,DL
    OUT     60h,AL
   
    CMP     REPEAT,1
    JE      LOADBITE
   
    RET 
LOAD_BITE ENDP

DELAY PROC NEAR 
   
    MOV     AH,86h
    MOV     CX,0000000000001100b
    MOV     DX,1101010000000000b
    INT     15h   
   
    RET
DELAY ENDP
      
NEW_INT PROC FAR
    
    PUSH    AX
    push    CX
    PUSH    DX
    PUSH    DS
    push    ES

    MOV     AX,@DATA           
    MOV     DS,AX            

    PUSHF
    CALL    DWORD PTR OLDINT
        
    IN      AL,60h
    MOV     AH,AL
   
    CMP     AH,10h
    JNE     CONT
    MOV     EXIT,1
   
    JMP     ENDINT
      
    CONT:
    MOV     BX,AX
    MOV     CX,2
   
    PRINTLOOP:
    ROL     BX,4
    MOV     AX,BX
    AND     AX,000Fh
    CMP     AX,10
    JL      PRINTDIGIT
   
    ADD     AL,7
    PRINTDIGIT:
    ADD     AL,'0'
    MOV     DL,AL
    MOV     AH,02h
    INT     21h
    
    LOOP    PRINTLOOP
   
    MOV     AH,02h
    MOV     dl,' '
    INT     21h
     
    CMP     AH,0FEh
    JNE     ENDINT
    MOV     REPEAT,1
   
    ENDINT:
   
    POP     ES      
    POP     DS
    POP     DX
    POP     CX
    POP     AX         
         
    IRET
NEW_INT ENDP         

END