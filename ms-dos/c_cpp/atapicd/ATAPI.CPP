//****************************************************************************
//                             File ATAPI.CPP
//
//                    ATAPI hardware class methods
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BC31/SOURCE/ATAPICD/RCS/atapi.cpp $
//  $RCSfile: atapi.cpp $
//   $Author: dstef $
//     $Date: 1999/12/31 19:55:22 $
// $Revision: 1.2 $
//   $Locker: dstef $
//
//      $Log: atapi.cpp $
//      Revision 1.2  1999/12/31 19:55:22  dstef
//      Switched to safe coding style (strncat,strncpy)
//
//      Revision 1.1  1999/01/02 00:20:13  dstef
//      Initial revision
//
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
static char  rcsid[] = "$Id: atapi.cpp 1.2 1999/12/31 19:55:22 dstef Exp dstef $";              // RCS marker



//****************************************************************************
//            --- AtapiHardwareAccess::AtapiHardwareAccess ---
//
// Purpose: (Build)Initialize ATAPI drive object (constructor)
//   Input: const WORD ioBaseMain -  Hardware main base address
//          const WORD ioBaseAlt  -  Hardware alternate base address
//          const BYTE bDrv       -  Drive number for this base
//          const BYTE bIntNum    -  Interrupt (software) number (INT)
//          const BYTE bIrqNum    -  Interrupt (hardware) number (IRQ)
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
AtapiHardwareAccess::AtapiHardwareAccess(const WORD ioBaseMain,
                                         const WORD ioBaseAlt,
                                         const BYTE bDrv,
                                         const BYTE bIntNum,
                                         const BYTE bIrqNum)
{
    char     chTemp[2];                     // Temporary storage
    BYTE     bDriveOrderNum = 0;            // Drive order in system

#if defined(_DEBUG) && defined(_BETA)
    if (g_fDebug)
        OutputMessageLF("<<< AtapiHardwareAccess(): start >>>");
#endif                                      // #ifdef defined(_DEBUG) && defined(_BETA)

//-------------------------- Constructor parameters --------------------------

#if defined(_DEBUG) && defined(_BETA)
    if (g_fDebug)
    {
        OutputMessage("ATAPI hardware constructor for base=");
        OutputHexWord(ioBaseMain, g_fAddHexPrefix, g_fNoAddNewLine);
        OutputMessage(", alt=");
        OutputHexWord(ioBaseAlt, g_fAddHexPrefix, g_fNoAddNewLine);
        OutputMessage(", drv=");
        OutputHexByte(bDrv, g_fAddHexPrefix, g_fAddNewLine);
    }
#endif                                      // #ifdef defined(_DEBUG) && defined(_BETA)

//------------------------- Initialize instance data -------------------------

#if defined(_DEBUG) && defined(_BETA)
    if (g_fDebug)
        OutputMessageLF("Init variables");
#endif                                      // #ifdef defined(_DEBUG) && defined(_BETA)

    m_bATAPI_Version          =  0;
    m_bATAPI_Drive            =  bDrv;
    m_wDriveBaseMainAddr      =  ioBaseMain;
    m_wDriveBaseAltAddr       =  ioBaseAlt;
    m_bSoftIntNum             =  bIntNum;
    g_bCurIntNum              =  bIntNum;   // Find other way and you're lucky!
    m_bHardIrqNum             =  bIrqNum;
    g_bCurIrqNum              =  bIrqNum;
    m_fThisIsDevATAPI         =  BOOL_FALSE;
    m_fIdentifyDataATAPI      =  BOOL_FALSE;
    m_fInquiryDataExt         =  BOOL_FALSE;
    m_pbAllModePagesBuf       =  NULL;
    memset( &m_IdentifyData,   0, sizeof(m_IdentifyData) );
    memset( &m_InquiryDataStd, 0, sizeof(m_InquiryDataStd) );
    memset( &m_InquiryDataExt, 0, sizeof(m_InquiryDataExt) );

//----------------------- Build base filename for drive -----------------------

    m_chBaseFileName[0] = '\0';             // Default: drive0, drive1
    strncat(m_chBaseFileName, "drive", sizeof(m_chBaseFileName) );
    if  ( m_wDriveBaseMainAddr == ioQUATERNARY_MAIN_CTRLR_IO_BASE )
      bDriveOrderNum += 6;                  // drive6, drive7
    else if  ( m_wDriveBaseMainAddr == ioTERTIARY_MAIN_CTRLR_IO_BASE )
      bDriveOrderNum += 4;                  // drive4, drive5
    else if  ( m_wDriveBaseMainAddr == ioSECONDARY_MAIN_CTRLR_IO_BASE )
      bDriveOrderNum += 2;                  // drive2, drive3
    else if  ( m_wDriveBaseMainAddr == ioPRIMARY_MAIN_CTRLR_IO_BASE )
      bDriveOrderNum += 0;                  // drive0, drive1
    else if  ( m_wDriveBaseMainAddr == g_wUserBaseAddr )
      bDriveOrderNum += 8;                  // drive8, drive9
    if ( m_bATAPI_Drive )
      bDriveOrderNum++;
    itoa( bDriveOrderNum, chTemp, g_wDecRadix );
    strncat( m_chBaseFileName, chTemp, sizeof(m_chBaseFileName) );

//---------------- Build register map specific for each device ----------------

#if defined(_DEBUG) && defined(_BETA)
    if (g_fDebug)
        OutputMessageLF("Init registers map");
#endif                                      // #ifdef defined(_DEBUG) && defined(_BETA)

    m_ATAPI_Ctrl_Blk_Rd.bFDC_A_Stat        = ioBaseAlt + 0;
    m_ATAPI_Ctrl_Blk_Rd.bFDC_B_Stat        = ioBaseAlt + 1;
    m_ATAPI_Ctrl_Blk_Rd.bUnused_1          = ioBaseAlt + 2;
    m_ATAPI_Ctrl_Blk_Rd.FloppyTape.bFDC_ID = ioBaseAlt + 3;
    m_ATAPI_Ctrl_Blk_Rd.bFDC_Stat          = ioBaseAlt + 4;
    m_ATAPI_Ctrl_Blk_Rd.bFDC_DATA          = ioBaseAlt + 5;
    m_ATAPI_Ctrl_Blk_Rd.bATAPI_Stat_ALt    = ioBaseAlt + 6;
    m_ATAPI_Ctrl_Blk_Rd.bUnused_2          = ioBaseAlt + 7;

    m_ATAPI_Ctrl_Blk_Wr.bUnused_1   = ioBaseAlt + 0;
    m_ATAPI_Ctrl_Blk_Wr.bUnused_2   = ioBaseAlt + 1;
    m_ATAPI_Ctrl_Blk_Wr.bFDC_DOR    = ioBaseAlt + 2;
    m_ATAPI_Ctrl_Blk_Wr.bReserved_1 = ioBaseAlt + 3;
    m_ATAPI_Ctrl_Blk_Wr.bReserved_2 = ioBaseAlt + 4;
    m_ATAPI_Ctrl_Blk_Wr.bFDC_DATA   = ioBaseAlt + 5;
    m_ATAPI_Ctrl_Blk_Wr.bDev_Ctrl   = ioBaseAlt + 6;
    m_ATAPI_Ctrl_Blk_Wr.bUnused_3   = ioBaseAlt + 7;

    m_ATAPI_Cmd_Blk_Rd.wData              = ioBaseMain + 0;
    m_ATAPI_Cmd_Blk_Rd.bATAPI_Err         = ioBaseMain + 1;
    m_ATAPI_Cmd_Blk_Rd.bATAPI_Intr_Reason = ioBaseMain + 2;
    m_ATAPI_Cmd_Blk_Rd.bSAM_TAG           = ioBaseMain + 3;
    m_ATAPI_Cmd_Blk_Rd.bATAPI_Byte_Cnt_Lo = ioBaseMain + 4;
    m_ATAPI_Cmd_Blk_Rd.bATAPI_Byte_Cnt_Hi = ioBaseMain + 5;
    m_ATAPI_Cmd_Blk_Rd.bDrv_Sel           = ioBaseMain + 6;
    m_ATAPI_Cmd_Blk_Rd.bATAPI_Stat        = ioBaseMain + 7;

    m_ATAPI_Cmd_Blk_Wr.wData              = ioBaseMain + 0;
    m_ATAPI_Cmd_Blk_Wr.bATAPI_Features    = ioBaseMain + 1;
    m_ATAPI_Cmd_Blk_Wr.bATAPI_Unused      = ioBaseMain + 2;
    m_ATAPI_Cmd_Blk_Wr.bSAM_TAG           = ioBaseMain + 3;
    m_ATAPI_Cmd_Blk_Wr.bATAPI_Byte_Cnt_Lo = ioBaseMain + 4;
    m_ATAPI_Cmd_Blk_Wr.bATAPI_Byte_Cnt_Hi = ioBaseMain + 5;
    m_ATAPI_Cmd_Blk_Wr.bDrv_Sel           = ioBaseMain + 6;
    m_ATAPI_Cmd_Blk_Wr.bATA_Cmd           = ioBaseMain + 7;

#if defined(_DEBUG) && defined(_BETA)
    if (g_fDebug)
        OutputMessageLF("<<< AtapiHardwareAccess(): end >>>");
#endif                                      // #ifdef defined(_DEBUG) && defined(_BETA)
}



