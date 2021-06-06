                   PAGE   59,132
                   TITLE  External assembly routines for TpKbd Unit

;  Version     1.10
;  Date        01/09/91
;  Programmer  Dima Stefankov

   INCLUDE   TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references
          EXTRN    ReadKey        :   FAR
          EXTRN    KeyPressed     :   FAR

;  internal variables
   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   ReadKeyTimeSlice

;  interface  part

    ReadKeyTimeSlice    PROC         FAR
    L1:
                  int      28h                   ;help keep popups from locking out other TSR's
                  call     KeyPressed            ;key pressed?
                  cmp      al,false              ;no?
                  je       L1                    ;then wait
                  call     ReadKey               ;else read a char
                  ret                            ;return far
    ReadKeyTimeSlice    ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
