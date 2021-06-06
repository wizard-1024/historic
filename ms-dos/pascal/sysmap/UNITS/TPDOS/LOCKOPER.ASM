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
          EXTRN    DosIO          :  NEAR

   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM


          PUBLIC   LockFile,UnLockFile

;  interface  functions

   LockHandle       EQU         SS:[BX+12]       ;parms
   OfsHi            EQU         SS:[BX+10]
   OfsLo            EQU         SS:[BX+8]
   LenHi            EQU         SS:[BX+6]
   LenLo            EQU         SS:[BX+4]

   LockFile         PROC        FAR
               mov   ax,(FileLock shl 8) + 0      ;Dos function
   L25:        StackFrame   bx                    ;set up stack
               mov   dx,OfsLo                     ;get the offset
               mov   cx,OfsHi
               mov   di,LenLo                     ;get the length
               mov   si,LenHi
               mov   bx,LockHandle                ;load the handle to lock
               call  DosIO                        ;Dos interface
               ret    10                          ;return and pop parms
   LockFile         ENDP

   UnLockFile       PROC        FAR
               mov   ax,(FileLock shl 8) + 1      ;Dos service
               jmp   SHORT  L25                   ;exit through other function
   UnLockFile       ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
