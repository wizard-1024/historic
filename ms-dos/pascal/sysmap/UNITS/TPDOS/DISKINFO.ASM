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

          PUBLIC   DiskInfo

;  interface  functions

   DriveForInfo    EQU          SS:[SI+8]        ;undocumented function
   DiskBlock       EQU          SS:[SI+4]

   DiskInfo        PROC         FAR
              StackFrame    si                   ;set stack frame
              push      ds                       ;save DS
              mov       dx,DriveForInfo          ;get the drive
              mov       ah,GetDriveInfo          ;Dos function
              call       DosControl              ;call Dos
              clc                                ;assume no error
              BooleanResult   al                 ;check for zero
              jz        L22                      ;no error then exit
              stc                                ;set the error flag
              mov    ax,InvalidData              ;put the error code
              jmp    SHORT   L23                 ;exit with error
   L22:
              les       di,DiskBlock             ;pointer to record
              mov       si,bx                    ;get the offset
              mov       cx,1Ch                   ;length of block
              rep       movsb                    ;move the info
   L23:
              pop       ds                       ;restore DS
              call   DosError                    ;check for errors
              ret	6                        ;return and pop parms
   DiskInfo        ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
