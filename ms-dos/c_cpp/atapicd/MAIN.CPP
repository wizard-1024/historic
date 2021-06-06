//****************************************************************************
//                              File MAIN.CPP
//
//              ATAPI CD-ROM Drive Identification Program
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: d:/projects/hardware/atapicd/RCS/MAIN.CPP $
//  $RCSfile: MAIN.CPP $
//   $Author: dstef $
//     $Date: 2003/01/27 20:11:41 $
// $Revision: 1.2 $
//   $Locker: dstef $
//
//      $Log: MAIN.CPP $
//      Revision 1.2  2003/01/27 20:11:41  dstef
//      Fixed for DJGPP
//
//      Revision 1.1  1999/01/02 01:20:40  dstef
//      Initial revision
//
//****************************************************************************



//--------------------------- Standard library modules -------------------------
#if defined(_WIN32)
#include <windows.h>                        // Windows definitions
#endif                                      // #if defined(_WIN32)
#include <stdlib.h>                         // Std system functions
#include <string.h>                         // String manipulation
#include <conio.h>                          // Direct console DOS functions

#include  "compile.hpp"                     // Compilation switches
#include  "atapicd.hpp"                     // General definitions
#include  "cdrom.hpp"                       // ATAPI CD-ROM definitions
#include  "inth.hpp"                        // Interrupt handlung
#include  "fproto.hpp"                      // Function prototypes
#include  "extern.hpp"                      // External data declarations
#include  "atapi.hpp"                       // ATAPI hardware class



//---------------------------Compilation Information--------------------------
static char  rcsid[] = "$Id: MAIN.CPP 1.2 2003/01/27 20:11:41 dstef Exp dstef $";              // RCS marker



