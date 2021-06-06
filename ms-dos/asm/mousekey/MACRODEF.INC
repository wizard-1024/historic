			SUBTTL	Equates, definitions, structures, macros
			PAGE

;-----------------------------------------------------------------
; Name          	MACRODEF.INC				 ;
; Purpose		Include file				 ;
; Version		1.00A	12/24/91			 ;
;			1.00B   07/24/91			 ;
;			1.00C   08/24/91			 ;
; Programmer		Dmitry Stefankov			 ;
; Copyright Notice	(C) Copyright Dmitry Stefankov 1990,1991 ;
;----------------------------------------------------------------- 



COMMENT  !

******************** Notation Description *****************

	prefix			meaning
     ------------     -------------------------------
	c			char
	db			byte (unsigned char)
	i			integer
	b			boolean
	n			short integer
	dw			word (unsigned long)
	dd			double word (unsigned long)
	r			real


	s			string
	sz			string terminated by NULL
	sa			ASCII string


	p			pointer
	sp			pointer to string
	fp			far pointer
	np			near pointer
	wp			pointer to word
	cp			pointer to char
	bp			pointer to byte
	rp			pointer to real


	h			handle (word)
	m			message
	l			length
	x,y,z			coordinates X,Y,Z
	w			window
        f			file


	fn			function
	_			procedure
	@			label
	mac@			macro

********************* compiled by Dima Stefankov, 07/23/91 ***********

  !


; boolean equates

	false	=	0
	true	=	0FFh


; pointer equates

	bPTR	EQU	<BYTE PTR>
	wPTR	EQU	<WORD PTR>
	dPTR	EQU	<DWORD PTR>


; ASCII equates

	NULL		=	0
	TAB		=	9
        LF              =       0Ah
        CR              =       0Dh
        ESC_CH	        =       1Bh
	SPACE		=	32


; DOS standard handles

	STD_INPUT	=	0
	STD_OUTPUT	=	1
	STD_ERROR	=	2
	STD_AUX		=	3
	STD_PRN		=	4


; DOS magic numbers

	PSP_SIZE	=	100h


; interrupts equates

	TimerHdwrINT	=	08h
	KbdHdwrINT	=	09h
	HdwrINTn0C	=	0Ch
        DiskSoftINT     =       13h
	KbdSoftINT	=	16h
        DosFnINT        =       21h
	MultiplexINT	=	2Fh
        MouseSoftINT    =       33h


; Disk Int 13h functions

	GetDiskParms	=	08h


; Dos Int 21h functions

	OutputMessage	=	09h
	SetVector	=	25h
	KeepProcess	=	31h
	GetVector	=	35h
	DosRead		=	3Fh
	DosWrite	=	40h
	FreeMemBlock	=	49h
	ExitProcess	=	4Ch


; Mouse Software Int 33h functions

	HardReset	=	00h
	ShowCursor	=	01h
	HideCursor	=	02h
	GetStatusPos	=	03h
	SetPos		=	04h
	SetIntHandler	=	0Ch
	MotionPixelRatio =	0Fh
	SwapIntHandler  =	14h
	SoftReset	=	21h


; multiplex process equates 

	ExtID		=	'DS'
	TimeParkID	=	90h
	HddLedID	=	91h
	VclockID	=	92h
	MouseKeyID	=	93h
	SoftKeyID	=	94h
	KeybRussID	=	95h
	FastBootID	=	96h


; subfunctions for multiplex processes

	Install		=	0               ;at call:
						;  AL = 00   OK to install
						;     = 01   not OK to install
						;     = 0FF  installed
						;  BX = extended ID
	GetProgInfo	=	1		;at return:
						;  AL = good return
						;  BX = program PSP
						;  ES:DI = ptr to array of 
						;	 hooked vectors
	GetSetSystemFlags	=	2	;
	GetFlags		=	0	;at cal:
						;  BL = 0
						;at return:
						;  CX = old program flags
	SetFlags		=	1	;at call
						;  BL = 1
						;  CX = new program flags

	OK_to_Install		=	00h	;return  values for
	not_OK_to_Install	=	01h	;subfn install
	Already_Installed	=	0FFh
	BadReturn		=	0FFh	;invalid call or parameter


; structures definitions


; defined only for pass 1

IF1

; ===================================================
;   		general-purpose macros
; ===================================================

