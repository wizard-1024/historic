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

   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   FindNext

;  interface  functions

   SearchRecord    EQU          SS:[BX+4]

   FindNext        PROC         FAR
              StackFrame   bx                    ;set up stack
              push   ds                          ;save DS
              lds    dx,SearchRecord             ;load the info buffer
              mov    ah,FNext                    ;Dos service
              call    DosControl                 ;call Dos
              pop    ds                          ;recover DS
              call   DosError		         ;check for errors
              ret    4                           ;return and pop parameter
   FindNext        ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
