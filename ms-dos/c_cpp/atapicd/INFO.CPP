//****************************************************************************
//                              File INFO.CPP
//
//              Drive Information output functions
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BC31/SOURCE/ATAPICD/RCS/info.cpp $
//  $RCSfile: info.cpp $
//   $Author: dstef $
//     $Date: 1999/01/02 01:19:41 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: info.cpp $
//      Revision 1.1  1999/01/02 01:19:41  dstef
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

#include  "compile.hpp"
#include  "atapicd.hpp"
#include  "cdrom.hpp"
#include  "fproto.hpp"
#include  "extern.hpp"
#include  "atapi.hpp"



//---------------------------Compilation Information--------------------------
static  char    rcsid[]  =  "$Id: info.cpp 1.1 1999/01/02 01:19:41 dstef Exp dstef $";         // RCS marker



//****************************************************************************
//            --- AtapiHardwareAccess::mf_OutputIdentifyData ---
//
// Purpose: Output identify data in readable human format
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  AtapiHardwareAccess::mf_OutputIdentifyData()
{
    WORD    wTransferMode;                  // Transfer mode value
    WORD    wDmaXfrMode;                    // DMA Transfer mode value
    WORD    wPioXfrMode;                    // PIO Transfer mode value
    WORD    wModeIndex;                     // Index to mode scanning
    WORD    wVersion;                       // Version of standard
    WORD    wTimeValue;                     // Time value to release bus
    struct  GeneralConfigFlags   *wGeneralConfig;
    struct  CapabilitiesFlags    *wCapableFlags;
    struct  ValidityFlags_53     *wValidFlags_53;
#if 0
    struct  SingleDMA_Flags_62   *wSingleWordDmaModes;
    struct  MultiDMA_Flags_63    *wMultiWordDmaModes;
    struct  Adv_PIO_Modes_Flags  *AdvancedPioModesFlags;
#endif
//---------------------- Is this device ATAPI-compatible ----------------------
#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Display identify data received from device---");
#endif                                      // #ifdef _DEBUG
    if  (mf_GetIdentifyATAPI() == BOOL_FALSE)
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
        return;
    }

//------------------------------- Output banner -------------------------------

    OutputMessageLF("************************* Identify Device Data *********************");

//---------------------------- General Information ----------------------------

    OutputMessage("Model number....................... ");
    if (g_fModelOutFmt)
        OutputFieldFmtASCII((char*)&m_IdentifyData.chModelNumber[0],sizeof(m_IdentifyData.chModelNumber));
    else
        OutputFieldasASCII((char*)&m_IdentifyData.chModelNumber[0],sizeof(m_IdentifyData.chModelNumber));
    OutputMessage("Serial number...................... ");
    OutputFieldasASCII((char*)&m_IdentifyData.chSerialNumber[0],sizeof(m_IdentifyData.chSerialNumber));
    OutputMessage("Firmware revision.................. ");
    OutputFieldasASCII((char*)&m_IdentifyData.chFirmwareRevision[0],sizeof(m_IdentifyData.chFirmwareRevision));

//--------------------- General configuration for device ---------------------

    wGeneralConfig = (GeneralConfigFlags*)&m_IdentifyData.wGeneralConfiguration;

    OutputMessage("Peripheral device type ............ ");
    OutputDeviceType(wGeneralConfig->DEVICE_TYPE);

    OutputMessage("Removable device................... ");
    OutputBoolean(wGeneralConfig->REMOVABLE_DEV,BOOL_TRUE);

    OutputMessage("Protocol type for device........... ");

    switch (wGeneralConfig->PROTOCOL_TYPE)
    {

        case  wProtType_ATA_0:
        case  wProtType_ATA_1:
                OutputMessageLF("ATA");
                break;

        case  wProtType_ATAPI:
                OutputMessageLF("ATAPI");
                break;

        case  wProtType_Reserved:
                OutputMessageLF("reserved");
        break;

        default:
                break;

    }

    OutputMessage("Command packet size................ ");

    switch (wGeneralConfig->CMD_PKT_SIZE)
    {

        case  wCmd_Pkt_Size_CDROM:
                OutputMessageLF("12 bytes");
                break;

        case  wCmd_Pkt_Size_SAM:
                OutputMessageLF("16 bytes");
                break;

    case  wCmd_Pkt_Size_Reserved_2:
        case  wCmd_Pkt_Size_Reserved_3:
                OutputMessageLF("reserved");
                break;

        default:
                break;

    }

    OutputMessage("Command packet DRQ type ........... ");

    switch (wGeneralConfig->CMD_DRQ_TYPE)
    {

        case wCmd_DRQ_Type_MicroProccessor_DRQ:
                OutputMessageLF("microprocessor (slow=3ms)");
                break;

        case wCmd_DRQ_Type_Interrupt_DRQ:
                OutputMessageLF("interrupt (fast=10ms)");
                break;

        case wCmd_DRQ_Type_Accelerated_DRQ:
                OutputMessageLF("accelerated (fastest=50us)");
                break;

        case wCmd_DRQ_Type_Reserved:
                OutputMessageLF("reserved");
                break;

        default:
                break;

    }

