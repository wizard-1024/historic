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
          EXTRN    SetDTA         :  FAR

   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   FindFirstEntry

;  interface  functions

   PathName        EQU          SS:[BX+8]        ;parms
   AttrToSearch    EQU          SS:[BX+6]
   SearchBuffer    EQU          SS:[BX+2]

   FindFirstEntry  PROC         NEAR
              StackFrame   bx                    ;set up stack
              push   ds                          ;save DS
              les    di,SearchBuffer             ;load the buffer pointer
              push   bx                          ;save BX
              push   es                          ;push into stack
              push   di
              call   SetDTA                      ;DTA buffer = our buffer
              pop    bx                          ;restore BX
              lds    dx,PathName                 ;load the pathname pointer
              mov    cx,AttrToSearch             ;load attributes
              mov    ah,FindFirst                ;Dos function
              call    DosControl                 ;call Dos
              pop    ds                          ;restore DS
              call	DosError		 ;check for errors
              ret    10                          ;return and pop parameters
   FindFirstEntry  ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
