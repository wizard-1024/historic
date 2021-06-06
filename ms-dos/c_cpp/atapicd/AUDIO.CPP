//****************************************************************************
//                             File AUDIO.CPP
//
//          Audio commands functions for ATAPI CD-ROM hardware
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BC31/SOURCE/ATAPICD/RCS/audio.cpp $
//  $RCSfile: audio.cpp $
//   $Author: dstef $
//     $Date: 1999/12/31 19:54:34 $
// $Revision: 1.2 $
//   $Locker: dstef $
//
//      $Log: audio.cpp $
//      Revision 1.2  1999/12/31 19:54:34  dstef
//      Switched to safe coding style (strncat,strncpy)
//
//      Revision 1.1  1999/01/02 00:24:00  dstef
//      Initial revision
//
//
//****************************************************************************



//--------------------------- Standard library modules -------------------------
#if defined(_WIN32)
#include <windows.h>                        // Windows definitions
#endif                                      // #if defined(_WIN32)
#include <string.h>                         // String manipulation
#include <conio.h>                          // Direct console DOS functions

#include  "compile.hpp"                     // Compilation switches
#include  "atapicd.hpp"                     // General definitions
#include  "cdrom.hpp"                       // ATAPI CD-ROM definitions
#include  "fproto.hpp"                      // Function prototypes
#include  "extern.hpp"                      // External data declarations
#include  "atapi.hpp"                       // ATAPI hardware class



//---------------------------Compilation Information--------------------------
static char  rcsid[] = "$Id: audio.cpp 1.2 1999/12/31 19:54:34 dstef Exp dstef $";              // RCS marker



#if defined(_AUDIO)
//****************************************************************************
//          --- AtapiHardwareAccess::mf_PlayAudio ---
//
// Purpose: Plays audio disk (partial) using PLAY AUDIO command
//   Input: DWORD  dwLBA  -  Starting address of block to play
//          WORD    wLen  -  Number of blocks to play
//  Output: BOOLEAN       -  FALSE  if no playing started
//                           TRUE   if playing started
// Written: by Dmitry V.Stefankov 08-30-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_PlayAudio(DWORD dwLBA, WORD wLen)
{
    DWORD      dwTimeout;                   // Timeout counter
    BYTE       bErrorStatus;                // Error status code
    BOOLEAN    fFuncRes = BOOL_FALSE;       // Function result
    struct  Play_Audio_Cmd_Pkt_Out   Play_Audio_Cmd_Pkt;
    struct  ATAPI_CDROM_Std_Cmd_Pkt  ATAPI_Cmd_Pkt_Std;

//---------------------- Test for ATAPI device presence ----------------------

#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputMessageLF("---Audio command (ATAPI pkt cmd): Play audio---");
        OutputMessage("--- Starting LBA: ");
        OutputDoubleWord(dwLBA);
        OutputMessage(";   Number blocks to play: ");
        OutputWordLF(wLen);
    }
#endif                                      // #ifdef _DEBUG
        if  (m_fThisIsDevATAPI == BOOL_FALSE)
        {
#ifdef _DEBUG
            if (g_fDebug)
                OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
            goto Terminate;
    }

//------------------- Select device and wait device ready ---------------------

    mf_SetDriveSelectReg();
    dwTimeout = g_dwTimeoutDef;
    if (!mf_WaitReadyDrive(dwTimeout))
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNotReadyDev();
#endif                                      // #ifdef _DEBUG
        goto Terminate;
   }

//-------------------- Build ATAPI PLAY AUDIO command packet ------------------

    memset( &Play_Audio_Cmd_Pkt, 0, sizeof(Play_Audio_Cmd_Pkt_Out) );
    Play_Audio_Cmd_Pkt.bOpCode = bPlayAudio;
    Play_Audio_Cmd_Pkt.bStart_LBA_3 = (BYTE)(dwLBA >> 24); // 0 = begin at 00m 02s 00f
    Play_Audio_Cmd_Pkt.bStart_LBA_2 = (BYTE)(dwLBA >> 16); // 0xFFFF 0xFFFF = current position
    Play_Audio_Cmd_Pkt.bStart_LBA_1 = (BYTE)(dwLBA >> 8);
    Play_Audio_Cmd_Pkt.bStart_LBA_0 = (BYTE)(dwLBA & 0xFF);
    Play_Audio_Cmd_Pkt.bTransferLenMSB = wLen >> 8;  // 65,535 blocks = ~10 min
    Play_Audio_Cmd_Pkt.bTransferLenLSB = wLen & 0xFF;// 0 = no audio operation shall occur
    memcpy( &ATAPI_Cmd_Pkt_Std, &Play_Audio_Cmd_Pkt, sizeof(Play_Audio_Cmd_Pkt_Out) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
        goto Terminate;                     // Command was ejected
    }
    WaitBiosTicksSec18(3);

//----------------------- Wait ready status from drive ------------------------

    mf_WaitCommandComplete( g_dwWaitAudioCmd, 18*g_wWaitCmdBIOSticks );

