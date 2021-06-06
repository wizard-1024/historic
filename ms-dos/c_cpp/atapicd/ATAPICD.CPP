//****************************************************************************
//                            File ATAPICD.CPP
//
//              ATAPI CD-ROM drive hardware commands
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BC31/SOURCE/ATAPICD/RCS/atapicd.cpp $
//  $RCSfile: atapicd.cpp $
//   $Author: dstef $
//     $Date: 1999/12/31 19:53:57 $
// $Revision: 1.2 $
//   $Locker: dstef $
//
//      $Log: atapicd.cpp $
//      Revision 1.2  1999/12/31 19:53:57  dstef
//      Switched to safe coding style (strncat,strncpy)
//
//      Revision 1.1  1999/01/02 00:23:09  dstef
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
#include  "inth.hpp"                        // Interrupt handlung
#include  "fproto.hpp"                      // Function prototypes
#include  "extern.hpp"                      // External data declarations
#include  "atapi.hpp"                       // ATAPI hardware class



//---------------------------Compilation Information--------------------------
static char  rcsid[] = "$Id: atapicd.cpp 1.2 1999/12/31 19:53:57 dstef Exp dstef $";               // RCS marker



//****************************************************************************
//               --- AtapiHardwareAccess::mf_GetInquiryData ---
//
// Purpose: Read inquiry data from drive
//   Input: none
//  Output: BOOLEAN -  FALSE if no transferred inquiry data from drive
//                     TRUE  if inquiry data transfer complete
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_GetInquiryData()
{
    DWORD      dwTimeout;                   // Timeout counter
    BOOLEAN    fFuncRes  =  BOOL_FALSE;     // Function result
    char       chName[g_wDosFileNameSize];  // File name to dump
    WORD       wXfrCount;                   // Transferred bytes count
    struct  Inquiry_Cmd_Pkt_Out   Inquiry_Cmd_Pkt;
    struct  ATAPI_CDROM_Std_Cmd_Pkt  ATAPI_Cmd_Pkt_Std;

//----------------------- Check for interrupt logic --------------------------

#if defined(_WIN32)
#pragma message ("(4) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_LinkInterruptHandler();
#endif                                      // #if defined(_WIN32)

//---------------------- Test for ATAPI device presence ----------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---ATAPI pkt cmd: Get ATAPI Inquiry Device data (standard)---");
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

//-------------------- Build ATAPI INQUIRY command packet --------------------

    memset( &Inquiry_Cmd_Pkt, 0, sizeof(Inquiry_Cmd_Pkt_Out) );
    Inquiry_Cmd_Pkt.bOpCode = bInquiry;
    Inquiry_Cmd_Pkt.bPageCode = 0;
    Inquiry_Cmd_Pkt.bAllocLength = sizeof(m_InquiryDataStd);
    memcpy( &ATAPI_Cmd_Pkt_Std, &Inquiry_Cmd_Pkt, sizeof(Inquiry_Cmd_Pkt_Out) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
        goto Terminate;                     // Command was ejected
    }

//--------------------------- Read data from drive ---------------------------
#ifdef _DEBUG
    if (g_fDebug)
       OutputMessageLF("---Transfer inquiry data (standard)---");
#endif                                      // #ifdef _DEBUG
    wXfrCount = mf_TransferDataFromDrive( (PBYTE)&m_InquiryDataStd,
                                          sizeof(m_InquiryDataStd),
                                          0);
    fFuncRes = (BOOLEAN)( wXfrCount == sizeof(m_InquiryDataStd) );

//-------------------------- Write raw data to file --------------------------

    if (fFuncRes && g_fRawDump)
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("---Write inquiry (std) data to file---");
#endif                                      // #ifdef _DEBUG
        strncpy(chName, m_chBaseFileName, sizeof(chName));
        WriteBinaryFile( strncat(chName, g_szInquiryStdExt, sizeof(chName)),
                        (PBYTE)&m_InquiryDataStd,
                        sizeof(m_InquiryDataStd));
    }

//----------------------- Terminate function ---------------------------------

