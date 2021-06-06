{****************************************************************************
//                            File CALLBACK.PAS
//
//                  Multiplex process interface library
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/callback.pas $
//  $RCSfile: callback.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:50:35 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: callback.pas $
//      Revision 1.1  1999/01/03 17:50:35  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             CALLBACK.PAS                                    }
{ PURPOSE               Multiplex process interface library             }
{ VERSION               0.01                                            }
{ DATE                  13-Sep-94                                       }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Tel. 007 (095) 944-6304                         }
{ COPYRIGHT NOTICE      Copyright (C) 1987-1994, Dmitry Stefankov       }
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
{                       GLOBALS.TPU    (global public definitions)      }
{                       MESSAGES.TPU   (text user messages)             }
{                       VIDEO.TPU      (user screen interface)          }
{                       STRLIB.TPU     (string support library)         }
{                       DOSCTL.TPU     (advanced DOS support library)   }
{                       Project Maintence Files                         }
{                       TYPIST.MAK        (auto compiling & linking)    }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       0.01   13-Sep-94  DS  initial release           }
{-----------------------------------------------------------------------}



UNIT
     CallBack;


INTERFACE

USES
     Globals,
     Messages,
     StrLib,
     Video,
     DosCtl;


PROCEDURE   _CallBackDoorInterface;
FUNCTION    _fnbIsFreeMultChannel(dbChannelNum : System.Byte) : System.Boolean;
FUNCTION    _fndbFindFirstFreeMultChannel : System.Byte;
FUNCTION    _fndbCheckForInstallation : System.Byte;
FUNCTION    _fndwTransLogIndexToPhysIndex(dwIndex : System.Word) : System.Word;
FUNCTION    _fnbIsFreeIndex(dwThisIndex : System.Word) : System.Boolean;
FUNCTION    _SearchEnvListForFirstFree : System.Word;
FUNCTION    _fndbGetCurrentKeyboardMode : System.Byte;
FUNCTION    _fnsGetCurrentKeyboardModeDesc(dbStateMode : System.Byte) : STRING;
FUNCTION    _fnsGetCurrentSubStateModeDesc(dbSubStateMode : System.Byte) : STRING;
FUNCTION    _fnsGetLastStatusCodeDesc(dbStatusCode : System.Byte) : STRING;
FUNCTION    _fnsGetMultiplexReturnCodeDesc(dbCode : System.Byte) : STRING;
FUNCTION    _fnsGetRawUserInput : STRING;
FUNCTION    _fndwGetCurEnv : System.Word;
FUNCTION    _fnsGetEstimateTimerStateDesc : STRING;
FUNCTION    _fnlpGetCurEnvSettings : System.Pointer;
FUNCTION    _fnlpGetPrevIntVecIntoHandler(dbIntVec : System.Byte) : System.Pointer;
FUNCTION    _fnlpGetResidentPartStart :  System.Pointer;
FUNCTION    _fnlpTransEnvHandleToDictPtr(dwEnvHandle : System.Word) : System.Pointer;
FUNCTION    _fnsTransEnvHandleToDictName(dwEnvHandle : System.Word) : STRING;
FUNCTION    _fnsTransEnvHandleToDictComment(dwEnvHandle : System.Word) : STRING;
FUNCTION    _fndwTransDictNameToEnvHandle(sDictName : Globals.DictNameSTR16) : System.Word;
FUNCTION    _fndwGetCurrentUserEnvOptions : System.Word;
FUNCTION    _fnlpGetStatBlock : Globals.lpStatTimingBlock;
{$IFDEF   StaVer}
FUNCTION    _bIsMemBlockInStatBlockPresent : System.Boolean;
FUNCTION    _bIsStatBlockPresentGlobal : System.Boolean;
{$ENDIF} {StaVer}
PROCEDURE   _GetEnvListInfo(VAR dwEnvHandlesCount : System.Word;
                            VAR pEnvIndexTable : System.Pointer);
PROCEDURE   _GetStateSearchUserInput(VAR  sSearchWord : STRING;
                                     VAR  dwSearchWordLen,
                                          dwSearchFlags,
                                          dwReplaceCount  :  System.Word);
PROCEDURE   _FindMatchEntryInDictionary(sSearchWord : STRING;
                                        dwSearchWordLen :  System.Word;
                                        VAR  sFoundEntry : STRING;
                                        VAR  dwFoundEntryLen : System.Word);
PROCEDURE   _GetFoundStrToReplace(VAR  sFoundEntry : STRING;
                                  VAR  dwFoundEntryLen : System.Word);
PROCEDURE   _SetFilterRawUserInputFlag(bNewFilterFlag : System.Boolean);
PROCEDURE   _SetPrevIntVecIntoHandler(dbIntVec : System.Byte;
                                      lpIntVecHandler : System.Pointer);
PROCEDURE   _SetCurrentKeyboardMode(dbNewKbdMode : System.Byte);
PROCEDURE   _AllocNewFreeSpace(pFreeSpace : System.Pointer;
                               dwFreeSpaceSize : System.Word);
PROCEDURE   _GetFreeItemDataDict(VAR  pItemSpace : System.Pointer;
                                 dwItemSize : System.Word);
PROCEDURE   _GetFreeSpaceForDataDict(VAR  pFreeSpace : System.Pointer;
                                     VAR  dwFreeSpaceSize : System.Word);
PROCEDURE   _DumpFreeSpaceInfo(dwMaxFreeSpace : System.Word);
PROCEDURE   _DisplayEnvList;
PROCEDURE   _AddNewEnvToEnvList(pEnvDescTable : System.Pointer;
                                VAR  dwFoundFreeIndex : System.Word);
PROCEDURE   _RemoveThisEnvFromEnvList(dwIndexToFree : System.Word);
PROCEDURE   _SelectNewEnv(dwNewEnvHandle : System.Word);
PROCEDURE   _ResetCurrentEnvironment;
PROCEDURE   _ResetCurrentFreeDataSpacePointer;
PROCEDURE   _SetEstimateTimerFlag(bNewTimerFlag : System.Boolean);
PROCEDURE   _GetEstimateTimer(VAR bCurTimerFlag : System.Boolean;
                              VAR dwLastEstimateTimeValue : System.Word);
PROCEDURE   _GetProgramInfo(VAR  dwDataBufSize  :  System.Word;
                            pDataBuf  :  System.Pointer);
PROCEDURE   _CopyGlobalFreeDataSpacePointerToEnvironment(dwEnvironment : System.Word);
PROCEDURE   _AddNewEntryInDictionary(sAddEntry : STRING;
                                     dwAddWordLen :  System.Word;
                                     VAR  dbStatusCode : System.Byte);
PROCEDURE   _RemoveDictByIndex(dwDictIndex : System.Word);
PROCEDURE   _RemoveDictByName(sUserDictName : STRING);
PROCEDURE   _ListAllLoadedDictionaries;
PROCEDURE   _RemoveAllDictionariesFromMemory;
PROCEDURE   _DoResidentPartDiagDump;
PROCEDURE   _SetupEstimateTimer(dbNewState : System.Byte);
PROCEDURE   _SetStatBlock(lpStatBlock : Globals.lpStatTimingBlock);
{$IFDEF   StaVer}
PROCEDURE   _DisableTypingWatchMonitoring(lpStatBlock : Globals.lpStatTimingBlock);
PROCEDURE   _EnableTypingWatchMonitoring(lpStatBlock : Globals.lpStatTimingBlock);
PROCEDURE   _ResetTypingStat;
PROCEDURE   _DispTypingStat;
PROCEDURE   _RunTypingStat(dwRunStatTime : System.Word;
                           bHighMemToUse : System.Boolean);
{$ENDIF} {StaVer}



IMPLEMENTATION


{*MULTCALL.INC*}

PROCEDURE
         _CallBackDoorInterface; ASSEMBLER;
{*
Description.
     Interface to resident program part;
     executes the requested service.
*}
ASM
         int     Globals.aMultiplexInt
END;  {asm-end}
{ _CallBackDoorInterface }



FUNCTION
        _fnbIsFreeMultChannel(dbChannelNum : System.Byte) : System.Boolean;
{*
Description.
    Checks specified multilpex channel for the availability.
*}
VAR
  bResult  :  System.Boolean;

BEGIN
{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(78)+
                                  ' = '+
                                  StrLib._fnsByteToTurboHexFmt(dbChannelNum)+
                                  ' '+
                                  Messages._fnsTextMessageByIndex(79),
                                  Globals.aModuleCallBack);
    {if-then}
{$ENDIF} {DebVer}

  bResult := System.True;
  ASM
      @TryNextMP:
                mov     ah, dbChannelNum          {check installation}
                mov     al, Globals.aMP_Install
                call    _CallBackDoorInterface
                cmp     al, Globals.aMP_OK_to_Install {installed something?}
                je     @CheckDone
                mov     bResult, System.False

      @CheckDone:
  END;
  {asm-end}

{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
        THEN  BEGIN
          IF  (bResult)
            THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(80),
                                            Globals.aModuleCallBack)
            ELSE  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(81),
                                            Globals.aModuleCallBack);
          {if-then-else}
              END;
    {if-then}
{$ENDIF} {DebVer}

  _fnbIsFreeMultChannel := bResult;
END;
{ _fnbIsFreeMultChannel }



FUNCTION
        _fndbFindFirstFreeMultChannel : System.Byte;
{*
Description.
    Searches for the first free multilpex slot;
    returns 0 if no free found.
*}
VAR
  dbChannel  :  System.Byte;

BEGIN
{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(82),
                                        Globals.aModuleCallBack);
    {if-then}
{$ENDIF} {DebVer}

  dbChannel := 0;
  ASM
                        mov     bh, Globals.aUSER_First_MPID  {load initial value}
      @TryNextMP:
                        mov     ah, bh                    {check installation}
                        mov     al, Globals.aMP_Install
                        call    _CallBackDoorInterface

                        cmp     al, Globals.aMP_OK_to_Install {installed something?}
                        jne    @AnotherCheck

                        mov     dbChannel, bh
                        jmp    @SearchDone
      @AnotherCheck:
                        cmp     bh, Globals.aUSER_Last_MPID   {last MP number?}
                        je     @SearchDone

      @IncrMP:
                        inc     bh                   {go to next channel}
                        jmp    @TryNextMP
      @SearchDone:
  END;
  {asm-end}

{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
        THEN  BEGIN
          IF (dbChannel = 0)
            THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(83),
                                            Globals.aModuleCallBack)
            ELSE  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(84)+
                           ' = '+StrLib._fnsByteToTurboHexFmt(dbChannel),
                           Globals.aModuleCallBack);
          {if-then-else}
              END;
    {if-then}
{$ENDIF} {DebVer}

  _fndbFindFirstFreeMultChannel := dbChannel;
END;
{ _fndbFindFirstFreeMultChannel }



FUNCTION
        _fndbCheckForInstallation : System.Byte;
{*
Description.
     Checks for presence of memory-resident of program;
     returns 0 if our program not found.
*}
VAR
  dbChannel,
  dbTemp,
  dbCurChannel      :  System.Byte;

BEGIN
{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(85),
                                        Globals.aModuleCallBack);
    {if-then}
{$ENDIF} {DebVer}

    dbChannel := 0;
    dbCurChannel := Globals.aUSER_First_MPID;
    ASM
      @TryNextMP:
                        mov     bh, dbCurChannel      {load initial value}
                        mov     ah, bh                {check installation}
                        mov     al, Globals.aMP_Install
                        call    _CallBackDoorInterface

                        cmp     al, Globals.aMP_Already_Installed {installed?}
                        je     @CheckITypist_MPID

      @AnotherCheck:
                        mov     bh, dbCurChannel          {load initial value}
                        cmp     bh, Globals.aUSER_Last_MPID  {last MP number?}
                        je     @SearchDone

                        inc     bh                   {go to next channel}
                        mov     dbCurChannel, bh
                        jmp    @TryNextMP

      @CheckITypist_MPID:
                         mov    ah, bh
                         mov    dbTemp, ah
                         mov    dbCurChannel, ah
                         sub    bx, bx
                         mov    cx, bx
                         mov    al, Globals.aITypist_Current_Status
                         stc
                         call    _CallBackDoorInterface

                         jc    @AnotherCheck           {do extended check!}
                         cmp    bx, Globals.adwExt_MPID_1
                         jne   @AnotherCheck
                         cmp    cx, Globals.adwExt_MPID_2
                         jne   @AnotherCheck
                         mov    al, dbTemp
                         mov    dbChannel, al

      @SearchDone:
    END;
    {asm-end}

