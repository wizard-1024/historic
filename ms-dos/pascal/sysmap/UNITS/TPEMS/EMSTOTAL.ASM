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

          PUBLIC   EmsTotalPages

;  interface  part

;   Thanks to  TurboPower Sotfware  Inc.

    EmsTotalPages	PROC FAR
            EmsCall	42h		;Get number of pages function
            EmsWordResult	DX	;If successful,	return value in	DX
            RET				;Return
    EmsTotalPages	ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