Terminate:
#if defined(_WIN32)
#pragma message ("(5) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_UnLinkInterruptHandler();
#endif                                      // #if defined(_WIN32)

    return (fFuncRes);
}



//****************************************************************************
//               --- AtapiHardwareAccess::mf_GetInquiryDataExt ---
//
// Purpose: Read inquiry data from drive (extended)
//   Input: none
//  Output: BOOLEAN -  FALSE if no transferred inquiry data from drive
//                     TRUE  if inquiry data transfer complete
// Written: by Dmitry V.Stefankov 02-25-96
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_GetInquiryDataExt()
{
    DWORD      dwTimeout;                   // Timeout counter
    BOOLEAN    fFuncRes = BOOL_FALSE;       // Function result
    char       chName[g_wDosFileNameSize];  // File name to dump
    WORD       wXfrCount;                   // Transferred bytes count
    struct  Inquiry_Cmd_Pkt_Out   Inquiry_Cmd_Pkt;
                                            // Inquiry command packet buffer
    struct  ATAPI_CDROM_Std_Cmd_Pkt  ATAPI_Cmd_Pkt_Std;
                                            // Command packet buffer

//----------------------- Check for interrupt logic --------------------------

#if defined(_WIN32)
#pragma message ("(6) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_LinkInterruptHandler();
#endif                                      // #if defined(_WIN32)

//---------------------- Test for ATAPI device presence ----------------------
#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---ATAPI pkt cmd: Get ATAPI Inquiry Device data (extended)---");
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

//-------------------- Build ATAPI INQUIRY command packet --------------------

    memset( &Inquiry_Cmd_Pkt, 0, sizeof(Inquiry_Cmd_Pkt_Out) );
    Inquiry_Cmd_Pkt.bOpCode = bInquiry;
    Inquiry_Cmd_Pkt.bPageCode = 0;
    Inquiry_Cmd_Pkt.bAllocLength = sizeof(m_InquiryDataExt);
    memcpy( &ATAPI_Cmd_Pkt_Std, &Inquiry_Cmd_Pkt, sizeof(Inquiry_Cmd_Pkt_Out) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
        goto Terminate;                     // Command was ejected
    }

//--------------------------- Read data from drive ---------------------------
#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Transfer inquiry data (extended)---");
#endif                                      // #ifdef _DEBUG
    wXfrCount = mf_TransferDataFromDrive( (PBYTE)&m_InquiryDataExt,
                                          sizeof(m_InquiryDataExt),
                                          0);
    fFuncRes = (BOOLEAN)( wXfrCount == sizeof(m_InquiryDataExt) );

//-------------------------- Write raw data to file --------------------------

    if (fFuncRes && g_fRawDump)
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("---Write inquiry (ext) data to file---");
#endif                                      // #ifdef _DEBUG
        strncpy(chName, m_chBaseFileName, sizeof(chName));
        WriteBinaryFile( strncat(chName, g_szInquiryExtExt, sizeof(chName)),
                        (PBYTE)&m_InquiryDataExt,
                        sizeof(m_InquiryDataExt));
    }

//----------------------- Terminate function ---------------------------------

Terminate:
#if defined(_WIN32)
#pragma message ("(7) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_UnLinkInterruptHandler();
#endif                                      // #if defined(_WIN32)

    return (fFuncRes);
}



//****************************************************************************
//            --- AtapiHardwareAccess::mf_GetAllModePagesData ---
//
// Purpose: Read all the mode pages data from drives
//   Input: BYTE bPageControlValue  - Type of return page
//  Output: BOOLEAN -  FALSE  if no data ware getting
//                     TRUE   if data were getting
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_GetAllModePagesData(BYTE bPageControlValue)
{
    DWORD      dwTimeout;                   // Timeout counter
    BOOLEAN    fFuncRes;                    // Function result
    char       chName[g_wDosFileNameSize];  // File name to dump
    WORD       wXfrCount;                   // Transferred bytes count
    struct  Mode_Sense_Cmd_Pkt_Out    Mode_Sense_Cmd_Pkt;
    struct  ATAPI_CDROM_Std_Cmd_Pkt   ATAPI_Cmd_Pkt_Std;
    struct  PageCodeControl           *PageCodeControlField;

//---------------------- Test for ATAPI device presence ----------------------
#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---ATAPI pkt cmd: Get ATAPI Mode Page data---");
#endif                                      // #ifdef _DEBUG
    if (m_fThisIsDevATAPI == BOOL_FALSE)
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
        return (BOOL_FALSE);
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
        return (BOOL_FALSE);
    }

