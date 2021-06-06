{****************************************************************************
//                            File FILE2BIN.PAS
//
//                    Get binary portion from file
//
//      Copyright (c) 1992, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/FILE2BIN/RCS/file2bin.pas $
//  $RCSfile: file2bin.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:40:01 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: file2bin.pas $
//      Revision 1.1  1998/10/03 14:40:01  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                FILE_TO_BIN_COPY                                }
{ FILE NAME             FILE2BIN.PAS                                    }
{ PURPOSE               Extract the file portion to binary image        }
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
{ ARGUMENTS             <infile>   -  input  stream                     }
{                       <outfile>  -  output stream                     }
{                       <filepos>  -  offset in input file              }
{                       <count>    -  # of bytes to copy                }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           1. Seek <filepos> in input file                 }
{                       2. Copy <count> bytes from input to output      }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   04-Jan-92  DS  initilal release          }
{                       1.01   05-Jan-92  DS  add documentation         }
{                       1.02   09-Jan-92  DS  some syntax corrections   }
{                       1.03   10-Jan-92  DS  changed r/w algorithms    }
{                       1.04   24-Jan-92  DS  some corrections          }
{                       1.10   25-Aug-92  DS  updated documentation     }
{                       1.20   08-Oct-92  DS  some style corrections    }
{                       1.21   27-Oct-92  DS  some corrections          }
{                       1.22   04-Nov-92  DS  some updates              }
{                       1.23   07-Apr-93  DS  some corrections          }
{                       1.24   19-May-93  DS  some style updates        }
{                       1.25   04-Jul-93  DS  updated documentation     }
{                       1.30   28-Oct-93  DS  some style updates        }
{                       1.31   26-Jul-97  DS  updated documentation     }
{                       1.32   02-Aug-97  DS  removed tabs              }
{                       1.33   02-Sep-97  DS  fixed open r/o file bug   }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   ExtractFromFileToBinaryImage;


{*** other modules ***}
USES
  ShowTErr;


{** switches for compilation **}
{$S-}                   {*  stack checking  *}
{$R-}                   {*  range checking  *}
{$M 16384,65536,65536}  {*  memory allocation  *}


{*========================== CONSTANTS PART ============================*}

CONST

     asPurpose                  =       'File Smart Copy';
     asVersion                  =       '1.33';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1992, 1997';
     asProgram                  =       'File2bin';
     asProgramPrompt            =       asProgram+': ';
     asProgramU                 =       'FILE2BIN';

     { exit codes }
     errTerminateOK             =     0;
     errBadParmsNumber          =     1;
     errSourceNotFound          =     2;
     errDestDontWrite           =     3;
     errBadOffset               =     4;
     errBadSize                 =     5;
     errSrcOpenFailed           =     6;
     errDestCreateFailed        =     7;
     errSeekInSourceFailed      =     8;
     errZeroLengthFound         =     9;

     achNULL                    =     #0;
     achCR                      =     #13;

     achYes                     =     'Y';
     achNo                      =     'N';

     achHexPrefix               =     '$';
     achDosExtMark              =     '.';
     asInDefExt                 =     'exe';
     asOutDefExt                =     'bin';

     aPercent100                =     100;
     aHexRadix                  =     16;
     aMaxOnHeap                 =     65520;


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
    STR3        =       STRING[3];


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

    setHexChars        :  SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];
    gddBytesCountDone  :  System.Longint =  0;


{*=========================== VARIABLES PART ===========================*}

VAR

   gfInputStream    :   FILE;
   gsInFileName     :   STRING[80];

   gfOutputStream   :   FILE;
   gsOutFileName    :   STRING[80];

   gddOffsetInFile  :   System.Longint;
   gddByteCount     :   System.Longint;
   gddInFileSize    :   System.Longint;

   gdwMemBlockSize  :   System.Word;
   gdwBytesRead     :   System.Word;
   gpMemoryBlock    :   System.Pointer;

   giErrorCode      :   System.Integer;

   gsTempInput      :   STRING;
   gchInUser        :   System.Char;


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


FUNCTION  _fnsForceFileNameExt(sFileName, sDefExt : STRING) : STRING;
{* Add extension for filename if not present. *}
BEGIN
   IF (System.Pos(achDosExtMark,sFileName) = 0)
     THEN  sFileName := sFileName + achDosExtMark + sDefExt;
   {if-then}
  _fnsForceFileNameExt := sFileName;
END;
{ _fnsForceFileNameExt }


FUNCTION  _fnsUpcaseStr(sInput : STRING) : STRING;
{* Make all uppercase. *}
VAR
  dbIndex  :  System.BYTE;
  dbCount  :  System.BYTE;

BEGIN
  dbCount := System.Length(sInput);

  IF (dbCount <> 0)  THEN
    FOR dbIndex :=  1  TO  dbCount DO
      sInput[dbIndex] := System.Upcase(sInput[dbIndex]);
    {for-to-do}
  {if-then}

   _fnsUpcaseStr := sInput;
END; { _fnsUpcaseStr }


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


{*============================== MAIN PART =============================*}

