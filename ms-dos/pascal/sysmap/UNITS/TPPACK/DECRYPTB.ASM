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

          PUBLIC   DecryptB

;  interface  part

    Password               EQU          SS:[BX+4]
    Counter                EQU          SS:[BX+8]
    BufferPtr              EQU          SS:[BX+10]

    DecryptB               PROC         FAR
               StackFrame    bx                  ;set up stack frame
               push    bp                        ;save BP
               push    ds                        ;save DS
               cld                               ;go forward
               mov     cx,Counter                ;get a counter
               jcxz    L17
               lds     si,BufferPtr              ;load a pointer
               les     di,Password               ;load a password
               Zero    dx                        ;CX = 0
               mov     dl,es:[di]                ;get a length
               or      dl,dl                     ;is null length
               jz      L17
               inc     di                        ;skip length
               mov     bp,di                     ;save a beginnig
               add     dx,di                     ;add a offset
    L14:
               lodsb                             ;get a byte
               dec     si                        ;backward
               xor     al,es:[di]                ;EOR with a char
               mov     [si],al                   ;put a XOR'ed byte back
               inc     si
               inc     di
               cmp     di,dx                     ;end of string
               jne     L15
               mov     di,bp                     ;restore a beginning
    L15:
               loop    L14                       ;make till done
	       mov     cx,Counter		 ;get a counter
	       shr     cx,1			 ;only words
	       jcxz    L17
	       lds     si,BufferPtr
	       les     di,BufferPtr
    L16:
	       lodsw				 ;get a word
	       mov    dx,ax			 ;make a copy
	       and    dx,00F0Fh
	       and    ax,0F0F0h
	       REPT   4
	          ror    dx,1
	       ENDM
	       xor    ax,dx
	       REPT   4
		  shr    dx,1
	       ENDM
	       or     ax,dx
	       stosw	                         ;put back a word
	       loop   L16
     L17:
	       pop    ds
	       pop    bp
	       ret    10
     DecryptB     ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
