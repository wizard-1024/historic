                   PAGE   59,132
                   TITLE  External assembly routines for TpDos Unit

;  Version     2.0
;  Date        01/07/90
;  Programmer  Dima Stefankov

   INCLUDE  TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

          EXTRN    InOutRes       :  WORD        ;i/o operation result
          EXTRN    FileMode       :  BYTE        ;file mode to open
          EXTRN    SaveInt00      :  WORD        ;pointer to interrupt vectors
          EXTRN    PrefixSeg      :  WORD        ;segment of PSP
          EXTRN    UpCaseString   :  FAR         ;TpString Unit
          EXTRN    ExecBlock      :  WORD        ;exec parameter block
          EXTRN    OvBlock        :  WORD        ;overlay param block
	  EXTRN	   OldSS	  :  WORD	 ;stack info
	  EXTRN	   OldSP	  :  WORD
          EXTRN    UseTrueDos     :  BYTE
          EXTRN    DosControl     :  NEAR
          EXTRN    DosError       :  NEAR
          EXTRN    DosIO          :  NEAR
          EXTRN    SaveHandle     :  NEAR
          EXTRN    HandleIO       :  NEAR
          EXTRN    MoveString     :  NEAR

   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   SetDate

;  interface  functions

   RecordPtr       EQU       SS:[BX+4]           ;pointer to structure

   SetDate         PROC      FAR
                 StackFrame   bx                 ;set up stack
                 mov    ah,SetSysDate            ;Dos function
                 les    bx,RecordPtr             ;set the pointer
                 mov    cx,es:0[bx]              ;set the word
                 mov    dh,es:2[bx]              ;set the month
                 mov    dl,es:3[bx]              ;set the day
   L3:           call    DosControl              ;call Dos
                 BooleanResult   al              ;boolean zero
                 clc                             ;assume no errors
                 jz     L2                       ;no error then exit
                 stc                             ;set the error flag
                 mov    ax,InvalidData           ;put the error code
   L2:
                 call	DosError		 ;check for errors
                 ret    4                        ;return and pop parameter
   SetDate         ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
