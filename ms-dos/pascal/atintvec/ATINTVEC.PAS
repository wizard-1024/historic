{****************************************************************************
//                            File ATINTVEC.PAS
//
//            Builder for PC/AT ROM BIOS interrupt vector table
//
//      Copyright (c) 1993, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/ATINTVEC/RCS/atintvec.pas $
//  $RCSfile: atintvec.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 15:06:47 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: atintvec.pas $
//      Revision 1.1  1998/10/03 15:06:47  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                AT_INTERRUPT_VECTOR_TABLE_DUMP                  }
{ FILE NAME             ATINTVEC.PAS                                    }
{ PURPOSE               Build the PC/AT ROM BIOS Interrupt Vector Table }
{                       (Ints 00h-1Fh,70h-77h,02h,05h)                  }
{ VERSION               1.13                                            }
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
{ COMPILER              Turbo Pascal Version 7.0                        }
{                       (Borland International Inc.) or compatible      }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             <infile>     -   input  stream                  }
{                       <outfile>    -   output stream                  }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               Binary file must be exactly 65,536 bytes (64K)  }
{ DESCRIPTION           1. Read ROM-image input stream                  }
{                       2. Extract the ROM BIOS vector information      }
{                       3. Write converted output stream                }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   21-May-93  DS  initilal release          }
{                       1.01   04-Jul-93  DS  some corrections          }
{                       1.10   20-Sep-93  DS  some style updates        }
{                       1.11   26-Jul-97  DS  updated documentation     }
{                       1.12   02-Aug-97  DS  removed tabs              }
{                       1.13   02-Sep-97  DS  fixed open r/o file bug   }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   ATROMBIOSVectorTable;


{*** other modules ***}
USES
   ShowTErr;


{** switches for compilation **}
{$M 16384,65536,65536 }   {* memory allocation   *}
{$S-}                     {* stack checking      *}
{$R-}                     {* range checking      *}
 

{*========================== CONSTANTS PART ============================*}

CONST
     asPurpose                  =       'ATROMIntVecTbl Builder';
     asVersion                  =       '1.13';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1993, 1997';
     asProgramPrompt            =       'ATVecTbl: ';
     asProgram                  =       'ATVecTbl';
     asProgramU                 =       'ATVECTBL';

   { exit codes }
     errTerminateOK             =     0;
     errBadParmsNumber          =     1;
     errSourceNotFound          =     2;
     errDestDontWrite           =     3;
     errSameNames               =     4;
     errSrcOpenFailed           =     6;
     errDestCreateFailed        =     7;
     errInsufficientMemory      =     8;
     errReadSource              =     9;

   { miscellaneous }
     achDosExtMark              =     '.';
     asBlankStr                 =     '';
     asSpaces5                  =     '     ';
     asInDefExt                 =     'bin';
     asOutDefExt                =     'int';

   { ASCII characters }
     achNULL                    =     #0;
     achHTAB                    =     #9;
     achCR                      =     #13;
     achBlank                   =     ' ';

     achYes                     =     'Y';
     achNo                      =     'N';

   { spaces strings }
     asSpace2                   =       achBlank+achBlank;
     asSpace4                   =       asSpace2+asSpace2;
     asSpace6                   =       asSpace4+asSpace2;
     asSpace8                   =       asSpace6+asSpace2;

   { number base conversion }
     aHexRadix                  =     16;
     achHexPrefix               =     '$';

   { default values }
     aDefBaseNumber             =     16;

   { buffers size }
     aMaxInBufSize              =     65536;          { 64K }
     aMaxInBufSizeDiv2          =     65536 DIV 2;    { 32K }
     aMaxInBufSizeParas         =     65536 SHR 4;    { 64K / 16 }
     aProgramMemory             =     160;            { 128+32 Kb }


   { IBM AT hard-coded addresses }
     aRomIntVecTableOfs00       =      $FEE3;
     aRomIntVecTableOfs70       =      $FF23;
     aRomIntVecOfs02            =      $E2C3;
     aRomIntVecOfs05            =      $FF54;


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
    STR2        =       STRING[2];
    STR4        =       STRING[4];


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

    setHexChars              :   SET  OF  System.Char  =  ['0'..'9','A'..'F','a'..'f'];
    setUnusedLeadChars       :   SET  OF  System.Char  =  [achHTAB,achBlank];

    gadbFirstIntVecNum00      :   System.Byte           =   $00;     {group 00-1F}
    gadbLastIntVecNum1F       :   System.Byte           =   $1F;

    gadbFirstIntVecNum70      :   System.Byte           =   $70;     {group 70-77}
    gadbLastIntVecNum77       :   System.Byte           =   $77;

    gadbIntVec02              :   System.Byte           =   $02;     {fixed interrupt}
    gadbIntVec05              :   System.Byte           =   $05;     {fixed interrupt}


