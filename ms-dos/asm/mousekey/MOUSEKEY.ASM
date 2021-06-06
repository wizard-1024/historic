			PAGE	60,132
			TITLE	Keyboard Emulator with Microsoft Mouse
			SUBTTL	Global declarations

;-----------------------------------------------------------------------
; Name		    MOUSEKEY.ASM				       ;
; Version	    1.03A					       ;
; Purpose 	    Keyboard emulator by Microsoft-or-Compatible Mouse ;
; Date		    Initial    02/01/91				       ;
;		    1.02A      07/12/91				       ;
;		    1.03A      07/24/91				       ;
; Programmer	    Dmitry Stefankov				       ;
; Copyright Notice  (C) Copyright 1991 Dmitry Stefankov		       ;
;-----------------------------------------------------------------------

;============================================
;	 equates, macros, structures
;============================================



	DeLim		EQU	':'
	HookedVecs	=	2		;08h,2Fh
        Version         EQU    "V1.03A"

MaxValue	=	3

CR_Key          =       1C0Dh
ESC_Key         =       011Bh
PgUp_Key        =       4900h
PgDn_Key        =       5100h
Left_Arrow      =       4B00h
Right_Arrow     =       4D00h
Up_Arrow        =       4800h
Down_Arrow      =       5000h

TimerTicks	=	18
MinDefaultSen	=	1
MaxDefaultSen   =	99
HorizDefMickey	=	8
VertDefMickey	=	16

MonoAttr	=	70h
ColorAttr	=	4Eh
ColorInverse	=	70h
MonoInverse	=	07h
ScreenRows	=	25
MonoCardSeg	=	0B000h
ColorCardSeg	=	0B800h

EnhancedKbd	=	10h
StdMenuWidth	=	5
FuncMenuWidth	=	3
MinMenuLen	=	2 + 10
MaxMenuLen	=	2 + 12

;===================================================
;		include  files
;===================================================

	.XLIST
        INCLUDE         MACRODEF.INC
	.LIST
	
; use for debugging with Codeview
;	INCLUDE		MOUSEKEY.PUB

;===================================================
;		segment  definitions
;===================================================

	.XLIST
	INCLUDE		BIOS.SEG
	.LIST

;
; new subtitle
;
			SUBTTL	program text is easy to analyze
			PAGE

;=======================================================
; 		 program code segment
;=======================================================

CODE	SEGMENT	PARA 	PUBLIC	'CODE'
	ASSUME	CS:CODE, DS:CODE, ES:CODE, SS:STACK

; include the DOS predefined labels

		mac@DosPSP

; reset for EXE-style

		ORG	0

; variables

        VectorArrayPtr		LABEL	DWORD
	 mac@VecEntry	HookedVecs,<TimerHdwrInt,MultiplexInt>

; align on word boundary

			mac@AlignWord

;            System Flags Bits Description
; ---------------------------------------------------------------------------
	TimeIntInUse		= 0000000000000001b   ; Timer Int in progress
	WaitRelease		= 0000000000000010b   ; both buttons must be released
        EnableProgram           = 0000000000000100b   ; enable events
	PullMenu		= 0000000000001000b   ; cursor on screen
	MouseCenterPosX		= 0000000000010000b   ; use to set X pos
	MouseCenterPosY		= 0000000000100000b   ; use to set Y pos
	MenuInUse		= 0000000001000000b   ; menu already on screen

; additional bit masks
	ResetBitMask		= 0000000000000100b   ;these bits may be set
	FullMask		= 1111111111111111b

	SystemFlags	DW	EnableProgram
	InitValue	DW	?
	Counter		DW	?
	PSPSeg		DW	?
	CurPosX		DW	?
	CurPosY		DW	?
	LastPosX	DW	?
	LastPosY	DW	?
	HorizMove	DW	0
	VertMove	DW	0
	CenterX		DW	?
	CenterY		DW	?

; some internals

	LeftButtonKey	DW	CR_Key
	RightButtonKey  DW	ESC_Key
	VideoSegment	DW	?
	RowLength	DW	?
	LeftCorner	DW	?
	X1		EQU	<Bptr LeftCorner>
	Y1		EQU	<Bptr LeftCorner+1>
	RightCorner	DW	?
	X2		EQU	<Bptr RightCorner>
	Y2		EQU	<Bptr RightCorner+1>
	MenuLength	DB	?
	InternalFlag	DB	1
	CheckSnow	DB	false
	CopyToVideoMem	DB	false
	DirectVideo	DB	true
	EnhancedFlag	DB	false
	MenuWidth	DB	?
	LeftCounter	DB	0
	RightCounter	DB	0
	TextAttr	DB	?
	HiLightAttr	DB	?

; function keys table

	FunctionTable	DB	3Bh,3Ch,3Dh,3Eh,3Fh,40h,41h,42h,43h,44h  ; F1-F10
			DB	57h,59h

; menu image

	MemoryImage	DB	'É',0,'Í',0,'Í',0,'Í',0,'»',0
	ImageRowLen	=	$  - MemoryImage
			DB	'º',0,'F',0,'1',0,' ',0,'º',0
			DB	'º',0,'F',0,'2',0,' ',0,'º',0
			DB	'º',0,'F',0,'3',0,' ',0,'º',0
			DB	'º',0,'F',0,'4',0,' ',0,'º',0
			DB	'º',0,'F',0,'5',0,' ',0,'º',0
			DB	'º',0,'F',0,'6',0,' ',0,'º',0
			DB	'º',0,'F',0,'7',0,' ',0,'º',0
			DB	'º',0,'F',0,'8',0,' ',0,'º',0
			DB	'º',0,'F',0,'9',0,' ',0,'º',0
			DB	'º',0,'F',0,'1',0,'0',0,'º',0
	ExtMem		LABEL	BYTE
			DB	'º',0,'F',0,'1',0,'1',0,'º',0
			DB	'º',0,'F',0,'1',0,'2',0,'º',0
	LastImage	LABEL	BYTE
			DB	'È',0,'Í',0,'Í',0,'Í',0,'¼',0
	End_Image_Len	=	$ - LastImage

; saved window

	SaveImage	DB  MaxMenuLen DUP ('SPACExxxxx')

; align on word boundary

		mac@AlignWord

;====================================================
;  		internal subroutines
;====================================================

; 
; initialize the attribute of menu
; Enter:   ES:DI -> ptr to row
;	   CX = number of rows
; Destroy: AX,CX,DI
;
	InitAttrForMenu		PROC	NEAR
		cld					; go forward
		mov	al,TextAttr
	Init_Attr_Row:
		mac@Save	   <cx>			; save a count
		mac@LoadZero	ch			; CH = 0
		mov	cl,MenuWidth

; internal loop

	Internal_Loop:
		mac@IncVal	di			; skip a char
		stosb					; store a word
		loop	Internal_Loop

; external loop

		mac@Restore   <cx>			; recover a cnt
		loop	Init_Attr_Row
			ret
	InitAttrForMenu		ENDP

