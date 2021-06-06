			PAGE	60,132
			TITLE	Commercial Program

;  Name		COMCODE.ASM
;  Purpose	Virus-Protection  for any .COM file
;  Input	None
;  Output	None
;  Version	2.10
;  Date		04/03/90
;  Programmer	Dima Sfefankov

	CODE	SEGMENT	WORD	PUBLIC	'CODE'
		ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE

;  equates

	ComBegin	EQU	100h
	WP		EQU	<WORD PTR>
	DP		EQU	<DWORD PTR>
	Version		EQU	'V2.10'
	PSPLen		=	100h
	true		=	0FFh
	false		=	0
	SaveLength	=	8

;  macros

	DosCall		MACRO	reg
		mov	ah,reg
		int	21h
			ENDM

	DosCallAX	MACRO	reg
		mov	ax,reg
		int	21h
			ENDM

        PUBLIC          MyCode

        MyCode  PROC	NEAR
                jmp     Init                    ;jump to begin

;   data  area
        DataArea        =       $
	MyID		DB	'DS'
	Offset0		=	$ - DataArea
	OldData		DB	SaveLength  DUP (?)    ;+0
	Offset1		=	$ - DataArea
	OldComSize	DW	?              ;+18
	Offset2		=	$ - DataArea
	FileSize	DW	?              ;+20
	Offset3		=	$ - DataArea
	FileAttr	DW	?              ;+22
	Offset4		=	$ - DataArea
	FileTime	DW	?              ;+24
	Offset5		=	$ - DataArea
	FileDate	DW	?              ;+26
	Offset6		=	$ - DataArea
	NameLength	DB	?              ;+28
	Offset7		=	$ - DataArea
        FileName        DB      13  DUP (0)    ;+29
	Offset8		=	$ - DataArea
        PathName        LABEL   DWORD          ;+42
        Path            DW      2   DUP (?)

	Offset9		=	$ - DataArea
	CRLF		DB	10,13,'$'      ;+46
	Offset10	=	$ - DataArea
	Prompt1		DB	'File size mismatch! (R)ecover,(C)ontinue,(A)bort?$'
	Diff1		=	$ - Prompt1
	Prompt2		DB	10,13,'Recovery OK! (C)ontinue, (A)bort?$'
	Diff2		=	$ - Prompt1
	ErrMessage	DB	10,13,'Unrecoverable error!',10,13,'$'
	Diff3		=	$ - Prompt1
	Copyright	DB	'Virus Protection Code here!',13,10,'$'
	Diff4		=	$ - Prompt1
	DosEntry	DB	07,'Protection fails!',13,10,'$'

	Offset11	=	$  - DataArea
	Search1		db	9Ch,0FAh,50h,2Eh,0FFh,36h
	Len1		=	$  - Search1
	Offset12	=	$  - DataArea
	Search2		db	2Eh,3Ah,26h
	Len2		=	$  - Search2

	Offset13	=	$  -  DataArea
	DosTrueOfs	dw	0
	Offset14	=	$  -  DataArea
	DosTrueSeg	dw	0
	Offset15	=	$  -  DataArea
	OldInt65	dd	0
	Offset16	=	$  -  DataArea
	OldInt24	dd	0

; code here

	Init:	push	ax			;save register

                call    Here                    ;use the indirect addressing
        Here:
        DataOfs         =       Here  - DataArea

                pop     si
                sub     si,DataOfs              ;find the beginning of the data

		lea	dx,[si+Offset10+Diff3]	;display a starting message
		call	Message

		DosCall 52h			;'InVars' function
		mov	bx,si			;save the data offset

		cld				;go forward
		sub	di,di			;DI = 0
		mov	cx,4000h		;16K to search
	find1:
		mov	al,[bx+Offset11]	;get a first byte
		repne	scasb
		jcxz	not_found

		push	cx			;now compare remainder
		push	di
		mov	dx,di
		lea	si,[bx+Offset11+1]
		mov	cx,Len1 - 1
		repe	cmpsb
		je	found1
		pop	di
		pop	cx
		jmp	short  find1

	not_found:
		mov	si,bx			;unknown DOS version or
		lea	dx,[si+Offset10+Diff4]	;new virus resident scheme 
		call	Message
		jmp	GotoDos2

	found1:
		pop	cx			;save the DI reg
		pop	cx
		dec	dx			;ES:DX = old entry for CP/M
						;	 style functions
	find2:
		mov	al,[bx+Offset12]	;get a 1st byte
		repne	scasb
		jcxz	not_found

		push	cx			;compare the remainder
		push	di
		mov	bp,di
		lea	si,[bx+Offset12+1]
		mov	cx,Len2 - 1
		repe	cmpsb
		je	found2
		pop	di
		pop	cx
		jmp	short	find2

	found2:
		pop	di
		pop	cx

		dec	bp
		mov	ax,bp			;ES:BP = old Dos entry
		sub	ax,dx
		cmp	ax,13h			;undocumented fact
		jne	not_found

		mov	si,bx
		mov	[si+Offset13],bp
		mov	[si+Offset14],es

		DosCallAX  3524h		;use the new INT $24 handler
		mov	WP [si+Offset16],bx
		mov	WP [si+Offset16+2],es

		lea	dx,[si+ProcOffset]
		DosCallAX  2524h

		DosCallAX  3565h		;re-vector the INT 65h
		mov	WP [si+Offset15],bx
		mov	WP [si+Offset15+2],es

		push	ds
		lds	dx,[si+Offset13]	;use for our safe
		DosCallAX  2565h
		pop	ds

                push    cs
                pop     es			;ES = code segment

                call    Decrypt                 ;decrypts a name

                lea     ax,[si+Offset7]         ;try to find in current dir
                mov     [si+Offset8],ax
                mov     [si+Offset8+2],cs

		mov	al,0			;R/O access mode
		call	OpenFile
		jnc	G2

		cld				;go forward
                mov     cx,8000h                ;try to find the DOS path
                mov     es,es:[2Ch]
                sub     al,al
                sub     di,di
        L1:     repne   scasb			;search for double null
                cmp     al,es:[di]
                jne     L1
                add     di,3
                mov     [si+Offset8],di		;save a pointer to the path
                mov     [si+Offset8+2],es

                push    cs
                pop     es			;ES = code segment

	G1:
		mov	al,0			;R/O access mode
		call	OpenFile
		jnc	G2
		jmp	Error
	G2:
		mov	bx,ax			;save handle
		mov	ax,4202h		;LSEEK to end =
		sub	cx,cx			; = file size
		sub	dx,dx
		call	Dos

		cmp	ax,[si+Offset2]		;equal?
		je	Continue

		lea	dx,[si+Offset10]	;user interface
		call	Message

	TryAgain:
		call	GetKey			;wait a user response

		cmp	al,'A'			;which actions?
		jne	L3
		call	CloseFile		;close a handle

	GoToDos:
		call	RestoreVectors

	GoToDos2:
		DosCallAX  4C00h		;terminate program normally

	L3:
		cmp	al,'R'			;recovery?
		jne	L4
		call    Recovery
		lea	dx,[si+Offset10+Diff1]  ;be happy!
		call	Message

	TryAgain1:
		call	GetKey			;user action
		cmp	al,'C'			;continue?
		je	Continue
		cmp	al,'A'			;abort?
		je	GoToDos
		jmp	SHORT   TryAgain1

	L4:	cmp	al,'C'			;just continue?
		jne	TryAgain
	Continue:
		lea	dx,[si+Offset9]      	;cursor to next line
		call	Message

		call	CloseFile		;file operations done
		call	RestoreVectors

		mov	cx,[si+Offset1]		;old file size
		push	cx
		lea	si,[si+Offset0]		;copy old beginning
                mov	di,ComBegin
		mov	cx,3
		rep	movsb
                sub	bp,bp			;prepare for new start
		mov	di,bp
		mov	si,di
		mov	bx,si
		mov	dx,ComBegin
		pop	cx
		pop	ax
                push    dx
                mov     dx,si
                ret
	MyCode	ENDP