{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
        THEN  BEGIN
          IF (dbChannel = 0)
            THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(86),
                                            Globals.aModuleCallBack)
            ELSE  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(87)+
                              ' = '+StrLib._fnsByteToTurboHexFmt(dbChannel),
                              Globals.aModuleCallBack);
          {if-then-else}
              END;
    {if-then}
{$ENDIF} {DebVer}

  _fndbCheckForInstallation := dbChannel;
END;
{ _fndbCheckForInstallation }



FUNCTION
        _fndwTransLogIndexToPhysIndex(dwIndex : System.Word) : System.Word;
{*
Description.
    Translates a logical index to a physical handle;
    checks for valid environment index.
*}
BEGIN
  IF  ((Globals.aEnviron_Avail_Min <= dwIndex)  AND
       (dwIndex <= Globals.aEnviron_Avail_Max))
    THEN  System.Dec(dwIndex)
    ELSE  Video._HaltProgram(Messages._fnsTextMessageByIndex(88),
                             Globals.errBadEnvHandleFound);
  {if-then-else}
    _fndwTransLogIndexToPhysIndex := dwIndex;
END;
{ _fndwTransLogIndexToPhysIndex }



PROCEDURE
         _GetEnvListInfo(VAR  dwEnvHandlesCount  :  System.Word;
                         VAR  pEnvIndexTable  :  System.Pointer);
{*
Description.
    Gets the environment list information.
*}
VAR
  dwAvailEnv        :   System.Word;
  pEnvList          :   System.Pointer;
  bResultOk         :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_List_Environ
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     dwAvailEnv, cx
            mov     WORD PTR pEnvList+0, bx
            mov     WORD PTR pEnvList+2, es
       @Done:
     END;
     {asm-end}
     IF  (bResultOk)
        THEN   BEGIN
            pEnvIndexTable := pEnvList;
            dwEnvHandlesCount := dwAvailEnv;
                END
        ELSE   BEGIN
            Video._HaltProgram(Messages._fnsTextMessageByIndex(89),
                               Globals.errGetEnvList);
                END;
     {if-then-else}
END;
{ _GetEnvListInfo }



FUNCTION
        _fnbIsFreeIndex(dwThisIndex : System.Word) : System.Boolean;
{*
Description.
     Checks a given index for availability to use.
*}
VAR
  dwAvailEnvCount   :  System.Word;
  pEnvList,
  pTemp             :  System.Pointer;

BEGIN
  _GetEnvListInfo(dwAvailEnvCount,pEnvList);
  dwThisIndex := _fndwTransLogIndexToPhysIndex(dwThisIndex);
  _fnbIsFreeIndex :=  (System.Pointer(System.MemL[System.Seg(pEnvList^):
                      (System.Ofs(pEnvList^)+dwThisIndex*aDWord)]) = NIL);
END;
{ _fnbIsFreeIndex }



FUNCTION
        _SearchEnvListForFirstFree : System.Word;
{*
Description.
    Searches the environment to find the first free handle;
    returns 0 if no free handle found.
*}
VAR
  dwIndex,
  dwFreeIndex       :  System.Word;

BEGIN
{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(90),
                                        Globals.aModuleCallBack);
    {if-then}
{$ENDIF} {DebVer}
    dwIndex := 0;
    dwFreeIndex := 0;

    REPEAT
      System.Inc(dwIndex);
      IF  (_fnbIsFreeIndex(dwIndex))
        THEN  dwFreeIndex := dwIndex;
      {if-then}
    UNTIL ((dwFreeIndex <> 0)  OR
           (dwIndex >= Globals.aEnviron_Avail_Max));
    {repeat-until}
    _SearchEnvListForFirstFree := dwFreeIndex;
END;
{ _SearchEnvListForFirstFree }


FUNCTION
        _fndbGetCurrentKeyboardMode : System.Byte;
{*
Description.
    Gets a current keyboard mode.
*}
VAR
  dbCurMode   :   System.Byte;
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Set_Kbd_Mode
            sub     bx, bx                       {Subfunction Get (0)}
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     dbCurMode, bl
       @Done:
     END;
     IF  (NOT(bResultOk))
        THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(91),
                                 Globals.errGetCurKbdModeFailed);
     {if-then}
     _fndbGetCurrentKeyboardMode := dbCurMode;
END;
{ _fndbGetCurrentKeyboardMode }



FUNCTION
        _fnsGetCurrentKeyboardModeDesc(dbStateMode : System.Byte) : STRING;
{*
Description.
     Returns a current keyboard mode string description.
*}
VAR
  sTemp  :  STRING;

BEGIN
  CASE  (dbStateMode)  OF
       Globals.aStateIsIdleMode     : sTemp := Messages._fnsTextMessageByIndex(293);
       Globals.aStateIsManualMode   : sTemp := Messages._fnsTextMessageByIndex(294);
       Globals.aStateIsAddMode      : sTemp := Messages._fnsTextMessageByIndex(295);
       Globals.aStateIsSearchMode   : sTemp := Messages._fnsTextMessageByIndex(296);
  ELSE
       sTemp := Messages._fnsTextMessageByIndex(92);
  END;
  {case-of}
  _fnsGetCurrentKeyboardModeDesc := sTemp;
END;
{ _fnsGetCurrentKeyboardModeDesc }



FUNCTION
        _fnsGetCurrentSubStateModeDesc(dbSubStateMode : System.Byte) : STRING;
{*
Description.
      Returns a current substate mode string description.
*}
VAR
  sTemp  :  STRING;

BEGIN
  CASE  (dbSubStateMode)  OF
       Globals.aSearchSubStateIsAnalyze : sTemp := Messages._fnsTextMessageByIndex(373);
       Globals.aSearchSubStateIsSearch  : sTemp := Messages._fnsTextMessageByIndex(374);
       Globals.aSearchSubStateIsReplace : sTemp := Messages._fnsTextMessageByIndex(375);
  ELSE
       sTemp := Messages._fnsTextMessageByIndex(92);
  END;
  {case-of}
  _fnsGetCurrentSubStateModeDesc := sTemp;
END;
{ _fnsGetCurrentSubStateModeDesc }



FUNCTION
        _fnsGetLastStatusCodeDesc(dbStatusCode : System.Byte) : STRING;
{*
Description.
      Returns a last status code string description.
*}
VAR
  sTemp  :  STRING;

BEGIN
  CASE  (dbStatusCode)  OF
       Globals.errStatus_Success               : sTemp := Messages._fnsTextMessageByIndex(376);
       Globals.errStatus_Bad_Non_Special_Sym   : sTemp := Messages._fnsTextMessageByIndex(377);
       Globals.errStatus_No_Match_Search_Entry : sTemp := Messages._fnsTextMessageByIndex(378);
       Globals.errStatus_Empty_Expression      : sTemp := Messages._fnsTextMessageByIndex(379);
       Globals.errStatus_Bad_User_Definition   : sTemp := Messages._fnsTextMessageByIndex(409);
       Globals.errStatus_No_Enough_Free_Memory : sTemp := Messages._fnsTextMessageByIndex(410);
       Globals.errStatus_Dict_Is_Compressed    : sTemp := Messages._fnsTextMessageByIndex(411);
       Globals.errStatus_Bad_Num_Parm          : sTemp := Messages._fnsTextMessageByIndex(430);
       errStatus_Duplicate_Entry_Found         : sTemp := Messages._fnsTextMessageByIndex(548);
  ELSE
       sTemp := Messages._fnsTextMessageByIndex(380);
  END;
  {case-of}
  _fnsGetLastStatusCodeDesc := sTemp;
END;
{ _fnsGetLastStatusCodeDesc }



FUNCTION
        _fnsGetMultiplexReturnCodeDesc(dbCode : System.Byte) : STRING;
{*
Description.
     Returns a multiplex return code string description.
*}
VAR
  sTemp  :  STRING;

BEGIN
  CASE  (dbCode)  OF
      Globals.aMP_Bad_Call                : sTemp := Messages._fnsTextMessageByIndex(412);
      Globals.aMP_Successful_Done         : sTemp := Messages._fnsTextMessageByIndex(413);
      Globals.aMP_No_Free_Memory          : sTemp := Messages._fnsTextMessageByIndex(414);
      Globals.aMP_Bad_Range_Env           : sTemp := Messages._fnsTextMessageByIndex(415);
      Globals.aMP_Empty_Env               : sTemp := Messages._fnsTextMessageByIndex(416);
      Globals.aMP_Not_Implemented         : sTemp := Messages._fnsTextMessageByIndex(417);
      Globals.aMP_Bad_Kbd_Mode            : sTemp := Messages._fnsTextMessageByIndex(418);
      Globals.aMP_Bad_New_Free_Space      : sTemp := Messages._fnsTextMessageByIndex(419);
      Globals.aMP_Bad_Filter_Flag         : sTemp := Messages._fnsTextMessageByIndex(420);
      Globals.aMP_Bad_Int_Vec_Num         : sTemp := Messages._fnsTextMessageByIndex(421);
      Globals.aMP_Bad_Search_Parms        : sTemp := Messages._fnsTextMessageByIndex(422);
      Globals.aMP_Bad_User_Options_Func   : sTemp := Messages._fnsTextMessageByIndex(423);
      Globals.aMP_Bad_Estimate_Timer_Func : sTemp := Messages._fnsTextMessageByIndex(424);
      Globals.aMP_Bad_User_Def_Str        : sTemp := Messages._fnsTextMessageByIndex(425);
      Globals.aMP_User_Dict_Is_Compressed : sTemp := Messages._fnsTextMessageByIndex(426);
      Globals.aMP_Bad_Stat_Block_Func     : sTemp := Messages._fnsTextMessageByIndex(500);
      Globals.aMP_Bad_Stat_Block_Pointer  : sTemp := Messages._fnsTextMessageByIndex(501);
      Globals.aMP_Same_Entry_Found        : sTemp := Messages._fnsTextMessageByIndex(550);
  ELSE
       sTemp := Messages._fnsTextMessageByIndex(380);
  END;
  {case-of}
  _fnsGetMultiplexReturnCodeDesc := sTemp;
END;
{ _fnsGetMultiplexReturnCodeDesc }



FUNCTION
        _fnsGetRawUserInput : STRING;
{*
Description.
    Extracts last raw user input (string) from keyboard handler.
*}
VAR
  dwRawInputBufSeg,
  dwRawInputBufOfs,
  dwRawInputBufCurOfs  :   System.Word;
  sTemp                :   STRING;
  dbCount              :   System.Byte;
  bResultOk            :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Raw_User_Input
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     dwRawInputBufCurOfs, cx
            mov     dwRawInputBufOfs, bx
            mov     dwRawInputBufSeg, es
       @Done:
     END;
     IF  (bResultOk)
        THEN   BEGIN
            dbCount := System.Lo(dwRawInputBufCurOfs-dwRawInputBufOfs);
            System.Move(System.Mem[dwRawInputBufSeg:dwRawInputBufOfs],sTemp[1],dbCount);
            sTemp[0] := System.Char(dbCount);
               END
        ELSE   BEGIN
          Video._HaltProgram(Messages._fnsTextMessageByIndex(93),
                             Globals.errGetRawUserInputCallFailed);
               END;
     {if-then-else}
     _fnsGetRawUserInput := sTemp;
