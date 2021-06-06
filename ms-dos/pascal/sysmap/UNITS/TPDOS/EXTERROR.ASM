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

          PUBLIC  ExtendedError

;  interface  functions

   DosErrorCode    EQU          SS:[SI+16]
   ErrorClass      EQU          SS:[SI+12]
   SuggestedClass  EQU          SS:[SI+8]
   Locus           EQU          SS:[SI+4]

   ExtendedError   PROC         FAR
              StackFrame    si                   ;set stack frame
              push      ds                       ;save environment
              push      bp
              push      si
              mov       ah,GetDosError
              call       DosControl              ;call Dos
              pop       si
              les       di,DosErrorCode          ;load the proper pams
              mov       es:[di],ax
              les       di,ErrorClass            ;load the proper pams
              mov       BYTE PTR es:[di],bh
              les       di,SuggestedClass        ;load the proper pams
              mov       BYTE PTR es:[di],bl
              les       di,Locus                 ;load the proper pams
              mov       BYTE PTR es:[di],ch
              pop       bp                       ;restore a environment
              pop       ds
              ret	16                       ;return and pop parms
   ExtendedError   ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