//----------------------- Allocate dynamic data buffer -----------------------
#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Allocate dynamic data buffer for mode pages---");
#endif                                      // #ifdef _DEBUG
    if ( m_pbAllModePagesBuf == NULL)
    {
        m_pbAllModePagesBuf = new ModePageBuf;
        if ( m_pbAllModePagesBuf == NULL)
        {
#ifdef _DEBUG
            if (g_fDebug)
                OutputMessageLF("-> Cannot allocate dynamic data buffer for mode pages.");
#endif                                      // #ifdef _DEBUG
            return (BOOL_FALSE);
        }
    }
    else
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("!!! Dynamic data buffer for mode pages already allocated.");
#endif                                      // #ifdef _DEBUG
    }
    memset( m_pbAllModePagesBuf, 0, sizeof(ModePageBuf) );

//------------------- Build ATAPI MODE SENSE command packet -------------------

    memset( &Mode_Sense_Cmd_Pkt, 0, sizeof(Mode_Sense_Cmd_Pkt_Out) );
    Mode_Sense_Cmd_Pkt.bOpCode = bModeSense;
    PageCodeControlField = (PageCodeControl * )&Mode_Sense_Cmd_Pkt.bPageCodeControl;
    PageCodeControlField->PAGE_CODE = bAllPagesMPC;
    PageCodeControlField->PAGE_CONTROL = bPageControlValue;
    Mode_Sense_Cmd_Pkt.bAllocLenMSB = sizeof(ModePageBuf) >> 8;
    Mode_Sense_Cmd_Pkt.bAllocLenLSB = sizeof(ModePageBuf) & 0xFF;
    memcpy( &ATAPI_Cmd_Pkt_Std, &Mode_Sense_Cmd_Pkt, sizeof(Mode_Sense_Cmd_Pkt) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("!!! ATAPI packet command failed.");
#endif                                      // #ifdef _DEBUG
        return (BOOL_FALSE);
    }

//--------------------------- Read data from drive ---------------------------

    wXfrCount = mf_TransferDataFromDrive( (PBYTE)m_pbAllModePagesBuf,
                                          sizeof(ModePageBuf),
                                          0);
    fFuncRes = (BOOLEAN)( (wXfrCount != 0) && (wXfrCount != 0xFFFF) );

//----------------------------- Check for errors -----------------------------

    if ( mf_GetErrorATAPI() != 0 )
    {
        fFuncRes = BOOL_FALSE;
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("!!! Mode sense command failed.");
#endif                                      // #ifdef _DEBUG
    }

