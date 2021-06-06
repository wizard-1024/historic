{****************************************************************************
//                            File DDLOADER.PAS
//
//                        DOS device driver loader
//
//      Copyright (c) 1995, 1998 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/DDLOADER/RCS/ddloader.pas $
//  $RCSfile: ddloader.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:28:58 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: ddloader.pas $
//      Revision 1.1  1998/10/03 14:28:58  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                DYNAMICALLY_LOADABLE_DEVICE_DRIVER              }
{ FILE NAME             DDLOADER.PAS                                    }
{ PURPOSE               Dynamically load device driver during phase of  }
{                       DOS startup (processing of CONFIG.SYS)          }
{ VERSION               1.14                                            }
{ DATE                  04-Jan-1998                                     }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Telephone: +007 (095) 944-6304                  }
{ INTERNET              wizard@radio-msu.net, dima@mccbn.ru             }
{ COPYRIGHT NOTICE      Copyright (C) 1995, 1998  Dmitry Stefankov      }
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
{ DESCRIPTION           1. Trap Int $21 for Fn $4B03 (load driver)      }
{                          and for Fn $4B00 (execute program)           }
{                          While not encountered (EXEC) do an           }
{                          intercept of call Fn $4B03 and ask an user   }
{                          to loadthe driver from processed CONFIG.SYS  }
{                          If Fn $4B00 found then disable Int $21 trap  }
{                       2. Stealth technology                           }
{                           Hide or remove our code after work done     }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   12-Dec-95  DS  initilal release          }
{                       1.10   13-Dec-95  DS  added change of settings  }
{                                             added DOS version check   }
{                       1.11   01-Jun-97  DS  fixed no timeout bug      }
{                       1.12   26-Jul-97  DS  updated documentation     }
{                       1.13   02-Aug-97  DS  removed tabs              }
{                       1.14   04-Jan-98  DS  fixed syntax bug          }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   DynamicallyDeviceDriverLoader;


{*** other modules ***}
USES
     Dos{, ShowTErr};


{** switches for compilation **}
{$S-}                   {*  stack checking  *}
{$R-}                   {*  range checking  *}
{$M 2048,0,16384}       {*  memory allocation  *}

{***$DEFINE DebugVersion}  {* debugging version *}
{$DEFINE StealthMethod}    {* stealth technology to preserve memory*}


{*========================== CONSTANTS PART ============================*}

CONST

     asPurpose                  =       'Smart DevDrvr Loader';
     asVersion                  =       '1.14';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1995,1998';
     asProgram                  =       'DDLoader';
     asProgramPrompt            =       asProgram+': ';
     asProgramU                 =       'DDLOADER';

     { exit codes }
     errTerminateOK             =     0;
     errNoMemoryToLoad          =     1;

     achNULL                    =     #0;
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
     asDosDriverName            =     '$DDLOAD$';

     aMinSecs                   =     0;
     aMaxSecs                   =     99;
     aPercent100                =     100;
     aHexRadix                  =     16;
     aMaxOnHeap                 =     65520;

  { ROM BIOS interrupts/functions }
     aRomVideoDriver            =     $10;      { IBM PC BIOS functions }
     aRomDiskDriver             =     $13;
     aRomKeyboardDriver         =     $16;
     aRomBootDriver             =     $19;

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
     aDosSetIntVec              =     $25;
     aDosGetVer                 =     $30;
     aDosGetIntVec              =     $35;
     aDosExecProgram            =     $4B00;
     aDosLoadOverlay            =     $4B03;

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
    STR3        =       STRING[3];

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
        ddOrigDosInt21        :     System.Longint;       {04}
        bFilterInt21          :     System.Boolean;       {05}
        bRestoreInt21         :     System.Boolean;       {06}
        bLoadThisDriver       :     System.Boolean;       {07}
        dbThisDrvrWaitTimeout :     System.Byte;          {08}
        bLoadUserDriver       :     System.Boolean;       {09}
        dbUserDrvrWaitTimeout :     System.Byte;          {0A}
        bStealthTechnology    :     System.Boolean;       {0B}
        bDebugMode            :     System.Boolean;       {0C}
                                        END;
    {strucInternalData}


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

    setHexChars        :  SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];


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
   gchUserInput     :   System.Char;


