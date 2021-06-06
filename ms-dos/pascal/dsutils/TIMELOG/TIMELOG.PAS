{****************************************************************************
//                            File TIMELOG.PAS
//
//                         Time Logging Device
//
//          Copyright (c) 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/TIMELOG/RCS/timelog.pas $
//  $RCSfile: timelog.pas $
//   $Author: dstef $
//     $Date: 1998/10/03 14:51:02 $
// $Revision: 1.1 $ 
//   $Locker: dstef $
//
//      $Log: timelog.pas $
//      Revision 1.1  1998/10/03 14:51:02  dstef
//      Initial revision
//: 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                TIMELOG_DEVICE_DRIVER                           }
{ FILE NAME             TIMELOG.PAS                                     }
{ PURPOSE               Time logging to profile purpose                 }
{ VERSION               1.00                                            }
{ DATE                  04-Aug-1997                                     }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Telephone: +007 (095) 944-6304                  }
{ INTERNET              wizard@radio-msu.net, dima@mccbn.ru             }
{ COPYRIGHT NOTICE      Copyright (C) 1997  Dmitry Stefankov            }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,           }
{                       NOT FOR COMMERCIAL PURPOSE                      }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 7.0                        }
{                       (Borland International Inc.) or compatible      }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             None                                            }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   04-Aug-97  DS  initilal release          }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   TimeLogDevice;


{** switches for compilation **}
{$S-}                   {*  stack checking  *}
{$R-}                   {*  range checking  *}
{$G+}                   {*  286+ processor  *}
{$M 2048,0,16384}       {*  memory allocation  *}

{***$DEFINE DebugVersion}  {* debugging version *}


{*** other modules ***}
USES
     Dos{,ShowTErr};


{*========================== CONSTANTS PART ============================*}

