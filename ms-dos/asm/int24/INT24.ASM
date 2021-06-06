				PAGE	59,132
				TITLE	Sample Program for my book

 ; Name		INT24.ASM
 ; Purpose	Display detailed info about failed functions for the device driver
 ; Input	None
 ; Output	None
 ; Version	1.01
 ; Date		09/25/1989
 ; Programmer	Dima Stefankoff

		.8086					; MASM directive

 ; Usage:	assembly module		MASM INT24;			
 ;		link module		LINK INT24;
 ;		convert module		EXE2BIN INT24.EXE INT24.COM
 ;		delete unused file	DEL INT24.EXE

 ; equates (symbols)

	false	=	0				; boolean FALSE value
	true	=	0FFh				; boolean TRUE value

 ; chars equates

	LF	EQU	0Ah				; ASCII line feed
	CR	EQU	0Dh				; ASCII carriage return

 ; string equates

	WP	EQU	<WORD PTR>			; shorten ASM directive
	DP	EQU	<DWORD PTR>			; shoretn ASM directive

 ; default constants

	ExitCode	=	0			; ERRORLEVEL value
	NameLen		=	8			; length = 8 bytes
	PATCH_CODE_LEN	=	5			; length = 5 bytes

 ; DOS equates

	ErrHandler	EQU	24h			; DOS critical error handler
	DOS	EQU	21h				; DOS dispatcher interrupt
	DispStr	EQU	09h				; DOS function codes
	GetVec	EQU	35h
	TSR	EQU	31h
	OutChar EQU	2

 ; BIOS equates

	VIDEO_BIOS	EQU	10h			; IBM BIOS INTR
	VIDEO_ATTR	EQU	15			; white on black
	Wind_Beg_X	EQU	00h			; (0,0)
	Wind_Beg_Y	EQU	00h
	LEN_X		=	50			; 39 chars/row
	LEN_Y_1		=	10			; 10 rows in window
	LEN_Y_2		=	LEN_Y_1 - 3
	WIN_SIZE	=	LEN_X * LEN_Y_1
	KBD_BIOS	EQU	16h			; IBM BIOS INTR

 ; structures
	IntVec	STRUC
	    VecOfs	DW	?			; offset
	    VecSeg	DW	?			; segment
	IntVec	ENDS

 ;	main code segment

	CODE	SEGMENT		WORD	PUBLIC	'CODE'

		ASSUME	CS:CODE, DS:CODE, SS:CODE, ES:NOTHING
		ORG	100h				; make .COM file

		jmp	INIT				; go to initialization code


 ;	data area
	
	PATCH_CODE	DB	0EAh			; direct inter-segment jump
	CODE_OFS	DW	?			; code offset
	CODE_SEG	DW	?			; code segment

	OLD_INT_24_VEC	INTVEC	<>			; old interrupt vector
	OLD_CODE	DB 	PATCH_CODE_LEN  DUP (?)	; code to restore

	OLD_SS		DW	?			; old SS register
	OLD_SP		DW	?			; old SP register

	FAILED_DRIVE	LABEL	BYTE			
	ERROR_INFO	DW	?			; the info about error
	ERROR_CODE	DW	?

	DEVICE_ATTR	DW	?			; failed device info
	DEVICE_NAME	DB	NameLen	DUP (?),"$"
	DEV_HDR_OFS	DW	?
	DEV_HDR_SEG	DW	?

	DRIVE_FLAG	DB	true			; character/block device toggle

	VIDEO_PAGE	DB	?			; video info
	OLD_CUR_POS	DW	?
	
	WINDOW_SIZE_XY	LABEL	WORD			; window info
	WIN_SIZ_X	DB	LEN_X			; # of columns
	WIN_SIZ_Y	DB	?			; # of rows
	WIN_AREA	DW	WIN_SIZE  DUP (?)

 ;	table of hexadecmal digits

	HEX_TABLE	DB	"0123456789ABCDEF"

 ;	device driver error codes

	ERR_TABLE	DW	OFFSET  ERR_CODE_0
			DW	OFFSET	ERR_CODE_1
			DW	OFFSET	ERR_CODE_2
			DW	OFFSET	ERR_CODE_3
			DW	OFFSET	ERR_CODE_4
			DW	OFFSET	ERR_CODE_5
			DW	OFFSET	ERR_CODE_6
			DW	OFFSET	ERR_CODE_7
			DW	OFFSET	ERR_CODE_8
			DW	OFFSET	ERR_CODE_9
			DW	OFFSET	ERR_CODE_10
			DW	OFFSET	ERR_CODE_11
			DW	OFFSET	ERR_CODE_12
			DW	OFFSET	ERR_CODE_13
			DW	OFFSET	ERR_CODE_14
			DW	OFFSET	ERR_CODE_15
	
	ERR_CODE_0	DB	"write-protected$"
	ERR_CODE_1	DB	"unknown unit$"
	ERR_CODE_2	DB	"device not ready$"
	ERR_CODE_3	DB	"unknown command$"
	ERR_CODE_4	DB	"CRC error$"
	ERR_CODE_5	DB	"bad request structure length$"
	ERR_CODE_6	DB	"seek error$"
	ERR_CODE_7	DB	"unknown media$"
	ERR_CODE_8	DB	"sector not found$"
	ERR_CODE_9	DB	"printer out of paper$"
	ERR_CODE_10	DB	"write fault$"
	ERR_CODE_11	DB	"read fault$"
	ERR_CODE_12	DB	"general failure$"
	ERR_CODE_13	DB	"reserved$"
	ERR_CODE_14	DB	"reserved$"
	ERR_CODE_15	DB	"invalid disk change$"

	OP_READ		DB	"read$"			; type of operation
	OP_WRITE	DB	"write$"

	FAIL_DATA_TABLE	DW	OFFSET 	FAIL_1		; where to fail
			DW	OFFSET	FAIL_2
			DW	OFFSET	FAIL_3
			DW	OFFSET	FAIL_4

	FAIL_1		DB	"system files$"
	FAIL_2		DB	"FAT$"
	FAIL_3		DB	"root directory$"
	FAIL_4		DB	"data files$"

	CRLF		DB	CR,LF,"$"

	TEXT_HEADER	DB	"INT 24h HANDLER INFORMATION...$"
	BLOCK_DEVICE	DB	"Block Device $"
	CHAR_DEVICE	DB	"Non-Block Device $"
	DEV_ADDR	DB	"Driver Header(seg:ofs) $"
	DEV_ATTR_WORD	DB	"Device Driver Attributes: $"
	ERROR_MESSAGE	DB	"Error: $"
	TYPE_MESSAGE	DB	"Operation: $"
	DISK_AREA	DB	"Disk area: $"
	USER_KEY_PRESS	DB	"press any key to continue...$"

 ;	useful subroutines

 ;	Purpose: 	Output the string to screen
 ;	At entry:	DS:DX = pointer to string terminated by '$'

	DISPLAY_MESSAGE	PROC	NEAR
		mov	ah,DispStr			; DOS function code
		int	DOS				; call DOS dispatcher
		ret					; return to caller
	DISPLAY_MESSAGE	ENDP

 ;	Purpose:	Write \n to screen

	NEW_LINE	PROC	NEAR
		mov	dx,OFFSET CRLF			; string to output
		call	DISPLAY_MESSAGE			; do it
		ret					; return to caller
	NEW_LINE	ENDP

 ;	Purpose:	Output the char to screen
 ;	At entry:	AL = char code

	WRITE_CHAR	PROC	NEAR
		push	dx				; save DX
		mov	dl,al				; make a copy
		mov	ah,OutChar			; DOS service
		int	DOS				; call DOS dispatcher
		pop	dx				; restore DX
		ret					; return to caller
	WRITE_CHAR	ENDP

 ;	Purpose:	Write the number in hexadecimal format
 ;	At entry:	AX = word to output

	WRITE_HEX_WORD	PROC	NEAR
		xchg	ah,al				; swap low and high bytes
		mov	dx,ax				; save AX

		mov	al,'$'				; hex. digit ID
		call	WRITE_CHAR			; output it

		mov	ax,dx				; restore AX
		mov	bx,OFFSET HEX_TABLE		; BX = base of table
		mov	cl,4				; shift count

		shr	al,cl				; first digit
		xlat					; get it into AL
		call	WRITE_CHAR			; output it

		mov	ax,dx				; second digit
		and	al,0Fh				; low nibble
		xlat					; get a char
		call	WRITE_CHAR			; output it

		xchg	dh,dl				; make third digit
		mov	ax,dx
		shr	al,cl
		xlat
		call	WRITE_CHAR			; output it

		mov	ax,dx				; make fourth digit
		and	al,0Fh
		xlat
		call	WRITE_CHAR			; output it

		ret					; return to caller
	WRITE_HEX_WORD	ENDP

 ;	new interrupt 24h handler code routine

	NEW_ERR_HANDLER		PROC	FAR

 ;	save current stack info
	
		mov	CS:OLD_SS,ss			; SS reg
		mov	CS:OLD_SP,sp			; SP reg

 ;	switch to local stack

		mov	ss,CS:CODE_SEG			; new SS
		mov	sp,OFFSET LOCAL_STACK		; new SP

 ; 	save all general registers and flags

		pushf
		push	ax
		push	bx
		push	cx
		push 	dx
		push	si
		push	di
		push	bp
		push	ds
		push	es

		sti					; re-enable interrupts

 ;	save the entry info

		mov	bx,cs				; move the CS
		mov	ds,bx				;  to DS

		mov	ERROR_INFO,ax
		mov	ERROR_CODE,di
		mov	DEV_HDR_SEG,bp
		mov	DEV_HDR_OFS,si

		mov	es,bx				; ES = code seg now
		mov	ds,bp				; DS:SI = device header pointer
		mov	di,OFFSET DEVICE_ATTR		; DI = destination offset
		add	si,4				; skip the link field
		lodsw					; copy the attrs
		stosw
		add	si,4				; skip the 'offset' fields
		mov	cx,NameLen shr 1		; length (in words)
		cld					; go forward
		rep	movsw				; copying of name...
		mov	ds,bx				; restore DS

 ;	get the video mode

		mov	ah,0Fh				; video service 15
		int	VIDEO_BIOS			; video interface

 		mov	VIDEO_PAGE,bh			; save page to use later

		cmp	al,7				; mono mode?
		je	TEXT_MODE			; yes, then jump
		cmp	al,3				; modes 0-3?
		jbe	TEXT_MODE			; yes, then jump
		jmp	INT_EXIT			; no display in graphic mode

	TEXT_MODE:
		mov	WIN_SIZ_Y,LEN_Y_1		; 10 rows
		mov	DRIVE_FLAG,true			; assume the block device
		test	ERROR_INFO,8000h		; bit 15 = 0 (block device)
		jz	DRIVE_FAILED_NOW		; if zero, then jump

		mov	DRIVE_FLAG,false		; flag = non-block device
		mov	WIN_SIZ_Y,LEN_Y_2		; 7 rows

	DRIVE_FAILED_NOW:
		mov	ah,3				; get the cursor pos
		int	VIDEO_BIOS			; video interface

		mov	OLD_CUR_POS,dx			; save it's position

		mov	di,OFFSET  WIN_AREA		; DI = destination offset
		mov	cx,WINDOW_SIZE_XY		; CX = # of words
		mov	dx,(Wind_Beg_Y shl 8) + Wind_Beg_X ; DX = start pos of cursor
	
	GET_CHAR:
		mov	ah,2				; set the new pos
		int	VIDEO_BIOS			; video interface

		mov	ah,8				; read char/attr at cursor pos
		int	VIDEO_BIOS			; video interface
		stosw					; store a video word
		
		inc	dl				; incr col
		cmp	dl,cl				; at end of row?
		jne	GET_CHAR			; no? then jump
		mov	dl,Wind_Beg_X			; reset to beginning
		inc	dh				; incr row
		cmp	dh,ch				; last row past?
		jne	GET_CHAR			; no, then jump

 ;	clears the window
		mov	bh,VIDEO_ATTR			; how to clear?
		mov	cx,(Wind_Beg_Y shl 8) + Wind_Beg_X ; left corner
		mov	dl,LEN_X - 1			; convert to BIOS format
		mov	dh,WIN_SIZ_Y
		mov	al,dh				; # of rows to scroll
		dec	dh
		mov	ah,7				; scroll down
		int	VIDEO_BIOS			; video interface

 ;	set the cursor to left corner of window

		mov	dx,(Wind_Beg_Y shl 8) + Wind_Beg_X ; DX = start pos of cursor
		mov	bh,VIDEO_PAGE			; active video page
		mov	ah,2				; set the new pos
		int	VIDEO_BIOS			; video interface

 ;	write the text what to see

		mov	dx,OFFSET  TEXT_HEADER
		call	DISPLAY_MESSAGE
		call	NEW_LINE

 ;	write the name of device

		cmp	DRIVE_FLAG,false		; disk drive?
		je	OTHER_DEVICE

		mov	dx,OFFSET BLOCK_DEVICE
		call	DISPLAY_MESSAGE
		mov	al,FAILED_DRIVE
		add	al,'A'				; make a letter
		call	WRITE_CHAR			; and output it
		jmp	SHORT  NAME_DONE		; jump always

	OTHER_DEVICE:
		mov	dx,OFFSET  CHAR_DEVICE
		call	DISPLAY_MESSAGE
		mov	dx,OFFSET DEVICE_NAME
		call	DISPLAY_MESSAGE

	NAME_DONE:
		call	NEW_LINE			; reset the cursor to
							; beginning of new line

 ;	write the device driver header address

		mov	dx,OFFSET  DEV_ADDR
		call	DISPLAY_MESSAGE

		mov	ax,DEV_HDR_SEG			; format $xxxx:$yyyy
		call	WRITE_HEX_WORD

		mov	al,':'
		call	WRITE_CHAR

		mov	ax,DEV_HDR_OFS
		call	WRITE_HEX_WORD

		call	NEW_LINE			; jump to new line

 ;	write the device driver attribute status

		mov	dx,OFFSET  DEV_ATTR_WORD
		call	DISPLAY_MESSAGE
		mov	ax,DEVICE_ATTR			; format $xxxx
		call	WRITE_HEX_WORD

		call	NEW_LINE

 ;	write the error code (text)

		mov	dx,OFFSET ERROR_MESSAGE
		call	DISPLAY_MESSAGE

		mov	bx,ERROR_CODE
		and	bx,15				; used only bits 0-4
		shl	bx,1				; offset = word
		add	bx,OFFSET ERR_TABLE
		mov	dx,[bx]				; load new offset
		call	DISPLAY_MESSAGE

		call	NEW_LINE

 ;	see where the error occurred

		cmp	DRIVE_FLAG,false		; non-block devcie?
		je	ALL_INFO			; yes, then jump

 ;	for block device: which operation type

		mov	dx,OFFSET TYPE_MESSAGE
		call	DISPLAY_MESSAGE

		mov	dx,OFFSET OP_READ
		test	WP ERROR_INFO,0100h		; see the op type
		jz	OP_DONE				; if zero, then reading faile
		mov	dx,OFFSET OP_WRITE		; else writing
	OP_DONE:
		call	DISPLAY_MESSAGE

		call	NEW_LINE

 ;	for block device: where to fail
		
		mov	dx,OFFSET  DISK_AREA
		call	DISPLAY_MESSAGE

		mov	bl,BYTE PTR  ERROR_INFO+1
		sub	bh,bh
		and	bl,00000110b			; only bits 1-2
		add	bx,OFFSET  FAIL_DATA_TABLE
		mov	dx,[bx]				; new offset
		call	DISPLAY_MESSAGE

		call	NEW_LINE

 ;	all info on screen, wait user action

	ALL_INFO:
		mov	dx,OFFSET USER_KEY_PRESS
		call	DISPLAY_MESSAGE

 ;	empties the kbd queue and wait the user hit

	TEST_KBD:
		mov	ah,1				; service 1
		int	KBD_BIOS
		jz	WAIT_KEY			; no key available?
		sub	ah,ah				; service 0
		int	KBD_BIOS
		jmp	SHORT	TEST_KBD		; jump always
	WAIT_KEY:
		sub	ah,ah				; service 0
		int	KBD_BIOS

 ;	restore the window on screen

		mov	si,OFFSET  WIN_AREA		; DI = destination offset
		mov	cx,WINDOW_SIZE_XY		; CX = # of words
		mov	dx,(Wind_Beg_Y shl 8) + Wind_Beg_X ; DX = start pos of cursor
		mov	bh,VIDEO_PAGE			; active video page
	
	PUT_CHAR:
		mov	ah,2				; set the new pos
		int	VIDEO_BIOS			; video interface

		push	cx				; save a counter
		lodsw					; get a video word
		mov	bl,ah				; BL = attr
		mov	cx,1				; CX = # of chars
		mov	ah,9				; write char/attr at cursor pos
		int	VIDEO_BIOS			; video interface
		pop	cx				; restore counter

		inc	dl				; incr col
		cmp	dl,cl				; at end of row?
		jne	PUT_CHAR			; no? then jump
		mov	dl,Wind_Beg_X			; reset to beginning
		inc	dh				; incr row
		cmp	dh,ch				; last row past?
		jne	PUT_CHAR			; no, then jump

		mov	dx,OLD_CUR_POS			; restore old position
		mov	ah,2				; video service 2
		int	VIDEO_BIOS			; video interface

 ;	restore the beginning of the old handler
	INT_EXIT:
		mov	cx,PATCH_CODE_LEN		; load a count
		les	di,DP CS:OLD_INT_24_Vec		; ES:DI = pointer to old vector
		mov	ds,CS:CODE_SEG			; DS = source segment
		mov	si,OFFSET OLD_CODE		; SI = source offset
		rep	movsb				; now copying...
		
 ;	now restore all general registers and flags
		
		cli					; disable interrupts
		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf

 ;	switch	to old stack

		mov	ss,CS:OLD_SS
		mov	sp,CS:OLD_SP
		
 ;	call the old interrupt handler routine

		pushf					; emulate the interrupt
		call		DP  CS:OLD_INT_24_VEC	; exit trough old INT 24h handler

 ;	save the needing registers

		push	ds
		push	es
		push	cx
		push	si
		push	di

 ;	patch the code again

		mov	cx,PATCH_CODE_LEN		; load a count
		mov	ds,CS:CODE_SEG			; DS = code segment
		mov	si,OFFSET PATCH_CODE		; SI = source offset
		les	di,DP CS:OLD_INT_24_Vec		; ES:DI = pointer to old vector
 		rep	movsb				; now copying...

 ;	restore the saved registers

		pop	di
		pop	si
		pop	cx
		pop	es
		pop	ds

 ; 	return from interrupt

		iret		

	NEW_ERR_HANDLER		ENDP


 ;	local stack space  =  256 bytes

	STACK_SPACE	DB	32  DUP ('STACKxxx')	; pattern for recognize
	LOCAL_STACK	LABEL	WORD			; top of stack

 ;	how much bytes of memory to keep resident

	CodeToKeep	LABEL	BYTE


 ; 	initialization code

	INIT:
		mov	CODE_SEG,cs			; save current code segment

 ;	get and save the old INT 24h vector

		mov	ax,(GetVec shl 8) + ErrHandler  ; DOS function = GetIntVec
		int	DOS				; call Dos dispatcher

		mov	OLD_INT_24_VEC.VecOfs,bx	; save the offset
		mov	OLD_INT_24_VEC.VecSeg,es	; save the segment

 ;	set the new INT 24h vector using the code patching

		mov	CODE_OFS,OFFSET NEW_ERR_HANDLER ; load a offset for jump

		mov	cx,PATCH_CODE_LEN		; load a count
		mov	es,CODE_SEG			; ES = destination segment
		mov	di,OFFSET OLD_CODE		; DI = destination offset
		lds	si,DP OLD_INT_24_Vec		; DS:SI = pointer to old vector
		rep	movsb				; now copying...

		mov	cx,PATCH_CODE_LEN		; load a count
		mov	ds,CS:CODE_SEG			; DS = code segment
		mov	si,OFFSET PATCH_CODE		; SI = source offset
		les	di,DP OLD_INT_24_Vec		; ES:DI = pointer to old vector
 		rep	movsb				; now copying...
		
 ;	display a installation message
		
		mov	dx,OFFSET INSTALLATION		; DS:DX = pointer to string
		call	DISPLAY_MESSAGE			; output to screen

 ;	terminate and stay resident into memory
		
		mov	dx,OFFSET CodeToKeep + 15	; resident code length
		mov	cl,4				; shift count
		shr	dx,cl				; DX = # of paragraphs
		mov	ax,(TSR shl 8) + ExitCode	; say to DOS that we resident
		int	DOS				; call DOS dispatcher

 ;	message

	INSTALLATION	DB	"Sample Program  V1.00  by D.Stefankoff, 21 September 1989",CR,LF
			DB	"Additional Int 24h handler installed.",CR,LF,"$"

	IF1
		%OUT	Ending of Pass 1
	ENDIF

	IF2
		%OUT	Ending	of Pass 2
	ENDIF

	CODE	ENDS
		END
