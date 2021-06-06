{****************************************************************************
//                            File OS-BOOT.PAS
//
//                 Multiple Operating Systems loader
//
//      Copyright (c) 1992, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/OS-BOOT/RCS/os-boot.pas $
//  $RCSfile: os-boot.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:31:58 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: os-boot.pas $
//      Revision 1.1  1998/10/03 14:31:58  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                MULTIPLE-OPERATING-SYSTEMS-LOADER               }
{ FILE NAME             OS-BOOT.PAS                                     }
{ PURPOSE               OS-loader from the fixed disk                   }
{ VERSION               2.12                                            }
{ DATE                  02-Aug-1997                                     }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Telephone: +007 (095) 944-6304                  }
{ INTERNET              wizard@radio-msu.net, dima@mccbn.ru             }
{ COPYRIGHT NOTICE      Copyright (C) 1992, 1997  Dmitry Stefankov      }
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
{ DESCRIPTION           1. Read Master Boot Record.                     }
{                       1a. If our loader present then copy some info   }
{                           by user confirming                          }
{                       2. Extract the Partition Table from it and      }
{                          link with new loader code.                   }
{                       3. Install a new Master Boot Record if user     }
{                           wants it                                    }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   13-Sep-92  DS  initial release           }
{                       1.01   14-Sep-92  DS  add saving old MBR to file}
{                       1.02   21-Sep-92  DS  some corrections          }
{                       1.10   08-Oct-92  DS  some style corrections    }
{                       1.11   27-Oct-92  DS  some corrections          }
{                       1.12   04-Nov-92  DS  some updates              }
{                       1.20   23-Mar-93  DS  some corrections          }
{                       1.21   14-May-93  DS  some style updates        }
{                       1.30   18-Oct-93  DS  added a checking of copy  }
{                                             already installed on disk }
{                       2.00   11-Aug-96  DS  added default partition   }
{                                             loading w/timeout         }
{                       2.01   28-Nov-96  DS  fixed a bug for default   }
{                                             partition loading (marker }
{                                             destroyed boot menu)      }
{                       2.10   05-Dec-96  DS  added advancde boot logic }
{                       2.11   26-Jul-97  DS  updated documentation     }
{                       2.12   02-Aug-97  DS  removed tabs              }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   OS_LOADER_FROM_FIXED_DISK;


{*** other modules ***}
USES
  ShowTErr;


{** switches for compilation **}
{$S-}           {*  stack checking   *}
{$R-}           {*  range checking   *}

{* generate version for loader code debugging *}
{***$DEFINE  DebugVersion}                  {debugging}
{***$DEFINE AdvancedBootManager}            {combine with other loader}


{*========================== CONSTANTS PART ============================*}

CONST

    { program definitions }
     asPurpose                  =       'OS-MultBoot';
     asVersion                  =       '2.12';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1992, 1997';
     asProgram                  =       'OS-Boot';
     asProgramPrompt            =       asProgram+': ';

     { exit codes }
       errTerminateOK           =     0;
       errBootStrapDebug        =     1;
       errBadReadFixedDisk      =     2;
       errBadWriteFixedDisk     =     3;
       errUserInstallAbort      =     4;
       errUserWriteAbort        =     5;
       errMismatchLoaderCode    =     6;
       errWrongOSselection      =     7;
       errBadTimeoutValue       =     8;

    { miscellaneous }
      aMaxTpStrLen              =     255;
      asBlank                   =     '';
      achHexPrefix              =     '$';
      asFreeSlot                =     ' <*** free slot ***>';
      asNonFreeSlot             =     ' <*** disk slot ***>';
      aSectorSize               =     512;
      aSecSizeInWords           =     aSectorSize DIV 2;
      aQuit                     =     'Q';
      achYes                    =     'Y';
      achNo                     =     'N';
      aDefExt                   =     'BIN';
      aDosExtMark               =     '.';

    { ASCII codes }
      achNULL                   =     00;
      achLF                     =     10;
      achCR                     =     13;
      achOne                    =     '1';
      achFour                   =     '4';

      {***** ATTENTION!!! Hard-coded values below. *****}
      {***** Please modify carefully!              *****}
{$IFDEF  DebugVersion}
      adwBootSeg                =     $8000;     { segment at 512K }
{$ELSE}
      adwBootSeg                =     $0000;     { segment at 0K }
{$ENDIF}
     adwBootOfs                 =     $7C00;
     adwRelBootOfs              =     adwBootOfs + aSectorSize;
     adwPartitionTable          =     $1BE;
     aPartitonEntrySize         =     $10;
     aMaxAvailLogicalPartition  =     4;
     adwBootMarkOfs             =     adwPartitionTable + (aPartitonEntrySize*aMaxAvailLogicalPartition);
     adwBootSecID               =     $AA55;

     aOS_Desc_Str_Len           =     $13;      { these values found }
     aOS_Desc_Ofs               =     $03;      { after assembly of  }
     aOS_Desc_Start             =     $31;      { IPL procedure.     }
     aOS_Desc_Str_Len_Ext       =     aOS_Desc_Str_Len + 2;
     aDefault_Part_Start        =     $1D;
     aDefault_TimeOut_Start     =     aDefault_Part_Start+1;
     asDefaultTimeout           =     10;       { seconds }

     aDebugOff                  =     0;
     aDebugOn                   =     1;

     aFarJumpOpCode             =     $EA;      { iAPX86 opcode }

     aRomKbdDriver              =     $16;      { IBM PC BIOS functions }
     aRomDiskDriver             =     $13;
     aRomVideoDriver            =     $10;

     aBiosTimerTicksPerSecond   =     18;       { BIOS timer resolution }
     aBiosTimerTicksLoc         =     $46C;     { BIOS timer update location }

  { use for to check of installed version }
     asCopyrightNotice          =     'OS-MultBoot v2.1';


