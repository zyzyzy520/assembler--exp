stack	segment	stack	
	dw	100 dup(?)	
stack	ends		
			
data	segment	
	msg1  db 'please type a hexadecimal number(without h):','$'
	msg2  db 'the answer is:','$'
	sign  dw 1 dup(0)
	wtemp dw 2 dup(?)
data	ends		
			
code	segment			
	assume	cs:code, ds:data, ss:stack
start:	mov	ax,data	
	mov	ds,ax	
	mov	es,ax	
	nop		
	mov dx,offset msg1
	call disp	 ;打印提示符
	call read    ;读入用户输入16进制数
	call CR 	 ;打印换行符
	mov dx,offset msg2
	call disp
	mov dx,bx
	mov bx,10000 ;除法为了将八位十进制分成两半，方便调用
	div bx   
	mov wtemp,ax
	call write   ;打印前四位十进制数
	mov cx,0
	mov sign,cx	  ;符号位只与前四位有关
	mov wtemp,dx  ;打印后四位十进制数
	call write 
	jmp $

;读取用户输入
read proc near	;用ax,bx传递出口参数
	push cx		;保护寄存器
	push dx
	mov bx,0	;计算总值,高16位
	mov dx,0	;计算总值，低16位
	;mov cx,0	;正负标志位
	mov ah,01h
	int 21h
	cmp al,'+'
	jz read1
	cmp al,'-'
	jnz read2	;直接输入符号
	mov cx,-1;负数标志
	mov sign,cx
	;push cx		;移位操作会用到cx，所以先压入堆栈保护
read1: mov ah,01h
	int 21h
read2: cmp al,'0'
	jb read3	;输入不是0-9结束	
	cmp al,'9'
	jbe read4	;输入是0-9,只需减30H
	cmp al,'A'	;输入位于9~A结束
	jb read3
	cmp al,'F'	;输入在A-F，需先减07H
	jbe read5	
	cmp al,'a'	;输入在F-a,结束
	jb read3
	cmp al,'f'	;输入在a~z，需再先减20H
	ja read3
	sub al,20h
read5: sub al,07h	
read4: sub al,30h

;移动4位，扩大16倍
	mov cx,4
	mov ah,0	;高8位置0
cycle:	shl dx,1
	rcl bx,1
	loop cycle
	add dx,ax   ;加入新一位
	adc bx,0    ;可能有进位
	jmp read1 	;继续输入字符
read3:mov ax,dx
	pop dx
	pop cx
	ret
read endp

;打印数据
write proc near 
	push ax
	push bx
	push dx
	push cx
	mov ax,wtemp
	test ax,ax		;判断零、正数、负数
	jnz write1
	mov cx,4
	mov ah,02h
	mov dl,'0'
zero:	int 21h
	loop zero
	jmp write5
write1:mov cx,sign
	test cx,cx
	jz write2
	mov bx,ax
	mov ah,02h
	mov dl,'-'
	int 21h
	mov ax,bx
write2:mov bx,10
	push bx 		;作为退出标志
write3:cmp ax,0		;ax-商 dx-余数
	jz write4
	mov dx,0
	div bx
	add dx,30h
	push dx
	jmp write3
write4:pop dx
	cmp dl,10
	jz write5
	mov ah,02h
	int 21h
	jmp write4
write5:pop cx
	pop dx
	pop bx
	pop ax
	ret
write endp


;换行
CR proc near
	push dx
	push ax
	mov dl,0dh
	mov ah,02h
	int 21h
	mov dl,0ah
	int 21h
	pop ax
	pop dx
	ret
	CR endp

;打印提示符
disp proc near
	push ax 
	mov ah,9  
	int 21h
	pop ax
	ret
disp endp

code	ends		
	end		start	