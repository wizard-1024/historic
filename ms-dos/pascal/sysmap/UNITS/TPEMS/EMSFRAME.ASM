                   PAGE   59,132
                   TITLE  External assembly routines for TpEms Unit

;  Version     1.0
;  Date        4/22/89
;  Programmer  Dima Stefankov

   INCLUDE  TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

;  internal variables

   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   EmsPageFramePtr

;  interface  part

;   Thanks to  TurboPower Sotfware  Inc.

    EmsPageFramePtr	PROC FAR
            EmsCall	41h		;Get page frame	segment
            OR	AH,AH			;Check for error
            MOV	AX,0			;Offset	is zero	in any case
            MOV	DX,BX			;Segment from DX to BX
            JZ	FramePtrExit		;Done if AH = 0
            Zero	DX		;Else DX = 0
    FramePtrExit:
            RET				;Return
    EmsPageFramePtr	ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
