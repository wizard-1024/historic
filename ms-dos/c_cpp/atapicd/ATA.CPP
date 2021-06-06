//****************************************************************************
//                              File ATA.CPP
//
//        ATA commands functions for ATAPI CD-ROM drive hardware
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BC31/SOURCE/ATAPICD/RCS/ata.cpp $
//  $RCSfile: ata.cpp $
//   $Author: dstef $
//     $Date: 1999/01/02 00:13:30 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: ata.cpp $
//      Revision 1.1  1999/01/02 00:13:30  dstef
//      Initial revision
//
//
//****************************************************************************



//--------------------------- Standard library modules -------------------------
#if defined(_WIN32)
#include <windows.h>                        // Windows definitions
#endif                                      // #if defined(_WIN32)
#include <stdlib.h>                         // Std system functions
#include <conio.h>                          // Direct console DOS functions

#include  "compile.hpp"                     // Compilation switches
#include  "atapicd.hpp"                     // General definitions
#include  "cdrom.hpp"                       // ATAPI CD-ROM definitions
#include  "ata.hpp"                         // ATA definitions
#include  "inth.hpp"                        // Interrupt handlung
#include  "fproto.hpp"                      // Function prototypes
#include  "extern.hpp"                      // External data declarations
#include  "atapi.hpp"                       // ATAPI hardware class



//---------------------------Compilation Information--------------------------
static char  rcsid[] = "$Id: ata.cpp 1.1 1999/01/02 00:13:30 dstef Exp dstef $";              // RCS marker



#if defined(_ATA_CMDS)
//****************************************************************************
//              --- AtapiHardwareAccess::mf_ChkPwrMode ---
//
// Purpose: Checks the power mode
//   Input: none
//  Output: BOOLEAN -  FALSE if command successful
//                     TRUE  if command unsuccessful
// Written: by Dmitry V.Stefankov 12-Sep-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_ChkPwrMode()
{
    DWORD    dwTimeout = g_dwTimeoutDef;    // Timeout counter
    DWORD    dwWaitFuncRes;                 // Function result
    BOOLEAN  fExitCode = BOOL_FALSE;        // Exit code
    BYTE     bStatusCode;                   // Current Power Mode State
    tagATAPI_Stat_Reg_RD    StatusReg;      // ATAPI status byte
    tagATAPI_Err_Reg_RD     ErrorReg;       // ATAPI error byte
    PBYTE    pbError    = (PBYTE)&ErrorReg; // Pointer to error byte
    PBYTE    pbStatus   = (PBYTE)&StatusReg;// Pointer to status byte

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---ATA cmd: Check Power Mode---");
#endif                                      // #ifdef _DEBUG

//------------------------------- Select device -------------------------------

    mf_SetDriveSelectReg();
    mf_OutputStatusATAPI( mf_GetStatusATAPI() );

//----------------------- Check for interrupt logic --------------------------

#if defined(_WIN32)
#pragma message ("(17) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_LinkInterruptHandler();
#endif                                      // #if defined(_WIN32)

//------------------------ Send ATA command to device ------------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF(">>>Send Check Power Mode command<<<");
#endif                                      // #ifdef _DEBUG
    mf_WriteByteReg(m_ATAPI_Cmd_Blk_Wr.bATAPI_Unused, 0xAA); // SC not used for ATAPI cmd
    mf_SendCmdByteATA(bATA_cmd_Chk_Pwr_Mode);

//------------------------- Wait while drive is busy -------------------------

    WaitBiosTicksSec18(3);                  // Some delay before go further

//----------------------- Wait command termination from drive -----------------

    if (m_bSoftIntNum)
    {
        dwWaitFuncRes = mf_WaitDriveInt(3);   // ~3.5 seconds
    }
    else
    {
        dwWaitFuncRes = mf_WaitBusyDrive(dwTimeout);
    }

    if ( !dwWaitFuncRes )
    {
        mf_OutputErrorATAPI( mf_GetErrorATAPI() );
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Check Power Mode command failed.");
#endif                                      // #ifdef _DEBUG
        goto Terminate;
    }

//---------------------------- Look return code -------------------------------

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---Check returned status and error codes---");
#endif                                      // #ifdef _DEBUG
    *pbStatus = mf_GetStatusATAPI();
    mf_OutputStatusATAPI( *pbStatus );
    *pbError = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( *pbError );
    if ( *pbError == 0 )
    {
#ifdef _DEBUG
        if (g_fDebug)
           OutputMessageLF("---Check Power Mode command completed successfully---");
#endif                                      // #ifdef _DEBUG
        bStatusCode = mf_ReadByteReg(m_ATAPI_Cmd_Blk_Rd.bATAPI_Intr_Reason);
#ifdef _DEBUG
        if (g_fDebug)
        {
            OutputMessage("Sector Count register=");
            OutputHexByte(bStatusCode, g_fAddHexPrefix, g_fAddNewLine);
        }
#endif                                      // #ifdef _DEBUG
        OutputMessage(".....Current Power Mode: ");
        switch  (bStatusCode)
        {
            case  0x00:
                        OutputMessageLF("standby");
                        break;
            case  0xFF:
                        OutputMessageLF("idle");
                        break;
            default:
                        OutputMessageLF("undefined");
                        break;
        }
        fExitCode = BOOL_TRUE;              // Good termination
    }
    else
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Check Power Mode command returned bad status.");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Check for filtered interrupts -----------------------
Terminate:
#if defined(_WIN32)
#pragma message ("(18) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_UnLinkInterruptHandler();
#endif                                      // #if defined(_WIN32)
    return (fExitCode);
}