;
; restore the attribute for line
; Enter:  BH = row number on screen
;
	Restore_Line	PROC	NEAR
		mac@Save	 <bx,cx,dx,si,di>

		mov	MenuWidth,FuncMenuWidth

		mac@MoveToES	cs,ax			; ES = CS

		mac@LoadOfs	di,MemoryImage
		mov	al,bh				; AL = vrow
		sub	al,Y1				; AL = row number in matrix 
		mac@SetConst	  ah,ImageRowLen
		mul	ah				; AX = where to put
		mac@IncVal	ax,2			; skip the 2 bytes
		add	di,ax				; DI = offset
		mov	si,di
		mac@SetConst		cx,1			; only 1 row
		call	InitAttrForMenu
		mov	di,si				; restore DI
		mov	dl,X1				; DL = col (X1)
		inc	dl				; move 1 pos to right
		mov	dh,bh				; DH = row (Y1)
		mov	ch,bh				; X2 pos
		mov	cl,dl				; Y2 pos
		mac@IncVal   cl,FuncMenuWidth		; add 3
		mac@SetConst   CopyToVideoMem,true
		call	MoveWindow

; restore the defaults

		mov	MenuWidth,StdMenuWidth
		mac@Restore  <di,si,dx,cx,bx>
		ret
	Restore_Line	ENDP

;
; store the highlight attribute for line
; Enter:  BL = row number on screen
;
	HiLight_Line	PROC	NEAR
		mac@Save     <bx>
		mac@ExchangeByte   HiLightAttr,TextAttr,al
		mov	bh,bl			; BH = row
		call	Restore_Line
		mac@ExchangeByte   HiLightAttr,TextAttr,al
		mac@Restore  <bx>
		ret
	HiLight_Line	ENDP

;
; set the video internal variables
; Enter: none
; Exit:	 none
;
	Set_Video_Vars	PROC	NEAR
		mac@Save	<ax,bx,es>

		mac@MoveToES	<SEG ROM_DATA>,ax
		ASSUME   ES:ROM_DATA

; find the video segment for current mode

		mac@SetConst	ax,MonoCardSeg
		mac@SetConst	bl,MonoAttr
		mac@SetConst	bh,MonoInverse

		cmp	dbVideo_Mode,7			; mono mode?
		je	Segment_Done

		mac@SetConst	ax,ColorCardSeg		; else color mode
		mac@SetConst	bl,ColorAttr
		mac@SetConst	bh,ColorInverse

	Segment_Done:
		mov	VideoSegment,ax			;AX = video mem seg
		mov	TextAttr,bl
		mov	HiLightAttr,bh
		mov	ax,dwVideo_Columns		;AX = # of cols
		mac@ShiftLeft 	ax			;multiply by 2
		mov	RowLength,ax			;save it

; find the left-X, right-X

		mac@ShiftRight   al			;divide by 2
		sub	al,MenuWidth			;screen - menu
		mac@ShiftRight   al			;divide by 2
		mov	X1,al
		add	al,MenuWidth
		mov	X2,al

; find the right-Y, left-Y

		mac@SetConst     al,ScreenRows		;assume that 25 lines

		cmp	dbVideo_Rows,0			;on screen
		je	Rows_Done

		mov	al,dbVideo_Rows			;may be 43/50 lines
		mac@IncVal	al

	Rows_Done:
		mov	ah,MenuLength
		sub	al,ah				;screen - menu
		mac@ShiftRight	al			;AL div 2
		mov	Y1,al
		add	al,ah
		mov	Y2,al

; exit from subroutine

		mac@Restore	<es,bx,ax>
		ASSUME  ES:CODE
		ret
	Set_Video_Vars	ENDP

;
;
; At entry:  DH = row, DL = col
; At exit:   AX = offset on the video page
; 	     DX = CRTC base address
;
   	CalcOffset      PROC        NEAR
		mac@Save	<ds>

		mac@MoveToDS	<SEG ROM_DATA>,ax
		ASSUME   DS:ROM_DATA

		mac@LoadZero	ah			; AH = 0
		mov	al,dh				; AL = row
		mul	Bptr dwVideo_Columns		; AX = rows * width
		mac@LoadZero   dh			; DL = col, DH = 0
		add	ax,dx				; AX = row * width + col
		mac@ShiftLeft	ax			; AX = AX * 2
		add	ax,dwBuffer_Start		; add offset of video memory
		mov	dx,dwCRTC_Base			; DX = CRTC base address

		mac@Restore	<ds>
		ASSUME  DS:CODE
                  ret
	CalcOffset           ENDP

;
; copy from/to the video memory
; Enter:   access to global variable CopyToVideoMem
;	   ES:DI -> pointer to source/destination memory buffer
;	   CH, CL = right corner of window
;  	   DH, DL = left corner of window
;
	   MoveWindow           PROC         NEAR
		mac@Save	<bp,ds>

		cmp	DirectVideo,true
		je	@F

		jmp	@SaveBiosWindow

	@@:
                sub      cx,dx			;CH = # of rows, CL = # of cols
                mov      bx,cx			;save it
                xchg         ch,cl		;CL = # of rows,CH = # of cols
                mac@LoadZero      ch              	;CX = # of rows

		mac@ZeroValue?	cx			;CX == 0?
		jnz	Check_One_Row		;if not, then jump

		mac@SetConst	   cl,1			;CX = 1 row

	Check_One_Row:

                mac@LoadZero      bh              	;BX = # of cols


		
                call         CalcOffset       	;AX = video offset
                add          dx,6             	;DX = video status reg

                cmp          CheckSnow,true	;old CGA card?
                je           NoCheckSnow

                mac@LoadZero     dx               	;DX = 0

	NoCheckSnow:
                mov          bp,RowLength 	;BP = length of one row
                mov          si,ax            	;SI = video offset

		cmp	cs:CopyToVideoMem,false	;see to/from video memory?
		jne	MoveToVideoMemory

                mov          ds,VideoSegment  	;DS = video buffer start
		mac@sJump    Init_Done

	MoveToVideoMemory:
		xchg	     si,di	      ;DI = offset of buffer
                mov          ax,es            ;save ES
                mov          es,VideoSegment  ;DS = video buffer start
                mov          ds,ax            ;move old ES into DS	

	Init_Done:
                cld                           	;go forward

   	CopyOneRow:
                mac@Save         <cx>             ;save row counter

		cmp	cs:CopyToVideoMem,false	;see to/from video memory?
		jne	MoveVideo3

                mac@Save         <si>             ;save video offset
		mac@sJump	MoveVideo4

	MoveVideo3:
                mac@Save         <di>             ;save video offset

	MoveVideo4:
                mov          cx,bx            	;CX = # of cols

                mac@ZeroValue?       dx	       ;check for snow?
                jz           DirectRead

		mov	     ah,9		;vert. + horiz. retraces

   Read1:
                mac@InByte     		        ; get status

                test         al,8		; in vertical retrace
                jnz          Read3

                shr          al,1		; check for horizontal retrace?
                jc           Read1

                cli

   Read2:
                mac@InByte                        ; get the video status

                and          al,ah
                jz           Read2

   Read3:
                movsw				; copy a word
                sti				; enable intrs
                loop         Read1

                mac@sJump    ReadDone

   DirectRead:
                rep          movsw              ;just copy

   ReadDone:
		cmp	cs:CopyToVideoMem,false	;see to/from video memory?
		jne	MoveVideo1

                mac@Restore     <si>            ;restore offset
                add          si,bp              ;SI = offset of new row

		mac@sJump	MoveVideo2

	MoveVideo1:
                mac@Restore     <di>              ;restore offset
                add          di,bp              ;DI = offset of new row

	MoveVideo2:
               mac@Restore     <cx>		;restore a row cnt
                loop         CopyOneRow

                mac@Restore   <ds,bp>             ;restore a world
                 ret

   @SaveBiosWindow:
		mov	bp,dx			; save X1 in DL
		mac@Save	<cx,dx>			;save coordinates of window
		
		mov	    ah,0Fh		; get current video page
		int	    10h

                mov	    ah,3                ;get cursor pos.
		int	    10h			;DX = pos, CX = mode

		mov	    ax,dx		; save current cursor pos.
		mac@Restore	<dx,cx>

