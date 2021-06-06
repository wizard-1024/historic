                   PAGE   59,132
                   TITLE  External assembly routines for TpExtend Unit

;  Owner    Video Trends Software
;  Version  1.0
;  Date     4/10/89
;  Programmer  Dmitri V. Stefankov

   INCLUDE   TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references
          EXTRN    DiskError     :   BYTE        ;disk error flag
          EXTRN    DiskStatus    :   BYTE        ;disk status var

;  internal variables

   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   ResetDisk                     ;public declarations
          PUBLIC   GetDiskStatus
          PUBLIC   ReadFromDisk
          PUBLIC   WriteToDisk
          PUBLIC   VerifyDisk
          PUBLIC   FormatTrackOnDiskette
          PUBLIC   FormatTrackHardXT
          PUBLIC   FormatTrackHardAT
          PUBLIC   FixedDiskParms
          PUBLIC   DisketteParms
          PUBLIC   InitDiskTable
          PUBLIC   ReadLong
          PUBLIC   WriteLong
          PUBLIC   SeekCylinder
          PUBLIC   AlternateResetDisk
          PUBLIC   TestDriveReady
          PUBLIC   RecalibrateDrive
          PUBLIC   ReadDASDtype
          PUBLIC   ChangeStatusLine
          PUBLIC   SetDASDtype
          PUBLIC   SetMediaType


;   interface  part

    CheckStatus    PROC      NEAR
                mov      DiskStatus,ah           ;save a result of operation
                jc       L1
                mov      DiskError,false         ;success operation
                ret
    L1:
                mov      DiskError,true         ;error presents
                ret
    CheckStatus    ENDP

    Drive          EQU       SS:[BX+4]

    ResetDisk      PROC      FAR
                Zero     ax                      ;function 0
    L2:
                StackFrame  bx                   ;set up stack frame
                mov      dx,Drive                ;load the drive
    L3:
                int      BiosDisk                ;call BIOS
                call     CheckStatus             ;check for errors
                ret      2                       ;return and pop
    ResetDisk      ENDP

    GetDiskStatus  PROC      FAR
                mov      ah,1                    ;load function
                jmp      SHORT  L2               ;exit through other function
    GetDiskStatus  ENDP

    Result         EQU       SS:[SI+4]           ;parameters
    Buffer         EQU       SS:[SI+8]
    DiskDrive      EQU       SS:[SI+12]
    Head           EQU       SS:[SI+14]
    StartSec       EQU       SS:[SI+16]
    Track          EQU       SS:[SI+18]
    SecNum         EQU       SS:[SI+20]

    ReadFromDisk   PROC      FAR
                mov      ah,2                    ;load function
    L4:
                StackFrame  si                   ;set up stack frame
                mov      al,SecNum               ;load # of sectors
                PutCylinder  Track               ;load a cylinder
                or       cl,StartSec             ;load beginning sector
                mov      dh,Head                 ;load a r/w head
                mov      dl,DiskDrive            ;get a drive
                les      bx,Buffer               ;pointer to buffer
                int      BiosDisk                ;call BIOS
                les      di,Result               ;load a ptr to a var
                mov      es:[di],al              ;save a value
                call     CheckStatus             ;check for errors
                ret      18                      ;return and pop parms
    ReadFromDisk   ENDP

    WriteToDisk    PROC      FAR
                mov      ah,3                    ;load a function
                jmp      SHORT  L4               ;exit through other function
    WriteToDisk    ENDP


    VerifyDisk     PROC      FAR
                mov      ah,4                    ;load a function
                jmp      SHORT  L4               ;exit through other function
    VerifyDisk     ENDP

    AddrList       EQU       SS:[SI+4]
    DisketteDrive  EQU       SS:[SI+8]
    DisketteHead   EQU       SS:[SI+10]
    DisketteTrack  EQU       SS:[SI+12]
    DisketteSecs   EQU       SS:[SI+14]

    FormatTrackOnDiskette PROC  FAR
                StackFrame  si                   ;set up stack frame
                mov      al,DisketteSecs         ;load parms
                PutCylinder  DisketteTrack
                mov      dh,DisketteHead
                mov      dl,DisketteDrive
                les      bx,AddrList
                mov      ah,5
                int      BiosDisk                ;call BIOS
                call     CheckStatus             ;check for errors
                ret      12                      ;return and pop parms
    FormatTrackOnDiskette ENDP

    DriveXT        EQU       SS:[BX+4]
    HeadXT         EQU       SS:[BX+6]
    TrackXT        EQU       SS:[BX+8]
    Interleave     EQU       SS:[BX+10]

    FormatTrackHardXT  PROC  FAR
                StackFrame  bx                   ;set up stack frame
                mov      al,Interleave           ;load parms
                PutCylinder  TrackXT
                mov      dh,HeadXT
                mov      dl,DriveXT
                mov      ah,5
                int      BiosDisk                ;call BIOS
                call     CheckStatus             ;check for errors
                ret      8                       ;return and pop parms
    FormatTrackHardXT  ENDP

    AddrListAT     EQU       SS:[BX+4]
    DriveAT        EQU       SS:[BX+8]
    HeadAT         EQU       SS:[BX+10]
    TrackAT        EQU       SS:[BX+12]

    FormatTrackHardAT  PROC  FAR
                StackFrame  bx                  ;set up stack frame
