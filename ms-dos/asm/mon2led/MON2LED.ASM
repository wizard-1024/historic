	PAGE	60, 132

; Copyright (c) 1994 Dmitry Stefankov
; Evaluation code only

	.186

swDebugLevel	=	0	; 0 = no debugging 
				; 2 = debugging of TSR internal logic

swSlowlyBios    =       1	; like Phoenix, Acer
aSlowCountExt	=	1
aSlowCountInt	=	8000h
swSyncBIOS      =       0

BIOS_DATA	SEGMENT		AT 40h
	ORG	17h
dwKBD_FLAGS_1	db	?
dwKBD_FLAGS_2	db	?
	ORG	96h
dwKBD_FLAGS_3	db	?
dwKBD_FLAGS_4	db	?
	btSCROLL_LED_ON		=	01h
	btNUM_LED_ON		=	02h
	btCAPS_LED_ON		=	04h
BIOS_DATA	ENDS
	
CODE	SEGMENT	BYTE PUBLIC  'CODE'
ASSUME	CS:CODE,DS:CODE,SS:STACK

		ORG	0
@StartOfResidentCode	LABEL	BYTE


_lpDiskInt	PROC	FAR
		pushf
		test	dl, 80h
		jnz	@HardDisk

@GoToPrevDiskInt:
@L1:
		popf
		jmp	DWORD PTR	cs:ddPrevDiskInt

@HardDisk:
		cmp	ah, 2
		je	@DisplayActivity
		cmp	ah, 3
		jne	@GoToPrevDiskInt

@DisplayActivity:
		popf
		pop	cs:dwReturnIP
		pop	cs:dwReturnCS
		popf

		sti
		pushf
		call	_SendLED_ON
		popf

		pushf
		call	DWORD PTR	cs:cs:ddPrevDiskInt

		pushf
		call	_SendLED_OFF
		popf
		jmp	DWORD PTR	cs:@ddReturnAddress
_lpDiskInt	ENDP



_SynchController	PROC	NEAR
		mov	cx, 0FFFFh

	@Wait2:
		jmp	SHORT  $ + 2
		in	al, 64h
		test	al, 2
		jz     @SynchOk
		loop   @Wait2
		stc

	@SynchOk:
		ret
_SynchController	ENDP

IF	swSyncBIOS	GE	1
_WaitAcknowledge	PROC	NEAR
		mov	ah, 3
		ASSUME	DS:BIOS_DATA
	@1:
		mov	cx, 0FFFFh

	@WaitAck:
		mov	al, dwKBD_FLAGS_4
		test	al, 00010000b
		jz	@AckDone
		loop	@WaitAck
		dec	ah
		jnz	@1
		stc
	@AckDone:
		clc
		ret
_WaitAcknowledge	ENDP
ENDIF


_SendLED_ON		PROC	NEAR
		push	ax
		push	cx
		push	ds
		
		mov	ax, SEG BIOS_DATA
		mov	ds, ax
		ASSUME	DS:BIOS_DATA

		call	_SynchController
		jc     @DoneBad
		and	dwKBD_FLAGS_4, 00101111b
		cli
		mov	al, 0EDh
		out	60h, al
		sti

IF	swSlowlyBios
		mov	ax, aSlowCountExt
	@Slow1:
		mov	cx, aSlowCountInt
	@Slow2:
		loop	@Slow2
		dec	ax
		jnz	@Slow1
ENDIF

IF	swSyncBIOS	GE	1		
		call	_WaitAcknowledge
		jc     @DoneBad
ENDIF
		call	_SynchController
		jc     @DoneBad
		mov	al, dwKBD_FLAGS_4
		and	al, 00000111b
		or	al, 1
		cli
		out	60h, al
		and	dwKBD_FLAGS_4, 00101111b
		sti
IF	swSyncBIOS	GE	1
		call	_WaitAcknowledge
		jc	@DoneBad
ENDIF
		pop	ds
		pop	cx
		pop	ax
		ret
	@DoneBad:
		mov	al, 0F4h
		out	60h, al
		sti
		pop	ds
		pop	cx
		pop	ax
		ret
_SendLED_ON		ENDP


_SendLED_OFF		PROC	NEAR
		push	ax
		push	cx
		push	ds
		
		mov	ax, SEG BIOS_DATA
		mov	ds, ax
		ASSUME	DS:BIOS_DATA
		call	_SynchController
		jc     @DoneBad
		cli
		mov	al, 0EDh
		out	60h, al
		and	dwKBD_FLAGS_4, 00101111b
		sti

IF	swSlowlyBios
		mov	ax, aSlowCountExt
	@Slow3:
		mov	cx, aSlowCountInt
	@Slow4:
		loop	@Slow4
		dec	ax
		jnz	@Slow3
ENDIF

IF	swSyncBIOS	GE	1
		call	_WaitAcknowledge
		jc     @DoneBad
ENDIF
		call	_SynchController
		jc     @DoneBad
		mov	al, dwKBD_FLAGS_4
		and	al, 00000111b
		and	al, 0FEh
		cli
		out	60h, al
		and	dwKBD_FLAGS_4, 00101111b
		sti
IF	swSyncBIOS	GE	1
		call	_WaitAcknowledge
		jc	@DoneBad
ENDIF
		pop	ds
		pop	cx
		pop	ax
		ret
_SendLED_OFF		ENDP


ddPrevDiskInt	dd	0
@ddReturnAddress	LABEL	DWORD
dwReturnIP	dw	0
dwReturnCS	dw	0


IF	swDebugLevel	EQ	2
_lpDummyIRET	PROC	FAR
		iret
_lpDummyIRET	ENDP
ENDIF


@EndOfResidentCode	LABEL	BYTE

sHelloMsg	DB	'Monitor in keyboard LEDs Version 0.01, Copyright (c) 1994 Dmitry Stefankov'
		DB	13, 10, '$'

@Start:
		mov	ax, cs
		mov	ds, ax
		ASSUME  DS:CODE

IF	swDebugLevel	EQ	2
		mov	WORD PTR  ddPrevDiskInt+0, OFFSET _lpDummyIRET
		mov	WORD PTR  ddPrevDiskInt+2, cs
		
		mov	dl, 80h
		mov	ah, 02h
		pushf
		push	cs
		call	NEAR  PTR  _lpDiskInt
		mov	ax,4c00h
		int	21h
ENDIF

IF	swDebugLevel	EQ	0
		mov	dx, OFFSET sHelloMsg
		mov	ah, 9
		int	21h

		mov	dx, OFFSET  _lpDiskInt
		mov	ax, cs
		mov	es, ax
		mov	bx, dx

		mov	ah, 13h
		int	2Fh
		mov	WORD PTR  cs:ddPrevDiskInt+0, dx
		mov	WORD PTR  cs:ddPrevDiskInt+2, ds

		mov	dx, (((OFFSET @EndOfResidentCode) - (OFFSET @StartOfResidentCode)) + 15+256) SHR 4
		mov	ax, 3100h
		int	21h
ENDIF
		mov	ax,4c00h
		int	21h

CODE	ENDS

STACK	SEGMENT	WORD	STACK	'STACK'
	db	512	DUP	('STACKxxx')
STACK	ENDS

	END	@Start