BEGIN
  _CopyrightDisplay;

     IF (System.ParamCount <> 4) THEN
     BEGIN
          System.WriteLn(asProgramPrompt+'  screen help for you.');
          System.WriteLn('Usage: infile outfile offset size');
          System.WriteLn('  infile   -  source filename      (def. ext. = '+asInDefExt+')');
          System.WriteLn('  outfile  -  destination filename (def. ext. = '+asOutDefExt+')');
          System.WriteLn('  offset   -  offset in source');
          System.WriteLn('  size     -  number of bytes to transfer');
          System.WriteLn('  Numbers may be decimals, or hexadecimals (first symbol is ''$'' for hex.).');
          System.Halt(errBadParmsNumber);
     END; { if }


  {** copy the parameters from command line **}
  gsInFileName  := _fnsUpcaseStr(System.ParamStr(1));
  gsInFileName := _fnsForceFileNameExt(gsInFileName,asInDefExt);

  gsOutFileName := _fnsUpcaseStr(System.ParamStr(2));
  gsOutFileName := _fnsForceFileNameExt(gsOutFileName,asOutDefExt);


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


  {** read the following parameter = offset **}
  gsTempInput := System.ParamStr(3);
  gddOffsetInFile := _fnddGetNum(gsTempInput,giErrorCode);

  IF  (giErrorCode <> 0)  THEN
      BEGIN
        System.WriteLn(asProgramPrompt+'Bad offset parameter.');
        System.Halt(errBadOffset);
      END;
  {if-then}


  {** read the following parameter = size **}
  gsTempInput  := System.ParamStr(4);
  gddByteCount := _fnddGetNum(gsTempInput,giErrorCode);

  IF  (giErrorCode <> 0)  THEN
      BEGIN
        System.WriteLn(asProgramPrompt+'Bad size parameter.');
        System.Halt(errBadSize);
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
    System.WriteLn(asProgramPrompt+'Unable to open '+gsInFileName);
    System.Halt(errSrcOpenFailed);
  END;
  {if-then}


  {** find the wanted # of bytes **}
  IF  (System.FileSize(gfInputStream) < (gddOffsetInFile + gddByteCount))
    THEN  BEGIN
      gddByteCount := System.FileSize(gfInputStream) - gddOffsetInFile;
      System.WriteLn(asProgramPrompt+'Warning! Only partial copy...');
          END;
  {if-then}

  IF  (gddByteCount = 0) THEN
  BEGIN
    System.Close(gfInputStream);
    System.WriteLn(asProgramPrompt+'Zero found for bytes count.');
    System.Halt(errZeroLengthFound);
  END;
  {if-then}


  {** seek wanted position in file. **}
  IF  (System.FileSize(gfInputStream) <= gddOffsetInFile) THEN
  BEGIN
    System.Close(gfInputStream);
    System.WriteLn(asProgramPrompt+'Seek operation in source file failed.');
    System.Halt(errSeekInSourceFailed);
  END;
  {if-then}

  {$I-}
  System.Seek(gfInputStream,gddOffsetInFile);
  {$I+}


  {** create the destination file **}
  System.FileMode := 2; {read/write, compatibilty mode}
  System.Assign(gfOutputStream,gsOutFileName);
  {$I-}
  System.Rewrite(gfOutputStream,1);
  {$I+}

  IF  (System.IoResult <> 0) THEN
  BEGIN
    System.Close(gfInputStream);
    System.WriteLn(asProgramPrompt+'Unable to create '+gsOutFileName);
    System.Halt(errDestCreateFailed);
  END;
  {if-then}


  {** get memory on heap **}
  IF  (System.MaxAvail < aMaxOnHeap)
    THEN  gdwMemBlockSize := System.MaxAvail
    ELSE  gdwMemBlockSize := aMaxOnHeap;
  {if-then-else}
  System.GetMem(gpMemoryBlock,gdwMemBlockSize);
  gddInFileSize := gddByteCount;



  {** simple algorithm for buffered copy **}
  WHILE (gddByteCount <> 0) DO
  BEGIN
       IF  ((gddByteCount DIV gdwMemBlockSize) <> 0)
          THEN  gdwBytesRead := gdwMemBlockSize
          ELSE  gdwBytesRead := gddByteCount;
       {if-then-else}
       System.Inc(gddBytesCountDone,gdwBytesRead);

               System.WriteLn(asProgramPrompt+'Reading...');
               System.BlockRead(gfInputStream,
                                System.Mem[System.Seg(gpMemoryBlock^):System.Ofs(gpMemoryBlock^)],
                                gdwBytesRead,
                                gdwBytesRead);
               System.WriteLn(asProgramPrompt+'Writing...');
               System.BlockWrite(gfOutputStream,
                                 System.Mem[System.Seg(gpMemoryBlock^):System.Ofs(gpMemoryBlock^)],
                                 gdwBytesRead);
               System.Dec(gddByteCount,gdwBytesRead);
               System.Write(achCR+asProgramPrompt+'Completed ('+
               _fnsNumToStr3((gddBytesCountDone*aPercent100) DIV gddInFileSize)+'%)');
               System.WriteLn;
  END;
  {while-do}


  {** free memory on heap **}
  System.FreeMem(gpMemoryBlock,gdwMemBlockSize);


  {** close all files **}
  System.Close(gfInputStream);
  System.Close(gfOutputStream);


  {** report all done **}
  System.WriteLn(asProgramPrompt+'Done.');

  {* System.Halt(errTerminateOk); *}
END.

