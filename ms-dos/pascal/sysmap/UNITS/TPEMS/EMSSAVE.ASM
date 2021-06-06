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

          PUBLIC   SaveEmsContext

;  interface  part

;   Thanks to  TurboPower Sotfware  Inc.

    EmsHandle	EQU	WORD PTR SS:[BX+4]

    SaveEmsContext	PROC FAR
            StackFrame	 bx		;Set up	stack frame
            MOV	DX,EmsHandle		;DX = Handle
            EmsCall	47h		;Save mapping context function
            EmsBoolean			;Set AX	and zero flag
            RET	2			;Remove	parameter and return
    SaveEmsContext	ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
