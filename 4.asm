stack	segment	stack	
	dw	100 dup(?)	
stack	ends		
			
data	segment	
	msg1  db 'please type the number of array:','$'
	msg2 db 'please type the array:','$'
	msg3  db 'the orderly array is:','$'
	count dw 1 dup(0)
	array dw 30 dup(?)
	wtemp dw 1 dup(0)
data	ends		
			
code	segment			
	assume	cs:code, ds:data, ss:stack
start:	mov	ax,data	
	mov	ds,ax	
	mov	es,ax	
	nop		
	mov dx,offset msg1
	call disp	 ;打印提示符
	call CR		 ;打印换行符
	call read 	 ;读输入队列个数
	mov count,ax
	call CR		 ;打印换行符
	mov dx,offset msg2
	call disp	 ;打印提示符
	call CR		 ;打印换行符
	call inputArray;循环输入队列数字
	call CR		 ;打印换行符
	mov dx,offset msg3
	call disp	 ;打印提示符
	call CR		 ;打印换行符
	call bubble
	call outputArray	;循环输出队列数字
	jmp $

;让用户输入队列
inputArray proc near
	push cx
	push ax
	push si
	mov si,0
	mov cx,count
again:	call read
	mov array[si],ax
	inc si
	inc si
	loop again
	pop si
	pop ax
	pop cx
	ret
inputArray endp

;打印输出队列
outputArray proc near
	push cx
	push bx
	push ax
	mov cx,count
	mov bx,offset array
again1:	mov ax,[bx]
	mov wtemp,ax
	call write
	inc bx 
	inc bx
	mov ah,02h
	mov dl,20h
	int 21h
	loop again1 
	pop ax
	pop bx
	pop cx
	ret
outputArray endp

;冒泡排序
bubble proc near
	push cx
	push dx
	push bx
	mov cx,count	;数组元素个数
	dec cx			;外循环次数
outlp:mov dx,cx		;内循环次数
	mov bx,offset array
inlp:mov ax,[bx]	;取前一个元素
	cmp ax,[bx+2]	;与后一个元素比较
	jna next		;前一个不大于后一个元素，则不进行交换
	xchg ax,[bx+2]
	mov [bx],ax
next:inc bx
	inc bx
	dec dx
	jnz inlp 		;内循环尾
	loop outlp		;外循环尾
	pop bx
	pop dx
	pop cx
	ret
bubble endp

;读取用户输入
read proc near	;用ax传递出口参数
	push cx		;保护寄存器
	push bx
	push dx
	mov bx,0	;计算总值
	mov cx,0	;正负标志位
	mov ah,01h
	int 21h
	cmp al,'+'
	jz read1
	cmp al,'-'
	jnz read2	;直接输入符号
	mov cx,-1	;负数标志
read1: mov ah,01h
	int 21h
read2: cmp al,'0'
	jb read3	;输入不是0-9结束	
	cmp al,'9'
	ja read3	;输入不是0-9结束
	sub al,30h
	shl bx,1
	mov dx,bx
	shl bx,1	;移位实现扩大10倍
	shl bx,1
	add bx,dx
	mov ah,0	;8位置0
	add bx,ax
	mov ah,0
	add dx,ax
	jmp read1 	;继续输入字符
read3: cmp cx,-1	;处理正负数
	jnz read4
	neg bx		;负数取补码
read4:mov ax,bx
	pop dx
	pop bx
	pop cx
	ret
read endp

;打印数据
write proc near 
	push ax
	push bx
	push dx
	mov ax,wtemp
	test ax,ax		;判断零、正数、负数
	jnz write1
	mov ah,02h
	mov dl,'0'
	int 21h
	jmp write5
write1:jns write2
	mov bx,ax
	mov ah,02h
	mov dl,'-'
	int 21h
	mov ax,bx
	neg ax			;求绝对值
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
write5:pop dx
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