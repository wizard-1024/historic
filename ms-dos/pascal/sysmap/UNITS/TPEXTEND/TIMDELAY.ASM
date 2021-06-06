                   PAGE   59,132
                   TITLE  External assembly routines for TpExtend Unit

;  Version      1.0
;  Date         04/22/90
;  Programmer   Dima Stefankov

   INCLUDE  TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

;  internal variables

   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   TimeDelay                     ;public declarations


;  interface  part

   CountHi         EQU       SS:[BX+10]
   CountLo         EQU       SS:[BX+8]
   ErrorVar        EQU       SS:[BX+4]

   TimeDelay       PROC      FAR
                StackFrame  bx                   ;set up stack frame
                mov      cx,CountHi              ;load a delay value
                mov      dx,CountLo
                mov      ah,86h                  ;load functon
                int      ATbios                  ;call gen services
   L1:
                Zero     al                      ;assume error
                jc       L2                      ;error flag is set
                mov      al,1                    ;result = true
   L2:
                les     di,ErrorVar              ;get the pointer to var
                mov     es:[di],al               ;save a value
                ret     8                        ;return and pop parms
   TimeDelay       ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