//****************************************************************************
//            --- AtapiHardwareAccess::~AtapiHardwareAccess ---
//
// Purpose: Destroy(free) ATAPI drive object (destructor)
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
AtapiHardwareAccess::~AtapiHardwareAccess()
{

#if defined(_DEBUG) && defined(_BETA)
    if (g_fDebug)
        OutputMessageLF("<<< ~AtapiHardwareAccess(): start >>>");
#endif                                      // #ifdef defined(_DEBUG) && defined(_BETA)

//------------------------ Which destructor is called ------------------------

#if defined(_DEBUG) && defined(_BETA)
    if (g_fDebug)
    {
        OutputMessage("ATAPI hardware destructor for base=");
        OutputHexWord(m_wDriveBaseMainAddr, g_fAddHexPrefix, g_fNoAddNewLine);
        OutputMessage(", alt=");
        OutputHexWord(m_wDriveBaseAltAddr, g_fAddHexPrefix, g_fNoAddNewLine);
        OutputMessage(", drv=");
        OutputHexByte(m_bATAPI_Drive, g_fAddHexPrefix, g_fAddNewLine);
    }
#endif                                      // #ifdef defined(_DEBUG) || defined(_BETA)

//------------------------------ Free resources ------------------------------

    g_bCurIntNum = 0;                       // Classes not supported interrupts
    g_bCurIrqNum = 0;

    if ( m_pbAllModePagesBuf != NULL)
    {
#if defined(_DEBUG) && defined(_BETA)
        if (g_fDebug)
            OutputMessageLF("Dealllocate dynamic data buffer for mode pages.");
#endif                                      // #ifdef defined(_DEBUG) || defined(_BETA)
        delete m_pbAllModePagesBuf;
    }

#if defined(_DEBUG) && defined(_BETA)
    if (g_fDebug)
        OutputMessageLF("<<< ~AtapiHardwareAccess(): end >>>");
#endif                                      // #ifdef defined(_DEBUG) || defined(_BETA)
}