{*=========================== VARIABLES PART ===========================*}

VAR
   gfInputStream        :       FILE;
   gsInFileName         :       STRING[80];

   gfOutputStream       :       System.Text;
   gfOutputStreamRec    :       FILE  ABSOLUTE  gfOutputStream;
   gsOutFileName        :       STRING[80];

   gdwInBufDosSeg       :       System.Word;
   gdwResCount          :       System.Word;
   giErrorCode          :       System.Integer;
   gsTempInput          :       STRING;


{*=========================== FUNCTIONAL PART ==========================*}

FUNCTION  _fnbFileExist(VAR fStruc : FILE; sFileName : STRING) : System.Boolean;
{* Check that file exits. *}
VAR
  bResult  :  System.Boolean;
  dbOldFileMode  :  System.Byte;

BEGIN
    {Use safe mode to open}
    dbOldFileMode := System.FileMode;
    System.FileMode := $20;   {read, deny write on share}

  {** attempt to open the file **}
    System.Assign(fStruc,sFileName);
    {$I-}
    System.Reset(fStruc);
    {$I+}

  {** copy the result of last I/O operation **}
    bResult := (System.IOResult = 0);

    IF (bResult)
      THEN  System.Close(fStruc);
    {if-then}

   {Restore defaults}
   dbOldFileMode := System.FileMode;

  _fnbFileExist := bResult;
END; { _fnbFileExist }


FUNCTION  _fnsForceFileNameExt(sFileName, sDefExt : STRING) : STRING;
{* Add extension for filename if not present. *}
BEGIN
   IF (System.Pos(achDosExtMark,sFileName) = 0)
     THEN sFileName := sFileName + achDosExtMark + sDefExt;
   {if-then}
  _fnsForceFileNameExt := sFileName;
END;
{ _fnsForceFileNameExt }


FUNCTION   _fnchGetFirstChar(sInput : STRING) : System.Char;
{* Returns a first char from string. *}
VAR
  chTemp  :  System.Char;

BEGIN
   IF (System.Length(sInput) <> 0)
     THEN  chTemp := sInput[1]
     ELSE  chTemp := achNULL;
   {if-then-else}
  _fnchGetFirstChar := chTemp;
END;
{ _fnchGetFirstChar }



FUNCTION  _fnsUpcaseStr(sInput : STRING) : STRING;
{* Make all uppercase. *}
VAR
  dbIndex  :  System.BYTE;
  dbCount  :  System.BYTE;

BEGIN
  dbCount := System.Length(sInput);

  IF (dbCount <> 0)
    THEN  FOR dbIndex :=  1  TO  dbCount DO
             sInput[dbIndex] := System.Upcase(sInput[dbIndex]);
         {for-to-do}
  {if-then}

   _fnsUpcaseStr := sInput;
END; { _fnsUpcaseStr }


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



FUNCTION   _fnsByteToHexFmt(dbInput : System.Byte) : STR2;
{* Converts a byte to the hex format number representation. *}
CONST
    dbHexCharTable : ARRAY[0..15] OF System.Char = '0123456789ABCDEF';

