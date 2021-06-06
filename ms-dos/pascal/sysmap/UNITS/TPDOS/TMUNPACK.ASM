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

          PUBLIC   UnPackTime

;  interface  functions

   DateHi          EQU        SS:[SI+10]         ;parms
   TimeLo	   EQU	      SS:[SI+8]
   TimePtr	   EQU	      SS:[SI+4]

   UnPackTime      PROC       FAR
		 StackFrame   si                 ;set up stack
		 cld				 ;forward direction
		 les    di,TimePtr		 ;get the structure ptr
		 mov	ax,DateHi		 ;get the packed date
		 mov	bx,ax			 ;save it
		 mov	cl,9			 ;load the shift
		 shr	ax,cl			 ;shift to right
		 add	ax,StartYear		 ;add offset
		 stosw				 ;store a year
		 mov	ax,bx                    ;get time back
		 mov    cl,5                     ;load the shift
		 shr	ax,cl                    ;shift to right
		 and	ax,0Fh			 ;isolate bits 0-3
		 stosb				 ;store the month
		 mov	ax,bx                    ;get time back
		 and	ax,1Fh			 ;isolate bits 0-4
		 stosb				 ;store the day
		 mov    ax,TimeLo		 ;get the packed time
		 mov	bx,ax			 ;save it
		 mov	cl,11			 ;load the shifter
                 shr	ax,cl			 ;shift to right
		 stosb				 ;store a hour
		 mov	ax,bx                    ;get data back
		 mov    cl,5                     ;load the shift
		 shr	ax,cl                    ;shift to right
		 and	ax,3Fh			 ;isolate bits 0-5
		 stosb				 ;store the minute
		 mov	ax,bx                    ;get time back
		 and	ax,1Fh			 ;isolate bits 0-4
		 stosb				 ;store the second
                 ret    8                        ;return and pop parameters
   UnPackTime      ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
