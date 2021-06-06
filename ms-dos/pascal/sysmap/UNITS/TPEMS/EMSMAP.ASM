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

          PUBLIC   MapEmsPage

;  interface  part

;   Thanks to  TurboPower Sotfware  Inc.

    MapHandle	EQU	WORD PTR SS:[BX+8]
    MapLogPage	EQU	WORD PTR SS:[BX+6]
    MapPhysPage	EQU	BYTE PTR SS:[BX+4]

    MapEmsPage	PROC FAR
            StackFrame    bx		;Set up	stack frame
            MOV	AL,MapPhysPage		;AL = PhysicalPage
            MOV	DX,MapHandle		;DX = Handle
            MOV	BX,MapLogPage		;BX = LogicalPage
            EmsCall	44h		;Map memory function
            EmsBoolean			;Set AX	and zero flag
            RET	6			;Remove	parameters and return
    MapEmsPage	ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