//----------------------------- Capabilites Flags -----------------------------

    wCapableFlags = (CapabilitiesFlags*)&m_IdentifyData.wCapabilities;

    OutputMessage("DMA supported...................... ");
    OutputBoolean(wCapableFlags->DMA_SUP,BOOL_TRUE);

    OutputMessage("LBA supported...................... ");
    OutputBoolean(wCapableFlags->LBA_SUP,BOOL_TRUE);

    OutputMessage("Disabling of IORDY supported....... ");
    OutputBoolean(wCapableFlags->IORDY_CAN_DIS,BOOL_TRUE);

    OutputMessage("IORDY supported.................... ");
    OutputBoolean(wCapableFlags->IORDY_SUP,BOOL_TRUE);

    OutputMessage("Overlap operation supported........ ");
    OutputBoolean(wCapableFlags->OVLAP_SUP,BOOL_TRUE);

//---------------------------- PIO data transfer modes -----------------------

    wTransferMode = m_IdentifyData.wPIO_Cycle_Timing >> 8;
    OutputMessage("PIO transfer cycle timing.......... ");
    if ( wTransferMode <= wPIO_Mode_4 )
        OutputModePIO(NULL,wTransferMode);
    else
    {
        OutputMessage("mode ");
        OutputByteLF( (BYTE)wTransferMode );
    }

//---------------------------- DMA transfer modes ----------------------------

    wTransferMode = m_IdentifyData.wDMA_Cycle_Timing >> 8;
    OutputMessage("SingleWord DMA transfer............ ");
    if ( wTransferMode <= wSW_DMA_Mode_2 )
    {
        OutputModeSingleWordDMA(NULL,wTransferMode);
    }
    else
    {
        OutputMessage("mode ");
        OutputByteLF( (BYTE)wTransferMode );
    }

    wValidFlags_53 = (ValidityFlags_53*)&m_IdentifyData.wValidity_53;
#if 0
    wSingleWordDmaModes = (SingleDMA_Flags_62*)&m_IdentifyData.wSingleDMA_Modes;
#endif
    wDmaXfrMode = m_IdentifyData.wSingleDMA_Modes & 0x00FF;
    for (wModeIndex=0; wModeIndex<=7; wModeIndex++)
        if ( wDmaXfrMode & (1 << wModeIndex) )
        {
            OutputModeSingleWordDMA("Support SingleWord DMA transfer.... ",
                                    wModeIndex);
        }

    wDmaXfrMode = m_IdentifyData.wSingleDMA_Modes >> 8;
    for (wModeIndex=0; wModeIndex<=7; wModeIndex++)
        if ( wDmaXfrMode & (1 << wModeIndex) )
        {
            OutputModeSingleWordDMA("Active SingleWord DMA transfer..... ",
                                    wModeIndex);
        }
#if 0
    wMultiWordDmaModes = (MultiDMA_Flags_63*)&m_IdentifyData.wMultiDMA_Modes;
#endif
    wDmaXfrMode = m_IdentifyData.wMultiDMA_Modes & 0x00FF;
    for (wModeIndex=0; wModeIndex<=7; wModeIndex++)
        if ( wDmaXfrMode & (1 << wModeIndex) )
        {
            OutputModeMultiWordDMA("Support MultiWord DMA transfer..... ",
                                   wModeIndex);
        }

    wDmaXfrMode = m_IdentifyData.wMultiDMA_Modes >> 8;
    for (wModeIndex=0; wModeIndex<=7; wModeIndex++)
        if ( wDmaXfrMode & (1 << wModeIndex) )
        {
            OutputModeMultiWordDMA("Active MultiWord DMA transfer...... ",
                                   wModeIndex);
        }

    if (wValidFlags_53->VALID_FLAGS_54_58)
    {
        // not implemented for ATAPI
    }

//-------------------------- Advanced PIO/DMA modes --------------------------

    if (wValidFlags_53->VALID_FLAGS_64_70)
    {
#if 0
        AdvancedPioModesFlags = (Adv_PIO_Modes_Flags*)&m_IdentifyData.wAdv_PIO_Modes;
#endif
        wPioXfrMode = m_IdentifyData.wAdv_PIO_Modes;
        for (wModeIndex=0; wModeIndex<=7; wModeIndex++)
            if ( wPioXfrMode & (1 << wModeIndex) )
            {
                OutputModePIO("Enhanced PIO transfer modes........ ",
                              wModeIndex+3);
            }

        OutputTransferTime("Min MultiWord DMA xfr cycle........ ",
                            m_IdentifyData.wMin_Mult_DMA_Xfr_Cycle_Time_Per_Word);

    OutputTransferTime("Manuf/rec MultiWord DMA xfr cycle.. ",
                       m_IdentifyData.wManuf_Mult_DMA_Xfr_Time);

        OutputTransferTime("Min PIO transfer w/o Flow Control.. ",
                           m_IdentifyData.wMin_PIO_Xfr_Cycle_Time_No_Flow_Ctrl);

        OutputTransferTime("Min PIO xfr w/IORDY Flow Control... ",
                           m_IdentifyData.wMin_PIO_Xfr_Cycle_Time_IORDY_Flow_Ctrl);
    }

