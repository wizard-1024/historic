
;  Version  2.00
;  Date     01/09/90
;  Programmer  Dima Stefankoff

;  common equates

   false           EQU       0                   ;boolean equates
   true            EQU       1

   WP              EQU       <WORD PTR>          ;string equates
   DP		   EQU       <DWORD PTR>

;   TpKbd

   BiosKbd         EQU       16h                 ;BIOS service
   ReadChar        EQU       0                   ;functions
   CharAvail       EQU       1
   GetStatus       EQU       2
   SetRate         EQU       0305h
   PutKey          EQU       5
   ExtReadChar     EQU       10h
   ExtCharAvail    EQU       11h
   ExtGetStatus    EQU       12h
   CtrlState       EQU       4
   CtrlC           EQU       3

;   TpClock

   PCTimerInt      EQU       08h                ;8253 timer tick
   BiosTimer       EQU       1Ah                 ;BIOS service
   SetTimer        EQU       1                   ;functions
   ReadTimeAT      EQU       2                   ;RTC for AT
   SetTimeAT       EQU       3
   ReadDateAT      EQU       4
   SetDateAT       EQU       5
   SetAlarm        EQU       6
   ResetAlarm      EQU       7

;  TpComm

   BiosComm        EQU       14h                 ;BIOS service
   OutChar         EQU       1                   ;functions
   InitPort        EQU       0
   InChar          EQU       2
   GetCommStatus   EQU       3

;  TpDisk

   BiosDisk        EQU       13h                 ;BIOS service

;    TpDos

   InvalidData     EQU       0Bh                 ;Dos error 13d
   ErrorCode	   EQU	     0FFFFh
   StartYear       EQU       1980                ;Dos appearence year
   BlockSize       EQU       3                   ;offset in DOS Mem Ctrl Block
   TopMem          EQu       2                   ;offset in PSP
   EnvPtr          EQU       2Ch                 ;offset in PSP
   ShellSeg        EQU       10h                 ;offset in PSP
   EqualSign       EQU       '='                 ;Ascii char
   CR              EQU	     0Dh                 ;carraige return
   MaxLenOfEnv     EQU       32768               ;32K for Dos environment
   MsDos	   EQU       21h                 ;Dos funcion dispatcher
   TrueMsDos       EQU       65h                 ;also Dos function dispatcher
   DosRead         EQU       25h                 ;absolute disk control
   DosWrite        EQU       26h

   Select          EQU       0Eh                 ;Dos functions
   CurrentDrive    EQU       19h
   SetDTAbuffer    EQU       1Ah
   SetVector       EQU       25h
   Parse           EQU       29h
   GetSysDate      EQU       2Ah
   SetSysDate      EQU       2Bh
   GetSysTime      EQU       2Ch
   SetSysTime      EQU       2Dh
   VerifySwitch    EQU       2Eh
   GetDTAbuffer    EQU       2Fh
   GetVersion      EQU       30h
   TSR             EQU       31h
   GetDriveInfo    EQU       32h
   DosCBreak       EQU       33h
   DosActiveFlag   EQU       34h
   GetVector       EQU       35h
   DiskSpace       EQU       36h
   SwitchChar      EQU       37h
   CreateDir	   EQU	     39h
   RemDir	   EQU	     3Ah
   ChDir	   EQU	     3Bh
   Create	   EQU	     3Ch
   Open		   EQU	     3Dh
   Close	   EQU	     3Eh
   Read		   EQU	     3Fh
   Write	   EQU	     40h
   Unlink	   EQU	     41h
   LSeek           EQU       42h
   CHMOD           EQU       43h
   GetDir	   EQU	     47h
   AllocMem        EQU       48h
   FreeMem         EQU       49h
   ModifyMem       EQU       4Ah
   Exec	           EQU	     4Bh
   TerminateProg   EQU       4Ch
   GetExitCode	   EQU	     4Dh
   FindFirst       EQU       4Eh
   FNext           EQU       4Fh
   GetVerifySwitch EQU       54h
   RenameFile	   EQU	     56h
   FileTimeDate    EQU       57h
   MemAllocCode    EQU       58h
   GetDosError     EQU       59h
   TempFile        EQU       5Ah
   NewFile         EQU       5Bh
   FileLock        EQU       5Ch
   GetPSPaddr      EQU       62h

