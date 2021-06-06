//****************************************************************************
//                             File EXTERN.HPP
//
//                      External data declarations
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: d:/projects/hardware/atapicd/RCS/EXTERN.HPP $
//  $RCSfile: EXTERN.HPP $
//   $Author: dstef $
//     $Date: 2003/01/27 20:10:42 $
// $Revision: 1.3 $
//   $Locker: dstef $
//
//      $Log: EXTERN.HPP $
//      Revision 1.3  2003/01/27 20:10:42  dstef
//      Added support for DJGPP
//
//      Revision 1.2  2003/01/27 17:58:03  dstef
//      Fixed a bug for Watcom interrupt declaration
//
//      Revision 1.1  1999/01/02 01:10:55  dstef
//      Initial revision
//
//
//****************************************************************************



//---------------------- Data declarations -----------------------------------
extern  PCHAR  g_pchMessages[g_wLangTableIdx][g_wMsgTableIdx];
extern  char  g_chProgramPrompt[];
extern  char  g_chVersion[];
extern  char  g_chYears[];

extern    char  g_szModeSenseExt[];
extern    char  g_szIdentifyExt[];
extern    char  g_szInquiryStdExt[];
extern    char  g_szInquiryExtExt[];
extern    char  g_szReadTOCdata[];

extern WORD  g_wCurLanguage;
extern WORD  g_wCurLinesOnPageMax;
extern WORD  g_wCurLinesOnPage;

extern sWordParameter  g_LangValues;
extern sWordParameter  g_LinesValues;
extern sBoolParameter  g_RawDumpValues;
extern sBoolParameter  g_InqResetValues;
extern sBoolParameter  g_ModeSenseValues;
extern sBoolParameter  g_SoftResetValues;
extern sBoolParameter  g_ModelValues;
extern sWordParameter  g_BaseValues;
extern sWordParameter  g_CtrlValues;
extern sByteParameter  g_PrimIntValues;
extern sByteParameter  g_SecIntValues;
extern sByteParameter  g_TerIntValues;
extern sByteParameter  g_QuatIntValues;
extern sByteParameter  g_UserIntValues;
extern sByteParameter  g_PrimIrqValues;
extern sByteParameter  g_SecIrqValues;
extern sByteParameter  g_TerIrqValues;
extern sByteParameter  g_QuatIrqValues;
extern sByteParameter  g_UserIrqValues;
extern sBoolParameter  g_CurMPageValues;
extern sByteParameter  g_PrimDrv0Values;
extern sByteParameter  g_PrimDrv1Values;
extern sByteParameter  g_SecDrv0Values;
extern sByteParameter  g_SecDrv1Values;
extern sByteParameter  g_TerDrv0Values;
extern sByteParameter  g_TerDrv1Values;
extern sByteParameter  g_QuatDrv0Values;
extern sByteParameter  g_QuatDrv1Values;
extern sWordParameter  g_DelayValues;

#if defined(_AUDIO)
extern sBoolParameter  g_LockValues;
extern sBoolParameter  g_UnlockValues;
extern sBoolParameter  g_LoadValues;
extern sBoolParameter  g_EjectValues;
extern sBoolParameter  g_PlayResetValues;
extern sBoolParameter  g_MSFValues;
extern sBoolParameter  g_CDValues;
extern sBoolParameter  g_EmuLBAValues;
extern sBoolParameter  g_TOCValues;
extern sByteParameter  g_FirstTrackValues;
extern sByteParameter  g_LastTrackValues;
extern sBoolParameter  g_PlayValues;
extern sBoolParameter  g_StopValues;
extern sBoolParameter  g_PauseValues;
extern sBoolParameter  g_ResumeValues;
#endif                                      // #if defined(_AUDIO)

#if defined(_SOUNDBLASTER)
extern sWordParameter  g_SBportValues;
#endif                                      // #if defined(_SOUNDBLASTER)

#ifdef _DEBUG
extern sBoolParameter  g_DebugValues;
#endif                                      // #ifdef _DEBUG

#if defined(_ATA_CMDS)
extern sBoolParameter  g_ChkModeValues;
extern sBoolParameter  g_IdleImmValues;
extern sBoolParameter  g_StandbyImmValues;
extern sBoolParameter  g_SleepValues;
extern sBoolParameter  g_NopValues;
#endif                                      // #if defined(_ATA_CMDS)

#ifdef _DEBUG
extern  BYTE g_fDebug;
#endif                                      // #ifdef _DEBUG

extern   BYTE  g_fPrimDrive0;
extern   BYTE  g_fPrimDrive1;
extern   BYTE  g_fSecDrive0;
extern   BYTE  g_fSecDrive1;
extern   BYTE  g_fTerDrive0;
extern   BYTE  g_fTerDrive1;
extern   BYTE  g_fQuatDrive0;
extern   BYTE  g_fQuatDrive1;
extern   BYTE  g_fRawDump;
extern   BYTE  g_fUserHelp;
extern   BYTE  g_fInquiryReset;
extern   BYTE  g_fModeSenseReset;
extern   BYTE  g_fSoftReset;
extern   BYTE  g_fModelOutFmt;
extern   WORD  g_wUserBaseAddr;
extern   WORD  g_wUserCtrlAddr;
extern   BYTE  g_bPrimCtlrInt;
extern   BYTE  g_bSecCtlrInt;
extern   BYTE  g_bTerCtlrInt;
extern   BYTE  g_bQuatCtlrInt;
extern   BYTE  g_bUserCtlrInt;
extern   BYTE  g_bPrimCtlrIrq;
extern   BYTE  g_bSecCtlrIrq;
extern   BYTE  g_bTerCtlrIrq;
extern   BYTE  g_bQuatCtlrIrq;
extern   BYTE  g_bUserCtlrIrq;
extern   BYTE  g_fIntComplete;
extern   BYTE  g_bCurImrValue;
extern   BYTE  g_bCurIntNum;
extern   BYTE  g_bCurIrqNum;
extern   WORD  g_wDelay;
extern   BYTE  g_fCurMPage;
extern   BYTE  g_fOtherCmdDone;
extern   BYTE  g_fAtaCmd;
extern   BYTE  g_fAudioCmd;