//****************************************************************************
//                              --- main ---
//
// Purpose: Detect ATAPI CD-ROM drives and reports characterictics
//   Input: int  argc    -  number of arguments in command line
//          char *argv[] -  command line arguments
//  Output: int          -  exit code
// Written: by Dmitry V. Stefankov 2/12/96
//****************************************************************************
main( int argc, char *argv[] )
{

//-------------------------- Miscellaneous switches --------------------------

    BOOLEAN   fBadUserSwitch   = BOOL_FALSE;// Bad parameter found

//---------------------------- Process commad line ----------------------------

    int i = argc;                           // Number of arguments

    PCHAR  pszFileName;                     // Filename of our program
    PCHAR  pszTemp = argv[0];               // Temporary pointer

    do
    {
        pszFileName = pszTemp;
        pszTemp = strchr(pszTemp, '\\');
    }  while (pszTemp++ != NULL);

    while ( (i-- != 1) && (fBadUserSwitch == BOOL_FALSE) )
    {
        int            j = 0;               // Number of available parameters
        PCHAR    pSubStr = NULL;            // Parameter string
        PCHAR    pParamDefStr;              // Definition string
        char     UserParamType;             // Type of value
        BOOLEAN  fParameterFound = BOOL_FALSE; // Parameter presence flag

        pParamDefStr = (const PCHAR)g_ParamDefinitions[j].ParmName;
        while ( (pParamDefStr != NULL) && (fParameterFound == BOOL_FALSE) )
        {
            pSubStr = strstr(argv[i],pParamDefStr);
            if (pSubStr != NULL)
            {
                PCHAR       pchDelim;       // Pointer to actual value
                PBOOLEAN    pfData;         // Pointer to data
                BYTE        bTempValue;     // Temporary storage
                PWORD       pwData;         // Pointer to data
                WORD        wTempValue;     // Temporary storage
                sByteParameter * bTypeParam;// Limits structure
                sWordParameter * wType;     // Limits structure
                PCHAR       pTemp;          // Temporary pointer

                fParameterFound = BOOL_TRUE;
                UserParamType = g_ParamDefinitions[j].ParmType;
                pchDelim = strchr(pSubStr, g_chEqual[0]);
                if ( pchDelim == NULL )
                    pchDelim = strchr(pSubStr, g_chColon[0]);
                if ( pchDelim != NULL )
                    pchDelim++;             // Skip a delimiter

                switch ( UserParamType )
                {

                    case  g_chTypeIsString:
                        if (g_ParamDefinitions[j].pAnyValue == NULL)
                        {
                            pfData = (PBYTE)g_ParamDefinitions[j].pVarAddr;
                            if (pfData)
                                *pfData = BOOL_TRUE;
                        }
                        else
                        {
                            // nothing
                        }
                        break;

                    case  g_chTypeIsByte:
                        pfData = (PBYTE)g_ParamDefinitions[j].pVarAddr;
                        bTypeParam = (sByteParameter*)g_ParamDefinitions[j].pAnyValue;
                        if (  ( strlen(pchDelim) > 2) &&
                              ( pchDelim[0] == '0' )  &&
                              (  ( pchDelim[1] == 'x' ) ||
                                 ( pchDelim[1] == 'X' ) )  )
                        {
                          bTempValue = (BYTE)strtoul(pchDelim,&pTemp,g_wHexRadix);
                        }
                        else
                        {
                          bTempValue = atoi(pchDelim);
                        }
                        if ( (pfData) &&
                             (bTempValue <= bTypeParam->bMaxValue) &&
                             (bTempValue >= bTypeParam->bMinValue) )
                        {
                            *pfData = bTempValue;
                        }
                        break;

                    case  g_chTypeIsWord:
                        pwData = (PWORD)g_ParamDefinitions[j].pVarAddr;
                        wType = (sWordParameter*)g_ParamDefinitions[j].pAnyValue;
                        if (  ( strlen(pchDelim) > 2) &&
                              ( pchDelim[0] == '0' )  &&
                              (  ( pchDelim[1] == 'x' ) ||
                                 ( pchDelim[1] == 'X' ) )  )
                        {
                          wTempValue = (WORD)strtoul(pchDelim,&pTemp,g_wHexRadix);
                        }
                        else
                        {
                          wTempValue = atoi(pchDelim);
                        }
                        if ( (pwData) &&
                             (wTempValue <= wType->wMaxValue) &&
                             (wTempValue >= wType->wMinValue) )
                         {
                            *pwData = wTempValue;
                         }
                        break;

                            default:
                        break;
                        }
                }
            j++;
            pParamDefStr = (const PCHAR)g_ParamDefinitions[j].ParmName;
        } /*while*/
    if (fParameterFound == BOOL_FALSE)
        fBadUserSwitch = BOOL_TRUE;
    } /*while*/

//-------------------------- Standard program banner --------------------------

    OutputMessage(g_pchMessages[g_wCurLanguage][g_wMsgTablePurpose]);
    OutputMessage(g_chBlank);
    OutputMessage(g_chVersion);
    OutputMessage(g_chComma);
    OutputMessage(g_chBlank);
    OutputMessage(g_pchMessages[g_wCurLanguage][g_wMsgTableCopyright]);
    OutputMessage(g_chBlank);
    OutputMessage(g_chYears);
    OutputMessage(g_chBlank);
    OutputMessage(g_pchMessages[g_wCurLanguage][g_wMsgTableAuthor]);
    OutputMessage(g_chEOLN);

    OutputMessage("All rights reserved. Disassembly or decompilation no prohibited.");
    OutputMessage(g_chEOLN);

//------------------------- Say about wrong parameter -------------------------

    if (fBadUserSwitch)
    {
        OutputMessage("Bad user parameter found. Use for short help:  ");
        OutputMessage(pszFileName);
        OutputMessage(g_chBlank);
        OutputMessage(g_szHelpSwitch);
        OutputMessageLF(g_chPoint);
        exit(g_errBadUserParam);
    }

//------------------- Display user help and stop execution -------------------

    if (g_fUserHelp)
    {
        OutputMessage(g_pchMessages[g_wCurLanguage][g_wMsgTableEvaluationVersion]);
        OutputMessage(g_chEOLN);

        PCHAR         pDate = __DATE__;    // Date
        PCHAR         pTemp = pDate;       // Temporary pointer

        while ( (pTemp = strchr(pDate, ' ')) != NULL )
        {
            *pTemp = '-';
            if ( *(++pTemp) == ' ')
              *pTemp = '0';
        }
        OutputMessage("Release date:  ");
        OutputMessage(pDate);
        OutputMessage(";   Release time:  ");
        OutputMessage(__TIME__);
        OutputMessage(g_chEOLN);

        OutputMessage("Used compiler:  ");
#if defined(__BCPLUSPLUS__)
        OutputMessage("Borland C/C++ v");
        OutputHexByte(__BCPLUSPLUS__ >> 8,g_fNoAddHexPrefix,g_fNoAddNewLine);
        OutputMessage(g_chPoint);
        OutputHexByte(__BCPLUSPLUS__ & 0xFF,g_fNoAddHexPrefix,g_fNoAddNewLine);
#elif defined(_MSC_VER)                     // #if defined(__BCPLUSPLUS__)
        OutputMessage("Microsoft C/C++ v");
        OutputWord(_MSC_VER);
#elif defined(__WATCOMC__)                  // #if defined(__BCPLUSPLUS__)
        OutputMessage("WATCOM C/C++ v");
        OutputWord(__WATCOMC__);
#elif defined(__DJGPP__)                    // #if defined(__BCPLUSPLUS__)
        OutputMessage("DJGPP C/C++ v");
        OutputWord(__DJGPP__);
#else                                       // #if defined(__BCPLUSPLUS__)
#error Undefined compiler information. Please define this information!
#endif                                      // #if defined(__BCPLUSPLUS_)
        OutputMessage(g_chEOLN);

        OutputMessageLF("Short user help screen.");
        OutputMessageLF("Program is based on ATAPI CD-ROM stds r1.2, r2.5 and r2.6 (draft versions)");
        OutputMessageLF("Use the following switches to control a program behaviour.");

        OutputMessageLF("BASIC features:");
        OutputMessage("   ");
        OutputMessage(g_szAltHelpSwitch);
        OutputMessage(g_chComma);
        OutputMessage(" ");
        OutputMessage(g_szHelpSwitch);
        OutputMessageLF("            this help screen");
        OutputMessage("   ");
        OutputMessage(g_szLinesSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0..4096] lines on page: 0=off, 24=default, 4096=max");
        OutputMessage("   ");
        OutputMessage(g_szLangSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]      language: 0=English (default), 1=Russian");
        OutputMessage("   ");
        OutputMessage(g_szPrimDrive0);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]       check drive 0 on primary ctlr: 0=no, 1=yes (default");
        OutputMessage("   ");
        OutputMessage(g_szPrimDrive1);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]       check drive 1 on primary ctlr: 0=no, 1=yes (default)");
        OutputMessage("   ");
        OutputMessage(g_szSecDrive0);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]       check drive 0 on secondary ctlr: 0=no, 1=yes (default)");
        OutputMessage("   ");
        OutputMessage(g_szSecDrive1);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]       check drive 1 on secondary ctlr: 0=no, 1=yes (default)");
        OutputMessage("   ");
        OutputMessage(g_szTerDrive0);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]       check drive 0 on tertiary ctlr: 0=no (default), 1=yes");
        OutputMessage("   ");
        OutputMessage(g_szTerDrive1);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]       check drive 1 on tertiary ctlr: 0=no (default), 1=yes");
        OutputMessage("   ");
        OutputMessage(g_szQuatDrive0);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]       check drive 0 on quaternary ctlr: 0=no (default), 1=yes");
        OutputMessage("   ");
        OutputMessage(g_szQuatDrive1);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]       check drive 1 on quaternary ctlr: 0=no (default), 1=yes");

        OutputMessageLF("ADVANCED features:");
        OutputMessage("   ");
        OutputMessage(g_szDelaySwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0..100]  delay before drive access (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szModelSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]     model ID string : 0=Motorola  (default), 1=Intel");
        OutputMessage("   ");
        OutputMessage(g_szDumpSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]      write raw dump: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szSoftResetSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]    make software reset if necessary: 0=off, 1=on (default)");
        OutputMessage("   ");
        OutputMessage(g_szInqResetSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]    reset before inquiry: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szModSenseResSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]    reset before mode sense: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szCurMPageSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]    return current mode page values: 0=off (default), 1=on");
