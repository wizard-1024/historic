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

          PUBLIC   EncryptB

;  interface  part

    Password               EQU          SS:[BX+4]
    Counter                EQU          SS:[BX+8]
    BufferPtr              EQU          SS:[BX+10]

    EncryptB               PROC         FAR
               StackFrame    bx                  ;set up stack frame
               push    bp                        ;save BP
               push    ds                        ;save DS
               cld                               ;go forward
               mov     cx,Counter                ;get a counter
               shr     cx,1                      ;divide by 2
               jcxz    L13
               lds     si,BufferPtr              ;load a pointer
    L10:
               lodsw                             ;get a word
               dec     si                        ;back a pointer
               dec     si
               mov     dx,ax
               REPT    4
                   shl     dx,1
               ENDM
               and     dx,1111000011110000b
               xor     ax,dx                     ;XOR'ed word
               REPT    4
                   rol     dx,1
               ENDM
               and     ax,1111000011110000b
               or      ax,dx                     ;swap the low nibbles
               mov     [si],ax                   ;put a word back
               inc     si                        ;forward
               inc     si
               loop    L10                       ;repeat till done
               mov     cx,Counter                ;get a counter
               lds     si,BufferPtr              ;load a pointer
               les     di,Password               ;load a password
               Zero    dx                        ;CX = 0
               mov     dl,es:[di]                ;get a length
               or      dl,dl                     ;is null length
               jz      L13
               inc     di                        ;skip length
               mov     bp,di                     ;save a beginnig
               add     dx,di                     ;add a offset
    L11:
               lodsb                             ;get a byte
               dec     si                        ;backward
               xor     al,es:[di]                ;EOR with a char
               mov     [si],al                   ;put a XOR'ed byte back
               inc     si
               inc     di
               cmp     di,dx                     ;end of string
               jne     L12
               mov     di,bp                     ;restore a beginning
    L12:
               loop    L11                       ;make till done
    L13:
               pop     ds                        ;restore DS
               pop     bp                        ;restore BP
               ret     10                        ;remove parms and returm
    EncryptB               ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
