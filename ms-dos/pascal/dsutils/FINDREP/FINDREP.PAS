{****************************************************************************
//                            File FINDREP.PAS
//
//                 Find and replace strings in file
//
//      Copyright (c) 1992, 1998 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/FINDREP/RCS/findrep.pas $
//  $RCSfile: findrep.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:30:23 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: findrep.pas $
//      Revision 1.1  1998/10/03 14:30:23  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                FIND_AND_REPLACE                                }
{ FILE NAME             FINDREP.PAS                                     }
{ PURPOSE               Replaces any occurence of wanted string         }
{ VERSION               1.41                                            }
{ DATE                  09-May-1998                                     }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Telephone: +007 (095) 944-6304                  }
{ INTERNET              wizard@radio-msu.net,dima@mccbn.ru,dstef@nsl.ru }
{ COPYRIGHT NOTICE      Copyright (C) 1992, 1998  Dmitry Stefankov      }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,           }
{                       NOT FOR COMMERCIAL PURPOSE                      }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 7.0                        }
{                       (Borland International Inc.) or compatible      }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             <infile>     -  input  stream                   }
{                       <outfile>    -  output stream                   }
{                       <instr>      -  input string                    }
{                       <outstr>     -  output string                   }
{                       <query>      -  ask user for replace match      }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           1.Read input stream                             }
{                       2.Find match pattern                            }
{                       3.If found then replace to another string       }
{                       4.Write output stream                           }
{                       !!! IMPORTANT NOTE !!!                          }
{                       The old algorithm of searching has a so-called  }
{                       syndrom "wrong matching window to advance":     }
{                       if not full match found then instead undo to N-1}
{                       chars back, the earlier algorithm just ignores  }
{                       this case.                                      }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   22-Jan-92  DS  initilal release          }
{                       1.01   23-Jan-92  DS  added text format string, }
{                                             added documentation       }
{                       1.02   24-Jan-92  DS  some corrections          }
{                       1.03   17-Mar-92  DS  fixed a bug with hexformat}
{                       1.10   25-Aug-92  DS  updated documentation     }
{                       1.20   08-Oct-92  DS  some style corrections    }
{                       1.21   27-Oct-92  DS  some corrections          }
{                       1.22   04-Nov-92  DS  some updates              }
{                       1.23   23-Dec-92  DS  added empty string        }
{                                             as replace string         }
{                       1.24   16-Jan-93  DS  fixed a bug with hexadec. }
{                                             output                    }
{                       1.25   07-Apr-93  DS  some corrections          }
{                       1.26   24-May-93  DS  some style updates        }
{                       1.27   10-Jun-93  DS  fixed a bug with upcases  }
{                       1.28   05-Jul-93  DS  updated documentation     }
{                       1.29   09-Sep-93  DS  fixed an input stream EOF }
{                                             bug at buffer processong  }
{                       1.30   28-Oct-93  DS  some style updates        }
{                       1.31   28-Oct-96  DS  added filestamp retaining }
{                       1.32   26-Jul-97  DS  updated documentation     }
{                       1.33   02-Aug-97  DS  removed tabs              }
{                                             fixed a bug for input of  }
{                                             text string as parameter  }
{                       1.34   02-Sep-97  DS  fixed open r/o file bug   }
{                       1.40   04-Feb-98  DS  changed s/r algorithm     }
{                       1.41   09-May-98  DS  fix a file writing bug    }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   HexaDecimalFindAndReplaceFileUtility;


{*** other modules ***}
USES
    Dos, ShowTErr;


{** switches for compilation **}
{$S-}                       {*  stack checking     *}
{$R-}                       {*  range checking     *}
{$M 16384,131072,131072}    {*  memory allocation  *}
{$DEFINE   NewSRalgorithm}  {*  more better code   *}



{*========================== CONSTANTS PART ============================*}

CONST

     asPurpose                  =       'FindRep Utility';
     asVersion                  =       '1.41';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1992, 1998';
     asProgram                  =       'FindRep';
     asProgramPrompt            =       asProgram+': ';
     asProgramU                 =       'FINDREP';

     { exit codes }
     errOK                      =     0;
     errTerminateOK             =     0;
     errBadParmsNumber          =     1;
     errSourceNotFound          =     2;
     errDestDontWrite           =     3;
     errSameNames               =     4;
     errSrcOpenFailed           =     6;
     errDestCreateFailed        =     7;
     errBadInStr                =     8;
     errBadOutStr               =     9;
     errSrcReadFailed           =    10;
     errDestWriteFailed         =    11;

     achHexPrefix               =     '$';
     achDosExtMark              =     '.';
     asInDefExt                 =     'exe';
     asOutDefExt                =     'exe';

     aPercent100                =     100;
     aHexRadix                  =     16;
     aMaxOnHeap                 =     65520;
     aUNDO_BUF_SIZ              =     256;

     achNULL                    =     #0;
     achHTAB                    =     #9;
     achSkip                    =     '.';
     achUserWant                =     'Y';
     achUserDontWant            =     'N';


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE

    STR2        =       STRING[2];
    STR4        =       STRING[4];
    STR8        =       STRING[8];


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

     setHexChars  :    SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];

     galiMatchCount       :       System.Longint      =  0;
     galiReplaceCount     :       System.Longint      =  0;
     gabUserAskToReplace  :       System.Boolean      =  System.False;
     gabFileToReplace     :       System.Boolean      =  System.True;
     gabUserAskToDisplay  :       System.Boolean      =  System.False;


