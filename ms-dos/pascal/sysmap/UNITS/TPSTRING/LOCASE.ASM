                PAGE   59,132
                TITLE  External assembly routines for TpString Unit

;  Version     2.00
;  Date        01/03/90
;  Programmer  Dmitri V. Stefankov

   INCLUDE   TPCOMMON.INC                             ;macros and equates

;   data  segment
   DATA         SEGMENT  WORD  PUBLIC
                ASSUME   DS:DATA                      ;info for MASM
; no variables

   DATA         ENDS

;  code  segment
   CODE         SEGMENT  BYTE  PUBLIC
                ASSUME   CS:CODE,DS:DATA              ;info for MASM

                PUBLIC   LoCase

;  function

  CharToConvert EQU      SS:[BX+4]

  LoCase        PROC     FAR
             StackFrame  bx                           ;set up stack frame
             mov      ax,CharToConvert                ;convert to lowercase
             cmp      al,'Z'
             ja       Quit4
             cmp      al,'A'
             jb       Quit4
             add      al,'a'-'A'
  Quit4:
             ret      2
  LoCase        ENDP

   CODE         ENDS
       		END