//-------------- Timing for release bus / overlapped operations --------------

    wTimeValue = m_IdentifyData.wTypTimeToReleaseAfterCmdReceived;
    if ( wTimeValue != 0 )
    {
        OutputTransferTime("Exp. time to release (cmd rcvd).... ",
                           wTimeValue);
    }

    wTimeValue = m_IdentifyData.wTypTimeToReleaseAfterServiceCmd;
    if ( wTimeValue != 0 )
    {
        OutputMessage("Exp. time to release (srvc cmd).... ");
        OutputWord(wTimeValue);
        OutputMessage(" us ");
        OutputMessage(g_chEOLN);
    }

//-------------------- Version of supported ATAPI standard --------------------

    wVersion = m_IdentifyData.wMajorVersionNumber;
    if ( (wVersion != 0) && (wVersion != 0xFFFF) )
    {
        OutputMessage("Major version number (std)......... ");
        OutputWordLF(wVersion >> 1);
    }

    wVersion = m_IdentifyData.wMinorVersionNumber;
    if ( (wVersion != 0) && (wVersion != 0xFFFF) )
    {
        OutputMessage("Minor version number (std)......... ");
        OutputWordLF(wVersion);
    }
}



//****************************************************************************
//             --- AtapiHardwareAccess::mf_OutputInquiryData ---
//
// Purpose: Output inquiry data in readable human format
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  AtapiHardwareAccess::mf_OutputInquiryData()
{
    BYTE     bRetryCount  =  g_bRetryNumber;// Number of attempts
    struct  ATAPI_Inquiry_Flags_Dev  *InquiryFlagsStd_Dev;
    struct  ATAPI_Inquiry_Flags_Ver  *InquiryFlagsStd_Ver;

//------------ Execute a software reset for ATAPI device/controller -----------

    if (g_fInquiryReset)
    {
        mf_SoftResetATAPI();                // Use only for strange ATAPI controllers
        WaitBiosTicksSec18(6*18);           // Some delay before go further
    }

//--------------------- Check for ATAPI-compatible device ---------------------
#ifdef _DEBUG
    if (g_fDebug)
    OutputMessageLF("---Display inquiry data (std) received from device---");
#endif                                      // #ifdef _DEBUG
    while ( mf_GetInquiryData() == BOOL_FALSE )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
        if (! (bRetryCount--) )             // Some drives don't respond at first time
            return;
        WaitBiosTicksSec18(3);              // Wait some time
    }

// Check for extended data

    if ( (m_InquiryDataStd.bAddionalLength+4) == sizeof(ATAPI_Inquiry_Data_Ext_In) )
    {
        m_fInquiryDataExt = mf_GetInquiryDataExt();
    }

//------------------------------- Output banner -------------------------------

    OutputMessageLF("************************ Inquiry Device Data ***********************");

//---------------------------- Device type/meduim ----------------------------

    InquiryFlagsStd_Dev = (ATAPI_Inquiry_Flags_Dev*)&m_InquiryDataStd.bDevType;

    OutputMessage("Peripheral device type ............ ");
    OutputDeviceType(InquiryFlagsStd_Dev->PERIPHERAL_DEV_TYPE);

    OutputMessage("Removable medium................... ");
    OutputBoolean(InquiryFlagsStd_Dev->RMB,BOOL_TRUE);

//-------------------------- Vendor and its product --------------------------

    OutputMessage("Vendor identification.............. ");
    OutputFieldFmtASCII(m_InquiryDataStd.chVendorIdentification,
                        sizeof(m_InquiryDataStd.chVendorIdentification));
    OutputMessage("Product identification............. ");
    OutputFieldFmtASCII(m_InquiryDataStd.chProductIdentification,
                        sizeof(m_InquiryDataStd.chProductIdentification));
    OutputMessage("Product revision level............. ");
    OutputFieldFmtASCII(m_InquiryDataStd.chProductRevisionLevel,
                        sizeof(m_InquiryDataStd.chProductRevisionLevel));

    InquiryFlagsStd_Ver = (ATAPI_Inquiry_Flags_Ver*)&m_InquiryDataStd.bVersion;

