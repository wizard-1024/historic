                   PAGE   59,132
                   TITLE  External assembly routines for TpKbd Unit

;  Version     1.10
;  Date        01/09/91
;  Programmer  Dima Stefankov

   INCLUDE   TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references
          EXTRN    EnhancedKbd    :   BYTE       ;kbd type ID

;  internal variables
   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   ShiftStatus

;  interface  part

    ShiftStatus     PROC      FAR
                mov       ah,GetStatus           ;load a function
                cmp       EnhancedKbd,false      ;see what type kbd
                je        L1
                mov       ah,ExtGetStatus
    L1:
                int       BiosKbd                ;call BIOS
                ret                              ;return far
    ShiftStatus     ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