END;
{ _fnsGetRawUserInput }



FUNCTION
        _fndwGetCurEnv  : System.Word;
{*
Description.
     Returns the current environment handle.
*}
VAR
  dwCurEnvHandle     :   System.Word;
  bResultOk          :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            sub     bx, bx                        {Get subfunction (0)}
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Set_Environ
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     dwCurEnvHandle, bx
       @Done:
     END;
     {asm-end}
     IF  (bResultOk)
        THEN    BEGIN
{$IFDEF   DebVer}
           IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
               THEN  Video._OutputMessage(Messages._fnsTextMessageByIndex(94)+
                        ' = '+StrLib._fnsNumToStr(dwCurEnvHandle,5),
                        System.True);
           {if-then}
{$ENDIF} {DebVer}
                END
        ELSE    BEGIN
           Video._HaltProgram(Messages._fnsTextMessageByIndex(95),
                              Globals.errCallToGetCurEnvHandleFailed);
                END;
     {if-then-else}
     _fndwGetCurEnv := dwCurEnvHandle;
END;
{ _fndwGetCurEnv }



FUNCTION
        _fnlpGetCurEnvSettings : System.Pointer;
{*
Description.
    Returns a pointer to the current environment.
*}
VAR
  pTemp              :   System.Pointer;
  bResultOk          :   System.Boolean;

BEGIN
     bResultOk := System.False;
     pTemp := NIL;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Cur_Environ_Parms
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     WORD PTR  pTemp+0 , bx
            mov     WORD PTR  pTemp+2 , es
       @Done:
     END;
     {asm-end}
     IF (NOT(bResultOk))
         THEN   BEGIN
           Video._HaltProgram(Messages._fnsTextMessageByIndex(96),
                              Globals.errCallToGetCurEnvSettingsFailed);
                END;
     {if-then}
     _fnlpGetCurEnvSettings := pTemp;
END;
{ _fnlpGetCurEnvSettings }



PROCEDURE
         _GetStateSearchUserInput(VAR  sSearchWord : STRING;
                                  VAR  dwSearchWordLen,
                                  dwSearchFlags,
                                  dwReplaceCount  :  System.Word);
{*
Description.
   Extracts last search user input (string) from keyboard handler.
*}
VAR
  dwSearchInputBufSeg,
  dwSearchInputBufOfs,
  dwSearchInputBufSize,
  dwSearchWordFlags,
  dwCharsToReplace      :   System.Word;
  dbCount               :   System.Byte;
  bResultOk             :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Search_User_Input
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     dwSearchWordFlags, dx
            mov     dwSearchInputBufSize, cx
            mov     dwSearchInputBufOfs, bx
            mov     dwSearchInputBufSeg, es
            mov     dwCharsToReplace, si
       @Done:
     END;
     IF  (bResultOk)
         THEN  BEGIN
            dwReplaceCount := dwCharsToReplace;
            dwSearchFlags := dwSearchWordFlags;
            dbCount := System.Lo(dwSearchInputBufSize);
            dwSearchWordLen := dwSearchInputBufSize;
            System.Move(System.Mem[dwSearchInputBufSeg:dwSearchInputBufOfs],sSearchWord[1],dbCount);
            sSearchWord[0] := System.Char(dbCount);
               END
         ELSE  BEGIN
          Video._HaltProgram(Messages._fnsTextMessageByIndex(97),
                             Globals.errGetSearchUserInputCallFailed);
               END;
     {if-then-else}
END;
{ _GetStateSearchUserInput }



PROCEDURE
         _FindMatchEntryInDictionary(sSearchWord : STRING;
                                     dwSearchWordLen :  System.Word;
                                     VAR  sFoundEntry : STRING;
                                     VAR  dwFoundEntryLen : System.Word);
{*
Description.
   Searches the current resident dictionary for the match user input.
*}
VAR
  dwFoundEntryBufSeg,
  dwFoundEntryBufOfs,
  dwFoundEntryBufSize   :   System.Word;
  dbCount               :   System.Byte;
  bResultOk             :   System.Boolean;

BEGIN
     bResultOk := System.False;
     sFoundEntry := asBlank;
     dwFoundEntryLen := 0;
     dwFoundEntryBufSeg := System.Seg(sSearchWord[1]);
     dwFoundEntryBufOfs := System.Ofs(sSearchWord[1]);
     ASM
            mov     es, dwFoundEntryBufSeg
            mov     bx, dwFoundEntryBufOfs
            mov     cx, dwSearchWordLen
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Search_Dict_Entry
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     dwFoundEntryBufSize, cx
            mov     dwFoundEntryBufOfs, bx
            mov     dwFoundEntryBufSeg, es
       @Done:
     END;
     IF  (bResultOk)
        THEN   BEGIN
            dbCount := System.Lo(dwFoundEntryBufSize);
            dwFoundEntryLen := dwFoundEntryBufSize;
            System.Move(System.Mem[dwFoundEntryBufSeg:dwFoundEntryBufOfs],sFoundEntry[1],dbCount);
            sFoundEntry[0] := System.Char(dbCount);
               END
        ELSE   BEGIN
          Video._HaltProgram(Messages._fnsTextMessageByIndex(98),
                             Globals.errBadEntrySearchParameters);
               END;
     {if-then-else}
END;
{ _FindMatchEntryInDictionary }



PROCEDURE
         _GetFoundStrToReplace(VAR  sFoundEntry : STRING;
                               VAR  dwFoundEntryLen : System.Word);
{*
Description.
    Returns the found entry (replace string) from the dictionary.
*}
VAR
  dwFoundEntryBufSeg,
  dwFoundEntryBufOfs,
  dwFoundEntryBufSize   :   System.Word;
  dbCount               :   System.Byte;
  bResultOk             :   System.Boolean;

BEGIN
     bResultOk := System.False;
     sFoundEntry := asBlank;
     dwFoundEntryLen := 0;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Replace_Str
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     dwFoundEntryBufSize, cx
            mov     dwFoundEntryBufOfs, bx
            mov     dwFoundEntryBufSeg, es
       @Done:
     END;
     IF  (bResultOk)
       THEN    BEGIN
            dbCount := System.Lo(dwFoundEntryBufSize);
            dwFoundEntryLen := dwFoundEntryBufSize;
            System.Move(System.Mem[dwFoundEntryBufSeg:dwFoundEntryBufOfs],sFoundEntry[1],dbCount);
            sFoundEntry[0] := System.Char(dbCount);
               END
       ELSE    BEGIN
          Video._HaltProgram(Messages._fnsTextMessageByIndex(99),
                       Globals.errGetReplaceBufCallFailed);
               END;
     {if-then-else}
END;
{ _GetFoundStrToReplace }



PROCEDURE
         _SetFilterRawUserInputFlag(bNewFilterFlag : System.Boolean);
{*
Description.
     Sets a new filtering flag for the raw user input.
*}
VAR
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Filter_Raw_User_Input
            mov     bl, 1               { SubFunc: Set }
            mov     bh, bNewFilterFlag
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     IF (NOT(bResultOk))
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(100),
                                  Globals.errSetNewFilterFlagFailed);
     {if-then}
END;
{ _SetFilterRawUserInputFlag }



PROCEDURE
         _SetPrevIntVecIntoHandler(dbIntVec : System.Byte;
                                   lpIntVecHandler : System.Pointer);
{*
Description.
   Saves a previous interrupt handler address to our keyboard handler.
*}
VAR
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            les     dx, lpIntVecHandler
            mov     bh, dbIntVec
            mov     bl, 1               {Subfunction Set}
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Set_Prev_Int_Vec
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     IF (NOT(bResultOk))
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(101),
                                  Globals.errCopyOldIntVecFailed);
     {if-then}
END;
{ _SetPrevIntVecIntoHandler }



FUNCTION
        _fnlpGetPrevIntVecIntoHandler(dbIntVec : System.Byte) : System.Pointer;
{*
Description.
    Gets a previous interrupt handler address from
    the our keyboard handler.
*}
VAR
  pTemp       :   System.Pointer;
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     pTemp := NIL;
     ASM
            mov     bh, dbIntVec
            mov     bl, 0               { SubFunc: Get }
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Set_Prev_Int_Vec
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     WORD PTR  pTemp+0, dx
            mov     WORD PTR  pTemp+2, es
       @Done:
     END;
     IF  (bResultOk)
        THEN  _fnlpGetPrevIntVecIntoHandler := pTemp
        ELSE  Video._HaltProgram(Messages._fnsTextMessageByIndex(102),
                                 Globals.errGetOldIntVecFailed);
     {if-then}
END;
{ _fnlpGetPrevIntVecIntoHandler }



PROCEDURE
         _SetCurrentKeyboardMode(dbNewKbdMode : System.Byte);
{*
Description.
     Sets a specified keyboard mode.
*}
VAR
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Set_Kbd_Mode
            sub     bx, bx                       { Subfunc: Set }
            mov     bl, dbNewKbdMode
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     IF (NOT(bResultOk))
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(103),
                                  Globals.errSetNewKbdModeFailed);
     {if-then}
END;
{ _SetCurrentKeyboardMode }



PROCEDURE
         _AllocNewFreeSpace(pFreeSpace : System.Pointer;
                            dwFreeSpaceSize : System.Word);
{*
Description.
   Allocates a new free space for our resident handler.
*}
VAR
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_New_Free_Space
            les     bx, pFreeSpace
            mov     cx, dwFreeSpaceSize
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     IF (NOT(bResultOk))
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(104),
                                  Globals.errAllocNewFreeSpaceFailed);
     {if-then}
END;
{ _AllocNewFreeSpace }



PROCEDURE
         _GetFreeItemDataDict(VAR  pItemSpace : System.Pointer;
                              dwItemSize : System.Word);
{*
Description.
   Gets a block from a free memory pool for a given byte count.
*}
VAR
  pTemp     :   System.Pointer;
  bResultOk :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Free_Elem
            mov     bx, dwItemSize
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     WORD PTR pTemp+0, bx
            mov     WORD PTR pTemp+2, es
       @Done:
     END;
     IF  (bResultOk)
        THEN   pItemSpace := pTemp
        ELSE   Video._HaltProgram(Messages._fnsTextMessageByIndex(105),
                                  Globals.errNoEnoughFreeMemInPool);
     {if-then-else}
END;
{ _GetFreeItemDataDict }



PROCEDURE
         _GetFreeSpaceForDataDict(VAR  pFreeSpace : System.Pointer;
                                  VAR  dwFreeSpaceSize : System.Word);
{*
Description.
    Returns info about the free space for the current environment.
*}
VAR
  pTemp     :   System.Pointer;
  dwSize    :   System.Word;
  bResultOk :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Free_Elem
            sub     bx, bx                        {get only info}
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     dwSize, cx
            mov     WORD PTR pTemp+0, bx
            mov     WORD PTR pTemp+2, es
       @Done:
     END;
     IF (bResultOk)
         THEN   BEGIN
             pFreeSpace := pTemp;
             dwFreeSpaceSize := dwSize;
                END
         ELSE   BEGIN
            Video._HaltProgram(Messages._fnsTextMessageByIndex(106),
                         Globals.errFreeMemInfoCallFailed);
                END;
     {if-then-else}
END;
{ _GetFreeSpaceForDataDict }



PROCEDURE
         _DumpFreeSpaceInfo(dwMaxFreeSpace : System.Word);
{*
Description.
    Displays the information about the free space size.
*}
VAR
   pFreeMemoryPool    :   System.Pointer;
   dwFreeMemorySize,   
   dwDivisor          :   System.Word;

