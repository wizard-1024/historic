//****************************************************************************
//                              File DATA.CPP
//
//                   Public (global) data definitions
//
//    Copyright (c) 1996, 2003 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: d:/projects/hardware/atapicd/RCS/DATA.CPP $
//  $RCSfile: DATA.CPP $
//   $Author: dstef $
//     $Date: 2003/01/27 20:10:31 $
// $Revision: 1.5 $
//   $Locker: dstef $
//
//      $Log: DATA.CPP $
//      Revision 1.5  2003/01/27 20:10:31  dstef
//      Fixed for DJGPP
//
//      Revision 1.4  2003/01/27 17:59:35  dstef
//      Changed version and copyright
//
//      Revision 1.3  2003/01/27 17:57:34  dstef
//      Fixed bug for Watcom interrupt declaration
//
//      Revision 1.2  1999/12/31 19:56:06  dstef
//      Changed minor version number (20 to 21)
//
//      Revision 1.1  1999/01/02 01:10:34  dstef
//      Initial revision
//
//
//****************************************************************************



//--------------------------- Standard library modules -------------------------
#if defined(_WIN32)
#include <windows.h>                        // Windows definitions
#endif                                      // #if defined(_WIN32)
#include <stdlib.h>                         // Std system functions

#include  "compile.hpp"                     // Compilation switches
#include  "atapicd.hpp"                     // General definitions



//---------------------------Compilation Information--------------------------
static char  rcsid[] = "$Id: DATA.CPP 1.5 2003/01/27 20:10:31 dstef Exp dstef $";              // RCS marker



//---------------------------Text of messages----------------------------------
PCHAR  g_pchMessages[g_wLangTableIdx][g_wMsgTableIdx]  =
{
     {   "Copyright (c)",
         "Dmitry Stefankov",
         "ATAPI CD-ROM Drive Identify",
         "Done.",
         "module:",
         "compiled at",
#ifdef _EVAL
#ifdef _BETA
         "Evaluation beta version. Only for internal use or testing purposes."
#else
         "Evaluation version. Only for internal use. No distributed."
#endif                                      // #ifdef _BETA
#else
         "Freeware version. The world distribution no prohibited."
#endif                                      // #ifdef _EVAL
     },
     {   "Авторское право (с)",
         "Дмитрий Стефанков",
         "ATAPI/CD-ROM Диск",
         "Завершено.",
         "модуль:",
         "скомпилирован",
#ifdef _EVAL
#ifdef _BETA
             "Оценочная версия. Только для внутренного использования или тестирования."
#else
             "Оценочная версия. Только для внутренного использования или тестирования."
#endif                                      // #ifdef _BETA
#else
         "Оценочная версия. Только для внутренного использования или тестирования."
#endif                                      // #ifdef _EVAL
     }
};



//---------------------------Program definitions-------------------------------
  char  g_chProgramPrompt[]      =  { "ATAPICD: " };
  char  g_chVersion[]            =  { "2.22" };
  char  g_chYears[]              =  { "1996, 2003" };



//------------------------------ File Extensions ------------------------------
   char  g_szModeSenseExt[]      =  ".mod"; // Mode sense page
   char  g_szIdentifyExt[]       =  ".idn"; // Identify data
   char  g_szInquiryStdExt[]     =  ".std"; // Inquiry data
   char  g_szInquiryExtExt[]     =  ".ext"; // Extended inquiry data
   char  g_szReadTOCdata[]       =  ".toc"; // Read TOC data



//---------------------------Global Data---------------------------------------
WORD  g_wCurLanguage     =  g_wLangDef; // Current language index
WORD  g_wCurLinesOnPageMax    =  g_wLinesOnPageDef; // Max.available lines for page
WORD  g_wCurLinesOnPage       =  g_wLinesOnPageMin; // Current line counter on page


sWordParameter  g_LangValues    =   { g_wLangMin,   // Language bounds
                                      g_wLangDef,
                                      g_wLangMax };
sWordParameter  g_LinesValues   =   { g_wLinesOnPageMin,// Lines/page bounds
                                      g_wLinesOnPageDef,
                                      g_wLinesOnPageMax };
