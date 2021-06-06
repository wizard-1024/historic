{****************************************************************************
//                            File GLOBALS.PAS
//
//                       Global public definitions
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/globals.pas $
//  $RCSfile: globals.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:54:34 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: globals.pas $
//      Revision 1.1  1999/01/03 17:54:34  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             GLOBALS.PAS                                     }
{ PURPOSE               Global public definitions                       }
{ VERSION               0.01                                            }
{ DATE                  13-Sep-94                                       }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Tel. 007 (095) 944-6304                         }
{ COPYRIGHT NOTICE      Copyright (C) 1994-1995, Dmitry Stefankov       }
{ RESTRICTED RIGHTS     FOR INTERNAL USE ONLY.                          }
{                       THIS FILE CONTAINS PROPRIETARY AND CONFIDENTIAL }
{                       INFORMATION. COPYING AND REPRODUCTION WITHOUT   }
{                       PRIOR WRITTEN PERMISSION IS PROHIBITED.         }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 7.0                        }
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             None                                            }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       DOS.TPU        (DOS functions and procedures)   }
{                       Project Maintence Files                         }
{                       TYPIST.MAK     (auto compiling & linking)       }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       0.01   13-Sep-94  DS  initial release           }
{-----------------------------------------------------------------------}



UNIT
    Globals;


INTERFACE


USES
    Dos;


{*CONST.INC*}
{*========================== CONSTANTS PART ============================*}