//---------------------------- Supported standards ----------------------------

    OutputMessage("ANSI version....................... ");
    OutputByteLF( (BYTE)InquiryFlagsStd_Ver->ANSI );

    OutputMessage("ECMA version....................... ");
    OutputByteLF( (BYTE)InquiryFlagsStd_Ver->ECMA );

    OutputMessage("ISO version........................ ");
    OutputByteLF( (BYTE)InquiryFlagsStd_Ver->ISO );

    m_bATAPI_Version = (BYTE)InquiryFlagsStd_Ver->ATAPI;
    OutputMessage("ATAPI version...................... ");
    OutputByteLF(m_bATAPI_Version);

    OutputMessage("Response data format............... ");
    OutputByteLF( (BYTE)InquiryFlagsStd_Ver->RESP_DAT_FMT );

//--------------------- Additional parameters --------------------------------

    OutputMessage("Additional length (param bytes).... ");
    OutputByteLF(m_InquiryDataStd.bAddionalLength);

    if (m_fInquiryDataExt)
    {
        OutputMessage("Vendor-specific data............... ");
        OutputFieldFmtASCII(m_InquiryDataExt.bVendorSpecific,
                            sizeof(m_InquiryDataExt.bVendorSpecific));
    }
}



//****************************************************************************
//            --- AtapiHardwareAccess::mf_OutputModePagesData ---
//
// Purpose: Output mode pages data in readable human format
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  AtapiHardwareAccess::mf_OutputModePagesData()
{
    ModeParameterListHeader *    ModeParametersHdr; // Mode Parameter Header (ptr)
    ModePageFormatHeader*    ModePageHdr;   // Mode Page Header (ptr)
    PBYTE    pCurPageModeBuf;               // Current byte in buffer (ptr)
    WORD     wTotalBufSize;                 // Size
    BYTE     bTemp;                         // Temporary
    BYTE     bPageCode;                     // Page Code
    BYTE     bRetryCount = g_bRetryNumber;  // Number of attempts
    BYTE     bModePageControl;              // Mode Page Control

//-------------------- Select mode page control value -------------------------

    if ( g_fCurMPage == BOOL_TRUE )
      bModePageControl = bCurrentValuesPC;
    else
      bModePageControl = bDefaultValuesPC;

//------------ Execute a software reset for ATAPI device/controller -----------

    if (g_fModeSenseReset)
    {
        mf_SoftResetATAPI();                // Use only for strange ATAPI controllers
        WaitBiosTicksSec18(6*18);           // Some delay before go further
    }

//--------------------- Check for ATAPI compatible device ---------------------
#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Display mode pages data received from device---");
#endif                                      // #ifdef _DEBUG
    while ( mf_GetAllModePagesData(bModePageControl) == BOOL_FALSE )
    {
#ifdef _DEBUG
        if (g_fDebug)
            OutputWarnNonAtapiDev();
#endif                                      // #ifdef _DEBUG
        if (! (bRetryCount--) )             // Some drives don't respond at first time
            return;
        WaitBiosTicksSec18(3);              // Wait some time
    }

//------------------------------- Output banner -------------------------------

    OutputMessageLF("************************ Inquiry Device Mode Pages Data ************");

//----------------------- Mode parameter list info ---------------------------

    ModeParametersHdr = (ModeParameterListHeader * )m_pbAllModePagesBuf;
    pCurPageModeBuf = (PBYTE)ModeParametersHdr;

    wTotalBufSize = (ModeParametersHdr->bModeDataLenLSB) +
                    (ModeParametersHdr->bModeDataLenMSB << 8);
#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputMessage("Mode parameter list bytes = ");
        OutputWordLF(wTotalBufSize);
    }
#endif                                      // #ifdef _DEBUG
    OutputMessage("Medium type code = ");
    OutputMediumType(ModeParametersHdr->bMeduimType);

//------------------------ Scan all getting mode pages ------------------------

    wTotalBufSize -= sizeof(ModeParameterListHeader);
    wTotalBufSize += 2;                     // Add header size (2 bytes)
    pCurPageModeBuf += sizeof(ModeParameterListHeader);
#ifdef _DEBUG
    if (g_fDebug)
    {
        OutputMessage("Mode pages list bytes = ");
        OutputWordLF(wTotalBufSize);
    }