;               inc     cl              	;increment for next computations
;               inc     ch			; CL = X2+1, CH=Y2+1

		mac@Save  <ax>			; push pos. onto stack

		cld				; go forward

		cmp	cs:CopyToVideoMem,false	;see to/from video memory?
		je	@RWNextChar

		mac@MoveToDS	es,ax		; move ES to DS
		mov	si,di			; DS:SI -> src buf

   @RWNextChar:
                   mov          ah,2            ;AH = set cursor pos.
                   int          10h	           ;call video BIOS

		cmp	cs:CopyToVideoMem,false	;see to/from video memory?
		je	@BiosRead

		mac@Save		<cx>		;save (X2+1,Y2+1)
		   lodsw			;get char/attr
                   mov          bl,ah           ;load attribute
                   mov          cx,1            ;write 1 char
                   mov          ah,9            ;AH = write a char
                   int          10h	        ;call video BIOS

		mac@Restore	<cx>		;restore (X2+1,Y2+1)
		jmp	short	@BiosCallDone		

	@BiosRead:
                   mov          ah,8            ;AH = read a char
                   int          10h	        ;call video BIOS

	@BiosCallDone:

		cmp	cs:CopyToVideoMem,true	;see to/from video memory?
		je	@SkipPut

                   stosw                        ;save char/attr

	@SkipPut:
                   inc          dl              ;inc X-pos

                   cmp          dl,cl           ;X > XHigh ?
                   jb          @RWNextChar      ;no, then continue

		   mov		ah,dh		;save Y-pos
                   mov          dx,bp		;restore DL, where = (X1)
		   mov		dh,ah		;restore current Y-pos
                   inc          dh              ;inc Y-pos

                   cmp          dh,ch           ;Y > YHigh ?
                   jb           @RWNextChar     ;no, then continue

                   mac@Restore     <dx>           ;restore the old cursor pos

                   mov          ah,2            ;AH = set cursor pos.
                   int          10h	        ;call video BIOS

                mac@Restore   <ds,bp>             ;restore a world
		   ret
	  MoveWindow           ENDP

;
;  Function menu display
;
	MenuPopUp	PROC	NEAR

; save a world

		mac@Save	  <ax,bx,cx,dx,si,di,bp,es>

; initialize the variables

		call	Set_Video_Vars

; init the video attribute

		mac@MoveToES	cs,ax

		mac@LoadOfs	di,MemoryImage
		mac@SetConst	cx,MaxMenuLen
		mov	MenuWidth,StdMenuWidth
		call	InitAttrForMenu

; save the window

		mov	dx,LeftCorner
		mov	cx,RightCorner
		mac@LoadOfs    di,SaveImage
		mac@SetConst   CopyToVideoMem,false
		call	MoveWindow

; move the menu window to screen

		mac@MoveToES	cs,ax
		mov	dx,LeftCorner
		mov	cx,RightCorner
		mac@LoadOfs    di,MemoryImage
		mac@SetConst   CopyToVideoMem,true
		call	MoveWindow

; at first remove all entries from the  queue

		call	Flush_Kbd_Buffer

; control loop to select the function key

		mov	bl,Y1			; BL = row counter
		inc	bl			; skip 1st line
		mov	cl,bl
		mov	ch,cl			; CL = min line (L-bound)
		add	ch,MenuLength	        ; CH = max line (U-bound)
		sub	ch,3
		call	HiLight_Line

	Control_Kbd:
		mac@ReadKbd
		cmp	ax,ESC_Key
		je	Menu_Exit

		cmp	ax,Up_Arrow		; move up?
		jne	Next_Key_1
		mov	bh,bl			; save the crrent pos.
		mac@DecVal	bl		; decr a counter
		cmp	bl,cl
		jae	Up_Ok
		mov	bl,ch			; set to last pos

	Up_Ok:
		call	Restore_Line
		call	HiLight_Line
		mac@sJump	Control_Kbd

	Next_Key_1:
		cmp	ax,Down_Arrow		; move down?
		jne	Next_Key_2
		mov	bh,bl			; save the crrent pos.
		mac@IncVal	bl		; incr a counter
		cmp	bl,ch
		jbe	Down_Ok
		mov	bl,cl			; set to first pos

	Down_Ok:
		mac@sJump	Up_Ok

	Next_Key_2:
		cmp	ax,CR_Key		; key selected?
		jne	Control_Kbd		; no, then go back

; put the function key to buffer

		sub	bl,Y1			; adjust to get the pos	
		dec	bl			; also  minus 1
		mac@LoadZero  bh		; BH = 0
		mov	ah,FunctionTable[bx]	; Scan code from table
		mac@LoadZero   al		; ASCII code = 0
		call	Put_Key

; restore a saved window

	Menu_Exit:
		mac@MoveToES	cs,ax
		mov	dx,LeftCorner
		mov	cx,RightCorner
		mac@LoadOfs    di,SaveImage
		mac@SetConst   CopyToVideoMem,true
		call	MoveWindow

; restore a world

		mac@Restore  <es,bp,di,si,dx,cx,bx,ax>
		ret
	MenuPopUp	ENDP

;
; flush the ROM keyboard buffer
;
	Flush_Kbd_Buffer	PROC	NEAR
		mac@Save		<ax,ds>

		mac@MoveToDS	<SEG ROM_DATA>,ax
		ASSUME   DS:ROM_DATA

		mov	ax,dwKbd_Head			; effective flushing
		mov	dwKbd_Tail,ax			; of queue

		mac@Restore	<ds,ax>
		ASSUME  DS:CODE
		ret
	Flush_Kbd_Buffer	ENDP