//****************************************************************************
//                --- AtapiHardwareAccess::mf_EmulateDelay ---
//
// Purpose: Emulate JMP instruction to time delay
//   Input: WORD wCount - Times of "JMPs"
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  AtapiHardwareAccess::mf_EmulateDelay(WORD wCount)
{
#if defined(_WIN32)
#pragma message ("(14) Emulate delay function must be tested in Win32 environment." )
    Sleep( wCount );                        // Wait N ms
#else                                       // #if defined(_WIN32)
    while (wCount--)
    {
        goto  FlushQueue;
        FlushQueue:  { /*empty*/ }
    }
#endif                                      // #if defined(_WIN32)
}



//****************************************************************************
//             --- AtapiHardwareAccess::mf_SetDriveSelectReg ---
//
// Purpose: Sets the current drive to access for controller (channel)
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  AtapiHardwareAccess::mf_SetDriveSelectReg()
{
    struct ATAPI_Drv_Sel_Reg_RD_WR  bATAPI_Drv_Sel_Reg;
                                            // ATAPI Register
    PBYTE  pbData = (PBYTE)&bATAPI_Drv_Sel_Reg; // ATAPI Drive Select (pointer)

    *pbData = 0;                            // Initialize

    bATAPI_Drv_Sel_Reg.DRV = m_bATAPI_Drive;// Selected drive (instance data)
    bATAPI_Drv_Sel_Reg.SET_ONE_1 = 1;       // For ATA compatible devices
    bATAPI_Drv_Sel_Reg.SET_ONE_2 = 1;       // For ATA compatible devices

    mf_WriteByteReg(m_ATAPI_Cmd_Blk_Wr.bDrv_Sel, *pbData); // Sets wanted device
}



//****************************************************************************
//             --- AtapiHardwareAccess::mf_OutputStatusATAPI ---
//
// Purpose: Output ATAPI status register value w/bit description
//   Input: BYTE bStatusOut - Status byte
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  AtapiHardwareAccess::mf_OutputStatusATAPI(BYTE bStatusOut)
{
#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputMessage("Status reg=");
        OutputHexByte(bStatusOut, g_fAddHexPrefix, g_fNoAddNewLine);
        OutputBitStatus(bStatusOut, g_fAddNewLine);
    }
#else
    bStatusOut = bStatusOut;                // Avoid warning messages
#endif                                      // #ifdef _DEBUG
}



//****************************************************************************
//              --- AtapiHardwareAccess::mf_OutputErrorATAPI ---
//
// Purpose: Output ATAPI error register value w/bit description
//   Input: BYTE bErrorOut - Error status byte
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  AtapiHardwareAccess::mf_OutputErrorATAPI(BYTE bErrorOut)
{
#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputMessage("Error  reg=");
        OutputHexByte(bErrorOut, g_fAddHexPrefix, g_fNoAddNewLine);
        OutputBitError(bErrorOut, g_fAddNewLine);
    }
#else
    bErrorOut = bErrorOut;                  // Avoid warning messages
#endif                                      // #ifdef _DEBUG
}



