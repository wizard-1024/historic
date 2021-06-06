{****************************************************************************
//                            File BIN2BIT.PAS
//
//      Convert binary file to assembler output format file (bit-strings)
//
//      Copyright (c) 1992, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/BIN2BIT/RCS/bin2bit.pas $
//  $RCSfile: bin2bit.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 15:03:22 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: bin2bit.pas $
//      Revision 1.1  1998/10/03 15:03:22  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                BIN_TO_BIT_CONVERTER                            }
{ FILE NAME             BIN2BIT.PAS                                     }
{ PURPOSE               Convert the binary file to a bit-asm formatting }
{                       text file.                                      }
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
{ COPYRIGHT NOTICE      Copyright (C) 1992, 1997  Dmitry Stefankov      }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,           }
{                       NOT FOR COMMERCIAL PURPOSE                      }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 7.0                        }
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             <infile>     -  input  stream                   }
{                       <outfile>    -  output stream                   }
{                       <bytecount>  -  # of bytes for symbol           }
{                       <initchar>   -  initial number for Char         }
{                       <ascii>      -  switch for select ASCII char set}
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
{                       2.Write Byte-bit ASM formatting output stream   }
{                       3.If switch present then                        }
{                            add ASCII representation for each line     }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   08-Jan-92  DS  initilal release          }
{                       1.01   09-Jan-92  DS  some syntax corrections   }
{                       1.02   10-Jan-92  DS  new read/write algorithms }
{                       1.03   24-Jan-92  DS  some corrections          }
{                       1.10   25-Aug-92  DS  updated documentation     }
{                       1.20   08-Oct-92  DS  some style corrections    }
{                       1.21   27-Oct-92  DS  some corrections          }
{                       1.22   04-Nov-92  DS  some updates              }
{                       1.23   07-Apr-93  DS  fixed a bug with bit str  }
{                       1.24   20-May-93  DS  some style updates        }
{                       1.25   04-Jul-93  DS  updated documentation     }
{                       1.30   28-Oct-93  DS  some style updates        }
{                       1.31   26-Jul-97  DS  updated documentation     }
{                       1.32   02-Aug-97  DS  removed tabs              }
{                       1.33   02-Sep-97  DS  fixed open r/o file bug   }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   BinaryFileToBitByteAssemblerFormatFile;


{*** other modules ***}
USES
  ShowTErr;


{** switches for compilation **}
{$S-}                   {*  stack checking     *}
{$R-}                   {*  range checking     *}
{$M 16384,65536,65536}  {*  memory allocation  *}


{*========================== CONSTANTS PART ============================*}

CONST
     asPurpose                  =       'BitAsmFile Converter';
     asVersion                  =       '1.33';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1992, 1997';
     asProgram                  =       'Bin2bit';
     asProgramPrompt            =       asProgram+': ';
     asProgramU                 =       'BIN2BIT';

     { exit codes }
     errTerminateOK             =     0;
     errBadParmsNumber          =     1;
     errSourceNotFound          =     2;
     errDestDontWrite           =     3;
     errSameNames               =     4;
     errBadFmtBytesValue        =     5;
     errSrcOpenFailed           =     6;
     errDestCreateFailed        =     7;
     errBadBytesValue           =     8;
     errBadCharValue            =     9;

     aPercent100                =     100;

     achHexPrefix               =     '$';
     achDosExtMark              =     '.';
     asBlankStr                 =     '';
     asSpace2                   =     '  ';
     asSpaces5                  =     '     ';
     asInDefExt                 =     'bin';
     asOutDefExt                =     'asm';

     aAsciiNone                 =     0;
     aAscii7                    =     1;
     aAscii8                    =     2;

     achAsciiBit7               =     '7';
     achAsciiBit8               =     '8';

     aDefaultBytesPerLine       =     8;
     aMaxBytesPerLine           =     128;
     aHexRadix                  =     16;

     aMaxOnHeap                 =     32768;
     aMaxOutBufSize             =     32768;

     achNULL                    =     #0;
     achHTAB                    =     #9;
     achCR                      =     #13;
     achSkip                    =     '.';
     achZero                    =     '0';
     achOne                     =     '1';
     achDelimiter               =     ',';
     achSemicolon               =     ';';

     achYes                     =     'Y';
     achNo                      =     'N';

     asAsmData                  =     'DB';
     asHexSuffix                =     'h';
     asAsmBitData               =     'b';
     asAsmNoList                =     '.XLIST';
     asAsmList                  =     '.LIST';



