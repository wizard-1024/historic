{****************************************************************************
//                            File SND2WAV.PAS
//
//            Convert raw sound data file to wave format file
//
//        Copyright (c) 1998 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/SND2WAV/RCS/snd2wav.pas $
//  $RCSfile: snd2wav.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:50:00 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: snd2wav.pas $
//      Revision 1.1  1998/10/03 14:50:00  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                SOUND_TO_WAV_FORMAT_CONVERT                     }
{ FILE NAME             SND2WAV.PAS                                     }
{ PURPOSE               Converts raw sound data to .WAV file            }
{ VERSION               1.01                                            }
{ DATE                  07-May-1998                                     }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Telephone: +007 (095) 944-6304                  }
{ INTERNET              wizard@radio-msu.net,dima@mccbn.ru,dstef@nsl.ru }
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
{                       <wavtype>  -  wavefile type                     }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           1. Builds WAV. file header based on suggested   }
{                          user type                                    }
{                       2. Add raw data from input file to output file  }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   26-Apr-98  DS  initilal release          }
{                       1.01   07-May-98  DS  added switch <wavtype>    }
{                                             minor fixes               }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   SoundRawToWavFmtFile;


{*** other modules ***}
USES
  ShowTErr;


{** switches for compilation **}
{$S-}                   {*  stack checking  *}
{$R-}                   {*  range checking  *}
{$M 16384,65536,65536}  {*  memory allocation  *}


{*========================== CONSTANTS PART ============================*}

CONST

     asPurpose                  =       'Convert .SND to .WAV';
     asVersion                  =       '1.01';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1998';
     asProgram                  =       'Snd2wav';
     asProgramPrompt            =       asProgram+': ';
     asProgramU                 =       'SND2WAV';

     { exit codes }
     errTerminateOK             =     0;
     errBadParmsNumber          =     1;
     errSourceNotFound          =     2;
     errDestDontWrite           =     3;
     errSrcOpenFailed           =     4;
     errDestCreateFailed        =     5;
     err16SamplesNotFound       =     6;

     achNULL                    =     #0;
     achCR                      =     #13;

     achYes                     =     'Y';
     achNo                      =     'N';

     achHexPrefix               =     '$';
     achDosExtMark              =     '.';
     asInDefExt                 =     'snd';
     asOutDefExt                =     'wav';
     asWavSamples16             =     '-16';

     aPercent100                =     100;
     aHexRadix                  =     16;
     aMaxOnHeap                 =     65520;

     aUnknown                   =     0;
     aBit16StereoPcm44          =     1;

{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
    STR3           =       STRING[3];
    FourCharCode   =       ARRAY[0..3] OF System.Char;

    TWavDataHeader   =       RECORD
        chRIFF           : FourCharCode; {00-03  "RIFF"    Identification block         }
        liSize           : Longint;      {04-07  ???       File size=header+data        }
        chWave           : FourCharCode; {08-11  "WAVE"    Identification block         }
        chFMT            : FourCharCode; {12-15  "fmt "    Identification block         }
        liSizeFmt        : Longint;      {16-19  16,0,0,0  Size of header to this point }
        dwFormatTag      : Word;         {20-21  1,0       1=PCM                        }
        dwChannels       : Word;         {22-23  1,0       1=Mono, 2=Stereo             }
        liSampleRate     : Longint;      {24-27  ???       Samples per second           }
        liAvgBytesPerSec : Longint;      {28-31  ???       Average Bytes per second     }
        dwBlockAlign     : Word;         {32-33  1,0       Block align                  }
        dwBitsperSample  : Word;         {34-35  16,0      Bits per sample (8,12,or 16) }
        chDat            : FourCharCode; {36-39  "data"    Marker to incoming data      }
        liSizedata       : Longint;      {40-43  ???       Size of the sample data      }
                             END;

{*====================== TYPED CONSTANTS PART ==========================*}

CONST

    setHexChars        :  SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];
    gddBytesCountDone  :  System.Longint =  0;
    g_dbWavType        :  System.Byte = aBit16StereoPcm44;


{*=========================== VARIABLES PART ===========================*}

