{****************************************************************************
//                            File MESSAGES.INC
//
//                    International support module
//
//      Copyright (c) 1993, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/LPRINT/RCS/messages.inc $
//  $RCSfile: messages.inc $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:26:42 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: messages.inc $
//      Revision 1.1  1998/10/03 14:26:42  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                TEXT_LINE_PRINT                                 }
{ FILE NAME             MESSAGES.INC                                    }
{ PURPOSE               Text Messages for Main Module                   }
{ VERSION               1.03                                            }
{ DATE                  02-Aug-1997                                     }
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
{                       (Borland International Inc.), or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             See command line syntax description             }
{ RETURN                See error return codes definitions              }
{ REQUIRES              Source Code Files                               }
{                       NONE                                            }
{                       External Object Files                           }
{                       NONE                                            }
{ NATURAL LANGUAGE      A. English Language                             }
{                       B. Russian Language                             }
{                       C. Germany Language                             }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       P.Fischer-Haaser (FH)                           }
{                       1.00  20-Oct-93  DS  initilal release           }
{                       1.01  30-Jan-95  FH  updated German language    }
{                                            translation                }
{                       1.02  26-Jul-97  DS  updated documentation      }
{                       1.03  02-Aug-97  DS  removed tabs               }
{-----------------------------------------------------------------------}


 {*****************  Support of ENGLISH  ***************}

   { global scope }
 {$IFDEF EnglishVersion}
     abEnglishAvail             =       System.True;
 {$ELSE}
     abEnglishAvail             =       System.False;
 {$ENDIF}


   { program descriptions }
     asPurposeEngl               =      'LPrint Utility';
     asAuthorEngl                =      'Dima Stefankov';
     asCopyrightEngl             =      'Copyright (c)';
     asMsgVersionEngl            =      '  Version ';
     asProgramEngl               =      'LPrint';
     asProgramPromptEngl         =      asProgramEngl+': ';
     asUProgramEngl              =      'LPRINT';

  { languages }
     asEnglishLanguageEngl       =      'English';
     asRussianLanguageEngl       =      'Russian';
     asGermanyLanguageEngl       =      'Germany';

  { user response }
    achUserWantEngl              =      'Y';
    achUserDontWantEngl          =      'N';

  { string constants }
    asSwValON_Engl               =      '(=on)';
    asSwValOFF_Engl              =      '(=off)';
    asSwValNONE_Engl             =      '(=none)';
    asAllChars_Engl              =      'all chars enabled';

  { program messages }
    asMsgBadBooleanSwitchEngl    =      'Bad boolean switch present in command line.';
    asMsgBadNumericFoundEngl     =      'Bad numeric format present in command line.';
    asMsgBadSwitchFoundEngl      =      'Non-valid';
    asMsgsMisMatchSwitchEngl     =      ' switch found in command line.';
    asMsgFileNotFoundEngl        =      'Unable to open ';
    asMsgFileNotCreatedEngl      =      'Unable to create ';
    asMsgSameFilesNotAllowedEngl =      'Unable to use same file as input and as output';
    asMsgBadPrefixSwitchEngl     =      'Invalid prefix for';
    asMsgBadMarginSwitchEngl     =      'Bad margin';
    asMsgBadLineSwitchEngl       =      'Bad line';
    asMsgBadHeaderSwitchEngl     =      'Bad header';
    asMsgBadPageSwitchEngl       =      'Bad page';
    asMsgBadFileSwitchEngl       =      'Bad filename';
    asMsgPrintCtrlSwitchEngl     =      'Bad print control';
    asMsgBadLangSwitchEngl       =      'Bad language';
    asMsgTimeOfFileCreateEngl    =      'File was created:   ';
    asMsgPageEngl                =      'Page ';
    asMsgPrintPageNumEngl        =      'Printing page  ';
    asMsgPrintLineNumEngl        =      ',  line ';
    asMsgWriteFaultEngl          =      'WriteFault';
    asMsgDeviceNotReadyEngl      =      'Output Device Not Ready';
    asMsgUserWantBreakEngl       =      'Do you want to break print? ('+achUserDontWantEngl+'/'+achUserWantEngl+'): ';
    asMsgStopPrintByUserEngl     =      'Printing off by user request';
    asMsgAbortOfPrintEngl        =      'Printing aborted by user.';
    asMsgRetryActionEngl         =      '. Retry? ('+achUserWantEngl+'/'+achUserDontWantEngl+'): ';
    asMsgOutFileEngl             =      'Output file ';
    asMsgAlreadyExistsEngl       =      ' already exists. Overwrite? ('+achUserDontWantEngl+'/'+achUserWantEngl+'): ';
    asMsgUserHeaderEngl          =      'Enter header string:';
    asMsgPrintStartEngl          =      'Printing from ';
    asMsgToEngl                  =      ' to ';
    asMsgUserAvailableKeysEngl   =      'Press '+asExitKey+' key to break of printing, '+asStopKey+' to stop of printing.';
    asMsgPrintDoneEngl           =      'Done. Pages ';
    asMsgReadFailEngl            =      'File Read Fault';
    asMsgWriteFailEngl           =      'File Write Fault';
    asMsgBadCtrlCodeEngl         =      'Bad control character code';
    asMsgLoadBinFileEngl         =      'Loading of binary file ';
    asMsgLoadTransFileEngl       =      'Loading of char code translate file ';
    asMsgScriptFileEngl          =      'Parse script file ';
    asMsgAMEngl                  =      'am';
    asMsgPMEngl                  =      'pm';

  { help screen }
    asMsgHelp00A_Engl            =      'short help screen for you.';
    asMsgHelp01A_Engl            =      'Usage: ';
    asMsgHelp01B_Engl            =      ' [Options], where';
    asMsgHelp02A_Engl            =      '  Options may be preceded by either '+achDosSwitch+' or '+achUnixSwitch+'.';
    asMsgHelp03A_Engl            =      '  Valid options (all no case-sensitive) are as follows:';
    asMsgHelp04A_Engl            =      '      switch     |          meaning              |    default';
    asMsgHelp05A_Engl            =      asHelpIndent+aFileSwitch+aConfigCmd+'str      |     config filename           |  '+
                                        'empty '+asSwValNONE_Engl;
    asMsgHelp06A_Engl            =      asHelpIndent+aFileSwitch+aSourceCmd+'str      |     source filename           |  '+
                                        'empty '+asSwValNONE_Engl;
    asMsgHelp07A_Engl            =      asHelpIndent+aFileSwitch+aDestinationCmd+'str      |     dest   filename           |'+
                                        '  '+asStdDosPrintDevice;
    asMsgHelp08A_Engl            =      asHelpIndent+aFileSwitch+aWordStarCmd+'[-|+]    |     WordStar files            |  '+
                                        achSwitchOFF+achBlank+asSwValOFF_Engl;
    asMsgHelp09A_Engl            =      asHelpIndent+aFileSwitch+aFirstBinaryCmd+'str      |     binfile load at start     |'+
                                        '  empty '+asSwValNONE_Engl;
    asMsgHelp10A_Engl            =      asHelpIndent+aFileSwitch+aLastBinaryCmd+'str      |     binfile load at end       |'+
                                        '  empty '+asSwValNONE_Engl;
    asMsgHelp11A_Engl            =      asHelpIndent+aFileSwitch+aTransCodesCmd+'str      |     translate table file      |'+
                                        '  empty '+asSwValNONE_Engl;
    asMsgHelp12A_Engl            =      asHelpIndent+aControlSwitch+aStatisticsCmd+'[-|+]    |     output statistics        '+
                                        ' |  '+
                                        achSwitchON+achBlank+asSwValON_Engl;
    asMsgHelp13A_Engl            =      asHelpIndent+aControlSwitch+aAdvancedCtrlCmd+'[-|+]    |     advanced control       '+
                                        '   |  '+achSwitchOFF+achBlank+asSwValOFF_Engl;
    asMsgHelp14A_Engl            =      asHelpIndent+aControlSwitch+aBatchCmd+'[-|+]    |     batch mode control        |  '+
                                        achSwitchOFF+achBlank+asSwValOFF_Engl;
    asMsgHelp15A_Engl            =      asHelpIndent+aControlSwitch+aCtrlCodesCmd+'[-|+]    |     strip control chars       '+
                                        '|  '+achSwitchOFF+achBlank+asSwValOFF_Engl;
    asMsgHelp16A_Engl            =      asHelpIndent+aControlSwitch+aLanguageCmd+'n        |     select language           |'+
                                        '  ';
    asMsgHelp17A_Engl            =      asHelpIndent+aControlSwitch+aTabCmd+'n        |     set htab size             |  ';
    asMsgHelp17B_Engl            =      ' (spaces)';
    asMsgHelp18A_Engl            =      asHelpIndent+aControlSwitch+aCtrlCharCodeCmd+'[n[-|+]] |     toggle use of char <n> '+
                                        '   |  '+asAllChars_Engl;
    asMsgHelp19A_Engl            =      asHelpIndent+aLineSwitch+aLineNumCmd+'n        |     line numbers              |  ';
    asMsgHelp19B_Engl            =      achBlank+asSwValOFF_Engl;
    asMsgHelp20A_Engl            =      asHelpIndent+aLineSwitch+aLineSpacingCmd+'n        |     line spacing              '+
                                        '|  ';
    asMsgHelp20B_Engl            =      achBlank+asSwValOFF_Engl;
    asMsgHelp21A_Engl            =      asHelpIndent+aPageSwitch+aHeightCmd+'n        |     page height               |  ';
    asMsgHelp21B_Engl            =      ' lines';
    asMsgHelp22A_Engl            =      asHelpIndent+aPageSwitch+aWidthCmd+'n        |     page width                |  ';
    asMsgHelp22B_Engl            =      ' columns';
    asMsgHelp23A_Engl            =      asHelpIndent+aPageSwitch+aPageNumberCmd+'n        |     page number               |'+
                                        '  ';
    asMsgHelp24A_Engl            =      asHelpIndent+aPageSwitch+aPrintOddCmd+'[-|+]    |     print odd  pages          |  '+
                                        achSwitchON+achBlank+asSwValON_Engl;
    asMsgHelp25A_Engl            =      asHelpIndent+aPageSwitch+aPrintEvenCmd+'[-|+]    |     print even pages          |'+
                                        '  '+achSwitchON+achBlank+asSwValON_Engl;
    asMsgHelp26A_Engl            =      asHelpIndent+aPageSwitch+aSkipPagesCmd+'n        |     page skip                 |'+
                                        '  ';
    asMsgHelp26B_Engl            =      achBlank+asSwValNONE_Engl;
    asMsgHelp27A_Engl            =      asHelpIndent+aPageSwitch+aCountPagesCmd+'n        |     pages count to print      |'+
                                        '  ';
    asMsgHelp27B_Engl            =      ' (=all)';
    asMsgHelp28A_Engl            =      asHelpIndent+aMarginSwitch+aTopMarginCmd+'n        |     margin top                '+
                                        '|  ';
    asMsgHelp29A_Engl            =      asHelpIndent+aMarginSwitch+aBottomMarginCmd+'n        |     margin bottom          '+
                                        '   |  ';
    asMsgHelp30A_Engl            =      asHelpIndent+aMarginSwitch+aLeftMarginCmd+'n        |     margin left              '+
                                        ' |  ';
    asMsgHelp31A_Engl            =      asHelpIndent+aMarginSwitch+aRightMarginCmd+'n        |     margin right            '+
                                        '  |  ';
    asMsgHelp32A_Engl            =      asHelpIndent+aHeaderSwitch+aHdrLevelCmd+'n        |     header level              |'+
                                        '  ';
    asMsgHelp33A_Engl            =      asHelpIndent+aHeaderSwitch+aHdrTextCmd+'str      |     header text               |'+
                                        '  empty '+asSwValNONE_Engl+', ask user';
    asMsgHelp33B_Engl            =      '                 |                               |  if switch without string';
    asMsgHelp34A_Engl            =      '  Short Example';

  { day/month/year }
    aDay_01_Engl                 =      'Sunday';
    aDay_02_Engl                 =      'Monday';
    aDay_03_Engl                 =      'Tuesday';
    aDay_04_Engl                 =      'Wednesday';
    aDay_05_Engl                 =      'Thursday';
    aDay_06_Engl                 =      'Friday';
    aDay_07_Engl                 =      'Saturday';

    aMonth_01_Engl               =      'January';
    aMonth_02_Engl               =      'February';
    aMonth_03_Engl               =      'March';
    aMonth_04_Engl               =      'April';
    aMonth_05_Engl               =      'May';
    aMonth_06_Engl               =      'June';
    aMonth_07_Engl               =      'July';
    aMonth_08_Engl               =      'August';
    aMonth_09_Engl               =      'September';
    aMonth_10_Engl               =      'October';
    aMonth_11_Engl               =      'November';
    aMonth_12_Engl               =      'December';


 {*********************  Support of RUSSIAN  *****************}

   { global scope }
 {$IFDEF RussianVersion}
     abRussianAvail             =       System.True;
 {$ELSE}
     abRussianAvail             =       System.False;
 {$ENDIF}

   { program descriptions }
     asPurposeRuss              =       'Утилита Печати';
     asAuthorRuss               =       'Дима Стефанков';
     asCopyrightRuss            =       'Авторское право (с)';
     asMsgVersionRuss           =       '  Версия ';
     asProgramRuss              =       'Печать';
     asProgramPromptRuss        =       asProgramRuss+': ';
     asUProgramRuss             =       'ПЕЧАТЬ';

  { languages }
     asEnglishLanguageRuss       =       'Английский';
     asRussianLanguageRuss       =       'Русский';
     asGermanyLanguageRuss       =       'Немецкий';

  { user response }
    achUserWantRuss             =       'Д';
    achUserDontWantRuss         =       'Н';

  { string constants }
    asSwValON_Russ               =      '(=вкл.)';
    asSwValOFF_Russ              =      '(=выкл.)';
    asSwValNONE_Russ             =      '(=ничего)';
    asAllChars_Russ              =      'все символы разрешены';

  { program messages }
    asMsgBadBooleanSwitchRuss   =       'Неверен логический переключатель в командной строке.';
    asMsgBadNumericFoundRuss    =       'Неверен формат числа в командной строке.';
    asMsgBadSwitchFoundRuss     =       'Неверный';
    asMsgsMisMatchSwitchRuss    =       ' переключатель найден в командной строке.';
    asMsgFileNotFoundRuss       =       'Не найден файл ';
    asMsgFileNotCreatedRuss     =       'Не могу создать файл ';
    asMsgSameFilesNotAllowedRuss =      'Один и тот же файл для чтения и записи не рекомендуется';
    asMsgBadPrefixSwitchRuss    =       'Неверен префиксный ';
    asMsgBadMarginSwitchRuss    =       'Неверный <поле>';
    asMsgBadLineSwitchRuss      =       'Неверный <строка>';
    asMsgBadHeaderSwitchRuss    =       'Неверный <заголовок>';
    asMsgBadPageSwitchRuss      =       'Неверный <страница>';
    asMsgBadFileSwitchRuss      =       'Неверный <файл>';
    asMsgPrintCtrlSwitchRuss    =       'Неверный <контроль>';
    asMsgBadLangSwitchRuss      =       'Неверный <язык>';
    asMsgTimeOfFileCreateRuss   =       'Файл был создан:   ';
    asMsgPageRuss               =       'Страница ';
    asMsgPrintPageNumRuss       =       'Печать страницы  ';
    asMsgPrintLineNumRuss       =       ',  строки ';
    asMsgWriteFaultRuss         =       'Ошибка записи';
    asMsgDeviceNotReadyRuss     =       'Устройство для вывода не готово';
    asMsgUserWantBreakRuss      =       'Вы желаете завершить вывод? ('+achUserDontWantRuss+'/'+achUserWantRuss+'): ';
    asMsgStopPrintByUserRuss    =       'Вывод временно приостановлен';
    asMsgAbortOfPrintRuss       =       'Печать закончена по требованию пользователя.';
    asMsgRetryActionRuss        =       '. Возобновить? ('+achUserWantRuss+'/'+achUserDontWantRuss+'): ';
    asMsgOutFileRuss            =       'Выходный файл ';
    asMsgAlreadyExistsRuss      =       ' уже существует. Перезаписать? ('+achUserDontWantRuss+'/'+achUserWantRuss+'): ';
    asMsgUserHeaderRuss         =       'Введите доп. заголовок:';
    asMsgPrintStartRuss         =       'Печатать из ';
    asMsgToRuss                 =       ' в ';
    asMsgUserAvailableKeysRuss  =       'Нажмите клавишу '+asExitKey+' для выхода, '+asStopKey+' для остановки печати.';
    asMsgPrintDoneRuss          =       'Закончено. Страницы ';
    asMsgReadFailRuss           =       'Ошибка чтения из файла';
    asMsgWriteFailRuss          =       'Ошибка записи в файл';
    asMsgBadCtrlCodeRuss        =       'Неверный символьный управляющий код';
    asMsgLoadBinFileRuss        =       'Загрузка двоичного файла ';
    asMsgLoadTransFileRuss      =       'Загрузка файла перекодировки ';
    asMsgScriptFileRuss         =       'Разбор конфигурационного файла ';
    asMsgAMRuss                 =       'дп';
    asMsgPMRuss                 =       'пп';

  { help screen }
    asMsgHelp00A_Russ            =      'краткая помощь пользователю.';
    asMsgHelp01A_Russ            =      'Применение: ';
    asMsgHelp01B_Russ            =      ' [Ключи-выбора], где';
    asMsgHelp02A_Russ            =      '  Разрешены префиксные символы '+achDosSwitch+' or '+achUnixSwitch+'.';
    asMsgHelp03A_Russ            =      '  Следущие ключи-выбора доступны (большие и маленькие буквы разрешены):';
    asMsgHelp04A_Russ            =      '   переключатель |          управление           |    нач.значение';
    asMsgHelp05A_Russ            =      asHelpIndent+aFileSwitch+aConfigCmd+'строка   |     конфигурационный файл     |  '+
                                        'пусто '+asSwValNONE_Russ;
    asMsgHelp06A_Russ            =      asHelpIndent+aFileSwitch+aSourceCmd+'строка   |     файл для печати           |  '+
                                        'пусто '+asSwValNONE_Russ;
    asMsgHelp07A_Russ            =      asHelpIndent+aFileSwitch+aDestinationCmd+'строка   |     выходный файл             |'+
                                        '  '+asStdDosPrintDevice;
    asMsgHelp08A_Russ            =      asHelpIndent+aFileSwitch+aWordStarCmd+'[-|+]    |     файл в формате WordStar   |  '+
                                        achSwitchOFF+achBlank+asSwValOFF_Russ;
    asMsgHelp09A_Russ            =      asHelpIndent+aFileSwitch+aFirstBinaryCmd+'строка   |     загрузить файл до печати  |'+
                                        '  пусто '+asSwValNONE_Russ;
    asMsgHelp10A_Russ            =      asHelpIndent+aFileSwitch+aLastBinaryCmd+'строка   |     загрузить файл после печ. |'+
                                        '  пусто '+asSwValNONE_Russ;
    asMsgHelp11A_Russ            =      asHelpIndent+aFileSwitch+aTransCodesCmd+'строка   |     файл перекодировки        |'+
                                        '  пусто '+asSwValNONE_Russ;
    asMsgHelp12A_Russ            =      asHelpIndent+aControlSwitch+aStatisticsCmd+'[-|+]    |     статистика печати        '+
                                        ' |  '+achSwitchON+achBlank+asSwValON_Russ;
    asMsgHelp13A_Russ            =      asHelpIndent+aControlSwitch+aAdvancedCtrlCmd+'[-|+]    |     дополнительный контроль'+
                                        '   |  '+achSwitchOFF+achBlank+asSwValOFF_Russ;
    asMsgHelp14A_Russ            =      asHelpIndent+aControlSwitch+aBatchCmd+'[-|+]    |     пакетный режим            |  '+
                                        achSwitchOFF+achBlank+asSwValOFF_Russ;
    asMsgHelp15A_Russ            =      asHelpIndent+aControlSwitch+aCtrlCodesCmd+'[-|+]    |     выкл. управляющие символы '+
                                        '|  '+achSwitchOFF+achBlank+asSwValOFF_Russ;
    asMsgHelp16A_Russ            =      asHelpIndent+aControlSwitch+aLanguageCmd+'n        |     выбрать язык              |'+
                                        '  ';
    asMsgHelp17A_Russ            =      asHelpIndent+aControlSwitch+aTabCmd+'n        |     длина гориз. табуляции    |  ';
    asMsgHelp17B_Russ            =      ' (пробелов)';
    asMsgHelp18A_Russ            =      asHelpIndent+aControlSwitch+aCtrlCharCodeCmd+'[n[-|+]] |     использование '+
                                        'символа <n> |  '+asAllChars_Russ;
    asMsgHelp19A_Russ            =      asHelpIndent+aLineSwitch+aLineNumCmd+'n        |     номера для строк          |  ';
    asMsgHelp19B_Russ            =      achBlank+asSwValOFF_Russ;
    asMsgHelp20A_Russ            =      asHelpIndent+aLineSwitch+aLineSpacingCmd+'n        |     пробел между строками     '+
                                        '|  ';
    asMsgHelp20B_Russ            =      achBlank+asSwValOFF_Russ;
    asMsgHelp21A_Russ            =      asHelpIndent+aPageSwitch+aHeightCmd+'n        |     высота страницы           |  ';
    asMsgHelp21B_Russ            =      ' строк';
    asMsgHelp22A_Russ            =      asHelpIndent+aPageSwitch+aWidthCmd+'n        |     ширина страницы           |  ';
    asMsgHelp22B_Russ            =      ' колонок';
    asMsgHelp23A_Russ            =      asHelpIndent+aPageSwitch+aPageNumberCmd+'n        |     нумерация страниц         |'+
                                        '  ';
    asMsgHelp24A_Russ            =      asHelpIndent+aPageSwitch+aPrintOddCmd+'[-|+]    |     печатать нечетные страницы|  '+
                                        achSwitchON+achBlank+asSwValON_Russ;
    asMsgHelp25A_Russ            =      asHelpIndent+aPageSwitch+aPrintEvenCmd+'[-|+]    |     печатать четные страницы  |'+
                                        '  '+achSwitchON+achBlank+asSwValON_Russ;
    asMsgHelp26A_Russ            =      asHelpIndent+aPageSwitch+aSkipPagesCmd+'n        |     пропустить страницы       |'+
                                        '  ';
    asMsgHelp26B_Russ            =      achBlank+asSwValNONE_Russ;
    asMsgHelp27A_Russ            =      asHelpIndent+aPageSwitch+aCountPagesCmd+'n        |     кол-во страниц для печати |'+
                                        '  ';
    asMsgHelp27B_Russ            =      ' (=все)';
    asMsgHelp28A_Russ            =      asHelpIndent+aMarginSwitch+aTopMarginCmd+'n        |     верхний отступ            '+
                                        '|  ';
    asMsgHelp29A_Russ            =      asHelpIndent+aMarginSwitch+aBottomMarginCmd+'n        |     нижний отступ          '+
                                        '   |  ';
    asMsgHelp30A_Russ            =      asHelpIndent+aMarginSwitch+aLeftMarginCmd+'n        |     левый отступ             '+
                                        ' |  ';
    asMsgHelp31A_Russ            =      asHelpIndent+aMarginSwitch+aRightMarginCmd+'n        |     правый отступ           '+
                                        '  |  ';
    asMsgHelp32A_Russ            =      asHelpIndent+aHeaderSwitch+aHdrLevelCmd+'n        |     кол-во заголовков         |'+
                                        '  ';
    asMsgHelp33A_Russ            =      asHelpIndent+aHeaderSwitch+aHdrTextCmd+'строка   |     текст заголовка           |'+
                                        '  пусто '+asSwValNONE_Russ+', если';
    asMsgHelp33B_Russ            =      '                 |                               |  нет строки тогда запрос';
    asMsgHelp34A_Russ            =      '  Краткий пример';

  { day/month/year }
    aDay_01_Russ                =       'Воскресенье';
    aDay_02_Russ                =       'Понедельник';
    aDay_03_Russ                =       'Вторник';
    aDay_04_Russ                =       'Среда';
    aDay_05_Russ                =       'Четверг';
    aDay_06_Russ                =       'Пятница';
    aDay_07_Russ                =       'Суббота';

    aMonth_01_Russ              =       'Январь';
    aMonth_02_Russ              =       'Февраль';
    aMonth_03_Russ              =       'Март';
    aMonth_04_Russ              =       'Апрель';
    aMonth_05_Russ              =       'Май';
    aMonth_06_Russ              =       'Июнь';
    aMonth_07_Russ              =       'Июль';
    aMonth_08_Russ              =       'Август';
    aMonth_09_Russ              =       'Сентябрь';
    aMonth_10_Russ              =       'Октябрь';
    aMonth_11_Russ              =       'Ноябрь';
    aMonth_12_Russ              =       'Декабрь';


 {*********************  Support of GERMANY  *******************}

   { global scope }
 {$IFDEF GermanyVersion}
     abGermanyAvail             =       System.True;
 {$ELSE}
     abGermanyAvail             =       System.False;
 {$ENDIF}

   { program descriptions }
     asPurposeGerm              =       'LPrint Programm';
     asAuthorGerm               =       'Dima Stefankov';
     asCopyrightGerm            =       'Copyright (c)';
     asMsgVersionGerm           =       '  Version ';
     asProgramGerm              =       'LPrint';
     asProgramPromptGerm        =       asProgramGerm+': ';
     asUProgramGerm             =       'LPRINT';

  { languages }
     asEnglishLanguageGerm       =      'Englisch';
     asRussianLanguageGerm       =      'Russisch';
     asGermanyLanguageGerm       =      'Deutsch';

  { user response }
    achUserWantGerm              =      'J';
    achUserDontWantGerm          =      'N';

  { string constants }
    asSwValON_Germ               =      '(=an)';
    asSwValOFF_Germ              =      '(=aus)';
    asSwValNONE_Germ             =      '(=keins)';
    asAllChars_Germ              =      'alle Symbole erlaubt';

  { program messages }
    asMsgBadBooleanSwitchGerm   =       'Falscher Schalter in der Kommandozeile.';
    asMsgBadNumericFoundGerm    =       'Falsche Zahl in der Kommandozeile.';
    asMsgBadSwitchFoundGerm     =       'UngБltig';
    asMsgsMisMatchSwitchGerm    =       ' Schalter in den Kommandozeile gefunden.';
    asMsgFileNotFoundGerm       =       'Datei nicht gefunden ';
    asMsgFileNotCreatedGerm     =       'Datei kann nicht erstellt werden ';
    asMsgSameFilesNotAllowedGerm =      'Eingangs- und Ausgangsdatei mБssen unterschiedlich sein';
    asMsgBadPrefixSwitchGerm    =       'Falscher PrДfix fБr';
    asMsgBadMarginSwitchGerm    =       'Falsche (Rand-)Grenze';
    asMsgBadLineSwitchGerm      =       'Falsche Seite';
    asMsgBadHeaderSwitchGerm    =       'Falscher Kopf';
    asMsgBadPageSwitchGerm      =       'Falsche Seite';
    asMsgBadFileSwitchGerm      =       'Falscher Name';
    asMsgPrintCtrlSwitchGerm    =       'Falscher Drucker Befehl';
    asMsgBadLangSwitchGerm      =       'Falsche Sprache';
    asMsgTimeOfFileCreateGerm   =       'Datei wurde erstellt:   ';
    asMsgPageGerm               =       'Seite ';
    asMsgPrintPageNumGerm       =       'Drucke Seite  ';
    asMsgPrintLineNumGerm       =       ', Seite ';
    asMsgWriteFaultGerm         =       'Schreib-Fehler';
    asMsgDeviceNotReadyGerm     =       'AusgabegerДt nicht bereit';
    asMsgUserWantBreakGerm      =       'Druck abbrechen? ('+achUserDontWantGerm+'/'+achUserWantGerm+'): ';
    asMsgStopPrintByUserGerm    =       'Druck zeitweilig unterbrochnen';
    asMsgAbortOfPrintGerm       =       'Druck durch Benutzer abgebrochen.';
    asMsgRetryActionGerm        =       '. Weiter? ('+achUserWantGerm+'/'+achUserDontWantGerm+'): ';
    asMsgOutFileGerm            =       'Ausgabedatei ';
    asMsgAlreadyExistsGerm      =       ' existiert bereits. Ъberschreiben? ('+achUserDontWantGerm+'/'+achUserWantGerm+'): ';
    asMsgUserHeaderGerm         =       'Bitte Kopfzeite eingeben:';
    asMsgPrintStartGerm         =       'Ausdruck von ';
    asMsgToGerm                 =       ' bis ';
    asMsgUserAvailableKeysGerm  =       'DrБcken Sie '+asExitKey+' zum Abbruch des Drucks, '+asStopKey+
                                        ' stoppt das Drucken.';
    asMsgPrintDoneGerm          =       'Ende. Seiten ';
    asMsgReadFailGerm           =       'Fehler beim Lesen';
    asMsgWriteFailGerm          =       'Fehler beim Schreiben';
    asMsgBadCtrlCodeGerm        =       'Falscher Befehlcode';
    asMsgLoadBinFileGerm        =       'Laden der BinДrdatei ';
    asMsgLoadTransFileGerm      =       'Laden der Ъbesetzungstabelle ';
    asMsgScriptFileGerm         =       'Interpretiere die Kommandodatei ';
    asMsgAMGerm                 =       'vormittags';
    asMsgPMGerm                 =       'nachmittags';

  { help screen }
    asMsgHelp00A_Germ            =      'Kurzhilfe:';
    asMsgHelp01A_Germ            =      'Aufruf: ';
    asMsgHelp01B_Germ            =      ' [Optionen], Ziel';
    asMsgHelp02A_Germ            =      '  Optionsschalter sind entweder '+achDosSwitch+' oder '+achUnixSwitch+'.';
    asMsgHelp03A_Germ            =      '  GБltige Optionen (Ohne Beachtung von Groс-/Kleinschreibung)';
    asMsgHelp04A_Germ            =      '     Schalter    |          Bedeutung            |    Standard';
    asMsgHelp05A_Germ            =      asHelpIndent+aFileSwitch+aConfigCmd+'str      |     Konfigurationsdatei       |  '+
                                        'leer '+asSwValNONE_Germ;
    asMsgHelp06A_Germ            =      asHelpIndent+aFileSwitch+aSourceCmd+'str      |     Quell- Dateiname          |  '+
                                        'leer '+asSwValNONE_Germ;
    asMsgHelp07A_Germ            =      asHelpIndent+aFileSwitch+aDestinationCmd+'str      |     Ziel-  Dateiname          |'+
                                        '  '+asStdDosPrintDevice;
    asMsgHelp08A_Germ            =      asHelpIndent+aFileSwitch+aWordStarCmd+'[-|+]    |     WordStar Datei            |  '+
                                        achSwitchOFF+achBlank+asSwValOFF_Germ;
    asMsgHelp09A_Germ            =      asHelpIndent+aFileSwitch+aFirstBinaryCmd+'str      |     BinДrdatei am Anfang      |'+
                                        '  leer '+asSwValNONE_Germ;
    asMsgHelp10A_Germ            =      asHelpIndent+aFileSwitch+aLastBinaryCmd+'str      |     BinДrdatei am Ende        |'+
                                        '  leer '+asSwValNONE_Germ;
    asMsgHelp11A_Germ            =      asHelpIndent+aFileSwitch+aTransCodesCmd+'str      |     Ъbersetzungstabelle       |'+
                                        '  leer '+asSwValNONE_Germ;
    asMsgHelp12A_Germ            =      asHelpIndent+aControlSwitch+aStatisticsCmd+'[-|+]    |     Ausgang Statistik        '+
                                        ' |  '+
                                        achSwitchON+achBlank+asSwValON_Germ;
  asMsgHelp13A_Germ            =      asHelpIndent+aControlSwitch+aAdvancedCtrlCmd+'[-|+]    |     erweiterte Kommandos   '+
                                        '   |  '+achSwitchOFF+achBlank+asSwValOFF_Germ;
    asMsgHelp14A_Germ            =      asHelpIndent+aControlSwitch+aBatchCmd+'[-|+]    |     Batch-Modus               |  '+
                                        achSwitchOFF+achBlank+asSwValOFF_Germ;
    asMsgHelp15A_Germ            =      asHelpIndent+aControlSwitch+aCtrlCodesCmd+'[-|+]    |     Steuerzeichen umwandeln   '+
                                        '|  '+achSwitchOFF+achBlank+asSwValOFF_Germ;
    asMsgHelp16A_Germ            =      asHelpIndent+aControlSwitch+aLanguageCmd+'n        |     Sprache wДhlen            |'+
                                        '  ';
    asMsgHelp17A_Germ            =      asHelpIndent+aControlSwitch+aTabCmd+'n        |     TabgrФсen setzen          |  ';
    asMsgHelp17B_Germ            =      ' (Leerzeichen)';
    asMsgHelp18A_Germ            =      asHelpIndent+aControlSwitch+aCtrlCharCodeCmd+'[n[-|+]] |     Zeichen <n> umschalten '+
                                        '   |  '+asAllChars_Germ;
    asMsgHelp19A_Germ            =      asHelpIndent+aLineSwitch+aLineNumCmd+'n        |     Seiten-Nummern            |  ';
    asMsgHelp19B_Germ            =      achBlank+asSwValOFF_Germ;
    asMsgHelp20A_Germ            =      asHelpIndent+aLineSwitch+aLineSpacingCmd+'n        |     Seitenumbruch             '+
                                        '|  ';
    asMsgHelp20B_Germ            =      achBlank+asSwValOFF_Germ;
    asMsgHelp21A_Germ            =      asHelpIndent+aPageSwitch+aHeightCmd+'n        |     Seiten-HФhe               |  ';
    asMsgHelp21B_Germ            =      ' Zeilen';
    asMsgHelp22A_Germ            =      asHelpIndent+aPageSwitch+aWidthCmd+'n        |     Seiten-Breite             |  ';
    asMsgHelp22B_Germ            =      ' Spalten';
    asMsgHelp23A_Germ            =      asHelpIndent+aPageSwitch+aPageNumberCmd+'n        |     Seiten-Nummer             |'+
                                        '  ';
    asMsgHelp24A_Germ            =      asHelpIndent+aPageSwitch+aPrintOddCmd+'[-|+]    |     ungerade Seiten drucken   |  '+
                                        achSwitchON+achBlank+asSwValON_Germ;
    asMsgHelp25A_Germ            =      asHelpIndent+aPageSwitch+aPrintEvenCmd+'[-|+]    |     gerade Seiten drucken     |'+
                                        '  '+achSwitchON+achBlank+asSwValON_Germ;
    asMsgHelp26A_Germ            =      asHelpIndent+aPageSwitch+aSkipPagesCmd+'n        |     Seite Бbergehen           |'+
                                        '  ';
    asMsgHelp26B_Germ            =      achBlank+asSwValNONE_Germ;
    asMsgHelp27A_Germ            =      asHelpIndent+aPageSwitch+aCountPagesCmd+'n        |     Seitenzahl zu drucken     |'+
                                        '  ';
    asMsgHelp27B_Germ            =      ' (=alle)';
    asMsgHelp28A_Germ            =      asHelpIndent+aMarginSwitch+aTopMarginCmd+'n        |     obere Grenze              '+
                                        '|  ';
    asMsgHelp29A_Germ            =      asHelpIndent+aMarginSwitch+aBottomMarginCmd+'n        |     untere Grenze          '+
                                        '   |  ';
    asMsgHelp30A_Germ            =      asHelpIndent+aMarginSwitch+aLeftMarginCmd+'n        |     linker Rand              '+
                                        ' |  ';
    asMsgHelp31A_Germ            =      asHelpIndent+aMarginSwitch+aRightMarginCmd+'n        |     rechter Rand            '+
                                        '  |  ';
    asMsgHelp32A_Germ            =      asHelpIndent+aHeaderSwitch+aHdrLevelCmd+'n        |     Kopfzeile                 |'+
                                        '  ';
    asMsgHelp33A_Germ            =      asHelpIndent+aHeaderSwitch+aHdrTextCmd+'str      |     Kopfzeilentext            |'+
                                        '  leer  '+asSwValNONE_Germ+', Eingabe';
    asMsgHelp33B_Germ            =      '                 |                               |  wenn Option ohne String';
    asMsgHelp34A_Germ            =      '  Beispiel';

  { day/month/year }
    aDay_01_Germ                =       'Sonntag';
    aDay_02_Germ                =       'Montag';
    aDay_03_Germ                =       'Dienstag';
    aDay_04_Germ                =       'Mittwoch';
    aDay_05_Germ                =       'Donnerstag';
    aDay_06_Germ                =       'Freitag';
    aDay_07_Germ                =       'Sonnabend';

    aMonth_01_Germ              =       'Januar';
    aMonth_02_Germ              =       'Februar';
    aMonth_03_Germ              =       'MДrz';
    aMonth_04_Germ              =       'April';
    aMonth_05_Germ              =       'Mai';
    aMonth_06_Germ              =       'Juni';
    aMonth_07_Germ              =       'Juli';
    aMonth_08_Germ              =       'August';
    aMonth_09_Germ              =       'September';
    aMonth_10_Germ              =       'Oktober';
    aMonth_11_Germ              =       'November';
    aMonth_12_Germ              =       'Dezember';


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

  { suppoted natural languages for each generated version }
    gbLanguagesArray            :       ARRAY[aMinLangNum..aMaxLangNum]  OF System.Boolean =
                                           (abEnglishAvail,
                                            abRussianAvail,
                                            abGermanyAvail);

  { day/month/year }
    gstrucDaysOfWeek : ARRAY [aMinLangNum..aMaxLangNum]  OF
                          ARRAY[0..6] OF  System.PChar  =
                  {$IFDEF EnglishVersion}
                     ((aDay_01_Engl, aDay_02_Engl,
                       aDay_03_Engl, aDay_04_Engl,
                       aDay_05_Engl, aDay_06_Engl,
                       aDay_07_Engl),
                  {$ELSE}
                     ((asBlankStr, asBlankStr,
                       asBlankStr, asBlankStr,
                       asBlankStr, asBlankStr,
                       asBlankStr),
                  {$ENDIF}
                  {$IFDEF RussianVersion}
                      (aDay_01_Russ, aDay_02_Russ,
                       aDay_03_Russ, aDay_04_Russ,
                       aDay_05_Russ, aDay_06_Russ,
                       aDay_07_Russ),
                  {$ELSE}
                      (asBlankStr, asBlankStr,
                       asBlankStr, asBlankStr,
                       asBlankStr, asBlankStr,
                       asBlankStr),
                  {$ENDIF}
                  {$IFDEF GermanyVersion}
                      (aDay_01_Germ, aDay_02_Germ,
                       aDay_03_Germ, aDay_04_Germ,
                       aDay_05_Germ, aDay_06_Germ,
                       aDay_07_Germ));
                  {$ELSE}
                      (asBlankStr, asBlankStr,
                       asBlankStr, asBlankStr,
                       asBlankStr, asBlankStr,
                       asBlankStr));
                  {$ENDIF}


    gstrucMonthsOfYear :  ARRAY [aMinLangNum..aMaxLangNum]  OF
                            ARRAY [1..12]  OF  System.PChar =
                  {$IFDEF EnglishVersion}
                       ((aMonth_01_Engl, aMonth_02_Engl, aMonth_03_Engl,
                         aMonth_04_Engl, aMonth_05_Engl, aMonth_06_Engl,
                         aMonth_07_Engl, aMonth_08_Engl, aMonth_09_Engl,
                         aMonth_10_Engl, aMonth_11_Engl, aMonth_12_Engl),
                  {$ELSE}
                       ((asBlankStr, asBlankStr, asBlankStr,
                         asBlankStr, asBlankStr, asBlankStr,
                         asBlankStr, asBlankStr, asBlankStr,
                         asBlankStr, asBlankStr, asBlankStr),
                  {$ENDIF}
                  {$IFDEF RussianVersion}
                        (aMonth_01_Russ, aMonth_02_Russ, aMonth_03_Russ,
                         aMonth_04_Russ, aMonth_05_Russ, aMonth_06_Russ,
                         aMonth_07_Russ, aMonth_08_Russ, aMonth_09_Russ,
                         aMonth_10_Russ, aMonth_11_Russ, aMonth_12_Russ),
                  {$ELSE}
                        (asBlankStr, asBlankStr, asBlankStr,
                         asBlankStr, asBlankStr, asBlankStr,
                         asBlankStr, asBlankStr, asBlankStr,
                         asBlankStr, asBlankStr, asBlankStr),
                  {$ENDIF}
                  {$IFDEF GermanyVersion}
                        (aMonth_01_Germ, aMonth_02_Germ, aMonth_03_Germ,
                         aMonth_04_Germ, aMonth_05_Germ, aMonth_06_Germ,
                         aMonth_07_Germ, aMonth_08_Germ, aMonth_09_Germ,
                         aMonth_10_Germ, aMonth_11_Germ, aMonth_12_Germ));
                  {$ELSE}
                        (asBlankStr, asBlankStr, asBlankStr,
                         asBlankStr, asBlankStr, asBlankStr,
                         asBlankStr, asBlankStr, asBlankStr,
                         asBlankStr, asBlankStr, asBlankStr));
                  {$ENDIF}

  { international program messages }
    gszPurpose                  :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asPurposeEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asPurposeRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asPurposeGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszAuthor                   :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asAuthorEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asAuthorRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asAuthorGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszCopyright                :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asCopyrightEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asCopyrightRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asCopyrightGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszProgramPrompt            :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asProgramPromptEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asProgramPromptRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asProgramPromptGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszProgram                  :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asProgramEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asProgramRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asProgramGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszUProgram                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asUProgramEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asUProgramRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asUProgramGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgVersion                :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgVersionEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgVersionRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgVersionGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgBadBooleanSwitch       :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgBadBooleanSwitchEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgBadBooleanSwitchRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgBadBooleanSwitchGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgBadNumericFound        :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgBadNumericFoundEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgBadNumericFoundRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgBadNumericFoundGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgBadSwitchFound        :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgBadSwitchFoundEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgBadSwitchFoundRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgBadSwitchFoundGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgsMisMatchSwitch        :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgsMisMatchSwitchEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgsMisMatchSwitchRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgsMisMatchSwitchGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgFileNotFound           :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgFileNotFoundEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgFileNotFoundRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgFileNotFoundGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgFileNotCreated         :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgFileNotCreatedEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgFileNotCreatedRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgFileNotCreatedGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgSameFilesNotAllowed    :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgSameFilesNotAllowedEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgSameFilesNotAllowedRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgSameFilesNotAllowedGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgBadPrefixSwitch        :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgBadPrefixSwitchEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgBadPrefixSwitchRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgBadPrefixSwitchGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgBadMarginSwitch        :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgBadMarginSwitchEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgBadMarginSwitchRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgBadMarginSwitchGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgBadLineSwitch          :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgBadLineSwitchEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgBadLineSwitchRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgBadLineSwitchGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgBadHeaderSwitch        :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgBadHeaderSwitchEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgBadHeaderSwitchRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgBadHeaderSwitchGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgBadPageSwitch          :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgBadPageSwitchEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgBadPageSwitchRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgBadPageSwitchGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgBadFileSwitch          :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgBadFileSwitchEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgBadFileSwitchRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgBadFileSwitchGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgPrintCtrlSwitch        :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgPrintCtrlSwitchEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgPrintCtrlSwitchRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgPrintCtrlSwitchGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgBadLangSwitch          :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgBadLangSwitchEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgBadLangSwitchRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgBadLangSwitchGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgTimeOfFileCreate       :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgTimeOfFileCreateEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgTimeOfFileCreateRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgTimeOfFileCreateGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgPage                   :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgPageEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgPageRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgPageGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgPrintPageNum           :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgPrintPageNumEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgPrintPageNumRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgPrintPageNumGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgPrintLineNum           :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgPrintLineNumEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgPrintLineNumRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgPrintLineNumGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgWriteFault             :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgWriteFaultEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgWriteFaultRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgWriteFaultGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgDeviceNotReady         :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgDeviceNotReadyEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgDeviceNotReadyRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgDeviceNotReadyGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgUserWantBreak          :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgUserWantBreakEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgUserWantBreakRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgUserWantBreakGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgStopPrintByUser        :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgStopPrintByUserEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgStopPrintByUserRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgStopPrintByUserGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgAbortOfPrint           :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgAbortOfPrintEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgAbortOfPrintRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgAbortOfPrintGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgRetryAction            :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgRetryActionEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgRetryActionRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgRetryActionGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgOutFile                :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgOutFileEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgOutFileRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgOutFileGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgAlreadyExists          :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgAlreadyExistsEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgAlreadyExistsRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgAlreadyExistsGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgUserHeader             :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgUserHeaderEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgUserHeaderRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgUserHeaderGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgPrintStart             :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgPrintStartEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgPrintStartRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgPrintStartGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgTo                     :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgToEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgToRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgToGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgUserAvailableKeys      :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgUserAvailableKeysEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgUserAvailableKeysRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgUserAvailableKeysGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgPrintDone              :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgPrintDoneEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgPrintDoneRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgPrintDoneGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgReadFail               :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgReadFailEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgReadFailRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgReadFailGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgWriteFail              :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgWriteFailEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgWriteFailRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgWriteFailGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgBadCtrlCode            :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgBadCtrlCodeEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgBadCtrlCodeRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgBadCtrlCodeGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgLoadBinFile            :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgLoadBinFileEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgLoadBinFileRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgLoadBinFileGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgLoadTransFile          :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgLoadTransFileEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgLoadTransFileRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgLoadTransFileGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgScriptFile             :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgScriptFileEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgScriptFileRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgScriptFileGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgAM                     :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgAMEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgAMRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgAMGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgPM                     :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgPMEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgPMRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgPMGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}


  { languages support }
    gszEnglishLanguage         :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asEnglishLanguageEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asEnglishLanguageRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asEnglishLanguageGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszRussianLanguage        :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asRussianLanguageEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asRussianLanguageRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asRussianLanguageGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszGermanyLanguage        :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                       System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asGermanyLanguageEngl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asGermanyLanguageRuss,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asGermanyLanguageGerm);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}



  { user possible responses }
    gchUserWant                :   ARRAY [aMinLangNum..aMaxLangNum]  OF  System.Char =
                                  {$IFDEF EnglishVersion}
                                     (achUserWantEngl,
                                  {$ELSE}
                                     (achZero,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      achUserWantRuss,
                                  {$ELSE}
                                      achZero,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      achUserWantGerm);
                                  {$ELSE}
                                      achZero);
                                  {$ENDIF}

    gchUserDontWant            :   ARRAY [aMinLangNum..aMaxLangNum]  OF  System.Char =
                                  {$IFDEF EnglishVersion}
                                     (achUserDontWantEngl,
                                  {$ELSE}
                                     (achZero,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      achUserDontWantRuss,
                                  {$ELSE}
                                      achZero,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      achUserDontWantGerm);
                                  {$ELSE}
                                      achZero);
                                  {$ENDIF}

  { user help }
    gszMsgHelp00A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp00A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp00A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp00A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp01A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp01A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp01A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp01A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp01B                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp01B_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp01B_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp01B_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp02A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp02A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp02A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp02A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp03A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp03A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp03A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp03A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp04A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp04A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp04A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp04A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp05A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp05A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp05A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp05A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp06A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp06A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp06A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp06A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp07A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp07A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp07A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp07A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp08A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp08A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp08A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp08A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp09A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp09A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp09A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp09A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp10A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp10A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp10A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp10A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp11A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp11A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp11A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp11A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp12A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp12A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp12A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp12A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp13A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp13A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp13A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp13A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp14A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp14A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp14A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp14A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp15A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp15A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp15A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp15A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp16A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp16A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp16A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp16A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp17A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp17A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp17A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp17A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp17B                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp17B_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp17B_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp17B_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp18A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp18A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp18A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp18A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp19A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp19A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp19A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp19A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp19B                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp19B_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp19B_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp19B_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp20A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp20A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp20A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp20A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp20B                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp20B_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp20B_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp20B_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp21A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp21A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp21A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp21A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp21B                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp21B_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp21B_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp21B_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp22A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp22A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp22A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp22A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp22B                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp22B_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp22B_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp22B_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp23A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp23A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp23A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp23A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp24A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp24A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp24A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp24A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp25A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp25A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp25A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp25A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp26A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp26A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp26A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp26A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp26B                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp26B_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp26B_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp26B_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp27A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp27A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp27A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp27A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp27B                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp27B_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp27B_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp27B_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp28A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp28A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp28A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp28A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp29A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp29A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp29A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp29A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp30A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp30A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp30A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp30A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp31A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp31A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp31A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp31A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp32A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp32A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp32A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp32A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp33A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp33A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp33A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp33A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp33B                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp33B_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp33B_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp33B_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}

    gszMsgHelp34A                 :   ARRAY [aMinLangNum..aMaxLangNum]  OF
                                        System.PChar =
                                  {$IFDEF EnglishVersion}
                                     (asMsgHelp34A_Engl,
                                  {$ELSE}
                                     (asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF RussianVersion}
                                      asMsgHelp34A_Russ,
                                  {$ELSE}
                                      asBlankStr,
                                  {$ENDIF}
                                  {$IFDEF GermanyVersion}
                                      asMsgHelp34A_Germ);
                                  {$ELSE}
                                      asBlankStr);
                                  {$ENDIF}
