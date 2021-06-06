                   PAGE   59,132
                   TITLE  External assembly routines for TpKbd Unit

;  Version     1.00
;  Date        01/06/90
;  Programmer  Dima Stefankov

   INCLUDE   TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references
          EXTRN    EnhancedKbd    :   BYTE       ;kbd ID type

;  internal variables
   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   NonDestructiveInput

;  interface  part

    NonDestructiveInput     PROC      FAR
                mov       ah,CharAvail           ;load a function
                cmp       EnhancedKbd,false
                je        L2
                mov       ah,ExtCharAvail        ;load a extended function
    L2:
                int       BiosKbd                ;call BIOS
                jz        L3                     ;no available char?
                ret                              ;return far
    L3:
                Zero      ax                     ;result = $0
                ret                              ;return far
    NonDestructiveInput     ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