{*=========================== VARIABLES PART ===========================*}

VAR

   gfInputStream        :       FILE;
   gsInFileName         :       STRING[80];

   gfOutputStream       :       FILE;
   gsOutFileName        :       STRING[80];

   gddInFileTimeDate    :       System.Longint;
   gddInOffsetInFile    :       System.Longint;
   gddInByteCount       :       System.Longint;
   gddTotalFileBytes    :       System.Longint;


   gdwInBytesRead       :       System.Word;
   gdwInBytesReadAdd    :       System.Word;
   gdwInBytesReadTest   :       System.Word;
   gdwOutBytesWritten   :       System.Word;

   g_ddMatchOffsInFile  :       System.Longint;
   g_lpSrchPattern      :       System.Pointer;
   g_lpReplacePattern   :       System.Pointer;
   g_lpBufPos           :       System.Pointer;
   g_dwCurBufPos        :       System.Word;
   g_dwMaxBufPos        :       System.Word;
   g_dwFullBufSiz       :       System.Word;
   g_dwFoundBufPos      :       System.Word;
   g_dwMatchLen         :       System.Word;
   g_dwReplaceLen       :       System.Word;
   g_dwNextReadPos      :       System.Word;

   gpInMemoryBlock      :       System.Pointer;
   gdwInMemBlockSize    :       System.Word;
   gpOutMemoryBlock     :       System.Pointer;
   gdwOutMemBlockSize   :       System.Word;


   giErrorCode          :       System.Integer;

   gsTempInput          :       STRING;
   gsInSearch           :       STRING;
   gsOutReplace         :       STRING;
   gchInUser            :       System.Char;
   g_bReplaceMake       :       System.Boolean;


{*=========================== FUNCTIONAL PART ==========================*}

FUNCTION  _fndbHexCharToBin(chIn: System.Char) : System.Byte; assembler;
{* Converts hexadecimal char to binary. *}
asm
        mov   al,chIn        { AL = chIn }
        sub   al,'0'         { AL <- AL - '0' }

        cmp   al,9           { test for digit }
        jbe   @Done

        and   al,11011111b   { make uppercase }
        sub   al,'A'-'9'-1   { AL = 'A'..'F' }

      @Done:
                             { AL = function result }
END;
  {asm-end}
{ _fndbHexCharToBin }


FUNCTION  _fnsUpcaseStr(sInput : STRING) : STRING;
{* Make all uppercase. *}
VAR
  dbIndex  :  System.BYTE;
  dbCount  :  System.BYTE;

BEGIN
  dbCount := System.Length(sInput);

  IF (dbCount <> 0)
    THEN  FOR  dbIndex :=  1  TO  dbCount  DO
            sInput[dbIndex] := System.Upcase(sInput[dbIndex]);
          {for-to-do}
  {if-then}

   _fnsUpcaseStr := sInput;
END; { _fnsUpcaseStr }


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
  {$I-} System.Reset(fStruc); {$I+}

  {** copy the result of last I/O operation **}
  bResult := (System.IOResult = 0);

  IF (bResult)
    THEN  System.Close(fStruc);
  {if-then}

  {Restore defaults}
  dbOldFileMode := System.FileMode;

  _fnbFileExist := bResult;
END; { _fnbFileExist }


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

FUNCTION   _fndwSearchBuf(lpBuffer : pointer; dwBufferLen : word;
                          lpMatch : pointer; dwMatchLen : word) : word; ASSEMBLER;
{* Search through Buffer for Match, returns the number bytes searched
   to find Match, 0FFFFh(-1) if not found. *}
