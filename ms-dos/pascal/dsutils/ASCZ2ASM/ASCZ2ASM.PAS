{****************************************************************************
//                            File ASCZ2ASM.PAS
//
//              Extract null-terminated messages from file
//
//      Copyright (c) 1993, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/ASCZ2ASM/RCS/ascz2asm.pas $
//  $RCSfile: ascz2asm.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 15:09:16 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: ascz2asm.pas $
//      Revision 1.1  1998/10/03 15:09:16  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                ASCIIZ_TO_ASM_CONVERTER                         }
{ FILE NAME             ASCZ2ASM.PAS                                    }
{ PURPOSE               Convert the binary file                         }
{                       (ASCII MESSAGES TERMINATED BY NULL)             }
{                       to an assembler format file.                    }
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
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             <infile>     -   input  stream                  }
{                       <outfile>    -   output stream                  }
{                       <maxbytes>   -   max # of chars per one line    }
{                       <dispofs>    -   display file offset of string  }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           1.Read from input stream                        }
{                       2.Write ASM-format  output stream               }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   13-Jul-93  DS  initilal release          }
{                       1.01   22-Sep-93  DS  some style updates        }
{                       1.10   28-Oct-93  DS  some minor changes        }
{                       1.11   26-Jul-97  DS  updated documentation     }
{                       1.12   02-Aug-97  DS  removed tabs              }
{                       1.13   02-Sep-97  DS  fixed open r/o file bug   }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   AsciizFileToAssemblerFormatFile;


{*** other modules ***}
USES
   ShowTErr;


{** switches for compilation **}
{$S-}                   {*  stack checking  *}
{$R-}                   {*  range checking  *}


{*========================== CONSTANTS PART ============================*}

