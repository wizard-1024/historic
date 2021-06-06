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

                PUBLIC   AsciizString                 ;public declarations

;  procedures

  StringPtr     EQU      SS:[BX+4]                    ;string pointer

  AsciizString  PROC     FAR
  		StackFrame  bx                        ;set up stack frame
                cld				      ;forward direction
                mov      dx,ds                        ;save DS
  		lds      si,StringPtr		      ;load the pointer
                les	 di,StringPtr		      ;load the same pointer
                xor	 ch,ch			      ;clear CH
                mov	 cl,[si]		      ;CX = string length
                jcxz     Quit1                        ;zero lentgth then quit
                inc	 si			      ;skip the index
                rep	 movsb			      ;move the string up
                mov	 BYTE PTR [di],0	      ;make ASCIIZ string
  Quit1:
                mov      ds,dx                        ;recover DS
                ret      4
  AsciizString  ENDP


   CODE         ENDS
       		END
