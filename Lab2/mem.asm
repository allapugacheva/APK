code segment
     assume cs:code, ds:code
     org 100h
        
start:  
jmp install_handler 

print_bin proc       
   mov cx, 8
   
print_loop:
   rol al, 1
   jnc zero_result
   mov byte ptr es:[di], '1'
   jmp inc_loop
   
zero_result:
   mov byte ptr es:[di], '0'
    
inc_loop:
   inc di
   inc di
   loop print_loop

   ret
print_bin endp

print_data proc
   mov ax, 0B800h
   mov es, ax 
            
   mov di, 0
   xor ax, ax
   
   mov al, 0Ah
   out 20h, al
   
   mov dx, 20h
   in al, dx
    
   call print_bin
   
   mov byte ptr es:[di], ' '
   inc di
   inc di
   
   mov al, 0Ah
   out 0A0h, al
   
   mov dx, 0A0h
   in al, dx
   
   call print_bin 
   
   mov byte ptr es:[di], ' '
   inc di
   inc di  
               
   mov byte ptr es:[di], 'I'
   inc di
   inc di
   mov byte ptr es:[di], 'R'
   inc di
   inc di
   mov byte ptr es:[di], 'Q'
   
   add di,120
   
   mov al, 0Bh
   out 20h, al
   
   mov dx, 20h
   in al, dx
    
   call print_bin
   
   mov byte ptr es:[di], ' '
   inc di
   inc di
   
   mov al, 0Bh
   out 0A0h, al
   
   mov dx, 0A0h
   in al, dx
   
   call print_bin
   
   mov byte ptr es:[di], ' '
   inc di
   inc di  
               
   mov byte ptr es:[di], 'I'
   inc di
   inc di
   mov byte ptr es:[di], 'S'
   inc di
   inc di
   mov byte ptr es:[di], 'R'
   
   add di,120
   
   mov dx, 21h
   in al, dx
   
   call print_bin
   
   mov byte ptr es:[di], ' '
   inc di
   inc di
   
   mov dx, 0A1h
   in al, dx
   
   call print_bin
   
   mov byte ptr es:[di], ' '
   inc di
   inc di   
               
   mov byte ptr es:[di], 'I'
   inc di
   inc di
   mov byte ptr es:[di], 'M'
   inc di
   inc di
   mov byte ptr es:[di], 'R'
   ret
print_data endp
      
new_int00 proc
   pushf
   push ds
   push es
   push cs
   pop ds               
                   
   call print_data   
   
   pop es
   pop ds
   
   mov al, 0Bh
   out 20h, al
   
   mov dx, 20h
   in al, dx
   
   mov cx, 0
   cmp al, 0
   je slave_reg
   jmp find_pos
      
   slave_reg:
   add cx, 8
   mov al, 0Bh
   out 0A0h, al
   
   mov dx, 0A0h
   in al, dx
   
   find_pos:
   test al, 1
   jz cont
   jmp call_int
   
   cont:
   inc cx
   shr al, 1
   jmp find_pos
   
   call_int:
   mov si, cx   
   shl si, 2
      
   call cs:[old_int00 + si]
   
   iret
new_int00 endp          

old_int00 dd 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

install_handler:

    cli
    
    mov cx, 8
    mov ax, 3508h
    
    lea si, [old_int00]
    
    save_loop:
    int 21h
    
    mov word ptr [si], bx
    mov word ptr [si + 2], es
    
    add si, 4 
    inc ax
    loop save_loop
    
    cmp ax, 3578h
    je install_icw
    
    mov cx, 8
    mov ax, 3570h
    jmp save_loop
    
    install_icw:
    
    mov al, 00010001b
    out 20h, al
    out 0A0h, al
           
    mov al, 80h
    out 21h, al
    
    mov al, 08h
    out 0A1h, al
    
    mov al, 00000001b
    out 21h, al
        
    mov al, 00000000b
    out 0A1h, al
    
    mov al, 00000001b
    out 21h, al      
    out 0A1h, al
    
    mov cx, 8
    mov ax, 2580h
    mov dx, offset new_int00
    
    install_loop:     
    int 21h
    inc ax
    loop install_loop
    
    cmp ax, 2510h
    je finish
    
    mov cx, 8
    mov ax, 2508h
    jmp install_loop 

    finish:
    
    sti
    
    mov ax, 3100h
    mov dx, (install_handler - start + 10Fh) / 16
    int 21h

code ends
end start