BEGIN
   _GetFreeSpaceForDataDict(pFreeMemoryPool,dwFreeMemorySize);
   dwDivisor := Globals.aFreeSpaceMax;
   IF  (dwDivisor = 0)
     THEN  dwDivisor := 1;
   {if-then}
   Video._OutputMessage(Messages._fnsTextMessageByIndex(107)+
                 ' = '+
                 StrLib._fnsPointerToTurboHexFmt(pFreeMemoryPool) +
                 ';  '+
                 Messages._fnsTextMessageByIndex(108)+
                 ' = ' +
                 StrLib._fnsNumToStr(dwFreeMemorySize,5)+
                 ' ('+
                 StrLib._fnsNumToStr(System.Trunc(((dwMaxFreeSpace-dwFreeMemorySize)
                              /dwDivisor)*Globals.aPercent100),3)+
                 Globals.achPercent+Globals.achSPACE+
                 Messages._fnsTextMessageByIndex(109)+')',
                 System.True);
END;
{ _DumpFreeSpaceInfo }



FUNCTION
        _fnlpTransEnvHandleToDictPtr(dwEnvHandle : System.Word) : System.Pointer;
{*
Description.
    Translates the environment handle (index) to
    the dictionary memory image pointer.
*}
VAR
  pTemp,
  pEnvTable             :  System.Pointer;
  dwEnvHandlesCountMax  :  System.Word;

BEGIN
   pTemp := NIL;
   _GetEnvListInfo(dwEnvHandlesCountMax,pEnvTable);
    pTemp := System.Pointer(System.MemL[System.Seg(pEnvTable^):
                    (System.Ofs(pEnvTable^)+(_fndwTransLogIndexToPhysIndex(dwEnvHandle))*Globals.aDWord)]);
   _fnlpTransEnvHandleToDictPtr := pTemp;
END;
{ _fnlpTransEnvHandleToDictPtr }



PROCEDURE
         _DisplayEnvList;
{*
Description.
    Displays list of all the available environments.
*}
VAR
  dwAvailEnv,
  dwIndex,
  dwFreeEnvCount    :  System.Word;
  pEnvList,
  pTemp             :  System.Pointer;
  bResultOk         :   System.Boolean;

BEGIN
   _GetEnvListInfo(dwAvailEnv,pEnvList);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(110),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(111)+
                        ' = '+
                        StrLib._fnsNumToStr(dwAvailEnv,5)+
                        '; '+
                        Messages._fnsTextMessageByIndex(112)+
                        ' = '+
                        StrLib._fnsPointerToTurboHexFmt(pEnvList),
                        System.True);
   dwFreeEnvCount := 0;
   FOR  dwIndex := Globals.aEnviron_Avail_Min  TO  dwAvailEnv  DO
   BEGIN
      pTemp := _fnlpTransEnvHandleToDictPtr(dwIndex);
      IF (pTemp = NIL)
        THEN  System.Inc(dwFreeEnvCount)
        ELSE  Video._OutputMessage(Messages._fnsTextMessageByIndex(113)+
                                   ' = '+StrLib._fnsNumToStr(dwIndex,5)+
                                   ';  '+
                                   Messages._fnsTextMessageByIndex(114)+
                                   ' = '+
                                   StrLib._fnsPointerToTurboHexFmt(pTemp),
                                   System.True);
      {if-then-else}
   END;
   {for-to-do}
   Video._OutputMessage(Messages._fnsTextMessageByIndex(115)+
                        ' = '+StrLib._fnsNumToStr(dwFreeEnvCount,5),
                        System.True);
END;
{ _DisplayEnvList }



PROCEDURE
         _AddNewEnvToEnvList(pEnvDescTable : System.Pointer;
                             VAR  dwFoundFreeIndex  :  System.Word);
{*
Description.
   Adds the new environment to the table if free place found.
*}
VAR
  dwHandle           :   System.Word;
  bResultOk          :   System.Boolean;

BEGIN
     dwFoundFreeIndex := _SearchEnvListForFirstFree;
     dwHandle := dwFoundFreeIndex;
     bResultOk := System.False;
     ASM
            mov     di, WORD PTR pEnvDescTable+0
            mov     es, WORD PTR pEnvDescTable+2
            mov     bx, dwHandle
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Add_Environ
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     {asm-end}
     IF (bResultOk)
         THEN   BEGIN
{$IFDEF   DebVer}
           IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
               THEN  Video._OutputMessage(Messages._fnsTextMessageByIndex(116)+
                           ' #'+StrLib._fnsNumToStr(dwHandle,5)+'.',
                           System.True);
           {if-then}
{$ENDIF} {DebVer}
                END
         ELSE   BEGIN
           Video._HaltProgram(Messages._fnsTextMessageByIndex(117),
                              Globals.errEnvListFull);
                END;
     {if-then-else}
END;
{ _AddNewEnvToEnvList }



PROCEDURE
         _RemoveThisEnvFromEnvList(dwIndexToFree  :  System.Word);
{*
Description.
    Removes a given environment from the environment table.
*}
VAR
  bResultOk          :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            sub     di, di               { ES:DI <- NIL }
            mov     es, di
            mov     bx, dwIndexToFree
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Add_Environ
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     {asm-end}
     IF (bResultOk)
         THEN   BEGIN
{$IFDEF   DebVer}
           IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
               THEN  Video._OutputMessage(Messages._fnsTextMessageByIndex(118)+
                          ' #'+StrLib._fnsNumToStr(dwIndexToFree,5)+'.',
                          System.True);
           {if-then}
{$ENDIF} {DebVer}
                END
         ELSE   BEGIN
           Video._HaltProgram(Messages._fnsTextMessageByIndex(119),
                              Globals.errBadRemoveFromEnvList);
                END;
     {if-then-else}
END;
{ _RemoveThisEnvFromEnvList }



PROCEDURE
          _SelectNewEnv(dwNewEnvHandle : System.Word);
{*
Description.
   Selects a new current environment.
*}
VAR
  bResultOk          :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     bx, dwNewEnvHandle
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Set_Environ
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     {asm-end}
     IF (bResultOk)
         THEN   BEGIN
{$IFDEF   DebVer}
           IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
               THEN  Video._OutputMessage(Messages._fnsTextMessageByIndex(120)+
                           ' '+StrLib._fnsNumToStr(dwNewEnvHandle,5)+'.',
                           System.True);
           {if-then}
{$ENDIF} {DebVer}
                END
         ELSE   BEGIN
           Video._HaltProgram(Messages._fnsTextMessageByIndex(121),
                              Globals.errCallToSetNewEnvHandleFailed);
                END;
     {if-then-else}
END;
{ _SelectNewEnv }



FUNCTION
        _fnlpGetResidentPartStart : System.Pointer;
{*
Description.
     Gets a pointer to the resident part if it is installed.
*}
VAR
  pTemp         :   System.Pointer;
  bResultOk     :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            sub     bx, bx              {BX<-0}
            mov     cx, bx              {CX<-0}
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Current_Status
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            cmp     bx, Globals.adwEXT_MPID_1
            jne    @Done
            cmp     cx, Globals.adwEXT_MPID_2
            jne    @Done
            mov     bResultOk, System.True
            mov     WORD  PTR  pTemp+0, di
            mov     WORD  PTR  pTemp+2, es
       @Done:
     END;
     {asm-end}
     IF (bResultOk)
         THEN   BEGIN
           _fnlpGetResidentPartStart := pTemp;
                END
         ELSE   BEGIN
           Video._HaltProgram(Messages._fnsTextMessageByIndex(122),
                              Globals.errCallToGetCurrentStatusFailed);
                END;
     {if-then-else}
END;
{ _fnlpGetResidentPartStart }



PROCEDURE
         _ResetCurrentEnvironment;
{*
Description.
     Resets a current environment (wipes copy of current environment record).
*}
VAR
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Reset_Cur_Environ
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     IF NOT(bResultOk)
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(123),
                                  Globals.errResetCurEnvFailed);
     {if-then}
END;
{ _ResetCurrentEnvironment }



PROCEDURE
         _ResetCurrentFreeDataSpacePointer;
{*
Description.
      Resets a current pointer of free space (to NIL).
*}
VAR
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Reset_Free_Space_Ptr
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     IF (NOT(bResultOk))
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(124),
                                  Globals.errResetCurFreeSpacePtrFailed);
     {if-then}
END;
{ _ResetCurrentFreeDataSpacePointer }



PROCEDURE
         _SetEstimateTimerFlag(bNewTimerFlag : System.Boolean);
{*
Description.
     Sets a new flag for estimate timer.
*}
VAR
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Set_Estimate_Timer
            mov     bl, 1               {Subfunction Set}
            mov     bh, bNewTimerFlag
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     IF  (NOT(bResultOk))
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(334),
                                  Globals.errSetNewTimerFlagFailed);
     {if-then}
END;
{ _SetEstimateTimerFlag }



PROCEDURE
         _GetEstimateTimer(VAR  bCurTimerFlag : System.Boolean;
                           VAR  dwLastEstimateTimeValue : System.Word);
{*
Description.
     Returns a current state of estimate timer.
*}
VAR
  dwCount     :   System.Word;
  bState      :   System.Boolean;
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Set_Estimate_Timer
            mov     bl, 0               {SubFunction: Get}
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     dwCount, cx
            mov     bState, bh
       @Done:
     END;
     IF  (NOT(bResultOk))
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(335),
                                  Globals.errGetStateOfTimerFailed)
         ELSE  BEGIN
             bCurTimerFlag := bState;
             dwLastEstimateTimeValue := dwCount;
               END;
     {if-then-else}
END;
{ _GetEstimateTimer }



FUNCTION
        _fnsGetEstimateTimerStateDesc : STRING;
{*
Description.
     Returns the estimate timer state description string.
*}
VAR
  sTemp         :   STRING;
  dwCount       :   System.Word;
  bState        :   System.Boolean;

BEGIN
  _GetEstimateTimer(bState,dwCount);
  IF  (bState)
    THEN  sTemp := Messages._fnsTextMessageByIndex(432)
    ELSE  sTemp := Messages._fnsTextMessageByIndex(337);
  {if-then-else}
  _fnsGetEstimateTimerStateDesc := sTemp;
END;
{ _fnsGetEstimateTimerStateDesc }



PROCEDURE
         _GetProgramInfo(VAR  dwDataBufSize  :  System.Word;
                         pDataBuf  :  System.Pointer);
{*
Description.
    Returns the resident program list information.
*}
VAR
  dwCount           :  System.Word;
  bResultOk         :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     bx, WORD PTR pDataBuf+0
            mov     es, WORD PTR pDataBuf+2
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Program_Info
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     dwCount, cx
       @Done:
     END;
     {asm-end}
     IF (bResultOk)
         THEN   BEGIN
            dwDataBufSize := dwCount;
                END
         ELSE   BEGIN
            Video._HaltProgram(Messages._fnsTextMessageByIndex(351),
                               Globals.errGetProgramList);
                END;
     {if-then-else}
END;
{ _GetProgramInfo }



PROCEDURE
         _CopyGlobalFreeDataSpacePointerToEnvironment(dwEnvironment : System.Word);
{*
Description.
   Copies a global pointer of free space to the specified
   environment record.
*}
VAR
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     bx, dwEnvironment
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Copy_Free_Links_To_Env
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     IF (NOT(bResultOk))
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(397),
                                  Globals.errCopyCurFreeSpacePtrFailed);
     {if-then}
END;
{ _CopyGlobalFreeDataSpacePointerToEnvironment }



PROCEDURE
         _AddNewEntryInDictionary(sAddEntry : STRING;
                                  dwAddWordLen :  System.Word;
                                  VAR  dbStatusCode : System.Byte);
{*
Description.
     Adds the new entry for the current resident dictionary.
*}
VAR
  dwAddEntryBufSeg,
  dwAddEntryBufOfs,
  dwAddEntryBufSize     :   System.Word;
  dbResultCode          :   System.Byte;
  bResultOk             :   System.Boolean;

