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
          EXTRN    DosError       :  NEAR
          EXTRN    DosVersion     :  FAR

;  internal variables
          PACKET   LABEL    BYTE
              DW  ?         ; +0
              DW  ?         ; +2
              DW  ?         ; +4
              DW  ?         ; +6
              DW  ?         ; +8

   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM


          PUBLIC   DosAbsoluteRead,DosAbsoluteWrite

;  interface  functions

   DosDrive        EQU          SS:[SI+14]
   SecsNum         EQU          SS:[SI+12]
   StartSecHi      EQU          SS:[SI+10]
   StartSecLo      EQU          SS:[SI+8]
   MemBuffer       EQU          SS:[SI+4]

   GetParms        PROC         NEAR
              call   DosVersion                  ;get Dos version
              cmp    ax,031Fh                    ;version < 3.31?
              jb     DosOld
              cmp    ah,10                       ;version >= 10.0 (OS/2)?
              jae    DosOld
              mov    bx,OFFSET Packet
              mov    cx,StartSecLo               ;starting sector
              mov    0[bx],cx
              mov    cx,StartSecHi
              mov    2[bx],cx
              mov    cx,SecsNum                  ;sector count
              mov    4[bx],cx
              mov    cx,0FFFFh                   ;extended sign
              les    dx,MemBuffer                ;memory buffer address
              mov    6[bx],dx
              mov    8[bx],es
              mov    ax,DosDrive                 ;get the drive
              jmp    SHORT  DosLoad
   DosOld:
              mov    ax,DosDrive                 ;get the drive
              mov    cx,SecsNum                  ;load the sectors count
              mov    dx,StartSecLo               ;beginning sector
              lds    bx,MemBuffer                ;memory buffer
   DosLoad:
              ret                                ;return near
   GetParms        ENDP

   DosAbsoluteRead PROC         FAR
              StackFrame   si                    ;set up stack
              push   ds                          ;save a environment
              push   bp
              call   GetParms                    ;load the parms
              int    DosRead                     ;call Dos service
              pop    dx                          ;discard flags on stack
              pop    bp                          ;restore a environment
              pop    ds
              call   DosError		         ;check for errors
              ret    12                          ;return and pop parms
   DosAbsoluteRead ENDP

   DosAbsoluteWrite PROC        FAR
              StackFrame    si                   ;set up stack
              push   ds                          ;save a environment
              push   bp
              call   GetParms                    ;load the parms
              int    DosWrite                    ;call Dos service
              pop    dx                          ;discard flags on stack
              pop    bp                          ;restore a environment
              pop    ds
              call   DosError		         ;check for errors
              ret    12                          ;return and pop parms
   DosAbsoluteWrite ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