CONST

    {* general information *}

     asVersion                  =       '0.01';
     asYears                    =       '1994, 1995';


    {* program exit codes *}

       errTerminateOK                           =        0;
       errUserAbort                             =        1;
       errBadNumeric                            =        2;
       errBadCPU                                =        3;
       errNeedDataWordAlignment                 =        4;
       errUserHelp                              =        5;
       errNoPrefixSwitch                        =        6;
       errBadBooleanParam                       =        7;
       errBadWordParam                          =        8;
       errBadWordParamRange                     =        9;
       errBadPasStrParam                        =       10;
       errBadPasStrParamRange                   =       11;
       errUnsupportedSwitch                     =       12;
       errOpenConfigFile                        =       13;
       errReadConfigFile                        =       14;
       errBadSectionHeader                      =       15;
       errBadSectionNumber                      =       16;
       errEmptyConfigFile                       =       17;
       errBadKeyboardSubSectionStatement        =       18;
       errBadDictionarySubSectionStatement      =       19;
       errBadSyntaxNumericEntry                 =       20;
       errBadNumericEntry                       =       21;
       errBadSyntaxUserSubString                =       22;
       errEmptyUserAbbreviation                 =       23;
       errNoKeywordToTranslate                  =       24;
       errEmptyUserDictionaryEntry              =       25;
       errBadSearchType                         =       26;
       errNoFreeMultSlot                        =       27;
       errBadFreeSpaceSize                      =       28;
       errBadIntVecInst                         =       29;
       errFreeMemInfoCallFailed                 =       30;
       errNoEnoughFreeMemInPool                 =       31;
       errGetEnvList                            =       32;
       errEnvListFull                           =       33;
       errBadKeyboardHotKeyDefinition           =       34;
       errBadKeyboardHotKeyDefinitionStatement  =       35;
       errGetCurKbdModeFailed                   =       36;
       errSetNewKbdModeFailed                   =       37;
       errGetRawUserInputCallFailed             =       38;
       errAllocNewFreeSpaceFailed               =       39;
       errCallToSetNewEnvHandleFailed           =       40;
       errSetNewFilterFlagFailed                =       41;
       errBadLogicalValue                       =       42;
       errGetSearchUserInputCallFailed          =       43;
       errBadByteParam                          =       44;
       errBadByteParamRange                     =       45;
       errCopyOldIntVecFailed                   =       46;
       errBadOptionsSubSectionStatement         =       47;
       errBadInitSearchFlags                    =       48;
       errBadEntrySearchParameters              =       49;
       errGetReplaceBufCallFailed               =       50;
       errBadOptionsParameterKeyword            =       51;
       errCallToGetCurEnvHandleFailed           =       52;
       errCallToGetCurEnvSettingsFailed         =       53;
       errCreateDumpEnvFile                     =       54;
       errUserNeedMoreHelpToRun                 =       55;
       errHelpFileNotFound                      =       56;
       errHelpFileDisplayed                     =       57;
       errWrongMemType                          =       58;
       errEmptyUserTranslateCharFrom            =       59;
       errDuplicateAbbreviation                 =       60;
       errBadSortingOrderType                   =       61;
       errBadScanCodeForHotKeyDefinition        =       62;
       errNoMemoryCopyFoundAtUnloading          =       63;
       errMemoryCopyFoundAtLoading              =       64;
       errGetOldIntVecFailed                    =       65;
       errCallToGetCurrentStatusFailed          =       66;
       errOtherProgramsOwnIntVecs               =       67;
       errBadProgramMemoryUninstall             =       68;
       errBadUserChannel                        =       69;
       errCallToPatchMultiplexInterface         =       70;
       errEmptyUserCharInWord                   =       71;
       errBadDictionaryMemoryUninstall          =       72;
       errBadRemoveFromEnvList                  =       73;
       errResetCurEnvFailed                     =       74;
       errBadUserDictNameToRemove               =       75;
       errBadEnvHandleFound                     =       76;
       errBadMemoryCopyOfUserDict               =       77;
       errBadEnvProgramMemoryUninstall          =       78;
       errBadHighMemoryToInstall                =       79;
       errDictAlreadyLoaded                     =       80;
       errBadHighMemoryToReszie                 =       81;
       errResetCurFreeSpacePtrFailed            =       82;
       errEmptyUserWordDelimiter                =       83;
       errTooManyWordDelimiters                 =       84;
       errNoneLanguage                          =       85;
       errThisLanguageNotSupported              =       86;
       errCurrentEnviromentNotFound             =       87;
       errEmptyUserAutoLastChar                 =       88;
       errSetNewTimerFlagFailed                 =       89;
       errGetStateOfTimerFailed                 =       90;
       errGetProgramList                        =       91;
       errCopyCurFreeSpacePtrFailed             =       92;
       errAddEntryDictCallFailed                =       93;
       errBadRunTimerValue                      =       94;
       errBadDictSearchType                     =       95;
       errBadBooleanParameterState              =       96;
       errNoMoreFreeMemOnHeap                   =       97;
       errTooLargeUserDictionary                =       98;
       errGetCurEnvOptionsFailed                =       99;
       errBadBooleanParamRange                  =      100;
       errCallToGetStatBlockFailed              =      101;
       errCallToSetStatBlockFailed              =      102;
       errNoStatBlockGlobalSupport              =      103;
       errNoAllocMemInStatBlock                 =      104;
       errMoMemFoundToEnableTypingWatch         =      105;
       errTypingStatAlreadyInProgress           =      106;
       errEmptyUserAddIgnoreCase                =      107;
       errNotSupportedInt154F                   =      108;
       errBadUserConfigDosVar                   =      109;


    {* characters and strings *}

      achSPACE                  =     ' ';
      achHexPrefix              =     '$';
      achDosDelim               =     '.';
      achDosSwitch              =     '/';
      achUnixSwitch             =     '-';
      achDosDirSwitch           =     '\';
      achPlus                   =     '+';
      achMinus                  =     '-';
      achColon                  =     ':';
      achEqual                  =     '=';
      achPercent                =     '%';
      achNULL                   =     #0;
      achPhantomSpace           =     #255;
      achComment                =     '#';
      achDoubleQuota            =     #34;  { " }
      achBELL                   =     #7;
      achBS                     =     #8;
      achHTAB                   =     #9;
      achLF                     =     #10;
      achVTAB                   =     #11;
      achFF                     =     #12;
      achCR                     =     #13;
      achZero                   =     '0';
      achNine                   =     '9';
      achOpeningBracket         =     '[';
      achClosingBracket         =     ']';
      achSemiColon              =     ';';
      achComma                  =     ',';
      achLess                   =     '<';
      achGreater                =     '>';
      achAsterisk               =     '*';
      achEnglishLetter_E        =     'E';

      asBlank                   =     '';
      asPcEoln                  =     achCR+achLF;
      aMaxStrLen                =     255;


    {* errors check code *}

      errOK                     =     0;


    {* default values *}

      asDefCfgExt               =     'cfg';
      asDefDicExt               =     'dic';

      asDefaultOFF              =     'off';
      asDefaultON               =     'on';

      asDefaultYes              =     'yes';
      asDefaultNo               =     'no';


    {* percents definitions *}

      aPercent90                =     90;
      aPercent100               =     100;


    {* binary definitions *}

      aMinCharBit8              =     0;
      aMaxCharBit8              =     255;
      aByte                     =     1;
      aWord                     =     2;
      aDWord                    =     4;
      aTen                      =     10;
      aFullLowNibble            =     $0F;
      aFullHighNibble           =     $F0;
      aFullByte                 =     $FF;
      aFullWord                 =     $FFFF;
      aFullDWord                =     $FFFFFFFF;
      aBitsPerByte              =     8;
      aBitsPerWord              =     16;
      aBytesForSet256           =     32;  { = (aMaxCharBit8+1)/aBitsPerByte}
      aBitCountsForSet256       =     16;  { = aBytesForSet256/2 }
      aBytesPerKByte            =     1024;
      aKBytesPerMbyte           =     1024;


    {* DOS memory area definitions *}

      aPSP_Size                 =     256;    {bytes}
      aBytesPerParagraph        =     16;
      aPSP_Size_In_Paras        =     aPSP_Size DIV aBytesPerParagraph; {paragraphs}
      aDosEnvSeg                =     $2C;    {offset}


     {* program screen output values *}

       aDisableScreenPage       =     0;
       aMinOutLineOnScreen      =     1;
       aDefMaxOutLineForScreen  =     23;
       aBigOutLinesForScreenNum =     2048;


    {* bit values *}

       btBit_0_ON               =       $0001;
       btBit_1_ON               =       $0002;
       btBit_2_ON               =       $0004;
       btBit_3_ON               =       $0008;
       btBit_4_ON               =       $0010;
       btBit_5_ON               =       $0020;
       btBit_6_ON               =       $0040;
       btBit_7_ON               =       $0080;
       btBit_8_ON               =       $0100;
       btBit_9_ON               =       $0200;
       btBit_A_ON               =       $0400;
       btBit_B_ON               =       $0800;
       btBit_C_ON               =       $1000;
       btBit_D_ON               =       $2000;
       btBit_E_ON               =       $4000;
       btBit_F_ON               =       $8000;


    {* parameter types *}

       aParmIsIndefinite        =       0;
       aParmIsPascalStr         =       aParmIsIndefinite+1;
       aParmIsAsciiZ            =       aParmIsPascalStr+1;
       aParmIsBoolean           =       aParmIsAsciiZ+1;
       aParmIsByte              =       aParmIsBoolean+1;
       aParmIsInteger           =       aParmIsByte+1;
       aParmIsWord              =       aParmIsInteger+1;


    {* configuration sections *}

       aUndefinedSectionNum     =       0;
       aKeyboardSectionNum      =       1;
       aOptionsSectionNum       =       aKeyboardSectionNum + 1;
       aDictionarySectionNum    =       aOptionsSectionNum + 1;
       aMaxSectionNum           =       aDictionarySectionNum;

       asKeyboardSection        =       'keyboard';
       asOptionsSection         =       'options';
       asDictionarySection      =       'dictionary';


    {* <keyboard> section syntax elements *}

       asIdleModeHotkey        =        'IdleModeSwitch';
       asManualModeHotkey      =        'ManualModeSwitch';
       asAddModeHotkey         =        'AddModeSwitch';
       asSearchModeHotkey      =        'SearchModeSwitch';
       asEnvironmentSwitch     =        'EnvironmentSwitch';
       asVideoIndicationSwitch =        'VideoIndicationSwitch';

       aStateIsUndefinedMode   =        0;
       aStateIsIdleMode        =        1;
       aStateIsManualMode      =        2;
       aStateIsAddMode         =        3;
       aStateIsSearchMode      =        4;
       aStateModeValMin        =        aStateIsIdleMode;
       aStateModeValMax        =        aStateIsSearchMode;
       aStateIsEnvMode         =        5;
       aStateIsVidMode         =        6;

       aSearchSubStateIsAnalyze         =      0;
       aSearchSubStateIsSearch          =      1;
       aSearchSubStateIsReplace         =      2;
       aSearchSubStateModeValMin        =      aSearchSubStateIsAnalyze;
       aSearchSubStateModeValMax        =      aSearchSubStateIsReplace;

       achIdleModeLetter                =        'I';
       achManualModeLetter              =        'M';
       achAddModeLetter                 =        'A';
       achSearchModeLetter              =        'S';
       achAnalyzeStateLetter            =        'A';
       achSearchStateLetter             =        'S';
       achReplaceStateLetter            =        'R';

       asLeftShiftKey          =        'LShift';
       asRightShiftKey         =        'RShift';
       asLeftControlKey        =        'LCtrl';
       asRightControlKey       =        'RCtrl';
       asLeftAltKey            =        'LAlt';
       asRightAltKey           =        'RAlt';
       asScrollLockKey         =        'ScrollLock';
       asNumLockKey            =        'NumLock';
       asCapsLockKey           =        'CapsLock';

       btLeftShiftHotKey       =        $01;
       btRightShiftHotKey      =        $02;
       btLeftControlHotKey     =        $04;
       btRightControlHotKey    =        $08;
       btLeftAltHotKey         =        $10;
       btRightAltHotKey        =        $20;
       btScrollLockHotKey      =        $40;
       btNumLockHotKey         =        $80;
       btCapsLockHotKey        =        $100;

       asForwardSearchSymbol      =        'FwdSrchSym';
       asBackwardSearchSymbol     =        'BkwdSrchSym';
       asNonSpecialSymbol         =        'NonSpecSym';
       asSearchAbbrevSymbol       =        'AbbrvSrchSym';
       asSearchExpressionSym      =        'ExprSrchSym';
       asDirectionSearchOrderSym  =        'DirSrchOrdSym';
       asDictSearchOrderSym       =        'DictSrchOrdSym';
       asCaseSensitiveSearchSym   =        'CaseSrchSym';
       asMiddleSearchSym          =        'MiddleSrchSym';
       asBreakInputSym            =        'BreakInputSym';
       asSingleWordSearchSym      =        'SingleSrchSym';

       btForwardSearch                  =    $0001;
       btBackwardSearch                 =    $0002;
       btSearchAbbreviation             =    $0004;
       btSearchExpression               =    $0008;
       btSearchFirstForward             =    $0010;
       btSearchFirstAbbreviation        =    $0020;
       btSearchCaseSensitive            =    $0040;
       btMiddleSearch                   =    $0080;
       btSingleWordSearchSym            =    $0100;
       btBreakInputSymPresent           =    $0200;

       asDelimDefinitionSym   =    'DelimDefSym';
       asNonDefSym            =    'NonDefSym';
       asOpenNumericSym       =    'OpenNumericSym';
       asCloseNumericSym      =    'CloseNumericSym';

       asInitSearchFlags      =    'InitSearchFlags';
       asColorVideoAttr       =    'ColorVideoAttr';
       asMonoVideoAttr        =    'MonoVideoAttr';
       asDictName             =    'DictName';
       asDictComment          =    'DictComment';


    {* <dictionary> section syntax elements *}

       asOpeningDelimiter      =        'OpenDelim';
       asClosingDelimiter      =        'CloseDelim';

       asAddEntry              =        'AddEntry';
       asContinueEntry         =        'ContinueEntry';
       asNoMoreEntry           =        'NoMoreEntry';
       asTranslateTo           =        'TO';

       aSearchUndefined                 =    $00;
       aSearchForwardFromStart          =    $01;

       btNoSearchThisTable              =      0;
       btForwardSearchAbbreviation      =      1;
       btBackwardSearchAbbreviation     =      2;
       btForwardSearchExpression        =      3;
       btBackwardSearchExpression       =      4;
       btSearchAbbreviationSizes        =      5;
       btSearchExpressionSizes          =      6;


    {* <options> section syntax elements *}

       asAutoAddChar                    =       'AutoAddChar';
       asVideoIndicationOn              =       'VideoIndicationOn';
       asUseTableCompression            =       'UseTableCompression';
       asUseNodeCompression             =       'UseNodeCompression';
       asClickOnModeChange              =       'ClickOnModeChange';
       asFilterRawInput                 =       'FilterRawInput';
       asAddPaddingZero                 =       'AddPaddingZero';
       asRecognizeMetaSymbols           =       'RecognizeMetaSymbols';
       asAutoPutScanCode                =       'AutoPutScanCode';
       asUseForMSWord                   =       'UseForMSWord';
       asUseInt154F                     =       'UseInt154F';
       asUseForOldNorton1986            =       'UseForOldNorton1986';
       asSetBorderColorAsMarker         =       'SetBorderColorAsMarker';
       asEmptyAbbreviation              =       'EmptyAbbreviation';
       asFlushInputOnCR                 =       'FlushInputOnCR';
       asUseInt1601                     =       'UseInt1601';

       btAutoAddChar                    =       $0001;
       btVideoIndicationOn              =       $0002;
       btUseTableCompression            =       $0004;
       btUseNodeCompression             =       $0008;
       btClickOnModeChange              =       $0010;
       btFilterRawInput                 =       $0020;
       btAddPaddingZero                 =       $0040;
       btRecognizeMetaSymbols           =       $0080;
       btAutoPutScanCode                =       $0100;
       btUseForMSWord                   =       $0200;
       btUseInt154F                     =       $0400;
       btUseForOldNorton1986            =       $0800;
       btSetBorderColorAsMarker         =       $1000;
       btEmptyAbbreviation              =       $2000;
       btFlushInputOnCR                 =       $4000;
       btUseInt1601                     =       $8000;

       btNodeHasPaddingZero             =       $0001;
       btNodeIsCompressed               =       $0002;
       btNodeLinkOffsetPresentFA        =       $0004;
       btNodeLinkOffsetPresentBA        =       $0008;
       btNodeLinkOffsetPresentFE        =       $0010;
       btNodeLinkOffsetPresentBE        =       $0020;
       btNodeLinkOffsetPresentAS        =       $0040;
       btNodeLinkOffsetPresentES        =       $0080;
       btNodeHasEmptyAbbreviation       =       $0100;
       btNodeLinkOffsetFABA             =  btNodeLinkOffsetPresentFA+
                                           btNodeLinkOffsetPresentBA;
       btNodeLinkOffsetFABAFE           =  btNodeLinkOffsetFABA+
                                           btNodeLinkOffsetPresentFE;
       btNodeLinkOffsetFABAFEBE         =  btNodeLinkOffsetFABAFE+
                                           btNodeLinkOffsetPresentBE;
       btNodeLinkOffsetFABAFEBEAS       =  btNodeLinkOffsetFABAFEBE+
                                           btNodeLinkOffsetPresentAS;
       btNodeLinkOffsetFABAFEBEASES     =  btNodeLinkOffsetFABAFEBEAS+
                                           btNodeLinkOffsetPresentES;

       asCaseTranslate                  =       'CaseTranslate';
       asAddScanCode                    =       'AddScanCode';
       asSortByAlphabet                 =       'SortByAlphabet';
       asSortBySize                     =       'SortBySize';
       asCharInWord                     =       'CharInWord';
       asWordDelim                      =       'WordDelim';
       asAutoLastChar                   =       'AutoLastChar';
       asSearchType                     =       'SearchType';
       asFA_LinkPresent                 =       'FA-Link';
       asBA_LinkPresent                 =       'BA-Link';
       asFE_LinkPresent                 =       'FE-Link';
       asBE_LinkPresent                 =       'BE-Link';
       asAS_LinkPresent                 =       'AS-Link';
       asES_LinkPresent                 =       'ES-Link';
       asSortCaseIgnore                 =       'SortCaseIgnore';
       asAddSortIgnoreCase              =       'AddSortIgnoreCase';
       asAddSortMatchCase               =       'AddSortMatchCase';

       asAscendingOrder                 =       'Ascending';
       asDescendingOrder                =       'Descending';
       asNoneOrder                      =       'None';

       aNoneSortingOrder                =       0;
       aAscendingSortingOrder           =       1;
       aDescendingSortingOrder          =       2;

       asFirstFitType                   =       'FirstFit';
       asBestFitType                    =       'BestFit';
       asLastFitType                    =       'LastFit';

       aFirstFitType                    =       0;
       aBestFitType                     =       1;
       aLastFitType                     =       2;


       asActiveModeBorder               =       'ActiveModeBorder';
       asIdleModeBorder                 =       'IdleModeBorder';

       btBlueIntensity2of3              =       $01;
       btGreenIntensity2of3             =       $02;
       btRedIntensity2of3               =       $04;
       btBlueIntensity1of3              =       $08;
       btGreenIntensity1of3             =       $10;
       btRedIntensity1of3               =       $20;
       btOverscanColorMask              =       btBlueIntensity2of3+
                                                btGreenIntensity2of3+
                                                btRedIntensity2of3+
                                                btBlueIntensity1of3+
                                                btGreenIntensity1of3+
                                                btRedIntensity1of3;

       aOverscanColorIsBlack            =       0;

    {just same in TYPIST.PAS module}
       asResvdEmptyAbbrLength           =       3;
       asReservedEmptyAbbreviation      =       achEnglishLetter_E+
                                                achEnglishLetter_E+
                                                achEnglishLetter_E;

    {* program code equates (version/release/revision) *}

      aExtMajorVer                =        0;            { release  }
      aExtMinorVer                =        1;            { version  }
      aExtLevel                   =        0;            { revision }

      aIntMajorVer                =        0;            { release  }
      aIntMinorVer                =        1;            { version  }
      aIntLevel                   =        0;            { revision }


    {* timing/keystroke statistics *}

      aTimeTicksPerMinute        =         182*6;        {18.2*60}
      aSecondsPerMinute          =         60;
      aMinutesPerHour            =         60;
      aHoursPerDay               =         24;


    {*
       elements to limit = number of environments,
                          dynamic extension size,
                          number entries for each dictionary
     *}

      aEnviron_Avail_Min       =        1;
      aReserveMemoryMin        =        0;
      aReserveMemoryDef        =        0;
      aStatMinutesMin          =        1;
      aStatMinutesDef          =        30;
{$IFDEF   EvaVer}
      aEnviron_Def_Max         =        2;
      aWords_For_Dict_Def_Max  =        80;
      aReserveMemoryMax_Def    =        256;
      aStatMinutesMax_Def      =        aMinutesPerHour*1;
{$ELSE}
{$IFDEF   ComVer}
      aEnviron_Def_Max         =        16;
      aWords_For_Dict_Def_Max  =        10000;
      aReserveMemoryMax_Def    =        32768;
      aStatMinutesMax_Def      =        aMinutesPerHour*aHoursPerDay;
{$ELSE}
      aEnviron_Def_Max         =        1;
      aWords_For_Dict_Def_Max  =        16;
      aReserveMemoryMax_Def    =        128;
      aStatMinutesMax_Def      =        30;
{$ENDIF} {ComVer}
{$ENDIF} {EvaVer}
      aEnviron_Avail_Max       =        aEnviron_Def_Max;
      aWords_For_Dict_Max      =        aWords_For_Dict_Def_Max;
      aReserveMemoryMax        =        aReserveMemoryMax_Def;
      aStatMinutesMax          =        aStatMinutesMax_Def;

    {* reserve space in memory for dictionary in code segment 'TYPIST' *}