ASM
             push      ds                   {save DS}
             cld                            {forward direction}
             les       di,lpBuffer          {ES:DI => buffer}
             mov       bx,di                {BX = Ofs(Buffer)}
             mov       cx,dwBufferLen       {CX = area to search}
             mov       dx,dwMatchLen        {DX = len of match string}
             test      dx,dx                {null length?}
             jz       @SearchErr            {if so, we're done}
             lds       si,lpMatch           {DS:DI => match buffer}
             lodsb                          {AL = Match[1],DS:SI => next char}
             dec       dx                   {DX = MatchLen - 1}
             sub       cx,dx                {CX = BufLen - MatchLen + 1}
             jbe      @SearchErr            {error if BufLen is less}
  @Next:
             repne     scasb                {search for Match[1]}
             jne      @SearchErr            {done if not found}
             test      dx,dx                {if length = 1 (DX = 0)}
             jz       @Found                {the "string" was found}
             push      cx                   {save CX}
             push      di                   {save DI}
             push      si                   {save SI}
             mov       cx,dx                {CX = Length(Match) - 1}
             repe      cmpsb                {does rest string match}
             pop       si                   {recover registers}
             pop       di
             pop       cx
             jne      @Next                 {try again if no match}
  @Found:
             dec       di                   {DI = offset where end}
             mov       ax,di                {prepare to subtract}
             sub       ax,bx                {subtract starting offset}
             jmp      @Done                 {done}
  @SearchErr:
             mov       ax,0FFFFh            {return -1}
  @Done:
             pop       ds                   {restore Turbo environment}
END;
{asm-end}
{ _fndwSearchBuf }


{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+
                    '  Version '+
                    asVersion+
                    ', '+
                    asCopyright+
                    '   '+
                    asAuthor);
END;  { _CopyrightDisplay }


PROCEDURE  _TranslateStr(sInput         :  STRING;
                               VAR sOutput    :  STRING;
                               VAR iErrorCode :  System.Integer);
{* Convert the string from hex/text format to char representation. *}
VAR
  dbIndex    :  System.BYTE;
  dbCount    :  System.BYTE;
  bFormatOk  :  System.Boolean;

BEGIN
  {* set initial values *}
      dbCount    := 0;
  IF  (System.Length(sInput) = 0)
    THEN  BEGIN
      sOutput[0] := System.Char(dbCount);
      iErrorCode := 0;
          END
    ELSE  BEGIN
      bFormatOk  := System.True;
      iErrorCode := -1;
      dbIndex    := 1;
          END;

  IF  (sInput[dbIndex] = achHexPrefix) THEN
    BEGIN

     IF (System.Length(sInput) >= 2) AND (sInput[dbIndex+1] = achHexPrefix)
     THEN
         BEGIN
              {* just a copy text string but skip 1st 2 chars *}
                sOutput := sInput;
                System.Delete(sOutput,1,2);
                iErrorCode := 0;
         END
     ELSE
      BEGIN
      {* skip a ID char *}
      System.Inc(dbIndex);

      {* test for valid count of chars *}
      IF  NOT(System.Odd(System.Length(sInput)))
         THEN  bFormatOk := System.False;
      {if-then}

      WHILE (bFormatOk) AND (dbIndex <= System.Length(sInput))  DO
      BEGIN
        IF  (sInput[dbIndex] IN setHexChars)
        THEN
          BEGIN
             {* byte is constructed from 2 chars *}
             IF  System.ODD(dbIndex)  THEN
                BEGIN
                  {* Note: counter is used also as index *}
                  System.Inc(dbCount);
                  sOutput[dbCount] := System.Char((_fndbHexCharToBin(sInput[dbIndex-1]) SHL 4)
                                       + _fndbHexCharToBin(sInput[dbIndex]));
                END;
             {if-then}

             {* try next char* }
             System.Inc(dbIndex);
          END
        ELSE
          bFormatOK := System.False;
     {if-then-else}
      END;
      {while-do}
      END;
      {if-else }
    END
    ELSE BEGIN
           {* just a copy text string *}
           sOutput := sInput;
           iErrorCode := 0;
         END;
    {if-then-else }

  IF (bFormatOK) AND (dbCount <> 0)
    THEN  BEGIN
      sOutput[0] := System.Char(dbCount);
      iErrorCode := 0;
          END;
  {if-then}
END; { _TranslateStr }


PROCEDURE  _ProcessBuffer(VAR fInFile        :   FILE;
                              pInMemBuf      :  System.Pointer;
                              dwInByteCount  :  System.Word;
                              dwInBufSize    :  System.Word;
                          VAR fOutFile       :  FILE;
                              pOutMemBuf     :  System.Pointer;
                              dwOutBufSize   :  System.Word;
                              sSearchInput   :  STRING;
                              sReplaceOutput :  STRING;
                          VAR dwAddBytesRW   :  System.Word);
{* Writes the contents of buffer with replacing if requires. *}
VAR
  sSaveBytes            :  STRING;
  ddMatchOffsetInFile   :  System.Longint;
  dwInBufOfs            :  System.Word;
  dwOutBufOfs           :  System.Word;
  dbIndex               :  System.Byte;
  dbCount               :  System.Byte;
  chInByte              :  System.Char;
  bMatch                :  System.Boolean;
  bReplaceMake          :  System.Boolean;
  bInFilePast           :  System.Boolean;


PROCEDURE _PutByteToOutput(VAR dwOutBufferOffset : System.Word; dbInPut : System.Byte);
{* Put a byte to buffer and write a buffer to disk if buffer is full. *}
BEGIN
  asm
        les     di, dwOutBufferOffset   { get a pointer to offset           }
        mov     ax, es:[di]             { fetch an offset                   }
        mov     di, [bp+4]              { Turbo calculation of pOutMemBuf   }
        les     di, ss:[di+12h]         { ES:DI <- Pointer to Output Buffer }
        add     di, ax                  { add an offset                     }
        mov     al, dbInPut             { get a putting value               }
        mov     es:[di], al             { write this byte                   }
  end;
  {*** The following PASCAL-code is functionally identical to the ASM-code **}
  {** System.Mem[System.Seg(pOutMemBuf^):System.Ofs(pOutMemBuf^)+dwOutBufferOffset] := dbInPut; **}
  System.Inc(dwOutBufferOffset);

  {* check is buffer full *}
  IF (dwOutBufferOffset = dwOutBufSize)
    THEN  BEGIN
             {$I-}
             System.BlockWrite(fOutFile,
                              System.Mem[System.Seg(pOutMemBuf^):System.Ofs(pOutMemBuf^)],
                              dwOutBufSize,
                              gdwOutBytesWritten);
             {$I+}
             IF (dwOutBufSize <> gdwOutBytesWritten)
                  THEN  BEGIN
                    System.WriteLn(asProgramPrompt+'Unable to write output file '+gsOutFileName);
                    System.Halt(errDestWriteFailed);
                        END;
              {if-then}
              dwOutBufferOffset := 0;
          END;
  {if-then}
END; { _PutByteToOutput }


PROCEDURE _GetByteFromInput(VAR dwInBufferOffset : System.Word;
                            VAR dbOut            : System.Char;
                            VAR dwInTotalCount   : System.Word;
                            VAR bInPast          : System.Boolean);
{* Get a byte from buffer and check for empty. *}
BEGIN
  {* check is buffer empty *}
  IF (dwInBufferOffset = dwInBufSize)
   THEN  BEGIN
             {* now we read only by one byte *}
             dwInBufSize := 1;
             {$I-}
             System.BlockRead(fInFile,
                              System.Mem[System.Seg(pInMemBuf^):System.Ofs(pInMemBuf^)],
                              dwInBufSize,
                              gdwInBytesReadTest);
             {$I+}
             {* special case: EOF detected *}
              IF (gdwInBytesReadTest = 0)
                THEN BEGIN
                       dwInBufSize      := 0;
                       bInPast          := System.True;
                       dwInBufferOffset := 0;
                       dwInTotalCount   := 1;
                     END
                ELSE
                  BEGIN
                    dwInBufferOffset := 0;
                    dwInTotalCount   := dwInBufSize;
                    System.Inc(dwAddBytesRW);
                  END;
              {if-then-else }
          END;
  {if-then}

   asm
         les    di, dwInBufferOffset    { get a pointer to offset          }
         mov    ax, es:[di]             { fetch an offset                  }
         mov    di, [bp+4]              { Turbo calculation of pInMemBuf   }
         les    di, ss:[di+1Eh]         { ES:DI <- Pointer to Input Buffer }
         add    di, ax                  { add offset in this buffer        }
         mov    al, es:[di]             { get a byte from this buffer      }
         les    di, dbOut               { get a pointer to byte variable   }
         mov    es:[di], al             { save a byte to a pointer         }
   end;
  {**** The following PASCAL-code is functionally identical to the ASM-code **
   dbOut := System.Char(System.Mem[System.Seg(pInMemBuf^):
                                    System.Ofs(pInMemBuf^)+dwInBufferOffset]);
   ****}
   System.Inc(dwInBufferOffset);
   System.Dec(dwInTotalCount);
   System.Inc(gddInOffsetInFile);
END; { _GetByteFromInput }


BEGIN
  {** initial values **}
  dwInBufOfs   := 0;
  dwOutBufOfs  := 0;
  dwAddBytesRW := 0;
  bInFilePast  := System.False;

  {** read/search&replace/write **}
  WHILE  (dwInByteCount <> 0) DO
  BEGIN
    _GetByteFromInput(dwInBufOfs,chInByte,dwInByteCount,bInFilePast);
    IF (chInByte <> sSearchInput[1])
    THEN  BEGIN
              IF (gabFileToReplace)
                THEN
                 _PutByteToOutput(dwOutBufOfs,System.Byte(chInByte));
              {if-then}
          END
    {* first match char found *}
    ELSE BEGIN
            {* initials *}
            bMatch  := System.True;
            dbIndex := 1;
            sSaveBytes[dbIndex] := chInByte;
            dbCount := System.Length(sSearchInput) - 1;
            ddMatchOffsetInFile := gddInOffsetInFile - 1;

            WHILE (bMatch) AND (dbCount <> 0) DO
            BEGIN
               _GetByteFromInput(dwInBufOfs,chInByte,dwInByteCount,bInFilePast);

               {* special case: EOF detected *}
               IF (bInFilePast)
                 THEN
                   bMatch := System.False
                 ELSE
                   BEGIN
                    System.Inc(dbIndex);
                    sSaveBytes[dbIndex] := chInByte;
                    bMatch  :=  (chInByte = sSearchInput[dbIndex]);
                    System.Dec(dbCount);
                   END;
               {if-then-else }

            END;
            {while-do}

            {* setup a string length *}
            sSaveBytes[0] := System.Char(dbIndex);

            IF  (bMatch)
              THEN BEGIN
                     System.Inc(galiMatchCount);
                     bReplaceMake := System.True;

                     IF  (gabUserAskToReplace OR gabUserAskToDisplay)  THEN
                     BEGIN
                         System.Write(asProgramPrompt+'Match found at offset '+achHexPrefix+
                                       +_fnsDoubleWordToHexFmt(ddMatchOffsetInFile)
                                       +'(',ddMatchOffsetInFile,
                                       +')');
                         IF (gabFileToReplace)
                           THEN
                             System.Write(' Replace? (n/y): ')
                           ELSE
                             System.WriteLn;
                         {if-then}
                         IF (gabFileToReplace)
                           THEN
                             System.ReadLn(gsTempInput)
                           ELSE
                             gsTempInput := achUserDontWant;
                         {if-then-else}
                         IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achUserWant)
                           THEN  bReplaceMake := System.False;
                         {if-then}
                     END;
                     {if-then}

                     IF  (bReplaceMake)
                         THEN
                           BEGIN
                              dbCount := System.Length(sReplaceOutput);
                              System.Inc(galiReplaceCount);
                              IF (dbCount <> 0) THEN
                                 FOR dbIndex := 1 TO  dbCount DO
                                    _PutByteToOutput(dwOutBufOfs,System.Byte(sReplaceOutput[dbIndex]));
                                 {for-to-do}
                              {if-then}
                           END
                         ELSE
                           BEGIN
                          {* no replacement *}
                             dbCount := System.Length(sSaveBytes);
                             FOR dbIndex := 1 TO  dbCount DO
                               IF (gabFileToReplace)  THEN
                                 _PutByteToOutput(dwOutBufOfs,System.Byte(sSaveBytes[dbIndex]));
                               {if-then}
                             {for-to-do}
                           END;
                     {if-then-else }
                   END
            ELSE BEGIN
                     {* just copy a saved bytes *}
                     dbCount := System.Length(sSaveBytes);
                     FOR  dbIndex := 1 TO  dbCount DO
                       IF (gabFileToReplace)  THEN
                            _PutByteToOutput(dwOutBufOfs,System.Byte(sSaveBytes[dbIndex]));
                       {if-then}
                     {for-to-do}
                   END;
            {if-then-else }
         END;
    {if-then-else }
  END;
  {while-do}

  {** output buffer is empty? **}
  IF (dwOutBufOfs <> 0)
    THEN  BEGIN
       IF (gabFileToReplace)
         THEN  BEGIN
             {$I-}
             System.BlockWrite(fOutFile,
                              System.Mem[System.Seg(pOutMemBuf^):System.Ofs(pOutMemBuf^)],
                              dwOutBufOfs,
                              gdwOutBytesWritten);
             {$I+}
             IF (dwOutBufOfs <> gdwOutBytesWritten)
                  THEN  BEGIN
                    System.WriteLn(asProgramPrompt+'Unable to write output file '+gsOutFileName);
                    System.Halt(errDestWriteFailed);
                        END;
              {if-then}
               END;
       {if-then}
          END;
  {if-then}