BEGIN
     bResultOk := System.False;
     dwAddEntryBufSeg := System.Seg(sAddEntry[1]);
     dwAddEntryBufOfs := System.Ofs(sAddEntry[1]);
     ASM
            mov     es, dwAddEntryBufSeg
            mov     bx, dwAddEntryBufOfs
            mov     cx, dwAddWordLen
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Add_Dict_Entry
            call    _CallBackDoorInterface
            jc     @Done
            mov     bResultOk, System.True
            mov     dbResultCode, al
       @Done:
     END;
     IF  (bResultOk)
         THEN  BEGIN
            dbStatusCode := dbResultCode;
               END
         ELSE  BEGIN
          Video._HaltProgram(Messages._fnsTextMessageByIndex(407),
                             Globals.errAddEntryDictCallFailed);
               END;
     {if-then-else}
END;
{ _AddNewEntryInDictionary }



FUNCTION
        _fnsTransEnvHandleToDictName(dwEnvHandle : System.Word) : STRING;
{*
Description.
     Translates the specified environment index into the dictionary name.
*}
VAR
  pDictMemImage  :  lprecEnvironmentDesc;
  sDictName      :  STRING;

BEGIN
  sDictName := asBlank;  {NOT FOUND!}
  pDictMemImage := _fnlpTransEnvHandleToDictPtr(dwEnvHandle);
  IF  (pDictMemImage <> NIL)
    THEN  sDictName := pDictMemImage^.sDictName16;
  {if-then}
  _fnsTransEnvHandleToDictName := sDictName;
END;
{ _fnsTransEnvHandleToDictName }



FUNCTION
        _fnsTransEnvHandleToDictComment(dwEnvHandle : System.Word) : STRING;
{*
Description.
    Translates the specified environment index to the dictionary comment.
*}
VAR
  pDictMemImage  :  lprecEnvironmentDesc;
  sDictComment   :  STRING;

BEGIN
  sDictComment := asBlank;  {NOT FOUND!}
  pDictMemImage := _fnlpTransEnvHandleToDictPtr(dwEnvHandle);
  IF  (pDictMemImage <> NIL)
    THEN  sDictComment := pDictMemImage^.sDictComment32;
  {if-then}
  _fnsTransEnvHandleToDictComment := sDictComment;
END;
{ _fnsTransEnvHandleToDictComment }



FUNCTION
        _fndwTransDictNameToEnvHandle(sDictName : Globals.DictNameSTR16) : System.Word;
{*
Description.
    Translates the specified dictionary name to the matching
    environment index;
    returns 0 if not found matching name.
*}
VAR
  dwEnvIndex,
  dwMatchEnv           :   System.Word;

BEGIN
  dwEnvIndex := 0;
  dwMatchEnv := 0;  {NOT FOUND!}
  WHILE  ((dwMatchEnv = 0)  AND
         (dwEnvIndex < Globals.aEnviron_Avail_Max))
  DO  BEGIN
      System.Inc(dwEnvIndex);
      IF  (sDictName = _fnsTransEnvHandleToDictName(dwEnvIndex))
        THEN  dwMatchEnv := dwEnvIndex;
      {if-then}
  END;
  {while-do}
  _fndwTransDictNameToEnvHandle := dwMatchEnv;
END;
{ _fndwTransDictNameToEnvHandle }


PROCEDURE
         _RemoveDictByIndex(dwDictIndex : System.Word);
{*
Description.
    Removes the user data dictionary from memory by a given index.
*}
VAR
   dwCurEnvHandle,
   dwDictMemSeg         :  System.Word;
   pDictInMem           :  System.Pointer;
   bFreeMemOk,
   bDictDelOk           :  System.Boolean;
   s16DictionaryName    :  Globals.DictNameSTR16;

BEGIN
    bDictDelOk := System.False;
{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(211)+' #'+
                                        StrLib._fnsNumToStr(dwDictIndex,2),
                                        Globals.aModuleCallBack);
    {if-then}
{$ENDIF} {DebVer}
    pDictInMem := _fnlpTransEnvHandleToDictPtr(dwDictIndex);
    IF  (pDictInMem = NIL)
      THEN  BEGIN
{$IFDEF   DebVer}
        IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
           THEN  Video._OutputMessage(Messages._fnsTextMessageByIndex(212),
                                      System.True);
        {if-then}
{$ENDIF} {DebVer}
            END
      ELSE  BEGIN
         s16DictionaryName := _fnsTransEnvHandleToDictName(dwDictIndex);
         IF  (System.Ofs(pDictInMem^) <> 0)
           THEN  BEGIN
{$IFDEF   DebVer}
              IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
                THEN  Video._OutputMessage(Messages._fnsTextMessageByIndex(213),
                                           System.True);
              {if-then}
{$ENDIF} {DebVer}
                 END
           ELSE  BEGIN
                dwDictMemSeg := System.Seg(pDictInMem^);
                IF  (DosCtl._fnbIsLowMemBlock(dwDictMemSeg))
                  THEN  BEGIN
{$IFDEF   DebVer}
                   IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
                        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(214),
                                                        Globals.aModuleCallBack);
                   {if-then}
{$ENDIF} {DebVer}
                    bFreeMemOk := DosCtl._fnbReleaseLowMemBlock(dwDictMemSeg-Globals.aPSP_Size_In_Paras);
                        END
                  ELSE  BEGIN
{$IFDEF   DebVer}
                   IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
                        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(215),
                                                        Globals.aModuleCallBack);
                   {if-then}
{$ENDIF} {DebVer}
                    bFreeMemOk := DosCtl._fnbReleaseHighMemBlock(dwDictMemSeg);
                        END;
                {if-then-else}
                IF  NOT(bFreeMemOk)
                  THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(216),
                                           Globals.errBadProgramMemoryUninstall);
                {if-then}
                _RemoveThisEnvFromEnvList(dwDictIndex);
                dwCurEnvHandle := _fndwGetCurEnv;
                IF  (dwCurEnvHandle = dwDictIndex)
                  THEN  BEGIN
                     {switch off screen border if enabled}
                     _SetCurrentKeyboardMode(Globals.aStateIsIdleMode);
                     _ResetCurrentEnvironment;
                     Video._OutputMessage(Messages._fnsTextMessageByIndex(217),
                                          System.True);
                        END;
                {if-then-else}
                bDictDelOk := System.True;
                 END;
         {if-then-else}
            END;
    {if-then-else}
    IF  (bDictDelOk)
      THEN  Video._OutputMessage(Messages._fnsTextMessageByIndex(218)+
                                 ''''+
                                 s16DictionaryName+
                                 ''''+
                                 Messages._fnsTextMessageByIndex(562),
                                 System.True)
      ELSE  Video._OutputMessage(Messages._fnsTextMessageByIndex(219),
                                 System.True);
    {if-then-else}
END;
{ _RemoveDictByIndex }



PROCEDURE
         _RemoveDictByName(sUserDictName : STRING);
{*
Description.
       Removes the user data dictionary from memory by a given name.
*}
VAR
  dwDictEnvHandle   :   System.Word;

BEGIN
   dwDictEnvHandle := _fndwTransDictNameToEnvHandle(sUserDictName);
   IF  (dwDictEnvHandle = 0)
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(220),
                              Globals.errBadUserDictNameToRemove)
     ELSE  Video._OutputMessage(Messages._fnsTextMessageByIndex(221),
                                System.True);
   {if-then-else}
   _RemoveDictByIndex(dwDictEnvHandle);
END;
{ _RemoveDictByName }



PROCEDURE
         _ListAllLoadedDictionaries;
{*
Description.
    Displays an user information about all the loaded dictionaries,
    found in the memory.
*}
VAR
  dwCurEnvHandle,
  dwEnvNum,
  dwEnvCount            :    System.Word;
  pDictInMem            :    System.Pointer;
  sTemp                 :    STRING;

BEGIN
  Video._OutputMessage(Messages._fnsTextMessageByIndex(222),
                       System.True);
  dwCurEnvHandle := _fndwGetCurEnv;
  dwEnvCount := 0;
  FOR  dwEnvNum := Globals.aEnviron_Avail_Min  TO  Globals.aEnviron_Avail_Max  DO
  BEGIN
     pDictInMem := _fnlpTransEnvHandleToDictPtr(dwEnvNum);
     IF  (pDictInMem <> NIL)
       THEN  BEGIN
         System.Inc(dwEnvCount);
         sTemp := Messages._fnsTextMessageByIndex(223)+_fnsNumToStr(dwEnvNum,2)+
                              ', '+Messages._fnsTextMessageByIndex(224)+''''+
                              _fnsTransEnvHandleToDictName(dwEnvNum)+
                              ''', '+
                              Messages._fnsTextMessageByIndex(225)+''''+
                              _fnsTransEnvHandleToDictComment(dwEnvNum)+
                              '''';
         IF  (dwEnvNum = dwCurEnvHandle)
           THEN  sTemp := Globals.achAsterisk + sTemp
           ELSE  sTemp := Globals.achSPACE + sTemp;
         {if-then-else}
         Video._OutputMessage(sTemp,System.True);
             END;
     {if-then}
  END;
  {for-to-do}
  IF  (dwEnvCount = 0)
     THEN  Video._OutputMessage(Messages._fnsTextMessageByIndex(226),
                                System.True)
     ELSE  Video._OutputMessage(Messages._fnsTextMessageByIndex(227)+_fnsNumToStr(dwEnvCount,2),
                                System.True);
  {if-then-else}
END;
{ _ListAllLoadedDictionaries }



PROCEDURE
         _RemoveAllDictionariesFromMemory;
{*
Description.
    Removes all the found dictionaries from a memory.
*}
VAR
  dwEnvNum   :    System.Word;

BEGIN
  Video._OutputMessage(Messages._fnsTextMessageByIndex(228),
                       System.True);
  FOR  dwEnvNum := Globals.aEnviron_Avail_Min  TO  Globals.aEnviron_Avail_Max  DO
  BEGIN
    IF  NOT(_fnbIsFreeIndex(dwEnvNum))
      THEN  _RemoveDictByIndex(dwEnvNum);
    {if-then}
  END;
  {for-to-do}
END;
{ _RemoveAllDictionariesFromMemory }



PROCEDURE
          _DoResidentPartDiagDump;
{*
Description.
    Outputs useful diagnostic information about the resident program.
*}
VAR
  dbTempBuf  :  ARRAY[1..128]  OF  System.Byte;  {make sure sufficient buffer}
  recProgramInfo   :  Globals.recProgramInfoList  ABSOLUTE  dbTempBuf;
  lpCurStatBlock   : Globals.lpStatTimingBlock;
  liTotalUsedMemory : System.Longint;
  dwStatBlockMemSeg,
  dwStatMemBlkSize,
  dwFreeSpaceSize,
  dwInfoBufSize,
  dwDataBlockSeg,
  dwDataBlockSize,
  dwAllHandles,
  dwHandleIndex,
  dwTotalHandles,
  dwUsedHandles,
  dwFreeHandles,
  dwCurHandle    :  System.Word;
  pEnvTable,
  pThisEnv       :  System.Pointer;
  sTemp8,
  sBlock8        :  STR8;