{*====================== TYPED CONSTANTS PART ==========================*}

TYPE

  {* strings *}
       STR2                     =     STRING[2];
       STR4                     =     STRING[4];
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


{*=========================== VARIABLES PART ===========================*}

VAR

   grecFixedDiskBoot    :   recMasterBoot;
   gfOutStream          :   FILE  OF  recMasterBoot;
   gsTempInput          :   STRING;
   gsTemp               :   STRING;
   gdwOurBootRecLen     :   System.Word;
   gdwMemOfs            :   System.Word;
   giErrorCode          :   System.Integer;
   gbStatusOk           :   System.Boolean;
   gdbIndex             :   System.Byte;
   gdbValue             :   System.Byte;
   gchIn                :   System.Char;



{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE _IPL_Code; far; assembler;
{* Initial program loader. *}
{* Note 1: This procedure must be always first. *}
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
{$ENDIF}

        cli                           { disable ints during regs setup }
{$IFDEF DebugVersion}
        mov      ax, adwBootSeg
{$ELSE}
        sub      ax, ax
{$ENDIF}
        mov      ds, ax               { set seg registers to zero = ABS0 seg }
        mov      es, ax
        mov      ss, ax               { stack at $0000:$7C00 }
        mov      sp, adwBootOfs

        sti                           { re-enable intrs }
        cld                           { go forward }
        mov      si, sp               { DS:SI -> 0:$7C00 }
        mov      di, adwRelBootOfs    { ES:DI -> 0:$7E00 }
        mov      cx, aSecSizeInWords  { words count }
        rep      movsw                { relocate code to safe place }
                                      { jump to continue from new place }
        db       aFarJumpOpCode       { Direct FAR Jump }
        dw       adwRelBootOfs + (OFFSET @NewStart)
        dw       adwBootSeg
  @dbLoadDefaultPartition:            { the order is very important!! }
        db       0                    { Warning: hard-coded offset! }
  @dbLoadDefaultTimeout:
        db       0
                                      { messages for user }
                                      { offset to ref        =>  $10 }

  @dbUserMenu_MSG:
        db       "OS-MultBoot v2.1"
        db       achCR,achLF
                                      {** Hard-coded values, be carefully! **}
                                      { offset to ref        =>  $31 }
                                      { length of each entry =>  $13 }
                                      { offset of <None>     =>  $03 }
        db       " 1:None OS         "
        db       achCR, achLF

        db       " 2:None OS         "
        db       achCR, achLF

        db       " 3:None OS         "
        db       achCR, achLF

        db       " 4:None OS         "
        db       achCR, achLF

        db       "Select:"
        db       achNULL

  @LoadOS_MSG:
        db       achCR,achLF
        db       '<Load OS>'
        db       achCR,achLF
        db       achNULL

  @BadPartition_MSG:
        db       achCR,achLF
        db       '<Bad Partition>'
        db       achNULL

  @ErrLoadOS_MSG:
        db       achCR,achLF
        db       '<Error loading OS>'
        db       achNULL

  @BadOS_MSG:
        db       achCR,achLF
        db       '<Missing OS>'
        db       achNULL

  @BadUserSelect_MSG:
        db       achCR,achLF
        db       '<Bad select>'
        db       achNULL


  @AnyKey_MSG:
        db       achCR,achLF
        db       '..Strike any key..'
        db       achNULL


  @NewStart:
        mov      ah, 0Fh              { get video mode }
        int      aRomVideoDriver      { call ROM BIOS video driver }
        mov      ah, 00h              { set video mode }
        int      aRomVideoDriver      { call ROM BIOS video driver }

        mov      si, OFFSET  @dbUserMenu_MSG
        call     @AsciizOutput        { Display string in format <ASCII+zero> }

        mov      al, [OFFSET @dbLoadDefaultTimeout] + adwRelBootOfs
        mov      ah, aBiosTimerTicksPerSecond
        mul      ah
        or       ax, ax               {timeout == 0?}
        jz      @FakeKey

        mov      di, ax               {preserve timeout value}
        mov      bx, aBiosTimerTicksLoc
        mov      cx, es:[bx][2]       {high part}
        mov      dx, es:[bx][0]       {low part}

@CheckKeyInBuf:
        mov      si, es:[bx][2]       {high part}
        mov      ax, es:[bx][0]       {low part}
        sub      si, cx
        sbb      ax, dx
        cmp      ax, di
        mov      al, [OFFSET @dbLoadDefaultPartition] + adwRelBootOfs
        jae     @TimeoutOccurred

        mov      ah, 01h              { check for user char }
        int      aRomKbdDriver        { call ROM BIOS keyboard driver }
        jz      @CheckKeyInBuf

@FakeKey:
        mov      ah, 00h              { get user char }
        int      aRomKbdDriver        { call ROM BIOS keyboard driver }

@TimeoutOccurred:
        cmp      al, achOne           { test for match value }
        jb       @BadEntry
        cmp      al, achFour
        ja       @BadEntry

        and      ax, $0007            { must in range 1..4 }
        mov      cl, 4                { each entry in PT occupies }
        shl      al, cl               { exactly 16 bytes }
        mov      si, adwRelBootOfs + adwPartitionTable - aPartitonEntrySize
        add      si, ax               { DS:SI -> Partition Table entry }

        mov      dx, [si]             { DH = head, DL = drive }
        mov      cx, [si+2]           { CX = cyl/sec }
        mov      ax, cx               { test valid info }
        or       ax, dx
        jz       @BadPartition        { jump if unable to load this }

        or       dl, 080h             { turn on a bit for fixed disk }
        mov      bx, adwBootOfs       { ES:BX -> buffer }
        mov      bp, 7                { retry count }

  @TryLoad:
       mov      ax, 0201h             { read one sector from disk to memory }
       int      aRomDiskDriver        { call ROM BIOS disk driver }
       jnc      @LoadOk               { jump if driver says OK }
       xor      ah, ah                { reset controller }
       int      aRomDiskDriver        { call ROM BIOS disk driver }
       dec      bp                    { decrement a retries counter }
       jnz      @TryLoad
                                      { may be disk bad? }
       mov      si, OFFSET  @ErrLoadOS_MSG

  @UserWarning:
        call     @AsciizOutput        { Display string in format <ASCII+zero> }

        mov      si, OFFSET  @AnyKey_MSG
        call     @AsciizOutput        { Display string in format <ASCII+zero> }

        mov      ah, 00h              { get user char }
        int      aRomKbdDriver        { call ROM BIOS keyboard driver }
        jmp      @NewStart

  @LoadOk:                            { check boot ID }
        cmp     word ptr [bx+adwBootMarkOfs], adwBootSecID
        jne    @BadOS

        mov      si, OFFSET  @LoadOS_MSG
        call     @AsciizOutput        { Display string in format <ASCII+zero> }
        db     aFarJumpOpCode         { Direct Far Jump }
        dw     adwBootOfs, adwBootSeg { address }

  @BadEntry:                          { invalid user option }
        mov    si, OFFSET  @BadUserSelect_MSG
        jmp    @UserWarning

  @BadOS:                             { non-bootable sector }
        mov    si, OFFSET  @BadOS_MSG
        jmp    @UserWarning

  @BadPartition:                      { bad partition table }
        mov    si, OFFSET  @BadPartition_MSG
        jmp    @UserWarning


 {** _AsciizOutput  PROC NEAR **}
  @AsciizOutput:
        add    si, adwRelBootOfs      { fix problem with relocation }

  @NextChar:
        lodsb                         { get char }
        or       al, al               { AL is zero? }
        jz       @Done                { exit if match }
        push     si                   { preserve SI (may be destroyed for older BIOS versions!) }
        mov      bx, 0007h            { white-on-black }
        mov      ah, 0Eh              { TTY function }
        int      aRomVideoDriver      { call ROM BIOS video driver }
        pop      si                   { recover SI }
        jmp      @NextChar

  @Done:
        retn                          { return to caller }
 {** _AsciizOutput  ENDP  **}

END; {end-asm}
{ _IPL_Code }


PROCEDURE    _DummyProc;
{* It is used for reference only. Don't remove this code!!! *}
BEGIN
  {** nothing!!! *}
  asm
      db  0,0,0,0
  end;
  {asm-end}
END;
{ _DummyProc }



{*=========================== FUNCTIONAL PART ==========================*}

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


{*============================== MAIN PART =============================*}

BEGIN

  {* copyright message *}
    _CopyrightDisplay;


  {* set a length of boot code, don't count TP RETF instruction *}
     gdwOurBootRecLen := System.Ofs(_DummyProc) - System.Ofs(_IPL_Code) - 1;


  {* test bootstrap procedure *}
{$IFDEF  DebugVersion}
    System.WriteLn(asProgramPrompt+'Debugging of boostrap procedure.');
    asm
      mov        ax,  aDebugOn        { no relocated code }
    END;
    {asm-end}

    _IPL_Code;

   System.Halt(errBootStrapDebug);
{$ENDIF}

  {* test for match length of IPL *}
     IF  (gdwOurBootRecLen > adwPartitionTable)
       THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Bad size of loader code please re-code.');
         System.Halt(errMismatchLoaderCode);
             END;
     {if-then}

  {* Read original master boot record *}
    System.WriteLn(asProgramPrompt+'Reading of MBR.');
    gbStatusOk := System.True;
    asm
        mov     dx, 0080h             { drive 0, head 0 }
        mov     cx, 0001h             { cyl 0, sec 1 }
        mov     ax, ds
        mov     es, ax                { ES = Turbo DS }
        mov     bx, OFFSET grecFixedDiskBoot
        mov     ax, 0201h             { read 1 sector }
        int     aRomDiskDriver        { ROM BIOS disk driver }
        jnc     @Done
                                      { at this point reading failed }
        mov     gbStatusOk, System.False

     @Done:
    END;
    {ams-end}

  IF NOT(gbStatusOk)
    THEN  BEGIN
       System.WriteLn(asProgramPrompt+'Unable to read MBR from fixed disk.');
       System.Halt(errBadReadFixedDisk);
          END;
  {if-then}


  {* check for presence of installed loader *}
     System.Move(grecFixedDiskBoot,gsTempInput[1],aMaxTpStrLen);
     gsTempInput[0] := System.Char(aMaxTpStrLen);
     IF  (System.Pos(asCopyrightNotice,gsTempInput) <> 0)
       THEN  BEGIN
          System.WriteLn(asProgramPrompt+asProgram+' loader found on fixed disk 0.');
          System.Write(asProgramPrompt+'Copy description strings from installed copy (Y/N): ');
          System.ReadLn(gsTempInput);

          IF  (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achNo)
             THEN  BEGIN
                System.WriteLn(asProgramPrompt+'Copy description strings.');
                System.Move(System.Mem[System.Seg(grecFixedDiskBoot.dbReservedCode):
                            (System.Ofs(grecFixedDiskBoot.dbReservedCode)+aOS_Desc_Start)],
                            System.Mem[System.Seg(System.Addr(_IPL_Code)^):aOS_Desc_Start],
                            aOS_Desc_Str_Len_Ext*aMaxAvailLogicalPartition);
                   END;
          {if-then}
             END
       ELSE
          System.WriteLn(asProgramPrompt+asProgram+' loader not present.');
     {if-then}


  {* save original boot record *}
     System.Write(asProgramPrompt+'Save original MBR (Y/N): ');
     System.ReadLn(gsTempInput);
     IF  ((System.UpCase(gsTempInput[1]) <> achNo) OR (gsTempInput = asBlank))
       THEN  BEGIN
         System.Write(asProgramPrompt+'Enter filename (def.ext.='+aDefExt+'): ');
         System.ReadLn(gsTempInput);
         IF (gsTempInput <> asBlank)
           THEN  BEGIN
              gsTempInput := _fnsForceFileExtension(gsTempInput,aDefExt);
              System.WriteLn(asProgramPrompt+'Copy original MBR to file.');
            {** no check for errors **}
              System.Assign(gfOutStream,gsTempInput);
              System.Rewrite(gfOutStream);
              System.Write(gfOutStream,grecFixedDiskBoot);
              System.Close(gfOutStream);
                 END;
         {if-then}
             END;
     {if-then}


  {* make a new boot record *}
    System.WriteLn(asProgramPrompt+'Copy loader code.');
    System.Move(System.Mem[System.Seg(System.Addr(_IPL_Code)^):0],
                           grecFixedDiskBoot,
                           gdwOurBootRecLen);

  {* Ask user about installation. *}
     System.Write(asProgramPrompt+'Install OS-MBoot. Are you sure (N/Y): ');
     System.ReadLn(gsTempInput);
     IF  (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achYes)
       THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Aborted by user.');
         System.Halt(errUserInstallAbort);
             END;
     {if-then}


  {* Ask user about OS select. *}
     gbStatusOk := System.False;

     REPEAT
      {* display current settings *}
       System.WriteLn(asProgramPrompt+'Operating System (OS)  Define Menu: ');
       FOR  gdbIndex  := 0  TO  aMaxAvailLogicalPartition-1  DO
       BEGIN
         {* wipe default partition mark *}
         System.Mem[System.Seg(grecFixedDiskBoot):
                    System.Ofs(grecFixedDiskBoot.dbReservedCode[aOS_Desc_Start+(aOS_Desc_Str_Len_Ext*gdbIndex)])]
                    := System.Byte(' ');
         {* copy found strings *}
         System.Move(grecFixedDiskBoot.dbReservedCode[aOS_Desc_Start+(aOS_Desc_Str_Len_Ext*gdbIndex)],
                     gsTempInput[1],
                     aOS_Desc_Str_Len);
         gsTempInput[0] := System.Char(aOS_Desc_Str_Len);
         {* check for free slot *}
             CASE (grecFixedDiskBoot.recDiskPartitionsTable[gdbIndex].dbOperatingSystemID) OF
                     $00  :  gsTemp := '<Empty>';
                     $01  :  gsTemp := '<DOS FAT12>';
                     $02  :  gsTemp := '<XENIX root file system>';
                     $03  :  gsTemp := '<XENIX /usr file system>';
                     $04  :  gsTemp := '<DOS FAT16 upto 32MB>';
                     $05  :  gsTemp := '<DOS 3.3+ extended partition>';
                     $06  :  gsTemp := '<DOS FAT16 3.31+ more 32MB>';
                     $07  :  gsTemp := '<QNX/HPFS/NTFS/Unix>';
                     $08  :  gsTemp := '<OS/2 v1.x or AIX or Commodre or DELL>';
                     $09  :  gsTemp := '<AIX data or Coherent filesystem>';
                     $0A  :  gsTemp := '<OS/2 boot or OPUS or Coherent swap>';
                     $0B  :  gsTemp := '<Windows 95 with FAT32>';
                     $0C  :  gsTemp := '<Windows 95 with FAT32 (LBA)>';
                     $0E,
                     $0F  :  gsTemp := '<Microsoft LBA VFAT>';
                     $10  :  gsTemp := '<OPUS>';
                     $11  :  gsTemp := '<OS/2 Boot Manager hidden FAT12>';
                     $12  :  gsTemp := '<Compaq Diagnostics>';
                     $14  :  gsTemp := '<OS/2 Boot Manager hidden sub-32M FAT16>';
                     $16  :  gsTemp := '<OS/2 Boot Manager hidden over-32M FAT16>';
                     $17  :  gsTemp := '<OS/2 Boot Manager hidden HPFS>';
                     $18  :  gsTemp := '<AST special Windows swap file>';
                     $24  :  gsTemp := '<NEC MS-DOS 3.x>';
                     $3C  :  gsTemp := '<PowerQuest PartitionMagic recovery>';
                     $40  :  gsTemp := '<VENIX 80286>';
                     $41  :  gsTemp := '<Personal RISC Boot>';
                     $42  :  gsTemp := '<Secure File System (SFS)>';
                     $50  :  gsTemp := '<OnTrack Disk Manager (read-only)>';
                     $51  :  gsTemp := '<OnTrack Disk Manager (read-write) or NOVEL>';
                     $52  :  gsTemp := '<Microport System V/386 or CP/M>';
                     $53  :  gsTemp := '<OnTrack Disk Manager (write-only)>';
                     $54  :  gsTemp := '<OnTrack Disk Manager (DDO)>';
                     $56  :  gsTemp := '<GoldenBow VFeature>';
                     $61  :  gsTemp := '<SpeedStor>';
                     $63  :  gsTemp := '<Unix SysV/386 or Mach or GNU HURD>';
                     $64  :  gsTemp := '<Novell NetWare 286>';
                     $65  :  gsTemp := '<Novell NetWare (3.11)>';
                     $67,
                     $68,
                     $69  :  gsTemp := '<Novel>';
                     $70  :  gsTemp := '<DiskSecure Multi-Boot>';
                     $75  :  gsTemp := '<PC/IX>';
                     $80  :  gsTemp := '<Minix v1.1 - 1.4a>';
                     $81  :  gsTemp := '<Minix v1.4b+ or Linux or Mitac ADM>';
                     $82  :  gsTemp := '<Linux Swap or Prime>';
                     $83  :  gsTemp := '<Linux native file system>';
                     $84  :  gsTemp := '<OS/2 hides DOS FAT16 drive>';
                     $87  :  gsTemp := '<HPFS Fault-Tolerant mirrored>';
                     $93  :  gsTemp := '<Amoeba file system>';
                     $94  :  gsTemp := '<Amoeba bad block table>';
                     $A5  :  gsTemp := '<FreeBSD or BSD/386>';
                     $B7  :  gsTemp := '<BSDI file system (secondary swap)>';
                     $B8  :  gsTemp := '<BSDI swap (secondary file system)>';
                     $C1  :  gsTemp := '<DR DOS 6.0 LOGIN.EXE-secured FAT12>';
                     $C4  :  gsTemp := '<DR DOS 6.0 LOGIN.EXE-secured FAT16>';
                     $C6  :  gsTemp := '<DR DOS 6.0 LOGIN.EXE-secured Huge>';
                     $C7  :  gsTemp := '<Syrinx Boot>';
                     $D8  :  gsTemp := '<CP/M-86>';
                     $DB  :  gsTemp := '<Concurrent CP/M or CTOS>';
                     $E1  :  gsTemp := '<SpeedStor FAT12>';
                     $E3  :  gsTemp := '<DOS (read-only) or Storage Dimensions>';
                     $E4  :  gsTemp := '<SpeedStor FAT16>';
                     $F1  :  gsTemp := '<Storage Dimensions>';
                     $F2  :  gsTemp := '<DOS 3.3+ secondary>';
                     $F4  :  gsTemp := '<SpeedStor>';
                     $FE  :  gsTemp := '<LANstep or IBM PS/2 IML>';
                     $FF  :  gsTemp := '<Xenix bad block table>';
               ELSE
                     gsTemp := '<Reserved or unknown>';
             END;
             {case-of}
         gsTempInput := gsTempInput + gsTemp;
         System.WriteLn(gsTempInput);
       END;
       {for-to-do}
       System.WriteLn('[Q] Quit');
       System.Write('Select your option(1,2,3,4,Q): ');

     {* get user input *}
       System.ReadLn(gsTempInput);
       gchIn := System.UpCase(_fnchGetFirstChar(gsTempInput));

       IF (gsTempInput <> asBlank)
         THEN  CASE  gchIn  OF
                        achOne..achFour  :  BEGIN
       {* only 4 logical partitions enabled *}
         gdbIndex := System.Byte(gchIn) - System.Byte(achOne);
         System.Write(asProgramPrompt+'Enter OS/ID string (up ',(aOS_Desc_Str_Len-aOS_Desc_Ofs),' chars): ');
         System.ReadLn(gsTempInput);

         IF  (gsTempInput <> asBlank)
           THEN  BEGIN
       {* cut string if need *}
         WHILE  (System.Length(gsTempInput) > (aOS_Desc_Str_Len-aOS_Desc_Ofs)) DO
           System.Delete(gsTempInput,System.Length(gsTempInput),1);
         {while-do}
       {* copy ID string *}
         System.Move(gsTempInput[1],
                     grecFixedDiskBoot.dbReservedCode[aOS_Desc_Start+((aOS_Desc_Str_Len+2)*gdbIndex)+aOS_Desc_Ofs],
                     System.Length(gsTempInput));
                 END
         {if-then}
                                     END;
                        aQuit       :  gbStatusOk := System.True;
                 ELSE
                     System.WriteLn(asProgramPrompt+'Bad selection.');
               END;
               {case-of}
       {if-then}
     UNTIL (gbStatusOk);
     {repeat-until}


  {* Ask user about default partiton *}
     System.Write(asProgramPrompt+'Set a default OS to load. Are you sure (Y/N): ');
     System.ReadLn(gsTempInput);
     IF  (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achNo)
       THEN  BEGIN
         System.Write(asProgramPrompt+'Set a default OS [1..4]: ');
         System.ReadLn(gsTempInput);
         gchIn := System.UpCase(_fnchGetFirstChar(gsTempInput));
         IF (gchIn IN [achOne..achFour])
           THEN BEGIN
              gdbIndex := System.Byte(gchIn) - System.Byte(achOne);
              System.Mem[System.Seg(grecFixedDiskBoot):
                         System.Ofs(grecFixedDiskBoot.dbReservedCode[aOS_Desc_Start+(aOS_Desc_Str_Len_Ext*gdbIndex)])]
                         := System.Byte('*');
              System.Mem[System.Seg(grecFixedDiskBoot):
                         System.Ofs(grecFixedDiskBoot.dbReservedCode[aDefault_Part_Start])]
                         := System.Byte(gchIn);
              System.Write(asProgramPrompt+
                           'Set a default timeout (2..255 secs, def.=',
                           asDefaultTimeout,'): ');
              System.ReadLn(gsTempInput);
              IF  (gsTempInput = asBlank)
                THEN  Str(asDefaultTimeout, gsTempInput);
              {if-then}
              Val(gsTempInput, gdbValue, giErrorCode);
              IF (giErrorCode <> 0) OR NOT(gdbValue IN [2..255])
                THEN  BEGIN
                  System.WriteLn(asProgramPrompt+'Bad timeout value.');
                  System.Halt(errBadTimeoutValue);
                      END;
              {if-then}
              System.Mem[System.Seg(grecFixedDiskBoot):
                         System.Ofs(grecFixedDiskBoot.dbReservedCode[aDefault_Timeout_Start])]
                         := gdbValue;
                END
           ELSE BEGIN
             System.WriteLn(asProgramPrompt+'Wrong OS selection.');
             System.Halt(errWrongOSselection);
                END;
         {if-then-else}
             END;
     {if-then}

  {* Ask user about writing. *}
     System.Write(asProgramPrompt+'Write a new IPL. Are you sure (N/Y): ');
     System.ReadLn(gsTempInput);
     IF  (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achYes)
       THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Aborted by user.');
         System.Halt(errUserWriteAbort);
             END;
     {if-then}


  {* Write a new master boot record *}
    System.WriteLn(asProgramPrompt+'Writing of MBR.');
    gbStatusOk := System.True;
    asm
        mov     dx, 0080h             { drive 0, head 0 }
{$IFDEF   AdvancedBootManager}
        mov     cx, 0002h             { cyl 0, sec 2 }
{$ELSE}  {AdvancedBootManager}
        mov     cx, 0001h             { cyl 0, sec 1 }
{$ENDIF  {AdvancedBootManager}
        mov     ax, ds
        mov     es, ax                { ES = Turbo DS }
        mov     bx, OFFSET grecFixedDiskBoot
        mov     ax, 0301h             { write one sector }
        int     aRomDiskDriver        { ROM BIOS disk driver }
        jnc     @Done
                                      { we know that writing failed here }
        mov     gbStatusOk, System.False

     @Done:
    END;
    {asm-end}

  IF NOT(gbStatusOk)
    THEN  BEGIN
       System.WriteLn(asProgramPrompt+'Unable to write MBR to fixed disk.');
       System.Halt(errBadWriteFixedDisk);
          END;
  {if-then}


  {* final report *}
{$IFDEF   AdvancedBootManager}
    System.WriteLn(asProgramPrompt+'Don''t forget to install boot stage 1!!!');
{$ENDIF  {AdvancedBootManager}
    System.WriteLn(asProgramPrompt+'Done.');

  {* System.Halt(errTerminateOk); *}
END.
