.model small
.stack 100h

.data

Data1 db 'A'
Data2 db ?

errorMsg db "error",0Dh,0Ah,'$'
sentMsg db "Byte sent",0Dh, 0Ah, '$'
receiveMsg db "Byte received: $"

.code
mov ax, @data
mov ds, ax

mov dx, 0000h         ; Number of COM port.
mov ah, 00h           ; Initialising of COM ports.
mov al, 11100011b     ; Parameters of COM port: speed 9600, no paritet, stop bit lenght - 1, 8 byte in symbol.
int 14h

mov dx, 0001h
mov ah, 00h
mov al, 11100011b
int 14h  

mov dx, 0000h         ; Number of COM port.
mov ah, 01h           ; Sending data.
mov al, Data1
int 14h
jc error              ; Checking errors.
  
test ah, 00001110b    ; If everything was correct register LSR should be empty.
jnz error
                        
mov ah, 09h
lea dx, sentMsg
int 21h   

mov dx, 0001h         ; Number of COM port.
mov ah, 02h           ; Receiving data.
int 14h
jc error              ; Checkint errors.
 
test ah, 00001110b    ; If everything was correct register LSR should be empty.
jnz error               

mov Data2, al

mov ah, 09h
lea dx, receiveMsg
int 21h  
            
mov ah, 02h
mov dl, Data2
int 21h
jmp s0  
          
error: 
mov ah, 09h
lea dx, errorMsg
int 21h 

s0:
mov ax, 4C00h
int 21h      
       
END