#ifdef _DEBUG
        OutputMessage("   ");
        OutputMessage(g_szDebugSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]     debugging output: 0=off (default), 1=on");
#endif                                      // #ifdef _DEBUG
        OutputMessage("   ");
        OutputMessage(g_szUserBaseAddr);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$30..$FFF8]   user-defined base address (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szUserCtrlAddr);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$30..$FFF8]   user-defined control address (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szPrimCtrlInt);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$08..$FF]     primary controller interrupt (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szSecCtrlInt);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$08..$FF]     secondary controller interrupt (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szTerCtrlInt);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$08..$FF]     tertiary controller interrupt (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szQuatCtrlInt);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$08..$FF]     quaternary controller interrupt (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szUserCtrlInt);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$08..$FF]     user-defined controller interrupt (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szPrimCtrlIrq);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$03..$15]     primary controller IRQ (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szSecCtrlIrq);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$03..$15]     secondary controller IRQ (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szTerCtrlIrq);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$03..$15]     tertiary controller IRQ (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szQuatCtrlIrq);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$03..$15]     quaternary controller IRQ (0=default)");
        OutputMessage("   ");
        OutputMessage(g_szUserCtrlIrq);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$03..$15]     user-defined controller IRQ (0=default)");

#if defined(_AUDIO)
        OutputMessageLF("PLAY AUDIO features:");
        OutputMessage("   ");
        OutputMessage(g_szPlaySwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]      start playing audio disc: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szStopSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]      stop playing audio disc: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szPauseSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]     pause playing audio disc: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szResumeSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]    resume playing audio disc: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szLoadSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]      load disc into drive: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szEjectSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]     eject disc from drive: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szLockSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]      lock disc in drive: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szUnlockSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]    unlock disc in drive: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szFirstTrackSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[1..99]    first track number to play: 1=default, 99=max");
        OutputMessage("   ");
        OutputMessage(g_szLastTrackSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[1..99]    last track number to play: last found=default, 99=max");
        OutputMessage("   ");
        OutputMessage(g_szMSFSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]       use MSF form for audio command: 0=off, 1=on (default)");
        OutputMessage("   ");
        OutputMessage(g_szCDSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]        use PLAY CD command: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szEmuLBASwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]    emulate READ TOC cmd (LBA form): 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szTOCSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]       display TOC of inserted disc: 0=off (default), 1=on");
