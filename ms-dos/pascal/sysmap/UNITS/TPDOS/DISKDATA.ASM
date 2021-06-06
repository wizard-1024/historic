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

          PUBLIC   DiskSize,DiskFree

;  interface  functions

   DiskDrive       EQU        SS:[BX+4]          ;drive parm

   DiskFree        PROC       FAR
                 StackFrame   bx                 ;set up stack
                 mov     dx,DiskDrive            ;get the drive
                 mov     ah,DiskSpace            ;Dos function
                 call    DosControl              ;call Dos
   L4:
                 cmp     ax,ErrorCode            ;drive invalid?
                 jne     L5                      ;no, then continue
                 stc                             ;set the error flag
                 mov    ax,InvalidData           ;put the error code
                 jmp    SHORT  L5A               ;exit
   L5:
                 mul     cx                      ;(bytes * sectors) in cluster
                 mul     bx                      ;free clusters * bytes
                 clc                             ;no errors
   L5A:          call	DosError		 ;check for errors
                 ret     2                       ;return and pop parms
   DiskFree        ENDP

;  interface  procedures

   DiskSize        PROC       FAR
                 StackFrame   bx                 ;set up stack
                 mov     dx,DiskDrive            ;get the drive
                 mov     ah,DiskSpace            ;Dos function
                 call    DosControl              ;call Dos
                 mov     bx,dx                   ;get the total size
                 jmp     SHORT  L4               ;exit
   DiskSize        ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