//****************************************************************************
//              --- AtapiHardwareAccess::mf_EnterIdleModeImm ---
//
// Purpose: Causes a transition to Idle Mode Immediate
//   Input: none
//  Output: BOOLEAN -  FALSE if command successful
//                     TRUE  if command unsuccessful
// Written: by Dmitry V.Stefankov 13-Sep-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_EnterIdleModeImm()
{
    DWORD    dwTimeout = g_dwTimeoutDef;    // Timeout counter
    DWORD    dwWaitFuncRes;                 // Function result
    BOOLEAN  fExitCode = BOOL_FALSE;        // Exit code
    tagATAPI_Stat_Reg_RD    StatusReg;      // ATAPI status byte
    tagATAPI_Err_Reg_RD     ErrorReg;       // ATAPI error byte
    PBYTE    pbError    = (PBYTE)&ErrorReg; // Pointer to error byte
    PBYTE    pbStatus   = (PBYTE)&StatusReg;// Pointer to status byte

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---ATA cmd: Idle Immediate---");
#endif                                      // #ifdef _DEBUG

//------------------------------- Select device -------------------------------

    mf_SetDriveSelectReg();
    mf_OutputStatusATAPI( mf_GetStatusATAPI() );

//----------------------- Check for interrupt logic --------------------------

#if defined(_WIN32)
#pragma message ("(19) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_LinkInterruptHandler();
#endif                                      // #if defined(_WIN32)

//------------------------ Send ATA command to device ------------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF(">>>Send Idle Mode Immediate command<<<");
#endif                                      // #ifdef _DEBUG
    mf_SendCmdByteATA(bATA_cmd_Idle_Imm);

//------------------------- Wait while drive is busy -------------------------

    WaitBiosTicksSec18(6);                  // Some delay before go further

//----------------------- Wait command termination from drive -----------------

    if (m_bSoftIntNum)
    {
        dwWaitFuncRes = mf_WaitDriveInt(3);   // ~3.5 seconds
    }
    else
    {
        dwWaitFuncRes = mf_WaitBusyDrive(dwTimeout);
    }

    if ( !dwWaitFuncRes )
    {
        mf_OutputErrorATAPI( mf_GetErrorATAPI() );
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Idle Mode Immediate command failed.");
#endif                                      // #ifdef _DEBUG
        goto Terminate;
    }

//---------------------------- Look return code -------------------------------

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---Check returned status and error codes---");
#endif                                      // #ifdef _DEBUG
    *pbStatus = mf_GetStatusATAPI();
    mf_OutputStatusATAPI( *pbStatus );
    *pbError = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( *pbError );
    if ( *pbError == 0 )
    {
#ifdef _DEBUG
        if (g_fDebug)
           OutputMessageLF("---Idle Mode Immediate command completed successfully---");
#endif                                      // #ifdef _DEBUG
        fExitCode = BOOL_TRUE;              // Good termination
    }
    else
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Idle Mode Immediate command returned bad status.");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Check for filtered interrupts -----------------------
Terminate:
#if defined(_WIN32)
#pragma message ("(20) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_UnLinkInterruptHandler();
#endif                                      // #if defined(_WIN32)
    return (fExitCode);
}