#endif                                      // #ifdef _DEBUG
    while (wTotalBufSize)
    {
//---------------------------- Construct new mode page -----------------------

        ModePageHdr = (ModePageFormatHeader*)pCurPageModeBuf;
        bPageCode = ModePageHdr->PageCodePS.PAGE_CODE;
        bTemp = ModePageHdr->PageLength;
#ifdef _DEBUG
        if (g_fDebug)
        {
            OutputMessage("Code page = ");
            OutputHexWord(bPageCode, g_fAddHexPrefix, g_fAddNewLine);
            OutputMessage("Mode page length (bytes) = ");
            OutputByteLF(bTemp);
        }
#endif                                      // #ifdef _DEBUG

//--------------------------- Check for bad values ---------------------------

    if ( (!bPageCode) || (!bTemp) ||
         (bPageCode == 0xFF) || (bTemp == 0xFF) )
        {
#ifdef _DEBUG
            if (g_fDebug)
                OutputMessageLF("!!! Bad page code parameters found.");
#endif                                      // #ifdef _DEBUG

            break;
        }

//---------- Output information about mode page if match page found ----------

        switch (bPageCode)
        {

            case    bReadErrRecoveryMPC:
                mf_OutputErrorRecoveryPage( (pReadErrorRecoveryPage)pCurPageModeBuf );
                break;

            case    bCDROM_MPC:
                mf_OutputDeviceParamsPage( (pDeviceParametersPage)pCurPageModeBuf );
                break;

            case    bCDROM_AudioCtrl_MPC:
                mf_OutputAudioControlPage( (pAudioCtrlPage)pCurPageModeBuf );
                break;

            case    bCDROM_Capable_MechStat_MPC:
                mf_OutputCapabilitiesPage( (pCapabilitiesPage)pCurPageModeBuf );
                break;

            default:
#ifdef _DEBUG
                if (g_fDebug)
                    OutputMessageLF("!! This page skipped because unknown format.");
#endif                                      // #ifdef _DEBUG
                break;

        }
//--------------------------- Advance to next mode page ----------------------

        bTemp           += sizeof(ModePageFormatHeader);
        pCurPageModeBuf += bTemp;
        wTotalBufSize   -= bTemp;
    }
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_OutputCapabilitiesPage ---
//
// Purpose: Output CD-ROM drive capabilities page in readable human format
//   Input: pCapabilitiesPage pPageBuf - Pointer to capabilities page buffer
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  AtapiHardwareAccess::mf_OutputCapabilitiesPage(pCapabilitiesPage pPageBuf)
{
    WORD    wTemp;                          // Temporary
    BYTE    bBitValue;                      // Temporary storage

//------------------------------- Output banner -------------------------------

    OutputMessageLF("********** CD-ROM Capabilities and Mechanical Status Page Data **********");

    bBitValue = pPageBuf->PageHdr.PageCodePS.PS;
    OutputPageSaveableStatus(bBitValue);

//-------------------------- General characteristics --------------------------

    OutputMessageLF("---General characterisctics---");

    wTemp = (pPageBuf->bDriveBufferSizeLSB) +
            ( (pPageBuf->bDriveBufferSizeMSB) << 8 );
    OutputMessage("Drive Buffer Size (KB)................. ");
    OutputWordLF(wTemp);

    wTemp = (pPageBuf->bMaxSpeedLSB) +
            ( (pPageBuf->bMaxSpeedMSB) << 8 );
    OutputMessage("Maximum Drive Speed (KBytes/second).... ");
    OutputWord(wTemp);
    OutputSpeedX(wTemp,wSpeedMPC);
    OutputMessage("Maximum Drive Speed (KBytes/second).... ");
    OutputWord(wTemp);
    OutputSpeedX(wTemp,wSpeedX1);

    wTemp = (pPageBuf->bCurSpeedLSB) +
            ( (pPageBuf->bCurSpeedMSB) << 8 );
    OutputMessage("Current Drive Speed (KBytes/second).... ");
    OutputWord(wTemp);
    OutputSpeedX(wTemp,wSpeedMPC);
    OutputMessage("Current Drive Speed (KBytes/second).... ");
    OutputWord(wTemp);
    OutputSpeedX(wTemp,wSpeedX1);

    OutputMessage("Number of discrete volume levels....... ");
    OutputByteLF(pPageBuf->bVolumeLevelsNumber);

//------------------------ Media Function Capabilities ------------------------

    if  (m_bATAPI_Version > 1)                 // only std 2.0+
    {
        OutputMessageLF("---Media function capability bits---");

        OutputMessage("CD-R disc read function (Orange Book Part II)...... ");
        OutputBoolean(pPageBuf->wMediaFunction.CD_R_RD,BOOL_TRUE);

        OutputMessage("CD-E disc read function (Orange Book Part III)..... ");
        OutputBoolean(pPageBuf->wMediaFunction.CD_E_RD,BOOL_TRUE);

        OutputMessage("Read function of CD-Rs written with addr.method 2.. ");
        OutputBoolean(pPageBuf->wMediaFunction.METHOD_2,BOOL_TRUE);

        OutputMessage("CD-R disc write function (Orange Book Part II)..... ");
        OutputBoolean(pPageBuf->wMediaFunction.CD_R_WR,BOOL_TRUE);

        OutputMessage("CD-E disc write function (Orange Book Part III).... ");
        OutputBoolean(pPageBuf->wMediaFunction.CD_E_WR,BOOL_TRUE);
    }

//------------------------------ Capability Bits ------------------------------

    OutputMessageLF("---Drive's capability bits---");

//----------------------------- Audio/Video Data -----------------------------

    OutputMessage("Audio play/overlap operation supported............. ");
    OutputBoolean(pPageBuf->wCapabilityLow.AUDIO_PLAY,BOOL_TRUE);

    if  (m_bATAPI_Version > 1)               // only std 2.0+
        OutputMessage("Deliver composite audio and video data stream...... ");
    else
        OutputMessage("All CD-ROM XA commands supported................... ");
    OutputBoolean(pPageBuf->wCapabilityLow.COMPOSITE,BOOL_TRUE);

    if  (m_bATAPI_Version > 1)               // only std 2.0+
    {
        OutputMessage("Supports digital output (IEC958) on port 1......... ");
        OutputBoolean(pPageBuf->wCapabilityLow.DIGITAL_PORT_1,BOOL_TRUE);

        OutputMessage("Supports digital output (IEC958) on port 2......... ");
        OutputBoolean(pPageBuf->wCapabilityLow.DIGITAL_PORT_2,BOOL_TRUE);
    }

//------------------------------- Disc Formats -------------------------------

    OutputMessage("Read sectors in Mode 2 Form 1 (XA) format.......... ");
    OutputBoolean(pPageBuf->wCapabilityLow.MODE_2_FORM_1,BOOL_TRUE);

    OutputMessage("Read sectors in Mode 2 Form 2 format............... ");
    OutputBoolean(pPageBuf->wCapabilityLow.MODE_2_FORM_2,BOOL_TRUE);

    OutputMessage("Read multiple session of Photo-CD dics............. ");
    OutputBoolean(pPageBuf->wCapabilityLow.MULTI_SESSION,BOOL_TRUE);

    OutputMessage("Red Book audio can be read using READ-CD command... ");
    OutputBoolean(pPageBuf->wCapabilityLow.CD_DA_CMDS,BOOL_TRUE);

    OutputMessage("CD-DA stream is accurate (recover w/o failure)..... ");
    OutputBoolean(pPageBuf->wCapabilityLow.CD_DA_STREAM_IS_ACCURATE,BOOL_TRUE);

//---------------------------- Sub-channel support ----------------------------

    OutputMessage("Sub-channel data can have combined R-W info........ ");
    OutputBoolean(pPageBuf->wCapabilityLow.R_W_SUPPORT,BOOL_TRUE);

    OutputMessage("R-W SubCh data de-interleaved & error corrected.... ");
    OutputBoolean(pPageBuf->wCapabilityLow.R_W_INTLVD_CORR,BOOL_TRUE);

    OutputMessage("C2 Error Pointers/C2 Blocks Error Flags support.... ");
    OutputBoolean(pPageBuf->wCapabilityLow.C2_POINTERS_SUPPORT,BOOL_TRUE);

//------------------------------ Recording codes ------------------------------

    OutputMessage("International Standard Recording Code Information.. ");
    OutputBoolean(pPageBuf->wCapabilityLow.ISRC,BOOL_TRUE);

    OutputMessage("Media Catalog Number............................... ");
    OutputBoolean(pPageBuf->wCapabilityLow.UPC,BOOL_TRUE);

//---------------------------- Lock/Unlock support ----------------------------

    OutputMessage("Software commands really lock media into drive..... ");
    OutputBoolean(pPageBuf->wCapabilityHigh.LOCK,BOOL_TRUE);

    OutputMessage("Drive is currently in prevented(locked) state...... ");
    OutputBoolean(pPageBuf->wCapabilityHigh.LOCK_STATE,BOOL_TRUE);

    OutputMessage("Prevent/Allow jumper present (optional)............ ");
    OutputBoolean(pPageBuf->wCapabilityHigh.PREVENT_JUMPER,BOOL_TRUE);

//----------------------------- Load/unload media -----------------------------

    OutputMessage("Drive can eject disc using software command........ ");
    OutputBoolean(pPageBuf->wCapabilityHigh.EJECT_CMD,BOOL_TRUE);

    OutputMessage("Drive has ");

    switch (pPageBuf->wCapabilityHigh.LOAD_MECH_TYPE)
    {

        case 0:
                 OutputMessageLF("caddy type loading mechanism.");
                 break;

        case 1:
                 OutputMessageLF("tray type loading mechanism.");
                 break;

        case 2:
                 OutputMessageLF("pop-up type loading mechanism.");
                 break;

        case 4:
                 OutputMessageLF("changer with individually changeable discs.");
                 break;

        case 6:
                 OutputMessageLF("changer using a cartrigde mechanism.");
                 break;

        default:
                 OutputMessageLF("unknown loading mechanism type.");
                 break;

    }

//------------------------------- Miscellaneous -------------------------------

    OutputMessage("Audio level of channel has independent control..... ");
    OutputBoolean(pPageBuf->wCapabilityHigh.SEPARATE_VOL_LEVEL,BOOL_TRUE);

    OutputMessage("Mute of each channel has independent control....... ");
    OutputBoolean(pPageBuf->wCapabilityHigh.SEPARATE_CHANNEL_MUTE,BOOL_TRUE);

    if  (m_bATAPI_Version > 1)               // only std 2.0+
    {
        OutputMessage("Device contains an embedded changer................ ");
        OutputBoolean(pPageBuf->wCapabilityHigh.SDP,BOOL_TRUE);

        OutputMessage("Software slot selection (LOAD/UNLOAD cmd).......... ");
        OutputBoolean(pPageBuf->wCapabilityHigh.SSS,BOOL_TRUE);
    }

//------------------------------ Digital Output ------------------------------

    if  (m_bATAPI_Version > 1)               // only std 2.0+
    {
        OutputMessageLF("---Drive's digital output---");

        OutputMessage("Data valid on ");
        if (pPageBuf->bDigOutFlags.BCKF)
            OutputMessage("falling");
        else
            OutputMessage("rising");
        OutputMessageLF(" edge of the BCK signal");

        if (pPageBuf->bDigOutFlags.RCH)
            OutputMessage("Right");
        else
            OutputMessage("Left");
        OutputMessageLF(" channel data come first");

        if (pPageBuf->bDigOutFlags.LSBF)
            OutputMessage("LSB");
        else
            OutputMessage("MSB");
        OutputMessageLF(" comes first");

        OutputMessage("Length is ");

        switch  (pPageBuf->bDigOutFlags.LENGTH)
        {

            case  0:
                     OutputMessageLF("32 BCKs");
                     break;

            case  1:
                     OutputMessageLF("16 BCKs");
                     break;

            case  2:
                     OutputMessageLF("24 BCKs");
                     break;

            case  3:
                     OutputMessageLF("24 BCKs (I**2 S)");
                     break;

            default:
                     break;

        }

    }
}



