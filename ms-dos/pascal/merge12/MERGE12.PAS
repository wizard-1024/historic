{****************************************************************************
//                            File MERGE12.PAS
//
//                       Merge text pages to print
//
//      Copyright (c) 1992, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/MERGE12/RCS/merge12.pas $
//  $RCSfile: merge12.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:57:34 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: merge12.pas $
//      Revision 1.1  1998/10/03 14:57:34  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                MERGE_TEXT_PAGES                                }
{ FILE NAME             MERGE12.PAS                                     }
{ PURPOSE               MERGE ALREADY FORMATTED TEXT TO OUTPUT          }
{                       OF TWO PAGES ON ONE LIST                        }
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
{ COPYRIGHT NOTICE      Copyright (C) 1992, 1997  Dmitry Stefankov      }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,           }
{                       NOT FOR COMMERCIAL PURPOSE                      }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 6.0                        }
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             <infile>   -   input filename                   }
{                       <outfile>  -   output filename                  }
{                       <lines>    -   max. available lines on page if  }
{                                      form feed not encountered        }
{ RETURN                See error return codes definitions              }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           1.Read   input  stream                          }
{                       2.Format output stream                          }
{                       3.Write  output stream                          }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00  11-Dec-92  DS  initilal release           }
{                       1.01  28-Jan-93  DS  fixed a bug with last page }
{                       1.02  02-Feb-93  DS  fixed a bug with empty side}
{                       1.03  19-May-93  DS  some style updates         }
{                       1.04  02-Jul-93  DS  fixed partial last page    }
{                                            problem if right > left    }
{                       1.10  20-Sep-93  DS  some style updates         }
{                       1.11  26-Jul-97  DS  updated documentation      }
{                       1.12  02-Aug-97  DS  removed tabs               }
{                       1.13  02-Sep-97  DS  fixed open r/o file bug    }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM  MergeTwoPagesToFourPages;


{** switches for compilation **}
{$S-}             {*  stack checking               *}
{$R-}             {*  range checking               *}
{$X-}             {*  extended syntax              *}


{*** other modules ***}
USES
   ShowTErr;


{** debugging version **}
{***$DEFINE DebugVersion}


{*========================== CONSTANTS PART ============================*}

CONST
   { program descriptions }
     asPurpose                  =       'MERGE 1 to 2 Pages ';
     asMsgVersion               =       'Version ';
     asVersion                  =       '1.13';
     asAuthor                   =       'Dmitry Stefankov';
     asCopyright                =       'Copyright (c) 1992, 1997';
     asProgram                  =       'MERGE12';
     asProgramPrompt            =       asProgram+': ';


   { program exit codes }
     errTerminateOK             =     0;
     errBadParamStr             =     1;
     errSourceNotFound          =     2;
     errDestDontWrite           =     3;

   { Dos miscellaneous }
     achDosSwitch               =     '/';
     achUnixSwitch              =     '-';
     achCommentMark             =     '#';
     achDosEndFile              =     #$1A;
     aDosFileNameLength         =     13;

   { TP error codes }
     errOK                      =     0;

   { TP internal }
     aMaxOnHeap                 =     65520;
     aBytesInPara               =     16;

   { base numeric system }
     aHexRadix                  =     16;
     aMaxByteVal                =     255;
     achHexPrefix               =     '$';
     achHexSuffix               =     'h';

   { character constants }
     achNULL                    =     #0;
     achHTAB                    =     #9;
     achLF                      =     #10;
     achFF                      =     #12;
     achCR                      =     #13;
     achESC                     =     #27;
     achSPC                     =     #32;
     achBlank                   =     ' ';
     achColon                   =     ':';
     achComma                   =     ',';
     achSemiColon               =     ';';
     achPoint                   =     '.';
     achZERO                    =     '0';
     achNine                    =     '9';
     achUpperA                  =     'A';
     achUpperF                  =     'F';
     achLowerA                  =     'a';
     achLowerF                  =     'f';
     achDEL                     =     #127;

   { string constants }
     asBlankStr                 =       '';
     asSpaces2                  =       achBlank+achBlank;
     asSpaces4                  =       asSpaces2+asSpaces2;
     asSpaces6                  =       asSpaces4+asSpaces2;

   { character values for boolean switch }
     achSwitchON                =    '+';
     achSwitchOFF               =    '-';

   { user confirm }
     achUserWant                =     'Y';
     achUserDontWant            =     'N';

   { strings definitions }
     aMaxLinesPerPage           =      100;
     aMaxCharsPerLine           =      144;

   { buffers size }
     aMaxTextBufSize            =       32768;          { 32K    }
     aMaxOutBufSize             =       65520;          { 64K-16 }


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
    STR2        =       STRING[2];
    STR4        =       STRING[4];
    STR6        =       STRING[6];
    STR8        =       STRING[8];
    STR9        =       STRING[9];
    STR10       =       STRING[10];
    STR80       =       STRING[80];
    MAXSTR      =       STRING[aMaxCharsPerLine];


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

   gsInputFileName              :       STR80            =   asBlankStr;
   gsOutputFileName             :       STR80            =   asBlankStr;

   gbOneHalfOK                  :       System.Boolean   =   System.True;
   gbTwoHalfOK                  :       System.Boolean   =   System.False;
   gbFormFeedFound              :       System.Boolean   =   System.False;

   gdwBufOfs                    :       System.Word      =   0;

   gdwPageCount                 :       System.Word      =   0;
   gdwMaxLinesOnPage            :       System.Word      =   aMaxLinesPerPage;
   gdbLinesOnPage               :       System.Byte      =   64;
   gdbLineNum                   :       System.Byte      =   1;
   gdbLeftSideLastLineNum       :       System.Byte      =   0;
   gdbRightSideLastLineNum      :       System.Byte      =   0;
   gdbTabCols                   :       System.Byte      =   8;