; set the new subtitle on page

		mac@Break	MACRO	subtitle
			subttl	subtitle
			page
				ENDM

; set the location counter to the new value

		mac@SetORG	MACRO	newval
			ORG	newval
				ENDM

; align on word boundary

		mac@AlignWord	MACRO
			 EVEN				;;MASM directive
				ENDM

; set Interrupt Flag

		mac@IntrsON	MACRO
			sti
				ENDM

; clear Interrupt Flag

		mac@IntrsOFF	MACRO
			cli
				ENDM

; set the mem/reg to constant value

		mac@SetConst	   MACRO	regmem,val
			mov    regmem,val
			   ENDM

; set the mem/reg to boolean constant

		mac@BooleanConst  MACRO	  regmem,BooleanVal
			IFIDNI	<Booleanval>,<false>
				mov	regmem,false
			ELSEIFIFNI	<BooleanVal>,<true>
				mov	regmem,true
			ELSE
				.ERR
				%OUT	Undefined Boolean Constant
			ENDIF
				  ENDM	
; set or reset ZERO FLAG detecting zero value in register

	mac@ZeroValue?	    MACRO      reg1,reg2
		IFNB	<reg2>
		    or   reg1,reg2
		ELSE
		    or   reg1,reg1
		ENDIF
		    ENDM

; repeated instructions many times

	mac@REPEAT    MACRO	instr,times
		REPT  times
		    instr
		ENDM
		    ENDM

; save registers in list

        mac@Save      MACRO      reglist
              IRP   reg,<reglist>
                 push   reg
              ENDM
                  ENDM

; restore registers in list

        mac@Restore    MACRO      reglist
              IRP   reg,<reglist>
                 pop   reg
              ENDM
                  ENDM

; convert char to upcase

        mac@UpperCase  MACRO    reg
             LOCAL  Done
                 cmp    reg,'a'
                 jb     Done
                 cmp    reg,'z'
                 ja     Done
                 sub    reg,'a' - 'A'
             Done:
                      ENDM

; emulate the interrupt call

             mac@OldIntCall  MACRO  turnoff,memloc
	                pushf
			IFIDNI      <turnoff>,<off>
			     cli
			ELSEIFIDNI  <instr>,<on>
			     sti
			ELSE
			   .ERR
			   %OUT  Undefined parameter
			ENDIF
                        call  dPTR  memloc
                      ENDM

; jump to saved vector

             mac@OldJump  MACRO  memloc
                       jmp  dPTR  memloc
                      ENDM

; move to DS new value

	       mac@MoveToDS    MACRO     segreg,reg
			IFNB	<reg>
			mov	reg,segreg
			mov	ds,reg
			ELSE
			push	segreg
			pop	ds
			ENDIF
			     ENDM

; move to ES new value

	       mac@MoveToES    MACRO     segreg,reg
			IFNB	<reg>
			mov	reg,segreg
			mov	es,reg
			ELSE
			push	segreg
			pop	es
			ENDIF
			     ENDM

; set one bit or couple

	       mac@SetBit	     MACRO	memloc,value
			or	memloc,value
			     ENDM

; reset one bit or couple

	       mac@ResetBit     MACRO	memloc,value
			and	memloc,value
			     ENDM

; test one bit or couple

	       mac@TestBit     MACRO	memloc,value
			test	memloc,value
			     ENDM

; set register to zero

	       mac@LoadZero     MACRO	reg
			sub	reg,reg
			     ENDM

; description of interrupt vectors structures

	       mac@VecEntry   MACRO   vec_num,veclist
			dw	vec_num
		   IRP	   entry,<veclist>
                                      DB       entry
			Old&&entry    DD	?
		   ENDM
			     ENDM

; add value to reg/mem

               mac@IncVal    MACRO    reg,value
                        IFNB   <value>
                            add    reg,value
                        ELSE
                            inc    reg
                        ENDIF
                             ENDM

; add value to reg/mem

               mac@DecVal    MACRO    reg,value
                        IFNB   <value>
                            sub    reg,value
                        ELSE
                            dec    reg
                        ENDIF
                             ENDM

; jump SHORT

               mac@sJump    MACRO    target
                        IFNB   <target>
                            JMP   SHORT   target
                        ELSE
                            JMP   SHORT  $ + 2
                        ENDIF
                             ENDM