{$IFDEF   Add8KB}
      aAdd8K    =       8192;
{$ELSE}
      aAdd8K    =       0;
{$ENDIF} {Add8KB}
{$IFDEF   Add16KB}
      aAdd16K   =       16384;
{$ELSE}
      aAdd16K   =       0;
{$ENDIF} {Add16KB}

      aFreeSpaceMin            =        0;        { must be counted in DWords }
      aFreeSpaceDef            =        0;
      aFreeSpaceMax            =        aAdd8K+aAdd16K;


    {* interrupt channels *}

      aMinIntelIntNum          =        $00;
      aMaxIntelIntNum          =        $FF;
      aHardTimerInt            =        $08;
      aHardKbdInt              =        $09;
      aVideoInt                =        $10;
      aServerInt               =        $15;
      aSoftKbdInt              =        $16;
      aDosServicesInt          =        $21;
      aMultiplexInt            =        $2F;


    {* DOS functions (INT $21) *}

      aKeepResident            =        $31;
      aCountryInfo             =        $38;
      aAllocMemBlock           =        $48;
      aFreeMemBlock            =        $49;
      aResizeMemBlock          =        $4A;
      aTerminateProcess        =        $4C;
      aMemStrategy             =        $58;


    {* DOS subfunctions (INT $21) *}

      aGetCountryInfo          =        $00;         {Function $38}
      aGetMemStrategy          =        $00;         {Function $58}
      aSetMemStrategy          =        $01;
      aGetUmbLinkState         =        $02;
      aSetUmbLinkState         =        $03;


    {* DOS country codes *}

      aCountryCode_US                   =        1;
      aCountryCode_Russia               =        7;
      aCountryCode_Switzerland          =        41;
      aCountryCode_UK                   =        44;
      aCountryCode_Germany              =        49;
      aCountryCode_Australia            =        61;


    {* DOS environment variables *}

      asDosEnvVarDef                    =        'TYPIST';


    {* DOS environment variable syntax *}

      achDosEnvVarConfigPathPrefix       =        'D';
      achDosEnvVarIntNumPrefix           =        'I';
      achDosEnvVarChannelNumPrefix       =        'C';


    {* DOS values for memory allocation strategy *}

      aFirstFitLowMem          =        $00;           { DOS 2.0+ }
      aBestFitLowMem           =        $01;
      aLastFitLowMem           =        $02;
      aFirstFitHighMem         =        $40;           { DOS 5.0+ }
      aBestFitHighMem          =        $41;
      aLastFitHighMem          =        $42;
      aFirstFitHighLowMem      =        $80;
      aBestFitHighLowMem       =        $81;
      aLastFitHighLowMem       =        $82;


    {* DOS values for upper memory link state *}

      aRemoveUMBsfromDosChain   =        $00;
      aAddUMBsfromDosChain      =        $01;


    {* DOS memory area header *}

      aDosMemBlockID            =        $00;
      aDosMemBlockOwner         =        $01;
      aDosMemBlockSize          =        $03;
      aDosMemBlockName          =        $08;


    {* DOS magic numbers *}

      aConvMemSegMax            =        $B000;  {safe for QEMM}


    {* multiplex channels/processes *}

      aMinMultiplexNum          =       $00;
      aMaxMultiplexNum          =       $FF;

      aDOS_First_MPID           =       aMinMultiplexNum;  { INT $2F }
      aDOS_Last_MPID            =       $BF;
      aUSER_First_MPID          =       aDOS_Last_MPID+1;
      aUSER_Last_MPID           =       aMaxMultiplexNum;


    {* our multiplex functions *}

      aITypist_Install_Status                   =       $00;
      aITypist_Current_Status                   =       $01;
      aITypist_Add_Dict_Entry                   =       $02;
      aITypist_Get_Set_Kbd_Mode                 =       $03;
      aITypist_Get_Free_Elem                    =       $04;
      aITypist_Get_Set_Environ                  =       $05;
      aITypist_Add_Environ                      =       $06;
      aITypist_List_Environ                     =       $07;
      aITypist_Search_Dict_Entry                =       $08;
      aITypist_New_Free_Space                   =       $09;
      aITypist_Get_Raw_User_Input               =       $0A;
      aITypist_Filter_Raw_User_Input            =       $0B;
      aITypist_Get_Search_User_Input            =       $0C;
      aITypist_Get_Set_Prev_Int_Vec             =       $0D;
      aITypist_Get_Replace_Str                  =       $0E;
      aITypist_Get_Set_User_Options             =       $0F;
      aITypist_Get_Cur_Environ_Parms            =       $10;
      aITypist_Reset_Cur_Environ                =       $11;
      aITypist_Reset_Free_Space_Ptr             =       $12;
      aITypist_Get_Set_Estimate_Timer           =       $13;
      aITypist_Get_Program_Info                 =       $14;
      aITypist_Copy_Free_Links_To_Env           =       $15;
      aITypist_Get_Set_Stat_Block               =       $16;
      aITypist_Func_Num_Max                     =       aITypist_Get_Set_Stat_Block;


    {* DOS multiplex standard functions *}

      aMP_Install               =       $00;


    {* response codes to multiplex function 0 *}

      aMP_OK_to_Install         =       $00;
      aMP_Not_OK_to_Install     =       $01;
      aMP_Already_Installed     =       $FF;


    {* our response codes for multiplex functions *}

      aMP_Bad_Call                      =       $FF;
      aMP_Successful_Done               =       $00;
      aMP_No_Free_Memory                =       $01;
      aMP_Bad_Range_Env                 =       $02;
      aMP_Empty_Env                     =       $03;
      aMP_Not_Implemented               =       $04;
      aMP_Bad_Kbd_Mode                  =       $05;
      aMP_Bad_New_Free_Space            =       $06;
      aMP_Bad_Filter_Flag               =       $07;
      aMP_Bad_Int_Vec_Num               =       $08;
      aMP_Bad_Search_Parms              =       $09;
      aMP_Bad_User_Options_Func         =       $0A;
      aMP_Bad_Estimate_Timer_Func       =       $0B;
      aMP_Bad_User_Def_Str              =       $0C;
      aMP_User_Dict_Is_Compressed       =       $0D;
      aMP_Bad_Stat_Block_Func           =       $0E;
      aMP_Bad_Stat_Block_Pointer        =       $0F;
      aMP_Same_Entry_Found              =       $10;


    {* our program identifier *}

      addPROG_ID_1              =       $49505954;  { 'IPYT' }
      addPROG_ID_2              =       $00005453;  { 'TS' }
      adwEXT_MPID_1             =       $4453;  { 'DS'= extended identifier 1 }
      adwEXT_MPID_2             =       $3934;  { '94'= extended identifier 2 }


    {* status codes from resident program *}

      errStatus_Success                         =       0;
      errStatus_Bad_Non_Special_Sym             =       1;
      errStatus_No_Match_Search_Entry           =       2;
      errStatus_Empty_Expression                =       3;
      errStatus_Bad_User_Definition             =       4;
      errStatus_No_Enough_Free_Memory           =       5;
      errStatus_Dict_Is_Compressed              =       6;
      errStatus_Bad_Num_Parm                    =       7;
      errStatus_Duplicate_Entry_Found           =       8;


    {* BIOS server for OS services *}

      aUserHookForScanCode     =        $4F;
      aGetConfigInfo           =        $C0;


    {* BIOS keyboard services *}

      aReadKeyStd              =        $00;
      aReadKeyEnh              =        $10;
      aAvailKeyStd             =        $01;
      aAvailKeyEnh             =        $11;


    {* BIOS video services *}

      aGetEgaInfo              =        $12;
      aVideoPaletteServices    =        $10;


    {* video palette access subfunctions *}

      aSetOverscanColor        =        $01;


    {* BIOS segments *}

       aRomBiosSeg              =     $F000;
       aBiosDataSeg             =     $40;


    {* ROM BIOS code entry points *}

       aRomKeyboardInt08        =     $FEA5;
       aRomKeyboardInt09        =     $E987;
       aRomKeyboardInt10        =     $F065;
       aRomKeyboardInt15        =     $F859;
       aRomKeyboardInt16        =     $E82E;
       aRomDummyIRET            =     $FF53;


    {* BIOS data area locations *}

       adbKbdStatus1            =     $17;
       adbKbdStatus2            =     $18;
       adbKbdStatus3            =     $96;
       adbKbdStatus4            =     $97;

       adwKbdBufHead            =     $1A;
       adwKbdBufTail            =     $1C;
       adwKbdBufStart           =     $80;
       adwKbdBufEnd             =     $82;

       adbVideoMode             =     $49;
       adwVidBufStart           =     $4E;

       addDayTimeCounter        =     $6C;


    {* PC standard video buffer segment *}

       adwMonoTextVidBuf        =     $B000;
       adwColorTextVidBuf       =     $B800;


    {* PC standard video text modes *}

       aVidTextMode7            =     $7;
       aVidTextMode3            =     $3;


     {* Bit-mapped flags for BIOS keyboard status data *}

       btRightShiftKey          =     $01;       { Status 1 }
       btLeftShiftKey           =     $02;
       btCtrlKey                =     $04;
       btAltKey                 =     $08;
       btScrollLockON           =     $10;
       btNumLockON              =     $20;
       btCapsLockON             =     $40;
       btInsertON               =     $80;

       btLeftCtrlKey            =     $01;       { Status 2 }
       btLeftAltKey             =     $02;
       btSysReqKey              =     $04;
       btPauseKey               =     $08;
       btScrollLockKey          =     $10;
       btNumLockKey             =     $20;
       btCapsLockKey            =     $40;
       btInsertKey              =     $80;

       btRightCtrlKey           =     $04;       { Status 3 }
       btRightAltKey            =     $08;
       btEnhancedKbdPresent     =     $10;


     {* PC hardware ports *}

        aInBuf8042              =     $60;
        aPPI_8255_Port_B        =     $61;
        ioBase8253_PIT          =     $40;
        ioTimerCount0           =     ioBase8253_PIT+0;
        ioTimerCount1           =     ioBase8253_PIT+1;
        ioTimerCount2           =     ioBase8253_PIT+2;
        ioTimerCtrl             =     ioBase8253_PIT+3;

        btSpeakerGateOn         =     $01;
        btSpeakerDataOutOn      =     $02;


     {* iAPX x86 Family *}

        adbNearJumpOpcode       =     $E9;


     {* PC standard timer definitions (INT $8) *}

        aTicksPerSecond         =     18;

        aPauseDelayInSecMin     =     1;
        aPauseDelayInSecDef     =     1;
        aPauseDelayInSecMax     =     10;

        aUserTimeFactorMin      =     1;
        aUserTimeFactorDef      =     3;
        aUserTimeFactorMax      =     aTicksPerSecond*aPauseDelayInSecMax;

        aWaitTicksMin           =     1;
        aWaitTicksDef           =     1;
        aWaitTicksMax           =     aTicksPerSecond;


     {* video attribute values *}

        aForeColorAttribMin     =     0;           { black }
        aForeColorAttribDef     =     7;           { white }
        aForeColorAttribMax     =     15;          { bright white }
        aBackColorAttribMin     =     0;           { black }
        aBackColorAttribDef     =     0;           { black }
        aBackColorAttribMax     =     15;          { bright white }


     {* memory types *}

        asHighMemory                    =    'high';
        asLowMemory                     =    'low';
        aMemoryTypeIsUndefined          =    0;
        aMemoryTypeIsHigh               =    1;
        aMemoryTypeIsLow                =    2;


     {* estimate timer setup values *}

        aNoneTimer                      =    0;
        aStopTimer                      =    1;
        aStartTimer                     =    2;


     {* debug modules names *}

       aNoneModule                      =    0;
       aModuleVideo                     =    1;
       aModuleDosCtl                    =    2;
       aModuleCallBack                  =    3;
       aModuleConfig                    =    4;
       aModuleTypist                    =    5;


    {* debugging level *}

       btNoDebugInfo                    =    $0000;
       btTraceVideo                     =    $0001;
       btTraceDosCtl                    =    $0002;
       btTraceCallBack                  =    $0004;
       btTraceConfig                    =    $0008;
       btTraceTypist                    =    $0010;
       btTraceLevelMax                  =    btTraceVideo+
                                             btTraceDosCtl+
                                             btTraceCallBack+
                                             btTraceConfig+
                                             btTraceTypist;
       btTraceAll                       =    $8000;


     {* international languages support *}

        aNoneLanguage                   =   0;
        aEnglishLanguage                =   1;
        aRussianLanguage                =   2;
        aMinLanguage                    =   aEnglishLanguage;
        aMaxLanguage                    =   aRussianLanguage;

