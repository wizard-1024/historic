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

                PUBLIC   UpCaseString

;  procedures

  StringPtr     EQU      SS:[BX+4]                    ;string pointer

  UpCaseString  PROC     FAR
             StackFrame  bx                           ;set up stack frame
             cld                                      ;forward direction
             mov      dx,ds                           ;save DS
             lds      si,StringPtr                    ;load the string pointer
             sub      cx,cx                           ;clear CX
             mov      cl,[si]                         ;load the length
             jcxz     Quit3                           ;exit if null length
             les      di,StringPtr                    ;load the string pointer
             inc      si                              ;skip a index
             inc      di
  UpCase:
             lodsb                                    ;get a char
             cmp      al,'a'                          ;convert to upcase
             jb       UpCase1
             cmp      al,'z'
             ja       UpCase1
             sub      al,'a'-'A'                      ;adjust to upcase
  UpCase1:
             stosb                                    ;store a char
             loop     UpCase                          ;loop till done
  Quit3:
             mov      ds,dx                           ;restore DS
             ret      4
  UpCaseString  ENDP

   CODE         ENDS
       		END
