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

          PUBLIC   Execute

;  interface  functions

   ProgramPath     EQU          SS:[SI+6]
   CommandLine	   EQU	        SS:[SI+2]

   Execute         PROC         NEAR
              StackFrame    si                   ;set stack frame
	      push	bp                       ;save BP
	      les	di,CommandLine           ;add CR to cmd parms line
	      mov	bx,1
	      add	bl,BYTE PTR es:[di]
	      mov	BYTE PTR es:[di+bx],CR
 	      mov	2[ExecBlock],di          ;save pointer to it
	      mov	4[ExecBlock],es
	      mov	ax,ds                    ;set pointer to EXEC block
	      mov	es,ax
	      mov	bx,OFFSET ExecBlock
	      cli
	      mov	OldSS,ss                 ;save the stack info
	      mov	OldSP,sp
	      sti
              lds	dx,ProgramPath
	      mov	ax,(Exec shl 8) + 0      ;EXEC function
	      call   DosControl                  ;call DOS
	      mov   dx,Data			 ;restore DS
	      mov   ds,dx
	      cli
	      mov	ss,OldSS                 ;restore old stack
              mov	sp,OldSp
              sti
              pop	bp                       ;restore environment
              call	DosError                 ;check for errors
              ret	8                        ;return and pop parms
   Execute	   ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