#if defined(_AUDIO)
extern   BYTE  g_fLock;
extern   BYTE  g_fUnlock;
extern   BYTE  g_fLoad;
extern   BYTE  g_fEject;
extern   BYTE  g_fPlayReset;
extern   BYTE  g_fPlay;
extern   BYTE  g_fStop;
extern   BYTE  g_fPause;
extern   BYTE  g_fResume;
extern   DWORD g_dwFirstPlayTrack;
extern   DWORD g_dwLastPlayTrack;
extern   BYTE  g_bFirstTrack;
extern   BYTE  g_bLastTrack;
extern   BYTE  g_fMSF;
extern   BYTE  g_fCD;
extern   BYTE  g_fEmuLBA;
extern   BYTE  g_fTOC;
#endif                                      // #if defined(_AUDIO)

#if defined(_SOUNDBLASTER)
extern   WORD  g_wSBbasePort;
#endif                                      // #if defined(_SOUNDBLASTER)

#if defined(_ATA_CMDS)
extern   BYTE  g_fChkMode;
extern   BYTE  g_fIdleModeImm;
extern   BYTE  g_fStandbyImm;
extern   BYTE  g_fSleep;
extern   BYTE  g_fNOP;
#endif                                      // #if defined(_ATA_CMDS)


//------------------------- User commands -------------------------------------
extern    char    g_szLangSwitch[];
extern    char    g_szDumpSwitch[];
extern    char    g_szHelpSwitch[];
extern    char    g_szAltHelpSwitch[];
extern    char    g_szLinesSwitch[];
extern    char    g_szInqResetSwitch[];
extern    char    g_szModSenseResSwitch[];
extern    char    g_szPlayResetSwitch[];
extern    char    g_szSoftResetSwitch[];
extern    char    g_szModelSwitch[];
extern    char    g_szOptinalSwitch[];
extern    char    g_szPrimDrive0[];
extern    char    g_szPrimDrive1[];
extern    char    g_szSecDrive0[];
extern    char    g_szSecDrive1[];
extern    char    g_szTerDrive0[];
extern    char    g_szTerDrive1[];
extern    char    g_szQuatDrive0[];
extern    char    g_szQuatDrive1[];
extern    char    g_szUserBaseAddr[];
extern    char    g_szUserCtrlAddr[];
extern    char    g_szPrimCtrlInt[];
extern    char    g_szSecCtrlInt[];
extern    char    g_szTerCtrlInt[];
extern    char    g_szQuatCtrlInt[];
extern    char    g_szUserCtrlInt[];
extern    char    g_szPrimCtrlIrq[];
extern    char    g_szSecCtrlIrq[];
extern    char    g_szTerCtrlIrq[];
extern    char    g_szQuatCtrlIrq[];
extern    char    g_szUserCtrlIrq[];
extern    char    g_szDelaySwitch[];
extern    char    g_szCurMPageSwitch[];

#ifdef _DEBUG
extern    char    g_szDebugSwitch[];
#endif                                      // #ifdef _DEBUG

#if defined(_AUDIO)
extern    char    g_szPlaySwitch[];
extern    char    g_szStopSwitch[];
extern    char    g_szPauseSwitch[];
extern    char    g_szResumeSwitch[];
extern    char    g_szLockSwitch[];
extern    char    g_szUnlockSwitch[];
extern    char    g_szEjectSwitch[];
extern    char    g_szLoadSwitch[];
extern    char    g_szFirstTrackSwitch[];
extern    char    g_szLastTrackSwitch[];
extern    char    g_szMSFSwitch[];
extern    char    g_szCDSwitch[];
extern    char    g_szEmuLBASwitch[];
extern    char    g_szTOCSwitch[];
#endif                                      // #if defined(_AUDIO)

#if defined(_SOUNDBLASTER)
extern    char    g_szSBportSwitch[];
#endif                                      // #if defined(_SOUNDBLASTER)

#if defined(_ATA_CMDS)
extern    char    g_szChkModeSwitch[];
extern    char    g_szIdleImmSwitch[];
extern    char    g_szStandbyImmSwitch[];
extern    char    g_szSleepSwitch[];
extern    char    g_szNopSwitch[];
#endif                                      // #if defined(_ATA_CMDS)


extern sParameter  g_ParamDefinitions[];

#if defined(__BCPLUSPLUS__)
#ifdef __cplusplus
    #define __CPPARGS ...
#else
    #define __CPPARGS
#endif                                      // #ifdef __cplusplus
extern void interrupt (*g_lpPrevAtapiInt)(__CPPARGS);
                                            // Original interrupt handler entry point
#elif defined(_MSC_VER)                     // #if defined(__BCPLUSPLUS_)
extern void  (__interrupt __far *g_lpPrevAtapiInt)();
                                            // Original interrupt handler entry point
#elif defined(__WATCOMC__)                  // #if defined(__BCPLUSPLUS__)
extern void  (__interrupt __far *g_lpPrevAtapiInt)();
                                            // Original interrupt handler entry point
#elif defined(__DJGPP__)                    // #if defined(__BCPLUSPLUS__)
extern void  (*g_lpPrevAtapiInt)();
                                            // Original interrupt handler entry point
#else                                       // #if defined(__BCPLUSPLUS__)
#error Interrupt handlers no declared!
#endif                                      // #if defined(__BCPLUSPLUS_)