BEGIN
  Video._OutputMessage(Messages._fnsTextMessageByIndex(349),
                       System.True);
  Video._OutputMessage(Messages._fnsTextMessageByIndex(372),
                       System.True);
  dwInfoBufSize := 0;
  _GetProgramInfo(dwInfoBufSize,@recProgramInfo);
  IF  (dwInfoBufSize <> 0)
    THEN  WITH  (recProgramInfo)  DO
          BEGIN
       liTotalUsedMemory := System.Longint(dwResidentProgramSizeInParas) SHL 4;
       Video._OutputMessage(Messages._fnsTextMessageByIndex(355)+
                            StrLib._fnsNumToStr(dbInternalRelease,3),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(356)+
                            StrLib._fnsNumToStr(dbInternalVersion,3),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(357)+
                            StrLib._fnsNumToStr(dbInternalRevision,3),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(358)+
                            StrLib._fnsWordToTurboHexFmt(dwResidentProgramSegment),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(359)+
                            StrLib._fnsNumToStr(liTotalUsedMemory,3)+
                            Messages._fnsTextMessageByIndex(254),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(360)+
                            StrLib._fnsByteToTurboHexFmt(dbInterfaceInterruptNumber),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(361)+
                            StrLib._fnsByteToTurboHexFmt(dbMultiplexChannelNumber),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(362)+
                            StrLib._fnsNumToStr(dbMaxSupportedFunctionsNum+1,3),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(363)+
                            StrLib._fnsNumToStr(dbCurrentStateMode,3)+
                            ' ('+
                            _fnsGetCurrentKeyboardModeDesc(dbCurrentStateMode)+
                            ')',
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(364)+
                            StrLib._fnsNumToStr(dbCurrentSearchSubStateMode,3)+
                            ' ('+
                            _fnsGetCurrentSubStateModeDesc(dbCurrentSearchSubStateMode)+
                            ')',
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(365)+
                            StrLib._fnsNumToStr(dbLastStatusCode,3)+
                            ' ('+
                            _fnsGetLastStatusCodeDesc(dbLastStatusCode)+
                            ')',
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(366)+
                            StrLib._fnsNumToStr(dbInitWaitTimerTicks,3),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(367)+
                            StrLib._fnsBooleanStateOfVar(bEstimateTimerFlag),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(368)+
                            StrLib._fnsNumToStr(dwLastEstimateTimerValue,5),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(369)+
                            StrLib._fnsNumToStr(dwFreeSpaceSize,5)+
                            Messages._fnsTextMessageByIndex(254),
                            System.True);
       Video._OutputMessage(Messages._fnsTextMessageByIndex(370)+
                            StrLib._fnsPointerToTurboHexFmt(lpFreeSpaceLink),
                            System.True);
          END
          {with-do}
    ELSE  BEGIN
      Video._OutputMessage(Messages._fnsTextMessageByIndex(371),
                           System.True);
          END;
  {if-then-else}
  _GetEnvListInfo(dwAllHandles,pEnvTable);
  Video._OutputMessage(Messages._fnsTextMessageByIndex(383),
                       System.True);
  Video._OutputMessage(Messages._fnsTextMessageByIndex(240)+
                       StrLib._fnsPointerToTurboHexFmt(pEnvTable),
                       System.True);
  Video._OutputMessage(Messages._fnsTextMessageByIndex(384),
                       System.True);
  Video._OutputMessage(Messages._fnsTextMessageByIndex(548),
                       System.True);
  dwTotalHandles := dwAllHandles;
  dwFreeHandles := 0;
  FOR  dwHandleIndex := Globals.aEnviron_Avail_Min  TO  dwAllHandles  DO
  BEGIN
      IF  (_fnbIsFreeIndex(dwHandleIndex))
        THEN  BEGIN
          sTemp8 := Messages._fnsTextMessageByIndex(385);
          System.Inc(dwFreeHandles);
              END
        ELSE  BEGIN
          sTemp8 := Messages._fnsTextMessageByIndex(386);
              END;
      {if-then-else}
      dwDataBlockSeg := System.Seg(_fnlpTransEnvHandleToDictPtr(dwHandleIndex)^);
      dwDataBlockSize := System.MemW[(dwDataBlockSeg-(1+Globals.aPSP_Size_In_Paras)):Globals.aDosMemBlockSize];
      pThisEnv := _fnlpTransEnvHandleToDictPtr(dwHandleIndex);
      dwFreeSpaceSize := Globals.lprecEnvironmentDesc(pThisEnv)^.dwFreeSize;
      IF  (dwDataBlockSeg = (recProgramInfo.dwResidentProgramSegment+Globals.aPSP_Size_In_Paras))
        THEN  sBlock8 := Messages._fnsTextMessageByIndex(393)
        ELSE  BEGIN
           IF  (DosCtl._fnbIsLowMemBlock(dwDataBlockSeg))
             THEN  BEGIN
               IF  (pThisEnv = NIL)
                 THEN  BEGIN
                   sBlock8 := Messages._fnsTextMessageByIndex(396);
                   dwDataBlockSize := 0;
                   dwFreeSpaceSize := 0;
                       END
                 ELSE  BEGIN
                   sBlock8 := Messages._fnsTextMessageByIndex(394);
                       END;
               {if-then-else}
                   END
             ELSE  BEGIN
               sBlock8 := Messages._fnsTextMessageByIndex(395);
               dwDataBlockSize := System.MemW[(dwDataBlockSeg-1):Globals.aDosMemBlockSize];
                   END;
           {if-then-else}
              END;
      {if-then-else}
      System.Inc(liTotalUsedMemory,(System.Longint(dwDataBlockSize) SHL 4));
      Video._OutputMessage(' '+
                           StrLib._fnsNumToStrNoAdj(dwHandleIndex,2)+
                           '    '+
                           StrLib._fnsPointerToTurboHexFmt(pThisEnv)+
                           '   '+
                           sTemp8+
                           '   '+
                           StrLib._fnsTrailingAddSpacesToMax(_fnsTransEnvHandleToDictName(dwHandleIndex),
                                  System.SizeOf(Globals.DictNameSTR16)-1)+
                           '  '+
                           sBlock8+
                           '   '+
                           StrLib._fnsNumToStrNoAdj((System.Longint(dwDataBlockSize) SHL 4),5)+
                           ','+
                           StrLib._fnsNumToStr(dwFreeSpaceSize,5)+
                           Messages._fnsTextMessageByIndex(254),
                           System.True);
  END;
  {for-to-do}
  dwUsedHandles := dwTotalHandles - dwFreeHandles;
  Video._OutputMessage(Messages._fnsTextMessageByIndex(387),
                       System.True);
  Video._OutputMessage(Messages._fnsTextMessageByIndex(388)+
                       StrLib._fnsNumToStr(dwTotalHandles,2)+
                       ', '+
                       Messages._fnsTextMessageByIndex(389)+
                       StrLib._fnsNumToStr(dwUsedHandles,2)+
                       ', '+
                       Messages._fnsTextMessageByIndex(390)+
                       StrLib._fnsNumToStr(dwFreeHandles,2)+
                       ', '+
                       Messages._fnsTextMessageByIndex(391)+
                       StrLib._fnsNumToStr(_fndwGetCurEnv,2),
                       System.True);
  Video._OutputMessage(Messages._fnsTextMessageByIndex(392)+
                       StrLib._fnsPointerToTurboHexFmt(_fnlpGetCurEnvSettings),
                       System.True);
{$IFDEF   StaVer}
  lpCurStatBlock := _fnlpGetStatBlock;
  Video._OutputMessage(Messages._fnsTextMessageByIndex(531),
                       System.True);
  Video._OutputMessage(Messages._fnsTextMessageByIndex(530)+
                       StrLib._fnsPointerToTurboHexFmt(lpCurStatBlock),
                       System.True);
  Video._OutputMessage(Messages._fnsTextMessageByIndex(528)+
                       StrLib._fnsBooleanStateOfVar(lpCurStatBlock^.bRunStatTimingMode),
                       System.True);
  Video._OutputMessage(Messages._fnsTextMessageByIndex(529)+
                       StrLib._fnsPointerToTurboHexFmt(lpCurStatBlock^.lpStatTimingMemBlock),
                       System.True);
  dwStatBlockMemSeg := System.Seg(lpCurStatBlock^.lpStatTimingMemBlock^);
  IF  (dwStatBlockMemSeg <> 0)
    THEN  BEGIN
      IF  (DosCtl._fnbIsLowMemBlock(dwStatBlockMemSeg))
        THEN  dwStatMemBlkSize := System.MemW[(dwStatBlockMemSeg-(1+Globals.aPSP_Size_In_Paras)):Globals.aDosMemBlockSize]
        ELSE  dwStatMemBlkSize := System.MemW[(dwStatBlockMemSeg-1):Globals.aDosMemBlockSize];
      {if-then-else}
          END
    ELSE  BEGIN
       dwStatMemBlkSize := 0;
          END;
  {if-then-else}
  System.Inc(liTotalUsedMemory,(System.Longint(dwStatMemBlkSize) SHL 4));
  Video._OutputMessage(Messages._fnsTextMessageByIndex(556)+
                       StrLib._fnsNumToStr((System.Longint(dwStatMemBlkSize) SHL 4),5)+
                       Messages._fnsTextMessageByIndex(254),
                       System.True);
{$ENDIF} {StaVer}
  Video._OutputMessage(Messages._fnsTextMessageByIndex(558),
                       System.True);
  Video._OutputMessage(Messages._fnsTextMessageByIndex(559)+
                       StrLib._fnsNumToStr(liTotalUsedMemory,6)+
                       Messages._fnsTextMessageByIndex(254),
                       System.True);
END;
{ _DoResidentPartDiagDump }



PROCEDURE
         _SetupEstimateTimer(dbNewState : System.Byte);
{*
Description.
   Initializes estimate timer with a new state.
*}
BEGIN
{$IFDEF   DebVer}
          IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
               THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(431),
                                               Globals.aModuleCallBack);
          {if-then}
{$ENDIF} {DebVer}
          CASE  (dbNewState)  OF
                aNoneTimer       :   BEGIN
                                     END;
                aStopTimer        :  BEGIN
                                   _SetEstimateTimerFlag(System.False);
                                     END;
                aStartTimer      :   BEGIN
                                   _SetEstimateTimerFlag(System.True);
                                     END;
          ELSE  BEGIN
             Video._HaltProgram(Messages._fnsTextMessageByIndex(433),
                                Globals.errBadRunTimerValue)
                END;
          END;
          {case-of}

{$IFDEF   DebVer}
          IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
               THEN  Video._OutputDebugMessage(_fnsGetEstimateTimerStateDesc,
                                               Globals.aModuleCallBack);
          {if-then}
{$ENDIF} {DebVer}
END;
{ _SetupEstimateTimer }



FUNCTION
        _fndwGetCurrentUserEnvOptions : System.Word;
{*
Description.
     Returns the current environment user options.
*}
VAR
  dwEnvOptions :   System.Word;
  bResultOk   :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     ah, gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Set_User_Options
            sub     bx, bx                    {Subfunction Get}
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     dwEnvOptions, cx
       @Done:
     END;
     IF  (NOT(bResultOk))
       THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(444),
                                Globals.errGetCurEnvOptionsFailed);
     {if-then}
     _fndwGetCurrentUserEnvOptions := dwEnvOptions;
END;
{ _fndwGetCurrentUserEnvOptions }



FUNCTION
        _fnlpGetStatBlock : Globals.lpStatTimingBlock;
{*
Description.
    Returns the statistics block pointer.
*}
VAR
  lpStatBlock        :   System.Pointer;
  bResultOk          :   System.Boolean;

BEGIN
     bResultOk := System.False;
     lpStatBlock := NIL;
     ASM
            sub     bx, bx               {Get subfunction (0)}
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Set_Stat_Block
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
            mov     WORD PTR lpStatBlock.[0], di
            mov     WORD PTR lpStatBlock.[2], es
       @Done:
     END;
     {asm-end}
     IF (bResultOk)
         THEN   BEGIN
{$IFDEF   DebVer}
           IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
               THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(504)+
                        StrLib._fnsPointerToTurboHexFmt(lpStatBlock),
                        Globals.aModuleCallBack);
           {if-then}
{$ENDIF} {DebVer}
                END
         ELSE   BEGIN
           Video._HaltProgram(Messages._fnsTextMessageByIndex(502),
                              Globals.errCallToGetStatBlockFailed);
                END;
     {if-then-else}

     _fnlpGetStatBlock := lpStatBlock;
END;
{ _fnlpGetStatBlock }



PROCEDURE
         _SetStatBlock(lpStatBlock : Globals.lpStatTimingBlock);
{*
Description.
    Sets the new statistics block pointer.
*}
VAR
  bResultOk          :   System.Boolean;

