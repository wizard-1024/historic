                   PAGE   59,132
                   TITLE  External assembly routines for TpPack Unit

;  Version     2.00
;  Date        01/07/90
;  Programmer  Dima Stefankov

    INCLUDE  TPCOMMON.INC

    DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references
		EXTRN   BYTESCHECKSUM : FAR	 ;external routine
;  internal variables

    DATA   ENDS


    CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   CheckRomCard

;  interface  part

    MemorySeg       EQU        SS:[BX+4]

    CheckRomCard    PROC       FAR
               StackFrame    bx                  ;set up stack frame
               push    ds                        ;save DS
               mov     ds,MemorySeg              ;DS = Rom card seg
               Zero    al                        ;assume that fails
               Zero    bx                        ;BX = base
               cmp     WP  [bx],0AA55h           ;check for the ROM ID
               jne     ROM_Done                  ;AL = result done
               push    ds                        ;DS = seg(Card)
               push    bx                        ;BX = ofs(Card)
               mov     cl,[bx+2]                 ;CL = length in 512-byte blocks
               Zero    ch,ch                     ;CX = ...
               mov     ax,512                    ;prepare for multiplication
               mul     cx                        ;DX:AX = result
               push    dx                        ;push a counter
               push    ax
               call    BytesCheckSum             ;get a check sum
               inc     al                        ;add 1
               cmp     al,1                      ;previous result = 0?
               je      ROM_Done                  ;yes, then AL = true
               Zero    al                        ;AL = false
    ROM_Done:
               pop     ds                        ;restore DS
               ret     2                         ;pop parms and exit
    CheckRomCard    ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
