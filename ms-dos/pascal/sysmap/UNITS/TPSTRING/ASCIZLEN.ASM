                PAGE   59,132
                TITLE  External assembly routines for TpString Unit

;  Version     2.00
;  Date        06/27/90
;  Programmer  Dima Stefankov

   INCLUDE   TPCOMMON.INC                             ;macros and equates

;   data  segment
   DATA         SEGMENT  WORD  PUBLIC
                ASSUME   DS:DATA                      ;info for MASM
; no variables

   DATA         ENDS

;  code  segment
   CODE         SEGMENT  BYTE  PUBLIC
                ASSUME   CS:CODE,DS:DATA              ;info for MASM

                PUBLIC   LenAsciiz

;  procedures

  AsciizStrPtr  EQU      SS:[BX+4]

  LenAsciiz     PROC     FAR
             StackFrame  bx                           ;set up stack frame
             les      di,AsciizStrPtr                 ;load the pointer
             mov      bx,di                           ;store initial offset
             mov      cx,0FFFFh                       ;check the max. len
             sub      al,al                           ;look for null
             cld                                      ;forward direction
             repne    scasb                           ;scan while not equal
             sub      di,bx                           ;get the count of bytes
             mov      ax,di                           ;return in AX
             dec      ax                              ;0 doesn't count
             ret      4                               ;pop parms
  LenAsciiz     ENDP

   CODE         ENDS
       		END