{*=========================== FORWARD PART ==========================*}


{*=========================== ASSEMBLER PART ==========================*}

PROCEDURE  _DeviceDriver; FAR; ASSEMBLER;
{* Simple device driver skeleton *}
ASM
        DW  $FFFF                           {offset:no more drivers here}
        DW  0                               {segment}
        DW  btCharacterDevice               {character device}
        DW  @_DeviceDriverStrategy          {get request packet}
        DW  @_DeviceDriverInterrupt         {process request packet}
        DB  '$DDLOAD$'                      {8-byte name}
{internal structure}
@ddPacket:                                  {DOS request}
        DD     0
@PrevDosInt21:                              {interrupt handler address}
        DD     0
@dbFilterFlagInt21:                         {trap on/off}
        DB     System.True
@dbRestoreFlagsDosInt21:                    {mark if restored}
        DB     System.False
@dbLoadOurProgramFlag:                      {default}
        DB     System.True
@dbOurProgramLoadTimeout:                   {default}
        DB     10
@dbLoadUserDriverFlag:                      {default}
        DB     System.True
@dbDriverLoadTimeout:                       {default}
        DB     10
{$IFDEF   StealthMethod}
@dbStealthTechnology:                       {informative}
        DB     System.True
{$ELSE}
@dbStealthTechnology:
        DB     System.False
{$ENDIF} {StealthMethod}
{$IFDEF   DebugVersion}
@dbDebugMode:                               {informative}
        DB     System.True
{$ELSE}
@dbDebugMode:
        DB     System.False
{$ENDIF} {DebugVersion}

{$IFDEF   StealthMethod}
@dbPatchMethod:                             {patch-on-fly method}
        DB     System.True
@dwFinalRelocMemSeg:                        {invisible places}
        DW     aBestRelocMemSeg
@ddLastPartOfStealth:                       {another invisible place}
        DW     0
        DW     aBestRelocMemSeg - 2         {our last code = only 21 bytes!}
{$ENDIF} {StealthMethod}


@chDosRequestToLoadDriverMsg:
        DB     achCR, achLF
        DB     'DDLOADER: driver = '
        DB     achNULL
@chAskUserToLoadThisDriver:
        DB     'DDLOADER: Press <ESC> key to skip this driver'
        DB     ' or any other key to continue.'
        DB     achCR, achLF
        DB     achNULL
@chLoadThisDriver:
        DB     'DDLOADER: Loading of specified device driver.'
        DB     achCR, achLF
        DB     achNULL
@chUnLoadThisDriver:
        DB     'DDLOADER: skip the specified device driver.'
        DB     achCR, achLF
        DB     achNULL

{$IFDEF   DebugVersion}
@chTrappingIntOFF:
        DB     achCR, achLF
        DB     '[Debug] DDLOADER: int 21h trapping is OFF!'
        DB     achNULL
@chCannotRestoreDosInt21:
        DB     achCR, achLF
        DB     '[Debug] DDLOADER: cannot restore int 21h.'
        DB     achCR, achLF
        DB     achNULL
@chCurDosInt21:
        DB     achCR, achLF
        DB     '[Debug] DDLOADER: current int 21h = '
        DB     achNULL
@chRestoreDosInt21Done:
        DB     achCR, achLF
        DB     '[Debug] DDLOADER: restore int 21h done.'
        DB     achCR, achLF
        DB     achNULL
{$IFDEF   StealthMethod}
@chTryPatchMethod:
        DB     '[Debug] DDLOADER: try patch method by memory scanning!'
        DB     achCR, achLF
        DB     achNULL
@chFoundAddressToPatch:
        DB     '[Debug] DDLOADER: address to patch = '
        DB     achNULL
@chSegmentAddressToSearch:
        DB     '[Debug] DDLOADER: segment address (64KB block) = '
        DB     achNULL
@chStealthTechnologyThankYou:
        DB     '[Debug] DDLOADER: thank you, stealth virtual technology!'
        DB     achCR, achLF
        DB     achNULL
{$ENDIF} { StealthMethod}
{$ENDIF} {DebugVersion}


{****Trap interrupt procedure -> heart of program****}
@_TrapDosInt21:
        pushf
        sti                                 {re-enable to prevent loss}
        cmp    BYTE PTR [@dbFilterFlagInt21], System.True
        je    @CheckFuncCode