//--------------------------- Read status from drive --------------------------

    mf_OutputStatusATAPI( mf_GetStatusATAPI() );
    bErrorStatus = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( bErrorStatus );
    if ( bErrorStatus )
    {
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("!!! Play audio command failed.");
#endif                                      // #ifdef _DEBUG
    }
    else
    {
       fFuncRes = BOOL_TRUE;
#ifdef _DEBUG
       if (g_fDebug)
         OutputAudioPlayInProgress();
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Terminate function ---------------------------------

Terminate:
    return( fFuncRes );
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_PlayAudioMSF ---
//
// Purpose: Plays audio disk using PLAY AUDIO MSF command
//   Input: DWORD  dwStartMSF     -  Starting address of block to play
//          DWORD  DWORD dwEndMSF -  Ending   address of block to play
//  Output: BOOLEAN       -  FALSE  if no playing started
//                           TRUE   if playing started
// Written: by Dmitry V.Stefankov 08-30-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_PlayAudioMSF(DWORD dwStartMSF, DWORD dwEndMSF)
{
    DWORD      dwTimeout;                   // Timeout counter
    BYTE       bMinutes;                    // Field M
    BYTE       bSeconds;                    // Field S
    BYTE       bFrames;                     // Field F
    BYTE       bErrorStatus;                // Error status code
    BOOLEAN    fFuncRes = BOOL_FALSE;       // Function result
    struct  Play_Audio_MSF_Cmd_Pkt_Out  Play_Audio_MSF_Cmd_Pkt;
    struct  ATAPI_CDROM_Std_Cmd_Pkt     ATAPI_Cmd_Pkt_Std;

//---------------------- Test for ATAPI device presence ----------------------

#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputMessageLF("---Audio command (ATAPI pkt cmd): Play audio (MSF)---");
        OutputInputLBA( dwStartMSF, dwEndMSF );
    }
#endif                                      // #ifdef _DEBUG
        if  (m_fThisIsDevATAPI == BOOL_FALSE)
        {
#ifdef _DEBUG
            if (g_fDebug)
                OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
            goto Terminate;
    }

//------------------- Select device and wait device ready ---------------------

    mf_SetDriveSelectReg();
    dwTimeout = g_dwTimeoutDef;
    if (!mf_WaitReadyDrive(dwTimeout))
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNotReadyDev();
#endif                                      // #ifdef _DEBUG
        goto Terminate;
   }

//-------------------- Build ATAPI PLAY AUDIO MSF command packet --------------

    memset( &Play_Audio_MSF_Cmd_Pkt, 0, sizeof(Play_Audio_MSF_Cmd_Pkt_Out) );
    Play_Audio_MSF_Cmd_Pkt.bOpCode = bPlayAudioMSF;
    Hsg2Red(dwStartMSF, &bMinutes, &bSeconds, &bFrames);
    Play_Audio_MSF_Cmd_Pkt.bStart_M_Field = bMinutes;
    Play_Audio_MSF_Cmd_Pkt.bStart_S_Field = bSeconds;
    Play_Audio_MSF_Cmd_Pkt.bStart_F_Field = bFrames;
    Hsg2Red(dwEndMSF, &bMinutes, &bSeconds, &bFrames);
    Play_Audio_MSF_Cmd_Pkt.bEnd_M_Field  = bMinutes;
    Play_Audio_MSF_Cmd_Pkt.bEnd_S_Field  = bSeconds;
    Play_Audio_MSF_Cmd_Pkt.bEnd_F_Field  = bFrames;
    memcpy( &ATAPI_Cmd_Pkt_Std, &Play_Audio_MSF_Cmd_Pkt, sizeof(Play_Audio_MSF_Cmd_Pkt_Out) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
        goto Terminate;                     // Command was ejected
    }
    WaitBiosTicksSec18(3);

//----------------------- Wait ready status from drive ------------------------

    mf_WaitCommandComplete( g_dwWaitAudioCmd, 18*g_wWaitCmdBIOSticks );

//--------------------------- Read status from drive --------------------------

    mf_OutputStatusATAPI( mf_GetStatusATAPI() );
    bErrorStatus = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( bErrorStatus );
    if ( bErrorStatus )
    {
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("!!! Play audio MSF command failed.");
#endif                                      // #ifdef _DEBUG
    }
    else
    {
       fFuncRes = BOOL_TRUE;
#ifdef _DEBUG
       if (g_fDebug)
         OutputAudioPlayInProgress();
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Terminate function ---------------------------------

Terminate:

    return( fFuncRes );
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_PlayCD ---
//
// Purpose: Plays audio disk using PLAY CD command
//   Input: BOOLEAN fMSFform       -  Form of command (MSF or LBA)
//          DWORD   dwStartMSF     -  Starting address of block to play
//          DWORD   DWORD dwEndMSF -  Ending   address of block to play
//  Output: BOOLEAN  -  FALSE  if no playing started
//                      TRUE   if playing started
// Written: by Dmitry V.Stefankov 08-30-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_PlayCD(BOOLEAN fMSFform,
                                        DWORD dwStartLbaMsf,
                                        DWORD dwEndLbaMsf)
{
    DWORD      dwTimeout;                   // Timeout counter
    DWORD      dwTransferSectors;           // Transfer length
    BYTE       bMinutes;                    // Field M
    BYTE       bSeconds;                    // Field S
    BYTE       bFrames;                     // Field F
    BYTE       bErrorStatus;                // Error status code
    BOOLEAN    fFuncRes = BOOL_FALSE;       // Function result
    struct  Play_CD_Cmd_Pkt_Out      Play_CD_Cmd_Pkt;
    struct  ATAPI_CDROM_Std_Cmd_Pkt  ATAPI_Cmd_Pkt_Std;

//---------------------- Test for ATAPI device presence ----------------------

#ifdef _DEBUG
    if (g_fDebug)
    {
        if (fMSFform == BOOL_TRUE)
          OutputMessageLF("---Audio command (ATAPI pkt cmd): Play CD (MSF form)---");
        else
          OutputMessageLF("---Audio command (ATAPI pkt cmd): Play CD (LBA form)---");
        OutputInputLBA( dwStartLbaMsf, dwEndLbaMsf );
    }
#endif                                      // #ifdef _DEBUG
        if  (m_fThisIsDevATAPI == BOOL_FALSE)
        {
#ifdef _DEBUG
            if (g_fDebug)
                OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
            goto Terminate;
    }

//------------------- Select device and wait device ready ---------------------

    mf_SetDriveSelectReg();
    dwTimeout = g_dwTimeoutDef;
    if (!mf_WaitReadyDrive(dwTimeout))
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNotReadyDev();
#endif                                      // #ifdef _DEBUG
      goto Terminate;
   }

