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


          PUBLIC MakeFile,CreateNewFile

;  interface  functions

   ReturnHandle     EQU         SS:[BX+2]
   AttrToCreate     EQU         SS:[BX+6]
   FilePath         EQU         SS:[BX+8]

   MakeFile         PROC        NEAR
              mov    ah,TempFile                 ;Dos function
   L24:       StackFrame   bx                    ;set up stack
              push   ds                          ;save DS
              mov    cx,AttrToCreate             ;load the attributes
              lds    dx,FilePath                 ;get the full filename
              call    DosControl                 ;call Dos
              pop    ds                          ;recover DS
              call   DosError		         ;check for errors
              les    di,ReturnHandle             ;load the variable addr
              mov    es:[di],ax                  ;save a handle
              ret    10                          ;return and pop parms
   MakeFile         ENDP

   CreateNewFile    PROC        NEAR
              mov    ah,NewFile                  ;Dos function call
              jmp    SHORT  L24                  ;exit through other function
   CreateNewFile    ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
