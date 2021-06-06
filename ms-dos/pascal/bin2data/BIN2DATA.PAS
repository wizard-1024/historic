{****************************************************************************
//                            File BIN2DATA.PAS
//
//              Convert binary data file to data format file
//
//      Copyright (c) 1994, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/BIN2DATA/RCS/bin2data.pas $
//  $RCSfile: bin2data.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 15:01:01 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: bin2data.pas $
//      Revision 1.1  1998/10/03 15:01:01  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                BIN_TO_DATA_CONVERTER                           }
{ FILE NAME             BIN2DATA.PAS                                    }
{ PURPOSE               Convert the binary file to a data format file.  }
{ VERSION               1.03                                            }
{ DATE                  02-Sep-1997                                     }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Telephone: +007 (095) 944-6304                  }
{ INTERNET              wizard@radio-msu.net, dima@mccbn.ru             }
{ COPYRIGHT NOTICE      Copyright (C) 1994, 1997  Dmitry Stefankov      }
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
{                       <bytes>      -   # of bytes per one line        }
{                       <ascii>      -   switch to indicate ASCII set   }
{                       <lang>       -   format of output file          }
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
{                       2.Write formatted  output stream                }
{                       3.If switch present then                        }
{                            add ASCII representation for each line     }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   01-Jun-94  DS  initilal release          }
{                       1.01   26-Jul-97  DS  updated documentation     }
{                       1.02   02-Aug-97  DS  removed tabs              }
{                       1.03   02-Sep-97  DS  fixed open r/o file bug   }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   BinaryFileToDataFormatFile;


{*** other modules ***}
USES
  ShowTErr;


{** switches for compilation **}
{$S-}                   {*  stack checking     *}
{$R-}                   {*  range checking     *}
{$M 16384,65536,65536}  {*  memory allocation  *}


{*========================== CONSTANTS PART ============================*}

