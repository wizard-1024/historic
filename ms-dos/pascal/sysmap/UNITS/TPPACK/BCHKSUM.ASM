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

          PUBLIC   BytesCheckSum                 ;public declarations

;  interface  part

    BufferL                EQU          SS:[BX+8]
    CountLo                EQU          SS:[BX+4]
    CountHi                EQU          SS:[BX+6]

    BytesCheckSum          PROC         FAR
               StackFrame    bx                  ;set up stack frame
               push    ds                        ;save DS
               cld                               ;go forward
               mov     cx,CountHi                ;bytes counter
	       mov     dx,CountLo
               lds     si,BufferL                ;pointer
               Zero    ax                        ;AX = 0
    L1:
               add     al,[si]                   ;add byte to sum
               inc     si                        ;incr offset
               dec     dx                        ;decrement a counter
	       jnz     L1
               or      cx,cx                     ;<66536?
               jz      L1A
	       mov     di,ds
	       add     di,1000h                  ;64K = segment
	       mov     ds,di
	       Zero    si
               dec     cx
	       jnz     L1			 ;if zero then done
    L1A:
               pop     ds                        ;restore DS
               ret     8                         ;remove parms and returm
    BytesCheckSum          ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
