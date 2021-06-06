                   PAGE   59,132
                   TITLE  External assembly routines for TpKbd Unit

;  Version     1.10
;  Date        01/09/91
;  Programmer  Dima Stefankov

   INCLUDE   TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references
	  EXTRN    CheckBreak     :   BYTE       ;^Break disable/enable
          EXTRN    BreakCstr      :   BYTE       ;break string for display
          EXTRN    WriteBiosStr   :   FAR        ;TP interface
	  EXTRN	   ShiftStatus	  :   FAR
          EXTRN    EnhancedKbd    :   BYTE       ;kbd type ID
	  EXTRN    SaveKbdCode	  :   WORD	 ;last kbd codes

;  internal variables
   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   ReadKey
	  PUBLIC   GetAsciiCode
	  PUBLIC   GetScanCode

;  interface  part

    ReadKey        PROC      FAR
                mov       ah,ReadChar            ;load a function
                cmp       EnhancedKbd,false      ;see what type kbd
                je        L1
                mov       ah,ExtReadChar
    L1:
                int       BiosKbd                ;call BIOS
		mov	  SaveKbdCode,ax	 ;save scan & Ascii code
		cmp	  CheckBreak,false	 ;AX = result
		je	  FuncExit
		mov	  bx,ax			 ;save the result
		push	  ax
		call	  ShiftStatus		 ;get kbd status
		test	  al,CtrlState		 ;is ctrl key pressed?
		jz	  Done
		cmp	  bl,CtrlC		 ;C = ASCII code?
		jne	  Done
		push	  ds			 ;push DS
		mov	  ax,OFFSET BreakCStr
		push	  ax			 ;now on stack ptr to string
		call	  WriteBiosStr		 ;display this string
		int	  23h			 ;call ^C handler
    Done:
		pop	  ax
    FuncExit:
                ret                              ;return far
    ReadKey        ENDP

    GetAsciiCode   PROC          FAR
		mov	al,Byte Ptr SaveKbdCode  ;get low byte
		ret
    GetAsciiCode   ENDP

    GetScanCode    PROC          FAR
		mov	 al,Byte Ptr SaveKbdCode+1 ;get high byte
		ret
    GetScanCode    ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