//****************************************************************************
//              --- AtapiHardwareAccess::mf_EnterStandbyModeImm ---
//
// Purpose: Causes a transition to Standby Mode Immediate
//   Input: none
//  Output: BOOLEAN -  FALSE if command successful
//                     TRUE  if command unsuccessful
// Written: by Dmitry V.Stefankov 14-Sep-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_EnterStandbyModeImm()
{
    DWORD    dwTimeout = g_dwTimeoutDef;    // Timeout counter
    DWORD    dwWaitFuncRes;                 // Function result
    BOOLEAN  fExitCode = BOOL_FALSE;        // Exit code
    tagATAPI_Stat_Reg_RD    StatusReg;      // ATAPI status byte
    tagATAPI_Err_Reg_RD     ErrorReg;       // ATAPI error byte
    PBYTE    pbError    = (PBYTE)&ErrorReg; // Pointer to error byte
    PBYTE    pbStatus   = (PBYTE)&StatusReg;// Pointer to status byte

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---ATA cmd: Standby Mode Immediate---");
#endif                                      // #ifdef _DEBUG

//------------------------------- Select device -------------------------------

    mf_SetDriveSelectReg();
    mf_OutputStatusATAPI( mf_GetStatusATAPI() );

//----------------------- Check for interrupt logic --------------------------

#if defined(_WIN32)
#pragma message ("(21) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_LinkInterruptHandler();
#endif                                      // #if defined(_WIN32)

//------------------------ Send ATA command to device ------------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF(">>>Send Standby Immediate command<<<");
#endif                                      // #ifdef _DEBUG
    mf_SendCmdByteATA(bATA_cmd_Standby_Imm);

//------------------------- Wait while drive is busy -------------------------

    WaitBiosTicksSec18(6);                  // Some delay before go further

//----------------------- Wait command termination from drive -----------------

    if (m_bSoftIntNum)
    {
        dwWaitFuncRes = mf_WaitDriveInt(3);   // ~3.5 seconds
    }
    else
    {
        dwWaitFuncRes = mf_WaitBusyDrive(dwTimeout);
    }

    if ( !dwWaitFuncRes )
    {
        mf_OutputErrorATAPI( mf_GetErrorATAPI() );
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Standby Mode Immediate command failed.");
#endif                                      // #ifdef _DEBUG
        goto Terminate;
    }

//---------------------------- Look return code -------------------------------

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---Check returned status and error codes---");
#endif                                      // #ifdef _DEBUG
    *pbStatus = mf_GetStatusATAPI();
    mf_OutputStatusATAPI( *pbStatus );
    *pbError = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( *pbError );
    if ( *pbError == 0 )
    {
#ifdef _DEBUG
        if (g_fDebug)
           OutputMessageLF("---Standby Mode Immediate command completed successfully---");
#endif                                      // #ifdef _DEBUG
        fExitCode = BOOL_TRUE;              // Good termination
    }
    else
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Standby Mode Immediate command returned bad status.");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Check for filtered interrupts -----------------------
Terminate:
#if defined(_WIN32)
#pragma message ("(22) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_UnLinkInterruptHandler();
#endif                                      // #if defined(_WIN32)
    return (fExitCode);
}



