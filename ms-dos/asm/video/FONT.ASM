;   VGA 8x16 font loader

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

_TEXT        SEGMENT   PARA PUBLIC 'CODE'
		ASSUME  CS:_TEXT, SS:STACK

   Old_EGA_Table_Ptr	DD	?

   New_EGA_Table_Ptr	EGA_Tables <>
   EGA_Tables_Len		=	$  -  New_EGA_Table_Ptr


; for text mode - uncomment next lines
   New_Text_Font_Ptr	LABEL    BYTE
   New_Font     Font_Desc  <16,0,256,0,OFFSET Font_Ptr,SEG _TEXT,0FFh>
;  supported video modes
		DB	0,1,2,3,7,0FFh

   New_Graph_Font_Ptr	LABEL	BYTE
   New_Gr_Font  GrFont_Desc  <0,16,OFFSET Font_Ptr,SEG _TEXT>
		DB	11h,12h,0FFh

   Font_Ptr	LABEL	BYTE
	
	INCLUDE		A8x16.INC

   Start:

; set up the data registers

		mov	ax,SEG	ROM_DATA
		mov	ds,ax
		ASSUME	DS:ROM_DATA

		mov     ax,SEG  _TEXT
		mov	es,ax
		ASSUME  ES:_TEXT

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
		mov     Wptr [EGA_Table_Ptr+2],SEG _TEXT
;load text pointer 
		mov	Wptr New_EGA_Table_Ptr.Alpha_Mode_Aux_Gen_Ptr,OFFSET New_Text_Font_Ptr
		mov     Wptr New_EGA_Table_Ptr.Alpha_Mode_Aux_Gen_Ptr+2,SEG _TEXT
;load graph pointer
		mov	Wptr New_EGA_Table_Ptr.Graph_Mode_Aux_Gen_Ptr,OFFSET New_Graph_Font_Ptr
		mov     Wptr New_EGA_Table_Ptr.Graph_Mode_Aux_Gen_Ptr+2,SEG _TEXT

; TSR function

		mov	ax,3100h
		mov     dx,OFFSET Start + 256           ;+PSP length
		mov	cl,4
		shr	dx,cl
		inc	dx		
		int	21h
_TEXT   ENDS

        Stack   SEGMENT STACK
                DB      32  DUP ('STACKxxx')
        Stack   ENDS

		END	Start

