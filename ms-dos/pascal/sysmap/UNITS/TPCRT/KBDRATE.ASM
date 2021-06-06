                   PAGE   59,132
                   TITLE  External assembly routines for TpKbd Unit

;  Version     1.00
;  Date        01/06/90
;  Programmer  Dima Stefankov

   INCLUDE   TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

;  internal variables

   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   SetKeyboardRate

;  interface  part

    Rate           EQU       SS:[SI+6]
    Delay          EQU       SS:[SI+4]

    SetKeyboardRate PROC     FAR
                StackFrame  si                   ;set up stack frame
                mov       bh,Delay               ;load a parms
                mov       bl,Rate
                mov       ax,SetRate
                int       BiosKbd                ;call BIOS
                ret       4                      ;return and pop parms
    SetKeyboardRate ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