//****************************************************************************
//           --- AtapiHardwareAccess::mf_OutputAudioControlPage ---
//
// Purpose: Output CD-ROM audio control page in readable human format
//   Input: pAudioCtrlPage pPageBuf -  Pointer to audio control page buffer
//  Output: none
// Written: by Dmitry V.Stefankov 02-22-96
//****************************************************************************
void  AtapiHardwareAccess::mf_OutputAudioControlPage(pAudioCtrlPage pPageBuf)
{
    BYTE    bBitValue;                      // Temporary storage

//------------------------------- Output banner -------------------------------

    OutputMessageLF("********** CD-ROM Audio Control Page Data **********");

    bBitValue = pPageBuf->PageHdr.PageCodePS.PS;
    OutputPageSaveableStatus(bBitValue);

//---------------- Red book audio decoders and ADPCM decoders ----------------

    OutputMessageLF("---Red book audio decoders and ADPCM decoders---");

    OutputMessage("Support of completion status during playback....... ");
    OutputBoolean(pPageBuf->AudioFlags.IMMED,BOOL_TRUE);

    OutputMessage("Stop on track crossing during playback............. ");
    OutputBoolean(pPageBuf->AudioFlags.SOTC,BOOL_TRUE);

    OutputMessage("Logical block per second of playback............... ");
    OutputWordLF(pPageBuf->wLogBlkPerSecAudioPlayback);

//----------------------- Four Red book audio decoders -----------------------

    OutputMessageLF("---Four Red book audio decoders---");

    OutputMessage("Output Port 0 ");
    bBitValue = pPageBuf->CDDA_OutputPort_0.CDDA_OutputPort;
    OutputPortChannelSelect(bBitValue);

    OutputMessage("Output Port 0 volume (binary,attenuation level).... ");
    OutputPortVolume(pPageBuf->bOutputPort_0_Volume);

    OutputMessage("Output Port 1 ");
    bBitValue = pPageBuf->CDDA_OutputPort_1.CDDA_OutputPort;
    OutputPortChannelSelect(bBitValue);

    OutputMessage("Output Port 1 volume (binary,attenuation level).... ");
    OutputPortVolume(pPageBuf->bOutputPort_1_Volume);

    OutputMessage("Output Port 2 ");
    bBitValue = pPageBuf->CDDA_OutputPort_2.CDDA_OutputPort;
    OutputPortChannelSelect(bBitValue);

    OutputMessage("Output Port 2 volume (binary,attenuation level).... ");
    OutputPortVolume(pPageBuf->bOutputPort_2_Volume);

    OutputMessage("Output Port 3 ");
    bBitValue = pPageBuf->CDDA_OutputPort_3.CDDA_OutputPort;
    OutputPortChannelSelect(bBitValue);

    OutputMessage("Output Port 3 volume (binary,attenuation level).... ");
    OutputPortVolume(pPageBuf->bOutputPort_3_Volume);

//--------------------------- Stereo ADPCM decoders ---------------------------

}