;
; Enter:   AH = scan code
;          AL = ASCII code
        Put_Key         PROC    NEAR
                mac@Save    <ds,bx,si>

                mac@MoveToDS     <SEG ROM_DATA>,bx ;DS = rom bios vars
                 ASSUME    ds:ROM_DATA

		mov       bx,dwKbd_Tail		;ptr to 1st free element

; try to put the following element

                mov       si,bx
		add	  bx,2

; check for wraparound

		cmp	  bx,dwKbd_End            ;at end of buffer?
		jne	  Fall_Check

		mov	  bx,dwKbd_Start	;set ptr to beginning

; enough room in buffer?

	Fall_Check:
		cmp	  bx,dwKbd_Head		
		je	  Key_Done

; write a new keystroke

		cli				;disable intrs
		mov	[si],ax			;into the BIOS kbd buffer
		mov	dwKbd_Tail,bx		;kbd tail ptr
		sti				;re-enable intrerrupts

; exit from this routine

	Key_Done:
                mac@Restore  <si,bx,ds>		;restore a world
                ret
        Put_Key         ENDP

; 
; Enter:   AH = Scan code
;          AL = ASCII code
;  !!! Very important !!!
;	   CX = (number of keystrokes) * 8
;
        Fill_Buffer     PROC    NEAR
		mac@ShiftRight   cx,3		;divide by 8
		jcxz	Fill_Done		;exit if done

	Put_One:
		call	Put_Key			;write one keystroke
		loop	Put_One			;repeat till done

	Fill_Done:
                ret				;here return
        Fill_Buffer     ENDP

;
; align the coordinte on char boundary (8 pixels)
; Enter:   AX = position
; Exit:    AX = ((pos.) div 8) * 8
;
	Coordinate8	PROC	NEAR
		mac@ShiftRight   ax,3		;divide by 8
		mac@ShiftLeft    ax,3		;multiply by 8
		ret
	Coordinate8	ENDP

;
; THIS routine services the HARDWARE events!
; -----------------------------------------------------------
; call mask bits definition
	PositionChanged		=	00000000000000001b
	LeftButtonPressed	=	00000000000000010b
	LeftButtonReleased	=	00000000000000100b
	RightButtonPressed	=	00000000000001000b
	RightButtonReleased	=	00000000000010000b

; button status bits
	LeftButtonDown		=	00000000000000001b
	RightButtonDown		=	00000000000000010b
	NewCallMask = (PositionChanged+LeftButtonPressed+RightButtonPressed+LeftButtonReleased+RightButtonReleased)
;
; Enter:  	AX = call mask
;		BX = button status
;	  	CX = X coordinate for virtual screen
;	  	DX = Y coordinate for virtual screen
;	  	SI = horizontal counter
;	  	DI = vertical counter
;
	HardwareService	PROC	FAR
		sti
                mac@Save     <ax,cx,ds>		;save registers

		mac@MoveToDS	cs,ax		;init DS
            	 ASSUME	  DS:CODE

; if our handler enabled

		mac@TestBit  SystemFlags,EnableProgram
		jz	ImmediatelyExit
		
; we are in process to handle the mouse active event

		mac@ResetBit   bx,<LeftButtonDown + RightButtonDown>

; wait till both buttons will be released
		
		mac@TestBit  SystemFlags,WaitRelease
		jz	Save_Cur_Pos

		mac@ZeroValue?	  bx
		jnz	Released_Both

		mac@ResetBit   SystemFlags,<FullMask - WaitRelease>
		mac@sJump	  Save_Cur_Pos
		
	Released_Both:
		mac@LoadZero	bx

; save the current mouse cursor position

	Save_Cur_Pos:
		mov	CurPosX,cx
		mov	CurPosY,dx

; test for both buttons pressed

		cmp	bx,(LeftButtonDown + RightButtonDown)
		jne	Not_BothPressed

; process if both buttons were pressed

	BothPressed:
		mac@SetBit  SystemFlags,PullMenu
		mac@SetBit  SystemFlags,WaitRelease
		mac@sJump	  Horiz_Mouse_Moved?

; exit if done

	ImmediatelyExit:	
		jmp	  ServiceDone		
		
; test for left button

	Not_BothPressed:
		mac@TestBit  bx,LeftButtonDown	;left button pressed?
		jz	TestLeftCounter

		inc	LeftCounter		;then add 1
		mac@sJump	TestRightButton

; left counter test
		
	TestLeftCounter:
		mov	al,LeftCounter		;get left button cnt
		mac@ZeroValue?	al			;test for zero count
		jz	TestRightButton

; this reserved for future extensions
COMMENT  @
		cmp	al,1			;once pressed
		jne	Many_Left?
  @
; try to put <CR> into ROM kbd buffer

		mov     ax,LeftButtonKey		
		call	Put_Key			
COMMENT  !
		mac@sJump	Reset_Left
  !

	Many_Left?:
	Reset_Left:
		mac@SetConst   LeftCounter,0		;set to zero

; test for right button

	TestRightButton:
		mac@TestBit  bx,RightButtonDown	;right button pressed?
		jz	TestRightCounter
		inc	RightCounter		;then add 1
		mac@sJump	Horiz_Mouse_Moved?

; right counter test

	TestRightCounter:	
		mov	al,RightCounter		;get right button cnt
		mac@ZeroValue?	al		;test for zero count
		jz	Horiz_Mouse_Moved?

; this reserved for future extensions
COMMENT  @
		cmp	al,1			;once pressed
		jne	Many_Right?
  @

;try to put the <ESC> into ROM kbd buffer
 
		mov   ax,RightButtonKey
		call	Put_Key			

COMMENT  !
		mac@sJump	Reset_Right
  !

	Many_Right?:

	Reset_Right:
		mac@SetConst   RightCounter,0	;set to zero

; process the mouse horizontal movement

	Horiz_Mouse_Moved?:
		mov	cx,CurPosX		;find the difference
		mov	ax,cx			;save it
		call	Coordinate8		;align coordinate
		sub	cx,LastPosX		;current - last
		mov	LastPosX,ax		;save the current position
		mac@SetConst  ax,Right_Arrow	;assume that moved right
		jns	Moved_Right
		neg	cx			;2's complement
		mac@SetConst   ax,Left_Arrow	;was moved left
	Moved_Right:
		call	Fill_Buffer		;write all keys

; process the mouse vertical movement
	
	Vert_Mouse_Moved?:
		mov	cx,CurPosY		;find the difference
		mov	ax,cx			;save it
		call	Coordinate8		;align coordinate
		sub	cx,LastPosY		;current - last
		mov	LastPosY,ax		;set the new position

		mac@SetConst   ax,Down_Arrow	;assume that moved down
		jns	Moved_Down

		neg	cx			;2's complement
		mac@SetConst  ax,Up_Arrow		;was moved up

	Moved_Down:
		call	Fill_Buffer		;write all keys

