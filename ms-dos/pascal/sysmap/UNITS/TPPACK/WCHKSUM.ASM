                   PAGE   59,132
                   TITLE  External assembly routines for TpPack Unit

;  Version     2.00
;  Date        01/07/90
;  Programmer  Dima Stefankov

    INCLUDE  TPCOMMON.INC

    DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

;  internal variables

    DATA   ENDS


    CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   WordsCheckSum

;  interface  part

    BufferL                EQU          SS:[BX+8]
    CountLo                EQU          SS:[BX+4]
    CountHi                EQU          SS:[BX+6]

    WordsCheckSum          PROC         FAR
               StackFrame    bx                  ;set up stack frame
               push    ds                        ;save DS
               cld                               ;go forward
               mov     cx,CountHi                ;bytes counter
	       mov     dx,CountLo
               lds     si,BufferL                ;pointer
               Zero    ax                        ;AX = 0
               Zero    bx                        ;BX = 0
    L2:
               lodsw                             ;get a word
               add     bx,ax                     ;add it to sum
               dec     dx                        ;decrement a counter
	       jnz     L2
               or      cx,cx                     ;<66536?
               jz      L21A
	       mov     di,ds
	       add     di,1000h                  ;64K = segment
	       mov     ds,di
	       Zero    si
               dec     cx
	       jnz     L2			 ;if zero then done
    L21A:
               mov     ax,bx                     ;AX = result
               pop     ds                        ;restore DS
               ret     8                         ;remove parms and returm
    WordsCheckSum          ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
