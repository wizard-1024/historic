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

          PUBLIC   UnPack

;  interface  part

     SourceBuf    EQU         SS:[BX+8]
     DestBuf	  EQU	      SS:[BX+4]

     Unpack       PROC        FAR
              StackFrame   bx
	      push   ds
              cld
	      lds    si,SourceBuf
	      les    di,DestBuf
	      Zero   cx
	      cld
     P4:
	      lodsb
	      or     al,al
	      jz     p5
	      mov    cl,al
	      lodsb
	      rep    stosb
	      jmp    SHORT   P4
     P5:
	      pop    ds
	      ret    8
     Unpack       ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
