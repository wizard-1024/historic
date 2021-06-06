 			PAGE	59,132
			TITLE	External routines for VPCINST.PAS

;  Name		OVL1.ASM
;  Purpose	Virus-Protect  for many .EXE file
;  Input	None
;  Output	None
;  Version	2.02A
;  Date		07/29/90
;  Programmer	Dima Sfefankov

	CODE	SEGMENT	WORD	PUBLIC	'CODE'
		ASSUME	CS:CODE,DS:CODE

                PUBLIC  ExeFileHide

;   equates

	WP	EQU	<WORD PTR>

;  main code

	Init	LABEL	BYTE

;   data  area

	MyID		DB	'DS'
	Header		DB	01Ch	DUP (?)
	HeaderLen	=	$ - Header
	OldHeader	DB	01Ch	DUP (?)
	FileSize	DW	2  DUP (?)
	FileAttr	DW	?
	FileTime	DW	?
	FileDate	DW	?
	PathName	LABEL	DWORD
	Path		DW	2  DUP (?)
	Copyright	DB	'Protected code here!',13,10,'$'
	DosEntry	DB	07,'Unable to start! Exit to DOS...',13,10,'$'

	Search1		db	9Ch,0FAh,50h,2Eh,0FFh,36h
	Len1		=	$  - Search1
	Search2		db	2Eh,3Ah,26h
	Len2		=	$  - Search2

	DosTrueOfs	dw	0
	DosTrueSeg	dw	0
	OldInt65	dd	0
	OldInt24	dd	0

	SavePSP		DW	0
	CRLF		DB	10,13,'$'
	Prompt1		DB	'Filesize mismatch! (R)ecover,(C)ontinue,(A)bort?$'
	Prompt2		DB	10,13,'Recovery done! (C)ontinue, (A)bort?$'
	ErrMessage	DB	10,13,'Protection scheme failed!',10,13,'$'

	Init2:
		cld				;forward
		push	ax			;save registers
		push	bx
		push	cx
		push	ds
		push	es

		mov	ax,cs			;init DATA
		mov	ds,ax

		lea	dx,Copyright		;display a copyright
		call	Message

		mov	[SavePSP],es
		mov	ah,52h			;InVars function
		int	21h
		mov	bx,si			;save the data offset

		sub	di,di			;DI = 0
		mov	cx,3000h
	find1:
		mov	al,Search1
		repne	scasb
		jcxz	not_found

		push	cx
		push	di
		mov	dx,di
		lea	si,[Search1+1]
		mov	cx,Len1 - 1
		repe	cmpsb
		je	found1
		pop	di
		pop	cx
		jmp	short  find1

	not_found:
		mov	si,bx
		lea	dx,DosEntry
		call	Message
		jmp	GotoDos

	found1:
		pop	cx			;save the DI reg
		pop	cx
		dec	dx			;ES:DX = old entry for CP/M

	find2:
		mov	al,[Search2]
		repne	scasb
		jcxz	not_found

		push	cx
		push	di
		mov	bp,di
		lea	si,[Search2+1]
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
		mov	[DosTrueOfs],bp
		mov	[DosTrueSeg],es

		mov	ax,3524h		;use the new INT $24 handler
		int	21h
		mov	WP [OldInt24],bx
		mov	WP [OldInt24+2],es

		lea	dx,MyInt24
		mov	ax,2524h
		int	21h

		mov	ax,3565h		;re-vector the INT 65h
		int	21h
		mov	WP [OldInt65],bx
		mov	WP [OldInt65+2],es

		push	ds
		lds	dx,DWORD PTR DosTrueOfs
		mov	ax,2565h
		int	21h
		pop	ds

		mov	es,[SavePSP]
		mov	es,es:[2Ch]		;find the ASCIIZ filename
		sub	al,al
		sub	di,di
		mov	cx,8000h
        L1:     repne	scasb
		cmp	al,es:[di]		;double null?
		jne	L1

	        add	di,3
		mov	Path[0],di		;save a pointer
		mov	Path[2],es

		sub	cx,cx			;set normal attr
		call	SetAttr

		mov	al,00h			;open a file in R/O mode
		call	OpenFile
		mov	ax,4202h		;LSEEK to end
		sub	cx,cx
		sub	dx,dx
		call	Dos

		cmp	dx,FileSize[2]		;compare lens
		ja	NoMatch
		cmp	ax,FileSize[0]
		je	Continue
	NoMatch:
		lea	dx,Prompt1		;user interface
		call	Message
	TryAgain:
		call	GetKey

		cmp	al,'A'			;which actions?
		jne	L3
		call	CloseFile
		mov	cx,[FileAttr]
		call	SetAttr

	GoToDos2:
		call	RestoreVectors
	GoToDos:
		mov	ax,4C00h		;terminate program normally
		int	21h
	L3:
		cmp	al,'R'
		jne	L4
		call    Recovery
		lea	dx,Prompt2		;file recovered
		call	Message
	TryAgain1:
		call	GetKey
		cmp	al,'C'
		je	Continue
		cmp	al,'A'
		je	GoToDos
		jmp	SHORT   TryAgain1
	L4:
		cmp	al,'C'
		jne	TryAgain
	Continue:
		lea	dx,CRLF			;cursor to next line
		call	Message

		call	CloseFile		;all OK
		mov	cx,[FileAttr]
		call	SetAttr
		call	RestoreVectors

		pop	es
		mov	ax,es
		add	ax,10h
		add	WP OldHeader[0Eh],ax
		add	WP OldHeader[16h],ax
		pop	ds			;recover regs
		pop	cx
		pop	bx
		pop	ax
		cli				;set up stack
		mov	ss,WP cs:OldHeader[0Eh]
		mov	sp,WP cs:OldHeader[10h]
		sti
		jmp	DWORD PTR cs:OldHeader[14h]