//****************************************************************************
//           --- AtapiHardwareAccess::mf_OutputDeviceParamsPage ---
//
// Purpose: Output CD-ROM device parameters page in readable human format
//   Input: pDeviceParametersPage pPageBuf -  Pointer to audio control page buffer
//  Output: none
// Written: by Dmitry V.Stefankov 02-23-96
//****************************************************************************
void  AtapiHardwareAccess::mf_OutputDeviceParamsPage(pDeviceParametersPage pPageBuf)
{
    WORD    wTemp;                          // Temporary
    BYTE    bBitValue;                      // Temporary storage

//------------------------------- Output banner -------------------------------

    OutputMessageLF("********** CD-ROM Device Parameters Page Data **********");

    bBitValue = pPageBuf->PageHdr.PageCodePS.PS;
    OutputPageSaveableStatus(bBitValue);

//----------------------------- Device Parameters -----------------------------

    OutputMessageLF("---Device Parameters---");

    OutputMessage("Minimum time in hold track state................... ");
    bBitValue = pPageBuf->InActTimerMultValue.INACTMULTTIME;
    OutputHoldTrackTime(bBitValue);

    wTemp = pPageBuf->MSF_S_M_Unit_LSB + (pPageBuf->MSF_S_M_Unit_MSB << 8);
    OutputMessage("S units per MSF - M unit........................... ");
    OutputWord(wTemp);

    switch  (wTemp)
    {

        case  60:
                    OutputMessageLF(" (std value)");
                    break;

        default:
                    OutputMessageLF(" (no std value)");
                    break;

    }

    wTemp = pPageBuf->MSF_F_S_Unit_LSB + (pPageBuf->MSF_F_S_Unit_MSB << 8);
    OutputMessage("F units per MSF - S unit........................... ");
    OutputWord(wTemp);

    switch  (wTemp)
    {

        case  75:
                    OutputMessageLF(" (std value)");
                    break;

        default:
                    OutputMessageLF(" (no std value)");
                    break;

    }

}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_OutputErrorRecoveryPage ---
//
// Purpose: Output read error recovery parameters page in readable human format
//   Input: pReadErrorRecoveryPage pPageBuf -  Pointer to audio control page buffer
//  Output: none
// Written: by Dmitry V.Stefankov 02-23-96
//****************************************************************************
void  AtapiHardwareAccess::mf_OutputErrorRecoveryPage(pReadErrorRecoveryPage pPageBuf)
{
    BYTE   bBitValue;                       // Temporary storage

//------------------------------- Output banner -------------------------------

    OutputMessageLF("********** Read Error Recovery Parameters Page Data **********");

    bBitValue = pPageBuf->PageHdr.PageCodePS.PS;
    OutputPageSaveableStatus(bBitValue);

//----------------------------- Error Correction -----------------------------

    OutputMessageLF("---Error correction flags---");

    OutputMessage("Disable correction................................. ");
    OutputBoolean(pPageBuf->ReadErrorRecovery.ReadErrorFlags.DCR,BOOL_TRUE);

    OutputMessage("Disable transfer on error.......................... ");
    OutputBoolean(pPageBuf->ReadErrorRecovery.ReadErrorFlags.DTE,BOOL_TRUE);

    OutputMessage("Post error (reports recovered errors).............. ");
    OutputBoolean(pPageBuf->ReadErrorRecovery.ReadErrorFlags.PER,BOOL_TRUE);

    OutputMessage("Read continuous (w/o error recovery)............... ");
    OutputBoolean(pPageBuf->ReadErrorRecovery.ReadErrorFlags.RC,BOOL_TRUE);

    OutputMessage("Transfer block (not recovered within time limits).. ");
    OutputBoolean(pPageBuf->ReadErrorRecovery.ReadErrorFlags.TB,BOOL_TRUE);

    OutputMessage("Error recovery parameter........................... ");
    OutputByteLF(pPageBuf->ReadErrorRecovery.ErrorRecoveryParameter);

    OutputMessage("Read retry count (recovery algorithm calls)........ ");
    OutputByteLF(pPageBuf->ReadRetryCount);
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_OutputDriveInformation ---
//
// Purpose: Output information about drive state and capabilities
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  AtapiHardwareAccess::mf_OutputDriveInformation()
{
#if defined(_AUDIO)
    if  ( g_fAudioCmd == BOOL_TRUE )
    {
       mf_ExecAudioDriveCmd();              // Run requested command
    }
    else
#endif                                      // #if defined(_AUDIO)
#if defined(_ATA_CMDS)
    if  ( g_fAtaCmd == BOOL_TRUE )
    {
       mf_ExecAtaDriveCmd();                // Run requested command
    }
    else
#endif                                      // #if defined(_ATA_CMDS)
    {
       mf_OutputIdentifyData();             // Type 1 information
       WaitBiosTicksSec18(3);
       mf_OutputInquiryData();              // Type 2 information
       WaitBiosTicksSec18(3);
       mf_OutputModePagesData();            // Type 3 information
       WaitBiosTicksSec18(9);
    }
}
