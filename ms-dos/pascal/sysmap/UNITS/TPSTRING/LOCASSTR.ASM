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

                PUBLIC   LoCaseString

;  procedures

  StringPtr     EQU      SS:[BX+4]                    ;string pointer

  LoCaseString  PROC     FAR
             StackFrame  bx                           ;set up stack frame
             cld                                      ;forward direction
             mov      dx,ds                           ;save DS
             lds      si,StringPtr                    ;load the string pointer
             sub      cx,cx                           ;clear CX
             mov      cl,[si]                         ;load the length
             jcxz     Quit                            ;exit if null length
             les      di,StringPtr                    ;load the string pointer
             inc      si                              ;skip a index
             inc      di
  LowCase:
             lodsb                                    ;get a char
             cmp      al,'A'                          ;convert to upcase
             jb       LoCase1
             cmp      al,'Z'
             ja       LoCase1
             add      al,'a'-'A'                      ;adjust to upcase
  LoCase1:
             stosb                                    ;store a char
             loop     LowCase                         ;loop till done
  Quit:
	     mov      ds,dx		              ;restore DS
	     ret       4	
  LoCaseString  ENDP

   CODE         ENDS
       		END
