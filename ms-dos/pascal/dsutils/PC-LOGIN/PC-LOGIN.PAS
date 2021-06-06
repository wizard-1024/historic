{****************************************************************************
//                            File PC-LOGIN.PAS
//
//                      PC system logging utility
//
//      Copyright (c) 1994, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/PC-LOGIN/RCS/pc-login.pas $
//  $RCSfile: pc-login.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:35:59 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: pc-login.pas $
//      Revision 1.1  1998/10/03 14:35:59  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                USER-LOGIN-ON-PC                                }
{ FILE NAME             PC-LOGIN.PAS                                    }
{ PURPOSE               PC SYSTEM LOGGING WITH JOURNAL STATISTICS       }
{ VERSION               1.02                                            }
{ DATE                  02-Aug-1997                                     }
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
{ COMPILER              Turbo Pascal Version 6.0                        }
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             <pclogfile> -  statistics filename              }
{ RETURN                See error return codes definitions              }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           1. Open user logfile if not found then creat it }
{                       2. Get current date & time from OS              }
{                       3. Write to logfile account,date/time, and maybe}
{                          method of logging                            }
{                       4. Close logfile and exit                       }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00  28-Jun-94  DS  initilal release           }
{                       1.01  26-Jul-97  DS  updated documentation      }
{                       1.02  02-Aug-97  DS  removed tabs               }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM  PcLoginSystem;

{** switches for compilation **}
{$S-}             {*  stack checking               *}
{$R-}             {*  range checking               *}
{$X-}             {*  extended syntax              *}


{*** other modules ***}
USES
   Dos, ShowTErr;


{** debugging version **}
{***$DEFINE DebugVersion}


{*========================== CONSTANTS PART ============================*}

CONST
   { program descriptions }
     asPurpose                  =       'PC System Login';
     asMsgVersion               =       'Version ';
     asVersion                  =       '1.02';
     asAuthor                   =       'Dmitry Stefankov';
     asCopyright                =       'Copyright (c) 1994, 1997';
     asProgram                  =       'PC-LOGIN';
     asProgramPrompt            =       asProgram+': ';


   { program exit codes }
     errTerminateOK             =     0;
     errBadParamStr             =     1;
     errNoLogFile               =     3;

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
     asBlank                    =       '';
     asSpaces2                  =       achBlank+achBlank;
     asSpaces4                  =       asSpaces2+asSpaces2;
     asSpaces6                  =       asSpaces4+asSpaces2;

   { character values for boolean switch }
     achSwitchON                =    '+';
     achSwitchOFF               =    '-';

   { user confirm }
     achUserWant                =     'Y';
     achUserDontWant            =     'N';


   { buffers size }
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


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

   gsLogFileName                :       STR80            =   asBlank;
   gdbTabCols                   :       System.Byte      =   8;

   gsDayOfWeekTable             :       ARRAY[0..6]  OF  STR9 =
     ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');

   gsMonthOfYearTable             :       ARRAY[1..12]  OF  STR9 =
     ('January','February','March','April','May','June',
      'July','August','September','October','November','December');



{*=========================== VARIABLES PART ===========================*}

VAR

   gfLogStream                  :       TEXT;
   gfLogStreamFileRec           :       FILE  ABSOLUTE  gfLogStream;

   gsTempInput                  :       STRING;
   giErrorCode                  :       System.Integer;


{*=========================== FUNCTIONAL PART ==========================*}

FUNCTION  _fnbFileExist(VAR fStruc : FILE; sFileName : STRING) : System.Boolean;
{* Check that file exits. *}
VAR
  bResult  :  System.Boolean;

BEGIN
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


FUNCTION  _fnsGetCurretDateTime : STRING;
{ Returns the current date/time from operating system. }
VAR
  sDateTimeStamp  :  STRING;
  sTempYear       :  STR4;
  s2Temp          :  STR2;
  dwYear,
  dwMonth,
  dwDay,
  dwDayOfWeek,
  dwHour,
  dwMinute,
  dwSecond,
  dwSec100        :  System.Word;

BEGIN
   Dos.GetDate(dwYear,dwMonth,dwDay,dwDayOfWeek);
   Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);

   sDateTimeStamp := gsDayOfWeekTable[dwDayOfWeek] + asSpaces2;
   sDateTimeStamp := sDateTimeStamp + gsMonthOfYearTable[dwMonth] + achBlank;
   System.Str(dwDay:2,s2Temp);
   IF (dwDay < 10)
     THEN   s2Temp := s2Temp[2];
   {if-then}
   sDateTimeStamp := sDateTimeStamp + s2Temp + achComma + achBlank;
   System.Str(dwYear:4,sTempYear);
   sDateTimeStamp := sDateTimeStamp + sTempYear + asSpaces2;

   System.Str(dwHour:2,s2Temp);
   sDateTimeStamp := sDateTimeStamp + s2Temp + achColon;
   System.Str(dwMinute:2,s2Temp);
   IF (s2Temp[1] = achBlank)
     THEN  s2Temp[1] := achZERO;
   {if-then}
   sDateTimeStamp := sDateTimeStamp + s2Temp + achColon;
   System.Str(dwSecond:2,s2Temp);
   IF (s2Temp[1] = achBlank)
     THEN  s2Temp[1] := achZERO;
   {if-then}
   sDateTimeStamp := sDateTimeStamp + s2Temp;

   _fnsGetCurretDateTime := sDateTimeStamp;
END; { _fnsGetCurretDateTime }


{*=========================== PROCEDURAL PART ==========================*}


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

    IF (System.ParamCount = 0)
      THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Usage: '+ asProgram + ' logfile');
         System.Halt(errBadParamStr);
            END;
    {if-then}

    gsLogFileName  := System.ParamStr(1);

    {** source file exists? **}
    System.WriteLn(achCR+asProgramPrompt+'Is logfile exist?');
    IF  NOT(_fnbFileExist(gfLogStreamFileRec,gsLogFileName)) THEN
    BEGIN
      System.WriteLn(asProgramPrompt+'No file <'+gsLogFileName+'> exists.');
      System.Write(asProgramPrompt+' Create this file? (Y/N): ');
      System.ReadLn(gsTempInput);
      IF (System.Upcase(_fnchGetFirstChar(gsTempInput)) = achUserDontWant)
        THEN  BEGIN
          System.WriteLn(asProgramPrompt+'No logfile specified.');
          System.Halt(errNoLogFile);
              END
        ELSE  BEGIN
          System.WriteLn(achCR+asProgramPrompt+'Create logfile.');
          System.Assign(gfLogStream,gsLogFileName);
          System.Rewrite(gfLogStream);
          System.Close(gfLogStream);
              END;
      {if-then-else}
    END;
    {if-then}

    System.WriteLn(achCR+asProgramPrompt+'Logfile found.');
    System.Assign(gfLogStream,gsLogFileName);

    System.WriteLn(achCR+asProgramPrompt+'Append to logfile.');
    System.Append(gfLogStream);

    System.WriteLn(gfLogStream);
    System.WriteLn(gfLogStream,'Account:  None');
    System.WriteLn(gfLogStream,'Logged:   '+_fnsGetCurretDateTime);
    System.WriteLn(gfLogStream,'Method:   No specified');

    System.WriteLn(achCR+asProgramPrompt+'Close logfile.');
    System.Close(gfLogStream);

    System.WriteLn(asProgramPrompt+'Done.');

END.
