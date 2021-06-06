{****************************************************************************
//                            File ASC2BIN.PAS
//
//                   Extract ASCII messages from file
//
//      Copyright (c) 1993, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/ASC2BIN/RCS/asc2bin.pas $
//  $RCSfile: asc2bin.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 15:10:54 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: asc2bin.pas $
//      Revision 1.1  1998/10/03 15:10:54  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                ASC_TO_BIN_CONVERTER                            }
{ FILE NAME             ASC2BIN.PAS                                     }
{ PURPOSE               Convert the ASCII file to the binary file.      }
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
{                       <base>       -   representation number base     }
{                       <type>       -   type of binary number          }
{                       <numcount>   -   # of extracted numbers/line    }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           1. Read from input stream                       }
{                       2. Convert ASCII to binary representation       }
{                       3. Write converted output stream                }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   15-May-93  DS  initilal release          }
{                       1.01   19-May-93  DS  some style corrections    }
{                       1.02   18-Oct-93  DS  some style updates        }
{                       1.10   28-Oct-93  DS  some minor changes        }
{                       1.11   26-Jul-97  DS  updated documentation     }
{                       1.12   02-Aug-97  DS  removed tabs              }
{                       1.13   02-Sep-97  DS  fixed a open r/o file bug }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   AsciiFormatFileToBinaryFormatFile;


{*** other modules ***}
USES
  ShowTErr;


{** switches for compilation **}
{$S-}                    {*  stack checking     *}
{$R-}                    {*  range checking     *}
{$M 16384,65536,65536}   {*  memory allocation  *}


{*========================== CONSTANTS PART ============================*}

CONST
     asPurpose                  =       'AscBinFile Converter';
     asVersion                  =       '1.13';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1993, 1997';
     asProgramPrompt            =       'Asc2bin: ';
     asProgram                  =       'Asc2bin';
     asProgramU                 =       'ASC2BIN';

   { exit codes }
     errTerminateOK             =     0;
     errBadParmsNumber          =     1;
     errSourceNotFound          =     2;
     errDestDontWrite           =     3;
     errSameNames               =     4;
     errSrcOpenFailed           =     6;
     errDestCreateFailed        =     7;
     errBadBase                 =     8;
     errBadType                 =     9;
     errBadBytesValue           =     10;

   { miscellaneous }
     achDosExtMark              =     '.';
     asBlankStr                 =     '';
     asSpaces5                  =     '     ';
     asInDefExt                 =     'asc';
     asOutDefExt                =     'bin';
     aPercent100                =     100;

   { ASCII characters }
     achNULL                    =     #0;
     achHTAB                    =     #9;
     achCR                      =     #13;
     achBlank                   =     ' ';

     achYes                     =     'Y';
     achNo                      =     'N';

   { number base conversion }
     aOctalRadix                =     8;
     aDecimalRadix              =     10;
     aHexRadix                  =     16;
     achHexPrefix               =     '$';

   { default values }
     aDefBaseNumber             =     16;
     aDefBytesPerBinaryNumber   =     1;
     aBinaryNumberBytes1        =     1;
     aBinaryNumberBytes2        =     2;
     aBinaryNumberBytes3        =     3;
     aBinaryNumberBytes4        =     4;
     aMaxBytesPerBinaryNumber   =     4;
     aDefNumbersPerLine         =     16;
     aMaxNumbersPerLine         =     32;

   { buffers size }
     aMaxTextBufSize            =       32768;          { 32K    }
     aMaxOutBufSize             =       65520;          { 64K-16 }



{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
    STR2        =       STRING[2];
    STR4        =       STRING[4];


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

    setOctalChars            :   SET  OF  System.Char  =  ['0'..'7'];
    setDecimalChars          :   SET  OF  System.Char  =  ['0'..'9'];
    setHexChars              :   SET  OF  System.Char  =  ['0'..'9','A'..'F','a'..'f'];
    setAvailRadix            :   SET  OF  System.Byte  =  [aOctalRadix,aDecimalRadix,aHexRadix];
    setUnusedLeadChars       :   SET  OF  System.Char  =  [achHTAB,achBlank];

    gliReadBytesCount        :   System.Longint   =   0;
    gdwBufOfs                :   System.Word      =   0;

    gadbNumberBase           :   System.Byte      =   aDefBaseNumber;
    gadbBytesPerBinaryNumber :   System.Byte      =   aDefBytesPerBinaryNumber;
    gdaNumbersPerLine        :   System.Byte      =   aDefNumbersPerLine;


{*=========================== VARIABLES PART ===========================*}

VAR
   gfInputStream        :       System.Text;
   gfInputStreamRec     :       FILE  ABSOLUTE  gfInputStream;
   gsInFileName         :       STRING[80];

   gfOutputStream       :       FILE;
   gsOutFileName        :       STRING[80];

   gliFileSize          :       System.Longint;
   glpOutBuf            :       System.Pointer;
   giErrorCode          :       System.Integer;
   gsTempInput          :       STRING;

   gdbLargeInBuf        :       ARRAY[0..aMaxTextBufSize-1] OF System.Char;


{*=========================== FUNCTIONAL PART ==========================*}

FUNCTION  _fnbFileExist(VAR fStruc : FILE; sFileName : STRING) : System.Boolean;
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

  FOR  dbIndex :=  1  TO  dbCount  DO
      sInput[dbIndex] := System.Upcase(sInput[dbIndex]);
  {for-to-do}

   _fnsUpcaseStr := sInput;
END; { _fnsUpcaseStr }


FUNCTION  _fndbHexCharToBin(chIn: System.Char) : System.Byte; assembler;
{* Converts hexadecimal char to decimal digit. *}
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


FUNCTION  _fnliOctalStrToBin(sOctalInput : STRING; VAR iErrCode : System.Integer) : System.Longint;
{* Converts octal string to binary number. *}
VAR
  ddNumber               :       System.Longint;
  dbStrIndex, dbStrLen   :       System.Byte;

BEGIN
  iErrCode   := 0;
  ddNumber   := 0;
  dbStrIndex := 1;
  dbStrLen   := System.Length(sOctalInput);

  WHILE (iErrCode = 0) and (dbStrLen > 0) DO
  BEGIN
    IF  (sOctalInput[dbStrIndex] IN setOctalChars)
    THEN  BEGIN
               ddNumber := ddNumber * aOctalRadix + System.Byte(sOctalInput[dbStrIndex])-System.Byte('0');
               System.Inc(dbStrIndex);
               System.Dec(dbStrLen);
          END
    ELSE  BEGIN
        iErrCode  := -1;
          END;
    {if-then-else}
  END;
  {while-do}

  _fnliOctalStrToBin := ddNumber;
END;  { _fnliOctalStrToBin }


FUNCTION  _fnliDecimalStrToBin(sDecimalInput : STRING; VAR iErrCode : System.Integer) : System.Longint;
{* Converts decimal string to binary number. *}
VAR
  ddNumber               :       System.Longint;
  dbStrIndex, dbStrLen   :       System.Byte;

BEGIN
  iErrCode   := 0;
  ddNumber   := 0;
  dbStrIndex := 1;
  dbStrLen   := System.Length(sDecimalInput);

  WHILE (iErrCode = 0) and (dbStrLen > 0) DO
  BEGIN
    IF  (sDecimalInput[dbStrIndex] IN setDecimalChars)
    THEN  BEGIN
               ddNumber := ddNumber * aDecimalRadix + System.Byte(sDecimalInput[dbStrIndex])-System.Byte('0');
               System.Inc(dbStrIndex);
               System.Dec(dbStrLen);
          END
    ELSE
        iErrCode  := -1;
    {if-then-else}
  END;
  {while-do}

  _fnliDecimalStrToBin := ddNumber;
END;  { _fnliDecimalStrToBin }


FUNCTION  _fnliHexStrToBin(sHexInput : STRING; VAR iErrCode : System.Integer) : System.Longint;
{* Converts hexadecimal string to binary number. *}
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


FUNCTION  _fnddGetNum(sInput : STRING;VAR iErrorCode : System.Integer)  :  System.Longint;
{* Reads a numeric string and returns a double word *}
VAR
  ddTemp      :   System.Longint;

BEGIN
  IF  (sInput[1] <> achHexPrefix)
     THEN  System.Val(sInput,ddTemp,iErrorCode)
     ELSE  ddTemp := _fnliHexStrToBin(Copy(sInput,2,System.Length(sInput)-1),iErrorCode);
  {if-then-else}
  _fnddGetNum := ddTemp;
END;
{ _fnddGetNum }


FUNCTION  _fndwGetNum(sInput : STRING;VAR iErrorCode : System.Integer)  :  System.Word;
{* Reads a numeric string and returns a word *}
BEGIN
 _fndwGetNum := (_fnddGetNum(sInput,iErrorCode) AND $000FFFF);
END;
{ _fndwGetNum }


FUNCTION  _fndbGetNum(sInput : STRING;VAR iErrorCode : System.Integer)  :  System.Byte;
{* Reads a numeric string and returns a byte *}
BEGIN
 _fndbGetNum := (_fnddGetNum(sInput,iErrorCode) AND $000000FF);
END;
{ _fndbGetNum }


FUNCTION  _fnsRemoveLeadChars(sInput : STRING) : STRING;
{* Remove all occurrences of leading char from left side. *}
BEGIN
   WHILE ((sInput <> asBlankStr) AND (sInput[1] IN setUnusedLeadChars))
   DO  System.Delete(sInput,1,1);
   {while-do}
   _fnsRemoveLeadChars := sInput;
END; { _fnsRemoveLeadChars }


FUNCTION  _fnsNumToStr2(dwNum : System.Word) : STR2;
{* Convert a numeric value to its string representation. *}
VAR
  sTemp2 : STR2;

BEGIN
   System.Str(dwNum:2,sTemp2);
   _fnsNumToStr2 := sTemp2;
END;
{ _fnsNumToStr2 }


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


PROCEDURE  _PutByteToOutFile(dbNextChar : System.Byte);
{* Buffered writing to output stream. *}
BEGIN
  IF  (gdwBufOfs >= aMaxOutBufSize)
    THEN  BEGIN
         System.BlockWrite(gfOutputStream,
                           System.Mem[System.Seg(glpOutBuf^):System.Ofs(glpOutBuf^)],
                           aMaxOutBufSize);
         gdwBufOfs := 0;
          END;
  {if-then}
  System.Mem[System.Seg(glpOutBuf^):(System.Ofs(glpOutBuf^)+gdwBufOfs)] := dbNextChar;
  System.Inc(gdwBufOfs);
END;
{  _PutByteToOutFile }



PROCEDURE  _ProcessLine(sInput : STRING);
{* Process one line. *}
VAR
  sCurNumStr      :  STRING;
  ddTempNumber    :  System.LongInt;
  iErrorCode      :  System.Integer;
  dwByteOffset    :  System.Word;
  dbNumbersCount  :  System.Byte;
  dbWriteCount    :  System.Byte;
  chCurSym        :  System.Char;
  bMatchSym       :  System.Boolean;

FUNCTION  _fnchGetCurSymbol(VAR sInput : STRING) : System.Char;
{* Returns a first char from a string
   with the following removing of it from string. *}
VAR
  chTemp  :  System.Char;
BEGIN
  chTemp := _fnchGetFirstChar(sInput);
  IF (chTemp <> achNULL)
    THEN  System.Delete(sInput,1,1);
  {if-then}
  _fnchGetCurSymbol := chTemp;
END;
{ _fnchGetCurSymbol }

BEGIN
  {* init an internal counter *}
    dbNumbersCount := 0;
    sInput := _fnsUpcaseStr(sInput);
    sInput := _fnsRemoveLeadChars(sInput);

  {* scan a string until it is no empty or max. numbers count not reached *}
    WHILE  ((sInput <> asBlankStr) AND
            (dbNumbersCount < gdaNumbersPerLine))  DO
    BEGIN
      {* try to get the numeric substring, *}
        sCurNumStr  := asBlankStr;

      {* one char look-ahead algorithm     *}
      REPEAT
        chCurSym  := _fnchGetCurSymbol(sInput);
        bMatchSym := System.False;

        CASE  (gadbNumberBase)  OF
               aOctalRadix    :  BEGIN
                                   IF  (chCurSym IN setOctalChars)
                                     THEN  BEGIN
                                       sCurNumStr :=  sCurNumStr + chCurSym;
                                       bMatchSym := System.True;
                                           END;
                                   {if-then}
                                 END;
               aDecimalRadix  :  BEGIN
                                   IF  (chCurSym IN setDecimalChars)
                                     THEN  BEGIN
                                       sCurNumStr :=  sCurNumStr + chCurSym;
                                       bMatchSym := System.True;
                                           END;
                                   {if-then}
                                 END;
               aHexRadix      :  BEGIN
                                   IF  (chCurSym IN setHexChars)
                                     THEN  BEGIN
                                       sCurNumStr :=  sCurNumStr + chCurSym;
                                       bMatchSym := System.True;
                                           END;
                                   {if-then}
                                 END;
        ELSE
          {* reserved *}
        END;
        {case-of}

      UNTIL  ((sInput = asBlankStr) OR
                NOT(bMatchSym));
      {repeat-until}

      {* make the number conversion if need *}
      IF (sCurNumStr <> asBlankStr)
        THEN  BEGIN
           CASE  gadbNumberBase  OF
                  aOctalRadix    :  BEGIN
                      ddTempNumber := _fnliOctalStrToBin(sCurNumStr,iErrorCode);
                                    END;
                  aDecimalRadix  :  BEGIN
                       ddTempNumber := _fnliDecimalStrToBin(sCurNumStr,iErrorCode);
                                    END;
                  aHexRadix      :  BEGIN
                      ddTempNumber := _fnliHexStrToBin(sCurNumStr,iErrorCode);
                                    END;
           ELSE
             {* reserved *}
           END;
           {case-of}

           IF (iErrorCode = 0)  THEN
             BEGIN
                 CASE  gadbBytesPerBinaryNumber  OF
                     aBinaryNumberBytes1  : dbWriteCount := 1;
                     aBinaryNumberBytes2  : dbWriteCount := 2;
                     aBinaryNumberBytes3  : dbWriteCount := 3;
                     aBinaryNumberBytes4  : dbWriteCount := 4;
                 ELSE
                     dbWriteCount := 0;
                 END;
                 IF (dbWriteCount <> 0)
                   THEN  BEGIN
                      FOR  dwByteOffset := 0  TO  dbWriteCount-1  DO
                      BEGIN
                        _PutByteToOutFile(Mem[Seg(ddTempNumber):(Ofs(ddTempNumber)+dwByteOffset)])
                      END;
                      {for-to-do}
                      {**  Alternative **}
                      {**System.BlockWrite(gfOutputStream,ddTempNumber,dbWriteCount);**}
                      {**  Alternative **}
                      System.Inc(dbNumbersCount);
                         END;
                 {if-then}
             END;
           {if-then}
              END;
      {if-then}

      {* prepare a string for the next parsing *}
        sInput := _fnsRemoveLeadChars(sInput);
    END;
    {while-do}

END;
{ _ProcessLine }


{*============================== MAIN PART =============================*}

BEGIN
  _CopyrightDisplay;

     IF (System.ParamCount < 2) THEN
     BEGIN
          System.WriteLn(asProgramPrompt+'  help screen for you.');
          System.WriteLn('Usage: infile outfile [base [type [numcount]]]');
          System.WriteLn(' infile   - source filename                   (default extension='+asInDefExt+')');
          System.WriteLn(' outfile  - destination filename              (default extension='+asOutDefExt+')');
          System.WriteLn(' base     - representation number base        (default=',aDefBaseNumber,
                         ', available=',aOctalRadix,',',aDecimalRadix,',',aHexRadix,')');
          System.WriteLn(' type     - bytes number per binary entity    (default=',aDefBytesPerBinaryNumber,
                         ', max=',aMaxBytesPerBinaryNumber,')');
          System.WriteLn(' numcount - numbers count extracted from line (default=',aDefNumbersPerLine,
                         ', max=',aMaxNumbersPerLine,')');
          System.WriteLn('  Numbers may be decimals, or hexadecimals (first symbol is ''$'' for hex.).');
          System.Halt(errBadParmsNumber);
     END;
     {if-then}


  {** copy the parameters from command line **}
    gsInFileName  := _fnsUpcaseStr(System.ParamStr(1));
    gsInFileName := _fnsForceFileNameExt(gsInFileName,asInDefExt);

    gsOutFileName := _fnsUpcaseStr(System.ParamStr(2));
    gsOutFileName := _fnsForceFileNameExt(gsOutFileName,asOutDefExt);


  {* may be same names? *}
    IF (gsInFileName = gsOutFileName)
      THEN  BEGIN
        System.WriteLn(asProgramPrompt+'  Unable to use same file as input and as output');
        System.Halt(errSameNames);
            END;
    {if-then}


  {** source file exists? **}
    IF  NOT(_fnbFileExist(gfInputStreamRec,gsInFileName)) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+' Unable to open file '+gsInFileName);
      System.Halt(errSourceNotFound);
    END;
    {if-then}


  {** destination file present? **}
  IF (_fnbFileExist(gfOutputStream,gsOutFileName)) THEN
  BEGIN
    System.Write(asProgramPrompt+' Output file '+gsOutFileName+
                 ' already exists. Overwrite? (n/y): ');
    System.ReadLn(gsTempInput);
    IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achYes)
      THEN  System.Halt(errDestDontWrite);
    {if-then}
  END;
  {if-then}


  {** read the following parameter = number base **}
    IF  (System.ParamCount >= 3) THEN
    BEGIN
      gadbNumberBase := _fndbGetNum(System.ParamStr(3),giErrorCode);
      IF  ((giErrorCode <> 0) OR
           (NOT(gadbNumberBase IN setAvailRadix)))
      THEN
          BEGIN
            System.WriteLn(asProgramPrompt+'Invalid BASE parameter.');
            System.Halt(errBadBase);
          END;
      {if-then}
    END;
    {if-then}


  {** read the following parameter = binary type **}
    IF  (System.ParamCount >= 4) THEN
    BEGIN
       gadbBytesPerBinaryNumber := _fndbGetNum(System.ParamStr(4),giErrorCode);
       IF  ((giErrorCode <> 0) OR
            (gadbBytesPerBinaryNumber > aMaxBytesPerBinaryNumber) OR
            (gadbBytesPerBinaryNumber = 0))
       THEN
           BEGIN
             System.WriteLn(asProgramPrompt+'Bad TYPE parameter.');
             System.Halt(errBadType);
           END;
       {if-then}
    END;
    {if-then}

  {** read the following parameter = bytes switch **}
    IF  (System.ParamCount >= 5) THEN
    BEGIN
         gdaNumbersPerLine := _fndbGetNum(System.ParamStr(5),giErrorCode);
         IF ((giErrorCode <> 0) OR
             (gdaNumbersPerLine = 0) OR
             (gdaNumbersPerLine > aMaxNumbersPerLine))
            THEN   BEGIN
               System.WriteLn(asProgramPrompt+' Invalid value for NUMCOUNT switch.');
               System.Halt(errBadBytesValue);
                   END;
         {if-then}
    END;
    {if-then}


  {** open the source file **}
    System.FileMode := $20;   {read, deny write on share}
    System.Assign(gfInputStreamRec,gsInFileName);
    {$I-}
    System.Reset(gfInputStreamRec,1);
    {$I+}

    IF  (System.IoResult <> 0) THEN
    BEGIN
      System.Write(asProgramPrompt+' Unable to open '+gsInFileName);
      System.Halt(errSrcOpenFailed);
    END;
    {if-then}

    gliFileSize := System.FileSize(gfInputStreamRec);
    System.Close(gfInputStreamRec);

  {** open the source file **}
    System.Assign(gfInputStream,gsInFileName);
    System.SetTextBuf(gfInputStream,gdbLargeInBuf);
    {$I-}
    System.Reset(gfInputStream);
    {$I+}

    IF  (System.IoResult <> 0) THEN
    BEGIN
      System.Write(asProgramPrompt+' Unable to open '+gsInFileName);
      System.Halt(errSrcOpenFailed);
    END;
    {if-then}


  {** create the destination file **}
    System.GetMem(glpOutBuf,aMaxOutBufSize);
    System.FileMode := 2; {read/write, compatibilty mode}
    System.Assign(gfOutputStream,gsOutFileName);
    {$I-}
    System.Rewrite(gfOutputStream,1);
    {$I+}

    IF  (System.IoResult <> 0) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+' Unable to create '+gsOutFileName);
      System.Halt(errDestCreateFailed);
    END;
    {if-then}



  {** main loop: read_buffer/write_to_text_file **}
    WHILE (NOT(System.Eof(gfInputStream))) DO
    BEGIN
         System.ReadLn(gfInputStream,gsTempInput);
         System.Inc(gliReadBytesCount,System.Length(gsTempInput)+2);
         System.Write(achCR+asProgramPrompt+' Completed ('+
                      _fnsNumToStr2(System.Word(gliReadBytesCount*aPercent100 DIV gliFileSize))+'%)');
         _ProcessLine(gsTempInput);
    END;
    {while-do}


  {* output '100%' message *}
    System.WriteLn(achCR+asProgramPrompt+' Completed (',aPercent100,'%)');

  {* write a remainder in buffer to disk *}
    IF  (gdwBufOfs <> 0)
      THEN  System.BlockWrite(gfOutputStream,
                              System.Mem[System.Seg(glpOutBuf^):System.Ofs(glpOutBuf^)],
                              gdwBufOfs);
    {if-then}

  {** close all files **}
    System.Close(gfInputStream);
    System.Close(gfOutputStream);

  {* free all memory on heap *}
    System.FreeMem(glpOutBuf,aMaxOutBufSize);

  {** report all done **}
    System.WriteLn(asProgramPrompt+' Done.');

  {* System.Halt(errTerminateOk); *}
END.