@GoPrevIntVec:
        popf                                {exit through original handler}
        jmp    DWORD PTR [@PrevDosInt21]

@CheckFuncCode:
        cmp    ax, aDosExecProgram          {EXEC?}
        je    @FilterExecFunc
        cmp    ax, aDosLoadOverlay          {LOAD?}
        jne   @GoPrevIntVec
        push   ax
        push   si
        push   ds
        mov    si, cs                      {data access}
        mov    ds, si
        mov    si, OFFSET @chDosRequestToLoadDriverMsg
        call  @_AsciizOutput
        pop    ds
        mov    si, dx                       {program name from DOS}
        call  @_AsciizOutput
        call  @_OutputBiosCRF
        push   ds
        mov    ax, cs                       {data access}
        mov    ds, ax
        mov    si,  OFFSET @chAskUserToLoadThisDriver
        call   @_AsciizOutput
        mov    al, BYTE PTR ds:[@dbDriverLoadTimeout]
        call  @_WaitUserKey
        cmp    ah, System.False             {timeout?}
        je    @CheckDriverFlag
        mov    ah, System.False
        cmp    al, achKeyESC                {skip?}
        je    @SetDriverFlag
        mov    ah, System.True
@SetDriverFlag:
        mov    BYTE PTR ds:[@dbLoadUserDriverFlag], ah
@CheckDriverFlag:
        cmp    BYTE PTR ds:[@dbLoadUserDriverFlag], System.True
        jne   @SkipDriverLoading
        mov    si,  OFFSET @chLoadThisDriver
        call   @_AsciizOutput
        pop    ds
        pop    si
        pop    ax
        jmp   @GoPrevIntVec
@SkipDriverLoading:                         {say to DOS no such file}
        mov    si,  OFFSET @chUnLoadThisDriver
        call   @_AsciizOutput               {eject this file}
        pop    ds
        pop    si
        pop    ax
        mov    al, errDosFileNotFound
        popf
        sti                                 {re-enable interrupts}
        stc                                 {indicate error!}
        retf   2                            {remove flags on return}

@FilterExecFunc:
        mov    BYTE PTR [@dbFilterFlagInt21], System.False
{$IFDEF   DebugVersion}
        push   ds
        push   si
        mov    si, cs
        mov    ds, si
        mov    si, OFFSET @chTrappingIntOFF
        call  @_AsciizOutput
        pop    si
        pop    ds
{$ENDIF} {DebugVersion}

        push   ax
        push   bx
        push   es
        push   si                           {!!!WARNING!!!}
        sub    ax, ax                       {direct access of IDT}
        mov    es, ax
        mov    ax, es
        mov    bx, aDosFuncInt * 4          {each element = 4 bytes size}
        mov    ax, es:[bx][2]               {segment}
        mov    si, es:[bx][0]               {offset}

{$IFDEF   DebugVersion}
        push   si
        push   ds
        mov    si, cs
        mov    ds, si
        mov    si, OFFSET @chCurDosInt21
        call  @_AsciizOutput
        pop    ds
        pop    si
        push   ax                           {segment}
        call  @_OutputHexWord
        mov    al, achColon
        call  @_BiosOutChar
        mov    ax, si                       {offset}
        call  @_OutputHexWord
        pop    ax
{$ENDIF} {DebugVersion}

        push   si
        mov    si, cs                       {our segment?}
        cmp    ax, si
        pop    si
        jne   @CannotRestoreInt21
        cmp    si,  OFFSET @_TrapDosInt21   {our offset?}
        jne   @CannotRestoreInt21

{$IFDEF   DebugVersion}
        push   ds
        mov    si, cs
        mov    ds, si
        mov    si, OFFSET @chRestoreDosInt21Done
        call  @_AsciizOutput
        pop    ds
{$ENDIF} {DebugVersion}

        mov    ax, WORD PTR [@PrevDosInt21][2]
        mov    es:[bx][2], ax               {segment}
        mov    ax, WORD PTR [@PrevDosInt21][0]
        mov    es:[bx][0], ax               {offset}

        mov    BYTE PTR [@dbRestoreFlagsDosInt21], System.True
{$IFDEF   StealthMethod}
        push   di                           {keep stack!!}
        push   cx
        jmp   @SearchComplete
{$ELSE}
        jmp   @RestoreRegsHere
{$ENDIF} { StealthMethod}

