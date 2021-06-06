{****************************************************************************
//                            File LPRINT.PAS
//
//                Text Formatter For Smart Printing
//
//      Copyright (c) 1992, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/LPRINT/RCS/lprint.pas $
//  $RCSfile: lprint.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:26:19 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: lprint.pas $
//      Revision 1.1  1998/10/03 14:26:19  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                TEXT_LINE_PRINT                                 }
{ FILE NAME             LPRINT.PAS                                      }
{ PURPOSE               Text Formatter For Printing                     }
{ VERSION               1.32                                            }
{ DATE                  02-Aug-1997                                     }
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
{                       (Borland International Inc.), or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             See command line syntax description             }
{ RETURN                See error return codes definitions              }
{ REQUIRES              Source Code Files                               }
{                       MESSAGES.INC    (text messages)                 }
{                       External Object Files                           }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      A. English Language                             }
{                       B. Russian Language                             }
{                       C. Germany Language                             }
{ SPECIAL               None                                            }
{ DESCRIPTION           1.Read   input  stream                          }
{                       2.Format output stream                          }
{                       3.Write  output stream                          }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00  21-Feb-92  DS  initilal release           }
{                       1.01  12-Mar-92  DS  fixed some bugs            }
{                       1.02  17-Mar-92  DS  added documentation        }
{                       1.03  07-Apr-92  DS  added some print options,  }
{                                            fixed errors at printing   }
{                       1.04  19-Apr-92  DS  added user break of print  }
{                       1.05  28-Apr-92  DS  some corrections of syntax }
{                       1.06  08-May-92  DS  added UNIX text convert    }
{                       1.07  14-May-92  DS  added command file option  }
{                       1.10  15-Jun-92  DS  international support and  }
{                                            new user interface         }
{                       1.11  02-Jul-92  DS  fixed a bug for inputstream}
{                       1.12  16-Jul-92  DS  added PC parameter         }
{                       1.13  31-Aug-92  DS  added international help   }
{                       1.14  04-Sep-92  DS  some corrections           }
{                       1.15  18-Sep-92  DS  fixed a bug with page count}
{                                            calculation                }
{                       1.20  27-Oct-92  DS  some corrections           }
{                       1.21  08-Nov-92  DS  some updates and added true}
{                                            Germany writing            }
{                       1.22  14-May-93  DS  some style updates         }
{                       1.23  04-Jul-93  DS  updated documentation      }
{                       1.24  19-Aug-93  DS  fixed problem character map}
{                                            translation                }
{                       1.30  25-Oct-93  DS  added large string options,}
{                                            automatic adjusting        }
{                       1.31  26-Jul-97  DS  updated documentation      }
{                       1.32  02-Aug-97  DS  removed tabs               }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   LinePrintUtility;



{** switches for compilation **}
{$S-}                    {*  stack checking   *}
{$R-}                    {*  range checking   *}
{$X+}                    {*  extended syntax  *}
{$M 32768,65536,65536}   {*  stack/heap sizes *}


{** switches for international support **}
{$DEFINE EnglishVersion}
{$DEFINE RussianVersion}
{$DEFINE GermanyVersion}


{*** other modules ***}
USES
     Strings, Dos, ShowTErr;


{*========================== CONSTANTS PART ============================*}

CONST

   { std definitions }
     asVersion                  =       '1.32';
     asYears                    =       ' 1992, 1997  ';
     asMsgHyphen                =       ' - ';

   { character constants }
     achNULL                    =     #0;
     achBS                      =     #8;
     achHTAB                    =     #9;
     achLF                      =     #10;
     achFF                      =     #12;
     achCR                      =     #13;
     achEOF                     =     #26;
     achESC                     =     #27;
     achComma                   =     ',';
     achBlank                   =     ' ';
     achColon                   =     ':';
     achComment                 =     '#';
     achZERO                    =     '0';
     ach255                     =     #255;

   { string constants }
     asPcTextLF                 =     achCR + achLF;
     asBlankStr                 =     '';
     asSpaces2                  =     achBlank+achBlank;
     asSpaces4                  =     asSpaces2+asSpaces2;
     aMaxSymInStr               =     4096;     { lentgth = 4K !!}

   { Dos standard devices }
     asStdDosConsoleDevice      =     'CON';
     asStdDosPrintDevice        =     'PRN';

   { Dos miscellaneous }
     achDosSwitch               =     '/';
     achUnixSwitch              =     '-';

   { character values for boolean switch }
     achSwitchON                =    '+';
     achSwitchOFF               =    '-';

   { string constants }
    asHelpIndent                =     asSpaces4+achBlank+achDosSwitch;

   { print settings constants }
     aFileSwitch                =       'F';
     aControlSwitch             =       'C';
     aPageSwitch                =       'P';
     aHeaderSwitch              =       'H';
     aLineSwitch                =       'L';
     aMarginSwitch              =       'M';

   { <file> switches }
     aConfigCmd                 =       'C';
     aSourceCmd                 =       'S';
     aDestinationCmd            =       'D';
     aWordStarCmd               =       'W';
     aFirstBinaryCmd            =       'F';
     aLastBinaryCmd             =       'L';
     aTransCodesCmd             =       'T';

   { <control> switches > }
     aStatisticsCmd             =       'S';
     aAdvancedCtrlCmd           =       'A';
     aBatchCmd                  =       'B';
     aCtrlCodesCmd              =       'C';
     aTabCmd                    =       'T';
     aCtrlCharCodeCmd           =       'N';
     aLanguageCmd               =       'L';

   { <page> switches }
     aHeightCmd                 =       'H';
     aWidthCmd                  =       'W';
     aPageNumberCmd             =       'N';
     aSkipPagesCmd              =       'S';
     aCountPagesCmd              =      'C';
     aPrintEvenCmd              =       'E';
     aPrintOddCmd               =       'O';

   { <header> switches }
     aHdrLevelCmd               =       'L';
     aHdrTextCmd                =       'T';

   { <line> switches }
     aLineNumCmd                =       'N';
     aLineSpacingCmd            =       'S';

   { <margin> switches }
     aLeftMarginCmd             =       'L';
     aRightMarginCmd            =       'R';
     aTopMarginCmd              =       'T';
     aBottomMarginCmd           =       'B';

   { user confirm }
     asExitKey                  =     'ESC';
     asStopKey                  =     'SPACE BAR';
     adwUserStopPrint           =     $3920;   { System BIOS  SPACE BAR key }
     adwUserBreakPrint          =     $011B;   { System BIOS  ESCAPE    key }

   { human languages }
     aEnglishLanguage           =       0;
     aRussianLanguage           =       1;
     aGermanyLanguage           =       2;
     aBadLanguage               =       3;

 {$IFDEF EnglishVersion}
     aDefLang                   =       aEnglishLanguage;
 {$ELSE}
    {$IFDEF RussianVersion}
          aDefLang              =       aRussianLanguage;
    {$ELSE}
       {$IFDEF GermanyVersion}
             aDefLang           =       aGermanyLanguage;
       {$ELSE}
             aDefLang           =       aBadLanguage;
       {$ENDIF}
    {$ENDIF}
 {$ENDIF}

     aMinLangNum                =       aEnglishLanguage;
     aMaxLangNum                =       aGermanyLanguage;

   { some help }
     asLongLine                 =      ' ----------------+-------------------------------+-----------------------------';
     asShortExample             =       ': -FSa:\my.doc /pw80 -pN2 /bfc:\bin\lptfont.bin';

{ include files }
{$I MESSAGES.INC}