#endif                                      // #if defined(_AUDIO)
#if defined(_SOUNDBLASTER)
        OutputMessage("   ");
        OutputMessage(g_szSBportSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[$100..$3E0]    Sound Blaster base port: none=0 (default)");
#endif                                      // #if defined(_SOUNDBLASTER)

#if defined(_ATA_CMDS)
        OutputMessageLF("ATA advanced features:");
        OutputMessage("   ");
        OutputMessage(g_szChkModeSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]    check power mode: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szSleepSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]     enter sleep mode: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szIdleImmSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]    enter idle mode immediate: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szStandbyImmSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]    enter standby mode immediate: 0=off (default), 1=on");
        OutputMessage("   ");
        OutputMessage(g_szNopSwitch);
        OutputMessage(g_szOptinalSwitch);
        OutputMessageLF("[0|1]       no operation (test interface): 0=off (default), 1=on");
#endif                                      // #if defined(_ATA_CMDS)

        OutputMessageLF("  ----------------------------------------------------------------------------");
        OutputMessageLF("     Sample 1:   ATAPICD  -ireset:1  -lines:1965");
        OutputMessageLF("     Sample 2:   ATAPICD  -base:0x1E8  -ctrl:0x3E8");
        OutputMessageLF("     Sample 3:   ATAPICD  -ds2:0 -base:0x170 -ctrl:0x370 -int1:0x77 -irq1:15");
#ifdef _DEBUG
        OutputMessageLF("     Sample 4:   ATAPICD  -lines:0 -debug:1 -dump:1");
#endif                                      // #ifdef _DEBUG
        OutputMessageLF("     Sample 5:   ATAPICD  -ds0:2  -load:1 -play:1 -sbport:0x220 -ftrk:3 -ltrk:8");
        OutputMessageLF("     Sample 6:   ATAPICD  -eject:1");

        OutputMessageLF("  NOTE 1: To limit search drives use value 2 for unit: -ds[X]:2 ");
        OutputMessageLF("  NOTE 2: For more help please read external documentation.");

        exit(g_errUserHelpScreen);
  }

//---------------------- Display user input parameters ------------------------

