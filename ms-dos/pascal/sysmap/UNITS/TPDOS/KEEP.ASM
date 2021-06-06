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

   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   Keep

;  interface  functions

   TSRcode         EQU          SS:[BX+4]

   Keep            PROC         FAR
              StackFrame   bx                    ;set up stack
              mov    es,PrefixSeg                ;get PSP address
              mov    ax,es                       ;save it
              mov    dx,WP es:[TopMem]           ;get the memory top
              sub    dx,ax                       ;calculate resident part
              mov    ax,TSRcode                  ;get the return code
              mov    ah,TSR                      ;Dos function
              call    DosControl                 ;call Dos
   Keep            ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
