			PAGE	60,132
			TITLE	Resident Video Clock Program V1.0

; Name		VCLOCK.ASM
; Version	1.0
; Purpose	Display continuosly the time
; Date		07/20/90
; Programmer	Dima Stefankov

false		=	0
true		=	0FFh

Wptr		EQU	<WORD PTR>
Bptr		EQU	<BYTE PTR>
Dptr		EQU	<DWORD PTR>

ClockInUse	=	1
InitVal		=	ClockInUse
MaxValue	=	18

ColorSeg	=	0B800h
MonoSeg		=	0B000h
ColorAttr	=	04Eh			;yellow on red
MonoAttr	=	070h			;reverse

ROM_DATA	SEGMENT		AT	40h
		ORG	49h
VideoMode	db	?
VideoCols	db	?
		ORG	4Eh
Buffer_Start	dw	?
		ORG	6Ch
Timer_Count	DD	?
ROM_DATA	ENDS

CODE	SEGMENT
	ASSUME CS:CODE,DS:CODE,SS:STACK

; memory marker

	MemoryMarker	label	byte
		db	'DK'

; useful subroutines

;At exit:	AH  =  hours
;		AL  =  minuntes
;		BH  =  seconds
;		BL  =  hundreths

CalcTime	PROC	NEAR
		mov	ax,SEG ROM_DATA
		mov	ds,ax
		ASSUME	DS:ROM_DATA
		mov	dx,Wptr Timer_Count	;get # of timer tics
		mov	cx,Wptr Timer_Count+2

		mov	ax,cx			;code from Microsoft
		mov	bx,dx			;CLOCK$ device driver
		shl	dx,1
		rcl	cx,1
		shl	dx,1
		rcl	cx,1
		add	dx,bx
		adc	ax,cx
		xchg	ax,dx
		mov	cx,0E90Bh
		div	cx
		mov	bx,ax
		xor	ax,ax
		div	cx
		mov	dx,bx
		mov	cx,200
		div	cx
		cmp	dl,100
		jb	Under
		sub	dl,100
	Under:
		cmc
		mov	bl,dl
		rcl	ax,1
		mov	dl,0
		rcl	dx,1
		mov	cx,60
		div	cx
		mov	bh,dl
		div	cl
		xchg	al,ah
		ret
CalcTime	ENDP

; Entry:	AL = number
; Exit:		AX = 2 decimal digits

Convert		PROC	NEAR
		sub	ah,ah
		mov	cl,10
		div	cl
		add	ax,'00'			;AH = remainder, AL = quoitent
		ret
Convert		ENDP

; variables

OldInt08	DD	?
SysFlags	DB	InitVal
Counter		DB	MaxValue
VideoImage	DB	0,0,':',0,0,':',0,0
ImageLen	=	$ - VideoImage

; init data seg regs
; Exit:		AX = video buffer offset
;		BX = offset on line
;		CL = current video mode

SetVideoVars	PROC	NEAR
		mov	ax,SEG ROM_DATA
		mov	ds,ax			;ES = 40h
		ASSUME	DS:ROM_DATA
		mov	ax,Buffer_Start		;AX = video buffer offset
		mov	bl,VideoCols
		sub	bl,ImageLen
		sub	bh,bh
		shl	bx,1			;attr+char
		mov	cl,VideoMode
		ret
SetVideoVars	ENDP

; main resident code

NewInt08	PROC	FAR
		pushf				;emulate the interrupt
		call	Dptr cs:OldInt08

		test	cs:SysFlags,ClockInUse	;enabled?
		jz	Done

		dec	cs:Counter
		jnz	Done

		sti				;enable interripts
		mov	Bptr cs:Counter,MaxValue

		push	ax			;save registers
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	ds
		push	es

		call	CalcTime

		mov	di,cs
		mov	es,di			;ES = data buffer

		cld				;go forward
		mov	di,OFFSET VideoImage	;make the new clock image
		push	ax
		mov	al,ah			;AL = hour
		call	Convert
		stosw
		inc	di			;skip colon
		pop	ax			;AL = min
		call	Convert
		stosw
		inc	di			;skip colon
		mov	al,bh			;AL = sec
		call	Convert
		stosw
		
		call	SetVideoVars		;get video vars

		add	ax,0B000h		;assume that mono adapter
		mov	ch,MonoAttr
		cmp	cl,7			;check for text mode
		je	ModeOk
		add	ah,08h			;assume color text
		mov	ch,ColorAttr
		cmp	cl,3
		ja	CopyDone

	ModeOk:
		mov	si,cs
		mov	ds,si			;DS = data buffer

		mov	es,ax			;ES = video buffer

		mov	ah,ch			;AH = video attribute
		mov	cx,ImageLen
		mov	si,OFFSET VideoImage
		mov	di,bx			;DI = video offset

	PutVideoByte:
		movsb				;move a char
		mov	al,ah		        ;get attribute
		stosb				;put a back
		loop	PutVideoByte

	CopyDone:
		pop	es			;restore registers
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
	Done:
		iret				;preserve flags
NewInt08	ENDP