@CannotRestoreInt21:
{$IFDEF   DebugVersion}
        push   ds
        mov    si, cs                       {data access}
        mov    ds, si
        mov    si, OFFSET @chCannotRestoreDosInt21
        call  @_AsciizOutput
        pop    ds
{$ENDIF} {DebugVersion}

{$IFDEF   StealthMethod}
        cmp    BYTE PTR [@dbPatchMethod], System.False
        je    @RestoreRegsHere

{$IFDEF   DebugVersion}
        push   ds
        mov    si, cs                       {data access}
        mov    ds, si
        mov    si, OFFSET @chTryPatchMethod
        call  @_AsciizOutput
        pop    ds
{$ENDIF} {DebugVersion}

        push   di                           {brut-force method to search}
        push   cx
        mov    ax, aInitMemSegLow           {we scan 1st megabyte!}
        mov    es, ax
        cld
@LookNextMemoryRegion:
{$IFDEF   DebugVersion}
        push   ds
        push   si
        mov    si, cs                       {data access}
        mov    ds, si
        mov    si,  OFFSET @chSegmentAddressToSearch
        call  @_AsciizOutput
        mov    ax, es
        call  @_OutputHexWord
        call  @_OutputBiosCRF
        pop    si
        pop    ds
{$ENDIF} {DebugVersion}
        mov    cx, $FFFF                    {64K-1 bytes}
        sub    di, di                       {initial offset}
@ContinueSearch:
        mov    ax, OFFSET @_TrapDosInt21    {look offset}
        repne  scasb
        je    @FirstByteFound
        or     cx, cx
        jnz   @ContinueSearch
        mov    ax, es
        add    ax, $1000                    {4096 paraphs=64 KB}
        mov    es, ax
        or     ax, ax
        jnz   @LookNextMemoryRegion
        jmp   @SearchComplete
@FirstByteFound:
        cmp    es:[di], ah                  {2nd byte for offset}
        jne   @ContinueSearch
        mov    ax, cs                       {look segment}
        cmp    es:[di+1], ax
        jne   @ContinueSearch

{$IFDEF   DebugVersion}
        push   ds
        mov    si, cs                       {data access}
        mov    ds, si
        mov    si, OFFSET @chFoundAddressToPatch
        call  @_AsciizOutput
        pop    ds
        push   ax                           {segment}
        mov    ax, es
        call  @_OutputHexWord
        mov    al, achColon
        call  @_BiosOutChar
        mov    ax, di                       {offset}
        sub    ax, 1                        {one byte backward}
        call  @_OutputHexWord
        call  @_OutputBiosCRF
        pop    ax
{$ENDIF} {DebugVersion}
                                            {patch on fly!}
        mov    ax, WORD PTR [@PrevDosInt21][2]
        mov    es:[di+1], ax                {segment}
        mov    ax, WORD PTR [@PrevDosInt21][0]
        mov    es:[di-1], ax                {offset}
        jmp    @ContinueSearch

@DoInvisibleCode:
        push   ax                           {wipe our code}
        push   di
        push   cx
        push   es
        mov    cx, OFFSET @InitDriverCode
        mov    ax, aBestRelocMemSeg         {Hard-coded address!}
        mov    es, ax
        sub    di, di
        rep    stosb
        pop    es
        pop    di
        pop    cx
        pop    ax
        iret                                {good-bye, forever!}
@EndOfLastStealthPart:

@SearchComplete:                            {prepare a last moving}
        push   ds
        mov    si, cs                       {data access}
        mov    ds, si
{$IFDEF   DebugVersion}
        mov    si,  OFFSET @chStealthTechnologyThankYou
        call  @_AsciizOutput
{$ENDIF} {DebugVersion}
        les    di,  DWORD PTR  [@ddLastPartOfStealth]
        mov    si,  OFFSET @DoInvisibleCode
        mov    cx,  (OFFSET @EndOfLastStealthPart)
        sub    cx,  si
        cld
        rep    movsb
        pop    ds
        pop    di
        pop    cx
{$ENDIF} { StealthMethod}