{*=========================== VARIABLES PART ===========================*}

VAR

   gfInputStream                :       TEXT;
   gfInputStreamFileRec         :       FILE  ABSOLUTE  gfInputStream;
   gfOutputStream               :       FILE;

   gchLeftSideStrings           :       ARRAY[1..aMaxLinesPerPage]  OF  MAXSTR;
   gsTempInput                  :       STRING;
   glpOutBuf                    :       System.Pointer;
   giErrorCode                  :       System.Integer;
   gdbIndex                     :       System.Byte;
   gdbLargeInBuf                :       ARRAY[0..aMaxTextBufSize-1] OF System.Char;


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


FUNCTION  _fnsMakeLargeStr(sMain,sAdd : STRING) : STRING;
{* Concatenation of strings. *}
VAR
  dbIndex, dbCount :  System.Byte;

BEGIN
   dbCount := Length(sAdd);
   dbIndex := 1;
   WHILE  (dbCount <> 0) DO
   BEGIN
     sMain := sMain + sAdd[dbIndex];
     System.Inc(dbIndex);
     System.Dec(dbCount);
   END;
   {while-do}
  _fnsMakeLargeStr := sMain;
END;
{ _fnsMakeLargeStr }


FUNCTION  _fnsAddStringAndSpaces(sInput : STRING; aMaxLen : System.Byte) : STRING;
{* Add wanted # of spaces. *}
BEGIN
    WHILE  (System.Length(sInput) < aMaxLen) DO
       Insert(achSPC,sInput,System.Length(sInput)+1);
    {while-do}
    _fnsAddStringAndSpaces := sInput;
END;
{ _fnsAddStringAndSpaces }


FUNCTION  _fnsAddSpaces(dbSpaceNum : System.Byte) : STRING;
{* String must be contain only spaces. *}
VAR
  sTemp : STRING;

BEGIN
    IF (dbSpaceNum <> 0)
       THEN  System.FillChar(sTemp[1],System.Word(dbSpaceNum),achBlank);
    {if-then}

    sTemp[0] := System.Char(dbSpaceNum);
   _fnsAddSpaces := sTemp;
END; { _fnsAddSpaces }


FUNCTION  _fnsDeTabString(sInput: STRING) : STRING;
{* Replace the control chars. *}
VAR
  sUnTabStr :  STRING;
  dbIndex :  System.Byte;

BEGIN
    dbIndex := System.Pos(achHTAB,sInput);     { works also if empty string }

    {** replace all occurrences of tab mark to wanted # of spaces **}
      WHILE  (dbIndex <> 0) DO
      BEGIN
          System.Delete(sInput,dbIndex,1);
          sUnTabStr := _fnsAddSpaces(gdbTabCols-((dbIndex-1) MOD gdbTabCols));
          System.Insert(sUnTabStr,sInput,dbIndex);
          dbIndex := System.Pos(achHTAB,sInput);
      END;
      {while-do}
     _fnsDeTabString := sInput;
END; { _fnsDeTabString }


{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE  _InitLeftSideOnPage;
{* Init all lines on page. *}
VAR
  dbIndex : System.Byte;

BEGIN
  FOR  dbIndex := 1  TO  aMaxLinesPerPage  DO
     gchLeftSideStrings[dbIndex] := _fnsAddStringAndSpaces(asBlankStr,aMaxCharsPerLine);
  {for-to-do}
END;
{ _InitLeftSideOnPage }


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


PROCEDURE  _WriteCRLF_ToFile;
{* Writes a large string to file. *}
BEGIN
   _PutByteToOutFile(System.Byte(achCR));
   _PutByteToOutFile(System.Byte(achLF));
END;
{ _WriteCRLF_ToFile }


PROCEDURE  _WriteStrToFile(sOutput : STRING; bAddCRLF : System.Boolean);
{* Writes a large string to file. *}
VAR
  dbIndex  :  System.Byte;

BEGIN
   FOR  dbIndex := 1 TO System.Length(sOutput)  DO
       _PutByteToOutFile(System.Byte(sOutput[dbIndex]));
   {for-to-do}

   IF (bAddCRLF)
     THEN  _WriteCRLF_ToFile;
   {if-then}
END;
{ _WriteStrToFile }


PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+
                    asMsgVersion+
                    asVersion+
                    achComma+achBlank +
                    asCopyright+
                    asSpaces2+
                    asAuthor);
END;  { _CopyrightDisplay }


{*============================== MAIN PART =============================*}

BEGIN
    _CopyrightDisplay;

    IF (System.ParamCount < 2)
      THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Usage: '+ asProgram + ' infile outfile [maxlines]');
         System.Halt(errBadParamStr);
            END;
    {if-then}

    gsInputFileName  := System.ParamStr(1);
    gsOutputFileName := System.ParamStr(2);
    IF (System.ParamStr(3) <> asBlankStr)
      THEN BEGIN
             Val(System.ParamStr(3),gdwMaxLinesOnPage,giErrorCode);
           END;
    {if-then}

    {** source file exists? **}
    IF  NOT(_fnbFileExist(gfInputStreamFileRec,gsInputFileName)) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+'Unable to open file '+gsInputFileName);
      System.Halt(errSourceNotFound);
    END;
    {if-then}

    {** destination file present? **}
    IF (_fnbFileExist(gfOutputStream,gsOutputFileName)) THEN
    BEGIN
      System.Write(asProgramPrompt+'Output file '+gsOutputFileName+
                   ' already exists. Overwrite? (n/y): ');
      System.ReadLn(gsTempInput);
      IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achUserWant)
        THEN  System.Halt(errDestDontWrite);
      {if-then}
    END;
    {if-then}

    System.Assign(gfInputStream,gsInputFileName);
    System.Assign(gfOutputStream,gsOutputFileName);

    System.SetTextBuf(gfInputStream,gdbLargeInBuf);
    System.GetMem(glpOutBuf,aMaxOutBufSize);

    System.FileMode := $20;   {read, deny write on share}
    System.Reset(gfInputStream);
    System.FileMode := 2; {read/write, compatibilty mode}
    System.ReWrite(gfOutputStream,1);

    System.Write(achCR+asProgramPrompt+'Read Page ',gdwPageCount,asSpaces6);

    _InitLeftSideOnPage;

    WHILE  NOT(System.EOF(gfInputStream))  DO
    BEGIN
       System.ReadLn(gfInputStream,gsTempInput);
       gsTempInput := _fnsDeTabString(gsTempInput);
       gbFormFeedFound := (System.Pos(achFF,gsTempInput) <> 0);

       IF (gbTwoHalfOK)
         THEN  BEGIN
            IF  (gbFormFeedFound)
              THEN  BEGIN
                 IF  (gdbRightSideLastLineNum < gdbLeftSideLastLineNum)
                   THEN   gdbRightSideLastLineNum := gdbLeftSideLastLineNum;
                 {if-then}
                 FOR  gdbIndex :=  gdbLineNum  TO  gdbRightSideLastLineNum  DO
                 BEGIN
                   {$IFDEF DebugVersion}
                      System.Write(achCR+asProgramPrompt+'Write Line ',gdbIndex,asSpaces6);
                   {$ENDIF}
                    _WriteStrToFile(gchLeftSideStrings[gdbIndex],System.True);
                 END;
                 {for-to-do}
                _WriteStrToFile(achFF,System.False);
                 gbTwoHalfOK := System.False;
                 gbOneHalfOK := System.True;
                 gdbLineNum  := 1;
                 gdbLeftSideLastLineNum := 0;
                 gdbRightSideLastLineNum := 0;
                 System.Inc(gdwPageCount);
                 System.Write(achCR+asProgramPrompt+'Read Page ',gdwPageCount,asSpaces6);
                _InitLeftSideOnPage;
                    END
              ELSE BEGIN
                {$IFDEF DebugVersion}
                   System.Write(achCR+asProgramPrompt+'Write Line ',gdbLineNum,asSpaces6);
                {$ENDIF}
                System.Insert(asSpaces2,gsTempInput,1);
                _WriteStrToFile(gchLeftSideStrings[gdbLineNum],System.False);
                _WriteStrToFile(gsTempInput,System.True);
                System.Inc(gdbLineNum);
                IF (gdbLineNum  > gdwMaxLinesOnPage)
                  THEN  BEGIN
                     _WriteStrToFile(achFF,System.False);
                     gbTwoHalfOK := System.False;
                     gbOneHalfOK := System.True;
                     gdbLineNum  := 1;
                     gdbLeftSideLastLineNum := 0;
                     gdbRightSideLastLineNum := 0;
                     System.Inc(gdwPageCount);
                     System.Write(achCR+asProgramPrompt+'Read Page ',gdwPageCount,asSpaces6);
                     _InitLeftSideOnPage;
                        END;
                {if-then}
                   END;
            {if-then-else}
               END
         ELSE
         BEGIN
            IF  (gbFormFeedFound) 
              THEN  BEGIN
                  gbTwoHalfOK := System.True;
                  gbOneHalfOK := System.False;
                  gdbLineNum  := 1;
                  System.Write(achCR+asProgramPrompt+'Write Page ',gdwPageCount,asSpaces6);
                    END
              ELSE  BEGIN
               gchLeftSideStrings[gdbLineNum] := _fnsAddStringAndSpaces(gsTempInput,aMaxCharsPerLine);
               {$IFDEF DebugVersion}
                  System.Write(achCR+asProgramPrompt+'Read Line ',gdbLineNum,asSpaces6);
               {$ENDIF}
               gdbLeftSideLastLineNum := gdbLineNum;
               System.Inc(gdbLineNum);
               IF (gdbLineNum  > gdwMaxLinesOnPage)
                 THEN  BEGIN
                  gbTwoHalfOK := System.True;
                  gbOneHalfOK := System.False;
                  gdbLineNum  := 1;
                  System.Write(achCR+asProgramPrompt+'Write Page ',gdwPageCount,asSpaces6);
                       END;
               {if-then}
                    END;
            {if-then-else}
         END;
       {if-then-else}
    END;
    {while-do}

  {* some check for miscellaneous cituations for end of input stream *}

    IF  (gbTwoHalfOK)
      THEN  BEGIN
        IF (gdbRightSideLastLineNum < gdbLineNum)
          THEN  gdbRightSideLastLineNum := gdbLineNum;
        {if-then}
            END;
    {if-then}

    IF  (gdbRightSideLastLineNum > gdbLeftSideLastLineNum)
      THEN  gdbLeftSideLastLineNum := gdbRightSideLastLineNum;
    {if-then}

    IF  (gdbLeftSideLastLineNum <> 0)
        THEN  BEGIN
    IF  (gdbLineNum > gdbLeftSideLastLineNum)
      THEN  gdbLineNum := 1;
    {if-then}
    System.Write(achCR+asProgramPrompt+'Write Page ',gdwPageCount,asSpaces6);
    FOR  gdbIndex :=  gdbLineNum  TO  gdbLeftSideLastLineNum  DO
    BEGIN
     {$IFDEF DebugVersion}
        System.Write(achCR+asProgramPrompt+'Write Line ',gdbIndex,asSpaces6);
     {$ENDIF}
       _WriteStrToFile(gchLeftSideStrings[gdbIndex],System.True);
    END;
    {for-to-do}
             END;
    {if-then} 

    _WriteStrToFile(achFF,System.False);
    _WriteCRLF_ToFile;

    {* write a remainder in buffer to disk *}
    IF  (gdwBufOfs <> 0)
      THEN  System.BlockWrite(gfOutputStream,
                              System.Mem[System.Seg(glpOutBuf^):System.Ofs(glpOutBuf^)],
                              gdwBufOfs);
    {if-then}

    System.Close(gfInputStream);
    System.Close(gfOutputStream);

    System.FreeMem(glpOutBuf,aMaxOutBufSize);

    System.WriteLn;
    System.WriteLn(asProgramPrompt+'Pages 1-',gdwPageCount+1);
    System.WriteLn(asProgramPrompt+'Done.');

END.
