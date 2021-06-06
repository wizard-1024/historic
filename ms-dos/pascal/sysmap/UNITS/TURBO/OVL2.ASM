			PAGE	59,132
			TITLE	External Routines for VPCINST.PAS

;  Name		OVL2.ASM
;  Purpose	Virus-UnProtect  for .EXE file
;  Input	None
;  Output	None
;  Version	2.01
;  Date		07/29/90
;  Programmer	Dima Sfefankov

	CODE	SEGMENT	WORD	PUBLIC	'CODE'
		ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE

                PUBLIC  ExeFileUnHide
;   equates

	WP	EQU	<WORD PTR>
	DataOfs	=	03A0h

;   data  area

	TempData	DB	01Eh	DUP (0)
	HeaderLen	=	$ - TempData - 2
	Header		DB	HeaderLen  DUP (0)
	FileSize	DW	2  DUP (?)
	FileAttr	DW	?
	FileTime	DW	?
	FileDate	DW	?
	CRLF		DB	10,13,'$'
	ErrMessage	DB	10,13,"I/O error occurred!",13,10,'$'


;  useful subroutines

	Message	PROC	NEAR
                push    ds
                mov     ax,cs
                mov     ds,ax
		mov	ah,9			;Dos service
		call	Dos
                pop     ds
		ret
	Message	ENDP

	CloseFile	PROC	NEAR
		mov	ah,3Eh			;close a handle
		call	Dos
	Done1:
		ret
	CloseFile	ENDP

	Dos		PROC	NEAR
		int	21h
		jnc	Done1
	Error:
		lea	dx,ErrMessage		;display error message and exit
		mov	ah,9
		int	21h
		jmp	GoToDos_err
	Dos		ENDP


        WriteFile       PROC    NEAR
                mov     ah,40h			;write to handle
                call    Dos
                ret
        WriteFile	ENDP

;  main entry

        ExeFileUnHide     PROC    FAR

                push    bp
                push    ds
                mov     bp,sp                   ;make stack
                lds     si,ss:[bp+8]            ;get the file name
                mov     ax,cs
                mov     es,ax
                lea     di,KeyBuf               ;copy the filename
                cld                             ;from TP string format
                lodsb                           ;to ASCIIZ string
                mov     cl,al
                sub    ch,ch
                rep     movsb

                mov     ax,cs                   ;init DATA seg
                mov     ds,ax

                lea	dx,KeyBuf		;CHMOD function
		mov	ax,4300h		;get a file attr
		call	Dos

		mov	[FileAttr],cx		;save attrs

		sub	cx,cx			;normal attrs
		call	SetAttr

                mov     ax,3D02h                ;open a file in R/W mode
                call    Dos

                mov     bx,ax                   ;save a handle

                mov	ax,5700h		;get old time
                call	Dos
		mov	[FileTime],cx
		mov	[FileDate],dx

		mov	cx,2			;check for .EXE header
		lea	dx,TempData
		mov	ah,3Fh
		call	Dos

		mov	ax,WP TempData
		cmp	ax,'ZM'
		je	HeaderOk

		cmp	ax,'MZ'
		jne	Err_Exit

	HeaderOK:
		mov	ax,4202h		;LSEEK to end
		sub	cx,cx
		sub	dx,dx
		call	Dos

		stc				;calc. a new pos
		mov	cx,dx
		mov	dx,ax
		sub	dx,DataOfs
		sbb	cx,0

		mov	ax,4200h		;LSEEK to a new pos
		call	Dos

		mov	cx,HeaderLen*2+2	;read a old EXE header
		lea	dx,TempData
		mov	ah,3Fh
		call	Dos

		cmp	WP TempData,'SD'	;check the my ID
		je	ID_found

	Err_Exit:
                call    CloseFile		;close a handle

		mov	cx,[FileAttr]		;restore attrs
		call	SetAttr

                lea     dx,Warning		;error!
                call    Message
                mov     al,1
		jmp	Good_Return

	ID_found:
		mov	ax,4200h		;LSEEK to beginning
		sub	cx,cx
		sub	dx,dx
		call	Dos

		mov	cx,HeaderLen		;write a old EXE header
		lea	dx,Header
		call	WriteFile
		cmp	ax,cx
		je	Go1
		jmp	Error
	Go1:
		mov	ax,WP Header[04]	;calc a file size
		cmp	WP Header[02],0		;no bytes in last page?
		je	L0
		dec	ax
	L0:
		mul	WP [BlockSize]
		add	ax,WP Header[02]
		adc	dx,0			;DX:AX = file size

		mov	cx,dx
		mov	dx,ax
		mov	ax,4200h		;seek the old EOF
		call	Dos

		mov	cx,0			;truncate a file
		call	WriteFile

                mov	ax,5701h		;restore old time
		mov	cx,[FileTime]
		mov	dx,[FileDate]
		call	Dos

                call    CloseFile		;close a handle

		mov	cx,[FileAttr]		;restore attrs
		call	SetAttr

                lea     dx,Success		;all done!
                call    Message

        Good_Return:
                mov     al,1                    ;AL = true

        GoToDos:				;exit
                mov     sp,bp                   ;restore TP environment
		pop	ds
                pop     bp
                retf     4

        GotoDos_Err:
                mov     al,0
                jmp     SHORT  GotoDOs

	SetAttr		PROC	NEAR
		lea	dx,KeyBuf		;CHMOD function
		mov	ax,4301h
		call	Dos
		ret
	SetAttr		ENDP

;  data  area

	BlockSize	DW	512
	HeaderSize	DW	16
	NewPos	DW	2  DUP (?)
        KeyBuf  DB      80   Dup  (0)
        Success DB      'Now unprotected.',13,10,'$'
	Warning db	'Protected code not found.',13,10,'$'

        ExeFileUnHide     ENDP

	CODE	ENDS
		END

