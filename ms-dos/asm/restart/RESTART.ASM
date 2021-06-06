			PAGE	63, 132
			TITLE	Warm PC Computer Boot 


; Name			RESTART.ASM
; Purpose		Warm/Cold boot through PC keyboard controller
; Version/Date		1.0   9/8/94		original
;			1.1   11/25/94		added time delay (about 3 sec)
; Author		Dmitry Stefankov
; Machine		any IBM PC compatible computer
; BIOS			Any
; Chip Set 		Any
; Copyright Notice	Copyright (c) 1994 Dmitry Stefankov
; Distribution		Only for Evaluation Purpose


	bFalse		=	0
	bTrue		=	NOT	bFalse

;*	swEmulationReset	=	bFalse		; false = hard	(cold)
							; true = soft (warm)
;**	swKeybdTrick		=	bTrue
	swSimulateInt154Fh	=	bTrue		; trick for very clever
							; memory managers
	swWorkAroundPM_STD	=	bTrue

	 errTerminateOk		=	0

	sBlanks			EQU	<'  '>
	chAsterisk		EQU	<'*'>
	chBlank			EQU	<' '>

	ioKbdCntlrOutPort	=	64h
	btPulseResetCpu		=	0FEh

	ioPM486DX2		=	0EBh

	aDelKeySystemScanCode	=	53h
	btAlt			=	08h
	btCtrl			=	04h

	aEnableMemTest		=	0
	aDisableMemTest		=	1234h

	aInt15			=	15h
	aFunc4F			=	4Fh
	aFunc86			=	86h

	aDosDispChar		=	02h
	aDosDispMessage		=	09h
	aDosConsoleInput	=	07h
	aDosSetIntVec		=	25h
	aDosGetIntVec		=	35h
	aDosTerminateProcess	=	4Ch


	mac@InBytePort		MACRO	Port, Value
		IFNB	<Value>
			mov	al, Value
		ENDIF
		IFNB	<Port>
			IF	Port	GE	100h
				mov	dx, Port
				in	al, dx
			ELSE
				in	al, Port
			ENDIF
		ELSE
			in	al, dx
		ENDIF
				ENDM

	mac@OutBytePort		MACRO	Port, Value
		IFNB	<Value>
			mov	al, Value
		ENDIF
		IFNB	<Port>
			IF	Port	GE	100h
				mov	dx, Port
				out	dx, al
			ELSE
				out	Port, al
			ENDIF
		ELSE
			out	dx, al
		ENDIF
				ENDM


	mac@OutWordPort		MACRO	Port, Value
		IFNB	<Value>
			mov	ax, Value
		ENDIF
		IFNB	<Port>
			IF	Port	GE	100h
				mov	dx, Port
				out	dx, ax
			ELSE
				out	Port, ax
			ENDIF
		ELSE
			out	dx, ax
		ENDIF
				ENDM

	mac@EmptyOperation	MACRO	Times
			IFNB	<Times>
			  REPT  Times
				nop
			  ENDM
			ENDIF
				ENDM

	
	mac@DelayIO_486		MACRO
			LOCAL	@D
				jmp	SHORT	@D
			  @D:
				ENDM


	mac@DelayIO		MACRO	Times
			IFNB	<Times>
			 REPT	Times
				mac@DelayIO_486
			 ENDM
			ENDIF		
				ENDM

	mac@WordRegToMem	MACRO	reg, memw
		mov	WORD PTR memw, reg
			ENDM

	mac@WordMemToReg	MACRO	memw, reg
		mov	reg, WORD PTR memw
			ENDM

	mac@ByteRegToMem	MACRO	reg, memb
		mov	BYTE PTR memb, reg
			ENDM

	mac@DosInterface	MACRO	FnAX, FnAH, FnAL
			IFNB	<FnAX>
				MOV	ax, FnAX
			ENDIF
			IFNB	<FnAH>
				MOV	ah, FnAH
			ENDIF
			IFNB	<FnAL>
				MOV	al, FnAL
			ENDIF
			int	21h
				ENDM

	mac@DisplayMessage	MACRO	msg
		mov	dx, OFFSET  msg
		mac@DosInterface	,aDosDispMessage
				ENDM

	mac@SetIntVec	MACRO	intnum,intcode
		IFNB	<intcode>
		mov	dx, OFFSET  intcode
		ENDIF
		mac@DosInterface	,aDosSetIntVec,intnum
				ENDM

	mac@GetIntVec	MACRO	intnum
		mac@DosInterface	,aDosGetIntVec,intnum
				ENDM

	mac@ConsoleInput	MACRO	
		mac@DosInterface	,aDosConsoleInput
				ENDM


	BIOS_DATA	SEGMENT  	AT  40h
		ASSUME DS:BIOS_DATA
		ORG	17h
