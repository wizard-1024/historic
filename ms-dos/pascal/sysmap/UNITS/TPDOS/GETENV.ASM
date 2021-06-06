			PAGE	59,132			;set the page length,width
			TITLE	Copyright  (c)  Video Trends Software  1989

;   Program	GET-ENV.ASM
;   Purpose	Get memory for the new environment
;   Input	Number of bytes from the DOS command line
;   Output	None
;   Version	1.02
;   Programmer  D.Stefankoff
;   Date	07/12/89

			.8086				;MASM directives
			.MODEL  small
			DOSSEG

			INCLUDE		internal.inc	;macros
			INCLUDE		memory.inc	;macros
			INCLUDE		process.inc	;macros
			INCLUDE		output.inc	;macros

	Zero	MACRO	reg				;macro definitions
		sub	reg,reg
		ENDM
		
			.STACK	100h

			.DATA
        Message1	DB	'Copyright (c)  1989  Video Trends Software',13,10,'$'
	Message2	DB	'Invalid number of bytes.',13,10,'$'
	Message3	DB	'All OK! New memory block reserved now.',13,10,'$'

			.CODE

	Start:		mov	es,es:[2Ch]		;get environmenr addr
			@FreeBlok			;frees env

			mov	si,80h			;start of cmd line
			lodsb				;get a length
			cmp	al,4			;matching  length?
			jae	ScanLine		;Ok,then continue

	GoToDos:	mov	ax,@DATA		;set up DS
			mov	ds,ax
			@DispStr  Message1
			@DispStr  Message2
			@Exit	1			;return code = 1

	ScanLine:	Zero	cx			;Clear CX
			mov	cl,al			;CX = length
			Zero	dx			;clear registers
			Zero	di
			Zero	bp
			mov	bx,10			;for later use

	Next:		lodsb				;get a char
			cmp	al,'0'			;char in ['0'..'9']?
			jb	Skip
			cmp	al,'9'
			ja	Skip
			sub	al,'0'			;convert to a number
			Zero	ah
			xchg	dx,di
			xchg	ax,bp
			mul	bx
			add	ax,bp
			adc	dx,0
			xchg	dx,di
			xchg	ax,bp
	Skip:		loop	Next			;if not done then continue

			xchg	dx,di			;get back a number
			xchg	ax,bp
			
			or	dx,dx			;number > 65535?
			jnz	Ok
			cmp	ax,160			;AX > 160?
			jbe	GoToDos

	Ok:		add	ax,15			;align  para boundary
			adc	dx,0
			and	ax,0FFF0h
			mov	cx,4			;shift count
	RShift:		clc				;divide by 16
			rcr	dx,1
			rcr	ax,1
			loop	RShift
			mov	cx,ax

			mov	bx,50h			;put the  address at 50:0
			mov	es,bx
			mov	es:[0],ds
			mov	es:[2],cx

			mov	ax,@DATA		;set up DS
			mov	ds,ax

			@DispStr  Message1		;happy!
			@DispStr  Message3

			mov	dx,cx			;DX = number of para
			@TSR	,0			;stay resident


			END	Start