#ifdef _DEBUG
   if (g_fDebug)
   {
     OutputMessage("User param str: ");
     for (int i=1; i < argc; i++ )
     {
        OutputMessage(argv[i]);
        OutputMessage(" ");
     }
     OutputMessage(g_chEOLN);
   }
#endif                                      // #ifdef _DEBUG

//------------ Look for single drive testing only request ---------------------

  if ( (g_fPrimDrive0 == g_bAudioDiskPlay) || (g_fPrimDrive1 == g_bAudioDiskPlay) ||
       (g_fSecDrive0  == g_bAudioDiskPlay) || (g_fSecDrive1  == g_bAudioDiskPlay) ||
       (g_fTerDrive0  == g_bAudioDiskPlay) || (g_fTerDrive1  == g_bAudioDiskPlay) ||
       (g_fQuatDrive0 == g_bAudioDiskPlay) || (g_fQuatDrive1 == g_bAudioDiskPlay) )
  {
      if ( g_fPrimDrive0 == g_bAudioDiskPlay )
        g_fPrimDrive0 = BOOL_TRUE;
      else
        g_fPrimDrive0 = BOOL_FALSE;
      if ( g_fPrimDrive1 == g_bAudioDiskPlay )
        g_fPrimDrive1 = BOOL_TRUE;
      else
        g_fPrimDrive1 = BOOL_FALSE;
      if ( g_fSecDrive0  == g_bAudioDiskPlay )
        g_fSecDrive0 = BOOL_TRUE;
      else
        g_fSecDrive0 = BOOL_FALSE;
      if ( g_fSecDrive1  == g_bAudioDiskPlay )
        g_fSecDrive1 = BOOL_TRUE;
      else
        g_fSecDrive1 = BOOL_FALSE;
      if ( g_fTerDrive0  == g_bAudioDiskPlay )
        g_fTerDrive1 = BOOL_TRUE;
      else
        g_fTerDrive1 = BOOL_FALSE;
      if ( g_fTerDrive1  == g_bAudioDiskPlay )
        g_fTerDrive1 = BOOL_TRUE;
      else
        g_fTerDrive1 = BOOL_FALSE;
      if ( g_fQuatDrive0 == g_bAudioDiskPlay )
        g_fTerDrive1 = BOOL_TRUE;
      else
        g_fTerDrive1 = BOOL_FALSE;
      if ( g_fQuatDrive1 == g_bAudioDiskPlay )
        g_fTerDrive1 = BOOL_TRUE;
      else
        g_fTerDrive1 = BOOL_FALSE;
  }

//------------ Look for audio command request ---------------------------------
#if defined(_AUDIO)
    if ( (g_fPlay  == BOOL_TRUE) || (g_fStop   == BOOL_TRUE) ||
         (g_fPause == BOOL_TRUE) || (g_fResume == BOOL_TRUE) ||
         (g_fLock  == BOOL_TRUE) || (g_fUnlock == BOOL_TRUE) ||
         (g_fLoad  == BOOL_TRUE) || (g_fEject  == BOOL_TRUE) ||
         (g_fTOC   == BOOL_TRUE) )
    {
        g_fAudioCmd = BOOL_TRUE;
    }
#endif                                      // #if defined(_AUDIO)

//------------ Look for ATA command request ---------------------------------
#if defined(_ATA_CMDS)
    if ( ( g_fChkMode == BOOL_TRUE )     || ( g_fNOP == BOOL_TRUE )   ||
         ( g_fIdleModeImm == BOOL_TRUE ) || ( g_fSleep == BOOL_TRUE ) ||
         ( g_fStandbyImm == BOOL_TRUE ) )
    {
        g_fAtaCmd = BOOL_TRUE;
    }
#endif                                      // #if defined(_ATA_CMDS)

