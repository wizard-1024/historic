{****************************************************************************
//                            File HD-MBOOT.PAS
//
//                OS boot loader with hard disk setup 
//
//      Copyright (c) 1993, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/HD-MBOOT/RCS/hd-mboot.pas $
//  $RCSfile: hd-mboot.pas $
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:22:59 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: hd-mboot.pas $
//      Revision 1.1  1998/10/03 14:22:59  dstef
//      Initial revision
//: 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                OPERATING-SYSTEM-LOADER FROM HARD DISK          }
{ FILE NAME             HD-MBOOT.PAS                                    }
{ PURPOSE               OS-loader from the fixed disk with a setup of   }
{                       the hard disk drive(s) type(s) at the boot time }
{ VERSION               1.33                                            }
{ DATE                  02-Sep-1997                                     }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Telephone: +007 (095) 944-6304                  }
{ INTERNET              wizard@radio-msu.net, dima@mccbn.ru             }
{ COPYRIGHT NOTICE      Copyright (C) 1993, 1997  Dmitry Stefankov      }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,           }
{                       NOT FOR COMMERCIAL PURPOSE                      }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 6.0                        }
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             None                                            }
{ RETURN                See error return codes definitions              }
{ REQUIRES              Source Code Files                               }
{                       NONE                                            }
{                       External Object Files                           }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Maintence Project Files                         }
{                       NONE                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           Bootstrap procedure                             }
{                       1. Setup work registers and relocate code       }
{                          to avoid overwriting                         }
{                       2. If drive 0 type must be installed            }
{                            then  setup BIOS vector $41                }
{                                  call disk BIOS set dsk parms fn      }
{                       3. If drive 1 type must be installed            }
{                            then  setup BIOS vector $46                }
{                                  call disk BIOS set dsk parms fn      }
{                       4. If boot drive prompt is active               }
{                             then  ask user about boot drive           }
{                                  (hard disk 0 or floppy diskette 0)   }
{                             otherwise try to load OS from hard disk 0 }
{                       Main program                                    }
{                       1. Read Master Boot Record.                     }
{                       2. Copy already installed drive types/settings  }
{                          if found and user will confirm               }
{                       3. Enter user command menu                      }
{                         3.1. Execute user command or return error     }
{                              with description of reason               }
{                      NOTE: Please use source code as program manual   }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   08-Sep-93  DS  initial release           }
{                       1.01   24-Sep-93  DS  added user menu           }
{                       1.10   19-Oct-93  DS  updated documentation and }
{                                             fixed some bugs           }
{                       1.11   22-Nov-93  DS  remove 286 code generation}
{                                             switch for our MBR        }
{                       1.20   17-May-94  DS  added RAM area support to }
{                                             override standard BIOS    }
{                                             RAM area at 0:300         }
{                       1.30   05-Dec-96  DS  Added support for advanced}
{                                             boot management (combined }
{                                             with loader like OS-BOOT) }
{                       1.31   26-Jul-97  DS  updated documentation     }
{                       1.32   02-Aug-97  DS  removed tabs              }
{                       1.33   02-Sep-97  DS  fixed open r/o file bug   }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   HARD_DISK_MASTER_BOOT_RECORD;


{*** other modules ***}
USES
    Dos{,ShowTErr};


{** switches for compilation **}
{$S-}           {*  stack checking   *}
{$R-}           {*  range checking   *}

{* generate version for loader code debugging *}
{***$DEFINE  DebugVersion}                  {debugging}
{***$DEFINE FormatLogicTest}                {format drive}
{***$DEFINE VerifyLogicTest}                {verify drive after formatting}
{$DEFINE AdvancedUserVersion}
{***$DEFINE  DriveType2}                    {default drive type is 2}
{***$DEFINE  PresentDiskDrive0}             {set drive type as default}
{***$DEFINE  PresentDiskDrive1}             {set drive type as default}
{***$DEFINE AdvancedBootManager}            {combine with other loader}


{*========================== CONSTANTS PART ============================*}

CONST
     { program definitions }
       asPurpose               =       'HD-MasterBoot';
       asVersion               =       '1.33';
       asAuthor                =       'Dima Stefankov';
       asCopyright             =       'Copyright (c) 1993, 1997';
       asProgram               =       'HD-MBoot';
       asProgramPrompt         =       asProgram+': ';

     { exit codes }
       errTerminateOK           =     0;
       errBootStrapDebug        =     1;
       errBadReadFixedDisk      =     2;
       errBadWriteFixedDisk     =     3;
       errUserInstallAbort      =     4;
       errUserWriteAbort        =     5;
       errMismatchLoaderCode    =     6;
       errBadNumeric            =     7;
       errBadInitFixedDisk      =     8;
       errFormatFailed          =     9;
       errBadGetParmsFixedDisk  =     10;

    { miscellaneous }
      asBlank                   =     '';
      asSpaces10                =     '          ';
      achHexPrefix              =     '$';
      aSectorSize               =     512;
      aSecSizeInWords           =     aSectorSize DIV 2;
      aMaxTpStrLen              =     255;
     aHexRadix                  =     16;


      achZero                   =     '0';
      achOne                    =     '1';
      achTwo                    =     '2';
      achThree                  =     '3';
      achFour                   =     '4';
      achFive                   =     '5';
      achSix                    =     '6';
      achSeven                  =     '7';
      achEight                  =     '8';
      achNine                   =     '9';

      achYes                    =     'Y';
      achNo                     =     'N';

      achHardBoot               =     'H';
      achFloppyBoot             =     'F';

      achAutoMode               =     'A';
      achManualMode             =     'M';

      achCopyCmd                =     'C';
      achDisplayCmd             =     'D';
      achFormatCmd              =     'F';
      achTestCmd                =     'T';
      achSetCmd                 =     'S';
      achRamAreaCmd             =     'R';
      achQuitCmd                =     'Q';

      aDefExt                   =     'BIN';
      aDosExtMark               =     '.';
      errOK                     =     0;

    { ASCII codes }
      achNULL                   =     #00;
      achLF                     =     #10;
      achCR                     =     #13;

    { text messages }
      asNotImplementedYet       =     'Not implemented yet.';

    {***** ATTENTION!!! Hard-coded values below. *****}
    {***** Please modify carefully!              *****}
{$IFDEF  DebugVersion}
      adwBootSeg                =     $8000;     { segment at 512K }
{$ELSE}
      adwBootSeg                =     $0000;     { segment at 0K }
{$ENDIF} {DebugVersion}
     adwBootOfs                 =     $7C00;
     adwABS0_Seg                =     $0000;
     adwBiosMemSizeLoc          =     $413;
     adwRelBootOfs              =     adwBootOfs + aSectorSize;
     adwPartitionTable          =     $1BE;
     aPartitonEntrySize         =     $10;
     aMaxAvailLogicalPartition  =     4;
     adwBootMarkOfs             =     adwPartitionTable + (aPartitonEntrySize*aMaxAvailLogicalPartition);
     adwBootSecID               =     $AA55;

     aDebugOff                  =     0;
     aDebugOn                   =     1;

     aBootPartitionID           =     $80;
     aRetryOpCount              =     10;

     aFarJumpOpCode             =     $EA;      { iAPX86 opcodes }
     aNearJumpOpCode            =     $E9;
     aShortJumpOpCode           =     $EB;

     aRomVideoDriver            =     $10;      { IBM PC BIOS functions }
     aRomDiskDriver             =     $13;
     aRomKeyboardDriver         =     $16;
     aRomBootDriver             =     $19;

     aBiosWaitKbdInput          =     $00;      { keyboard functions }

     btHeadsMoreThan8           =     $08;
     aDefInterleaveFactor       =     $03;
     aBadSectorFlag             =     $80;
     aGoodSectorFlag            =     $00;
     btSecNumMask               =     $3F;

     aHardDrive_0               =     $80;
     aHardDrive_1               =     aHardDrive_0 + $1;

     aBiosSecCountIs1           =     $01;
     aBiosSecNumIs1             =     $01;
     aBiosHeadNumIs0            =     $00;
     aBiosCylNumIs0             =     $00;

     aBiosResetOp               =     $00;      { disk functions }
     aBiosReadOp                =     $02;
     aBiosWriteOp               =     $03;
     aBiosVerifyOp              =     $04;
     aBiosFormatOp              =     $05;
     aBiosGetDriveParmsOp       =     $08;
     aBiosSetDriveParmsOp       =     $09;
     aBiosTestIsDriveReady      =     $10;
     aBiosRecalibrateDrive      =     $11;

     aRamAreaInBytes            =     2;
     aHardDiskSupportNum        =     2;
     aTotalRamAreaSize          =     aRamAreaInBytes * aHardDiskSupportNum;
     aDiskParmTableSize         =     $10;                      {* Hard-Coded Values!!     *}
     aDiskParmTableSizeDiv2     =     aDiskParmTableSize DIV 2;
     aInitBitFlagsOfs           =     $1D;
     aTotalSettingsSize         =     aDiskParmTableSize * aHardDiskSupportNum + 1+aTotalRamAreaSize;
     aBootDiskDriveTableOfs     =     aInitBitFlagsOfs + 1;


     aIntelVecSize              =     4;
     aDrvParmVec_0              =     $41;
     aDrvParmVec_1              =     $46;
     aDrvParmVec_LowMemLoc_0    =     aDrvParmVec_0 * aIntelVecSize;
     aDrvParmVec_LowMemLoc_1    =     aDrvParmVec_1 * aIntelVecSize;


  {** ATTENTION!!! Use another memory locations if any problem occurred **}
     aLowMemParmVecStoreArea_0  =     $C0 * aIntelVecSize;
     aLowMemParmVecStoreArea_1  =     $C4 * aIntelVecSize;

  { copyright notice for detection of already installed copy }
    asSearchNotice             =     'HD-MBoot 1993 D.Stefankov';

  { DOS partition magic values }
    aDos12                     =      $01;
    aDos16                     =      $04;
    aDosBig                    =      $06;
    aSecsPerFAT12              =      4096;
    aSecsPerFAT16              =      65536;
    aSecsPerFATBIG             =      $FFFFFFFF;

  { IBM magic values }
    aPcTypeIsAT                =      $FC;
    adwTestMemBufSeg           =      $8000;           { 512 K }
    adwTestMemBufOfs           =      $0;

  { bit-mapped flags }
    btFullMaskFF               =      $FF;
    btSetDiskType_0            =      $01;
    btSetDiskType_1            =      $02;
    btReserved_02              =      $04;
    btReserved_03              =      $08;
    btReserved_04              =      $10;
    btReserved_05              =      $20;
    btReserved_06              =      $40;
    btAskBootDisk              =      $80;
{$IFDEF  PresentDiskDrive0}
    btInitialDiskType_0        =      btSetDiskType_0;
{$ELSE}
    btInitialDiskType_0        =      $00;
{$ENDIF} {PresentDiskDrive0}
{$IFDEF  PresentDiskDrive1}
    btInitialDiskType_1        =      btSetDiskType_1;
{$ELSE}
    btInitialDiskType_1        =      $00;
{$ENDIF} {PresentDiskDrive1}
    btInitialDiskTypes         =      btInitialDiskType_0 + btInitialDiskType_1;


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
  {* strings *}
       STR2                     =     STRING[2];
       STR3                     =     STRING[3];
       STR4                     =     STRING[4];
       STR5                     =     STRING[5];
       STR8                     =     STRING[8];

    {* Information about logical disk *}
    recLogicalPartition  =  RECORD
                 dbBootDriveMark              :       System.Byte;      {00}
                 dbStartingHead               :       System.Byte;      {01}
                 dwStartingCylSec             :       System.Word;      {02}
                 dbOperatingSystemID          :       System.Byte;      {04}
                 dbEndingHead                 :       System.Byte;      {05}
                 dwEndingCylSec               :       System.Word;      {06}
                 ddPrecedingSecs              :       System.Longint;   {08}
                 ddSecsPerPartition           :       System.Longint;   {0C}
                           END;
    {* recLogicalPartition *}

    {* Master Boot Sector *}
    recMasterBoot  =  RECORD
         dbReservedCode           :  ARRAY[0..adwPartitionTable-1] OF System.Byte;                  {000}
         recDiskPartitionsTable   :  ARRAY[0..aMaxAvailLogicalPartition-1] OF recLogicalPartition;  {1BE}
         dwValidBootRecID         :  System.Word;                                                   {1FE}
                           END;
    {* recMasterBoot *}


    {* Hard Disk Parameters Table *}
    recHARD_DISK_PARMS  = RECORD
                dwMAX_CYLS_NUM               :    System.Word;     {00}
                dbMAX_HEADS_NUM              :    System.Byte;     {02}
                dwSTART_WRC_XT               :    System.Word;     {03}
                dwSTART_WRC                  :    System.Word;     {05}
                dbMAX_ECC_DATA_BURST_LEN     :    System.Byte;     {07}
                dbCONTROL_BYTE               :    System.Byte;     {08}
                dbSTD_TIME_OUT_XT            :    System.Byte;     {09}
                dbFMT_TIME_OUT_XT            :    System.Byte;     {0A}
                dbCHECK_TIME_OUT_XT          :    System.Byte;     {0B}
                dwLANDING_ZONE               :    System.Word;     {0C}
                dbSECTORS_PER_TRACK          :    System.Byte;     {0E}
                dbPARM_RESERVED              :    System.Byte;     {0F}
                          END;
    {* recHARD_DISK_PARMS *}