;  useful subroutines

	Message	PROC	NEAR
		push	ds
		mov	ax,cs
		mov	ds,ax
		mov	ah,9			;Dos service
		int	21h
		pop	ds
		ret
	Message	ENDP

	GetKey	PROC	NEAR
		mov	ah,1			;read-echo char
		int	21h
		cmp	al,'a'
		jb	GetKey1
		cmp	al,'z'
		ja	GetKey1
		sub	al,20h
	GetKey1:
		ret
	GetKey	ENDP

	Dos		PROC	NEAR
		int	65h			;call Dos
		jnc	Done1
	Error:
		push	cs
		pop	ds
		lea	dx,ErrMessage		;display error message and exit
		mov	ah,9
		int	21h
		jmp	GoToDos
	Dos		ENDP

	OpenFile	PROC	NEAR
		mov	ah,3Dh			;AL = file mode
		push	ds
		lds	dx,PathName
		int	65h
		pop	ds
		jnc	G2
		jmp	Error
	G2:
		mov	bx,ax			;BX = new file handle
		ret
	OpenFile	ENDP

	CloseFile	PROC	NEAR
		mov	ah,3Eh			;close a handle
		call	Dos
		ret
	CloseFile	ENDP

	SetAttr		PROC	NEAR
		push	ds
		lds	dx,PathName
		mov	ax,4301h
		int	65h
		pop	ds
		jc	Error
	Done1:
		ret
	SetAttr		ENDP

        WriteFile       PROC    NEAR
                mov     ah,40h			;write to handle
                call    Dos
                ret
        WriteFile	ENDP

	Recovery	PROC	NEAR
		call	CloseFile
		call	OpenFile
		mov	ax,4200h		;move ptr to beginning of file
		sub	cx,cx
		sub	dx,dx
		call	Dos

		lea	dx,Header		;write old header
		mov	cx,HeaderLen
		call	WriteFile
		cmp	ax,cx
		jne	Error

		mov	cx,FileSize[2]		;restore old length
		mov	dx,FileSize[0]
		mov	ax,4200h
		call	Dos

		sub	cx,cx			;truncate a file
		call	WriteFile

		mov	ax,5701h		;old time/date
		mov	cx,[FileTime]
		mov	dx,[FileDate]
		call	Dos
		ret
	Recovery	ENDP

; our handler

	MyInt24		PROC	FAR
		mov	al,3			;AL = fail code
		iret
	MyInt24		ENDP

	RestoreVectors	PROC	NEAR
		push	ds
		lds	dx,OldInt65
		mov	ax,2565h
		int	21h
		pop	ds
		push	ds
		lds	dx,OldInt24
		mov	ax,2524h
		int	21h
		pop	ds
		ret
	RestoreVectors	ENDP

; stack space for safe

			EVEN
                        DB      16    DUP('stackxxx')	;new stack

	ProgramLen	EQU	$ - Init