sBoolParameter  g_RawDumpValues =   { BOOL_FALSE,   // Dump bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_InqResetValues =  { BOOL_FALSE,   // IReset bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_ModeSenseValues = { BOOL_FALSE,   // MReset bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter g_SoftResetValues =   { BOOL_FALSE,   // SReset bounds
                                      BOOL_TRUE,
                                      BOOL_TRUE };
sBoolParameter  g_ModelValues   =   { BOOL_FALSE,   // Model bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sWordParameter  g_BaseValues    =   { 0x30,         // Base/Addr bounds
                                      0,
                                      65536-8 };
sWordParameter  g_CtrlValues   =    { 0x30,         // Base/Addr bounds
                                      0,
                                      65536-8 };
sByteParameter  g_PrimIntValues =    { 0x08,         // Prim/Int bounds
                                      0,
                                      0xFF };
sByteParameter  g_SecIntValues =    { 0x08,         // Sec/Int bounds
                                      0,
                                      0xFF };
sByteParameter  g_TerIntValues =    { 0x08,         // Ter/Int bounds
                                      0,
                                      0xFF };
sByteParameter  g_QuatIntValues=    { 0x08,         // Quat/Int bounds
                                      0,
                                      0xFF };
sByteParameter  g_UserIntValues=    { 0x08,         // User/Int bounds
                                      0,
                                      0xFF };
sByteParameter  g_PrimIrqValues=    { 0x03,         // Prim/IRQ bounds
                                      0,
                                      0x15 };
sByteParameter  g_SecIrqValues =    { 0x03,         // Sec/IRQ bounds
                                      0,
                                      0x15 };
sByteParameter  g_TerIrqValues =    { 0x03,         // Ter/IRQ bounds
                                      0,
                                      0x15 };
sByteParameter  g_QuatIrqValues=    { 0x03,         // Quat/IRQ bounds
                                      0,
                                      0x15 };
sByteParameter  g_UserIrqValues=    { 0x03,         // User/IRQ bounds
                                      0,
                                      0x15 };
sBoolParameter  g_CurMPageValues =  { BOOL_FALSE,   // CurMPage bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sByteParameter  g_PrimDrv0Values=   { BOOL_FALSE,   // Prim/Drive 0 bounds
                                      BOOL_TRUE,
                                      g_bAudioDiskPlay };
sByteParameter  g_PrimDrv1Values=   { BOOL_FALSE,   // Prim/Drive 1 bounds
                                      BOOL_TRUE,
                                      g_bAudioDiskPlay };
sByteParameter  g_SecDrv0Values =   { BOOL_FALSE,   // Sec/Drive 0 bounds
                                      BOOL_TRUE,
                                      g_bAudioDiskPlay };
sByteParameter  g_SecDrv1Values =   { BOOL_FALSE,   // Sec/Drive 1 bounds
                                      BOOL_TRUE,
                                      g_bAudioDiskPlay };
sByteParameter  g_TerDrv0Values =   { BOOL_FALSE,   // Ter/Drive 0 bounds
                                      BOOL_FALSE,
                                      g_bAudioDiskPlay };
sByteParameter  g_TerDrv1Values =   { BOOL_FALSE,   // Ter/Drive 1 bounds
                                      BOOL_FALSE,
                                      g_bAudioDiskPlay };
sByteParameter  g_QuatDrv0Values=   { BOOL_FALSE,   // Quat/Drive 0 bounds
                                      BOOL_FALSE,
                                      g_bAudioDiskPlay };
sByteParameter  g_QuatDrv1Values=   { BOOL_FALSE,   // Quat/Drive 1 bounds
                                      BOOL_FALSE,
                                      g_bAudioDiskPlay };
sWordParameter  g_DelayValues    =   { 0,           // Delay bounds
                                       0,
                                       100  };
#if defined(_AUDIO)
sBoolParameter  g_LockValues   =    { BOOL_FALSE,   // Lock bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_UnlockValues =    { BOOL_FALSE,   // Unlock bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_LoadValues   =    { BOOL_FALSE,   // Load bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_EjectValues  =    { BOOL_FALSE,   // Eject bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_PlayResetValues = { BOOL_FALSE,   // PReset bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_MSFValues    =    { BOOL_FALSE,   // MSF bounds
                                      BOOL_TRUE,
                                      BOOL_TRUE };
