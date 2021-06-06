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

          PUBLIC   SwapBuffers                   ;public declarations

;  interface  part

    Source                 EQU          SS:[BX+10]
    Destination		   EQU		SS:[BX+6]
    Count                  EQU          SS:[BX+4]

    SwapBuffers           PROC          FAR
               StackFrame    bx                  ;set up stack frame
               mov     dx,ds			 ;save DS
               mov     cx,Count                  ;bytes counter
	       jcxz    L6			 ;if zero,done
               lds     si,Source                 ;load pointers
	       les     di,Destination
	       cld				 ;go forward
               shr     cx,1
               jcxz    L5A                       ;swap only 1 byte
               pushf
    L5:
               mov     ax,[si]                   ;get the words
               xchg    ax,es:[di]
               mov     [si],ax                   ;now swapping
               add     si,2                      ;update pointers
               add     di,2
               loop    L5                        ;repeat till done
               popf
               jnc     L6
    L5A:
               mov     al,[si]                   ;swap the last byte
               xchg    al,es:[di]
               mov     [si],al
    L6:
               mov     ds,dx                     ;restore DS
               ret     10                        ;remove parms and returm
    SwapBuffers           ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