END;  { _ProcessBuffer }


{$IFDEF   NewSRalgorithm}
PROCEDURE  _WriteBuf2Dsk(VAR   fOutFile  :  FILE;
                         lpOutBuf        :  System.Pointer;
                         dwOutBufSiz     :  System.Word);
{* Writes buffer contents to disk file. *}
VAR
  dwOutBytesWritten : System.Word;
BEGIN
   IF  (gabFileToReplace)
     THEN  BEGIN
     {$I-}
     System.BlockWrite(fOutFile,
                      System.Mem[System.Seg(lpOutBuf^):System.Ofs(lpOutBuf^)],
                      dwOutBufSiz,
                      dwOutBytesWritten);
     {$I+}
     IF (dwOutBufSiz <> dwOutBytesWritten)
          THEN  BEGIN
            System.WriteLn(asProgramPrompt+'Unable to write output file '+gsOutFileName);
            System.Halt(errDestWriteFailed);
                END;
      {if-then}
           END;
   {if-then}
END;
{ _WriteBuf2Dsk }


PROCEDURE  _ReadDsk2Buf(VAR   fInFile  :  FILE;
                         lpInBuf        :  System.Pointer;
                         dwInBufSiz     :  System.Word);
{* Read a disk file into memory buffer. *}
VAR
  dwInBytesRead : System.Word;