//****************************************************************************
//            --- AtapiHardwareAccess::mf_CheckSignatureATAPI ---
//
// Purpose: Detect ATAPI Signature if present
//   Input: none
//  Output: BOOLEAN -  FALSE if signature not found
//                     TRUE  if signature found
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_CheckSignatureATAPI()
{
    if ( (mf_ReadByteReg(m_ATAPI_Cmd_Blk_Rd.bATAPI_Byte_Cnt_Lo) == bReset_Reg_Cyl_Lo)
      &&
       (mf_ReadByteReg(m_ATAPI_Cmd_Blk_Rd.bATAPI_Byte_Cnt_Hi) == bReset_Reg_Cyl_Hi) )
        return (BOOL_TRUE);                     // Signature found!
    else
        return (BOOL_FALSE);
}

//****************************************************************************
//              --- AtapiHardwareAccess::mf_GetTransferCount ---
//
// Purpose: Read current transfer count from drive
//   Input: none
//  Output: WORD - Number of bytes to transfer
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
WORD  AtapiHardwareAccess::mf_GetTransferCount()
{
    WORD    wCount;                         // Temporary counter

    wCount = mf_ReadByteReg(m_ATAPI_Cmd_Blk_Rd.bATAPI_Byte_Cnt_Hi) << 8;
    wCount += mf_ReadByteReg(m_ATAPI_Cmd_Blk_Rd.bATAPI_Byte_Cnt_Lo);
    return (wCount);
}



//****************************************************************************
//           --- AtapiHardwareAccess::mf_DetectHardwarePresence ---
//
// Purpose: Tests a presence ATA/ATAPI Task File in system
//   Input: none
//  Output: BOOLEAN -  FALSE  if no Task File
//                     TRUE   if Task File found
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_DetectHardwarePresence()
{
    WORD    wTestRegR  =  m_ATAPI_Cmd_Blk_Rd.bATAPI_Byte_Cnt_Lo; // Test Reg to read
    WORD    wTestRegW  =  m_ATAPI_Cmd_Blk_Wr.bATAPI_Byte_Cnt_Lo; // Test Reg to write
    BYTE    bTestValue  =  0x5A;            // Test value to load
    BYTE    bWriteBackValue;                // Saved original value
    BYTE    bNewValue;                      // New value after writing

    mf_SetDriveSelectReg();

//----------------------- Check ATAPI signature before -----------------------

    if ( mf_CheckSignatureATAPI() == BOOL_TRUE)
        return (BOOL_TRUE);                 // Very true ATAPI device

//------------- Simple read/write test for presence of Task File -------------

    bWriteBackValue = mf_ReadByteReg(wTestRegR);
    mf_EmulateDelay(2);

    mf_WriteByteReg(wTestRegW, bTestValue);
    mf_EmulateDelay(2);

    bNewValue = mf_ReadByteReg(wTestRegR);
    mf_EmulateDelay(2);

    mf_WriteByteReg(wTestRegW, bWriteBackValue);

//---------------------------- Check test results ----------------------------

    if ( bNewValue == bTestValue )          // R/W test passed OK?
        return (BOOL_TRUE);                 // Strong condition!

    if ( bNewValue != 0xFF )                // Usually PC hardware bus returns 0xFF if not present
        return (BOOL_TRUE);                 // Very weak condition!

    return (BOOL_FALSE);                    // Otherwise we assume no hardware
}



//****************************************************************************
//               --- AtapiHardwareAccess::mf_SoftResetATAPI ---
//
// Purpose: Execute a soft reset of ATAPI device
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  AtapiHardwareAccess::mf_SoftResetATAPI()
{
    tagATAPI_Stat_Reg_RD    StatusReg;      // ATAPI status byte
    tagATAPI_Err_Reg_RD     ErrorReg;       // ATAPI error byte
    PBYTE    pbError    = (PBYTE)&ErrorReg; // Pointer to error byte
    PBYTE    pbStatus   = (PBYTE)&StatusReg;// Pointer to status byte
    DWORD    dwCount = g_dwTimeoutDef;      // Timeout counter

#ifdef _DEBUG
    if (g_fDebug)
    OutputMessageLF("---ATA(PI) cmd: ATAPI Soft Reset---");
#endif                                      // #ifdef _DEBUG

//------------------------------ Selects device ------------------------------

    mf_SetDriveSelectReg();
    mf_OutputStatusATAPI( mf_GetStatusATAPI() );

//-------------------------- Send ATAPI command to device ---------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF(">>>Send ATAPI Soft Reset command<<<");
#endif                                      // #ifdef _DEBUG
    mf_SendCmdByteATA(bATAPI_cmd_Soft_Reset);

//------------------------------ Wait a response ------------------------------

    WaitBiosTicksSec18(6);                  // Some delay before go further

    *pbError = 0;                           // Initialize
    do
    {
        *pbStatus = mf_GetStatusATAPI();
        if (!StatusReg.BSY)
        {
            *pbError = mf_GetErrorATAPI();  // Get error status if drive no busy
            dwCount = 1;                    // Terminate if reached zero
        }
        dwCount--;
    } while ((dwCount != 0) && (*pbError != bReset_Reg_Error) );

//-------------------------- Output status to watch --------------------------

    mf_OutputStatusATAPI( mf_GetStatusATAPI() );
}