//------------ Scan ATAPI hardware on primary controller ----------------------

    if ( (g_fPrimDrive0 == BOOL_TRUE) && (g_fOtherCmdDone == BOOL_FALSE) )
    {
         AtapiHardwareAccess* ATAPI_Drv_0 =
                 new  AtapiHardwareAccess(ioPRIMARY_MAIN_CTRLR_IO_BASE,
                                          ioPRIMARY_ALT_CTRLR_IO_BASE,
                                          bPhysDrive0,
                                          g_bPrimCtlrInt,
                                          g_bPrimCtlrIrq);
         OutputMessageLF(".....Testing primary drive on primary controller.....");
         if ( ATAPI_Drv_0->mf_DetectThisDeviceATAPI(g_fSoftReset,g_fAtaCmd) )
         {
            ATAPI_Drv_0->mf_OutputDriveInformation();
         }
         delete ATAPI_Drv_0;
    }

    if ( (g_fPrimDrive1 == BOOL_TRUE) && (g_fOtherCmdDone == BOOL_FALSE) )
    {
        AtapiHardwareAccess* ATAPI_Drv_1 =
                new  AtapiHardwareAccess(ioPRIMARY_MAIN_CTRLR_IO_BASE,
                                         ioPRIMARY_ALT_CTRLR_IO_BASE,
                                         bPhysDrive1,
                                         g_bPrimCtlrInt,
                                         g_bPrimCtlrIrq);
        OutputMessageLF(".....Testing secondary drive on primary controller.....");
        if ( ATAPI_Drv_1->mf_DetectThisDeviceATAPI(g_fSoftReset,g_fAtaCmd) )
        {
            ATAPI_Drv_1->mf_OutputDriveInformation();
        }
        delete ATAPI_Drv_1;
    }

//------------ Scan ATAPI hardware on secondary controller --------------------

    if ( (g_fSecDrive0 == BOOL_TRUE) && (g_fOtherCmdDone == BOOL_FALSE) )
    {
         AtapiHardwareAccess* ATAPI_Drv_2 =
                 new  AtapiHardwareAccess(ioSECONDARY_MAIN_CTRLR_IO_BASE,
                                          ioSECONDARY_ALT_CTRLR_IO_BASE,
                                          bPhysDrive0,
                                          g_bSecCtlrInt,
                                          g_bSecCtlrIrq);
         OutputMessageLF(".....Testing primary drive on secondary controller.....");
         if ( ATAPI_Drv_2->mf_DetectThisDeviceATAPI(g_fSoftReset,g_fAtaCmd) )
         {
            ATAPI_Drv_2->mf_OutputDriveInformation();
         }
         delete ATAPI_Drv_2;
    }

    if ( (g_fSecDrive1 == BOOL_TRUE) && (g_fOtherCmdDone == BOOL_FALSE) )
    {
      AtapiHardwareAccess* ATAPI_Drv_3 =
              new  AtapiHardwareAccess(ioSECONDARY_MAIN_CTRLR_IO_BASE,
                                       ioSECONDARY_ALT_CTRLR_IO_BASE,
                                       bPhysDrive1,
                                       g_bSecCtlrInt,
                                       g_bSecCtlrIrq);
      OutputMessageLF(".....Testing secondary drive on secondary controller.....");
      if ( ATAPI_Drv_3->mf_DetectThisDeviceATAPI(g_fSoftReset,g_fAtaCmd) )
      {
        ATAPI_Drv_3->mf_OutputDriveInformation();
      }
      delete ATAPI_Drv_3;
    }

//------------ Scan ATAPI hardware on tertiary controller ---------------------

    if ( (g_fTerDrive0 == BOOL_TRUE) && (g_fOtherCmdDone == BOOL_FALSE) )
    {
      AtapiHardwareAccess* ATAPI_Drv_4 =
              new  AtapiHardwareAccess(ioTERTIARY_MAIN_CTRLR_IO_BASE,
                                       ioTERTIARY_ALT_CTRLR_IO_BASE,
                                       bPhysDrive0,
                                       g_bTerCtlrInt,
                                       g_bTerCtlrIrq);
      OutputMessageLF(".....Testing primary drive on tertiary controller.....");
      if ( ATAPI_Drv_4->mf_DetectThisDeviceATAPI(g_fSoftReset,g_fAtaCmd) )
      {
        ATAPI_Drv_4->mf_OutputDriveInformation();
      }
      delete ATAPI_Drv_4;
    }

    if ( (g_fTerDrive1 == BOOL_TRUE) && (g_fOtherCmdDone == BOOL_FALSE) )
    {
      AtapiHardwareAccess* ATAPI_Drv_5 =
              new  AtapiHardwareAccess(ioTERTIARY_MAIN_CTRLR_IO_BASE,
                                       ioTERTIARY_ALT_CTRLR_IO_BASE,
                                       bPhysDrive1,
                                       g_bTerCtlrInt,
                                       g_bTerCtlrIrq);
      OutputMessageLF(".....Testing secondary drive on tertiary controller.....");
      if ( ATAPI_Drv_5->mf_DetectThisDeviceATAPI(g_fSoftReset,g_fAtaCmd) )
      {
        ATAPI_Drv_5->mf_OutputDriveInformation();
      }
      delete ATAPI_Drv_5;
    }

