			PAGE	,132
			TITLE	EGA/VGA font loader

;   EGA/VGA font loader

; to load EGA font to comment the line below
VGAload	      =	    0

SetVector     MACRO     Interrupt,HandlerPtr
              mov       al,Interrupt
              mov       dx, offset HandlerPtr
              mov       ah,25h
              int       21h
              ENDM

GetVector     MACRO     Interrupt
              mov       al,Interrupt
              mov       ah,35h
              int       21h
              ENDM

Message       MACRO     String
              mov       dx, offset String
              mov       ah,09h
              int       21h
              ENDM


; definitions

   Wptr		EQU		<WORD PTR>

   EGA_Tables	STRUC
	Video_Parms_Ptr		DD	?
	Dynamic_Save_Area_Ptr	DD	?
	Alpha_Mode_Aux_Gen_Ptr	DD	?
	Graph_Mode_Aux_Gen_Ptr	DD	?
	Reserved_Ptrs		DD	3  DUP (?)
   EGA_Tables	ENDS



   Font_Desc	STRUC
	Bytes_Per_Char		DB	?
	Char_Block		DB	?
	Char_Count		DW	?
	Char_Offset		DW	?
	Char_Font_Ptr_Ofs	DW	?
	Char_Font_Ptr_SEG	DW	?
	Displayable_Rows	DB	?
   Font_Desc	ENDS

   GrFont_Desc	STRUC
	GrDisplayable_Rows	DB	?
	GrBytes_Per_Char	DW	?
	GrChar_Font_Ptr_Ofs	DW	?
	GrChar_Font_Ptr_SEG	DW	?
   GrFont_Desc	ENDS

	ROM_DATA	SEGMENT	AT	40h
		ORG	0A8h
   EGA_Table_Ptr	LABEL	DWORD	
	ROM_DATA	ENDS

; to make the following order
; segment 1 = CODE
; segment 2 = STACK

			DOSSEG

CODE        SEGMENT   PARA PUBLIC 'CODE'
		ASSUME  CS:CODE, DS:CODE, SS:STACK

   Old_EGA_Table_Ptr	DD	?

   New_EGA_Table_Ptr	EGA_Tables <>
   EGA_Tables_Len		=	$  -  New_EGA_Table_Ptr


; for text mode - uncomment next lines

		IFDEF	VGAload
		      BytesPerChar  =   16
		ELSE			
		      BytesPerChar  =   14
		ENDIF

   New_Text_Font_Ptr	LABEL    BYTE
   New_Font     Font_Desc  <BytesPerChar,0,256,0,OFFSET Font_Ptr,SEG CODE,0FFh>
;  supported video modes
		DB	0,1,2,3,7,0FFh

   New_Graph_Font_Ptr	LABEL	BYTE
   New_Gr_Font  GrFont_Desc  <0,BytesPerChar,OFFSET Font_Ptr,SEG CODE>

	IFDEF	VGAload	
		DB	11h,12h,0FFh
	ELSE
		DB	0Fh,10h,0FFh
	ENDIF

   Font_Ptr	LABEL	BYTE

	IFDEF	VGAload
		  INCLUDE	A8x16.INC
	ELSE
		INCLUDE		A8x14.INC
	ENDIF

   Start:

; set up the data registers

		mov	ax,SEG	ROM_DATA
		mov	ds,ax
		ASSUME	DS:ROM_DATA

		mov     ax,SEG  CODE
		mov	es,ax
		ASSUME  ES:CODE

; save the original EGA pointer

		lds	si,EGA_Table_Ptr
		mov	Wptr Old_EGA_Table_Ptr.[0],si
		mov	Wptr Old_EGA_Table_Ptr.[2],ds

;  now copy the EGA data area

		mov	di,OFFSET New_EGA_Table_Ptr
		mov	cx,(EGA_Tables_Len) shr 1
		cld
		rep	movsw

; set up the new EGA_tables pointer

		mov	ax,SEG	ROM_DATA
		mov	ds,ax
		ASSUME	DS:ROM_DATA

		mov	Wptr [EGA_Table_Ptr],OFFSET New_EGA_Table_Ptr
		mov     Wptr [EGA_Table_Ptr+2],SEG CODE
;load text pointer 
		mov	Wptr New_EGA_Table_Ptr.Alpha_Mode_Aux_Gen_Ptr,OFFSET New_Text_Font_Ptr
		mov     Wptr New_EGA_Table_Ptr.Alpha_Mode_Aux_Gen_Ptr+2,SEG CODE
;load graph pointer
		mov	Wptr New_EGA_Table_Ptr.Graph_Mode_Aux_Gen_Ptr,OFFSET New_Graph_Font_Ptr
		mov     Wptr New_EGA_Table_Ptr.Graph_Mode_Aux_Gen_Ptr+2,SEG CODE

; TSR function
		mov	ah,03h				; get cursor position
		int	10h
		mov	ah,0Fh				; get current video mode
		int	10h
		mov	ah,00h				; set new pointers!!
		or	al,80h				; preserve current screen image
		int	10h
		mov	ah,02h				; set cursor position
		int	10h

		mov	ax,3100h
		mov     dx,OFFSET Start + 256           ;+PSP length
		mov	cl,4
		shr	dx,cl
		inc	dx		
		int	21h
CODE   ENDS
	
STACK   SEGMENT STACK
                DB      32  DUP ('STACKxxx')
STACK   ENDS

		END	Start