;  useful subroutines

	Message	PROC	NEAR
		DosCall 9			;Dos service
		ret
	Message	ENDP

	GetKey	PROC	NEAR
		DosCall 01h			;read-echo char
		and	al,11011111b		;make the uppercase	
	GetKey1:
		ret
	GetKey	ENDP

	OpenFile	PROC	NEAR
		mov	ah,3Dh			;open a file
                push    ds
		lds	dx,[si+Offset8]		;DS:DX = path
		int	65h
                pop     ds
		ret
	OpenFile	ENDP

	CloseFile	PROC	NEAR
		mov	ah,3Eh			;close a handle
		call	Dos
		ret
	CloseFile	ENDP

	SetAttr		PROC	NEAR
                push    ds			;CHMOD func
		lds	dx,[si+Offset8]		;DS:DX = pointer to pathname
		mov	ax,4301h
		int	65h
                pop     ds
        Done1:
		ret
	SetAttr		ENDP

	Dos		PROC	NEAR
		int	65h			;call Dos
		jnc	Done1
	Error:
		lea	dx,[si+Offset10+Diff2]	;display error message and exit
		call	Message
		jmp	GoToDos
	Dos		ENDP

	Recovery	PROC	NEAR
		call	CloseFile		;at first close a file

		sub	cx,cx			;set the normal attrs
		call	SetAttr

		mov	al,2			;R/W access mode
		call	OpenFile		
		mov	bx,ax			;save the handle

		mov	ax,4200h		;move ptr to beginning of file
		sub	cx,cx
		sub	dx,dx
		call	Dos

                mov	cl,[si+Offset6]         ;CX = # of chars
		sub	ch,ch
                push    si
		lea	si,[si+Offset7]
                mov     di,si
        Encrypt:
		lodsb				;now decrypts a name
		rol	al,1
		rol	al,1
		stosb
		loop	Encrypt
                pop     si

		mov	cx,[si+Offset2]		;write old contents
		mov	dx,ComBegin
		mov	ah,40h
		call	Dos
		cmp	ax,cx
		jne	Error

		mov	ah,40h			;truncate a length
		sub	cx,cx
		call	Dos

		mov	ax,5701h		;old time
		mov	cx,[si+Offset4]
		mov	dx,[si+Offset5]
		call	Dos

                call    Decrypt                 ;decrypts a name

		mov	cx,[si+Offset3]		;set the old file attributes
		call	SetAttr
		ret
	Recovery	ENDP

        Decrypt         PROC     NEAR
                mov	cl,[si+Offset6]      	;CX = # of chars
		sub	ch,ch
                push    si
		lea	si,[si+Offset7]
                mov     di,si
        Decrypt1:
		lodsb				;now decrypts a name
		ror	al,1
		ror	al,1
		stosb
		loop	Decrypt1
                pop     si
                ret
        Decrypt         ENDP

; our handler

	ProcOffset	=	$  - DataArea

	MyInt24		PROC	FAR
		mov	al,3			;AL = fail code
		iret
	MyInt24		ENDP

	RestoreVectors	PROC	NEAR
		push	ds
		lds	dx,[si+Offset15]
		DosCallAX  2565h		;old INT 65h vector
		pop	ds
		push	ds
		lds	dx,[si+Offset16]
		DosCallAX  2524h		;old INT 24h vector
		pop	ds
		ret
	RestoreVectors	ENDP

	ProgramLen	EQU	$ - MyCode

	CODE	ENDS
		END
