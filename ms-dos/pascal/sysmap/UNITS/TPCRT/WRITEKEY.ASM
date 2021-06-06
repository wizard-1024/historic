                   PAGE   59,132
                   TITLE  External assembly routines for TpKbd Unit

;  Version     1.00
;  Date        01/06/90
;  Programmer  Dima Stefankov

   INCLUDE   TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

;  internal variables

   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   WriteKey

;  interface  part

    Result          EQU      SS:[BX+4]
    AsciiCode       EQU      SS:[BX+8]
    ScanCode        EQU      SS:[BX+10]

    WriteKey        PROC     FAR
                StackFrame  bx                   ;set up stack frame
                mov       ch,ScanCode            ;put a scan code
                mov       cl,AsciiCode           ;put a ASCII code
                mov       ah,PutKey              ;load the function
                int       BiosKbd                ;call BIOS
                les       di,Result              ;get a ptr to value
                mov       es:[di],al             ;save a boolean value
                ret       8                      ;return and pop parms
    WriteKey        ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
