{****************************************************************************
//                            File TYPIST.PAS
//
//                   Intellectual typist (main module)
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/typist.pas $
//  $RCSfile: typist.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:59:16 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: typist.pas $
//      Revision 1.1  1999/01/03 17:59:16  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             TYPIST.PAS                                      }
{ PURPOSE               Decrease greatly the time to type regular text  }
{ VERSION               0.01                                            }
{ DATE                  14-Sep-94                                       }
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
{ ARGUMENTS             See program on-line help                        }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       DOS.TPU        (DOS functions and procedures)   }
{                       SHOWTERR.TPU   (Turbo RunTime Errors Handler)   }
{                       GLOBALS.TPU    (global public definitions)      }
{                       MESSAGES.TPU   (text user messages)             }
{                       STRLIB.TPU     (string support library)         }
{                       VIDEO.TPU      (user screen interface)          }
{                       DOSCTL.TPU     (advanced DOS support library)   }
{                       USRPARAM.TPU   (user parameters processing)     }
{                       CALLBACK.TPU   (multiplex interface)            }
{                       DICTMEM.TPU    (dump dictionary in memory)      }
{                       DEMOMODE.TPU   (demo simulation mode)           }
{                       USERDICT.TPU   (user dictionary preprocessor)   }
{                       CONFIG.TPU     (program configuration options)  }
{                       THISVER.TPU    (compiled version information)   }
{                       Project Maintence Files                         }
{                       TYPIST.MAK        (auto compiling & linking)    }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       0.01   14-Sep-94  DS  initial release           }
{-----------------------------------------------------------------------}



{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   INTELLECTUAL_TYPIST;


{** switches for compilation **}
{$S-}                       {*  stack checking    *}
{$R-}                       {*  range checking    *}
{$X+}                       {*  extended syntax   *}
{$M 65520,65536,65536 }     {*  stack/heap space  *}


{** Defined switches to build miscellaneous versions. **}
{** DebVer  <- debugging version  **}
{** TstVer  <- testing version    **}
{** DemVer  <- demo version       **}
{** ComVer  <- commercial version **}
{** EvaVer  <- evaluation version **}
{** EngVer  <- english version    **}
{** RusVer  <- russian version    **}
{** StaVer  <- add statistics     **}
{** Add8KB  <- add free space     **}
{** Add16KB <- add free space     **}


{*** other modules ***}
USES
     Dos,
     ShowTErr,
     Globals,
     Messages,
     StrLib,
     Video,
     DosCtl,
     UsrParam,
     CallBack,
     DictMem,
{$IFDEF   DemVer}
     DemoMode,
{$ENDIF} {DemVer}
     UserDict,
     Config,
     ThisVer;


{*FORWARD.INC*}
{*=========================== FORWARD REFERENCES PART ==================*}

PROCEDURE    _fndwGetTableOffsetByIndex; near; FORWARD;
PROCEDURE    _PutFirstTableOffsetByIndex; near; FORWARD;
PROCEDURE    _fndwGetNodeOptions; near; FORWARD;
PROCEDURE    _StoreNodeOptions; near; FORWARD;
PROCEDURE    _fndwGetNodeLinkOffsetForFA; near; FORWARD;
PROCEDURE    _StoreNodeLinkOffsetForFA; near; FORWARD;
PROCEDURE    _fndwGetNodeLinkOffsetForBA; near; FORWARD;
PROCEDURE    _StoreNodeLinkOffsetForBA; near; FORWARD;
PROCEDURE    _fndwGetNodeLinkOffsetForFE; near; FORWARD;
PROCEDURE    _StoreNodeLinkOffsetForFE; near; FORWARD;
PROCEDURE    _fndwGetNodeLinkOffsetForBE; near; FORWARD;
PROCEDURE    _StoreNodeLinkOffsetForBE; near; FORWARD;
PROCEDURE    _fndwGetNodeAccessCount; near; FORWARD;
PROCEDURE    _StoreNodeAccessCount; near; FORWARD;
PROCEDURE    _fndwGetNodeHitCount; near; FORWARD;
PROCEDURE    _StoreNodeHitCount; near; FORWARD;
PROCEDURE    _fndbGetNodeAbbreviationSize; near; FORWARD;
PROCEDURE    _StoreNodeAbbreviationSize; near; FORWARD;
PROCEDURE    _fndbGetNodeExpressionSize; near; FORWARD;
PROCEDURE    _StoreNodeExpressionSize; near; FORWARD;
PROCEDURE    _fndwGetNodeAbbreviationOfs; near; FORWARD;
PROCEDURE    _fndwGetNodeExpressionOfs; near; FORWARD;
PROCEDURE    _fndwGetNodeLinkOffsetForAS; near; FORWARD;
PROCEDURE    _StoreNodeLinkOffsetForAS; near; FORWARD;
PROCEDURE    _fndwGetNodeLinkOffsetForES; near; FORWARD;
PROCEDURE    _StoreNodeLinkOffsetForES; near; FORWARD;
PROCEDURE    _fndwGetNodeSizeTotal; near; FORWARD;
PROCEDURE    _CallBackInterface; near; FORWARD;


{*INLINE.INC}
{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE
         _IO_DELAY_2;
{*
Description.
       Some i/o bus delay for back-to-back operations.
*}
INLINE($EB/$00/     {jmp short $ + 2}
       $EB/$00);    {jmp short $ + 2}
{ _IO_DELAY_2 }



{*=========================== RESIDENT PART ============================*}

{*KEYBOARD.INC*}

PROCEDURE
         _KeyboardHandler; far; assembler;
{*
Description.
      Permanent resident code and data;
      includes keyboard, timer, multiplex handler;
*}
ASM

{Entry for interrupt handlers}
@EntryInt15:
                DB     Globals.adbNearJumpOpcode
                DW     (OFFSET @EnterHandlerInt15) - 3 - Globals.aDWord*0
                nop
@EntryInt16:
                DB     Globals.adbNearJumpOpcode
                DW     (OFFSET @EnterHandlerInt16) - 3 - Globals.aDWord*1
                nop
@EntryInt2F:
                DB     Globals.adbNearJumpOpcode
                DW     (OFFSET @EnterHandlerInt2F) - 3 - Globals.aDWord*2
                nop
@EntryInt08:
                DB     Globals.adbNearJumpOpcode
                DW     (OFFSET @EnterHandlerInt08) - 3 - Globals.aDWord*3
                nop
@EntryInt09:
                DB     Globals.adbNearJumpOpcode
                DW     (OFFSET @EnterHandlerInt09) - 3 - Globals.aDWord*4
                nop

{addresses of previous interrupt routines}
@lpPrevInt15:
             DD       0
@lpPrevInt16:
             DD       0
@lpPrevInt2F:
             DD       0
@lpPrevInt08:
             DD       0
@lpPrevInt09:
             DD       0

{!!!Very important!!!}
{This is the critical offset, it must be equal 10*4=40 bytes from beginning}
{of procedure (current mode/interrupt/state/channel/version)}
{!!!Very important!!!}
@dbCurMultiplexNum:
             DB       0
@dbCurCallBackIntNum:
             DB       Globals.aMultiplexInt
@dbCurStateMode:
             DB       Globals.aStateIsIdleMode

{dynamic extension of dictionary}
@bDynamicExtendDict:
             DB       System.False

{current found keyboard status bit flags}
@CurKbdStatusFlags:
             DW       0

{global free space links}
@lpFreeSpaceStart:
            DD        0
@dwFreeSpaceSize:
            DW        0

{statistics record block}
{$IFDEF   StaVer}
@bRunStatTiming:
            DB        System.False
@dbResStat_0:
            DB        0
@dbStartHour:
            DB        0
@dbStartMinute:
            DB        0
@dwTotalStatTimeInMinutes:
            DW        0
@dwRemStatTimeInMinutes:
            DW        0
@dwInitTimeTicksPerMinute:
            DW        0
@dwCurTicksForOneMin:
            DW        0
@lpStatMemBlock:
            DD        0
@lpCurKeystrokesRecord:
            DD        0
{$ENDIF} {StaVer}

{environment links}
@dwCurEnvironment:
             DW       0
@ddEnvironmentTable:
             {Globals.aEnviron_Avail_Max(=1,2,16) entries only available}
{$IFDEF   EvaVer}
             DD       0,0
{$ELSE}
{$IFDEF   ComVer}
             DD       0,0,0,0
             DD       0,0,0,0
             DD       0,0,0,0
             DD       0,0,0,0
{$ELSE}
             DD       0
{$ENDIF} {ComVer}
{$ENDIF} {EvaVer}

{keyboard links}
@dwCurIdleModeHotkey:
             DW       0
@dwCurManualModeHotkey:
             DW       0
@dwCurAddModeHotkey:
             DW       0
@dwCurSearchModeHotkey:
             DW       0
@dwCurEnvironmentHotKey:
             DW       0
@dwCurVideoIndicationHotKey:
             DW       0
@dbCurIdleModeScanCode:
             DB       0
@dbCurManualModeScanCode:
             DB       0
@dbCurAddModeScanCode:
             DB       0
@dbCurSearchModeScanCode:
             DB       0
@dbCurEnvironmentScanCode:
             DB       0
@dbCurVideoIndicationScanCode:
             DB       0

{search/environment/miscellaneous options}
@dwCurInitSearchFlags:
             DW       0
@dwCurUserEnvOptions:
             DW       0
@dbCurColorVideoAttr:
             DB       Globals.achNULL
@dbCurMonoVideoAttr:
             DB       Globals.achNULL

{metasymbols}
@chCurForwardSearchSymbol:
             DB       Globals.achNULL
@chCurBackwardSearchSymbol:
             DB       Globals.achNULL
@chCurNonSpecialSymbol:
             DB       Globals.achNULL
@chCurSearchAbbrevSymbol:
             DB       Globals.achNULL
@chCurSearchExpressionSymbol:
             DB       Globals.achNULL
@chCurDirectionSearchOrderSym:
             DB       Globals.achNULL
@chCurDictSearchOrderSym:
             DB       Globals.achNULL
@chCurCaseSearchSym:
             DB       Globals.achNULL
@chCurMiddleSrchSym:
             DB       Globals.achNULL
@chCurBreakInputSym:
             DB       Globals.achNULL
@chCurSingleWordSearchSym:
             DB       Globals.achNULL

{dictionary name; size=1 byte, name=16 bytes}
@sCurDictName16:
             DB       Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL

{dictionary comment; size=1 byte, name=32 bytes}
@sCurDictComment32:
             DB       Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL

{delimiters array; size=1 byte, name=16 bytes}
@sCurDelimiters16:
             DB       Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
             DB       Globals.achNULL,Globals.achNULL,Globals.achNULL,Globals.achNULL
{auto added character}
@chCurAutoAddChar:
             DB       Globals.achNULL
{definition delimiter}
@chCurDelimDefinitionSym:
             DB       Globals.achNULL
{non-special symbol marker}
@chCurNonDefSym:
             DB       Globals.achNULL
{open numeric parameter}
@chCurOpenNumericSym:
             DB       Globals.achNULL
{close numeric parameter}
@chCurCloseNumericSym:
             DB       Globals.achNULL
{search type for dictionary}
@dbCurSearchType:
             DB       Globals.aBestFitType

{dictionary links}
@CurForwardSearchAbbrevTablePtr:
             DD       0
@CurBackwardSearchAbbrevTablePtr:
             DD       0
@CurForwardSearchDictTablePtr:
             DD       0
@CurBackwardSearchDictTablePtr:
             DD       0
@CurStrSizeSearchAbbrevTablePtr:
             DD       0
@CurStrSizeSearchDictTablePtr:
             DD       0

{local free space links}
@lpCurFreePointer:
             DD       0
@dwCurFreeSize:
             DW       0

{ border or overscan color }
@dbCurActiveModeBorder:
             DB       Globals.aOverscanColorIsBlack
@dbCurIdleModeBorder:
             DB       Globals.aOverscanColorIsBlack

{case-mapping character array}
@chCurCaseMapArray256:
    { Globals.aMaxCharBit8+1 DB (0); each line contains 32 DWords=128 bytes }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

{key scancodes array}
@dbCurScanCodeArray256:
    { Globals.aMaxCharBit8+1 DB (0); each line contains 32 DWords }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

{single word characters array}
@dbCurWordCharTable256:
    { Globals.aMaxCharBit8+1 DB (0); each line contains 32 DWords }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

{status code of last operation}
@dbLastStatusCode:
             DB         Globals.errStatus_Success
{temporary storage}
@dbPrevStateMode:
             DB         0
{store a found offset of matching pattern}
@dwMatchPatternOfs:
             DW         0
{ordered table of dictionary types to search}
@dbSearchDictTable6:
             DB         0, 0, 0, 0, 0, 0

{raw user text buffer from keyboard input}
@pofsFirstCharInRawBuf:
             DW         0
@pofsUserRawInputWord:
             DW         OFFSET   @dbUserRawInputWord256
@dbUserRawInputWord256:
    {Globals.aMaxStrLen+1 DB (0); each line contains 32 DWords}
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

{non-case searching}
@ddSearchTable:
             DD         0
@chOldSearchTableSym:
             DB         0
@chNewSearchTableSym:
             DB         0

{current string length index}
@CurStrLenIndexCount:
             DW         0
{# of chars to remove from user input}
@dwCharsToReplaceBefore:
             DW         0
{found user search flags}
@dwUserSearchFlags:
             DW         0

{buffer after analyzing before searching}
@pofsUserSearchInputWordLength:
             DW         0
@dbUserSearchInputWord256:
    {Globals.aMaxStrLen+1 DB (0); each line contains 32 DWords}
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

{replace buffer filled after searching}
@pofsCurUserReplaceInput:
             DW         OFFSET   @dbUserReplaceInputWord256
@dwUserReplaceInputWordLength:
             DW         0
@dbUserReplaceInputWord256:
    {Globals.aMaxStrLen+1 DB (0); each line contains 32 DWords}
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

{INT $16 dispatcher table}
@pofsSoftKeyboardDispatchTable:
             DW         OFFSET   @ITypist_StateIsIdleMode
             DW         OFFSET   @ITypist_StateIsManualMode
             DW         OFFSET   @ITypist_StateIsAddMode
             DW         OFFSET   @ITypist_StateIsSearchMode

{search submode}
@dbSearchSubState:
             DB         Globals.aSearchSubStateIsAnalyze
{last received scan code from system keyboard handler}
@dbLastScanCode:
             DB         0

{search mode dispatch table}
@pofsSearchStateDispatchTable:
             DW         OFFSET   @SearchSubStateIsAnalyze
             DW         OFFSET   @aSearchSubStateIsSearch
             DW         OFFSET   @SearchSubStateIsReplace

{analyze mode}
@pofsMetaSymDispatchTable:
             DW         OFFSET   @CurForwardSearchSymbol
             DW         OFFSET   @CurBackwardSearchSymbol
             DW         OFFSET   @CurNonSpecialSymbol
             DW         OFFSET   @CurSearchAbbrevSymbol
             DW         OFFSET   @CurSearchExpressionSymbol
             DW         OFFSET   @CurDirectionSearchOrderSym
             DW         OFFSET   @CurDictSearchOrderSym
             DW         OFFSET   @CurCaseSearchSym
             DW         OFFSET   @CurMiddleSearchSym
             DW         OFFSET   @CurBreakInputSym
             DW         OFFSET   @CurSingleWordSearchSym

{# of leading delimiters before expected regular expression}
@LeadingDelimitersCount:
             DW        0
{searching types table}
@pofsSearchDictDispatchTable:
             DW         OFFSET   @SearchForwardAbbreviationDict
             DW         OFFSET   @SearchBackwardAbbreviationDict
             DW         OFFSET   @SearchForwardExpressionDict
             DW         OFFSET   @SearchBackwardExpressionDict
             DW         OFFSET   @SearchMiddleAbbreviationDict
             DW         OFFSET   @SearchMiddleExpressionDict

{temporary storage}
@dwJumpToCodeInt2F:
             DW          0
{multiplex channel interface dispatch table}
@pofsMultilpexDispatchTable:
             DW         OFFSET   @ITypist_Install_Status
             DW         OFFSET   @ITypist_Current_Status
             DW         OFFSET   @ITypist_Add_Dic_Entry
             DW         OFFSET   @ITypist_Get_Set_Kbd_Mode
             DW         OFFSET   @ITypist_Get_Free_Elem
             DW         OFFSET   @ITypist_Get_Set_Environ
             DW         OFFSET   @ITypist_Add_Environ
             DW         OFFSET   @ITypist_List_Environ
             DW         OFFSET   @ITypist_Search_Dict_Entry
             DW         OFFSET   @ITypist_New_Free_Space
             DW         OFFSET   @ITypist_Get_Raw_User_Input
             DW         OFFSET   @ITypist_Filter_Raw_User_Input
             DW         OFFSET   @ITypist_Get_Search_User_Input
             DW         OFFSET   @ITypist_Get_Set_Prev_Int_Vec
             DW         OFFSET   @ITypist_Get_Replace_Str
             DW         OFFSET   @ITypist_Get_Set_User_Options
             DW         OFFSET   @ITypist_Get_Cur_Environ_Parms
             DW         OFFSET   @ITypist_Reset_Cur_Environ
             DW         OFFSET   @ITypist_Reset_Free_Space_Ptr
             DW         OFFSET   @ITypist_Get_Set_Estimate_Timer
             DW         OFFSET   @ITypist_Get_Program_Info
             DW         OFFSET   @ITypist_Copy_Free_Links_To_Env
             DW         OFFSET   @ITypist_Get_Set_Stat_Block

{mode letter}
@chActiveModeLetterTable4:
             DB         Globals.achIdleModeLetter
             DB         Globals.achManualModeLetter
             DB         Globals.achAddModeLetter
             DB         Globals.achSearchModeLetter
{submode letter}
@chActiveSearchSubModeLetterTable3:
             DB         Globals.achAnalyzeStateLetter
             DB         Globals.achSearchStateLetter
             DB         Globals.achReplaceStateLetter

{distance code for search best fit pattern}
@dbDiffInSizes:
             DB         Globals.aMaxStrLen
{last expression size}
@dwLastSavedAbbrOfs:
             DW         0
{last dictionary node}
@lpLastSavedDictNode:
             DD         0

{use for the time delay between character returning to system}
@dbWaitTimerTicks:
             DB         0
@dbInitWaitTimerTicks:
             DB         Globals.aWaitTicksDef

{estimated timer values}
@bTimerFlag:
             DB         System.False
@dbOldValueOfPort8255_B:
             DB         0
@dwLastTimerValue:
             DW         0

{pointer to dynamically allocated node}
@lpDictNode:
             DD         0

{function code}
@dwFuncCodeInAX:
             DW         0

{reserved empty abbreviation: special case}
@dbReservedEmptyAbbrSize:
             DB         Globals.asResvdEmptyAbbrLength
@dbReservedEmptyAbbr3:
             DB         Globals.achEnglishLetter_E
             DB         Globals.achEnglishLetter_E
             DB         Globals.achEnglishLetter_E

{sync INT $16 read and read-ahead}
@bSyncInt16:
             DB         System.False



{ ********************* INT $15 ************************* }

{ ------------------------------------------------------- }
{ Description:                                            }
{    Handler of general OS/BIOS services.                 }
{    Hooks a function of coming scan code from system;    }
{    If match scan code and hotkey found then signals to  }
{    BIOS to remove this scan code from system queue,     }
{    otherwise does nothing.                              }
{ ------------------------------------------------------- }
@EnterHandlerInt15:
             pushf
             test     WORD PTR  cs:[@dwCurUserEnvOptions], Globals.btUseInt154F
             jz      @GoToPreviousInt15
             cmp      ah, Globals.aUserHookForScanCode   {our hoook?}
             jne     @GoToPreviousInt15
@FilterUserHookForScanCode:
             call     @LookMatchHotScanKey
             jc      @CheckToSwitch
             popf                        {restore stack}
             clc                         {indicate that scan code changed!}
             sti                         {re-enable interrupts}
             retf     2                  {discard flags on stack}
@CheckToSwitch:
             call     @StateSwitcherFromKeyboard
@GoToPreviousInt15:
             popf
             jmp      DWORD PTR cs:[@lpPrevInt15]
{ End }

{ ********************* INT $15 ************************* }



{ ********************* SUPPLEMENT ********************* }

{ Subroutine }
{ ****************************************************** }
{ Purpose:                                               }
{         Searches table of keys for matching hotkey     }
{ Enter:                                                 }
{         AL = system scan code                          }
{ Exit:                                                  }
{         NC = match scan code found                     }
{         CY = no matching char                          }
{ Used:                                                  }
{         Flags                                          }
{ Description:                                           }
{         Searches for match scan code;                  }
{         if not found then exits;                       }
{         searches for matching mode supplemental keys;  }
{         if not found the exits;                        }
{         calls task switcher;                           }
{         sets signal to indicate the used hotkey;       }
{         put back the scan code if searching failed;    }
{ ****************************************************** }
@LookMatchHotScanKey:
             sti             {enable other CPU events}
             push     ax
             push     ds
             push     bx
             push     cx
             mov      bx, cs
             mov      ds, bx
             mov      BYTE PTR  ds:[@dbLastScanCode], al
             sub      bx, bx       {offset=0}
             mov      cx, (recEnvironmentDesc.dbVideoIndicationScanCode)-(recEnvironmentDesc.dbIdleModeScanCode)+aByte
@TryNextScanCode:
             cmp      al, BYTE PTR  ds:[bx][OFFSET @dbCurIdleModeScanCode]
             je      @MatchScanCodeFound
             inc      bx
             dec      cx
             jnz     @TryNextScanCode
@NotOurHotKey:
             sub      ax, ax
             stc                        {no matching code found or error!}
@LookMatchScanCodeDone:
             mov      BYTE PTR  ds:[@dbLastScanCode], al     {AX=0}
             mov      WORD PTR  ds:[@CurKbdStatusFlags], ax
             pop      cx
             pop      bx
             pop      ds
             pop      ax
             retn
@MatchScanCodeFound:
             call     @GetKeyboardStatusFlags
             mov      WORD PTR  ds:[@CurKbdStatusFlags], ax
             shl      bx, 1
             mov      cx, WORD PTR  ds:[bx][OFFSET @dwCurIdleModeHotkey]
             or       cx, cx                {empty hotkey?}
             jz      @CompareStatusHotKeys
             and      ax, cx                {isolate our bits}
@CompareStatusHotKeys:
             cmp      ax, cx                {same bits?}
             jne     @NotOurHotKey
             call     @StateSwitcherFromKeyboard
             cmp      BYTE PTR  ds:[@dbLastScanCode], 0
             jne     @NotOurHotKey
             cmp      BYTE PTR  ds:[@dbCurStateMode], Globals.aStateIsManualMode
             jne     @ResetKbdStatusFlags
             cmp      BYTE PTR  ds:[@dbLastStatusCode], Globals.errStatus_Success
             jne     @NotOurHotKey              {searching failed?}
@ResetKbdStatusFlags:
             sub      ax, ax                    {sets CF to 0!}
             jmp     @LookMatchScanCodeDone
{ End }



{ Subroutine }
{ ********************************************************* }
{ Purpose:                                                  }
{     Gets the current keyboard status flags (mode hotkey)  }
{ Enter:                                                    }
{         None                                              }
{ Exit:                                                     }
{         AX = current keyboard status flags                }
{ Used:                                                     }
{         AX, Flags                                         }
{ Description:                                              }
{         Sets the BIOS data segment for ES segment;        }
{         reads the BIOS keyboard status data as words;     }
{         checks, sets or resets the corresponding bits     }
{         for constructed word of one-bit flags;            }
{ ********************************************************* }
@GetKeyboardStatusFlags:
             push     bx
             push     cx
             push     es
             mov      ax, Globals.aBiosDataSeg
             mov      es, ax
             mov      bx, WORD PTR  es:[Globals.adbKbdStatus1]
             mov      cx, WORD PTR  es:[Globals.adbKbdStatus3]
             sub      ax, ax
             test     bl, Globals.btLeftShiftKey
             jz      @Check_Other_1
             or       al, Globals.btLeftShiftHotKey
@Check_Other_1:
             test     bl, Globals.btRightShiftKey
             jz      @Check_Other_2
             or       al, Globals.btRightShiftHotKey
@Check_Other_2:
             test     bl, Globals.btCtrlKey
             jz      @Check_Other_4
             test     bh, Globals.btLeftCtrlKey
             jz      @Check_Other_3
             or       al, Globals.btLeftControlHotKey
@Check_Other_3:
             test     cl, Globals.btRightCtrlKey
             jz      @Check_Other_4
             or       al, Globals.btRightControlHotKey
@Check_Other_4:
             test     bl, Globals.btAltKey
             jz      @Check_Other_6
             test     bh, Globals.btLeftAltKey
             jz      @Check_Other_5
             or       al, Globals.btLeftAltHotKey
@Check_Other_5:
             test     cl, Globals.btRightAltKey
             jz      @Check_Other_6
             or       al, Globals.btRightAltHotKey
@Check_Other_6:
             test     bl, Globals.btScrollLockON
             jz      @Check_Other_7
             or       al, Globals.btScrollLockHotKey
@Check_Other_7:
             test     bl, Globals.btNumLockON
             jz      @Check_Other_8
             or       al, Globals.btNumLockHotKey
@Check_Other_8:
             test     bl, Globals.btCapsLockON
             jz      @Check_Other_9
             or       ah, (Globals.btCapsLockHotKey SHR 8)
@Check_Other_9:
             pop      es
             pop      cx
             pop      bx
             retn
{ End }



{ Subroutine }
{ ********************************************* }
{ Purpose:                                      }
{         Task switcher between modes and       }
{         executor of task in current mode      }
{ Enter:                                        }
{         None                                  }
{ Exit:                                         }
{         None                                  }
{ Used:                                         }
{         Flags                                 }
{         (interrupts are enabled at exit)      }
{ Description:                                  }
{         Searches for matching hotkey;         }
{         if not found then exits;              }
{         executes the corresponding service;   }
{         updates video indicators;             }
{         does nice clicks for user;            }
{ ********************************************* }
@StateSwitcherFromKeyboard:
             sti
             push     ax
             push     bx
             push     cx
             push     dx
             push     ds
             push     es
             mov      ax, cs
             mov      ds, ax
             test     WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btUseInt154F
             jz      @GetCurKbdStatus
             sub      ax, ax
             xchg     ax, WORD PTR  ds:[@CurKbdStatusFlags]  {zeroes word}
             or       ax, ax               {skips if status word was built}
             jnz     @CheckForSwitchMode
@GetCurKbdStatus:
             call     @GetKeyboardStatusFlags
@CheckForSwitchMode:
             mov      bl, BYTE PTR  ds:[@dbLastScanCode]
             or       bl, bl                    {empty?}
             jnz     @RunCheckForSwitchKey
             or       ax, ax                    {empty?}
             jz      @ExitStateSwitchDone
@RunCheckForSwitchKey:
             mov      cx, ax
             mov      dx, WORD PTR  ds:[@dwCurSearchModeHotkey]
             or       dx, dx                    {empty hotkey?}
             jz      @CompareHotKeys_1
             and      cx, dx                    {isolate our bits}
@CompareHotKeys_1:
             cmp      cx, dx                    {are same bits set?}
             jne     @CheckSwitchMode_1
             cmp      BYTE PTR  ds:[@dbCurSearchModeScanCode], bl
             jne     @CheckSwitchMode_1
             mov      al, BYTE PTR  ds:[@dbCurStateMode]
             cmp      al, Globals.aStateIsManualMode
             jne     @BadConditionsFound
@EnterSearchMode:
             mov      BYTE PTR  ds:[@dbPrevStateMode], al
             call     @SelectSearchMode
             jmp     @ModeSwitchDone
@CheckSwitchMode_1:
             mov      cx, ax
             mov      dx, WORD PTR  ds:[@dwCurIdleModeHotkey]
             or       dx, dx
             jz      @CompareHotKeys_2
             and      cx, dx
@CompareHotKeys_2:
             cmp      cx, dx
             jne     @CheckSwitchMode_2
             cmp      BYTE PTR  ds:[@dbCurIdleModeScanCode], bl
             jne     @CheckSwitchMode_2
             mov      al, Globals.aStateIsIdleMode
             call     @SelectIdleMode
             jmp     @ModeSwitchDone
@CheckSwitchMode_2:
             mov      cx, ax
             mov      dx, WORD PTR  ds:[@dwCurManualModeHotkey]
             or       dx, dx
             jz      @CompareHotKeys_3
             and      cx, dx
@CompareHotKeys_3:
             cmp      cx, dx
             jne     @CheckSwitchMode_3
             cmp      BYTE PTR  ds:[@dbCurManualModeScanCode], bl
             jne     @CheckSwitchMode_3
             mov      al, Globals.aStateIsManualMode
             call     @SelectManualMode
             jmp     @ModeSwitchDone
@CheckSwitchMode_3:
             mov      cx, ax
             mov      dx, WORD PTR  ds:[@dwCurAddModeHotkey]
             or       dx, dx
             jz      @CompareHotKeys_4
             and      cx, dx
@CompareHotKeys_4:
             cmp      cx, dx
             jne     @CheckSwitchMode_4
             cmp      BYTE PTR  ds:[@dbCurAddModeScanCode], bl
             jne     @CheckSwitchMode_4
             mov      al, BYTE PTR  ds:[@dbCurStateMode]
             cmp      al, Globals.aStateIsManualMode
             jne     @BadConditionsFound
@EnterAddMode:
             mov      BYTE PTR  ds:[@dbPrevStateMode], al
             call     @SelectAddMode
             jmp     @ModeSwitchDone
@CheckSwitchMode_4:
             mov      cx, ax
             mov      dx, WORD PTR  ds:[@dwCurEnvironmentHotKey]
             or       dx, dx
             jz      @CompareHotKeys_5
             and      cx, dx
@CompareHotKeys_5:
             cmp      cx, dx
             jne     @CheckSwitchMode_5
             cmp      BYTE PTR  ds:[@dbCurEnvironmentScanCode], bl
             jne     @CheckSwitchMode_5
             call     @SwitchToNextActiveEnvironment
             jmp     @SetVideoIndicators
@CheckSwitchMode_5:
             mov      cx, ax
             mov      dx, WORD PTR  ds:[@dwCurVideoIndicationHotKey]
             or       dx, dx
             jz      @CompareHotKeys_6
             and      cx, dx
@CompareHotKeys_6:
             cmp      cx, dx
             jne     @CheckSwitchMode_6
             cmp      BYTE PTR  ds:[@dbCurVideoIndicationScanCode], bl
             jne     @CheckSwitchMode_6
             xor      WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btVideoIndicationOn
             jmp     @SetVideoIndicators
@CheckSwitchMode_6:
             jmp     @ExitStateSwitchDone
@BadConditionsFound:
             jmp     @ExitStateSwitchDone
@ModeSwitchDone:
             mov      BYTE PTR  ds:[@dbCurStateMode], al  {new mode}
@SetVideoIndicators:
             mov      BYTE PTR  ds:[@dbLastScanCode], 0 {code was used!}
             call     @UpdateVideoIndicators
             call     @DoNiceClickOnModeChange
@ExitStateSwitchDone:
             pop      es
             pop      ds
             pop      dx
             pop      cx
             pop      bx
             pop      ax
             retn
{ End }



{ Subroutine }
{ *********************************************** }
{ Purpose:                                        }
{    Switches to the next active environment      }
{ Enter:                                          }
{    DS = our data segment                        }
{    BX = new environment handle                  }
{ Exit:                                           }
{    None                                         }
{ Used:                                           }
{    BX, CX, DX, Flags                            }
{ Description:                                    }
{    Scans all the environment table for active   }
{    environment and tries to switch to them;     }
{    if found or all the list was scanned, exits; }
{    If new environment was set then set border;  }
{ *********************************************** }
@SwitchToNextActiveEnvironment:
             mov      bx, WORD  PTR  ds:[@dwCurEnvironment]
             mov      dx, bx                          {do marker of end}
@GetNextEnvNum:
             inc      bx
             cmp      bx, Globals.aEnviron_Avail_Max  {check for wraparound}
             jbe     @ValidRangEnvNum
             mov      bx, Globals.aEnviron_Avail_Min
@ValidRangEnvNum:
             cmp      bx, dx                          {all the list?}
             je      @AllEnvNumPassed
             mov      cx, bx                          {save handle temporary}
             call    @SetNewCurEnv
             jnc     @NextEnvWasSelected
             mov      bx, cx                          {recover old handle}
             jmp     @GetNextEnvNum
@NextEnvWasSelected:
             mov      al, BYTE PTR  ds:[@dbCurStateMode]
             call     @SetOverscanColorOnDisplay
@AllEnvNumPassed:
@SetNextActiveEnvDone:
             retn
{ End }



{ Subroutine }
{ ************************************* }
{ Purpose:                              }
{       Prepares the idle state mode    }
{ Enter:                                }
{       DS = our data segment           }
{       AL = idle mode value            }
{ Exit:                                 }
{       None                            }
{ Used:                                 }
{       None                            }
{ Description:                          }
{       Sets the border as indicator;   }
{ ************************************* }
@SelectIdleMode:
             call     @SetOverscanColorOnDisplay
             retn
{ End }



{ Subroutine }
{ ***************************************************** }
{ Purpose:                                              }
{               Prepares the manual state mode          }
{ Enter:                                                }
{               DS = our data segment                   }
{               AL = manual mode value                  }
{ Exit:                                                 }
{               None                                    }
{ Used:                                                 }
{               Flags                                   }
{ Description:                                          }
{               Sets the border screen color as marker; }
{               Flushes user raw input, i.e. makes sure }
{               that this input string is empty;        }
{               Sets some variables to initaial values; }
{ ***************************************************** }
@SelectManualMode:
             call     @SetOverscanColorOnDisplay
             call     @ResetRawUserInput
             mov      BYTE  PTR  ds:[@dbLastStatusCode], Globals.errStatus_Success
             mov      BYTE PTR  ds:[@dbSearchSubState], Globals.aSearchSubStateIsAnalyze
             retn
{ End }



{ Subroutine }
{ ****************************************************** }
{ Purpose:                                               }
{               Does the needing work in the add state   }
{               mode                                     }
{ Enter:                                                 }
{               DS = our data segment                    }
{ Exit:                                                  }
{               None                                     }
{ Used:                                                  }
{               AL, Flags                                }
{ Description:                                           }
{               Saves the current mode (manual!);        }
{               sets the new state mode (add!);          }
{               displays this on user screen;            }
{               flushes (resets) user search string,     }
{               i.e. makes sure search string is empty;  }
{               analyzes user definition for new entry   }
{               into current dictionary;                 }
{               if analyzing completes unsuccessfully,   }
{               then exits immediately;                  }
{               prepares the definition from user stream }
{               to remove signaling about the user       }
{               success;                                 }
{               switches to the search state mode and    }
{               the replace state submode to wipe the    }
{               user definition from the input stream;   }
{            Exit: flushes the user raw input string;    }
{ ****************************************************** }
@SelectAddMode:
             push     si
             mov      al, BYTE PTR  ds:[@dbCurStateMode]
             push     ax
             mov      al, Globals.aStateIsAddMode
             mov      BYTE PTR  ds:[@dbCurStateMode], al
             call     @UpdateVideoIndicators
             call     @ResetSearchUserInput
             call     @AnalyzeAndAddNewDictEntryDefinition
             mov      BYTE PTR  ds:[@dbLastStatusCode], al
             jc      @WipeDone
             call     @WipeNewAddedEntryFromInputStream
             pop      ax
             mov      BYTE PTR  ds:[@dbSearchSubState], Globals.aSearchSubStateIsReplace
             mov      al, Globals.aStateIsSearchMode
             push     ax
@WipeDone:
             call     @ResetRawUserInput
             pop      ax
             pop      si
             retn
{ End }



{ Subroutine }
{ ******************************************************* }
{ Purpose:                                                }
{               Does a work for the search state mode.    }
{ Enter:                                                  }
{               DS = our data segment                     }
{ Exit:                                                   }
{               None                                      }
{ Used:                                                   }
{               AX, BX, CX, Flags                         }
{ Description:                                            }
{               Displays the new current state on screen; }
{               flushes (resets) user search string,      }
{               i.e. makes sure search string is empty;   }
{               analyzes user input string;               }
{               searches the current dictionary for       }
{               matching replacing string;                }
{               flushes user raw input, i.e. makes sure   }
{               that this input string is empty;          }
{ ******************************************************* }
@SelectSearchMode:
             call     @UpdateVideoIndicators
             call     @ResetSearchUserInput
             call     @AnalyzeAndReplaceUserTextPattern
             call     @ResetRawUserInput
             retn
{ End }



{ Subroutine }
{ ***************************************************** }
{ Purpose:                                              }
{               Prepares the removing of the user       }
{               definition string from input stream     }
{ Enter:                                                }
{               DS = our data segment                   }
{ Exit:                                                 }
{               None                                    }
{ Used:                                                 }
{               Flags                                   }
{ Description:                                          }
{               Calculates how many characters must be  }
{               deleted from user input stream;         }
{               Writes the delete characters to replace }
{               string buffer;                          }
{ ***************************************************** }
@WipeNewAddedEntryFromInputStream:
             push     si
             push     dx
             mov      si, (OFFSET  @dbUserReplaceInputWord256)
             mov      WORD PTR  ds:[@pofsCurUserReplaceInput], si
             mov      dx, WORD PTR  ds:[@dwCharsToReplaceBefore]
             mov      WORD PTR  ds:[@dwUserReplaceInputWordLength], dx
             call     @FillReplaceBufWithBS
             pop      dx
             pop      si
             retn
{ End }



{ Subroutine }
{ ***************************************************** }
{ Purpose:                                              }
{               Analyzes and adds new entry to current  }
{               dictionary                              }
{ Enter:                                                }
{               DS = our data segment                   }
{ Exit:                                                 }
{               NC = successful addition                }
{               CY = analyzing and addition failed      }
{ Used:                                                 }
{               Flags                                   }
{ Description:                                          }
{               Splites the user input string to the    }
{               abbreviation and expression strings;    }
{               checks for uplication of entry;         }
{               if successful then copies them to       }
{               the current dictionary;                 }
{ ***************************************************** }
@AnalyzeAndAddNewDictEntryDefinition:
             call     @SplitUserDefinition
             jc      @DefinitionWasWrong
             call     @CheckForDuplicateEntry
             jc      @DefinitionWasWrong
             call     @CopyEntryToDictNode
@DefinitionWasWrong:
             retn
{ End }



{ Subroutine }
{ ******************************************************* }
{ Purpose:                                                }
{               Splites the new dictionary entry          }
{               definition string                         }
{ Enter:                                                  }
{               DS = our data segment                     }
{ Exit:                                                   }
{               NC = successful analyzing                 }
{               CY = analyzing and spliting failed        }
{ Used:                                                   }
{               Flags                                     }
{ Description:                                            }
{               Setups the definition string for analyze; }
{               if successful then separate abbreviation  }
{               expression strings, copies to the string  }
{               buffers;                                  }
{               check for duplication of entry;           }
{ ******************************************************* }
@SplitUserDefinition:
             call     @SetUpDefinitionToAnalyze
             jc      @SplitDone
             call     @SeparateAndCopyDefForAbbrAndExpr
@SplitDone:
             retn
{ End }



{ Subroutine }
{ *********************************************** }
{ Purpose:                                        }
{         Converts the binary number to decimal   }
{         representation number                   }
{         (works only for numbers in range 0..99) }
{ Enter:                                          }
{         AL = number                             }
{ Exit:                                           }
{         AL = decimals (digit)                   }
{         CL = ones (digit)                       }
{ Used:                                           }
{         AX, CL, flags                           }
{ Description:                                    }
{         Divides number by ten;                  }
{ *********************************************** }
@Hex2Dec:
             mov        cl, aTen
             div        cl
             add        ax, (Globals.achZero SHL 8) + Globals.achZero
             mov        cl, ah
             retn
{ End }



{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{         Outputs the video indication of program state      }
{         (direct access of video buffer)                    }
{ Enter:                                                     }
{         DS = our data segment                              }
{ Exit:                                                      }
{         None                                               }
{ Used:                                                      }
{         Flags                                              }
{ Description:                                               }
{ Format screen output -> X pairs character/video attribute  }
{  EEMSCC, where                                             }
{  EE = current environment                                  }
{  M  = current mode                                         }
{  S  = search submode                                       }
{  CC = last status code                                     }
{         Checks the permission bit setting;                 }
{         Gets the current video mode from the system BIOS;  }
{         Detects the color or mono mode currently in use;   }
{         Writes the output video indicators string at (0,0) }
{         location in the video buffer (fixed address).      }
{ ********************************************************** }
@UpdateVideoIndicators:
             test     WORD PTR  ds:[@dwCurUserEnvOptions], btVideoIndicationOn
             jnz      @UpdateOnScreen
             retn
@UpdateOnScreen:
             push      ax
             push      bx
             push      cx
             push      di
             push      es
             mov       ax, Globals.aBiosDataSeg
             mov       es, ax
             mov       al, es:[Globals.adbVideoMode]
             mov       bx, Globals.adwMonoTextVidBuf
             mov       ch, BYTE PTR  ds:[@dbCurMonoVideoAttr]
             cmp       al, Globals.aVidTextMode7
             je       @TextVidModeFound
             mov       bx, Globals.adwColorTextVidBuf
             mov       ch, BYTE PTR  ds:[@dbCurColorVideoAttr]
             cmp       al, Globals.aVidTextMode3
             ja       @UpdateVideoScreenDone
@TextVidModeFound:
             add       bx, es:[Globals.adwVidBufStart]
             mov       es, bx
             sub       di, di
             mov       ax, WORD PTR  ds:[@dwCurEnvironment]
             call      @Hex2Dec
             mov       ah, ch
             mov       es:[di], ax
             add       di, Globals.aWord
             mov       al, cl
             mov       es:[di], ax
             add       di, Globals.aWord
             sub       bx, bx
             mov       bl, BYTE PTR  ds:[@dbCurStateMode]
             sub       bl, Globals.aStateIsIdleMode
             mov       al, BYTE PTR  ds:[@chActiveModeLetterTable4].[bx]
             mov       ah, ch
             mov       es:[di], ax
             add       di, Globals.aWord
             sub       bx, bx
             mov       bl, BYTE PTR  ds:[@dbSearchSubState]
             mov       al, BYTE PTR  ds:[@chActiveSearchSubModeLetterTable3].[bx]
             mov       ah, ch
             mov       es:[di], ax
             add       di, Globals.aWord
             sub       ax, ax
             mov       al, BYTE PTR  ds:[@dbLastStatusCode]
             call      @Hex2Dec
             mov       ah, ch
             mov       es:[di], ax
             add       di, Globals.aWord
             mov       al, cl
             mov       es:[di], ax
@UpdateVideoScreenDone:
             pop       es
             pop       di
             pop       cx
             pop       bx
             pop       ax
             retn
{ End }



{ Subroutine }
{ ***************************************************** }
{ Purpose:                                              }
{               Does a nice click on the mode change    }
{               (direct access to hardware)             }
{ Enter:                                                }
{               DS = our data segment                   }
{ Exit:                                                 }
{               None                                    }
{ Used:                                                 }
{               Flags                                   }
{ Description:                                          }
{               Checks the permission bit setting;      }
{               Reprograms timer 2 of 8253 or 8254 PIT  }
{               to produce some sound;                  }
{ ***************************************************** }
@DoNiceClickOnModeChange:
             test     WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btClickOnModeChange
             jnz      @DoClickEnabled
             retn
@DoClickEnabled:
             push      ax
             push      cx
             mov       cx, 10
@1:
             push      cx
             mov       bx, 40
             in        al,  Globals.aPPI_8255_Port_B
             push      ax
@2:
             and       al, (Globals.aFullByte - (Globals.btSpeakerDataOutOn+Globals.btSpeakerGateOn))
             out       Globals.aPPI_8255_Port_B, al
             mov       cx, 20
@2A:
             dec       cx
             jnz      @2A
             or        al, Globals.btSpeakerDataOutOn
             out       Globals.aPPI_8255_Port_B, al
             mov       cx, 20
@3:
             dec       cx
             jnz      @3
             dec       bx
             jnz      @2
             pop       ax
             out       Globals.aPPI_8255_Port_B, al
             mov       cx, 80
@4:
             dec       cx
             jnz      @4
             pop       cx
             dec       cx
             jnz      @1
             pop      cx
             pop      ax
             retn
{ End }



{ Subroutine }
{ ***************************************************** }
{ Purpose:                                              }
{               Sets the overscan (border) screen color }
{ Enter:                                                }
{               DS = our data segment                   }
{               AL = current state mode                 }
{ Exit:                                                 }
{               None                                    }
{ Used:                                                 }
{               Flags                                   }
{ Description:                                          }
{               Gets the user search flags;             }
{               checks for enabling of border color;    }
{               checks for active mono text mode;       }
{               checks for active color text modes;     }
{               checks for EGA+ card presence;          }
{               sets the new border color;              }
{ ***************************************************** }
@SetOverscanColorOnDisplay:
             test     WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btSetBorderColorAsMarker
             jnz      @DoNewOverscanColor
             retn
@DoNewOverscanColor:
             push      ax
             push      bx
             push      cx
             push      es
             mov       bh, BYTE PTR  ds:[@dbCurActiveModeBorder]
             cmp       al, Globals.aStateIsManualMode
             je       @CurStateWasDetected
             mov       bh, BYTE PTR  ds:[@dbCurIdleModeBorder]
             cmp       al, Globals.aStateIsIdleMode
             jne      @SetOverscanColorDone
@CurStateWasDetected:
             and       bh, Globals.btOverscanColorMask    {use bits 0-5}
             mov       ax, Globals.aBiosDataSeg
             mov       es, ax
             mov       al, es:[Globals.adbVideoMode]
             cmp       al, Globals.aVidTextMode7
             je       @MonoTextVidModeFound
             cmp       al, Globals.aVidTextMode3
             ja       @SetOverscanColorDone
             push      bx
             mov       ah, Globals.aGetEgaInfo         {check EGA+ presence}
             mov       bx, 0FF10h                      {BL=subfunction}
             int       Globals.aVideoInt
             cmp       bh, 0FFh
             pop       bx
             je       @ColorModeDone
             mov       ax, (Globals.aVideoPaletteServices SHL 8) + Globals.aSetOverscanColor
             int       Globals.aVideoInt
@ColorModeDone:
             jmp      @SetOverscanColorDone
@MonoTextVidModeFound:
@SetOverscanColorDone:
             pop       es
             pop       cx
             pop       bx
             pop       ax
             retn
{ End }



{ Subroutine }
{ ***************************************************** }
{ Purpose:                                              }
{               Builds the dictionary search table      }
{ Enter:                                                }
{               DS = our data segment                   }
{ Exit:                                                 }
{               None                                    }
{ Used:                                                 }
{               AX, BX, CX, Flags                       }
{ Description:                                          }
{               Gets the user search flags;             }
{               checks for middle search;               }
{               checks for forward search;              }
{               checks for backward search;             }
{               checks for abbreviation search;         }
{               checks for expression search;           }
{               checks for direction search and         }
{               dictionary search;                      }
{ ***************************************************** }
@MakeTableToSearchDictBasedOnSearchFlags:
             push     dx
             mov      ax, WORD PTR  ds:[@dwUserSearchFlags]
             mov      bx, (Globals.btForwardSearchAbbreviation) + (Globals.btBackwardSearchAbbreviation SHL 8)
             mov      cx, (Globals.btForwardSearchExpression) + (Globals.btBackwardSearchExpression SHL 8)
             mov      dx, (Globals.btSearchAbbreviationSizes) + (Globals.btSearchExpressionSizes SHL 8)
             test     ax, Globals.btMiddleSearch
             jnz     @DoSearchTable_A
             mov      dx, (Globals.btNoSearchThisTable) + (Globals.btNoSearchThisTable SHL 8)
@DoSearchTable_A:
             test     ax, Globals.btForwardSearch
             jnz     @DoSearchTable_0
             mov      bl, Globals.btNoSearchThisTable
             mov      cl, bl
@DoSearchTable_0:
             test     ax, Globals.btBackwardSearch
             jnz     @DoSearchTable_1
             mov      bh, Globals.btNoSearchThisTable
             mov      ch, bh
@DoSearchTable_1:
             test     ax, Globals.btSearchAbbreviation
             jnz     @DoSearchTable_2
             mov      bx, (Globals.btNoSearchThisTable) + (Globals.btNoSearchThisTable SHL 8)
             mov      dl, (Globals.btNoSearchThisTable)
@DoSearchTable_2:
             test     ax, Globals.btSearchExpression
             jnz     @DoSearchTable_3
             mov      cx, (Globals.btNoSearchThisTable) + (Globals.btNoSearchThisTable SHL 8)
             mov      dh, (Globals.btNoSearchThisTable)
@DoSearchTable_3:
{ Register:  BL, BH, CL, CH             }
{ Defaults:  FA, BA, FE, BE             }
{ FF FA   priority    search tables     }
{ 0   0     B,E        BE,FE,BA,FA      }
{ 1   0     F,E        FE,BE,FA,BA      }
{ 0   1     B,A        BA,FA,BE,FE      }
{ 1   1     F,A        FA,BA,FE,BE      }
             and      ax, (Globals.btSearchFirstForward + Globals.btSearchFirstAbbreviation)
             jnz     @DoSearchTable_5
             xchg     bx, cx
@DoSearchTable_4:
             xchg     bl, bh
             xchg     cl, ch
             jmp     @DoSearchTable_6
@DoSearchTable_5:
             test     ax, Globals.btSearchFirstForward
             jz      @DoSearchTable_4
             test     ax, Globals.btSearchFirstAbbreviation
             jnz     @DoSearchTable_6
             xchg     bx, cx
@DoSearchTable_6:
             mov      WORD PTR  ds:[@dbSearchDictTable6].[0], bx
             mov      WORD PTR  ds:[@dbSearchDictTable6].[2], cx
             mov      WORD PTR  ds:[@dbSearchDictTable6].[4], dx
             pop      dx
             retn
{ End }



{ Subroutine }
{ ***************************************************** }
{ Purpose:                                              }
{               Analyzes and replaces user specified    }
{               text pattern                            }
{ Enter:                                                }
{               DS = our data segment                   }
{ Exit:                                                 }
{               AL = new current state mode             }
{ Used:                                                 }
{               AX, BX, CX, Flags                       }
{ Description:                                          }
{               Gets and saves the current state mode;  }
{               sets the search state mode;             }
{               updates the video indicators on screen; }
{               analyzes and maybe replaces the user    }
{               specified text pattern from input;      }
{               saves the returned status code;         }
{               gets back the saved state mode;         }
{               if substate mode is the replace submode }
{               then sets the search state mode,        }
{               otherwise uses the old state mode;      }
{ ***************************************************** }
@AnalyzeAndReplaceUserTextPattern:
             mov      al, BYTE PTR  ds:[@dbCurStateMode]
             push     ax
             mov      al, Globals.aStateIsSearchMode
             mov      BYTE PTR  ds:[@dbCurStateMode], al
             call     @UpdateVideoIndicators
             call     @AnalyzeAndReplaceTextPattern
             mov      BYTE PTR  ds:[@dbLastStatusCode], al
             pop      ax
             cmp      BYTE PTR  ds:[@dbSearchSubState], Globals.aSearchSubStateIsReplace
             jne     @RestorePrevStateMode
             mov      al, Globals.aStateIsSearchMode
@RestorePrevStateMode:
             retn
{ End }



{ Subroutine }
{ ******************************************************* }
{ Purpose:                                                }
{               Analyzes and replaces user specified      }
{               text pattern (heart of program)           }
{ Enter:                                                  }
{               DS = our data segment                     }
{ Exit:                                                   }
{               NC = matching entry found                 }
{               CY = no matching entry found              }
{               AL = status code                          }
{ Used:                                                   }
{               AX, BX, CX, Flags                         }
{ Description:                                            }
{               Checks for permit to run estimate timer,  }
{               if enabled then setup and run timer;      }
{               analyzes user input string for presence   }
{               of metasymbols and extracts pattern to    }
{               search;                                   }
{               builds dictionary search table;           }
{               searches the dictionary for matching user }
{               text pattern;                             }
{               stops estimate timer if it was enabled    }
{               and stores the elapsed time value;        }
{ ******************************************************* }
@AnalyzeAndReplaceTextPattern:
             cmp      BYTE PTR  ds:[@bTimerFlag], System.False
             je      @SkipEstimateTimeSetup
             call     @SetupTimerCounter2
@StartTimerCounting:
             in       al, Globals.aPPI_8255_Port_B
             mov      BYTE PTR  ds:[@dbOldValueOfPort8255_B], al
             or       al, Globals.btSpeakerGateOn
             out      Globals.aPPI_8255_Port_B, al
@SkipEstimateTimeSetup:
             call     @AnalyzeUserInputForMetaSymAndExpression
             jc      @AnalyzeAndReplaceDone
             call     @MakeTableToSearchDictBasedOnSearchFlags
             call     @SearchDictForMatchForUserInput
@AnalyzeAndReplaceDone:
             pushf
             push     ax
             cmp      BYTE PTR  ds:[@bTimerFlag], System.False
             je      @SkipEstimateTimeReset
@StopTimerCounting:
             mov      al, BYTE PTR  ds:[@dbOldValueOfPort8255_B]
             out      Globals.aPPI_8255_Port_B, al
             call     @ReadTimerCounter2
             mov      WORD PTR  ds:[@dwLastTimerValue], ax
@SkipEstimateTimeReset:
             pop      ax
             popf
             retn
{ End }



{ Subroutine }
{ ******************************************************* }
{ Purpose:                                                }
{               Flushes (resets) the user raw input       }
{               string buffer                             }
{ Enter:                                                  }
{               DS = our data segment                     }
{ Exit:                                                   }
{               None                                      }
{ Used:                                                   }
{               None                                      }
{ Description:                                            }
{               Resets the user raw input to beginning;   }
{ ******************************************************* }
@ResetRawUserInput:
             mov     WORD PTR  ds:[@pofsUserRawInputWord], (OFFSET @dbUserRawInputWord256)
             retn
{ End }



{ Subroutine }
{ ******************************************************* }
{ Purpose:                                                }
{               Flushes (resets) the user search input    }
{               string buffer                             }
{ Enter:                                                  }
{               DS = our data segment                     }
{ Exit:                                                   }
{               None                                      }
{ Used:                                                   }
{               AX, Flags                                 }
{ Description:                                            }
{               Copies the current user search flags;     }
{               resets the user search input to start;    }
{               resets other search global variables;     }
{ ******************************************************* }
@ResetSearchUserInput:
             mov      BYTE  PTR  ds:[@dbLastStatusCode], Globals.errStatus_Success
             mov      ax, WORD PTR  ds:[@dwCurInitSearchFlags]
             mov      WORD PTR  ds:[@dwUserSearchFlags], ax
             mov      WORD PTR  ds:[@pofsCurUserReplaceInput], (OFFSET  @dbUserReplaceInputWord256)
             mov      BYTE PTR  ds:[@dbDiffInSizes], Globals.aMaxStrLen
             sub      ax, ax
             mov      WORD PTR  ds:[@pofsUserSearchInputWordLength], ax
             mov      WORD PTR  ds:[@dwCharsToReplaceBefore], ax
             mov      WORD PTR  ds:[@dwUserReplaceInputWordLength], ax
             mov      WORD PTR  ds:[@dwLastSavedAbbrOfs], ax
             mov      WORD PTR  ds:[@lpLastSavedDictNode][0], ax
             mov      WORD PTR  ds:[@lpLastSavedDictNode][2], ax
             retn
{ End }



{ Subroutine }
{ ******************************************************* }
{ Purpose:                                                }
{               Gets the current char from raw buffer     }
{ Enter:                                                  }
{               DS = our data segment                     }
{               DS:SI -> raw buffer                       }
{               CX =  current count of remaining chars in }
{               buffer                                    }
{ Exit:                                                   }
{               AL = current character                    }
{               DS:SI -> next available char in buffer    }
{               CX = # of remaining chars in buffer       }
{ Used:                                                   }
{               AX, CX, SI, Flags                         }
{ Description:                                            }
{               Copies the current available character    }
{               from the string buffer;                   }
{               updates current pointer and counter for   }
{               the text string buffer;                   }
{ ******************************************************* }
@GetRawChar:
             mov      al, [si]
             inc      si
             dec      cx
             retn
{ End }



{ Subroutine }
{ ******************************************************* }
{ Purpose:                                                }
{               Stores the char into the raw buffer       }
{ Enter:                                                  }
{               DS = our data segment                     }
{               AL = character to store                   }
{               BP = count of copying chars to search     }
{               ES:BX -> next available place to store    }
{                        character into search buffer     }
{ Exit:                                                   }
{               AL = current character                    }
{               ES:BX -> next available place in buffer   }
{               BP = # of remaining chars in string       }
{ Used:                                                   }
{               BX, BP, Flags                             }
{ Description:                                            }
{               Copies the specified character into the   }
{               string buffer;                            }
{               updates current pointer and counter for   }
{               the text string buffer;                   }
{ ******************************************************* }
@PutRawChar:
             mov      es:[bx], al
             inc      bx
             inc      bp
             retn
{ End }



{ Subroutine }
{ ******************************************************* }
{ Purpose:                                                }
{               Tests the specified char against set of   }
{               delimiters                                }
{ Enter:                                                  }
{               DS = our data segment                     }
{               AL = character to test                    }
{ Exit:                                                   }
{               NC = this char is not delimiter           }
{               CY = this char is delimiter               }
{ Used:                                                   }
{               Flags                                     }
{ Description:                                            }
{               Gets the count of delimiters to search;   }
{               if zero then exits;                       }
{               searches all the delimiters array for the }
{               matching entry;                           }
{               (Note: OR sets the carry flags to zero!)  }
{ ******************************************************* }
@IsThisDelimiter:
             push     cx
             push     si
             sub      cx, cx
             mov      si, OFFSET @sCurDelimiters16
             mov      cl, [si]                {CX=counter of items in array}
@TestEndOfLoop:
             or       cx, cx                  {CF<-0}
             jz      @DelimLoopEnd
             dec      cx
             inc      si
             cmp      al, [si]                {if equal then CF<-0!}
             jne     @TestEndOfLoop
             stc                              {delimiter found here}
@DelimLoopEnd:                                {carry flag indicates result}
             pop      si
             pop      cx
             retn
{ End }



{ Subroutine }
{ ******************************************************* }
{ Purpose:                                                }
{               Tests the specified char against set of   }
{               single word map                           }
{ Enter:                                                  }
{               DS = our data segment                     }
{               AL = character to test                    }
{ Exit:                                                   }
{               NZ = this char can be used for word       }
{               ZR = this char can not be used for word   }
{ Used:                                                   }
{               Flags                                     }
{ Description:                                            }
{               Uses the character code as index table;   }
{               gets the corresponding table entry;       }
{               tests it against zero;                    }
{ ******************************************************* }
@IsThisCharInSingleWord:
             push       bx
             sub        bx, bx
             mov        bl, al
             or         bh, BYTE PTR  ds:[@dbCurWordCharTable256].[bx]
             pop        bx
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Changes the presence the forward searching }
{               metasymbol in the search flags             }
{ Enter:                                                   }
{               DS = our data segment                      }
{               AL = current character                     }
{               CX = count of the remaining chars in the   }
{                    raw string                            }
{               BP = count of copying chars to search      }
{               DS:SI -> next char in raw string buffer    }
{               ES:BX -> next char to place in the search  }
{                        buffer                            }
{ Exit:                                                    }
{               NC = no error at parsing                   }
{ Used:                                                    }
{               Flags                                      }
{ Description:                                             }
{               Flips the corresponding bit in the user    }
{               user flags;                                }
{              (Note: XOR sets carry flag to zero!)        }
{ ******************************************************** }
{ Exit:
{ Description:  }
@CurForwardSearchSymbol:
             xor      WORD PTR  ds:[@dwUserSearchFlags], Globals.btForwardSearch
             retn
{ End }



{ Subroutine }
{ ********************************************************* }
{ Purpose:                                                  }
{               Changes the presence the backward searching }
{               metasymbol in the search flags              }
{ Enter:                                                    }
{               DS = our data segment                       }
{               AL = current character                      }
{               CX = count of the remaining chars in the    }
{                    raw string                             }
{               BP = count of copying chars to search       }
{               DS:SI -> next char in raw string buffer     }
{               ES:BX -> next char to place in the search   }
{                        buffer                             }
{ Exit:                                                     }
{               NC = no error at parsing                    }
{ Used:                                                     }
{               Flags                                       }
{ Description:                                              }
{               Flips the corresponding bit in the user     }
{               user flags;                                 }
{              (Note: XOR sets carry flag to zero!)         }
{ ********************************************************* }
@CurBackwardSearchSymbol:
             xor      WORD PTR  ds:[@dwUserSearchFlags], Globals.btBackwardSearch
             retn
{ End }



{ Subroutine }
{ ******************************************************************** }
{ Purpose:                                                             }
{               Copies the symbol following the non-special metasymbol }
{ Enter:                                                               }
{               DS = our data segment                                  }
{               AL = current character                                 }
{               CX = count of the remaining chars in the               }
{                    raw string                                        }
{               BP = count of copying chars to search                  }
{               DS:SI -> next char in raw string buffer                }
{               ES:BX -> next char to place in the search              }
{                        buffer                                        }
{ Exit:                                                                }
{               NC = no error at parsing                               }
{                 CX, BP, SI, BX are updated correspondingly           }
{               CY = error at parsing                                  }
{                 AL =  status code (bad non-special symbol)           }
{ Used:                                                                }
{               Flags                                                  }
{ Description:                                                         }
{              Checks for the empty user input;                        }
{              exits with error indication if no more chars available  }
{              in the user input stream;                               }
{              gets the next available raw character;                  }
{              puts this char without any filtering into the output    }
{              search string buffer;                                   }
{              (Note: OR instruction sets carry flag to zero!)         }
{ ******************************************************************** }
@CurNonSpecialSymbol:
             or       cx, cx
             jz      @UnExpectedEndOfInputFound
             call    @GetRawChar
             call    @PutRawChar
             retn
@UnExpectedEndOfInputFound:
             mov     al, Globals.errStatus_Bad_Non_Special_Sym
             stc
             retn
{ End }



{ Subroutine }
{ ************************************************************* }
{ Purpose:                                                      }
{               Changes the presence the abbreviation searching }
{               metasymbol in the search flags                  }
{ Enter:                                                        }
{               DS = our data segment                           }
{               AL = current character                          }
{               CX = count of the remaining chars in the        }
{                    raw string                                 }
{               BP = count of copying chars to search           }
{               DS:SI -> next char in raw string buffer         }
{               ES:BX -> next char to place in the search       }
{                        buffer                                 }
{ Exit:                                                         }
{               NC = no error at parsing                        }
{ Used:                                                         }
{               Flags                                           }
{ Description:                                                  }
{               Flips the corresponding bit in the user         }
{               user flags;                                     }
{              (Note: XOR sets carry flag to zero!)             }
{ ************************************************************* }
@CurSearchAbbrevSymbol:
             xor      WORD PTR  ds:[@dwUserSearchFlags], Globals.btSearchAbbreviation
             retn
{ End }



{ Subroutine }
{ ************************************************************* }
{ Purpose:                                                      }
{               Changes the presence the expression searching   }
{               metasymbol in the search flags                  }
{ Enter:                                                        }
{               DS = our data segment                           }
{               AL = current character                          }
{               CX = count of the remaining chars in the        }
{                    raw string                                 }
{               BP = count of copying chars to search           }
{               DS:SI -> next char in raw string buffer         }
{               ES:BX -> next char to place in the search       }
{                        buffer                                 }
{ Exit:                                                         }
{               NC = no error at parsing                        }
{ Used:                                                         }
{               Flags                                           }
{ Description:                                                  }
{               Flips the corresponding bit in the user         }
{               user flags;                                     }
{              (Note: XOR sets carry flag to zero!)             }
{ ************************************************************* }
@CurSearchExpressionSymbol:
             xor      WORD PTR  ds:[@dwUserSearchFlags], Globals.btSearchExpression
             retn
{ End }



{ Subroutine }
{ **************************************************************** }
{ Purpose:                                                         }
{               Changes the presence the direction order searching }
{               metasymbol in the search flags                     }
{ Enter:                                                           }
{               DS = our data segment                              }
{               AL = current character                             }
{               CX = count of the remaining chars in the           }
{                    raw string                                    }
{               BP = count of copying chars to search              }
{               DS:SI -> next char in raw string buffer            }
{               ES:BX -> next char to place in the search          }
{                        buffer                                    }
{ Exit:                                                            }
{               NC = no error at parsing                           }
{ Used:                                                            }
{               Flags                                              }
{ Description:                                                     }
{               Flips the corresponding bit in the user            }
{               user flags;                                        }
{              (Note: XOR sets carry flag to zero!)                }
{ **************************************************************** }
@CurDirectionSearchOrderSym:
             xor      WORD PTR  ds:[@dwUserSearchFlags], Globals.btSearchFirstForward
             retn
{ End }



{ Subroutine }
{ ***************************************************************** }
{ Purpose:                                                          }
{               Changes the presence the dictionary order searching }
{               metasymbol in the search flags                      }
{ Enter:                                                            }
{               DS = our data segment                               }
{               AL = current character                              }
{               CX = count of the remaining chars in the            }
{                    raw string                                     }
{               BP = count of copying chars to search               }
{               DS:SI -> next char in raw string buffer             }
{               ES:BX -> next char to place in the search           }
{                        buffer                                     }
{ Exit:                                                             }
{               NC = no error at parsing                            }
{ Used:                                                             }
{               Flags                                               }
{ Description:                                                      }
{               Flips the corresponding bit in the user             }
{               user flags;                                         }
{              (Note: XOR sets carry flag to zero!)                 }
{ ***************************************************************** }
@CurDictSearchOrderSym:
             xor      WORD PTR  ds:[@dwUserSearchFlags], Globals.btSearchFirstAbbreviation
             retn
{ End }



{ Subroutine }
{ ***************************************************************** }
{ Purpose:                                                          }
{               Changes the presence the case-sensitive searching   }
{               metasymbol in the search flags                      }
{ Enter:                                                            }
{               DS = our data segment                               }
{               AL = current character                              }
{               CX = count of the remaining chars in the            }
{                    raw string                                     }
{               BP = count of copying chars to search               }
{               DS:SI -> next char in raw string buffer             }
{               ES:BX -> next char to place in the search           }
{                        buffer                                     }
{ Exit:                                                             }
{               NC = no error at parsing                            }
{ Used:                                                             }
{               Flags                                               }
{ Description:                                                      }
{               Flips the corresponding bit in the user             }
{               user flags;                                         }
{              (Note: XOR sets carry flag to zero!)                 }
{ ***************************************************************** }
@CurCaseSearchSym:
             xor      WORD PTR  ds:[@dwUserSearchFlags], Globals.btSearchCaseSensitive
             retn
{ End }



{ Subroutine }
{ ******************************************************************* }
{ Purpose:                                                            }
{               Changes the presence the middle (all words) searching }
{               metasymbol in the search flags                        }
{ Enter:                                                              }
{               DS = our data segment                                 }
{               AL = current character                                }
{               CX = count of the remaining chars in the              }
{                    raw string                                       }
{               BP = count of copying chars to search                 }
{               DS:SI -> next char in raw string buffer               }
{               ES:BX -> next char to place in the search             }
{                        buffer                                       }
{ Exit:                                                               }
{               NC = no error at parsing                              }
{ Used:                                                               }
{               Flags                                                 }
{ Description:                                                        }
{               Flips the corresponding bit in the user               }
{               user flags;                                           }
{              (Note: XOR sets carry flag to zero!)                   }
{ ******************************************************************* }
@CurMiddleSearchSym:
             xor      WORD PTR  ds:[@dwUserSearchFlags], Globals.btMiddleSearch
             retn
{ End }



{ Subroutine }
{ ******************************************************************* }
{ Purpose:                                                            }
{               Changes the presence the break metasymbol in the      }
{               input string                                          }
{ Enter:                                                              }
{               DS = our data segment                                 }
{               AL = current character                                }
{               CX = count of the remaining chars in the              }
{                    raw string                                       }
{               BP = count of copying chars to search                 }
{               DS:SI -> next char in raw string buffer               }
{               ES:BX -> next char to place in the search             }
{                        buffer                                       }
{ Exit:                                                               }
{               NC = no error at parsing                              }
{ Used:                                                               }
{               Flags                                                 }
{ Description:                                                        }
{               Sets carry flag to zero (indicate success);           }
{ ******************************************************************* }
@CurBreakInputSym:
             xor      WORD PTR  ds:[@dwUserSearchFlags], Globals.btBreakInputSymPresent
             retn
{ End }



{ Subroutine }
{ ******************************************************************* }
{ Purpose:                                                            }
{               Changes the presence the single words searching       }
{               metasymbol in the search flags                        }
{ Enter:                                                              }
{               DS = our data segment                                 }
{               AL = current character                                }
{               CX = count of the remaining chars in the              }
{                    raw string                                       }
{               BP = count of copying chars to search                 }
{               DS:SI -> next char in raw string buffer               }
{               ES:BX -> next char to place in the search             }
{                        buffer                                       }
{ Exit:                                                               }
{               NC = no error at parsing                              }
{ Used:                                                               }
{               Flags                                                 }
{ Description:                                                        }
{               Flips the corresponding bit in the user               }
{               user flags;                                           }
{              (Note: XOR sets carry flag to zero!)                   }
{ ******************************************************************* }
@CurSingleWordSearchSym:
             xor      WORD PTR  ds:[@dwUserSearchFlags], Globals.btSingleWordSearchSym
             retn
{ End }



{ Subroutine }
{ ******************************************************* }
{ Purpose:                                                }
{               Tests the specified char against digits   }
{ Enter:                                                  }
{               DS = our data segment                     }
{               AL = character to test                    }
{ Exit:                                                   }
{               NC = this char is digit                   }
{               CY = this char is not digit               }
{ Used:                                                   }
{               Flags                                     }
{ Description:                                            }
{               Checks this char against range '0'..'9';  }
{ ******************************************************* }
@IsThisDigit:
             cmp      al, Globals.achZero       {<0?}
             jb      @NotDigitFound
             cmp      al, Globals.achNine       {>9?}
             ja      @NotDigitFound
             clc
             retn
@NotDigitFound:
             stc
             retn
{ End }



{ Subroutine }
{ ******************************************************* }
{ Purpose:                                                }
{               Translates a numeric entry into a symbol  }
{               representation                            }
{ Enter:                                                  }
{               DS = our data segment                     }
{               CX = count of the remaining chars in the  }
{                    raw string                           }
{               BP = count of copying chars to search     }
{               DS:SI -> next char in raw string buffer   }
{               ES:BX -> next char to place in the search }
{                        buffer                           }
{ Exit:                                                   }
{               NC = translation done                     }
{               CY = translation failed                   }
{                  AL = status code                       }
{ Used:                                                   }
{               CX, BP, SI, BX, Flags                     }
{ Description:                                            }
{               (1) checks for the empty input stream;    }
{               (2) checks for end of definition;         }
{               (3) if ending marker found then exits;    }
{               (4) tests current symbol as digit;        }
{               (5) if not digit then exits w/error;      }
{               (6) translates char to digit;             }
{               (7) calculates the currrent number using  }
{                   the following formulae:               }
{                 cur_num := prev_num * 10 + cur_dig      }
{               (8)  continue from (1);
{           (Note: processing goes from left to right!)   }
{ ******************************************************* }
@TransNumDefToSym:
             push     ax
             push     dx
             sub      dx, dx
@TakeNextSymFromNumStream:
             or       cx, cx
             jz      @UnexpectedEndOfNumericStream
             mov      dh, Globals.aTen
             call     @GetRawChar
             cmp      al, BYTE PTR  ds:[@chCurCloseNumericSym]
             je      @TransOK
             call     @IsThisDigit
             jc      @BadDigitFound
             sub      al, Globals.achZero       {char to digit}
             xchg     dl, al
             mul      dh
             add      al, dl
             mov      dl, al                    {save result}
             jmp     @TakeNextSymFromNumStream
@TransOK:
             mov      al, dl                    {last resulting number}
             call     @PutRawChar
             clc
             pop      dx
             pop      ax                {status code is undefined!}
             retn
@BadDigitFound:
@UnexpectedEndOfNumericStream:
             pop      dx
             pop      ax
             mov      al, Globals.errStatus_Bad_Num_Parm
             stc
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Translates a numeric entry into a symbol   }
{               representation                             }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               NC = setup done                            }
{               CY = setup failed                          }
{                  AL = status code                        }
{ Used:                                                    }
{               AX, Flags                                  }
{ Description:                                             }
{               A: sets the string pointer to the user raw }
{                  string buffer, inits a counters;        }
{               B: adjusts pointer to next char;           }
{               C: checks for reaching of start of buffer; }
{               D: gets a char from buffer;                }
{               E: if not delimiter then goto (B);         }
{               F: checks that previous symbol is not the  }
{                  non-special metasymbol,                 }
{                  if yes then goto (B);                   }
{               G: increments a delimiters counter;        }
{               H: if maximum counter reached then exits,  }
{                  otherwise goto (B);
{           (Note: processing goes from right to left!)    }
{ ******************************************************** }
@SetUpDefinitionToAnalyze:
             push     bx
             push     dx
             push     di
             mov      di, WORD PTR  ds:[@pofsUserRawInputWord]
             mov      si, OFFSET  @dbUserRawInputWord256
             mov      ah, BYTE PTR  ds:[@chCurDelimDefinitionSym]
             mov      dh, BYTE PTR  ds:[@chCurNonDefSym]
             sub      bx, bx               {counters for delimiters}
@IsCurCharDelimDef:
             dec      di                   {adjust to available char}
             cmp      di, si
             jb      @AllBufPassed
             mov      al, [di]             {get a char}
             cmp      al, ah
             jne     @IsCurCharDelimDef
             cmp      [di-1], dh           {non-special symbol before?}
             je      @IsCurCharDelimDef
             inc      bx                   {definition delimiter found!}
             cmp      bx, 2+2              {4 as maximum!}
             jne     @IsCurCharDelimDef    {CF<-0 if equal}
             mov      WORD PTR  ds:[@pofsFirstCharInRawBuf], di
@SetupDefDone:
             pop      di
             pop      dx
             pop      bx
             retn
@AllBufPassed:
             mov      al, Globals.errStatus_Bad_User_Definition
             stc
             jmp     @SetupDefDone
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Extracts from user entry definition the    }
{               abbreviation and expression strings        }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               NC = successfully done                     }
{               CY = bad user definition found             }
{                  AL = status code                        }
{ Used:                                                    }
{               AX, CX, SI, Flags                          }
{ Description:                                             }
{               A: setup the internal variables,           }
{                  abbreviation will be in search string,  }
{                  expression will be in replace string;   }
{               B: extracts the abbreviation;              }
{               C: extracts the expression;                }
{              (Note: OR sets carry flag to zero!)         }
{ ******************************************************** }
@SeparateAndCopyDefForAbbrAndExpr:
             push    bx
             push    dx
             push    di
             push    bp
             push    es
             mov     ax, ds
             mov     es, ax
             mov     bx, OFFSET  @dbUserSearchInputWord256
             mov     si, WORD PTR  ds:[@pofsFirstCharInRawBuf]
             mov     cx, WORD PTR  ds:[@pofsUserRawInputWord]
             sub     cx, si
             mov     di, cx                  {# of chars to replace}
             mov     ah, BYTE PTR  ds:[@chCurDelimDefinitionSym]
             mov     dl, System.False        {not in definition switch!}
             mov     dh, BYTE PTR  ds:[@chCurNonDefSym]
             sub     bp, bp
@ProcessAbbreviationDef:
             or      cx, cx
             jz     @BadDefFound
             call    @GetRawChar
             dec     di
             cmp     ah, al                   {definition open/close symbol?}
             je     @AbbreviationMarkerFound
             cmp     dl, System.False           {in abbreviation?}
             je     @ProcessAbbreviationDef
             inc     di
             cmp     al, dh                     {non-special symbol follows?}
             je     @StoreRawCharForAbbr
             cmp     al, BYTE PTR  ds:[@chCurOpenNumericSym] {numeric code as symbol!}
             je     @ProcessNumParamAbbr
             call    @PutRawChar
             jmp    @ProcessAbbreviationDef
@ProcessNumParamAbbr:
             call    @TransNumDefToSym
             jnc    @ProcessAbbreviationDef
             jmp    @BadDefFound
@StoreRawCharForAbbr:
             call    @ProcessNonDefSymbol
             jc     @BadDefFound
             inc     di
             jmp    @ProcessAbbreviationDef
@AbbreviationMarkerFound:
             inc     di
             cmp     dl, System.False           {end of abbreviation?}
             jne    @DoExpressionDef
             mov     dl, System.True          {switch to store abbreviation}
             jmp    @ProcessAbbreviationDef
@DoExpressionDef:
             or      bp, bp                   {empty abbreviation?}
             jz     @EmptyUserTextFound
             mov     WORD PTR  ds:[@pofsUserSearchInputWordLength], bp
             mov     bx, OFFSET  @dbUserReplaceInputWord256
             mov     dl, System.False        {not in expression definition}
             sub     bp, bp                  {same algorithm as above!}
@ProcessExpressionDef:
             or      cx, cx
             jcxz   @BadDefFound
             call    @GetRawChar
             cmp     ah, al
             je     @ExpressionMarkerFound
             cmp     dl, System.False
             je     @ProcessExpressionDef
             cmp     al, dh
             je     @StoreRawCharForExpr
             cmp     al, BYTE PTR  ds:[@chCurOpenNumericSym]
             je     @ProcessNumParamExpr
             call    @PutRawChar
             jmp    @ProcessExpressionDef
@ProcessNumParamExpr:
             call    @TransNumDefToSym
             jnc    @ProcessExpressionDef
             jmp    @BadDefFound
@StoreRawCharForExpr:
             call    @ProcessNonDefSymbol
             jnc    @ProcessExpressionDef
             jmp    @BadDefFound
@ExpressionMarkerFound:
             cmp     dl, System.False
             jne    @ExpressionPassed
             mov     dl, System.True
             jmp    @ProcessExpressionDef
@EmptyUserTextFound:
             mov     al, Globals.errStatus_Empty_Expression
@BadDefFound:
             stc
             jmp    @CopyDefDone
@ExpressionPassed:
             or      bp, bp                      {empty expression?}
             jz     @EmptyUserTextFound
             mov     WORD PTR  ds:[@dwUserReplaceInputWordLength], bp
             mov     WORD PTR  ds:[@dwCharsToReplaceBefore], di
             {carry flag is cleared here!}
@CopyDefDone:
             pop     es
             pop     bp
             pop     di
             pop     dx
             pop     bx
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Check the new user entry for duplication   }
{               in the current dictionary                  }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               NC = successfully done                     }
{               CY = duplicate found                       }
{                  AL = status code                        }
{ Used:                                                    }
{               AX, Flags                                  }
{ Description:                                             }
{               Check for the empty FA-link list;          }
{               Check for the empty user abbreviation;     }
{               Scan all the FA-link list looking for the  }
{               just same entry;                           }
{ ******************************************************** }
@CheckForDuplicateEntry:
             push     bx
             push     cx
             push     dx
             push     si
             push     di
             push     es
             les      bx, DWORD PTR  ds:[@CurForwardSearchAbbrevTablePtr]
             call     @IsPointerNIL
             jz      @NoDuplicateEntry
             call     @GetUserSearchStrLength
             jz      @NoDuplicateEntry
             mov      si, (OFFSET @dbUserSearchInputWord256)
             mov      al, [si]                  {first char}
             mov      dx, WORD PTR  ds:[@dwCurUserEnvOptions]
             call     _fndwGetTableOffsetByIndex
@GetNodeFA_1:
             or       bx, bx                    {end of list?}
             jz      @NoDuplicateEntry
             call     _fndbGetNodeAbbreviationSize
             cmp      al, cl                    {matching sizes?}
             jne     @GetNodeLinkFA_1
             push     si
             call     _fndwGetNodeAbbreviationOfs
             mov      di, ax
             call     @CompareStrFwd
             pop      si
             je      @SameAbbreviationEntryFound
@GetNodeLinkFA_1:
             call     _fndwGetNodeLinkOffsetForFA
             jmp     @GetNodeFA_1
@NoDuplicateEntry:
             {carry flag already cleared at this point!}
@CheckDuplicateDone:
             pop      es
             pop      di
             pop      si
             pop      dx
             pop      cx
             pop      bx
             retn
@SameAbbreviationEntryFound:
             stc
             mov      al, Globals.errStatus_Duplicate_Entry_Found
             jmp     @CheckDuplicateDone
{ End }


{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Add the new user entry to the current      }
{               dictionary                                 }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               NC = successfully done                     }
{               CY = failed to add                         }
{                  AL = status code                        }
{ Used:                                                    }
{               AX, CX, SI, Flags                          }
{ Description:                                             }
{               Check for free space available;            }
{               check for the compressed dictionary;       }
{               try to allocate memory for new entry;      }
{               copy the user strings and options to the   }
{               dictionary entry;
{               update the corresponding link tables;      }
{ ******************************************************** }
@CopyEntryToDictNode:
             push     bx
             push     dx
             push     di
             push     bp
             push     es
             les      bx, DWORD PTR  ds:[@lpFreeSpaceStart]
             call     @IsPointerNIL
             jz      @InsufficientFreeMem
             mov      dx, WORD PTR  ds:[@dwCurUserEnvOptions]
             les      bx, DWORD PTR  ds:[@CurForwardSearchAbbrevTablePtr]
             call     @IsPointerNIL
             jz      @InsufficientFreeMem
             mov      al, BYTE PTR  ds:[@dbUserSearchInputWord256][0]
             call     _fndwGetTableOffsetByIndex
             or       bx, bx
             jnz     @FindLastNode
             test     dx, (Globals.btUseTableCompression)
             jz      @NoDictCompression         {is table compressed?}
             jmp     @UnableToExtendDict
@FindLastNode:
             mov      dx, bx
             call     _fndwGetNodeLinkOffsetForFA
             or       bx, bx
             jnz     @FindLastNode
             mov      bx, dx
             call     _fndwGetNodeOptions
             test     ax, Globals.btNodeIsCompressed
             jz      @NoDictCompression
@UnableToExtendDict:
             mov      al, Globals.errStatus_Dict_Is_Compressed
             jmp     @CopyNewEntryError
@NoDictCompression:
             mov     cx, TYPE (Globals.recDictEntryHeaderDesc)
             mov     ax, cx
             add     ax, WORD PTR  ds:[@pofsUserSearchInputWordLength]
             add     ax, WORD PTR  ds:[@dwUserReplaceInputWordLength]
             mov     di, Globals.btNodeLinkOffsetFABAFEBEASES
             test    WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btAddPaddingZero
             jz     @NoPaddingOption
             test    ax, 1
             jz     @NoPaddingOption
             inc     ax
             add     di, Globals.btNodeHasPaddingZero
@NoPaddingOption:
             cmp     ax, WORD PTR  ds:[@dwFreeSpaceSize]
             ja     @InsufficientFreeMem
             mov     BYTE PTR  ds:[@bDynamicExtendDict], System.True
             call    @AllocateFreeMem
             mov     BYTE PTR  ds:[@bDynamicExtendDict], System.False
             mov     WORD PTR  ds:[@lpDictNode][0], bx
             mov     WORD PTR  ds:[@lpDictNode][2], es
             test    WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btEmptyAbbreviation
             jz     @SkipEmptyAbbreviation
             push    di
             mov     di, OFFSET  @dbReservedEmptyAbbr3
             mov     cx, WORD PTR  ds:[@pofsUserSearchInputWordLength]
             mov     si, OFFSET  @dbUserSearchInputWord256
             call    @CompareStrFwd
             pop     di
             jne    @SkipEmptyAbbreviation
             or      di, Globals.btNodeHasEmptyAbbreviation
@SkipEmptyAbbreviation:
             mov     ax, di
             call   _StoreNodeOptions
             sub     ax, ax
             call    _StoreNodeAccessCount
             sub     ax, ax
             call    _StoreNodeHitCount
             mov     ax, WORD PTR  ds:[@pofsUserSearchInputWordLength]
             mov     cx, ax
             call    _StoreNodeAbbreviationSize
             call    _fndwGetNodeAbbreviationOfs
             mov     di, ax
             mov     si, OFFSET  @dbUserSearchInputWord256
             call    @CopyMemoryStringFwd
             mov     ax, WORD PTR  ds:[@dwUserReplaceInputWordLength]
             mov     cx, ax
             call    _StoreNodeExpressionSize
             call    _fndwGetNodeExpressionOfs
             mov     di, ax
             mov     si, OFFSET @dbUserReplaceInputWord256
             call    @CopyMemoryStringFwd
             mov     al, BYTE PTR  ds:[@dbUserSearchInputWord256][0]
             les     bx, DWORD PTR  ds:[@CurForwardSearchAbbrevTablePtr]
             mov     si, OFFSET  _fndwGetNodeLinkOffsetForFA
             mov     di, OFFSET  _StoreNodeLinkOffsetForFA
             call    @UpdateNodeLink
             les     bx, DWORD PTR  ds:[@CurBackwardSearchAbbrevTablePtr]
             call    @IsPointerNIL
             jz     @SkipTableBA
             mov     si, WORD PTR  ds:[@pofsUserSearchInputWordLength]
             mov     al, [si][(OFFSET  @dbUserSearchInputWord256)-1]
             mov     si, OFFSET  _fndwGetNodeLinkOffsetForBA
             mov     di, OFFSET  _StoreNodeLinkOffsetForBA
             call    @UpdateNodeLink
@SkipTableBA:
             les     bx, DWORD PTR  ds:[@CurForwardSearchDictTablePtr]
             call    @IsPointerNIL
             jz     @SkipTableFE
             mov     al, BYTE PTR  ds:[@dbUserReplaceInputWord256][0]
             mov     si, OFFSET  _fndwGetNodeLinkOffsetForFE
             mov     di, OFFSET  _StoreNodeLinkOffsetForFE
             call    @UpdateNodeLink
@SkipTableFE:
             les     bx, DWORD PTR  ds:[@CurBackwardSearchDictTablePtr]
             call    @IsPointerNIL
             jz     @SkipTableBE
             mov     si, WORD PTR  ds:[@dwUserReplaceInputWordLength]
             mov     al, [si][(OFFSET  @dbUserReplaceInputWord256)-1]
             mov     si, OFFSET  _fndwGetNodeLinkOffsetForBE
             mov     di, OFFSET  _StoreNodeLinkOffsetForBE
             call    @UpdateNodeLink
@SkipTableBE:
             les     bx, DWORD PTR  ds:[@CurStrSizeSearchAbbrevTablePtr]
             call    @IsPointerNIL
             jz     @SkipTableAS
             mov     ax, WORD PTR  ds:[@pofsUserSearchInputWordLength]
             mov     si, OFFSET  _fndwGetNodeLinkOffsetForAS
             mov     di, OFFSET  _StoreNodeLinkOffsetForAS
             call    @UpdateNodeLink
@SkipTableAS:
             les     bx, DWORD PTR  ds:[@CurStrSizeSearchDictTablePtr]
             call    @IsPointerNIL
             jz     @SkipTableES
             mov     ax, WORD PTR  ds:[@dwUserReplaceInputWordLength]
             mov     si, OFFSET  _fndwGetNodeLinkOffsetForES
             mov     di, OFFSET  _StoreNodeLinkOffsetForES
             call    @UpdateNodeLink
@SkipTableES:
             mov     al, Globals.errStatus_Success
             clc
@CopyNewEntryDone:
             pop     es
             pop     bp
             pop     di
             pop     dx
             pop     bx
             retn
@InsufficientFreeMem:
             mov     al, Globals.errStatus_No_Enough_Free_Memory
@CopyNewEntryError:
             stc
             jmp    @CopyNewEntryDone
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Updates the links for the corresponding    }
{               link table                                 }
{ Enter:                                                   }
{               DS = our data segment                      }
{               ES:BX -> index table                       }
{               AL = character as index                    }
{               SI = address of function to get the link   }
{                    offset                                }
{               DI = address of function to store the link }
{                    offset                                }
{ Exit:                                                    }
{               None                                       }
{ Used:                                                    }
{               AX, BX, CX, DX, BP, Flags                  }
{ Description:                                             }
{               Gets the table ofsfet for the index;       }
{               if empty entry then adds the new entry,    }
{               otherwise adds the new entry to the end of }
{               the list;                                  }
{ ******************************************************** }
@UpdateNodeLink:
             mov      bp, ax
             mov      cx, bx
             mov      dx, WORD PTR  ds:[@dwCurUserEnvOptions]
             call     _fndwGetTableOffsetByIndex
             or       bx, bx
             jz      @EmptySlotInHeadTable
@FetchNextLink:
             mov      dx, bx
             call     si
             or       bx, bx
             jnz     @FetchNextLink
             mov      bx, dx
             test     WORD PTR  es:[bx][Globals.recDictEntryHeaderDesc.dwNodeOptions], Globals.btNodeIsCompressed
             jnz     @UpdateNodeDone
             mov      ax, WORD PTR  ds:[@lpDictNode][0]
             call     di
@UpdateAddedNode:
             mov      bx, WORD PTR  ds:[@lpDictNode][0]
             sub      ax, ax
             call     di
@UpdateNodeDone:
             retn
@EmptySlotInHeadTable:
             test     dx, (Globals.btUseTableCompression)
             jnz     @UpdateNodeDone
             mov      bx, cx
             mov      cx, WORD PTR  ds:[@lpDictNode][0]
             mov      ax, bp
             call     _PutFirstTableOffsetByIndex
             jmp     @UpdateAddedNode
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Copy the memory region                     }
{ Enter:                                                   }
{               DS = our data segment                      }
{               CX =  # of chars to copy                   }
{               DS:SI -> source string (buffer)            }
{               ES:DI -> destination string (buffer)       }
{ Exit:                                                    }
{               SI, DI, CX updated the correspondingly     }
{ Used:                                                    }
{               CX, Flags                                  }
{ Description:                                             }
{               Does the forward copying of the specifed   }
{               memory region;                             }
{ ******************************************************** }
@CopyMemoryStringFwd:
             cld
             shr      cx, 1
             jnc     @DoWordTransferFwd
             movsb
@DoWordTransferFwd:
             rep      movsw
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Copy the symbol follows the non-metasymbol }
{               in the user definition string              }
{ Enter:                                                   }
{               DS = our data segment                      }
{               CX = input stream buffer size              }
{               BP = output stream buffer size             }
{               DS:SI -> input stream buffer               }
{               ES:BX -> output stream buffer              }
{ Exit:                                                    }
{               SI, BX, CX, BP updated the correspondingly }
{               NC = copy done                             }
{               CY = copy failed                           }
{                 AL = status code                         }
{ Used:                                                    }
{               SI, DI, BP, BX, CX, Flags                  }
{ Description:                                             }
{               Checks for the empty input buffer;         }
{               copy one char from input buffer to output  }
{               buffer;                                    }
{          (Note: OR instruction sets carry flag to zero!) }
{ ******************************************************** }
@ProcessNonDefSymbol:
             or       cx, cx
             jz      @UnexpectedEndOfStream
             call     @GetRawChar
             call     @PutRawChar
             retn
@UnexpectedEndOfStream:
             mov      al, Globals.errStatus_Bad_Non_Special_Sym
             stc
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Extracts the word expression from the user }
{               input stream to analyze                    }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               CX = last character offset                 }
{               SI = first character offset                }
{               DX = # of trailing(as leading) delimiters  }
{ Used:                                                    }
{               AX, BX, CX, SI, DI, Flags                  }
{ Description:                                             }
{               Skips the trailing delimiters;             }
{               copies the chars to the buffer to search   }
{               until buffer flushing, or occurrence of a  }
{               delimiter,                                 }
{ ******************************************************** }
@SetUpWordToAnalyze:
             mov      cx, WORD PTR  ds:[@pofsUserRawInputWord]
             mov      si, OFFSET  @dbUserRawInputWord256
             mov      bx, cx
             mov      di, bx
             sub      bx, si                    {# of chars}
             mov      ah, System.False          {not in word!}
             sub      dx, dx
@GetCharToAnalyze:
             or       bx, bx
             jz      @WordPassed
             dec      bx                        {decrement counter}
             dec      di                        {go from right to left!}
             mov      al, [di]
             cmp      al, BYTE PTR  ds:[@chCurBreakInputSym]
             jne     @TestForDelimiter
             push     ax
             mov      al, BYTE PTR  ds:[@chCurNonSpecialSymbol]
             cmp      al, [di-1]        {fixed a problem of including break!}
             pop      ax
             jne     @BreakSymFound
@TestForDelimiter:
             call     @IsThisDelimiter
             jnc     @AddThisCharToWord
             mov      al, BYTE PTR  ds:[@chCurNonSpecialSymbol]
             cmp      al, [di-1]        {fixed a problem of including space!}
             je      @AddThisCharToWord
             cmp      ah, System.False     {before or after?}
             je      @DoOurWord
             inc      di                   {adjust back}
@DoOurWord:
             cmp      ah, System.True
             je      @WordPassed
             dec      cx                   {trailing delimiters}
             inc      dx
             jmp     @GetCharToAnalyze
@AddThisCharToWord:
             mov      ah, System.True      {we're in expression!}
             jmp     @GetCharToAnalyze
@BreakSymFound:
             cmp      ah, System.True      {before or after?}
             je      @WordPassed
             dec      cx                   {trailing delimiters}
             inc      dx                   
@WordPassed:
             mov      si, di
             mov      WORD PTR  ds:[@pofsFirstCharInRawBuf], si
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Analyze the user raw string to extract the }
{               the user search string and process the     }
{               metasymbols                                }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               NC = parsing done                          }
{               CY = error at parsing                      }
{                 AL = status code                         }
{ Used:                                                    }
{               AX, BX, CX, Flags                          }
{ Description:                                             }
{               Sets the search substate mode;             }
{               updates the video indicators on screen;    }
{               prepares the expression to analyze;        }
{               checks for empty expression;               }
{               scans the user string, copies raw chars,   }
{               analyzes the metasymbols;                  }
{        (Note: TEST instruction sets carry flag to zero!) }
{ ******************************************************** }
@AnalyzeUserInputForMetaSymAndExpression:
             mov      BYTE PTR  ds:[@dbSearchSubState], Globals.aSearchSubStateIsAnalyze
             call     @UpdateVideoIndicators
             push     dx
             push     si
             push     di
             push     bp
             push     es
             mov      ax, ds
             mov      es, ax
             call     @SetUpWordToAnalyze
             mov      WORD PTR  ds:[@LeadingDelimitersCount], dx
             mov      bx, OFFSET  @dbUserSearchInputWord256
             sub      cx, si
             test     WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btEmptyAbbreviation
             jz      @LookInputAbbrSize
             or       cx, cx                       {CF<-0!}
             jnz     @CheckEmptyExpr
             mov      ax, (Globals.btSearchAbbreviation + Globals.btMiddleSearch)
             mov      WORD PTR  ds:[@dwUserSearchFlags], ax
             jmp     @AnalyzeRestoreWorld          {carry flag cleared here!}
@LookInputAbbrSize:
             or       cx, cx
@CheckEmptyExpr:
             mov      al, Globals.errStatus_Empty_Expression
             jz      @ErrorAtAnalyze
             sub      bp, bp
@RemoveLeadingDelimiters:
             call     @GetRawChar
             call     @IsThisDelimiter
             jnc     @CharFromUserInputPresent
             inc      WORD PTR  ds:[@LeadingDelimitersCount]
             or       cx, cx
             jnz     @RemoveLeadingDelimiters
             jmp     @CheckEmptyExpr
@NextCharFromUserInput:
             call     @GetRawChar
@CharFromUserInputPresent:
             test     WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btRecognizeMetaSymbols
             jz      @CheckForTerminateDelimiter
             mov      dx, OFFSET @chCurForwardSearchSymbol
             mov      di, dx
             cld
             push     cx
             mov      cx, (Globals.recEnvironmentDesc.sDictName16 - Globals.recEnvironmentDesc.chForwardSearchSymbol)
             repne    scasb
             pop      cx
             jne     @CheckForTerminateDelimiter
             dec      di                          {adjust back}
             sub      di, dx
             shl      di, 1
             call     WORD PTR  ds:[@pofsMetaSymDispatchTable].[di]
             jc      @ErrorAtAnalyze
             jmp     @CheckForLastChar
@CheckForTerminateDelimiter:
             call     @IsThisDelimiter
             jc      @AnalyzeDone
@CopyThisCharToExpression:
             call     @PutRawChar
@CheckForLastChar:
             or       cx, cx
             jnz     @NextCharFromUserInput
@AnalyzeDone:
             mov      WORD PTR  ds:[@pofsUserSearchInputWordLength], bp
             sub      si, WORD PTR  ds:[@pofsFirstCharInRawBuf]
             add      si, WORD PTR  ds:[@LeadingDelimitersCount]
             mov      WORD PTR  ds:[@dwCharsToReplaceBefore], si
@AnalyzeRestoreWorld:
             pop      es
             pop      bp
             pop      di
             pop      si
             pop      dx
             retn
@ErrorAtAnalyze:
             stc
             jmp     @AnalyzeRestoreWorld
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Fill the buffer with the backspaces        }
{ Enter:                                                   }
{               DS = our data segment                      }
{               DS:SI -> buffer to fill before             }
{               DX = chars count to fill                   }
{ Exit:                                                    }
{               DS:SI -> buffer to fill after              }
{ Used:                                                    }
{               SI, Flags                                  }
{ Description:                                             }
{               Fill the buffer with the needing count of  }
{               the backspace character;                   }
{ ******************************************************** }
@FillReplaceBufWithBS:
             push     ax
             push     cx
             mov      cx, dx
             mov      al, Globals.achBS
@StoreOneBS:
             or       cx, cx
             jz    @FillBufDone
             mov      [si], al
             inc      si
             dec      cx
             jmp    @StoreOneBS
@FillBufDone:
             pop      cx
             pop      ax
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Tests the specified pointer against NIL    }
{ Enter:                                                   }
{               DS = our data segment                      }
{               ES:BX -> pointer                           }
{ Exit:                                                    }
{               ZR = NIL pointer                           }
{               NZ = NOT(NIL) pointer                      }
{ Used:                                                    }
{               AX, Flags                                  }
{ Description:                                             }
{               Does the logical addition of segment and   }
{               offset parts of the pointer and tests for  }
{               zero result;                               }
{ ******************************************************** }
@IsPointerNIL:
             mov      ax, es
             or       ax, bx
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Gets the opposite case character to the    }
{               specified character                        }
{ Enter:                                                   }
{               DS = our data segment                      }
{               AL = char to translate                     }
{ Exit:                                                    }
{               AL = translated char                       }
{ Used:                                                    }
{               AL, Flags                                  }
{ Description:                                             }
{               Extracts the table char by the index;      }
{ ******************************************************** }
@CaseTranslateOfChar:
             push     bx
             sub      bx, bx
             mov      bl, al
             mov      al, BYTE PTR  ds:[@chCurCaseMapArray256].[bx]
             pop      bx
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Compares the string by a forward searching }
{ Enter:                                                   }
{               DS = our data segment                      }
{               CX = # of chars to compare                 }
{               DS:SI -> source string                     }
{               ES:DI -> target string                     }
{ Exit:                                                    }
{               ZR = matching strings                      }
{               NZ = non-matching strings                  }
{ Used:                                                    }
{               AL, SI, DI, Flags                          }
{ Description:                                             }
{               (1) non case-sensitive searching           }
{               (2) case-sensitive searching               }
{ ******************************************************** }
@CompareStrFwd:
             push     cx
             test     WORD PTR  ds:[@dwUserSearchFlags], Globals.btSearchCaseSensitive
             jz      @NonCaseSensitiveFwd
             cld
             repe     cmpsb
             pop      cx
             retn
@NonCaseSensitiveFwd:
@NextCharFwd:
             mov      al, [si]
             cmp      al, es:[di]
             je      @IncrBufIndexFwd
             call     @CaseTranslateOfChar
             cmp      al, es:[di]
             jne     @CompareStrDoneFwd
@IncrBufIndexFwd:
             inc      si
             inc      di
             dec      cx
             jnz     @NextCharFwd
@CompareStrDoneFwd:
             pop      cx
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Compares the string by backward searching  }
{ Enter:                                                   }
{               DS = our data segment                      }
{               CX = # of chars to compare                 }
{               DS:SI -> source string                     }
{               ES:DI -> target string                     }
{ Exit:                                                    }
{               ZR = matching strings                      }
{               NZ = non-matching strings                  }
{ Used:                                                    }
{               AL, SI, DI, Flags                          }
{ Description:                                             }
{               (1) non case-sensitive searching           }
{               (2) case-sensitive searching               }
{ ******************************************************** }
@CompareStrBkwd:
             push     cx
             test     WORD PTR  ds:[@dwUserSearchFlags], Globals.btSearchCaseSensitive
             jz      @NonCaseSensitiveBkwd
             std
             repe     cmpsb
             pop      cx
             retn
@NonCaseSensitiveBkwd:
@NextCharBkwd:
             mov      al, [si]
             cmp      al, es:[di]
             je      @IncrBufIndexBkwd
             call     @CaseTranslateOfChar
             cmp      al, es:[di]
             jne     @CompareStrDoneBkwd
@IncrBufIndexBkwd:
             dec      si
             dec      di
             dec      cx
             jnz     @NextCharBkwd
@CompareStrDoneBkwd:
             pop      cx
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Compares the string by middle searching    }
{               (look all the dictionary)                  }
{ Enter:                                                   }
{               DS = our data segment                      }
{               CX = source string size                    }
{               AX = target string size                    }
{               DS:SI -> source string+0                   }
{               ES:DI -> target string+0                   }
{ Exit:                                                    }
{               ZR = matching strings                      }
{               NZ = non-matching strings                  }
{ Used:                                                    }
{               AX, SI, DI, Flags                          }
{ Description:                                             }
{               (1) non case-sensitive searching           }
{               (2) case-sensitive searching               }
{ ******************************************************** }
@CompareStrMiddle:
             push     cx
             test     WORD PTR  ds:[@dwUserSearchFlags], Globals.btSearchCaseSensitive
             jz      @NonCaseSensitiveMiddle
@NextStrTestMiddle:
             cmp      cx, ax
             jbe     @MatchLengthFoundMiddle
             or       cx, cx
             jne     @CompareStrMiddleDone
@MatchLengthFoundMiddle:
             cld
             push     cx
             push     si
             push     di
             repe     cmpsb
             pop      di
             pop      si
             pop      cx
             je      @CompareStrMiddleSuccessDone
             inc      di
             dec      ax
             jmp     @NextStrTestMiddle
@CompareStrMiddleSuccessDone:
             pushf
             test     WORD PTR  ds:[@dwUserSearchFlags], Globals.btSingleWordSearchSym
             jz      @SingleWordSearchMiddle
             mov      WORD PTR  ds:[@dwMatchPatternOfs], di
@SingleWordSearchMiddle:
             popf
@CompareStrMiddleDone:
             pop      cx
             retn
@NonCaseSensitiveMiddle:
             push     dx
             mov      dx, ax
@NonCaseNextStrTestMiddle:
             cmp      cx, dx
             jbe     @NonCaseMatchLengthFoundMiddle
             or       cx, cx
             jne     @NonCaseCompareStrDoneMiddle
@NonCaseMatchLengthFoundMiddle:
             push     cx
             push     si
             push     di
@NonCaseNextCharMiddle:
             mov      al, [si]
             cmp      al, es:[di]
             je      @NonCaseIncrBufIndexMiddle
             call     @CaseTranslateOfChar
             cmp      al, es:[di]
             jne     @NonCaseNonMatchCharFoundMiddle
@NonCaseIncrBufIndexMiddle:
             inc      si
             inc      di
             dec      cx
             jnz     @NonCaseNextCharMiddle
@NonCaseNonMatchCharFoundMiddle:
             pop      di
             pop      si
             pop      cx
             je      @NonCaseCompareStrDoneMiddleSuccess
             inc      di
             dec      dx
             jmp     @NonCaseNextStrTestMiddle
@NonCaseCompareStrDoneMiddleSuccess:
             pushf
             test     WORD PTR  ds:[@dwUserSearchFlags], Globals.btSingleWordSearchSym
             jz      @NonCaseSingleWordSearchMiddle
             mov      WORD PTR  ds:[@dwMatchPatternOfs], di
@NonCaseSingleWordSearchMiddle:
             popf
@NonCaseCompareStrDoneMiddle:
             pop      dx
             pop      cx
             retn
{ End }




{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Extracts the single word from the found    }
{               dictionary entry expression                }
{ Enter:                                                   }
{               DS = our data segment                      }
{               AX = offset of matching pattern            }
{               CX = expression entry size                 }
{               ES:DI -> expression entry in dictionary    }
{ Exit:                                                    }
{               ES:DI -> single word to copy               }
{               CX = # of chars in this word               }
{ Used:                                                    }
{               AX, DI, CX, Flags                          }
{ Description:                                             }
{               Finds the left boundary of the word;       }
{               Finds the right boundary of the word;      }
{ ******************************************************** }
@GetSingleWordFromDict:
             push      bx
             push      dx
             push      si
             jcxz     @GetSingleDictWordDone
             mov       dx, ax
             mov       si, ax
             dec       si
@FindWordLeftBoundary:
             cmp       si, di
             jb       @LeftBoundaryFound
             mov       al, es:[si]
             call      @IsThisCharInSingleWord
             jz       @LeftBoundaryFound
             dec       si
             jmp      @FindWordLeftBoundary
@LeftBoundaryFound:
             inc       si
             mov       bx, si
             mov       si, dx
             mov       ax, di
             add       ax, cx
             dec       ax
             mov       dx, ax                   {right boundary}
             inc       si
@FindWordRightBoundary:
             cmp       si, dx
             ja       @RightBoundaryFound
             mov       al, es:[si]
             call      @IsThisCharInSingleWord
             jz       @RightBoundaryFound
             inc       si
             jmp      @FindWordRightBoundary
@RightBoundaryFound:
             mov       cx, si
             sub       cx, bx
             mov       di, bx
@GetSingleDictWordDone:
             pop       si
             pop       dx
             pop       bx
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Copy the dictionary entry to buffer        }
{ Enter:                                                   }
{               DS = our data segment                      }
{               CX = # of chars to copy                    }
{               DS:SI -> target string                     }
{               ES:DI -> source string                     }
{ Exit:                                                    }
{               SI, DI updated by CX                       }
{ Used:                                                    }
{               AL, DI, SI, Flags                          }
{ Description:                                             }
{               Does a copying by the bytes;               }
{               does a copying by the words;               }
{ ******************************************************** }
@CopyStrFromDict:
             push     cx
             shr      cx, 1
             jnc     @CopyCharByCharSetupBX
             mov      al, es:[di]
             mov      [si], al
             inc      si
             inc      di
@CopyCharByCharSetupBX:
             jcxz    @CopyStrFromDictDone
             push     bx
             mov      bx, Globals.aWord
@CopyWordByWord:
             mov      ax, es:[di]
             mov      [si], ax
             add      si, bx
             add      di, bx
             dec      cx
             jnz     @CopyWordByWord
             pop      bx
@CopyStrFromDictDone:
             pop      cx
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Increments the access count for the node   }
{ Enter:                                                   }
{               DS = our data segment                      }
{               ES:BX -> dictionary node                   }
{ Exit:                                                    }
{               None                                       }
{ Used:                                                    }
{               AX, Flags                                  }
{ Description:                                             }
{               Gets the access count for the node;        }
{               increments and stores it back;             }
{ ******************************************************** }
@UpdateNodeAccessCount:
             call     _fndwGetNodeAccessCount
             inc      ax
             call     _StoreNodeAccessCount
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Increments the hit count for the node      }
{ Enter:                                                   }
{               DS = our data segment                      }
{               ES:BX -> dictionary node                   }
{ Exit:                                                    }
{               NC = successful end of searching           }
{ Used:                                                    }
{               AX, Flags                                  }
{ Description:                                             }
{               Gets the hit count for the node;           }
{               increments and stores it back;             }
{               sets the success flag for the searching;   }
{ ******************************************************** }
@UpdateNodeHitCount:
             call     _fndwGetNodeHitCount
             inc      ax
             call     _StoreNodeHitCount
             clc
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Resets the table pointers for searching    }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               None                                       }
{ Used:                                                    }
{               Flags                                      }
{ Description:                                             }
{               Sets the global variables;                 }
{ ******************************************************** }
@SetUserTablePtrsToNIL:
             push     ax
             sub      ax, ax
             mov      WORD PTR  ds:[@ddSearchTable].[0], ax
             mov      WORD PTR  ds:[@ddSearchTable].[2], ax
             mov      BYTE PTR  ds:[@chOldSearchTableSym], al
             mov      BYTE PTR  ds:[@chNewSearchTableSym], al
             pop      ax
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Sets the case searching pointers           }
{ Enter:                                                   }
{               DS = our data segment                      }
{               ES:BX -> node                              }
{               AL = first char of pattern                 }
{ Exit:                                                    }
{               None                                       }
{ Used:                                                    }
{               Flags                                      }
{ Description:                                             }
{               Sets the global variables;                 }
{ ******************************************************** }
@InitCaseSearchVars:
             test     WORD PTR  ds:[@dwUserSearchFlags], Globals.btSearchCaseSensitive
             jz      @NonCaseSensitiveWay
             call    @SetUserTablePtrsToNIL
             retn
@NonCaseSensitiveWay:
             push     ax
             mov      WORD PTR  ds:[@ddSearchTable].[0], bx
             mov      WORD PTR  ds:[@ddSearchTable].[2], es
             mov      BYTE PTR  ds:[@chOldSearchTableSym], al
             call     @CaseTranslateOfChar
             mov      BYTE PTR  ds:[@chNewSearchTableSym], al
             pop      ax
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Sets the case searching pointers           }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               AL = new symbol to search                  }
{               ES:BX -> new search link table             }
{               SI = offset of search input buffer         }
{               ZR = no non-case searching                 }
{               NZ = another case mapping way              }
{ Used:                                                    }
{               AX, SI, Flags                              }
{ Description:                                             }
{               Sets the global variables;                 }
{               tests a pointer for NIL;                   }
{ ******************************************************** }
@LoadCaseSearchVars:
             mov      si, (OFFSET @dbUserSearchInputWord256)
             mov      al, BYTE PTR  ds:[@chNewSearchTableSym]
             les      bx, DWORD PTR  ds:[@ddSearchTable]
             call     @SetUserTablePtrsToNIL
             push     ax
             call     @IsPointerNIL
             pop      ax
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Gets the user search input buffer size     }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               CX = user search input buffer length       }
{               NZ = non-empty string found                }
{               ZR = empty string found                    }
{ Used:                                                    }
{               CX, Flags                                  }
{ Description:                                             }
{               Gets the size and tests against a zero;    }
{ ******************************************************** }
@GetUserSearchStrLength:
             mov      cx, WORD PTR  ds:[@pofsUserSearchInputWordLength]
             or       cx, cx
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Search the dictionary for the matching     }
{               pattern through FA-link table              }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               NC = matching entry found                  }
{               CY = nothing found                         }
{ Used:                                                    }
{               AX, BX, DX, DI, ES, Flags                  }
{ Description:                                             }
{               Checks for empty table and string;         }
{               setups the global search variables;        }
{               searches the table by the the index with   }
{               the updating access count in the nodes;    }
{               if found then look the search type;        }
{               copy the found expression;                 }
{ ******************************************************** }
@SearchForwardAbbreviationDict:
             push     cx
             push     si
             les      bx, DWORD PTR  ds:[@CurForwardSearchAbbrevTablePtr]
             call     @IsPointerNIL
             jz      @ForwardAbbreviationSearchFailed
             call     @GetUserSearchStrLength
             jz      @ForwardAbbreviationSearchFailed
             mov      si, (OFFSET @dbUserSearchInputWord256)
             mov      al, [si]
             call     @InitCaseSearchVars
@GetTableIndexFA:
             mov      dx, WORD PTR  ds:[@dwCurUserEnvOptions]
             call     _fndwGetTableOffsetByIndex
@GetNodeFA:
             or       bx, bx
             jnz     @TryThisNodeFA
             call     @LoadCaseSearchVars
             jnz     @GetTableIndexFA
             cmp      BYTE PTR  ds:[@dbCurSearchType], Globals.aFirstFitType
             jne     @LookForSavedNodeFA
@BadSearchFA:
             jmp     @ForwardAbbreviationSearchFailed
@LookForSavedNodeFA:
             mov      dx, WORD PTR  ds:[@dwLastSavedAbbrOfs]
             or       dx, dx
             jz      @BadSearchFA
             les      bx, DWORD PTR  ds:[@lpLastSavedDictNode]
             call     @IsPointerNIL
             jz      @BadSearchFA
             jmp     @UseThisNodeFA
@TryThisNodeFA:
             call     @UpdateNodeAccessCount
             call     _fndbGetNodeAbbreviationSize
             cmp      al, cl
             jb      @GetNodeLinkFA
             push     si
             call     _fndwGetNodeAbbreviationOfs
             mov      di, ax
             mov      dx, di
             call     @CompareStrFwd
             pop      si
             je      @ForwardAbbreviationSearchSuccess
@GetNodeLinkFA:
             call     _fndwGetNodeLinkOffsetForFA
             jmp     @GetNodeFA
@ForwardAbbreviationSearchSuccess:
             mov      al, BYTE PTR  ds:[@dbCurSearchType]
             cmp      al, Globals.aFirstFitType
             je      @UseThisNodeFA
             cmp      al, Globals.aLastFitType
             jne     @LookBestFitForFA
@StoreLastNodeFA:
             mov      WORD PTR  ds:[@dwLastSavedAbbrOfs], dx
             mov      WORD PTR  ds:[@lpLastSavedDictNode][0], bx
             mov      WORD PTR  ds:[@lpLastSavedDictNode][2], es
             jmp     @GetNodeLinkFA
@LookBestFitForFA:
             call     _fndbGetNodeAbbreviationSize
             sub      al, cl
             or       al, al
             jz      @UseThisNodeFA
             cmp      al, BYTE PTR  ds:[@dbDiffInSizes]
             jae     @GetNodeLinkFA
             mov      BYTE PTR  ds:[@dbDiffInSizes], al
             jmp     @StoreLastNodeFA
@UseThisNodeFA:
             mov      di, dx
             sub      ax, ax
             call     _fndbGetNodeAbbreviationSize
             add      di, ax
             mov      si, OFFSET  @dbUserReplaceInputWord256
             sub      cx, cx
             call     _fndbGetNodeExpressionSize
             mov      cl, al
             mov      ax, WORD PTR  ds:[@dwCharsToReplaceBefore]
             mov      dx, ax
             add      ax, cx
             mov      WORD PTR  ds:[@dwUserReplaceInputWordLength], ax
             call     @FillReplaceBufWithBS
             call     @CopyStrFromDict
             call     @UpdateNodeHitCount
@ForwardAbbreviationSearchRestoreWorld:
             pop      si
             pop      cx
             retn
@ForwardAbbreviationSearchFailed:
             stc
             jmp     @ForwardAbbreviationSearchRestoreWorld
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Search the dictionary for the matching     }
{               pattern through BA-link table              }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               NC = matching entry found                  }
{               CY = nothing found                         }
{ Used:                                                    }
{               AX, BX, DX, DI, ES, Flags                  }
{ Description:                                             }
{               Checks for empty table and string;         }
{               setups the global search variables;        }
{               searches the table by the the index with   }
{               the updating access count in the nodes;    }
{               if found then look the search type;        }
{               copy the found expression;                 }
{ ******************************************************** }
@SearchBackwardAbbreviationDict:
             push     cx
             push     si
             les      bx, DWORD PTR  ds:[@CurBackwardSearchAbbrevTablePtr]
             call     @IsPointerNIL
             jz      @BackwardAbbreviationSearchFailed
             call     @GetUserSearchStrLength
             jz      @BackwardAbbreviationSearchFailed
             mov      si, (OFFSET @dbUserSearchInputWord256)
             mov      di, cx
             dec      di
             add      di, si
             mov      al, [di]
             call     @InitCaseSearchVars
@GetTableIndexBA:
             mov      dx, WORD PTR  ds:[@dwCurUserEnvOptions]
             call     _fndwGetTableOffsetByIndex
@GetNodeBA:
             or       bx, bx
             jnz     @TryThisNodeBA
             call    @LoadCaseSearchVars
             jnz     @GetTableIndexBA
             cmp      BYTE PTR  ds:[@dbCurSearchType], Globals.aFirstFitType
             jne     @LookForSavedNodeBA
@BadSearchBA:
             jmp     @BackwardAbbreviationSearchFailed
@LookForSavedNodeBA:
             mov      dx, WORD PTR  ds:[@dwLastSavedAbbrOfs]
             or       dx, dx
             jz      @BadSearchBA
             les      bx, DWORD PTR  ds:[@lpLastSavedDictNode]
             call     @IsPointerNIL
             jz      @BadSearchBA
             jmp     @UseThisNodeBA
@TryThisNodeBA:
             call     @UpdateNodeAccessCount
             call     _fndbGetNodeAbbreviationSize
             cmp      al, cl
             jb      @GetNodeLinkBA
             push     si
             add      si, cx
             dec      si
             mov      dx, ax
             call     _fndwGetNodeAbbreviationOfs
             mov      di, ax
             mov      ax, dx
             mov      dx, di
             sub      ah, ah
             add      di, ax
             dec      di
             call     @CompareStrBkwd
             pop      si
             je      @BackwardAbbreviationSearchSuccess
@GetNodeLinkBA:
             call     _fndwGetNodeLinkOffsetForBA
             jmp     @GetNodeBA
@BackwardAbbreviationSearchSuccess:
             mov      al, BYTE PTR  ds:[@dbCurSearchType]
             cmp      al, Globals.aFirstFitType
             je      @UseThisNodeBA
             cmp      al, Globals.aLastFitType
             jne     @LookBestFitForBA
@StoreLastNodeBA:
             mov      WORD PTR  ds:[@dwLastSavedAbbrOfs], dx
             mov      WORD PTR  ds:[@lpLastSavedDictNode][0], bx
             mov      WORD PTR  ds:[@lpLastSavedDictNode][2], es
             jmp     @GetNodeLinkBA
@LookBestFitForBA:
             call     _fndbGetNodeAbbreviationSize
             sub      al, cl
             or       al, al
             jz      @UseThisNodeBA
             cmp      al, BYTE PTR  ds:[@dbDiffInSizes]
             jae     @GetNodeLinkBA
             mov      BYTE PTR  ds:[@dbDiffInSizes], al
             jmp     @StoreLastNodeBA
@UseThisNodeBA:
             mov      di, dx
             sub      ax, ax
             call     _fndbGetNodeAbbreviationSize
             add      di, ax
             mov      si, OFFSET  @dbUserReplaceInputWord256
             sub      cx, cx
             call     _fndbGetNodeExpressionSize
             mov      cl, al
             mov      ax, WORD PTR  ds:[@dwCharsToReplaceBefore]
             mov      dx, ax
             add      ax, cx
             mov      WORD PTR  ds:[@dwUserReplaceInputWordLength], ax
             call     @FillReplaceBufWithBS
             call     @CopyStrFromDict
             call     @UpdateNodeHitCount
@BackwardAbbreviationSearchRestoreWorld:
             pop      si
             pop      cx
             retn
@BackwardAbbreviationSearchFailed:
             stc
             jmp     @BackwardAbbreviationSearchRestoreWorld
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Search the dictionary for the matching     }
{               pattern through FE-link table              }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               NC = matching entry found                  }
{               CY = nothing found                         }
{ Used:                                                    }
{               AX, BX, DX, DI, ES, Flags                  }
{ Description:                                             }
{               Checks for empty table and string;         }
{               setups the global search variables;        }
{               searches the table by the the index with   }
{               the updating access count in the nodes;    }
{               if found then copy the found expression;   }
{ ******************************************************** }
@SearchForwardExpressionDict:
             push     cx
             push     si
             les      bx, DWORD PTR  ds:[@CurForwardSearchDictTablePtr]
             call     @IsPointerNIL
             jz      @ForwardExprSearchFailed
             call     @GetUserSearchStrLength
             jz      @ForwardExprSearchFailed
             mov      si, (OFFSET @dbUserSearchInputWord256)
             mov      al, [si]
             call     @InitCaseSearchVars
@GetTableIndexFE:
             mov      dx, WORD PTR  ds:[@dwCurUserEnvOptions]
             call     _fndwGetTableOffsetByIndex
@GetNodeFE:
             or       bx, bx
             jnz     @TryThisNodeFE
             call    @LoadCaseSearchVars
             jnz     @GetTableIndexFE
             jmp     @ForwardExprSearchFailed
@TryThisNodeFE:
             call     @UpdateNodeAccessCount
             call     _fndbGetNodeExpressionSize
             cmp      al, cl
             jb      @GetNodeLinkFE
             push     si
             call     _fndwGetNodeExpressionOfs
             mov      di, ax
             mov      dx, di
             call     @CompareStrFwd
             pop      si
             je      @ForwardExprSearchSuccess
@GetNodeLinkFE:
             call     _fndwGetNodeLinkOffsetForFE
             jmp     @GetNodeFE
@ForwardExprSearchSuccess:
             mov      di, dx
             mov      si, OFFSET  @dbUserReplaceInputWord256
             sub      cx, cx
             call     _fndbGetNodeExpressionSize
             mov      cl, al
             mov      ax, WORD PTR  ds:[@dwCharsToReplaceBefore]
             mov      dx, ax
             add      ax, cx
             mov      WORD PTR  ds:[@dwUserReplaceInputWordLength], ax
             call     @FillReplaceBufWithBS
             call     @CopyStrFromDict
             call     @UpdateNodeHitCount
@ForwardExprSearchRestoreWorld:
             pop      si
             pop      cx
             retn
@ForwardExprSearchFailed:
             stc
             jmp     @ForwardExprSearchRestoreWorld
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Search the dictionary for the matching     }
{               pattern through BE-link table              }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               NC = matching entry found                  }
{               CY = nothing found                         }
{ Used:                                                    }
{               AX, BX, DX, DI, ES, Flags                  }
{ Description:                                             }
{               Checks for empty table and string;         }
{               setups the global search variables;        }
{               searches the table by the the index with   }
{               the updating access count in the nodes;    }
{               if found then copy the found expression;   }
{ ******************************************************** }
@SearchBackwardExpressionDict:
             push     cx
             push     si
             les      bx, DWORD PTR  ds:[@CurBackwardSearchDictTablePtr]
             call     @IsPointerNIL
             jz      @BackwardExprSearchFailed
             call     @GetUserSearchStrLength
             jz      @BackwardExprSearchFailed
             mov      si, (OFFSET @dbUserSearchInputWord256)
             mov      di, cx
             dec      di
             add      di, si
             mov      al, [di]
             call     @InitCaseSearchVars
@GetTableIndexBE:
             mov      dx, WORD PTR  ds:[@dwCurUserEnvOptions]
             call     _fndwGetTableOffsetByIndex
@GetNodeBE:
             or       bx, bx
             jnz     @TryThisNodeBE
             call    @LoadCaseSearchVars
             jnz     @GetTableIndexBE
             jmp     @BackwardExprSearchFailed
@TryThisNodeBE:
             call     @UpdateNodeAccessCount
             call     _fndbGetNodeExpressionSize
             cmp      al, cl
             jb      @GetNodeLinkBE
             push     si
             add      si, cx
             dec      si
             call     _fndwGetNodeExpressionOfs
             mov      di, ax
             mov      dx, di
             sub      ax, ax
             call     _fndbGetNodeExpressionSize
             add      di, ax
             dec      di
             call     @CompareStrBkwd
             pop      si
             je      @BackwardExprSearchSuccess
@GetNodeLinkBE:
             call     _fndwGetNodeLinkOffsetForBE
             jmp     @GetNodeBE
@BackwardExprSearchSuccess:
             mov      di, dx
             mov      si, OFFSET  @dbUserReplaceInputWord256
             sub      cx, cx
             call     _fndbGetNodeExpressionSize
             mov      cl, al
             mov      ax, WORD PTR  ds:[@dwCharsToReplaceBefore]
             mov      dx, ax
             add      ax, cx
             mov      WORD PTR  ds:[@dwUserReplaceInputWordLength], ax
             call     @FillReplaceBufWithBS
             call     @CopyStrFromDict
             call     @UpdateNodeHitCount
@BackwardExprSearchRestoreWorld:
             pop      si
             pop      cx
             retn
@BackwardExprSearchFailed:
             stc
             jmp     @BackwardExprSearchRestoreWorld
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Search the dictionary for the matching     }
{               pattern through AS-link table              }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               NC = matching entry found                  }
{               CY = nothing found                         }
{ Used:                                                    }
{               AX, BX, DX, DI, ES, Flags                  }
{ Description:                                             }
{               Checks for empty table and string;         }
{               setups the global search variables;        }
{               searches the table by the the index with   }
{               the access count updating for the nodes;   }
{               if found then copy the found expression;   }
{ ******************************************************** }
@SearchMiddleAbbreviationDict:
             push     cx
             push     si
             les      bx, DWORD PTR  ds:[@CurStrSizeSearchAbbrevTablePtr]
             call     @IsPointerNIL
             jz      @MiddleAbbreviationSearchFailed
             call     @GetUserSearchStrLength
             jnz     @GetUserAbbrLengthDone
             test     WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btEmptyAbbreviation
             jz      @MiddleAbbreviationSearchFailed
             mov      cl, BYTE PTR  ds:[@dbReservedEmptyAbbrSize]
             mov      si, (OFFSET @dbReservedEmptyAbbr3)
             jmp     @SetupTableIndexAS
@GetUserAbbrLengthDone:
             mov      si, (OFFSET @dbUserSearchInputWord256)
@SetupTableIndexAS:
             sub      ax, ax
             add      al, cl
             dec      ax
@GetTableIndexAS:
             inc      ax
             mov      WORD PTR  ds:[@CurStrLenIndexCount], ax
             les      bx, DWORD PTR  ds:[@CurStrSizeSearchAbbrevTablePtr]
             mov      dx, WORD PTR  ds:[@dwCurUserEnvOptions]
             call     _fndwGetTableOffsetByIndex
@GetNodeAS:
             or       bx, bx
             jnz     @TryThisNodeAS
             mov      ax, WORD PTR  ds:[@CurStrLenIndexCount]
             cmp      ax, Globals.aMaxCharBit8
             jbe     @GetTableIndexAS
             jmp     @MiddleAbbreviationSearchFailed
@TryThisNodeAS:
             call     @UpdateNodeAccessCount
             push     si
             call     _fndwGetNodeAbbreviationOfs
             mov      di, ax
             mov      dx, di
             mov      ax, WORD PTR  ds:[@CurStrLenIndexCount]
             call     @CompareStrMiddle
             pop      si
             je      @MiddleAbbreviationSearchSuccess
@GetNodeLinkAS:
             call     _fndwGetNodeLinkOffsetForAS
             jmp     @GetNodeAS
@MiddleAbbreviationSearchSuccess:
             mov      di, dx
             sub      ax, ax
             call     _fndbGetNodeAbbreviationSize
             add      di, ax
             mov      si, OFFSET  @dbUserReplaceInputWord256
             sub      cx, cx
             call     _fndbGetNodeExpressionSize
             mov      cl, al
             mov      ax, WORD PTR  ds:[@dwCharsToReplaceBefore]
             mov      dx, ax
             add      ax, cx
             mov      WORD PTR  ds:[@dwUserReplaceInputWordLength], ax
             call     @FillReplaceBufWithBS
             call     @CopyStrFromDict
             call     @UpdateNodeHitCount
@MiddleAbbreviationSearchRestoreWorld:
             pop      si
             pop      cx
             retn
@MiddleAbbreviationSearchFailed:
             stc
             jmp     @MiddleAbbreviationSearchRestoreWorld
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Search the dictionary for the matching     }
{               pattern through ES-link table              }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               NC = matching entry found                  }
{               CY = nothing found                         }
{ Used:                                                    }
{               AX, BX, DX, DI, ES, Flags                  }
{ Description:                                             }
{               Checks for empty table and string;         }
{               setups the global search variables;        }
{               searches the table by the the index with   }
{               the updating access count in the nodes;    }
{               if found then copy the found expression;   }
{ ******************************************************** }
@SearchMiddleExpressionDict:
             push     cx
             push     si
             les      bx, DWORD PTR  ds:[@CurStrSizeSearchDictTablePtr]
             call     @IsPointerNIL
             jz      @MiddleExpressionSearchFailed
             call     @GetUserSearchStrLength
             jz      @MiddleExpressionSearchFailed
             test     WORD PTR  ds:[@dwUserSearchFlags], Globals.btSingleWordSearchSym
             jz      @SingleWordSearchInitDone
             mov      WORD PTR  ds:[@dwMatchPatternOfs], 0
@SingleWordSearchInitDone:
             mov      si, (OFFSET @dbUserSearchInputWord256)
             sub      ax, ax
             add      al, cl
             dec      ax
@GetTableIndexES:
             inc      ax
             mov      WORD PTR  ds:[@CurStrLenIndexCount], ax
             les      bx, DWORD PTR  ds:[@CurStrSizeSearchDictTablePtr]
             mov      dx, WORD PTR  ds:[@dwCurUserEnvOptions]
             call     _fndwGetTableOffsetByIndex
@GetNodeES:
             or       bx, bx
             jnz     @TryThisNodeES
             mov      ax, WORD PTR  ds:[@CurStrLenIndexCount]
             cmp      ax, Globals.aMaxCharBit8
             jbe     @GetTableIndexES
             jmp     @MiddleExpressionSearchFailed
@TryThisNodeES:
             call     @UpdateNodeAccessCount
             push     si
             call     _fndwGetNodeExpressionOfs
             mov      di, ax
             mov      dx, di
             mov      ax, WORD PTR  ds:[@CurStrLenIndexCount]
             call     @CompareStrMiddle
             pop      si
             je      @MiddleExpressionSearchSuccess
@GetNodeLinkES:
             call     _fndwGetNodeLinkOffsetForES
             jmp     @GetNodeES
@MiddleExpressionSearchSuccess:
             mov      di, dx
             sub      cx, cx
             call     _fndbGetNodeExpressionSize
             mov      cl, al
             test     WORD PTR  ds:[@dwUserSearchFlags], Globals.btSingleWordSearchSym
             jz      @SkipSingleWordSearch
             mov      ax, WORD PTR  ds:[@dwMatchPatternOfs]
             call     @GetSingleWordFromDict
@SkipSingleWordSearch:
             mov      si, OFFSET  @dbUserReplaceInputWord256
             mov      ax, WORD PTR  ds:[@dwCharsToReplaceBefore]
             mov      dx, ax
             add      ax, cx
             mov      WORD PTR  ds:[@dwUserReplaceInputWordLength], ax
             call     @FillReplaceBufWithBS
             call     @CopyStrFromDict
             call     @UpdateNodeHitCount
@MiddleExpressionSearchRestoreWorld:
             pop      si
             pop      cx
             retn
@MiddleExpressionSearchFailed:
             stc
             jmp     @MiddleExpressionSearchRestoreWorld
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Search the dictionary for the matching     }
{               pattern through builded searching table    }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               AL = status code                           }
{               NC = matching entry found                  }
{               CY = nothing found                         }
{ Used:                                                    }
{               AX, BX, ES, Flags                          }
{ Description:                                             }
{               Sets the search substate mode;             }
{               updates the video indicators on screen;    }
{               searches the builded table of link tables  }
{               for searching of the matching pattern;     }
{               if found then copy the expression to the   }
{               replace buffer and sets the substate mode  }
{               to the replace state;                      }
{               (add the auto char if bit was set)         }
{ ******************************************************** }
@SearchDictForMatchForUserInput:
             push     dx
             push     si
             push     di
             push     bp
             mov      BYTE PTR  ds:[@dbSearchSubState], Globals.aSearchSubStateIsSearch
             call     @UpdateVideoIndicators
             mov      si, (OFFSET @dbSearchDictTable6)
             mov      cx, (Globals.btSearchExpressionSizes - Globals.btNoSearchThisTable) {=6}
@GetTableID:
             mov      al, [si]
             inc      si
             or       al, al
             jz      @IncrTableIndex
             sub     bx, bx
             mov     bl, al
             sub     bx, Globals.btForwardSearchAbbreviation
             shl     bx, 1
             call    WORD PTR  ds:[@pofsSearchDictDispatchTable].[bx]
             jnc    @MatchEntryFound
@IncrTableIndex:
             dec      cx
             jz     @ErrorAtSearch
             jmp    @GetTableID
@MatchEntryFound:
             test     WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btAutoAddChar
             jz      @AutoAddSpaceDone
             mov      bx, WORD PTR  ds:[@dwUserReplaceInputWordLength]
             mov      al, BYTE PTR ds:[@chCurAutoAddChar]
             mov      BYTE PTR  ds:[@dbUserReplaceInputWord256].[bx], al
             inc      bx
             mov      WORD PTR  ds:[@dwUserReplaceInputWordLength], bx
@AutoAddSpaceDone:
             call     @ReplaceUserInputForMatchingFromDict
             mov      al, Globals.errStatus_Success
             clc
@SearchRestoreWorld:
             pop      bp
             pop      di
             pop      si
             pop      dx
             retn
@ErrorAtSearch:
             mov      al, Globals.errStatus_No_Match_Search_Entry
             stc
             jmp     @SearchRestoreWorld
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Sets the replace substate mode             }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               None                                       }
{ Used:                                                    }
{               Flags                                      }
{ Description:                                             }
{               Sets the replace substate mode;            }
{               updates the video indicators on screen;    }
{ ******************************************************** }
@ReplaceUserInputForMatchingFromDict:
             mov      BYTE PTR  ds:[@dbSearchSubState], Globals.aSearchSubStateIsReplace
             call     @UpdateVideoIndicators
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Filtering of the raw input                 }
{ Enter:                                                   }
{               DS = our data segment                      }
{               AL = character to test                     }
{               DS:BX -> raw string buffer                 }
{ Exit:                                                    }
{               NC = allows char to put into buffer        }
{               CY = no allows char to put into buffer     }
{ Used:                                                    }
{               BX, Flags                                  }
{ Description:                                             }
{               Rejects the control characters;            }
{               checks for the backspace character with    }
{               deleting of character;                     }
{ ******************************************************** }
@FilterUserInput:
             cmp     al, Globals.achSpace
             jae    @GoodCharFound
             cmp     al, Globals.achBS
             jne    @BadCharFound
             dec     bx
             cmp     bx, OFFSET @dbUserRawInputWord256
             jae     @BadCharFound
             mov     bx, OFFSET @dbUserRawInputWord256
@BadCharFound:
             stc
             retn
@GoodCharFound:
             clc
             retn
{ End }



{$IFDEF   StaVer}

{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Increment user keystroke record            }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               None                                       }
{ Used:                                                    }
{               Flags                                      }
{ Description:                                             }
{               Checks for enabling of updating;           }
{               checks for empty record pointer;           }
{               increment keystrokes count;                }
{ ******************************************************** }
@UpdateUserKeystrokeRecord:
             cmp     BYTE PTR  ds:[@bRunStatTiming], System.False
             je     @UpdateUserRecDone
             push    ax
             push    bx
             push    es
             les     bx, DWORD PTR  ds:[@lpCurKeystrokesRecord]
             call    @IsPointerNIL
             jz     @SkipUpdateUserRecord
             inc     WORD PTR es:[bx][Globals.recKeystrokesTiming.dwUserKeystrokes]
@SkipUpdateUserRecord:
             pop     es
             pop     bx
             pop     ax
@UpdateUserRecDone:
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Increment program keystroke record         }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               None                                       }
{ Used:                                                    }
{               Flags                                      }
{ Description:                                             }
{               Checks for enabling of updating;           }
{               checks for empty record pointer;           }
{               increment keystrokes count;                }
{ ******************************************************** }
@UpdateProgramKeystrokeRecord:
             cmp     BYTE PTR  ds:[@bRunStatTiming], System.False
             je     @UpdateProgramRecDone
             push    ax
             push    bx
             push    es
             les     bx, DWORD PTR  ds:[@lpCurKeystrokesRecord]
             call    @IsPointerNIL
             jz     @SkipUpdateProgramRecord
             inc     WORD PTR es:[bx][Globals.recKeystrokesTiming.dwProgramKeystrokes]
@SkipUpdateProgramRecord:
             pop     es
             pop     bx
             pop     ax
@UpdateProgramRecDone:
             retn
{ End }

{$ENDIF} {StaVer}


{ ********************* SUPPLEMENT ********************* }



{ ********************* INT $16 ********************* }

{ ------------------------------------------------------- }
{ Description:                                            }
{    Handler of keyboard BIOS services;                   }
{    Calls the state switch task;                         }
{    Calls the corresponding mode subroutine;             }
{ ------------------------------------------------------- }
@EnterHandlerInt16:
             pushf
             call    @StateSwitcherFromKeyboard
             push    ax
             mov     al, BYTE PTR  cs:[@dbCurStateMode]
             cmp     al, Globals.aStateModeValMin
             jb     @ExitToPrevHandlerInt16
             cmp     al, Globals.aStateModeValMax
             ja     @ExitToPrevHandlerInt16
             pop     ax
             popf
             push    ds
             push    bx
             mov     bx, cs
             mov     ds, bx
             sub     bx, bx
             mov     bl, BYTE PTR  ds:[@dbCurStateMode]
{$IFDEF   StaVer}
             cmp     BYTE PTR  ds:[@bRunStatTiming], System.False
             je     @SkipTimingStat
             cmp     ah, Globals.aReadKeyStd
             je     @CheckCurKbdMode
             cmp     ah, Globals.aReadKeyEnh
             jne    @SkipTimingStat
@CheckCurKbdMode:
             cmp     bl, Globals.aStateIsManualMode
             jne    @DoUserTimingStat
             cmp     BYTE PTR  ds:[@dbSearchSubState], Globals.aSearchSubStateIsReplace
             je     @SkipTimingStat
@DoUserTimingStat:
             call    @UpdateUserKeystrokeRecord
@SkipTimingStat:
{$ENDIF} {StaVer}
             sub     bx, Globals.aStateIsIdleMode
             shl     bx, 1
             jmp     WORD PTR  ds:[@pofsSoftKeyboardDispatchTable].[bx]

@ExitToPrevHandlerInt16:
             pop     ax
             popf
@JumpToPrevHandlerInt16:
             jmp     DWORD PTR  cs:[@lpPrevInt16]


{ ------------------------------------------------------- }
{ Description:                                            }
{       Gives the control to the previous handler;        }
{ ------------------------------------------------------- }
@ITypist_StateIsAddMode:
@NoActionForThisMode:
             pop     bx
             pop     ds
             sti
             jmp    @JumpToPrevHandlerInt16


{ ------------------------------------------------------- }
{ Description:                                            }
{       Filters the functions $01, $11;                   }
{       Checks for the matching hotkey;                   }
{       Switches to the corresponding mode;               }
{       Otherwise, returns as is;                         }
{ ------------------------------------------------------- }
@ITypist_StateIsIdleMode:
@ITypist_StateIsManualMode:
             cmp     ah, Globals.aAvailKeyStd
             je     @FilterNonFlushReading
             cmp     ah, Globals.aAvailKeyEnh
             jne    @CheckOtherReadFunctions
@FilterNonFlushReading:
             test    WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btUseInt1601
             jz     @CheckOtherReadFunctions
             mov     WORD PTR  ds:[@dwFuncCodeInAX], ax
@FilterNonFlushReadingAX:
             pushf
             call    DWORD PTR  ds:[@lpPrevInt16]  {read, but no remove key}
             pushf
             jnz    @SomethingInKbdBuf
@NonFlushReadDone:
             popf
             jmp    @ExitInt16
@TryToSyncInt16:
             mov     BYTE PTR  ds:[@bSyncInt16], System.True
             jmp    @NonFlushReadDone
@SomethingInKbdBuf:
             test    WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btUseInt154F
             jnz    @NonFlushReadDone
             cmp     BYTE PTR  ds:[@bSyncInt16], System.True
             je     @NonFlushReadDone
             xchg    ah, al
             call   @LookMatchHotScanKey
             xchg    ah, al
             jc     @TryToSyncInt16
             cmp     BYTE PTR  ds:[@dbLastStatusCode], Globals.errStatus_Success
             jne    @NonFlushReadDone
@RemoveHotKeyFromBuf:
             popf                       {adjust stack pointer}
             mov     ax, WORD PTR  ds:[@dwFuncCodeInAX]
             dec     ah                 {translate to destructive reading!}
             pushf
             call    DWORD PTR  ds:[@lpPrevInt16]
             mov     ax, WORD PTR  ds:[@dwFuncCodeInAX]
             jmp    @FilterNonFlushReadingAX
{ ------------------------------------------------------- }
{ Description:                                            }
{       Filters the functions $00, $10;                   }
{       Checks for the matching hotkey;                   }
{       Switches to the corresponding mode;               }
{       Filters the input characters;                     }
{       Stores a character in the raw input buffer;       }
{ ------------------------------------------------------- }
@CheckOtherReadFunctions:
             cmp     ah, Globals.aReadKeyStd
             je     @FilterThisSubFuncFlushRead
             cmp     ah, Globals.aReadKeyEnh
             je     @FilterThisSubFuncFlushRead
             jmp    @NoActionForThisMode
@FilterThisSubFuncFlushRead:
             mov     WORD PTR  ds:[@dwFuncCodeInAX], ax
@FilterThisSubFuncIntFlushReadAX:
             pushf
             call    DWORD PTR  ds:[@lpPrevInt16]    {remove key}
             pushf
             test    WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btUseInt154F
             jnz    @NoMatchHotKey
             mov     bl, System.False
             xchg    BYTE PTR  ds:[@bSyncInt16], bl
             cmp     bl, System.True
             je     @NoMatchHotKey
             xchg    ah, al
             call   @LookMatchHotScanKey
             xchg    ah, al
             jc     @NoMatchHotKey
             cmp     BYTE PTR  ds:[@dbLastStatusCode], Globals.errStatus_Success
             jne    @ReturnKeyToInt16
             popf             {adjust stack pointer}
             mov     ax, WORD PTR  ds:[@dwFuncCodeInAX]  {wait other key!}
             jmp    @FilterThisSubFuncIntFlushReadAX
@ReturnKeyToInt16:
             popf
             or      ax, ax
             jmp    @ExitInt16
@NoMatchHotKey:
             cmp     BYTE PTR  ds:[@dbCurStateMode], Globals.aStateIsIdleMode
             je     @ReturnKeyToInt16
             push    ax
             mov     bx, WORD PTR  ds:[@pofsUserRawInputWord]
             cmp     bx, (OFFSET @dbUserRawInputWord256) + (Globals.aMaxStrLen)
             jb     @NoRollUserWordBuf
             mov     bx, OFFSET @dbUserRawInputWord256
@NoRollUserWordBuf:
             cmp     al, 0E0h                   {extended arrow keys}
             jne    @NotE0
             or      ah, ah                     {scan code}
             jnz    @StoreCharDone
             jmp    @ScanToAscii
@NotE0:
             or      al, al                     {ASCII code}
             jnz    @StoreUserChar
             cmp     ah, 128                    {upper half?}
             jb     @StoreCharDone
@ScanToAscii:
             mov     al, ah
@StoreUserChar:
             test    WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btFlushInputOnCR
             jz     @LookForFilterInput
             cmp     al, Globals.achCR
             jne    @LookForFilterInput
             call    @ResetRawUserInput
             jmp    @ExitInt16Restore
@LookForFilterInput:
             test    WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btFilterRawInput
             jz     @NoFilterForInput
             call    @FilterUserInput
             jc     @StoreCharDone
@NoFilterForInput:
             mov     [bx], al                   {store character}
             inc     bx
@StoreCharDone:
             mov     WORD PTR  ds:[@pofsUserRawInputWord], bx
@ExitInt16Restore:
             pop     ax
             popf
@ExitInt16:
             pop     bx                         {recover stack}
             pop     ds
             sti                                {interrupts turn ON!!!}
             retf    2


{ ------------------------------------------------------- }
{ Description:                                            }
{       Dispatcher for the replace submode;               }
{ ------------------------------------------------------- }
@ITypist_StateIsSearchMode:
             mov     bl, BYTE PTR  ds:[@dbSearchSubState]
             shl     bx, 1
             jmp     WORD PTR  ds:[@pofsSearchStateDispatchTable].[bx]


{ ------------------------------------------------------- }
{ Description:                                            }
{       Simply terminates;                                }
{ ------------------------------------------------------- }
@SearchSubStateIsAnalyze:
@aSearchSubStateIsSearch:
             jmp    @NoActionForThisMode


{ -------------------------------------------------------- }
{ Description:                                             }
{       Filters function $0, $1, $10, $11;                 }
{       Gets the next available character from a replace   }
{       buffer;                                            }
{       Does a trick with the multiple backspaces;         }
{       Switch to the previous state if replace buffer was }
{       flushed, with video indication updating;           }
{ -------------------------------------------------------- }
@SearchSubStateIsReplace:
@CheckKbdFuncs:
             cmp     BYTE PTR  ds:[@dbWaitTimerTicks], 0
             jne    @TheseFuncsNotUsed
             cmp     ah, Globals.aAvailKeyStd
             je     @NonDestructiveReading
             cmp     ah, Globals.aAvailKeyEnh
             jne    @CheckReadKeyFuncs
@NonDestructiveReading:
             call    @GetCharFromReplaceStrBuf
             jmp    @ExitInt16
@CheckReadKeyFuncs:
             cmp     ah, Globals.aReadKeyStd
             je     @GetAvailableKeystroke
             cmp     ah, Globals.aReadKeyEnh
             jne    @TheseFuncsNotUsed
@GetAvailableKeystroke:
             call    @GetCharFromReplaceStrBuf
             push    ax
             call    @CheckForMultipleBS
             call    @IncrCharIndexForReplaceStr
{$IFDEF   StaVer}
             call    @UpdateProgramKeystrokeRecord
{$ENDIF} {StaVer}
             pop     ax
             jmp    @ExitInt16
@TheseFuncsNotUsed:
             jmp    @NoActionForThisMode



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Increment pointer for replace buffer       }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               None                                       }
{ Used:                                                    }
{               AX, Flags                                  }
{ Description:                                             }
{               Updates the global variables;              }
{               checks for empty size of buffer;           }
{               if empty then switch to the previous state }
{               of handler with video indication update;   }
{ ******************************************************** }
@IncrCharIndexForReplaceStr:
             inc     WORD PTR  ds:[@pofsCurUserReplaceInput]
             dec     WORD PTR  ds:[@dwUserReplaceInputWordLength]
             jnz    @AvailableKeystrokeInAX
             mov     BYTE PTR  ds:[@dbSearchSubState], Globals.aSearchSubStateIsAnalyze
             mov     al, BYTE PTR  ds:[@dbPrevStateMode]
             mov     BYTE PTR  ds:[@dbCurStateMode], al
             call    @UpdateVideoIndicators
             call    @CheckForModeDefaults
@AvailableKeystrokeInAX:
             retn
{ End }



{ Subroutine }
{ ******************************************************** }
{ Purpose:                                                 }
{               Gets the replace character/scan code       }
{ Enter:                                                   }
{               DS = our data segment                      }
{ Exit:                                                    }
{               AL = ASCII code of character               }
{               AH = Scan code of character                }
{               NZ = keystroke was found in buffer         }
{ Used:                                                    }
{               AX, BX, Flags                              }
{ Description:                                             }
{               Gets the char from buffer;                 }
{               gets the scan code from the table using    }
{               the code as the table index;               }
{ ******************************************************** }
@GetCharFromReplaceStrBuf:
             mov         bx, WORD PTR  ds:[@pofsCurUserReplaceInput]
             sub         ax, ax
             mov         al, [bx]
             or          bx, bx
             pushf
             sub         bx, bx
             mov         bl, al
             test        WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btAutoPutScanCode
             jz         @AddScanCodeDone
             mov         ah, BYTE PTR  ds:[@dbCurScanCodeArray256].[bx]
@AddScanCodeDone:
             popf
             retn
{ End }

{ ********************* INT $16 ********************* }



{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{               Checks for multiple backspaces               }
{ Enter:                                                     }
{               DS = our data segment                        }
{ Exit:                                                      }
{               None                                         }
{ Used:                                                      }
{               AX, BX, Flags                                }
{ Description:                                               }
{               Does a trick based on the timer handler to   }
{               put the our keystrokes into the BIOS buffer; }
{ ********************************************************** }
@CheckForMultipleBS:
             test      WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btUseForOldNorton1986
             jnz      @UsePatchOnTimer
             test      WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btUseForMSWord
             jz       @ThisIsNotBS
             cmp       al, Globals.achBS
             jne      @ThisIsNotBS
@UsePatchOnTimer:
             mov       bl, BYTE PTR  ds:[@dbInitWaitTimerTicks]
             mov       BYTE PTR  ds:[@dbWaitTimerTicks], bl
@ThisIsNotBS:
             retn
{ End }



{ ********************* INT $08 ********************* }

{ ------------------------------------------------------- }
{ Description:                                            }
{    Handler of BIOS timer.                               }
{    Updates the wait timer to return replace key;        }
{    Updates the typing statistics;                       }
{ ------------------------------------------------------- }
@EnterHandlerInt08:
             push      ax
             push      ds
             mov       ax, cs
             mov       ds, ax
             pushf
             call      DWORD PTR ds:[@lpPrevInt08]
             test      WORD PTR  ds:[@dwCurUserEnvOptions], (Globals.btUseForMSWord+Globals.btUseForOldNorton1986)
             jz       @WriteKeyDone
             cmp       BYTE PTR  ds:[@dbWaitTimerTicks], 0
             je       @WriteKeyDone
             dec       BYTE PTR  ds:[@dbWaitTimerTicks]
@WriteKeyDone:
{$IFDEF   StaVer}
             cmp       BYTE PTR  ds:[@bRunStatTiming], System.False
             je       @TimerServiceDone
             dec       WORD PTR  ds:[@dwCurTicksForOneMin]
             jnz      @NoEndOfTimeUnit
             mov       ax, WORD PTR  ds:[@dwInitTimeTicksPerMinute]
             mov       WORD PTR  ds:[@dwCurTicksForOneMin], ax
             add       WORD PTR  ds:[@lpCurKeystrokesRecord][0], TYPE (Globals.recKeystrokesTiming)
             dec       WORD PTR  ds:[@dwRemStatTimeInMinutes]
             jnz      @NoEndOfTimeUnit
             mov       BYTE PTR  ds:[@bRunStatTiming], System.False
@NoEndOfTimeUnit:
{$ENDIF} {StaVer}
@TimerServiceDone:
             pop       ds
             pop       ax
             iret
{ End }

{ ********************* INT $08 ********************* }



{ ********************* INT $09 ************************* }

{ ------------------------------------------------------- }
{ Description:                                            }
{    Handler of keyboard hardware interrupt.              }
{    Calls the previous interrupt handler.                }
{    Checks for INT154F flag and it is not set then       }
{    calls the task switcher.                             }
{    Exit from interrupt.                                 }
{ ------------------------------------------------------- }
@EnterHandlerInt09:
             pushf
             call      DWORD PTR cs:[@lpPrevInt09]
             test      WORD PTR  cs:[@dwCurUserEnvOptions], Globals.btUseInt154F
             jnz      @ExitInt09
             call      @StateSwitcherFromKeyboard
@ExitInt09:
             iret
{ End }

{ ********************* INT $09 ************************* }



{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{               Emulates the default mode setting            }
{ Enter:                                                     }
{               DS = our data segment                        }
{               AL = current mode of handler                 }
{ Exit:                                                      }
{               None                                         }
{ Used:                                                      }
{               AX, Flags                                    }
{ Description:                                               }
{               Switch to the corresponding mode;            }
{ ********************************************************** }
@CheckForModeDefaults:
             cmp      al, Globals.aStateIsManualMode
             jne     @KbdMode_0
             call     @SelectManualMode
             jmp      @CheckForModeDefaultsDone
@KbdMode_0:
             cmp      al, Globals.aStateIsAddMode
             jne     @KbdMode_1
             call     @SelectAddMode
             jmp      @CheckForModeDefaultsDone
@KbdMode_1:
             cmp      al, Globals.aStateIsIdleMode
             jne     @KbdMode_2
             call     @SelectIdleMode
@KbdMode_2:
@CheckForModeDefaultsDone:
             retn
{ End }



{ ***************** INT $2F or other user interrupt ***************** }

{ ------------------------------------------------------- }
{ Description:                                            }
{    Return from interrupt with error.                    }
{ ------------------------------------------------------- }
@BadCall2F_CodeAL:
             pop     ds
@BadCall2F_CodeAL_NoDS:
             stc
             retf    2
@BadCall2F_NoDS:
             mov     al, Globals.aMP_Bad_Call
             jmp     @BadCall2F_CodeAL_NoDS


{ ******************************** }
{  Purpose: API interface          }
{  Enter: AH = multiplex channel   }
{         AL = subfunction number  }
{         Other: see below         }
{  Return:  CY error occurred      }
{             AL = error code      }
{           NC successful          }
{             AL = 00 (good)       }
{           Other: see below       }
{ Description:                     }
{ ******************************** }
@EnterHandlerInt2F:
             cmp     ah, BYTE PTR cs:[@dbCurMultiplexNum]
             je     @MatchMultiplexNum
             {fix a problem of user empty interrupt}
             cmp     WORD PTR cs:[@lpPrevInt2F][2], 0
             jne    @GoToPrevInt2F
             cmp     WORD PTR cs:[@lpPrevInt2F][0], 0
             je     @BadCall2F_CodeAL_NoDS
@GoToPrevInt2F:
             jmp     DWORD PTR cs:[@lpPrevInt2F]

@MatchMultiplexNum:
             cmp     al, Globals.aITypist_Func_Num_Max
             ja     @BadCall2F_NoDS
             sti
             push    ds
             push    ax
             push    bx
             sub     bx, bx
             mov     bl, al
             shl     bx, 1
             mov     ax, cs
             mov     ds, ax
             mov     bx, WORD PTR ds:[@pofsMultilpexDispatchTable].[bx]
             mov     WORD PTR ds:[@dwJumpToCodeInt2F], bx
             pop     bx
             pop     ax
             jmp     WORD PTR ds:[@dwJumpToCodeInt2F]
{ End }



{ ******************************** }
{  Purpose: Status of TSR          }
{  Enter:  None                    }
{  Return: AL = install state      }
{  Description:                    }
{ ******************************** }
@ITypist_Install_Status:
             mov     al, Globals.aMP_Already_Installed
             jmp     @ExitInt2F
{ End }



{ ******************************** }
{  Purpose: Extended TSR status    }
{  Enter:  None                    }
{  Return: BX = 2-byte ID 1        }
{          CX = 2-byte ID 2        }
{          ES:DI -> Resident_CS:0  }
{  Description:                    }
{ ******************************** }
@ITypist_Current_Status:
             mov      bx, Globals.adwEXT_MPID_1
             mov      cx, Globals.adwEXT_MPID_2
             mov      di, cs                   { ES:DI -> resident part }
             mov      es, di
             sub      di, di                   { DI <- 0 }
             jmp     @GoodExitInt2F
{ End }



{ ************************************************************** }
{  Purpose:                                                      }
{       Dynamic extension of dictionary                          }
{  Enter:                                                        }
{      ES:BX -> user string to procces new dictionary entry      }
{         CX =  # of characters in string                        }
{  Return:                                                       }
{      None                                                      }
{  Description:                                                  }
{ ************************************************************** }
@ITypist_Add_Dic_Entry:
             cmp      cx, 2+1+2         {at least > 5 chars}
             jbe     @BadUserStr
             call     @IsPointerNIL
             jz      @BadUserStr
             call     @ResetSearchUserInput
             call     @ResetRawUserInput
             push     si
             push     cx
             mov      si, OFFSET @dbUserRawInputWord256
@CopyUserStrToMemBuf:
             mov      al, es:[bx]
             mov      [si], al
             inc      bx
             inc      si
             dec      cx
             jnz     @CopyUserStrToMemBuf
             mov      WORD PTR  ds:[@pofsUserRawInputWord], si
             call     @AnalyzeAndAddNewDictEntryDefinition
             mov      ah, Globals.aMP_No_Free_Memory
             cmp      al, Globals.errStatus_No_Enough_Free_Memory
             je      @ErrorCodeWasSet
             mov      ah, Globals.aMP_Same_Entry_Found
             cmp      al, Globals.errStatus_Duplicate_Entry_Found
             je      @ErrorCodeWasSet
             mov      ah, Globals.aMP_Bad_User_Def_Str
             cmp      al, Globals.errStatus_Bad_User_Definition
             je      @ErrorCodeWasSet
             cmp      al, Globals.errStatus_Bad_Non_Special_Sym
             je      @ErrorCodeWasSet
             cmp      al, Globals.errStatus_Bad_Num_Parm
             je      @ErrorCodeWasSet
             mov      ah, Globals.aMP_User_Dict_Is_Compressed
             cmp      al, Globals.errStatus_Dict_Is_Compressed
             je      @ErrorCodeWasSet
             mov      ah, Globals.aMP_Successful_Done
@ErrorCodeWasSet:
             mov      al, ah
             pop      cx
             pop      si
@AddEntryCallDone:
             jmp     @ExitInt2F
@BadUserStr:
             mov      al, Globals.aMP_Bad_User_Def_Str
             jmp     @AddEntryCallDone
{ End }



{ *********************************************** }
{  Purpose: Keyboard Mode Control                 }
{  Enter:  BX = new keyboard mode;                }
{               0 = return current keyboard mode  }
{  Return: For GetKeyboardMode                    }
{           BX = current keyboard mode            }
{          For SetKeyboardMode                    }
{           None                                  }
{ Description:                                    }
{ *********************************************** }
@ITypist_Get_Set_Kbd_Mode:
             or       bx, bx
             jz      @GetCurKbdMode
             cmp      bx, Globals.aStateModeValMin
             jb      @BadKbdModeFound
             cmp      bx, Globals.aStateModeValMax
             ja      @BadKbdModeFound
             mov      BYTE PTR  ds:[@dbCurStateMode], bl
             mov      al, bl
             call    @CheckForModeDefaults
@KbdModeCallDone:
             jmp     @GoodExitInt2F
@GetCurKbdMode:
             sub      bx, bx
             mov      bl, BYTE PTR  ds:[@dbCurStateMode]
             jmp     @KbdModeCallDone
@BadKbdModeFound:
             mov      al, Globals.aMP_Bad_Kbd_Mode
             jmp     @BadCall2F_CodeAL
{ End }



{ ****************************************** }
{  Purpose:                                  }
{          Allocate free memory              }
{  Enter:                                    }
{          BX = size of bytes;               }
{               0 = return info about pool   }
{  Return:                                   }
{          For GetPoolInfo                   }
{           ES:BX -> free memory pool        }
{           CX = size of pool                }
{          For GetBlockFromPool              }
{           ES:BX -> block address           }
{ Description:                               }
{ ****************************************** }
@ITypist_Get_Free_Elem:
             or       bx, bx        {get?}
             jz      @GetInfoAboutFreeSpace
             cmp      bx, WORD PTR  ds:[@dwFreeSpaceSize]
             ja      @NoEnoughFreeMemory
             mov      ax, bx
             call     @AllocateFreeMem
             jmp    @GoodExitInt2F
     @NoEnoughFreeMemory:
             mov      al, Globals.aMP_No_Free_Memory
             jmp     @BadCall2F_CodeAL
     @GetInfoAboutFreeSpace:
             mov      cx, WORD PTR  ds:[@dwFreeSpaceSize]
             les      bx, DWORD PTR  ds:[@lpFreeSpaceStart]
             jmp     @GoodExitInt2F
{ End }



{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{               Allocates actual free memory block           }
{ Enter:                                                     }
{               DS = our data segment                        }
{               AX = count of bytes to allocate              }
{ Exit:                                                      }
{               ES:BX -> pointer to allocated block          }
{ Used:                                                      }
{               AX, BX, ES, Flags                            }
{ Description:                                               }
{               Decrease the free memory pool;               }
{               synchronize with current environment links;  }
{ ********************************************************** }
@AllocateFreeMem:
             les      bx, DWORD PTR  ds:[@lpFreeSpaceStart]
             sub      WORD PTR  ds:[@dwFreeSpaceSize], ax
             add      WORD PTR  ds:[@lpFreeSpaceStart].[0], ax
             cmp      BYTE PTR  ds:[@bDynamicExtendDict], System.False
             je      @AllocFreeMemDone
             push     bx
             mov      bx, WORD PTR  ds:[@dwCurEnvironment]
             or       bx, bx
             jz      @SyncFreeLinksDone
             call     @CopyFreeSpaceLink
@SyncFreeLinksDone:
             pop      bx
@AllocFreeMemDone:
             retn
{ End }



{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{               Checks the specified environment handle for  }
{               the valid range                              }
{ Enter:                                                     }
{               DS = our data segment                        }
{               BX = environment handle                      }
{ Exit:                                                      }
{               NC = handle in valid range                   }
{               CY = invalid handle                          }
{ Used:                                                      }
{               Flags                                        }
{ Description:                                               }
{               Tests handle for valid range;                }
{ ********************************************************** }
@CheckEnvRange:
             cmp      bx, Globals.aEnviron_Avail_Min
             jb      @BadEnvIndexFound
             cmp      bx, Globals.aEnviron_Avail_Max
             ja      @BadEnvIndexFound
             clc
             retn
@BadEnvIndexFound:
             stc
             retn
{ End }



{ ********************************************** }
{  Purpose: Environment Control                  }
{  Enter:  BX = environment handle;              }
{               0 = return current environment   }
{  Return: For GetEnvironment                    }
{           BX = current environment             }
{          For SetEnvironment                    }
{           None                                 }
{ Description:                                   }
{ ********************************************** }
@ITypist_Get_Set_Environ:
             or       bx, bx
             jz      @GetCurEnvironment
             call    @CheckEnvRange
             jnc     @GoodEnvIndex
     @BadEnvIndex:
             mov      al, Globals.aMP_Bad_Range_Env
     @BadEnvFuncCall:
             jmp     @BadCall2F_CodeAL
     @GoodEnvIndex:
             call     @SetNewCurEnv
             jc      @BadEnvFuncCall
             jmp     @GetSetEnvCallDone
     @GetCurEnvironment:
             mov      bx, WORD PTR  ds:[@dwCurEnvironment]
     @GetSetEnvCallDone:
             jmp     @GoodExitInt2F
{ End }



{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{               Sets the new current environment             }
{ Enter:                                                     }
{               DS = our data segment                        }
{               BX = environment handle                      }
{ Exit:                                                      }
{               NC = setting done                            }
{               CY = setting failed                          }
{ Used:                                                      }
{               AX, BX, Flags                                }
{ Description:                                               }
{               Tests handle for presence pointer in table;  }
{               if empty pointer then exits with error,      }
{               otherwise copy new environment to current;   }
{ ********************************************************** }
@SetNewCurEnv:
             push     cx
             mov      ax, bx
             dec      bx
             shl      bx, 1
             shl      bx, 1
             mov      cx, WORD PTR  ds:[@ddEnvironmentTable].[bx].[0]
             or       cx, WORD PTR  ds:[@ddEnvironmentTable].[bx].[2]
             jz      @BadSetNewEnvFuncCall
             mov      WORD PTR  ds:[@dwCurEnvironment], ax
             push     ds
             push     es
             push     di
             push     si
             mov      di, OFFSET  @dwCurIdleModeHotkey
             mov      cx, ds
             mov      es, cx
             lds      si, DWORD PTR  ds:[@ddEnvironmentTable].[bx]
             mov      cx, TYPE  (Globals.recEnvironmentDesc)
             call     @CopyMemoryStringFwd
             pop      si
             pop      di
             pop      es
             pop      ds
             mov      ax, WORD PTR  ds:[@lpCurFreePointer][0]
             mov      WORD PTR  ds:[@lpFreeSpaceStart][0], ax
             mov      ax, WORD PTR  ds:[@lpCurFreePointer][2]
             mov      WORD PTR  ds:[@lpFreeSpaceStart][2], ax
             mov      ax, WORD PTR  ds:[@dwCurFreeSize]
             mov      WORD PTR  ds:[@dwFreeSpaceSize], ax
             call     @UpdateVideoIndicators
             clc
@SetNewEnvFuncCallDone:
             pop      cx
             retn
@BadSetNewEnvFuncCall:
             stc
             jmp     @SetNewEnvFuncCallDone
{ End }



{ ****************************************** }
{  Purpose: Add new environment              }
{  Enter:  BX = environment handle           }
{          ES:DI -> environment description  }
{  Return: None                              }
{ Description:                               }
{ ****************************************** }
@ITypist_Add_Environ:
             call    @CheckEnvRange
             jc      @BadEnvIndex
             dec      bx
             shl      bx, 1
             shl      bx, 1
             add      bx, OFFSET @ddEnvironmentTable
             mov      [bx].[0], di
             mov      [bx].[2], es
             jmp     @GoodExitInt2F
{ End }



{ *********************************** }
{  Purpose: Get environment list      }
{  Enter:  None                       }
{  Return: CX = environment count     }
{          ES:BX -> environment list  }
{ Description:                        }
{ *********************************** }
@ITypist_List_Environ:
             mov      bx, ds
             mov      es, bx
             mov      bx, OFFSET  @ddEnvironmentTable
             mov      cx, Globals.aEnviron_Avail_Max
             jmp     @GoodExitInt2F
{ End }



{ ************************************************* }
{  Purpose: Search dictionary for matching entry    }
{  Enter:  CX = abbreviation size                   }
{          ES:BX -> abbreviation string             }
{  Return: CX = dictionary entry size; 0=not found  }
{          ES:BX -> dictionary entry                }
{ Description:                                      }
{ ************************************************* }
@ITypist_Search_Dict_Entry:
             or       cx, cx
             jz      @InvalidParametersForSearch
             call     @IsPointerNIL
             jz      @InvalidParametersForSearch
             call     @ResetSearchUserInput
             call     @ResetRawUserInput
             push     si
             push     cx
             mov      si, OFFSET @dbUserRawInputWord256
@CopyUserEntryToMemBuf:
             mov      al, es:[bx]
             mov      [si], al
             inc      bx
             inc      si
             dec      cx
             jnz     @CopyUserEntryToMemBuf
             mov      WORD PTR  ds:[@pofsUserRawInputWord], si
             pop      cx
             pop      si
             call     @AnalyzeAndReplaceTextPattern
             mov      cx, WORD PTR  ds:[@dwUserReplaceInputWordLength]
             mov      bx, ds
             mov      es, bx
             mov      bx, OFFSET  @dbUserReplaceInputWord256
             jmp     @GoodExitInt2F
@InvalidParametersForSearch:
             mov      al, Globals.aMP_Bad_Search_Parms
             jmp     @BadCall2F_CodeAL
{ End }



{ *********************************** }
{  Purpose: Set new free memory pool  }
{  Enter:  CX = new free space size   }
{          ES:BX -> free space link   }
{  Return:  None                      }
{  Description:                       }
{ *********************************** }
@ITypist_New_Free_Space:
             or       cx, cx
             jz      @InvalidNewFreeSpaceLinkOrSize
             call     @IsPointerNIL
             jz      @InvalidNewFreeSpaceLinkOrSize
             mov      WORD PTR  ds:[@dwFreeSpaceSize], cx
             mov      WORD PTR  ds:[@lpFreeSpaceStart][0], bx
             mov      WORD PTR  ds:[@lpFreeSpaceStart][2], es
             jmp     @GoodExitInt2F
@InvalidNewFreeSpaceLinkOrSize:
             mov      al, Globals.aMP_Bad_New_Free_Space
             jmp     @BadCall2F_CodeAL
{ End }



{ **************************************** }
{  Purpose: Raw buffer pointer             }
{  Enter:  None                            }
{  Return: CX = offset in input buffer     }
{          ES:BX -> raw user input buffer  }
{  Description:                            }
{ **************************************** }
@ITypist_Get_Raw_User_Input:
             mov      cx, WORD PTR  ds:[@pofsUserRawInputWord]
             mov      bx, ds
             mov      es, bx
             mov      bx, OFFSET  @dbUserRawInputWord256
             jmp     @GoodExitInt2F
{ End }



{ ********************************************** }
{  Purpose: Input filteration                    }
{  Enter:  BL = 0  GetFilterState                }
{               1  SetFilterState                }
{             For SetFilterState                 }
{    BH = 0 disable filtering of raw user input  }
{         1 enable filtering of raw user input   }
{  Return: For  GetFilterState                   }
{           BH = current filtering flag          }
{          For SetFilterState                    }
{           None                                 }
{  Description:                                  }
{ ********************************************** }
@ITypist_Filter_Raw_User_Input:
             or       bl, bl
             jz      @GetFilterFlag
             cmp      bh, System.True
             jne     @CheckFilterFlagAgain
             or       WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btFilterRawInput
             jmp     @FilterCallDone
@CheckFilterFlagAgain:
             cmp      bh, System.False
             jne     @BadFilterFlagFound
             and       WORD PTR  ds:[@dwCurUserEnvOptions], (Globals.aFullWord - Globals.btFilterRawInput)
@FilterCallDone:
             jmp     @GoodExitInt2F
@GetFilterFlag:
             mov      bh, System.True
             test     WORD PTR  ds:[@dwCurUserEnvOptions], Globals.btFilterRawInput
             jnz     @GetFilterCallDone
             mov      bh, System.False
@GetFilterCallDone:
             jmp     @FilterCallDone
@BadFilterFlagFound:
             mov      al, Globals.aMP_Bad_Filter_Flag
             jmp     @BadCall2F_CodeAL
{ End }



{ ************************************************************** }
{  Purpose: Search buffer pointer                                }
{  Enter:  None                                                  }
{  Return: DX = flags found to search                            }
{          CX = length of search word                            }
{          SI = # of chars to replace before put our expression  }
{          ES:BX -> user search buffer word                      }
{  Description:                                                  }
{ ************************************************************** }
@ITypist_Get_Search_User_Input:
             mov      dx, WORD PTR  ds:[@dwUserSearchFlags]
             mov      cx, WORD PTR  ds:[@pofsUserSearchInputWordLength]
             mov      si, WORD PTR  ds:[@dwCharsToReplaceBefore]
             mov      bx, ds
             mov      es, bx
             mov      bx, OFFSET  @dbUserSearchInputWord256
             jmp     @GoodExitInt2F
{ End }



{ ********************************************************* }
{  Purpose: Interrupt handlers control                      }
{  Enter:  BL = 0  GetPrevIntVec                            }
{               1  SetPrevIntVec                            }
{             For SetPrevIntVec                             }
{    BH = interrupt vector number (only $8,$9,$15,$16,$2F)  }
{    ES:DX -> address of interrupt routine                  }
{  Return: For  GetPrevIntVec                               }
{             ES:DX -> address of interrupt routine         }
{          For SetPrevIntVec                                }
{           None                                            }
{  Description:                                             }
{ ********************************************************* }
@ITypist_Get_Set_Prev_Int_Vec:
             mov      al, bl
             cmp      bh, Globals.aServerInt
             je      @ServerIntNumFound
             cmp      bh, Globals.aSoftKbdInt
             je      @SoftKbdIntNumFound
             cmp      bh, BYTE PTR  ds:[@dbCurCallBackIntNum]
             je      @MultiplexIntNumFound
             cmp      bh, Globals.aHardTimerInt
             je      @HardTimerIntNumFound
             cmp      bh, Globals.aHardKbdInt
             je      @HardKbdIntNumFound
@BadIntVecNumFound:
             mov      al, Globals.aMP_Bad_Int_Vec_Num
             jmp     @BadCall2F_CodeAL
@ServerIntNumFound:
             mov     bx, Globals.aDWord*0
@GetSetIntVecCall:
             or       al, al
             jz      @GetPrevIntVec
             mov      WORD PTR  ds:[@lpPrevInt15].[0].[bx], dx
             mov      WORD PTR  ds:[@lpPrevInt15].[2].[bx], es
@GetSetIntVecCallDone:
             jmp     @GoodExitInt2F
@GetPrevIntVec:
             mov      dx, WORD PTR  ds:[@lpPrevInt15].[0].[bx]
             mov      es, WORD PTR  ds:[@lpPrevInt15].[2].[bx]
             jmp     @GetSetIntVecCallDone
@SoftKbdIntNumFound:
             mov     bx, Globals.aDWord*1
             jmp     @GetSetIntVecCall
@MultiplexIntNumFound:
             mov     bx, Globals.aDWord*2
             jmp     @GetSetIntVecCall
@HardTimerIntNumFound:
             mov     bx, Globals.aDWord*3
             jmp     @GetSetIntVecCall
@HardKbdIntNumFound:
             mov     bx, Globals.aDWord*4
             jmp     @GetSetIntVecCall
{ End }



{ **************************************** }
{  Purpose:  Replace buffer pointer        }
{  Enter:  None                            }
{  Return: CX = length of replace string   }
{          ES:BX -> replace string buffer  }
{  Description:                            }
{ **************************************** }
@ITypist_Get_Replace_Str:
             mov      cx, WORD PTR  ds:[@dwUserReplaceInputWordLength]
             mov      bx, ds
             mov      es, bx
             mov      bx, OFFSET  @dbUserReplaceInputWord256
             jmp     @GoodExitInt2F
{ End }



{ *************************************** }
{  Purpose: User environment options      }
{  Enter:  BL = 0  GetUserOptions         }
{               1  SetUserOptions         }
{             For SetUserOptions          }
{    CX = user options                    }
{           (see bit definitions above)   }
{  Return: For  GetUserOptions            }
{           CX = current user options     }
{          For SetUserOptions             }
{           None                          }
{  Description:                           }
{ *************************************** }
@ITypist_Get_Set_User_Options:
             or       bl, bl
             jz      @GetUserOptions
             cmp      bl, System.True   {=1?}
             jne     @BadUserOptionsSubFuncFound
             mov      WORD PTR  ds:[@dwCurUserEnvOptions], cx
             jmp     @UserOptionsCallDone
@GetUserOptions:
             mov      cx, WORD PTR  ds:[@dwCurUserEnvOptions]
@UserOptionsCallDone:
             jmp     @GoodExitInt2F
@BadUserOptionsSubFuncFound:
             mov      al, Globals.aMP_Bad_User_Options_Func
             jmp     @BadCall2F_CodeAL
{ End }



{ *********************************************** }
{  Purpose: Current environment record            }
{  Enter:  None                                   }
{  Return: ES:BX -> current environment settings  }
{ Description:                                    }
{ *********************************************** }
@ITypist_Get_Cur_Environ_Parms:
             mov      bx, ds
             mov      es, bx
             mov      bx, OFFSET  @dwCurIdleModeHotkey
             jmp     @GoodExitInt2F
{ End }



{ *************************************** }
{  Purpose: Wipe current environment copy }
{  Enter:  None                           }
{  Return: None                           }
{  Description:                           }
{ *************************************** }
@ITypist_Reset_Cur_Environ:
             push     cx
             push     di
             push     es
             sub      ax, ax
             mov      WORD PTR  ds:[@dwCurEnvironment], ax
             mov      di, OFFSET  @dwCurIdleModeHotkey
             mov      cx, ds
             mov      es, cx
             mov      cx, TYPE  (Globals.recEnvironmentDesc)
             cld
             shr      cx, 1
             jnc     @FastStore1
             stosb
     @FastStore1:
             rep      stosw
             call     @ResetGlobalFreeSpaceLink
             call     @UpdateVideoIndicators
             clc
             pop      es
             pop      di
             pop      cx
             jmp     @GoodExitInt2F
{ End }



{ *********************************** }
{  Purpose: Reset free memory pool    }
{  Enter:  None                       }
{  Return:  None                      }
{  Description:                       }
{ *********************************** }
@ITypist_Reset_Free_Space_Ptr:
             call     @ResetGlobalFreeSpaceLink
             jmp     @GoodExitInt2F
{ End }



{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{               Sets global free space links to NIL          }
{ Enter:                                                     }
{               DS = our data segment                        }
{ Exit:                                                      }
{               None                                         }
{ Used:                                                      }
{               AX, Flags                                    }
{ Description:                                               }
{               Resets the global variables;                 }
{ ********************************************************** }
@ResetGlobalFreeSpaceLink:
             sub      ax, ax   {AX<-0}
             mov      WORD PTR  ds:[@dwFreeSpaceSize], ax
             mov      WORD PTR  ds:[@lpFreeSpaceStart][0], ax
             mov      WORD PTR  ds:[@lpFreeSpaceStart][2], ax
             retn
{ End }



{ ****************************************** }
{  Purpose: Estimate timer control           }
{  Enter:  BL = 0  GetTimerState             }
{               1  SetTimerState             }
{             For SetTimerState              }
{     BH =  0 turn off timer                 }
{           1 turn on timer                  }
{  Return: For  GetTimerState                }
{           BH = current timer flag          }
{           CX = last estimated timer value  }
{          For SetTimerState                 }
{           None                             }
{  Description:                              }
{ ****************************************** }
@ITypist_Get_Set_Estimate_Timer:
             or       bl, bl           {get?}
             jz      @GetStateOfTimer
             cmp      bl, 1            {set?}
             jne     @BadEstimateTimerSubFuncFound
             or       bh, bh              {off?}
             jz      @SetStateOfTimer
             cmp      bh, System.True     {on?}
             jne     @BadEstimateTimerSubFuncFound
@SetStateOfTimer:
             mov      BYTE PTR  ds:[@bTimerFlag], bh
             jmp     @EstimateTimerCallDone
@GetStateOfTimer:
             mov      cx, WORD PTR  ds:[@dwLastTimerValue]
             mov      bh, BYTE PTR  ds:[@bTimerFlag]
@EstimateTimerCallDone:
             jmp     @GoodExitInt2F
@BadEstimateTimerSubFuncFound:
             mov      al, Globals.aMP_Bad_Estimate_Timer_Func
             jmp     @BadCall2F_CodeAL
{ End }



{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{               Reads the current timer value                }
{ Enter:                                                     }
{               DS = our data segment                        }
{ Exit:                                                      }
{               AX = current timer 2 counter                 }
{ Used:                                                      }
{               AX                                           }
{ Description:                                               }
{               Direct access to PIT;                        }
{               (Note: timer counts down)                    }
{ ********************************************************** }
@ReadTimerCounter2:
             pushf
             cli
             in       al, Globals.ioTimerCount2
             mov      ah, al
             in       al, Globals.ioTimerCount2
             popf
             xchg     ah, al
             neg      ax
             retn
{ End }



{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{               Setup the timer 2                            }
{ Enter:                                                     }
{               DS = our data segment                        }
{ Exit:                                                      }
{               None                                         }
{ Used:                                                      }
{               AX, Flags                                    }
{ Description:                                               }
{               Direct access to PIT;                        }
{               writes zero counter;                         }
{               (Note: timer counts down)                    }
{ ********************************************************** }
@SetupTimerCounter2:
             in       al, Globals.aPPI_8255_Port_B    {stop counting}
             and      al, (Globals.aFullByte - (Globals.btSpeakerGateOn+Globals.btSpeakerDataOutOn))
             out      Globals.aPPI_8255_Port_B, al
             mov      al, 0B8h                        {set timer 2 mode}
             out      Globals.ioTimerCtrl, al
             pushf
             cli
             mov      al, 0
             out      Globals.ioTimerCount2, al       {low count}
             out      Globals.ioTimerCount2, al       {high count}
             popf
             retn
{ End }



{ ***************************************************** }
{  Purpose: TSR code information                        }
{  Enter:  ES:BX -> buffer to fill info data            }
{  Return: CX = number of bytes transferred into buffer }
{ Description:                                          }
{ ***************************************************** }
@ITypist_Get_Program_Info:
             push    di
             push    bx
             mov     di, bx
             cld
             mov     al, Globals.aIntMajorVer
             stosb
             mov     al, Globals.aIntMinorVer
             stosb
             mov     al, Globals.aIntLevel
             stosb
             mov     bx, cs
             cmp     bx, Globals.aConvMemSegMax
             jae     @InHighMemory
             sub     bx, Globals.aPSP_Size_In_Paras
  @InHighMemory:
             mov     ax, bx
             stosw
             dec     bx
             push    es
             mov     es, bx
             mov     ax, es:[Globals.aDosMemBlockSize]
             pop     es
             stosw
             mov     al, BYTE PTR  ds:[@dbCurCallBackIntNum]
             stosb
             mov     al, BYTE PTR  ds:[@dbCurMultiplexNum]
             stosb
             mov     al, Globals.aITypist_Func_Num_Max
             stosb
             mov     al, BYTE PTR  ds:[@dbCurStateMode]
             stosb
             mov     al, BYTE PTR  ds:[@dbSearchSubState]
             stosb
             mov     al, BYTE PTR  ds:[@dbLastStatusCode]
             stosb
             mov     al, BYTE PTR  ds:[@dbInitWaitTimerTicks]
             stosb
             mov     al, BYTE PTR  ds:[@bTimerFlag]
             stosb
             mov     ax, WORD PTR  ds:[@dwLastTimerValue]
             stosw
             mov     ax, WORD PTR  ds:[@dwFreeSpaceSize]
             stosw
             mov     ax, WORD PTR  ds:[@lpFreeSpaceStart][0]
             stosw
             mov     ax, WORD PTR  ds:[@lpFreeSpaceStart][2]
             stosw
             pop     bx
             sub     di, bx
             mov     cx, di
             pop     di
             jmp     @GoodExitInt2F
{ End }



{ ************************************ }
{  Purpose: Synchronize with free pool }
{  Enter:  BX = environment            }
{  Return:  None                       }
{  Description:                        }
{ ************************************ }
@ITypist_Copy_Free_Links_To_Env:
             call    @CheckEnvRange
             jc      @BadEnvIndex
             call    @CopyFreeSpaceLink
             jc      @BadCopyPtrFunctionCall
             jmp     @GoodExitInt2F
  @BadCopyPtrFunctionCall:
             jmp     @BadCall2F_CodeAL
{ End }



{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{               Copy free space link to environment          }
{ Enter:                                                     }
{               DS = our data segment                        }
{               BX = environment handle                      }
{ Exit:                                                      }
{               NC = copy done                               }
{               CY = copying failed                          }
{               AL = status code                             }
{ Used:                                                      }
{               AX, BX, Flags                                }
{ Description:                                               }
{               Checks the specified handle for the empty    }
{               pointer in the environment table;            }
{               copy the links to environment record;        }
{               synchronize with current environment;        }
{ ********************************************************** }
@CopyFreeSpaceLink:
             push     es
             dec      bx
             shl      bx, 1
             shl      bx, 1
             add      bx, OFFSET @ddEnvironmentTable
             mov      es, [bx].[2]
             mov      bx, [bx].[0]
             call     @IsPointerNIL
             jz      @EmptyEnvFound
             add      bx, Globals.recEnvironmentDesc.pFreePointer
             mov      ax, WORD PTR  ds:[@lpFreeSpaceStart][0]
             mov      es:[bx], ax
             add      bx, Globals.aWord
             mov      ax, WORD PTR  ds:[@lpFreeSpaceStart][2]
             mov      es:[bx], ax
             add      bx, Globals.aWord
             mov      ax, WORD PTR  ds:[@dwFreeSpaceSize]
             mov      es:[bx], ax
             call     @SyncCurEnvFreeSpaceLink
             clc
  @FreeLinksCallDone:
             pop      es
             retn
  @EmptyEnvFound:
             mov      al, Globals.aMP_Empty_Env
             stc
             jmp     @FreeLinksCallDone
{ End }



{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{               Synchronize free space link state            }
{ Enter:                                                     }
{               DS = our data segment                        }
{ Exit:                                                      }
{               None                                         }
{ Used:                                                      }
{               AX                                           }
{ Description:                                               }
{               Updates the global variables;                }
{ ********************************************************** }
@SyncCurEnvFreeSpaceLink:
             mov      ax, WORD PTR  ds:[@lpFreeSpaceStart][0]
             mov      WORD PTR  ds:[@lpCurFreePointer][0], ax
             mov      ax, WORD PTR  ds:[@lpFreeSpaceStart][2]
             mov      WORD PTR  ds:[@lpCurFreePointer][2], ax
             mov      ax, WORD PTR  ds:[@dwFreeSpaceSize]
             mov      WORD PTR  ds:[@dwCurFreeSize], ax
             retn
{ End }



{ ****************************************** }
{  Purpose: Statistics records               }
{  Enter:  BL = 0  GetStatBlock              }
{               1  SetStatBlock              }
{             For SetStatBlock               }
{     ES:DI -> statistics record block       }
{  Return: For  GetStatBlock                 }
{     ES:DI -> statistics record block       }
{          For SetStatBlock                  }
{           None                             }
{  Description:                              }
{ ****************************************** }
@ITypist_Get_Set_Stat_Block:
             or       bl, bl           {get?}
             jz      @GetStatBlock
             cmp      bl, 1            {set?}
             jne     @BadStatBlockSubFunction
{$IFDEF   StaVer}
             push     bx
             mov      bx, di
             call     @IsPointerNIL
             mov      al, Globals.aMP_Bad_Stat_Block_Pointer
             jz      @BadStatBlockCall
             pop      bx
             push     si
             push     cx
             push     ds
             mov      cx, es
             mov      si, ds
             mov      ds, cx
             mov      es, si
             mov      si, OFFSET  @bRunStatTiming
             mov      cx, TYPE (Globals.recStatTimingBlock)
             call     @CopyMemoryStringFwd
             pop      ds
             pop      cx
             pop      si
             jmp     @StatBlockCallDone
{$ELSE}
             jmp     @BadStatBlockCall
{$ENDIF} {StaVer}
@GetStatBlock:
{$IFDEF   StaVer}
             mov      di, cs
             mov      es, di
             mov      di, OFFSET @bRunStatTiming
{$ELSE}
             sub      di, di            {NIL pointer}
             mov      es, di
{$ENDIF} {StaVer}
@StatBlockCallDone:
             jmp     @GoodExitInt2F
@BadStatBlockSubFunction:
             mov      al, Globals.aMP_Bad_Stat_Block_Func
@BadStatBlockCall:
             jmp     @BadCall2F_CodeAL
{ End }



{ return from interrupt }
@GoodExitInt2F:
             mov      al, Globals.aMP_Successful_Done
@ExitInt2F:
             pop      ds
             clc
             retf     2
{ End }
{ ********************* INT $2F (or other) ********************* }


{ Subroutine }
{ ********************************************************** }
{ Purpose:                                                   }
{               None
{ Enter:                                                     }
{               DS = our data segment                        }
{ Exit:                                                      }
{               None                                         }
{ Used:                                                      }
{               None                                         }
{ Description:                                               }
{               None                                         }
{ ********************************************************** }
{ End }


{* Simulate assembler directive 'EVEN'. *}
             nop
            {nop}

END; {asm-end}
{ _KeyboardHandler }



{*NODES.INC*}
PROCEDURE
          _fndwGetNodeLinkOffsetGeneric; assembler;
{* Purpose:                                            *}
{*    Get a requsted link offset from the given node.  *}
{* Enter:  ES:BX -> node                               *}
{*         AX    -> bitmask for used fields            *}
{* Exit:   AX = offset from node beginning             *}
{*               (0 = no this field)                   *}
{* Used also: None                                     *}
{* Description:                                        *}
{* ATTENTION: Algorithm is based on assumption         *}
{*            that first word in a node will be        *}
{*            skipped!!!                               *}
ASM
             push     bx
             push     cx
             push     dx
             mov      dx, es:[bx][Globals.recDictEntryHeaderDesc.dwNodeOptions]
             sub      cx, cx   {CX<-0}
             and      ax, Globals.btNodeLinkOffsetFABAFEBEASES
             test     dx, ax
             jz      @GetLinkGenericDone
             mov      bx, Globals.btNodeLinkOffsetPresentFA
             test     dx, bx
             jz      @SkipNodeFA
             add      cx, Globals.aWord
@SkipNodeFA:
             shl      bx, 1
             cmp      bx, ax
             ja      @GetLinkGenericDone
             test     dx, Globals.btNodeLinkOffsetPresentBA
             jz      @SkipNodeBA
             add      cx, Globals.aWord
@SkipNodeBA:
             shl      bx, 1
             cmp      bx, ax
             ja      @GetLinkGenericDone
             test     dx, Globals.btNodeLinkOffsetPresentFE
             jz      @SkipNodeFE
             add      cx, Globals.aWord
@SkipNodeFE:
             shl      bx, 1
             cmp      bx, ax
             ja      @GetLinkGenericDone
             test     dx, Globals.btNodeLinkOffsetPresentBE
             jz      @SkipNodeBE
             add      cx, Globals.aWord
@SkipNodeBE:
             shl      bx, 1
             cmp      bx, ax
             ja      @GetLinkGenericDone
             test     dx, Globals.btNodeLinkOffsetPresentAS
             jz      @SkipNodeAS
             add      cx, Globals.aWord
@SkipNodeAS:
             shl      bx, 1
             cmp      bx, ax
             ja      @GetLinkGenericDone
             test     dx, Globals.btNodeLinkOffsetPresentES
             jz      @SkipNodeES
             add      cx, Globals.aWord
@SkipNodeES:
@GetLinkGenericDone:
             mov      ax, cx
             pop      dx
             pop      cx
             pop      bx
END; {asm-end}
{ _fndwGetNodeLinkOffsetGeneric }



PROCEDURE
          _fndwGetNodeSizeOfAllLinks; assembler;
{* Get a size of all the link offsets from the given node.  *}
{* Enter:  ES:BX -> node                                    *}
{* Exit:   AX = total size of all links in node             *}
{* Used also: None                                          *}
{* Description:                                             *}
ASM
             mov      ax, (Globals.btNodeLinkOffsetFABAFEBEASES)
             call     _fndwGetNodeLinkOffsetGeneric
             add      ax, Globals.aWord             { last field size }
END; {asm-end}
{ _fndwGetNodeSizeOfAllLinks }



PROCEDURE
         _fndwGetNodeLinkOffsetForFA; assembler;
{* Get a FA link offset from the given node.  *}
{* Enter:  ES:BX -> node                      *}
{* Exit:   BX = offset from table             *}
{* Used also: None                            *}
{* Description:                               *}
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentFA)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetFA
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetFA:
             mov      bx, ax
             pop      ax
END; {asm-end}
{ _fndwGetNodeLinkOffsetForFA }



PROCEDURE
         _StoreNodeLinkOffsetForFA; assembler;
{* Store a new FA link offset for the given node.  *}
{* Enter:  ES:BX -> node                           *}
{*         AX = new link offset                    *}
{* Exit:   None                                    *}
{* Used also: None                                 *}
{* Description:                                    *}
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentFA)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetFA
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetFA:
             pop      cx
             pop      ax
END; {asm-end}
{ _StoreNodeLinkOffsetForFA }



PROCEDURE
         _fndwGetNodeLinkOffsetForBA; assembler;
{* Get a BA link offset from the given node.  *}
{* Enter:  ES:BX -> node                      *}
{* Exit:   BX = offset from table             *}
{* Used also: None                            *}
{* Description:                               *}
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentBA)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetBA
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetBA:
             mov      bx, ax
             pop      ax
END; {asm-end}
{ _fndwGetNodeLinkOffsetForBA }



PROCEDURE
         _StoreNodeLinkOffsetForBA; assembler;
{* Store a new BA link offset for the given node.  *}
{* Enter:  ES:BX -> node                           *}
{*         AX = new link offset                    *}
{* Exit:   None                                    *}
{* Used also: None                                 *}
{* Description:                                    *}
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentBA)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetBA
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetBA:
             pop      cx
             pop      ax
END; {asm-end}
{ _StoreNodeLinkOffsetForBA }



PROCEDURE
         _fndwGetNodeLinkOffsetForFE; assembler;
{* Get a FE link offset from the given node.  *}
{* Enter:  ES:BX -> node                      *}
{* Exit:   BX = offset from table             *}
{* Used also: None                            *}
{* Description:                               *}
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentFE)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetFE
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetFE:
             mov      bx, ax
             pop      ax
END; {asm-end}
{ _fndwGetNodeLinkOffsetForFE }



PROCEDURE
         _StoreNodeLinkOffsetForFE; assembler;
{* Store a new FE link offset for the given node.  *}
{* Enter:  ES:BX -> node                           *}
{*         AX = new link offset                    *}
{* Exit:   None                                    *}
{* Used also: None                                 *}
{* Description:                                    *}
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentFE)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetFE
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetFE:
             pop      cx
             pop      ax
END; {asm-end}
{ _StoreNodeLinkOffsetForFE }



PROCEDURE
         _fndwGetNodeLinkOffsetForBE; assembler;
{* Get a BE link offset from the given node.  *}
{* Enter:  ES:BX -> node                      *}
{* Exit:   BX = offset from table             *}
{* Used also: None                            *}
{* Description:                               *}
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentBE)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetBE
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetBE:
             mov      bx, ax
             pop      ax
END; {asm-end}
{ _fndwGetNodeLinkOffsetForBE }



PROCEDURE
         _StoreNodeLinkOffsetForBE; assembler;
{* Store a new BE link offset for the given node.  *}
{* Enter:  ES:BX -> node                           *}
{*         AX = new link offset                    *}
{* Exit:   None                                    *}
{* Used also: None                                 *}
{* Description:                                    *}
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentBE)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetBE
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetBE:
             pop      cx
             pop      ax
END; {asm-end}
{ _StoreNodeLinkOffsetForBE }



PROCEDURE
         _fndwGetNodeLinkOffsetForAS; assembler;
{* Get a AS link offset from the given node.  *}
{* Enter:  ES:BX -> node                      *}
{* Exit:   BX = offset from table             *}
{* Used also: None                            *}
{* Description:                               *}
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentAS)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetAS
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetAS:
             mov      bx, ax
             pop      ax
END; {asm-end}
{ _fndwGetNodeLinkOffsetForAS }



PROCEDURE
         _StoreNodeLinkOffsetForAS; assembler;
{* Store a new AS link offset for the given node.  *}
{* Enter:  ES:BX -> node                           *}
{*         AX = new link offset                    *}
{* Exit:   None                                    *}
{* Used also: None                                 *}
{* Description:                                    *}
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentAS)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetAS
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetAS:
             pop      cx
             pop      ax
END; {asm-end}
{ _StoreNodeLinkOffsetForAS }



PROCEDURE
         _fndwGetNodeLinkOffsetForES; assembler;
{* Get a ES link offset from the given node.  *}
{* Enter:  ES:BX -> node                      *}
{* Exit:   BX = offset from table             *}
{* Used also: None                            *}
{* Description:                               *}
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentES)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetES
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetES:
             mov      bx, ax
             pop      ax
END; {asm-end}
{ _fndwGetNodeLinkOffsetForES }



PROCEDURE
         _StoreNodeLinkOffsetForES; assembler;
{* Store a new ES link offset for the given node.  *}
{* Enter:  ES:BX -> node                           *}
{*         AX = new link offset                    *}
{* Exit:   None                                    *}
{* Used also: None                                 *}
{* Description:                                    *}
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentES)
             call     _fndwGetNodeLinkOffsetGeneric
             or       ax, ax
             jz      @NoPresentLinkOffsetES
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetES:
             pop      cx
             pop      ax
END; {asm-end}
{ _StoreNodeLinkOffsetForES }



PROCEDURE
         _fndwGetNodeAccessCount; assembler;
{* Get the access count from the given node.  *}
{* Enter:  ES:BX -> node                      *}
{* Exit:   AX = access count for node         *}
{* Used also: None                            *}
{* Description:                               *}
ASM
             call     _fndwGetNodeSizeOfAllLinks
             push     di
             mov      di, bx
             add      di, ax
             mov      ax, es:[di]
             pop      di
END; {asm-end}
{ _fndwGetNodeAccessCount }



PROCEDURE
         _StoreNodeAccessCount; assembler;
{* Store a new access count for the given node.  *}
{* Enter:  ES:BX -> node                         *}
{*         AX = new access count                 *}
{* Exit:   None                                  *}
{* Used also: None                               *}
{* Description:                                  *}
ASM
             push     ax
             push     cx
             push     di
             mov      cx, ax
             call     _fndwGetNodeSizeOfAllLinks
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
             pop      cx
             pop      ax
END; {asm-end}
{ _StoreNodeAccessCount }



PROCEDURE
         _fndwGetNodeHitCount; assembler;
{* Get the hit count from the given node.  *}
{* Enter:  ES:BX -> node                   *}
{* Exit:   AX = hit count for node         *}
{* Used also: None                         *}
{* Description:                            *}
ASM
             call     _fndwGetNodeSizeOfAllLinks
             add      ax,(Globals.recDictEntryHeaderDesc.dwNodeHitCount)-(Globals.recDictEntryHeaderDesc.dwNodeAccessCount)
             push     di
             mov      di, bx
             add      di, ax
             mov      ax, es:[di]
             pop      di
END; {asm-end}
{ _fndwGetNodeHitCount }



PROCEDURE
         _StoreNodeHitCount; assembler;
{* Store a new hit count for the given node.  *}
{* Enter:  ES:BX -> node                      *}
{*         AX = new hit count                 *}
{* Exit:   None                               *}
{* Used also: None                            *}
{* Description:                               *}
ASM
             push     ax
             push     cx
             push     di
             mov      cx, ax
             call     _fndwGetNodeSizeOfAllLinks
             add      ax,(Globals.recDictEntryHeaderDesc.dwNodeHitCount)-(Globals.recDictEntryHeaderDesc.dwNodeAccessCount)
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
             pop      cx
             pop      ax
END; {asm-end}
{ _StoreNodeHitCount }



PROCEDURE
         _fndwGetNodeOptions; assembler;
{* Get the option flags from the given node.  *}
{* Enter:  ES:BX -> node                      *}
{* Exit:   AX = options for node              *}
{* Used also: None                            *}
{* Description:                               *}
ASM
             mov      ax, es:[bx][Globals.recDictEntryHeaderDesc.dwNodeOptions]
END; {asm-end}
{ _fndwGetNodeOptions }



PROCEDURE
         _StoreNodeOptions; assembler;
{* Store a new options for the given node.  *}
{* Enter:  ES:BX -> node                    *}
{*         AX = new options                 *}
{* Exit:   None                             *}
{* Used also: None                          *}
{* Description:                             *}
ASM
             mov      es:[bx][Globals.recDictEntryHeaderDesc.dwNodeOptions], ax
END; {asm-end}
{ _StoreNodeOptions }



PROCEDURE
         _fndbGetNodeAbbreviationSize; assembler;
{* Get the abbreviation size from the given node.  *}
{* Enter:  ES:BX -> node                           *}
{* Exit:   AL = size in bytes                      *}
{* Used also: None                                 *}
{* Description:                                    *}
ASM
             call     _fndwGetNodeSizeOfAllLinks
             add      ax,(recDictEntryHeaderDesc.dbHeaderDictAbbreviationSize)-(recDictEntryHeaderDesc.dwNodeAccessCount)
             push     di
             mov      di, bx
             add      di, ax
             mov      al, es:[di]
             pop      di
END; {asm-end}
{ _fndbGetNodeAbbreviationSize }



PROCEDURE
         _StoreNodeAbbreviationSize; assembler;
{* Store a new abbreviation size for the given node.  *}
{* Enter:  ES:BX -> node                              *}
{*         AL = new size                              *}
{* Exit:   None                                       *}
{* Used also: None                                    *}
{* Description:                                       *}
ASM
             push     ax
             push     cx
             push     di
             mov      cx, ax
             call     _fndwGetNodeSizeOfAllLinks
             add      ax,(recDictEntryHeaderDesc.dbHeaderDictAbbreviationSize)-(recDictEntryHeaderDesc.dwNodeAccessCount)
             mov      di, bx
             add      di, ax
             mov      es:[di], cl
             pop      di
             pop      cx
             pop      ax
END; {asm-end}
{ _StoreNodeAbbreviationSize }



PROCEDURE
         _fndbGetNodeExpressionSize; assembler;
{* Get the expression size from the given node.  *}
{* Enter:  ES:BX -> node                         *}
{* Exit:   AL = size in bytes                    *}
{* Used also: None                               *}
{* Description:                                  *}
ASM
             call     _fndwGetNodeSizeOfAllLinks
             add      ax,(Globals.recDictEntryHeaderDesc.dbHeaderDictEntrySize)-(recDictEntryHeaderDesc.dwNodeAccessCount)
             push     di
             mov      di, bx
             add      di, ax
             mov      al, es:[di]
             pop      di
END; {asm-end}
{ _fndbGetNodeExpressionSize }



PROCEDURE
         _StoreNodeExpressionSize; assembler;
{* Store a new expression size for the given node.  *}
{* Enter:  ES:BX -> node                            *}
{*         AL = new size                            *}
{* Exit:   None                                     *}
{* Used also: None                                  *}
{* Description:                                     *}
ASM
             push     ax
             push     cx
             push     di
             mov      cx, ax
             call     _fndwGetNodeSizeOfAllLinks
             add      ax,(Globals.recDictEntryHeaderDesc.dbHeaderDictEntrySize)-(recDictEntryHeaderDesc.dwNodeAccessCount)
             mov      di, bx
             add      di, ax
             mov      es:[di], cl
             pop      di
             pop      cx
             pop      ax
END; {asm-end}
{ _StoreNodeExpressionSize }



PROCEDURE
         _fndwGetNodeAbbreviationOfs; assembler;
{* Get the abbreviation offset for the given node.  *}
{* Enter:  ES:BX -> node                            *}
{* Exit:   AX = offset of abbreviation string       *}
{* Used also: None                                  *}
{* Description:                                     *}
ASM
             call     _fndwGetNodeSizeOfAllLinks
             add      ax,(recDictEntryHeaderDesc.dbHeaderDictEntrySize)-(recDictEntryHeaderDesc.dwNodeAccessCount)+aByte
             add      ax, bx
END; {asm-end}
{ _fndwGetNodeAbbreviationOfs }



PROCEDURE
         _fndwGetNodeExpressionOfs; assembler;
{* Get the expression offset for the given node.  *}
{* Enter:  ES:BX -> node                          *}
{* Exit:   AX = offset of expression string       *}
{* Used also: None                                *}
{* Description:                                   *}
ASM
             push     cx
             call     _fndwGetNodeAbbreviationOfs
             mov      cx, ax
             sub      ax, ax
             call     _fndbGetNodeAbbreviationSize
             add      ax, cx
             pop      cx
END; {asm-end}
{ _fndwGetNodeExpressionOfs }



PROCEDURE
         _fndwGetNodeSizeTotal; assembler;
{* Get the node size for the given node.  *}
{* Enter:  ES:BX -> node                  *}
{* Exit:   AX = size of node              *}
{* Used also: None                        *}
{* Description:                           *}
ASM
             push     cx
             call     _fndwGetNodeSizeOfAllLinks
             add      ax, (recDictEntryHeaderDesc.dbHeaderDictEntrySize)-(recDictEntryHeaderDesc.dwNodeAccessCount)+aByte
             mov      cx, ax
             sub      ax, ax
             call     _fndbGetNodeAbbreviationSize
             add      cx, ax
             sub      ax, ax
             call     _fndbGetNodeExpressionSize
             add      ax, cx
             test     es:[bx][Globals.recDictEntryHeaderDesc.dwNodeOptions], Globals.btNodeHasPaddingZero
             jz      @NoPaddingZero
             inc      ax
@NoPaddingZero:
             pop      cx
END; {asm-end}
{ _fndwGetNodeSizeTotal }



PROCEDURE
         _fndwGetTableOffsetByIndex; assembler;
{* Get a link offset from the static head table. *}
{* Enter:  AL    =  character                    *}
{*         ES:BX -> index table                  *}
{*         DX    =  user environment options     *}
{* Exit:   BX = offset from table                *}
{*         ES = segment of dictionary            *}
{* Used also:  AX                                *}
{* Description:                                  *}
ASM
             push     di
             test     dx, Globals.btUseTableCompression
             jnz     @CompressedStaticHeadTable
             sub      ah, ah
             sub      di, di
             mov      di, ax
             shl      di, 1
             mov      bx, es:[bx].[di]
             pop      di
             retn
{ Description:                                                              }
{ The following compression scheme is in use:                               }
{ 32 bytes = bit-map of non-zero offset for corresponding ASCII characters  }
{ 16 bytes = bits counters for each previous byte                           }
{            bit #0-3  bit count for odd  byte                              }
{            bit #4-7  bit count for even byte                              }
{ variable = link word offsets to corresponding nodes                       }
{ Algorihm:  (S1)  byte offset = char DIV 8                                 }
{            (S2)  bit  offset = char MOD 8                                 }
{            (S3)  test presence bit in bitmap set                          }
{            (S4)  if zero bit found then exit                              }
{            (S5)  byte offset for bit-count array = char DIV 16            }
{            (S6)  bit offset for bit-count array = char MOD 16             }
{                  odd  byte = char MOD 16 <= 7                             }
{                  even byte = char MOD 16 > 7                              }
{            (S7)  link offset = word * calculated presence bits count      }
{                                before our bit                             }
@CompressedStaticHeadTable:
             push     cx
             push     dx
             sub      dx, dx
             mov      ch, al
             shr      al, 1
             shr      al, 1
             shr      al, 1
             mov      dl, al
             mov      cl, ch
             and      cl, $07
             mov      ah, $1
             shl      ah, cl
             mov      di, dx
             mov      al, es:[bx].[di]
             mov      dh, al
             test     al, ah
             jnz     @BitEntryFound
             sub     bx, bx
             jmp    @CompressedLinkOfsFound
@BitEntryFound:
             mov      al, dl
             shr      al, 1
             mov      dl, al
             sub      ax, ax
             mov      di, Globals.recCompressedHeadLinkTable.dbCharBitCounters16
             push     dx
@CalcBitSummaForCharOffsets:
             or       dl, dl
             jz      @CalcBitSummaInLastByte
             mov      dh, es:[bx].[di]
             and      dh, Globals.aFullLowNibble
             add      al, dh
             adc      ah, 0
             mov      dh, es:[bx].[di]
             shr      dh, 1
             shr      dh, 1
             shr      dh, 1
             shr      dh, 1
             add      al, dh
             adc      ah, 0
             inc      di
             dec      dl
             jmp     @CalcBitSummaForCharOffsets
@CalcBitSummaInLastByte:
             pop      dx
             and      ch, Globals.aFullLowNibble
             cmp      ch, $7
             jbe     @OddNibble
             mov      dl, es:[bx].[di]
             and      dl, Globals.aFullLowNibble
             add      al, dl
             adc      ah, 0
@OddNibble:
@TestNextBit:
             or       cl, cl
             jz      @AllBitSummaFound
             shr      dh, 1
             adc      ax, 0
             dec      cl
             jmp     @TestNextBit
@AllBitSummaFound:
             shl      ax, 1
             add      ax, (Globals.recCompressedHeadLinkTable.dbCharBitCounters16) + Globals.aBitCountsForSet256
             mov      di, ax
             mov      bx, es:[bx].[di]
@CompressedLinkOfsFound:
             pop      dx
             pop      cx
             pop      di
END; {asm-end}
{ _fndwGetTableOffsetByIndex }



PROCEDURE
         _PutFirstTableOffsetByIndex; assembler;
{* Put a link offset into the static head table. *}
{* Enter:  AL    =  character                    *}
{*         ES:BX -> index table                  *}
{*         DX    =  user environment options     *}
{*         CX    =  new offset                   *}
{* Exit:   None                                  *}
{* Used also: AH                                 *}
{* Description:                                  *}
ASM
             push     di
             test     dx, Globals.btUseTableCompression
             jnz     @CompressedStaticHeadTable
             sub      ah, ah
             sub      di, di
             mov      di, ax
             shl      di, 1
             mov      es:[bx].[di], cx
             pop      di
             retn
{ Description:                                                              }
{ The following compression scheme is in use:                               }
{ 32 bytes = bit-map of non-zero offset for corresponding ASCII characters  }
{ 16 bytes = bits counters for each previous byte                           }
{            bit #0-3  bit count for odd  byte                              }
{            bit #4-7  bit count for even byte                              }
{ variable = link word offsets to corresponding nodes                       }
{ Algorihm:  (S1)  byte offset = char DIV 8                                 }
{            (S2)  bit  offset = char MOD 8                                 }
{            (S3)  test presence bit in bitmap set                          }
{            (S4)  if zero bit found then exit                              }
{            (S5)  byte offset for bit-count array = char DIV 16            }
{            (S6)  bit offset for bit-count array = char MOD 16             }
{                  odd  byte = char MOD 16 <= 7                             }
{                  even byte = char MOD 16 > 7                              }
{            (S7)  link offset = word * calculated presence bits count      }
{                                before our bit                             }
@CompressedStaticHeadTable:
             push     cx
             push     dx
             sub      dx, dx
             mov      ch, al
             shr      al, 1
             shr      al, 1
             shr      al, 1
             mov      dl, al
             mov      cl, ch
             and      cl, $07
             mov      ah, $1
             shl      ah, cl
             mov      di, dx
             mov      al, es:[bx].[di]
             mov      dh, al
             test     al, ah
             jnz     @BitEntryFound
             pop      dx
             pop      cx
             pop      di
             retn
@BitEntryFound:
             mov      al, dl
             shr      al, 1
             mov      dl, al
             sub      ax, ax
             mov      di, Globals.recCompressedHeadLinkTable.dbCharBitCounters16
             push     dx
@CalcBitSummaForCharOffsets:
             or       dl, dl
             jz      @CalcBitSummaInLastByte
             mov      dh, es:[bx].[di]
             and      dh, Globals.aFullLowNibble
             add      al, dh
             adc      ah, 0
             mov      dh, es:[bx].[di]
             shr      dh, 1
             shr      dh, 1
             shr      dh, 1
             shr      dh, 1
             add      al, dh
             adc      ah, 0
             inc      di
             dec      dl
             jmp     @CalcBitSummaForCharOffsets
@CalcBitSummaInLastByte:
             pop      dx
             and      ch, Globals.aFullLowNibble
             cmp      ch, $7
             jbe     @OddNibble
             mov      dl, es:[bx].[di]
             and      dl, Globals.aFullLowNibble
             add      al, dl
             adc      ah, 0
@OddNibble:
@TestNextBit:
             or       cl, cl
             jz      @AllBitSummaFound
             shr      dh, 1
             adc      ax, 0
             dec      cl
             jmp     @TestNextBit
@AllBitSummaFound:
             shl      ax, 1
             add      ax, (Globals.recCompressedHeadLinkTable.dbCharBitCounters16) + Globals.aBitCountsForSet256
             mov      di, ax
             pop      dx
             pop      cx
             mov      es:[bx].[di], cx
             pop      di
END; {asm-end}
{ _PutFirstTableOffsetByIndex }



{*CALLBACK.INC*}

PROCEDURE
         _CallBackInterface; assembler;
{*
Descriptiom.
      Executes a requested service.
*}
ASM
         int     Globals.aMultiplexInt
END; {asm-end}
{ _CallBackInterface }


{*MEMSPACE.INC*}

PROCEDURE
         _FreeDataSpace; assembler;
{*
Descriptiom.
    Free space for dictionary/debugging/statistics/other data.
*}
ASM
{$IFDEF   Add8KB}
  { Number of entries  8192 / 4; each line contains 32 DWords }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
{$ENDIF} {Add8KB}
{$IFDEF   Add16KB}
  { Number of entries  8192 / 4; each line contains 32 DWords }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  { Number of entries  8192 / 4; each line contains 32 DWords }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
{$ENDIF} {Add16KB}
END; {asm-end}
{ _FreeDataSpace }



PROCEDURE
         _DummyProc; assembler;
{*
Description.
     This procedure is used for reference purposes.
*}
ASM
    DB  'DummyProc',0
END; {asm-end}
{ _DummyProc }


{*NODES_A.INC*}
PROCEDURE   _fndwGetNodeLinkOffsetGenericAlt; assembler;
{* Purpose:                                            *}
{*    Get a requsted link offset from the given node.  *}
{* Enter:  ES:BX -> node                         *}
{*         AX    -> bitmask for used fields      *}
{* Exit:   AX = offset from node beginning       *}
{*               (0 = no this field)             *}
{* Used also: None                               *}
{* Description:  }
{* ATTENTION: Algorithm is based on assumption   *}
{*            that first word in a node will be  *}
{*            skipped!!!                         *}
ASM
             push     bx
             push     cx
             push     dx
             mov      dx, es:[bx][Globals.recDictEntryHeaderDesc.dwNodeOptions]
             sub      cx, cx   {CX<-0}
             and      ax, Globals.btNodeLinkOffsetFABAFEBEASES
             test     dx, ax
             jz      @GetLinkGenericDone
             mov      bx, Globals.btNodeLinkOffsetPresentFA
             test     dx, bx
             jz      @SkipNodeFA
             add      cx, Globals.aWord
@SkipNodeFA:
             shl      bx, 1
             cmp      bx, ax
             ja      @GetLinkGenericDone
             test     dx, Globals.btNodeLinkOffsetPresentBA
             jz      @SkipNodeBA
             add      cx, Globals.aWord
@SkipNodeBA:
             shl      bx, 1
             cmp      bx, ax
             ja      @GetLinkGenericDone
             test     dx, Globals.btNodeLinkOffsetPresentFE
             jz      @SkipNodeFE
             add      cx, Globals.aWord
@SkipNodeFE:
             shl      bx, 1
             cmp      bx, ax
             ja      @GetLinkGenericDone
             test     dx, Globals.btNodeLinkOffsetPresentBE
             jz      @SkipNodeBE
             add      cx, Globals.aWord
@SkipNodeBE:
             shl      bx, 1
             cmp      bx, ax
             ja      @GetLinkGenericDone
             test     dx, Globals.btNodeLinkOffsetPresentAS
             jz      @SkipNodeAS
             add      cx, Globals.aWord
@SkipNodeAS:
             shl      bx, 1
             cmp      bx, ax
             ja      @GetLinkGenericDone
             test     dx, Globals.btNodeLinkOffsetPresentES
             jz      @SkipNodeES
             add      cx, Globals.aWord
@SkipNodeES:
@GetLinkGenericDone:
             mov      ax, cx
             pop      dx
             pop      cx
             pop      bx
END;  { _fndwGetNodeLinkOffsetGenericAlt }



PROCEDURE   _fndwGetNodeSizeOfAllLinksAlt; assembler;
{* Get a size of all the link offsets from the given node.  *}
{* Enter:  ES:BX -> node                         *}
{* Exit:   AX = total size of all links in node  *}
{* Used also: None                               *}
{ Description:  }
ASM
             mov      ax, (Globals.btNodeLinkOffsetFABAFEBEASES)
             call     _fndwGetNodeLinkOffsetGenericAlt
             add      ax, Globals.aWord             { last field size }
END;  { _fndwGetNodeSizeOfAllLinksAlt }



PROCEDURE   _fndwGetNodeLinkOffsetForFAAlt; assembler;
{* Get a FA link offset from the given node.  *}
{* Enter:  ES:BX -> node           *}
{* Exit:   BX = offset from table  *}
{* Used also: None                 *}
{ Description:  }
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentFA)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetFA
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetFA:
             mov      bx, ax
             pop      ax
END;  { _fndwGetNodeLinkOffsetForFAAlt }


PROCEDURE   _StoreNodeLinkOffsetForFAAlt; assembler;
{* Store a new FA link offset for the given node.  *}
{* Enter:  ES:BX -> node         *}
{*         AX = new link offset  *}
{* Exit:   None                  *}
{* Used also: None               *}
{ Description:  }
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentFA)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetFA
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetFA:
             pop      cx
             pop      ax
END;  { _StoreNodeLinkOffsetForFAAlt }


PROCEDURE   _fndwGetNodeLinkOffsetForBAAlt; assembler;
{* Get a BA link offset from the given node.  *}
{* Enter:  ES:BX -> node           *}
{* Exit:   BX = offset from table  *}
{* Used also: None                 *}
{ Description:  }
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentBA)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetBA
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetBA:
             mov      bx, ax
             pop      ax
END;  { _fndwGetNodeLinkOffsetForBAAlt }


PROCEDURE   _StoreNodeLinkOffsetForBAAlt; assembler;
{* Store a new BA link offset for the given node.  *}
{* Enter:  ES:BX -> node         *}
{*         AX = new link offset  *}
{* Exit:   None                  *}
{* Used also: None               *}
{ Description:  }
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentBA)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetBA
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetBA:
             pop      cx
             pop      ax
END;  { _StoreNodeLinkOffsetForBAAlt }


PROCEDURE   _fndwGetNodeLinkOffsetForFEAlt; assembler;
{* Get a FE link offset from the given node.  *}
{* Enter:  ES:BX -> node           *}
{* Exit:   BX = offset from table  *}
{* Used also: None                 *}
{ Description:  }
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentFE)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetFE
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetFE:
             mov      bx, ax
             pop      ax
END;  { _fndwGetNodeLinkOffsetForFEAlt }


PROCEDURE   _StoreNodeLinkOffsetForFEAlt; assembler;
{* Store a new FE link offset for the given node.  *}
{* Enter:  ES:BX -> node         *}
{*         AX = new link offset  *}
{* Exit:   None                  *}
{* Used also: None                     *}
{ Description:  }
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentFE)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetFE
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetFE:
             pop      cx
             pop      ax
END;  { _StoreNodeLinkOffsetForFEAlt }


PROCEDURE   _fndwGetNodeLinkOffsetForBEAlt; assembler;
{* Get a BE link offset from the given node.  *}
{* Enter:  ES:BX -> node           *}
{* Exit:   BX = offset from table  *}
{* Used also: None                 *}
{ Description:  }
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentBE)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetBE
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetBE:
             mov      bx, ax
             pop      ax
END;  { _fndwGetNodeLinkOffsetForBEAlt }


PROCEDURE   _StoreNodeLinkOffsetForBEAlt; assembler;
{* Store a new BE link offset for the given node.  *}
{* Enter:  ES:BX -> node         *}
{*         AX = new link offset  *}
{* Exit:   None                  *}
{* Used also: None               *}
{ Description:  }
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentBE)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetBE
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetBE:
             pop      cx
             pop      ax
END;  { _StoreNodeLinkOffsetForBEAlt }


PROCEDURE    _fndwGetNodeLinkOffsetForASAlt; assembler;
{* Get a AS link offset from the given node.  *}
{* Enter:  ES:BX -> node           *}
{* Exit:   BX = offset from table  *}
{* Used also: None                 *}
{ Description:  }
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentAS)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetAS
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetAS:
             mov      bx, ax
             pop      ax
END;  { _fndwGetNodeLinkOffsetForASAlt }


PROCEDURE    _StoreNodeLinkOffsetForASAlt; assembler;
{* Store a new AS link offset for the given node.  *}
{* Enter:  ES:BX -> node         *}
{*         AX = new link offset  *}
{* Exit:   None                  *}
{* Used also: None               *}
{ Description:  }
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentAS)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetAS
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetAS:
             pop      cx
             pop      ax
END;  { _StoreNodeLinkOffsetForASAlt }


PROCEDURE    _fndwGetNodeLinkOffsetForESAlt; assembler;
{* Get a AS link offset from the given node.  *}
{* Enter:  ES:BX -> node           *}
{* Exit:   BX = offset from table  *}
{* Used also: None                 *}
{ Description:  }
ASM
             push     ax
             mov      ax, (Globals.btNodeLinkOffsetPresentES)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetES
             add      bx, ax
             mov      bx, es:[bx]
             pop      ax
             retn
@NoPresentLinkOffsetES:
             mov      bx, ax
             pop      ax
END;  { _fndwGetNodeLinkOffsetForESAlt }


PROCEDURE    _StoreNodeLinkOffsetForESAlt; assembler;
{* Store a new AS link offset for the given node.  *}
{* Enter:  ES:BX -> node         *}
{*         AX = new link offset  *}
{* Exit:   None                  *}
{* Used also: None               *}
{ Description:  }
ASM
             push     ax
             push     cx
             mov      cx, ax
             mov      ax, (Globals.btNodeLinkOffsetPresentES)
             call     _fndwGetNodeLinkOffsetGenericAlt
             or       ax, ax
             jz      @NoPresentLinkOffsetES
             push     di
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
@NoPresentLinkOffsetES:
             pop      cx
             pop      ax
END;  { _StoreNodeLinkOffsetForESAlt }


PROCEDURE   _fndwGetNodeAccessCountAlt; assembler;
{* Get the access count from the given node.  *}
{* Enter:  ES:BX -> node               *}
{* Exit:   AX = access count for node  *}
{* Used also: None                     *}
{ Description:  }
ASM
             call     _fndwGetNodeSizeOfAllLinksAlt
             push     di
             mov      di, bx
             add      di, ax
             mov      ax, es:[di]
             pop      di
END;  { _fndwGetNodeAccessCountAlt }


PROCEDURE   _StoreNodeAccessCountAlt; assembler;
{* Store a new access count for the given node.  *}
{* Enter:  ES:BX -> node          *}
{*         AX = new access count  *}
{* Exit:   None                   *}
{* Used also: None                *}
{ Description:  }
ASM
             push     ax
             push     cx
             push     di
             mov      cx, ax
             call     _fndwGetNodeSizeOfAllLinksAlt
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
             pop      cx
             pop      ax
END;  { _StoreNodeAccessCountAlt }


PROCEDURE   _fndwGetNodeHitCountAlt; assembler;
{* Get the hit count from the given node.  *}
{* Enter:  ES:BX -> node            *}
{* Exit:   AX = hit count for node  *}
{* Used also: None                  *}
{ Description:  }
ASM
             call     _fndwGetNodeSizeOfAllLinksAlt
             add      ax,(Globals.recDictEntryHeaderDesc.dwNodeHitCount)-(Globals.recDictEntryHeaderDesc.dwNodeAccessCount)
             push     di
             mov      di, bx
             add      di, ax
             mov      ax, es:[di]
             pop      di
END;  { _fndwGetNodeHitCountAlt }


PROCEDURE   _StoreNodeHitCountAlt; assembler;
{* Store a new hit count for the given node.  *}
{* Enter:  ES:BX -> node       *}
{*         AX = new hit count  *}
{* Exit:   None                *}
{* Used also: None             *}
{ Description:  }
ASM
             push     ax
             push     cx
             push     di
             mov      cx, ax
             call     _fndwGetNodeSizeOfAllLinksAlt
             add      ax,(Globals.recDictEntryHeaderDesc.dwNodeHitCount)-(Globals.recDictEntryHeaderDesc.dwNodeAccessCount)
             mov      di, bx
             add      di, ax
             mov      es:[di], cx
             pop      di
             pop      cx
             pop      ax
END;  { _StoreNodeHitCountAlt }


PROCEDURE   _fndwGetNodeOptionsAlt; assembler;
{* Get the option flags from the given node.  *}
{* Enter:  ES:BX -> node          *}
{* Exit:   AX = options for node  *}
{* Used also: None                *}
{ Description:  }
ASM
             mov      ax, es:[bx][Globals.recDictEntryHeaderDesc.dwNodeOptions]
END;  { _fndwGetNodeOptionsAlt }


PROCEDURE   _StoreNodeOptionsAlt; assembler;
{* Store a new options for the given node.  *}
{* Enter:  ES:BX -> node     *}
{*         AX = new options  *}
{* Exit:   None              *}
{* Used also: None           *}
ASM
             mov      es:[bx][Globals.recDictEntryHeaderDesc.dwNodeOptions], ax
END;  { _StoreNodeOptionsAlt }


PROCEDURE   _fndbGetNodeAbbreviationSizeAlt; assembler;
{* Get the abbreviation size from the given node.  *}
{* Enter:  ES:BX -> node       *}
{* Exit:   AL = size in bytes  *}
{* Used also: None             *}
{ Description:  }
ASM
             call     _fndwGetNodeSizeOfAllLinksAlt
             add      ax,(recDictEntryHeaderDesc.dbHeaderDictAbbreviationSize)-(recDictEntryHeaderDesc.dwNodeAccessCount)
             push     di
             mov      di, bx
             add      di, ax
             mov      al, es:[di]
             pop      di
END;  { _fndbGetNodeAbbreviationSizeAlt }


PROCEDURE   _StoreNodeAbbreviationSizeAlt; assembler;
{* Store a new abbreviation size for the given node.  *}
{* Enter:  ES:BX -> node  *}
{*         AL = new size  *}
{* Exit:   None           *}
{* Used also: None        *}
{ Description:  }
ASM
             push     ax
             push     cx
             push     di
             mov      cx, ax
             call     _fndwGetNodeSizeOfAllLinksAlt
             add      ax,(recDictEntryHeaderDesc.dbHeaderDictAbbreviationSize)-(recDictEntryHeaderDesc.dwNodeAccessCount)
             mov      di, bx
             add      di, ax
             mov      es:[di], cl
             pop      di
             pop      cx
             pop      ax
END;  { _StoreNodeAbbreviationSizeAlt }


PROCEDURE   _fndbGetNodeExpressionSizeAlt; assembler;
{* Get the expression size from the given node.  *}
{* Enter:  ES:BX -> node       *}
{* Exit:   AL = size in bytes  *}
{* Used also: None             *}
{ Description:  }
ASM
             call     _fndwGetNodeSizeOfAllLinksAlt
             add      ax,(Globals.recDictEntryHeaderDesc.dbHeaderDictEntrySize)-(recDictEntryHeaderDesc.dwNodeAccessCount)
             push     di
             mov      di, bx
             add      di, ax
             mov      al, es:[di]
             pop      di
END;  { _fndbGetNodeExpressionSizeAlt }


PROCEDURE   _StoreNodeExpressionSizeAlt; assembler;
{* Store a new expression size for the given node.  *}
{* Enter:  ES:BX -> node  *}
{*         AL = new size  *}
{* Exit:   None           *}
{* Used also: None        *}
{ Description:  }
ASM
             push     ax
             push     cx
             push     di
             mov      cx, ax
             call     _fndwGetNodeSizeOfAllLinksAlt
             add      ax,(Globals.recDictEntryHeaderDesc.dbHeaderDictEntrySize)-(recDictEntryHeaderDesc.dwNodeAccessCount)
             mov      di, bx
             add      di, ax
             mov      es:[di], cl
             pop      di
             pop      cx
             pop      ax
END;  { _StoreNodeExpressionSizeAlt }


PROCEDURE   _fndwGetNodeAbbreviationOfsAlt; assembler;
{* Get the abbreviation offset for the given node.  *}
{* Enter:  ES:BX -> node                       *}
{* Exit:   AX = offset of abbreviation string  *}
{* Used also: None                             *}
{ Description:  }
ASM
             call     _fndwGetNodeSizeOfAllLinksAlt
             add      ax,(recDictEntryHeaderDesc.dbHeaderDictEntrySize)-(recDictEntryHeaderDesc.dwNodeAccessCount)+aByte
             add      ax, bx
END;  { _fndwGetNodeAbbreviationOfsAlt }


PROCEDURE   _fndwGetNodeExpressionOfsAlt; assembler;
{* Get the expression offset for the given node.  *}
{* Enter:  ES:BX -> node                     *}
{* Exit:   AX = offset of expression string  *}
{* Used also: None                           *}
{ Description:  }
ASM
             push     cx
             call     _fndwGetNodeAbbreviationOfsAlt
             mov      cx, ax
             sub      ax, ax
             call     _fndbGetNodeAbbreviationSizeAlt
             add      ax, cx
             pop      cx
END;  { _fndwGetNodeExpressionOfsAlt }


PROCEDURE    _fndwGetNodeSizeTotalAlt; assembler;
{* Get the node size for the given node.  *}
{* Enter:  ES:BX -> node      *}
{* Exit:   AX = size of node  *}
{* Used also: None            *}
{ Description:  }
ASM
             push     cx
             call     _fndwGetNodeSizeOfAllLinksAlt
             add      ax, (recDictEntryHeaderDesc.dbHeaderDictEntrySize)-(recDictEntryHeaderDesc.dwNodeAccessCount)+aByte
             mov      cx, ax
             sub      ax, ax
             call     _fndbGetNodeAbbreviationSize
             add      cx, ax
             sub      ax, ax
             call     _fndbGetNodeExpressionSizeAlt
             add      ax, cx
             test     es:[bx][Globals.recDictEntryHeaderDesc.dwNodeOptions], Globals.btNodeHasPaddingZero
             jz      @NoPaddingZero
             inc      ax
@NoPaddingZero:
             pop      cx
END;  { _fndwGetNodeSizeTotalAlt }


PROCEDURE   _fndwGetTableOffsetByIndexAlt; assembler;
{* Get a link offset from the static head table. *}
{* Enter:  AL    =  character                 *}
{*         ES:BX -> index table               *}
{*         DX    =  user environment options  *}
{* Exit:   BX = offset from table             *}
{*         ES = segment of dictionary         *}
{* Used also:  AH                             *}
{* Description:  *}
ASM
             push     di
             test     dx, Globals.btUseTableCompression
             jnz     @CompressedStaticHeadTable
             sub      ah, ah
             sub      di, di
             mov      di, ax
             shl      di, 1
             mov      bx, es:[bx].[di]
             pop      di
             retn
{ Description:                                                             }
{ The following compression scheme is in use:                               }
{ 32 bytes = bit-map of non-zero offset for corresponding ASCII characters  }
{ 16 bytes = bits counters for each previous byte                           }
{            bit #0-3  bit count for odd  byte                              }
{            bit #4-7  bit count for even byte                              }
{ variable = link word offsets to corresponding nodes                       }
{ Algorihm:  (S1)  byte offset = char DIV 8                                 }
{            (S2)  bit  offset = char MOD 8                                 }
{            (S3)  test presence bit in bitmap set                          }
{            (S4)  if zero bit found then exit                              }
{            (S5)  byte offset for bit-count array = char DIV 16            }
{            (S6)  bit offset for bit-count array = char MOD 16             }
{                  odd  byte = char MOD 16 <= 7                             }
{                  even byte = char MOD 16 > 7                              }
{            (S7)  link offset = word * calculated presence bits count      }
{                                before our bit                             }
@CompressedStaticHeadTable:
             push     cx
             push     dx
             sub      dx, dx
             mov      ch, al
             shr      al, 1
             shr      al, 1
             shr      al, 1
             mov      dl, al
             mov      cl, ch
             and      cl, $07
             mov      ah, $1
             shl      ah, cl
             mov      di, dx
             mov      al, es:[bx].[di]
             mov      dh, al
             test     al, ah
             jnz     @BitEntryFound
             sub     bx, bx
             jmp    @CompressedLinkOfsFound
@BitEntryFound:
             mov      al, dl
             shr      al, 1
             mov      dl, al
             sub      ax, ax
             mov      di, Globals.recCompressedHeadLinkTable.dbCharBitCounters16
             push     dx
@CalcBitSummaForCharOffsets:
             or       dl, dl
             jz      @CalcBitSummaInLastByte
             mov      dh, es:[bx].[di]
             and      dh, Globals.aFullLowNibble
             add      al, dh
             adc      ah, 0
             mov      dh, es:[bx].[di]
             shr      dh, 1
             shr      dh, 1
             shr      dh, 1
             shr      dh, 1
             add      al, dh
             adc      ah, 0
             inc      di
             dec      dl
             jmp     @CalcBitSummaForCharOffsets
@CalcBitSummaInLastByte:
             pop      dx
             and      ch, Globals.aFullLowNibble
             cmp      ch, $7
             jbe     @OddNibble
             mov      dl, es:[bx].[di]
             and      dl, Globals.aFullLowNibble
             add      al, dl
             adc      ah, 0
@OddNibble:
@TestNextBit:
             or       cl, cl
             jz      @AllBitSummaFound
             shr      dh, 1
             adc      ax, 0
             dec      cl
             jmp     @TestNextBit
@AllBitSummaFound:
             shl      ax, 1
             add      ax, (Globals.recCompressedHeadLinkTable.dbCharBitCounters16) + Globals.aBitCountsForSet256
             mov      di, ax
             mov      bx, es:[bx].[di]
@CompressedLinkOfsFound:
             pop      dx
             pop      cx
             pop      di
END;  { _fndwGetTableOffsetByIndexAlt }


PROCEDURE   _PutFirstTableOffsetByIndexAlt; assembler;
{* Put a link offset into the static head table. *}
{* Enter:  AL    =  character                 *}
{*         ES:BX -> index table               *}
{*         DX    =  user environment options  *}
{*         CX    =  new offset                *}
{* Exit:   None                               *}
{* Used also: AH                              *}
{* Description:                               *}
ASM
             push     di
             test     dx, Globals.btUseTableCompression
             jnz     @CompressedStaticHeadTable
             sub      ah, ah
             sub      di, di
             mov      di, ax
             shl      di, 1
             mov      es:[bx].[di], cx
             pop      di
             retn
{ Description:                                                             }
{ The following compression scheme is in use:                               }
{ 32 bytes = bit-map of non-zero offset for corresponding ASCII characters  }
{ 16 bytes = bits counters for each previous byte                           }
{            bit #0-3  bit count for odd  byte                              }
{            bit #4-7  bit count for even byte                              }
{ variable = link word offsets to corresponding nodes                       }
{ Algorihm:  (S1)  byte offset = char DIV 8                                 }
{            (S2)  bit  offset = char MOD 8                                 }
{            (S3)  test presence bit in bitmap set                          }
{            (S4)  if zero bit found then exit                              }
{            (S5)  byte offset for bit-count array = char DIV 16            }
{            (S6)  bit offset for bit-count array = char MOD 16             }
{                  odd  byte = char MOD 16 <= 7                             }
{                  even byte = char MOD 16 > 7                              }
{            (S7)  link offset = word * calculated presence bits count      }
{                                before our bit                             }
@CompressedStaticHeadTable:
             push     cx
             push     dx
             sub      dx, dx
             mov      ch, al
             shr      al, 1
             shr      al, 1
             shr      al, 1
             mov      dl, al
             mov      cl, ch
             and      cl, $07
             mov      ah, $1
             shl      ah, cl
             mov      di, dx
             mov      al, es:[bx].[di]
             mov      dh, al
             test     al, ah
             jnz     @BitEntryFound
             pop      dx
             pop      cx
             pop      di
             retn
@BitEntryFound:
             mov      al, dl
             shr      al, 1
             mov      dl, al
             sub      ax, ax
             mov      di, Globals.recCompressedHeadLinkTable.dbCharBitCounters16
             push     dx
@CalcBitSummaForCharOffsets:
             or       dl, dl
             jz      @CalcBitSummaInLastByte
             mov      dh, es:[bx].[di]
             and      dh, Globals.aFullLowNibble
             add      al, dh
             adc      ah, 0
             mov      dh, es:[bx].[di]
             shr      dh, 1
             shr      dh, 1
             shr      dh, 1
             shr      dh, 1
             add      al, dh
             adc      ah, 0
             inc      di
             dec      dl
             jmp     @CalcBitSummaForCharOffsets
@CalcBitSummaInLastByte:
             pop      dx
             and      ch, Globals.aFullLowNibble
             cmp      ch, $7
             jbe     @OddNibble
             mov      dl, es:[bx].[di]
             and      dl, Globals.aFullLowNibble
             add      al, dl
             adc      ah, 0
@OddNibble:
@TestNextBit:
             or       cl, cl
             jz      @AllBitSummaFound
             shr      dh, 1
             adc      ax, 0
             dec      cl
             jmp     @TestNextBit
@AllBitSummaFound:
             shl      ax, 1
             add      ax, (Globals.recCompressedHeadLinkTable.dbCharBitCounters16) + Globals.aBitCountsForSet256
             mov      di, ax
             pop      dx
             pop      cx
             mov      es:[bx].[di], cx
             pop      di
END;  { _PutFirstTableOffsetByIndexAlt }



{*CALLBACK.INC*}

PROCEDURE   _CallBackInterfaceAlt; assembler;
{* Executes a requested service.  *}
ASM
         int     Globals.aMultiplexInt
END;  { _CallBackInterfaceAlt }


{*=========================== FUNCTIONAL PART ==========================*}


{*=========================== PROCEDURAL PART ==========================*}


PROCEDURE
         _MyExitProc; FAR;
{*
Description.
   This procedure will be called from Turbo RunTime Error Handler.
*}
BEGIN
    IF  (Globals.gbRestoreInts)
      THEN  DosCtl._RestoreCurrentVectors;
    {if-then}
    ExitProc := Globals.glpOldExitProc;
END;
{ _MyExitProc }



PROCEDURE
         _PatchCallBackInterface;
{*
Description.
   Patches the multiplex interrupt interface call.
*}
VAR
  dwMainOfs, dwMainSeg,
  dwAltOfs,  dwAltSeg,
  dwUnitOfs, dwUnitSeg  :  System.Word;

BEGIN
   dwMainSeg := System.Seg(_CallBackInterface);
   dwMainOfs := System.Ofs(_CallBackInterface) + Globals.aByte;
   dwAltOfs  := System.Seg(_CallBackInterfaceAlt);
   dwAltSeg  := System.Ofs(_CallBackInterfaceAlt) + Globals.aByte;
   dwUnitSeg := System.Seg(CallBack._CallBackDoorInterface);
   dwUnitOfs := System.Ofs(CallBack._CallBackDoorInterface) + Globals.aByte;
   System.Mem[dwMainSeg:dwMainOfs] := Globals.gdbCallBackIntNum;
   System.Mem[dwAltSeg:dwAltOfs] := Globals.gdbCallBackIntNum;
   System.Mem[dwUnitSeg:dwUnitOfs] := Globals.gdbCallBackIntNum;
   IF  (System.Mem[dwMainSeg:dwMainOfs] <> Globals.gdbCallBackIntNum) AND
       (System.Mem[dwAltSeg:dwAltOfs] <> Globals.gdbCallBackIntNum) AND
       (System.Mem[dwUnitSeg:dwUnitOfs] <> Globals.gdbCallBackIntNum)
     THEN  BEGIN
       Video._HaltProgram(Messages._fnsTextMessageByIndex(125),
                    Globals.errCallToPatchMultiplexInterface);
           END;
   {if-then}
END;  { _PatchCallBackInterface }


PROCEDURE
        _DoCallByIndex; far; assembler;
{*
Description.
     Does the call by the given index and far return after call.
     Enter: SI = index into call table.
*}
ASM
        shl     si, 1
        call    WORD PTR  ds:[si][Globals.glpNearCallIndexTable]
END;
{ _DoCallByIndex }


PROCEDURE
         _InitCallBackIndexTable(lpIndexTable : System.Pointer); assembler;
{*
Description.
     Initializes the index table for calls back.
*}
ASM
        jmp     @DoInitTable
@pofsLinkTableMain:
        DW      OFFSET    _fndwGetTableOffsetByIndex   {00}
        DW      OFFSET    _PutFirstTableOffsetByIndex  {01}
        DW      OFFSET    _fndwGetNodeOptions          {02}
        DW      OFFSET    _StoreNodeOptions            {03}
        DW      OFFSET    _fndwGetNodeLinkOffsetForFA  {04}
        DW      OFFSET    _StoreNodeLinkOffsetForFA    {05}
        DW      OFFSET    _fndwGetNodeLinkOffsetForBA  {06}
        DW      OFFSET    _StoreNodeLinkOffsetForBA    {07}
        DW      OFFSET    _fndwGetNodeLinkOffsetForFE  {08}
        DW      OFFSET    _StoreNodeLinkOffsetForFE    {09}
        DW      OFFSET    _fndwGetNodeLinkOffsetForBE  {10}
        DW      OFFSET    _StoreNodeLinkOffsetForBE    {11}
        DW      OFFSET    _fndwGetNodeAccessCount      {12}
        DW      OFFSET    _StoreNodeAccessCount        {13}
        DW      OFFSET    _fndwGetNodeHitCount         {14}
        DW      OFFSET    _StoreNodeHitCount           {15}
        DW      OFFSET    _fndbGetNodeAbbreviationSize {16}
        DW      OFFSET    _StoreNodeAbbreviationSize   {17}
        DW      OFFSET    _fndbGetNodeExpressionSize   {18}
        DW      OFFSET    _StoreNodeExpressionSize     {19}
        DW      OFFSET    _fndwGetNodeAbbreviationOfs  {20}
        DW      OFFSET    _fndwGetNodeExpressionOfs    {21}
        DW      OFFSET    _fndwGetNodeLinkOffsetForAS  {22}
        DW      OFFSET    _StoreNodeLinkOffsetForAS    {23}
        DW      OFFSET    _fndwGetNodeLinkOffsetForES  {24}
        DW      OFFSET    _StoreNodeLinkOffsetForES    {25}
        DW      OFFSET    _fndwGetNodeSizeTotal        {26}
@pofsLinkTableAlt:
        DW      OFFSET    _fndwGetTableOffsetByIndexAlt   {00}
        DW      OFFSET    _PutFirstTableOffsetByIndexAlt  {01}
        DW      OFFSET    _fndwGetNodeOptionsAlt          {02}
        DW      OFFSET    _StoreNodeOptionsAlt            {03}
        DW      OFFSET    _fndwGetNodeLinkOffsetForFAAlt  {04}
        DW      OFFSET    _StoreNodeLinkOffsetForFAAlt    {05}
        DW      OFFSET    _fndwGetNodeLinkOffsetForBAAlt  {06}
        DW      OFFSET    _StoreNodeLinkOffsetForBAAlt    {07}
        DW      OFFSET    _fndwGetNodeLinkOffsetForFEAlt  {08}
        DW      OFFSET    _StoreNodeLinkOffsetForFEAlt    {09}
        DW      OFFSET    _fndwGetNodeLinkOffsetForBEAlt  {10}
        DW      OFFSET    _StoreNodeLinkOffsetForBEAlt    {11}
        DW      OFFSET    _fndwGetNodeAccessCountAlt      {12}
        DW      OFFSET    _StoreNodeAccessCountAlt        {13}
        DW      OFFSET    _fndwGetNodeHitCountAlt         {14}
        DW      OFFSET    _StoreNodeHitCountAlt           {15}
        DW      OFFSET    _fndbGetNodeAbbreviationSizeAlt {16}
        DW      OFFSET    _StoreNodeAbbreviationSizeAlt   {17}
        DW      OFFSET    _fndbGetNodeExpressionSizeAlt   {18}
        DW      OFFSET    _StoreNodeExpressionSizeAlt     {19}
        DW      OFFSET    _fndwGetNodeAbbreviationOfsAlt  {20}
        DW      OFFSET    _fndwGetNodeExpressionOfsAlt    {21}
        DW      OFFSET    _fndwGetNodeLinkOffsetForASAlt  {22}
        DW      OFFSET    _StoreNodeLinkOffsetForASAlt    {23}
        DW      OFFSET    _fndwGetNodeLinkOffsetForESAlt  {24}
        DW      OFFSET    _StoreNodeLinkOffsetForESAlt    {25}
        DW      OFFSET    _fndwGetNodeSizeTotalAlt        {26}
@DoInitTable:
         mov    ax, OFFSET _DoCallByIndex
         mov    WORD PTR ds:[Globals.glpFarCallManager][0], ax  {dispatcher}
         mov    WORD PTR ds:[Globals.glpFarCallManager][2], cs  {address}
         les    di, lpIndexTable
         push   ds
         mov    si, OFFSET @pofsLinkTableMain
         cmp    Globals.gbUseAltCall, System.False
         je    @UseMainCall
         mov    si, OFFSET @pofsLinkTableAlt
@UseMainCall:
         mov    ax, cs
         mov    ds, ax
         mov    cx, aMaxAvailCallBackIndex+1       {0-based}
         cld
         rep    movsw                              {store offsets}
         pop    ds
END; {asm-end}
{ _InitCallBackIndexTable }


PROCEDURE
        _DoNearCallWithParmPtr; far; assembler;
{*
Description.
     Does the call by the fixed address and far return after call.
     Enter: DX:AX -> pointer of table.
*}
ASM
        push    dx
        push    ax
        call    _InitCallBackIndexTable
END;
{ _DoNearCallWithParmPtr }



{*DICT2MEM.INC*}

PROCEDURE
         _BuildMemoryEnvironmentAndDictionary;
{*
Description.
    Copies the prepared dictionary/environment to memory
    of resident part of program.
*}
VAR
  pTempTable    :   System.Pointer;
  pEnvDesc      :   Globals.lprecEnvironmentDesc;

PROCEDURE
         _AllocHeadLinkTableSpace(VAR  pHeadTable : System.Pointer;
                                  dbStaticHeadTableType : System.Byte);
{*
Description.
    Allocates the static and/or dynamic table for 256 nodes.
*}
VAR
  recHeadLinkTable        :   Globals.recCompressedHeadLinkTable;
  lpFrequencyNodesArray   :   Globals.lpDWTable256;
  dwHeadLinkTableSize     :   System.Word;
  dbCharIndex,
  dbCharByteOfs,
  dbCharBitOfs,
  dbCharBitCount,
  dbTemp                  :   System.Byte;
BEGIN
   IF  ((Globals.gdwCurUserEnvOptions AND Globals.btUseTableCompression) = 0)
     THEN  CallBack._GetFreeItemDataDict(pHeadTable,(Globals.aMaxCharBit8+1)*Globals.aWord)
     ELSE  BEGIN
         CASE  (dbStaticHeadTableType)  OF
             Globals.btForwardSearchAbbreviation  :
                                                 BEGIN
                        lpFrequencyNodesArray := @Globals.gSymFrequencyNodesArrayFA;
                                                 END;
             Globals.btBackwardSearchAbbreviation  :
                                                 BEGIN
                        lpFrequencyNodesArray := @Globals.gSymFrequencyNodesArrayBA;
                                                 END;
             Globals.btForwardSearchExpression  : 
                                                 BEGIN
                        lpFrequencyNodesArray := @Globals.gSymFrequencyNodesArrayFE;
                                                 END;
             Globals.btBackwardSearchExpression  :  
                                                 BEGIN
                        lpFrequencyNodesArray := @Globals.gSymFrequencyNodesArrayBE;
                                                 END;
             Globals.btSearchAbbreviationSizes  :  
                                                 BEGIN
                        lpFrequencyNodesArray := @Globals.gAbbrevSizesFrequencyNodesArray;
                                                 END;
             Globals.btSearchExpressionSizes   :
                                                 BEGIN
                        lpFrequencyNodesArray := @Globals.gExprSizesFrequencyNodesArray;
                                                 END;
         END;
         {case-of}
         dwHeadLinkTableSize := System.SizeOf(Globals.recCompressedHeadLinkTable);
         System.FillChar(recHeadLinkTable,
                         System.SizeOf(Globals.recCompressedHeadLinkTable),
                         Globals.achNULL);
         FOR  dbCharIndex :=  Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
           WITH  (recHeadLinkTable)  DO
           BEGIN
              IF (lpFrequencyNodesArray^[dbCharIndex] = 0)
                THEN  BEGIN
                      END
                ELSE  BEGIN
                   System.Inc(dwHeadLinkTableSize,Globals.aWord);
                   dbCharByteOfs  := dbCharIndex SHR 3;
                   dbCharBitCount := dbCharIndex AND $07;
                   dbCharBitOfs := $01 SHL dbCharBitCount;
                   dbTemp := dbBitMapAsciiSet32[dbCharByteOfs] OR (dbCharBitOfs);
                   dbBitMapAsciiSet32[dbCharByteOfs] := dbTemp;
                   dbTemp := dbCharBitCounters16[(dbCharByteOfs SHR 1)];
                   IF ((dbCharIndex AND Globals.aFullLowNibble) <= 7)
                     THEN
                        System.Inc(dbTemp,1)
                     ELSE
                        System.Inc(dbTemp,(1 SHL 4));
                   {if-then-else}
                   dbCharBitCounters16[(dbCharByteOfs SHR 1)] := dbTemp;
                      END;
              {if-then-else}
           END;
           {with-do}
         {for-to-do}
         CallBack._GetFreeItemDataDict(pHeadTable,dwHeadLinkTableSize);
         System.Move(recHeadLinkTable,
                     System.Mem[System.Seg(pHeadTable^):System.Ofs(pHeadTable^)],
                     System.SizeOf(Globals.recCompressedHeadLinkTable));
           END;
   {if-then-else}
END;
{ _AllocHeadLinkTableSpace }

PROCEDURE
         _AddNextDictSearchTable(pSrcMemDict : Globals.lpPTable256;
                                 pMemEnv : Globals.lprecEnvironmentDesc);
{*
Description.
     Copies the search table to the memory dictionary image.
*}
VAR
   pTemp,
   pDictEntry,
   pAbbreviation        :        System.Pointer;
   pDictTable           :        Globals.lpDWTable256;
   lpDictNode           :        Globals.lprecDicEntryDesc;
   lpHeaderDict,
   lpHeaderDictPrev     :        Globals.lprecDictEntryHeaderDesc;
   sAbbreviation,
   sExpression          :         STRING;
   dwCompressionFlags,
   dwTempOptions,
   dwTempStore,
   dwHeaderDictSeg,
   dwHeaderDictOfs,
   dwDicAbbrvStoreSeg,
   dwDicAbbrvStoreOfs,
   dwDicEntryStoreSeg,
   dwDicEntryStoreOfs   :        System.Word;
   dbTableCharIndex,
   dbCharIndex,
   dbDictItemSize,
   dbTempCount          :        System.Byte;
   bEmptyAbbreviation,
   bAddPaddingZero,
   bNodeWasCompressed   :        System.Boolean;

PROCEDURE
         _UpdateSearchLinkTable(lpNodeToUpdate : Globals.lprecDictEntryHeaderDesc;
                                pSearchLinkTable : Globals.lpDWTable256;
                                dbIndexInTable,
                                dbSearchTableType : System.Byte);
{*
Description.
   Updates the link search table.
*}
VAR
  lpNodeToUpdatePrev    :  Globals.lprecDictEntryHeaderDesc;
  dwLinkOfs,
  dwLinkOfsPrev,
  dwCurFreeSpaceSeg     :  System.Word;
BEGIN
  IF  (pSearchLinkTable = NIL)
    THEN  System.Exit;
  {if-then}
  dwCurFreeSpaceSeg := System.Seg(lpNodeToUpdate^);
  ASM
      les      bx, pSearchLinkTable
      mov      al, dbIndexInTable
      mov      dx, Globals.gdwCurUserEnvOptions
      cmp      Globals.gbUseAltCall, System.True
      je      @UseAltCall
      call     _fndwGetTableOffsetByIndex
      jmp     @AltCallDone
@UseAltCall:
      call     _fndwGetTableOffsetByIndexAlt
@AltCallDone:
      mov      dwLinkOfs, bx
  END;
  {asm-end}
  dwLinkOfsPrev := 0;
  lpNodeToUpdatePrev := NIL;

  WHILE  (dwLinkOfs <> 0)  DO
  BEGIN
      dwLinkOfsPrev := dwLinkOfs;
      lpNodeToUpdatePrev := System.Ptr(dwCurFreeSpaceSeg,dwLinkOfsPrev);
      CASE  (dbSearchTableType)  OF
         Globals.btBackwardSearchAbbreviation   :   BEGIN
                  ASM
                      les       bx, lpNodeToUpdatePrev
                      cmp       Globals.gbUseAltCall, System.True
                      je       @UseAltCall
                      call      _fndwGetNodeLinkOffsetForBA
                      jmp      @AltCallDone
        @UseAltCall:
                      call      _fndwGetNodeLinkOffsetForBAAlt
        @AltCallDone:
                      mov       dwLinkOfs, bx
                  END;
                  {asm-end}
                                            END;
         Globals.btForwardSearchExpression      :   BEGIN
                  ASM
                      les       bx, lpNodeToUpdatePrev
                      cmp       Globals.gbUseAltCall, System.True
                      je       @UseAltCall
                      call      _fndwGetNodeLinkOffsetForFE
                      jmp      @AltCallDone
        @UseAltCall:
                      call      _fndwGetNodeLinkOffsetForFEAlt
        @AltCallDone:
                      mov       dwLinkOfs, bx
                  END;
                  {asm-end}
                                            END;
         Globals.btBackwardSearchExpression     :   BEGIN
                  ASM
                      les       bx, lpNodeToUpdatePrev
                      cmp       Globals.gbUseAltCall, System.True
                      je       @UseAltCall
                      call      _fndwGetNodeLinkOffsetForBE
                      jmp      @AltCallDone
        @UseAltCall:
                      call      _fndwGetNodeLinkOffsetForBEAlt
        @AltCallDone:
                      mov       dwLinkOfs, bx
                  END;
                  {asm-end}
                                            END;
         Globals.btSearchAbbreviationSizes      :   BEGIN
                  ASM
                      les       bx, lpNodeToUpdatePrev
                      cmp       Globals.gbUseAltCall, System.True
                      je       @UseAltCall
                      call      _fndwGetNodeLinkOffsetForAS
                      jmp      @AltCallDone
        @UseAltCall:
                      call      _fndwGetNodeLinkOffsetForASAlt
        @AltCallDone:
                      mov       dwLinkOfs, bx
                  END;
                  {asm-end}
                                            END;
         Globals.btSearchExpressionSizes        :   BEGIN
                  ASM
                      les       bx, lpNodeToUpdatePrev
                      cmp       Globals.gbUseAltCall, System.True
                      je       @UseAltCall
                      call      _fndwGetNodeLinkOffsetForES
                      jmp      @AltCallDone
        @UseAltCall:
                      call      _fndwGetNodeLinkOffsetForESAlt
        @AltCallDone:
                      mov       dwLinkOfs, bx
                  END;
                  {asm-end}
                                            END;
      END;
      {case-of}
  END;
  {while-do}

  dwLinkOfs := System.Ofs(lpNodeToUpdate^);
  IF (dwLinkOfsPrev <> 0)
    THEN  BEGIN
      CASE  (dbSearchTableType)  OF
         Globals.btBackwardSearchAbbreviation   :   BEGIN
                  ASM
                      les       bx, lpNodeToUpdatePrev
                      mov       ax, dwLinkOfs
                      cmp       Globals.gbUseAltCall, System.True
                      je       @UseAltCall
                      call      _StoreNodeLinkOffsetForBA
                      jmp      @AltCallDone
        @UseAltCall:
                      call      _StoreNodeLinkOffsetForBAAlt
        @AltCallDone:
                  END;
                  {asm-end}
                                            END;
         Globals.btForwardSearchExpression      :   BEGIN
                  ASM
                      les       bx, lpNodeToUpdatePrev
                      mov       ax, dwLinkOfs
                      cmp       Globals.gbUseAltCall, System.True
                      je       @UseAltCall
                      call      _StoreNodeLinkOffsetForFE
                      jmp      @AltCallDone
        @UseAltCall:
                      call      _StoreNodeLinkOffsetForFEAlt
        @AltCallDone:
                  END;
                  {asm-end}
                                            END;
         Globals.btBackwardSearchExpression     :   BEGIN
                  ASM
                      les       bx, lpNodeToUpdatePrev
                      mov       ax, dwLinkOfs
                      cmp       Globals.gbUseAltCall, System.True
                      je       @UseAltCall
                      call      _StoreNodeLinkOffsetForBE
                      jmp      @AltCallDone
        @UseAltCall:
                      call      _StoreNodeLinkOffsetForBEAlt
        @AltCallDone:
                  END;
                  {asm-end}
                                            END;
         Globals.btSearchAbbreviationSizes      :   BEGIN
                  ASM
                      les       bx, lpNodeToUpdatePrev
                      mov       ax, dwLinkOfs
                      cmp       Globals.gbUseAltCall, System.True
                      je       @UseAltCall
                      call      _StoreNodeLinkOffsetForAS
                      jmp      @AltCallDone
        @UseAltCall:
                      call      _StoreNodeLinkOffsetForASAlt
        @AltCallDone:
                  END;
                  {asm-end}
                                            END;
         Globals.btSearchExpressionSizes        :   BEGIN
                  ASM
                      les       bx, lpNodeToUpdatePrev
                      mov       ax, dwLinkOfs
                      cmp       Globals.gbUseAltCall, System.True
                      je       @UseAltCall
                      call      _StoreNodeLinkOffsetForES
                      jmp      @AltCallDone
        @UseAltCall:
                      call      _StoreNodeLinkOffsetForESAlt
        @AltCallDone:
                  END;
                  {asm-end}
                                            END;
      END;
      {case-of}
          END
    ELSE  BEGIN
        ASM
            les      bx, pSearchLinkTable
            mov      al, dbIndexInTable
            mov      dx, Globals.gdwCurUserEnvOptions
            mov      cx, dwLinkOfs
            cmp      Globals.gbUseAltCall, System.True
            je      @UseAltCall
            call     _PutFirstTableOffsetByIndex
            jmp     @AltCallDone
@UseAltCall:
            call     _PutFirstTableOffsetByIndexAlt
@AltCallDone:
        END;
        {asm-end}
          END;
  {if-then-else}
END;
{ _UpdateSearchLinkTable }

BEGIN
  {* do head tables *}
     pDictTable := pMemEnv^.pForwardSearchAbbrevTable;
  {* copy dictionary table *}
   FOR  dbCharIndex := Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
   BEGIN
       lpDictNode := pSrcMemDict^[dbCharIndex];
       ASM
           les      bx, pDictTable
           mov      al, dbCharIndex
           mov      dx, Globals.gdwCurUserEnvOptions
           sub      cx, cx    {CX<-0}
           cmp      Globals.gbUseAltCall, System.True
           je      @UseAltCall
           call     _PutFirstTableOffsetByIndex
           jmp     @AltCallDone
@UseAltCall:
           call     _PutFirstTableOffsetByIndexAlt
@AltCallDone:
       END;
       {asm-end}
       lpHeaderDictPrev := NIL;
       WHILE  (lpDictNode <> NIL)  DO
       BEGIN
          System.Inc(Globals.gliWordsPerDictBuild);
          IF  (Globals.gliWordsPerDictBuild > Globals.aWords_For_Dict_Max)
            THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(439),
                                     Globals.errTooLargeUserDictionary);
          {if-then}
          WITH  (lpDictNode^)  DO
          BEGIN
             sAbbreviation :=  _fnsGetAbbreviationStr(lpDictNode);
             sExpression :=  _fnsGetExpressionStr(lpDictNode);
             bNodeWasCompressed := System.False;
             IF ((pMemEnv^.dwUserEnvOptions AND Globals.btUseNodeCompression) <> 0)
               THEN  BEGIN
                 dbDictItemSize := System.SizeOf(Globals.recDictEntryHeaderDesc);
                 dwCompressionFlags := $0;
                 dbTableCharIndex := dbCharIndex;
                 IF  (Globals.gSymFrequencyNodesArrayFA[dbTableCharIndex] > 1)
                   THEN  BEGIN
                     System.Dec(Globals.gSymFrequencyNodesArrayFA[dbTableCharIndex]);
                     System.Inc(dwCompressionFlags,Globals.btNodeLinkOffsetPresentFA);
                         END
                   ELSE  BEGIN
                     System.Dec(dbDictItemSize,Globals.aWord);
                         END;
                 {if-then-else}
                 dbTableCharIndex := System.Byte(sAbbreviation[dbDicAbbrvSize]);
                 IF  (Globals.gSymFrequencyNodesArrayBA[dbTableCharIndex] > 1)
                   THEN  BEGIN
                     System.Dec(Globals.gSymFrequencyNodesArrayBA[dbTableCharIndex]);
                     System.Inc(dwCompressionFlags,Globals.btNodeLinkOffsetPresentBA);
                         END
                   ELSE  BEGIN
                     System.Dec(dbDictItemSize,Globals.aWord);
                         END;
                 {if-then-else}
                 dbTableCharIndex := System.Byte(sExpression[1]);
                 IF  (Globals.gSymFrequencyNodesArrayFE[dbTableCharIndex] > 1)
                   THEN  BEGIN
                     System.Dec(Globals.gSymFrequencyNodesArrayFE[dbTableCharIndex]);
                     System.Inc(dwCompressionFlags,Globals.btNodeLinkOffsetPresentFE);
                         END
                   ELSE  BEGIN
                     System.Dec(dbDictItemSize,Globals.aWord);
                         END;
                 {if-then-else}
                 dbTableCharIndex := System.Byte(sExpression[dbEntrySize]);
                 IF  (Globals.gSymFrequencyNodesArrayBE[dbTableCharIndex] > 1)
                   THEN  BEGIN
                     System.Dec(Globals.gSymFrequencyNodesArrayBE[dbTableCharIndex]);
                     System.Inc(dwCompressionFlags,Globals.btNodeLinkOffsetPresentBE);
                         END
                   ELSE  BEGIN
                     System.Dec(dbDictItemSize,Globals.aWord);
                         END;
                 {if-then-else}
                 dbTableCharIndex := dbDicAbbrvSize;
                 IF  (Globals.gAbbrevSizesFrequencyNodesArray[dbTableCharIndex] > 1)
                   THEN  BEGIN
                     System.Dec(Globals.gAbbrevSizesFrequencyNodesArray[dbTableCharIndex]);
                     System.Inc(dwCompressionFlags,Globals.btNodeLinkOffsetPresentAS);
                         END
                   ELSE  BEGIN
                     System.Dec(dbDictItemSize,Globals.aWord);
                         END;
                 {if-then-else}
                 dbTableCharIndex := dbEntrySize;
                 IF  (Globals.gExprSizesFrequencyNodesArray[dbTableCharIndex] > 1)
                   THEN  BEGIN
                     System.Dec(Globals.gExprSizesFrequencyNodesArray[dbTableCharIndex]);
                     System.Inc(dwCompressionFlags,Globals.btNodeLinkOffsetPresentES);
                         END
                   ELSE  BEGIN
                     System.Dec(dbDictItemSize,Globals.aWord);
                         END;
                 {if-then-else}
                     bNodeWasCompressed := (dbDictItemSize <> System.SizeOf(Globals.recDictEntryHeaderDesc));
                     END
               ELSE  BEGIN
                 dwCompressionFlags := Globals.btNodeLinkOffsetPresentFA +
                                       Globals.btNodeLinkOffsetPresentBA +
                                       Globals.btNodeLinkOffsetPresentFE +
                                       Globals.btNodeLinkOffsetPresentBE +
                                       Globals.btNodeLinkOffsetPresentAS +
                                       Globals.btNodeLinkOffsetPresentES;
                 dbDictItemSize := System.SizeOf(Globals.recDictEntryHeaderDesc);
                     END;
             {if-then-else}
             bEmptyAbbreviation := System.False;
             IF  ((pMemEnv^.dwUserEnvOptions AND Globals.btEmptyAbbreviation) <> 0)
               THEN  BEGIN
                  IF (sAbbreviation = Globals.asReservedEmptyAbbreviation)
                    THEN  BEGIN
                       bEmptyAbbreviation := System.True;
                          END;
                  {if-then}
                     END;
             {if-then}
             dbDictItemSize := dbDictItemSize + dbDicAbbrvSize + dbEntrySize;
             bAddPaddingZero := System.False;
             IF  ((pMemEnv^.dwUserEnvOptions AND Globals.btAddPaddingZero) <> 0)
               THEN  BEGIN
                  IF (System.ODD(dbDictItemSize))
                    THEN  BEGIN
                       System.Inc(dbDictItemSize);
                       bAddPaddingZero := System.True;
                          END;
                  {if-then}
                     END;
             {if-then}
             _GetFreeItemDataDict(System.Pointer(lpHeaderDict),dbDictItemSize);
             dwHeaderDictSeg := System.Seg(lpHeaderDict^);
             dwHeaderDictOfs := System.Ofs(lpHeaderDict^);
             dwDicAbbrvStoreSeg := System.Seg(lpDicAbbrvStore^);
             dwDicAbbrvStoreOfs := System.Ofs(lpDicAbbrvStore^);
             dwDicEntryStoreSeg := System.Seg(lpDicEntryStore^);
             dwDicEntryStoreOfs := System.Ofs(lpDicEntryStore^);
             IF (bAddPaddingZero)
               THEN  System.Mem[dwHeaderDictSeg:(dwHeaderDictOfs+
                          dbDictItemSize)] := System.Byte(Globals.achNULL);
             {if-then}
             WITH  (lpHeaderDict^)  DO
             BEGIN
                 dwTempOptions := 0;
                 IF (bAddPaddingZero)
                   THEN  System.Inc(dwTempOptions,Globals.btNodeHasPaddingZero);
                 {if-then}
                 System.Inc(dwTempOptions,dwCompressionFlags);
                 IF (bNodeWasCompressed)
                   THEN  BEGIN
                     System.Inc(dwTempOptions,Globals.btNodeIsCompressed);
                         END;
                 {if-then}
                 IF  (bEmptyAbbreviation)
                   THEN  BEGIN
                     System.Inc(dwTempOptions,Globals.btNodeHasEmptyAbbreviation);
                         END;
                 {if-then}
                 ASM
                     les       bx, lpHeaderDict
                     mov       ax, dwTempOptions
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _StoreNodeOptions
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _StoreNodeOptionsAlt
        @AltCallDone:
                 END;
                 {asm-end}
                 ASM
                     les       bx, lpHeaderDict
                     sub       ax, ax          {AX <- 0}
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _StoreNodeLinkOffsetForFA
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _StoreNodeLinkOffsetForFAAlt
        @AltCallDone:
                 END;
                 {asm-end}
                 ASM
                     les       bx, lpHeaderDict
                     sub       ax, ax          {AX <- 0}
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _StoreNodeLinkOffsetForBA
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _StoreNodeLinkOffsetForBAAlt
        @AltCallDone:
                 END;
                 {asm-end}
                 ASM
                     les       bx, lpHeaderDict
                     sub       ax, ax          {AX <- 0}
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _StoreNodeLinkOffsetForFE
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _StoreNodeLinkOffsetForFEAlt
        @AltCallDone:
                 END;
                 {asm-end}
                 ASM
                     les       bx, lpHeaderDict
                     sub       ax, ax          {AX <- 0}
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _StoreNodeLinkOffsetForBE
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _StoreNodeLinkOffsetForBEAlt
        @AltCallDone:
                 END;
                 {asm-end}
                 ASM
                     les       bx, lpHeaderDict
                     sub       ax, ax          {AX <- 0}
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _StoreNodeLinkOffsetForAS
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _StoreNodeLinkOffsetForASAlt
        @AltCallDone:
                 END;
                 {asm-end}
                 ASM
                     les       bx, lpHeaderDict
                     sub       ax, ax          {AX <- 0}
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _StoreNodeLinkOffsetForES
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _StoreNodeLinkOffsetForESAlt
        @AltCallDone:
                 END;
                 {asm-end}
                 ASM
                     les       bx, lpHeaderDict
                     sub       ax, ax          {AX <- 0}
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _StoreNodeAccessCount
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _StoreNodeAccessCountAlt
        @AltCallDone:
                 END;
                 ASM
                     les       bx, lpHeaderDict
                     sub       ax, ax          {AX <- 0}
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _StoreNodeHitCount
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _StoreNodeHitCountAlt
        @AltCallDone:
                 END;
                 dbTempCount := dbDicAbbrvSize;
                 ASM
                     les       bx, lpHeaderDict
                     mov       al, dbTempCount
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _StoreNodeAbbreviationSize
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _StoreNodeAbbreviationSizeAlt
        @AltCallDone:
                 END;
                 {asm-end}
                 dbTempCount := dbEntrySize;
                 ASM
                     les       bx, lpHeaderDict
                     mov       al, dbTempCount
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _StoreNodeExpressionSize
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _StoreNodeExpressionSizeAlt
        @AltCallDone:
                 END;
                 {asm-end}
                 ASM
                     les       bx, lpHeaderDict
                     cmp       Globals.gbUseAltCall, System.True
                     je       @UseAltCall
                     call      _fndwGetNodeAbbreviationOfs
                     jmp      @AltCallDone
        @UseAltCall:
                     call      _fndwGetNodeAbbreviationOfsAlt
        @AltCallDone:
                     mov       dwTempStore, ax
                 END;
                 {asm-end}
                 System.Move(sAbbreviation[1],
                             System.Mem[dwHeaderDictSeg:dwTempStore],
                             dbDicAbbrvSize);
                 ASM
                         les       bx, lpHeaderDict
                         cmp       Globals.gbUseAltCall, System.True
                         je       @UseAltCall
                         call      _fndwGetNodeExpressionOfs
                         jmp      @AltCallDone
        @UseAltCall:
                         call      _fndwGetNodeExpressionOfsAlt
        @AltCallDone:
                         mov       dwTempStore, ax
                 END;
                 {asm-end}
                 System.Move(sExpression[1],
                             System.Mem[dwHeaderDictSeg:dwTempStore],
                             dbEntrySize);
                 IF (lpHeaderDictPrev <> NIL)
                   THEN  BEGIN
                        ASM
                            les       bx, lpHeaderDictPrev
                            mov       ax, dwHeaderDictOfs
                            cmp       Globals.gbUseAltCall, System.True
                            je       @UseAltCall
                            call      _StoreNodeLinkOffsetForFA
                            jmp      @AltCallDone
                @UseAltCall:
                            call      _StoreNodeLinkOffsetForFAAlt
                @AltCallDone:
                        END;
                        {asm-end}
                         END
                   ELSE  BEGIN
                    ASM
                        les      bx, pDictTable
                        mov      al, dbCharIndex
                        mov      dx, gdwCurUserEnvOptions
                        mov      cx, dwHeaderDictOfs
                        cmp      Globals.gbUseAltCall, System.True
                        je      @UseAltCall
                        call     _PutFirstTableOffsetByIndex
                        jmp     @AltCallDone
        @UseAltCall:
                        call     _PutFirstTableOffsetByIndexAlt
        @AltCallDone:
                    END;
                    {asm-end}
                         END;
                 {if-then-else}
                 lpHeaderDictPrev := lpHeaderDict;
             END;
             {with-do}
             _UpdateSearchLinkTable(lpHeaderDict,
                                    pMemEnv^.pBackwardSearchAbbrevTable,
                                    System.Byte(sAbbreviation[dbDicAbbrvSize]),
                                    btBackwardSearchAbbreviation);
             _UpdateSearchLinkTable(lpHeaderDict,
                                    pMemEnv^.pForwardSearchDictTable,
                                    System.Byte(sExpression[1]),
                                    btForwardSearchExpression);
             _UpdateSearchLinkTable(lpHeaderDict,
                                    pMemEnv^.pBackwardSearchDictTable,
                                    System.Byte(sExpression[dbEntrySize]),
                                    btBackwardSearchExpression);
             _UpdateSearchLinkTable(lpHeaderDict,
                                    pMemEnv^.pStrSizeSearchAbbrevTable,
                                    dbDicAbbrvSize,
                                    btSearchAbbreviationSizes);
             _UpdateSearchLinkTable(lpHeaderDict,
                                    pMemEnv^.pStrSizeSearchDictTable,
                                    dbEntrySize,
                                    btSearchExpressionSizes);
             lpDictNode := lpNextDicEntryDesc;
          END;
          {with-do}
       END;
       {while-do}
   END;
   {for-to-do}
END;
{ _AddNextDictSearchTable }

BEGIN
    Video._OutputMessage(Messages._fnsTextMessageByIndex(206),
                         System.True);

{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(207),
                                        aModuleTypist);
    {if-then}
{$ENDIF} {DebVer}
    CallBack._GetFreeItemDataDict(System.Pointer(pEnvDesc),
                                  System.SizeOf(Globals.recEnvironmentDesc));

    WITH  (pEnvDesc^)  DO
    BEGIN
{$IFDEF   DebVer}
       IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
           THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(208),
                                           aModuleTypist);
       {if-then}
{$ENDIF} {DebVer}
       dwIdleModeHotkey            :=   Globals.gdwCurIdleModeHotkey;
       dwManualModeHotkey          :=   Globals.gdwCurManualModeHotkey;
       dwAddModeHotkey             :=   Globals.gdwCurAddModeHotkey;
       dwSearchModeHotkey          :=   Globals.gdwCurSearchModeHotkey;
       dwEnvironmentHotKey         :=   Globals.gdwCurEnvironmentHotKey;
       dwVideoIndicationHotKey     :=   Globals.gdwCurVideoIndicationHotKey;
       dbIdleModeScanCode          :=   Globals.gdbCurIdleModeScanCode;
       dbManualModeScanCode        :=   Globals.gdbCurManualModeScanCode;
       dbAddModeScanCode           :=   Globals.gdbCurAddModeScanCode;
       dbSearchModeScanCode        :=   Globals.gdbCurSearchModeScanCode;
       dbEnvironmentScanCode       :=   Globals.gdbCurEnvironmentScanCode;
       dbVideoIndicationScanCode   :=   Globals.gdbCurVideoIndicationScanCode;
       dwInitSearchFlags           :=   Globals.gdwCurInitSearchFlags;
       dwUserEnvOptions            :=   Globals.gdwCurUserEnvOptions;
       dbColorVideoAttr            :=   Globals.gdbCurColorVideoAttr;
       dbMonoVideoAttr             :=   Globals.gdbCurMonoVideoAttr;
       chForwardSearchSymbol       :=   Globals.gchCurForwardSearchSymbol;
       chBackwardSearchSymbol      :=   Globals.gchCurBackwardSearchSymbol;
       chNonSpecialSymbol          :=   Globals.gchCurNonSpecialSymbol;
       chSearchAbbrevSymbol        :=   Globals.gchCurSearchAbbrevSymbol;
       chSearchExpressionSymbol    :=   Globals.gchCurSearchExpressionSymbol;
       chDirectionSearchOrderSym   :=   Globals.gchCurDirectionSearchOrderSym;
       chDictSearchOrderSym        :=   Globals.gchCurDictSearchOrderSym;
       chCaseSearchSym             :=   Globals.gchCurCaseSearchSym;
       chMiddleSrchSym             :=   Globals.gchCurMiddleSrchSym;
       chBreakInputSym             :=   Globals.gchCurBreakInputSym;
       chSingleWordSearchSym       :=   Globals.gchCurSingleWordSearchSym;
       sDictComment32              :=   Globals.gsCurDictComment32;
       sDelimiters16               :=   Globals.gsCurDelimiters16;
       chAutoAddChar               :=   Globals.gchCurAutoAddChar;
       chDelimDefinitionSym        :=   Globals.gchCurDelimDefinitionSym;
       chNonDefSym                 :=   Globals.gchCurNonDefSym;
       chOpenNumericSym            :=   Globals.gchCurOpenNumericSym;
       chCloseNumericSym           :=   Globals.gchCurCloseNumericSym;
       dbSearchType                :=   Globals.gdbCurSearchType;
       sDictName16                 :=   Globals.gsCurDictName16;
       pForwardSearchAbbrevTable   :=   NIL;
       pBackwardSearchAbbrevTable  :=   NIL;
       pForwardSearchDictTable     :=   NIL;
       pBackwardSearchDictTable    :=   NIL;
       pStrSizeSearchAbbrevTable   :=   NIL;
       pStrSizeSearchDictTable     :=   NIL;
       pFreePointer                :=   NIL;
       dwFreeSize                  :=   0;
       dbActiveModeBorder          :=   Globals.gdbCurActiveModeBorder;
       dbIdleModeBorder            :=   Globals.gdbCurIdleModeBorder;
       System.Move(Globals.gchCurCaseMapArray256,chCaseMapArray256,Globals.aMaxCharBit8+1);
       System.Move(Globals.gdbCurScanCodeTable256,dbScanCodeTable256,Globals.aMaxCharBit8+1);
       System.Move(Globals.gdbCurWordCharTable256,dbWordCharTable256,Globals.aMaxCharBit8+1);

{$IFDEF   DebVer}
       IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
           THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(209),
                                           aModuleTypist);
       {if-then}
{$ENDIF} {DebVer}
       IF  (Globals.gbLink_FA_Ok)
         THEN _AllocHeadLinkTableSpace(pForwardSearchAbbrevTable,Globals.btForwardSearchAbbreviation);
       {if-then}
       IF  (Globals.gbLink_BA_Ok)
         THEN _AllocHeadLinkTableSpace(pBackwardSearchAbbrevTable,Globals.btBackwardSearchAbbreviation);
       {if-then}
       IF  (Globals.gbLink_FE_Ok)
         THEN _AllocHeadLinkTableSpace(pForwardSearchDictTable,Globals.btForwardSearchExpression);
       {if-then}
       IF  (Globals.gbLink_BE_Ok)
         THEN _AllocHeadLinkTableSpace(pBackwardSearchDictTable,Globals.btBackwardSearchExpression);
       {if-then}
       IF  (Globals.gbLink_AS_Ok)
         THEN _AllocHeadLinkTableSpace(pStrSizeSearchAbbrevTable,Globals.btSearchAbbreviationSizes);
       {if-then}
       IF  (Globals.gbLink_ES_Ok)
         THEN _AllocHeadLinkTableSpace(pStrSizeSearchDictTable,Globals.btSearchExpressionSizes);
       {if-then}
    END;
    {with-do}

{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(210),
                                        aModuleTypist);
    {if-then}
{$ENDIF} {DebVer}
    _AddNextDictSearchTable(@Globals.gDirectSearchArray,pEnvDesc);
    CallBack._AddNewEnvToEnvList(pEnvDesc,Globals.gdwEnvDictHandle);
    CallBack._CopyGlobalFreeDataSpacePointerToEnvironment(Globals.gdwEnvDictHandle);
END;
{ _BuildMemoryEnvironmentAndDictionary }



PROCEDURE
         _SetupProgramDefaultsAfterUserParametersParsing;
{*
Description.
    Setup all the program parameters.
*}
CONST
    rDiv     :     System.Real   =  1193183/1.0E+9;
              { maximum estimated time interval = ~55 ms  }
              { minimum estimated time interval = ~838 ns }
VAR
  rExecTime             :   System.Real;
  sTempInput,
  sSrchPattern          :       STRING;
  liMaxUMABlockSize,
  liMaxCMABlockSize     :       System.Longint;
  lpResidentPart,
  lpIntVec09,
  lpIntVec08,
  lpIntVec2F,
  lpIntVec16,
  lpIntVec15,
  lpTemp                :       System.Pointer;
  dbTemp,
  dbIndex               :       System.Byte;
  dwNewFreeSize,
  dwResidentSeg,
  dwTemp,
  dwTempOfs,
  dwStrLen,
  dwFlags,
  dwReplaces,
  dwCodeBlockSeg,
  dwDataBlockSeg,
  dwEnvDictHandle       :       System.Word;
  bFreeMemOk,
  bAllocMemOk,
  bFilterState,
  bUserChannelInUse     :       System.Boolean;

{$IFDEF   TstVer}
PROCEDURE
          _RunningInTestOrDemoMode;
{*
Description.
    Test or demo modes of program.
*}
BEGIN
    Video._OutputMessage(Messages._fnsTextMessageByIndex(229),
                         System.True);
    CallBack._SelectNewEnv(Globals.gdwEnvDictHandle);
    IF  (Globals.gbEnvDiagDumpOk)
      THEN  DictMem._DoEnvDiagDump;
    {if-then}
    Video._OutputMessage(Messages._fnsTextMessageByIndex(230)+
                   CallBack._fnsGetCurrentKeyboardModeDesc(CallBack._fndbGetCurrentKeyboardMode),
                   System.True);
    Video._OutputMessageNoLF(Messages._fnsTextMessageByIndex(231),
                             System.True);
    System.ReadLn(dbTemp);
    CASE  (dbTemp)  OF
           0    :    BEGIN
                  bFilterState := System.False;
                     END;
           1    :    BEGIN
                  bFilterState := System.True;
                     END;
    ELSE
       Video._HaltProgram(Messages._fnsTextMessageByIndex(232),
                          Globals.errBadLogicalValue);
    END;
    {case-of}
    CallBack._SetFilterRawUserInputFlag(bFilterState);
    Video._OutputMessageNoLF(Messages._fnsTextMessageByIndex(336),
                             System.True);
    System.ReadLn(dbTemp);
    CASE  (dbTemp)  OF
           0    :    BEGIN
                  bFilterState := System.False;
                     END;
           1    :    BEGIN
                  bFilterState := System.True;
                     END;
    ELSE
       Video._HaltProgram(Messages._fnsTextMessageByIndex(232),
                          Globals.errBadLogicalValue);
    END;
    {case-of}
    CallBack._SetEstimateTimerFlag(bFilterState);
    CallBack._GetFreeSpaceForDataDict(Globals.glpFreeMemoryDictPool,Globals.gdwFreeSpaceInDictMem);
    Video._OutputMessageNoLF(Messages._fnsTextMessageByIndex(233),
                             System.True);
    System.ReadLn(Globals.gsTemp);
    IF  (Globals.gsTemp <> Globals.asBlank)
      THEN  BEGIN
        IF  NOT(DosCtl._fnbReleaseLowMemBlock(System.MemW[System.PrefixSeg:Globals.aDosEnvSeg]))
          THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(234),
                                   Globals.errBadEnvProgramMemoryUninstall);
        {if-then}
        dwTemp := System.Ofs(_DummyProc) -
                  Globals.gdwFreeSpaceInDictMem;
        Globals.gdwResidentPartInParas := (dwTemp +
                                           Globals.gdwFreeSpaceSize +
                                           Globals.aBytesPerParagraph) SHR 4;
        dwNewFreeSize := (System.Longint(Globals.gdwResidentPartInParas) SHL 4) - dwTemp + 1;
        CallBack._AllocNewFreeSpace(Globals.glpFreeMemoryDictPool,dwNewFreeSize);
        CallBack._CopyGlobalFreeDataSpacePointerToEnvironment(Globals.gdwEnvDictHandle);
        Video._OutputMessage(Messages._fnsTextMessageByIndex(235),
                             System.True);
        Dos.SwapVectors;
        {last report}
        Video._OutputMessage(Messages._fnsTextMessageByIndex(7),
                             System.True);
        IF  (Globals.gbHighMemOk)
        THEN  BEGIN
           System.MemW[(dwCodeBlockSeg-1):1] := Globals.adwEXT_MPID_1; {special}
           ASM
                    mov       ax, (Globals.aTerminateProcess SHL 8) + Globals.errTerminateOK
                    int       Globals.aDosServicesInt
           END;
           {asm-end}
              END
        ELSE  BEGIN
           ASM
                    mov       dx, Globals.gdwResidentPartInParas
                    add       dx, Globals.aPSP_Size SHR 4
                    mov       ax, (Globals.aKeepResident SHL 8) + Globals.errTerminateOK
                    int       Globals.aDosServicesInt
           END;
           {asm-end}
              END;
        {if-then-else}
             END;
    {if-then}
    sSrchPattern := 'skip  ~new~ ~added new entry for \~add\~~  skip';
    Video._OutputMessage(Messages._fnsTextMessageByIndex(236)+sSrchPattern,
                         System.True);
    CallBack._AddNewEntryInDictionary(sSrchPattern,System.Length(sSrchPattern),dbTemp);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(408)+
                         StrLib._fnsByteToTurboHexFmt(dbTemp)+
                         ' ('+
                         CallBack._fnsGetMultiplexReturnCodeDesc(dbTemp)+
                         ')',
                         System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(244)+
                   StrLib._fnsDisplayStrAsHexDecAndAscii(CallBack._fnsGetRawUserInput,System.False),
                   System.True);
    CallBack._GetStateSearchUserInput(sTempInput,dwStrLen,dwFlags,dwReplaces);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(245)+
                         StrLib._fnsNumToStr(dwStrLen,5),
                         System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(246)+
                         StrLib._fnsNumToStr(dwReplaces,5),
                         System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(247)+
                   Globals.achHexPrefix+StrLib._fnsWordToHexFmt(dwFlags),
                   System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(248)+
                   StrLib._fnsDisplayStrAsHexDecAndAscii(sTempInput,System.False),
                   System.True);
    _GetFoundStrToReplace(sTempInput,dwStrLen);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(237)+
                   StrLib._fnsDisplayStrAsHexDecAndAscii(sTempInput,System.False),
                   System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(238)+
                   StrLib._fnsNumToStr(dwStrLen,5),
                   System.True);

    sSrchPattern := 'ds! xaxa_#*/!il  ' {'al^$#' '#*/%!eLl' '#*/!fan'};
    Video._OutputMessage(Messages._fnsTextMessageByIndex(236)+
                         '"'+sSrchPattern+'"',
                         System.True);
    CallBack._FindMatchEntryInDictionary(sSrchPattern,
                                         System.Length(sSrchPattern),
                                         sTempInput,
                                         dwStrLen);
    CallBack._GetEstimateTimer(bFilterState,dwTemp);
    IF  (bFilterState)
      THEN  BEGIN
        rExecTime :=  dwTemp/rDiv;
        Video._OutputMessage(Messages._fnsTextMessageByIndex(338)+
                             _fnsNumToRealStr((rExecTime/1.0E6),6,3),
                             System.True);
            END
      ELSE  BEGIN
        Video._OutputMessage(Messages._fnsTextMessageByIndex(337),
                             System.True);
            END;
    {if-then}
    Video._OutputMessage(Messages._fnsTextMessageByIndex(237)+
                   StrLib._fnsDisplayStrAsHexDecAndAscii(sTempInput,System.False),
                   System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(238)+
                         StrLib._fnsNumToStr(dwStrLen,5),
                         System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(239),
                         System.True);
    CallBack._SetCurrentKeyboardMode(Globals.aStateIsManualMode);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(230)+
                   CallBack._fnsGetCurrentKeyboardModeDesc(CallBack._fndbGetCurrentKeyboardMode),
                   System.True);
    Video._OutputMessageNoLF(Messages._fnsTextMessageByIndex(241),
                             System.True);
{$IFDEF   DemVer}
    IF  (Globals.gbDemoModeOk)
       THEN  BEGIN
          DemoMode._InitStringToSimulateUserInput('User simulation test DONE '+
                      Globals.achBS+Globals.achBS+Globals.achBS+Globals.achBS+Globals.achBS+
                      'complete !!!');
          DemoMode._SetupTimerIntInSimulationMode;
             END;
    {if-then}
{$ENDIF} {DemVer}
    System.ReadLn(sTempInput);
    CallBack._GetEstimateTimer(bFilterState,dwTemp);
    IF  (bFilterState)
      THEN  BEGIN
        rExecTime :=  dwTemp/rDiv;
        Video._OutputMessage(Messages._fnsTextMessageByIndex(338)+
                             StrLib._fnsNumToRealStr((rExecTime/1.0E6),6,3),
                             System.True);
            END
      ELSE  BEGIN
        Video._OutputMessage(Messages._fnsTextMessageByIndex(337),
                             System.True);
            END;
    {if-then}
    Video._OutputMessage(Messages._fnsTextMessageByIndex(242),
                         System.True);
    CallBack._SetCurrentKeyboardMode(Globals.aStateIsIdleMode);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(230)+
                   CallBack._fnsGetCurrentKeyboardModeDesc(CallBack._fndbGetCurrentKeyboardMode),
                   System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(243)+sTempInput,
                         System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(244)+
                   StrLib._fnsDisplayStrAsHexDecAndAscii(CallBack._fnsGetRawUserInput,System.False),
                   System.True);
    CallBack._GetStateSearchUserInput(sTempInput,
                                      dwStrLen,
                                      dwFlags,
                                      dwReplaces);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(245)+
                         StrLib._fnsNumToStr(dwStrLen,5),
                         System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(246)+
                         StrLib._fnsNumToStr(dwReplaces,5),
                         System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(247)+
                   Globals.achHexPrefix+StrLib._fnsWordToHexFmt(dwFlags),
                   System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(248)+
                   StrLib._fnsDisplayStrAsHexDecAndAscii(sTempInput,System.False),
                   System.True);
    CallBack._GetFoundStrToReplace(sTempInput,dwStrLen);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(237)+
                   StrLib._fnsDisplayStrAsHexDecAndAscii(sTempInput,System.False),
                   System.True);
    Video._OutputMessage(Messages._fnsTextMessageByIndex(238)+
                   StrLib._fnsNumToStr(dwStrLen,5),
                   System.True);
    IF  (Globals.gbEnvDiagDumpOk)
      THEN  DictMem._DoEnvDiagDump;
    {if-then}
    IF  (Globals.gbStatDiagDumpOk)
      THEN   DictMem._DoStatDiagDump;
    {if-then}
END;
{ _RunningInTestOrDemoMode }
{$ENDIF} {TstVer}

BEGIN
{$IFDEF   DebVer}
  IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
       THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(249),
                                       aModuleTypist);
  {if-then}
{$ENDIF} {DebVer}

  {check true size of resident part}
{$IFDEF   DebVer}
  IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
       THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(250),
                                       aModuleTypist);
  {if-then}
{$ENDIF} {DebVer}
  dwTempOfs := System.Ofs(_DummyProc) - System.Ofs(_FreeDataSpace);
  IF (dwTempOfs < Globals.aFreeSpaceMax)
    THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(251),
                             Globals.errBadFreeSpaceSize);
  {if-then}

  {init some variables}
     IF (Globals.gdwMaxScreenLines = Globals.aDisableScreenPage)
        THEN  Globals.gdwTextLineNum := Globals.aDisableScreenPage;
     {if-then}

  {patch interrupt service}
  _PatchCallBackInterface;

   {save some system information}
     DosCtl._SaveCurrentVectors;

  {dumps memory reserve option}
  IF  (Globals.gdwFreeSpaceSize <> 0)
    THEN  Video._OutputMessage(Messages._fnsTextMessageByIndex(402)+
                               StrLib._fnsNumToStr(Globals.gdwFreeSpaceSize,5)+
                               Messages._fnsTextMessageByIndex(254),
                               System.True);
  {if-then}

  {check user specified channel}
  bUserChannelInUse := System.False;
  IF  (Globals.gdbUserMultiplexChannel <> Globals.grecUserMultChannelParm.dbDefaultValue)
    THEN  BEGIN
      IF  NOT(CallBack._fnbIsFreeMultChannel(Globals.gdbUserMultiplexChannel))
        THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(252),
                                 Globals.errBadUserChannel)
        ELSE  bUserChannelInUse := System.True;
     {if-then-else}
          END;
  {if-then}

  {see available memory information}
  liMaxCMABlockSize := DosCtl._fnliCMB_MaxAvail;
{$IFDEF   DebVer}
       IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
            THEN  BEGIN
               Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(560)+
                                         StrLib._fnsNumToStr(liMaxCMABlockSize,6)+
                                         Messages._fnsTextMessageByIndex(254),
                                         aModuleTypist);
                  END;
       {if-then}
{$ENDIF} {DebVer}
  IF  (Globals.gbHighMemOk)
    THEN  BEGIN
       liMaxUMABlockSize := DosCtl._fnliUMB_MaxAvail;
{$IFDEF   DebVer}
       IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
            THEN  BEGIN
               Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(253)+
                                         StrLib._fnsNumToStr(liMaxUMABlockSize,6)+
                                         Messages._fnsTextMessageByIndex(254),
                                         aModuleTypist);
                  END;
       {if-then}
{$ENDIF} {DebVer}
       IF  (liMaxUMABlockSize = 0)
         THEN  BEGIN
           Globals.gbHighMemOk := System.False;
{$IFDEF   DebVer}
       IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
            THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(427),
                                            aModuleTypist);
       {if-then}
{$ENDIF} {DebVer}
               END;
       {if-then}
          END;
  {if-then}


  {display any help for some active users}
     IF (Globals.gdbUserHelpRequest)
       THEN  Video._DisplayProgramHelp;
     {if-then}
     IF (Globals.gbHelpFileOk)
       THEN  BEGIN
          {look (1) current directory                        }
          {     (2) directory defined by environment variable}
          Video._DisplayHelpFile(Globals.gsHelpFileName,System.False);
          Video._DisplayHelpFile(Globals.gsDefaultConfigPath+Globals.gsHelpFileName,System.True);
             END;
     {if-then}

  {initialiaze dictionary entries links}
   FOR  dbIndex := Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
   BEGIN
       Globals.gDirectSearchArray[dbIndex] := NIL;
       Globals.gSymFrequencyNodesArrayFA[dbIndex] := 0;
       Globals.gSymFrequencyNodesArrayBA[dbIndex] := 0;
       Globals.gSymFrequencyNodesArrayFE[dbIndex] := 0;
       Globals.gSymFrequencyNodesArrayBE[dbIndex] := 0;
       Globals.gAbbrevSizesFrequencyNodesArray[dbIndex] := 0;
       Globals.gExprSizesFrequencyNodesArray[dbIndex] := 0;
   END;
   {for-to-do}

  {check for configuration file presence}
    IF  (Globals.gsConfigFileName <> Globals.asBlank)
      THEN  BEGIN
         {look (1) current directory                        }
         {     (2) directory defined by environment variable}
         Globals.gsConfigFileName  := StrLib._fnsForceFileExtension(Globals.gsConfigFileName,Globals.asDefCfgExt);
         Config._ParseConfigFile(gsConfigFileName,System.False);
         IF NOT(Globals.gbConfigDone)
           THEN  Config._ParseConfigFile(Globals.gsDefaultConfigPath+Globals.gsConfigFileName,System.True);
         {if-then}
         Globals.gbLoadDataDict := System.True;
            END;
    {if-then}

   {some diagnostics}
     IF  (Globals.gbDictDiagDumpOk)
       THEN   UserDict._DoDictDiagDump(System.True);
     {if-then}

   {sorting of dictionary}
   IF (Globals.gdbSortByAlphabet <> Globals.aNoneSortingOrder) OR
      (Globals.gdbSortBySize <> Globals.aNoneSortingOrder)
     THEN  UserDict._SortUserDictionaryOfAbbreviations;
   {if-then}

   {some diagnostics}
     IF  (Globals.gbDictDiagDumpOk)
       THEN   UserDict._DoDictDiagDump(System.False);
     {if-then}

   {check dictionary size for enough memory}
   {if option of nodes compression was used then we'll get non-exact info}
{$IFDEF   DebVer}
   IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
      THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(561)+
                                      StrLib._fnsNumToStr(Globals.gdwEstimatedDictSize,5)+
                                      Messages._fnsTextMessageByIndex(254),
                                      aModuleTypist);
   {if-then}
{$ENDIF} {DebVer}
   IF  ((Globals.gbHighMemOk) AND
        (liMaxUMABlockSize < Globals.gdwEstimatedDictSize))
     THEN  Globals.gbHighMemOk := System.False;
   {if-then}

   {look for resident part}
     Globals.gdbCurMultiplexChannel := CallBack._fndbCheckForInstallation;
     IF  (Globals.gdbCurMultiplexChannel <> 0)
       THEN  Globals.gbResidentPartFound := System.True;
     {if-then}

   {look for free multiplex slot}
     dbTemp := CallBack._fndbFindFirstFreeMultChannel;
     IF (dbTemp = 0) AND (Globals.gdbCurMultiplexChannel = 0)
       THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(256),
                                Globals.errNoFreeMultSlot)
       ELSE  Globals.gdbFreeMultiplexChannel := dbTemp;
     {if-then-else}

   {set multiplex channel for interaction}
    IF (Globals.gbResidentPartFound)
      THEN  BEGIN
{$IFDEF   DebVer}
          IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
               THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(257),
                                               aModuleTypist);
          {if-then}
{$ENDIF} {DebVer}
          IF  (Globals.gdbRunTimerVal <> Globals.aNoneTimer)
            THEN  CallBack._SetupEstimateTimer(Globals.gdbRunTimerVal);
          {if-then}
          IF  (Globals.gbTsrInfoOk)
            THEN  CallBack._DoResidentPartDiagDump;
          {if-then}
{$IFDEF   StaVer}
          IF  (Globals.gbResetStatOk)
            THEN   CallBack._ResetTypingStat;
          {if-then}
          IF  (Globals.gbDispTypingStatOk)
            THEN   CallBack._DispTypingStat;
          {if-then}
          IF  (Globals.gdwStatTime <> 0)
            THEN   CallBack._RunTypingStat(Globals.gdwStatTime,
                                           Globals.gbHighMemOk);
          {if-then}
{$ENDIF} {StaVer}
          IF  (Globals.gbStatDiagDumpOk)
            THEN   DictMem._DoStatDiagDump;
          {if-then}
          IF  (Globals.gbEnvDiagDumpOk)
            THEN  DictMem._DoEnvDiagDump;
          {if-then}
          IF  (Globals.gbLoadOk)
            THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(258),
                                      Globals.errMemoryCopyFoundAtLoading);
          {if-then}
          IF  (Globals.gsSetDictName <> Globals.asBlank)
            THEN  BEGIN
                dwEnvDictHandle := CallBack._fndwTransDictNameToEnvHandle(Globals.gsSetDictName);
                IF  (dwEnvDictHandle = 0)
                  THEN  BEGIN
                    Video._HaltProgram(Messages._fnsTextMessageByIndex(259),
                                        Globals.errBadMemoryCopyOfUserDict);
                        END
                  ELSE  BEGIN
                    CallBack._SelectNewEnv(dwEnvDictHandle);
                    Video._OutputMessage(Messages._fnsTextMessageByIndex(260)+
                                         ''''+
                                         CallBack._fnsTransEnvHandleToDictName(dwEnvDictHandle)+
                                         ''''+
                                         Messages._fnsTextMessageByIndex(563),
                                         System.True);
                        END;
                {if-then-else}
                  END;
          {if-then}
          IF  (Globals.gsRemoveDictName <> asBlank)
            THEN  BEGIN
               CallBack._RemoveDictByName(gsRemoveDictName);
                  END;
          {if-then}
          IF  (Globals.gbListAllOk)
            THEN  BEGIN
                CallBack._ListAllLoadedDictionaries;
                  END;
          {if-then}
          IF  (Globals.gbAddDictOk) AND (Globals.gbLoadDataDict)
            THEN  BEGIN
             IF  (CallBack._fndwTransDictNameToEnvHandle(Globals.gsCurDictName16) <> 0)
               THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(261),
                                         Globals.errDictAlreadyLoaded);
             {if-then}
             lpResidentPart := CallBack._fnlpGetResidentPartStart;
             dwResidentSeg := System.Seg(lpResidentPart^);
             IF  (Globals.gbHighMemOk) AND (liMaxUMABlockSize <> 0)
               THEN  BEGIN
                 dwTemp := (liMaxUMABlockSize AND $FFF0) SHR 4;
                 dwTempOfs := dwTemp SHL 4;
                 IF  (DosCtl._fnbAllocHighMemBlock(dwTemp,lpTemp))
                    THEN  BEGIN
                      dwDataBlockSeg := System.Seg(lpTemp^);
{$IFDEF   DebVer}
                      IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                           THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(262),
                                                           aModuleTypist);
                      {if-then}
{$ENDIF} {DebVer}
                      System.FillChar(System.Mem[dwDataBlockSeg:$0],
                                      dwTempOfs,
                                      Globals.achNULL);
                      CallBack._AllocNewFreeSpace(lpTemp,dwTempOfs);
{$IFDEF   DebVer}
                     IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                        THEN  CallBack._DumpFreeSpaceInfo(dwTempOfs);
                     {if-then}
{$ENDIF} {DebVer}
                     _BuildMemoryEnvironmentAndDictionary;
{$IFDEF   DebVer}
                     IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                        THEN  BEGIN
                           CallBack._DumpFreeSpaceInfo(dwTempOfs);
                           CallBack._DisplayEnvList;
                               END;
                     {if-then}
{$ENDIF} {DebVer}
                     bAllocMemOk := System.True;
                     CallBack._SelectNewEnv(Globals.gdwEnvDictHandle);
                     CallBack._GetFreeSpaceForDataDict(Globals.glpFreeMemoryDictPool,Globals.gdwFreeSpaceInDictMem);
                     dwTempOfs := dwTempOfs - Globals.gdwFreeSpaceInDictMem;
                     dwTemp := (dwTempOfs +
                                Globals.aBytesPerParagraph +
                                Globals.gdwFreeSpaceSize) SHR 4;
                     dwNewFreeSize := (System.Longint(dwTemp) SHL 4) - dwTempOfs;
                     CallBack._AllocNewFreeSpace(Globals.glpFreeMemoryDictPool,dwNewFreeSize);
                     CallBack._CopyGlobalFreeDataSpacePointerToEnvironment(Globals.gdwEnvDictHandle);
                     IF  NOT(DosCtl._fnbResizeMemBlock(dwDataBlockSeg,dwTemp))
                       THEN  BEGIN
                         CallBack._ResetCurrentFreeDataSpacePointer;
                         Video._HaltProgram(Messages._fnsTextMessageByIndex(263),
                                            Globals.errBadHighMemoryToReszie);
                             END;
                     {if-then}
                     System.MemW[(dwDataBlockSeg-1):$1] := dwResidentSeg;
                     Video._OutputMessage(Messages._fnsTextMessageByIndex(218)+
                                          ''''+Globals.gsCurDictName16+''''+
                                          Messages._fnsTextMessageByIndex(266),
                                          System.True);
                          END
                    ELSE  BEGIN
                      Video._HaltProgram(Messages._fnsTextMessageByIndex(264),
                                         Globals.errBadHighMemoryToInstall);
                          END;
                 {if-then-else}
                     END
               ELSE  BEGIN
                 dwTempOfs := System.Ofs(_DummyProc) AND $FFF0;  {align in paras}
                 dwDataBlockSeg := System.CSeg;
                 Globals.gbUseAltCall := System.True; {!!We WIPE OUT }
                                                      {our main code block!!}
                 _InitCallBackIndexTable(@Globals.glpNearCallIndexTable);
{$IFDEF   DebVer}
                 IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                      THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(265),
                                                      aModuleTypist);
                 {if-then}
{$ENDIF} {DebVer}
                 System.FillChar(System.Mem[dwDataBlockSeg:$0],
                                 System.Ofs(_FreeDataSpace),
                                 Globals.achNULL);
                 bAllocMemOk := System.True;
                 CallBack._AllocNewFreeSpace(@_KeyboardHandler,dwTempOfs);
{$IFDEF   DebVer}
                IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                   THEN  CallBack._DumpFreeSpaceInfo(dwTempOfs);
                {if-then}
{$ENDIF} {DebVer}
                _BuildMemoryEnvironmentAndDictionary;
{$IFDEF   DebVer}
                IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                   THEN  BEGIN
                      CallBack._DumpFreeSpaceInfo(dwTempOfs);
                      CallBack._DisplayEnvList;
                          END;
                {if-then}
{$ENDIF} {DebVer}
                IF  NOT(DosCtl._fnbReleaseLowMemBlock(System.MemW[System.PrefixSeg:Globals.aDosEnvSeg]))
                  THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(234),
                                           Globals.errBadEnvProgramMemoryUninstall);
                {if-then}
                CallBack._SelectNewEnv(Globals.gdwEnvDictHandle);
                CallBack._GetFreeSpaceForDataDict(Globals.glpFreeMemoryDictPool,Globals.gdwFreeSpaceInDictMem);
                dwTemp := dwTempOfs -
                          Globals.gdwFreeSpaceInDictMem;
                Globals.gdwResidentPartInParas := (dwTemp +
                                                   Globals.gdwFreeSpaceSize +
                                                   Globals.aBytesPerParagraph) SHR 4;
                dwNewFreeSize := (System.Longint(Globals.gdwResidentPartInParas) SHL 4) - dwTemp;
                CallBack._AllocNewFreeSpace(Globals.glpFreeMemoryDictPool,dwNewFreeSize);
                CallBack._CopyGlobalFreeDataSpacePointerToEnvironment(Globals.gdwEnvDictHandle);
                Video._OutputMessage(Messages._fnsTextMessageByIndex(218)+
                                     ''''+Globals.gsCurDictName16+''''+
                                     Messages._fnsTextMessageByIndex(267),
                                     System.True);
                Dos.SwapVectors;
                {last report}
                Video._OutputMessage(Messages._fnsTextMessageByIndex(7),
                                     System.True);
                ASM
                            mov       dx, Globals.gdwResidentPartInParas
                            add       dx, Globals.aPSP_Size SHR 4
                            mov       ax, (Globals.aKeepResident SHL 8) + Globals.errTerminateOK
                            int       Globals.aDosServicesInt
                END;
                {asm-end}
                     END;
             {if-then-else}
                  END;
          {if-then}
          IF  (Globals.gbUnLoadOk)
            THEN  BEGIN
              lpIntVec08 := CallBack._fnlpGetPrevIntVecIntoHandler(Globals.aHardTimerInt);
              lpIntVec09 := CallBack._fnlpGetPrevIntVecIntoHandler(Globals.aHardKbdInt);
              lpIntVec15 := CallBack._fnlpGetPrevIntVecIntoHandler(Globals.aServerInt);
              lpIntVec16 := CallBack._fnlpGetPrevIntVecIntoHandler(Globals.aSoftKbdInt);
              lpIntVec2F := CallBack._fnlpGetPrevIntVecIntoHandler(Globals.gdbCallBackIntNum);
              lpResidentPart := CallBack._fnlpGetResidentPartStart;
              dwResidentSeg := System.Seg(lpResidentPart^);
              IF  ((System.Ptr(dwResidentSeg,Globals.aDWord*0) = Globals.glpCurIntVec15) AND
                   (System.Ptr(dwResidentSeg,Globals.aDWord*1) = Globals.glpCurIntVec16) AND
                   (System.Ptr(dwResidentSeg,Globals.aDWord*2) = Globals.glpCurIntVec2F) AND
                   (System.Ptr(dwResidentSeg,Globals.aDWord*3) = Globals.glpCurIntVec08) AND
                   (System.Ptr(dwResidentSeg,Globals.aDWord*4) = Globals.glpCurIntVec09))
                THEN  BEGIN
{$IFDEF   DebVer}
                    IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                         THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(268),
                                                         aModuleTypist);
                    {if-then}
{$ENDIF} {DebVer}
                    IF (lpIntVec08 <> NIL)
                      THEN  Globals.glpCurIntVec08 := lpIntVec08;
                    {if-then}
                    IF (lpIntVec09 <> NIL)
                      THEN  Globals.glpCurIntVec09 := lpIntVec09;
                    {if-then}
                    IF (lpIntVec15 <> NIL)
                      THEN  Globals.glpCurIntVec15 := lpIntVec15;
                    {if-then}
                    IF (lpIntVec16 <> NIL)
                      THEN  Globals.glpCurIntVec16 := lpIntVec16;
                    {if-then}
                    IF (lpIntVec2F <> NIL)
                      THEN  Globals.glpCurIntVec2F := lpIntVec2F;
                    {if-then}
                    CallBack._RemoveAllDictionariesFromMemory;
{$IFDEF   StaVer}
                    IF  (CallBack._bIsMemBlockInStatBlockPresent)
                       THEN  CallBack._ResetTypingStat;
                    {if-then}
{$ENDIF} {StaVer}
                    DosCtl._RestoreCurrentVectors;
{$IFDEF   DebVer}
                    IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                         THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(269),
                                                         aModuleTypist);
                    {if-then}
{$ENDIF} {DebVer}
                    IF  (DosCtl._fnbIsLowMemBlock(dwResidentSeg))
                      THEN  BEGIN
{$IFDEF   DebVer}
                       IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                            THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(270),
                                                            aModuleTypist);
                       {if-then}
{$ENDIF} {DebVer}
                        bFreeMemOk := DosCtl._fnbReleaseLowMemBlock(dwResidentSeg-Globals.aPSP_Size_In_Paras);
                            END
                      ELSE  BEGIN
{$IFDEF   DebVer}
                       IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                            THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(271),
                                                            aModuleTypist);
                       {if-then}
{$ENDIF} {DebVer}
                        bFreeMemOk := DosCtl._fnbReleaseHighMemBlock(dwResidentSeg);
                            END;
                    {if-then-else}
                    IF  NOT(bFreeMemOk)
                      THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(272),
                                               Globals.errBadProgramMemoryUninstall);
                    {if-then}
                    Video._OutputMessage(Messages._fnsTextMessageByIndex(273),
                                         System.True);
                      END
                ELSE  BEGIN
                  Video._HaltProgram(Messages._fnsTextMessageByIndex(274),
                                     Globals.errOtherProgramsOwnIntVecs);
                      END;
              {if-then-else}
                  END;
            END
      ELSE  BEGIN
          IF  (Globals.gbUnLoadOk)
            THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(275),
                                     Globals.errNoMemoryCopyFoundAtUnloading);
          {if-then}
          IF (Globals.gbLoadOk)
            THEN  BEGIN
{$IFDEF   DebVer}
               IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                    THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(276),
                                                    aModuleTypist);
               {if-then}
{$ENDIF} {DebVer}
               IF (bUserChannelInUse)
                 THEN  Globals.gdbCurMultiplexChannel := Globals.gdbUserMultiplexChannel
                 ELSE  Globals.gdbCurMultiplexChannel := Globals.gdbFreeMultiplexChannel;
               {if-then-else}
              IF  (Globals.gbTestModeOk)
                THEN  dwTempOfs := System.Ofs(_DummyProc) 
                ELSE  dwTempOfs := System.Ofs(_FreeDataSpace)+Globals.gdwFreeSpaceSize;
              {if-then-else}
              IF  (Globals.gbHighMemOk) AND (liMaxUMABlockSize > dwTempOfs)
                THEN  BEGIN
{$IFDEF   DebVer}
                   IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(277),
                                                        aModuleTypist);
                   {if-then}
{$ENDIF} {DebVer}
                   dwTemp := (dwTempOfs SHR 4) + 1;
                   IF  (DosCtl._fnbAllocHighMemBlock(dwTemp,lpTemp))
                     THEN  BEGIN
                        dwCodeBlockSeg := System.Seg(lpTemp^);
{$IFDEF   DebVer}
                        IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                             THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(278)+
                                                             StrLib._fnsPointerToTurboHexFmt(lpTemp)+
                                                             Messages._fnsTextMessageByIndex(279)+
                                                             StrLib._fnsNumToStr((dwTemp SHL 4),6)+
                                                             Messages._fnsTextMessageByIndex(254),
                                                             aModuleTypist);
                        {if-then}
{$ENDIF} {DebVer}
{$IFDEF   DebVer}
                        IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                             THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(262),
                                                             aModuleTypist);
                        {if-then}
{$ENDIF} {DebVer}
                        System.FillChar(System.Mem[dwCodeBlockSeg:$0],
                                        dwTempOfs,
                                        Globals.achNULL);
{$IFDEF   DebVer}
                        IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                             THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(280),
                                                             aModuleTypist);
                        {if-then}
{$ENDIF} {DebVer}
                        System.Move(System.Mem[System.Seg(_KeyboardHandler):System.Ofs(_KeyboardHandler)],
                                    System.Mem[dwCodeBlockSeg:$0],
                                    dwTempOfs);
                           END
                     ELSE  BEGIN
                        dwCodeBlockSeg := System.CSeg;
                        Globals.gbHighMemOk := System.False;
{$IFDEF   DebVer}
                        IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                             THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(281),
                                                             aModuleTypist);
                        {if-then}
{$ENDIF} {DebVer}
                           END;
                   {if-then-else}
                      END
                ELSE  BEGIN
                   dwCodeBlockSeg := System.CSeg;
{$IFDEF   DebVer}
                   IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(282),
                                                        aModuleTypist);
                   {if-then}
{$ENDIF} {DebVer}
                      END;
              {if-then-else}
{$IFDEF   DebVer}
               IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                    THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(283),
                                                    aModuleTypist);
               {if-then}
{$ENDIF} {DebVer}
               System.Mem[dwCodeBlockSeg:(Globals.aDWord*10)] := Globals.gdbCurMultiplexChannel;
               System.Mem[dwCodeBlockSeg:(Globals.aDWord*10+Globals.aByte)] := Globals.gdbCallBackIntNum;
               Dos.SetIntVec(Globals.gdbCallBackIntNum,
                             System.Ptr(dwCodeBlockSeg,(System.Ofs(_KeyboardHandler)+Globals.aDWord*2)));
               CallBack._SetPrevIntVecIntoHandler(Globals.gdbCallBackIntNum,Globals.glpCurIntVec2F);
               CallBack._SetPrevIntVecIntoHandler(Globals.aServerInt,Globals.glpCurIntVec15);
               CallBack._SetPrevIntVecIntoHandler(Globals.aSoftKbdInt,Globals.glpCurIntVec16);
               CallBack._SetPrevIntVecIntoHandler(Globals.aHardTimerInt,Globals.glpCurIntVec08);
               CallBack._SetPrevIntVecIntoHandler(Globals.aHardKbdInt,Globals.glpCurIntVec09);
{$IFDEF   DebVer}
               IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                    THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(284),
                                                    aModuleTypist);
               {if-then}
{$ENDIF} {DebVer}
               Dos.SetIntVec(Globals.aServerInt,
                             System.Ptr(dwCodeBlockSeg,(System.Ofs(_KeyboardHandler)+Globals.aDWord*0)));
               Dos.SetIntVec(Globals.aSoftKbdInt,
                             System.Ptr(dwCodeBlockSeg,(System.Ofs(_KeyboardHandler)+Globals.aDWord*1)));
               Dos.SetIntVec(Globals.aHardTimerInt,
                             System.Ptr(dwCodeBlockSeg,(System.Ofs(_KeyboardHandler)+Globals.aDWord*3)));
               Dos.SetIntVec(Globals.aHardKbdInt,
                             System.Ptr(dwCodeBlockSeg,(System.Ofs(_KeyboardHandler)+Globals.aDWord*4)));
{$IFDEF   DebVer}
               IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                    THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(285),
                                                    aModuleTypist);
               {if-then}
{$ENDIF} {DebVer}
               IF  (CallBack._fndbCheckForInstallation <> 0)
                 THEN  BEGIN
{$IFDEF   DebVer}
                   IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(286),
                                                        aModuleTypist);
                   {if-then}
{$ENDIF} {DebVer}
                   CallBack._ResetCurrentFreeDataSpacePointer;
                   IF  (Globals.gdbRunTimerVal <> Globals.aNoneTimer)
                     THEN  CallBack._SetupEstimateTimer(Globals.gdbRunTimerVal);
                   {if-then}
                   IF  (NOT(Globals.gbTestModeOk))
                     THEN  BEGIN
                   IF  (NOT(DosCtl._fnbReleaseLowMemBlock(System.MemW[System.PrefixSeg:Globals.aDosEnvSeg])))
                     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(234),
                                              Globals.errBadEnvProgramMemoryUninstall);
                   {if-then}
                   Globals.gdwResidentPartInParas := (System.Ofs(_FreeDataSpace) +
                           Globals.gdwFreeSpaceSize +
                           Globals.aPSP_Size + Globals.aBytesPerParagraph) SHR 4;
                   Dos.SwapVectors;
                   IF  (Globals.gbHighMemOk)
                   THEN  BEGIN
                      Video._OutputMessage(Messages._fnsTextMessageByIndex(287),System.True);
                      {last report}
                      Video._OutputMessage(Messages._fnsTextMessageByIndex(7),
                                           System.True);
                      {make a trick to prevent DOS from freeing of our memory}
                      System.MemW[(dwCodeBlockSeg-1):Globals.aDosMemBlockOwner] := Globals.adwEXT_MPID_1;
                      System.MemL[(dwCodeBlockSeg-1):Globals.aDosMemBlockName] := Globals.addPROG_ID_1;
                      System.MemL[(dwCodeBlockSeg-1):Globals.aDosMemBlockName+Globals.aDWord] := Globals.addPROG_ID_2;
                      ASM
                               mov       ax, (Globals.aTerminateProcess SHL 8) + Globals.errTerminateOK
                               int       Globals.aDosServicesInt
                      END;
                      {asm-end}
                         END
                   ELSE  BEGIN
                      Video._OutputMessage(Messages._fnsTextMessageByIndex(288),
                                           System.True);
                      {last report}
                      Video._OutputMessage(Messages._fnsTextMessageByIndex(7),
                                           System.True);
                      ASM
                               mov       dx, Globals.gdwResidentPartInParas
                               mov       ax, (Globals.aKeepResident SHL 8) + Globals.errTerminateOK
                               int       Globals.aDosServicesInt
                      END;
                      {asm-end}
                        END;
                  {if-then-else}
                           END;
                  {if-then}
                       END
                 ELSE  BEGIN
{$IFDEF   DebVer}
                   IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
                        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(289),
                                                        aModuleTypist);
                   {if-then}
{$ENDIF} {DebVer}
                   DosCtl._RestoreCurrentVectors;
                   Video._HaltProgram(Messages._fnsTextMessageByIndex(290),
                                      Globals.errBadIntVecInst);
                       END;
               {if-then-else}
                  END;
          {if-then}
{$IFDEF   DebVer}
       IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
             THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(291),
                                             aModuleTypist);
       {if-then}
{$ENDIF} {DebVer}
       IF  (Globals.gbLoadDataDict)
          THEN  BEGIN
            CallBack._DumpFreeSpaceInfo(0);
            Video._OutputMessage(Messages._fnsTextMessageByIndex(292),
                                 System.True);
            IF  (Globals.gbHighMemOk)
              THEN  BEGIN
                CallBack._AllocNewFreeSpace(System.Ptr(dwCodeBlockSeg,System.Ofs(_FreeDataSpace)),Globals.aFreeSpaceMax);
                    END
              ELSE  BEGIN
                CallBack._AllocNewFreeSpace(@_FreeDataSpace,Globals.aFreeSpaceMax);
                    END;
            {if-then-else}
            CallBack._DumpFreeSpaceInfo(Globals.aFreeSpaceMax);
            _BuildMemoryEnvironmentAndDictionary;
            CallBack._DumpFreeSpaceInfo(Globals.aFreeSpaceMax);
            CallBack._DisplayEnvList;
            Video._OutputMessage(Messages._fnsTextMessageByIndex(230)+
                                 _fnsGetCurrentKeyboardModeDesc(_fndbGetCurrentKeyboardMode),
                                 System.True);
                END;
       {if-then}
       IF  (Globals.gbTestModeOk)
         THEN  BEGIN
{$IFDEF   TstVer}
            _RunningInTestOrDemoMode;
{$ENDIF} {TstVer}
               END;
       {if-then}
            END;
    {if-then-else}

  {restore some system information}
    DosCtl._RestoreCurrentVectors;

END;  { _SetupProgramDefaultsAfterUserParametersParsing }



{*============================== MAIN PART =============================*}

BEGIN

  {gets the true program name}
     Globals.gsPath := System.ParamStr(0);
     Dos.FSplit(Globals.gsPath,Globals.gsDir,Globals.gsName,Globals.gsExtension);

  {checks for the language support}
  IF  (Globals.gdwCurLanguage = Globals.aNoneLanguage)
    THEN  BEGIN
       Globals.gdwCurLanguage := Globals.aRussianLanguage;
       Video._OutputMessage(Messages._fnsTextMessageByIndex(2),
                            System.True);
       Globals.gdwCurLanguage := Globals.aEnglishLanguage;
       Video._HaltProgram(Messages._fnsTextMessageByIndex(2),
                          Globals.errNoneLanguage);
          END;
  {if-then}

  {check free space size}
  IF  (System.Odd(System.Ofs(_FreeDataSpace)))
    THEN  BEGIN
      Video._HaltProgram(Messages._fnsTextMessageByIndex(333),
                         Globals.errNeedDataWordAlignment);
          END;
  {if-then}

  {simple test for CPU type}
  IF  (Globals.gbTestCpuType)
    THEN  BEGIN
       ASM
             push    sp
             pop     ax

             cmp     ax, sp
             je      @CPU186

             mov     Globals.giErrorCode, -1
          @CPU186:
       END;
       {asm-end}
    IF (Globals.giErrorCode <> 0)
          THEN  BEGIN
             Video._HaltProgram(Messages._fnsTextMessageByIndex(5),
                                Globals.errBadCPU);
          END;
    {if-then}
          END;
  {if-then}


  {process a command line}
    IF  (System.ParamCount = 0)
      THEN  BEGIN
        Video._MoreHelpMessageDisplay;
        Video._HaltProgram(Messages._fnsTextMessageByIndex(6),
                           Globals.errUserNeedMoreHelpToRun);
            END;
    {if-then}
    DosCtl._ExtractDefaultsFromDosEnvironment;
    UsrParam._ScanProgramParameterLine(Globals.aNumOfCmdParms);
    IF  (Globals.gsDosEnvVar <> Globals.asDosEnvVarDef)
      THEN  DosCtl._ExtractDefaultsFromDosEnvironment;
    {if-then}

{$IFDEF   DebVer}
       IF  (Globals.gbJournalFileOk)
             THEN  BEGIN
               System.Assign(Globals.gfDebugOutputStream,Globals.gsJournalFileName);
               System.Rewrite(Globals.gfDebugOutputStream);
                   END;
       {if-then}
{$ENDIF} {DebVer}

   {check the debugging level}
{$IFDEF   DebVer}
       IF  ((Globals.gdwDebugLevel AND Globals.btTraceAll) <> 0)
             THEN  Globals.gdwDebugLevel := Globals.btTraceLevelMax;
       {if-then}
{$ENDIF} {DebVer}


   {again check current language}
   IF  NOT(gbLanguagesPresentArray[Globals.gdwCurLanguage])
     THEN  BEGIN
        gdwIndex := Globals.gdwCurLanguage;
        Video._OutputMessage(Messages._fnsTextMessageByIndex(gdwLangMsgIdxArray[Globals.gdwCurLanguage,gdwIndex]),
                             System.True);
        DosCtl._SetCurLanguageBasedOnCurCountryCode;
        Video._HaltProgram(Messages._fnsTextMessageByIndex(gdwLangMsgIdxArray[Globals.gdwCurLanguage,gdwIndex]),
                          Globals.errThisLanguageNotSupported);
           END;
   {if-then}


   {display copyright message}
    Video._CopyrightDisplay;

   {additional errors handler}
    Globals.glpOldExitProc := ExitProc;
    ExitProc := @_MyExitProc;

   {display an internal information}
     IF  (Globals.gbDispVerInfoOk)
       THEN  ThisVer._DisplayMoreInfoAboutThisVersion;
     {if-then}

   {setup variables and do the service by the request}
    Globals.dwMainCodeSeg := System.CSeg;
    Globals.glpInitFarCall := @_DoNearCallWithParmPtr;
    _InitCallBackIndexTable(@Globals.glpNearCallIndexTable);
    _SetupProgramDefaultsAfterUserParametersParsing;

   {last report}
    Video._OutputMessage(Messages._fnsTextMessageByIndex(7),
                         System.True);

{$IFDEF   DebVer}
       IF  (Globals.gbJournalFileOk)
             THEN  System.Close(Globals.gfDebugOutputStream);
       {if-then}
{$ENDIF} {DebVer}
END.