;  main subroutine

        ExeFileHide     PROC    FAR

                push    bp
                push    ds
                mov     bp,sp                   ;make stack
                lds     si,ss:[bp+8]            ;get the file name
                mov     ax,cs
                mov     es,ax
                lea     di,KeyBuf               ;copy the filename
                cld                             ;TP string format
                lodsb                           ;to ASCIZ string
                mov     cl,al
                sub    ch,ch
                rep     movsb

                mov     ax,cs                   ;init DATA seg
                mov     ds,ax

		lea	dx,KeyBuf		;CHMOD function
		mov	ax,4300h		;get a file attr
		call	Dos2

		mov	[FileAttr],cx		;save attrs

		sub	cx,cx			;normal attrs
		call	SetAttr2

                mov     ax,3D02h                ;open a file in R/W mode
                call    Dos2

                mov     bx,ax                   ;save a handle

                mov	ax,5700h		;get old time/date
                call	Dos2
		mov	[FileTime],cx
		mov	[FileDate],dx

		sub	cx,cx			;find the file length
		sub	dx,dx
		mov	ax,4202h
		call	Dos2
		mov	OldSize[0],ax
		mov	OldSize[2],dx

		mov	ax,4200h		;pointer to beginning of file
		sub	cx,cx
		sub	dx,dx
		call	Dos2

		mov	cx,HeaderLen		;read a EXE header
		lea	dx,Header
		mov	ah,3Fh
		call	Dos2

		mov	ax,WP Header		;check for EXE file
		cmp	ax,'MZ'
		je	HeaderOk

		cmp	ax,'ZM'
		jne	OverlayFile

	HeaderOk:
		mov	si,dx			;save the header
		lea	di,OldHeader
		mov	cx,HeaderLen
		rep	movsb

		mov	WP Header[12h],01989h	;new checksum

		mov	ax,WP Header[04]	;calc a file size
		cmp	WP Header[02],0		;no bytes in last page?
		je	L0
		dec	ax
	L0:
		mul	WP [BlockSize]
		add	ax,WP Header[02]
		adc	dx,0			;DX:AX = file size

		cmp	dx,OldSize[2]		;check for overlay
		je	FileOk

	What_DO:
		push	ax
		push	dx
		lea	dx,UserW
		call	Message
		call	GetKey
		cmp	al,'C'			;try to protect?
		jne	OverlayFile
		lea	dx,CRLF
		call	Message
		pop	dx
		pop	ax
		jmp	SHORT  Make_Protect

	OverlayFile:
                mov	ah,3Eh			;close a handle
		call	Dos2

		mov	cx,[FileAttr]		;restore attrs
		call	SetAttr2

                lea     dx,Warning		;all done!
                call    Message

                jmp     Good_Return		;exit

	FileOk:
		cmp	ax,OldSize[0]
		jne	What_DO

	Make_Protect:
		add	ax,15			;align para boundary
		adc	dx,0
		and	ax,0FFF0h

		mov	NewPos[0],ax
		mov	NewPos[2],dx

		add	ax,ProgramLen		;calc. the new size
		adc	dx,0
		mov	FileSize[0],ax
		mov	FileSize[2],dx
		div	[BlockSize]
		or	dx,dx
		jz	L2
		inc	ax
	L2:
		mov	WP Header[04],ax	;save to EXE header
		mov	WP Header[2],dx

		mov	ax,NewPos[0]		;now find the new CS
		mov	dx,NewPos[2]
		div	[HeaderSize]
		sub	ax,WP Header[08]

		mov	WP Header[16h],ax	;initial CS
		mov	WP Header[14h],(OFFSET Init2-OFFSET Init)	;initial IP
		mov	WP Header[0Eh],ax	;initial SS
		mov	WP Header[10h],ProgramLen

		mov	ax,4200h		;pointer to beginning of file
		sub	cx,cx
		sub	dx,dx
		call	Dos2

		lea	dx,Header		;write a new EXE header
		mov	cx,HeaderLen
		mov	ah,40h
		call	Dos2

		mov	ax,4200h		;seek a old end
		mov	dx,NewPos[0]
		mov	cx,NewPos[2]
		call	Dos2

		lea	dx,Init			;add a protection code
		mov	cx,ProgramLen
		mov	ah,40h
		call	Dos2

                mov	ax,5701h		;restore old time/date
		mov	cx,[FileTime]
		mov	dx,[FileDate]
		call	Dos2

                mov	ah,3Eh			;close a handle
		call	Dos2

		mov	cx,[FileAttr]		;restore attrs
		call	SetAttr2

                lea     dx,Success		;all done!
                call    Message

        Good_Return:
                mov     al,1                    ;AL = true

         Return_Here:
                mov     sp,bp
                pop     ds                      ;restore TP environment
                pop     bp
                retf    4                       ;remove parameter

        Return_Here_Err:
                sub     al,al                   ;AL = false
                jmp     SHORT   Return_Here

	SetAttr2	PROC	NEAR
		lea	dx,KeyBuf		;CHMOD function
		mov	ax,4301h
		call	Dos2
	DoneOk:
		ret
	SetAttr2	ENDP

	Dos2		PROC	NEAR
		int	21h
		jnc	DoneOk
	Error2:
		lea	dx,ErrMessage		;display error message and exit
		call	Message
		jmp	Return_Here_Err
	Dos2		ENDP

;  data  area

	BlockSize	DW	512
	HeaderSize	DW	16
	NewPos	DW	2  DUP  (?)
	OldSize	DW	2  DUP  (?)
        KeyBuf  DB      80 DUP(0)
        Success DB      'Now protected from the virus-attack.',13,10,'$'
	Warning DB	'Unable to protect...',13,10,'$'
	UserW   DB	07,'Warning! File may be destroyed!'
		DB	' (C)ontinue or (A)bort? $'

        ExeFileHide     ENDP

	CODE	ENDS
                END