; here test if mouse cursor at screen boundary

	TestBoundary:				;at first horizontal pos.
		mov	ax,LastPosX
		cmp	ax,CurPosX		;current = last?
		jne	TestVertPos
		mac@ZeroValue?	   ax		;left corner reached?
		jz	SetResetX

; cursor reached the most right horizontal position?
		
		mov	cx,CenterX
		mac@ShiftLeft   cx		;multilpy by 2
		mac@DecVal	cx,8		;last - 8

		cmp	ax,cx			;see if at most right pos.
		jb	TestVertPos

	SetResetX:
		mac@SetBit   SystemFlags,MouseCenterPosX  ;set reset bit
	
	TestVertPos:
		mov	ax,LastPosY
		cmp	ax,CurPosY		;current = last?
		jne	ServiceDone

		mac@ZeroValue?	   ax		;left corner reached?
		jz	SetResetY

; cursor reached the most right position?

		mov	cx,CenterY
		mac@ShiftLeft   cx		;multilpy by 2
		cmp	ax,cx			;see if at most right pos.
		jb	ServiceDone

	SetResetY:
		mac@SetBit   SystemFlags,MouseCenterPosY  ;set reset bit
	
; exit from routine

	ServiceDone:
                mac@Restore  <ds,cx,ax>		;restore registers
		ret
	HardwareService	ENDP

;
; get a ticks to wait
;	Enter:	AX = ticks
;	Exit:	AX = how many calls
;
	Get_Ticks_Calls		PROC	NEAR
		mac@Save	<bx>
		mac@SetConst  bl,TimerTicks		;BL = 18.2 ticks/second
		xchg	al,bl			;AL = 18.2, BL = calls
		div	bl			;AL = new counter
		mac@Restore  <bx>
		ret
	Get_Ticks_Calls		ENDP

; initialize the time counter
;
	InitVars	PROC	NEAR
		mov	ax,cs:InitValue		;new counter value
		mov	cs:Counter,ax
	        ret
	InitVars	ENDP

;
; set the current mouse position
; Enter:  CX = horizontal position
;	  DX = vertical position
; Exit:   nothing
;
	Set_Mouse_Position	PROC	NEAR
		mac@MouseSetPosition
		ret
	Set_Mouse_Position	ENDP

;
; get the current mouse position
; Enter:  nothing
; Exit:   BX = button status
;	  CX = horizontal position
;	  DX = vertical position
;
	Get_Mouse_Status	PROC	NEAR
		mac@MouseGetStatus
		ret
	Get_Mouse_Status	ENDP

;
; timer interrupt service
;
	NewInt08	PROC	FAR
		mac@OldIntCall    off,cs:VectorArrayPtr[3+5*0]  ;call old routine

		mac@Save	<ax,bx,cx,dx,ds>	;save registers

		mac@MoveToDS	cs,ax		;init DS
            	 ASSUME	  DS:CODE

;check the our activity

		mac@TestBit  SystemFlags,<TimeIntInUse>
		jnz	IntDone

		dec	Counter			;counter is decremented
		jz	EnterInt		;zero reached?

; recover registers

	IntDone:
		mac@Restore	  <ds,dx,cx,bx,ax>	;all done
		iret

; enter to main part of service routine

	EnterInt:
		sti				;re-enable interrupts
		mac@SetBit  SystemFlags,TimeIntInUse
		call	InitVars		;reset to defaults

; enable events?

		mac@TestBit  SystemFlags,EnableProgram
		jnz	StartService
		mac@sJump	NowResetBit   

; service routine starts
	
	StartService:

; try to pull menu

		mac@TestBit	SystemFlags,PullMenu
		jz	ResetPosBits

; check for menu on screen

		mac@TestBit  SystemFlags,MenuInUse
		jnz	ResetPosBits

; pull menu for keyboard emulatution

		mac@SetBit  SystemFlags,MenuInUse

; reset the pull menu bit

		mac@ResetBit  SystemFlags,<FullMask - PullMenu>

; pop-up menu to screen

		call	MenuPopUp

; reset the indicated bit

		mac@ResetBit  SystemFlags,<FullMask - MenuInUse>

; check to set resetting bits mouse pos.
	
	ResetPosBits:
		mac@TestBit   SystemFlags,MouseCenterPosX
		jz	NextBit
		call	Get_Mouse_Status	;get the current status
		mov	cx,CenterX		;reset the X-pos for mouse
		mov	LastPosX,cx
		mov	CurPosX,cx
		call	Set_Mouse_Position
		mac@ResetBit  SystemFlags,<FullMask - MouseCenterPosX>

	NextBit:
		mac@TestBit   SystemFlags,MouseCenterPosY
		jz	NowResetBit
		call	Get_Mouse_Status	;get the current status
		mov	dx,CenterY		;reset the Y-pos for mouse
		mov	LastPosY,dx
		mov	CurPosY,dx
		call	Set_Mouse_Position
		mac@ResetBit  SystemFlags,<FullMask - MouseCenterPosY>

; service routine ends

	NowResetBit:
		mac@ResetBit   SystemFlags,<FullMask - TimeIntInUse>
		jmp	IntDone
	NewInt08	ENDP

;
; multiplex process handler
;
	NewInt2F	PROC	FAR
		cmp	ah,MouseKeyID		;our ID?
		je	MayBeWe

; jump to previous handler

	OldCall:
		mac@OldJump   cs:VectorArrayPtr[3+5*1]

;subfunction 0 call ?

	MayBeWe:
		mac@ZeroValue?   al		;install?
		jnz	Func_1
		mac@SetConst  al,Already_Installed	;put back the program ID
		mac@SetConst  bx,ExtID		;additional check
		mac@sJump	Just_Return

	Int_2F_Ret:
		mac@LoadZero   al		;AL = good return
	
	Just_Return:
                clc                             ;no errors
	Far_Return:
		ret	2

;subfunction 1 call ?

	Func_1:
		cmp	al,GetProgInfo		
		jne	Func_2
		mac@LoadZero   al		;AL = good return
		mov	bx,cs:PSPseg		;BX = program PSP
                push    cs                      ;ES:DI -> array
                pop     es
		mac@LoadOfs    di,VectorArrayPtr
		mac@sJump	Int_2F_Ret

; subfunction 2 call ?

	Func_2:                                 
		cmp	al,GetSetSystemFlags
		jne	Func_3
		cmp	bl,GetFlags		;get flags?
		jne	Try_Set_Flags		;no,then skip
		mov	cx,cs:SystemFlags	;CX = program flags
		mac@sJump	Int_2F_Ret

	Try_Set_Flags:
		cmp	bl,SetFlags		;set flags?
		jne	Bad_Function
		mov	cs:SystemFlags,cx	;put the new program flags
		mac@sJump	Int_2F_Ret

	Bad_Function:
		mac@SetConst  al,BadReturn		;indicate that fails
		stc				;set error flag
		mac@sJump	Far_Return		;far return