//****************************************************************************
//              --- AtapiHardwareAccess::mf_EnterSleepMode ---
//
// Purpose: Causes a transition to Sleep Mode
//   Input: none
//  Output: BOOLEAN -  FALSE if command successful
//                     TRUE  if command unsuccessful
// Written: by Dmitry V.Stefankov 14-Sep-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_EnterSleepMode()
{
    DWORD    dwTimeout = g_dwTimeoutDef;    // Timeout counter
    DWORD    dwWaitFuncRes;                 // Function result
    BOOLEAN  fExitCode = BOOL_FALSE;        // Exit code
    tagATAPI_Stat_Reg_RD    StatusReg;      // ATAPI status byte
    tagATAPI_Err_Reg_RD     ErrorReg;       // ATAPI error byte
    PBYTE    pbError    = (PBYTE)&ErrorReg; // Pointer to error byte
    PBYTE    pbStatus   = (PBYTE)&StatusReg;// Pointer to status byte

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---ATA cmd: Sleep Mode---");
#endif                                      // #ifdef _DEBUG

//------------------------------- Select device -------------------------------

    mf_SetDriveSelectReg();
    mf_OutputStatusATAPI( mf_GetStatusATAPI() );

//----------------------- Check for interrupt logic --------------------------

#if defined(_WIN32)
#pragma message ("(23) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_LinkInterruptHandler();
#endif                                      // #if defined(_WIN32)

//------------------------ Send ATA command to device ------------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF(">>>Send Sleep Mode command<<<");
#endif                                      // #ifdef _DEBUG
    mf_SendCmdByteATA(bATA_cmd_Sleep);

//------------------------- Wait while drive is busy -------------------------

    WaitBiosTicksSec18(3);                  // Some delay before go further

//----------------------- Wait command termination from drive -----------------

    if (m_bSoftIntNum)
    {
        dwWaitFuncRes = mf_WaitDriveInt(3);   // ~3.5 seconds
    }
    else
    {
        dwWaitFuncRes = mf_WaitBusyDrive(dwTimeout);
    }

    if ( !dwWaitFuncRes )
    {
        mf_OutputErrorATAPI( mf_GetErrorATAPI() );
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Sleep Mode command failed.");
#endif                                      // #ifdef _DEBUG
        goto Terminate;
    }

//---------------------------- Look return code -------------------------------

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---Check returned status and error codes---");
#endif                                      // #ifdef _DEBUG
    *pbStatus = mf_GetStatusATAPI();
    mf_OutputStatusATAPI( *pbStatus );
    *pbError = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( *pbError );
    if ( *pbError == 0 )
    {
#ifdef _DEBUG
        if (g_fDebug)
           OutputMessageLF("---Sleep Mode command completed successfully---");
#endif                                      // #ifdef _DEBUG
        fExitCode = BOOL_TRUE;              // Good termination
    }
    else
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Sleep Mode command returned bad status.");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Check for filtered interrupts -----------------------
Terminate:
#if defined(_WIN32)
#pragma message ("(24) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_UnLinkInterruptHandler();
#endif                                      // #if defined(_WIN32)
    return (fExitCode);
}



//****************************************************************************
//              --- AtapiHardwareAccess::mf_SetFeatures ---
//
// Purpose: Sets some interface timing and protocol modes
//   Input: BOOLEAN  fSetFeature  -  Set or Clear feature
//          BYTE     bFeature     -  Feature Number
//          BYTE     bParam       -  Additional Parameter (Transfer Mode)
//  Output: BOOLEAN -  FALSE if command successful
//                     TRUE  if command unsuccessful
// Written: by Dmitry V.Stefankov 14-Sep-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_SetFeatures(BOOLEAN fSetFeature,
                                             BYTE bFeature,
                                             BYTE bParam)
{
    DWORD    dwTimeout = g_dwTimeoutDef;    // Timeout counter
    DWORD    dwWaitFuncRes;                 // Function result
    BOOLEAN  fExitCode = BOOL_FALSE;        // Exit code
    tagATAPI_Stat_Reg_RD    StatusReg;      // ATAPI status byte
    tagATAPI_Err_Reg_RD     ErrorReg;       // ATAPI error byte
    tagSetFeatReg           SetFeatReg;     // ATAPI set features byte
    PBYTE    pbError    = (PBYTE)&ErrorReg; // Pointer to error byte
    PBYTE    pbStatus   = (PBYTE)&StatusReg;// Pointer to status byte
    PBYTE    pbSetFeat  = (PBYTE)&SetFeatReg;// Pointer to SetFeat byte

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---ATA cmd: Set Features---");
#endif                                      // #ifdef _DEBUG

//------------------------------- Select device -------------------------------

    mf_SetDriveSelectReg();
    mf_OutputStatusATAPI( mf_GetStatusATAPI() );

//----------------------- Check for interrupt logic --------------------------

#if defined(_WIN32)
#pragma message ("(25) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_LinkInterruptHandler();
#endif                                      // #if defined(_WIN32)

//------------------------ Send ATA command to device ------------------------

    SetFeatReg.FeatureNumber   = bFeature;
    SetFeatReg.SetClearFeature = (BYTE)fSetFeature;
    mf_WriteByteReg(m_ATAPI_Cmd_Blk_Wr.bATAPI_Features, *pbSetFeat );
    if ( bFeature == SetTransferModeBasedOnSCR )
       mf_WriteByteReg(m_ATAPI_Cmd_Blk_Wr.bATAPI_Unused, bParam);
#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputMessage("--- SetFeatsReg=");
        OutputHexByte(*pbSetFeat, g_fAddHexPrefix, g_fNoAddNewLine);
        OutputMessage(";   SecContReg=");
        OutputHexByte(bParam, g_fAddHexPrefix, g_fAddNewLine);
        OutputMessageLF(">>>Send Set Features command<<<");
    }
