{****************************************************************************
//                            File LC.PAS
//
//                  Lines count for text files
//
//      Copyright (c) 1994, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/LC/RCS/lc.pas $
//  $RCSfile: lc.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:44:02 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: lc.pas $
//      Revision 1.1  1998/10/03 14:44:02  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                SOURCE_CODE_PROCESS                             }
{ FILE NAME             LC.PAS                                          }
{ PURPOSE               Text File Line Counter                          }
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
{ COPYRIGHT NOTICE      Copyright (C) 1993, 1997  Dmitry Stefankov      }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,           }
{                       NOT FOR COMMERCIAL PURPOSE                      }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 7.0                        }
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             <where> - drive/path/files                      }
{ RETURN                See error return codes definitions              }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           1. Read Directory entry                         }
{                       2. Find matching file                           }
{                       3. Count lines in this file                     }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00  28-Jan-94  DS  initilal release           }
{                       1.01  26-Jul-97  DS  updated documentation      }
{                       1.02  02-Aug-97  DS  removed tabs               }
{                       1.03  02-Sep-97  DS  fixed open r/o file bug    }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM  TextFilesLineCount;


{*** other modules ***}
USES
     Dos, ShowTErr;

{** switches for compilation **}
{$S-}             {*  stack checking               *}
{$R-}             {*  range checking               *}


{** debugging version **}
{***$DEFINE DebugVersion}


{*========================== CONSTANTS PART ============================*}

CONST
   { program descriptions }
     asPurpose                  =       'DOS Line Count';
     asMsgVersion               =       'Version ';
     asVersion                  =       '1.03';
     asAuthor                   =       'Dmitry Stefankov';
     asCopyright                =       'Copyright (c) 1994, 1997';
     asProgram                  =       'LC';
     asProgramPrompt            =       asProgram+': ';
     asProgramU                 =       'LC';


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


   { base numeric system }
     aHexRadix                  =     16;
     aMaxByteVal                =     255;
     achHexPrefix               =     '$';
     achHexSuffix               =     'h';
     aPercent100                =     100;

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


   { user confirm }
     achUserWant                =     'Y';
     achUserDontWant            =     'N';

   { strings definitions }

   { buffers size }
     aMaxTextBufSize            =       16384;          { 16K  }


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
    STR2        =       STRING[2];
    STR3        =       STRING[3];
    STR4        =       STRING[4];
    STR6        =       STRING[6];
    STR8        =       STRING[8];
    STR9        =       STRING[9];
    STR10       =       STRING[10];
    STR80       =       STRING[80];


{*====================== TYPED CONSTANTS PART ==========================*}

CONST
   gsInputSearchPath            :       STR80            =   '.\';
   gliLineCountTotal            :       System.Longint   =   0;
   gliLineCountEmpty            :       System.Longint   =   0;
   gliFilesFoundCount           :       System.Longint   =   0;
   gdwSearchFileAttr            :       System.Word = AnyFile;

{*=========================== VARIABLES PART ===========================*}

VAR
   gsTempInput                  :       STRING;
   giErrorCode                  :       System.Integer;
   gdbIndex                     :       System.Byte;
   gdbInputTextBuf              :       ARRAY[1..aMaxTextBufSize] OF System.Byte;


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
     System.WriteLn(asPurpose+
                    achBlank+
                    asMsgVersion+
                    asVersion+
                    achComma+achBlank +
                    asCopyright+
                    asSpaces2+
                    asAuthor);
END;  { _CopyrightDisplay }


PROCEDURE  _ProcessFile(sInputFileName : STR80);
{* Do a line count for a selected file. *}
VAR
   fInputStream                :       TEXT;
   fInputStreamRec             :       FILE ABSOLUTE fInputStream;
   liFileLineCountTotal        :       System.LongInt;
   liFileLineCountEmpty        :       System.LongInt;
   sTemp                       :       STRING;

BEGIN
    {** source file exists? **}
    IF  NOT(_fnbFileExist(fInputStreamRec,sInputFileName)) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+'Unable to open file '+sInputFileName);
      System.Halt(errSourceNotFound);
    END;
    {if-then}

    {* open input stream *}
      System.FileMode := $20;   {read, deny write on share}
      System.Assign(fInputStream,sInputFileName);
      System.SetTextBuf(fInputStream,gdbInputTextBuf);
      System.Reset(fInputStream);

    {* main process *}
      liFileLineCountTotal := 0;
      liFileLineCountEmpty := 0;

      WHILE  NOT(System.Eof(fInputStream)) DO
      BEGIN
         System.ReadLn(fInputStream,sTemp);
         System.Inc(liFileLineCountTotal);
         IF (sTemp = asBlankStr)
           THEN  System.Inc(liFileLineCountEmpty);
         {if-then}
      END;
      {while-do}

    {* close all streams *}
      System.Close(fInputStream);

    {* print a statistics *}
      System.WriteLn(asProgramPrompt+'----- File Statistics -----');
      System.WriteLn(asProgramPrompt+'Source File: '+sInputFileName);
      System.WriteLn(asProgramPrompt+'Total Lines: ',liFileLineCountTotal);
      System.WriteLn(asProgramPrompt+'Empty Lines: ',liFileLineCountEmpty);
      System.WriteLn(asProgramPrompt+'Percentage:  ',
                     ((liFileLineCountEmpty*aPercent100) DIV liFileLineCountTotal),
                     '%');

    {* do a global statatistics *}
       System.Inc(gliFilesFoundCount);
       System.Inc(gliLineCountTotal,liFileLineCountTotal);
       System.Inc(gliLineCountEmpty,liFileLineCountEmpty);

END;
{ _ProcessFile }


PROCEDURE  _SearchDir(sSearchSpec  :  STRING;
                      dwFileAttr   :  System.Word);
{* Do a search the selected files in the selected catalog. *}
VAR
  recDirInfo  : Dos.SearchRec;

BEGIN
   Dos.FindFirst(sSearchSpec, dwFileAttr, recDirInfo);
   WHILE  (Dos.DosError = 0) DO
   BEGIN
      IF ((recDirInfo.Attr AND (Directory+VolumeID)) = 0)
        THEN  _ProcessFile(recDirInfo.Name);
      {if-then}
      Dos.FindNext(recDirInfo);
  END;
  {while-do}
END;
{ _SearchDir }


{*============================== MAIN PART =============================*}

BEGIN
    _CopyrightDisplay;

    IF (System.ParamCount = 0)
      THEN  BEGIN
         System.WriteLn(asProgramPrompt+'short help for you.');
         System.WriteLn('Usage: '+ asProgram + ' where');
         System.WriteLn('  where    -  drive/path/files to search (def.=current,all)');
         System.Halt(errBadParamStr);
            END;
    {if-then}

    gsInputSearchPath := System.ParamStr(1);


  {* do a search *}
     _SearchDir(gsInputSearchPath,gdwSearchFileAttr);

  {* last report *}
    System.WriteLn(asProgramPrompt+'----- Global Statistics -----');
    System.WriteLn(asProgramPrompt+'ALL Found Files: ',gliFilesFoundCount);
    System.WriteLn(asProgramPrompt+'ALL Total Lines: ',gliLineCountTotal);
    System.WriteLn(asProgramPrompt+'ALL Empty Lines: ',gliLineCountEmpty);
    System.WriteLn(asProgramPrompt+'ALL Percentage:  ',
                   ((gliLineCountEmpty*aPercent100) DIV gliLineCountTotal),
                   '%');
    System.WriteLn(asProgramPrompt+'Done.');

END.