VAR

   gfInputStream    :   FILE;
   gsInFileName     :   STRING[80];

   gfOutputStream   :   FILE;
   gsOutFileName    :   STRING[80];

   gddByteCount     :   System.Longint;
   gddInFileSize    :   System.Longint;

   gdwMemBlockSize  :   System.Word;
   gdwBytesRead     :   System.Word;
   gpMemoryBlock    :   System.Pointer;

   giErrorCode      :   System.Integer;

   gsTempInput      :   STRING;
   gchInUser        :   System.Char;
   g_dwTemp         :   System.Word;
   g_rTemp          :   System.real;
   g_WavOutHeader   :   TWavDataHeader;

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

     IF (System.ParamCount <> 3) THEN
     BEGIN
          System.WriteLn(asProgramPrompt+'  screen help for you.');
          System.WriteLn('Usage: infile outfile offset size');
          System.WriteLn('  infile   -  source filename      (def. ext. = '+asInDefExt+')');
          System.WriteLn('  outfile  -  destination filename (def. ext. = '+asOutDefExt+')');
          System.WriteLn('  '+asWavSamples16+'      -  16-bit sound samples');
          System.Halt(errBadParmsNumber);
     END; { if }


  {** copy the parameters from command line **}
  gsInFileName  := _fnsUpcaseStr(System.ParamStr(1));
  gsInFileName := _fnsForceFileNameExt(gsInFileName,asInDefExt);

  gsOutFileName := _fnsUpcaseStr(System.ParamStr(2));
  gsOutFileName := _fnsForceFileNameExt(gsOutFileName,asOutDefExt);


  IF  (System.ParamStr(3) <> asWavSamples16)
    THEN  BEGIN
      System.WriteLn(asProgramPrompt+'Sorry, this version supported only 16-bit samples.');
      System.Halt(err16SamplesNotFound);
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
  gddByteCount := FileSize(gfInputStream);
  WriteLn(asProgramPrompt+'Input file size = ',gddByteCount,' bytes.');
  gddInFileSize := gddByteCount;

  {** write .WAV file header **}
  IF  (g_dbWavType = aBit16StereoPcm44)
    THEN  WriteLn(asProgramPrompt+'Write .WAV file header (PCM,stereo,16-bit,44.1KHz).');
  {if-then}
  WITH  (g_WavOutHeader)  DO
  BEGIN
      chRIFF[0] := 'R';                     {Fill id}
      chRIFF[1] := 'I';
      chRIFF[2] := 'F';
      chRIFF[3] := 'F';
      liSize    := gddInFileSize + sizeof(TWavDataHeader)-
                   sizeof(chDat) - sizeof(liSizedata) ;  {Full hdr+data}
      chWave[0] := 'W';                     {Fill id}
      chWave[1] := 'A';
      chWave[2] := 'V';
      chWave[3] := 'E';
      chFMT[0]  := 'f';                     {Fill id}
      chFMT[1]  := 'm';
      chFMT[2]  := 't';
      chFMT[3]  := ' ';
      liSizeFmt := sizeof(chRIFF) + sizeof(liSize) + sizeof(chWave) +
                   sizeof(chFMT);           {=16}
      dwFormatTag := 1;                     {PCM}
      dwChannels := 2;                      {stereo}
      dwBitsperSample := 16;                {16 bits/sample}
      liSampleRate := 44100;                {44.1 KHz}
      dwBlockAlign := 2*dwChannels;
      liAvgBytesPerSec := liSampleRate * (dwBitsperSample DIV 8) * dwChannels;
      chDat[0] := 'd';                      {Fill id}
      chDat[1] := 'a';
      chDat[2] := 't';
      chDat[3] := 'a';
      liSizedata := gddInFileSize;          {Size of data}
  END;
  {with-do}
  System.BlockWrite(gfOutputStream, g_WavOutHeader, sizeof(g_WavOutHeader));

  {** simple algorithm for buffered copy **}
  WHILE (gddByteCount <> 0) DO
  BEGIN
       IF  ((gddByteCount DIV gdwMemBlockSize) <> 0)
          THEN  gdwBytesRead := gdwMemBlockSize
          ELSE  gdwBytesRead := gddByteCount;
       {if-then-else}
       System.Inc(gddBytesCountDone,gdwBytesRead);

               System.Write(achCR+asProgramPrompt+'R');
               System.BlockRead(gfInputStream,
                                System.Mem[System.Seg(gpMemoryBlock^):System.Ofs(gpMemoryBlock^)],
                                gdwBytesRead,
                                gdwBytesRead);
               System.Write(#8'W');
               System.BlockWrite(gfOutputStream,
                                 System.Mem[System.Seg(gpMemoryBlock^):System.Ofs(gpMemoryBlock^)],
                                 gdwBytesRead);
               System.Dec(gddByteCount,gdwBytesRead);
               g_rTemp := gddBytesCountDone;
               g_rTemp := (g_rTemp * aPercent100) / gddInFileSize;
               g_dwTemp := System.Round(g_rTemp);
               System.Write(' ('+ _fnsNumToStr3(g_dwTemp) +'%)');
  END;
  {while-do}
  System.WriteLn;


  {** free memory on heap **}
  System.FreeMem(gpMemoryBlock,gdwMemBlockSize);


  {** close all files **}
  System.Close(gfInputStream);
  System.Close(gfOutputStream);


  {** report all done **}
  System.WriteLn(asProgramPrompt+'Done.');

  {* System.Halt(errTerminateOk); *}
END.