CONST
     asPurpose                  =       'AsciizAsmFile Converter';
     asVersion                  =       '1.13';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1993, 1997';
     asProgram                  =       'Ascz2asm';
     asProgramPrompt            =       asProgram+': ';
     asProgramU                 =       'ASCZ2ASM';

     { exit codes }
     errTerminateOK             =     0;
     errBadParmsNumber          =     1;
     errSourceNotFound          =     2;
     errDestDontWrite           =     3;
     errSameNames               =     4;
     errSrcOpenFailed           =     6;
     errDestCreateFailed        =     7;
     errBadBytesValue           =     8;

   { miscellaneous }
     aPercent100                =     100;
     achHexPrefix               =     '$';
     achDosExtMark              =     '.';
     asBlankStr                 =     '';
     asSpaces2                  =     '  ';
     asSpaces5                  =     '     ';
     asInDefExt                 =     'bin';
     asOutDefExt                =     'asm';

   { defaults }
     aDefBytesPerLine           =     64;
     aMaxBytesPerLine           =     128;
     aMaxOnHeap                 =     65520;

   { characters }
     achNULL                    =     #0;
     achHTAB                    =     #9;
     achCR                      =     #13;
     achSPACE                   =     ' ';
     achZero                    =     '0';
     achSkip                    =     '.';
     achDelimiter               =     ',';
     achStrDelim                =     '''';
     achAnotherStrDelim         =     '"';
     achSemicolon               =     ';';

   { user confirm }
     achYes                     =     'Y';
     achNo                      =     'N';

   { assembler directives and equates }
     achHexSuffix               =     'h';
     asAsmDataDefine            =     'DB';
     asAsmNoList                =     '.XLIST';
     asAsmList                  =     '.LIST';


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
    STR2        =       STRING[2];
    STR3        =       STRING[3];
    STR4        =       STRING[4];
    STR8        =       STRING[8];
    STR80       =       STRING[80];


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

    setHexChars  :    SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];
    setAscii7    :    SET OF System.Char  =  [#32..#126];
    setAscii8    :    SET OF System.Char  =  [#32..#126,#128..#255];


    gabDisplayStrOffset  :       System.Boolean   =   System.False;
    gadbSymbolsInString  :       System.Byte      =   aDefBytesPerLine;
    gddStrInFileOfs      :       System.Longint   =   0;
    gddReadBytesCount    :       System.Longint   =   0;
    gasOutAsmLine        :       STRING           =   asBlankStr;


{*=========================== VARIABLES PART ===========================*}

VAR
   gfInputByteStream    :       FILE  OF  System.Byte;
   gfInputStream        :       FILE ABSOLUTE gfInputByteStream;
   gsInFileName         :       STR80;

   gfOutputFormatText   :       System.Text;
   gfOutputStream       :       FILE  ABSOLUTE  gfOutputFormatText;
   gsOutFileName        :       STR80;

   gddByteCount         :       System.Longint;
   gddInFileSize        :       System.Longint;

   giErrorCode          :       System.Integer;
   gsTempInput          :       STRING;
   gchInput             :       System.Char;



{*=========================== FUNCTIONAL PART ==========================*}

FUNCTION  _fnbFileExist(VAR fStruc : FILE;
                            sFileName : STRING) : System.Boolean;
{* Check that file exits. *}
VAR
  bResult        :  System.Boolean;
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
     THEN  sFileName := sFileName + achDosExtMark + sDefExt;
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


FUNCTION   _fnsDoubleWordToHexFmt(ddInput : System.Longint) : STR8;
{* Converts a double word to the hex format number representation. *}
BEGIN
  _fnsDoubleWordToHexFmt := _fnsWordToHexFmt(System.Word(ddInput SHR 16)) +
                      _fnsWordToHexFmt(System.Word(ddInput and $0000FFFF));
END;  { _fnsDoubleWordToHexFmt }


FUNCTION   _fnsByteToAsmFormat(dbInput : System.Byte) : STR4;
{* Converts a byte to the ASM format number representation. *}
BEGIN
  _fnsByteToAsmFormat := achZero +
                         _fnsByteToHexFmt(dbInput) +
                         achHexSuffix;
END;  { _fnsByteToAsmFormat }


FUNCTION  _fnsUpcaseStr(sInput : STRING) : STRING;
{* Make all uppercase. *}
VAR
  dbIndex  :  System.BYTE;
  dbCount  :  System.BYTE;

BEGIN
  dbCount := System.Length(sInput);

  IF (dbCount <> 0)  THEN
    FOR  dbIndex :=  1  TO  dbCount  DO
        sInput[dbIndex] := System.Upcase(sInput[dbIndex]);
    {for-to-do}
  {if-then}

   _fnsUpcaseStr := sInput;
END; { _fnsUpcaseStr }


FUNCTION  _fnsAsmPreformat : STRING;
{* Do an assembler DB directive. *}
BEGIN
      _fnsAsmPreformat :=  achHTAB +
                           achHTAB +
                           asAsmDataDefine +
                           achSPACE +
                           achSPACE +
                           achSPACE;
END;
{ _fnsAsmPreformat }


FUNCTION  _fnsAddHTabs(sInput : STRING) : STRING;
{* Adds # of htabs, based on the string length. *}
VAR
  dbLength   :   System.Byte;

BEGIN
   dbLength := 4;
   IF (System.Length(sInput) >= 7)
     THEN  System.Dec(dbLength);
   IF (System.Length(sInput) >= 14)
     THEN  System.Dec(dbLength);
   FillChar(sInput[1],dbLength,achHTAB);
   sInput[0] := System.Char(dbLength);
   _fnsAddHTabs := sInput;
END;
{ _fnsAddHTabs }


FUNCTION  _fnsNumToStr3(dwNum : System.Word) : STR3;
{* Convert a numeric value to its string representation. *}
VAR
  sTemp : STR3;

BEGIN
   System.Str(dwNum:3,sTemp);
   _fnsNumToStr3 := sTemp;
END;
{ _fnsNumToStr3 }



{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+'  Version '+asVersion+', '+asCopyright+'  '+asAuthor);
END;  { _CopyrightDisplay }



PROCEDURE  _FormattedLineOutput(sOutputLine :  STRING);
{* Writes formatted string. *}
BEGIN
    System.Write(achCR+asProgramPrompt+'Completed ('+
                _fnsNumToStr3((gddReadBytesCount*aPercent100) DIV gddInFileSize)+'%)');
    System.WriteLn(gfOutputFormatText,sOutputLine);
END;
{ _FormattedLineOutput }


PROCEDURE  _WriteOutputLine(sOutput : STRING; bZeroFound : System.Boolean);
{* Writes non-formatted string. *}
VAR
  chDelim       :       System.Char;
  sTemp         :       STRING;

BEGIN
             sTemp := sOutput;
             IF (System.Length(sTemp) <> 0)
               THEN  BEGIN
                     IF (System.Pos(achStrDelim,sTemp) <> 0)
                       THEN  chDelim := achAnotherStrDelim
                       ELSE  chDelim  := achStrDelim;
                     {if-then-else}
                     sTemp :=  _fnsAsmPreformat +
                                  chDelim +
                                  sTemp +
                                  chDelim;
                     END;
             {if-then}
             IF  (bZeroFound)
               THEN  BEGIN
                 IF (sTemp <> asBlankStr)
                       THEN  sTemp := sTemp + achDelimiter + achZero
                       ELSE  sTemp := _fnsAsmPreformat + achZero;
                 {if-then-else}
                     END;
             {if-then}
             IF (gabDisplayStrOffset)
               THEN  BEGIN
                 sTemp := sTemp +
                            _fnsAddHTabs(sOutput) +
                            achSemicolon +
                            achSPACE +
                            achSPACE +
                            achHexPrefix +
                            _fnsDoubleWordToHexFmt(gddStrInFileOfs);
                     END;
             {if-then}
             _FormattedLineOutput(sTemp);
END;
{ _WriteOutputLine }


PROCEDURE  _InitTemporaryValues;
{* Set empty string and get current file position. *}
BEGIN
   gasOutAsmLine := asBlankStr;
   gddStrInFileOfs := System.FilePos(gfInputByteStream);
END;
{ _InitTemporaryValues }


{*============================== MAIN PART =============================*}

BEGIN
  _CopyrightDisplay;

     IF (System.ParamCount < 2) THEN
     BEGIN
          System.WriteLn(asProgramPrompt+'  help screen for you.');
          System.WriteLn(' Usage: infile outfile [maxbytes [dispofs]]');
          System.WriteLn('   infile   -  source filename               (def. ext. = '+asInDefExt+')');
          System.WriteLn('   outfile  -  destination filename          (def. ext. = '+asOutDefExt+')');
          System.WriteLn('   maxbytes -  max. number chars per line    (def. num. = ',aDefBytesPerLine,
                         ', max=',aMaxBytesPerLine,')');
          System.WriteLn('   dispofs  -  display file offset of string (def. = no, any string to enable)');
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
      System.WriteLn(asProgramPrompt+'Unable to use same file as input and as output');
      System.Halt(errSameNames);
    END;
    {if-then}


  {** source file exists? **}
    IF  NOT(_fnbFileExist(gfInputStream,gsInFileName)) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+'Unable to open file '+gsInFileName);
      System.Halt(errSourceNotFound);
    END;
    {if-then}


  {** destination file present? **}
  IF (_fnbFileExist(gfOutputStream,gsOutFileName)) THEN
  BEGIN
    System.Write(asProgramPrompt+'Output file '+gsOutFileName+
                 ' already exists. Overwrite? (n/y): ');
    System.ReadLn(gsTempInput);
    IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achYes)
      THEN  System.Halt(errDestDontWrite);
    {if-then}
  END;
  {if-then}


  {** read the following parameter = bytes switch **}
    IF  (System.ParamCount >= 3) THEN
    BEGIN
         gsTempInput := System.ParamStr(3);
         System.Val(gsTempInput,gadbSymbolsInString,giErrorCode);
         IF  (gadbSymbolsInString = 0)  OR
              (gadbSymbolsInString > aMaxBytesPerLine)
            THEN   BEGIN
               System.WriteLn(asProgramPrompt+'Invalid value for BYTES switch.');
               System.Halt(errBadBytesValue);
                   END;
         {if-then}
    END;
    {if-then}


  {** display offset *}
    IF  (System.ParamCount >= 4) THEN
    BEGIN
        gabDisplayStrOffset := System.True;
    END;
    {if-then}


  {** open the source file **}
    System.FileMode := $20;   {read, deny write on share}
    System.Assign(gfInputByteStream,gsInFileName);
    {$I-}
    System.Reset(gfInputByteStream);
    {$I+}

    IF  (System.IoResult <> 0) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+'Unable to open '+gsInFileName);
      System.Halt(errSrcOpenFailed);
    END;
    {if-then}


  {** create the destination file **}
    System.FileMode := 2; {read/write, compatibilty mode}
    System.Assign(gfOutputFormatText,gsOutFileName);
    {$I-}
    System.Rewrite(gfOutputFormatText);
    {$I+}

    IF  (System.IoResult <> 0) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+'Unable to create '+gsOutFileName);
      System.Halt(errDestCreateFailed);
    END;
    {if-then}


  {** get a count of bytes to read. **}
    gddInFileSize := System.FileSize(gfInputByteStream);
    gddByteCount  := gddInFileSize;


  {** write first lines to output stream **}
    System.WriteLn(gfOutputFormatText);
    System.WriteLn(gfOutputFormatText,';  SOURCE FILE:  '+gsInFileName);
    System.WriteLn(gfOutputFormatText,';  Created by '+asProgram+' utility, '+asCopyright+'  '+asAuthor);
    System.WriteLn(gfOutputFormatText);
    System.WriteLn(gfOutputFormatText,asAsmNoList);
    System.WriteLn(gfOutputFormatText);


  {** main loop: read_buffer/write_to_text_file **}
    WHILE (gddByteCount <> 0) DO
    BEGIN
       System.Read(gfInputByteStream,System.Byte(gchInput));
       System.Inc(gddReadBytesCount,1);
       IF (gchInput = achNULL)
         THEN  BEGIN
             _WriteOutputLine(gasOutAsmLine,System.True);
             _InitTemporaryValues;
               END
         ELSE  BEGIN
             IF (gchInput IN setAscii8)
               THEN     BEGIN
                  gasOutAsmLine := gasOutAsmLine + gchInput;
                  IF (System.Length(gasOutAsmLine) >= gadbSymbolsInString)
                    THEN  BEGIN
                     _WriteOutputLine(gasOutAsmLine,System.False);
                     _InitTemporaryValues;
                          END;
                  {if-then}
                        END
               ELSE  BEGIN
                 IF (gasOutAsmLine <> asBlankStr)
                   THEN  _WriteOutputLine(gasOutAsmLine,System.False);
                 {if-then}
                 gasOutAsmLine:=  _fnsAsmPreformat +
                                  _fnsByteToAsmFormat(System.Byte(gchInput));
                 _FormattedLineOutput(gasOutAsmLine);
                 _InitTemporaryValues;
                     END;
                  {if-then-else}
               END;
       {if-then-else}
       System.Dec(gddByteCount);
    END;
    {while-do}


  {** write last lines to output stream **}
    IF (gasOutAsmLine <> asBlankStr)
      THEN  _WriteOutputLine(gasOutAsmLine,System.False);
    {if-then}
    System.WriteLn(gfOutputFormatText);
    System.WriteLn(gfOutputFormatText,asAsmList);



  {** close all files **}
    System.Close(gfInputStream);
    System.Close(gfOutputFormatText);


  {** report all done **}
    System.WriteLn;
    System.WriteLn(asProgramPrompt+'Done.');

  {* System.Halt(errTerminateOk); *}
END.
