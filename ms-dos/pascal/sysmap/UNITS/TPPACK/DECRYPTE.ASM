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

          PUBLIC   DecryptE

;  interface  part

     Buffer	  EQU	       SS:[BX+6]
     COUNT	  EQU	       SS:[BX+4]

     DecryptE     PROC         FAR
               StackFrame    bx                  ;set up stack frame
               push    ds                        ;save DS
               cld                               ;go forward
               mov     cx,Count                  ;bytes counter
               jcxz    L21                       ;if zero, done
               lds     si,Buffer                 ;pointer
               les     di,Buffer
    L20:
               lodsb                             ;get a byte
               ror     al,1                      ;rotate to right
               ror     al,1
               stosb                             ;put a back
               loop    L20                       ;repeat until done
    L21:
               pop     ds                        ;restore DS
               ret     6                         ;remove parms and returm
    DecryptE      ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