BEGIN
     bResultOk := System.False;
     ASM
            mov     bl, 1                     {Set subfunction (1)}
            mov     di, WORD PTR lpStatBlock.[0]
            mov     es, WORD PTR lpStatBlock.[2]
            mov     ah, Globals.gdbCurMultiplexChannel
            mov     al, Globals.aITypist_Get_Set_Stat_Block
            call    _CallBackDoorInterface
            jc     @Done
            cmp     al, Globals.aMP_Successful_Done
            jne    @Done
            mov     bResultOk, System.True
       @Done:
     END;
     {asm-end}
     IF (bResultOk)
         THEN   BEGIN
{$IFDEF   DebVer}
           IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
               THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(505)+
                        StrLib._fnsPointerToTurboHexFmt(lpStatBlock),
                        Globals.aModuleCallBack);
           {if-then}
{$ENDIF} {DebVer}
                END
         ELSE   BEGIN
           Video._HaltProgram(Messages._fnsTextMessageByIndex(503),
                              Globals.errCallToSetStatBlockFailed);
                END;
     {if-then-else}

END;
{ _SetStatBlock }



{$IFDEF   StaVer}

FUNCTION
           _bIsStatBlockPresentGlobal : System.Boolean;
{*
Description.
    Tests the returned statistics block pointer.
*}
BEGIN
   _bIsStatBlockPresentGlobal := (_fnlpGetStatBlock <> NIL);
END;
{ _bIsStatBlockPresentGlobal }



FUNCTION
           _bIsMemBlockInStatBlockPresent : System.Boolean;
{*
Description.
    Tests the returned memory statistics block pointer.
*}
BEGIN
   _bIsMemBlockInStatBlockPresent := (_fnlpGetStatBlock^.lpStatTimingMemBlock <> NIL);
END;
{ _bIsMemBlockInStatBlockPresent }



PROCEDURE
         _DisableTypingWatchMonitoring(lpStatBlock : Globals.lpStatTimingBlock);
{*
Description.
    Stops a collection of the typing statistcis.
*}
BEGIN
   lpStatBlock^.bRunStatTimingMode := System.False;
   _SetStatBlock(lpStatBlock);
END;
{ _DisableTypingWatchMonitoring }



PROCEDURE
         _EnableTypingWatchMonitoring(lpStatBlock : Globals.lpStatTimingBlock);
{*
Description.
    Starts a collection of the typing statistcis.
*}
BEGIN
   WITH  (lpStatBlock^)  DO
   BEGIN
      IF  ((lpStatTimingMemBlock = NIL) AND
           (lpCurKeystrokesTimingRec = NIL))
         THEN  BEGIN
           Video._HaltProgram(Messages._fnsTextMessageByIndex(527),
                              Globals.errMoMemFoundToEnableTypingWatch);
               END;
      {if-then}
      bRunStatTimingMode := System.True;
   END;
   {with-do}
   _SetStatBlock(lpStatBlock);
END;
{ _EnableTypingWatchMonitoring }



PROCEDURE
           _ResetTypingStat;
{*
Description.
    Removes a typing watch memory and reset all the statistics.
*}
VAR
  lpCurStatBlock         :  Globals.lpStatTimingBlock;
  lpDosMemBlock          :  System.Pointer;
  dwStatBlockMemSeg      :  System.Word;
  bFreeMemOk             :  System.Boolean;

BEGIN
   Video._OutputMessage(Messages._fnsTextMessageByIndex(516),
                        System.True);
   IF  (NOT(_bIsStatBlockPresentGlobal))
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(515),
                              Globals.errNoStatBlockGlobalSupport);
   {if-then}
   bFreeMemOk :=  System.False;
   {stop watching}
   lpCurStatBlock := _fnlpGetStatBlock;
   IF  (_bIsMemBlockInStatBlockPresent)
     THEN   BEGIN
        lpDosMemBlock := lpCurStatBlock^.lpStatTimingMemBlock;
        dwStatBlockMemSeg := System.Seg(lpDosMemBlock^);
{$IFDEF   DebVer}
        IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
            THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(524)+
                     StrLib._fnsPointerToTurboHexFmt(lpDosMemBlock),
                     Globals.aModuleCallBack);
        {if-then}
{$ENDIF} {DebVer}
            END
     ELSE   BEGIN
          Video._HaltProgram(Messages._fnsTextMessageByIndex(520),
                             Globals.errNoAllocMemInStatBlock);
            END;
   {if-then-else}
{$IFDEF   DebVer}
      IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
           THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(525),
                                           Globals.aModuleCallBack);
      {if-then}
{$ENDIF} {DebVer}
   _DisableTypingWatchMonitoring(lpCurStatBlock);
{$IFDEF   DebVer}
      IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
           THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(526),
                                           Globals.aModuleCallBack);
      {if-then}
{$ENDIF} {DebVer}
   IF  (DosCtl._fnbIsLowMemBlock(dwStatBlockMemSeg))
     THEN  BEGIN
{$IFDEF   DebVer}
      IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
           THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(517),
                                           Globals.aModuleCallBack);
      {if-then}
{$ENDIF} {DebVer}
       bFreeMemOk := DosCtl._fnbReleaseLowMemBlock(dwStatBlockMemSeg-Globals.aPSP_Size_In_Paras);
           END
     ELSE  BEGIN
{$IFDEF   DebVer}
      IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
           THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(518),
                                           Globals.aModuleCallBack);
      {if-then}
{$ENDIF} {DebVer}
       bFreeMemOk := DosCtl._fnbReleaseHighMemBlock(dwStatBlockMemSeg);
           END;
   {if-then-else}
   IF  NOT(bFreeMemOk)
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(519),
                              Globals.errBadProgramMemoryUninstall);
   {if-then}
   {reset all statistcis}
{$IFDEF   DebVer}
      IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
           THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(521),
                                           Globals.aModuleCallBack);
      {if-then}
{$ENDIF} {DebVer}
   WITH  (lpCurStatBlock^)  DO
   BEGIN
     bRunStatTimingMode        := System.False;
     dbStartingHour            := 0;
     dbStartingMinute          := 0;
     dwTotalTimeInMinutes      := 0;
     dwRemTimeInMinutes        := 0;
     dwInitTicksPerMinute      := 0;
     dwCurTicksForMinute       := 0;
     lpStatTimingMemBlock      := NIL;
     lpCurKeystrokesTimingRec  := NIL;
   END;
   {with-do}
   _SetStatBlock(lpCurStatBlock);
END;
{ _ResetTypingStat }



PROCEDURE
          _DispTypingStat;
{*
Description.
   Writes a typing activity watch monitoring to a file.
*}
CONST
  dwTypStatFileExt       :  System.Word = 0;
VAR
  fTextStream            :  System.Text;
  lpCurStatBlock         :  Globals.lpStatTimingBlock;
  liTempDivisor,
  liTotalTrueTypistKeys,
  liTotalTrueUserKeys,
  liTotalAllKeys,
  liKeysForThisMinute,
  liTotalUserKeys,
  liTotalTypistKeys      :  System.Longint;
  dwTrueWatchTime,
  dwSaveWatchTime,
  dwWatchHour,
  dwWatchMinute,
  dwUserKeys,
  dwProgramKeys,
  dwOfsOfNextRecord,
  dwStatBlockMemSeg,
  dwMemBlkSize,
  dwWatchTimeInMinutes   :  System.Word;

