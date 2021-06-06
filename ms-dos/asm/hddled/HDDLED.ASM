; Emulator for the light-diod of the hard disk drive activity

false		=	0
true		=	0FFh
MyID		=	0ABh
Wptr		EQU	<WORD PTR>
Bptr		EQU	<BYTE PTR>

MonoAttr	=	070h
fColorAttr	=	06Fh
hColorAttr	=	04Eh
ColorSeg	=	0B800h
MonoSeg		=	0B000h

ROM_DATA	SEGMENT		AT	40h
		ORG	49h
VideoMode	db	?
		ORG	4Eh
Buffer_Start	dw	?
ROM_DATA	ENDS

CODE	SEGMENT
	ASSUME CS:CODE,DS:CODE,SS:STACK

OldInt13	DD	?
PSP		DW	?
hMark		DW	hColorAttr * 256 + 'H'
fMark		DW	fColorAttr * 256 + 'F'
SaveImage	DW	3  Dup (?)
HardDiskFlag	DB	true
hDskCount	DB	0
fDskCount	DB	0

SetVideoVars	PROC	NEAR
		mov	ax,SEG ROM_DATA
		mov	es,ax			;ES = 40h
		ASSUME	ES:ROM_DATA
		mov	al,VideoMode
		cmp	al,7
		jne	ColorMode

		mov	ax,MonoSeg
		mov	Bptr cs:hMark+1,MonoAttr
		mov	Bptr cs:fMark+1,MonoAttr
		jmp	SHORT	ModeOk

	ColorMode:
		mov	ax,ColorSeg
	ModeOk:
		add	ax,Buffer_Start		;AX = video buffer offset
		mov	ds,ax
		ret
SetVideoVars	ENDP

NewInt13	PROC	FAR
		sti				;enable intrs
		cmp	ah,MyID			;our function?
		jne	CallOrigDisk
		mov	ax,MyID			;AX = our code
		mov	bx,cs			;BX = our code segment
		sub	bx,10h			;BX = our PSP
		les	dx,cs:OldInt13		;ES:DX = old Int 13h
		iret

	CallOrigDisk:
		cmp	dl,80h			;DL = 80h-81h (fixed disk 0,1)
		jae	Hard_Disk
		mov	cs:HardDiskFlag,false

	Hard_Disk:
		push	ax			;save a registers
		push	ds
		push	es

		call	SetVideoVars

		mov	ax,Wptr ds:[0000h]	;save the 1st video word
		mov	cs:SaveImage[0],ax
		mov	ax,Wptr ds:[0002h]	;save the 2nd video word
		mov	cs:SaveImage[2],ax
		mov	ax,Wptr ds:[0004h]	;save the 3rd video word
		mov	cs:SaveImage[4],ax

		mov	ax,cs:[hMark]		;which mask to use?
		cmp	cs:HardDiskFlag,true
		je	Put_Video_Word
		mov	ax,cs:[fMark]

	Put_Video_Word:
		mov	Wptr ds:[0000h],ax	;display the LED
		mov	al,'D'
		mov	Wptr ds:[0002h],ax	;display the LED

		mov	al,dl
		and	al,03h
		cmp	cs:HardDiskFlag,true
		je	Hard_Filter
		cmp	al,cs:fDskCount
		jb	Put_Number
		mov	al,cs:fDskCount
		dec	al			;AL = count - 1
		jmp	SHORT	Put_Number

	Hard_Filter:
		cmp	al,cs:hDskCount
		jb	Put_Number
		mov	al,cs:hDskCount
		dec	al			;AL = count - 1

	Put_Number:
		add	al,'0'			;displat the drive number
		mov	Wptr ds:[0004h],ax
		
		pop	es			;recover registers
		pop	ds
		pop	ax

		pushf				;emulate the interrupt
		cli
		call	cs:OldInt13

		pushf				;save a world
		push	ax
		push	ds
		push	es

		call	SetVideoVars
		mov	ax,cs:SaveImage[0]	;recover the old video image
		mov	Wptr ds:[0000h],ax
		mov	ax,cs:SaveImage[2]	;recover the old video image
		mov	Wptr ds:[0002h],ax
		mov	ax,cs:SaveImage[4]	;recover the old video image
		mov	Wptr ds:[0004h],ax

		pop	es			;restore registers
		pop	ds
		pop	ax

		mov	cs:HardDiskFlag,true
		mov	Bptr cs:fMark+1,fColorAttr
		mov	Bptr cs:hMark+1,hColorAttr
		popf
		ret	2			;preserve flags