#endif                                      // #ifdef _DEBUG
    mf_SendCmdByteATA(bATA_cmd_Set_Features);

//------------------------- Wait while drive is busy -------------------------

    WaitBiosTicksSec18(3);                  // Some delay before go further

//----------------------- Wait command termination from drive -----------------

    if (m_bSoftIntNum)
    {
        dwWaitFuncRes = mf_WaitDriveInt(3);   // ~3.5 seconds
    }
    else
    {
        dwWaitFuncRes = mf_WaitBusyDrive(dwTimeout);
    }

    if ( !dwWaitFuncRes )
    {
        mf_OutputErrorATAPI( mf_GetErrorATAPI() );
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Set Features command failed.");
#endif                                      // #ifdef _DEBUG
        goto Terminate;
    }

//---------------------------- Look return code -------------------------------

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---Check returned status and error codes---");
#endif                                      // #ifdef _DEBUG
    *pbStatus = mf_GetStatusATAPI();
    mf_OutputStatusATAPI( *pbStatus );
    *pbError = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( *pbError );
    if ( *pbError == 0 )
    {
#ifdef _DEBUG
        if (g_fDebug)
           OutputMessageLF("---Set Features command completed successfully---");
#endif                                      // #ifdef _DEBUG
        fExitCode = BOOL_TRUE;              // Good termination
    }
    else
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Set Features command returned bad status.");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Check for filtered interrupts -----------------------
Terminate:
#if defined(_WIN32)
#pragma message ("(26) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_UnLinkInterruptHandler();
#endif                                      // #if defined(_WIN32)
    return (fExitCode);
}



//****************************************************************************
//              --- AtapiHardwareAccess::mf_ExecDriveDiag ---
//
// Purpose: Performs the internal diagnostic test
//   Input: none
//  Output: BOOLEAN -  FALSE if command successful
//                     TRUE  if command unsuccessful
// Written: by Dmitry V.Stefankov 6-Oct-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_ExecDriveDiag()
{
    DWORD    dwTimeout = g_dwTimeoutDef;    // Timeout counter
    DWORD    dwWaitFuncRes;                 // Function result
    BOOLEAN  fExitCode = BOOL_FALSE;        // Exit code
    tagATAPI_Stat_Reg_RD    StatusReg;      // ATAPI status byte
    tagATAPI_Err_Reg_RD     ErrorReg;       // ATAPI error byte
    PBYTE    pbError    = (PBYTE)&ErrorReg; // Pointer to error byte
    PBYTE    pbStatus   = (PBYTE)&StatusReg;// Pointer to status byte

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---ATA cmd: Execure Drive Diagnostic---");
#endif                                      // #ifdef _DEBUG

//------------------------------- Select device -------------------------------

    mf_SetDriveSelectReg();
    mf_OutputStatusATAPI( mf_GetStatusATAPI() );

//----------------------- Check for interrupt logic --------------------------

#if defined(_WIN32)
#pragma message ("(27) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_LinkInterruptHandler();
#endif                                      // #if defined(_WIN32)

//------------------------ Send ATA command to device ------------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF(">>>Send Execure Drive Diagnostic command<<<");
#endif                                      // #ifdef _DEBUG
    mf_SendCmdByteATA(bATA_cmd_Exec_Drv_Diag);

//------------------------- Wait while drive is busy -------------------------

    WaitBiosTicksSec18(3);                  // Some delay before go further

//----------------------- Wait command termination from drive -----------------

    if (m_bSoftIntNum)
    {
        dwWaitFuncRes = mf_WaitDriveInt(10);   // 10 seconds
    }
    else
    {
        dwWaitFuncRes = mf_WaitBusyDrive(dwTimeout); // ???
    }

    if ( !dwWaitFuncRes )
    {
        mf_OutputErrorATAPI( mf_GetErrorATAPI() );
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Execure Drive Diagnostic command failed.");
#endif                                      // #ifdef _DEBUG
        goto Terminate;
    }

//---------------------------- Look return code -------------------------------

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---Check returned status and error codes---");
#endif                                      // #ifdef _DEBUG
    *pbStatus = mf_GetStatusATAPI();
    mf_OutputStatusATAPI( *pbStatus );
    *pbError = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( *pbError );
    if ( *pbError == 0 )
    {
#ifdef _DEBUG
        if (g_fDebug)
           OutputMessageLF("---Execure Drive Diagnostic command completed successfully---");
#endif                                      // #ifdef _DEBUG
        fExitCode = BOOL_TRUE;              // Good termination
    }
    else
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->Execure Drive Diagnostic command returned bad status.");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Check for filtered interrupts -----------------------
Terminate:
#if defined(_WIN32)
#pragma message ("(28) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_UnLinkInterruptHandler();
#endif                                      // #if defined(_WIN32)
    return (fExitCode);
}