{*====================== TYPED CONSTANTS PART ==========================*}

CONST
   ddPrevIntVec41            :   System.Pointer         =       NIL;
   ddPrevIntVec46            :   System.Pointer         =       NIL;
   gbSetupParmsForDrive_0    :   System.Boolean         =       System.False;
   gbSetupParmsForDrive_1    :   System.Boolean         =       System.False;

   setHexChars        :  SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];


{*=========================== VARIABLES PART ===========================*}

VAR
   grecFixedDiskBoot         :   recMasterBoot;
   grecOrigFixedDiskBoot     :   recMasterBoot;
   grecHARD_DISK_PARMS_0     :   recHARD_DISK_PARMS;
   grecHARD_DISK_PARMS_1     :   recHARD_DISK_PARMS;
   gfOutStream               :   FILE  OF  recMasterBoot;
   gdbFormatSectorBuffer     :   ARRAY[0..aSectorSize-1]  OF  System.Byte;
   gsTempInput               :   STRING;
   gdwOurBootRecLen          :   System.Word;
   gdwMemOfs                 :   System.Word;
   gbUserAskExit             :   System.Boolean;
   gbPCATFoundOk             :   System.Boolean;
   gbOriginalMBRpresent      :   System.Boolean;

   gdbPcType                 :   System.Byte  ABSOLUTE  $F000:$FFFE;



{*=========================== PROCEDURAL PART ==========================*}