sBoolParameter  g_CDValues     =    { BOOL_FALSE,   // PlayCD bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_EmuLBAValues =    { BOOL_FALSE,   // EmuLBA bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_TOCValues    =    { BOOL_FALSE,   // TOC bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sByteParameter  g_FirstTrackValues = { 0x01,        // First track bounds
                                       0x01,
                                       0x63 };
sByteParameter  g_LastTrackValues =  { 0x01,        // Last track bounds
                                       0x01,
                                       0x63 };
sBoolParameter  g_PlayValues =      { BOOL_FALSE,   // Play bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_StopValues =      { BOOL_FALSE,   // Stop bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_PauseValues =     { BOOL_FALSE,   // Pause bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_ResumeValues =    { BOOL_FALSE,   // Resume bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
#endif                                      // #if defined(_AUDIO)
#if defined(_SOUNDBLASTER)
sWordParameter  g_SBportValues    =  { 0x100,       // SB/Port bounds
                                        0,
                                      0x400-0x20 };
#endif                                      // #if defined(_SOUNDBLASTER)
#ifdef _DEBUG
sBoolParameter  g_DebugValues   =   { BOOL_FALSE,   // Debug bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
#endif                                      // #ifdef _DEBUG
#if defined(_ATA_CMDS)
sBoolParameter  g_ChkModeValues  =  { BOOL_FALSE,   // Check/Power/Mode bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_IdleImmValues =  {  BOOL_FALSE,   // IdleImm bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_StandbyImmValues = {  BOOL_FALSE,   // StandbyImm bounds
                                        BOOL_FALSE,
                                        BOOL_TRUE };
sBoolParameter  g_SleepValues   =  {  BOOL_FALSE,   // Sleep bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
sBoolParameter  g_NopValues      =  { BOOL_FALSE,   // Nop bounds
                                      BOOL_FALSE,
                                      BOOL_TRUE };
#endif                                      // #if defined(_ATA_CMDS)

#ifdef _DEBUG
#ifdef _BETA
BYTE  g_fDebug        =   BOOL_FALSE;// Debug output
#else                                       // #ifdef _BETA
BYTE  g_fDebug        =   BOOL_FALSE;// Debug output
#endif                                      // #ifdef _BETA
#endif                                      // #ifdef _DEBUG

BYTE  g_fPrimDrive0   =   BOOL_TRUE;// Primary controller drive 0
BYTE  g_fPrimDrive1   =   BOOL_TRUE;// Primary controller drive 1
BYTE  g_fSecDrive0    =   BOOL_TRUE;// Secondary controller drive 0
BYTE  g_fSecDrive1    =   BOOL_TRUE;// Secondary controller drive 1
BYTE  g_fTerDrive0    =   BOOL_FALSE;// Tertiary controller drive 0
BYTE  g_fTerDrive1    =   BOOL_FALSE;// Tertiary controller drive 1
BYTE  g_fQuatDrive0   =   BOOL_FALSE;// Quaternary controller drive 0
BYTE  g_fQuatDrive1   =   BOOL_FALSE;// Quaternary controller drive 1
BYTE  g_fRawDump      =   BOOL_FALSE;// Raw binary dump to file
BYTE  g_fUserHelp     =   BOOL_FALSE;// User help was requested
BYTE  g_fInquiryReset =   BOOL_FALSE;// Do reset before data inquiry
BYTE  g_fModeSenseReset = BOOL_FALSE;// Do reset before data inquiry
BYTE  g_fSoftReset    =   BOOL_TRUE; // Soft reset for drive
BYTE  g_fModelOutFmt  =   BOOL_FALSE;// Output model string format
                                             // FALSE=Motorola (default)
                                             // TRUE=Intel (for strange drives)
  WORD  g_wUserBaseAddr =   0;        // User base I/O address
  WORD  g_wUserCtrlAddr =   0;        // User base I/O address
  BYTE  g_bPrimCtlrInt  =   0;        // Primary ctlr interrupt
  BYTE  g_bSecCtlrInt   =   0;        // Secondary ctlr interrupt
  BYTE  g_bTerCtlrInt   =   0;        // Tertiary ctlr interrupt
  BYTE  g_bQuatCtlrInt  =   0;        // Quaternary ctlr interrupt
  BYTE  g_bUserCtlrInt  =   0;        // User-defined ctlr interrupt
  BYTE  g_bPrimCtlrIrq  =   0;        // Primary ctlr IRQ
  BYTE  g_bSecCtlrIrq   =   0;        // Secondary ctlr IRQ
  BYTE  g_bTerCtlrIrq   =   0;        // Tertiary ctlr IRQ
  BYTE  g_bQuatCtlrIrq  =   0;        // Quaternary ctlr IRQ
  BYTE  g_bUserCtlrIrq  =   0;        // User-defined ctlr IRQ
  BYTE  g_fIntComplete  =  BOOL_FALSE;// Interrupt completion flag
  BYTE  g_bCurImrValue  =   0;        // Interrupt Mask Register (PIC)
  BYTE  g_bCurIntNum    =   0;        // Interrupt number in use
  BYTE  g_bCurIrqNum    =   0;        // IRQ number in use
  WORD  g_wDelay           =  0;      // Add delay for BUSY, DRQ waiting functions
  BYTE  g_fCurMPage     = BOOL_FALSE; // Current mode pages values
  BYTE  g_fOtherCmdDone = BOOL_FALSE; // Audio/ATA cmd was executed
  BYTE  g_fAtaCmd       = BOOL_FALSE; // ATA cmd was requested
  BYTE  g_fAudioCmd     = BOOL_FALSE; // Audio cmd was requested

#if defined(_AUDIO)
  BYTE  g_fLock         =  BOOL_FALSE;// Lock media in drive
  BYTE  g_fUnlock       =  BOOL_FALSE;// Unlock media in drive
  BYTE  g_fLoad         =  BOOL_FALSE;// Load media in drive
  BYTE  g_fEject        =  BOOL_FALSE;// Unload media from drive
  BYTE  g_fPlayReset    =  BOOL_FALSE;// Do reset before any play cmd
  BYTE  g_fPlay         =  BOOL_FALSE;// Start Play audio
  BYTE  g_fStop         =  BOOL_FALSE;// Stop play audio
  BYTE  g_fPause        =  BOOL_FALSE;// Pause Play audio
  BYTE  g_fResume       =  BOOL_FALSE;// Resume play audio
  DWORD g_dwFirstPlayTrack =  0;      // First track to play
  DWORD g_dwLastPlayTrack  =  0;      // Last track to play
  BYTE  g_bFirstTrack      =  1;      // User supplied track to play (start)
  BYTE  g_bLastTrack  = g_bLeadOutAreaID;// User supplied track to play (end)
  BYTE  g_fMSF          =  BOOL_TRUE; // Use MSF form for audio command
  BYTE  g_fCD           = BOOL_FALSE; // Use PLAY CD cmd to play audio
  BYTE  g_fEmuLBA       = BOOL_FALSE; // Use MSF form for ReadTOC (only!)
  BYTE  g_fTOC          = BOOL_FALSE; // Display TOC of inserted disc
#endif                                      // #if defined(_AUDIO)

#if defined(_SOUNDBLASTER)
  WORD  g_wSBbasePort   =  0;         // Sound Blaster card base port
#endif                                      // #if defined(_SOUNDBLASTER)

#if defined(_ATA_CMDS)
  BYTE  g_fChkMode      = BOOL_FALSE; // Check Power Mode
  BYTE  g_fIdleModeImm  = BOOL_FALSE; // Idle Mode Immediate
  BYTE  g_fStandbyImm   = BOOL_FALSE; // Standby Mode Immediate
  BYTE  g_fSleep        = BOOL_FALSE; // Sleep Mode
  BYTE  g_fNOP          = BOOL_FALSE; // No Operation
#endif                                      // #if defined(_ATA_CMDS)


//------------------------- User commands -------------------------------------
   char    g_szLangSwitch[]      =  { "-lang" };
   char    g_szDumpSwitch[]      =  { "-dump" };
   char    g_szHelpSwitch[]      =  { "-help" };
   char    g_szAltHelpSwitch[]   =  { "-?" };
   char    g_szLinesSwitch[]     =  { "-lines" };
   char    g_szInqResetSwitch[]  =  { "-ireset" };
   char    g_szModSenseResSwitch[] =  { "-mreset" };
   char    g_szPlayResetSwitch[] =  { "-preset" };
   char    g_szSoftResetSwitch[] =  { "-sreset" };
   char    g_szModelSwitch[]     =  { "-model" };
   char    g_szOptinalSwitch[]   =  { "[=|:]" };
   char    g_szPrimDrive0[]      =  { "-ds0"  };
   char    g_szPrimDrive1[]      =  { "-ds1"  };
   char    g_szSecDrive0[]       =  { "-ds2"  };
   char    g_szSecDrive1[]       =  { "-ds3"  };
   char    g_szTerDrive0[]       =  { "-ds4"  };
   char    g_szTerDrive1[]       =  { "-ds5"  };
   char    g_szQuatDrive0[]      =  { "-ds6"  };
   char    g_szQuatDrive1[]      =  { "-ds7"  };
   char    g_szUserBaseAddr[]    =  { "-base"  };
   char    g_szUserCtrlAddr[]    =  { "-ctrl"  };
   char    g_szPrimCtrlInt[]     =  { "-int0"  };
   char    g_szSecCtrlInt[]      =  { "-int1"  };
   char    g_szTerCtrlInt[]      =  { "-int2"  };
   char    g_szQuatCtrlInt[]     =  { "-int3"  };
   char    g_szUserCtrlInt[]     =  { "-intu"  };
   char    g_szPrimCtrlIrq[]     =  { "-irq0"  };
   char    g_szSecCtrlIrq[]      =  { "-irq1"  };
   char    g_szTerCtrlIrq[]      =  { "-irq2"  };
   char    g_szQuatCtrlIrq[]     =  { "-irq3"  };
   char    g_szUserCtrlIrq[]     =  { "-irqu"  };
   char    g_szDelaySwitch[]     =  { "-delay" };
   char    g_szCurMPageSwitch[]  =  { "-curmpg" };


#ifdef _DEBUG
   char    g_szDebugSwitch[]     =  { "-debug" };
#endif                                      // #ifdef _DEBUG

#if defined(_AUDIO)
   char    g_szPlaySwitch[]      =  { "-play" };
   char    g_szStopSwitch[]      =  { "-stop" };
   char    g_szPauseSwitch[]     =  { "-pause" };
   char    g_szResumeSwitch[]    =  { "-resume" };
   char    g_szLockSwitch[]      =  { "-lock" };
   char    g_szUnlockSwitch[]    =  { "-unlock" };
   char    g_szEjectSwitch[]     =  { "-eject" };
   char    g_szLoadSwitch[]      =  { "-load" };
   char   g_szFirstTrackSwitch[] =  { "-ftrk" };
   char   g_szLastTrackSwitch[]  =  { "-ltrk" };
   char    g_szMSFSwitch[]       =  { "-msf" };
   char    g_szCDSwitch[]        =  { "-cd" };
   char    g_szEmuLBASwitch[]    =  { "-emulba" };
   char    g_szTOCSwitch[]       =  { "-toc" };
#endif                                      // #if defined(_AUDIO)

#if defined(_SOUNDBLASTER)
   char    g_szSBportSwitch[]    =  { "-sbport" };
#endif                                      // #if defined(_SOUNDBLASTER)

#if defined(_ATA_CMDS)
   char    g_szChkModeSwitch[]   =  { "-chkmod" };
   char    g_szIdleImmSwitch[]   =  { "-idleim" };
   char    g_szStandbyImmSwitch[]=  { "-stdbim" };
   char    g_szSleepSwitch[]     =  { "-sleep" };
   char    g_szNopSwitch[]       =  { "-nop" };
#endif                                      // #if defined(_ATA_CMDS)

sParameter  g_ParamDefinitions[] =
      {
   { g_szLangSwitch,   g_chTypeIsWord,   &g_LangValues,     &g_wCurLanguage },
   { g_szDumpSwitch,   g_chTypeIsByte,   &g_RawDumpValues,  &g_fRawDump },
   {g_szInqResetSwitch,g_chTypeIsByte,   &g_InqResetValues, &g_fInquiryReset },
{g_szModSenseResSwitch,g_chTypeIsByte,   &g_ModeSenseValues,&g_fModeSenseReset },
  {g_szSoftResetSwitch,g_chTypeIsByte,   &g_SoftResetValues,&g_fSoftReset },
   { g_szModelSwitch,  g_chTypeIsByte,   &g_ModelValues,    &g_fModelOutFmt },
   { g_szDelaySwitch,  g_chTypeIsWord,   &g_DelayValues,    &g_wDelay},
  { g_szCurMPageSwitch,g_chTypeIsByte,   &g_CurMPageValues, &g_fCurMPage},
   { g_szHelpSwitch,   g_chTypeIsString, NULL,              &g_fUserHelp },
   { g_szAltHelpSwitch,g_chTypeIsString, NULL,              &g_fUserHelp },
   { g_szLinesSwitch,  g_chTypeIsWord,   &g_LinesValues,    &g_wCurLinesOnPageMax },
   { g_szPrimDrive0,   g_chTypeIsByte,   &g_PrimDrv0Values, &g_fPrimDrive0 },
   { g_szPrimDrive1,   g_chTypeIsByte,   &g_PrimDrv1Values, &g_fPrimDrive1 },
   { g_szSecDrive0,    g_chTypeIsByte,   &g_SecDrv0Values,  &g_fSecDrive0 },
   { g_szSecDrive1,    g_chTypeIsByte,   &g_SecDrv1Values,  &g_fSecDrive1 },
   { g_szTerDrive0,    g_chTypeIsByte,   &g_TerDrv0Values,  &g_fTerDrive0 },
   { g_szTerDrive1,    g_chTypeIsByte,   &g_TerDrv1Values,  &g_fTerDrive1 },
   { g_szQuatDrive0,   g_chTypeIsByte,   &g_QuatDrv0Values, &g_fQuatDrive0 },
   { g_szQuatDrive1,   g_chTypeIsByte,   &g_QuatDrv1Values, &g_fQuatDrive1 },
   { g_szUserBaseAddr, g_chTypeIsWord,   &g_BaseValues,     &g_wUserBaseAddr},
   { g_szUserCtrlAddr, g_chTypeIsWord,   &g_CtrlValues,     &g_wUserCtrlAddr},
   { g_szPrimCtrlInt,  g_chTypeIsByte,   &g_PrimIntValues,  &g_bPrimCtlrInt},
   { g_szSecCtrlInt,   g_chTypeIsByte,   &g_SecIntValues,   &g_bSecCtlrInt},
   { g_szTerCtrlInt,   g_chTypeIsByte,   &g_TerIntValues,   &g_bTerCtlrInt},
   { g_szQuatCtrlInt,  g_chTypeIsByte,   &g_QuatIntValues,  &g_bQuatCtlrInt},
   { g_szUserCtrlInt,  g_chTypeIsByte,   &g_UserIntValues,  &g_bUserCtlrInt},
   { g_szPrimCtrlIrq,  g_chTypeIsByte,   &g_PrimIrqValues,  &g_bPrimCtlrIrq},
   { g_szSecCtrlIrq,   g_chTypeIsByte,   &g_SecIrqValues,   &g_bSecCtlrIrq},
   { g_szTerCtrlIrq,   g_chTypeIsByte,   &g_TerIrqValues,   &g_bTerCtlrIrq},
   { g_szQuatCtrlIrq,  g_chTypeIsByte,   &g_QuatIrqValues,  &g_bQuatCtlrIrq},
   { g_szUserCtrlIrq,  g_chTypeIsByte,   &g_UserIrqValues,  &g_bUserCtlrIrq},
#if defined(_AUDIO)
   { g_szLockSwitch,   g_chTypeIsByte,   &g_LockValues,     &g_fLock},
   { g_szUnlockSwitch, g_chTypeIsByte,   &g_UnlockValues,   &g_fUnlock},
   { g_szLoadSwitch,   g_chTypeIsByte,   &g_LoadValues,     &g_fLoad},
   { g_szEjectSwitch,  g_chTypeIsByte,   &g_EjectValues,    &g_fEject},
  {g_szPlayResetSwitch,g_chTypeIsByte,   &g_PlayResetValues,&g_fPlayReset },
   { g_szPlaySwitch,   g_chTypeIsByte,   &g_PlayValues,     &g_fPlay},
   { g_szStopSwitch,   g_chTypeIsByte,   &g_StopValues,     &g_fStop},
   { g_szPauseSwitch,  g_chTypeIsByte,   &g_PauseValues,    &g_fPause},
   { g_szResumeSwitch, g_chTypeIsByte,   &g_ResumeValues,   &g_fResume},
   { g_szMSFSwitch,    g_chTypeIsByte,   &g_MSFValues,      &g_fMSF},
   { g_szCDSwitch,     g_chTypeIsByte,   &g_CDValues,       &g_fCD},
   { g_szEmuLBASwitch, g_chTypeIsByte,   &g_EmuLBAValues,   &g_fEmuLBA},
{ g_szFirstTrackSwitch,g_chTypeIsByte,  &g_FirstTrackValues,&g_bFirstTrack},
 { g_szLastTrackSwitch,g_chTypeIsByte,   &g_LastTrackValues,&g_bLastTrack},
   { g_szTOCSwitch,    g_chTypeIsByte,   &g_TOCValues,      &g_fTOC},
#endif                                      // #if defined(_AUDIO)
#if defined(_SOUNDBLASTER)
   { g_szSBportSwitch, g_chTypeIsWord,   &g_SBportValues,   &g_wSBbasePort},
#endif                                      // #if defined(_SOUNDBLASTER)
#if defined(_ATA_CMDS)
   { g_szChkModeSwitch,g_chTypeIsByte,   &g_ChkModeValues,  &g_fChkMode},
   { g_szIdleImmSwitch,g_chTypeIsByte,   &g_IdleImmValues,  &g_fIdleModeImm},
{ g_szStandbyImmSwitch,g_chTypeIsByte,  &g_StandbyImmValues,&g_fStandbyImm},
   { g_szSleepSwitch,  g_chTypeIsByte,   &g_SleepValues,    &g_fSleep},
   { g_szNopSwitch,    g_chTypeIsByte,   &g_NopValues,      &g_fNOP},
#endif                                      // #if defined(_ATA_CMDS)
#ifdef _DEBUG
   { g_szDebugSwitch,  g_chTypeIsByte,   &g_DebugValues,    &g_fDebug },
#endif                                      // #ifdef _DEBUG
     NULL, g_chNULL, NULL, NULL
       };

#if defined(__BCPLUSPLUS__)
#ifdef __cplusplus
    #define __CPPARGS ...
#else
    #define __CPPARGS
#endif                                      // #ifdef __cplusplus
void interrupt (*g_lpPrevAtapiInt)(__CPPARGS) = NULL;
                                            // Original interrupt handler entry point
#elif defined(_MSC_VER)                     // #if defined(__BCPLUSPLUS__)
void  (__interrupt __far *g_lpPrevAtapiInt)() = NULL;
                                            // Original interrupt handler entry point
#elif defined(__WATCOMC__)                  // #if defined(__BCPLUSPLUS__)
void  (__interrupt __far *g_lpPrevAtapiInt)() = NULL;
                                            // Original interrupt handler entry point                                            
#elif defined(__DJGPP__)                    // #if defined(__BCPLUSPLUS__)
void  (*g_lpPrevAtapiInt)() = NULL;
                                            // Original interrupt handler entry point                                            
#else                                       // #if defined(__BCPLUSPLUS__)
#error Interrupt handlers no declared!
#endif                                      // #if defined(__BCPLUSPLUS_)
