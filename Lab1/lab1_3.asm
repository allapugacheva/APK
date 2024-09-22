.model small
.stack 100h  

.data

Data1 db 'A'
Data2 db ?                          
sentMsg db "Byte sent", 0Dh, 0Ah, '$'
receiveMsg db "Byte received: $"
errorMsg db "Error", 0Dh, 0Ah, '$'

.code
mov ax, @data                  ; Initialize data
mov ds, ax

mov al, 11000011b              ; Install bits: DLAB - to set frequency divider, BRCON - to stop sending data
mov dx, 3FBh                   ; SDB_ID0, SDB_ID1 - to set amount of sending bits.
out dx, al  

mov al, 0Ch                    ; Install less significant beat of frequency divider.
mov dx, 3F8h
out dx, al
    
mov al, 00h                    ; Install most significant beat of frequency divider. 
mov dx, 3F9h
out dx, al                     ; Setted value - 9600

mov al, 00000011b              ; Uninstall bits: DLAB - to have access to data register, BRCON - to open sending flow
mov dx, 3FBh
out dx, al

waitEmptyTransmitter:          ; Wait 5th bit of LSR register - informs that register of transmitter is ready to
mov dx, 3FDh                   ; receive byte to send.
in al, dx
test al, 20h                   ; Check 5th bit.
jz waitEmptyTransmitter 
           
mov dx, 3F8h                    
mov al, Data1
out dx, al                     ; Send data to the COM2. 

mov dx, 3FDh
in al, dx
test al, 00001110b             ; Check errors.
jnz error

mov ah, 09h
lea dx, sentMsg
int 21h

waitDataEmpty:                 ; Wait 1st bit of LSR register - informs that regitster of receiver is ready to
mov dx, 2FDh                   ; receive sended byte.
in al, dx
test al, 01h                   ; Check 1st bit.
jz waitDataEmpty

mov dx, 2F8h                   
in al, dx                      ; Receive data from the COM1.
mov Data2, al

mov dx, 2FDh
in al, dx
test al, 00001110b             ; Check errors.
jnz error             

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