//------------ Scan ATAPI hardware on quaternary controller --------------------

    if ( (g_fQuatDrive0 == BOOL_TRUE) && (g_fOtherCmdDone == BOOL_FALSE) )
    {
      AtapiHardwareAccess* ATAPI_Drv_6 =
              new  AtapiHardwareAccess(ioQUATERNARY_MAIN_CTRLR_IO_BASE,
                                       ioQUATERNARY_ALT_CTRLR_IO_BASE,
                                       bPhysDrive0,
                                       g_bQuatCtlrInt,
                                       g_bQuatCtlrIrq);
      OutputMessageLF(".....Testing primary drive on quaternary controller.....");
      if ( ATAPI_Drv_6->mf_DetectThisDeviceATAPI(g_fSoftReset,g_fAtaCmd) )
      {
        ATAPI_Drv_6->mf_OutputDriveInformation();
      }
      delete ATAPI_Drv_6;
    }

    if ( (g_fQuatDrive1 == BOOL_TRUE) && (g_fOtherCmdDone == BOOL_FALSE) )
    {
      AtapiHardwareAccess* ATAPI_Drv_7 =
              new  AtapiHardwareAccess(ioQUATERNARY_MAIN_CTRLR_IO_BASE,
                                       ioQUATERNARY_ALT_CTRLR_IO_BASE,
                                       bPhysDrive1,
                                       g_bQuatCtlrInt,
                                       g_bQuatCtlrIrq);
      OutputMessageLF(".....Testing secondary drive on quaternary controller.....");
      if ( ATAPI_Drv_7->mf_DetectThisDeviceATAPI(g_fSoftReset,g_fAtaCmd) )
      {
        ATAPI_Drv_7->mf_OutputDriveInformation();
      }
      delete ATAPI_Drv_7;
    }

//------------ Scan ATAPI hardware on user-defined controller -----------------

    if  ( ( g_wUserBaseAddr != 0 ) && ( g_wUserCtrlAddr != 0 ) )
    {
      AtapiHardwareAccess* ATAPI_Drv_UserDef =
              new  AtapiHardwareAccess(g_wUserBaseAddr,
                                       g_wUserCtrlAddr,
                                       bPhysDrive0,
                                       g_bUserCtlrInt,
                                       g_bUserCtlrIrq);
      OutputMessageLF(".....Testing primary drive on user-defined controller.....");
      if ( ATAPI_Drv_UserDef->mf_DetectThisDeviceATAPI(g_fSoftReset,g_fAtaCmd) )
      {
        ATAPI_Drv_UserDef->mf_OutputDriveInformation();
      }
      delete ATAPI_Drv_UserDef;

      ATAPI_Drv_UserDef =
              new  AtapiHardwareAccess(g_wUserBaseAddr,
                                       g_wUserCtrlAddr,
                                       bPhysDrive1,
                                       g_bUserCtlrInt,
                                       g_bUserCtlrIrq);
      OutputMessageLF(".....Testing secondary drive on user-defined controller.....");
      if ( ATAPI_Drv_UserDef->mf_DetectThisDeviceATAPI(g_fSoftReset,g_fAtaCmd) )
      {
        ATAPI_Drv_UserDef->mf_OutputDriveInformation();
      }
      delete ATAPI_Drv_UserDef;
    }

//---------------------------- Termination message ----------------------------

    OutputMessage(g_chProgramPrompt);
    OutputMessage(g_pchMessages[g_wCurLanguage][g_wMsgTableDone]);
    OutputMessage(g_chEOLN);

    return( g_errTerminateOk );
}
