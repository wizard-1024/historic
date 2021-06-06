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

          PUBLIC   DecryptA

;  interface  part

    Password               EQU          SS:[BX+4]
    Counter                EQU          SS:[BX+8]
    BufferPtr              EQU          SS:[BX+10]

    DecryptA               PROC         FAR
               StackFrame    bx                  ;set up stack frame
               push    bp                        ;save BP
               push    ds                        ;save DS
               cld                               ;go forward
               mov     cx,Counter                ;get a counter
               shr     cx,1                      ;get a paars
               jcxz    L6                        ;empty buffer!
               lds     si,BufferPtr              ;load a pointer
    L5:
               lodsw                             ;get a even paar
               dec    si                         ;back a pointer
               dec    si
               mov    dh,al                      ;prepare for mask
               mov    dl,ah
               REPT   4                          ;swaps a bytes
                      shl    dh,1
               ENDM
               REPT   4
                      shr    dl,1
               ENDM
               and    ax,0000111111110000b
               or     ax,dx
               mov    [si],ax                    ;put a word back
               inc    si                         ;forward
               inc    si
               dec    cx                         ;decrement a counter
               jcxz   L6                         ;if done the exit
               lodsw                             ;get a even paar
               dec    si                         ;back a pointer
               dec    si
               mov    dh,al                      ;prepare for mask
               mov    dl,ah
               REPT   4                          ;swaps a bytes
                      shl    dl,1
               ENDM
               REPT   4
                      shr    dh,1
               ENDM
               and    ax,1111000000001111b
               or     ax,dx
               mov    [si],ax                    ;put a word back
               inc    si                         ;forward
               inc    si
               dec    cx                         ;decrement a counter
               jcxz   L6                         ;if done then exit
               jmp    SHORT   L5
    L6:
               mov     cx,Counter                ;get a counter
               jcxz    L9                        ;null length of buffer
               lds     si,BufferPtr              ;load a pointer
               les     di,Password               ;load a password
               Zero    dx                        ;CX = 0
               mov     dl,es:[di]                ;get a length
               or      dl,dl                     ;is null length?
               jz      L9                        ;yes, then exit
               inc     di                        ;skip length
               mov     bp,di                     ;save a beginnig
               add     dx,di                     ;add a offset
    L7:
               lodsb                             ;get a byte
               dec     si                        ;backward
               xor     al,es:[di]                ;EOR with a char
               mov     [si],al                   ;put a XOR'ed byte back
               inc     si
               inc     di
               cmp     di,dx                     ;end of string
               jne     L8
               mov     di,bp                     ;restore a beginning
    L8:
               loop    L7                        ;make till done
    L9:
               pop     ds                        ;restore DS
               pop     bp                        ;restore BP
               ret     10                        ;remove parms and returm
    DecryptA               ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