//****************************************************************************
//              --- AtapiHardwareAccess::mf_NOPeration ---
//
// Purpose: Enables host which can only perform 16-bit register accesses
//          to check drive status
//   Input: none
//  Output: BOOLEAN -  FALSE if command successful
//                     TRUE  if command unsuccessful
// Written: by Dmitry V.Stefankov 12-Sep-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_NOPeration()
{
    BOOLEAN  fExitCode = BOOL_FALSE;        // Exit code
    tagATAPI_Stat_Reg_RD    StatusReg;      // ATAPI status byte
    tagATAPI_Err_Reg_RD     ErrorReg;       // ATAPI error byte
    PBYTE    pbError    = (PBYTE)&ErrorReg; // Pointer to error byte
    PBYTE    pbStatus   = (PBYTE)&StatusReg;// Pointer to status byte

#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---ATA cmd: No Operation---");
#endif                                      // #ifdef _DEBUG

//------------------------------- Select device -------------------------------

    mf_SetDriveSelectReg();
    mf_OutputStatusATAPI( mf_GetStatusATAPI() );

//------------------------ Send ATA command to device ------------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF(">>>Send NOP command<<<");
#endif                                      // #ifdef _DEBUG
    mf_SendCmdByteATA(bATA_cmd_NOP);

//------------------------- Wait while drive is busy -------------------------

    WaitBiosTicksSec18(1);                  // Really we no need this

//---------------------------- Look return status -----------------------------

    *pbStatus = mf_GetStatusATAPI();
    mf_OutputStatusATAPI( *pbStatus );
    *pbError = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( *pbError );
    if ( (StatusReg.CHECK) && (ErrorReg.ABRT) && (!StatusReg.BSY) )
    {
#ifdef _DEBUG
        if (g_fDebug)
           OutputMessageLF("---NOP command terminated successfully---");
#endif                                      // #ifdef _DEBUG
        fExitCode = BOOL_TRUE;              // Good termination
    }
    else
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("->NOP command failed.");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Check for filtered interrupts -----------------------
Terminate:
    return (fExitCode);
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_ExecAtaDriveCmd ---
//
// Purpose: Executes a ATA drive command
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 12-Sep-97
//****************************************************************************
void  AtapiHardwareAccess::mf_ExecAtaDriveCmd()
{
    BOOLEAN     fFuncResult;                // Function result

    if ( g_fNOP == BOOL_TRUE )
    {
      OutputMessageLF(".....NOP (test interface).");
      fFuncResult = mf_NOPeration();        // Tests 16-bit interface
    }
    if ( g_fChkMode == BOOL_TRUE )
    {
      OutputMessageLF(".....Check Power Mode.");
      fFuncResult = mf_ChkPwrMode();        // Tests power mode
    }
    if ( g_fIdleModeImm == BOOL_TRUE )
    {
      OutputMessageLF(".....Enter Idle Mode Immediate.");
      fFuncResult = mf_EnterIdleModeImm();  // Enter idle mode immediate
    }
    if ( g_fStandbyImm == BOOL_TRUE )
    {
      OutputMessageLF(".....Enter Standby Mode Immediate.");
      fFuncResult = mf_EnterStandbyModeImm();// Enter idle mode immediate
    }
    if ( g_fSleep == BOOL_TRUE )
    {
      OutputMessageLF(".....Enter Sleep Mode.");
      fFuncResult = mf_EnterSleepMode();    // Enter sleep mode
    }
    if ( fFuncResult == BOOL_FALSE )
      OutputMessageLF(".....WARNING!! ATA command return bad status.");
    g_fOtherCmdDone = BOOL_TRUE;            // Yes, done
}
#endif                                      // #if defined(_ATA_CMDS)