CONST

     asPurpose                  =       'TimeLog Device';
     asVersion                  =       '1.00';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1997';
     asProgram                  =       'TimeLog';
     asProgramPrompt            =       asProgram+': ';
     asProgramU                 =       'TIMELOG';
     asProgramDebug             =       asProgramPrompt+'!DEBUG! ';

     { exit codes }
     errTerminateOK             =     0;
     errNoMemoryToLoad          =     1;
     errUserHelp                =     2;
     errBadDataCrc              =     3;

     {miscellaneous}
     achNULL                    =     #0;
     achBELL                    =     #7;
     achLF                      =     #10;
     achCR                      =     #13;

     achDosEndMsg               =     '$';
     achColon                   =     ':';

     achYes                     =     'Y';
     achNo                      =     'N';

     achHexPrefix               =     '$';
     achDosExtMark              =     '.';
     asInDefExt                 =     'sys';
     asOutDefExt                =     'sys';
     asDosDriverName            =     '$TIMLOG$';

     aWordSize                  =     2;
     aDWordSize                 =     4;
     aMinSecs                   =     0;
     aMaxSecs                   =     99;
     aPercent100                =     100;
     aHexRadix                  =     16;
     aMaxOnHeap                 =     65520;

   { Device commands }
     asCmdHelp                  =     '-?';
     asCmdDiff                  =     '-diff';
     asCmdNew                   =     '-new';
     asCmdPut                   =     '-put';
     asCmdClear                 =     '-clear';
     asCmdGet                   =     '-get';
     asCmdWait                  =     '-wait';
     asCmdDiffU                 =     'D';
     asCmdNewU                  =     'N';
     asCmdPutU                  =     'P';
     asCmdClearU                =     'C';
     asCmdGetU                  =     'G';
     asCmdWaitU                 =     'W';

   { Device command bit definitions }
     btCmdNew                   =     $0001;
     btCmdDiff                  =     $0002;
     btCmdGet                   =     $0004;
     btCmdPut                   =     $0008;
     btCmdClear                 =     $0010;
     btCmdWait                  =     $0020;

   { Time/Date }
     aSecsPerMin                =     60;
     aMinsPerHour               =     60;
     aHoursPerDay               =     24;

   { PC hardware ports }
     aCMOS_IDX_PORT             =     $70;       {CMOS RAM memory}
     aCMOS_DATA_PORT            =     $71;
     aCMOS_CUR_SEC              =     $00;
     aCMOS_CUR_MIN              =     $02;
     aCMOS_CUR_HOUR             =     $04;
     aCMOS_CUR_DAY              =     $07;
     aCMOS_CUR_MONTH            =     $08;
     aCMOS_CUR_YEAR             =     $09;
     aCMOS_STAT_REG_A           =     $0A;
     aCMOS_STAT_REG_B           =     $0B;
     aCMOS_STAT_REG_C           =     $0C;
     aCMOS_STAT_REG_D           =     $0D;

     btNMI_OFF                  =     $80;
     btInMode12hr               =     $80;      { Reg. $04 }
     btTimeUpdateInProgress     =     $80;      { Reg. $0A }
     btMode24hr                 =     $02;      { Reg. $0B }
     btDateTimeInBinary         =     $04;      { Reg. $0B }

  { ROM BIOS interrupts/functions }
     aRomVideoDriver            =     $10;      { IBM PC BIOS functions }
     aRomDiskDriver             =     $13;
     aRomKeyboardDriver         =     $16;
     aRomBootDriver             =     $19;
     aUnusedInt90               =     $90;      { Unused interrupt? }

     aBiosWaitKbdInput          =     $00;      { keyboard functions }
     aBiosCheckAvailKbdInput    =     $01;

  { BIOS definitions }
     aBiosTimerTicksPerSecond   =     18;
     achKeyESC                  =     $1B;
     aBiosDataSeg               =     $40;
     aBiosTimerTicksLoc         =     $6C;

  { PC memory constants }
     aInitMemSegLow             =     $0;
     aBestRelocMemSeg           =     $7000;    {448KB boundary}
     aMaxFileSize               =     12888;    {same as compiler MaxHeap}

  { DOS functions/interrupts }
     aDosFuncInt                =     $21;

     aDosDispMsg                =     $09;
     aDosGetVer                 =     $30;

  { DOS definitions }
     errDosFileNotFound         =     2;

  { device driver attributes }
     btCharacterDevice          =     $8000;
     btBlockDevice              =     $0000;


  { device driver functions }
        aDEV_INIT               =       0;
        aDINIT_HLen             =       23;

        aDEV_MEDIA_CHK          =       1;
        aDMED_HLen              =       19;

        aDEV_GET_BPB            =        2;
        aDBPB_HLen              =        22;

        aDEV_READ_IOCTL         =        3;
        aDEV_READ               =        4;
        aDRDWR_HLen             =        30;

        aDEV_READ_NOWAIT        =        5;
        aDRDND_HLen             =        14;

        aDEV_IN_STATUS          =        6;
        aDSTAT_HLen             =        13;

        aDEV_IN_FLUSH           =        7;
        aDFLSHLen               =        15;

        aDEV_WRITE              =        8;
        aDEV_WRITE_VERIFY       =        9;
        aDEV_OUT_STATUS         =        10;
        aDEV_OUT_FLUSH          =        11;
        aDEV_WRITE_IOCTL        =        12;

        aDEV_OPEN               =        13;
        aDEV_CLOSE              =        14;
        aDOPCL_HLen             =        13;

        aDEV_REM_MEDIA          =        15;
        aDREM_HLen              =        13;

        aDEV_OUT_NO_BUSY        =        16;
        aDEVOUTL_HLen           =        8;

        aDEV_GEN_IOCTL          =        19;

        aDEV_GETOWN             =        23;
        aDEV_SETOWN             =        24;
        aDOWN_HLen              =        13;

        aDEV_CHECK_GEN_IOCTL    =        25;

        aMaxDosRequestSize      =        32;
        aBPB_Size               =        32;

  { status word }
     btSTERR                    =       $8000;
     btSTBUI                    =       $0200;
     btSTDON                    =       $0100;
     aCLRCODE                   =       $0000;
     aSTECODE                   =       $00FF;

  { Device Driver Error Codes }
     errWriteProtect              =       $00;
     errBadUnit                   =       $01;
     errDriveNotReady             =       $02;
     errBadCommand                =       $03;
     errBadCRC                    =       $04;
     errBadRequestLength          =       $05;
     errSeekFailed                =       $06;
     errNonDosDisk                =       $07;
     errSectorNotFound            =       $08;
     errPaperOut                  =       $09;
     errWriteFailed               =       $0A;
     errReadFailed                =       $0B;
     errGeneralFailure            =       $0C;
     errDOS_Reserved_0Dh          =       $0D;
     errDOS_Reserved_0Eh          =       $0E;
     errWrongDiskChange           =       $0F;

  { return codes for function MEDIA_CHECK }
     adbMediaWasChanged           =       $FF;
     adbMediaNotChanged           =       $01;
     adbMediaDontKnow             =       $00;


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
    STR2        =       STRING[2];
    STR3        =       STRING[3];
    STR4        =       STRING[4];
    STR8        =       STRING[8];

  { Miscellaneous DOS structures }

  { Common Device Driver Header }
     recDevHeader    =           RECORD
        ddNextDevDrvrLink   :  System.Longint;            {00}
        dwDevAttr           :  System.Word;               {04}
        dwDevStrategy       :  System.Word;               {06}
        dwDevInterrupt      :  System.Word;               {08}
        chDevName           :  ARRAY[0..7] OF System.Char;{0A}
                                 END;
    {recDevHeader}

  { Generic Device Request Header }
     recSRHEAD       =           RECORD
        dbREQ_LEN         :   System.Byte;                {00}
        dbREQ_UNIT        :   System.Byte;                {01}
        dbREQ_FUNC        :   System.Byte;                {02}
        dwREQ_STATUS      :   System.Word;                {03}
        ddREQ_RESERVED    :   System.Pointer;             {05}
        ddREQ_QUEUELINK   :   System.Pointer;             {09}
                                 END;
    {recSRHEAD}

  { Device Request Header for function INIT DEVICE (00h) }
    recDEV_INIT_DEV  =       RECORD
        recSRHEAD           :      recSRHEAD;             {00}
        dbMaxDevNum         :      System.Byte;           {0D}
        lpDrvrResidentCode  :      System.Pointer;        {0E}
        lpDeviceBPB         :      System.Pointer;        {12}
        dbDrvNum            :      System.Byte;           {16}
                                END;
   {recDEV_INIT_DEV}

  { Device Request Header for function CHECK MEDIA (01h) }
    recDEV_MEDIA_CHECK  =       RECORD
        recSRHEAD           :      recSRHEAD;             {00}
        dbMediaDes          :      System.Byte;           {0D}
        dbMediaStatus       :      System.Byte;           {0E}
        lpszPrevDiskVolume  :      System.Pointer;        {0F}
                                END;
   {recDEV_MEDIA_CHECK}

  { Device Request Header for function BUILD BPB (02h) }
    recDEV_BUILD_BPB  =       RECORD
        recSRHEAD           :      recSRHEAD;             {00}
        dbMediaDes          :      System.Byte;           {0D}
        lpFatSector         :      System.Pointer;        {0E}
        lpDeviceBPB         :      System.Pointer;        {12}
                                END;
   {recDEV_BUILD_BPB}


  { Device Request Header for functions I/O CONTROL READ/WRITE (0Ch/03h) }
    recDEV_IOCTL_TRANSFER      =       RECORD
        recSRHEAD           :      recSRHEAD;             {00}
        dbMediaDes          :      System.Byte;           {0D}
        lpMemIOBuffer       :      System.Pointer;        {0E}
        dwIOTransferCount   :      System.Word;           {12}
                                        END;
   {recDEV_IOCTL_TRANSFER}


  { Device Request Header for functions READ/WRITE/VERIFY (04h/08h/09h) }
    recDEV_SECTOR_TRANSFER      =       RECORD
        recSRHEAD_04          :      recSRHEAD;           {00}
        dbMediaDes_04         :      System.Byte;         {0D}
        lpMemSectorBuffer     :      System.Pointer;      {0E}
        dwSectorCount         :      System.Word;         {12}
        dwSectorNumber16      :      System.Word;         {14}
        lpszDiskVolume        :      System.Pointer;      {16}
        ddSectorNumber32      :      System.Longint;      {1A}
                                        END;
   {recDEV_SECTOR_TRANSFER}

   {internal data for this driver}
     strucInternalData     =            RECORD
        ddDosPacketPtr        :     System.Longint;       {00}
        bLoadThisDriver       :     System.Boolean;       {04}
        dbThisDrvrWaitTimeout :     System.Byte;          {05}
        bDebugMode            :     System.Boolean;       {06}
                                        END;
    {strucInternalData}

    strucTimeDateDataPtr      =    ^strucTimeDateData;
    {Time/Date data structure}
     strucTimeDateData     =            RECORD
        ddBiosTicks           :     System.Longint;       {00}
        dbRtcSec              :     System.Byte;          {04}
        dbRtcMin              :     System.Byte;          {05}
        dbRtcHour             :     System.Byte;          {06}
        dbRtcDay              :     System.Byte;          {07}
        dbRtcMonth            :     System.Byte;          {08}
        dbRtcYear             :     System.Byte;          {09}
        dwCRC16               :     System.Word;          {0A}
                                        END;
    {strucTimeDateData}

{*====================== TYPED CONSTANTS PART ==========================*}

CONST

    setHexChars        :  SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];
    gdwRunCmdWord      :  System.Word  =  0;


{*=========================== VARIABLES PART ===========================*}

VAR

   gsFileName       :   STRING[80];
   gfBinStream      :   FILE;
   gstrucDriverData :   strucInternalData;
   gsTemp           :   STRING;
   glpDrvrCodeHeap  :   System.Pointer;
   gliFTime         :   System.Longint;
   gliFileSize      :   System.Longint;
   giInputErrCode   :   System.Integer;
   gdwPatchMemPlace :   System.Word;
   gdwFileBlockRW   :   System.Word;
   gdwResBlockRW    :   System.Word;
   gdbTempTimeout   :   System.Word;
   gdwTempValue     :   System.Word;
   gdwStrIndex      :   System.Word;
   gchUserInput     :   System.Char;


{*=========================== FORWARD PART ==========================*}

FUNCTION    _fnliGetBiosTicks : System.Longint; NEAR; FORWARD;
FUNCTION    _fndwCrc16(VAR pBuf; dwSize, dwSeed: System.Word) : System.Word; NEAR; FORWARD;
PROCEDURE   _InitDateTime(VAR strucDT : strucTimeDateData); NEAR; FORWARD;
PROCEDURE   _FillDateTime(VAR strucDT : strucTimeDateData); NEAR; FORWARD;
FUNCTION    _fnbValidateDateTime(VAR strucDT : strucTimeDateData) : System.Boolean; NEAR; FORWARD;
PROCEDURE   _GetDateTime(VAR strucDT : strucTimeDateData); NEAR; FORWARD;
PROCEDURE   _PutDateTime(VAR strucDT : strucTimeDateData); NEAR; FORWARD;