;subfunction 3 call ?

	Func_3:                         
		cmp	al,3
		jne	Func_4
		mac@ZeroValue?	    bx		;BX = new horizontal sensitivity
		jz	FirstParameter		;if zero then done nothing
		mov	cs:HorizMove,bx
	FirstParameter:
		mac@ZeroValue?	    cx		;BX = new vertical sensitivity
		jz	SecondParameter		;if zero then done nothing
		mov	cs:VertMove,cx
	SecondParameter:
		mac@sJump	Int_2F_Ret

; subfunction 4 call ?

	Func_4:				
		cmp	al,4			;filter other subfunctions!
		jne	Bad_Function
		mac@ZeroValue?     bl		;get a value?
		jnz	Set_New_Value
		mov	ax,cs:InitValue		;AX = # of wait ticks
		call	Get_Ticks_Calls		;AX = calls per second
		mac@sJump  Int_2F_Ret

	Set_New_Value:
		cmp	bl,1			;set a value!
		jne	Bad_Function
		mac@ZeroValue?	   cx		;check that no zero
		jz	Int_2F_Ret
		mov	ax,cx			;AX = calls per second
		call	Get_Ticks_Calls		;AX = # of wait ticks
		mov	cs:InitValue,ax		;set the new value
		mac@sJump	Int_2F_Ret
	NewInt2F	ENDP

;===========================================
;        	text for messages
;===========================================

	InitMessage   DB  'Resident Mouse-Keyboard Emulator ',Version,'.',CR,LF
                      DB  '(C) Copyright 1991 Dima Stefankov. All Rights reserved.',CR,LF
	MsgLen	      =   $ - InitMessage

        OnLineHelp    DB  'MOUSEKEY accepts the following command line syntax:',CR,LF
		      DB  '  MOUSEKEY [Options]',CR,LF
		      DB  '    Options may be preceded by either / or -.',CR,LF
		      DB  '    Valid Options are as follows:',CR,LF
                      DB  '    /?,?       write this help screen,',CR,LF
		      DB  '    /u         remove the program from memory,',CR,LF
		      DB  '    /h:dd      horizontal sensitivity (range 1..99, default = 8)',CR,LF
                      DB  '    /v:dd      vertical sensitivity (range 1..99, default = 16),',CR,LF
                      DB  '    /e         enable  program',CR,LF
		      DB  '    /d         disable program',CR,LF
		      DB  '    /t:dd      how many times called per second (range 1..18, default = 6)',CR,LF
		      DB  '    /k         switch to the alternate keyboard',CR,LF
		      DB  '    /s         check snow with write to screen',CR,LF
		      DB  '    /b	  write to screen with BIOS',CR,LF
		      DB  '    /x         exchange the purpose of buttons (def: left=CR,right=ESC)',CR,LF
		      DB  '  Where: d is the decimal digit, the letters are not case-sensitive,',CR,LF
		      DB  '         the default sensitivity.',CR,LF
		      DB  '    Example:  MOUSEKEY   -H:50 /v:67 /t:9',CR,LF
                      DB  '$'

	Invalid       	    DB  'Mouse driver not found...',CR,LF,'$'
	Removed       	    DB  'Successfully removed from memory...',CR,LF,'$'
	ErrorMessage        DB  'Invalid switches found...',CR,LF,'$'
	NotUnInstall        DB  'Unable to removed from memory...',CR,LF,'$'
	Passed	            DB  'Passed to existing program...',CR,LF,'$'
	Resident      	    DB  'Already present in memory...',CR,LF,'$'
        GoResident          DB  'Stay resident to memory...',CR,LF,'$'
	NoPassed            DB  'No passed to existing program...',CR,LF,'$'
	SetOurMaskMessage   DB  'The mouse event handler installed...',CR,LF,'$'
	NewMouseSensitivity DB	'The mouse sensitivity adjusted...',CR,LF,'$'
	NewTicks	    DB	'The new ticks calls installed...',CR,LF,'$'
	EnableEvents	    DB  'The program enabled now...',CR,LF,'$'
	DisableEvents	    DB	'The program disabled now...',CR,LF,'$'

;==================================================
; 		initialization code
;==================================================

;init data seg reg

	Start:
		mac@MoveToDS	cs,ax
		ASSUME	DS:CODE

		mov	PSPSeg,es		;ES = our PSP

;display init message

		mac@WriteHandle  STD_OUTPUT,MsgLen,<OFFSET InitMessage>
		mac@sJump	Init2

		mac@LoadOfs   dx,Invalid		;exit to DOS with error
	GoToDos:
		mac@DispStr
		mac@Terminate    01h		;set ERRORLEVEL = 1

	Init2:
		mac@Repeat    nop,3		;I got pleasure!!!

; try to detect the keyboard type

		mac@Save		<es>

		mac@MoveToES	<SEG ROM_DATA>,ax
		ASSUME	es:ROM_DATA

		mac@TestBit     dbKeyboard_Flags,EnhancedKbd
		jz	No_Enhanced_Kbd

		mov	EnhancedFlag,true

	No_Enhanced_Kbd:
		mac@Restore	<es>
		ASSUME	es:CODE

; scan the command parameters line

		mac@SetConst    di,<offset @psp_cmd_line_size>

	NextChar:
		mac@IncVal	di		;advance a pointer

		call	GetChar
		jne	LookChar
		jmp	ScanDone

; check for help request

	LookChar:
                cmp     al,'?'                  
                jne     LookAhead
                jmp     HelpSwitch

; switch prefix?

        LookAhead:
		cmp	al,'/'			
		je	SwitchFound
		cmp	al,'-'
		je	SwitchFound
		mac@sJump	NextChar

	SwitchFound:
		mac@IncVal	di		;bump a index pointer
		call	GetChar
		jne	LookSwitch
		jmp	ScanDone

; *remove* command switch

	LookSwitch:
                mac@UpperCase   al
		cmp	al,'U'			
		je       TryUninstall
                mac@sJump     Next1

;check for resident part

        TryUninstall:
		call	GetInfo			
		jc	TestResident
		jmp	ErrorSwitch

	TestResident:
                mac@Multiplex   MouseKeyID,GetProgInfo
		push    bx			;save the resident part seg
		mov	dx,bx
		add	dx,16			;Resident Seg = PSP + 10h

		mac@GetIntVec TimerHdwrInt	;our handler for INT $08

		mov	ax,es

		cmp	ax,dx			;match seg?
		jne	NoRemoved
		cmp	bx,OFFSET NewInt08	;match offset?
		jne	NoRemoved

		mac@GetIntVec   MultiplexInt		;our handler for INT $2F
		mov	ax,es
		cmp	ax,dx			;match seg?
		jne	NoRemoved
		cmp	bx,OFFSET NewInt2F	;match ofs?
		jne	NoRemoved

		push	ds			;save the DS
		mac@Multiplex  MouseKeyID,GetProgInfo

                mov     cx,es:[di]              ;CX = # of hooked vectors
                mac@IncVal    di,2              ;skip this word

        AllRestore:
		mac@SetPtr   ds,dx,es:[di+1]	;get a pointer to routine
                mov     al,es:[di]              ;vector number
                mac@SetIntVec
                mac@IncVal   di,5               ;skip 5 bytes
                loop     AllRestore