{*========================== CONSTANTS PART ============================*}

   { program exit codes }
     errTerminateOK             =     0;
     errBadParmsNumber          =     1;
     errSourceNotFound          =     2;
     errDestDontWrite           =     3;
     errSameNames               =     4;
     errInvalidSwtchCharFound   =     5;
     errSrcOpenFailed           =     6;
     errDestCreateFailed        =     7;
     errBinOpenFailed           =     8;
     errUserBreakOfPrint        =     9;
     errBadFormatForNumberFound =     10;
     errDestWriteFault          =     11;
     errBadBooleanValueFound    =     12;
     errNoSourceFileName        =     13;
     errNoActiveLanguageFound   =     14;

   { Dos miscellaneous }
     achDosEndFile              =     achEOF;
     aDosFileNameLength         =     13;
     aWSHBitOff                 =     $7F;

   { TP error codes }
     errOK                      =     0;

   { time/date miscellaneous }
     aHalfDay                   =     12;

   { defaults }
     aDefPageWidth              =       85;
     aDefPageHeight             =       66;

     aDefMarginTop              =       3;
     aDefMarginBottom           =       5;
     aDefMarginLeft             =       5;
     aDefMarginRight            =       5;

     aDefPageNumber             =       1;
     aDefPagesSkipCount         =       0;
     aDefPagesPrintCount        =       0;
     aDefOutPageNumber          =       1;

     aDefLineNumber             =       0;
     aDefCurrentLineOnPage      =       1;
     aDefOutLineNum             =       1;

     achDefEoln                 =       achLF;

     aDefLineSpacing            =       0;
     aNoHTabSpaces              =       0;
     aDefTabCols                =       8;
     aDefHeaderLevel            =       1;


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
    STR2                =       STRING[2];
    STR4                =       STRING[4];
    STR6                =       STRING[6];
    STR8                =       STRING[8];
    STR9                =       STRING[9];
    STR10               =       STRING[10];
    STR80               =       STRING[80];

    fBinFileType        =       FILE  OF  System.Byte;


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

   { command script file }
     gsCmdFileName         :      STR80               =   asBlankStr;

   { input stream assignment }
     gsInFileName          :       STR80             =    asBlankStr;

   { output stream assignment }
     gsOutFileName         :       STR80              =   asStdDosPrintDevice;

   { binary files misc. info }
     gsStartBinaryFileName :      STR80               =   asBlankStr;
     gsEndBinaryFileName   :      STR80               =   asBlankStr;
     gsTranslBinFileName   :      STR80               =   asBlankStr;

   { page linear sizes }
     gdwPageWidth         :       System.Word         =   aDefPageWidth;
     gdwPageHeight        :       System.Word         =   aDefPageHeight;

   { page indentation }
     gdwMarginTop         :       System.Word         =   aDefMarginTop;
     gdwMarginBottom      :       System.Word         =   aDefMarginBottom;
     gdwMarginLeft        :       System.Word         =   aDefMarginLeft;
     gdwMarginRight       :       System.Word         =   aDefMarginRight;

   { number of printing page }
     gdwPageNumber        :       System.Word         =   aDefPageNumber;
     gdwFirstPageNumber   :       System.Word         =   aDefPageNumber;
     gdwSkipPagesCount    :       System.Word         =   aDefPagesSkipCount;
     gdwPrintPagesCount   :       System.Word         =   aDefPagesPrintCount;
     gdwOutPageNumber     :       System.Word         =   aDefOutPageNumber;

   { page line number }
     gdwLineNumber        :       System.Longint      =   aDefLineNumber;
     gdwCurrentLineOnPage :       System.Longint      =   aDefCurrentLineOnPage;
     gdwOutLineNum        :       System.Word         =   aDefOutLineNum;

   { line spacing on page }
     gdwLineSpacing       :       System.Word         =   aDefLineSpacing;

   { tab size }
     gdbTabCols           :       System.Byte         =   aDefTabCols;

   { page header control }
     gdwHeaderLevel       :       System.Word         =   aDefHeaderLevel;
     gsHeaderText         :       STRING              =   asBlankStr;

   { print control miscellaneous switches }
     gbAdvancePrintControlOK    :     System.Boolean  =   System.False;
     gbBatchModeOK              :     System.Boolean  =   System.False;
     gbPrintStatisticsOK        :     System.Boolean  =   System.True;
     gbAsciiControlCharsOff     :     System.Boolean  =   System.False;
     gbWordStarModeOK           :     System.Boolean  =   System.False;
     gbTransModeOK              :     System.Boolean  =   System.False;
     gbPrintOK                  :     System.Boolean  =   System.True;
     gbOddPagesPrintOK          :     System.Boolean  =   System.True;
     gbEvenPagesPrintOK         :     System.Boolean  =   System.True;
     gbPrintNotAllPages         :     System.Boolean  =   System.False;
     gchEOLN                    :     System.Char     =   achDefEoln;

 { international support }
     gdbCurLanguage             :      System.Byte    =   aDefLang;

 { support for enhanced keyboard }
   gbEnhancedKeyboardFound      :     System.Boolean  =   System.False;

 { file open mode control byte, default=read/write }
   gdbOpenFileMode              :     System.Byte     =   2;

 { end of printing flag }
   gbPrintDone                  :     System.Boolean  =   System.False;

 { standard codes translation table }
   aNumOfCodes                  =    256;
   gchCodeTranslateTable        :     ARRAY[0..aNumOfCodes-1]  OF  System.Char =
                                    (#$00,#$01,#$02,#$03,#$04,#$05,#$06,#$07,
                                     #$08,#$09,#$0A,#$0B,#$0C,#$0D,#$0E,#$0F,
                                     #$10,#$11,#$12,#$13,#$14,#$15,#$16,#$17,
                                     #$18,#$19,#$1A,#$1B,#$1C,#$1D,#$1E,#$1F,
                                     #$20,#$21,#$22,#$23,#$24,#$25,#$26,#$27,
                                     #$28,#$29,#$2A,#$2B,#$2C,#$2D,#$2E,#$2F,
                                     #$30,#$31,#$32,#$33,#$34,#$35,#$36,#$37,
                                     #$38,#$39,#$3A,#$3B,#$3C,#$3D,#$3E,#$3F,
                                     #$40,#$41,#$42,#$43,#$44,#$45,#$46,#$47,
                                     #$48,#$49,#$4A,#$4B,#$4C,#$4D,#$4E,#$4F,
                                     #$50,#$51,#$52,#$53,#$54,#$55,#$56,#$57,
                                     #$58,#$59,#$5A,#$5B,#$5C,#$5D,#$5E,#$5F,
                                     #$60,#$61,#$62,#$63,#$64,#$65,#$66,#$67,
                                     #$68,#$69,#$6A,#$6B,#$6C,#$6D,#$6E,#$6F,
                                     #$70,#$71,#$72,#$73,#$74,#$75,#$76,#$77,
                                     #$78,#$79,#$7A,#$7B,#$7C,#$7D,#$7E,#$7F,
                                     #$80,#$81,#$82,#$83,#$84,#$85,#$86,#$87,
                                     #$88,#$89,#$8A,#$8B,#$8C,#$8D,#$8E,#$8F,
                                     #$90,#$91,#$92,#$93,#$94,#$95,#$96,#$97,
                                     #$98,#$99,#$9A,#$9B,#$9C,#$9D,#$9E,#$9F,
                                     #$A0,#$A1,#$A2,#$A3,#$A4,#$A5,#$A6,#$A7,
                                     #$A8,#$A9,#$AA,#$AB,#$AC,#$AD,#$AE,#$AF,
                                     #$B0,#$B1,#$B2,#$B3,#$B4,#$B5,#$B6,#$B7,
                                     #$B8,#$B9,#$BA,#$BB,#$BC,#$BD,#$BE,#$BF,
                                     #$C0,#$C1,#$C2,#$C3,#$C4,#$C5,#$C6,#$C7,
                                     #$C8,#$C9,#$CA,#$CB,#$CC,#$CD,#$CE,#$CF,
                                     #$D0,#$D1,#$D2,#$D3,#$D4,#$D5,#$D6,#$D7,
                                     #$D8,#$D9,#$DA,#$DB,#$DC,#$DD,#$DE,#$DF,
                                     #$E0,#$E1,#$E2,#$E3,#$E4,#$E5,#$E6,#$E7,
                                     #$E8,#$E9,#$EA,#$EB,#$EC,#$ED,#$EE,#$EF,
                                     #$F0,#$F1,#$F2,#$F3,#$F4,#$F5,#$F6,#$F7,
                                     #$F8,#$F9,#$FA,#$FB,#$FC,#$FD,#$FE,#$FF);

   { filter for ASCII control codes }
     aMinCtrlCodeChar       =     0;
     aMaxCtrlCodeChar       =     31;
     gbAvailAsciiCtrlCodesTable :     ARRAY[aMinCtrlCodeChar..aMaxCtrlCodeChar]  OF  System.Boolean  =
                     (System.False,System.False,System.False,System.False,  {0-3}
                      System.False,System.False,System.True, System.False,  {4-7}
                      System.True, System.True, System.False,System.False,  {8-11}
                      System.False,System.True, System.False,System.False,  {12-15}
                      System.False,System.False,System.False,System.False,  {16-19}
                      System.False,System.False,System.False,System.False,  {20-23}
                      System.False,System.False,System.False,System.False,  {24-27}
                      System.False,System.False,System.False,System.False); {28-31}

   { filter for ASCII codes }
     aMinCodeChar           =     0;
     aHalfTableCodeChar     =     127;
     aMaxCodeChar           =     255;
     gbAvailAsciiCodesTable :     ARRAY[aMinCodeChar..aMaxCodeChar]  OF  System.Boolean  =
        (System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {00-07}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {08-0F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {10-17}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {18-1F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {20-27}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {28-2F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {30-37}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {38-3F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {40-47}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {48-4F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {50-57}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {58-5F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {60-67}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {68-6F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {70-77}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {78-7F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {80-87}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {88-8F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {90-97}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {98-9F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {A0-A7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {A8-AF}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {B0-B7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {B8-BF}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {C0-C7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {C8-CF}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {D0-D7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {D8-DF}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {E0-E7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {E8-EF}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {F0-F7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True); {F8-FF}

   { character sets }
     setAscii8NoCtrl            :     SET OF System.Char = [achBlank..ach255];
     setUnusedLeadChars         :     SET OF System.Char = [achHTAB,achBlank];


{*=========================== VARIABLES PART ===========================*}

VAR

 { input stream description }
   gfInputStream        :       fBinFileType;
   gfInputFileRecord    :       Dos.FileRec  ABSOLUTE  gfInputStream;

 { output stream description }
   gfOutputStream       :       System.Text;
   gfOutputFileRecord   :       Dos.TextRec  ABSOLUTE  gfOutputStream;

 { DOS info for input stream }
   gsInFileDirStr       :       Dos.DirStr;
   gsInFileNameStr      :       Dos.NameStr;
   gsInFileExtStr       :       Dos.ExtStr;

 { DOS info for output stream }
   gsOutFileDirStr      :      Dos.DirStr;
   gsOutFileNameStr     :      Dos.NameStr;
   gsOutFileExtStr      :      Dos.ExtStr;

 { current date }
   gdwCurrentYear       :       System.Word;
   gdwCurrentMonth      :       System.Word;
   gdwCurrentDay        :       System.Word;
   gdwCurrentWeekDay    :       System.Word;

 { current time }
   gdwCurrentHour       :       System.Word;
   gdwCurrentMinute     :       System.Word;
   gdwCurrentSec        :       System.Word;
   gdwCurrentSec100     :       System.Word;

 { DOS miscellaneous info for input stream }
   gliFileTime          :       System.Longint;
   grecFileDateTime     :       Dos.DateTime;
   gdwFileDayOfWeek     :       System.Word;

 { text stamp for date/time }
   gsPrintDateStamp     :       STRING;
   gsFileDateStamp      :       STRING;

 { current printing page info }
   gdwOutLineWidth      :       System.Word;
   gdwOutLineHeight     :       System.Word;
   gdwOutLinesOnPage    :       System.Word;

 { large buffer for input string }
   gszLargeInBuf        :       ARRAY[0..aMaxSymInStr]  OF System.Char;
   gpszLargeInBuf       :       System.PChar;

{*=========================== FORWARD REFERENCES =======================*}

PROCEDURE  _OutputTextStrLn(sMessage : STRING);      FORWARD;
PROCEDURE  _ProcessOneCommand(sCommand : STRING);  FORWARD;
PROCEDURE  _ErrorHalt(sMessage : STRING; dbReturnCode : System.Byte); FORWARD;
PROCEDURE  _UserErrorReport(sMessage : STRING; bAddRetryAsk,bYesNo : System.Boolean); FORWARD;


{*=========================== FUNCTIONAL PART ==========================*}

FUNCTION  _bDeviceReadyForOutput(dwDeviceHandle : System.Word) : System.Boolean; assembler;
{* get output device status * }
asm
     mov        bx, dwDeviceHandle      { BX = handle }
     mov        ax, $4407               { IOCTL, get file/device output status }
     int        21h                     { Dos services }
     mov        ah, System.True         { AH = 1 }
     cmp        al,0FFh                 { 0FFh = ready, 00h = not ready }
     je         @ExitFunc
     mov        ah, System.False        { AH = 0 }
  @ExitFunc:
     mov        al, ah                  { return value of function }
END;
  {end-asm}
{ _bDeviceReadyForOutput }



FUNCTION  _fnbIsDevice(dwDeviceHandle : System.Word) : System.Boolean; assembler;
{* get output device status * }
  asm
     mov        bx, dwDeviceHandle      { BX = handle }
     mov        ax, $4400               { IOCTL, get file/device info }
     int        21h                     { Dos services }
     jc         @FileFound              { may be error }
     mov        ah, System.True         { AH = 1 }
     test       dx,080h                 { test DEV bit }
     jnz        @ExitFunc               { if ZR then we have disk file }
  @FileFound:
     mov        ah, System.False        { AH = 0 }
  @ExitFunc:
     mov        al, ah                  { return value of function }
END;
  {end-asm}
{ _fnbIsDevice }


FUNCTION  _fndwCalcDayOfWeek(dwInitYear,dwInitMonth,dwInitDay,
                             dwCurYear,dwCurMonth : System.Word) : System.Word;
VAR
  ddTotal, ddInitDays, ddCurDays  :  System.Longint;

FUNCTION  _fndwTotalDays(dwDayFn,dwMonthFn,dwYearFn : System.Word) : System.Word;
{* internal *}
VAR
  ddTemp  :  System.Longint;

BEGIN
  {* magic formula *}
     ddTemp := System.Trunc((22-dwMonthFn)/10);

  _fndwTotalDays := System.Trunc((dwYearFn-1899-ddTemp)*365.25)+
                 System.Trunc((12*ddTemp+dwMonthFn-14)*30.59)+29+dwDayFn;
END;  { _fndwAllDays }

BEGIN   { _fndwCalcDayOfWeek }
  {* magic calculations *}
      ddInitDays := _fndwTotalDays(dwInitDay,dwInitMonth,dwInitYear);
      ddCurDays  := _fndwTotalDays(1,dwCurMonth,dwCurYear);
      ddTotal := ddCurDays - ddInitDays;

    _fndwCalcDayOfWeek := System.Trunc((ddInitDays/7-System.Trunc(ddInitDays/7))*7+0.5);
END;    { _fndwCalcDayOfWeek }


FUNCTION  _fnsCurrentLanguage(dbDefLang : System.Byte)  :  STRING;
{* Get the current language in string form. *}
VAR
  sLang  :  STRING;
BEGIN
   CASE  dbDefLang  OF
       aEnglishLanguage    :   sLang := Strings.StrPas(gszEnglishLanguage[gdbCurLanguage]);
       aRussianLanguage    :   sLang := Strings.StrPas(gszRussianLanguage[gdbCurLanguage]);
       aGermanyLanguage    :   sLang := Strings.StrPas(gszGermanyLanguage[gdbCurLanguage]);
   ELSE
       sLang := 'Unknown';
   END;
   {case-of}

  _fnsCurrentLanguage := sLang;
END; { _fnsCurrentLanguage }


FUNCTION  _fnsUpcaseStr(sInput : STRING) : STRING;
{* Make all in uppercase. *}
VAR
  dbIndex  :  System.Byte;
  dbCount  :  System.Byte  ABSOLUTE sInput;

BEGIN
  IF  (dbCount <> 0)
  THEN  FOR dbIndex :=  1  TO  dbCount  DO
            sInput[dbIndex] := System.Upcase(sInput[dbIndex]);
        {for-to-do}
  {if-then}

   _fnsUpcaseStr := sInput;
END; { _fnsUpcaseStr }


FUNCTION  _fnszWordStar(szInput : System.PChar) : System.PChar;
{* Strip high bit off for all characters. *}
VAR
  dwIndex  :  System.Word;
  dwCount  :  System.Word;

BEGIN
  dwCount := Strings.StrLen(szInput);
  IF (dwCount <> 0)
    THEN   FOR dwIndex :=  0  TO  dwCount-1  DO
              szInput[dwIndex] := System.Char(System.Byte(szInput[dwIndex]) AND aWSHBitOff);
           {for-to-do}
  {if-then}

   _fnszWordStar := szInput;
END; { _fnszWordStar }


FUNCTION  _fnszTranslateCodes(szInput : System.PChar) : System.PChar;
{* Translate from one code table to another. *}
VAR
  dwIndex  :  System.Word;
  dwCount  :  System.Word;

BEGIN
  dwCount := Strings.StrLen(szInput);
  IF (dwCount <> 0)
    THEN   FOR dwIndex :=  0  TO  dwCount-1  DO
              szInput[dwIndex] := gchCodeTranslateTable[System.Byte((szInput[dwIndex]))];
           {for-to-do}
  {if-then}

   _fnszTranslateCodes := szInput;
END; { _fnszTranslateCodes }


FUNCTION  _fnszRemoveUnusedAsciiCodes(szInput : System.PChar) : System.PChar;
{* Strip all unwanted character codes. *}
VAR
  dwFetchIndex  :  System.Word;
  dwPutIndex    :  System.Word;
  dwCount       :  System.Word;
  chNext        :  System.Char;

BEGIN
  dwCount := Strings.StrLen(szInput);
  dwFetchIndex := 0;
  dwPutIndex := 0;

  WHILE  (dwCount <> 0) DO
  BEGIN
    chNext := szInput[dwFetchIndex];
    IF ((gbAvailAsciiCodesTable[System.Byte(chNext)]))
       THEN  BEGIN
                szInput[dwPutIndex] := chNext;
                System.Inc(dwPutIndex);
             END;
    {if-then}
    {* total count/pointer *}
      System.Inc(dwFetchIndex);
      System.Dec(dwCount);
  END;
  {while-do}

  {* make final str *}
    szInput[dwPutIndex] := achNULL;

  _fnszRemoveUnusedAsciiCodes := szInput;
END; { _fnszRemoveUnusedAsciiCodes }


FUNCTION _fnchUpperCase(chSym : System.Char) : System.Char;
{* Translates from lowercase to uppercase. *}
BEGIN
   CASE  gdbCurLanguage OF
      aEnglishLanguage  :  chSym := System.UpCase(chSym);
      aRussianLanguage  :  {** Attention!!! Hard-Coded Values! **}
                           CASE  chSym OF
                                 #$F1  : chSym := #$F1;
                                 #$A0..#$AF : System.Dec(System.Byte(chSym),$A0-$80);
                                 #$E0..#$EF : System.Dec(System.Byte(chSym),$E0-$90);
                             ELSE
                               {nothing};
                           END;
                           {case-of}
      aGermanyLanguage  :  chSym := System.UpCase(chSym);
   END;
   {case-of}

  _fnchUpperCase := chSym;
END; { _fnchUpperCase }


FUNCTION  _fnbGetValue(sInput : STRING) : System.Boolean;
{* Convert string to an integer number. *}
VAR
  bReturnValue    :  System.Boolean;
  chBooleanValue  :  System.Char;
  dbCount         :  System.Byte  ABSOLUTE  sInput;

BEGIN
    {* get a first char *}
      IF  (dbCount <> 0)
        THEN    chBooleanValue := sInput[1]
        ELSE    chBooleanValue := #0;
      {if-then-else}

    CASE  chBooleanValue  OF
            achSwitchON  : bReturnValue := System.True;
            achSwitchOFF : bReturnValue := System.False;
    ELSE
        _ErrorHalt(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                   Strings.StrPas(gszMsgBadBooleanSwitch[gdbCurLanguage]),
                     errBadBooleanValueFound);
    END;
    {case-of}

   _fnbGetValue := bReturnValue;
END; { _fnbGetValue }


FUNCTION  _fndwGetNum(sInput : STRING) : System.Word;
{* Convert string to an integer number. *}
VAR
  iErrorCode :  System.Integer;
  dwNumber   :  System.Word;

BEGIN
    System.Val(sInput,dwNumber,iErrorCode);
    IF  (iErrorCode <> errOK)
       THEN _ErrorHalt(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                       Strings.StrPas(gszMsgBadNumericFound[gdbCurLanguage]),
                        errBadFormatForNumberFound);
    {if-then}

   _fndwGetNum := dwNumber;
END; { _fndwGetNum }


FUNCTION  _fnsNumToStr(dwNum,dwWidth : System.Word) : STRING;
{* Returns a numeric format string for a given number. *}
VAR
  sNumStr   :  STRING;

BEGIN
  IF (dwWidth = 0)
    THEN  System.Str(dwNum,sNumStr)
    ELSE  System.Str(dwNum:dwWidth,sNumStr);
  {if-then-else}
  _fnsNumToStr := sNumStr;
END; { _fnsNumToStr }


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


FUNCTION  _fnsLeadingZeroSpace(sInput : STRING; bReplace : System.Boolean; chOld,chNew : System.Char) : STRING;
{* Remove or replace the leading character *}
VAR
  dbCount  :  System.Byte  ABSOLUTE  sInput;

BEGIN
  IF  (dbCount <> 0)  THEN
  BEGIN
     IF  (bReplace)
       THEN
          BEGIN  IF  (sInput[1] = chOld)
                   THEN sInput[1] := chNew;
                 {if-then}
          END
       ELSE
          IF  (sInput[1] = chOld) THEN System.Delete(sInput,1,1);
          {if-then}
      {if-then-else}
  END;
  {if-then}
  _fnsLeadingZeroSpace := sInput;
END; { _fnsLeadingZeroSpace }


FUNCTION  _fnsRemoveLeadChars(sInput : STRING) : STRING;
{* Remove all occurrences of leading char from left side. *}
BEGIN
   WHILE ((sInput <> asBlankStr) AND (sInput[1] IN setUnusedLeadChars))
   DO  System.Delete(sInput,1,1);
   {while-do}
   _fnsRemoveLeadChars := sInput;
END; { _fnsRemoveLeadChars }


FUNCTION  _fnsDateTimeStamp(dwYear,dwMonth,dwDay,dwWeekDay,dwHour,dwMinute : System.Word) : STRING;
{* Make the date/time stamp string. *}
VAR
  sStamp        :  STRING;
  sMeridian     :  STR2;

BEGIN
  {* add day of week *}
    sStamp := Strings.StrPas(gstrucDaysOfWeek[gdbCurLanguage,dwWeekDay]) + achComma + achBlank;

  {* add month/day *}
    sStamp := sStamp + Strings.StrPas(gstrucMonthsOfYear[gdbCurLanguage,dwMonth]) + achBlank;
    sStamp := sStamp +
              _fnsLeadingZeroSpace(_fnsNumToStr(dwDay,2),System.False,achBlank,achBlank) +
              achComma +
              achBlank;

  {* add year *}
    sStamp := sStamp + _fnsNumToStr(dwYear,4) + achComma + achBlank;

  {* add am/pm mark *}
     sMeridian := Strings.StrPas(gszMsgAM[gdbCurLanguage]);
     IF (dwHour  > (aHalfDay-1)) THEN
       BEGIN
         sMeridian := Strings.StrPas(gszMsgPM[gdbCurLanguage]);
         System.Dec(dwHour,aHalfDay);
       END;
     {if-then}
     IF (dwHour = aHalfDay) THEN
       BEGIN
         dwHour := 0;
         sMeridian := Strings.StrPas(gszMsgAM[gdbCurLanguage]);
       END;
     {if-then}

  {* add hour *}
    sStamp := sStamp +
              _fnsLeadingZeroSpace(_fnsNumToStr(dwHour,2),System.False,achBlank,achBlank) +
              achColon;

  {* add minute *}
    sStamp := sStamp +
              _fnsLeadingZeroSpace(_fnsNumToStr(dwMinute,2),System.True,achBlank,achZERO) +
              sMeridian;

   _fnsDateTimeStamp := sStamp;
END; { _fnsDateTimeStamp }


FUNCTION  _fnbTextFileExist(VAR fStruc : System.Text; sFileName : STRING) : System.Boolean;
{* Check that file exits. *}
VAR
  dwFileHandle   :  System.Word;
  bResult        :  System.Boolean;

BEGIN
  {** attempt to open the file **}
    System.Assign(fStruc,sFileName);

  {** turn I/O check off at file opening **}
    {$I-}  System.Reset(fStruc);  {$I+}

  {** get open handle **}
  {* Attention!! Access of TP internal structures *}
    asm
      les  di, fStruc            { ES:DI -> file struc }
      mov  ax, es:[di+0]         { AX = file handle !!!!}
      mov  dwFileHandle, ax      { save it }
    END;
    {asm}

  IF (_fnbIsDevice(dwFileHandle))
    THEN  BEGIN
             bResult := System.False;
             System.InOutRes := errOK;  { fix a TP run-time error }
          END
    ELSE  bResult := (System.IOResult = errOK);
  {if-then-else}

  {** if open successful then close this file **}
    IF (bResult)
      THEN  System.Close(fStruc);
    {if-then}

  _fnbTextFileExist := bResult;
END; { _fnbTextFileExist }


FUNCTION  _fnbBinFileExist(VAR fStruc : fBinFileType; sFileName : STRING) : System.Boolean;
{* Check that file exits. *}
VAR
  dwFileHandle   :  System.Word;
  bResult        :  System.Boolean;

BEGIN
  {** attempt to open the file **}
    System.Assign(fStruc,sFileName);

  {** turn I/O check off at file opening **}
    {$I-}  System.Reset(fStruc);  {$I+}

  {** get open handle **}
  {* Attention!!! Access of TP internal structures. *}
    asm
      les  di, fStruc            { ES:DI -> file struc }
      mov  ax, es:[di+0]         { AX = file handle, just DOS index !!!!}
      mov  dwFileHandle, ax      { save it }
    END;
    {end-asm}

  IF (_fnbIsDevice(dwFileHandle))
    THEN  BEGIN
             bResult := System.False;
             System.InOutRes := errOK;  { fix a TP run-time error!! }
          END
    ELSE  bResult := (System.IOResult = errOK);
  {if-then-else}

  {** if open successful then close this file **}
    IF (bResult)
      THEN  System.Close(fStruc);
    {if-then}

  _fnbBinFileExist := bResult;
END; { _fnbBinFileExist }


FUNCTION  _fnszDeTabString(szInput: System.PChar) : System.PChar;
{* Replaces the horizontal tabulation char with wanted # of spaces. *}
CONST
  aszHTAB     :  System.PChar    =  (achHTAB);

VAR
  szUnTabStr  :  System.PChar;
  pszIndex    :  System.PChar;
  sTemp       :  STRING;
  dwIndex     :  System.Word;
  dwStrSize   :  System.Word;
  dbPStrLen   :  System.Byte;

BEGIN
  { works also if empty string found }
    szUnTabStr := Strings.StrNew(szInput);
    dwStrSize := Strings.StrLen(szInput);
    pszIndex := Strings.StrPos(szInput,aszHTAB);


    {** replace all occurrences of tab mark to wanted # of spaces **}
      WHILE  (pszIndex <> NIL) DO
      BEGIN
          dwIndex := pszIndex - szInput;
          sTemp := _fnsAddSpaces(gdbTabCols-((dwIndex) MOD gdbTabCols));
          System.Move(szInput[dwIndex+1],szUnTabStr[0],dwStrSize-dwIndex+1);
          dbPStrLen := System.Length(sTemp);
          System.Move(sTemp[1],szInput[dwIndex],dbPStrLen);
          System.Move(szUnTabStr[0],szInput[dwIndex+dbPStrLen],dwStrSize-dwIndex+1);
          dwStrSize := Strings.StrLen(szInput);
          pszIndex := Strings.StrPos(szInput,aszHTAB);
      END;
      {while-do}

      Strings.StrDispose(szUnTabStr);
     _fnszDeTabString := szInput;
END; { _fnszDeTabString }


FUNCTION  _fnsFormatLineFromLeftSide(sInput : STRING) : STRING;
{* adjust the string from left side. *}
BEGIN
   _fnsFormatLineFromLeftSide := _fnsAddSpaces(gdwMarginLeft) + sInput;
END; { _fnsFormatLineFromLeftSide }


FUNCTION _fnsRemoveLastColon(sInput : STRING) : STRING;
{* remove the colon if found at the end of string *}
VAR
  dbIndex  :  System.Byte  ABSOLUTE sInput;

BEGIN
  IF (dbIndex <> 0)
  THEN  IF (sInput[dbIndex] = achColon)
           THEN  System.Delete(sInput,dbIndex,1);
        {if-then}
  {if-then}
  _fnsRemoveLastColon := sInput;
END; { _fnsRemoveLastColon }


FUNCTION  _fnszFileRead(VAR fStruc : fBinFileType; pszSInputBuf : System.PChar) : System.PChar;
{* Read one line from UNIX-formatted text *}
VAR
  dwCount       :       System.Word;
  szOutLine     :       System.PChar;
  bLineEnd      :       System.Boolean;
  chNextByte    :       System.Byte;
  bReadOk       :       System.Boolean;

BEGIN
  {* set defaults *}
    bLineEnd  :=  System.False;
    szOutLine := pszSInputBuf;
    dwCount   :=  0;

  {*****************************************************
    read char-by-char
        while linefeed not meeting
          or
        # of pushed symbols don't exceed maximum number
   *****************************************************}
  REPEAT
    bReadOk := System.False;
    REPEAT
      {$I-}  System.Read(fStruc,chNextByte);  {$I+}

       IF  (System.IoResult = errOK)
         THEN  bReadOk := System.True
         ELSE _UserErrorReport(Strings.StrPas(gszMsgReadFail[gdbCurLanguage]),
                               System.True,System.True);
       {if-then-else}
    UNTIL (bReadOk);
    {repeat-until}

    IF  (System.Char(chNextByte) = gchEOLN)
      THEN  bLineEnd := System.True
      ELSE
        IF (System.Char(chNextByte) <> achCR)
          THEN  BEGIN
            szOutLine[dwCount] := System.Char(chNextByte);
            System.Inc(dwCount);
                END;
        {if-then}
    {if-then-else}
  UNTIL ((bLineEnd) OR (System.Eof(fStruc)) OR (dwCount >= aMaxSymInStr));
  {repeat-until}

  {* we now have the DOS std text string *}
    szOutLine[dwCount] := achNULL;
    _fnszFileRead:= szOutLine;
END; { _fnszFileRead }


FUNCTION  _fnchUserAsk  :  System.Char;
{* ask user and display his option *}
VAR
  sUserInput :  STRING;

BEGIN
    {$I-} System.ReadLn(System.Input,sUserInput); {$I+}
    IF  (sUserInput <> asBlankStr)
      THEN  _fnchUserAsk := sUserInput[1]
      ELSE  _fnchUserAsk := achNULL;
    {if-then-else}
END; { _fnchUserAsk }


FUNCTION  _fnpszInsertString(DestTo,SrcFrom : System.PChar; dwMaxDestLen : System.Word) : System.PChar;
{* Insert function for zero-terminated strings. *}
VAR
   dwSrcCount,
   dwDestCount  :  System.Word;

BEGIN

   dwSrcCount := Strings.StrLen(SrcFrom);
   dwDestCount := Strings.StrLen(DestTo);

   IF ((dwSrcCount+dwDestCount) > dwMaxDestLen)
     THEN  dwSrcCount := dwMaxDestLen - dwDestCount;
   {if-then}

   IF (dwSrcCount <> 0)
     THEN  BEGIN
        System.Move(DestTo[0],DestTo[dwSrcCount],dwDestCount+1);
        System.Move(SrcFrom[0],DestTo[0],dwSrcCount);
           END;
   {if-then}

  _fnpszInsertString := DestTo;

END;
{ _fnpszInsertString }



{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     _OutputTextStrLn(Strings.StrPas(gszPurpose[gdbCurLanguage])+
                      Strings.StrPas(gszMsgVersion[gdbCurLanguage])+
                      asVersion+
                      achComma+achBlank +
                      Strings.StrPas(gszCopyright[gdbCurLanguage])+
                      asYears+
                      Strings.StrPas(gszAuthor[gdbCurLanguage]));
END;  { _CopyrightDisplay }


PROCEDURE  _ErrorHalt(sMessage : STRING; dbReturnCode : System.Byte);
{* Display message about error and exit to DOS. *}
BEGIN
    IF (sMessage <> asBlankStr)
      THEN  _OutputTextStrLn(sMessage);
    {if-then}
    System.Halt(dbReturnCode);
END; { _ErrorHalt }


PROCEDURE  _OutputTextStr(sMessage : STRING);
{* Display a message. }
BEGIN
    {$I-} System.Write(System.Output,sMessage); {$I+}
END; { _OutputTextStr }


PROCEDURE  _OutputTextStrLn(sMessage : STRING);
{* Display a message. }
BEGIN
    {$I-} System.WriteLn(System.Output,sMessage); {$I+}
END; { _OutputTextStrLn }


PROCEDURE  _BadSwitchFound(sErrorMessage : STRING);
{* Display message about error and stop program. *}
BEGIN
  _CopyrightDisplay;
  _ErrorHalt(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
              sErrorMessage +
              Strings.StrPas(gszMsgsMisMatchSwitch[gdbCurLanguage]),
                errInvalidSwtchCharFound);
END; { _BadSwitchFound }


PROCEDURE  _LoadBinaryFile(sBinFileName : STR80);
VAR
  fBinaryStream  :   FILE OF System.Byte;
  ddBytesCount   :   System.Longint;
  dbBufForByte   :   System.Byte;
  bReadOk        :   System.Boolean;
  bWriteOk       :   System.Boolean;

BEGIN
    {** debug message **}
      _OutputTextStrLn(Strings.StrPas(gszProgramPrompt[gdbCurLanguage])+
                       Strings.StrPas(gszMsgLoadBinFile[gdbCurLanguage])+
                       sBinFileName);

    {** attempt to open the file **}
      System.Assign(fBinaryStream,sBinFileName);

    {** turn I/O check off at file opening **}
      {$I-}  System.Reset(fBinaryStream);  {$I+}

    {** check if the file successfull opened **}
      IF  (System.IoResult <> errOK)
        THEN  _ErrorHalt(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                         Strings.StrPas(gszMsgFileNotFound[gdbCurLanguage]) +
                         sBinFileName,
                           errBinOpenFailed);
      {if-then}

    {* get total count of bytes in file *}
      ddBytesCount := System.FileSize(fBinaryStream);

    {** we are used one-by-one byte algorithm to copy **}
    WHILE  (ddBytesCount <> 0) DO
    BEGIN
      {* read only one byte *}
        bReadOk := System.False;
        REPEAT
           {$I-}  System.Read(fBinaryStream,dbBufForByte);  {$I+}

           IF  (System.IoResult = errOK)
             THEN  bReadOk := System.True
             ELSE  _UserErrorReport(Strings.StrPas(gszMsgReadFail[gdbCurLanguage]),
                                    System.True,System.True);
           {if-then}
        UNTIL (bReadOk);
        {repeat-until}

      {** write all bytes except EOF **}
        IF (dbBufForByte <> System.Byte(achDosEndFile))
          THEN  BEGIN
             bWriteOk := System.False;
             REPEAT
                {$I-} System.Write(gfOutputStream,System.Char(dbBufForByte)); {$I+}
                IF  (System.IoResult = errOK)
                  THEN   bWriteOk := System.True
                  ELSE  _UserErrorReport(Strings.StrPas(gszMsgWriteFail[gdbCurLanguage]),
                                         System.True,System.True);
                {if-then}
             UNTIL (bWriteOk); {
             repeat-until}
                END;
         {if-then}
      {* total count down *}
        System.Dec(ddBytesCount);
    END;
    {while-do}

    {* close this file if no need more *}
      System.Close(fBinaryStream);
END;  { _LoadBinaryFile }


PROCEDURE  _LoadCodeTranslFile(sTransBinFileName : STR80);
VAR
  fBinaryStream  :   FILE OF System.Byte;
  dwCount        :   System.Word;
  dbInitOfs      :   System.Byte;
  dbIndex        :   System.Byte;

FUNCTION _fndbGetByteFromFile : System.Byte;
{* Get one byte from binary stream. *}
VAR
  dbBufForByte   :   System.Byte;
  bReadOk        :   System.Boolean;

BEGIN
      bReadOk := System.False;

      REPEAT
         {$I-}  System.Read(fBinaryStream,dbBufForByte);  {$I+}
         IF  (System.IoResult = errOK)
           THEN   bReadOk := System.True
           ELSE  _UserErrorReport(Strings.StrPas(gszMsgReadFail[gdbCurLanguage]),
                                  System.True,System.True);
         {if-then-else}
      UNTIL (bReadOk);
      {repeat-until}

  _fndbGetByteFromFile := dbBufForByte;
END; { _fndbGetByteFromFile }

BEGIN
    {** debug message **}
      _OutputTextStrLn(Strings.StrPas(gszProgramPrompt[gdbCurLanguage])+
                       Strings.StrPas(gszMsgLoadTransFile[gdbCurLanguage])+
                       sTransBinFileName);

    {** attempt to open the file **}
       System.Assign(fBinaryStream,sTransBinFileName);

    {** turn I/O check off at file opening **}
      {$I-}  System.Reset(fBinaryStream);  {$I+}

    {** check if the file successfull opened **}
      IF  (System.IoResult <> errOK)
        THEN  _ErrorHalt(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                         Strings.StrPas(gszMsgFileNotFound[gdbCurLanguage]) +
                         sTransBinFileName,
                           errBinOpenFailed);
      {if-then}

    {* setup vars: total bytes in files, offset into table and # to copy *}
      dbInitOfs    := _fndbGetByteFromFile;
      dwCount      := _fndbGetByteFromFile;
      IF (dwCount = 0)
        THEN  dwCount := aNumOfCodes;
      {if-then}

    {* check user numbers *}
      IF ((System.Word(dbInitOfs)+dwCount) > aNumOfCodes)
        THEN  dwCount := aNumOfCodes - dbInitOfs;
      {if-then}

    FOR  dbIndex := 0 to (dwCount-1) DO
       gchCodeTranslateTable[dbInitOfs+dbIndex] := System.Char(_fndbGetByteFromFile);
    {for-to-do}

    {* close this file if no need more *}
      System.Close(fBinaryStream);

    {* enable global translation *}
      gbTransModeOK := System.True;
END;  { _LoadCodeTranslFile }


PROCEDURE  _UserErrorReport(sMessage : STRING; bAddRetryAsk,bYesNo : System.Boolean);
{* ask user to recover a error condition. }
VAR
 chUserExit  :  System.Char;
 chOtherKey  :  System.Char;

BEGIN
          _OutputTextStrLn(asBlankStr);
          _OutputTextStr(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) + sMessage);

          IF (bAddRetryAsk)
            THEN  _OutputTextStr(Strings.StrPas(gszMsgRetryAction[gdbCurLanguage]));
          {if-then}

          IF (bYesNo)
            THEN  BEGIN
                chUserExit  := gchUserDontWant[gdbCurLanguage];
                chOtherKey  := gchUserWant[gdbCurLanguage];
                  END
            ELSE  BEGIN
                chUserExit  := gchUserWant[gdbCurLanguage];
                chOtherKey  := gchUserDontWant[gdbCurLanguage];
                  END;
          {if-then-else}

          IF (gbBatchModeOK)
            THEN  _OutputTextStrLn(chOtherKey)
            ELSE
              IF (_fnchUpperCase(_fnchUserAsk) = chUserExit)
                  THEN  _ErrorHalt(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                                   Strings.StrPas(gszMsgAbortOfPrint[gdbCurLanguage]),
                                     errUserBreakOfPrint);
              {if-then}
          {if-then-else}
END; {  UserErrorReport }


PROCEDURE    _PrintLine(sOutStr : STRING; bIncLineNum,bAddLineFeed : System.Boolean);
{* Writes a text line to user specified output device. *}
VAR
  dbIndex    :  System.Byte;
  dbCount    :  System.Byte;
  bBadOutput :  System.Boolean;

PROCEDURE  _UserBreakOfPrint;
{* see what user want *}
VAR
  dwUserKey     :  System.Word;
  chUserKey     :  System.Char;

BEGIN
  {** NOTE: Access to low-level system ROM BIOS routines! **}
  asm
     mov    dwUserKey, 0     { assume that no key was pressed by user }
     cmp    gbEnhancedKeyboardFound,System.True
     je     @EnhancedKbd
     mov    ah, 01h          { keystroke in buffer? }
     int    16h              { system BIOS call }
     jz     @NoKey           { exit if no available user keystroke }
     mov    ah, 0            { get ready key }
     int    16h              { system BIOS call }
     jmp    @SaveKey         { exit from inline }
   @EnhancedKbd:
     mov    ah, 11h          { extended key in buffer? }
     int    16h              { system BIOS call }
     jz     @NoKey           { exit if no available user keystroke }
     mov    ah, 10h          { get ready extended key }
     int    16h              { system BIOS call }
   @SaveKey:
     mov    dwUserKey, ax    { save to TP variable }
   @NoKey:
  END;
  {end-asm}

   CASE (dwUserKey) OF
      adwUserStopPrint   :  BEGIN
                              _UserErrorReport(Strings.StrPas(gszMsgStopPrintByUser[gdbCurLanguage]),
                                               System.True, System.True);
                            END;
      adwUserBreakPrint :   BEGIN
                              _UserErrorReport(Strings.StrPas(gszMsgUserWantBreak[gdbCurLanguage]),
                                               System.False, System.False);
                            END;
   END;
   {case-of}
END; { _UserBreakOfPrint }

BEGIN
   {* check if user want to stop print *}
     _UserBreakOfPrint;

   {* add CR/LF if need }
     IF  (bAddLineFeed)
       THEN  sOutStr := sOutStr + asPcTextLF;
     {if-then}

   {* find the # of characters in string *}
     dbCount := System.Length(sOutStr);

   {* check if print enabled **}
    IF  (System.Odd(gdwOutPageNumber))
      THEN  gbPrintOK := gbOddPagesPrintOK
      ELSE  gbPrintOK := gbEvenPagesPrintOK;
    {if-then-else}

   {** skip these pages **}
     IF (gdwSkipPagesCount <> 0)
       THEN gbPrintOK := System.False;
     {if-then}

   IF  (gbPrintOK)
   THEN
     {** output char-by-char **}
     {* Note: each string has at least two chars: CR+LF }
     FOR  dbIndex := 1  TO  dbCount  DO
     BEGIN
        {** assume that print failed **}
        bBadOutput := System.True;

        {* repeat until output successful and/or user abort the printing **}
        WHILE  (bBadOutput) DO
        BEGIN

         {**** advanced printer control if enabled ****}
           IF (gbAdvancePrintControlOK)
           THEN  WHILE NOT(_bDeviceReadyForOutput(gfOutputFileRecord.Handle))
                 DO  _UserErrorReport(Strings.StrPas(gszMsgDeviceNotReady[gdbCurLanguage]),
                                      System.True,System.True);
                 {while-do}
           {if-then}

         {** no check for errors during TP operations **}
            {$I-} System.Write(gfOutputStream,sOutStr[dbIndex]); {$I+}

         {** our solution is based on error return code **}
           IF (System.IOResult <> errOK)
             THEN
                _UserErrorReport(Strings.StrPas(gszMsgWriteFault[gdbCurLanguage]),
                                 System.True,System.True)
             ELSE
                bBadOutput := System.False;
           {if-then-else}
        END;
        {while-do}
     END;
     {for-to-do}

   {** display print info: page,line **}
     IF (bIncLineNum) THEN
     BEGIN
       System.Inc(gdwCurrentLineOnPage);
       IF  ((gbPrintOK) AND (gbPrintStatisticsOK)) THEN
         BEGIN
            _OutputTextStr(achCR);
            _OutputTextStr(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                           Strings.StrPas(gszMsgPrintPageNum[gdbCurLanguage]) +
                           _fnsNumToStr(gdwOutPageNumber,0) +
                           Strings.StrPas(gszMsgPrintLineNum[gdbCurLanguage]) +
                           _fnsNumToStr(gdwCurrentLineOnPage,0) +
                           asSpaces4);
         END;
         {if-then}
     END;
     {if-then}

END;  { _PrintLine }


PROCEDURE    _FormFeed;
{* Output a form feed code. *}
BEGIN
   _PrintLine(achFF,System.False,System.False);
END;  { _FormFeed }


PROCEDURE    _SkipLinesOnPrint(dwCount : System.Word;bIncLineNum : System.Boolean);
{* Output empty lines. *}
VAR
  dwIndex : System.Word;

BEGIN
   IF  (dwCount <> 0)  THEN
      FOR dwIndex := 1 TO  dwCount  DO _PrintLine(asBlankStr,bIncLineNum,System.True);
      {for-to-do}
   {if-then}
END;  { _FormFeed }


PROCEDURE    _PrintPageHeader(dwPageNum : System.Word);
{* Output a page header. }
VAR
  sHeaderStr            :  STRING;
  sTemp                 :  STRING;
  dbFillLength          :  System.Byte;
  dbHeaderHeight        :  System.Byte;

BEGIN
  IF  (gdwHeaderLevel > 0)  THEN
    BEGIN
      {* put a file name in N-char field for DOS *}
        dbFillLength := aDosFileNameLength;
        sHeaderStr := gsInFileNameStr+gsInFileExtStr;

      {** fill the remainder with spaces **}
        WHILE  ( System.Length(sHeaderStr) < dbFillLength ) DO
           System.Insert(achBlank,sHeaderStr,System.Length(sHeaderStr)+1);
        {while-do}

      {* put a current date/time at center of line *}
        sTemp := gsPrintDateStamp;
        dbFillLength := (gdwOutLineWidth -(System.Length(sTemp)+System.Length(sHeaderStr))) DIV 2;
        sHeaderStr := sHeaderStr + _fnsAddSpaces(dbFillLength);
        sHeaderStr := sHeaderStr + sTemp;

      {* add page number at end of line *}
        sTemp := Strings.StrPas(gszMsgPage[gdbCurLanguage]) + _fnsNumToStr(dwPageNum,0);
        dbFillLength := gdwOutLineWidth - (System.Length(sTemp));
          WHILE  ( System.Length(sHeaderStr) < dbFillLength ) DO
              System.Insert(achBlank,sHeaderStr,System.Length(sHeaderStr)+1);
          {while-do}
        sHeaderStr := sHeaderStr + sTemp;

      {** output a header **}
        _PrintLine(_fnsFormatLineFromLeftSide(sHeaderStr),System.True,System.True);
    END;
    {if-then}

  {** output the file time/date at the creating moment**}
    IF  (gdwHeaderLevel > 1)  THEN
      BEGIN
         sTemp := Strings.StrPas(gszMsgTimeOfFileCreate[gdbCurLanguage]) + gsFileDateStamp;
        _PrintLine(_fnsFormatLineFromLeftSide(sTemp),System.True,System.True);
      END;
    {if-then}

  {** output user additional information **}
    IF  (gdwHeaderLevel > 2)  THEN
      BEGIN
        dbHeaderHeight := gdwHeaderLevel-2;

        IF  (gsHeaderText <> asBlankStr)
          THEN  BEGIN
           _PrintLine(_fnsFormatLineFromLeftSide(gsHeaderText),System.True,System.True);
            System.Dec(dbHeaderHeight);
               END;
        {if-then}

          WHILE (dbHeaderHeight <> 0) DO
          BEGIN
            _SkipLinesOnPrint(1,System.True);
             System.Dec(dbHeaderHeight);
          END;
          {while-do}

      END;
      {if-then}
END; { _PrintPageHeader }


PROCEDURE    _WriteLineToOutputStream(sInputStr : STRING;bIncLineCount : System.Boolean);
{* Writes only one string to stream. *}
BEGIN
    {** move to top of next page **}
    IF (gdwCurrentLineOnPage > gdwOutLinesOnPage)
              THEN
    BEGIN
       _FormFeed;

        {* check for total enabled pages to print *}
          IF (gbPrintNotAllPages) AND (gdwSkipPagesCount = 0)
            THEN  System.Dec(gdwPrintPagesCount);
          {if-then}

        IF (gbPrintNotAllPages) AND ((gdwPrintPagesCount) = 0)
          THEN  BEGIN
                   gbPrintDone := System.True;
                 {* terminates a current proc immediately *}
                   System.Exit;
                END;
        {if-then}

      {* start a new page *}
        System.Inc(gdwOutPageNumber);
        gdwCurrentLineOnPage := 1;

        {** decrement by one **}
          IF (gdwSkipPagesCount <> 0)
            THEN  System.Dec(gdwSkipPagesCount);
          {if-then}
    END;
    {if-then}

    {** skip top lines **}
      IF   (gdwCurrentLineOnPage = 1)   THEN
        BEGIN
          _SkipLinesOnPrint(gdwMarginTop,System.False);
        END;
      {if-then}

    {** output the header information **}
      IF  (gdwHeaderLevel <> 0) AND (gdwCurrentLineOnPage = 1)  THEN
        BEGIN
              _PrintPageHeader(gdwOutPageNumber);
              _SkipLinesOnPrint(1,System.True);
        END;
      {if-then}

   {* output the line from the input stream **}
      _PrintLine(sInputStr,bIncLineCount,System.True);
END; { _WriteLineToOutputStream }


PROCEDURE    _ProcessLine(szInput : System.PChar);
{* Output the formatting text line. *}
VAR
  sTemp       :  STRING;
  szAdjust    :  ARRAY[0..SizeOf(STRING)]  OF  System.Char;
  sNumTemp    :  STR10;
  szNumTemp   :  ARRAY[0..SizeOf(STR10)+1] OF  System.Char;
  dwIndex     :  System.Word;
  dwCount     :  System.Word;
  dwStrSize   :  System.Word;

BEGIN
   {* at first call code-translation proc *}
     IF (gbTransModeOK)
       THEN  szInput := _fnszTranslateCodes(szInput);
     {if-then}

   {* strip off unwanted char codes *}
     szInput :=_fnszRemoveUnusedAsciiCodes(szInput);

   {** high bit off if need **}
     IF (gbWordStarModeOK)
       THEN  szInput := _fnszWordStar(szInput);
     {if-then}

   {** de-tabulation process **}
     IF (gdbTabCols <> aNoHTabSpaces)
       THEN  szInput := _fnszDeTabString(szInput);
     {if-then}

   {* add line number if need *}
    IF  (gdwLineNumber <> 0)
      THEN  sNumTemp := _fnsNumToStr(gdwOutLineNum,6) + asSpaces4
      ELSE  sNumTemp := asBlankStr;
    {if-then-else}

  {* automatical adjusting *}

    dwIndex := 0;
    WHILE  (szInput[dwIndex] = achBlank)  DO
    BEGIN
       System.Inc(dwIndex);
    END;
    {while-do}
    dwCount := dwIndex;

    szInput := _fnpszInsertString(szInput,Strings.StrPCopy(szNumTemp,sNumTemp),aMaxSymInStr);


   IF (sNumTemp <> asBlankStr)
     THEN  BEGIN
         System.Inc(dwCount,SizeOf(STR10)-1);
           END;
   {if-then}
   System.FillChar(szAdjust[0],dwCount,achBlank);
   szAdjust[dwCount] := achNULL;

   {** main algorithm to print one line **}
     dwStrSize := Strings.StrLen(szInput);
     REPEAT
     IF (dwStrSize >= gdwOutLineWidth)
       THEN  {* output main line *}
             BEGIN
           System.Move(szInput[0],sTemp[1],gdwOutLineWidth);
           sTemp[0] := System.Char(System.Lo(gdwOutLineWidth));
           _WriteLineToOutputStream(_fnsFormatLineFromLeftSide(sTemp),System.True);
           System.Move(szInput[gdwOutLineWidth],szInput[0],dwStrSize-gdwOutLineWidth+1+1);
           szInput := _fnpszInsertString(szInput,szAdjust,aMaxSymInStr);
             END
       ELSE  {* output a remainder and/or empty line *}
            BEGIN
          _WriteLineToOutputStream(_fnsFormatLineFromLeftSide(Strings.StrPas(szInput)),System.True);
          System.Inc(gdwOutLineNum);
          szInput := asBlankStr;  {* force empty string *}
             END;
     {if-then-else}
     dwStrSize := Strings.StrLen(szInput);
     UNTIL (dwStrSize = 0);
     {repeat-until}

   {* add line spacing *}
      dwCount := gdwLineSpacing;

    WHILE (dwCount <> 0) DO
      BEGIN
          _SkipLinesOnPrint(1,System.True);
          System.Dec(dwCount);
      END;
      { while-do }
END; { _ProcessLine }


PROCEDURE  _ParseScriptFile(sScriptName : STR80);
{* Processing of the script file that must contain settings for printing. *}
VAR
  fStruc       :          System.Text;
  sInputLine   :          STRING;
  bReadOk      :          System.Boolean;

BEGIN
    {** debug message **}
      _OutputTextStrLn(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                       Strings.StrPas(gszMsgScriptFile[gdbCurLanguage]) +
                       sScriptName);

  {** attempt to open the file **}
    System.Assign(fStruc,sScriptName);

  {** turn I/O check off at file opening **}
    {$I-}  System.Reset(fStruc);  {$I+}

  {** check if the file successfull opened **}
    IF  (System.IoResult <> errOK)
        THEN  _ErrorHalt(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                         Strings.StrPas(gszMsgFileNotFound[gdbCurLanguage]) +
                         sScriptName,
                           errBinOpenFailed);
    {if-then}

    WHILE  NOT(System.Eof(fStruc)) DO
    BEGIN
        bReadOk := System.False;
        REPEAT
          {$I-} System.ReadLn(fStruc,sInputLine); {$I+}
          IF  (System.IoResult = errOK)
             THEN  bReadOk := System.True
             ELSE  _UserErrorReport(Strings.StrPas(gszMsgReadFail[gdbCurLanguage]),
                                    System.True,System.True);
          {if-then-else}
        UNTIL (bReadOk);
        {repeat-until}

        IF ((sInputLine <> asBlankStr) AND (sInputLine[1] <> achComment))
           THEN  _ProcessOneCommand(_fnsRemoveLeadChars(sInputLine));
        {if-then}
    END;
    { while-do }

  {** if reading was successful then close this file **}
    System.Close(fStruc);
END; { _ParseScriptFile }


PROCEDURE  _ProcessOneCommand(sCommand : STRING);
{* table-driven parse algorithm. *}
VAR
  sParameter       :  STRING;
  chSwitch         :  System.Char;
  chSubSwitch      :  System.Char;
  dbTemp           :  System.Byte;
  bSwitchVal       :  System.Boolean;

BEGIN
      {* initial parsing *}
      chSwitch := System.Upcase(sCommand[2]);
      chSubSwitch := System.Upcase(sCommand[3]);
      System.Delete(sCommand,1,3);

      {** go through the multiple tests **}
      CASE  chSwitch  OF
             aFileSwitch  :
                     CASE  chSubSwitch  OF
                             aConfigCmd  :
                                         BEGIN
                  gsCmdFileName := _fnsRemoveLastColon(_fnsUpcaseStr(sCommand));
                              IF  (gsCmdFileName <> asBlankStr)
                                THEN  _ParseScriptFile(gsCmdFileName);
                              {if-then}
                                         END;
                             aSourceCmd  :
                  gsInFileName  := _fnsRemoveLastColon(_fnsUpcaseStr(sCommand));
                             aDestinationCmd  :
                  gsOutFileName := _fnsRemoveLastColon(_fnsUpcaseStr(sCommand));
                              aWordStarCmd  :
                  gbWordStarModeOK := _fnbGetValue(sCommand);
                              aFirstBinaryCmd  :
                  gsStartBinaryFileName := _fnsRemoveLastColon(_fnsUpcaseStr(sCommand));
                               aLastBinaryCmd  :
                  gsEndBinaryFileName := _fnsRemoveLastColon(_fnsUpcaseStr(sCommand));
                                 aTransCodesCmd  :
                  gsTranslBinFileName := _fnsRemoveLastColon(_fnsUpcaseStr(sCommand));
                     ELSE
                           _BadSwitchFound(Strings.StrPas(gszMsgBadFileSwitch[gdbCurLanguage]));
                     END;
                     {case-of}
             aControlSwitch  :
                     CASE  chSubSwitch  OF
                              aStatisticsCmd  :
                                     gbPrintStatisticsOK := _fnbGetValue(sCommand);
                               aAdvancedCtrlCmd  :
                                     gbAdvancePrintControlOK := _fnbGetValue(sCommand);
                               aBatchCmd  :
                                     gbBatchModeOK := _fnbGetValue(sCommand);
                               aCtrlCodesCmd  :   BEGIN
                                     gbAsciiControlCharsOff  := _fnbGetValue(sCommand);
                                     IF (gbAsciiControlCharsOff)
                                       THEN  System.Move(gbAvailAsciiCtrlCodesTable[aMinCtrlCodeChar],
                                                         gbAvailAsciiCodesTable[aMinCodeChar],
                                                         aMaxCtrlCodeChar+1);
                                     {if-then}
                                                   END;
                               aTabCmd  :
                                     gdbTabCols := _fndwGetNum(sCommand);
                               aCtrlCharCodeCmd  :
                                          BEGIN
                                     dbTemp := System.Length(sCommand);
                                     bSwitchVal := _fnbGetValue(sCommand[dbTemp]);
                                     System.Delete(sCommand,dbTemp,1);
                                     dbTemp := _fndwGetNum(sCommand);
                                     IF ((aMinCodeChar <= dbTemp) AND (dbTemp <= aMaxCodeChar))
                                       THEN  gbAvailAsciiCodesTable[dbTemp] := bSwitchVal
                                       ELSE  _BadSwitchFound(Strings.StrPas(gszMsgBadCtrlCode[gdbCurLanguage]));
                                     {if-then-else}
                                          END;
                               aLanguageCmd  :
                                          BEGIN
                                     dbTemp := _fndwGetNum(sCommand);
                                     IF (dbTemp <= aMaxLangNum) AND (gbLanguagesArray[dbTemp])
                                       THEN   gdbCurLanguage := dbTemp
                                       ELSE   _BadSwitchFound(Strings.StrPas(gszMsgBadLangSwitch[gdbCurLanguage]));
                                     {if-then-else}
                                           END;
                        ELSE
                           _BadSwitchFound(Strings.StrPas(gszMsgPrintCtrlSwitch[gdbCurLanguage]));
                        END;
                        {case-of}
             aPageSwitch  :
                     CASE  chSubSwitch  OF
                              aHeightCmd  :
                                     gdwPageHeight := _fndwGetNum(sCommand);
                               aWidthCmd  :
                                     gdwPageWidth := _fndwGetNum(sCommand);
                               aPageNumberCmd  :
                                     gdwPageNumber := _fndwGetNum(sCommand);
                               aSkipPagesCmd  :
                                     gdwSkipPagesCount := _fndwGetNum(sCommand);
                               aCountPagesCmd  :  BEGIN
                                     gdwPrintPagesCount := _fndwGetNum(sCommand);
                                     gbPrintNotAllPages := System.True;
                                                  END;
                               aPrintEvenCmd  :
                                     gbEvenPagesPrintOK := _fnbGetValue(sCommand);
                               aPrintOddCmd  :
                                     gbOddPagesPrintOK := _fnbGetValue(sCommand);
                        ELSE
                           _BadSwitchFound(Strings.StrPas(gszMsgBadPageSwitch[gdbCurLanguage]));
                        END;
                        {case-of}
             aHeaderSwitch  :
                     CASE  chSubSwitch  OF
                              aHdrLevelCmd  :
                                    gdwHeaderLevel := _fndwGetNum(sCommand);
                              aHdrTextCmd  :
                                       BEGIN
                                          IF (sCommand = asBlankStr) THEN
                                           BEGIN
                                             _OutputTextStr(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                                                            Strings.StrPas(gszMsgUserHeader[gdbCurLanguage]));
                                             System.ReadLn(sCommand);
                                           END;
                                           {if-then}
                                          gsHeaderText := sCommand;
                                       END;
                        ELSE
                           _BadSwitchFound(Strings.StrPas(gszMsgBadHeaderSwitch[gdbCurLanguage]));
                        END;
                        {case-of}
             aLineSwitch  :
                     CASE  chSubSwitch  OF
                             aLineNumCmd  :
                                    gdwLineNumber := _fndwGetNum(sCommand);
                             aLineSpacingCmd  :
                                    gdwLineSpacing := _fndwGetNum(sCommand);
                        ELSE
                           _BadSwitchFound(Strings.StrPas(gszMsgBadLineSwitch[gdbCurLanguage]));
                        END;
                        {case-of}
             aMarginSwitch  :
                     CASE  chSubSwitch  OF
                             aLeftMarginCmd  :
                                    gdwMarginLeft := _fndwGetNum(sCommand);
                             aRightMarginCmd  :
                                    gdwMarginRight := _fndwGetNum(sCommand);
                             aTopMarginCmd  :
                                    gdwMarginTop := _fndwGetNum(sCommand);
                             aBottomMarginCmd  :
                                    gdwMarginBottom := _fndwGetNum(sCommand);
                         ELSE
                            _BadSwitchFound(Strings.StrPas(gszMsgBadMarginSwitch[gdbCurLanguage]));
                         END;
                         {case-of}
      ELSE
          _BadSwitchFound(Strings.StrPas(gszMsgBadSwitchFound[gdbCurLanguage]));
      END;
      {case-of}
END;  { _ProcessOneCommand }


PROCEDURE    _ParseCommandLine(dbFirstParmIndex,dbLastParmIndex : System.Byte);
{* Read the user suggested settings for text formatting. *}
VAR
  sParameter       :  STRING;
  chSwitch         :  System.Char;
  dbIndex          :  System.Byte;

BEGIN
   {** parse all parameters **}
   FOR dbIndex := dbFirstParmIndex TO dbLastParmIndex DO
   BEGIN
      {** !!ATTENTION!! This algorithm is based on two-char keyword for each switch **}
      sParameter := System.ParamStr(dbIndex);
      chSwitch := sParameter[1];

      {** test for switch present **}
      IF  ((chSwitch <> achDosSwitch) AND (chSwitch <> achUnixSwitch))
        THEN  _BadSwitchFound(Strings.StrPas(gszMsgBadPrefixSwitch[gdbCurLanguage]));
      {if-then}

      _ProcessOneCommand(sParameter);

   END;
   {for-to-do}
END;  { _ParseCommandLine }


PROCEDURE _ProgramHelp;
{* Output help screen for user *}
BEGIN
  {* copyright notice *}
  _CopyrightDisplay;

  {* small help *}
   _OutputTextStrLn(Strings.StrPas(gszProgramPrompt[gdbCurLanguage])+
                    Strings.StrPas(gszMsgHelp00A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp01A[gdbCurLanguage])+
                    Strings.StrPas(gszUProgram[gdbCurLanguage])+
                    Strings.StrPas(gszMsgHelp01B[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp02A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp03A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp04A[gdbCurLanguage]));
   _OutputTextStrLn(asLongLine);
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp05A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp06A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp07A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp08A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp09A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp10A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp11A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp12A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp13A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp14A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp15A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp16A[gdbCurLanguage])+
                    _fnsNumToStr(aDefLang,0)+
                    ' (='+
                    _fnsCurrentLanguage(aDefLang)+
                    ')');
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp17A[gdbCurLanguage])+
                    _fnsNumToStr(aDefTabCols,0)+
                    Strings.StrPas(gszMsgHelp17B[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp18A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp19A[gdbCurLanguage])+
                    _fnsNumToStr(aDefLineNumber,0)+
                    Strings.StrPas(gszMsgHelp19B[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp20A[gdbCurLanguage])+
                    +_fnsNumToStr(aDefLineSpacing,0)+
                    Strings.StrPas(gszMsgHelp20B[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp21A[gdbCurLanguage])+
                    _fnsNumToStr(aDefPageHeight,0)+
                    Strings.StrPas(gszMsgHelp21B[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp22A[gdbCurLanguage])+
                    _fnsNumToStr(aDefPageWidth,0)+
                    Strings.StrPas(gszMsgHelp22B[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp23A[gdbCurLanguage])+
                    _fnsNumToStr(aDefPageNumber,0));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp24A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp25A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp26A[gdbCurLanguage])+
                    _fnsNumToStr(aDefPagesSkipCount,0)+
                    Strings.StrPas(gszMsgHelp26B[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp27A[gdbCurLanguage])+
                    _fnsNumToStr(aDefPagesPrintCount,0)+
                    Strings.StrPas(gszMsgHelp27B[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp28A[gdbCurLanguage])+
                    _fnsNumToStr(aDefMarginTop,0));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp29A[gdbCurLanguage])+
                    _fnsNumToStr(aDefMarginBottom,0));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp30A[gdbCurLanguage])+
                    _fnsNumToStr(aDefMarginLeft,0));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp31A[gdbCurLanguage])+
                    _fnsNumToStr(aDefMarginRight,0));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp32A[gdbCurLanguage])+
                   _fnsNumToStr(aDefHeaderLevel,0));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp33A[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp33B[gdbCurLanguage]));
   _OutputTextStrLn(Strings.StrPas(gszMsgHelp34A[gdbCurLanguage])+
                    asShortExample);
END; { _ProgramHelp }


PROCEDURE  _InitInternals;
{* initialize some internal variables. *}
BEGIN
   {* access to System BIOS variable *}
   IF ((System.Mem[$40:$96] AND $10) <> 0)
     THEN  gbEnhancedKeyboardFound := System.True;
   {if-then}
END; { _InitInternals }


{*============================== MAIN PART =============================*}

BEGIN

  {* some housekeeping *}
    _InitInternals;

  {* do user want something? *}
     IF (System.ParamCount = 0) THEN
       BEGIN
          _ProgramHelp;
          _ErrorHalt(asBlankStr,errBadParmsNumber);
       END;
     {if-then}


  {** read all user parameters **}
     _ParseCommandLine(1,System.LO(System.ParamCount)); { if-then }


  {* exit if no source file for print *}
    IF (gsInFileName = asBlankStr)
      THEN BEGIN
              _ProgramHelp;
              _ErrorHalt(asBlankStr,errNoSourceFileName);
           END;
    {if-then}


  {* copyright notice *}
    _CopyrightDisplay;


  {** recalculate the print settings **}
     gdwOutLineWidth    := gdwPageWidth - (gdwMarginLeft+gdwMarginRight);
     gdwOutPageNumber   := gdwPageNumber;
     gdwOutLinesOnPage  := gdwPageHeight - (gdwMarginTop+gdwMarginBottom);
     gdwFirstPageNumber := gdwPageNumber + gdwSkipPagesCount;


  {* same names? *}
    IF (gsInFileName = gsOutFileName)
      THEN  _ErrorHalt(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                       Strings.StrPas(gszMsgSameFilesNotAllowed[gdbCurLanguage]),
                         errSameNames);
    {if-then}

  {** source file exists? **}
    IF  NOT(_fnbBinFileExist(gfInputStream,gsInFileName))
      THEN  _ErrorHalt(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                       Strings.StrPas(gszMsgFileNotFound[gdbCurLanguage]) +
                       gsInFileName,
                         errSourceNotFound);
    {if-then}

  {** may be destination file present? **}
    IF (_fnbTextFileExist(gfOutputStream,gsOutFileName))  THEN
    BEGIN
      _OutputTextStr(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                                   Strings.StrPas(gszMsgOutFile[gdbCurLanguage]) +
                                   gsOutFileName +
                                   Strings.StrPas(gszMsgAlreadyExists[gdbCurLanguage]));
      IF (gbBatchModeOK)
        THEN  _OutputTextStrLn(gchUserWant[gdbCurLanguage])
        ELSE  IF (_fnchUpperCase(_fnchUserAsk) <> gchUserWant[gdbCurLanguage])
                       THEN  _ErrorHalt(asBlankStr,errDestDontWrite);
      {if-then-else}
    END;
    {if-then}


  {** open the source file **}
    System.Assign(gfInputStream,gsInFileName);
    System.InOutRes := errOK;                 { fix an errata in TP-RTL }
    gdbOpenFileMode := System.FileMode;       { access to TP internal var }
    System.FileMode := $20;                   { read, deny write on sharing }
    {$I-} System.Reset(gfInputStream); {$I+}
    System.FileMode := gdbOpenFileMode;       { restore TP internal var }


  {** stop if open failed **}
    IF  (System.IOResult <> errOK)
      THEN  _ErrorHalt(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                       Strings.StrPas(gszMsgFileNotFound[gdbCurLanguage]) +
                       gsInFileName,
                        errSrcOpenFailed);
    {if-then}

  {** create the destination file **}
    System.Assign(gfOutputStream,gsOutFileName);
    {$I-} System.Rewrite(gfOutputStream); {$I+}

  {** creation failed? **}
    IF  (System.IOResult <> errOK)
      THEN   _ErrorHalt(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                        Strings.StrPas(gszMsgFileNotCreated[gdbCurLanguage]) +
                        gsOutFileName,
                         errDestCreateFailed);
    {if-then}

  {** load binary file if need **}
    IF  (gsStartBinaryFileName <> asBlankStr)
      THEN  _LoadBinaryFile(gsStartBinaryFileName);
    {if-then}


  {** load code translation file if need **}
    IF  (gsTranslBinFileName <> asBlankStr)
      THEN  _LoadCodeTranslFile(gsTranslBinFileName);
    {if-then}


  {** splite a input/output filenames **}
    Dos.FSplit(gsInFileName,gsInFileDirStr,gsInFileNameStr,gsInFileExtStr);
    Dos.FSplit(gsOutFileName,gsOutFileDirStr,gsOutFileNameStr,gsOutFileExtStr);


  {** get current date/time **}
    Dos.GetDate(gdwCurrentYear,gdwCurrentMonth,gdwCurrentDay,gdwCurrentWeekDay);
    Dos.GetTime(gdwCurrentHour,gdwCurrentMinute,gdwCurrentSec,gdwCurrentSec100);


  {** get input file date/time **}
    Dos.GetFTime(gfInputStream,gliFileTime);
    Dos.UnpackTime(gliFileTime,grecFileDateTime);
    WITH grecFileDateTime DO
           gdwFileDayOfWeek := _fndwCalcDayOfWeek(Year,
                                                  Month,
                                                  Day,
                                                  gdwCurrentYear,
                                                  gdwCurrentMonth);
    {with-do}

  {** user message: source -> destination **}
    _OutputTextStrLn(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                     Strings.StrPas(gszMsgPrintStart[gdbCurLanguage]) +
                     gsInFileNameStr +
                     gsInFileExtStr +
                     Strings.StrPas(gszMsgTo[gdbCurLanguage]) +
                     gsOutFileNameStr +
                     gsOutFileExtStr);

  {** get file date/time **}
    WITH grecFileDateTime  DO
            gsFileDateStamp  := _fnsDateTimeStamp(Year,
                                                  Month,
                                                  Day,
                                                  gdwFileDayOfWeek,
                                                  Hour,
                                                  Min);
    {with-do}

  {** get print date/time **}
     gsPrintDateStamp := _fnsDateTimeStamp(gdwCurrentYear,
                                           gdwCurrentMonth,
                                           gdwCurrentDay,
                                           gdwCurrentWeekDay,
                                            gdwCurrentHour,
                                            gdwCurrentMinute);

  {** user message: valid keys during the printing **}
    _OutputTextStrLn(Strings.StrPas(gszProgramPrompt[gdbCurLanguage]) +
                     Strings.StrPas(gszMsgUserAvailableKeys[gdbCurLanguage]));

  {** set a pointer **}
  gpszLargeInBuf := @gszLargeInBuf;

  {** main loop: read_line/process_line **}
  WHILE  (NOT(gbPrintDone)) AND NOT(System.Eof(gfInputStream)) DO
  BEGIN
    _ProcessLine(_fnszFileRead(gfInputStream,gpszLargeInBuf));
  END;
  { while-do }


  {** output last line **}
    _FormFeed;

  {** load binary file if need **}
    IF  (gsEndBinaryFileName <> asBlankStr)
      THEN  BEGIN
         _OutputTextStrLn(asBlankStr);
         _LoadBinaryFile(gsEndBinaryFileName);
           END;
    {if-then}

  {** write End-Of-File **}
    _PrintLine(achDosEndFile,System.False,System.False);

  {** close all files **}
    System.Close(gfInputStream);
    System.Close(gfOutputStream);

  {** put newline char and write report**}
    _OutputTextStrLn(asBlankStr);
    IF (gbPrintStatisticsOK)
       THEN  _OutputTextStrLn(Strings.StrPas(gszProgramPrompt[gdbCurLanguage])+
                              Strings.StrPas(gszMsgPrintDone[gdbCurLanguage])+
                              _fnsNumToStr(gdwFirstPageNumber,0)+
                              asMsgHyphen+
                              _fnsNumToStr(gdwOutPageNumber,0));
    {if-then}

  {* System.Halt(errTerminateOk); *}

END.
