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

          PUBLIC   SetTime

;  interface  functions

   RecordPtr       EQU       SS:[BX+4]           ;pointer to structure

   SetTime         PROC      FAR
                 StackFrame   bx                 ;set up stack
                 mov    ah,SetSysTime            ;Dos function
                 les    bx,RecordPtr             ;get the pointer
                 mov    ch,es:0[bx]              ;set the hour
                 mov    cl,es:1[bx]              ;set the minute
                 mov    dh,es:2[bx]              ;set the second
                 mov    dl,es:3[bx]              ;set the hundreths
                 call    DosControl              ;call Dos
                 BooleanResult   al              ;boolean zero
                 clc                             ;assume no errors
                 jz     L2                       ;no error then exit
                 stc                             ;set the error flag
                 mov    ax,InvalidData           ;put the error code
   L2:
                 call	DosError		 ;check for errors
                 ret    4                        ;return and pop parameter
   SetTime         ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
