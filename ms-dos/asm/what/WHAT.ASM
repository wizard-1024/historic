				PAGE	59,132
				TITLE	Device Driver Sample

; Name		WHAT.ASM
; Purpose	Dump the contents of CONFIG.SYS
; Input		None
; Output	None
; Version	1.20
; Date		12/25/89
; Programmer	D.Stefankoff

				.8086				;MASM directive

; boolean equates

	false	=	0
	true	=	1

; string equates

	CR	=	13
	LF	=	10
        SPC     =       32
	WP	EQU	<WORD PTR>
	DP	EQU	<DWORD PTR>

; program equates

	max_len	=	9

; debugging

	DEBUG	=	0
;	PATTERN =	0
	FILE	=	0

; structure definition

	DEVICE_RH	STRUC
		len	 db	?
		unit	 db	?
		cmd	 db	?
		status	 dw	?
		unused	 db	8  dup (?)
                media	 db	?
		code_ofs dw	?
		code_seg dw	?
		parm_ptr dd	?
		drive	db	?
	DEVICE_RH	ENDS

; code area

	CODE	SEGMENT	WORD	PUBLIC	'CODE'
		ASSUME	CS:CODE,DS:CODE,SS:CODE,ES:CODE
		ORG	0000h

; device driver header

		DD	-1
		DW	0040h
		DW	strategy
		DW	interrupt
		DB	'WHATDONE'

; internal data


	save_ptr	dd	?
	our_ds		dw	?
	old_ss		dw	?
	old_sp		dw	?

; code

	strategy	proc	far
		mov	wp  cs:save_ptr,bx
		mov	wp  cs:save_ptr+2,es
		ret
	strategy	endp

	interrupt	proc	far

; switch to local stack

		cli
		mov	cs:old_ss,ss
		mov	cs:old_sp,sp
		mov	cs:our_ds,cs
		mov	ss,cs:our_ds
		mov	sp,offset  stack_top
		sti

; save all registers

		IRP	reg,<ax,bx,cx,dx,bp,si,di,ds,es>
			push	reg
		ENDM

; load info from RH

                lds     bx,cs:save_ptr
                cmp	[bx].cmd,0
		je	init_device
		mov	ax,8103h				;set error flag
	Done:
		lds	bx,cs:save_ptr
		mov	[bx].status,ax

; restore all registers

		IRP	reg,<es,ds,di,si,bp,dx,cx,bx,ax>
			pop	reg
		ENDM

; switch back to old stack

		cli
		mov	ss,cs:old_ss
		mov	sp,cs:old_sp
		sti
		ret
	interrupt	endp

; function 0

	init_device:
                cld
		les	di,[bx].parm_ptr			;now copy the parm
                push	cs					;string
		pop	ds

; save the beginning
	
		dec	di

	IFDEF	File

; find the length of the configuration file

		mov	dx,OFFSET filename
		mov	ax,3D00h
		int	21h
		jc	func_done

		mov	bx,ax
		mov	ax,4202h
		sub	dx,dx
		mov	cx,dx
		int	21h

		mov	cx,ax

		mov	ah,3Eh
		int	21h

	IFDEF	DEBUG
		mov	ax,cx
		xchg	al,ah
		call	hex_dump
		mov	ax,cx
		call	hex_dump
		call	crlf
	ENDIF

		add	cx,16				; align para
		and	cx,0FFF0h
		mov	si,di

	ENDIF

	IFDEF	Pattern

		push	di

; search the pattern
		
		mov	cx,8000h
	search:
		mov	al,'C'
		repne	scasb
		jcxz	func_done

		push	cx
		mov	si,offset match+1
		mov	cx,match_len
		repe	cmpsb
		je	found

		pop	cx
		jmp	SHORT  search
		
	found:
		pop	cx
		pop	si				;saved DI
		mov	cx,di
		sub	cx,si
		add	cx,20

	ENDIF

		push	es
		pop	ds
	
		push	cx
		push	si

	char_loop:
		lodsb
		call	char_out
		loop	char_loop

		call	crlf

		mov	ah,7
		int	21h

		pop	si
		pop	cx
	
	next_char:
		lodsb
		call	hex_dump
		loop	next_char

		call	crlf

; user-friendly software

		push	cs
		pop	ds
		mov	dx,OFFSET message
		mov	ah,9
		int	21h

		mov	ah,7
		int	21h

		call	crlf

	func_done:
		lds	bx,cs:save_ptr
		mov	byte ptr [bx].media,0              ; 0 units
		mov	wp  [bx].code_ofs,0
		mov	wp  [bx].code_seg,cs
		mov	ax,100h
		jmp	Done

; subroutines

	hex_dump	proc	near
		push	cx
		push	ax
		mov	cl,4
		shr	al,cl
		lea	bx,hex_table
		xlat	cs:hex_table
		call	char_out
		pop	ax
		and	al,0Fh
		lea	bx,hex_table
		xlat	cs:hex_table
		call	char_out
		mov	al,SPC
		call	char_out
		pop	cx
		ret
	hex_dump	endp

	char_out	proc	near
		mov	ah,14
		mov	bx,7
		int	10h
		ret
	char_out	endp

	crlf	proc	near
		mov	al,CR
		call	char_out
		mov	al,LF
		call	char_out
		ret
	crlf	endp

; pattern

	IFDEF	Pattern
		match	db	'CFG.END'
		match_len	=  $ - (match + 1)
	ENDIF

	hex_table	db	'0123456789ABCEDF'
	filename	db	'CONFIG.SYS',0
	message		db	'Press any key to continue...$'

; stack area

		db	32	dup  ('STACKxxx')
	stack_top	label	word

	CODE	ENDS
		END

; conditional assembly

	IF1
          %OUT	Ending pass 1
	ENDIF

	IF2
          %OUT	Ending pass 2
	ENDIF