; set all mouse events disable

		mac@LoadZero	ax
		mov	es,ax
		mov	dx,ax			;ES:DX -> 0:0
		mac@MouseSetEventHandler   0	;call mask = 0
		mac@Restore	  <ds,es>	;recover data seg & our old PSP

		mac@FreeBlock                     ;free program seg
                jnc     Remove2
		mac@sJump	NoRemoved

        Remove2:
		mac@LoadOfs   dx,Removed
	LeaveProgram:
		mac@DispStr
	LeaveNoDisplay:
		mac@Terminate 00h			;set ERRORLEVEL = 0

	NoRemoved:
		mac@LoadOfs    dx,NotUnInstall
		jmp	GoToDos

; *horiz. sensitivity* parameter?

	Next1:
		cmp	al,'H'
		jne	Next2                   

	SecSwitch:
		mac@IncVal	di		;DI = index pointer
		call	GetChar
		jne	ParseSec2
	ParseSec1:
		mac@sJump	ErrorSwitch
	ParseSec2:
		cmp	al,DeLim
		jne	ParseSec1

		call	GetNumber		;get a number
		call	Check_Res_Range		;test for response
		mov	HorizMove,ax		;put a new value
		jmp	Next10

; *vert.sensitivity* parameter?

	Next2:
		cmp	al,'V'			
		jne	Next3

		mac@IncVal	di		;DI = index pointer
		call	GetChar
		jne	ParseMin2
	ParseMin1:
		mac@sJump	ErrorSwitch
	ParseMin2:
                cmp	al,DeLim                ;check for delimiter
		jne	ParseMin1

		call	GetNumber		;get a value
		call	Check_Res_Range		;test for response
		mov	VertMove,ax		;put a new value
		jmp	Next10

; *display help to user* switch

	Next3:
		cmp     al,'?'			
                jne	Next4

        HelpSwitch:
		mac@LoadOfs    dx,OnLineHelp
		jmp	LeaveProgram

	ErrorSwitch:				;parse error occured
		mac@LoadOfs    dx,ErrorMessage
		jmp	GoToDos

;  *tick calls* switch?

	Next4:
		cmp	al,'T'			
                jne	Next5
		mac@IncVal	di		;DI = index pointer
		call	GetChar
		jne	ParseMin4
	ParseMin3:
		jmp	ErrorSwitch
	ParseMin4:
                cmp	al,DeLim                ;check for delimiter
		jne	ParseMin3

		call	GetNumber		;get a value
		cmp	al,1			;must be in range 1..18
		jb	ParseMin3
		cmp	ax,TimerTicks
		ja	ParseMin3
		call	Get_Ticks_Calls		;AX = # of calls per second
		mov	InitValue,ax		;AX = # of wait ticks
		mac@sJump	Next10

;  *enhanced keyboard* switch?

	Next5:
		cmp	al,'K'
		jne	@Next6

		xor    	EnhancedFlag,true	 ; other keyboard support
		mac@sJump	Next10

;  *enable* switch?

	@Next6:
		cmp	al,'E'			
                jne	@Next6A

		mac@SetBit	SystemFlags,EnableProgram
		mac@sJump	Next10

;  *BIOS write* switch?

	@Next6A:
		cmp	al,'B'			
                jne	Next7

		mov	DirectVideo,false
		mac@sJump	Next10

;  *disable* switch?

	Next7:
		cmp	al,'D'			
                jne	Next8

		mac@ResetBit	SystemFlags,<FullMask - EnableProgram>
		mov	Bptr EnableFlag,false	;set switch to false
		mac@sJump	Next10

;  *enhanced keyboard* switch?

	Next8:
		cmp	al,'S'
		jne	Next9

		mov	CheckSnow,true		;support for older CGAs
		mac@sJump	Next10

;  *swap the purpose of buttons* switch?

	Next9:
		cmp	al,'X'
		jne	ErrorSwitch

		mac@ExchangeWord   LeftButtonKey,RightButtonKey,ax
		mac@sJump	Next10

        Next10:
               jmp      NextChar

; parsing ends here

	ScanDone:

; check for resident part

	CheckResident:
		call	GetInfo                 ;resident part present?
		jc	FoundInMemory		;if CY then present in memory
		jmp	NotInMemory

; at first the mouse sensitivity parameters

	FoundInMemory:
		mac@DispStr    <OFFSET Resident>
                mac@Multiplex   MouseKeyID,GetProgInfo  ;ES = resident code segment
		call	SaveMouseInfo		;also mouse soft reset
		call	NewMouseMask
		mac@DispStr   <OFFSET SetOurMaskMessage>
		mov	Bptr PassedParms,true

	Quit1:
		mov	bx,HorizMove		;BX = New Horiz. Value
		mov	cx,VertMove		;CX = New Horiz. Value
		mov	ax,bx			;may be both are zero?
		mac@ZeroValue?    ax,cx
		jz	Quit2
		mac@Multiplex  MouseKeyID,3       ;subfunction 3
		call	SetMouseSensitivity
		mac@DispStr    <OFFSET NewMouseSensitivity>
		mov	Bptr PassedParms,true

	Quit2:
		mov	cx,InitValue		;last resident parameter
		mac@ZeroValue?	  cx		;no updated?
		jz	Quit3
		mov	bl,1			;set the new value
		mac@Multiplex  MouseKeyID,4	;subfunction 4
		mac@DispStr   <OFFSET NewTicks>
		mov	Bptr PassedParms,true

	Quit3:
		mac@LoadZero    bl		;get the current state of flags
		mac@Multiplex  MouseKeyID,GetSetSystemFlags
		mac@ResetBit   cx,ResetBitMask	;isolate the bits
		cmp	cx,SystemFlags		;no updated state?
		je	Quit4
		mac@SetBit     cx,SystemFlags	;CX = new values
		mov      bl,1			;set the new program flags
		mac@Multiplex  MouseKeyID,GetSetSystemFlags
		mac@LoadOfs    dx,EnableEvents
		cmp	Bptr  EnableFlag,true	;display the corresponse message
		je	Quit_Disp
		mac@LoadOfs    dx,DisableEvents
	Quit_Disp:
		mov	Bptr PassedParms,true
		mac@DispStr
	Quit4:
		mac@LoadOfs   dx,NoPassed
		cmp	Bptr PassedParms,false
		je	Quit5
		mac@LoadOfs   dx,Passed
	Quit5:
		mac@DispStr
		jmp	LeaveNoDisplay

; init the internal variables
;     and the interrupt structure

	NotInMemory:
                push    cs                      ;move CS
                pop     es                      ; to ES
                mac@LoadOfs     di,VectorArrayPtr
                mov     cx,es:[di]
                mac@IncVal     di,2

        AllSave:
                mov     al,es:[di]              ;vector number
                push    es
                mac@GetIntVec                     ;ES:BX -> handler addr
		mac@SavePtr   es,bx,cs:[di+1]
                pop     es
                mac@IncVal   di,5               ;skip 5 bytes
                loop     AllSave

