                   PAGE   59,132
                   TITLE  External assembly routines for TpMath Unit

;  Version  1.0
;  Date     4/22/89
;  Programmer  Dmitri V. Stefankov

;  NOTE:    This file must be assembled with MASM's /R command line option

   INCLUDE  TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

;  internal variables

   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   Save8087                      ;public declarations
          PUBLIC   Restore8087
	  PUBLIC   Installed8087
          PUBLIC   Exceptions8087
          PUBLIC   Error8087


;  interface  part


    SaveBuf	EQU	DWORD PTR SS:[BX+4]

    Save8087	PROC      FAR
            StackFrame    bx		;Set up	stack frame
            LES	   DI,SaveBuf		;Point to save buffer
            FSAVE	ES:[DI]		;Save contents of 8087 registers
            WAIT			;Wait
            RET	   4			;Remove	parameter and return
    Save8087	ENDP

    Restore8087	PROC FAR
            StackFrame	  bx		;Set up	stack frame
            LES	  DI,SaveBuf		;Point to save buffer
            FRSTOR	ES:[DI]		;Restore contents of 8087 registers
            WAIT			;Wait
            RET	   4			;Remove	parameter and return
    Restore8087	ENDP

    Installed8087	PROC FAR
            StackFrame   bx		;Set up	stack frame
            FNINIT			;Initialize co-processor
            Zero	AX		;Assume	false
            PUSH	AX		;SS:[BX-2] = 0
            FNSTCW	SS:[BX-2]	;store control word
            CMP	  BYTE PTR SS:[BX-1],3	;upper byte is 3 if math chip installed
            JNE	  Done			;If not	3, no math chip	installed
            INC	  AX			;AX = 1	(True)
    Done:
            BooleanResult  al		;Set zero flag
            MOV	   SP,BX		;Restore the stack
            RET				;Return
    Installed8087	ENDP

    OnOff       EQU      BYTE PTR [BP+6]
    CtrlWord    EQU      WORD PTR [BP-2]

    Exceptions8087	 PROC FAR
            StackFrameBP		;Set up stack	frame
            MOV	  AL,OnOff
            OR	  AL,AL
            JZ	  ExceptionsOff
            MOV	  CtrlWord,0372H	;Unmask IM,ZM,OM
            JMP   SHORT   ExceptionsDone
    ExceptionsOff:
            FSTCW	CtrlWord	;Get current control word
            OR	   CtrlWord,00FFh	;Mask	all exceptions
    ExceptionsDone:
            FLDCW	CtrlWord	;Change 8087 control word
            ExitCode    2
    Exceptions8087	 ENDP

    StatWord EQU WORD PTR [BP-2]

    Error8087   PROC        FAR
            StackFrameBP		;Set up stack	frame
            FSTSW   StatWord	        ;Get current status word
            MOV	    AX,StatWord		;Return in AX
            AND	    AX,03Fh		;Just	the exception indicators
            FCLEX			;Clear exception indicators
            ExitCode   0
    Error8087   ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END



