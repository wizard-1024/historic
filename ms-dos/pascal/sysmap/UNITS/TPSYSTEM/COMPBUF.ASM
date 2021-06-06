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

          PUBLIC   CompareBuffers                ;public declarations
          PUBLIC   ComparePtrBuffers

;  interface  part

    Source                 EQU          SS:[BX+10]
    Destination		   EQU		SS:[BX+6]
    Count                  EQU          SS:[BX+4]

    ComparePtrBuffers    PROC         FAR
    CompareBuffers       PROC         FAR
               StackFrame    bx                  ;set up stack frame
               mov     dx,ds			 ;save DS
               mov     cx,Count                  ;bytes counter
	       jcxz    L7			 ;if zero,done
               lds     si,Source                 ;load pointers
	       les     di,Destination
	       cld				 ;go forward
               mov     bx,si                     ;save a start offset
               mov     ax,0FFFFh                 ;assume that fails
               repe    cmpsb                     ;repeat while equal
               je      L7                        ;AX = result
               dec     si                        ;adjust back
               sub     si,bx                     ;find the offset
               mov     ax,si                     ;AX = result
    L7:
               mov     ds,dx                     ;restore DS
               ret     10                        ;remove parms and returm
    CompareBuffers       ENDP
    ComparePtrBuffers       ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
