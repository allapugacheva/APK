.model small
.stack 100h

.data

ch0str db ' channel 0 word', 0Dh, 0Ah, '$'
ch1str db ' channel 1 word', 0Dh, 0Ah, '$'
ch2str db ' channel 2 word', 0Dh, 0Ah, '$'

df0str db ' division factor channel 0', 0Dh, 0Ah, '$'
df1str db ' division factor channel 1', 0Dh, 0Ah, '$'
df2str db ' division factor channel 2', 0Dh, 0Ah, '$'  
           
base_high dw 0000000000010010b
base_low dw 0011010011011100b           
divs dw 196, 261, 329, 196, 261, 329, 196, 261, 329

.code 
mov ax, @data
mov ds, ax
  
jmp start_prog 

print_bin proc       
   mov cx, 8
   
print_loop:
   rol al, 1
jnc zero_result
   push ax
   mov ah, 02h
   mov dl, '1'
   int 21h
   pop ax
jmp inc_loop
   
zero_result: 
   push ax
   mov ah, 02h
   mov dl, '0'
   int 21h
   pop ax
    
inc_loop:
loop print_loop

   ret
print_bin endp
     
     
print_data proc
   
   mov al, 11100010b
   out 43h, al
   
   in al, 40h
   call print_bin 
       
   mov ah, 09h
   lea dx, ch0str
   int 21h
   
   mov al, 11100100b
   out 43h, al
   
   in al, 41h
   call print_bin
   
   mov ah, 09h
   lea dx, ch1str
   int 21h   
   
   mov al, 11101000b
   out 43h, al  
   
   in al, 42h
   call print_bin
   
   mov ah, 09h
   lea dx, ch2str
   int 21h
   ret
print_data endp
   
   
print_hex proc
   mov bx, ax
   mov cx, 4
   
print_hex_loop:
   rol bx, 4
   mov ax, bx
   and ax, 000Fh
   cmp ax, 10
jl print_digit
   add al, 7
print_digit:
   add al, '0'
   mov dl, al
   mov ah, 02h
   int 21h   
loop print_hex_loop
              
   ret           
print_hex endp
    
      
start_prog: 
   
   mov cx, 9       
   lea si, [divs]
   
sound:    
   push cx
   
   mov al, 10110110b
   out 43h, al
            
   mov ax, base_low
   mov dx, base_high
   mov bx, [si]
   div bx         
            
   out 42h, al
   mov al, ah
   out 42h, al
   
   in al, 61h
   or al, 00000011b
   out 61h, al
           
   mov ah, 86h
   mov cx, 0000000000000110b
   mov dx, 0001101010000000b
   int 15h      
         
   in al, 61h
   and al, 11111100b
   out 61h, al         
         
   pop cx
   
   inc si
   inc si             
loop sound 

   call print_data
   
   mov al, 00000000b
   out 43h, al

   mov al, 00110110b
   out 43h, al
   
   in al, 40h
   mov bl, al
   in al, 40h
   mov ah, al
   mov al, bl
   
   call print_hex
   
   mov ah, 09h
   lea dx, df0str
   int 21h
   
   mov al, 01000000b
   out 43h, al
   
   mov al, 01110110b
   out 43h, al
   
   in al, 41h
   mov bl, al
   in al, 41h
   mov ah, al
   mov al, bl
   
   call print_hex
   
   mov ah, 09h
   lea dx, df1str
   int 21h
   
   mov al, 10000000b
   out 43h, al
   
   mov al, 10110110b
   out 43h, al
   
   in al, 42h
   mov bl, al
   in al, 42h
   mov ah, al
   mov al, bl
   
   call print_hex
   
   mov ah, 09h
   lea dx, df2str
   int 21h     
            
   mov ax, 4C00h
   int 21h

end