BEGIN
   Video._OutputMessage(Messages._fnsTextMessageByIndex(532),
                        System.True);
   IF  (NOT(_bIsStatBlockPresentGlobal))
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(515),
                              Globals.errNoStatBlockGlobalSupport);
   {if-then}
   lpCurStatBlock := _fnlpGetStatBlock;
   IF  (_bIsMemBlockInStatBlockPresent)
     THEN   BEGIN
        dwStatBlockMemSeg := System.Seg(lpCurStatBlock^.lpStatTimingMemBlock^);
            END
     ELSE   BEGIN
          Video._HaltProgram(Messages._fnsTextMessageByIndex(520),
                             Globals.errNoAllocMemInStatBlock);
            END;
   {if-then-else}
    System.Assign(fTextStream,StrLib._fnsGetNewFileName(dwTypStatFileExt,'TYPSTAT'));
    System.Rewrite(fTextStream);
    System.WriteLn(fTextStream,'<<< '+Messages._fnsTextMessageByIndex(533)+' >>>');
    System.WriteLn(fTextStream,'<<< ('+Messages._fnsTextMessageByIndex(40)+') >>>');
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream,'<<< '+Messages._fnsTextMessageByIndex(542));
    System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(530)+
                          StrLib._fnsPointerToTurboHexFmt(lpCurStatBlock));
    WITH  (lpCurStatBlock^)  DO
    BEGIN
       System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(528)+
                            StrLib._fnsBooleanStateOfVar(bRunStatTimingMode));
       System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(529)+
                            StrLib._fnsPointerToTurboHexFmt(lpStatTimingMemBlock));
       IF  (dwStatBlockMemSeg <> 0)
         THEN  BEGIN
              IF  (DosCtl._fnbIsLowMemBlock(dwStatBlockMemSeg))
                THEN  dwMemBlkSize := System.MemW[(dwStatBlockMemSeg-(1+Globals.aPSP_Size_In_Paras)):Globals.aDosMemBlockSize]
                ELSE  dwMemBlkSize := System.MemW[(dwStatBlockMemSeg-1):Globals.aDosMemBlockSize];
              {if-then-else}
               END
         ELSE  BEGIN
            dwMemBlkSize := 0;
               END;
       {if-then-else}
       System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(556)+
                            StrLib._fnsNumToStr((System.Longint(dwMemBlkSize) SHL 4),5)+
                            Messages._fnsTextMessageByIndex(254));
       System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(534)+
                            StrLib._fnsPointerToTurboHexFmt(lpCurKeystrokesTimingRec));
       System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(535)+
                            StrLib._fnsNumToStr(dwInitTicksPerMinute,3));
       System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(536)+
                            StrLib._fnsNumToStr(dwCurTicksForMinute,3));
       System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(537)+
                            StrLib._fnsNumToStr(dbStartingHour,3));
       System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(538)+
                            StrLib._fnsNumToStr(dbStartingMinute,3));
       System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(539)+
                            StrLib._fnsNumToStr(dwTotalTimeInMinutes,5));
       System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(540)+
                            StrLib._fnsNumToStr(dwRemTimeInMinutes,5));
       dwWatchTimeInMinutes := dwTotalTimeInMinutes - dwRemTimeInMinutes;
       dwWatchHour := dbStartingHour;
       dwWatchMinute := dbStartingMinute;
    END;
    {with-do}
    System.WriteLn(fTextStream,'>>> '+Messages._fnsTextMessageByIndex(542));
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream,'----- '+Messages._fnsTextMessageByIndex(541)+' -----');
    System.WriteLn(fTextStream);
    IF  (dwWatchTimeInMinutes = 0)
      THEN  BEGIN
         System.WriteLn(fTextStream,+Messages._fnsTextMessageByIndex(543));
            END
      ELSE  BEGIN
         dwSaveWatchTime := dwWatchTimeInMinutes;
         liTotalTrueTypistKeys := 0;
         liTotalTrueUserKeys := 0;
         liTotalUserKeys := 0;
         liTotalTypistKeys := 0;
         dwOfsOfNextRecord := 0;
         dwTrueWatchTime := 0;
         System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(544));
         System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(545));
         REPEAT
           dwUserKeys := System.MemW[dwStatBlockMemSeg:dwOfsOfNextRecord];
           dwProgramKeys := System.MemW[dwStatBlockMemSeg:(dwOfsOfNextRecord+Globals.aWord)];
           IF  (dwProgramKeys <> 0)
             THEN  BEGIN
               System.Inc(liTotalTrueUserKeys,dwUserKeys);
               System.Inc(liTotalTrueTypistKeys,dwProgramKeys);
               System.Inc(dwTrueWatchTime);
                   END;
           {if-then}
           System.Inc(liTotalUserKeys,dwUserKeys);
           System.Inc(liTotalTypistKeys,dwProgramKeys);
           liKeysForThisMinute := dwProgramKeys + dwUserKeys;
           {avoid division by zero}
           liTempDivisor := liKeysForThisMinute;
           IF  (liTempDivisor = 0)
             THEN  liTempDivisor := 1;
           {if-then}
           System.WriteLn(fTextStream,Globals.achSPACE,
                          StrLib._fnsNumToStrNoAdj(dwWatchHour,2),
                          Globals.achColon,
                          StrLib._fnsReplaceChars(StrLib._fnsNumToStrNoAdj(dwWatchMinute,2),
                                  Globals.achSPACE,Globals.achZero),
                          '     ',
                          StrLib._fnsNumToStrNoAdj(liKeysForThisMinute,5),
                          '     ',
                          StrLib._fnsNumToStrNoAdj(dwUserKeys,5),
                          '     ',
                          StrLib._fnsNumToStrNoAdj(dwProgramKeys,5),
                          '     ',
                          StrLib._fnsNumToStrNoAdj(System.Trunc((dwProgramKeys*aPercent100)/
                                                  liTempDivisor),3),
                          Globals.achPercent);
           System.Inc(dwWatchMinute);
           IF  (dwWatchMinute >= Globals.aMinutesPerHour)
             THEN  BEGIN
                dwWatchMinute := 0;
                System.Inc(dwWatchHour);
                IF  (dwWatchHour >= (Globals.aHoursPerDay-1))
                  THEN  dwWatchHour := 0;
                {if-then}
                   END;
           {if-then}
           System.Dec(dwWatchTimeInMinutes);
           System.Inc(dwOfsOfNextRecord,System.SizeOf(recKeystrokesTiming));
         UNTIL  (dwWatchTimeInMinutes = 0);
         {repeat-until}
         {total results}
         System.WriteLn(fTextStream);
         System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(546));
         liTotalAllKeys := liTotalUserKeys + liTotalTypistKeys;
         dwWatchTimeInMinutes := dwSaveWatchTime;
         dwWatchHour := dwWatchTimeInMinutes DIV Globals.aMinutesPerHour;
         dwWatchMinute := dwWatchTimeInMinutes MOD Globals.aMinutesPerHour;
         {avoid division by zero}
         liTempDivisor := liTotalAllKeys;
         IF  (liTempDivisor = 0)
           THEN  liTempDivisor := 1;
         {if-then}
         System.WriteLn(fTextStream,Globals.achSPACE,
                        StrLib._fnsReplaceChars(StrLib._fnsNumToStrNoAdj(dwWatchHour,2),
                                Globals.achSPACE,Globals.achZero),
                        Globals.achColon,
                        StrLib._fnsReplaceChars(StrLib._fnsNumToStrNoAdj(dwWatchMinute,2),
                                Globals.achSPACE,Globals.achZero),
                        '    ',
                        StrLib._fnsNumToStrNoAdj(liTotalAllKeys,6),
                        '    ',
                        StrLib._fnsNumToStrNoAdj(liTotalUserKeys,6),
                        '    ',
                        StrLib._fnsNumToStrNoAdj(liTotalTypistKeys,6),
                        '     ',
                        StrLib._fnsNumToStrNoAdj(System.Trunc((liTotalTypistKeys*aPercent100)/
                                                liTempDivisor),3),
                        Globals.achPercent);
         System.WriteLn(fTextStream);
         System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(547));
         {more fair statistics}
         liTotalAllKeys := liTotalTrueUserKeys + liTotalTrueTypistKeys;
         dwWatchHour := dwTrueWatchTime DIV Globals.aMinutesPerHour;
         dwWatchMinute := dwTrueWatchTime MOD Globals.aMinutesPerHour;
         {avoid division by zero}
         liTempDivisor := liTotalAllKeys;
         IF  (liTempDivisor = 0)
           THEN  liTempDivisor := 1;
         {if-then}
         System.WriteLn(fTextStream,Globals.achSPACE,
                        StrLib._fnsReplaceChars(StrLib._fnsNumToStrNoAdj(dwWatchHour,2),
                                Globals.achSPACE,Globals.achZero),
                        Globals.achColon,
                        StrLib._fnsReplaceChars(StrLib._fnsNumToStrNoAdj(dwWatchMinute,2),
                                Globals.achSPACE,Globals.achZero),
                        '    ',
                        StrLib._fnsNumToStrNoAdj(liTotalAllKeys,6),
                        '    ',
                        StrLib._fnsNumToStrNoAdj(liTotalTrueUserKeys,6),
                        '    ',
                        StrLib._fnsNumToStrNoAdj(liTotalTrueTypistKeys,6),
                        '     ',
                        StrLib._fnsNumToStrNoAdj(System.Trunc((liTotalTrueTypistKeys*aPercent100)/
                                                liTempDivisor),3),
                        Globals.achPercent);
            END;
    {if-then-else}
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(332));
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream);
    System.Close(fTextStream);
END;
{ _DispTypingStat }



PROCEDURE
          _RunTypingStat(dwRunStatTime : System.Word;
                         bHighMemToUse : System.Boolean);
{*
Description.
    Starts a typing watch monitoring.
*}
VAR
  liMaxAvailUMABlockSize :  System.Longint;
  lpMemBlock,
  lpResidentPart         :  System.Pointer;
  lpCurStatBlock         :  Globals.lpStatTimingBlock;
  dwTemp,
  dwCurSystemHour,
  dwCurSystemMinute,
  dwCurSystemSecond,
  dwCurSystemSec100,
  dwResidentSeg,
  dwMemBlockSeg,
  dwBytesInBlock,
  dwParasInMemBlock      :  System.Word;

BEGIN
   Video._OutputMessage(Messages._fnsTextMessageByIndex(512),
                        System.True);
   IF  (NOT(_bIsStatBlockPresentGlobal))
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(515),
                              Globals.errNoStatBlockGlobalSupport);
   {if-then}
   IF  (_bIsMemBlockInStatBlockPresent)
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(557),
                              Globals.errTypingStatAlreadyInProgress);
   {if-then}
     dwBytesInBlock := dwRunStatTime * System.SizeOf(Globals.recKeystrokesTiming);
     dwParasInMemBlock := (dwBytesInBlock + Globals.aBytesPerParagraph) SHR 4;
{$IFDEF   DebVer}
           IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
                THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(523)+
                                     StrLib._fnsNumToStr(dwBytesInBlock,5)+
                                     Messages._fnsTextMessageByIndex(254),
                                     aModuleCallBack);
           {if-then}
{$ENDIF} {DebVer}
  IF  (bHighMemToUse)
    THEN  BEGIN
       liMaxAvailUMABlockSize := DosCtl._fnliUMB_MaxAvail;
       IF  (System.Longint(dwBytesInBlock) > liMaxAvailUMABlockSize)
         THEN  BEGIN
           liMaxAvailUMABlockSize := 0;
           bHighMemToUse := System.False;
               END;
       {if-then}
          END
    ELSE  BEGIN
       liMaxAvailUMABlockSize := 0;
          END;
  {if-then-else}
  lpResidentPart := _fnlpGetResidentPartStart;
  dwResidentSeg := System.Seg(lpResidentPart^);
  {first try to allocate upper memory}
  IF  (bHighMemToUse)
    THEN  BEGIN
      IF  (DosCtl._fnbAllocHighMemBlock(dwParasInMemBlock,lpMemBlock))
         THEN  BEGIN
           dwMemBlockSeg := System.Seg(lpMemBlock^);
{$IFDEF   DebVer}
           IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
                THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(262),
                                                aModuleCallBack);
           {if-then}
{$ENDIF} {DebVer}
           System.FillChar(System.Mem[dwMemBlockSeg:$0],
                                      dwBytesInBlock,
                                      Globals.achNULL);
           System.MemW[(dwMemBlockSeg-1):$1] := dwResidentSeg;
           Video._OutputMessage(Messages._fnsTextMessageByIndex(513),
                                System.True);
                END
         ELSE   BEGIN
            bHighMemToUse := System.False;
{$IFDEF   DebVer}
            IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
                 THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(281),
                                                 aModuleCallBack);
            {if-then}
{$ENDIF} {DebVer}
                END;
      {if-then-else}
          END;
  {if-then}
  IF  (NOT(bHighMemToUse))
    THEN  BEGIN
       dwMemBlockSeg := Globals.dwMainCodeSeg;
       lpMemBlock := System.Ptr(dwMemBlockSeg,$0);
       Globals.gbUseAltCall := System.True; {!!We WIPE OUT our main code!!}
      {_InitCallBackIndexTable(@Globals.glpNearCallIndexTable);}
      ASM
                mov     dx, WORD PTR   ds:[Globals.glpNearCallIndexTable][2]
                mov     ax, WORD PTR   ds:[Globals.glpNearCallIndexTable][0]
                call    DWORD PTR  ds:[Globals.glpInitFarCall]
      END;
      {asm-end}
{$IFDEF   DebVer}
       IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
            THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(265),
                                            aModuleCallBack);
       {if-then}
{$ENDIF} {DebVer}
       System.FillChar(System.Mem[dwMemBlockSeg:$0],
                       dwBytesInBlock,
                       Globals.achNULL);
          END;
  {if-then}
{$IFDEF   DebVer}
           IF  ((Globals.gdwDebugLevel AND Globals.btTraceCallBack) <> 0)
               THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(522)+
                        StrLib._fnsPointerToTurboHexFmt(lpMemBlock),
                        Globals.aModuleCallBack);
           {if-then}
{$ENDIF} {DebVer}
  lpCurStatBlock := _fnlpGetStatBlock;
  Dos.GetTime(dwCurSystemHour,
              dwCurSystemMinute,
              dwCurSystemSecond,
              dwCurSystemSec100);
  {adjust timer ticks}
  dwTemp := (Globals.aSecondsPerMinute-dwCurSystemSecond);
  IF  (dwTemp = 0)
    THEN  dwTemp := 1;
  {if-then}
  WITH  (lpCurStatBlock^)  DO
  BEGIN
     bRunStatTimingMode        := System.True;
     dbStartingHour            := dwCurSystemHour;
     dbStartingMinute          := dwCurSystemMinute;
     dwTotalTimeInMinutes      := dwRunStatTime;
     dwRemTimeInMinutes        := dwRunStatTime;
     dwInitTicksPerMinute      := Globals.aTimeTicksPerMinute;
     dwCurTicksForMinute       := dwTemp * Globals.aTicksPerSecond;
     lpStatTimingMemBlock      := lpMemBlock;
     lpCurKeystrokesTimingRec  := lpMemBlock;
  END;
  {with-do}
  _SetStatBlock(lpCurStatBlock);
  IF  (NOT(bHighMemToUse))
    THEN  BEGIN
       IF  (NOT(DosCtl._fnbReleaseLowMemBlock(System.MemW[System.PrefixSeg:Globals.aDosEnvSeg])))
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(234),
                                  Globals.errBadEnvProgramMemoryUninstall);
       {if-then}
       Globals.gdwResidentPartInParas := (dwBytesInBlock +
               Globals.aPSP_Size + Globals.aBytesPerParagraph) SHR 4;
       Dos.SwapVectors;
       Video._OutputMessage(Messages._fnsTextMessageByIndex(514),
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
  {if-then}
END;
{ _RunTypingStat }

{$ENDIF} {StaVer}



BEGIN
    ASM
         mov     ah, Globals.aGetConfigInfo
         int     Globals.aServerInt
         jc     @Done
         or      ah, ah
         jnz    @Done
         test    BYTE PTR  es:[bx][$05], $10    {Feature byte 1}
         jz     @Done                    {Supported INT $15/AH=$4F in INT $09?}
         mov     Globals.gbFoundInt154F, System.True
      @Done:
    END;
    {asm-end}
END.
