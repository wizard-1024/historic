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

          PUBLIC   FileSize

;  interface  functions

   HandleToPos     EQU       SS:[SI+4]

   FileSize        PROC      FAR
                 StackFrame  si                  ;set up stack frame
                 SeekMode    1                   ;move from current pos.
                 mov    bx,HandleToPos           ;get the handle
                 Zero   cx                       ;CX = 0
                 Zero   dx                       ;DX = 0
                 call   DosIO                    ;Dos interface
                 mov    si,dx                    ;save the returning info
                 mov    di,ax
                 SeekMode    2                   ;seek from the file end
                 Zero   cx                       ;CX = 0
                 Zero   dx                       ;DX = 0
                 call   DosIO                    ;Dos interface
                 jc     L1                       ;if error the exit
                 push   dx                       ;save the file length
                 push   ax
                 SeekMode    0                   ;start from current pos.
                 mov    cx,si                    ;restore the previos
                 mov    dx,di                    ;position in the file
                 call    DosControl              ;call Dos
                 pop    ax                       ;get the length back
                 pop    dx
   L1:
                 ret    2                        ;return and pop parameter
   FileSize        ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