; use for 286-computers that have a bug in micro-code
; Note: the flags must be present already on stack

		mac@Popff	MACRO
			LOCAL	A,B
			mac@sJump   B
		    A:
			iret
		    B:	
			push	cs
			call	A		
				ENDM

; flush the prefetch queue

		mac@FlushJump	MACRO
			mac@sJump
				ENDM

; emulate the wait state for slow bus

		mac@DelayIO	MACRO	num
			IFNB	<num>
			REPT	num
			  mac@sJump
			ENDM
			ELSE
			  mac@sJump
			ENDIF
				ENDM

; load offset of variable into reg/mem

               mac@LoadOFS   MACRO    reg,varofs
			mov	reg,OFFSET varofs
                             ENDM

; load segment of variable into reg/mem

               mac@LoadSEG    MACRO    reg,varseg
			mov	reg,SEG varseg
                             ENDM

; save the vector in mem

             mac@SavePTR  MACRO   sreg,greg,memloc
                  mov   wPTR  memloc,greg
                  mov   wPTR  memloc+2,sreg
                        ENDM

; set the vector from pointer

             mac@SetPTR  MACRO   sreg,greg,memloc
		   l&sreg     greg,memloc
                        ENDM

; shift to right

             mac@ShiftRight  MACRO   reg,count
			IFNB   <count>
			mac@REPEAT   <shr	 reg,1>,count
			ELSE
			   shr	 reg,1
			ENDIF
                           ENDM

; shift to left

             mac@ShiftLeft  MACRO   reg,count
			IFNB   <count>
			mac@REPEAT   <shl	 reg,1>,count
			ELSE
			   shl	 reg,1
			ENDIF
                           ENDM

; input byte from specified port

		mac@InByte	MACRO   port
			IFNB	<port>
			    mov    dx,port
			ENDIF
			    in	  al,dx
				ENDM	      

; input word from specified port

		mac@InWord	MACRO   port
			IFNB	<port>
			    mov    dx,port
			ENDIF
			    in	  ax,dx
				ENDM	      

; output byte to specified port

		mac@OutByte	MACRO   port
			IFNB	<port>
			    mov    dx,port
			ENDIF
			    out	  dx,al
				ENDM	      

; output word to specified port

		mac@OutWord	MACRO   port
			IFNB	<port>
			    mov    dx,port
			ENDIF
			    out	  dx,ax
				ENDM	      

; exchange memory bytes

		mac@ExchangeByte	MACRO	mem1,mem2,regb
			mov	 regb,mem1		;; AL = mem1
			xchg	 regb,mem2		;; mem2 = mem1, AL = mem2
			mov	 mem1,regb		;; mem1 = mem2
				ENDM

; exchange memory words

		mac@ExchangeWord	MACRO	mem1,mem2,regw
			mov	 regw,mem1		;; AX = mem1
			xchg	 regw,mem2		;; mem2 = mem1, AX = mem2
			mov	 mem1,regw		;; mem1 = mem2
				ENDM

; for code debugging

		mac@DosDebugMessage  MACRO	message
			LOCAL	L,M
			   mac@sJump   L
		   M	db	&message
			db	CR,LF,'$'
		   L:	mac@Save	  <ax,dx,ds>
			lea	dx,M
			mac@MoveToDS	cs		;; DS:DX -> message'$'
			mov	ah,OutputMessage	;; DOS OUTPUT MESSAGE
			int	DosFnINT
			mac@Restore  <ds,dx,ax>
				ENDM


		mac@BiosDebugMessage  MACRO	message
			LOCAL	L,M
			   mac@sJump   L
		   M	db	&message
			db	CR,LF,0
		   L:	mac@Save	  <ax,si,ds>
			lea	si,M
			mac@MoveToDS  cs		;; DS:SI -> message-0
			mac@Restore  <ds,si,ax>
				ENDM


		mac@JumpOnInstr	MACRO	instr,JumpLabel
			LOCAL	L
			IFIDNI      <instr>,<JE>
			     jne  L
			ELSEIFIDNI  <instr>,<JNE>
			     je   L
			ELSEIFIDNI  <instr>,<JZ>
			     jnz   L
			ELSEIFIDNI  <instr>,<JNZ>
			     jz   L
			ELSEIFIDNI  <instr>,<JC>
			     jnc   L
			ELSEIFIDNI  <instr>,<JNC>
			     jc   L
			ELSEIFIDNI  <instr>,<JA>
			     jna   L
			ELSEIFIDNI  <instr>,<JNA>
			     ja   L			
			ELSEIFIDNI  <instr>,<JMP>
			     ;; nothing
			ELSE
			   %OUT  <Undefined instruction>
			   .ERR
			ENDIF
			  jmp	Jumplabel
		   L:
				ENDM