; Modification by Dmitry Avdeyev 12/14/90
		mov	dl,DriveAT		; Get the drive
		or	dl,80h			; Make sure that fixed
		mov	ah,8			; Get drive parms
		int	BiosDisk
		and	cl,00111111b		; Mask bits 6,7
		mov	al,cl			; AL = cylinders per track
; End modification
                PutCylinder  TrackAT
                mov      dh,HeadAT
                mov      dl,DriveAT
                les      bx,AddrListAT
                mov      ah,5
                int      BiosDisk                ;call BIOS
                call     CheckStatus             ;check for errors
                ret      10                      ;return and pop parms
    FormatTrackHardAT  ENDP

    Disks          EQU       SS:[BX+4]           ;parms
    Heads          EQU       SS:[BX+8]
    SectorsPar     EQU       SS:[BX+12]
    Tracks         EQU       SS:[BX+16]
    FixedDisk      EQU       SS:[BX+20]

    FixedDiskParms PROC      FAR
                StackFrame  bx                   ;set up stack frame
                mov      dl,FixedDisk            ;get the disk
                or       dl,80h                  ;make sure that fixed
                mov      ah,8
                int      BiosDisk                ;call Bios
                call     CheckStatus             ;check for errors
                les      di,Disks                ;save a values
                mov      es:[di],dl
                les      di,Heads
                mov      es:[di],dh
                les      di,SectorsPar
                push     cx                      ;make a word
                and      cl,00111111b            ;mask bits 6-7
                mov      es:[di],cl
                pop      cx
                les      di,Tracks
                mov      dx,cx
                xchg     dh,dl
                mov      cl,6
                shr      dh,cl
                mov      cx,dx
                mov      es:[di],cx
                ret      18                      ;return and pop parms
    FixedDiskParms ENDP

    DDPtable       EQU       SS:[SI+4]
    DriveType      EQU       SS:[SI+8]
    DisksNum       EQU       SS:[SI+12]
    HeadsNum       EQU       SS:[SI+16]
    SecNumber      EQU       SS:[SI+20]
    TracksNum      EQU       SS:[SI+24]
    DriveForInfo   EQU       SS:[SI+28]

    DisketteParms  PROC      FAR
                StackFrame  si                   ;set up stack frame
                mov      dl,DriveForInfo         ;load parms
                and      al,7Fh                  ;bit 7 off
                mov      ah,8
                int      BiosDisk                ;call Bios
                push     es                      ;save the pointer to table
                push     di
                les      di,DisksNum             ;load the pointer to var
                mov      es:[di],dl              ;save a value
                les      di,DriveType
                mov      es:[di],bl
                les      di,HeadsNum
                mov      es:[di],dh
                les      di,SecNumber
                push     cx                      ;save CX
                and      cl,3Fh
                mov      es:[di],cl              ;save a sector number
                pop      cx                      ;restore CX
                les      di,TracksNum
                mov      dx,cx
                xchg     dh,dl
                mov      cl,6
                shr      dh,cl
                mov      cx,dx
                mov      es:[di],cx
                pop      bx                      ;restore a ptr to table
                pop      dx
                les      di,DDPtable             ;load the var ptr
                mov      es:0[di],bx
                mov      es:2[di],dx
                ret      26                      ;return and pop
    DisketteParms  ENDP

    DiskToInit     EQU       SS:[BX+4]

    InitDiskTable  PROC      FAR
                StackFrame  bx                   ;set up stack frame
                mov      dx,DiskToInit           ;load a drive
                or       dl,80h                  ;make sure that fixed disk
                mov      ah,9                    ;load function
                jmp      L3                      ;exit through other function
    InitDiskTable  ENDP

    ReadLong       PROC      FAR
                mov      ah,10                   ;load function
                jmp      L4                      ;exit through other function
    ReadLong       ENDP

    WriteLong      PROC      FAR
                mov      ah,11                   ;load function
                jmp      L4                      ;exit through other function
    WriteLong      ENDP

    DriveToSeek    EQU       SS:[BX+4]           ;parms
    HeadToSeek     EQU       SS:[BX+6]
    TrackToSeek    EQU       SS:[BX+8]

    SeekCylinder   PROC      FAR
                StackFrame  bx                   ;set up stack frame
                PutCylinder  TrackToSeek         ;get a cylinder to seek
                mov      dl,DriveToSeek          ;load a drive
                or       dl,80h                  ;bit 7 on
                mov      dh,HeadToSeek           ;get a head
                mov      ah,0Ch                  ;load function
                int      BiosDisk                ;call BIOS
                call     CheckStatus             ;check for errors
                ret      6                       ;return and pop parms
    SeekCylinder   ENDP

    AlternateResetDisk PROC  FAR
                mov      ah,0Dh                  ;load function
                jmp      L2                      ;exit through other function
    AlternateResetDisk ENDP

    TestDriveReady PROC      FAR
                mov      ah,10h                  ;load function
                jmp      L2                      ;exit through other function
    TestDriveReady ENDP

    RecalibrateDrive PROC    FAR
                mov      ah,11h                  ;load function
                jmp      L2                      ;exit through other function
    RecalibrateDrive ENDP

    SecsInDrive      EQU     SS:[BX+4]
    DASDtype         EQU     SS:[BX+8]
    DriveRead        EQU     SS:[BX+12]

    ReadDASDtype     PROC    FAR
                StackFrame  bx                   ;set up stack frame
                mov      dl,DriveRead            ;load a drive
                mov      ah,15h                  ;load function
                int      BiosDisk                ;call BIOS
                call     CheckStatus             ;check for errors
                les      di,DASDtype             ;save a values
                mov      es:[di],ah
                les      di,SecsInDrive
                mov      es:0[di],dx
                mov      es:2[di],cx
                ret      10                      ;return and pop parms
    ReadDASDtype     ENDP

    StatusLine       EQU     SS:[BX+4]
    DriveToStatus    EQU     SS:[BX+8]

    ChangeStatusLine PROC    FAR
                StackFrame  bx                   ;set up stack frame
                mov      dl,DriveToStatus        ;load a drive
                mov      ah,16h                  ;load function
                int      BiosDisk                ;call BIOS
                call     CheckStatus             ;check for errors
                les      di,StatusLine           ;save a values
                mov      es:[di],ah
                ret      6                       ;return and pop parms
    ChangeStatusLine ENDP

    DASDdrive        EQU     SS:[BX+6]
    DASDcom          EQU     SS:[BX+4]

    SetDASDtype      PROC    FAR
                StackFrame  bx                   ;set up stack frame
                mov      dl,DASDdrive            ;load a drive
                mov      al,DASDcom              ;get a disk combination
                mov      ah,17h                  ;load function
                int      BiosDisk                ;call BIOS
                call     CheckStatus             ;check for errors
                ret      6                       ;return and pop parms
    SetDASDtype      ENDP

    DiskTablePtr     EQU     SS:[BX+4]
    DriveToSet       EQU     SS:[BX+8]
    SecsPerTrk       EQU     SS:[BX+10]
    TrkcsNum         EQU     SS:[BX+12]

    SetMediaType     PROC    FAR
                StackFrame  bx                   ;set up stack frame
                PutCylinder  TrkcsNum            ;get a track
                or       cl,SecsPerTrk           ;get the # of sectors on track
                mov      dl,DriveToSet           ;load a drive
                mov      ah,18h                  ;load function
                int      BiosDisk                ;call BIOS
                call     CheckStatus             ;check for errors
                push     es                      ;save a pointer
                push     di
                les      di,DiskTablePtr         ;get a pointer
                pop      bx                      ;pop a pointer
                pop      dx
                mov      es:0[di],bx             ;save a value
                mov      es:2[di],dx
                ret      10                      ;return and pop parms
    SetMediaType     ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
