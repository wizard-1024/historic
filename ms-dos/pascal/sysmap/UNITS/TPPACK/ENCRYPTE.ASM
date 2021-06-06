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

          PUBLIC   EncryptE

;  interface  part

     Buffer	  EQU	       SS:[BX+6]
     COUNT	  EQU	       SS:[BX+4]

     EncryptE     PROC         FAR
               StackFrame    bx                  ;set up stack frame
               push    ds                        ;save DS
               cld                               ;go forward
               mov     cx,Count                  ;bytes counter
               jcxz    L19                       ;if zero,done
               lds     si,Buffer                 ;pointer
               les     di,Buffer
    L18:
               lodsb                             ;get a byte
               rol     al,1                      ;rotate to left
               rol     al,1
               stosb                             ;put a back
               loop    L18                       ;repeat until done
    L19:
               pop     ds                        ;restore DS
               ret     6                         ;remove parms and returm
    EncryptE      ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