PROCEDURE _IPL_Code; near; assembler;
{* Initial program loader. *}
{* Note 1: This procedure must be always at beginning. *}
{* Note 2: The length of code must be <= $1BE for non-debugging version. *}
asm
{$IFDEF  DebugVersion}
        cmp      ax, aDebugOff        { Test for relocated code marker }
        je       @InitCode

        mov      bx, cs               { Our Procedure in TP code segment }
        mov      ds, bx               { We move it to new segment for debugging }
        mov      ax, adwBootSeg
        mov      es, ax
        mov      cx, aSecSizeInWords
        mov      si, 0
        mov      di, adwBootOfs
        push     es                   { Jump Segment into Stack }
        push     di                   { Jump Offset  into Stack }
        cld
        rep      movsw

        mov      ax, aDebugOff        { we had relocated code }
        retf                          { jump to relocated code }

  @InitCode:
{$ENDIF} {DebugVersion}

        cli                           { disable ints during regs setup }
{$IFDEF  DebugVersion}
        mov      ax, adwBootSeg
{$ELSE}
        sub      ax, ax
{$ENDIF} {DebugVersion}
        mov      ds, ax               { set seg registers to zero = ABS0 seg }
        mov      es, ax
        mov      ss, ax               { stack at $0000:$7C00 }
        mov      sp, adwBootOfs

        sti                           { re-enable interrupts }
        cld                           { go forward }
        mov      si, sp               { DS:SI -> 0:$7C00 }
        mov      di, adwRelBootOfs    { ES:DI -> 0:$7E00 }
        mov      cx, aSecSizeInWords  { words count }
        rep      movsw                { relocate code to safe place }
                                      { jump to continue from new place }
        db       aFarJumpOpCode       { Direct FAR Jump }
        dw       adwRelBootOfs + (OFFSET @NewStart)
        dw       adwBootSeg
                                      { messages for user }
                                      { offset to ref        =>  $1D }
  @bBitMappedFlags:
        db       btInitialDiskTypes

  @ParametersTableForDrive_0:
 {**       db       aDiskParmTableSize     DUP (0)  **}
{$IFDEF  DriveType2}
           dw       615
           db       4
           dw       0
           dw       300
           db       0
           db       0
           db       0
           db       0
           db       0
           dw       615
           db       17
           db       0
{$ELSE}
           dw       0, 0, 0, 0
           dw       0, 0, 0, 0
{$ENDIF}  {DriveType2}

  @ParametersTableForDrive_1:
 {**       db       aDiskParmTableSize     DUP (0)  **}
{$IFDEF  DriveType2}
           dw       615
           db       4
           dw       0
           dw       300
           db       0
           db       0
           db       0
           db       0
           db       0
           dw       615
           db       17
           db       0
{$ELSE}
           dw       0, 0, 0, 0
           dw       0, 0, 0, 0
{$ENDIF}  {DriveType2}
  @RamAreaForUserDefinedType_0:
           dw       aLowMemParmVecStoreArea_0
  @RamAreaForUserDefinedType_1:
           dw       aLowMemParmVecStoreArea_1

  @BootHello_MSG:
        db       'HD-MBoot 1993 D.Stefankov'
        db       achNULL

  @InitDriveType_0_MSG:
        db       '<Do HD0>'
        db       achNULL

  @InitDriveType_1_MSG:
        db       '<Do HD1>'
        db       achNULL

  @InitDriveFailed_MSG:
        db       '<Bad Init>'
        db       achNULL

  @ScanPartitionTable_MSG:
{$IFDEF   AdvancedBootManager}
        db       '<Find boot2>'
{$ELSE}  {AdvancedBootManager}
        db       '<Scan Boot Tbl>'
{$ENDIF  {AdvancedBootManager}
        db       achNULL

  @LoadOS_MSG:
{$IFDEF   AdvancedBootManager}
        db       '<Load boot2>'
{$ELSE}  {AdvancedBootManager}
        db       '<Load OS>'
{$ENDIF  {AdvancedBootManager}
        db       achCR,achLF
        db       achNULL

  @BadPartition_MSG:
        db       '<Bad Partition Table>'
        db       achNULL

  @ErrLoadOS_MSG:
{$IFDEF   AdvancedBootManager}
        db       '<Error load boot2>'
{$ELSE}  {AdvancedBootManager}
        db       '<Error load OS>'
{$ENDIF  {AdvancedBootManager}
        db       achNULL

  @BadOS_MSG:
{$IFDEF   AdvancedBootManager}
        db       '<Missing boot2>'
{$ELSE}  {AdvancedBootManager}
        db       '<Missing OS>'
{$ENDIF  {AdvancedBootManager}
        db       achNULL

  @AskWhereBootFrom_MSG:
        db       '<Boot H/F?>'
        db       achCR,achLF
        db       achNULL

  @NewStart:
        mov      si, OFFSET  @BootHello_MSG
        call     @AsciizOutput        { Display string in format <ASCII+zero> }


 @InitDriveParametersTable_0:
        mov      dh, BYTE PTR  [(OFFSET @bBitMappedFlags)+adwRelBootOfs]
        mov      di, WORD PTR [(OFFSET @RamAreaForUserDefinedType_0)+adwRelBootOfs]
        mov      dl, aHardDrive_0

        test     dh, btSetDiskType_0
        jz      @InitDriveParametersTable_1

        mov      si, OFFSET  @InitDriveType_0_MSG
        call     @AsciizOutput        { Display string in format <ASCII+zero> }

        mov      si, (OFFSET @ParametersTableForDrive_0) + adwRelBootOfs
        mov      bx, aDrvParmVec_LowMemLoc_0
        call     @InitDriveParm


 @InitDriveParametersTable_1:
        test      dh, btSetDiskType_1
        jz      @CheckAboutAsk

        mov      si, OFFSET  @InitDriveType_1_MSG
        call     @AsciizOutput        { Display string in format <ASCII+zero> }

        mov      si, (OFFSET @ParametersTableForDrive_1) + adwRelBootOfs
        mov      di, WORD PTR [(OFFSET @RamAreaForUserDefinedType_1)+adwRelBootOfs]
        mov      bx, aDrvParmVec_LowMemLoc_1
        inc      dl
        call     @InitDriveParm

 @CheckAboutAsk:
        test     dh, btAskBootDisk
        jz      @LookBootTable

 @AskAgain:
        mov      si, OFFSET  @AskWhereBootFrom_MSG
        call     @AsciizOutput        { Display string in format <ASCII+zero> }
        mov      ah, aBiosWaitKbdInput
        int      aRomKeyboardDriver
        and      al, 11011111B        { make uppercase }
        cmp      al, achHardBoot
        je      @LookBootTable
        cmp      al, achFloppyBoot
        jne     @AskAgain
        int      aRomBootDriver

  @LookBootTable:
        mov      si, OFFSET  @ScanPartitionTable_MSG
        call     @AsciizOutput        { Display string in format <ASCII+zero> }

{$IFDEF   AdvancedBootManager}
        jmp     @TryLoadOS

{$ELSE}  {AdvancedBootManager}
        mov      cx, aMaxAvailLogicalPartition
        mov      si, adwRelBootOfs + adwPartitionTable - aPartitonEntrySize

  @IsBootablePartition:
        add      si, aPartitonEntrySize
        cmp      BYTE PTR [si], aBootPartitionID
        je      @TryLoadOS

        dec      cx
        jnz      @IsBootablePartition

  @BadPartition:                      { bad partition table }
        mov      si, OFFSET  @BadPartition_MSG
{$ENDIF  {AdvancedBootManager}

  @BootStop:
        call     @AsciizOutput        { Display string in format <ASCII+zero> }

  @StopCPU:
        jmp      @StopCPU             { loop forever }

  @TryLoadOS:
{$IFDEF   AdvancedBootManager}
        mov      dx, (aBiosHeadNumIs0 SHL 8) + aHardDrive_0 { DH = head 0, DL = fixed drive 0}
        mov      cx, aBiosSecNumIs1+1 { CX = cyl 0/sec 2}
{$ELSE}  {AdvancedBootManager}
        mov      dx, [si]             { DH = head, DL = drive }
        mov      cx, [si+2]           { CX = cyl/sec }
{$ENDIF  {AdvancedBootManager}

        mov      bx, adwBootOfs       { ES:BX -> buffer }
        mov      bp, aRetryOpCount    { retry count }

  @TryLoad:
       mov      ax, (aBiosReadOp SHL 8) + aBiosSecCountIs1
                                      { read a sector from disk to memory }
       int      aRomDiskDriver        { call ROM BIOS disk driver }
       jnc      @SectorLoaded         { jump if driver says OK }
       mov      ah, (aBiosResetOp)    { reset controller }
       int      aRomDiskDriver        { call ROM BIOS disk driver }
       dec      bp                    { decrement a retries counter }
       jnz      @TryLoad

  @BadDisk:                           { may be disk bad? }
       mov      si, OFFSET  @ErrLoadOS_MSG
       jmp     @BootStop

  @SectorLoaded:
        mov    si, OFFSET  @BadOS_MSG  { non-bootable sector }
        cmp     word ptr [bx+adwBootMarkOfs], adwBootSecID
        jne    @BootStop

        push     es                   { indirect far jump }
        push     bx

        mov      si, OFFSET  @LoadOS_MSG
        call     @AsciizOutput        { Display string in format <ASCII+zero> }

        retf


 {** _InitDriveParm  PROC NEAR **}
  @InitDriveParm:
        mov      [bx], di             { store a new vector }
        mov      [bx+2], ds
        mov      cx, aDiskParmTableSizeDiv2
        rep      movsw
        mov      ah, aBiosSetDriveParmsOp
        int      aRomDiskDriver       { call ROM BIOS disk driver }
        jnc     @Done

  @InitFailed:
       mov      si, OFFSET  @InitDriveFailed_MSG
       jmp     @BootStop

 {** _InitDriveParmENDP  **}


 {** _AsciizOutput  PROC NEAR **}
  @AsciizOutput:
        mov    al, achCR              { output pair CR/LF }
        call    @BiosOutChar    
        mov    al, achLF  
        call    @BiosOutChar
        add    si, adwRelBootOfs      { fix problem with relocation }

  @NextChar:
        lodsb                         { get char }
        or       al, al               { AL is zero? }
        jz       @Done                { exit if match }
        call    @BiosOutChar
        jmp      @NextChar
        
 {** BiosOutChar  PROC NEAR **} 
@BiosOutChar:   
        mov      bx, 0007h            { white-on-black }
        mov      ah, 0Eh              { TTY function }
        int      aRomVideoDriver      { call ROM BIOS video driver }
  @Done:
        {retn}                        { return to caller }
                                      {! Generates automatically by TP!}
 {** _AsciizOutput  ENDP  **}

END; {end-asm}
{ _IPL_Code }



{**** procedural part 1 ****}

PROCEDURE    _DummyProc; near; assembler;
{* It is used for reference only. Don't remove this code!!! *}
{reserved space = 128 bytes}
asm
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
   DB  achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL, achNULL
END;
{ _DummyProc }



{*=========================== FUNCTIONAL PART ==========================*}


FUNCTION  _fndbHexCharToBin(chIn: System.Char) : System.Byte; assembler;
{* Converts the hexadecimal char to decimal. *}
asm
        mov   al, chIn       { AL = chIn }
        sub   al,'0'         { AL <- AL - '0' }

        cmp   al,9           { test for digit }
        jbe   @Done

        and   al,11011111b   { make uppercase }
        sub   al,'A'-'9'-1   { AL = 'A'..'F' }

      @Done:
                        { AL = function result }
END;
  {asm-end}
{ HexCharToDec }


FUNCTION  _fnliHexStrToBin(sHexInput : STRING; VAR iErrCode : System.Integer) : System.Longint;
{* Converts hexadecimal string to decimal number. *}
VAR
  ddNumber               :       System.Longint;
  dbStrIndex, dbStrLen   :       System.Byte;

BEGIN
  iErrCode   := 0;
  ddNumber   := 0;
  dbStrIndex := 1;
  dbStrLen   := System.Length(sHexInput);

  WHILE (iErrCode = 0) and (dbStrLen > 0) DO
  BEGIN
    IF  (sHexInput[dbStrIndex] IN setHexChars)
    THEN  BEGIN
               ddNumber := ddNumber * aHexRadix + _fndbHexCharToBin(sHexInput[dbStrIndex]);
               System.Inc(dbStrIndex);
               System.Dec(dbStrLen);
          END
    ELSE
        iErrCode  := -1;
    {if-then-else}
  END;
  {while-do}

  _fnliHexStrToBin := ddNumber;
END;  { _fnliHexStrToBin }



FUNCTION   _fnsByteToHexFmt(dbInput : System.Byte) : STR2;
{* Converts a byte to the hex format number representation. *}
CONST
    dbHexCharTable : ARRAY[0..15] OF System.Char = '0123456789ABCDEF';

BEGIN
  _fnsByteToHexFmt := dbHexCharTable[dbInput SHR 4] +
                      dbHexCharTable[dbInput AND $0F];
END;  { _fnsByteToHexFmt }


FUNCTION   _fnsWordToHexFmt(dwInput : System.Word) : STR4;
{* Converts a word to the hex format number representation. *}
BEGIN
  _fnsWordToHexFmt := _fnsByteToHexFmt(System.Hi(dwInput)) +
                      _fnsByteToHexFmt(System.Lo(dwInput));
END;  { _fnsWordToHexFmt }


FUNCTION  _fnddDoBiosCylSecNum(dwCyl,dwSec : System.Word) : System.Longint;
{* Construct a BIOS compatible cyl/sec pair. *}
BEGIN
   _fnddDoBiosCylSecNum := ((dwCyl AND $00FF) SHL 8) +
                           ((dwCyl AND $0300) SHR 2) +
                            (dwSec AND $003F);
END;
{ _fnddDoBiosCylSecNum }


FUNCTION  _fnsForceFileExtension(sFileName, sDefExt : STRING) : STRING;
{* Add extension for filename if not present. *}
BEGIN
   IF (System.Pos(aDosExtMark,sFileName) = 0)
     THEN sFileName := sFileName + aDosExtMark + sDefExt;
   {if-then}
  _fnsForceFileExtension := sFileName;
END;
{ _fnsForceFileExtension }


FUNCTION   _fnchGetFirstChar(sInput : STRING) : System.Char;
{* Returns a first char from string. *}
VAR
  chTemp  :  System.Char;

BEGIN
   IF (System.Length(sInput) <> 0)
     THEN  chTemp := sInput[1]
     ELSE  chTemp := System.Char(achNULL);
   {if-then-else}
  _fnchGetFirstChar := chTemp;
END;
{ _fnchGetFirstChar }


FUNCTION  _fndwGetValue(sInput : STRING)  : System.Word;
{* Translates string to its numeric representation. *}
VAR
  iErrorCode   :  System.Integer;
  dwTempValue  :  System.Word;

BEGIN
   System.Val(sInput,dwTempValue,iErrorCode);
   IF (iErrorCode <> 0)
      THEN  BEGIN
         System.WriteLn(asProgramPrompt+' Bad numeric value.');
         System.Halt(errBadNumeric);
             END;
   {if-then}

  _fndwGetValue := dwTempValue;
END;
{ _fndwGetValue }


FUNCTION  _fnsNumToStr(dwNum,dwWidth : System.Word) : STRING;
{* Convert a numeric value to its string representation. *}
VAR
  sTemp : STRING;

BEGIN
   System.Str(dwNum:dwWidth,sTemp);
  _fnsNumToStr := sTemp;
END;
{ _fnsNumToStr }


FUNCTION  _fnsNumToStr3(dwNum : System.Word) : STR3;
{* Convert a numeric value to its string representation. *}
VAR
  sTemp : STR3;

BEGIN
   System.Str(dwNum:3,sTemp);
  _fnsNumToStr3 := sTemp;
END;
{ _fnsNumToStr3 }


FUNCTION  _fnsNumToStr4(dwNum : System.Word) : STR4;
{* Convert a numeric value to its string representation. *}
VAR
  sTemp : STR4;

BEGIN
   System.Str(dwNum:4,sTemp);
  _fnsNumToStr4 := sTemp;
END;
{ _fnsNumToStr4 }


FUNCTION  _fnsNumToStr5(dwNum : System.Word) : STR5;
{* Convert a numeric value to its string representation. *}
VAR
  sTemp : STR5;

BEGIN
   System.Str(dwNum:5,sTemp);
  _fnsNumToStr5 := sTemp;
END;
{ _fnsNumToStr5 }




{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+
                    '  Version '+
                    asVersion+
                    ',  '+
                    asCopyright+
                    '  '+
                    asAuthor);
END;  { _CopyrightDisplay }


PROCEDURE  _GetDiskDriveParameters(dbDriveNum : System.Byte);
{* Gets the user defined parameters for disk drive. *}
VAR
   recDriveParms   :   recHARD_DISK_PARMS;
   sTemp           :   STRING;
   bAutoMode       :   System.Boolean;

BEGIN
     System.Write(asProgramPrompt+'Enter parameters hard drive ',dbDriveNum,': (Y/N): ');
     System.ReadLn(sTemp);
     IF  (System.UpCase(_fnchGetFirstChar(sTemp)) <> achNo)
       THEN  BEGIN
          System.Move(System.Mem[System.Seg(_IPL_Code):
                        (aBootDiskDriveTableOfs+(aDiskParmTableSize*dbDriveNum))],
                      recDriveParms,
                      aDiskParmTableSize);

          System.Write(asProgramPrompt+'Select mode to enter data (A=auto,M=manual)? (A/M): ');
          System.ReadLn(sTemp);
          bAutoMode := System.True;

          IF  (System.UpCase(_fnchGetFirstChar(sTemp)) = achManualMode)
            THEN  bAutoMode := System.False;
          {if-then}

          WITH  recDriveParms  DO
          BEGIN
             System.Write(asProgramPrompt+'Number of cylinders (CR=',dwMAX_CYLS_NUM,'): ');
             System.ReadLn(sTemp);
             IF (sTemp <> asBlank)
               THEN  dwMAX_CYLS_NUM := _fndwGetValue(sTemp);
             {if-then}
             System.Write(asProgramPrompt+'Number of heads (CR=',dbMAX_HEADS_NUM,'): ');
             System.ReadLn(sTemp);
             IF (sTemp <> asBlank)
               THEN  dbMAX_HEADS_NUM := System.Lo(_fndwGetValue(sTemp));
             {if-then}
             IF (dbMAX_HEADS_NUM > btHeadsMoreThan8)
                 THEN  dbCONTROL_BYTE := dbCONTROL_BYTE OR btHeadsMoreThan8;
             {if-then}
             IF (bAutoMode)
              THEN  {empty}
              ELSE  BEGIN
                 System.Write(asProgramPrompt+'Starting write-precompensation cylinder for XT (CR=',dwSTART_WRC_XT,'): ');
                 System.ReadLn(sTemp);
                 IF (sTemp <> asBlank)
                   THEN  dwSTART_WRC_XT := _fndwGetValue(sTemp);
                 {if-then}
                   END;
             {if-then}
             System.Write(asProgramPrompt+'Starting write-precompensation cylinder (CR=',dwSTART_WRC,'): ');
             System.ReadLn(sTemp);
             IF (sTemp <> asBlank)
               THEN  dwSTART_WRC := _fndwGetValue(sTemp);
             {if-then}
             IF (bAutoMode)
              THEN  {empty}
              ELSE  BEGIN
                 System.Write(asProgramPrompt+'ECC data burst length (CR=',dbMAX_ECC_DATA_BURST_LEN,'): ');
                 System.ReadLn(sTemp);
                 IF (sTemp <> asBlank)
                   THEN  dbMAX_ECC_DATA_BURST_LEN := System.Lo(_fndwGetValue(sTemp));
                 {if-then}
                 System.Write(asProgramPrompt+'Control Byte (CR=',dbCONTROL_BYTE,'): ');
                 System.ReadLn(sTemp);
                 IF (sTemp <> asBlank)
                   THEN  dbCONTROL_BYTE := System.Lo(_fndwGetValue(sTemp));
                 {if-then}
                 System.Write(asProgramPrompt+'Standard time-out for XT (CR=',dbSTD_TIME_OUT_XT,'): ');
                 System.ReadLn(sTemp);
                 IF (sTemp <> asBlank)
                   THEN  dbSTD_TIME_OUT_XT := System.Lo(_fndwGetValue(sTemp));
                 {if-then}
                 System.Write(asProgramPrompt+'Format time-out for XT (CR=',dbFMT_TIME_OUT_XT,'): ');
                 System.ReadLn(sTemp);
                 IF (sTemp <> asBlank)
                   THEN  dbFMT_TIME_OUT_XT := System.Lo(_fndwGetValue(sTemp));
                 {if-then}
                 System.Write(asProgramPrompt+'Check time-out for XT (CR=',dbCHECK_TIME_OUT_XT,'): ');
                 System.ReadLn(sTemp);
                 IF (sTemp <> asBlank)
                   THEN  dbCHECK_TIME_OUT_XT := System.Lo(_fndwGetValue(sTemp));
                 {if-then}
                   END;
             {if-then}
             System.Write(asProgramPrompt+'Landing zone (CR=',dwLANDING_ZONE,'): ');
             System.ReadLn(sTemp);
             IF (sTemp <> asBlank)
               THEN  dwLANDING_ZONE := _fndwGetValue(sTemp);
             {if-then}
             System.Write(asProgramPrompt+'Number of sectors/track (CR=',dbSECTORS_PER_TRACK,'): ');
             System.ReadLn(sTemp);
             IF (sTemp <> asBlank)
               THEN  dbSECTORS_PER_TRACK := System.Lo(_fndwGetValue(sTemp));
             {if-then}
             IF (bAutoMode)
              THEN  {empty}
              ELSE  BEGIN
                 System.Write(asProgramPrompt+'Reserved byte (CR=',dbPARM_RESERVED,'): ');
                 System.ReadLn(sTemp);
                 IF (sTemp <> asBlank)
                   THEN  dbPARM_RESERVED := System.Lo(_fndwGetValue(sTemp));
                 {if-then}
                   END;
             {if-then}
          END;
          {with-do}

          WITH  (recDriveParms)  DO
          BEGIN
             System.WriteLn(asProgramPrompt+'===== User defined parameters for fixed disk ',
                            dbDriveNum,' ===== ');
             System.WriteLn(asProgramPrompt+'Number of cylinders = ',dwMAX_CYLS_NUM);
             System.WriteLn(asProgramPrompt+'Number of heads = ',dbMAX_HEADS_NUM);
             System.WriteLn(asProgramPrompt+'Starting write-precompensation cylinder for XT = ',dwSTART_WRC_XT);
             System.WriteLn(asProgramPrompt+'Starting write-precompensation cylinder = ',dwSTART_WRC);
             System.WriteLn(asProgramPrompt+'ECC data burst length = ',dbMAX_ECC_DATA_BURST_LEN);
             System.WriteLn(asProgramPrompt+'Control Byte = ',dbCONTROL_BYTE);
             System.WriteLn(asProgramPrompt+'Standard time-out for XT = ',dbSTD_TIME_OUT_XT);
             System.WriteLn(asProgramPrompt+'Format time-out for XT = ',dbFMT_TIME_OUT_XT);
             System.WriteLn(asProgramPrompt+'Check time-out for XT = ',dbCHECK_TIME_OUT_XT);
             System.WriteLn(asProgramPrompt+'Landing zone = ',dwLANDING_ZONE);
             System.WriteLn(asProgramPrompt+'Number of sectors/track = ',dbSECTORS_PER_TRACK);
             System.WriteLn(asProgramPrompt+'Reserved byte = ',dbPARM_RESERVED);
          END;
          {with-do}

          System.Write(asProgramPrompt+'All entered data correct? (N/Y): ');
          System.ReadLn(sTemp);
          IF  (System.UpCase(_fnchGetFirstChar(sTemp)) = achYes)
            THEN  BEGIN
             System.WriteLn(asProgramPrompt+'User data for drive ',dbDriveNum,' accepted.');
             System.Move(recDriveParms,
                         System.Mem[System.Seg(_IPL_Code):
                                (aBootDiskDriveTableOfs+(aDiskParmTableSize*dbDriveNum))],
                          aDiskParmTableSize);
                   END
            ELSE   BEGIN
             System.WriteLn(asProgramPrompt+'No accepted user data for drive ',dbDriveNum,'.');
                   END;
          {if-then-else}
             END;
     {if-then}
END;
{ _GetDiskDriveParameters }


PROCEDURE  _AttachOrDeAttachDrive(dbDriveNum : System.Byte);
{* Enable/disable drive type setting at boot time. *}
VAR
   dbDriveMask  :  System.Byte;

BEGIN
    dbDriveMask := System.Mem[System.Seg(_IPL_Code):aInitBitFlagsOfs];
    IF ((dbDriveMask AND (1 SHL dbDriveNum)) = 0)
      THEN  BEGIN
        System.WriteLn(asProgramPrompt+'Drive ',dbDriveNum,' was inactive. Now active.');
            END
      ELSE  BEGIN
        System.WriteLn(asProgramPrompt+'Drive ',dbDriveNum,' was active. Now inactive.');
            END;
    {if-then-else}
    System.Mem[System.Seg(_IPL_Code):(aInitBitFlagsOfs)] := dbDriveMask XOR (1 SHL dbDriveNum);
END;
{ _AttachOrDeAttachDrive }


PROCEDURE  _ToggleBootDriveAsk;
{* Enable/disable drive type setting at boot time. *}
VAR
   dbAskBootDrive  :  System.Byte;

BEGIN
    dbAskBootDrive := System.Mem[System.Seg(_IPL_Code):(aInitBitFlagsOfs)];
    IF ((dbAskBootDrive AND System.Byte(btAskBootDisk)) <> 0)
      THEN  BEGIN
        System.WriteLn(asProgramPrompt+'Boot drive prompt was active. Now inactive.');
            END
      ELSE  BEGIN
        System.WriteLn(asProgramPrompt+'Boot drive prompt was inactive. Now active.');
            END;
    {if-then-else}
    dbAskBootDrive := dbAskBootDrive XOR btAskBootDisk;
    System.Mem[System.Seg(_IPL_Code):(aInitBitFlagsOfs)] := dbAskBootDrive;
END;
{ _ToggleBootDriveAsk }


PROCEDURE  _SaveMBRtoFile;
{* Write a Master Boot Record to File. *}
VAR
   sTempInput  :  STRING;

BEGIN
      System.Write(asProgramPrompt+'Write MBR to file (Y/N): ');
      System.ReadLn(sTempInput);

      IF  (System.UpCase(_fnchGetFirstChar(sTempInput)) <> achNo)
         THEN  BEGIN
           System.Write(asProgramPrompt+'Enter filename (def.ext.='+aDefExt+'): ');
           System.ReadLn(sTempInput);

           IF (sTempInput <> asBlank)
              THEN  BEGIN
                sTempInput := _fnsForceFileExtension(sTempInput,aDefExt);
                System.WriteLn(asProgramPrompt+'Copy MBR to file.');
              {** no check for errors! **}
                System.FileMode := 2; {read/write, compatibilty mode}
                System.Assign(gfOutStream,sTempInput);
                {$I-}
                System.Rewrite(gfOutStream);
                {$I+}
                IF (System.IoResult <> errOK)
                  THEN  BEGIN
                     System.WriteLn(asProgramPrompt+'Unable to create output file.');
                        END
                   ELSE  BEGIN
                     System.Write(gfOutStream,grecFixedDiskBoot);
                     System.Close(gfOutStream);
                         END;
                {if-then-else}
                    END;
          {if-then}
               END;

      {if-then}
END;
{ _SaveMBRtoFile }


PROCEDURE  _CopyLoaderCodeToMBR;
{* Copy boot loader code to MBR buffer. *}
BEGIN
   System.WriteLn(asProgramPrompt+'Copy loader code to MBR buffer.');
   System.Move(System.Mem[System.Seg(_IPL_Code):0],
               grecFixedDiskBoot,
               gdwOurBootRecLen);
END;
{ _CopyLoaderCodeToMBR }


PROCEDURE   _WriteMBRtoFixedDisk;
{* Write a Master Boot Record to fixed disk. *}
VAR
   bStatusOk  :  System.Boolean;

BEGIN
   System.WriteLn(asProgramPrompt+'Writing of MBR to fixed disk 0.');
   bStatusOk := System.True;
 { make sure that bootable sector is present }
   grecFixedDiskBoot.dwValidBootRecID := adwBootSecID;
   asm
         mov     dx, (aBiosHeadNumIs0 SHL 8) + aHardDrive_0
         mov     cx, (aBiosCylNumIs0 SHL 8) + aBiosSecNumIs1
         mov     ax, ds
         mov     es, ax                { ES = Turbo DS }
         mov     bx, OFFSET grecFixedDiskBoot
         mov     ax, (aBiosWriteOp SHL 8) + aBiosSecCountIs1
         int     aRomDiskDriver        { ROM BIOS disk driver }
         jnc     @Done
         { we know that writing failed here }
         mov     bStatusOk, System.False
      @Done:
   END;
   {asm-end}

   IF NOT(bStatusOk)
      THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Unable to write MBR to fixed disk.');
         System.Halt(errBadWriteFixedDisk);
            END;
   {if-then}
END;
{ _WriteMBRtoFixedDisk }


PROCEDURE   _ReadMBRfromFixedDisk;
{* Read a Master Boot Record from a fixed disk. *}
VAR
   bStatusOk  :  System.Boolean;

BEGIN
    System.WriteLn(asProgramPrompt+'Reading of MBR from fixed disk.');

    bStatusOk := System.True;
    asm
        mov     dx, (aBiosHeadNumIs0 SHL 8) + aHardDrive_0
        mov     cx, (aBiosCylNumIs0 SHL 8) + aBiosSecNumIs1
        mov     ax, ds
        mov     es, ax                { ES = Turbo DS }
        mov     bx, OFFSET grecFixedDiskBoot
        mov     ax, (aBiosReadOp SHL 8) + aBiosSecCountIs1
        int     aRomDiskDriver        { ROM BIOS disk driver }
        jnc     @Done
                                      { at this point reading failed }
        mov     bStatusOk, System.False

     @Done:
    END;
    {asm-end}

  IF NOT(bStatusOk)
    THEN  BEGIN
       System.WriteLn(asProgramPrompt+'Unable to read MBR from fixed disk.');
       System.Halt(errBadReadFixedDisk);
          END;
  {if-then}
END;
{ _ReadMBRfromFixedDisk }


PROCEDURE  _CopyDriveTypesAndSettingsFromMBR;
{* Copy boot loader code to MBR buffer. *}
BEGIN
   System.WriteLn(asProgramPrompt+'Copy drive settings/types to new loader code.');
   System.Move(System.Mem[System.Seg(grecFixedDiskBoot):(System.Ofs(grecFixedDiskBoot)+aInitBitFlagsOfs)],
               System.Mem[System.Seg(_IPL_Code):aInitBitFlagsOfs],
               aTotalSettingsSize);
END;
{ _CopyDriveTypesAndSettingsFromMBR }


PROCEDURE  _CopyDiskParmsFromIPLforFixedDisk(VAR recHD_Parms: recHARD_DISK_PARMS; dbDriveNum : System.Byte);
{* Extract drive 0 parameters. *}
BEGIN
    System.Move(System.Mem[System.Seg(_IPL_Code):
                 (aBootDiskDriveTableOfs+(aDiskParmTableSize*dbDriveNum))],
                recHD_Parms,
                aDiskParmTableSize);
END;
{ _CopyDiskParmsFromIPLforFixedDisk }


PROCEDURE  _RestoreMBRfromFile;
{* Recover an original boot record *}
VAR
   sTempInput  :  STRING;

BEGIN
   System.Write(asProgramPrompt+'Restore old MBR (Y/N): ');
   System.ReadLn(sTempInput);

   IF  (System.UpCase(_fnchGetFirstChar(sTempInput)) <> achNo)
      THEN  BEGIN
        System.Write(asProgramPrompt+'Enter filename (def.ext.='+aDefExt+'): ');
        System.ReadLn(sTempInput);
        IF (sTempInput <> asBlank)
           THEN  BEGIN
             sTempInput := _fnsForceFileExtension(sTempInput,aDefExt);
             System.WriteLn(asProgramPrompt+'Read original MBR from file.');

             {** no check for errors **}
             System.FileMode := $20;   {read, deny write on share}
             System.Assign(gfOutStream,sTempInput);
             {$I-}
             System.Reset(gfOutStream);
             {$I+}
             IF (System.IoResult <> errOK)
               THEN  BEGIN
                  System.WriteLn(asProgramPrompt+'Unable to open input file.');
                     END
               ELSE  BEGIN
                  System.Read(gfOutStream,grecFixedDiskBoot);
                  System.Close(gfOutStream);

                   {* Write a new master boot record *}
                   _WriteMBRtoFixedDisk;
                     END;
             {if-then-else}
                 END;
        {if-then}
            END;
   {if-then}
END;
{ _RestoreMBRfromFile }


PROCEDURE  _GetDriveParmsUsingBiosCall(dbDriveNum : System.Byte;
                                       VAR  dbErrorCode  :  System.Byte;
                                       VAR  dwMaxCylNum  :  System.Word;
                                       VAR  dbMaxHeadNum :  System.Byte;
                                       VAR  dbMaxSecsNum :  System.Byte);
{* Make a BIOS call to get a current drive parameters. *}
VAR
   bStatusOk  :  System.Boolean;

BEGIN
   System.WriteLn(asProgramPrompt+'Get disk drive ',dbDriveNum,' parameters.');
   bStatusOk := System.True;
   dbErrorCode := errOK;
   asm
       mov     dl, aHardDrive_0
       add     dl, dbDriveNum
       mov     ah, (aBiosGetDriveParmsOp)
       int     aRomDiskDriver        { ROM BIOS disk driver }

       jnc     @Done
           { we know that operation failed here }
       mov     bStatusOk, System.False
       les     di, dbErrorCode
       mov     es:[di], ah
    @Done:
       mov     ax, cx
       and     al, btSecNumMask
       les     di, dbMaxSecsNum
       mov     es:[di], al
       les     di, dwMaxCylNum
       and     cl, (btFullMaskFF - btSecNumMask)
       rol     cl, 1
       rol     cl, 1
       xchg    ch, cl
       mov     es:[di], cx
       les     di, dbMaxHeadNum
       mov     es:[di], dh
   END;
   {asm-end}

END;
{ _GetDriveParmsUsingBiosCall }



PROCEDURE   _InitMasterPartitionRecord;
{* *}
VAR
   liLogicalSectorsPerDrive   :  System.Longint;
   sTempInput                 :  STRING;
   dwMaxCylNum                :  System.Word;
   dbMaxHead,
   dbMaxSecNum,
   dbDriveNum,
   dbErrorCode,
   dbOS_ID                    :  System.Byte;

BEGIN
   {* copy a disk parameters *}
      dbDriveNum := aHardDrive_0-aHardDrive_0;
     _GetDriveParmsUsingBiosCall(dbDriveNum,dbErrorCode,dwMaxCylNum,dbMaxHead,dbMaxSecNum);

    IF (dbErrorCode <> errOK)
       THEN  BEGIN
          System.WriteLn(asProgramPrompt+'Unable to get parameters for fixed disk ',dbDriveNum,'.');
          System.Halt(errBadGetParmsFixedDisk);
       END;
    {if-then}

    System.Write(asProgramPrompt+'Wipe all entries in partition table? (N/Y): ');
    System.ReadLn(sTempInput);
    IF  (System.UpCase(_fnchGetFirstChar(sTempInput)) = achYes)
       THEN  BEGIN
          System.WriteLn(asProgramPrompt+'Invalidates all entries in partition table.');
          System.FillChar(grecFixedDiskBoot.recDiskPartitionsTable[0],
                          aPartitonEntrySize*aMaxAvailLogicalPartition,
                          achNull);
             END;
    {if-then}

    System.Write(asProgramPrompt+'Select mode to enter data (A=auto,M=manual)? (A/M): ');
    System.ReadLn(sTempInput);

    IF  (System.UpCase(_fnchGetFirstChar(sTempInput)) = achManualMode)
       THEN  BEGIN
           System.WriteLn(asProgramPrompt+asNotImplementedYet);
             END
       ELSE  BEGIN
          WITH  recLogicalPartition(grecFixedDiskBoot.recDiskPartitionsTable[0])  DO
          BEGIN
             liLogicalSectorsPerDrive := System.Longint(dwMaxCylNum+1) * (dbMaxHead+1) * (dbMaxSecNum);
             dbBootDriveMark := aHardDrive_0;
             dbStartingHead  :=  aBiosHeadNumIs0+1;
             dwStartingCylSec := _fnddDoBiosCylSecNum(aBiosCylNumIs0,aBiosSecNumIs1);

             dbOS_ID := aDosBig;
             IF  (liLogicalSectorsPerDrive < aSecsPerFAT16)
                THEN  dbOS_ID := aDos16;
             {if-then}
             IF  (liLogicalSectorsPerDrive < aSecsPerFAT12)
                THEN  dbOS_ID := aDos12;
             {if-then}
             dbOperatingSystemID := dbOS_ID;

             dbEndingHead := dbMaxHead;
             dwEndingCylSec := _fnddDoBiosCylSecNum((dwMaxCylNum),dbMaxSecNum);
             ddPrecedingSecs := dbMaxSecNum;
             ddSecsPerPartition := liLogicalSectorsPerDrive - ddPrecedingSecs;
          END;
          {with-do}
             END;
    {if-then-else}
END;
{ _InitMasterPartitionRecord }


PROCEDURE  _DoBiosCmdForSetDriveParms(dbDriveNum : System.Byte);
{* Make a BIOS call to set a new drive parameters. *}
VAR
   bStatusOk  :  System.Boolean;

BEGIN
   System.WriteLn(asProgramPrompt+'Set disk drive ',dbDriveNum,' parameters.');
   bStatusOk := System.True;
   asm
       mov     dl, aHardDrive_0
       add     dl, dbDriveNum
       mov     ah, (aBiosResetOp)
       int     aRomDiskDriver        { ROM BIOS disk driver }

       mov     dl, aHardDrive_0
       add     dl, dbDriveNum
       mov     ah, (aBiosSetDriveParmsOp)
       int     aRomDiskDriver        { ROM BIOS disk driver }
       jnc     @Done
           { we know that operation failed here }
       mov     bStatusOk, System.False
    @Done:
   END;
   {asm-end}

   IF NOT(bStatusOk)
      THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Unable to set parameters for fixed disk ',dbDriveNum,'.');
         System.Halt(errBadInitFixedDisk);
      END;
   {if-then}
END;
{ _DoBiosCmdForSetDriveParms }


PROCEDURE  _SetBiosDriveParametersForFixedDisk0;
{* Set drive parameters for BIOS. *}
VAR
   lpTemp   :   System.Pointer;

BEGIN
   {* save original vectors if need it *}
    IF (ddPrevIntVec41 = NIL)
          THEN  BEGIN
            System.WriteLn(asProgramPrompt+'Save fixed drive 0 parameters vector.');
            Dos.GetIntVec(aDrvParmVec_0,ddPrevIntVec41);
                END;
    {if-then}
   {* copy a new disk parameters *}
    _CopyDiskParmsFromIPLforFixedDisk(grecHARD_DISK_PARMS_0,aHardDrive_0-aHardDrive_0);
    System.WriteLn(asProgramPrompt+'Setup fixed disk 0 parameters.');
    System.Move(grecHARD_DISK_PARMS_0,
                System.Mem[adwABS0_Seg:aLowMemParmVecStoreArea_0],
                aDiskParmTableSize);
    Dos.SetIntVec(aDrvParmVec_0,System.Ptr(adwABS0_Seg,aLowMemParmVecStoreArea_0));
    Dos.GetIntVec(aDrvParmVec_0,lpTemp);
    IF (lpTemp <> System.Ptr(adwABS0_Seg,aLowMemParmVecStoreArea_0))
      THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Warning! Setup of interrupt vector failed.');
            END
      ELSE  BEGIN
         _DoBiosCmdForSetDriveParms(aHardDrive_0-aHardDrive_0);
         gbSetupParmsForDrive_0 := System.True;
            END;
    {if-then-else}
END;
{ _SetBiosDriveParametersForFixedDisk0 }


PROCEDURE  _SetBiosDriveParametersForFixedDisk1;
{* Set drive parameters for BIOS. *}
VAR
   lpTemp   :   System.Pointer;

BEGIN
   {* save original vectors if need it *}
    IF (ddPrevIntVec46 = NIL)
          THEN  BEGIN
            System.WriteLn(asProgramPrompt+'Save fixed drive 1 parameters vector.');
            Dos.GetIntVec(aDrvParmVec_1,ddPrevIntVec46);
                END;
    {if-then}
   {* copy a new disk parameters *}
    _CopyDiskParmsFromIPLforFixedDisk(grecHARD_DISK_PARMS_1,aHardDrive_1-aHardDrive_0);
    System.WriteLn(asProgramPrompt+'Setup fixed disk 1 parameters.');
    System.Move(grecHARD_DISK_PARMS_1,
                System.Mem[adwABS0_Seg:aLowMemParmVecStoreArea_1],
                aDiskParmTableSize);
    Dos.SetIntVec(aDrvParmVec_1,System.Ptr(adwABS0_Seg,aLowMemParmVecStoreArea_1));
    Dos.GetIntVec(aDrvParmVec_1,lpTemp);
    IF (lpTemp <> System.Ptr(adwABS0_Seg,aLowMemParmVecStoreArea_1))
      THEN  BEGIN
        System.WriteLn(asProgramPrompt+'Warning! Setup of interrupt vector failed.');
            END
      ELSE  BEGIN
         _DoBiosCmdForSetDriveParms(aHardDrive_1-aHardDrive_0);
         gbSetupParmsForDrive_1 := System.True;
            END;
    {if-then-else}
END;
{ _SetBiosDriveParametersForFixedDisk1 }


PROCEDURE  _FormatDriveWithNewParameters(dbDriveNum : System.Byte);
{* General-purpose formatting procedure for selected drive. *}
VAR
   {recFORMAT_HARD_DISK_PARMS  :  recHARD_DISK_PARMS;}
   dwMaxCylNum,
   dwFormatCylinderNum,
   dwCylSecValue              :  System.Word;
   dbMaxHeadNum,
   dbFormatDriveNum,
   dbFormatHeadNum,
   dbFormatSectorNum,
   dbSectorsPerTrack,
   dbInterleaveFactor,
   dbReturnCodeFromBios,
   dbErrorRetryCount,
   dbSectorFlag               :  System.Byte;
   bStatusOk,
   bMarkTrackAsBad            :  System.Boolean;
   sTemp                      :  STRING;
   lpDriveParms               :  System.Pointer;

BEGIN
   IF NOT(gbPCATFoundOk)
     THEN  BEGIN
      {* force exit *}
        System.WriteLn(asProgramPrompt+'This may work only for IBM PC/AT or compatible computer.');
        System.Exit;
           END;
  {if-then}

 {* ask about formatting *}
    System.Write(asProgramPrompt+'Do you want to format drive ',dbDriveNum,'? (N/Y): ');
    System.ReadLn(sTemp);
    IF (System.UpCase(_fnchGetFirstChar(sTemp)) <> achYes)
     THEN  BEGIN
      {* force exit *}
        System.WriteLn(asProgramPrompt+'No drive formatting done.');
        System.Exit;
           END;
    {if-then}

  {* init internal variables *}
    dbFormatDriveNum := aHardDrive_0 + dbDriveNum;
    dbInterleaveFactor := aDefInterleaveFactor;
    _GetDriveParmsUsingBiosCall(dbFormatDriveNum-aHardDrive_0,dbReturnCodeFromBios,
                                dwMaxCylNum,dbMaxHeadNum,dbSectorsPerTrack);

    IF (dbReturnCodeFromBios <> errOK)
       THEN  BEGIN
          System.WriteLn(asProgramPrompt+'Unable to get parameters for fixed disk ',dbDriveNum,'.');
          System.Halt(errBadGetParmsFixedDisk);
             END
       ELSE  System.WriteLn(asProgramPrompt+'Current drive parameters:   Cyls = ',(dwMaxCylNum+2),
                            ',   Hds = ',dbMaxHeadNum+1,',   Secs = ',dbSectorsPerTrack);

    {if-then}

    System.Write(asProgramPrompt+'Select interlave factor (',aBiosSecNumIs1,
                 '-',dbSectorsPerTrack,', CR=',dbInterleaveFactor,'): ');
    System.ReadLn(sTemp);
    IF (sTemp <> asBlank)
        THEN  BEGIN
          dbInterleaveFactor := System.Lo(_fndwGetValue(sTemp));
          IF  (dbInterleaveFactor > dbSectorsPerTrack)
             THEN  BEGIN
                System.WriteLn(asProgramPrompt+'Bad interleave value, reset to default value.');
                dbInterleaveFactor := aDefInterleaveFactor;
                   END;
          {if-then}
              END;
    System.WriteLn(asProgramPrompt+'Selected interlave factor = ',dbInterleaveFactor);
    {if-then}

 {* last chance before to begin of formatting proccess *}
    System.Write(asProgramPrompt+'ALL DATA ON YOUR FIXED DISK WILL BE LOST. ARE YOU SURE? (N/Y): ');
    System.ReadLn(sTemp);
    IF (System.UpCase(_fnchGetFirstChar(sTemp)) <> achYes)
     THEN  BEGIN
      {* force exit *}
        System.WriteLn(asProgramPrompt+'Last chance was used. You must be happy!');
        System.Exit;
           END;
    {if-then}

  {* check drive ready *}
           System.WriteLn(asProgramPrompt+'... Check Controller/Drive Ready ...');
           bStatusOk := System.True;
           asm
                  mov     ah, aBiosRecalibrateDrive
                  mov     dl, dbFormatDriveNum
                  int     aRomDiskDriver          { ROM BIOS disk driver }
                  mov     ah, aBiosRecalibrateDrive
                  mov     dl, dbFormatDriveNum
                  int     aRomDiskDriver          { ROM BIOS disk driver }
                  mov     ah, aBiosRecalibrateDrive
                  mov     dl, dbFormatDriveNum
                  int     aRomDiskDriver          { ROM BIOS disk driver }

                  mov     ah, aBiosTestIsDriveReady
                  mov     dl, dbFormatDriveNum
                  int     aRomDiskDriver          { ROM BIOS disk driver }
                  jnc    @Done
                  mov     bStatusOk, System.False

             @Done:
           END;
           {asm-end}

    IF NOT(bStatusOk)
         THEN  BEGIN
          {* force exit *}
            System.WriteLn(asProgramPrompt+'Controller/Drive not ready.');
            System.Exit;
               END;
        {if-then}

           dbErrorRetryCount := aRetryOpCount;
           dbSectorFlag := aGoodSectorFlag;
           bMarkTrackAsBad := System.False;
           dbFormatSectorNum := aBiosSecNumIs1;
           dwFormatCylinderNum := aBiosCylNumIs0;
           System.FillChar(gdbFormatSectorBuffer,
                           System.SizeOf(gdbFormatSectorBuffer),
                           System.Char(aGoodSectorFlag));

           System.WriteLn(asProgramPrompt+'... Formatting ...');


           REPEAT
             dbFormatHeadNum := aBiosHeadNumIs0;

               REPEAT
                 System.Write(achCR+asProgramPrompt+'  Cyl: '+_fnsNumToStr4(dwFormatCylinderNum)+
                                                   '   Hd: '+_fnsNumToStr3(dbFormatHeadNum));
                  asm
                      mov     ax, ds
                      mov     es, ax                { ES = Turbo DS }
                      mov     bx, OFFSET gdbFormatSectorBuffer
                      mov     di, bx
                      mov     al, dbSectorFlag
                      mov     ah, aBiosSecNumIs1
                      sub     cx, cx
                      mov     dx, cx
                      mov     dl, dbInterleaveFactor
                      shl     dx, 1                { counts also flags }
                      mov     cl, dbSectorsPerTrack
                      mov     si, cx
                      shl     si, 1                 { check marker of end records }
                      add     si, bx

                   @NextLogSecRec:
                       or     cx, cx
                       jz    @InitDone

                       mov    es:[di], ax          { write flag,sector }
                       inc    ah
                       dec    cx
                       add    di, dx               { add interleave }

                       cmp    di, si
                       jb    @MatchEntry

                       sub    di, si               { wrap around }
                       add    di, bx

                   @MatchEntry:
                      jmp    @NextLogSecRec

                   @InitDone:
                  END;
                  {asm-end}

                  dwCylSecValue := _fnddDoBiosCylSecNum(dwFormatCylinderNum,
                                                        dbFormatSectorNum);
                  bStatusOk := System.True;
                  asm
                      mov     ax, ds
                      mov     es, ax                { ES = Turbo DS }
                      mov     bx, OFFSET gdbFormatSectorBuffer
                      mov     dh, dbFormatHeadNum
                      mov     dl, dbFormatDriveNum
                      mov     cx, dwCylSecValue
                      mov     al, dbSectorsPerTrack
                      mov     ah, (aBiosFormatOp)
               {$IFDEF  FormatLogicTest}
                      clc                         { flag as success }
               {$ELSE}
                      int     aRomDiskDriver      { ROM BIOS disk driver }
               {$ENDIF} {FormatLogicTest}
                      jnc     @Done
                                                    { at this point reading failed }
                      mov     bStatusOk, System.False
                      mov     dbReturnCodeFromBios, ah

                   @Done:
                  END;
                  {asm-end}
               IF  NOT(bStatusOk)
                 THEN  BEGIN
                   IF  NOT(bMarkTrackAsBad)
                      THEN  System.Dec(dbErrorRetryCount);
                   {if-then}
                   IF (dbErrorRetryCount <> 0)
                     THEN  BEGIN
                       System.WriteLn('  Status: Failed,  Code: ',dbReturnCodeFromBios);
                       System.WriteLn(asProgramPrompt+'Reset disk subsystem.');
                       asm
                                mov     dl, dbFormatDriveNum
                                mov     ah, (aBiosResetOp)
                                int     aRomDiskDriver
                       END;
                       {asm-end}
                           END
                     ELSE  BEGIN
                          IF (bMarkTrackAsBad)
                             THEN  BEGIN
                                dbErrorRetryCount := aRetryOpCount;
                                dbSectorFlag := aGoodSectorFlag;
                                bMarkTrackAsBad := System.False;
                                System.WriteLn(asBlank);
                                System.WriteLn(asProgramPrompt+'Formatting operation failed.');
                                System.WriteLn(asProgramPrompt+'Check your controller and/or drive, cables, etc.');
                                System.Halt(errFormatFailed);
                                   END
                              ELSE BEGIN
                                System.WriteLn(asBlank);
                                System.WriteLn(asProgramPrompt+'Mark all sectors on this track as bad.');
                                bMarkTrackAsBad := System.True;
                                dbSectorFlag := aBadSectorFlag;
                                   END;
                          {if-then-else}
                           END;
                   {if-then}
                       END
               {if-then}
                 ELSE   BEGIN
                   IF (bMarkTrackAsBad)
                     THEN    BEGIN
                        dbErrorRetryCount := aRetryOpCount;
                        dbSectorFlag := aGoodSectorFlag;
                        bMarkTrackAsBad := System.False;
                        System.WriteLn(asBlank);
                        System.WriteLn(asProgramPrompt+'..Formatting continue..');
                             END
                  ELSE    BEGIN
                   System.Inc(dbFormatHeadNum);
                          END;
                   {if-then-else}
                        END;
               {if-then-else}

               bStatusOk := System.True;

             UNTIL (NOT(bStatusOk) OR (dbFormatHeadNum > dbMaxHeadNum));
             {repeat-until}

             System.Inc(dwFormatCylinderNum);
           UNTIL ((dwFormatCylinderNum > dwMaxCylNum) OR NOT(bStatusOk));
           {repeat-until}

    System.WriteLn(asBlank);
    System.WriteLn(asProgramPrompt+'Format complete.');

    System.WriteLn(asProgramPrompt+'Reset disk subsystem.');
    asm
             mov     dl, dbFormatDriveNum
             mov     ah, (aBiosResetOp)
             int     aRomDiskDriver
    END;
    {asm-end}

    System.Write(asProgramPrompt+'Verify after formatting? (N/Y): ');
    System.ReadLn(sTemp);
    IF (System.UpCase(_fnchGetFirstChar(sTemp)) = achYes)
      THEN  BEGIN
           dbFormatSectorNum := aBiosSecNumIs1;
           dwFormatCylinderNum := aBiosCylNumIs0;
           System.FillChar(gdbFormatSectorBuffer,
                           System.SizeOf(gdbFormatSectorBuffer),
                           System.Char(aGoodSectorFlag));

           System.WriteLn(asProgramPrompt+'... Verifying ...');

           REPEAT
             dbFormatHeadNum := aBiosHeadNumIs0;

               REPEAT
                 System.Write(achCR+asProgramPrompt+'  Cyl: '+_fnsNumToStr4(dwFormatCylinderNum)+
                                                   '   Hd: '+_fnsNumToStr3(dbFormatHeadNum));

                  dwCylSecValue := _fnddDoBiosCylSecNum(dwFormatCylinderNum,
                                                        dbFormatSectorNum);
                  bStatusOk := System.True;
                  asm
                      mov     ax, adwTestMemBufSeg
                      mov     es, ax                { ES = Turbo DS }
                      mov     bx, adwTestMemBufOfs
                      mov     dh, dbFormatHeadNum
                      mov     dl, dbFormatDriveNum
                      mov     cx, dwCylSecValue
                      mov     al, dbSectorsPerTrack
                      mov     ah, (aBiosVerifyOp)
               {$IFDEF  VerifyLogicTest}
                      clc                         { flag as success }
               {$ELSE}
                      int     aRomDiskDriver      { ROM BIOS disk driver }
               {$ENDIF} {VerifyLogicTest}
                      jnc     @Done
                                                    { at this point reading failed }
                      mov     bStatusOk, System.False
                      mov     dbReturnCodeFromBios, ah

                   @Done:
                  END;
                  {asm-end}
               IF  NOT(bStatusOk)
                 THEN  BEGIN
                   System.WriteLn('  Status: Failed,  Code: ',dbReturnCodeFromBios);
                   bStatusOk := System.True;
                   System.WriteLn(asProgramPrompt+'Reset disk subsystem.');
                   asm
                            mov     dl, dbFormatDriveNum
                            mov     ah, (aBiosResetOp)
                            int     aRomDiskDriver
                   END;
                   {asm-end}
                       END;
               {if-then}
               System.Inc(dbFormatHeadNum);
             UNTIL (NOT(bStatusOk) OR (dbFormatHeadNum > dbMaxHeadNum));
             {repeat-until}

             System.Inc(dwFormatCylinderNum);
           UNTIL ((dwFormatCylinderNum > dwMaxCylNum) OR NOT(bStatusOk));
           {repeat-until}

           System.WriteLn(asBlank);
           System.WriteLn(asProgramPrompt+'Drive verifying done.');
           END;
    {if-then}
END;
{ _FormatDriveWithNewParameters }


PROCEDURE  _DisplayCurrentSettingsForBootLoader;
{* Output miscellaneous current setting. *}
VAR
    recDriveParms_0,
    recDriveParms_1   :  recHARD_DISK_PARMS;
    dwRamArea_0,
    dwRamArea_1       :  System.Word;
    dbBitFlags        :  System.Byte;
    sTemp             :  STRING;

BEGIN
  dbBitFlags := System.Mem[System.Seg(_IPL_Code):aInitBitFlagsOfs];
  System.Move(System.Mem[System.Seg(_IPL_Code):
              (aBootDiskDriveTableOfs+(aDiskParmTableSize*(aHardDrive_0-aHardDrive_0)))],
              recDriveParms_0,
              aDiskParmTableSize);
  System.Move(System.Mem[System.Seg(_IPL_Code):
              (aBootDiskDriveTableOfs+(aDiskParmTableSize*(aHardDrive_1-aHardDrive_0)))],
              recDriveParms_1,
              aDiskParmTableSize);
  System.Move(System.Mem[System.Seg(_IPL_Code):
              (aBootDiskDriveTableOfs+(aDiskParmTableSize*aHardDiskSupportNum))],
              dwRamArea_0,
              aRamAreaInBytes);
  System.Move(System.Mem[System.Seg(_IPL_Code):
              (aBootDiskDriveTableOfs+(aDiskParmTableSize*aHardDiskSupportNum)+aRamAreaInBytes)],
              dwRamArea_1,
              aRamAreaInBytes);

   System.WriteLn(asProgramPrompt+'Current settings are the following:');
   System.WriteLn(asProgramPrompt+' --> Global Flags <--');

   IF  ((dbBitFlags AND btAskBootDisk) <> 0)
     THEN  sTemp := 'ON'
     ELSE  sTemp := 'OFF';
   {if-then}
   System.WriteLn(asProgramPrompt+'  Boot Drive Prompt is '+sTemp+'.');
   IF  ((dbBitFlags AND btSetDiskType_0) <> 0)
     THEN  sTemp := 'ON'
     ELSE  sTemp := 'OFF';
   {if-then}
   System.WriteLn(asProgramPrompt+'  Set disk type for drive 0 is '+sTemp+'.');
   IF  ((dbBitFlags AND btSetDiskType_1) <> 0)
     THEN  sTemp := 'ON'
     ELSE  sTemp := 'OFF';
   {if-then}
   System.WriteLn(asProgramPrompt+'  Set disk type for drive 1 is '+sTemp+'.');

   System.WriteLn(asProgramPrompt+'  Use RAM area for drive 0 type at $0000:'+_fnsWordToHexFmt(dwRamArea_0));
   System.WriteLn(asProgramPrompt+'  Use RAM area for drive 1 type at $0000:'+_fnsWordToHexFmt(dwRamArea_1));

   System.WriteLn(asProgramPrompt+' --> Drive Parameter <--        Drive 0        Drive 1');

   System.WriteLn(asProgramPrompt+'  Number of cylinders      =   '+
                  _fnsNumToStr5(recDriveParms_0.dwMAX_CYLS_NUM)+asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dwMAX_CYLS_NUM));
   System.WriteLn(asProgramPrompt+'  Number of heads          =   '+
                  _fnsNumToStr5(recDriveParms_0.dbMAX_HEADS_NUM)+asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dbMAX_HEADS_NUM));
   System.WriteLn(asProgramPrompt+'  Starting WPC for XT      =   '+
                  _fnsNumToStr5(recDriveParms_0.dwSTART_WRC_XT)+asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dwSTART_WRC_XT));
   System.WriteLn(asProgramPrompt+'  Starting WPC             =   '+
                  _fnsNumToStr5(recDriveParms_0.dwSTART_WRC)+asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dwSTART_WRC));
   System.WriteLn(asProgramPrompt+'  ECC data burst length    =   '+
                  _fnsNumToStr5(recDriveParms_0.dbMAX_ECC_DATA_BURST_LEN)+asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dbMAX_ECC_DATA_BURST_LEN));
   System.WriteLn(asProgramPrompt+'  Control Byte             =   '+
                  _fnsNumToStr5(recDriveParms_0.dbCONTROL_BYTE)+asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dbCONTROL_BYTE));
   System.WriteLn(asProgramPrompt+'  Standard time-out for XT =   '+
                  _fnsNumToStr5(recDriveParms_0.dbSTD_TIME_OUT_XT)+asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dbSTD_TIME_OUT_XT));
   System.WriteLn(asProgramPrompt+'  Format time-out for XT   =   '+
                  _fnsNumToStr5(recDriveParms_0.dbFMT_TIME_OUT_XT)+asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dbFMT_TIME_OUT_XT));
   System.WriteLn(asProgramPrompt+'  Check time-out for XT    =   '+
                  _fnsNumToStr5(recDriveParms_0.dbCHECK_TIME_OUT_XT)+asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dbCHECK_TIME_OUT_XT));
   System.WriteLn(asProgramPrompt+'  Landing zone             =   '+
                  _fnsNumToStr5(recDriveParms_0.dwLANDING_ZONE)+asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dwLANDING_ZONE));
   System.WriteLn(asProgramPrompt+'  Number of sectors/track  =   '+
                  _fnsNumToStr5(recDriveParms_0.dbSECTORS_PER_TRACK),asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dbSECTORS_PER_TRACK));
   System.WriteLn(asProgramPrompt+'  Reserved byte            =   '+
                  _fnsNumToStr5(recDriveParms_0.dbPARM_RESERVED),asSpaces10,
                  _fnsNumToStr5(recDriveParms_1.dbPARM_RESERVED));