dbKbdStatus_1	db	?
		ORG 	67h
dwJump_IP	dw	?
dwJump_CS	dw	?
		ORG	72h
dwMemTestFlag	db	?
	BIOS_DATA	ENDS


	BIOS_ROM	SEGMENT  	AT  0F000h
		ASSUME	CS:BIOS_ROM
		ORG  0FFF0h
@lpInit_Rom_Bios_Entry	LABEL	FAR
	BIOS_ROM	ENDS



	CODE	SEGMENT	WORD PUBLIC 'CODE'
	ASSUME	CS:CODE, DS:CODE, ES:CODE, SS:CODE
		ORG	100h

	@Init:
		jmp	@Start

	IF	swEmulationReset
	IF	swKeybdTrick
	szHello			db	13, 10
				db	'Do a soft reboot. Press any key to restart.'
				db	'$'
	ELSE
	szHello			db	13, 10
				db	'Do a warm reboot.'
				db	'$'
	ENDIF
	ELSE
	szHello			db	13, 10
				db	'Do a cold reboot.'
				db	'$'
	ENDIF

	IF	swEmulationReset
	IF	swKeybdTrick
		EVEN
	ddOldInt15		DD	0
	@NewInt15:
		cmp	ah, aFunc4F
		je	@FilterFunc4F
		jmp	DWORD PTR  cs:ddOldInt15
@FilterFunc4F:
		mov	al, aDelKeySystemScanCode
		pushf
		call	DWORD PTR  cs:ddOldInt15
		mov	al, aDelKeySystemScanCode
		stc
		iret
	ENDIF
	ENDIF
	@Start:

		mac@DisplayMessage  szHello

	@TimeDelay3sec:
		mov	dx, 50880		; (3000000L MOD 65536)
		mov	cx, 45			; (3000000 / 65536)
		mov	ah, aFunc86
		int	aInt15

	IF	swKeybdTrick
	ELSE
	IF	swSimulateInt154Fh
		mov	ax, SEG BIOS_DATA
		mov	es, ax
		ASSUME	es:BIOS_DATA
		mac@ByteRegToMem	<btAlt+btCtrl>,dbKbdStatus_1
		mov	ah, aFunc4F
		mov	al, aDelKeySystemScanCode 
		stc
		int	aInt15
	ENDIF
	ENDIF

	IF	swEmulationReset
	IF	swKeybdTrick
		mac@GetIntVec	aInt15
		mac@WordRegToMem	bx,ddOldInt15+0
		mac@WordRegToMem	es,ddOldInt15+2
		mac@SetIntVec	aInt15, @NewInt15
		mov	ax, SEG BIOS_DATA
		mov	es, ax
		ASSUME	es:BIOS_DATA
		mac@ByteRegToMem	<btAlt+btCtrl>,dbKbdStatus_1
		mac@ConsoleInput
		mac@WordMemToReg	ddOldInt15+0, dx
		push	ds
		mac@WordMemToReg	ddOldInt15+2, ds
		pop	ds
		mac@SetIntVec	aInt15
		jmp	@Exit
	ENDIF
	ENDIF
		mov	ax, SEG BIOS_DATA
		mov	es, ax
		ASSUME	es:BIOS_DATA
	IF	swEmulationReset
		mac@WordRegToMem	aDisableMemTest,dwMemTestFlag
		jmp	 @lpInit_Rom_Bios_Entry
	ELSE
		mac@WordRegToMem	aEnableMemTest,dwMemTestFlag
		mac@OutBytePort	ioKbdCntlrOutPort, btPulseResetCpu
	IF	swWorkAroundPM_STD
		mac@OutWordPort	ioPM486DX2
	ENDIF

		cli
	@WaitHere:
		hlt
		jmp		@WaitHere
	ENDIF
@Exit:
		mac@DosInterface	,aDosTerminateProcess,errTerminateOk

CODE	ENDS


	END	@Init