//****************************************************************************
//              --- AtapiHardwareAccess::mf_GetIdentifyData ---
//
// Purpose: Get identify drive data
//   Input: none
//  Output: BOOLEAN -  FALSE if no data transferred from drive
//                     TRUE  if data transferred successful
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_GetIdentifyData()
{
    DWORD    dwTimeout = g_dwTimeoutDef;    // Timeout counter
    DWORD    dwWaitFuncRes;                 // Function result
    char     chName[g_wDosFileNameSize];    // File name to dump
    WORD     wXfrCount;                     // Transferred bytes count
    BOOLEAN  fExitCode = BOOL_FALSE;        // Exit code

#ifdef _DEBUG
    if (g_fDebug)
    OutputMessageLF("---ATA(PI) cmd: Get ATAPI Identify Device data---");
#endif                                      // #ifdef _DEBUG

//------------------------------- Select device -------------------------------

    mf_SetDriveSelectReg();
    mf_OutputStatusATAPI( mf_GetStatusATAPI() );

//----------------------- Check for interrupt logic --------------------------

#if defined(_WIN32)
#pragma message ("(2) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_LinkInterruptHandler();
#endif                                      // #if defined(_WIN32)

//------------------------ Send ATA command to device ------------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF(">>>Send ATAPI Identify Device command<<<");
#endif                                      // #ifdef _DEBUG
    mf_SendCmdByteATA(bATAPI_cmd_Identify_Dev);

//------------------------- Wait while drive is busy -------------------------

    WaitBiosTicksSec18(2);                  // Some delay before go further

    if ( (!m_bSoftIntNum) && (!mf_WaitBusyDrive(dwTimeout)) )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("-> Drive in busy state, exit after timeout expiration.");
#endif                                      // #ifdef _DEBUG
        goto Terminate;
    }

//----------------------- Wait data request from drive -----------------------

    if (m_bSoftIntNum)
    {
      dwWaitFuncRes = mf_WaitDriveInt(2);   // ~3 seconds
    }
    else
    {
      dwWaitFuncRes = mf_WaitDriveDRQ(dwTimeout);
    }

    if ( !dwWaitFuncRes )
    {
        m_fIdentifyDataATAPI = BOOL_FALSE;  // No identify data from drive
        mf_OutputErrorATAPI( mf_GetErrorATAPI() );
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("-> ATAPI Identify Device command failed (no data from device).");
#endif                                      // #ifdef _DEBUG
        goto Terminate;
    }

//---------------------------- Data transfer phase ----------------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Transfer identify data---");
#endif                                      // #ifdef _DEBUG
    wXfrCount = mf_TransferDataFromDrive( (PBYTE)&m_IdentifyData,
                                          wStdSecSize,
                                          wStdSecSize);
    m_fIdentifyDataATAPI = (BOOLEAN)(wXfrCount == wStdSecSize);
    fExitCode = m_fIdentifyDataATAPI;

//-------------------------- Write raw data to file --------------------------

    if (m_fIdentifyDataATAPI && g_fRawDump)
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("---Write identify data to file---");
#endif                                      // #ifdef _DEBUG
        strncpy(chName, m_chBaseFileName, sizeof(chName) );
        WriteBinaryFile( strncat(chName, g_szIdentifyExt, sizeof(chName) ),
                         (PBYTE)&m_IdentifyData,
                         wStdSecSize);
    }

//----------------------- Check for filtered interrupts -----------------------
Terminate:
#if defined(_WIN32)
#pragma message ("(3) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
    mf_UnLinkInterruptHandler();
#endif                                      // #if defined(_WIN32)
    return (fExitCode);
}



//****************************************************************************
//           --- AtapiHardwareAccess::mf_DetectThisDeviceATAPI ---
//
// Purpose: Determines is current drive ATAPI-compatible
//   Input: BOOLEAN fSoftReset  -  Drive soft reset switch
//          BOOLEAN fSkipAtaCmd - Skip detection phase if ATA cmd in progress
//  Output: BOOLEAN            -  FALSE if drive not ATAPI
//                                TRUE  if drive is ATAPI
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_DetectThisDeviceATAPI(BOOLEAN fSoftReset,
                                                       BOOLEAN fSkipAtaCmd)
{
    BOOLEAN  fHardwareFound  =  BOOL_FALSE; // Hardware detected flag

//-------------------- Skip hardware test for ATA command --------------------

    if ( fSkipAtaCmd == BOOL_TRUE )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("-> Detection phase skipped for ATA command.");
#endif                                      // #ifdef _DEBUG
        fHardwareFound = BOOL_TRUE;
        return( fHardwareFound );
    }

//-------------------- Test hardware (task file) presence --------------------

    if ( mf_DetectHardwarePresence() )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessage("!!! Task file hardware found for base=");
#endif                                      // #ifdef _DEBUG
        fHardwareFound = BOOL_TRUE;
    }
    else
    {
        m_fThisIsDevATAPI = BOOL_FALSE;
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessage("!!! Task file hardware not found for base=");
#endif                                      // #ifdef _DEBUG
    }
