{****************************************************************************
//                            File FSPLIT.PAS
//
//                        File splitter utility
//
//      Copyright (c) 1993, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/FSPLIT/RCS/fsplit.pas $
//  $RCSfile: fsplit.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:47:51 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: fsplit.pas $
//      Revision 1.1  1998/10/03 14:47:51  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                FILE_SPLIT                                      }
{ FILE NAME             FSPLIT.PAS                                      }
{ PURPOSE               SPLITES BINARY FILE TO TWO PARTIAL FILES        }
{ VERSION               1.23                                            }
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
{ ARGUMENTS             <infile>    -   input binary file               }
{                       <evenfile>  -   output filename (even bytes)    }
{                       <oddfile>   -   output filename (odd bytes)     }
{                       <evencount> -   # of bytes to put in even part  }
{                       <oddcount>  -   # of bytes to put in odf part   }
{ RETURN                See error return codes definitions              }
{ REQUIRES              Source Code Files                               }
{                       NONE                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Maintence Project Files                         }
{                       NONE                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           1.Read   input  stream (# of bytes)             }
{                       2.Format output stream (evencount of bytes put  }
{                         to even stream, oddcount - to odd stream)     }
{                       3.Write output streams (2 streams)              }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00  23-Mar-93  DS  initilal release           }
{                       1.01  30-Mar-93  DS  updated messages output    }
{                       1.02  19-May-93  DS  some style updates         }
{                       1.10  16-Aug-93  DS  overwritten the part of r/w}
{                                            in/out streams, added more }
{                                            parameters to files split  }
{                       1.20  20-Sep-93  DS  some style updates         }
{                       1.21  26-Jul-97  DS  updated documentation      }
{                       1.22  02-Aug-97  DS  removed tabs               }
{                       1.23  02-Sep-97  DS  fixed open r/o file bug   }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM SpliteBinaryFile;


{*** other modules ***}
USES
  ShowTErr;


{** switches for compilation **}
{$S-}           {*  stack checking   *}
{$R-}           {*  range checking   *}


{* generate version for debugging *}
{***$DEFINE  DebugVersion}


{*========================== CONSTANTS PART ============================*}

CONST
     asPurpose                  =       'FILE SPLIT UTILITY';
     asVersion                  =       '1.23';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1993, 1997';
     asProgram                  =       'FSplit';
     asProgramU                 =       'FSPLIT';
     asProgramPrompt            =       asProgram+': ';

     { exit codes }
       errTerminateOK           =     0;
       errOnLineHelp            =     1;
       errSourceNotFound        =     2;
       errDestDontWriteEven     =     3;
       errDestDontWriteOdd      =     4;
       errBadEvenCount          =     5;
       errBadOddCount           =     6;

     { defaults to byte count }
       aEvenCountDef         =        1;
       aOddCountDef          =        1;
       aEvenCountMax         =        4096;
       aOddCountMax          =        4096;

     { allocating memory heaps sizes }
       aMaxOutBufSize         =       aEvenCountMax;
       aMaxInBufSize        =         aMaxOutBufSize * 2;

     { miscellaneous equates }
       achNULL               =        #0;
       achYes                =        'Y';
       achHexPrefix          =        '$';
       aHexRadix             =        16;


{*====================== TYPED CONSTANTS PART ==========================*}

CONST
  setHexChars  :    SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];

  gdwEvenOutBufOfs      :       System.Word          =       0;
  gdwOddOutBufOfs       :       System.Word          =       0;
  gdwEvenByteCount      :       System.Word          =       aEvenCountDef;
  gdwOddByteCount       :       System.Word          =       aOddCountDef;
  gdwEvenIndex          :       System.Word          =       aEvenCountDef;
  gdwOddIndex           :       System.Word          =       0;
  gdwInActualCount      :       System.Word          =       0;
  gdwInBufTotalCount    :       System.Word          =       0;
  agbReadEvenPart       :       System.Boolean       =       System.True;


{*=========================== VARIABLES PART ===========================*}

VAR
  gfOutStreamEven, gfOutStreamOdd, gfInStream :  FILE;
  gsOutNameEven,   gsOutNameOdd,   gsInName   :  STRING;

  glpInBuf,
  glpEvenOutBuf,
  glpOddOutBuf                               :  System.Pointer;
  gliInBytesCount                            :  System.Longint;
  gdwCmdCount                                :  System.Word;
  giErrorCode                                :  System.Integer;
  gsTempInput                                :  STRING;


{*=========================== FORWARD REFERENCES =======================*}

PROCEDURE    _ProgramOutputMessage(sMessage : STRING); FORWARD;


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

  {** try to open the file **}
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


FUNCTION  _fndbHexCharToBin(chIn: System.Char) : System.Byte; assembler;
{* Converts the hexadecimal char to binary number. *}
asm
        mov   al,chIn        { AL = chIn }
        sub   al,'0'         { AL <- AL - '0' }

        cmp   al,9           { test for digit 0-9 }
        jbe   @Done

        and   al,11011111b   { make uppercase }
        sub   al,'A'-'9'-1   { AL = 'A'..'F' }

      @Done:
                             { AL = function result }
END;
    {asm-end}
{ _fndbHexCharToBin }


FUNCTION  _fnliHexStrToBin(sHexInput : STRING; VAR iErrCode : System.Integer) : System.Longint;
{* Converts hexadecimal string to decimal number. *}
VAR
  ddNumber               :       System.Longint;
  dbStrIndex, dbStrLen   :       System.Byte;

BEGIN
  iErrCode   := 0;
  ddNumber   := 0;
  dbStrIndex := 1;
  dbStrLen := System.Length(sHexInput);

  WHILE (iErrCode = 0) and (dbStrLen > 0) DO
  BEGIN
    IF  (sHexInput[dbStrIndex] IN setHexChars)
    THEN  BEGIN
               ddNumber := ddNumber * aHexRadix +
                           _fndbHexCharToBin(sHexInput[dbStrIndex]);
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
{* Reads a numeric string. *}
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



{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE  _PutByteToEvenOutFile(dbNextChar : System.Byte);
{* Buffered writing to output stream. *}
BEGIN
  IF  (gdwEvenOutBufOfs >= aMaxOutBufSize)
    THEN  BEGIN
         _ProgramOutputMessage('Write Output Stream (even).');
         System.BlockWrite(gfOutStreamEven,
                           System.Mem[System.Seg(glpEvenOutBuf^):System.Ofs(glpEvenOutBuf^)],
                           aMaxOutBufSize);
         gdwEvenOutBufOfs := 0;
          END;
  {if-then}
  System.Mem[System.Seg(glpEvenOutBuf^):(System.Ofs(glpEvenOutBuf^)+gdwEvenOutBufOfs)] := dbNextChar;
  System.Inc(gdwEvenOutBufOfs);
END;
{  _PutByteToEvenOutFile }


PROCEDURE  _PutByteToOddOutFile(dbNextChar : System.Byte);
{* Buffered writing to output stream. *}
BEGIN
  IF  (gdwOddOutBufOfs >= aMaxOutBufSize)
    THEN  BEGIN
         _ProgramOutputMessage('Write Output Stream (odd).');
         System.BlockWrite(gfOutStreamOdd,
                           System.Mem[System.Seg(glpOddOutBuf^):System.Ofs(glpOddOutBuf^)],
                           aMaxOutBufSize);
         gdwOddOutBufOfs := 0;
          END;
  {if-then}
  System.Mem[System.Seg(glpOddOutBuf^):(System.Ofs(glpOddOutBuf^)+gdwOddOutBufOfs)] := dbNextChar;
  System.Inc(gdwOddOutBufOfs);
END;
{  _PutByteToEvenOutFile }


FUNCTION  _fndbReadInFile : System.Byte;
{* Buffered reading from even input stream. *}
BEGIN
{$IFDEF  DebugVersion}
  _fndbReadEvenInFile := $0;
{$ELSE}
  IF (gdwInActualCount = 0)
    THEN  BEGIN
    _ProgramOutputMessage('Read Input Stream.');
    {$I-}
    System.BlockRead(gfInStream,
                     System.Mem[System.Seg(glpInBuf^):System.Ofs(glpInBuf^)],
                     aMaxInBufSize,gdwInBufTotalCount);
    gdwInActualCount := gdwInBufTotalCount;
    {$I+}
          END;
  {if-then}
   System.Dec(gdwInActualCount);
  _fndbReadInFile := System.Mem[System.Seg(glpInBuf^):
                                    (System.Ofs(glpInBuf^)+(gdwInBufTotalCount-(1+gdwInActualCount)))];
{$ENDIF  DebugVersion}
END;
{ _fndbReadInFile }



PROCEDURE    _ProgramOutputMessage(sMessage : STRING);
{* Output a message with a program name as prefix. *}
BEGIN
  System.WriteLn(asProgramPrompt+sMessage);
END;
{ _ProgramOutputMessage }


PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+
                    '  Version '+
                    asVersion+
                    ',  '+
                    asCopyright
                    +'  '+
                    asAuthor);
END;  { _CopyrightDisplay }


{*============================== MAIN PART =============================*}

BEGIN

  _CopyrightDisplay;


 {* find # of user parameters *}
   gdwCmdCount := System.ParamCount;

  IF (gdwCmdCount < 3)
    THEN BEGIN
      _ProgramOutputMessage('on-line help');
      System.WriteLn(' Usage: '+asProgramU+' infile evenfile oddfile [evencount [oddcount]]');
      System.WriteLn('  infile     -  source file');
      System.WriteLn('  evenfile   -  destination file (1st part)');
      System.WriteLn('  oddfile    -  destination file (2nd part)');
      System.WriteLn('  evencount  -  # of xfr bytes at each pass to 1st part (def=',
                     aEvenCountDef,',max=',aEvenCountMax,')');
      System.WriteLn('  oddcount   -  # of xfr bytes at each pass to 2nd part (def=',
                     aOddCountDef,',max=',aOddCountMax,')');
      System.WriteLn('  Numbers may be decimals, or hexadecimals (first symbol is ''$'' for hex.).');
      System.Halt(errOnLineHelp);
         END
    ELSE BEGIN
      gsInName      := System.ParamStr(1);
      gsOutNameEven := System.ParamStr(2);
      gsOutNameOdd  := System.ParamStr(3);
         END;
  {if-then-else}


  {** source file exists? **}
  IF  NOT(_fnbFileExist(gfInStream,gsInName)) THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to open file '+gsInName);
    System.Halt(errSourceNotFound);
  END;
  {if-then}

  {** destination files present? **}
  IF (_fnbFileExist(gfOutStreamEven,gsOutNameEven)) THEN
  BEGIN
    System.Write(asProgramPrompt+'Output file '+gsOutNameEven+
                 ' already exists. Overwrite? (n/y): ');
    System.ReadLn(gsTempInput);
    IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achYes)
      THEN  System.Halt(errDestDontWriteEven);
    {if-then}
  END;
  {if-then}

  IF (_fnbFileExist(gfOutStreamOdd,gsOutNameOdd)) THEN
  BEGIN
    System.Write(asProgramPrompt+'Output file '+gsOutNameOdd+
                 ' already exists. Overwrite? (n/y): ');
    System.ReadLn(gsTempInput);
    IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achYes)
      THEN  System.Halt(errDestDontWriteOdd);
    {if-then}
  END;
  {if-then}


  {** read the following parameter = even bytes count **}
  IF (gdwCmdCount >  3)
    THEN  BEGIN
     gsTempInput := System.ParamStr(4);
     gdwEvenByteCount := _fnddGetNum(gsTempInput,giErrorCode);

     IF ((giErrorCode <> 0) OR
         (aEvenCountDef > gdwEvenByteCount) OR
         (gdwEvenByteCount > aEvenCountMax))
      THEN
         BEGIN
           System.WriteLn(asProgramPrompt+' Bad even count found.');
           System.Halt(errBadEvenCount);
         END;
      {if-then}
          END;
  {if-then}


  {** read the following parameter = odd bytes count **}
  IF (gdwCmdCount >  4)
    THEN  BEGIN
     gsTempInput := System.ParamStr(5);
     gdwOddByteCount := _fnddGetNum(gsTempInput,giErrorCode);

     IF ((giErrorCode <> 0) OR
         (aOddCountDef > gdwOddByteCount) OR
         (gdwOddByteCount > aOddCountMax))
      THEN
         BEGIN
           System.WriteLn(asProgramPrompt+' Bad odd count found.');
           System.Halt(errBadOddCount);
         END;
      {if-then}
          END;
  {if-then}



 {* do in/out streams *}
    System.FileMode := $20;   {read, deny write on share}
    System.Assign(gfInStream,gsInName);
    System.Reset(gfInStream,1);

    System.FileMode := 2; {read/write, compatibilty mode}
    System.Assign(gfOutStreamEven,gsOutNameEven);
    System.Rewrite(gfOutStreamEven,1);

    System.Assign(gfOutStreamOdd,gsOutNameOdd);
    System.Rewrite(gfOutStreamOdd,1);


 {* allocate a memory *}
    System.GetMem(glpInBuf,aMaxInBufSize);
    System.GetMem(glpEvenOutBuf,aMaxOutBufSize);
    System.GetMem(glpOddOutBuf,aMaxOutBufSize);


 {* initialize the internal variables *}
    gliInBytesCount := System.FileSize(gfInStream);
    gdwEvenIndex := gdwEvenByteCount;

 {* main loop *}
    WHILE  (gliInBytesCount <> 0) DO
    BEGIN
       IF  (agbReadEvenPart)
          THEN  BEGIN
                 WHILE (gliInBytesCount <> 0) AND (gdwEvenIndex <> 0) DO
                 BEGIN
                   _PutByteToEvenOutFile(_fndbReadInFile);
                    System.Dec(gdwEvenIndex);
                    IF (gdwEvenIndex = 0)
                      THEN  gdwOddIndex := gdwOddByteCount;
                    {if-then}
                   System.Dec(gliInBytesCount);
                 END;
                 {while-do}
                 agbReadEvenPart := System.False;
                END
          ELSE  BEGIN
                 WHILE (gliInBytesCount <> 0) AND (gdwOddIndex <> 0) DO
                 BEGIN
                   _PutByteToOddOutFile(_fndbReadInFile);
                    System.Dec(gdwOddIndex);
                    IF (gdwOddIndex = 0)
                      THEN  gdwEvenIndex := gdwEvenByteCount;
                    {if-then}
                   System.Dec(gliInBytesCount);
                 END;
                 {while-do}
                 agbReadEvenPart := System.True;
                END;
       {if-then-else}
    END;
    {while-do}


 {* check what is present in output buffers? *}
  IF (gdwEvenOutBufOfs <> 0)
    THEN  BEGIN
       _ProgramOutputMessage('Write last output buffer (even).');
       System.BlockWrite(gfOutStreamEven,
                         System.Mem[System.Seg(glpEvenOutBuf^):System.Ofs(glpEvenOutBuf^)],
                         gdwEvenOutBufOfs);
          END;
  {if-then}

  IF (gdwOddOutBufOfs <> 0)
    THEN  BEGIN
       _ProgramOutputMessage('Write last output buffer (odd).');
       System.BlockWrite(gfOutStreamOdd,
                         System.Mem[System.Seg(glpOddOutBuf^):System.Ofs(glpOddOutBuf^)],
                         gdwOddOutBufOfs);
          END;
  {if-then}


  _ProgramOutputMessage('Done.');

  System.FreeMem(glpEvenOutBuf,aMaxOutBufSize);
  System.FreeMem(glpOddOutBuf,aMaxOutBufSize);
  System.FreeMem(glpInBuf,aMaxInBufSize);

  System.Close(gfOutStreamEven);
  System.Close(gfOutStreamOdd);
  System.Close(gfInStream);

  {* System.Halt(errTerminateOk); *}
END.
