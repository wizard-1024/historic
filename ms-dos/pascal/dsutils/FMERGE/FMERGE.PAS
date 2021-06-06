{****************************************************************************
//                            File FMERGE.PAS
//
//                         Merge files utility
//
//      Copyright (c) 1992, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/FMERGE/RCS/fmerge.pas $
//  $RCSfile: fmerge.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:45:42 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: fmerge.pas $
//      Revision 1.1  1998/10/03 14:45:42  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                FILE_MERGE                                      }
{ FILE NAME             FMERGE.PAS                                      }
{ PURPOSE               MERGE BINARY FILES SPLITTED TO SOME PARTS       }
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
{                       (Borland International Inc.) or compatible      }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             <evenfile>  -   input filename ('even' bytes)   }
{                       <oddfile>   -   input filename ('odd' bytes)    }
{                       <outfile>   -   resulting file                  }
{                       <evencount> -   # of bytes to put early         }
{                       <oddcount>  -   # of bytes to put later         }
{ RETURN                See error return codes definitions              }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           1.Read   input  stream (first early, then later)}
{                       2.Format output stream (do entity from # bytes) }
{                       3.Write  output stream (entity)                 }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00  11-Aug-92  DS  initilal release           }
{                       1.01  06-Mar-93  DS  added more fast block read }
{                                            and writing from/to file   }
{                       1.02  23-Mar-93  DS  some style changes         }
{                       1.03  30-Mar-93  DS  updated message output     }
{                       1.10  19-May-93  DS  some style updates         }
{                       1.20  15-Aug-93  DS  full overwritten of rd/wr, }
{                                            added parameters to vary of}
{                                            # of bytes transferred from}
{                                            input stream files         }
{                       1.30  20-Sep-93  DS  some style updates         }
{                       1.31  26-Jul-97  DS  updated documentation      }
{                       1.32  02-Aug-97  DS  removed tabs               }
{                       1.33  02-Sep-97  DS  fixed open r/o file bug    }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM  MergeBinaryFiles;


{*** other modules ***}
USES
  ShowTErr;


{** switches for compilation **}
{$S-}           {*  stack checking   *}
{$R-}           {*  range checking   *}


{* generate version for debugging version *}
{***$DEFINE  DebugVersion}


{*========================== CONSTANTS PART ============================*}

CONST
     asPurpose                  =       'FILE MERGE UTILITY';
     asVersion                  =       '1.33';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1992, 1997';
     asProgram                  =       'FMerge';
     asProgramU                 =       'FMERGE';
     asProgramPrompt            =       asProgram+': ';

     { exit codes }
       errTerminateOK           =     0;
       errOnLineHelp            =     1;
       errSourceEvenNotFound    =     2;
       errSourceOddNotFound     =     3;
       errDestDontWrite         =     4;
       errBadEvenCount          =     5;
       errBadOddCount           =     6;


     { miscellaneous equates }
       achNULL               =        #0;
       achYes                =        'Y';
       achHexPrefix          =        '$';
       aHexRadix             =        16;

     { defaults to byte count }
       aEvenCountDef         =        1;
       aOddCountDef          =        1;
       aEvenCountMax         =        4096;
       aOddCountMax          =        4096;

     { allocating memory heaps sizes }
       aMaxInBufSize         =       aEvenCountMax;
       aMaxOutBufSize        =       aMaxInBufSize * 2;


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

  setHexChars  :    SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];

  gdwOutBufOfs          :       System.Word          =       0;
  gdwEvenByteCount      :       System.Word          =       aEvenCountDef;
  gdwOddByteCount       :       System.Word          =       aOddCountDef;
  gdwEvenIndex          :       System.Word          =       aEvenCountDef;
  gdwOddIndex           :       System.Word          =       0;
  gdwEvenActualCount    :       System.Word          =       0;
  gdwOddActualCount     :       System.Word          =       0;
  gdwEvenBufTotalCount  :       System.Word          =       0;
  gdwOddBufTotalCount   :       System.Word          =       0;
  agbReadEvenPart       :       System.Boolean       =       System.True;


{*=========================== VARIABLES PART ===========================*}

VAR
  gfInStreamEven, gfInStreamOdd, gfOutStream :  FILE;
  gsInNameEven,   gsInNameOdd,   gsOutName   :  STRING;

  glpOutBuf,
  glpInEvenBuf,
  glpInOddBuf                                :  System.Pointer;
  gliEvenInBytesCount,
  gliOddInBytesCount,
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


FUNCTION  _fndbReadEvenInFile : System.Byte;
{* Buffered reading from even input stream. *}
BEGIN
{$IFDEF  DebugVersion}
  _fndbReadEvenInFile := $0;
{$ELSE}
  IF (gdwEvenActualCount = 0)
    THEN  BEGIN
    _ProgramOutputMessage('Read Even.');
    {$I-}
    System.BlockRead(gfInStreamEven,
                     System.Mem[System.Seg(glpInEvenBuf^):System.Ofs(glpInEvenBuf^)],
                     aMaxInBufSize,gdwEvenBufTotalCount);
    gdwEvenActualCount := gdwEvenBufTotalCount;
    {$I+}
          END;
  {if-then}
   System.Dec(gdwEvenActualCount);
  _fndbReadEvenInFile := System.Mem[System.Seg(glpInEvenBuf^):
                                    (System.Ofs(glpInEvenBuf^)+(gdwEvenBufTotalCount-(1+gdwEvenActualCount)))];
{$ENDIF  DebugVersion}
END;
{ _fndbReadEvenInFile }


FUNCTION  _fndbReadOddInFile : System.Byte;
{* Buffered reading from odd input stream. *}
BEGIN
{$IFDEF  DebugVersion}
  _fndbReadOddInFile := $FF;
{$ELSE}
  IF (gdwOddActualCount = 0)
    THEN  BEGIN
    _ProgramOutputMessage('Read Odd.');
    {$I-}
    System.BlockRead(gfInStreamOdd,
                     System.Mem[System.Seg(glpInOddBuf^):System.Ofs(glpInOddBuf^)],
                     aMaxInBufSize,gdwOddBufTotalCount);
    gdwOddActualCount := gdwOddBufTotalCount;
    {$I+}
          END;
  {if-then}
   System.Dec(gdwOddActualCount);
  _fndbReadOddInFile := System.Mem[System.Seg(glpInOddBuf^):
                                    (System.Ofs(glpInOddBuf^)+(gdwOddBufTotalCount-(1+gdwOddActualCount)))];
{$ENDIF  DebugVersion}
END;
{ _fndbReadOddInFile }



{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE  _PutByteToOutFile(dbNextChar : System.Byte);
{* Buffered writing to output stream. *}
BEGIN
  IF  (gdwOutBufOfs >= aMaxOutBufSize)
    THEN  BEGIN
         System.BlockWrite(gfOutStream,
                           System.Mem[System.Seg(glpOutBuf^):System.Ofs(glpOutBuf^)],
                           aMaxOutBufSize);
         gdwOutBufOfs := 0;
          END;
  {if-then}
  System.Mem[System.Seg(glpOutBuf^):(System.Ofs(glpOutBuf^)+gdwOutBufOfs)] := dbNextChar;
  System.Inc(gdwOutBufOfs);
END;
{  _PutByteToOutFile }


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
      System.WriteLn(' Usage: '+asProgramU+' evenfile oddfile outfile [evencount [oddcount]]');
      System.WriteLn('  evenfile   -  source file (1st part)');
      System.WriteLn('  oddfile    -  source file (2nd part)');
      System.WriteLn('  outfile    -  destination file');
      System.WriteLn('  evencount  -  # of xfr bytes at each pass from 1st part (def=',
                     aEvenCountDef,',max=',aEvenCountMax,')');
      System.WriteLn('  oddcount   -  # of xfr bytes at each pass from 2nd part (def=',
                     aOddCountDef,',max=',aOddCountMax,')');
      System.WriteLn('  Numbers may be decimals, or hexadecimals (first symbol is ''$'' for hex.).');
      System.Halt(errOnLineHelp);
         END
    ELSE BEGIN
      gsInNameEven := System.ParamStr(1);
      gsInNameOdd  := System.ParamStr(2);
      gsOutName    := System.ParamStr(3);
         END;
  {if-then-else}


  {** source files exists? **}
  IF  NOT(_fnbFileExist(gfInStreamEven,gsInNameEven)) THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to open file '+gsInNameEven);
    System.Halt(errSourceEvenNotFound);
  END;
  {if-then}

  IF  NOT(_fnbFileExist(gfInStreamOdd,gsInNameOdd)) THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to open file '+gsInNameOdd);
    System.Halt(errSourceOddNotFound);
  END;
  {if-then}


  {** destination file present? **}
  IF (_fnbFileExist(gfOutStream,gsOutName)) THEN
  BEGIN
    System.Write(asProgramPrompt+'Output file '+gsOutName+
                 ' already exists. Overwrite? (n/y): ');
    System.ReadLn(gsTempInput);
    IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achYes)
      THEN  System.Halt(errDestDontWrite);
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
  System.Assign(gfInStreamEven,gsInNameEven);
  System.Reset(gfInStreamEven,1);

  System.Assign(gfInStreamOdd,gsInNameOdd);
  System.Reset(gfInStreamOdd,1);

  System.FileMode := 2; {read/write, compatibilty mode}
  System.Assign(gfOutStream,gsOutName);
  System.Rewrite(gfOutStream,1);


 {* find a minimal file size from input streams *}
  IF (System.FileSize(gfInStreamEven) <= (System.FileSize(gfInStreamOdd)))
    THEN  gliInBytesCount := System.FileSize(gfInStreamEven)
    ELSE  gliInBytesCount := System.FileSize(gfInStreamOdd);
  {if-then-else}


 {* allocate a memory *}
  System.GetMem(glpInEvenBuf,aMaxInBufSize);
  System.GetMem(glpInOddBuf,aMaxInBufSize);
  System.GetMem(glpOutBuf,aMaxOutBufSize);


 {* initialize the internal variables *}
    gliEvenInBytesCount := System.FileSize(gfInStreamEven);
    gliOddInBytesCount := System.FileSize(gfInStreamOdd);
    gdwEvenIndex := gdwEvenByteCount;

 {* main loop *}
    WHILE  (gliEvenInBytesCount <> 0) OR (gliOddInBytesCount <> 0)  DO
    BEGIN
       IF  (agbReadEvenPart)
          THEN  BEGIN
            IF  (gliOddInBytesCount <> 0)
              THEN  BEGIN
                 WHILE (gliEvenInBytesCount <> 0) AND (gdwEvenIndex <> 0) DO
                 BEGIN
                   _PutByteToOutFile(_fndbReadEvenInFile);
                    System.Dec(gdwEvenIndex);
                    IF (gdwEvenIndex = 0)
                      THEN  gdwOddIndex := gdwOddByteCount;
                    {if-then}
                   System.Dec(gliEvenInBytesCount);
                 END;
                 {while-do}
                 agbReadEvenPart := System.False;
                    END
              ELSE  BEGIN
                WHILE  (gliEvenInBytesCount <> 0)  DO
                BEGIN
                   _PutByteToOutFile(_fndbReadEvenInFile);
                   System.Dec(gliEvenInBytesCount);
                END;
                {while-do}
                    END;
            {if-then-else}
                END
          ELSE  BEGIN
            IF  (gliEvenInBytesCount <> 0)
              THEN  BEGIN
                 WHILE (gliOddInBytesCount <> 0) AND (gdwOddIndex <> 0) DO
                 BEGIN
                   _PutByteToOutFile(_fndbReadOddInFile);
                    System.Dec(gdwOddIndex);
                    IF (gdwOddIndex = 0)
                      THEN  gdwEvenIndex := gdwEvenByteCount;
                    {if-then}
                   System.Dec(gliOddInBytesCount);
                 END;
                 {while-do}
                 agbReadEvenPart := System.True;
                    END
              ELSE  BEGIN
                WHILE  (gliOddInBytesCount <> 0)  DO
                BEGIN
                   _PutByteToOutFile(_fndbReadOddInFile);
                   System.Dec(gliOddInBytesCount);
                END;
                {while-do}
                    END;
            {if-then-else}
                END;
       {if-then-else}
    END;
    {while-do}


 {* check what is present in output buffer? *}
  IF (gdwOutBufOfs <> 0)
    THEN  BEGIN
       _ProgramOutputMessage('Write last output buffer.');
       System.BlockWrite(gfOutStream,
                         System.Mem[System.Seg(glpOutBuf^):System.Ofs(glpOutBuf^)],
                         gdwOutBufOfs);
          END;
  {if-then}

  _ProgramOutputMessage('Done.');

  System.FreeMem(glpInEvenBuf,aMaxInBufSize);
  System.FreeMem(glpInOddBuf,aMaxInBufSize);
  System.FreeMem(glpOutBuf,aMaxOutBufSize);

  System.Close(gfInStreamEven);
  System.Close(gfInStreamOdd);
  System.Close(gfOutStream);

  {* System.Halt(errTerminateOk); *}
END.
