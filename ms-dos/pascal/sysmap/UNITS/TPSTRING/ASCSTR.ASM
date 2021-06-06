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

                PUBLIC   AscString

;  procedures

  StringPtr     EQU      SS:[BX+4]                    ;string pointer

  AscString     PROC     FAR
                StackFrame  bx                        ;set up stack frame
                cld                                   ;forward direction
                les      di,StringPtr                 ;load the string ptr
                mov      cx,255                       ;max. length of string
                xor      al,al                        ;end of string
                repne    scasb                        ;search the end
                not      cl                           ;1's complement
                dec      cl                           ;because points one more
                jcxz     Quit2                        ;zero length then exit
                mov      dx,ds                        ;save DS
                lds      si,StringPtr                 ;load the pointer
                std                                   ;back direction
                dec      di                           ;ponits to zero
                mov      si,di                        ;make SI=DI
                dec      si                           ;point to the last char
                push     cx                           ;save the length
                rep      movsb                        ;move the string up
                pop      cx                           ;restore CX
                mov      BYTE PTR [di],cl             ;write the length
                mov      ds,dx                        ;restore DS
  Quit2:
                ret      4
  AscString     ENDP

   CODE         ENDS
       		END