; =====================================================
; 			disk calls macros
; =====================================================

; general disk call, function in AX

	mac@DiskCallAX  MACRO	reg
            IFNB    <reg>
	      mov    ax,reg
            ENDIF
	     int    DiskSoftInt
		  ENDM

; general disk call, AH -> 1st paramter, AL -> 2nd parameter

	mac@DiskCall  MACRO	reg1,reg2
            IFNB    <reg1>
	      mov    ah,reg1
            ENDIF
            IFNB    <reg2>
	      mov    al,reg2
            ENDIF
	      int    DiskSoftInt
		  ENDM

; disk BIOS function 8

	mac@GetDiskParms  MACRO	disknum
            IFNB    <disknum>
		mov	dl,disknum
            ENDIF
	      mov    ah,GetDiskParms
	      int    DiskSoftInt
		  ENDM


;====================================================
;		keyboard macros calls
;====================================================

; general keyboard I/O calls, AX ->  parm

		mac@KbdCallAX	MACRO	reg
			IFNB  <reg>
			   mov	ax,reg
			ENDIF
			     int    KbdSoftInt
				ENDM

; general keyboard I/O calls, AH -> 1st parm, AL -> 2nd parm

		mac@KbdCall	MACRO	reg1,reg2
			IFNB  <reg1>
			   mov	ah,reg1
			ENDIF
			IFNB	<reg2>
			    mov	 al,reg2
			ENDIF
			     int    KbdSoftInt
				ENDM

; read a keyboard


		mac@ReadKbd   MACRO
			mac@KbdCall  0
			    ENDM


; ===========================================================
; 			DOS calls macros
; ===========================================================

; general DOS call, AH -> 1st parm, AL -> 2nd parm

	mac@DosCall	MACRO	reg1,reg2
            IFNB    <reg1>
	      mov    ah,reg1
            ENDIF
            IFNB    <reg2>
	      mov    al,reg2
            ENDIF
	      int     DosFnInt
		ENDM

; general DOS call, function in AX
 
	mac@DosCallAX  MACRO  reg
            IFNB    <reg>
	      mov    ax,reg
            ENDIF
	      int     DosFnInt
		   ENDM

; DOS function 25h

             mac@SetIntVec     MACRO   vecnum,memofs
		    IFNB   <memofs>
			mov   dx,memofs
		    ENDIF
		    IFNB  <vecnum>
                       mac@DosCallAX  <SetVector shl 8 + vecnum>
		    ELSE
                       mac@DosCall  SetVector
		    ENDIF
                          ENDM
; DOS function 35h

             mac@GetIntVec     MACRO   vecnum
		    IFNB  <vecnum>
                       mac@DosCallAX  <GetVector shl 8 + vecnum>
		    ELSE
                       mac@DosCall  GetVector
		    ENDIF
                          ENDM

; DOS function 49h

	     mac@FreeBlock  MACRO    memseg
		    IFNB  <memseg>
			   mov	es,memseg
		     ENDIF
                      mac@DosCall   FreeMemBlock
			  ENDM

; DOS function 09h

	      mac@DispStr	  MACRO    memofs
		    IFNB   <memofs>
			mov   dx,memofs
		    ENDIF
                     mac@DosCall   OutputMessage
			  ENDM

; DOS function 31h

	       mac@TSR	     MACRO	bytes,errorlevel
			IFNB   <bytes>
			   mov	dx,bytes
			   add	dx,15		;;align on para boundary
			   mov	cl,4
			   shr	dx,cl		;; convert to para count
			ENDIF
			IFNB	<errorlevel>
			   mac@DosCallAX   <KeepProcess shl 8 + errorlevel>
			ELSE
			  mac@DosCall   KeepProcess
			ENDIF
			     ENDM