; initialization code

	Start:
		mov	WPTR cs:MemoryMarker,'EM'  ; make TSR mark
		mov	cs:PSP,ds
		sub	bx,bx			;BX = 0
		mov	ax,cs
		mov	es,ax

	NextSegment:
		cmp	bx,ax			;our seg?
		jb	Parse_Code
		jmp	Install

	Parse_Code:
		mov	ds,bx			;DS = segment to scan
		mov	di,2			; offset
		mov	si,di
		mov	cx,10			;now compare
		cld
		repe	cmpsb
		jne	TryNext

		cmp	WPTR ds:[0],'EM'	; is disk image?
		je	CodeFound

	TryNext:
		inc	bx			;try next memory segment
		jmp	SHORT	NextSegment

	CodeFound:
		call	XXdata			;set DS = CS
		ASSUME  DS:CODE
		mov	dx,OFFSET Resident	;assume that already resident
		mov	cx,ResLen

		mov	es,PSP
		mov	si,80h
		mov	cl,es:[si]		;CL = # of chars on cmd line
		sub	ch,ch

	Scan_Line:
		jcxz	Incorrect_Parms		;if CX = 0 then done
		call	Get_Char
		cmp	al,'/'			;switch char?
		jne	Scan_Line
		call	Get_Char
		cmp	al,'U'			;*remove* cmd?
		je	Remove
		cmp	al,'E'			;*enable* cmd?
		jne	Next_Switch
		or	SysFlags,ClockInUse
		jmp	Short Send_Program
	Next_Switch:
		cmp	al,'D'			;*disable* cmd?
		jne	Scan_Line
		and	SysFlags,0FFh - ClockInUse
				
	Send_Program:
		mov	es,bx			;ES = resident
		mov	al,SysFlags		;now copy new setting
		mov	es:SysFlags,al
		mov	es:Counter,MaxValue	;reset the counter
		mov	dx,OFFSET ResSwitch
		mov	cx,SwitchLen

	GotoDos:
		call	MsgOut			;display the message
		mov	ax,4C00h		;normally terminate the program
		int	21h
	
	Incorrect_Parms:
		mov	cx,ResLen		;CX = length of message
		jmp	SHORT  GotoDos

	Remove:
		push	bx			;BX = resident code seg
		call	XXdata			;set DS = CS
		ASSUME  DS:CODE
		mov	cx,bx			;CX = resident

		mov	ax,3508h		;get the vector 13h
		int	21h
		mov	ax,es			;AX = vector segment

		cmp	cx,ax			;match segment?
		jne	NoRemove
		cmp	bx,OFFSET NewInt08
		jne	NoRemove

		push	ds
		mov	ds,cx			;DS = segment of resident code
		lds	dx,Dptr ds:OldInt08
		mov	ax,2508h		;restore old INT 08h
		int	21h

		pop	ds
		pop	bx			;BX = resident code
		sub	bx,10h			;BX = PSP
		mov	es,bx

		mov	ah,49h			;free a block
		int	21h
		jc	NoRemove		;error occured?

		mov	es,es:[2Ch]		;free a environment
		mov	ah,49h
		int	21h
		jc	NoRemove		;error occured?

		mov	dx,OFFSET RemoveMsg	;successfully removing!
		mov	cx,RemLen
		jmp	GotoDos

	NoRemove:
		mov	dx,OFFSET UnHappy	;unable to uninstall
		mov	cx,UnLen
		jmp	GotoDos

; installation code

	Install:
		call	XXdata			;set DS = CS
		ASSUME  DS:CODE

		mov	ax,3508h		;get the vector 13h
		int	21h
		mov	Wptr OldInt08,bx
		mov	Wptr OldInt08+2,es

		mov	dx,OFFSET NewInt08	;set the our handler
		mov	ax,2508h
		int	21h

	Copyright:
		mov	dx,OFFSET Message	;init message
		mov	cx,MsgLen
		call	MsgOut

	TSR:
		mov	es,cs:PSP
		mov	es,es:[2Ch]		;free a environment
		mov	ah,49h
		int	21h

		mov	dx,((OFFSET Start)+15+256) ;Terminate and Stay Resident
		mov	cl,4
		shr	dx,cl
		mov	ax,3100h
		int	21h

; DS:DX = ptr to data buffer
; CX = # of bytes to output
; Purpose:  Output to handle 1 (default = console)

	MsgOut	PROC	NEAR
	      mov	bx,1			;BX = handle to output
	      mov	ah,40h
	      int	21h
	      ret
	MsgOut	ENDP

; set up data seg reg

	XXdata	PROC	NEAR
		  mov	ax,cs			;move CS to DS
		  mov	ds,ax			
		  ret
	XXdata	ENDP

; char convertion

	Get_Char	PROC	NEAR
		  jcxz  All_Done		;if CX = 0 then exit
		  inc	si
		  mov	al,es:[si]		;access to global variables
		  dec	cx
		  cmp	al,'a'			;check for lowercase
		  jb	Convert_Done
		  cmp	al,'z'
		  ja	Convert_Done
		  and	al,0DFh			;now convert to upcase
	Convert_Done:
		  ret
	All_Done:
		mov	cx,ResLen		;CX = length of message
		jmp	Incorrect_Parms
	Get_Char	ENDP

; messages

	Message	  DB	'Resident Video Clock Program V1.00A.',13,10
                  DB    '(C) Copyright 1990 Dima Stefankov. All Rights reserved.',0Dh,0Ah
		  DB    'Usage: VCLOCK   [options], where',13,10
                  DB    '               /u  -  uninstall program.',13,10
		  DB    '               /e  -  enable  display clock.',13,10
		  DB	'               /d  -  disable display clock.',13,10
	MsgLen    =	$ - Message
	Resident  DB    'VCLOCK already in memory...',13,10
	ResLen	  =	$ - Resident
	RemoveMsg DB	'Successfully removed from memory...',13,10
	RemLen	  =	$ - RemoveMsg
	UnHappy	  DB    'Unable to remove from memory...',13,10
	UnLen	  =	$ - UnHappy
	ResSwitch DB    'Send to existing program...',13,10
	SwitchLen =     $ - ResSwitch

; variables

	PSP	DW	?

CODE	ENDS

STACK	SEGMENT	STACK
	DB	32	DUP ('STACKxxx')
STACK	ENDS
	END	Start