END;
{ _DisplayCurrentSettingsForBootLoader }


PROCEDURE  _SetRamAreaDriveParametersForFixedDisk(HardDisk : System.Byte);
{* Setup the wanted RAM area for user-defined type. *}
VAR
  dwRamArea,
  dwNewRamArea      :  System.Word;
  iErrCode          :  System.Integer;
  sTemp             :  STRING;

BEGIN
  System.Move(System.Mem[System.Seg(_IPL_Code):
              (aBootDiskDriveTableOfs+(aDiskParmTableSize*aHardDiskSupportNum)+(aRamAreaInBytes*HardDisk))],
              dwRamArea,
              aRamAreaInBytes);
  System.Write(asProgramPrompt+'Enter new offset as hexadecimal value (CR=$'+_fnsWordToHexFmt(dwRamArea)+'): ');
  System.ReadLn(sTemp);
  dwNewRamArea := _fnliHexStrToBin(sTemp,iErrCode);
  IF (iErrCode = 0)
     THEN  BEGIN
       IF (dwNewRamArea <= ($10000-aDiskParmTableSize))
          THEN  BEGIN
            System.Move(dwNewRamArea,
                        System.Mem[System.Seg(_IPL_Code):
                        (aBootDiskDriveTableOfs+(aDiskParmTableSize*aHardDiskSupportNum)+(aRamAreaInBytes*HardDisk))],
                        aRamAreaInBytes);
            System.WriteLn(asProgramPrompt+'New offset accepted.');
                END
          ELSE
            System.WriteLn(asProgramPrompt+'Offset must be lesser.');
       {if-then-else}
           END
     ELSE
        System.WriteLn(asProgramPrompt+'Wrong hexadecimal number.');
  {if-then-else}
