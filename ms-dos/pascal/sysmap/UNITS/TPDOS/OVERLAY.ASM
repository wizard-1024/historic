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


          PUBLIC   OverlayProgram

;  interface  functions

   OverlayPath      EQU         SS:[SI+2]

   OverlayProgram   PROC        NEAR
                StackFrame   si                   ;set up stack
                push  bp
                mov   ax,ds                       ;set the pointer to param block
                mov   es,ax
                mov   bx,OFFSET OvBlock
                cli                               ;save a stack info
                mov   OldSS,ss
                mov   OldSP,sp
                sti
                lds   dx,OverlayPath              ;load the file path
                mov   ax,(Exec shl 8) + 3;        ;load a overlay
                call   DosControl                 ;call Dos
		mov   dx,Data			  ;restore DS
		mov   ds,dx
                cli
                mov   ss,OldSS                    ;restore a program stack
                mov   sp,OldSP
                sti
                pop   bp                          ;restore a environment
                call  DosError		          ;check for errors
                ret   4                           ;return and pop parms
   OverlayProgram   ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