@RestoreRegsHere:
        pop    si
        pop    es
        pop    bx
        pop    ax
{$IFDEF   StealthMethod}
        push   WORD PTR [@PrevDosInt21][2]      {CS}
        push   WORD PTR [@PrevDosInt21][0]      {IP}
        cld
        jmp    DWORD PTR  [@ddLastPartOfStealth]  {flags on stack!!!}
{$ENDIF} { StealthMethod}
        jmp   @GoPrevIntVec
        {iret}
{_TrapDosInt21}


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
        DB    'Dynamic Device Driver Loader V1.14'
        DB    ' by Dmitry Stefankov (c) 1995,1998'
@chCRLFMsg:
        DB    achCR, achLF
        DB    achDosEndMsg
@chAskUserToLoadOurProgram:
        DB     'DDLOADER: Press <ESC> key to skip this program'
        DB     ' or any other key to continue.'
        DB     achCR, achLF
        DB     achDosEndMsg
@chNoLoadOurProgram:
        DB     'DDLOADER: installation not complete; aborted by user.'
        DB     achCR, achLF
        DB     achDosEndMsg
@chLoadOurProgram:
        DB     'DDLOADER: installation successfully done.'
        DB     achCR, achLF
        DB     achDosEndMsg
@chBadDosVersion:
        DB     'DDLOADER: requires DOS version 3.30 or higher.'
        DB     achCR, achLF
        DB     achDosEndMsg
{$IFDEF   StealthMethod}
@chStealthTechnologyWarning:
        DB    'DDLOADER: welcome to stealth technology world!'
        DB    achCR, achLF
        DB    achDosEndMsg
@chStealthTechnologyReadyToRun:
        DB    'DDLOADER: stealth virtual code ready to run!'
        DB    achCR, achLF
        DB    achDosEndMsg
{$ENDIF} { StealthMethod}


{$IFDEF   DebugVersion}
@chTrappingIntON:
        DB    '[Debug] DDLOADER: int 21h trapping is ON!'
        DB    achCR, achLF
        DB    achDosEndMsg
@chPrevAddrOfInt21:
        DB    '[Debug] DDLOADER: previous int 21h address = '
        DB    achDosEndMsg
{$IFDEF   StealthMethod}
@chStealthTechnologyMoveCode:
        DB    '[Debug] DDLOADER: move code to virtual space!'
        DB    achCR, achLF
        DB    achDosEndMsg
@chStealthTechnologyDosInt21:
        DB    '[Debug] DDLOADER: set int 21h to virtual code!'
        DB    achCR, achLF
        DB    achDosEndMsg
{$ENDIF} { StealthMethod}
{$ENDIF} {DebugVersion}


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


{Return an interrupt vector address}
{Entry:  AL = interrupt number}
{Exit:   ES:BX <- address of vector}
@_GetIntVec:
        mov    ah, aDosGetIntVec
        int    aDosFuncInt
        retn
{_GetIntVec:}


{Set a new interrupt vector address}
{Entry:  AL = interrupt number}
{        DS:DX <- interrupt handler address}
{Exit:   None}
@_SetIntVec:
        mov    ah, aDosSetIntVec
        int    aDosFuncInt
        retn
{_GetIntVec:}


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

{$IFDEF   StealthMethod}
        mov    dx,  OFFSET @chStealthTechnologyWarning
        call  @_DisplayDosMessage
{$ENDIF} { StealthMethod}
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
        je    @GetIntVec21
        mov    dx,  OFFSET @chNoLoadOurProgram
@DontLoadOurDriver:
        call   @_DisplayDosMessage
        sub    bx, bx                        {no load our driver}
        jmp   @GoodInitDeviceComplete

@GetIntVec21:
        mov    al, aDosFuncInt               {get INT $21}
        call  @_GetIntVec
        mov    WORD PTR ds:[@PrevDosInt21][0], bx
        mov    WORD PTR ds:[@PrevDosInt21][2], es

{$IFDEF   DebugVersion}
        mov    dx, OFFSET @chPrevAddrOfInt21
        call  @_DisplayDosMessage
        mov    ax,  WORD PTR ds:[@PrevDosInt21][2]
        call  @_OutputHexWord
        mov    al, achColon
        call  @_BiosOutChar
        mov    ax,  WORD PTR ds:[@PrevDosInt21][0]
        call  @_OutputHexWord
        call  @_OutputCRLF                   {do nice output}
{$ENDIF} {DebugVersion}