{*=========================== ASSEMBLER PART ==========================*}

PROCEDURE  _DeviceDriver; FAR; ASSEMBLER;
{* Simple device driver skeleton *}
ASM
        DW  $FFFF                           {offset:no more drivers here}
        DW  0                               {segment}
        DW  btCharacterDevice               {character device}
        DW  @_DeviceDriverStrategy          {get request packet}
        DW  @_DeviceDriverInterrupt         {process request packet}
        DB  '$TIMLOG$'                      {8-byte name}
{internal structure}
@ddPacket:                                  {DOS request}
        DD     0
@dbLoadOurProgramFlag:                      {default}
        DB     System.True
@dbOurProgramLoadTimeout:                   {default}
        DB     10
{$IFDEF   DebugVersion}
@dbDebugMode:                               {informative}
        DB     System.True
{$ELSE}
@dbDebugMode:
        DB     System.False
{$ENDIF} {DebugVersion}
@dwRunCommandWord:                          {execute commands}
        DW     0

{Wait a user key pressing for specified interval}
{Entry: AL = timeout in seconds}
{Exit:  AL = user key if no timeout}
{       AH = false if timeout occurred}
{            true  if key was pressed}
@_WaitUserKey:
        push   bx
        push   cx
        push   dx
        push   si
        push   di
        push   es
        mov    ah, aBiosTimerTicksPerSecond
        mul    ah
        mov    di, ax
        call  @_FlushKbdBuf
        or     di, di                       {timeout = 0?}
        jz    @TimeoutOccurred
        mov    ax, aBiosDataSeg             {access BIOS variables}
        mov    es, ax
        mov    bx, aBiosTimerTicksLoc
        mov    cx, es:[bx][2]               {high part}
        mov    dx, es:[bx][0]               {low part}
@CheckKeyInBuf:
        mov    si, es:[bx][2]               {high part}
        mov    ax, es:[bx][0]               {low part}
        sub    si, cx
        sbb    ax, dx
        cmp    ax, di
        jae   @TimeoutOccurred
        mov    ah, aBiosCheckAvailKbdInput  {check available char}
        int    aRomKeyboardDriver
        jz    @CheckKeyInBuf
@FakeKey:
        mov    ah, aBiosWaitKbdInput        {remove this char}
        int    aRomKeyboardDriver
        mov    ah, System.True
        jmp   @EventComplete
@TimeoutOccurred:
        mov    ah, System.False
@EventComplete:
        pop    es
        pop    di
        pop    si
        pop    dx
        pop    cx
        pop    bx
        retn
{_WaitUserKey}

{Output CR/LF pair}
{Entry: None}
{Exit:  None}
@_OutputBiosCRF:
        push   ax
        mov    al, achCR              { output pair CR/LF }
        call    @_BiosOutChar
        mov    al, achLF
        call    @_BiosOutChar
        pop    ax
        retn
{_OutputBiosCRF}

{** _AsciizOutput  PROC NEAR **}
{Enter: DS:SI <- null-terminated message}
{Exit:  SI = pints to last char in message}
@_AsciizOutput:
        push   ax                     {be carefully with STACK!!!}
        push   bx
        cld
  @NextChar:
        lodsb                         { get char }
        or       al, al               { AL is zero? }
        jz       @Done                { exit if match }
        call    @_BiosOutChar
        jmp      @NextChar

{** BiosOutChar  PROC NEAR **}
{Entry: AL = character}
{Exit:  None}
@_BiosOutChar:
        push     ax
        push     bx
        mov      bx, 0007h            { white-on-black, page 0 }
        mov      ah, 0Eh              { TTY function }
        int      aRomVideoDriver      { call ROM BIOS video driver }
  @Done:
        pop      bx
        pop      ax
        retn                          { return to caller }
{** _AsciizOutput  ENDP  **}


{Convert a binary value to ASCII code}
{Entry: AL = binary value in range 0..F}
{Exit:  AL = ASCII in set '0'..'9','A'..'F'}
@_Bin2asc:
        and    al, 00001111b                {use only lower nibble}
        cmp    al,9
        jbe   @AddAscZero
        add    al, 'A'-'9'-1                {'A'..'F'}
@AddAscZero:
        add    al, '0'                      {'0'..'9'}
        retn
{_Bin2asc}


{Output binary nibble as ASCII}
{Entry: AL = value}
{Exit:  None}
@_OutputHexNibble:
        push   ax
        call  @_Bin2asc                     {one digit}
        call  @_BiosOutChar
        pop    ax
        retn
{_OutputHexNibble}


{Output binary byte as ASCII}
{Entry: AL = value}
{Exit:  None}
@_OutputHexByte:
        push   ax
        push   ax
        shr    al, 1                        {display high nibble}
        shr    al, 1
        shr    al, 1
        shr    al, 1
        call  @_OutputHexNibble
        pop    ax                           {display low nibble}
        call  @_OutputHexNibble
        pop    ax
        retn
{_OutputHexByte}


{Output binary word as ASCII}
{Entry: AX = value}
{Exit:  None}
@_OutputHexWord:
        push   ax
        push   ax
        xchg   al, ah                       {display high byte}
        call  @_OutputHexByte
        pop    ax                           {display low byte}
        call  @_OutputHexByte
        pop    ax
        retn
{_OutputHexWord}


{Flush a BIOS keyboard buffer}
{Entry: none}
{Exit:  none}
@_FlushKbdBuf:
        mov    ah, aBiosCheckAvailKbdInput  {check available char}
        int    aRomKeyboardDriver
        jz    @FlushBufDone
        mov    ah, aBiosWaitKbdInput        {remove this char}
        int    aRomKeyboardDriver
        jmp   @_FlushKbdBuf
@FlushBufDone:
        retn
{_FlushKbdBuf}

{Keep TSR code only!}
@InitTSRCode:


{ Entry point for device driver call }
{ Entry: ES:BX <- device driver request packet }
{ Note: Turbo Pascal automatically uses CS prefix for our variables }
@_DeviceDriverStrategy:
        mov    WORD PTR [@ddPacket+0], bx
        mov    WORD PTR [@ddPacket+2], es
        retf
{_DeviceDriverStrategy}


