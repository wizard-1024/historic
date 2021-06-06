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

          PUBLIC   TestOneMemPara

;  interface  part

    MemorySeg       EQU        SS:[BX+4]

    TestOneMemPara  PROC       FAR
               StackFrame    bx                  ;set up stack frame
               push    ds                        ;save DS
               mov     ds,MemorySeg              ;SI = segment to test
               Zero    si
               mov     cx,16                     ;CX = counter
    Test_Continue:
               mov     al,[si]                   ;save a contents
               mov     bl,al                     ;save it
               not     bl                        ;one's complement
               mov     [si],bl                   ;write it
               mov     bl,[si]                   ;read a back
               not     bl                        ;one's complement
               xor     bl,al                     ;make a zero!
               jnz     Mismatch                  ;non-zero then error
               mov     [si],al                   ;write original contents
               inc     si                        ;advance a index
               loop    Test_Continue             ;till done
               mov     al,1                      ;AL = true
               jcxz    Test_End                  ;if CX = 0, done
    Mismatch:
               mov     al,0                      ;AL = false
    Test_End:
               pop     ds                        ;restore DS
               ret     2                         ;remove parms and returm
    TestOneMemPara  ENDP

     IF1
       %OUT    Ending  of  pass 1
     ENDIF
     IF2
       %OUT    Ending  of  pass 2
     ENDIF

     CODE      ENDS
	       END
