                   PAGE   59,132
                   TITLE  External assembly routines for TpKbd Unit

;  Version     1.00
;  Date        01/06/90
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

          PUBLIC   KeyPressed

;  interface  part

    KeyPressed     PROC      FAR
                mov       ah,CharAvail           ;load a function
                cmp       EnhancedKbd,false      ;see what type kbd
                je        L2
                mov       ah,ExtCharAvail
    L2:
                int       BiosKbd                ;call BIOS
                mov       al,1                   ;set result to true
                jnz       L3                     ;char available?
                Zero      al                     ;no, then result = false
    L3:
                ret                              ;return far
    KeyPressed     ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