NewInt13	ENDP

; initialization code

	Start:
		mov	cs:PSP,es

		mov	ah,8			;get the number of HDs
		mov	dx,80h
		int	13h
		mov	cs:hDskCount,dl

		int	11h			;AX = equipment byte
		test	al,1			;diskette drives installed
		jz	no_floppy_drives
		rol	al,1
		rol	al,1		
		and	al,3			;AL = drives - 1
		inc	al
		mov	cs:fDskCount,al

	no_floppy_drives:
		mov	ah,MyID			;check for presence
		sub	bx,bx			;BX = 0
		int	13h
		
		cmp	al,MyID			;we present?
		jnz	Install

		or	bx,bx			;BX != 0
		jz	Install

		push	bx
		cmp	Bptr ds:[80h],0		;present cmd parameter
		jne	Remove

		call	XXdata
		ASSUME  DS:CODE
		mov	dx,OFFSET Resident
		mov	cx,ResLen

	GotoDos:
		call	MsgOut
		mov	ax,4C00h
		int	21h

	Remove:
		call	XXdata
		ASSUME  DS:CODE
		mov	si,es			;save resident code seg
		mov	cx,bx			;CX = resident
		add	cx,10h			;CX = PSP + 256 bytes

		mov	ax,3513h		;get the vector 13h
		int	21h
		mov	ax,es			;AX = vector segment

		cmp	cx,ax			;match segment?
		jne	NoRemove
		cmp	bx,OFFSET NewInt13
		jne	NoRemove

		push	ds
		mov	ds,si
		mov	ax,2513h		;restore old INt 13h
		int	21h

		pop	ds
		pop	es			;ES = resident PSP

		mov	ah,49h			;free block
		int	21h

		mov	es,es:[2Ch]		;free environment
		mov	ah,49h
		int	21h

		mov	dx,OFFSET RemoveMsg
		mov	cx,RemLen
		jmp	GotoDos

	NoRemove:
		mov	dx,OFFSET UnHappy
		mov	cx,UnLen
		jmp	GotoDos

	Install:
		call	XXdata
		ASSUME  DS:CODE

		mov	ax,3513h		;get the vector 13h
		int	21h
		mov	Wptr OldInt13,bx
		mov	Wptr OldInt13+2,es

		mov	dx,OFFSET NewInt13	;set the our handler
		mov	ax,2513h
		int	21h

		mov	dx,OFFSET Message	;display copyright
		mov	cx,MsgLen
		call	MsgOut

	TSR:
		mov	es,cs:[PSP]		;free environment
		mov	es,es:[2Ch]
		mov	ah,49h
		int	21h

		mov	dx,((OFFSET Start)+15+256) ;Terminate and Stay Resident
		mov	cl,4
		shr	dx,cl
		mov	ax,3100h
		int	21h

; DS:DX = ptr to data buffer
; CX = # of bytes to output

	MsgOut	PROC	NEAR
	      mov	bx,1			;console
	      mov	ah,40h
	      int	21h
	      ret
	MsgOut	ENDP

; set up data seg reg

	XXdata	PROC	NEAR
		  mov	ax,cs
		  mov	ds,ax
		  ret
	XXdata	ENDP

; messages

	Message	  DB	'Hard/Floppy Disk Drive LED Emulator Program V1.01A.',13,10
                  DB    '(C) Copyright 1990 Dima Stefankov. All Rights reserved.',0Dh,0Ah
		  DB	'Usage: HDDLED  [/u] , where /u - uninstall program',13,10
	MsgLen    =	$ - Message
	Resident  DB    'HDDLED already in memory...',13,10
	ResLen	  =	$ - Resident
	RemoveMsg DB	'Successfully removed from memory...',13,10
	RemLen	  =	$ - RemoveMsg
	UnHappy	  DB    'Unable to remove from memory...',13,10
	UnLen	  =	$ - UnHappy


CODE	ENDS

STACK	SEGMENT	STACK
	DB	32	DUP ('STACKxxx')
STACK	ENDS
	END	Start

