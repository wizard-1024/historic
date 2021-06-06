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

          PUBLIC   PackTime

;  interface  functions

   TimeRecordPtr   EQU        SS:[BX+8]          ;parameters
   TimeVar         EQU        SS:[BX+4]

   PackTime        PROC       FAR
                 StackFrame   bx                 ;set up stack
                 push   ds                       ;save DS
                 les    di,TimeVar               ;get the destination ptr
		 lds    si,TimeRecordPtr         ;load the source ptr
		 cld				 ;set the forward direction
                 Zero   ax                       ;AX = will be stored result
		 lodsw                           ;get the year
		 sub    ax,StartYear		 ;AX = Year - 1980
                 mov    bx,ax                    ;BX = year now
                 lodsb                           ;get the month
		 mov    cl,4                     ;load the shift
                 shl    bx,cl                    ;left shift
                 or     bx,ax                    ;pack month
                 lodsb                           ;get the day
                 mov    cl,5                     ;load the shift
                 shl    bx,cl                    ;left shift
                 or     bx,ax                    ;pack day
		 mov	es:2[di],bx		 ;save the date
                 Zero   ax                       ;AX = will be stored result
                 lodsb                           ;get the hour
                 mov    bx,ax                    ;BX = hour now
                 lodsb                           ;get the minute
                 mov    cl,6                     ;load the shift
                 shl    bx,cl                    ;left shift
                 or     bx,ax                    ;pack minute
                 lodsb                           ;get the second
                 mov    cl,5                     ;load the shift
                 shl    bx,cl                    ;left shift
		 or     bx,ax                    ;pack second
		 mov	es:[di],bx		 ;save the date
                 pop    ds                       ;recover DS
                 ret    8                        ;return and pop parameters
   PackTime        ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