#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputHexWord(m_wDriveBaseMainAddr, g_fAddHexPrefix, g_fNoAddNewLine);
        OutputMessage(", drive=");
        OutputByteLF(m_bATAPI_Drive);
    }
#endif                                      // #ifdef _DEBUG

    if ( fHardwareFound == BOOL_FALSE )
        return (m_fThisIsDevATAPI);

//-------------------------- Get ATAPI identify data --------------------------

    mf_GetIdentifyData();
    if ( fSoftReset && (!m_fIdentifyDataATAPI) )
    {
        mf_SoftResetATAPI();                // Execute soft reset before
        mf_GetIdentifyData();               // second attempt to get info
    }

//------------------------ Returns ATAPI boolean flag ------------------------
Terminate:

    m_fThisIsDevATAPI = m_fIdentifyDataATAPI;
    return (m_fThisIsDevATAPI);
}



//****************************************************************************
//               --- AtapiHardwareAccess::mf_WaitCommandComplete ---
//
// Purpose: Wait while drive is busy in specified interval
//   Input: DWORD dwTimeoutValue - Timeout to wait
//           WORD wBIOSticks
//  Output: void
// Written: by Dmitry V.Stefankov 5-Sep-97
//****************************************************************************
void  AtapiHardwareAccess::mf_WaitCommandComplete(DWORD dwTimeoutValue,
                                                  WORD  wBIOSticks)
{
    while ( (wBIOSticks != 0) && ( mf_WaitBusyDrive(dwTimeoutValue) == 0) )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("-> Drive in busy state, enter wait state.");
#endif                                      // #ifdef _DEBUG
        WaitBiosTicksSec18(1);
#ifdef _DEBUG
             if (g_fDebug)
               OutputMessageLF("-> Leave exit wait state.");
#endif                                      // #ifdef _DEBUG
        if  ( !mf_WaitBusyDrive(dwTimeoutValue) )
        {
#ifdef _DEBUG
             if (g_fDebug)
               OutputMessageLF("!!! Drive in busy state.");
#endif                                      // #ifdef _DEBUG
        }
        wBIOSticks--;
    } /*while*/
}



//****************************************************************************
//               --- AtapiHardwareAccess::mf_WaitBusyDrive ---
//
// Purpose: Wait while drive is busy in specified interval
//   Input: DWORD dwTimeoutValue - Timeout to wait
//  Output: DWORD                - Zero  if drive is busy
//                                 Other if drive no busy
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
DWORD  AtapiHardwareAccess::mf_WaitBusyDrive(DWORD dwTimeoutValue)
{
    tagATAPI_Stat_Reg_RD   bATAPI_Stat_Reg; // ATAPI status byte
    PBYTE    bStatus = (PBYTE)&bATAPI_Stat_Reg; // ATAPI status byte (pointer)
    WORD     wDelayValue = g_wDelay;        // Emulation value

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Wait while drive is busy ---");
#endif                                      // #ifdef _DEBUG
    if ( wDelayValue )
       WaitBiosTicksSec18(wDelayValue);     // Some delay before go further
                                            // It requires for some older drives
    do
    {
        *bStatus = mf_GetStatusATAPI();
    }  while ( (bATAPI_Stat_Reg.BSY) && (--dwTimeoutValue) );

    mf_OutputStatusATAPI(*bStatus);

    if  (*bStatus == 0xFF)                 // Some drives make noise on bus!
       dwTimeoutValue = 0;                  // More strong condition!

    return (dwTimeoutValue);
}



//****************************************************************************
//                --- AtapiHardwareAccess::mf_WaitDriveDRQ ---
//
// Purpose: Wait before drive's data request in specified interval
//   Input: DWORD dwTimeoutValue - Timeout to wait
//  Output: DWORD                - Zero  if no data request
//                                 Other if data request occurred
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
DWORD  AtapiHardwareAccess::mf_WaitDriveDRQ(DWORD dwTimeoutValue)
{
    tagATAPI_Stat_Reg_RD   bATAPI_Stat_Reg; // ATAPI status byte
    PBYTE    bStatus = (PBYTE)&bATAPI_Stat_Reg; // ATAPI status byte (pointer)
    WORD     wDelayValue = g_wDelay;        // Emulation value

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("--- Polling method in use ---");
#endif                                      // #ifdef _DEBUG

    if ( wDelayValue )
       WaitBiosTicksSec18(wDelayValue);     // Some delay before go further
                                            // It requires for some older drives
    do
    {
        *bStatus = mf_GetStatusATAPI();
    }  while ( (!bATAPI_Stat_Reg.DRQ) && (--dwTimeoutValue) );

    mf_OutputStatusATAPI(*bStatus);

    if  (*bStatus == 0xFF)                 // Some drives make noise on bus!
       dwTimeoutValue = 0;                  // More strong condition!
    if ( ((pATAPI_Stat_Reg_RD)bStatus)->CHECK == 1 )
       dwTimeoutValue = 0;                  // More strong condition!

    return (dwTimeoutValue);
}