CONST
     asPurpose                  =       'Bin2DataFile Converter';
     asVersion                  =       '1.03';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1994, 1997';
     asProgram                  =       'Bin2data';
     asProgramPrompt            =       asProgram+': ';
     asProgramU                 =       'BIN2DATA';

     { exit codes }
     errTerminateOK             =     0;
     errBadParmsNumber          =     1;
     errSourceNotFound          =     2;
     errDestDontWrite           =     3;
     errSameNames               =     4;
     errSrcOpenFailed           =     6;
     errDestCreateFailed        =     7;
     errBadBytesValue           =     8;
     errBadLangParm             =     9;

     aPercent100                =     100;

     achNULL                    =     #0;
     achHTAB                    =     #9;
     achCR                      =     #13;
     achSPC                     =     ' ';
     achZero                    =     '0';
     achSkip                    =     '.';
     achDelimiter               =     ',';
     achSemicolon               =     ';';

     achYes                     =     'Y';
     achNo                      =     'N';

     achHexPrefix               =     '$';
     achDosExtMark              =     '.';
     asBlankStr                 =     '';
     asSpaces2                  =     achSPC+achSPC;
     asSpaces3                  =     asSpaces2+achSPC;
     asSpaces4                  =     asSpaces2+asSpaces2;
     asSpaces5                  =     asSpaces3+asSpaces2;
     asInDefExt                 =     'bin';
     asOutDefExtASM             =     'asm';
     asOutDefExtPAS             =     'pas';
     asOutDefExtC               =     'c';

     aAsciiNone                 =     0;
     aAscii7                    =     1;
     aAscii8                    =     2;

     aDefBytesPerLine           =     8;
     aMaxBytesPerLine           =     16;
     achAsciiBit7               =     '7';
     achAsciiBit8               =     '8';

     aMaxOnHeap                 =     8192;
     aMaxOutBufSize             =     32768;

     achHexSuffixASM            =     'h';
     asDataDefineASM            =     'DB';
     asNoListASM                =     '.XLIST';
     asListASM                  =     '.LIST';
     asOneLineCommentASM        =     ';';
     asOpenCommentASM           =     'COMMENT  !';
     asCloseCommentASM          =     '!';


     asOpenCommentC             =     '/*';
     asCloseCommentC            =     '*/';
     achHexPrefixC              =     '0x';

     asOpenCommentPASCAL        =     '{';
     asCloseCommentPASCAL       =     '}';
     achHexPrefixPASCAL         =     '$';

     aLanguageASM               =     0;
     aLanguagePASCAL            =     1;
     aLanguageC                 =     2;


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
    STR3        =       STRING[3];
    STR4        =       STRING[4];


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

     setHexChars   :    SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];
     setAscii7     :    SET OF System.Char  =  [#32..#126];
     setAscii8     :    SET OF System.Char  =  [#32..#126,#128..#255];
     setWhiteChars :    SET OF System.Char  =  [#9,#32];

     gdbOutFmtLang        :       System.Byte    =  aLanguageASM;
     gadbAsciiFormat      :       System.Byte    =  aAsciiNone;
     gadbSymbolsInString  :       System.Byte    =  aDefBytesPerLine;
     gddBytesCountDone    :       System.Longint =  0;


{*=========================== VARIABLES PART ===========================*}

VAR
   gfInputStream        :       FILE;
   gsInFileName         :       STRING[80];

   gfOutputFormatText   :       System.Text;
   gfOutputStream       :       FILE  ABSOLUTE  gfOutputFormatText;
   gsOutFileName        :       STRING[80];

   gddOffsetInFile      :       System.Longint;
   gddByteCount         :       System.Longint;
   gddInFileSize        :       System.Longint;

   gpMemoryBlock        :       System.Pointer;
   gdwMemBlockSize      :       System.Word;
   gdwBytesRead         :       System.Word;

   giErrorCode          :       System.Integer;
   gsTempInput          :       STRING;

   gdbTextOutBuf        :       ARRAY[1..aMaxOutBufSize] of System.Byte;



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


FUNCTION   _fnsByteToHexFormat(dbInput : System.Byte) : STR4;
{* Converts a byte to the hexadecimal format number representation. *}
CONST
    dbHexTable : ARRAY[0..15] OF System.Char = '0123456789ABCDEF';

BEGIN
  _fnsByteToHexFormat := dbHexTable[dbInput SHR 4] +
                         dbHexTable[dbInput AND $0F];
END;  { _fnsByteToHexFormat }


FUNCTION  _fnsUpcaseStr(sInput : STRING) : STRING;
{* Make all uppercase. *}
VAR
  dbIndex  :  System.BYTE;
  dbCount  :  System.BYTE;

BEGIN
  dbCount := System.Length(sInput);

  IF (dbCount <> 0)  THEN
    FOR  dbIndex :=  1  TO  dbCount DO
        sInput[dbIndex] := System.Upcase(sInput[dbIndex]);
    {for-to-do}
  {if-then}

   _fnsUpcaseStr := sInput;
END; { _fnsUpcaseStr }


FUNCTION  _fnsRemoveLeadingWhiteChar(sInput : STRING) : STRING;
VAR
  dbCount : System.BYTE  ABSOLUTE  sInput;

BEGIN
  WHILE (dbCount <> 0) AND (sInput[1] IN setWhiteChars)
  DO  System.Delete(sInput,1,1);
  {while-do}
  _fnsRemoveLeadingWhiteChar := sInput;
END;  { _fnsRemoveLeadingWhiteChar }


FUNCTION  _fnsNumToStr3(dwNum : System.Word) : STR3;
{* Convert a numeric value to its string representation. *}
VAR
  sTemp : STR3;

BEGIN
   System.Str(dwNum:3,sTemp);
   _fnsNumToStr3 := _fnsRemoveLeadingWhiteChar(sTemp);
END;
{ _fnsNumToStr3 }



{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+'  Version '+asVersion+', '+asCopyright+'  '+asAuthor);
END;  { _CopyrightDisplay }


PROCEDURE  _WriteBufferToDisk(VAR fOutTextFile : System.Text;
                                  pMemBuf : System.Pointer;
                                  dwByteCount : System.Word;
                                  dbAsciiSwitch : System.Byte);
{* Writes the contents of buffer in hexadecimal format to file. *}
VAR
  sOutStr            :  STRING;
  sAsciiStr          :  STRING;
  sOneElem           :  STRING;
  dwRemFileSize      :  System.Word;
  dwOffsetInBuffer   :  System.Word;
  dbInByte,
  dbIndex,
  dbStrPos           :  System.Byte;
  dbCountInLine      :  System.Byte;
  chAddChar          :  System.Char;


BEGIN
  {** initial offset in file buffer **}
    dwOffsetInBuffer := 0;
    dwRemFileSize := System.Word(gddInFileSize - gddBytesCountDone)+dwByteCount-1;
    CASE  gdbOutFmtLang  OF
        aLanguageASM         :   BEGIN
               sOneElem := asSpaces5;
                                 END;
        aLanguagePASCAL      :   BEGIN
               sOneElem  := asSpaces4;
                                 END;
        aLanguageC           :   BEGIN
               sOneElem   := asSpaces5;
                                 END;
    ELSE
       {reserved}
    END;
    {case-of}


  {** main algorithm **}
  WHILE  (dwByteCount <> 0) DO
  BEGIN
    {** init'd strings **}
    CASE  gdbOutFmtLang  OF
        aLanguageASM         :   BEGIN
               sOutStr   := achHTAB+asDataDefineASM+achHTAB;
                                 END;
        aLanguagePASCAL      :   BEGIN
               sOutStr   := achHTAB;
                                 END;
        aLanguageC           :   BEGIN
               sOutStr   := achHTAB;
                                 END;
    ELSE
       {reserved}
    END;
    {case-of}


      sAsciiStr := asBlankStr;

    {** CASE 1: extract full line **}
    {** CASE 2: extract partial line **}

    IF ((dwByteCount DIV gadbSymbolsInString) <> 0)
      THEN  dbCountInLine := gadbSymbolsInString
      ELSE  dbCountInLine := dwByteCount;
    {if-then-else}

    BEGIN
             FOR  dbIndex := 1  TO  dbCountInLine  DO
             BEGIN
               dbInByte := System.Mem[System.Seg(pMemBuf^):(System.Ofs(pMemBuf^)+dwOffsetInBuffer)];
               CASE  gdbOutFmtLang  OF
                     aLanguageASM         :   BEGIN
                         sOutStr := sOutStr +
                                    achZero +
                                    _fnsByteToHexFormat(dbInByte)+
                                    achHexSuffixASM;
                                              END;
                     aLanguagePASCAL      :   BEGIN
                         sOutStr := sOutStr +
                                    achHexPrefixPASCAL +
                                    _fnsByteToHexFormat(dbInByte);
                                              END;
                     aLanguageC           :   BEGIN
                         sOutStr := sOutStr +
                                    achHexPrefixC +
                                    _fnsByteToHexFormat(dbInByte);
                                              END;
               ELSE
                  {reserved}
                  END;
               {case-of}

               IF  (dbIndex < dbCountInLine)
                 THEN  sOutStr := sOutStr + achDelimiter;
               {if-then}


               IF  (dbIndex = dbCountInLine)
                 THEN  BEGIN
                    chAddChar := achSPC;
                    IF (dwRemFileSize <> dwOffsetInBuffer)
                      THEN  CASE  gdbOutFmtLang  OF
                               aLanguageASM         :   BEGIN
                                                        END;
                               aLanguagePASCAL      :   BEGIN
                                     chAddChar := achDelimiter;
                                                        END;
                               aLanguageC           :   BEGIN
                                     chAddChar := achDelimiter;
                                                        END;
                            ELSE
                                {reserved}
                            END;
                            {case-of}
                    {if-then}
                    sOutStr := sOutStr + chAddChar;
                       END;
               {if-then}

               chAddChar := System.Char(dbInByte);
               CASE  dbAsciiSwitch  OF
                        aAscii7   : IF  (chAddChar IN setAscii7)
                                       THEN  sAsciiStr := sAsciiStr + chAddChar
                                       ELSE  sAsciiStr := sAsciiStr + achSkip;
                        aAscii8   : IF  (chAddChar IN  setAscii8)
                                       THEN  sAsciiStr := sAsciiStr + chAddChar
                                       ELSE  sAsciiStr := sAsciiStr + achSkip;
               END;
               {case-of}

               System.Inc(dwOffsetInBuffer);
             END;
             {for-to-do}

             IF  (dbAsciiSwitch <> aAsciiNone)
                THEN  BEGIN
                        FOR  dbIndex := 1  TO  (gadbSymbolsInString-dbCountInLine)
                           DO  BEGIN
                             sOutStr := sOutStr + sOneElem;
                             sAsciiStr := sAsciiStr + achSPC;
                               END;
                        {for-to-do}
                        sOutStr := sOutStr + achHTAB;
                        CASE  gdbOutFmtLang  OF
                               aLanguageASM         :   BEGIN
                   sOutStr := sOutStr + asOneLineCommentASM +
                              asSpaces2 + sAsciiStr;
                                                        END;
                               aLanguagePASCAL      :   BEGIN
                   dbStrPos := Pos(asCloseCommentPASCAL,sAsciiStr);
                   IF (dbStrPos <> 0)
                     THEN  sAsciiStr[dbStrPos] := achSkip;
                   {if-then}
                   sOutStr := sOutStr + asOpenCommentPASCAL + asSpaces2 + sAsciiStr +
                              asSpaces2 + asCloseCommentPASCAL;
                                                        END;
                               aLanguageC           :   BEGIN
                   dbStrPos := Pos(asCloseCommentC,sAsciiStr);
                   IF (dbStrPos <> 0)
                     THEN  sAsciiStr[dbStrPos] := achSkip;
                   {if-then}
                   sOutStr := sOutStr + asOpenCommentC + asSpaces2 + sAsciiStr +
                              asSpaces2 + asCloseCommentC;
                                                        END;
                        ELSE
                           {reserved}
                        END;
                        {case-of}


                      END;
             {if-then}

             System.WriteLn(fOutTextFile,sOutStr);
             System.Dec(dwByteCount,dbCountInLine);
    END;
    {begin-end}
  END;
  {while-do}

END;  { _WriteBufferToDisk }



{*============================== MAIN PART =============================*}

BEGIN
  _CopyrightDisplay;

     IF (System.ParamCount < 2) THEN
     BEGIN
          System.WriteLn(asProgramPrompt+'  help screen for you.');
          System.WriteLn('Usage: infile outfile [bytes [ascii [lang]]]');
          System.WriteLn('  infile   -  source filename           (def. ext. = '+asInDefExt+')');
          System.WriteLn('  outfile  -  destination filename      (def. ext. = '+asOutDefExtASM+')');
          System.WriteLn('  bytes    -  number bytes for one line (def. num. = ',aDefBytesPerLine,
                         ', max=',aMaxBytesPerLine,')');
          System.WriteLn('  ascii    -  optional, enable to add ASCII-char string');
          System.WriteLn('                '+achAsciiBit7+' -> 7-bit ASCII format,');
          System.WriteLn('                '+achAsciiBit8+' -> 8-bit ASCII format.');
          System.WriteLn('                       (default = none)');
          System.WriteLn('  lang     -  optional, select output file format (asm,c,pas,def=asm)');
          System.Halt(errBadParmsNumber);
     END;
     {if-then}


  {** copy the parameters from command line **}
    gsInFileName  := _fnsUpcaseStr(System.ParamStr(1));
    gsInFileName := _fnsForceFileNameExt(gsInFileName,asInDefExt);

    gsOutFileName := _fnsUpcaseStr(System.ParamStr(2));


  {** read the following parameter = bytes switch **}
    IF  (System.ParamCount >= 3) THEN
    BEGIN
         gsTempInput := System.ParamStr(3);
         System.Val(gsTempInput,gadbSymbolsInString,giErrorCode);
         IF  (gadbSymbolsInString = 0) OR (gadbSymbolsInString > aMaxBytesPerLine)
            THEN   BEGIN
               System.WriteLn(asProgramPrompt+' Invalid value for BYTES switch.');
               System.Halt(errBadBytesValue);
                   END;
         {if-then}
    END;
    {if-then}


  {** read the following parameter = ascii switch **}
    IF  (System.ParamCount >= 4) THEN
    BEGIN
         gsTempInput := System.ParamStr(4);
         CASE  gsTempInput[1] OF
              achAsciiBit7    :  gadbAsciiFormat := aAscii7;
              achAsciiBit8    :  gadbAsciiFormat := aAscii8;
         ELSE
             {**reserved**};
         END;
         {case-of}
    END;
    {if-then}


  {** read the following parameter = language switch **}
    IF  (System.ParamCount >= 5) THEN
    BEGIN
         gsTempInput := _fnsUpcaseStr(System.ParamStr(5));
         IF (gsTempInput = 'ASM')
           THEN  gdbOutFmtLang :=  aLanguageASM
           ELSE  BEGIN
              IF (gsTempInput = 'PAS')
                THEN  gdbOutFmtLang :=  aLanguagePASCAL
                ELSE  BEGIN
                   IF (gsTempInput = 'C')
                     THEN  gdbOutFmtLang :=  aLanguageC
                     ELSE  BEGIN
                        System.WriteLn(asProgramPrompt+' Invalid parameter for LANG switch.');
                        System.Halt(errBadLangParm);
                           END;
                   {if-then-else}
                      END;
              {if-then-else}
                 END;
         {if-then-else}
    END;
    {if-then}

    CASE  gdbOutFmtLang  OF
           aLanguageASM         :   BEGIN
                       gsTempInput := asOutDefExtASM;
                                    END;
           aLanguagePASCAL      :   BEGIN
                       gsTempInput := asOutDefExtPAS;
                                    END;
           aLanguageC           :   BEGIN
                       gsTempInput := asOutDefExtC;
                                    END;
    ELSE
       {reserved}
    END;
    {case-of}
    gsOutFileName := _fnsForceFileNameExt(gsOutFileName,gsTempInput);


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


  {** open the source file **}
    System.FileMode := $20;   {read, deny write on share}
    System.Assign(gfInputStream,gsInFileName);
    {$I-}
    System.Reset(gfInputStream,1);
    {$I+}

    IF  (System.IoResult <> 0) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+' Unable to open '+gsInFileName);
      System.Halt(errSrcOpenFailed);
    END;
    {if-then}


  {** create the destination file **}
    System.FileMode := 2; {read/write, compatibilty mode}
    System.Assign(gfOutputFormatText,gsOutFileName);
    System.SetTextBuf(gfOutputFormatText,gdbTextOutBuf);
    {$I-}
    System.Rewrite(gfOutputFormatText);
    {$I+}

    IF  (System.IoResult <> 0) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+' Unable to create '+gsOutFileName);
      System.Halt(errDestCreateFailed);
    END;
    {if-then}


  {** get a count of bytes to read. **}
    gddByteCount := System.FileSize(gfInputStream);
    gddInFileSize := gddByteCount;


  {** get memory on heap **}
    IF  (System.MaxAvail < aMaxOnHeap)
      THEN  gdwMemBlockSize := System.MaxAvail
      ELSE  gdwMemBlockSize := aMaxOnHeap;
    {if-then-else}
    System.GetMem(gpMemoryBlock,gdwMemBlockSize);



  {** write first lines to output stream **}
    System.WriteLn(gfOutputFormatText);
    CASE  gdbOutFmtLang  OF
           aLanguageASM         :   BEGIN
                  System.WriteLn(gfOutputFormatText,asOpenCommentASM);
                                    END;
           aLanguagePASCAL      :   BEGIN
                  System.WriteLn(gfOutputFormatText,asOpenCommentPASCAL);
                                    END;
           aLanguageC           :   BEGIN
                  System.WriteLn(gfOutputFormatText,asOpenCommentC);
                                    END;
    ELSE
       {reserved}
    END;
    {case-of}
    System.WriteLn(gfOutputFormatText,'  SOURCE FILE:  '+gsInFileName);
    System.WriteLn(gfOutputFormatText,'  Created by '+asProgram+' utility, '+asCopyright+'  '+asAuthor);
    CASE  gdbOutFmtLang  OF
           aLanguageASM         :   BEGIN
                  System.WriteLn(gfOutputFormatText,asCloseCommentASM);
                                    END;
           aLanguagePASCAL      :   BEGIN
                  System.WriteLn(gfOutputFormatText,asCloseCommentPASCAL);
                                    END;
           aLanguageC           :   BEGIN
                  System.WriteLn(gfOutputFormatText,asCloseCommentC);
                                    END;
    ELSE
       {reserved}
    END;
    {case-of}
    System.WriteLn(gfOutputFormatText);
    System.WriteLn(gfOutputFormatText);
    CASE  (gdbOutFmtLang)  OF
           aLanguageASM         :   BEGIN
                   System.WriteLn(gfOutputFormatText,asNoListASM);
                                    END;
           aLanguagePASCAL      :   BEGIN
                   System.WriteLn(gfOutputFormatText,'CONST');
                   System.WriteLn(gfOutputFormatText,'   gdbDataArray  :  ARRAY[1..',
                                   gddByteCount,']  OF  System.Byte  =  (');
                   System.WriteLn(gfOutputFormatText);
                                    END;
           aLanguageC           :   BEGIN
                   System.WriteLn(gfOutputFormatText,'   unsigned char   gdbDataArray[',
                                   gddByteCount,']   =   {');
                   System.WriteLn(gfOutputFormatText);
                                    END;
    ELSE
       {reserved}
    END;
    {case-of}

  {** main loop: read_buffer/write_to_text_file **}
    WHILE (gddByteCount <> 0) DO
    BEGIN
        IF  ((gddByteCount DIV gdwMemBlockSize) <> 0)
          THEN  gdwBytesRead :=  gdwMemBlockSize
          ELSE  gdwBytesRead :=  gddByteCount;
        {if-then-else}
        System.Inc(gddBytesCountDone,gdwBytesRead);

        BEGIN
                 System.WriteLn(asProgramPrompt+' Reading...');
                 System.BlockRead(gfInputStream,
                                  System.Mem[System.Seg(gpMemoryBlock^):System.Ofs(gpMemoryBlock^)],
                                  gdwBytesRead,
                                  gdwBytesRead);
                 System.WriteLn(asProgramPrompt+' Writing...');
                 _WriteBufferToDisk(gfOutputFormatText,
                                    gpMemoryBlock,
                                    gdwBytesRead,
                                    gadbAsciiFormat);
                 System.Dec(gddByteCount,gdwBytesRead);
                 System.Write(achCR+asProgramPrompt+' Completed ('+
                 _fnsNumToStr3((gddBytesCountDone*aPercent100) DIV gddInFileSize)+'%)');
                 System.WriteLn;
        END;
    END;
    {while-do}


  {** write last lines to output stream **}
    System.WriteLn(gfOutputFormatText);
    CASE  (gdbOutFmtLang)  OF
           aLanguageASM         :   BEGIN
                  System.WriteLn(gfOutputFormatText,asListASM);
                                    END;
           aLanguagePASCAL      :   BEGIN
                  System.WriteLn(gfOutputFormatText,achHTAB+'  );');
                                    END;
           aLanguageC           :   BEGIN
                  System.WriteLn(gfOutputFormatText,achHTAB+'  };');
                                    END;
    ELSE
       {**reserved**}
    END;
    {case-of}

  {** free memory on heap **}
    System.FreeMem(gpMemoryBlock,gdwMemBlockSize);


  {** close all files **}
    System.Close(gfInputStream);
    System.Close(gfOutputFormatText);


  {** report all done **}
    System.WriteLn(asProgramPrompt+' Done.');

  {* System.Halt(errTerminateOk); *}
END.