//-------------------- Build ATAPI PLAY CD command packet ---------------------
    memset( &Play_CD_Cmd_Pkt, 0, sizeof(Play_CD_Cmd_Pkt_Out) );
    if ( fMSFform == BOOL_TRUE )
       Play_CD_Cmd_Pkt.bOpCode =  bPlayCDMSF;
    else
       Play_CD_Cmd_Pkt.bOpCode =  bPlayCDLBA;
    Play_CD_Cmd_Pkt.SectorTypeFlags.MSF_FORM_CMD = (BYTE)fMSFform;
    Play_CD_Cmd_Pkt.SectorTypeFlags.EXP_SECTOR_TYPE = bCDDA;
    Play_CD_Cmd_Pkt.Speed_Output_Type.ANALOG_AUDIO = 1;
    Play_CD_Cmd_Pkt.Speed_Output_Type.COMPOSITE_VIDEO = 0;
    Play_CD_Cmd_Pkt.Speed_Output_Type.DIGITAL_PORT_1 = 0;
    Play_CD_Cmd_Pkt.Speed_Output_Type.DIGITAL_PORT_2 = 0;
    Play_CD_Cmd_Pkt.Speed_Output_Type.SPEED = 1;  // the best possible
    if ( fMSFform == BOOL_TRUE )
    {
        Hsg2Red(dwStartLbaMsf, &bMinutes, &bSeconds, &bFrames);
        Play_CD_Cmd_Pkt.StartMSBlo.bStart_M_Field  = bMinutes;
        Play_CD_Cmd_Pkt.StartLSBhi.bStart_S_Field  = bSeconds;
        Play_CD_Cmd_Pkt.StartLSBlo.bStart_F_Field  = bFrames;
        Hsg2Red(dwEndLbaMsf, &bMinutes, &bSeconds, &bFrames);
        Play_CD_Cmd_Pkt.TransferLenMSBhi.bEnd_M_Field  = bMinutes;
        Play_CD_Cmd_Pkt.TransferLenMSBlo.bEnd_S_Field  = bSeconds;
        Play_CD_Cmd_Pkt.TransferLenLSBhi.bEnd_F_Field  = bFrames;
    }
    else
    {
        dwTransferSectors = dwEndLbaMsf - dwStartLbaMsf;
        Play_CD_Cmd_Pkt.StartMSBhi.bStart_LBA_3 = (BYTE)(g_dwFirstPlayTrack >> 24);
        Play_CD_Cmd_Pkt.StartMSBlo.bStart_LBA_2 = (BYTE)(g_dwFirstPlayTrack >> 16);
        Play_CD_Cmd_Pkt.StartLSBhi.bStart_LBA_1 = (BYTE)(g_dwFirstPlayTrack >> 8);
        Play_CD_Cmd_Pkt.StartLSBlo.bStart_LBA_0 = (BYTE)(g_dwFirstPlayTrack);
        Play_CD_Cmd_Pkt.TransferLenMSBhi.TransferLen_3 = (BYTE)(dwTransferSectors >> 24);
        Play_CD_Cmd_Pkt.TransferLenMSBlo.TransferLen_2 = (BYTE)(dwTransferSectors >> 16);
        Play_CD_Cmd_Pkt.TransferLenLSBhi.TransferLen_1 = (BYTE)(dwTransferSectors >> 8);
        Play_CD_Cmd_Pkt.TransferLenLSBlo.TransferLen_0 = (BYTE)(dwTransferSectors & 0xFF);
    };
    memcpy( &ATAPI_Cmd_Pkt_Std, &Play_CD_Cmd_Pkt, sizeof(Play_CD_Cmd_Pkt_Out) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
        goto Terminate;                     // Command was ejected
    }
    WaitBiosTicksSec18(3);

//----------------------- Wait ready status from drive ------------------------

    mf_WaitCommandComplete( g_dwWaitAudioCmd, 18*g_wWaitCmdBIOSticks );

//--------------------------- Read status from drive --------------------------

    mf_OutputStatusATAPI( mf_GetStatusATAPI() );
    bErrorStatus = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( bErrorStatus );
    if ( bErrorStatus )
    {
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("!!! Play CD command failed.");
#endif                                      // #ifdef _DEBUG
    }
    else
    {
       fFuncRes = BOOL_TRUE;
#ifdef _DEBUG
       if (g_fDebug)
         OutputAudioPlayInProgress();
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Terminate function ---------------------------------

Terminate:
    return( fFuncRes );
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_StopPlay ---
//
// Purpose: Stops playback
//   Input: none
//  Output: BOOLEAN       -  FALSE  if no playing stopped
//                           TRUE   if playing stopped
//  Output: none
// Written: by Dmitry V.Stefankov 08-30-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_StopPlay()
{
    DWORD      dwTimeout;                   // Timeout counter
    BYTE       bErrorStatus;                // Error status code
    BOOLEAN    fFuncRes = BOOL_FALSE;       // Function result
    struct  Stop_Play_Cmd_Pkt_Out    Stop_Play_Cmd_Pkt;
    struct  ATAPI_CDROM_Std_Cmd_Pkt  ATAPI_Cmd_Pkt_Std;

//---------------------- Test for ATAPI device presence ----------------------

#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputMessageLF("---Audio command (ATAPI pkt cmd): Stop Play---");
    }
#endif                                      // #ifdef _DEBUG
        if  (m_fThisIsDevATAPI == BOOL_FALSE)
        {
#ifdef _DEBUG
            if (g_fDebug)
                OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
            goto Terminate;
    }

//------------------- Select device and wait device ready ---------------------

    mf_SetDriveSelectReg();
    dwTimeout = g_dwTimeoutDef;
    if (!mf_WaitReadyDrive(dwTimeout))
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNotReadyDev();
#endif                                      // #ifdef _DEBUG
        goto Terminate;
   }

//-------------------- Build ATAPI STOP PLAY command packet -------------------

    memset( &Stop_Play_Cmd_Pkt, 0, sizeof(Stop_Play_Cmd_Pkt_Out) );
    Stop_Play_Cmd_Pkt.bOpCode = bStopPlay;
    memcpy( &ATAPI_Cmd_Pkt_Std, &Stop_Play_Cmd_Pkt, sizeof(Stop_Play_Cmd_Pkt_Out) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
        goto Terminate;                     // Command was ejected
    }
    WaitBiosTicksSec18(3);

//----------------------- Wait ready status from drive ------------------------

    mf_WaitCommandComplete( g_dwWaitAudioCmd, 18*g_wWaitCmdBIOSticks );