//-------------------------- Write raw data to file --------------------------

    if (fFuncRes && g_fRawDump)
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("---Write mode sense data to file---");
#endif                                      // #ifdef _DEBUG
        strncpy(chName, m_chBaseFileName, sizeof(chName));
        WriteBinaryFile( strncat(chName, g_szModeSenseExt, sizeof(chName)),
                        (PBYTE)m_pbAllModePagesBuf,
                         wXfrCount);
    }

    return (fFuncRes);
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_TestUnitReady ---
//
// Purpose: Checks is device ready
//   Input: none
//  Output: BOOLEAN       -  FALSE  if no unit ready
//                           TRUE   if unit ready
//  Output: none
// Written: by Dmitry V.Stefankov 08-30-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_TestUnitReady()
{
    DWORD      dwTimeout;                   // Timeout counter
    BYTE       bErrorStatus;                // Error status code
    BOOLEAN    fFuncRes = BOOL_FALSE;       // Function result
    struct  Test_Unit_Ready_Cmd_Pkt_Out  Test_Unit_Ready_Cmd_Pkt;
    struct  ATAPI_CDROM_Std_Cmd_Pkt      ATAPI_Cmd_Pkt_Std;

//---------------------- Test for ATAPI device presence ----------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---ATAPI pkt cmd: Test Unit Ready---");
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

//-------------------- Build ATAPI TEST UNIT READY command packet -------------

    memset( &Test_Unit_Ready_Cmd_Pkt, 0, sizeof(Test_Unit_Ready_Cmd_Pkt_Out) );
    Test_Unit_Ready_Cmd_Pkt.bOpCode = bTestUnitReady;
    memcpy( &ATAPI_Cmd_Pkt_Std, &Test_Unit_Ready_Cmd_Pkt, sizeof(Test_Unit_Ready_Cmd_Pkt_Out) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
        goto Terminate;                     // Command was ejected
    }
    WaitBiosTicksSec18(3);

//--------------------------- Read status from drive --------------------------

    mf_OutputStatusATAPI( mf_GetStatusATAPI() );
    bErrorStatus = mf_GetErrorATAPI();
    mf_OutputErrorATAPI( bErrorStatus );
    if ( bErrorStatus )
    {
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("!!! Test Unit Ready command failed.");
#endif                                      // #ifdef _DEBUG
    }
    else
    {
       fFuncRes = BOOL_TRUE;
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("---Test Unit Ready command completed successfully---");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Terminate function ---------------------------------

Terminate:
    return( fFuncRes );
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_SeekBlock ---
//
// Purpose: Seeks the specified logical block address
//   Input: DWORD  dwBlockNum  -  Address of logical block to seek
//  Output: BOOLEAN       -  FALSE  if no playing started
//                           TRUE   if playing started
//  Output: none
// Written: by Dmitry V.Stefankov 08-31-97
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_SeekBlock(DWORD  dwBlockNum)
{
    DWORD      dwTimeout;                   // Timeout counter
    BYTE       bErrorStatus;                // Error status code
    BOOLEAN    fFuncRes = BOOL_FALSE;       // Function result
    struct  Seek_Cmd_Pkt_Out           Seek_Cmd_Pkt;
    struct  ATAPI_CDROM_Std_Cmd_Pkt    ATAPI_Cmd_Pkt_Std;

//---------------------- Test for ATAPI device presence ----------------------

#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputMessageLF("---Seek---");
        OutputMessage("--- Address of block: ");
        OutputDoubleWordLF(dwBlockNum);
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

//-------------------- Build ATAPI SEEK command packet ------------------------

    memset( &Seek_Cmd_Pkt, 0, sizeof(Seek_Cmd_Pkt_Out) );
    Seek_Cmd_Pkt.bOpCode = bSeek;
    Seek_Cmd_Pkt.bStart_LBA_3 = (BYTE)(dwBlockNum >> 24);
    Seek_Cmd_Pkt.bStart_LBA_2 = (BYTE)(dwBlockNum >> 16);
    Seek_Cmd_Pkt.bStart_LBA_1 = (BYTE)(dwBlockNum >> 8);
    Seek_Cmd_Pkt.bStart_LBA_0 = (BYTE)(dwBlockNum & 0xFF);
    memcpy( &ATAPI_Cmd_Pkt_Std, &Seek_Cmd_Pkt, sizeof(Seek_Cmd_Pkt_Out) );

//------------------------- Send this packet to drive -------------------------

    if ( mf_SendPacketCommand(&ATAPI_Cmd_Pkt_Std) == BOOL_FALSE )
    {
        goto Terminate;                     // Command was ejected
    }
    WaitBiosTicksSec18(3);                  // Wait some time

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
         OutputMessageLF("!!! Seek command failed.");
#endif                                      // #ifdef _DEBUG
    }
    else
    {
       fFuncRes = BOOL_TRUE;
#ifdef _DEBUG
       if (g_fDebug)
         OutputMessageLF("---Seek completed successfully---");
#endif                                      // #ifdef _DEBUG
    }

//----------------------- Terminate function ---------------------------------

Terminate:
    return( fFuncRes );
}