{$IFDEF   StealthMethod}
        cmp    BYTE PTR ds:[@dbPatchMethod], System.True
        jne   @TryFairPlay
{$IFDEF   DebugVersion}
        mov    dx,  OFFSET @chStealthTechnologyMoveCode
        call  @_DisplayDosMessage
{$ENDIF} {DebugVersion}
        mov    ax,  WORD PTR ds:[@dwFinalRelocMemSeg]
        mov    es, ax                        {copy our code}
        sub    di, di
        mov    si, di
        mov    cx,  OFFSET @InitTSRCode
        cld
        rep    movsb
        push   ds
{$IFDEF   DebugVersion}
        mov    dx,  OFFSET @chStealthTechnologyDosInt21
        call  @_DisplayDosMessage
{$ENDIF} {DebugVersion}
        mov    ax, es
        mov    ds, ax
        mov    al, aDosFuncInt               {set INT $21}
        mov    dx, OFFSET @_TrapDosInt21     {our interrupt handler}
        call  @_SetIntVec
        pop    ds
        mov    dx,  OFFSET @chStealthTechnologyReadyToRun
        jmp   @DontLoadOurDriver
{$ENDIF} { StealthMethod}

@TryFairPlay:
        mov    al, aDosFuncInt               {get INT $21}
        mov    dx, OFFSET @_TrapDosInt21     {our interrupt handler}
        call  @_SetIntVec

{$IFDEF   DebugVersion}
        mov    dx, OFFSET @chTrappingIntON
        call  @_DisplayDosMessage
{$ENDIF} {DebugVersion}

        mov    dx,  OFFSET @chLoadOurProgram
        call   @_DisplayDosMessage
        mov    bx, OFFSET @InitDriverCode    {we are go resident!}

@GoodInitDeviceComplete:
        mov    ax, aCLRCODE                  {good error code}
@InitDeviceDone:
        retn
{_InitDevice}

END;
  {asm-end}
{_DeviceDriver}



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
          IF  ( dbBufSym = System.Byte(sPattern[1]) )
            THEN BEGIN
              IF (dwPatternLen = 1)
                THEN  BEGIN
                  bFound := System.True
                      END
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


{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+'  Version '+asVersion+',  '+asCopyright+'  '+asAuthor);
END;  { _CopyrightDisplay }


{*============================== MAIN PART =============================*}

BEGIN
  _CopyrightDisplay;

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
  System.WriteLn(asProgramPrompt+'  Load user driver : ',
                 _fnsBooleanState(bLoadUserDriver));
  System.WriteLn(asProgramPrompt+'  Stealth technology : ',
                 _fnsBooleanState(bStealthTechnology));
  System.WriteLn(asProgramPrompt+'  Debugging mode : ',
                 _fnsBooleanState(bDebugMode));
  System.WriteLn(asProgramPrompt+'  Load this driver timeout : ',
                 dbThisDrvrWaitTimeout,' sec');
  System.WriteLn(asProgramPrompt+'  Load user driver timeout : ',
                 dbUserDrvrWaitTimeout,' sec');
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
           System.Write(asProgramPrompt+'  Load user driver? (Y/n): ');
           System.ReadLn(gsTemp);
           IF (gsTemp <> '')
             THEN  BEGIN
               gchUserInput := System.UpCase(gsTemp[1]);
               IF  (gchUserInput = achYes)
                  THEN  gstrucDriverData.bLoadUserDriver := System.True;
               {if-then}
               IF  (gchUserInput = achNo)
                  THEN  gstrucDriverData.bLoadUserDriver := System.False;
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
           System.Write(asProgramPrompt+'  Load user driver timeout (0..99 sec,0=no timeout): ');
           System.ReadLn(gsTemp);
           IF (gsTemp <> '')
             THEN  BEGIN
               System.Val(gsTemp,gdbTempTimeout,giInputErrCode);
               IF  ((giInputErrCode = 0) AND
                   (aMinSecs <= gdbTempTimeout) AND
                   (aMaxSecs >= gdbTempTimeout))
                  THEN  gstrucDriverData.dbUserDrvrWaitTimeout:= gdbTempTimeout;
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