{$IFDEF   EngVer}
          aDefLanguage      =   aEnglishLanguage;
{$ELSE}
  {$IFDEF   RusVer}
          aDefLanguage      =   aRussianLanguage;
  {$ELSE}
          aDefLanguage      =   aNoneLanguage;
  {$ENDIF} {RusVer}
{$ENDIF} {EngVer}


     {* hard-coded values for call back table *}

        aGetTableOffsetByIndex           =       00;
        aPutFirstTableOffsetByIndex      =       01;
        aGetNodeOptions                  =       02;
        aStoreNodeOptions                =       03;
        aGetNodeLinkOffsetForFA          =       04;
        aStoreNodeLinkOffsetForFA        =       05;
        aGetNodeLinkOffsetForBA          =       06;
        aStoreNodeLinkOffsetForBA        =       07;
        aGetNodeLinkOffsetForFE          =       08;
        aStoreNodeLinkOffsetForFE        =       09;
        aGetNodeLinkOffsetForBE          =       10;
        aStoreNodeLinkOffsetForBE        =       11;
        aGetNodeAccessCount              =       12;
        aStoreNodeAccessCount            =       13;
        aGetNodeHitCount                 =       14;
        aStoreNodeHitCount               =       15;
        aGetNodeAbbreviationSize         =       16;
        aStoreNodeAbbreviationSize       =       17;
        aGetNodeExpressionSize           =       18;
        aStoreNodeExpressionSize         =       19;
        aGetNodeAbbreviationOfs          =       20;
        aGetNodeExpressionOfs            =       21;
        aGetNodeLinkOffsetForAS          =       22;
        aStoreNodeLinkOffsetForAS        =       23;
        aGetNodeLinkOffsetForES          =       24;
        aStoreNodeLinkOffsetForES        =       25;
        aGetNodeSizeTotal                =       26;
        aMaxAvailCallBackIndex           =       aGetNodeSizeTotal;