//--------------------------- Read status from drive --------------------------

    mf_OutputStatusATAPI( mf_GetStatusATAPI() );
    bErrorStatus = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( bErrorStatus );
    if ( bErrorStatus )
    {
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("!!! Stop Play command failed.");
#endif                                      // #ifdef _DEBUG
    }
    else
    {
       fFuncRes = BOOL_TRUE;
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("---Audio playback stopping done---");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Terminate function ---------------------------------

Terminate:
    return( fFuncRes );
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_PauseResume ---
//
// Purpose: Resumes or pauses audio playback
//   Input: BOOLEAN fResume - Select between pause (FALSE) or resume (TRUE)
//  Output: BOOLEAN       -  FALSE  if no playing paused or resumed
//                           TRUE   if playing paused or resumed
//  Output: none
// Written: by Dmitry V.Stefankov 08-30-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_PauseResume(BOOLEAN fResume)
{
    DWORD      dwTimeout;                   // Timeout counter
    BYTE       bErrorStatus;                // Error status code
    BOOLEAN    fFuncRes = BOOL_FALSE;       // Function result
    struct  Pause_Resume_Cmd_Pkt_Out   Pause_Resume_Cmd_Pkt;
    struct  ATAPI_CDROM_Std_Cmd_Pkt    ATAPI_Cmd_Pkt_Std;

//---------------------- Test for ATAPI device presence ----------------------

#ifdef _DEBUG
    if (g_fDebug)
    {
        if (fResume == BOOL_TRUE)
          OutputMessageLF("---Audio command (ATAPI pkt cmd): Resume play---");
        else
          OutputMessageLF("---Audio command (ATAPI pkt cmd): Pause play---");
    }
#endif                                      // #ifdef _DEBUG
        if  (m_fThisIsDevATAPI == BOOL_FALSE)
        {
#ifdef _DEBUG
            if (g_fDebug)
                OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
            goto Terminate;
    }

//------------------- Select device and wait device ready ---------------------

    mf_SetDriveSelectReg();
    dwTimeout = g_dwTimeoutDef;
    if (!mf_WaitReadyDrive(dwTimeout))
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNotReadyDev();
#endif                                      // #ifdef _DEBUG
        goto Terminate;
   }

//-------------------- Build ATAPI PAUSE/RESUME command packet -------------------

    memset( &Pause_Resume_Cmd_Pkt, 0, sizeof(Pause_Resume_Cmd_Pkt_Out) );
    Pause_Resume_Cmd_Pkt.bOpCode = bPauseResume;
    Pause_Resume_Cmd_Pkt.PauseResumeFlags.RESUME = (BYTE)fResume;
    memcpy( &ATAPI_Cmd_Pkt_Std, &Pause_Resume_Cmd_Pkt, sizeof(Pause_Resume_Cmd_Pkt_Out) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
        goto Terminate;                     // Command was ejected
    }
    WaitBiosTicksSec18(3);

//----------------------- Wait ready status from drive ------------------------

    mf_WaitCommandComplete( g_dwWaitAudioCmd, 18*g_wWaitCmdBIOSticks );

//--------------------------- Read status from drive --------------------------

    mf_OutputStatusATAPI( mf_GetStatusATAPI() );
    bErrorStatus = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( bErrorStatus );
    if ( bErrorStatus )
    {
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("!!! Pause/Resume command failed.");
#endif                                      // #ifdef _DEBUG
    }
    else
    {
       fFuncRes = BOOL_TRUE;
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("---Pause/resume audio playback done---");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Terminate function ---------------------------------

Terminate:
    return( fFuncRes );
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_LockDrive ---
//
// Purpose: Locks or unlocks media in drive
//   Input: BOOLEAN fPrevent - Lock media (TRUE) or unlock media (FALSE)
//  Output: BOOLEAN       -  FALSE  if no locking/unlocking done
//                           TRUE   if locking/unlocking done
//  Output: none
// Written: by Dmitry V.Stefankov 08-30-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_LockDrive(BOOLEAN fPrevent)
{
    DWORD      dwTimeout;                   // Timeout counter
    BYTE       bErrorStatus;                // Error status code
    BOOLEAN    fFuncRes = BOOL_FALSE;       // Function result
    struct  Prevent_Allow_Cmd_Pkt_Out   Prevent_Allow_Cmd_Pkt;
    struct  ATAPI_CDROM_Std_Cmd_Pkt     ATAPI_Cmd_Pkt_Std;

//---------------------- Test for ATAPI device presence ----------------------

#ifdef _DEBUG
    if (g_fDebug)
    {
        if (fPrevent == BOOL_TRUE)
          OutputMessageLF("---ATAPI pkt cmd: Lock drive---");
        else
          OutputMessageLF("---ATAPI pkt cmd: Unlock drive---");
    }
#endif                                      // #ifdef _DEBUG
        if  (m_fThisIsDevATAPI == BOOL_FALSE)
        {
#ifdef _DEBUG
            if (g_fDebug)
                OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
            goto Terminate;
    }

//------------------- Select device and wait device ready ---------------------

    mf_SetDriveSelectReg();
    dwTimeout = g_dwTimeoutDef;
    if (!mf_WaitReadyDrive(dwTimeout))
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNotReadyDev();
#endif                                      // #ifdef _DEBUG
        goto Terminate;
   }

//---------- Build ATAPI PREVENT/ALLOW MEDIUM REMOVAL command packet ----------

    memset( &Prevent_Allow_Cmd_Pkt, 0, sizeof(Prevent_Allow_Cmd_Pkt_Out) );
    Prevent_Allow_Cmd_Pkt.bOpCode = bPreventAllowMediumRemoval;
    Prevent_Allow_Cmd_Pkt.PreventFlags.PREVENT = (BYTE)fPrevent;
    memcpy( &ATAPI_Cmd_Pkt_Std, &Prevent_Allow_Cmd_Pkt, sizeof(Prevent_Allow_Cmd_Pkt_Out) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
        goto Terminate;                     // Command was ejected
    }
    WaitBiosTicksSec18(3);

//----------------------- Wait ready status from drive ------------------------

    mf_WaitCommandComplete( g_dwWaitAudioCmd, 18*g_wWaitCmdBIOSticks );

//--------------------------- Read status from drive --------------------------

    mf_OutputStatusATAPI( mf_GetStatusATAPI() );
    bErrorStatus = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( bErrorStatus );
    if ( bErrorStatus )
    {
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("!!! Lock/Unlock command failed.");
#endif                                      // #ifdef _DEBUG
    }
    else
    {
       fFuncRes = BOOL_TRUE;
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("---Lock/unlock command completed successfully---");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Terminate function ---------------------------------

Terminate:
    return( fFuncRes );
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_AccessDisc ---
//
// Purpose: Change access the disc if possible
//   Input: BYTE bOperationCode  -  Operation code to media access
//  Output: BOOLEAN       -  FALSE  if no playing started
//                           TRUE   if playing started
//  Output: none
// Written: by Dmitry V.Stefankov 08-31-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_AccessDisc(BYTE bOperationCode)
{
    DWORD      dwTimeout;                   // Timeout counter
    BYTE       bErrorStatus;                // Error status code
    BOOLEAN    fFuncRes = BOOL_FALSE;       // Function result
    struct  Start_Stop_Unit_Cmd_Pkt_Out  Start_Stop_Unit_Cmd_Pkt;
    struct  ATAPI_CDROM_Std_Cmd_Pkt      ATAPI_Cmd_Pkt_Std;

//---------------------- Test for ATAPI device presence ----------------------

#ifdef _DEBUG
    if (g_fDebug)
    {
        if  ( bOperationCode == bStopDisc )
           OutputMessageLF("---ATAPI pkt cmd: Stop disc ---");
        if  ( bOperationCode == bStartDiscReadTOC )
           OutputMessageLF("---ATAPI pkt cmd: Sart disc and read TOC---");
        if  ( bOperationCode == bEjectDisc )
           OutputMessageLF("---ATAPI pkt cmd: Eject disc ---");
        if  ( bOperationCode == bLoadDisc )
           OutputMessageLF("---ATAPI pkt cmd: Load disc ---");
    }
#endif                                      // #ifdef _DEBUG
        if  (m_fThisIsDevATAPI == BOOL_FALSE)
        {
#ifdef _DEBUG
            if (g_fDebug)
                OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
            goto Terminate;
    }

//------------------- Select device and wait device ready ---------------------

    mf_SetDriveSelectReg();
    dwTimeout = g_dwTimeoutDef;
    if (!mf_WaitReadyDrive(dwTimeout))
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNotReadyDev();
#endif                                      // #ifdef _DEBUG
        goto Terminate;
   }

//-------------------- Build ATAPI STAR/STOP UNIT command packet -------------------

    memset( &Start_Stop_Unit_Cmd_Pkt, 0, sizeof(Start_Stop_Unit_Cmd_Pkt_Out) );
    Start_Stop_Unit_Cmd_Pkt.bOpCode = bStartStopUnit;
    Start_Stop_Unit_Cmd_Pkt.ImmedFlags.IMMED = 0;   // Status only done
    Start_Stop_Unit_Cmd_Pkt.StartStopEjectFlags.START_LOEJ = bOperationCode;
    memcpy( &ATAPI_Cmd_Pkt_Std, &Start_Stop_Unit_Cmd_Pkt, sizeof(Start_Stop_Unit_Cmd_Pkt_Out) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
        goto Terminate;                     // Command was ejected
    }

//----------------------- Wait ready status from drive ------------------------

    mf_WaitCommandComplete( g_dwWaitAudioCmd, 18*g_wWaitCmdBIOSticks );

//--------------------------- Read status from drive --------------------------

    mf_OutputStatusATAPI( mf_GetStatusATAPI() );
    bErrorStatus = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( bErrorStatus );
    if ( bErrorStatus )
    {
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("!!! Start/Stop Unit command failed.");
#endif                                      // #ifdef _DEBUG
    }
    else
    {
       fFuncRes = BOOL_TRUE;
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("---Start/Stop Unit command completed successfully---");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Terminate function ---------------------------------

Terminate:
    return( fFuncRes );
}



//****************************************************************************
//            --- AtapiHardwareAccess::mf_ReadTOC ---
//
// Purpose: Read table of contents of all disc
//   Input: BYTE     bTOCDataFormat  -  Returned TOC data format
//          BOOLEAN  fMSFform        -  Form of command (MSF or LBA)
//  Output: BOOLEAN -  FALSE  if no data were getting
//                     TRUE   if data were getting
// Written: by Dmitry V.Stefankov 08-31-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_ReadTOC(BYTE bTOCDataFormat, BOOLEAN fMSFform)
{
    pTOCTrackDescriptorBkwdMode   pTOCTrackDescriptor; // TOC Track descriptor (ptr)
    pReadTOCDataHeader    pTOCDataHeader;   // ReadTOC data header (ptr)
    PBYTE      pCurTrackDescBuf;            // Current byte in buffer (ptr)
    DWORD      dwTimeout;                   // Timeout counter
    DWORD      dwLBA;                       // Absolute CD-ROM address
    BOOLEAN    fFuncRes = BOOL_FALSE;       // Function result
    BOOLEAN    fMarkDiscEnd = BOOL_FALSE;   // Marker of disc end
    BOOLEAN    fDispTocData = BOOL_FALSE;   // Display Read TOC data
    char       chName[g_wDosFileNameSize];  // File name to dump
    WORD       wXfrCount;                   // Transferred bytes count
    WORD       wTotalBufSize;               // Size
    BYTE       bFirstTrack;                 // First track on disc
    BYTE       bLastTrack;                  // Last track on disc
    BYTE       bTrackOnDisc;                // Track number on disc
    BYTE       bTemp;                       // Temporary
    BYTE       bMinutes;                    // Field M
    BYTE       bSeconds;                    // Field S
    BYTE       bFrames;                     // Field F
    BYTE       bErrorStatus;                // Error status code
    struct   Read_TOC_Cmd_Pkt_Out     Read_TOC_Cmd_Pkt;
    struct   ATAPI_CDROM_Std_Cmd_Pkt  ATAPI_Cmd_Pkt_Std;

//---------------------- Test for display data switch -------------------------

#ifdef _DEBUG
        if ( (g_fDebug == BOOL_TRUE) || (g_fTOC == BOOL_TRUE ) )
#else
        if (g_fTOC == BOOL_TRUE )
#endif                                      // #ifdef _DEBUG
        {
           fDispTocData = BOOL_TRUE;
        }

//---------------------- Test for ATAPI device presence -----------------------
#ifdef _DEBUG
    if (g_fDebug)
    {
        if ( fMSFform )
          OutputMessageLF("---Audio command (ATAPI pkt cmd): Read TOC (MSF form)---");
        else
          OutputMessageLF("---Audio command (ATAPI pkt cmd): Read TOC (LBA form)---");
    }
#endif                                      // #ifdef _DEBUG
    if (m_fThisIsDevATAPI == BOOL_FALSE)
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
        return (fFuncRes);
    }

//------------------- Select device and wait device ready ---------------------

    mf_SetDriveSelectReg();
    mf_OutputStatusATAPI( mf_GetStatusATAPI() );

    dwTimeout = g_dwTimeoutDef;
    if (!mf_WaitReadyDrive(dwTimeout))
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNotReadyDev();
#endif                                      // #ifdef _DEBUG
        return (fFuncRes);
    }

//----------------------- Allocate dynamic data buffer -----------------------
#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Allocate dynamic data buffer for TOC of disc---");
#endif                                      // #ifdef _DEBUG
    if ( m_pbAllModePagesBuf == NULL)
    {
        m_pbAllModePagesBuf = new ModePageBuf;
        if ( m_pbAllModePagesBuf == NULL)
        {
#ifdef _DEBUG
            if (g_fDebug)
                OutputMessageLF("-> Cannot allocate dynamic data buffer for TOC of disc.");
#endif                                      // #ifdef _DEBUG
            return (fFuncRes);
        }
    }
    else
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("!!! Dynamic data buffer for TOC of disc already allocated.");
#endif                                      // #ifdef _DEBUG
    }
    memset( m_pbAllModePagesBuf, 0, sizeof(ModePageBuf) );

//------------------- Build ATAPI READ TOC command packet ---------------------

    memset( &Read_TOC_Cmd_Pkt, 0, sizeof(Read_TOC_Cmd_Pkt_Out) );
    Read_TOC_Cmd_Pkt.bOpCode = bReadTOC;
    Read_TOC_Cmd_Pkt.MSFformFlags.MSF_FORM = (BYTE)fMSFform;
    Read_TOC_Cmd_Pkt.TOCFormatFlags.TOC_FORMAT = bTOCDataFormat;
    Read_TOC_Cmd_Pkt.TrackSession.bStartTrack = 0;  // Read all tracks
    Read_TOC_Cmd_Pkt.bAllocLenMSB = sizeof(ModePageBuf) >> 8;
    Read_TOC_Cmd_Pkt.bAllocLenLSB = sizeof(ModePageBuf) & 0xFF;
    memcpy( &ATAPI_Cmd_Pkt_Std, &Read_TOC_Cmd_Pkt, sizeof(Read_TOC_Cmd_Pkt) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("!!! ATAPI packet command failed.");
#endif                                      // #ifdef _DEBUG
        return (fFuncRes);
    }
    WaitBiosTicksSec18(6);                  // Wait some time

//--------------------------- Read data from drive ---------------------------

    wXfrCount = mf_TransferDataFromDrive( (PBYTE)m_pbAllModePagesBuf,
                                          sizeof(ModePageBuf),
                                          0);
    fFuncRes = (BOOLEAN)( (wXfrCount != 0) && (wXfrCount != 0xFFFF) );

//----------------------- Wait ready status from drive ------------------------

    mf_WaitCommandComplete( g_dwWaitAudioCmd, 18*g_wWaitCmdBIOSticks );

//----------------------------- Check for errors -----------------------------

    mf_OutputStatusATAPI( mf_GetStatusATAPI() );
    bErrorStatus = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( bErrorStatus );
    if ( ( bErrorStatus != 0 ) && (fFuncRes != BOOL_TRUE ) )
    {
        fFuncRes = BOOL_FALSE;
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("!!! Read TOC command failed.");
#endif                                      // #ifdef _DEBUG
    }
    else
    {
#ifdef _DEBUG
       if (g_fDebug)
          OutputMessageLF("---Read TOC command completed sucessfully---");
#endif                                      // #ifdef _DEBUG
    }

//-------------------------- Dump TOC in LBA form -----------------------------

    if ( fFuncRes == BOOL_TRUE )
    {

        if ( fDispTocData == BOOL_TRUE )
        {
          OutputMessageLF("********** CD-ROM Disc Table of Contents (TOC) **********");
        }

        pTOCDataHeader = (pReadTOCDataHeader)m_pbAllModePagesBuf;
        pCurTrackDescBuf = (PBYTE)pTOCDataHeader;
        wTotalBufSize = (pTOCDataHeader->bTOCDataLenLSB) +
                    (pTOCDataHeader->bTOCDataLenMSB << 8);
        bFirstTrack = pTOCDataHeader->FirstTrackSession.bFirstTrackNum;
        bLastTrack = pTOCDataHeader->LastTrackSession.bLastTrackNum;
        if ( g_bFirstTrack > g_bLastTrack )
        {
            bTemp = g_bFirstTrack;          // Heavy swap!
            g_bFirstTrack = g_bLastTrack;
            g_bLastTrack = bTemp;
        }
        if ( g_bFirstTrack > bLastTrack+1 )   // Check supplied values
           g_bFirstTrack = bFirstTrack;
        if ( g_bLastTrack != g_bLeadOutAreaID )
        {
            g_bLastTrack++;
            if ( g_bLastTrack > bLastTrack )
               g_bLastTrack = g_bLeadOutAreaID;
        }
        if ( fDispTocData == BOOL_TRUE )
        {
           OutputMessage("TOC data length: ");
           OutputWord(wTotalBufSize);
           OutputMessage(" bytes;   First Track: ");
           OutputWord(bFirstTrack);
           OutputMessage(";   Last Track: ");
           OutputWordLF(bLastTrack);
        }
        pCurTrackDescBuf += sizeof(ReadTOCDataHeader);
        wTotalBufSize -= ( sizeof(BYTE)*2 );// Don't count allocation length
        while (wTotalBufSize)
        {
             pTOCTrackDescriptor = (pTOCTrackDescriptorBkwdMode)pCurTrackDescBuf;
             bTrackOnDisc = pTOCTrackDescriptor->TrackInSessionNum.bTrackNum;
             if ( fMSFform == BOOL_TRUE )
             {
                bMinutes = pTOCTrackDescriptor->StartLBA_MSB_LO.bAbsField_M;
                bSeconds = pTOCTrackDescriptor->StartLBA_LSB_HI.bAbsField_S;
                bFrames  = pTOCTrackDescriptor->StartLBA_LSB_LO.bAbsField_F;
                dwLBA = Red2Hsg( bMinutes, bSeconds, bFrames );
             }
             else
             {
                dwLBA =  ((DWORD)pTOCTrackDescriptor->StartLBA_MSB_HI.bAbsLBA_3 << 24) +
                         ((DWORD)pTOCTrackDescriptor->StartLBA_MSB_LO.bAbsLBA_2 << 16 ) +
                         ((DWORD)pTOCTrackDescriptor->StartLBA_LSB_HI.bAbsLBA_1 << 8) +
                          (DWORD)pTOCTrackDescriptor->StartLBA_LSB_LO.bAbsLBA_0;
             }
             if ( bTrackOnDisc == g_bFirstTrack )
                g_dwFirstPlayTrack = dwLBA;
             if ( bTrackOnDisc == g_bLastTrack )
                g_dwLastPlayTrack = dwLBA - g_wBackBlocks;
             if ( bTrackOnDisc == g_bLeadOutAreaID )
                fMarkDiscEnd = BOOL_TRUE;
             if ( fDispTocData == BOOL_TRUE )
             {
                OutputMessage(" ***** Track ");
                if ( bTrackOnDisc != g_bLeadOutAreaID )
                  OutputByteLF(bTrackOnDisc);
                else
                  OutputMessageLF("(start of lead-out area)");
                OutputMessage("ADR: ");
                OutputByte( pTOCTrackDescriptor->AddrControlAttr.bADR );
                OutputMessage(";   CTRL: ");
                OutputByte( pTOCTrackDescriptor->AddrControlAttr.bControl );
                if ( fMSFform == BOOL_TRUE )
                {
                    OutputMessage(";   MSF: ");
                    OutputByte(bMinutes);
                    OutputMessage(":");
                    OutputByte(bSeconds);
                    OutputMessage(":");
                    OutputByte(bFrames);
                    OutputMessage(";   LBA (calc): ");
                    OutputDoubleWordLF(dwLBA);
                }
                else
                {
                    Hsg2Red(dwLBA, &bMinutes, &bSeconds, &bFrames);
                    OutputMessage(";   LBA: ");
                    OutputDoubleWord(dwLBA);
                    OutputMessage(";   MSF (calc): ");
                    OutputByte(bMinutes);
                    OutputMessage(":");
                    OutputByte(bSeconds);
                    OutputMessage(":");
                    OutputByteLF(bFrames);
                }
             } /*if*/
             if ( dwLBA > g_dwMaxBlocksOnDisc )
             {
#ifdef _DEBUG
                if (g_fDebug)
                  OutputMessageLF("!!! Too large LBA address found.");
#endif                                      // #ifdef _DEBUG
                fFuncRes = BOOL_FALSE;
                goto Terminate;
             }
             bTemp           = sizeof(TOCTrackDescriptorBkwdMode);
             pCurTrackDescBuf += bTemp;
             wTotalBufSize   -= bTemp;
        } /*while*/
    } /*if*/

//-------------------------- Write raw data to file --------------------------

Terminate:

    if (fFuncRes && g_fRawDump)
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("---Write raw Read TOC data to file---");
#endif                                      // #ifdef _DEBUG
        strncpy(chName, m_chBaseFileName, sizeof(chName) );
        WriteBinaryFile( strncat(chName, g_szReadTOCdata, sizeof(chName)),
                        (PBYTE)m_pbAllModePagesBuf,
                         wXfrCount);
    }

    if (fMarkDiscEnd == BOOL_FALSE )
      fFuncRes = BOOL_FALSE;                // Force to re-read TOC

    return( fFuncRes );
}



