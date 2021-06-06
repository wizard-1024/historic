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

          PUBLIC   GetFAttr

;  interface  functions

   Attribute       EQU       SS:[BX+2]           ;parms
   NameToAttr      EQU       SS:[BX+6]

   GetFAttr        PROC      NEAR
                 StackFrame   bx                 ;set up stack
                 mov       ax,(CHMOD shl 8) + 0
                 push      ds                    ;save DS
                 lds       dx,NameToAttr         ;load the pointer to name
                 call       DosControl           ;call Dos
                 pop       ds                    ;restore DS
                 call	DosError		 ;check for errors
		 les	   di,Attribute		 ;load a ptr
                 mov       es:[di],cx            ;save the attributes
                 ret       8                     ;return and pop parms
   GetFAttr        ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