; test for mouse present

		mac@GetIntVec	MouseSoftInt
		mov	ax,es			;AX = segment
		mac@ZeroValue?    ax,bx		;test for null pointer
		jnz	PassVectorTest

	MouseNotOk:
		mac@LoadOfs    dx,Invalid		;mouse not present!
		jmp	GotoDos

	PassVectorTest:
		mac@LoadZero   bx			;set to zero
		mac@MouseGeneralReset			;get the info
		mac@ZeroValue?	   bx			;BX = # of buttons
		jz	MouseNotOk

;set the new vec $08

		mac@SetIntVec    TimerHdwrInt,<OFFSET  NewInt08>

;set the new vec $2F

		mac@SetIntVec    MultiplexInt,<OFFSET  NewInt2F>

; init the internal variables
		
		mov	ax,InitValue

		mac@ZeroValue?    ax			;if zero then reset to defaults
		jnz	No_Set_Defaults

		mov	InitValue,MaxValue	;default = 3 wait ticks

	No_Set_Defaults:
		call	InitVars

; save the current position with mouse reset

		mac@MoveToES    cs,ax		;ES = code segment

		call	SaveMouseInfo
		call	SetMouseSensitivity
		
; set the new mouse event mask

		call	NewMouseMask

; find the menu length

		mov	al,MinMenuLen

		cmp	EnhancedFlag,false		; test for kbd type
		je	Kbd_Detect

		mov	al,MaxMenuLen

	Kbd_Detect:
		mov	MenuLength,al
		mov	MenuWidth,StdMenuWidth		; default = 5

		cmp	al,MinMenuLen			; F1 - F10 only?
		jne	MenuInitDone

		mov	si,offset LastImage		; copy the end of table
		mov	di,offset ExtMem		; don't support the enhanced
		mov	cx,End_Image_Len		; keyboard
		push	ds
		pop	es
		cld
		rep	movsb

	MenuInitDone:

; free environment

                mov     es,PSPSeg
		mac@FreeBlock   es:[@Environment]

; first resident go

                mac@DispStr  <OFFSET GoResident>

;Terminate and Stay Resident

		mac@TSR  <(OFFSET InitMessage  + PSP_SIZE)>,0  ;set the ERRORLEVEL = 0

;=============================================
; 	     working subroutines
;=============================================

	GetNumber      PROC   NEAR
		mac@IncVal    di
		call	GetDigit                ;test for getting digit
		jnc	AcceptDigit
		jmp	ErrorSwitch
	AcceptDigit:
		mov	bl,al			;save a 1st number
		mac@IncVal    di	
		call	GetDigit		;get the next number
		jnc	Multiply
		mac@IncVal    di
		mac@LoadZero    ah
		mov	al,bl			;AL = result
		ret
	Multiply:
		mov	bh,al			;BH = 2nd digit
		mac@SetConst  al,10
		mul	bl			;AX = 1st * 10
		add	al,bh			;AL = 1st * 10 + 2nd
		mac@LoadZero      ah		;AX = result
		ret
	GetNumber	ENDP

	GetChar		PROC	NEAR
                mov	al,es:[di]

		mac@ZeroValue?	  al			;test for zero
		jz	Reached_End

		cmp	al,CR			;end of string?

	Reached_End:
		ret
	GetChar		ENDP

	GetDigit	PROC	NEAR
		mov	al,es:[di]		;get a char

		cmp	al,'0'			;in range '0'..'9'?
		jb	NotDigit

		cmp	al,'9'
		ja	NotDigit

		sub	al,'0'
		clc				;CF = 0 no error
		ret

	NotDigit:
		stc				;CY = 1 error occurred
		ret
	GetDigit	ENDP

;
; test for match range for resolution switches
;	Enter:	AX = number
;	Exit:	AX = accepted number
;
	Check_Res_Range	   PROC	   NEAR
		cmp	al,MinDefaultSen	;see Microsoft Mouse Ref.
		jb	ErrorValue	

		cmp	al,MaxDefaultSen	;1..99 range accepted
		jbe	MatchValue

	ErrorValue:
		jmp	ErrorSwitch

	MatchValue:
		mac@LoadZero      ah			;AX = result
		ret
	Check_Res_Range	   ENDP

;
;  get the resident program information
; 
	GetInfo		PROC	NEAR
                mac@LoadZero    bx                 ;BX <- 0
                mac@Multiplex  MouseKeyID,Install ;subfunction 0

		mac@ZeroValue?     al                  ;if AL = 0 then OK to install
                jnz         Check_Further       ;if =! 0 then go

        No_Resident_Part:
                clc                             ;clear presence flag
		ret

        Check_Further:
                cmp      bx,ExtID               ;our sign?
                jne      No_Resident_Part

                stc                             ;set resident flag
                ret
	GetInfo		ENDP

;
; This routine sets new event handler
; Enter:  ES = code segment of handler
;
	NewMouseMask	PROC	NEAR
		mac@LoadOfs  dx,HardwareService    ;ES:DX -> ptr to our handler
		mac@MouseSetEventHandler   NewCallMask
		ret
	NewMouseMask	ENDP

;
; save the current mouse position
; Enter:  ES = data segment
	SaveMouseInfo	PROC	NEAR
		ASSUME  ES:CODE
		mac@MouseSoftReset		; set internal variables
						; for software
		call    Get_Mouse_Status	;read the mouse status
		mov	es:LastPosX,cx		;save the X-position
		mov	es:CenterX,cx
		mov	es:LastPosY,dx		;save the Y-position
		mov	es:CenterY,dx
		ret
	SaveMouseInfo	ENDP

;
; set the mouse mickey
; Enter: CX = horizontal mickey
;	 DX = vertical mickey
;
	SetMouseSensitivity	PROC	NEAR
		mov	cx,HorizMove

		mac@ZeroValue?	   cx			;if zero then set defaults
		jnz	Zero1?

		mov	cx,HorizDefMickey

	Zero1?:
		mov	dx,VertMove

		mac@ZeroValue?	   dx			;if zero then set defaults
		jnz	Zero2?

		mov	dx,VertDefMickey

	Zero2?:
		mac@MouseSetMotionPixelRatio
		ret		
	SetMouseSensitivity	ENDP

;==============================================
;	 temporary variables
;==============================================

	EnableFlag	DB	true
	PassedParms	DB	false
CODE	ENDS

;==================================================
;		stack segment defintion
;==================================================

STACK	SEGMENT	PARA STACK 'STACK'
	DB	32  DUP  ('STACKxxx')
STACK	ENDS

; end of program code here

IF1
	%OUT	Ending of pass 1
ENDIF

IF2
	%OUT	Ending of pass 2
ENDIF

	END	Start