{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
    STR3        =       STRING[3];
    STR4        =       STRING[4];
    STR8        =       STRING[8];


{*====================== TYPED CONSTANTS PART ==========================*}

CONST
     setHexChars  :    SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];
     setAscii7    :    SET OF System.Char  =  [#32..#126];
     setAscii8    :    SET OF System.Char  =  [#32..#126,#128..#255];
     setIbmAscii  :    SET OF System.Char  =  [#32..#126,#128..#254];

     gadbAsciiFormat      :       System.Byte         =  aAsciiNone;
     gdbInitCharCount     :       System.Byte         =  0;
     gadbSymbolsInString  :       System.Byte         =  aDefaultBytesPerLine;
     gddBytesCountDone    :       System.Longint      =  0;


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
   gchInUser            :       System.Char;

   gdbTextOutBuf        :       ARRAY[1..aMaxOutBufSize]  OF  System.Byte;


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


FUNCTION   _fnsByteToAsmFormat(dbInput : System.Byte) : STR4;
{* Converts a byte to the ASM format number representation. *}
CONST
    chHexDigitsTable : ARRAY[0..15] OF System.Char = '0123456789ABCDEF';

BEGIN
  _fnsByteToAsmFormat := achZero +
                         chHexDigitsTable[dbInput SHR 4] +
                         chHexDigitsTable[dbInput AND $0F] +
                         asHexSuffix;
END;  { _fnsByteToAsmFormat }


FUNCTION  _fnsByteToBitString(dbInput : System.Byte; chZero,chOne : System.Char) : STR8;
{* Return the bit representation of the byte. *}
      inline($5A                 {    pop   dx          ; DL = One           }
            /$5B                 {    pop   bx          ; BL = Zero          }
            /$58                 {    pop   ax          ; AL = Number        }
            /$88/$C7             {    mov   bh,al       ; BH = Number        }
            /$89/$E7             {    mov   di,sp       ; make stack frame   }
            /$36/$C4/$3D         {    les   di,ss:[di]  ; ES:DI -> string    }
            /$B9/$08/$00         {    mov   cx,8        ; repeat count       }
            /$FC                 {    cld               ; forward direction  }
            /$88/$C8             {    mov   al,cl       ; AL = string length }
            /$AA                 {    stosb             ; store it           }
                                 { NextBit:                                  }
            /$88/$D8             {    mov   al,bl       ; AL = Zero          }
            /$D0/$E7             {    shl   bh,1        ; transfer bit in CF }
            /$73/$02             {    jnc   BitDone     ; if not (CY), zero  }
            /$88/$D0             {    mov   al,dl        ; AL = One          }
                                 { BitDone:                                  }
            /$AA                 {    stosb             ; put a Char         }
            /$E2/$F5);           {    loop  NextBit     ; repeat till done   }
{ _fnsByteToBitString }


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
     System.WriteLn(asPurpose+'  Version '+asVersion+',  '+asCopyright+'  '+asAuthor);
END;  { _CopyrightDisplay }


PROCEDURE  _WriteBufferToDisk(VAR fOutTextFile : System.Text;
                                  pMemBuf : System.Pointer;
                                  dwByteCount : System.Word;
                                  dbAsciiSwitch : System.Byte);
{* Writes the contents of buffer in hexadecimal format to file. *}
VAR
  sOutStr            :  STRING;
  sAsciiStr          :  STRING;
  gdbByteArray       :  ARRAY[1..aMaxBytesPerLine] OF System.Byte;
  dwOffsetInBuffer   :  System.Word;
  dbInByte, dbIndex  :  System.Byte;
  dbCountInLine      :  System.Byte;
  dbCutLineIndex     :  System.Byte;
  chAddChar          :  System.Char;

BEGIN
  {** initial offset in file buffer **}
    dwOffsetInBuffer := 0;


  {* try to optimal value for # bytes per one text string *}
  IF  (gadbSymbolsInString > 10)
     THEN  BEGIN
              IF (gadbSymbolsInString > 20)
                   THEN  dbCutLineIndex := (gadbSymbolsInString DIV 8)
                   ELSE  dbCutLineIndex := (gadbSymbolsInString DIV 2);
             {if-then-else}
           END
     ELSE
        dbCutLineIndex := gadbSymbolsInString + 1;
  {if-then-else}


  {** main process **}
  WHILE  (dwByteCount <> 0) DO
  BEGIN
    {** init'd strings **}
    sOutStr   := ';**     '+asAsmData+achHTAB;
    sAsciiStr := asBlankStr;

    {* test for full/partial line *}
    IF ((dwByteCount DIV gadbSymbolsInString) <> 0)
      THEN  dbCountInLine := gadbSymbolsInString
      ELSE  dbCountInLine := dwByteCount;
    {if-then-else}

          BEGIN
             FOR  dbIndex := 1  TO  dbCountInLine  DO
             BEGIN
                   IF ((dbIndex = ((dbIndex DIV dbCutLineIndex)*dbCutLineIndex+1))
                          AND (dbIndex <> 1))  THEN
                   BEGIN
                       {** erase a delimiter **}
                       System.Delete(sOutStr,System.Length(sOutStr),1);

                       IF  (dbAsciiSwitch <> aAsciiNone)
                          THEN  sOutStr := sOutStr+achHTAB+achHTAB+
                                           achSemicolon+asSpace2+sAsciiStr;
                       {if-then}

                       System.WriteLn(fOutTextFile,sOutStr);
                       sOutStr   := ';**     '+asAsmData+achHTAB;
                       sAsciiStr := asBlankStr;
                   END;
                   {if-then}

               dbInByte := System.Mem[System.Seg(pMemBuf^):(System.Ofs(pMemBuf^)+dwOffsetInBuffer)];
               gdbByteArray[dbIndex] := dbInByte;
               sOutStr := sOutStr + _fnsByteToAsmFormat(dbInByte);

               IF  (dbIndex < dbCountInLine)
                 THEN  sOutStr := sOutStr + achDelimiter;
               {if-then}

               chAddChar := System.Char(dbInByte);
               CASE  dbAsciiSwitch  OF
                        aAscii7   : IF  (chAddChar IN setAscii7)
                                       THEN  sAsciiStr := sAsciiStr + chAddChar
                                       ELSE  sAsciiStr := sAsciiStr + achSkip;
                                    {if-then-else}
                        aAscii8   : IF  (chAddChar IN  setAscii8)
                                       THEN  sAsciiStr := sAsciiStr + chAddChar
                                       ELSE  sAsciiStr := sAsciiStr + achSkip;
                                    {if-then-else}
               END;
               {case-of}

               System.Inc(dwOffsetInBuffer);
             END;
             {for-to-do}

             IF  (dbAsciiSwitch <> aAsciiNone)
                THEN  BEGIN
                        FOR dbIndex := 1  TO  (gadbSymbolsInString-dbCountInLine)
                           DO  sOutStr := sOutStr + asSpaces5;
                        {for-to-do}
                        sOutStr := sOutStr + achHTAB + achHTAB +
                                   achSemicolon + asSpace2 + sAsciiStr;
                      END;
             {if-then}

             System.WriteLn(fOutTextFile,sOutStr);
             System.Dec(dwByteCount,dbCountInLine);

             sOutStr   := ';*       '+achHTAB + achHTAB +' Char #';
             System.Write(fOutTextFile,sOutStr,gdbInitCharCount);
             chAddChar := System.Char(gdbInitCharCount);
             IF  NOT(chAddChar IN setIbmAscii)
                 THEN  System.WriteLn(fOutTextFile,'  '''+'''')
                 ELSE  System.WriteLn(fOutTextFile,'  '''+ chAddChar+'''');
             {if-then-else}
             System.Inc(gdbInitCharCount);

             FOR  dbIndex := 1  TO  dbCountInLine  DO
             BEGIN
                 sOutStr   := achHTAB + achHTAB + asAsmData + achHTAB+
                      _fnsByteToBitString(gdbByteArray[dbIndex],achZero,achOne)+asAsmBitData;
                 System.WriteLn(fOutTextFile,sOutStr);
             END;
             {for-to-do}

             System.WriteLn(fOutTextFile);

          END;
  END;
  {while-do}

END;  { _WriteBufferToDisk }


{*============================== MAIN PART =============================*}

BEGIN
  _CopyrightDisplay;

     IF (System.ParamCount < 2) THEN
     BEGIN
          System.WriteLn(asProgramPrompt+'  help screen for you.');
          System.WriteLn('Usage: infile outfile [bytes[initchar[ascii]]]');
          System.WriteLn('  infile   -  source filename       (def. ext. = '+asInDefExt+')');
          System.WriteLn('  outfile  -  destination filename  (def. ext. = '+asOutDefExt+')');
          System.WriteLn('  bytecnt  -  number of bytes per char for representation (def.=',aDefaultBytesPerLine,
                         ', max=',aMaxBytesPerLine,')');
          System.WriteLn('  initchar -  initial char number   (def. num. = ',gdbInitCharCount,')');
          System.WriteLn('  ascii    -  optional, enable to add ASCII-char string');
          System.WriteLn('                '+achAsciiBit7+' -> 7-bit ASCII format,');
          System.WriteLn('                '+achAsciiBit8+' -> 8-bit ASCII format.');
          System.WriteLn('                       (default=none)');
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
    System.WriteLn(asProgramPrompt+'  Unable to open file '+gsInFileName);
    System.Halt(errSourceNotFound);
  END;
  {if-then}


  {** may be destination file present? **}
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
       IF  (giErrorCode <> 0)  THEN
       BEGIN
             System.WriteLn(asProgramPrompt+' Invalid format for BYTES switch.');
             System.Halt(errBadFmtBytesValue);
       END;
       {if-then}
  END;
  {if-then}



  {** read the following parameter = initchar switch **}
  IF  (System.ParamCount >= 4) THEN
  BEGIN
       gsTempInput := System.ParamStr(4);
       System.Val(gsTempInput,gdbInitCharCount,giErrorCode);
       IF  (giErrorCode <> 0)  THEN
       BEGIN
             System.WriteLn(asProgramPrompt+' Invalid value for INITCHAR switch.');
             System.Halt(errBadCharValue);
       END;
       {if-then}
  END;
  {if-then}



  {** read the following parameter = ascii switch **}
  IF  (System.ParamCount >= 5) THEN
  BEGIN
       gsTempInput := System.ParamStr(5);
       CASE  gsTempInput[1] OF
            achAsciiBit7  :  gadbAsciiFormat := aAscii7;
            achAsciiBit8  :  gadbAsciiFormat := aAscii8;
       ELSE
          {** reserved **};
       END;
       {case-of}
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
    System.WriteLn(asProgramPrompt+'  Unable to open '+gsInFileName);
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
    System.WriteLn(asProgramPrompt+'  Unable to create '+gsOutFileName);
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
  System.WriteLn(gfOutputFormatText,';  SOURCE FILE:  '+gsInFileName);
  System.WriteLn(gfOutputFormatText,';  Created by '+asProgram+' utility, '+asCopyright+'  '+asAuthor);
  System.WriteLn(gfOutputFormatText);
  System.WriteLn(gfOutputFormatText,asAsmNoList);
  System.WriteLn(gfOutputFormatText);


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
  System.WriteLn(gfOutputFormatText,asAsmList);

  {** free memory on heap **}
  System.FreeMem(gpMemoryBlock,gdwMemBlockSize);


  {** close all files **}
  System.Close(gfInputStream);
  System.Close(gfOutputFormatText);


  {** report all done **}
  System.WriteLn(asProgramPrompt+' Done.');

  {* System.Halt(errTerminateOk); *}
END.
