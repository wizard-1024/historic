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

          PUBLIC   ReadCMOS                      ;public declarations

;  interface  part

    CMOSport            EQU             SS:[BX+4]

    ReadCMOS            PROC            FAR
              StackFrame   bx                   ;set up stack frame
              mov      ax,CMOSport              ;AL = CMOS RAM index
              or       al,80h                   ;NMI off
              cli
              out      70h,al                   ;write to CMOS
              NullJump                          ;delay i/o
              NullJump
              NullJump
              in      al,71h                    ;AL = data from port
              sti
              ret      2                        ;remove parms & exit
    ReadCMOS            ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
