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

          PUBLIC   Pack

;  interface  part

     Buf1         EQU       SS:[BX+10]
     Buf2	  EQU	    SS:[BX+6]
     CharToPack   EQU	    SS:[BX+4]

     Pack         PROC      FAR
	      StackFrame   bx                   ;set up stack frame
	      push    ds
              cld                               ;go forward
	      lds     si,Buf1
	      les     di,Buf2
	      mov     dx,CharToPack
	      mov     cx,dx
	      jcxz    P4
	      cld
	      lodsb
	      mov     bl,al
	      Zero    cx
     P1:
	      lodsb
	      inc     cx
	      sub     dx,1
	      jz      P3
	      cmp     cx,255
	      jne     P2
	      mov     es:[di],cl
	      inc     di
	      Zero    cx
	      mov     es:[di],bl
	      inc     di
     P2:
	      cmp     al,bl
	      je      P1
	      mov     es:[di],cl
	      Zero    cx
	      inc     di
	      mov     es:[di],bl
	      inc     di
	      mov     bl,al
	      jmp     SHORT  P1
     P3:
	      mov     al,cl
	      stosb
	      mov     al,bl
	      stosb
	      Zero    al
	      stosb
     P4:
	      pop     ds
	      ret     10
     Pack         ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