{ Entry point for device driver call }
{ Entry: None }
@_DeviceDriverInterrupt:
        push   ax                           {save a world}
        push   bx
        push   cx
        push   dx
        push   si
        push   di
        push   bp
        push   ds
        push   es

        mov    ax, cs                       {access to our variables}
        mov    ds, ax

        les    bx, DWORD PTR ds:[@ddPacket] {now look request}
        mov    ax, btSTERR+errBadCommand    {we'll use only INIT function}
        cmp    es:[bx][recSRHEAD.dbREQ_FUNC], aDEV_INIT
        jne   @SetStatusWord

        call  @_InitDevice                  {init our body and soul}

        mov    dx, bx                       {save a length}
        les    bx, DWORD PTR ds:[@ddPacket]
        mov    WORD PTR es:[bx][recDEV_INIT_DEV.lpDrvrResidentCode][2], cs
        mov    WORD PTR es:[bx][recDEV_INIT_DEV.lpDrvrResidentCode][0], dx

@SetStatusWord:
        or     ax, btSTDON                  {always must be set}
        mov    es:[bx][recSRHEAD.dwREQ_STATUS], ax

        pop    es                           {restore a world}
        pop    ds
        pop    bp
        pop    di
        pop    si
        pop    dx
        pop    cx
        pop    bx
        pop    ax
        retf
{_DeviceDriverInterrupt}


{Keep resident part of driver}
@InitDriverCode:


{messages area}
@chHelloMsg:
        DB    'TimeLog Device Loader V1.00'
        DB    ' (c) 1997 Dmitry Stefankov'
@chCRLFMsg:
        DB    achCR, achLF
        DB    achDosEndMsg
@chAskUserToLoadOurProgram:
        DB     'TIMELOG: Press <ESC> key to skip this program'
        DB     ' or any other key to continue.'
        DB     achCR, achLF
        DB     achDosEndMsg
@chNoLoadOurProgram:
        DB     'TIMELOG: installation not complete; aborted by user.'
        DB     achCR, achLF
        DB     achDosEndMsg
@chLoadOurProgram:
        DB     'TIMELOG: installation successfully done.'
        DB     achCR, achLF
        DB     achDosEndMsg
@chBadDosVersion:
        DB     'TIMELOG: requires DOS version 3.30 or higher.'
        DB     achBELL
        DB     achCR, achLF
        DB     achDosEndMsg
@chBadDataCRC:
        DB     'TIMELOG: Bad data CRC during init of new structure.'
        DB     achBELL
        DB     achCR, achLF
        DB     achDosEndMsg
@chAnyKeyMessage:
        DB     'TIMELOG: Press any key to continue.'
        DB     achCR, achLF
        DB     achDosEndMsg
@chBadCommand:
        DB     'TIMELOG: Sorry, this command not implemented yet.'
        DB     achBELL
        DB     achCR, achLF
        DB     achDosEndMsg


{Display a message}
{Entry: DS:DX <- DOS style message}
{Exit:  None}
@_DisplayDosMessage:
        push   ax
        mov    ah, aDosDispMsg
        int    aDosFuncInt
        pop    ax
        retn
{_DisplayDosMessage:}


{Output CR/LF pair}
@_OutputCRLF:
        push   dx
        mov    dx, OFFSET @chCRLFMsg
        call  @_DisplayDosMessage
        pop    dx
        retn
{_OutputCRLF}


{CMD CODE = INITIALIZE DEVICE}
{Entry: ES:BX <- device driver request packet}
{Exit:  AX = error code}
{       BX = resident code size}
@_InitDevice:
        mov    dx,  OFFSET @chHelloMsg      {initial banner}
        call  @_DisplayDosMessage

        mov    ah, aDosGetVer
        int    aDosFuncInt                  {AH = minor, AL = major}
        xchg   ah, al                       {make usable for us}
        cmp    ax, (03 SHL 8) + (30)        {only DOS 3.30+}
        mov    dx,  OFFSET @chBadDosVersion
        jb    @DontLoadOurDriver

        mov    dx,  OFFSET @chAskUserToLoadOurProgram
        call   @_DisplayDosMessage
        mov    al,  BYTE PTR ds:[@dbOurProgramLoadTimeout]
        call  @_WaitUserKey
        cmp    ah, System.False              {timeout?}
        je    @CheckLoadingFlag
        mov    ah, System.False
        cmp    al, achKeyESC
        je    @SetLoadingFlag
        mov    ah, System.True
@SetLoadingFlag:
        mov    BYTE PTR ds:[@dbLoadOurProgramFlag], ah
@CheckLoadingFlag:
        cmp    BYTE PTR ds:[@dbLoadOurProgramFlag], System.True
        je    @LoadMe
        mov    dx,  OFFSET @chNoLoadOurProgram
@DontLoadOurDriver:
        call   @_DisplayDosMessage
        sub    bx, bx                        {no load our driver}
        jmp   @GoodInitDeviceComplete

@LoadMe:
        mov    dx,  OFFSET @chLoadOurProgram
        call   @_DisplayDosMessage

        les    bx, DWORD PTR ds:[@ddPacket] {restore a pointer}
        mov    di, WORD PTR es:[bx][recDEV_INIT_DEV.lpDeviceBPB+0]
        mov    es, WORD PTR es:[bx][recDEV_INIT_DEV.lpDeviceBPB+2]
        dec    di
@TakeNextChar:
        inc    di
        mov    al, es:[di]
        or     al, al                       {Look first terminator}
        jz    @NoMoreChars
        cmp    al, achLF
        je    @NoMoreChars
        cmp    al, achCR
        je    @NoMoreChars
        cmp    al, '-'                      {delimiter found?}
        jne   @TakeNextChar
        mov    al, es:[di+1]                {Take command letter}
@LookCmdDiff:
        cmp    al, asCmdDiffU
        jne   @LookCmdNew
        or     WORD PTR  [@dwRunCommandWord], btCmdDiff
        jmp   @TakeNextChar
@LookCmdNew:
        cmp    al, asCmdNewU
        jne   @LookCmdPut
        or     WORD PTR  [@dwRunCommandWord], btCmdNew
        jmp   @TakeNextChar
@LookCmdPut:
        cmp    al, asCmdPutU
        jne   @LookCmdClear
        or     WORD PTR  [@dwRunCommandWord], btCmdPut
        jmp   @TakeNextChar
@LookCmdClear:
        cmp    al, asCmdClearU
        jne   @LookCmdGet
        or     WORD PTR  [@dwRunCommandWord], btCmdClear
        jmp   @TakeNextChar
@LookCmdGet:
        cmp    al, asCmdGetU
        jne   @LookCmdWait
        or     WORD PTR  [@dwRunCommandWord], btCmdGet
        jmp   @TakeNextChar
@LookCmdWait:
        cmp    al, asCmdWaitU
        jne   @LookNextCmd
        or     WORD PTR  [@dwRunCommandWord], btCmdWait
        jmp   @TakeNextChar
@LookNextCmd:
        jmp   @TakeNextChar
@NoMoreChars:
                                            {process command word}
        test   WORD PTR  [@dwRunCommandWord], btCmdNew
        jz    @ExecCmdGet

        mov     di, aInitMemSegLow          {fixed memory location}
        mov     es, di
        mov     di, aUnusedInt90 * aDWordSize
        push    di                          {build}
        push    es
        call   _InitDateTime
        push    di                          {fill}
        push    es
        call   _FillDateTime
        push    di                          {validate integrity}
        push    es
        call   _fnbValidateDateTime
        cmp    al, System.True
        je    @ExecCmdGet
        mov    dx,  OFFSET @chBadDataCRC    {fail message!}
        call   @_DisplayDosMessage
        jmp    @TerminateInit

@ExecCmdGet:
        test   WORD PTR  [@dwRunCommandWord], btCmdGet
        jz    @ExecCmdClear
        mov     dx,  OFFSET @chBadCommand
        call   @_DisplayDosMessage

@ExecCmdClear:
        test   WORD PTR  [@dwRunCommandWord], btCmdClear
        jz    @ExecCmdPut
        mov     di, aInitMemSegLow          {fixed memory location}
        mov     es, di
        mov     di, aUnusedInt90 * aDWordSize
        push    di                          {build and zeroes}
        push    es
        call   _InitDateTime

@ExecCmdPut:
        test   WORD PTR  [@dwRunCommandWord], btCmdPut
        jz    @ExecCmdDiff
        mov     di, aInitMemSegLow          {fixed memory location}
        mov     es, di
        mov     di, aUnusedInt90 * aDWordSize
        push    di                          {write}
        push    es
        call   _PutDateTime

@ExecCmdDiff:
        test   WORD PTR  [@dwRunCommandWord], btCmdDiff
        jz    @ExecCmdWait
        mov     dx,  OFFSET @chBadCommand
        call   @_DisplayDosMessage

@ExecCmdWait:
        test   WORD PTR  [@dwRunCommandWord], btCmdWait
        jz    @ExecCmdNext
        mov    dx,  OFFSET @chAnyKeyMessage
        call   @_DisplayDosMessage
        mov    al,  BYTE PTR ds:[@dbOurProgramLoadTimeout]
        call  @_WaitUserKey
        call  @_OutputCRLF
@ExecCmdNext:

@TerminateInit:
{$IFDEF   DebugVersion}
        mov    bx, OFFSET @InitDriverCode   {we are go resident!}
{$ELSE}
        sub    bx, bx                       {no resident code!}
{$ENDIF} {DebugVersion}

@GoodInitDeviceComplete:
        mov    ax, aCLRCODE                 {good error code}
@InitDeviceDone:
        retn
{_InitDevice}

END;
  {asm-end}
{_DeviceDriver}


FUNCTION  _fnliGetBiosTicks : System.Longint; ASSEMBLER;
{* Read current BIOS timer ticks. *}
ASM
        push    es
        push    di
        mov     ax, aBiosDataSeg
        mov     es, ax
        mov     di, aBiosTimerTicksLoc
        mov     ax, es:[di+0]
        mov     dx, es:[di+2]
        pop     di
        pop     es
END;
{ _fnliGetBiosTicks }


FUNCTION  _fndbReadCmosData(dbIdxReg : System.Byte) : System.Byte; ASSEMBLER;
{* Read CMOS RAM byte. *}
ASM
        mov     al, dbIdxReg
        or      al, btNMI_OFF
        pushf
        cli
        out     aCMOS_IDX_PORT, al
        jmp    @W1
@W1:    jmp    @W2
@W2:
        in      al, aCMOS_DATA_PORT
        popf
END;
{ _fndbReadCmosData }


FUNCTION    _TransTimeData(dbTimeValue : System.Byte) : System.Byte; ASSEMBLER;
{* Translate from BCD to binary RTC RAM byte. *}
ASM
        mov     al, aCMOS_STAT_REG_B
        push    ax                          {AH=garbage!}
        call    _fndbReadCmosData
        test    al, btDateTimeInBinary
        mov     al, dbTimeValue             {Skip transform if binary format!}
        jnz    @InBinaryFormat
        push    bx
        mov     bx, ax                      {BCD=10*H+L}
        shr     al, 4
        mov     ah, 10
        mul     ah                          {Get H}
        mov     ah, al
        mov     al, bl
        and     al, 00001111b               {Add L}
        add     al, ah
        pop     bx
@InBinaryFormat:
END;
{ _TransTimeData }


FUNCTION  _fndbReadRTC(dbIdxReg : System.Byte) : System.Byte; ASSEMBLER;
{* Read RTC RAM byte. *}
ASM
@WaitUpdateRTC:
        mov     al, aCMOS_STAT_REG_A
        push    ax
        call    _fndbReadCmosData
        test    al, btTimeUpdateInProgress
        jnz    @WaitUpdateRTC
        mov     al, dbIdxReg
        push    ax                          {AH=garbage!}
        call    _fndbReadCmosData
END;
{ _fndbReadRTC }


FUNCTION  _fndwCrc16(VAR pBuf; dwSize, dwSeed: System.Word): System.Word; ASSEMBLER;
(*
  <<<This code was borrowed from SWAG Project Library>>>
  Set size parameter to 0 to process 64K.  If processing only one buffer, set
  seed parameter to 0, otherwise set to result from previous calculation.
  The polynomial is the X^16+X^12+X^5+X^0 or 0x8408.
  Note: C code translated by Don Paulsen.
  This routine is a translation of the following C code by Chuck Forsberg.
  The added "seed" parameter allows for finding the CRC value of data spanning
  multiple buffers.  The innermost loop has been unrolled at a cost of 32
  bytes in code, but the speed increase is nearly two-fold.

     int    Crc16 (ptr, count)
     char   *ptr;
     int    count;
     {   int crc, i;
         crc = 0;
         while (--count >= 0) {
            crc = crc ^ (int)*ptr++ << 8;
            for (i = 0; i < 8; ++i)
                if (crc & 0x8000)
                    crc = crc << 1 ^ 0x1021;
                else
                    crc = crc << 1;
          }
         return (crc & 0xFFFF);
     }
*)
ASM
        push    es
        push    di
        push    si
        push    dx
        push    bx
        les     di, pBuf
        mov     dx, dwSize
        mov     ax, dwSeed
        mov     si, $1021
@NextSym:
         xor     bx, bx
         mov     bh, es:[di]
         xor     ax, bx
         shl  ax, 1;    jnc  @noXor1;    xor  ax, si
@noXor1: shl  ax, 1;    jnc  @noXor2;    xor  ax, si
@noXor2: shl  ax, 1;    jnc  @noXor3;    xor  ax, si
@noXor3: shl  ax, 1;    jnc  @noXor4;    xor  ax, si
@noXor4: shl  ax, 1;    jnc  @noXor5;    xor  ax, si
@noXor5: shl  ax, 1;    jnc  @noXor6;    xor  ax, si
@noXor6: shl  ax, 1;    jnc  @noXor7;    xor  ax, si
@noXor7: shl  ax, 1;    jnc  @noXor8;    xor  ax, si
@noXor8:
         inc     di
         dec     dx
         jnz     @NextSym
         pop     bx
         pop     dx
         pop     si
         pop     di
         pop     es
END;
{ _fndwCrc16 }


PROCEDURE   _InitDateTime(VAR strucDT : strucTimeDateData); ASSEMBLER;
{* Initializes an instance of TimeDate structure. *}
ASM
        push    es
        push    di
        les     di, strucDT
        xor     ax, ax
        mov     WORD PTR es:[di+strucTimeDateData.ddBiosTicks+0], ax
        mov     WORD PTR es:[di+strucTimeDateData.ddBiosTicks+2], ax
        mov     es:[di+strucTimeDateData.dbRtcSec], al
        mov     es:[di+strucTimeDateData.dbRtcMin], al
        mov     es:[di+strucTimeDateData.dbRtcHour], al
        mov     es:[di+strucTimeDateData.dbRtcDay], al
        mov     es:[di+strucTimeDateData.dbRtcMonth], al
        mov     es:[di+strucTimeDateData.dbRtcYear], al
        mov     es:[di+strucTimeDateData.dwCRC16], ax
        pop     di
        pop     es
END;
{ _InitDateTime }



PROCEDURE   _FillDateTime(VAR strucDT : strucTimeDateData); ASSEMBLER;
{* Fill an instance of TimeDate structure. *}
ASM
        push    bx
        push    di
        push    es
        les     di, strucDT
        call    _fnliGetBiosTicks           { long BIOS timer ticks }
        mov     WORD PTR es:[di+strucTimeDateData.ddBiosTicks+0], ax
        mov     WORD PTR es:[di+strucTimeDateData.ddBiosTicks+2], dx
        mov     al, aCMOS_CUR_SEC           { RTC seconds }
        push    ax
        call    _fndbReadRTC
        push    ax
        call    _TransTimeData
        mov     es:[di+strucTimeDateData.dbRtcSec], al
        mov     al, aCMOS_CUR_MIN           { RTC minutes }
        push    ax
        call    _fndbReadRTC
        push    ax
        call    _TransTimeData
        mov     es:[di+strucTimeDateData.dbRtcMin], al
        mov     al, aCMOS_CUR_HOUR          { RTC hours }
        push    ax
        call    _fndbReadRTC
        mov     bx, ax                      { Save flag! }
        and     al, $FF - btInMode12hr      { = $7F }
        push    ax
        call    _TransTimeData
        push    ax
        mov     al, aCMOS_STAT_REG_B
        push    ax
        call    _fndbReadCmosData
        test    al, btMode24hr              {military time?}
        pop     ax
        jnz    @InMode24hr
        test    bl, btInMode12hr            {0-12 or 13-24?}
        jz     @InMode24hr
        add     al, 12
        cmp     al, 24
        jne    @InMode24hr
        mov     al, 0                       {24 hours past!}
@InMode24hr:
        mov     es:[di+strucTimeDateData.dbRtcHour], al
        mov     al, aCMOS_CUR_DAY           { RTC day }
        push    ax
        call    _fndbReadRTC
        push    ax
        call    _TransTimeData
        mov     es:[di+strucTimeDateData.dbRtcDay], al
        mov     al, aCMOS_CUR_MONTH         { RTC month }
        push    ax
        call    _fndbReadRTC
        push    ax
        call    _TransTimeData
        mov     es:[di+strucTimeDateData.dbRtcMonth], al
        mov     al, aCMOS_CUR_YEAR         { RTC year }
        push    ax
        call    _fndbReadRTC
        push    ax
        call    _TransTimeData
        mov     es:[di+strucTimeDateData.dbRtcYear], al
        push    es
        push    di
        mov     ax, OFFSET strucTimeDateData.dwCRC16
        push    ax
        mov     ax, 0
        push    ax
        call    _fndwCrc16
        mov     es:[di+strucTimeDateData.dwCRC16], ax
        pop     es
        pop     di
        pop     bx
END;
{ _FillDateTime }


FUNCTION   _fnbValidateDateTime(VAR strucDT : strucTimeDateData) : System.Boolean; ASSEMBLER;
{* Test an instance of TimeDate structure. *}
ASM
        push    es
        push    di
        push    bx
        les     di, strucDT
        push    es
        push    di
        mov     ax, OFFSET strucTimeDateData.dwCRC16
        push    ax
        mov     ax, 0
        push    ax
        call    _fndwCrc16
        mov     bl, System.False
        cmp     ax, es:[di+strucTimeDateData.dwCRC16]
        jne    @FuncRes
        mov     bl, System.True
@FuncRes:
        mov     al, bl                      {Function result}
        pop     bx
        pop     di
        pop     es
END;
{ _ValidateDateTime }


PROCEDURE   _GetDateTime(VAR strucDT : strucTimeDateData); ASSEMBLER;
{* Get an instance of TimeDate structure from a fixed memory location. *}
ASM
        push    ds
        push    si
        push    es
        push    di
        les     di, strucDT
        mov     cx, (OFFSET strucTimeDateData.dwCRC16) + aWordSize
        mov     si, aInitMemSegLow
        mov     ds, si
        mov     si, aUnusedInt90 * aDWordSize
        cld
        rep     movsb
        pop     di
        pop     es
        pop     si
        pop     ds
END;
{ _GetDateTime }


PROCEDURE   _PutDateTime(VAR strucDT : strucTimeDateData); ASSEMBLER;
{* Put an instance of TimeDate structure to a fixed memory location. *}
ASM
        push    ds
        push    si
        push    es
        push    di
        lds     si, strucDT
        mov     cx, (OFFSET strucTimeDateData.dwCRC16) + aWordSize
        mov     di, aInitMemSegLow
        mov     es, di
        mov     di, aUnusedInt90 * aDWordSize
        cld
        rep     movsb
        pop     di
        pop     es
        pop     si
        pop     ds
END;
{ _PutDateTime }



{*=========================== FUNCTIONAL PART ==========================*}

FUNCTION  _fnsBooleanState(bSwitch : System.Boolean) : STR3;
{* Text representation of boolean switch. *}
VAR
  sTemp : STR3;
BEGIN
  IF (bSwitch)
    THEN  sTemp := 'YES'
    ELSE  sTemp := 'NO';
  {if-then-else}
   _fnsBooleanState := sTemp;
END;
{ _fnsBooleanState }


FUNCTION  _fndwFirstMatchPatternInBuf(lpMemBlock : System.Pointer;
                                      dwMemBlockSize : System.Word;
                                      sPattern : STRING) : System.Word;
{* Searches a first matching pattern in memory buffer. *}
VAR
  dwFoundOfs    :  System.Word;
  dwPatternLen  :  System.Word;
  dwOfsInBuf    :  System.Word;
  dwStrIndex    :  System.Word;
  dbBufSym      :  System.Byte;
  bFound        :  System.Boolean;
BEGIN
   dwFoundOfs := $FFFF;
   dwOfsInBuf := 0;
   dwPatternLen := System.Length(sPattern);
   bFound := System.False;
   IF  (sPattern <> '') AND (dwPatternLen <= dwMemBlockSize)
     THEN  BEGIN
        WHILE  (NOT(bFound) AND (dwOfsInBuf < dwMemBlockSize)) DO
        BEGIN
          dbBufSym := System.Mem[System.Seg(lpMemBlock^):System.Ofs(lpMemBlock^)+dwOfsInBuf];
          System.Inc(dwOfsInBuf);
          IF  (dbBufSym = System.Byte(sPattern[1]))
            THEN BEGIN
              IF (dwPatternLen = 1)
                THEN  bFound := System.True
                ELSE  BEGIN
                  dwStrIndex := 2;
                  WHILE  (dwOfsInBuf < dwMemBlockSize) AND
                          (dwStrIndex <= dwPatternLen) DO
                  BEGIN
                     dbBufSym := System.Mem[System.Seg(lpMemBlock^):
                                            System.Ofs(lpMemBlock^)+dwOfsInBuf];
                     bFound := (sPattern[dwStrIndex] = System.Char(dbBufSym));
                     System.Inc(dwOfsInBuf);
                     System.Inc(dwStrIndex);
                  END;
                  {while-do}
                      END;
               {if-then-else}
                 END;
          {if-then}
        END;
        {while-do}
           END;
   {if-then}
   IF (bFound)
     THEN  BEGIN
        dwFoundOfs := dwOfsInBuf-dwPatternLen;  {adjust back}
           END;
   {if-then}
  _fndwFirstMatchPatternInBuf := dwFoundOfs;
END;
{ _fndwFirstMatchPatternInBuf }


FUNCTION   _fnsByteToHexFmt(dbInput : System.Byte) : STR2;
{* Converts a byte to the hexadecimal format number representation. *}
CONST
    dbHexTable : ARRAY[0..15] OF System.Char = '0123456789ABCDEF';

BEGIN
  _fnsByteToHexFmt := dbHexTable[dbInput SHR 4] + dbHexTable[dbInput AND $0F];
END;  { _fnsByteToHexFmt }


FUNCTION   _fnsWordToHexFmt(dwInput : System.Word) : STR4;
{* Converts a word to the hex format number representation. *}
BEGIN
  _fnsWordToHexFmt := _fnsByteToHexFmt(System.Hi(dwInput)) +
                      _fnsByteToHexFmt(System.Lo(dwInput));
END;  { _fnsWordToHexFmt }


FUNCTION   _fnsDWordToHexFmt(ddInput : System.Longint) : STR8;
{* Converts a double word to the hex format number representation. *}
BEGIN
  _fnsDWordToHexFmt := _fnsWordToHexFmt(ddInput SHR 16) +
                      _fnsWordToHexFmt(ddInput AND $0000FFFF);
END;  { _fnsDWordToHexFmt }


FUNCTION  _fnrJulDays(iDay, iMonth,  iYear: integer):  System.Real;
{*
  <<<This code was borrowed from SWAG Project Library>>>
   Uses the Julian calander mathmatical equasions to convert date
   to passed days.
*}
VAR
  rI, rJ, rK, rJ2, rJu: System.Real;
begin
     rI := iYear;
     rJ := iMonth;
     rK := iDay;
     rJ2 := System.Int( (rJ - 14)/12 );
     rJu := rK - 32075 + System.Int(1461 * ( rI + 4800 + rJ2 ) / 4 );
     rJu := rJu + System.Int( 367 * (rJ - 2 - rJ2 * 12) / 12);
     rJu := rJu - System.Int(3 * System.Int( (rI + 4900 + rJ2) / 100) / 4);
     _fnrJulDays := rJu;
end;
{ _fnrJulDays }


{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+'  Version '+asVersion+',  '+asCopyright+'  '+asAuthor);
END;  { _CopyrightDisplay }


PROCEDURE   _ProcessCommandWord(dwRunCmd : System.Word);
{* Run our magic processes. *}
VAR
  strucDateTimeNew,
  strucDateTimeOld   :  strucTimeDateData;
  pTemp              :  strucTimeDateDataPtr;
  liTemp1,
  liTemp2,
  liDiff             :  System.Longint;
BEGIN
{$IFDEF   DebugVersion}
    System.WriteLn(asProgramDebug+'Process a run command word.');
{$ENDIF} {DebugVersion}
    _InitDateTime(strucDateTimeNew);

    IF  ( (dwRunCmd AND btCmdNew) <> 0 )
      THEN  BEGIN
{$IFDEF   DebugVersion}
         System.WriteLn(asProgramDebug+'NEW command in progress.');
{$ENDIF} {DebugVersion}
        _FillDateTime( strucDateTimeNew );
        IF NOT( _fnbValidateDateTime(strucDateTimeNew) )
           THEN  BEGIN
             System.WriteLn(asProgramPrompt+'ERROR! Bad new structure CRC found.');
             System.Halt(errBadDataCrc);
                 END;
        {if-then}
            END;
    {if-then}

    IF  ( (dwRunCmd AND btCmdGet) <> 0 )
      THEN  BEGIN
{$IFDEF   DebugVersion}
         System.WriteLn(asProgramDebug+'GET command in progress.');
{$ENDIF} {DebugVersion}
        _GetDateTime( strucDateTimeOld );
        IF NOT( _fnbValidateDateTime(strucDateTimeOld) )
           THEN  BEGIN
             System.WriteLn(asProgramPrompt+'ERROR! Bad old structure CRC found.');
             System.Halt(errBadDataCrc);
                 END;
        {if-then}
            END;
    {if-then}

    IF  ( (dwRunCmd AND btCmdClear) <> 0 )
      THEN  BEGIN
{$IFDEF   DebugVersion}
         System.WriteLn(asProgramDebug+'CLEAR command in progress.');
{$ENDIF} {DebugVersion}
        pTemp := System.Ptr( aInitMemSegLow, aUnusedInt90*aDWordSize );
        _InitDateTime(pTemp^);
            END;
    {if-then}

    IF  ( (dwRunCmd AND btCmdPut) <> 0 )
      THEN  BEGIN
{$IFDEF   DebugVersion}
         System.WriteLn(asProgramDebug+'PUT command in progress.');
{$ENDIF} {DebugVersion}
        _PutDateTime( strucDateTimeNew );
            END;
    {if-then}

    IF  ( (dwRunCmd AND btCmdDiff) <> 0 )
      THEN  BEGIN
{$IFDEF   DebugVersion}
        System.WriteLn(asProgramDebug+'DIFF command in progress.');
{$ENDIF} {DebugVersion}
        liTemp1 := strucDateTimeNew.ddBiosTicks - strucDateTimeOld.ddBiosTicks;
        System.Write(asProgramPrompt+' BIOS ticks: ');
        System.Write('new=$'+_fnsDWordToHexFmt(strucDateTimeNew.ddBiosTicks));
        System.Write(', old=$'+_fnsDWordToHexFmt(strucDateTimeOld.ddBiosTicks));
        System.WriteLn(', dif=$'+_fnsDWordToHexFmt(liTemp1));
        System.Write(asProgramPrompt+' BIOS ticks time (ms) = ~');
        System.WriteLn(55*liTemp1);
        System.Write(asProgramPrompt+' RTC new time: ');
        System.Write('hour: ',strucDateTimeNew.dbRtcHour);
        System.Write('; min: ',strucDateTimeNew.dbRtcMin);
        System.WriteLn('; sec: ',strucDateTimeNew.dbRtcSec);
        System.Write(asProgramPrompt+' RTC old time: ');
        System.Write('hour: ',strucDateTimeOld.dbRtcHour);
        System.Write('; min: ',strucDateTimeOld.dbRtcMin);
        System.WriteLn('; sec: ',strucDateTimeOld.dbRtcSec);
        liTemp1 := System.Longint(strucDateTimeNew.dbRtcHour)*aSecsPerMin*aMinsPerHour+
                   System.Longint(strucDateTimeNew.dbRtcMin)*aSecsPerMin+
                   System.Longint(strucDateTimeNew.dbRtcSec);
        liTemp2 := System.Longint(strucDateTimeOld.dbRtcHour)*aSecsPerMin*aMinsPerHour+
                   System.Longint(strucDateTimeOld.dbRtcMin)*aSecsPerMin+
                   System.Longint(strucDateTimeOld.dbRtcSec);
        liDiff  := liTemp1 - liTemp2;
        System.WriteLn(asProgramPrompt+' RTC diff (secs): ',liDiff);
            END;
    {if-then}

    IF  ( (dwRunCmd AND btCmdWait) <> 0 )
      THEN  BEGIN
{$IFDEF   DebugVersion}
         System.WriteLn(asProgramDebug+'WAIT command in progress.');
{$ENDIF} {DebugVersion}
         System.Write(asProgramPrompt+' Press <ENTER> to continue.');
         System.ReadLn;
            END;
    {if-then}

END;
{ _ProcessCommandWord }



{*============================== MAIN PART =============================*}

BEGIN
  _CopyrightDisplay;

  gdwTempValue := System.ParamCount;
  IF  ( gdwTempValue <> 0)
    THEN  BEGIN
     IF  ( System.ParamStr(1) = asCmdHelp )
       THEN BEGIN
          System.WriteLn(asProgramPrompt+' short help screen for you.');
          System.WriteLn('Usage:  '+asProgramU+' [cmd],    where commands are defined as follows:');
          System.WriteLn('  '+asCmdPut+'         ->  put a current time to timelog device');
          System.WriteLn('  '+asCmdGet+'         ->  get a last time from timelog device');
          System.WriteLn('  '+asCmdClear+'       ->  clear a last time from timelog device');
          System.WriteLn('  '+asCmdWait+'        ->  wait a user keypress before continue');
          System.WriteLn('  '+asCmdNew+'         ->  read a current time using RTC and BIOS');
          System.WriteLn('  '+asCmdDiff+'        ->  get a differences between current and getting time');
          System.WriteLn('  -'+asCmdPutU+',-'+asCmdGetU+',-'+asCmdClearU+
                          ',-'+asCmdWaitU+',-'+asCmdNewU+',-'+asCmdDiffU+
                         '  -->  short commands must be used for device driver');
          System.Halt(errUserHelp);
           END
     ELSE BEGIN
{$IFDEF   DebugVersion}
        System.WriteLn(asProgramDebug+'Parse command-line parameters.');
{$ENDIF} {DebugVersion}
        gdwStrIndex := 1;
        WHILE ( gdwTempValue <> 0 ) DO
        BEGIN
            gsTemp := System.ParamStr(gdwStrIndex);
            IF  (gsTemp = asCmdGet)
              THEN  gdwRunCmdWord := gdwRunCmdWord OR btCmdGet;
            {if-then}
            IF  (gsTemp = asCmdPut)
              THEN  gdwRunCmdWord := gdwRunCmdWord OR btCmdPut;
            {if-then}
            IF  (gsTemp = asCmdNew)
              THEN  gdwRunCmdWord := gdwRunCmdWord OR btCmdNew;
            {if-then}
            IF  (gsTemp = asCmdDiff)
              THEN  gdwRunCmdWord := gdwRunCmdWord OR btCmdDiff;
            {if-then}
            IF  (gsTemp = asCmdClear)
              THEN  gdwRunCmdWord := gdwRunCmdWord OR btCmdClear;
            {if-then}
            IF  (gsTemp = asCmdWait)
              THEN  gdwRunCmdWord := gdwRunCmdWord OR btCmdWait;
            {if-then}
            System.Dec(gdwTempValue);
            System.Inc(gdwStrIndex);
        END;
        {while-do}
{$IFDEF   DebugVersion}
        System.WriteLn(asProgramDebug+'RunCmdWord=$'+_fnsWordToHexFmt(gdwRunCmdWord)+'.');
{$ENDIF} {DebugVersion}
        _ProcessCommandWord(gdwRunCmdWord);
        System.WriteLn(asProgramPrompt+'Done.');
        System.Halt(errTerminateOk);
          END;
     {if-then-else}
          END;
  {if-then}

  gdwPatchMemPlace := _fndwFirstMatchPatternInBuf(@_DeviceDriver,
                                          aMaxFileSize,
                                          asDosDriverName);
  System.Move(System.Mem[System.Seg(_DeviceDriver):
              (System.Ofs(_DeviceDriver)+gdwPatchMemPlace+System.Length(asDosDriverName))],
              gstrucDriverData,
              System.Sizeof(gstrucDriverData));

  {* output some information *}
  System.WriteLn(asProgramPrompt+' current settings/defaults for smart loader.');
  WITH  (gstrucDriverData)  DO
  BEGIN
    System.WriteLn(asProgramPrompt+'  Load this driver : ',
                   _fnsBooleanState(bLoadThisDriver));
    System.WriteLn(asProgramPrompt+'  Debugging mode : ',
                   _fnsBooleanState(bDebugMode));
    System.WriteLn(asProgramPrompt+'  Load this driver timeout : ',
                   dbThisDrvrWaitTimeout,' sec');
  END;
  {with-do}

  {* ask about change of settings *}
  System.Write(asProgramPrompt+'  Change something? (N/y): ');
  System.ReadLn(gsTemp);
  IF (gsTemp <> '')
    THEN  BEGIN
      gchUserInput := System.UpCase(gsTemp[1]);
      IF (gchUserInput = achYes)
        THEN  BEGIN
           System.Write(asProgramPrompt+'  Load this driver? (Y/n): ');
           System.ReadLn(gsTemp);
           IF (gsTemp <> '')
             THEN  BEGIN
               gchUserInput := System.UpCase(gsTemp[1]);
               IF  (gchUserInput = achYes)
                  THEN  gstrucDriverData.bLoadThisDriver := System.True;
               {if-then}
               IF  (gchUserInput = achNo)
                  THEN  gstrucDriverData.bLoadThisDriver := System.False;
               {if-then}
                   END;
           {if-then}
           System.Write(asProgramPrompt+'  Load this driver timeout (0..99 sec,0=no timeout): ');
           System.ReadLn(gsTemp);
           IF (gsTemp <> '')
             THEN  BEGIN
               System.Val(gsTemp,gdbTempTimeout,giInputErrCode);
               IF  ((giInputErrCode = 0) AND
                   (aMinSecs <= gdbTempTimeout) AND
                   (aMaxSecs >= gdbTempTimeout))
                  THEN  gstrucDriverData.dbThisDrvrWaitTimeout:= gdbTempTimeout;
               {if-then}
                   END;
           {if-then}
           gsFileName := System.ParamStr(0);
           System.GetMem(glpDrvrCodeHeap,aMaxFileSize);
           System.Assign(gfBinStream,gsFileName);
           System.Reset(gfBinStream,1);
           Dos.GetFTime(gfBinStream,gliFTime);
           gliFileSize := System.FileSize(gfBinStream);
           IF (gliFileSize > aMaxFileSize)
             THEN  BEGIN
                 System.WriteLn(asProgramPrompt+' insufficient memory to load driver on heap.');
                 System.Halt(errNoMemoryToLoad);
                   END;
           {if-then}
           gdwFileBlockRW := gliFileSize;  {implicit typecast!}
           System.BlockRead(gfBinStream,
       System.Mem[System.Seg(glpDrvrCodeHeap^):System.Ofs(glpDrvrCodeHeap^)],
                            gdwFileBlockRW,
                            gdwResBlockRW);
           System.Close(gfBinStream);
           gdwPatchMemPlace := _fndwFirstMatchPatternInBuf(glpDrvrCodeHeap,
                                          aMaxFileSize,
                                          asDosDriverName);
           System.Move(gstrucDriverData,
              System.Mem[System.Seg(glpDrvrCodeHeap^):
              (System.Ofs(glpDrvrCodeHeap^)+gdwPatchMemPlace+System.Length(asDosDriverName))],
              System.Sizeof(gstrucDriverData));
           System.Rewrite(gfBinStream,1);
           System.BlockWrite(gfBinStream,
       System.Mem[System.Seg(glpDrvrCodeHeap^):System.Ofs(glpDrvrCodeHeap^)],
                            gdwFileBlockRW,
                            gdwResBlockRW);
           Dos.SetFTime(gfBinStream,gliFTime);
           System.Close(gfBinStream);
           System.FreeMem(glpDrvrCodeHeap,aMaxFileSize);
              END;
      {if-then}
          END;
  {if-then}

  {** report all done **}
  System.WriteLn(asProgramPrompt+'Done.');

  {* System.Halt(errTerminateOk); *}
END.