BEGIN
  _fnsByteToHexFmt := dbHexCharTable[dbInput SHR 4] + dbHexCharTable[dbInput AND $0F];
END;  { _fnsByteToHexFmt }


FUNCTION   _fnsWordToHexFmt(dwInput : System.Word) : STR4;
{* Converts a word to the hex format number representation. *}
BEGIN
  _fnsWordToHexFmt := _fnsByteToHexFmt(System.Hi(dwInput)) +
                      _fnsByteToHexFmt(System.Lo(dwInput));
END;  { _fnsWordToHexFmt }




{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+
                    '  Version '+
                    asVersion+
                    ', '+
                    asCopyright+
                    '  '+
                    asAuthor);
END;  { _CopyrightDisplay }


PROCEDURE  _AllocDosMem(VAR dwDosMemSeg : System.Word; dwParas : System.Word);
{* Allocates a memory through DOS service. *}
VAR
  bFuncFail  :  System.Boolean;

BEGIN
   bFuncFail := System.True;
   asm
      mov    bx, dwParas                { # of memory paragraphas }
      mov    ah, 48h                    { alloc memory block of given size }
      int    21h                        { call DOS service }
      jc     @Done                      { jump if error occurred }

      mov    bFuncFail, System.False    { function ok }
      les    di, dwDosMemSeg            { get TP variable address }
      mov    es:[di], ax                { save DOS block segment }

    @Done:
   end;
   {asm-end}

   IF  (bFuncFail)
     THEN  BEGIN
       System.WriteLn(asProgramPrompt+'Insufficient memory. Program need about ',
                      aProgramMemory,' Kbytes');
       System.Halt(errInsufficientMemory);
           END;
   {if-then}
END;
{ _AllocDosMem }


PROCEDURE  _DeAllocDosMem(dwDosMemSeg : System.Word);
{* Freezes a memory through DOS service. *}
VAR
  bFuncFail  :  System.Boolean;

BEGIN
   asm
      mov    es, dwDosMemSeg            { memory block address }
      mov    ah, 49h                    { free memory block }
      int    21h                        { call DOS service }
   end;
   {asm-end}
END;
{ _DeAllocDosMem }


PROCEDURE  _DisplayIntVectorsInfo(dwTableOfs : System.Word;
                                  dbFirstIntVecNum, dbLastIntVecNum : System.Byte;
                                  bUseTableEntry : System.Boolean);
{* Display info about each requested interrupt vector. *}
VAR
  dwMemOfs      :       System.Word;
  dwActualOfs   :       System.Word;
  dwIBMentry    :       System.Word;
  dwTempOfs     :       System.Word;
  sTempInput    :       STRING;
  dbIndex       :       System.Byte;
  dbTestOpCode  :       System.Byte;

BEGIN
    FOR  dbIndex := dbFirstIntVecNum  TO  dbLastIntVecNum DO
    BEGIN
       sTempInput := asBlankStr;
       dwMemOfs := dwTableOfs;
       IF  (bUseTableEntry)
         THEN  dwTempOfs := System.MemW[gdwInBufDosSeg:dwMemOfs]
         ELSE  dwTempOfs := dwTableOfs;
       {if-then-else}
       dwActualOfs := dwTempOfs;
       IF  (dwTempOfs <= $FFF0)
         THEN  BEGIN
            dbTestOpCode := System.Mem[gdwInBufDosSeg:dwTempOfs];
            CASE  (dbTestOpCode)  OF
                      $E9  :  BEGIN
                                 FOR  dwActualOfs := 0  TO  2  DO
                                    sTempInput := sTempInput +
                                                  _fnsByteToHexFmt(Mem[gdwInBufDosSeg:(dwTempOfs+dwActualOfs)])+
                                                  achBlank;
                                 {fo-to-do}
                                 dwActualOfs := System.Word(System.LongInt(dwTempOfs+3) +
                                                 (System.LongInt(MemW[gdwInBufDosSeg:(dwTempOfs+1)])));
                              END;
                      $EA  :  BEGIN
                                 FOR  dwActualOfs := 0  TO  4  DO
                                    sTempInput := sTempInput +
                                                  _fnsByteToHexFmt(Mem[gdwInBufDosSeg:(dwTempOfs+dwActualOfs)])+
                                                  achBlank;
                                 {fo-to-do}
                              END;
                      $EB  :  BEGIN
                                 FOR  dwActualOfs := 0  TO  1  DO
                                    sTempInput := sTempInput +
                                                  _fnsByteToHexFmt(Mem[gdwInBufDosSeg:(dwTempOfs+dwActualOfs)])+
                                                  achBlank;
                                 {fo-to-do}
                                 dwActualOfs := System.Word(System.LongInt(dwTempOfs+2) +
                                                 (System.LongInt(Mem[gdwInBufDosSeg:(dwTempOfs+1)])));

                              END;
                      $CF  :  BEGIN
                                 FOR  dwActualOfs := 0  TO  0  DO
                                    sTempInput := sTempInput +
                                                  _fnsByteToHexFmt(Mem[gdwInBufDosSeg:(dwTempOfs+dwActualOfs)])+
                                                  achBlank;
                                 {fo-to-do}
                                 dwActualOfs := dwTempOfs;
                              END;
            ELSE
              {* reserved *}
            END;
            {case-of}
               END;
       {if-then}
       IF  (bUseTableEntry)
          THEN  dwIBMentry := System.MemW[gdwInBufDosSeg:dwMemOfs]
          ELSE  dwIBMentry := dwMemOfs;
       {if-then-else}
       System.WriteLn(gfOutputStream,
                      asSpace2+
                      achBlank+
                      _fnsByteToHexFmt(dbIndex)+
                      achBlank+
                      asSpace4+
                      achBlank+
                      _fnsWordToHexFmt(dwIBMentry)+
                      achBlank+
                      asSpace4+
                      achBlank+
                      _fnsWordToHexFmt(dwActualOfs)+
                      achBlank+
                      asSpace4+
                      sTempInput);
       System.Inc(dwTableOfs,2);
    END;
    {for-to-do}
END;
{ _DisplayIntVectorsInfo }



{*============================== MAIN PART =============================*}

BEGIN
  _CopyrightDisplay;

     IF (System.ParamCount < 2) THEN
     BEGIN
          System.WriteLn(asProgramPrompt+'  help screen for you.');
          System.WriteLn('Usage: infile outfile');
          System.WriteLn(' infile   - source filename                   (default extension='+asInDefExt+')');
          System.WriteLn(' outfile  - destination filename              (default extension='+asOutDefExt+')');
          System.Halt(errBadParmsNumber);
     END;
     {if-then}


  {** copy the parameters from command line **}
    gsInFileName  := _fnsUpcaseStr(System.ParamStr(1));
    gsInFileName := _fnsForceFileNameExt(gsInFileName,asInDefExt);

    gsOutFileName := _fnsUpcaseStr(System.ParamStr(2));
    gsOutFileName := _fnsForceFileNameExt(gsOutFileName,asOutDefExt);


  {* may be same names? *}
    IF (gsInFileName = gsOutFileName)  THEN
    BEGIN
      System.WriteLn(asProgramPrompt+'  Unable to use same file as input and as output');
      System.Halt(errSameNames);
    END;
    {if-then}


  {** source file exists? **}
    IF  NOT(_fnbFileExist(gfInputStream,gsInFileName)) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+' Unable to open file '+gsInFileName);
      System.Halt(errSourceNotFound);
    END;
    {if-then}


  {** destination file present? **}
  IF (_fnbFileExist(gfOutputStreamRec,gsOutFileName)) THEN
  BEGIN
    System.Write(asProgramPrompt+' Output file '+gsOutFileName+
                 ' already exists. Overwrite? (n/y): ');
    System.ReadLn(gsTempInput);
    IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achYes)
      THEN  System.Halt(errDestDontWrite);
    {if-then}
  END;
  {if-then}


  {** open the source file **}
    System.FileMode := $20;   {read, deny write on share}
    System.Assign(gfInputStream,gsInFileName);
    {$I-}
    System.Reset(gfInputStream,1);
    {$I+}

    IF  (System.IoResult <> 0) THEN
    BEGIN
      System.Write(asProgramPrompt+' Unable to open '+gsInFileName);
      System.Halt(errSrcOpenFailed);
    END;
    {if-then}


  {** ask memory from DOS **}
   _AllocDosMem(gdwInBufDosSeg,aMaxInBufSizeParas);


  {** read  binary image for ROM BIOS **}
    System.WriteLn(asProgramPrompt+' read binary image (1st part).');
    System.BlockRead(gfInputStream,System.Mem[gdwInBufDosSeg:0],aMaxInBufSizeDiv2,gdwResCount);
    IF  (gdwResCount <> aMaxInBufSizeDiv2)
      THEN  BEGIN
         System.WriteLn(asProgramPrompt+' Unable to read 1st part from '+gsInFileName);
         System.Halt(errReadSource);
            END;
    {if-then}
    System.WriteLn(asProgramPrompt+' read binary image (2nd part).');
    System.BlockRead(gfInputStream,System.Mem[gdwInBufDosSeg:aMaxInBufSizeDiv2],aMaxInBufSizeDiv2,gdwResCount);
    IF  (gdwResCount <> aMaxInBufSizeDiv2)
      THEN  BEGIN
         System.WriteLn(asProgramPrompt+' Unable to read 2nd part from '+gsInFileName);
         System.Halt(errReadSource);
            END;
    {if-then}


  {** create the destination file **}
    System.FileMode := 2; {read/write, compatibilty mode}
    System.Assign(gfOutputStream,gsOutFileName);
    {$I-}
    System.Rewrite(gfOutputStream);
    {$I+}

    IF  (System.IoResult <> 0) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+' Unable to create '+gsOutFileName);
      System.Halt(errDestCreateFailed);
    END;
    {if-then}


  {** output a header **}
    System.WriteLn(gfOutputStream);
    System.WriteLn(gfOutputStream,';**  SOURCE FILE:  '+gsInFileName);
    System.WriteLn(gfOutputStream,';**  Created by '+asProgram+' utility, '+asCopyright+'  '+asAuthor);
    System.WriteLn(gfOutputStream);

  {** output info about each interrupt vector **}
    System.WriteLn(gfOutputStream,asSpace2+'Int#'+asSpace4+'IBMROM'+asSpace4+'Actual'+asSpace4+'Comments');
    System.WriteLn(gfOutputStream,asSpace2+'----'+asSpace4+'------'+asSpace4+'------'+asSpace4+'--------');

    _DisplayIntVectorsInfo(aRomIntVecTableOfs00,gadbFirstIntVecNum00,gadbLastIntVecNum1F,System.True);
    System.WriteLn(gfOutputStream);
    _DisplayIntVectorsInfo(aRomIntVecTableOfs70,gadbFirstIntVecNum70,gadbLastIntVecNum77,System.True);
    System.WriteLn(gfOutputStream);
    _DisplayIntVectorsInfo(aRomIntVecOfs02,gadbIntVec02,gadbIntVec02,System.False);
    _DisplayIntVectorsInfo(aRomIntVecOfs05,gadbIntVec05,gadbIntVec05,System.False);


  {** free all memory from DOS **}
   _DeAllocDosMem(gdwInBufDosSeg);


  {** close all files **}
    System.Close(gfInputStream);
    System.Close(gfOutputStream);

  {** report all done **}
    System.WriteLn(asProgramPrompt+' Done.');

  {* System.Halt(errTerminateOk); *}
END.