END; { _SetRamAreaDriveParametersForFixedDisk0 }


PROCEDURE  _NoticeAboutAdvancedVersion;
{* Output notice to explain. *}
BEGIN
   System.WriteLn(asProgramPrompt+'Available only in advanced version of '+asProgram);
END;
{ _NoticeAboutAdvancedVersion }



{*============================== MAIN PART =============================*}

BEGIN

  {* copyright message *}
    _CopyrightDisplay;


  {* get a length of boot code *}
     gdwOurBootRecLen := System.Ofs(_DummyProc) - System.Ofs(_IPL_Code);


  {* test bootstrap procedure *}
{$IFDEF   DebugVersion}
    System.WriteLn(asProgramPrompt+'Debugging of boostrap procedure.');
    asm
      mov        ax,  aDebugOn        { no relocated code }
    END;
    {asm-end}

    _IPL_Code;

   System.Halt(errBootStrapDebug);
{$ENDIF}  {DebugVersion}

  {* test for match length of IPL *}
     IF  (gdwOurBootRecLen > adwPartitionTable)
       THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Bad size of loader code please re-code.');
         System.Halt(errMismatchLoaderCode);
             END;
     {if-then}

  {* some housekeeping *}
     gbPCATFoundOk := (gdbPcType = aPcTypeIsAT);

  {* Read original master boot record *}
      _ReadMBRfromFixedDisk;

  {* make a backup copy *}
    System.Move(grecFixedDiskBoot,grecOrigFixedDiskBoot,System.SizeOf(grecFixedDiskBoot));
    gbOriginalMBRpresent := System.True;

  {* check for presence of installed loader *}
    System.Move(grecFixedDiskBoot,gsTempInput[1],aMaxTpStrLen);
    gsTempInput[0] := System.Char(aMaxTpStrLen);
    IF  (System.Pos(asSearchNotice,gsTempInput) <> 0)
      THEN  BEGIN
         System.WriteLn(asProgramPrompt+asProgram+' loader found on fixed disk 0.');
         System.Write(asProgramPrompt+'Copy drive types/settings from installed copy (Y/N): ');
         System.ReadLn(gsTempInput);

         IF  (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achNo)
            THEN  BEGIN
               System.WriteLn(asProgramPrompt+'Copy already defined drive types/settings.');
               _CopyDriveTypesAndSettingsFromMBR;
                  END;
         {if-then}
            END
      ELSE
         System.WriteLn(asProgramPrompt+asProgram+' loader not present.');
    {if-then}

  {$IFDEF   FormatLogicTest}
      System.WriteLn(asProgramPrompt+'Logical test of format operations selected.');
  {$ENDIF} {FormatLogicTest}

  {$IFDEF   VerifyLogicTest}
      System.WriteLn(asProgramPrompt+'Logical test of verify operations selected.');
  {$ENDIF} {VerifyLogicTest}

  System.WriteLn(asProgramPrompt+'Press <ENTER> to continue.');
  System.ReadLn;

  gbUserAskExit := System.False;

  {* user menu and main command-driven loop *}

  WHILE  NOT(gbUserAskExit)  DO
  BEGIN
     System.WriteLn(asBlank);
     System.WriteLn('******************** Common User Menu ******************************');
     System.WriteLn('['+ achZero  +']  Enable/Disable Boot Drive Ask');
     System.WriteLn('['+ achOne   +']  Save Master Boot Record (MBR)');
     System.WriteLn('['+ achTwo   +']  Restore Master Boot Record (MBR)');
     System.WriteLn('['+ achThree +']  Set/Update parameters for drive 0');
     System.WriteLn('['+achFour   +']  Set/Update parameters for drive 1');
     System.WriteLn('['+achFive   +']  Enable/Disable type setup for drive 0 (at boot time)');
     System.WriteLn('['+achSix    +']  Enable/Disable type setup for drive 1 (at boot time)');
     System.WriteLn('['+achSeven  +']  Init/Update Master Partition');
     System.WriteLn('['+achEight  +']  Write/Update Master Boot Record (MBR)');
     System.WriteLn('['+achNine   +']  Quit');
  {$IFDEF  AdvancedUserVersion}
     System.WriteLn('******************** Advanced User Menu ******************************');
     System.WriteLn('['+achDisplayCmd+']  Display current boot loader settings');
     System.WriteLn('['+achCopyCmd   +']  Move Original Copy to MBR Buffer');
     System.WriteLn('['+achTestCmd   +']  Write new Master Boot Record (MBR) to file');
     System.WriteLn('['+achFormatCmd +']  Format drive 0/1 with new parameters');
     System.WriteLn('['+achSetCmd    +']  Set drive 0/1 parameters for BIOS');
     System.WriteLn('['+achRamAreaCmd+']  Set RAM area of drive 0/1 types');
     System.WriteLn('['+achQuitCmd+   ']  Alternate quit');
  {$ENDIF} {AdvancedUserVersion}
     System.WriteLn('--> Command Prompt <--');
     System.Write('Select your option: ');

     System.ReadLn(gsTempInput);
     gsTempInput := System.UpCase(_fnchGetFirstChar(gsTempInput));

     CASE  (gsTempInput[1])  OF
         achQuitCmd    :     BEGIN
                       {$IFDEF  AdvancedUserVersion}
                           gbUserAskExit := System.True;
                       {$ELSE}
                           _NoticeAboutAdvancedVersion;
                       {$ENDIF} {AdvancedUserVersion}
                             END;
         achDisplayCmd :     BEGIN
                       {$IFDEF  AdvancedUserVersion}
                           _DisplayCurrentSettingsForBootLoader;
                       {$ELSE}
                           _NoticeAboutAdvancedVersion;
                       {$ENDIF} {AdvancedUserVersion}
                             END;
         achRamAreaCmd:   BEGIN
                       {$IFDEF  AdvancedUserVersion}
                            System.Write(asProgramPrompt+'Select drive (0/1/CR=none): ');
                            System.ReadLn(gsTempInput);
                            gsTempInput := System.UpCase(_fnchGetFirstChar(gsTempInput));
                            CASE  (gsTempInput[1])  OF
                                achZero  :   BEGIN
                                          _SetRamAreaDriveParametersForFixedDisk(aHardDrive_0-aHardDrive_0);
                                             END;
                                achOne  :   BEGIN
                                          _SetRamAreaDriveParametersForFixedDisk(aHardDrive_1-aHardDrive_0);
                                             END;
                             ELSE
                                 System.WriteLn(asProgramPrompt+'None drive selected. Nothing done.');
                             END;
                             {case-of}

                       {$ELSE}
                           _NoticeAboutAdvancedVersion;
                       {$ENDIF} {AdvancedUserVersion}
                          END;
         achSetCmd  :     BEGIN
                       {$IFDEF  AdvancedUserVersion}
                            System.Write(asProgramPrompt+'Select drive (0/1/CR=none): ');
                            System.ReadLn(gsTempInput);
                            gsTempInput := System.UpCase(_fnchGetFirstChar(gsTempInput));
                            CASE  gsTempInput[1]  OF
                                achZero  :   BEGIN
                                          _SetBiosDriveParametersForFixedDisk0;
                                             END;
                                achOne  :   BEGIN
                                          _SetBiosDriveParametersForFixedDisk1;
                                             END;
                             ELSE
                                 System.WriteLn(asProgramPrompt+'None drive selected. Nothing done.');
                             END;
                             {case-of}
                       {$ELSE}
                           _NoticeAboutAdvancedVersion;
                       {$ENDIF} {AdvancedUserVersion}
                          END;
       achFormatCmd :     BEGIN
                       {$IFDEF   AdvancedUserVersion}
                            System.Write(asProgramPrompt+'Select drive (0/1/CR=none): ');
                            System.ReadLn(gsTempInput);
                            gsTempInput := System.UpCase(_fnchGetFirstChar(gsTempInput));
                            CASE  gsTempInput[1]  OF
                                achZero  :   BEGIN
                                        {$IFDEF   FormatLogicTest}
                                            gbSetupParmsForDrive_0 := System.True;
                                        {$ENDIF} {FormatLogicTest}
                                           IF (gbSetupParmsForDrive_0)
                                              THEN  BEGIN
                                          _FormatDriveWithNewParameters(aHardDrive_0-aHardDrive_0);
                                                    END
                                               ELSE  BEGIN
                                          System.WriteLn(asProgramPrompt+'You must set the drive parameters before.');
                                                     END;
                                           {if-then}
                                             END;
                                achOne  :   BEGIN
                                        {$IFDEF   FormatLogicTest}
                                            gbSetupParmsForDrive_1 := System.True;
                                        {$ENDIF} {FormatLogicTest}
                                           IF (gbSetupParmsForDrive_1)
                                              THEN  BEGIN
                                          _FormatDriveWithNewParameters(aHardDrive_1-aHardDrive_0);
                                                    END
                                               ELSE  BEGIN
                                          System.WriteLn(asProgramPrompt+'You must set the drive parameters before.');
                                                     END;
                                           {if-then}
                                             END;
                             ELSE
                                 System.Write(asProgramPrompt+'None drive selected. Nothing done.');
                             END;
                             {case-of}
                       {$ELSE}
                           _NoticeAboutAdvancedVersion;
                       {$ENDIF} {AdvancedUserVersion}
                          END;
         achTestCmd  :    BEGIN
                       {$IFDEF AdvancedUserVersion}
                           _CopyLoaderCodeToMBR;
                           System.WriteLn(asProgramPrompt+'Copy constructed MBR to file (for test purpose).');
                           _SaveMBRtoFile;
                       {$ELSE}
                           _NoticeAboutAdvancedVersion;
                       {$ENDIF} {AdvancedUserVersion}
                          END;
         achCopyCmd :     BEGIN
                       {$IFDEF AdvancedUserVersion}
                             IF (gbOriginalMBRpresent)
                               THEN  BEGIN
                                 System.WriteLn(asProgramPrompt+'Copy to MBR buffer.');
                                 System.Move(grecOrigFixedDiskBoot,
                                             grecFixedDiskBoot,
                                             System.SizeOf(grecFixedDiskBoot));
                                     END
                               ELSE  BEGIN
                                 System.WriteLn(asProgramPrompt+'Original MBR not saved at start-up.');
                                     END;
                             {if-then-else}
                       {$ELSE}
                           _NoticeAboutAdvancedVersion;
                       {$ENDIF} {AdvancedUserVersion}
                          END;
             achZero  :   BEGIN
                             _ToggleBootDriveAsk;
                          END;
             achOne :     BEGIN
                      {* save original boot record *}
                        System.WriteLn(asProgramPrompt+'Saving of original MBR.');
                        _SaveMBRtoFile;
                          END;
             achTwo :     BEGIN
                                _RestoreMBRfromFile;
                          END;
              achThree :  BEGIN
                       {* get the user parameters for the disk drive(s) in the system *}
                           _GetDiskDriveParameters(aHardDrive_0-aHardDrive_0);
                          END;
             achFour  :   BEGIN
                       {* get the user parameters for the disk drive(s) in the system *}
                           _GetDiskDriveParameters(aHardDrive_1-aHardDrive_0);
                          END;
             achFive  :   BEGIN
                              _AttachOrDeAttachDrive(aHardDrive_0-aHardDrive_0);
                          END;
             achSix  :    BEGIN
                              _AttachOrDeAttachDrive(aHardDrive_1-aHardDrive_0);
                          END;
             achSeven  :  BEGIN
                              _InitMasterPartitionRecord;
                          END;
             achEight  :  BEGIN
                      {* ask user about installation *}
                         System.Write(asProgramPrompt+'Install '+asProgram+'. Are you sure? (N/Y): ');
                         System.ReadLn(gsTempInput);
                         IF  (System.UpCase(_fnchGetFirstChar(gsTempInput)) = achYes)
                           THEN  BEGIN
                              {* make a new boot record *}
                                _CopyLoaderCodeToMBR;

                              {* Ask user about writing. *}
                                 System.Write(asProgramPrompt+'Write a new IPL. Are you sure? (N/Y): ');
                                 System.ReadLn(gsTempInput);

                                 IF  (System.UpCase(_fnchGetFirstChar(gsTempInput)) = achYes)
                                   THEN  BEGIN
                                      _WriteMBRtoFixedDisk;
{$IFDEF   AdvancedBootManager}
                                 System.Write(asProgramPrompt+'Don''t forget to install boot stage 2!!!');
                                 System.ReadLn;
{$ENDIF  {AdvancedBootManager}
                                         END
                                   ELSE  BEGIN
                                      System.WriteLn(asProgramPrompt+'Aborted by user.');
                                         END;
                                 {if-then-else}
                                 END
                           ELSE  BEGIN
                             System.WriteLn(asProgramPrompt+'Aborted by user.');
                                 END;
                         {if-then-else}
                          END;
             achNine  :   BEGIN
                       gbUserAskExit := System.True;
                          END;
       ELSE
          System.WriteLn(asProgramPrompt+'Invalid selection of menu item.');
     END;
     {case-of}
     IF  NOT(gbUserAskExit)
       THEN  BEGIN
          System.Write(asProgramPrompt+'Press <CR> to continue.');
          System.ReadLn;
             END;
     {if-then}

  END;
  {while-do}

  {* final report *}
    System.WriteLn(asProgramPrompt+'Done.');

  {* System.Halt(errTerminateOk); *}
END.
