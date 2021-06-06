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

          PUBLIC  ReadFileVar,ReadFile
          PUBLIC  WriteFileVar,WriteFile

;  interface  functions

   FileHandle      EQU       WP  SS:[SI+14]      ;parameters
   Buffer	   EQU       DP	 SS:[SI+10]
   Count           EQU       WP  SS:[SI+8]
   Result          EQU       DP  SS:[SI+4]

   ReadFileVar     PROC      FAR
   ReadFile        PROC      FAR
                mov     ah,Read                  ;read the handle
   FileIO:      StackFrame   si                  ;set up stack
                call    HandleIO                 ;handle interface
  		ret     12                       ;return and pop parms
   ReadFile	   ENDP
   ReadFileVar     ENDP

   WriteFileVar    PROC      FAR
   WriteFile       PROC      FAR
                mov     ah,Write                 ;read the handle
                jmp     SHORT  FileIO            ;jump to next action
   WriteFile       ENDP
   WriteFileVar    ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
