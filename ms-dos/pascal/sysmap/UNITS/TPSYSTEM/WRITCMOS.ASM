                   PAGE   59,132
                   TITLE  External assembly routines for TpSystem Unit

;  Version     2.00
;  Date        12/06/90
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

          PUBLIC   WriteCMOS                     ;public declarations

;  interface  part

    CMOSdata            EQU             SS:[BX+4]
    CMOSindex           EQU             SS:[BX+6]

    WriteCMOS           PROC            FAR
              StackFrame   bx                   ;set up stack frame
              mov      ax,CMOSdata              ;AL = CMOS RAM data
              mov      ah,al                    ;AH = data
              mov      al,bptr CMOSindex        ;BX = data port
              or       al,80h                   ;NMI off
              cli
              out      70h,al                   ;write to CMOS
              NullJump                          ;delay i/o
              NullJump
              NullJump
              mov     al,ah
              out      71h,al                   ;AL = data from port
              sti
              ret      4                        ;remove parms & exit
    WriteCMOS            ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