//****************************************************************************
//                --- AtapiHardwareAccess::mf_WaitDriveInt ---
//
// Purpose: Wait before drive's data request in specified interval
//   Input: DWORD dwTimeoutValue - Timeout to wait
//  Output: DWORD                - Zero  if no data request
//                                 Other if data request occurred
// Written: by Dmitry V.Stefankov 30-7-97
//****************************************************************************
DWORD  AtapiHardwareAccess::mf_WaitDriveInt(DWORD dwTimeoutValue)
{
    tagATAPI_Stat_Reg_RD   bATAPI_Stat_Reg; // ATAPI status byte
    PBYTE    bStatus = (PBYTE)&bATAPI_Stat_Reg; // ATAPI status byte (pointer)

    dwTimeoutValue *= g_wBiosStdTicksPerSec;// Make

//----------------------- Check interrupt method -----------------------------

    if (m_bSoftIntNum)
    {
#ifdef _DEBUG
      if (g_fDebug)
      {
          OutputMessageLF("--- Interrupt method in use ---");
          OutputMessageLF("--- Wait while interrupt occured ---");
      }
#endif                                      // #ifdef _DEBUG
      while ( (g_fIntComplete == BOOL_FALSE) &&
          (dwTimeoutValue) )
      {
         WaitBiosTicksSec18(1);
         dwTimeoutValue--;
      }
      if ( g_fIntComplete == BOOL_FALSE )
      {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("-> No interrupt occurred.");
#endif                                      // #ifdef _DEBUG
      }
      else
      {
  #ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("-> Interrupt occurred.");
  #endif                                      // #ifdef _DEBUG
      }
    }
    else
    {
       dwTimeoutValue = 0;                  // For total safe reason
    }
    *bStatus = mf_GetStatusATAPI();

    mf_OutputStatusATAPI(*bStatus);
    return (dwTimeoutValue);
}



//****************************************************************************
//               --- AtapiHardwareAccess::mf_WaitReadyDrive ---
//
// Purpose: Wait while drive will be ready
//   Input: DWORD dwTimeoutValue -  Timeout to wait
//  Output: DWORD                -  0     if drive not ready
//                                  Other if drive ready
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
DWORD  AtapiHardwareAccess::mf_WaitReadyDrive(DWORD dwTimeoutValue)
{
    tagATAPI_Stat_Reg_RD   bATAPI_Stat_Reg; // ATAPI status byte
    PBYTE    bStatus = (PBYTE)&bATAPI_Stat_Reg; // ATAPI status byte (pointer)

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Wait before drive will be ready ---");
#endif                                      // #ifdef _DEBUG

    do
    {
        *bStatus = mf_GetStatusATAPI();
    }  while ( (bATAPI_Stat_Reg.BSY)   &&
               (!bATAPI_Stat_Reg.DRDY) &&
               (--dwTimeoutValue) );

    mf_OutputStatusATAPI(*bStatus);
    return (dwTimeoutValue);
}



//****************************************************************************
//             --- AtapiHardwareAccess::mf_SendPacketCommand ---
//
// Purpose: Send ATAPI packet command to drive
//   Input: ATAPI_CDROM_Std_Cmd_Pkt *pBuf -  Command packet buffer (fixed length)
//  Output: BOOLEAN                       -  FALSE if command not sent
//                                           TRUE  if command was sent
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
BOOLEAN  AtapiHardwareAccess::mf_SendPacketCommand(ATAPI_CDROM_Std_Cmd_Pkt *pBuf)
{
    DWORD    dwTimeout;                     // Timeout value
    WORD     wCount = sizeof(ATAPI_CDROM_Std_Cmd_Pkt)/2; // Fixed command packet size
    PWORD    pwDataBuf = (PWORD)pBuf;       // Buffer pointer
    BOOLEAN  fExitCode = BOOL_FALSE;        // Exit code
    struct  ATAPI_CDROM_Std_Cmd_Pkt  ATAPI_Cmd_Pkt_Std;
                                            // Command packet buffer

//--------------------- Send ATAPI packet command request ---------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF(">>>Send ATAPI Packet command<<<");
#endif                                      // #ifdef _DEBUG
    mf_SendCmdByteATA(bATAPI_cmd_Pkt_Command);

//------------------------- Wait while drive is busy -------------------------

    mf_EmulateDelay(g_wWaitCmd);            // Some delay before go further

    dwTimeout = g_dwTimeoutDef;
    if  ( !mf_WaitBusyDrive(dwTimeout) )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("-> Drive in busy state, exit after timeout expiration.");
#endif                                      // #ifdef _DEBUG
        goto Terminate;
    }

//--------------- Wait data request to transfer command packet ---------------

    dwTimeout = g_dwTimeoutDef;
    if ( !mf_WaitDriveDRQ(dwTimeout) )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("-> No DRQ set, exit after timeout expiration.");
