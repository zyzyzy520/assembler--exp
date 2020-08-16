STACK	SEGMENT	STACK
	DW	100 DUP(?)
STACK	ENDS	
		
DATA	SEGMENT	

DATA	ENDS	
CODE	SEGMENT		
	ASSUME	CS:CODE, DS:DATA, SS:STACK,ES:DATA
;主程序
START:	mov ax,DATA
		mov	ds,ax
		mov	es,ax
		call Initial	
		mov	cx,100H
		mov	si,3000H
		mov	di,6000H
		call move
		mov	cx,100H
		mov	si,3000H
		mov	di,6000H
		mov ah,02h
		cld	
		repe cmpsb
		jne	ERROR
TRUE:	mov dl,'T'
		int 21h
		jmp	$	
ERROR:	mov dl,'F'	 
		int 21h
		jmp $

;初始化赋值子程序
Initial		PROC		NEAR
	mov cx,100H
	mov ax,0ffffH
	mov di,3000H
	cld
Initial1:	inc ax
	stosb
	loop Initial1
	RET	
Initial		ENDP	

;数据传送子程序
Move		PROC		NEAR
	cld	
	repz movsb
	ret	
Move		ENDP		
CODE			ENDS	
	END	START

