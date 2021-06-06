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

                PUBLIC   StringDup

;  procedures

  OldStringPtr  EQU      SS:[BX+6]
  SizeOfString  EQU      SS:[BX+4]

  StringDup     PROC     FAR
             StackFrame  bx                           ;set up stack frame
             mov      dx,ds
             lds      si,OldStringPtr                 ;get a string pointer
             les      di,OldStringPtr
             mov      bx,SizeOfString
             sub      ah,ah                           ;get a string length
             mov      al,[si]
             mov      cx,ax
             add      di,cx                           ;find the last char
             inc      di
             shl      ax,1                            ;make a new len
             cmp      ax,bx
             ja       DupDone                         ;if > 255, done
             mov      [si],al                         ;put a new len
             inc      si                              ;skip it
             cld                                      ;go forward
             rep      movsb                           ;now move...
  DupDone:
             mov     ds,dx                            ;restore DS
             ret     6                                ;remove & exit
  StringDup     ENDP


   CODE         ENDS
       		END
