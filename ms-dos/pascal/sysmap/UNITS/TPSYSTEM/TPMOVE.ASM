                   PAGE   59,132
                   TITLE  External assembly routines for TpSystem Unit

;  Version  2.00
;  Date     06/27/90
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

          PUBLIC   TpMove	                 ;public declarations

;  interface  part

    Source                 EQU          SS:[BX+10]
    Destination		   EQU		SS:[BX+6]
    Count                  EQU          SS:[BX+4]

    TpMove	          PROC         FAR
               StackFrame    bx                  ;set up stack frame
               mov     dx,ds			 ;save DS
               mov     cx,Count                  ;bytes counter
	       jcxz    L2			 ;if zero,done
               lds     si,Source                 ;load pointers
	       les     di,Destination
	       cld				 ;go forward
	       mov     ax,ds			 ;AX = segment of Source
	       mov     bx,es			 ;BX = segment of Destination
	       sub     ax,bx			 ;calc difference
	       REPT    4
		shl  ax,1			 ;multiply by 16
	       ENDM
	       add     ax,si			 ;add offset of Source
	       sub     ax,di			 ;subtract offset of Destination
	       jns     L1			 ;Source higher than Destination?
	       add     si,cx			 ;find the last byte
	       add     di,cx
	       dec     si			 ;adjust
	       dec     di
	       std				 ;go backward
    L1:
	       rep     movsb			 ;move
               mov     ds,dx                     ;restore DS
    L2:
               ret     10                        ;remove parms and returm
    TpMove	          ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