BEGIN
      System.BlockRead(fInFile,
                       System.Mem[System.Seg(lpInBuf^):System.Ofs(lpInBuf^)],
                       dwInBufSiz,
                       dwInBytesRead);
      {$I+}
      IF (dwInBufSiz <> dwInBytesRead)
         THEN  BEGIN
           System.WriteLn(asProgramPrompt+' Unable to read input file '+gsInFileName);
           System.Halt(errSrcReadFailed);
               END;
      {if-then}
END;
{ _ReadDsk2Buf }
{$ENDIF   NewSRalgorithm}


{*============================== MAIN PART =============================*}

BEGIN
  _CopyrightDisplay;

     IF (System.ParamCount = 0) THEN
     BEGIN
          System.WriteLn(asProgramPrompt+' help screen for you.');
          System.WriteLn('Usage: infile outfile instr outstr [query]');
          System.WriteLn('  infile   -  source filename       (def. ext. = '+asInDefExt+')');
          System.WriteLn('  outfile  -  destination filename  (def. ext. = '+asOutDefExt+')');
          System.WriteLn('  instr    -  string for search     (the following formats are supported:');
          System.WriteLn('                                       text string (ext. ASCII)   = Hello');
          System.WriteLn('                                       hexadecimal format string  = $0A8D');
          System.WriteLn('                                       text string started with $ = $$world )');
          System.WriteLn('  outstr   -  new string            (see format above)');
          System.WriteLn('  query    -  optional, any string  (user ask for replace)');
          System.WriteLn('                                    (default = no ask)');
          System.Halt(errBadParmsNumber);
     END;
     {if-then}


  {** copy the parameters from command line **}
  gsInFileName  := _fnsUpcaseStr(System.ParamStr(1));
  gsInFileName := _fnsForceFileNameExt(gsInFileName,asInDefExt);

  IF (System.ParamCount > 1)
    THEN  BEGIN
       gsOutFileName := _fnsUpcaseStr(System.ParamStr(2));
       gsOutFileName := _fnsForceFileNameExt(gsOutFileName,asOutDefExt);
          END
    ELSE
      gabFileToReplace := System.False;
  {if-then-else}


  {* may be same names? *}
  IF (gabFileToReplace)
  THEN
    IF (gsInFileName = gsOutFileName)  THEN
    BEGIN
      System.WriteLn(asProgramPrompt+'Unable to use same file as input and as output');
      System.Halt(errSameNames);
    END;
    {if-then}
  {if-then}


  {** source file exists? **}
  IF  NOT(_fnbFileExist(gfInputStream,gsInFileName)) THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to open file '+gsInFileName);
    System.Halt(errSourceNotFound);
  END;
  {if-then}


  {** destination file present? **}
  IF (gabFileToReplace)
  THEN
    IF (_fnbFileExist(gfOutputStream,gsOutFileName)) THEN
    BEGIN
      System.Write(asProgramPrompt+'Output file '+gsOutFileName+
                   ' already exists. Overwrite? (n/y): ');
      System.ReadLn(gsTempInput);
      IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achUserWant)
        THEN  System.Halt(errDestDontWrite);
    END;
    {if-then}
  {if-then}


  {** read the following parameter = search string **}
  IF  (System.ParamCount >= 3)
  THEN
    gsTempInput := System.ParamStr(3)
  ELSE
    BEGIN
      System.Write(asProgramPrompt+'Enter search string: ');
      System.ReadLn(gsTempInput);
    END;
  {if-then-else }

  _TranslateStr(gsTempInput,gsInSearch,giErrorCode);
   IF  (giErrorCode <> 0)  THEN
     BEGIN
         System.WriteLn(asProgramPrompt+'Invalid format for input string.');
         System.Halt(errBadInStr);
     END;
   {if-then}



  {** read the following parameter = replace string **}
  IF (gabFileToReplace)
  THEN BEGIN
    IF  (System.ParamCount >= 4)
    THEN
      gsTempInput := System.ParamStr(4)
    ELSE
      BEGIN
        System.Write(asProgramPrompt+'Enter replace string: ');
        System.ReadLn(gsTempInput);
      END;
    {if-then-else }
   _TranslateStr(gsTempInput,gsOutReplace,giErrorCode);
    IF  (giErrorCode <> 0)
    THEN  BEGIN
             System.WriteLn(asProgramPrompt+' Invalid format for output string.');
             System.Halt(errBadOutStr);
          END;
    {if-then}
       END;
  {if-then}


  {** read the following parameter = query switch **}
  IF (gabFileToReplace)
  THEN
    IF  (System.ParamCount >= 5) THEN
    BEGIN
      gabUserAskToReplace := System.True;
    END;
    {if-then}
  {if-then}

  IF (gabFileToReplace)
  THEN BEGIN
    IF  (System.ParamCount < 4) THEN
    BEGIN
      System.Write(asProgramPrompt+'Replace by asking? (n/y): ');
      System.ReadLn(gsTempInput);
      IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) = achUserWant)
         THEN  gabUserAskToReplace := System.True;
      {if-then}
    END
       END
    {if-then}
  ELSE BEGIN
      System.Write(asProgramPrompt+'Display offset? (n/y): ');
      System.ReadLn(gsTempInput);
      IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) = achUserWant)
         THEN  gabUserAskToDisplay := System.True;
      {if-then}
       END;
  {if-then-else}


  {** open the source file **}
  System.FileMode := $20;   {read, deny write on share}
  System.Assign(gfInputStream,gsInFileName);
  {$I-}
  System.Reset(gfInputStream,1);
  {$I+}

  IF  (System.IoResult <> errOK) THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to open '+gsInFileName);
    System.Halt(errSrcOpenFailed);
  END;
  {if-then}

  {** store filestamp **}
  Dos.GetFTime( gfInputStream,gddInFileTimeDate );

  {** create the destination file **}
  IF (gabFileToReplace)
  THEN  BEGIN
    System.FileMode := 2; {read/write, compatibilty mode}
    System.Assign(gfOutputStream,gsOutFileName);
    {$I-}
    System.Rewrite(gfOutputStream,1);
    {$I+}

    IF  (System.IoResult <> errOK) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+'Unable to create '+gsOutFileName);
      System.Halt(errDestCreateFailed);
    END;
    {if-then}
        END;
  {if-then}

  {** get a count of bytes to read. **}
  gddInByteCount := System.FileSize(gfInputStream);
  gddTotalFileBytes := gddInByteCount;

  {** global  var to indicate offset for user **}
  gddInOffsetInFile := 0;


  {** get memory on heap for input stream **}
  IF  (System.MaxAvail < aMaxOnHeap)
    THEN  gdwInMemBlockSize := System.MaxAvail
    ELSE  gdwInMemBlockSize := aMaxOnHeap;
  {if-then-else}
  System.GetMem(gpInMemoryBlock,gdwInMemBlockSize);