;   TpExtend

   ATbios          EQU       15h                 ;BIOS service

;  TpMouse

   Mouse           EQU       33h                 ;Mouse interface driver

;   TpPrint

   BiosPrint       EQU       17h                 ;BIOS service
   OutChar17       EQU       0                   ;functions
   InitPort17      EQU       1
   GetStatus17     EQU       2

;    TpCrt

   Video           EQU       10h                 ;BIOS service
   TurboBlink      EQU       16
   Blink           EQU       128
   BiosDataSegment EQU	     40h
   TimerLow	   EQU	     6Ch

   XLow            =         (BYTE PTR 0)
   YLow            =         (BYTE PTR 1)
   XHigh           =         (BYTE PTR 0)
   YHigh           =         (BYTE PTR 1)

   LF              EQU       10                  ;ASCII chars
   CR              EQU       13

;  8255-A ports

   PPI_B           =          61h

;  8253-5 ports

   Timer_Ctrl      =          43h
   Timer2          =          42h

   OneDelayMS      =          614

;  common macro definitions

    StackFrame     MACRO     reg
                     mov     reg,sp              ;;save SP
   		   ENDM

    StackFrameBP   MACRO
                     push    bp                  ;;emulate 'begin' statement
                     mov     bp,sp
                   ENDM

    ExitCode       MACRO     PopCount
                     mov     sp,bp
                     pop     bp
                     ret     PopCount
                   ENDM

    Zero           MACRO     reg
                     sub     reg,reg             ;;clear register
                   ENDM

    BooleanResult  MACRO     reg
                     or      reg,reg             ;;check for zero
                   ENDM

    PutCylinder    MACRO     Cylinder
                     mov     dx,Cylinder         ;;load a parameter
                     mov     ch,dl               ;;save a low part
                     mov     cl,6                ;;load a shifter
                     shl     dh,cl               ;;bits 0-1 to 6-7
                     mov     cl,dh               ;;CX = track now
                   ENDM

    SeekMode       MACRO     submode
                     mov     ax,(Lseek shl 8) + submode
                   ENDM

    NullJump       MACRO
                     jmp     SHORT  $+2
                   ENDM

    DosCall        MACRO     DosFuncNum
                     mov     ah,DosFuncNum
                     int     MsDos
                   ENDM

    DosCallAX      MACRO     AXvalue
                     mov     ax,AXvalue
                     int     MsDos
                   ENDM

    JmpFar         MACRO     JAddr
                     jmp     DD  JAddr
                   ENDM

    CallFar        MACRO     CAddr
                     call    DD  CAddr
                   ENDM

    VideoPrim      MACRO
                     push    bp
                     push    si
                     push    di
                     int     Video
                     pop     di
                     pop     si
                     pop     bp
                   ENDM

    VideoCall      MACRO     VidService
                     mov     ah,VidService
                     VideoPrim
                   ENDM

    VideoCallAX    MACRO     VidServiceAX
                     mov     ax,VidServiceAX
                     VideoPrim
                   ENDM

    KbdCall        MACRO     func
                     mov     ah,func
                     int     BiosKbd
                   ENDM

    EmsCall        MACRO    EmsFunction
                     mov    ah,EmsFunction
                     int    67h
                   ENDM

    EmsWordResult  MACRO    RegName
                   LOCAL   EWRexit
                     BooleanResult  AH
                     mov    ax,RegName
                     jz     EWRexit
                     mov    ax,ErrorCode
    EWRexit:
                   ENDM

    EmsByteResult  MACRO    RegName
                   LOCAL    EBexit
                   BooleanResult  AH
                   jz       EBexit
                   Zero     ax
    EBexit:
                   ENDM

    EmsBoolean     MACRO    RegName
                   LOCAL    EBexit1
                   cmp      ah,0
                   mov      ax,1
                   jz       EBexit1
                   dec      ax
    EBexit1:
                   BooleanResult al
                   ENDM

;  structure definitions

   Pointer      STRUC
           Ofst    DW    0
           Segm    DW    0
   Pointer      ENDS