; DOS function 40h

		mac@WriteHandle   MACRO   handle,count,memofs
			IFNB   <handle>
			   mov	bx,handle
			ENDIF
			IFNB   <count>
			   mov	cx,count
			ENDIF
			IFNB   <memofs>
			   mov	dx,memofs
			ENDIF
			mac@DosCall  DosWrite
				  ENDM

; DOS function 3Fh

		mac@ReadHandle   MACRO   handle,count,memofs
			IFNB   <handle>
			   mov	bx,handle
			ENDIF
			IFNB   <count>
			   mov	cx,count
			ENDIF
			IFNB   <memofs>
			   mov	dx,memofs
			ENDIF
			mac@DosCall  DosRead
				  ENDM

; DOS function 4Ch

		mac@Terminate   MACRO  errorlevel
			IFNB	<errorlevel>
			   mac@DosCallAX   <ExitProcess shl 8 + errorlevel>
			ELSE
			  mac@DosCall   ExitProcess
			ENDIF
			     ENDM

; DOS predefined labels

		mac@DosPSP	MACRO
		ORG	2Ch
	@Environment	label	word

		ORG	5Ch
	@FCB_One	label	byte

		ORG	6Ch
	@FCB_Two	label	byte

		ORG	80h
	@psp_cmd_line_size	label	byte

		ORG	81h
	@psp_cmd_line_tail	label	byte
				ENDM
			

; ======================================================
; 		multiplex processes macros
; ======================================================

; general MP calls, AH -> 1st parm, AL -> 2nd parm

		mac@Multiplex   MACRO	num,subcode
			IFNB   <num>
			  mov	ah,num
			ENDIF
			IFNB    <subcode>
			  mov	al,subcode
			ENDIF
			int	MultiplexInt
			      ENDM


; =======================================================
; 			mouse calls macros
; =======================================================

; general mouse driver call, AX -> parm

             mac@MouseCall  MACRO   reg
                   IFNB   <reg>
                       mov  ax,reg
                   ENDIF
                       int  MouseSoftInt
                          ENDM

; mouse driver fn 00h

             mac@MouseGeneralReset  MACRO
			mac@MouseCall  HardReset
                          ENDM

; mouse driver fn 01h

             mac@MouseShowCursor  MACRO
			mac@MouseCall  ShowCursor
                          ENDM

; mouse driver fn 02h

             mac@MouseHideCursor  MACRO
			mac@MouseCall  HideCursor
                          ENDM


; mouse driver fn 03h

	     mac@MouseGetStatus  MACRO  
			mac@MouseCall  GetStatusPos
                          ENDM

; mouse driver fn 04h

	     mac@MouseSetPosition  MACRO  NewX,NewY
			IFNB  <NewX>
			   mov	cx,NewX
			ENDIF 
			IFNB  <NewY>
			   mov	dx,NewY
			ENDIF 
			mac@MouseCall  SetPos
                          ENDM

; mouse driver fn 0Ch

	     mac@MouseSetEventHandler  MACRO   CallMask,EventPtr
			IFNB  <CallMask>
			  mov	cx,CallMask
			ENDIF
			IFNB  <EventPtr>
			  les   dx,EventPtr
			ENDIF
			mac@MouseCall  SetIntHandler
                          ENDM

; mouse driver fn 0Fh

	     mac@MouseSetMotionPixelRatio  MACRO  
			mac@MouseCall  MotionPixelRatio
                          ENDM

; mouse driver fn 14h

	     mac@MouseSwapEventHandler  MACRO   CallEventMask,EventPtr
			IFNB  <CallMask>
			  mov	cx,CallEventMask
			ENDIF
			IFNB  <EventPtr>
			  les   dx,EventPtr
			ENDIF
			mac@MouseCall  SwapIntHandler
                          ENDM

; mouse driver fn 21h

             mac@MouseSoftReset  MACRO
			mac@MouseCall  SoftReset
                          ENDM

; alternate keyboard handler structure

ALTERNATE_HANDLER_ENTRY	STRUC
		USER_ALTERNATE_CALL	dd	?
		USER_ALTERNATE_MASK	dw	?
		fUSER_ALTERNATE_ACTIVE  db	?
ALTERNATE_HANDLER_ENTRY		ENDS


; end of pass 1

ENDIF

; ==========================================================
;			 end of file
; ==========================================================