{$IFNDEF   NewSRalgorithm}
  {** get memory on heap output stream **}
  IF  (System.MaxAvail < aMaxOnHeap)
    THEN  gdwOutMemBlockSize := System.MaxAvail
    ELSE  gdwOutMemBlockSize := aMaxOnHeap;
  {if-then-else}
  System.GetMem(gpOutMemoryBlock,gdwOutMemBlockSize);
{$ENDIF   NewSRalgorithm}


{$IFDEF   NewSRalgorithm}
  g_dwMatchLen   := System.Length(gsInSearch);
  g_dwReplaceLen := System.Length(gsOutReplace);
  g_lpSrchPattern    := System.Ptr( System.Seg(gsInSearch[1]),
                                    System.Ofs(gsInSearch[1]) );
  g_lpReplacePattern := System.Ptr( System.Seg(gsOutReplace[1]),
                                    System.Ofs(gsOutReplace[1]) );

  WHILE (gddInByteCount <> 0) DO
  BEGIN
      IF  ((gddInByteCount DIV gdwInMemBlockSize) <> 0)
        THEN  BEGIN
           gdwInBytesRead :=  gdwInMemBlockSize;
           g_dwFullBufSiz := gdwInBytesRead;
           g_dwMaxBufPos := g_dwFullBufSiz - aUNDO_BUF_SIZ;
              END
        ELSE  BEGIN
           gdwInBytesRead :=  gddInByteCount;
           g_dwFullBufSiz := gdwInBytesRead;
           g_dwMaxBufPos := g_dwFullBufSiz;
              END;
      {if-then-else}

      System.WriteLn(asProgramPrompt+'Reading......');
      _ReadDsk2Buf(gfInputStream, gpInMemoryBlock, gdwInBytesRead);

      System.WriteLn(asProgramPrompt+'Processing...');
      g_dwCurBufPos := 0;
      g_dwNextReadPos := g_dwMaxBufPos;
      g_lpBufPos := System.Ptr(Seg(gpInMemoryBlock^),
                               Ofs(gpInMemoryBlock^)+g_dwCurBufPos);
      g_dwFoundBufPos := _fndwSearchBuf(g_lpBufPos,g_dwFullBufSiz,
                                        g_lpSrchPattern,g_dwMatchLen);

      WHILE  (g_dwFoundBufPos < g_dwMaxBufPos) DO
      BEGIN
         {-write bytes before found matching pattern-}
         _WriteBuf2Dsk( gfOutputStream, g_lpBufPos, g_dwFoundBufPos);
         System.Inc(galiMatchCount);
         g_bReplaceMake := System.True;
         g_ddMatchOffsInFile := gddInOffsetInFile+g_dwCurBufPos+g_dwFoundBufPos;

         IF  (gabUserAskToReplace OR gabUserAskToDisplay)  THEN
         BEGIN
             System.Write(asProgramPrompt+'Match found at offset '+achHexPrefix+
                           +_fnsDoubleWordToHexFmt(g_ddMatchOffsInFile)
                           +'(',g_ddMatchOffsInFile,
                           +')');
             IF (gabFileToReplace)
               THEN
                 System.Write(' Replace? (n/y): ')
               ELSE
                 System.WriteLn;
             {if-then}
             IF (gabFileToReplace)
               THEN
                 System.ReadLn(gsTempInput)
               ELSE
                 gsTempInput := achUserDontWant;
             {if-then-else}
             IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achUserWant)
               THEN  g_bReplaceMake := System.False;
             {if-then}
         END;
         {if-then}

         IF  (g_bReplaceMake)
             THEN
               BEGIN
                  System.Inc(galiReplaceCount);
                  _WriteBuf2Dsk( gfOutputStream,
                                 g_lpReplacePattern,
                                 g_dwReplaceLen );
               END
             ELSE
               BEGIN
              {* no replacement *}
                  _WriteBuf2Dsk( gfOutputStream,
                                 g_lpSrchPattern,
                                 g_dwMatchLen);
               END;
         {if-then-else }

         System.Inc(g_dwCurBufPos, g_dwFoundBufPos + g_dwMatchLen);
         g_lpBufPos := System.Ptr(Seg(gpInMemoryBlock^),
                                  Ofs(gpInMemoryBlock^)+g_dwCurBufPos);
         IF  ( g_dwCurBufPos >= g_dwMaxBufPos )
           THEN  BEGIN
              g_dwFoundBufPos := $FFFF;  {Terminate!}
              g_dwNextReadPos := g_dwCurBufPos;
                 END
           ELSE  BEGIN
              g_dwFoundBufPos := _fndwSearchBuf(g_lpBufPos,
                                                g_dwFullBufSiz-g_dwCurBufPos,
                                                g_lpSrchPattern,
                                                g_dwMatchLen);
                 END;
         {if-then-else}
      END;
      {while-do}

      IF (g_dwCurBufPos < g_dwNextReadPos)
        THEN  BEGIN
           g_lpBufPos := System.Ptr(Seg(gpInMemoryBlock^),
                                    Ofs(gpInMemoryBlock^)+g_dwCurBufPos);
           _WriteBuf2Dsk( gfOutputStream, g_lpBufPos,
                          g_dwNextReadPos-g_dwCurBufPos );
              END;
      {if-then}
      System.Inc(gddInOffsetInFile,g_dwNextReadPos);
      System.Seek(gfInputStream,gddInOffsetInFile);
      System.Dec(gddInByteCount,g_dwNextReadPos);
      System.WriteLn(asProgramPrompt+'Completed (',System.Trunc(((gddTotalFileBytes-gddInByteCount)
                     /gddTotalFileBytes)*aPercent100),'%)');
  END;
  {while-do}
{$ELSE}
  {** main loop: read_buffer/process_buffer **}
  WHILE (gddInByteCount <> 0) DO
  BEGIN
      IF  ((gddInByteCount DIV gdwInMemBlockSize) <> 0)
        THEN  gdwInBytesRead :=  gdwInMemBlockSize
        ELSE  gdwInBytesRead :=  gddInByteCount;
      {if-then-else}

          BEGIN
               System.WriteLn(asProgramPrompt+'Reading......');
               {$I-}
               System.BlockRead(gfInputStream,
                                System.Mem[System.Seg(gpInMemoryBlock^):System.Ofs(gpInMemoryBlock^)],
                                gdwInBytesRead,
                                gdwInBytesReadTest);
               {$I+}
               IF (gdwInBytesRead <> gdwInBytesReadTest)
                  THEN  BEGIN
                    System.WriteLn(asProgramPrompt+' Unable to read input file '+gsInFileName);
                    System.Halt(errSrcReadFailed);
                        END;
               {if-then}
               System.WriteLn(asProgramPrompt+'Processing...');
               _ProcessBuffer(gfInputStream, gpInMemoryBlock, gdwInBytesRead,gdwInBytesRead,
                              gfOutputStream,gpOutMemoryBlock,gdwOutMemBlockSize,
                              gsInSearch,gsOutReplace,gdwInBytesReadAdd);
               System.Dec(gddInByteCount,gdwInBytesRead+gdwInBytesReadAdd);
               System.WriteLn(asProgramPrompt+'Completed (',System.Trunc(((gddTotalFileBytes-gddInByteCount)
                              /gddTotalFileBytes)*aPercent100),'%)');

          END;
  END;
  {while-do}
{$ENDIF   NewSRalgorithm}


  {** close all files **}
  System.Close(gfInputStream);
  IF (gabFileToReplace)
    THEN  BEGIN
      {** restore filestamp **}
      Dos.SetFTime( gfOutputStream,gddInFileTimeDate );
      System.Close(gfOutputStream);
          END;
  {if-then}


  {** free memory on heap **}
  System.FreeMem(gpInMemoryBlock,gdwInMemBlockSize);
{$IFNDEF   NewSRalgorithm}
  System.FreeMem(gpOutMemoryBlock,gdwOutMemBlockSize);
{$ENDIF   NewSRalgorithm}


  {** put newline char and write report**}
  System.Write(asProgramPrompt+'Matches found = ',galiMatchCount);
  IF (gabFileToReplace)
  THEN
     System.WriteLn(',  Replaces made = ',galiReplaceCount)
  ELSE
     System.WriteLn;
  {if-then-else}
  System.WriteLn(asProgramPrompt+'Done.');

  {* System.Halt(errTerminateOk); *}
END.