#endif                                      // #ifdef _DEBUG
        goto Terminate;
    }

//----------------------- Command bytes transfer phase -----------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Send ATAPI Packet command bytes---");
#endif                                      // #ifdef _DEBUG

    while (wCount--)
    {
        mf_WriteDataReg(*pwDataBuf++);
    }
    fExitCode = BOOL_TRUE;

//----------------------- Terminate function ---------------------------------
Terminate:
    return  (fExitCode);
}



//****************************************************************************
//         --- AtapiHardwareAccess::mf_TransferDataFromDrive ---
//
// Purpose: Transfer information/other data from drive
//   Input: PBYTE  pInBuf       -  Storage buffer
//          WORD   wBufLen      -  Storage buffer size
//          WORD   wInDataCount -  Bytes count to transfer
//                                 if 0 then read transfer count from drive
//  Output: BOOLEAN             -  FALSE if transfer failed
//                                 TRUE  if transfer complete
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
WORD  AtapiHardwareAccess::mf_TransferDataFromDrive(PBYTE pInBuf,
                            WORD wBufLen,
                            WORD wInDataCount)
{
    tagATAPI_Stat_Reg_RD   bATAPI_Stat_Reg; // ATAPI status byte
    PBYTE    bStatus = (PBYTE)&bATAPI_Stat_Reg; // ATAPI status byte (pointer)
    DWORD    dwTimeout;                     // Timeout value
    DWORD    dwWaitFuncRes;                 // Function result
    WORD     wTotalXfrCount = 0;            // Total bytes transferred
    WORD     wByteCount;                    // Bytes count during one request
    WORD     wWordCount;                    // Words count during one request

//-------------------------- Check input parameters --------------------------

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Transfer information data from device---");
#endif                                      // #ifdef _DEBUG

    if ( (!wBufLen) || (pInBuf == NULL) )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("-> Too small incoming buffer.");
#endif                                      // #ifdef _DEBUG
        goto Terminate;
    }

//------------------------ Beginning of data transfer ------------------------

RepeatAgain:                                // Repeat all steps again

//--------------------------- Wait while drive busy ---------------------------

    dwTimeout = g_dwTimeoutDef;
    if (!mf_WaitBusyDrive(dwTimeout))
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("-> Drive is busy, timeout expired.");
#endif                                      // #ifdef _DEBUG
        wTotalXfrCount = 0;
        goto Terminate;
    }

//----------------------- Wait data request from drive -----------------------

    dwTimeout = g_dwTimeoutDef;
    dwWaitFuncRes = mf_WaitDriveDRQ(dwTimeout);

    if ( !dwWaitFuncRes )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("-> No DRQ set, exit after timeout expiration.");
#endif                                      // #ifdef _DEBUG
        wTotalXfrCount = 0;
        goto Terminate;
    }

//--------------------- Determine bytes count to transfer ---------------------

    if  (wInDataCount)
        wByteCount = wInDataCount;           // Use specifed number
    else
        wByteCount = mf_GetTransferCount();  // Get number from drive
    wTotalXfrCount += wByteCount;            // Update total counter
    wWordCount      = wByteCount / 2;
#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputMessage("Transfer bytes count = ");
        OutputWordLF(wByteCount);
    }
#endif                                      // #ifdef _DEBUG

    while (wWordCount)
    {
        WORD  wTemp = mf_ReadDataWord();    // Temporary storage
        wWordCount--;
        if (wBufLen)                        // Check buffer for overflow
        {
            wBufLen--;
            *pInBuf++ = (BYTE)(wTemp & 0x00FF); // Store a low byte
            if (wBufLen)
            {
                wBufLen--;
                *pInBuf++ = (BYTE)(wTemp >> 8); // Store a high byte
            }
        }
    }
    if (wByteCount & 1)                      // Check for odd number
    {
        BYTE bTempOdd = (BYTE)mf_ReadDataByte(); // Read odd byte (actual last)
        if (wBufLen)                        // Check buffer for overflow
        {
            wBufLen--;
            *pInBuf++ = bTempOdd;
        }
    }

//--------------------- Check maybe we need another phase ---------------------

    dwTimeout = g_dwTimeoutDef;
    mf_WaitBusyDrive(dwTimeout);            // Wait a some time

    *bStatus = mf_GetStatusATAPI();         // Test or reset DRQ!
    mf_OutputStatusATAPI(*bStatus);

//------------------------ Check termination condition ------------------------

    if ( (bATAPI_Stat_Reg.DRQ) && (wByteCount) )
        goto RepeatAgain;

//------------------------------- Output status -------------------------------

    mf_OutputStatusATAPI( mf_GetStatusATAPI() ); // Check good state
    mf_OutputErrorATAPI( mf_GetErrorATAPI() );
#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputMessage("Transfer complete, total bytes = ");
        OutputWordLF(wTotalXfrCount);
    }
#endif                                      // #ifdef _DEBUG
Terminate:
    return (wTotalXfrCount);
}
