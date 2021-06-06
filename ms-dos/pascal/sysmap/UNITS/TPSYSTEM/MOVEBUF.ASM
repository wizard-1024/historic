                   PAGE   59,132
                   TITLE  External assembly routines for TpSystem Unit

;  Version     2.00
;  Date        06/27/90
;  Programmer  Dima Stefankov

    INCLUDE  SYSDEF.INC
    INCLUDE  MACRO.INC

    DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

;  internal variables

    DATA   ENDS


    CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   MoveBuffer                    ;public declarations

;  interface  part

    Src                   EQU           SS:[BX+12]
    Dest                  EQU           SS:[BX+8]
    Counter               EQU           SS:[BX+6]
    MatchChar             EQU           SS:[BX+4]

    MoveBuffer            PROC          FAR
               StackFrame    bx                  ;set up stack frame
               mov     dx,ds			 ;save DS
               mov     cx,Counter                ;load a parms
               jcxz    L4                        ;if zero,done
               lds     si,Src
               les     di,Dest
               mov     bx,MatchChar
               cld                               ;forward
    L3:
               lodsb                             ;get a byte from Src
               stosb                             ;move it to Dest
               cmp     al,bl                     ;is match char?
               je      L4                        ;yes, the done
               loop    L3                        ;repeat till done
    L4:
               mov     ds,dx                     ;restore DS
               ret     10                        ;remove parms and returm
    MoveBuffer            ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