{*TYPES.INC*}
{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE

    {* strings *}

       STR2                     =     STRING[2];
       STR3                     =     STRING[3];
       STR4                     =     STRING[4];
       STR5                     =     STRING[5];
       STR8                     =     STRING[8];
       STR10                    =     STRING[10];
       STR11                    =     STRING[11];
       STR12                    =     STRING[12];

       DelimitersSTR16          =     STRING[16];
       DictNameSTR16            =     STRING[16];
       DictCommentSTR32         =     STRING[32];


    {* casemap character table *}

    arrayCaseMapTable256    =   ARRAY[aMinCharBit8..aMaxCharBit8] OF System.Char;
    lpCaseMapTable256       =   ^arrayCaseMapTable256;


    {* scancodes table *}

    arrayScanCodeTable256    =   ARRAY[aMinCharBit8..aMaxCharBit8] OF System.Byte;
    lpScanCodeTable256        =   ^arrayScanCodeTable256;


    {* dictionary description *}
    lprecDicEntryDesc     =     ^recDicEntryDesc;
    recDicEntryDesc       =     RECORD
                      dbDicAbbrvSize       :    System.Byte;
                      dbEntrySize          :    System.Byte;
                      lpDicAbbrvStore      :    System.Pointer;
                      lpDicEntryStore      :    System.Pointer;
                      lpNextDicEntryDesc   :    lprecDicEntryDesc;
                      lpPrevDicEntryDesc   :    lprecDicEntryDesc;
                                END;
    {* dictionary description *}


    {* environment description *}
    lprecEnvironmentDesc     =     ^recEnvironmentDesc;
    recEnvironmentDesc       =     RECORD
                         dwIdleModeHotkey            :   System.Word;
                         dwManualModeHotkey          :   System.Word;
                         dwAddModeHotkey             :   System.Word;
                         dwSearchModeHotkey          :   System.Word;
                         dwEnvironmentHotKey         :   System.Word;
                         dwVideoIndicationHotKey     :   System.Word;
                         dbIdleModeScanCode          :   System.Byte;
                         dbManualModeScanCode        :   System.Byte;
                         dbAddModeScanCode           :   System.Byte;
                         dbSearchModeScanCode        :   System.Byte;
                         dbEnvironmentScanCode       :   System.Byte;
                         dbVideoIndicationScanCode   :   System.Byte;
                         dwInitSearchFlags           :   System.Word;
                         dwUserEnvOptions            :   System.Word;
                         dbColorVideoAttr            :   System.Byte;
                         dbMonoVideoAttr             :   System.Byte;
                         chForwardSearchSymbol       :   System.Char;
                         chBackwardSearchSymbol      :   System.Char;
                         chNonSpecialSymbol          :   System.Char;
                         chSearchAbbrevSymbol        :   System.Char;
                         chSearchExpressionSymbol    :   System.Char;
                         chDirectionSearchOrderSym   :   System.Char;
                         chDictSearchOrderSym        :   System.Char;
                         chCaseSearchSym             :   System.Char;
                         chMiddleSrchSym             :   System.Char;
                         chBreakInputSym             :   System.Char;
                         chSingleWordSearchSym       :   System.Char;
                         sDictName16                 :   DictNameSTR16;
                         sDictComment32              :   DictCommentSTR32;
                         sDelimiters16               :   DelimitersSTR16;
                         chAutoAddChar               :   System.Char;
                         chDelimDefinitionSym        :   System.Char;
                         chNonDefSym                 :   System.Char;
                         chOpenNumericSym            :   System.Char;
                         chCloseNumericSym           :   System.Char;
                         dbSearchType                :   System.Byte;
                         pForwardSearchAbbrevTable   :   System.Pointer;
                         pBackwardSearchAbbrevTable  :   System.Pointer;
                         pForwardSearchDictTable     :   System.Pointer;
                         pBackwardSearchDictTable    :   System.Pointer;
                         pStrSizeSearchAbbrevTable   :   System.Pointer;
                         pStrSizeSearchDictTable     :   System.Pointer;
                         pFreePointer                :   System.Pointer;
                         dwFreeSize                  :   System.Word;
                         dbActiveModeBorder          :   System.Byte;
                         dbIdleModeBorder            :   System.Byte;
                         chCaseMapArray256           :   arrayCaseMapTable256;
                         dbScanCodeTable256          :   arrayScanCodeTable256;
                         dbWordCharTable256          :   arrayScanCodeTable256;
                                  END;
    {* environment description *}


    {* static head tables *}

    arrayPTable256    =   ARRAY[aMinCharBit8..aMaxCharBit8] OF System.Pointer;
    lpPTable256       =   ^arrayPTable256;

    arrayDWTable256    =   ARRAY[aMinCharBit8..aMaxCharBit8] OF System.Word;
    lpDWTable256       =   ^arrayDWTable256;


    {* dictionary entry memory image header *}
    lprecDictEntryHeaderDesc  =     ^recDictEntryHeaderDesc;
    recDictEntryHeaderDesc    =     RECORD
                         dwNodeOptions                    :   System.Word;
                         dwForwardAbbrevEntryLink         :   System.Word;
                         dwBackwardAbbrevEntryLink        :   System.Word;
                         dwForwardDictEntryLink           :   System.Word;
                         dwBackwardDictEntryLink          :   System.Word;
                         dwAbbrevSizeEntryLink            :   System.Word;
                         dwExprSizeEntryLink              :   System.Word;
                         dwNodeAccessCount                :   System.Word;
                         dwNodeHitCount                   :   System.Word;
                         dbHeaderDictAbbreviationSize     :   System.Byte;
                         dbHeaderDictEntrySize            :   System.Byte;
                                  END;
    {* dictionary entry memory image header *}


    {* program information list *}
    recProgramInfoList          =       RECORD
                dbInternalRelease                  :    System.Byte;
                dbInternalVersion                  :    System.Byte;
                dbInternalRevision                 :    System.Byte;
                dwResidentProgramSegment           :    System.Word;
                dwResidentProgramSizeInParas       :    System.Word;
                dbInterfaceInterruptNumber         :    System.Byte;
                dbMultiplexChannelNumber           :    System.Byte;
                dbMaxSupportedFunctionsNum         :    System.Byte;
                dbCurrentStateMode                 :    System.Byte;
                dbCurrentSearchSubStateMode        :    System.Byte;
                dbLastStatusCode                   :    System.Byte;
                dbInitWaitTimerTicks               :    System.Byte;
                bEstimateTimerFlag                 :    System.Boolean;
                dwLastEstimateTimerValue           :    System.Word;
                dwFreeSpaceSize                    :    System.Word;
                lpFreeSpaceLink                    :    System.Pointer;
                                        END;
    {* program information list *}


    {* static head link table memory image header *}
    lprecCompressedHeadLinkTable     =     ^recCompressedHeadLinkTable;
    recCompressedHeadLinkTable       =     RECORD
        dbBitMapAsciiSet32     :   Array[0..aBytesForSet256-1] OF System.Byte;
        dbCharBitCounters16    :   Array[0..aBitCountsForSet256-1] OF System.Byte;
                                           END;
    {* static head link table memory image header *}


    {* statistics record block *}
    lpStatTimingBlock      =   ^recStatTimingBlock;
    recStatTimingBlock     =   RECORD
           bRunStatTimingMode           :     System.Boolean;
           dbReservedStat_0             :     System.Byte;
           dbStartingHour               :     System.Byte;
           dbStartingMinute             :     System.Byte;
           dwTotalTimeInMinutes         :     System.Word;
           dwRemTimeInMinutes           :     System.Word;
           dwInitTicksPerMinute         :     System.Word;
           dwCurTicksForMinute          :     System.Word;
           lpStatTimingMemBlock         :     System.Pointer;
           lpCurKeystrokesTimingRec     :     System.Pointer;
                               END;
    {* statistics record block *}


    {* keystrokes timing record *}
    recKeystrokesTiming     =   RECORD
                       dwUserKeystrokes       :    System.Word;
                       dwProgramKeystrokes    :    System.Word;
                                END;
    {* keystrokes timing record *}


    {* word parameter description *}
    recWordParameter        =   RECORD
                       lpVarAddr       :    System.Pointer;
                       dwMinValue      :    System.Word;
                       dwDefaultValue  :    System.Word;
                       dwMaxValue      :    System.Word;
                                END;
    {* word parameter description *}


    {* boolean parameter description *}
    recBooleanParameter        =   RECORD
                       lpVarAddr       :    System.Pointer;
                       bMinValue       :    System.Boolean;
                       bDefaultValue   :    System.Boolean;
                       bMaxValue       :    System.Boolean;
                                   END;
    {* boolean parameter description *}


    {* byte parameter description *}
    recByteParameter           =   RECORD
                       lpVarAddr       :    System.Pointer;
                       dbMinValue      :    System.Byte;
                       dbDefaultValue  :    System.Byte;
                       dbMaxValue      :    System.Byte;
                                   END;
    {* byte parameter description *}


    {* Pascal string parameter description *}
    recPascalStrParameter        =   RECORD
                       lpVarAddr       :    System.Pointer;
                       dwMaxStrLen     :    System.Word;
                                   END;
    {* Pascal string parameter description *}


    {* command line parameter description *}
     recParameterType       =   RECORD
                       sParamName      :    System.PChar;
                       dwParamType     :    System.Word;
                       lpParamDesc     :    System.Pointer;
                                END;
    {* command line parameter description  *}




{*TYPCONST.INC*}
{*====================== TYPED CONSTANTS PART ==========================*}

CONST

    setAscii7_NoCtrl   :    SET OF System.Char  =  [#32..#127];
    setAscii8_NoCtrl   :    SET OF System.Char  =  [#32..#255];
    setHexChars        :    SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];
    setUnusedLeadChars :    SET OF System.Char = [achHTAB,achSpace];
    setDelimiters      :    SET OF System.Char = [achHTAB,achSpace,achComma,achColon,achEqual];

    giErrorCode          :   System.Integer  =  errOK;

    gdwEnvDictHandle     :   System.Word     =  $00;

    gliWordsPerDictRead  :   System.Longint  =  0;
    gliWordsPerDictBuild :   System.Longint  =  0;
    gdwEstimatedDictSize :   System.Word     =  0;

{$IFDEF   DemVer}
    gdwInitTicks         :   System.Word     =  aTicksPerSecond;
    gdwCurTicks          :   System.Word     =  aTicksPerSecond;
{$ENDIF} {DemVer}

    gbLink_FA_Ok         :   System.Boolean  =  System.True;
    gbLink_BA_Ok         :   System.Boolean  =  System.True;
    gbLink_FE_Ok         :   System.Boolean  =  System.True;
    gbLink_BE_Ok         :   System.Boolean  =  System.True;
    gbLink_AS_Ok         :   System.Boolean  =  System.True;
    gbLink_ES_Ok         :   System.Boolean  =  System.True;

{$IFDEF   EvaVer}
    gsSerialNumber       :   STRING[15]  = asBlank;
{$ELSE}
    gsSerialNumber       :   STRING[15]  = 'Serial number: ';
{$ENDIF} {EvaVer}
    gsCountryCode        :   STRING[3]   = '007';
    gsUserCode           :   STRING[8]   = '00000001';

    gdbCurExternalRelease        :      System.Byte     =   aExtMajorVer;
    gdbCurExternalVersion        :      System.Byte     =   aExtMinorVer;
    gdbCurExternalRevision       :      System.Byte     =   aExtLevel;

    gdwCurIdleModeHotkey         :   System.Word     =  $00;
    gdwCurManualModeHotkey       :   System.Word     =  $00;
    gdwCurAddModeHotkey          :   System.Word     =  $00;
    gdwCurSearchModeHotkey       :   System.Word     =  $00;
    gdwCurEnvironmentHotKey      :   System.Word     =  $00;
    gdwCurVideoIndicationHotKey  :   System.Word     =  $00;
    gdbCurIdleModeScanCode          :   System.Byte  =  $00;
    gdbCurManualModeScanCode        :   System.Byte  =  $00;
    gdbCurAddModeScanCode           :   System.Byte  =  $00;
    gdbCurSearchModeScanCode        :   System.Byte  =  $00;
    gdbCurEnvironmentScanCode       :   System.Byte  =  $00;
    gdbCurVideoIndicationScanCode   :   System.Byte  =  $00;
    gdwCurInitSearchFlags        :   System.Word     =  $00;
    gdwCurUserEnvOptions         :   System.Word     =  $00;
    gdbCurColorVideoAttr         :   System.Byte     =  (aForeColorAttribDef)+(aBackColorAttribDef SHL 4);
    gdbCurMonoVideoAttr          :   System.Byte     =  (aForeColorAttribDef)+(aBackColorAttribDef SHL 4);
    gchCurForwardSearchSymbol       :   System.Char  =  achNULL;
    gchCurBackwardSearchSymbol      :   System.Char  =  achNULL;
    gchCurNonSpecialSymbol          :   System.Char  =  achNULL;
    gchCurSearchAbbrevSymbol        :   System.Char  =  achNULL;
    gchCurSearchExpressionSymbol    :   System.Char  =  achNULL;
    gchCurDirectionSearchOrderSym   :   System.Char  =  achNULL;
    gchCurDictSearchOrderSym        :   System.Char  =  achNULL;
    gchCurCaseSearchSym             :   System.Char  =  achNULL;
    gchCurMiddleSrchSym             :   System.Char  =  achNULL;
    gchCurBreakInputSym             :   System.Char  =  achNULL;
    gchCurSingleWordSearchSym       :   System.Char  =  achNULL;
    gsCurDictName16                 :   DictNameSTR16    =  asBlank;
    gsCurDictComment32              :   DictCommentSTR32 =  asBlank;
    gsCurDelimiters16               :   DelimitersSTR16  =  asBlank;
    gchCurAutoAddChar               :   System.Char  =  achSPACE;
    gchCurDelimDefinitionSym        :   System.Char  =  achNULL;
    gchCurNonDefSym                 :   System.Char  =  achNULL;
    gchCurOpenNumericSym            :   System.Char  =  achNULL;
    gchCurCloseNumericSym           :   System.Char  =  achNULL;
    gdbCurSearchType                :   System.Byte  =  aBestFitType;
    gdbCurActiveModeBorder          :   System.Byte  =  aOverscanColorIsBlack;
    gdbCurIdleModeBorder            :   System.Byte  =  aOverscanColorIsBlack;
    gchCurCaseMapArray256           :   arrayCaseMapTable256 =
                        (#$00,#$01,#$02,#$03,#$04,#$05,#$06,#$07,
                         #$08,#$09,#$0A,#$0B,#$0C,#$0D,#$0E,#$0F,
                         #$10,#$11,#$12,#$13,#$14,#$15,#$16,#$17,
                         #$18,#$19,#$1A,#$1B,#$1C,#$1D,#$1E,#$1F,
                         #$20,#$21,#$22,#$23,#$24,#$25,#$26,#$27,
                         #$28,#$29,#$2A,#$2B,#$2C,#$2D,#$2E,#$2F,
                         #$30,#$31,#$32,#$33,#$34,#$35,#$36,#$37,
                         #$38,#$39,#$3A,#$3B,#$3C,#$3D,#$3E,#$3F,
                         #$40,#$61,#$62,#$63,#$64,#$65,#$66,#$67,
                         #$68,#$69,#$6A,#$6B,#$6C,#$6D,#$6E,#$6F,
                         #$70,#$71,#$72,#$73,#$74,#$75,#$76,#$77,
                         #$78,#$79,#$7A,#$5B,#$5C,#$5D,#$5E,#$5F,
                         #$60,#$41,#$42,#$43,#$44,#$45,#$46,#$47,
                         #$48,#$49,#$4A,#$4B,#$4C,#$4D,#$4E,#$4F,
                         #$50,#$51,#$52,#$53,#$54,#$55,#$56,#$57,
                         #$58,#$59,#$5A,#$7B,#$7C,#$7D,#$7E,#$7F,
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
   gdbCurScanCodeTable256    :    arrayScanCodeTable256  =  
                       ($00,$00,$00,$00,$00,$00,$00,$00,   {00-07}
                        $0E,$0F,$00,$00,$00,$1C,$00,$00,   {08-0F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {10-17}
                        $00,$00,$00,$01,$00,$00,$00,$00,   {18-1F}
                        $39,$02,$00,$00,$00,$00,$00,$28,   {20-27}
                        $00,$00,$37,$00,$33,$0C,$34,$35,   {28-2F}
                        $0B,$02,$03,$04,$05,$06,$07,$08,   {30-37}
                        $09,$0A,$00,$27,$00,$0D,$00,$00,   {38-3F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {40-47}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {48-4F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {50-57}
                        $00,$00,$00,$1A,$2B,$1B,$00,$00,   {58-5F}
                        $29,$1E,$30,$2E,$20,$12,$21,$22,   {60-67}
                        $23,$17,$24,$25,$26,$32,$31,$18,   {68-6F}
                        $19,$10,$13,$1F,$14,$16,$2F,$11,   {70-77}
                        $2D,$15,$2C,$00,$00,$00,$00,$00,   {78-7F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {80-87}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {88-8F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {90-97}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {98-9F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {A0-A7}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {A8-AF}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {B0-B7}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {B8-BF}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {C0-C7}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {C8-CF}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {D0-D7}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {D8-DF}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {E0-E7}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {E8-EF}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {F0-F7}
                        $00,$00,$00,$00,$00,$00,$00,$00);  {F8-FF}
   gdbCurWordCharTable256    :    arrayScanCodeTable256  =
                       ($00,$00,$00,$00,$00,$00,$00,$00,   {00-07}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {08-0F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {10-17}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {18-1F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {20-27}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {28-2F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {30-37}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {38-3F}
                        $00,$01,$01,$01,$01,$01,$01,$01,   {40-47}
                        $01,$01,$01,$01,$01,$01,$01,$01,   {48-4F}
                        $01,$01,$01,$01,$01,$01,$01,$01,   {50-57}
                        $01,$01,$01,$00,$00,$00,$00,$00,   {58-5F}
                        $00,$01,$01,$01,$01,$01,$01,$01,   {60-67}
                        $01,$01,$01,$01,$01,$01,$01,$01,   {68-6F}
                        $01,$01,$01,$01,$01,$01,$01,$01,   {70-77}
                        $01,$01,$01,$00,$00,$00,$00,$00,   {78-7F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {80-87}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {88-8F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {90-97}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {98-9F}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {A0-A7}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {A8-AF}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {B0-B7}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {B8-BF}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {C0-C7}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {C8-CF}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {D0-D7}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {D8-DF}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {E0-E7}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {E8-EF}
                        $00,$00,$00,$00,$00,$00,$00,$00,   {F0-F7}
                        $00,$00,$00,$00,$00,$00,$00,$00);  {F8-FF}
    gchLowCaseMapArray256           :   arrayCaseMapTable256 =
                        (#$00,#$01,#$02,#$03,#$04,#$05,#$06,#$07,
                         #$08,#$09,#$0A,#$0B,#$0C,#$0D,#$0E,#$0F,
                         #$10,#$11,#$12,#$13,#$14,#$15,#$16,#$17,
                         #$18,#$19,#$1A,#$1B,#$1C,#$1D,#$1E,#$1F,
                         #$20,#$21,#$22,#$23,#$24,#$25,#$26,#$27,
                         #$28,#$29,#$2A,#$2B,#$2C,#$2D,#$2E,#$2F,
                         #$30,#$31,#$32,#$33,#$34,#$35,#$36,#$37,
                         #$38,#$39,#$3A,#$3B,#$3C,#$3D,#$3E,#$3F,
                         #$40,#$61,#$62,#$63,#$64,#$65,#$66,#$67,
                         #$68,#$69,#$6A,#$6B,#$6C,#$6D,#$6E,#$6F,
                         #$70,#$71,#$72,#$73,#$74,#$75,#$76,#$77,
                         #$78,#$79,#$7A,#$5B,#$5C,#$5D,#$5E,#$5F,
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

    gdbCurMultiplexChannel   :   System.Byte     =  0;
    gdbFreeMultiplexChannel  :   System.Byte     =  0;

    gbConfigDone         :   System.Boolean  =  System.False;
    gbLoadDataDict       :   System.Boolean  =  System.False;
    gbResidentPartFound  :   System.Boolean  =  System.False;
    gdbUserHelpRequest   :   System.Boolean  =  System.False;
    gbRestoreInts        :   System.Boolean  =  System.False;
    gbUseAltCall         :   System.Boolean  =  System.False;
    gbTestCpuType        :   System.Boolean  =  System.False;
    gbFoundInt154F       :   System.Boolean  =  System.False;
    gbSortCaseIgnore     :   System.Boolean  =  System.False;
    gdbSortByAlphabet    :   System.Byte     =  aNoneSortingOrder;
    gdbSortBySize        :   System.Byte     =  aNoneSortingOrder;

    glpOldExitProc       :   System.Pointer  =  NIL;
    glpCurIntVec08       :   System.Pointer  =  NIL;
    glpCurIntVec09       :   System.Pointer  =  NIL;
    glpCurIntVec15       :   System.Pointer  =  NIL;
    glpCurIntVec16       :   System.Pointer  =  NIL;
    glpCurIntVec2F       :   System.Pointer  =  NIL;

    gsDefaultConfigPath  :   STRING          =  asBlank;
    gsHelpFileName       :   STR10           =  'TYPIST.HLP';

    glpInitFarCall       :   System.Pointer  =  NIL;
    glpFarCallManager    :   System.Pointer  =  NIL;
    glpNearCallIndexTable :  ARRAY[0..aMaxAvailCallBackIndex] OF System.Word=
                                 (0,0,0,0,0,0,0,0,
                                  0,0,0,0,0,0,0,0,
                                  0,0,0,0,0,0,0,0,
                                  0,0,0);

{$IFDEF   DemVer}
    gsSimulatedUserInput :   STRING          =  asBlank;
    gdbSimCharsCount     :   System.Byte     =  0;
    gdbSimCharsStrOfs    :   System.Byte     =  0;
{$ENDIF} {DemVer}

{$IFDEF   DebVer}
    gsJournalFileName    :   STR12           =  'TYPIST.JRF';
{$ENDIF} {DebVer}

    {* switches of compilation process *}
{$IFDEF   ComVer}
    gbCommercialVerOk           :   System.Boolean  =  System.True;
{$ELSE}
    gbCommercialVerOk           :   System.Boolean  =  System.False;
{$ENDIF} {ComVer}
{$IFDEF   EvaVer}
    gbEvaluationVerOk           :   System.Boolean  =  System.True;
{$ELSE}
    gbEvaluationVerOk           :   System.Boolean  =  System.False;
{$ENDIF} {EvaVer}
{$IFDEF   DebVer}
    gbDebugVerOk                :   System.Boolean  =  System.True;
{$ELSE}
    gbDebugVerOk                :   System.Boolean  =  System.False;
{$ENDIF} {DebVer}
{$IFDEF   TstVer}
    gbTestVerOk                 :   System.Boolean  =  System.True;
{$ELSE}
    gbTestVerOk                 :   System.Boolean  =  System.False;
{$ENDIF} {TstVer}
{$IFDEF   DemVer}
    gbDemoVerOk                 :   System.Boolean  =  System.True;
{$ELSE}
    gbDemoVerOk                 :   System.Boolean  =  System.False;
{$ENDIF} {DemVer}
{$IFDEF   StaVer}
    gbStatVerOk                 :   System.Boolean  =  System.True;
{$ELSE}
    gbStatVerOk                 :   System.Boolean  =  System.False;
{$ENDIF} {StaVer}
{$IFDEF   EngVer}
    gbEnglishVerOk              :   System.Boolean  =  System.True;
{$ELSE}
    gbEnglishVerOk              :   System.Boolean  =  System.False;
{$ENDIF} {EngVer}
{$IFDEF   RusVer}
    gbRussianVerOk              :   System.Boolean  =  System.True;
{$ELSE}
    gbRussianVerOk              :   System.Boolean  =  System.False;
{$ENDIF} {RusVer}
{$IFDEF   Add8KB}
    gbAddSpace8K_Ok             :   System.Boolean  =  System.True;
{$ELSE}
    gbAddSpace8K_Ok             :   System.Boolean  =  System.False;
{$ENDIF} {Add8KB}
{$IFDEF   Add16KB}
    gbAddSpace16K_Ok            :   System.Boolean  =  System.True;
{$ELSE}
    gbAddSpace16K_Ok            :   System.Boolean  =  System.False;
{$ENDIF} {Add16KB}


    {* user interface parameters *}

    gsConfigFileName     :    STRING              =  asBlank;
    grecConfigFileNameParm  :    recPascalStrParameter  =
                                     (lpVarAddr:@gsConfigFileName;
                                      dwMaxStrLen:aMaxStrLen);

    gsSetDictName        :    DictNameSTR16       =  asBlank;
    grecSetDictParm      :    recPascalStrParameter  =
                                     (lpVarAddr:@gsSetDictName;
                                      dwMaxStrLen:System.SizeOf(DictNameSTR16));

    gsRemoveDictName     :    DictNameSTR16       =  asBlank;
    grecRemoveDictParm   :    recPascalStrParameter  =
                                     (lpVarAddr:@gsRemoveDictName;
                                      dwMaxStrLen:System.SizeOf(DictNameSTR16));

    gdbMemType           :    System.Byte          =  aMemoryTypeIsUndefined;
    gbHighMemOk          :    System.Boolean       =  System.False;
    grecHighMemParm      :    recBooleanParameter  =
                                     (lpVarAddr:@gbHighMemOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbDispVerInfoOk      :    System.Boolean       =  System.False;
    grecDispVerInfoParm  :    recBooleanParameter  =
                                     (lpVarAddr:@gbDispVerInfoOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);


    gsDosEnvVar             :    STRING              =  asDosEnvVarDef;
    grecDosEnvVarParm       :    recPascalStrParameter  =
                                     (lpVarAddr:@gsDosEnvVar;
                                      dwMaxStrLen:aMaxStrLen);

{$IFDEF   StaVer}
    gdwStatTime          :    System.Word    =  0;
    grecStatTimeParm     :    recWordParameter  =
                                     (lpVarAddr:@gdwStatTime;
                                      dwMinValue:aStatMinutesMin;
                                      dwDefaultValue:aStatMinutesDef;
                                      dwMaxValue:aStatMinutesMax);

    gbDispTypingStatOk      :    System.Boolean       =  System.False;
    grecDispTypingStatParm  :    recBooleanParameter  =
                                     (lpVarAddr:@gbDispTypingStatOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbResetStatOk        :    System.Boolean       =  System.False;
    grecResetStatParm    :    recBooleanParameter  =
                                     (lpVarAddr:@gbResetStatOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);
{$ENDIF} {StaVer}

{$IFDEF   DebVer}
    gdwDebugLevel        :    System.Word    =  btNoDebugInfo;
    grecDebugLevelParm   :    recWordParameter  =
                                     (lpVarAddr:@gdwDebugLevel;
                                      dwMinValue:btNoDebugInfo;
                                      dwDefaultValue:btNoDebugInfo;
                                      dwMaxValue:btTraceAll);

    gbJournalFileOk      :    System.Boolean       =  System.False;
    grecJournalFileParm  :    recBooleanParameter  =
                                     (lpVarAddr:@gbJournalFileOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);
{$ENDIF} {DebVer}

    gbTestModeOk         :    System.Boolean       =  System.False;
    grecTestModeOkParm   :    recBooleanParameter  =
                                     (lpVarAddr:@gbTestModeOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
{$IFDEF   TstVer}
                                      bMaxValue:System.True);
{$ELSE}
                                      bMaxValue:System.False);
{$ENDIF} {TstVer}

{$IFDEF   DemVer}
    gbDemoModeOk         :    System.Boolean       =  System.False;
    grecDemoModeOkParm   :    recBooleanParameter  =
                                     (lpVarAddr:@gbDemoModeOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);
{$ENDIF} {DemVer}

    gbDictDiagDumpOk        :    System.Boolean       =  System.False;
    grecDictDiagDumpOkParm  :    recBooleanParameter  =
                                     (lpVarAddr:@gbDictDiagDumpOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbEnvDiagDumpOk         :    System.Boolean       =  System.False;
    grecEnvDiagDumpOkParm   :    recBooleanParameter  =
                                     (lpVarAddr:@gbEnvDiagDumpOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbStatDiagDumpOk        :    System.Boolean       =  System.False;
    grecStatDiagDumpOkParm  :    recBooleanParameter  =
                                     (lpVarAddr:@gbStatDiagDumpOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbAddDictOk             :    System.Boolean       =  System.False;
    grecAddDictOkParm       :    recBooleanParameter  =
                                     (lpVarAddr:@gbAddDictOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbLoadOk             :    System.Boolean       =  System.False;
    grecLoadOkParm       :    recBooleanParameter  =
                                     (lpVarAddr:@gbLoadOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbUnLoadOk             :    System.Boolean       =  System.False;
    grecUnLoadOkParm       :    recBooleanParameter  =
                                     (lpVarAddr:@gbUnLoadOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbHelpFileOk         :    System.Boolean       =  System.False;
    grecHelpFileOkParm   :    recBooleanParameter  =
                                     (lpVarAddr:@gbHelpFileOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbListAllOk             :    System.Boolean       =  System.False;
    grecListAllOkParm       :    recBooleanParameter  =
                                     (lpVarAddr:@gbListAllOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbTsrInfoOk             :    System.Boolean       =  System.False;
    grecTsrInfoOkParm       :    recBooleanParameter  =
                                     (lpVarAddr:@gbTsrInfoOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gdbRunTimerVal           :    System.Byte          =  aNoneTimer;
    grecRunTimerValParm      :    recByteParameter  =
                                     (lpVarAddr:@gdbRunTimerVal;
                                      dbMinValue:aStopTimer;
                                      dbDefaultValue:aNoneTimer;
                                      dbMaxValue:aStartTimer);

    gdbCallBackIntNum    :   System.Byte     =  aMultiplexInt;
    grecCallBackIntParm  :   recByteParameter  =
                                     (lpVarAddr:@gdbCallBackIntNum;
                                      dbMinValue:aMinIntelIntNum;
                                      dbDefaultValue:aMultiplexInt;
                                      dbMaxValue:aMaxIntelIntNum);

    gdbUserMultiplexChannel   :   System.Byte     =  aUSER_First_MPID;
    grecUserMultChannelParm   :   recByteParameter  =
                                     (lpVarAddr:@gdbUserMultiplexChannel;
                                      dbMinValue:aDOS_First_MPID;
                                      dbDefaultValue:aUSER_First_MPID;
                                      dbMaxValue:aUSER_Last_MPID);

{$IFDEF   DemVer}
    gdbUserTimeFactor       :   System.Byte       =  aUserTimeFactorDef;
    grecUserTimeFactorParm  :   recByteParameter  =
                                     (lpVarAddr:@gdbUserTimeFactor;
                                      dbMinValue:aUserTimeFactorMin;
                                      dbDefaultValue:aUserTimeFactorDef;
                                      dbMaxValue:aUserTimeFactorMax);

    gdbPauseDelayInSec      :   System.Byte       =  aPauseDelayInSecDef;
    grecPauseDelayInSecParm :   recByteParameter  =
                                     (lpVarAddr:@gdbPauseDelayInSec;
                                      dbMinValue:aPauseDelayInSecMin;
                                      dbDefaultValue:aPauseDelayInSecDef;
                                      dbMaxValue:aPauseDelayInSecMax);

    gdbUserTimeTicks        :   System.Byte       =  aWaitTicksDef;
    grecUserTimeTicksParm   :   recByteParameter  =
                                     (lpVarAddr:@gdbUserTimeTicks;
                                      dbMinValue:aWaitTicksMin;
                                      dbDefaultValue:aWaitTicksDef;
                                      dbMaxValue:aWaitTicksMax);
{$ENDIF} {DemVer}

   gbLanguagesPresentArray  :   ARRAY[aMinLanguage..aMaxLanguage]  OF  System.Boolean =
                       (
{$IFDEF   EngVer}
                          System.True,
{$ELSE}
                          System.False,
{$ENDIF} {EngVer}
{$IFDEF   RusVer}
                          System.True
{$ELSE}
                          System.False
{$ENDIF} {RusVer}
                       );
   gdwLangMsgIdxArray       :   ARRAY[aMinLanguage..aMaxLanguage,aMinLanguage..aMaxLanguage]  OF  System.Word =
                      ((3,4),     {English}    {see MESSAGES.PAS for more info}
                       (3,4));    {Russian}

    gdwCurLanguage          :   System.Word       =  aDefLanguage;
    grecLanguageParm        :   recWordParameter  =
                                     (lpVarAddr:@gdwCurLanguage;
                                      dwMinValue:aMinLanguage;
                                      dwDefaultValue:aDefLanguage;
                                      dwMaxValue:aMaxLanguage);


    gdwTextLineNum          :   System.Word       =  aMinOutLineOnScreen;
    gdwMaxScreenLines       :   System.Word       =  aDefMaxOutLineForScreen;
    grecMaxScreenLinesParm  :   recWordParameter  =
                                     (lpVarAddr:@gdwMaxScreenLines;
                                      dwMinValue:aDisableScreenPage;
                                      dwDefaultValue:aDefMaxOutLineForScreen;
                                      dwMaxValue:aBigOutLinesForScreenNum);

    gdwResidentPartInParas  :   System.Word       =  0;
    glpFreeMemoryDictPool   :   System.Pointer    =  NIL;
    gdwFreeSpaceInDictMem   :   System.Word       =  0;
    gdwFreeSpaceSize        :   System.Word       =  aReserveMemoryDef;
    grecFreeSpaceSizeParm   :   recWordParameter  =
                                     (lpVarAddr:@gdwFreeSpaceSize;
                                      dwMinValue:aReserveMemoryMin;
                                      dwDefaultValue:aReserveMemoryDef;
                                      dwMaxValue:aReserveMemoryMax);


   {* magic words for user interface *}

      aMaxParamStrLen          =     8;

      asScreenLines            =    'lines';
      asConfigFileName         =    'fc';
{$IFDEF   DebVer}
      asEnableDebugInfo        =    'debug';
      asJournalFile            =    'jfile';
{$ENDIF} {DebVer}
      asSetTestMode            =    'test';
{$IFDEF   DemVer}
      asTimeFactor             =    'factor';
      asPauseDelay             =    'pause';
      asWaitTimeTicks          =    'wticks';
      asSetDemoMode            =    'demo';
{$ENDIF} {DemVer}
{$IFDEF   StaVer}
      asDispStat               =    'typstat';
      asResetStat              =    'reset';
      asTimeStat               =    'time';
{$ENDIF} {StaVer}
      asEnableDictDiagDump     =    'dictdump';
      asEnableEnvDiagDump      =    'envdump';
      asEnableStatDiagDump     =    'statdump';
      asLoadTSR                =    'load';
      asUnLoadTSR              =    'unload';
      asLoadHelpFile           =    'helpfile';
      asAddDict                =    'add';
      asSetDict                =    'set';
      asRemoveDict             =    'rem';
      asFreeSpaceSize          =    'memsize';
      asMemType                =    'high';
      asListAll                =    'list';
      asCallBackInt            =    'int';
      asUserChannel            =    'mult';
      asHumanLanguage          =    'lang';
      asDispVerInfo            =    'ver';
      asDispTsrInfo            =    'inf';
      asRunTimer               =    'timer';
      asDosEnvVar              =    'var';
      asHelpOnScreen           =    '?';
      asAltHelpOnScreen        =    'help';

{$IFDEF   StaVer}
      aStatParms               =     3;
{$ELSE}
      aStatParms               =     0;
{$ENDIF} {StaVer}

{$IFDEF   DemVer}
      aDemoParms               =     4;
{$ELSE}
      aDemoParms               =     0;
{$ENDIF} {DemVer}

{$IFDEF   DebVer}
      aDebugParms              =     2;
{$ELSE}
      aDebugParms              =     0;
{$ENDIF} {DebVer}

      aNumOfCmdParms           =     24+aDebugParms+aDemoParms+aStatParms;


    gachProgramOptions  :  ARRAY[1..aNumOfCmdParms]  OF  recParameterType =
      ((sParamName:asScreenLines;dwParamType:aParmIsWord;lpParamDesc:@grecMaxScreenLinesParm),
       (sParamName:asConfigFileName;dwParamType:aParmIsPascalStr;lpParamDesc:@grecConfigFileNameParm),
{$IFDEF   DebVer}
       (sParamName:asEnableDebugInfo;dwParamType:aParmIsWord;lpParamDesc:@grecDebugLevelParm),
       (sParamName:asJournalFile;dwParamType:aParmIsBoolean;lpParamDesc:@grecJournalFileParm),
{$ENDIF} {DebVer}
       (sParamName:asSetTestMode;dwParamType:aParmIsBoolean;lpParamDesc:@grecTestModeOkParm),
{$IFDEF   DemVer}
       (sParamName:asSetDemoMode;dwParamType:aParmIsBoolean;lpParamDesc:@grecDemoModeOkParm),
       (sParamName:asPauseDelay;dwParamType:aParmIsByte;lpParamDesc:@grecPauseDelayInSecParm),
       (sParamName:asWaitTimeTicks;dwParamType:aParmIsByte;lpParamDesc:@grecUserTimeTicksParm),
       (sParamName:asTimeFactor;dwParamType:aParmIsByte;lpParamDesc:@grecUserTimeFactorParm),
{$ENDIF} {DemVer}
{$IFDEF   StaVer}
       (sParamName:asDispStat;dwParamType:aParmIsBoolean;lpParamDesc:@grecDispTypingStatParm),
       (sParamName:asResetStat;dwParamType:aParmIsBoolean;lpParamDesc:@grecResetStatParm),
       (sParamName:asTimeStat;dwParamType:aParmIsWord;lpParamDesc:@grecStatTimeParm),
{$ENDIF} {StaVer}
       (sParamName:asEnableDictDiagDump;dwParamType:aParmIsBoolean;lpParamDesc:@grecDictDiagDumpOkParm),
       (sParamName:asEnableEnvDiagDump;dwParamType:aParmIsBoolean;lpParamDesc:@grecEnvDiagDumpOkParm),
       (sParamName:asEnableStatDiagDump;dwParamType:aParmIsBoolean;lpParamDesc:@grecStatDiagDumpOkParm),
       (sParamName:asLoadTSR;dwParamType:aParmIsBoolean;lpParamDesc:@grecLoadOkParm),
       (sParamName:asUnLoadTSR;dwParamType:aParmIsBoolean;lpParamDesc:@grecUnLoadOkParm),
       (sParamName:asAddDict;dwParamType:aParmIsBoolean;lpParamDesc:@grecAddDictOkParm),
       (sParamName:asSetDict;dwParamType:aParmIsPascalStr;lpParamDesc:@grecSetDictParm),
       (sParamName:asRemoveDict;dwParamType:aParmIsPascalStr;lpParamDesc:@grecRemoveDictParm),
       (sParamName:asFreeSpaceSize;dwParamType:aParmIsWord;lpParamDesc:@grecFreeSpaceSizeParm),
       (sParamName:asMemType;dwParamType:aParmIsBoolean;lpParamDesc:@grecHighMemParm),
       (sParamName:asLoadHelpFile;dwParamType:aParmIsBoolean;lpParamDesc:@grecHelpFileOkParm),
       (sParamName:asListAll;dwParamType:aParmIsBoolean;lpParamDesc:@grecListAllOkParm),
       (sParamName:asCallBackInt;dwParamType:aParmIsByte;lpParamDesc:@grecCallBackIntParm),
       (sParamName:asUserChannel;dwParamType:aParmIsByte;lpParamDesc:@grecUserMultChannelParm),
       (sParamName:asHumanLanguage;dwParamType:aParmIsWord;lpParamDesc:@grecLanguageParm),
       (sParamName:asDispVerInfo;dwParamType:aParmIsBoolean;lpParamDesc:@grecDispVerInfoParm),
       (sParamName:asDispTsrInfo;dwParamType:aParmIsBoolean;lpParamDesc:@grecTsrInfoOkParm),
       (sParamName:asRunTimer;dwParamType:aParmIsByte;lpParamDesc:@grecRunTimerValParm),
       (sParamName:asDosEnvVar;dwParamType:aParmIsPascalStr;lpParamDesc:@grecDosEnvVarParm),
       (sParamName:asHelpOnScreen;dwParamType:aParmIsIndefinite;lpParamDesc:NIL),
       (sParamName:asAltHelpOnScreen;dwParamType:aParmIsIndefinite;lpParamDesc:NIL));




{*VARS.INC*}
{*=========================== VARIABLES PART ===========================*}

VAR

   gDirectSearchArray              :   arrayPTable256;
   gSymFrequencyNodesArrayFA,
   gSymFrequencyNodesArrayBA,
   gSymFrequencyNodesArrayFE,
   gSymFrequencyNodesArrayBE,
   gAbbrevSizesFrequencyNodesArray,
   gExprSizesFrequencyNodesArray   :   arrayDWTable256;
   gdwSortingArrayCaseIgnore,
   gdwSortingArrayCaseMatch        :   arrayDWTable256;
   dwMainCodeSeg,
   gdwIndex,
   gdwTempIndex,
   gdwTemp                     :   System.Word;
   gdbTempPos                  :   System.Byte;
   gbParmFound                 :   System.Boolean;
   gsTempParm                  :   STR8;
   gsTemp                      :   STRING;
   gsPath                      :   Dos.PathStr;
   gsDir                       :   Dos.DirStr;
   gsName                      :   Dos.NameStr;
   gsExtension                 :   Dos.ExtStr;
{$IFDEF   DebVer}
    gfDebugOutputStream        :   System.Text;
{$ENDIF} {DebVer}
   gdbTempBuf                  :   ARRAY[1..512]   OF  System.Byte;
{$IFDEF   ComVer}
   gdbLargeTextInBuf           :   ARRAY[1..8192]  OF  System.Byte;
{$ENDIF} {ComVer}


 {* absolute references to memory locations *}


IMPLEMENTATION

{BEGIN}
END.
