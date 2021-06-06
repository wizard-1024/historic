                PAGE   59,132
                TITLE  External assembly routines for TpString Unit

;  Version     2.00
;  Date        01/03/90
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

                PUBLIC   StringReverse

;  procedures

  StringPtr     EQU      SS:[BX+4]                    ;string pointer

  StringReverse PROC     FAR
             StackFrame  bx                           ;set up stack frame
             mov      dx,ds
             lds      si,StringPtr
             mov      di,si                           ;get a string pointer
             sub      ch,ch
             mov      cl,[si]                         ;load the length
             add      di,cx                           ;find the last char
             shr      cx,1                            ;divide by 2
             or       cx,cx                           ;is > 2?
             jcxz     AllDone
             inc      si                              ;skip the length
  Reverse:
             mov      al,[si]                         ;at begin
             mov      ah,[di]                         ;at end
             mov      [si],ah                         ;now reverse
             mov      [di],al
             inc      si                              ;update pointers
             dec      di
             loop     Reverse                         ;repeat till done
  AllDone:
             mov      ds,dx			      ;restore Turbo DS
	     ret       4
  StringReverse ENDP

   CODE         ENDS
       		END
