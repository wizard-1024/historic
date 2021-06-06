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

          PUBLIC   EmsPagesAvail

;  interface  part

;   Thanks to  TurboPower Sotfware  Inc.

    EmsPagesAvail        PROC     FAR
                EmsCall   42h                    ;get number of pages function
                EmsWordResult  BX                ;if succesful, return value in BX
                ret                              ;return
    EmsPagesAvail        ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