//****************************************************************************
//            --- AtapiHardwareAccess::mf_ReadDiscTOC ---
//
// Purpose: Read table of contents of all disc
//   Input: BOOLEAN  fMSFform        -  Form of command (MSF or LBA)
//  Output: BOOLEAN -  FALSE  if no data were getting
//                     TRUE   if data were getting
// Written: by Dmitry V.Stefankov 10-Sep-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_ReadDiscTOC(BOOLEAN fMSFform)
{
    BOOLEAN     fFuncRes = BOOL_FALSE;      // Function result

    if ( g_fEmuLBA == BOOL_TRUE )
    {
#ifdef _DEBUG
      if  ( g_fDebug )
         OutputMessageLF(">>>> Emulate LBA form command through MSF form command.");
#endif                                      // #ifdef _DEBUG
      fFuncRes = mf_ReadTOC(bBackwardCompMode,BOOL_TRUE);
    }
    else
    {
      fFuncRes = mf_ReadTOC(bBackwardCompMode,fMSFform);
    }
    return( fFuncRes );
}



//****************************************************************************
//            --- AtapiHardwareAccess::mf_PlayAudioDisk ---
//
// Purpose: Read table of contents of all disc
//   Input: BOOLEAN    fMSFform       -  MSF/LBA form of command
//          BOOLEAN    fPlayCDcmd     -  use PLAY CD command to playback
//          DWORD      dwStartLbaMSF  -  starting LBA/LBA value
//          DWORD      dwEndLbaMsf    -  ending   LBA/MSF value
//  Output: BOOLEAN       -  FALSE  if no playing started
//                           TRUE   if playing started
//  Output: none
// Written: by Dmitry V.Stefankov 04-Sep-97
//****************************************************************************
BOOLEAN AtapiHardwareAccess::mf_PlayAudioDisk(BOOLEAN fMSFform,
                                              BOOLEAN fPlayCDcmd)
{
    DWORD       dwTransferBlocks;           // # of blocks to transfer
    DWORD       dwStartLbaMSF;              // Starting sector
    DWORD       dwEndLbaMsf;                // Ending sector
    BOOLEAN     fFuncRes = BOOL_FALSE;      // Function result
    BOOLEAN     fFuncResPlay = BOOL_FALSE;  // Function result

    for (BYTE i=0; i < g_bRetryNumber; i++)
    {
      fFuncRes = mf_ReadDiscTOC(fMSFform);
      if ( fFuncRes == BOOL_TRUE )
      {
         dwStartLbaMSF = g_dwFirstPlayTrack;
         dwEndLbaMsf   = g_dwLastPlayTrack;
         if (g_fMSF == BOOL_TRUE)
         {
           if  ( fPlayCDcmd == BOOL_TRUE )
              fFuncResPlay = mf_PlayCD(BOOL_TRUE, dwStartLbaMSF, dwEndLbaMsf);
           else
              fFuncResPlay = mf_PlayAudioMSF(dwStartLbaMSF, dwEndLbaMsf);
         }
         else
         {
           if  ( fPlayCDcmd == BOOL_TRUE )
              fFuncResPlay = mf_PlayCD(BOOL_FALSE, dwStartLbaMSF, dwEndLbaMsf);
           else
           {
              dwTransferBlocks = dwEndLbaMsf - dwStartLbaMSF;
              if (dwTransferBlocks > 0xFFFF)   // Check for overflow
                dwTransferBlocks = 0xFFFF;
              fFuncResPlay = mf_PlayAudio( dwStartLbaMSF,
                                           (WORD)dwTransferBlocks );
            }
         }
         if ( fFuncResPlay == BOOL_FALSE )
         {
           OutputMessageLF(".....ERROR! Cannot play disc. Check disc or drive.");
         }
         else
         {
#if defined(_SOUNDBLASTER)
            if  ( DetectSoundBlaster(g_wSBbasePort) )
            {
               InitSoundBlaster( g_wSBbasePort );
            }
#endif                                      // #if defined(_SOUNDBLASTER)
         }
         goto Terminate;
      }
      else
      {
        // Errors processing
      }
      WaitBiosTicksSec18(3);                // Wait some time
    } /*for*/

//------------------------------ Termination ----------------------------------

Terminate:
   if  ( fFuncRes == BOOL_FALSE )
   {
      OutputMessageLF(".....ERROR! Cannot read TOC of disc.");
   }
   return( fFuncRes && fFuncResPlay );
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_ExecAudioDriveCmd ---
//
// Purpose: Executes a drive command for audio disk playback
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 04-Sep-97
//****************************************************************************
void  AtapiHardwareAccess::mf_ExecAudioDriveCmd()
{
    BOOLEAN     fFuncResult;                // Function result

    for ( BYTE i=0; i < g_bRetryTestUnit; i++ )
       fFuncResult = mf_TestUnitReady();
    if (g_fTOC == BOOL_TRUE)
    {
       OutputMessageLF(".....Display TOC of disc.");
       fFuncResult = mf_ReadDiscTOC(g_fMSF);// Display Table Of Contents
    }
    if (g_fLoad == BOOL_TRUE)
    {
       OutputMessageLF(".....Load disc.");
       fFuncResult = mf_AccessDisc(bLoadDisc);// Loads disc (closes tray)
    }
    if (g_fPlay == BOOL_TRUE)
    {
       if (g_fPlayReset)
       {
            mf_SoftResetATAPI();            // Use only for strange ATAPI controllers
            WaitBiosTicksSec18(6*18);
            mf_TestUnitReady();
            WaitBiosTicksSec18(3);
       }
       OutputMessageLF(".....Play audio disc.");
       fFuncResult = mf_PlayAudioDisk( g_fMSF, g_fCD );// Starts audio disc playback
    }
    if (g_fResume == BOOL_TRUE)
    {
       OutputMessageLF(".....Resume audio disc playback.");
       fFuncResult = mf_PauseResume(BOOL_TRUE);// Resumes playback audio disc
    }
    if (g_fStop == BOOL_TRUE)
    {
       OutputMessageLF(".....Stop audio disc playback.");
       fFuncResult = mf_StopPlay();         // Stops playback audio disc
    }
    if (g_fPause == BOOL_TRUE)
    {
       OutputMessageLF(".....Pause audio disc playback.");
       fFuncResult = mf_PauseResume(BOOL_FALSE);// Pauses playback audio disc
    }
    if (g_fLock == BOOL_TRUE)
    {
       OutputMessageLF(".....Lock drive.");
       fFuncResult = mf_LockDrive(BOOL_TRUE);// Locks media in drive
    }
    if (g_fUnlock == BOOL_TRUE)
    {
       OutputMessageLF(".....Unlock drive.");
       fFuncResult = mf_LockDrive(BOOL_FALSE);// Unlocks media in drive
    }
    if (g_fEject == BOOL_TRUE)
    {
       OutputMessageLF(".....Eject disc from drive.");
       fFuncResult = mf_AccessDisc(bEjectDisc);// Ejects disc from drive
    }
    if ( fFuncResult == BOOL_FALSE )
      OutputMessageLF(".....WARNING!! Requested operation return bad status.");
    g_fOtherCmdDone = BOOL_TRUE;            // Yes, done
#if defined(_SOUNDBLASTER)
    if ( (g_fStop == BOOL_TRUE) || (g_fEject == BOOL_TRUE) )
    {
        if  ( DetectSoundBlaster(g_wSBbasePort) )
        {
            DeinitSoundBlaster( g_wSBbasePort );  // Just for testing
        }
    }
#endif                                      // #if defined(_SOUNDBLASTER)
}
#endif                                      // #if defined(_AUDIO)

