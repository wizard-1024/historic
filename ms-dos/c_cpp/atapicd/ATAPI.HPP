//****************************************************************************
//                             File ATAPI.HPP
//
//                  ATAPI hardware class objects
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BC31/SOURCE/ATAPICD/RCS/atapi.hpp $
//  $RCSfile: atapi.hpp $
//   $Author: dstef $
//     $Date: 1999/01/02 00:22:27 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: atapi.hpp $
//      Revision 1.1  1999/01/02 00:22:27  dstef
//      Initial revision
//
//
//****************************************************************************



///////////////////////////////////////////////////////////////////////////////
//                    --- Class AtapiHardwareAccess ---                      //
///////////////////////////////////////////////////////////////////////////////
class  AtapiHardwareAccess
{
public:
    AtapiHardwareAccess    (const WORD  ioBaseMain,
                const WORD  ioBaseAlt,
                const BYTE  bDrv,
                const BYTE  bIntNum,
                const BYTE  bIrqNum);
    ~AtapiHardwareAccess   ();

protected:
    ATAPI_Ctrl_Block_Map_RD     m_ATAPI_Ctrl_Blk_Rd; // Control blk regs read map
    ATAPI_Ctrl_Block_Map_WR     m_ATAPI_Ctrl_Blk_Wr; // Control blk regs write map
    ATAPI_Cmd_Block_Map_RD      m_ATAPI_Cmd_Blk_Rd;  // Command blk regs read map
    ATAPI_Cmd_Block_Map_WR      m_ATAPI_Cmd_Blk_Wr;  // Command blk regs write map
    ATAPI_Identify_Dev_Data     m_IdentifyData;      // Identify data buffer
    ATAPI_Inquiry_Data_Std_In   m_InquiryDataStd;    // Inquiry data buffer (std)
    ATAPI_Inquiry_Data_Ext_In   m_InquiryDataExt;    // Inquiry data buffer (ext)
    BYTE                        m_bATAPI_Drive;      // Order number of drive
    BYTE                        m_bATAPI_Version;    // ATAPI spec. version
    BYTE                        m_bSoftIntNum;       // ATAPI software interrupt
    BYTE                        m_bHardIrqNum;       // ATAPI hardware interrupt
    BOOLEAN                     m_fThisIsDevATAPI;   // ATAPI device flag
    BOOLEAN                     m_fIdentifyDataATAPI;// Identify data presence
    BOOLEAN                     m_fInquiryDataExt;   // Inquiry data (ext) presence
    WORD                        m_wDriveBaseMainAddr;// Base address (main)
    WORD                        m_wDriveBaseAltAddr; // Base addres  (alternate)
    ModePageBuf *               m_pbAllModePagesBuf; // Mode pages buffer
    char                        m_chBaseFileName[9]; // Use for dump to disk


protected:  // Input/Output Operations (Low-Level)
#if defined(_WIN32)
#pragma message ("(13) Direct I/O ports access must be updated in Win32 environment." )
    BYTE      mf_ReadByteReg            (WORD wReg)  { return( (BYTE)0xFF); }
    WORD      mf_ReadWordReg            (WORD wReg)  { return(0xFFFF); }
    void      mf_WriteByteReg           (WORD wReg, BYTE bData)  { /*empty*/; }
    void      mf_WriteWordReg           (WORD wReg, WORD wData)  { /*empty*/; }
#else                                       // #if defined(_WIN32)
    BYTE      mf_ReadByteReg            (WORD wReg)  { return( (BYTE)inp(wReg)); }
    WORD      mf_ReadWordReg            (WORD wReg)  { return(inpw(wReg)); }
    void      mf_WriteByteReg           (WORD wReg, BYTE bData)  { outp(wReg,bData); }
    void      mf_WriteWordReg           (WORD wReg, WORD wData)  { outpw(wReg,wData); }
#endif                                      // #if defined(_WIN32)
    WORD      mf_ReadDataByte           ()  { return(mf_ReadByteReg(m_ATAPI_Cmd_Blk_Rd.wData)); }
    WORD      mf_ReadDataWord           ()  { return(mf_ReadWordReg(m_ATAPI_Cmd_Blk_Rd.wData)); }
    void      mf_WriteDataReg           (WORD wData)  { mf_WriteWordReg(m_ATAPI_Cmd_Blk_Wr.wData,wData); }

protected:  // Status/Error State
    BYTE      mf_GetStatusATAPI         ()  { return(mf_ReadByteReg(m_ATAPI_Cmd_Blk_Rd.bATAPI_Stat)); }
    BYTE      mf_GetErrorATAPI          ()  { return(mf_ReadByteReg(m_ATAPI_Cmd_Blk_Rd.bATAPI_Err)); }
    void      mf_OutputStatusATAPI      (BYTE bStatusOut);
    void      mf_OutputErrorATAPI       (BYTE bErrorOut);

protected:  // Miscellaneous Support Functions
    void      mf_SetDriveSelectReg      ();
    WORD      mf_GetTransferCount       ();
    DWORD     mf_WaitBusyDrive          (DWORD dwTimeoutValue);
    DWORD     mf_WaitDriveDRQ           (DWORD dwTimeoutValue);
    DWORD     mf_WaitReadyDrive         (DWORD dwTimeoutValue);
    void      mf_EmulateDelay           (WORD wCount);
    DWORD     mf_WaitDriveInt           (DWORD dwTimeoutValue);
    void      mf_WaitCommandComplete    (DWORD dwTimeoutValue, WORD wBIOSticks);
    void      mf_LinkInterruptHandler   ();
    void      mf_UnLinkInterruptHandler ();

protected:  // Media/Unit access commands
    BOOLEAN   mf_TestUnitReady          ();
    BOOLEAN   mf_SeekBlock              (DWORD  dwBlockNum);

#if defined(_AUDIO)
protected:  // Media/Unit access commands
    BOOLEAN   mf_LockDrive              (BOOLEAN fPrevent);
    BOOLEAN   mf_AccessDisc             (BYTE bOperationCode);
    void      mf_ExecAudioDriveCmd      ();

protected:  // Audio support commands
    BOOLEAN   mf_ReadTOC                (BYTE bTOCDataFormat, BOOLEAN fMSFform);
    BOOLEAN   mf_ReadDiscTOC            (BOOLEAN fMSFform);
    BOOLEAN   mf_PlayAudio              (DWORD dwLBA, WORD wLen);
    BOOLEAN   mf_PlayAudioMSF           (DWORD dwStartMSF, DWORD dwEndMSF);
    BOOLEAN   mf_PlayCD                 (BOOLEAN fMSFform, DWORD dwStartLbaMsf, DWORD dwEndLbaMsf);
    BOOLEAN   mf_PlayAudioDisk          (BOOLEAN fMSFform, BOOLEAN fPlayCDcmd);
    BOOLEAN   mf_StopPlay               ();
    BOOLEAN   mf_PauseResume            (BOOLEAN fResume);
#endif                                      // #if defined(_AUDIO)

protected:  // Data Transfer
    WORD      mf_TransferDataFromDrive  (PBYTE pInBuf, WORD wBufLen, WORD wInDataCount);
    BOOLEAN   mf_GetIdentifyData        ();
    BOOLEAN   mf_GetInquiryData         ();
    BOOLEAN   mf_GetInquiryDataExt      ();
    BOOLEAN   mf_GetAllModePagesData    (BYTE bPageControlValue);

protected:  // Hardware Detection/Presence
    BOOLEAN   mf_CheckSignatureATAPI    ();
    BOOLEAN   mf_DetectHardwarePresence ();
    BOOLEAN   mf_GetIdentifyATAPI       ()  { return(m_fThisIsDevATAPI); }
public:
    BOOLEAN   mf_DetectThisDeviceATAPI  (BOOLEAN fSoftReset, BOOLEAN fSkipAtaCmd);

protected:  // Execute Commands
    void      mf_SendCmdByteATA         (BYTE bCmdOpcode)  { mf_WriteByteReg(m_ATAPI_Cmd_Blk_Wr.bATA_Cmd, bCmdOpcode); }
    void      mf_SoftResetATAPI         ();
    BOOLEAN   mf_SendPacketCommand      (ATAPI_CDROM_Std_Cmd_Pkt *pBuf);

#if defined(_ATA_CMDS)
protected:  // CD-ROM ATA commands
    BOOLEAN   mf_EnterSleepMode         ();
    BOOLEAN   mf_EnterIdleModeImm       ();
    BOOLEAN   mf_EnterStandbyModeImm    ();
    BOOLEAN   mf_ChkPwrMode             ();
    BOOLEAN   mf_NOPeration             ();
    BOOLEAN   mf_SetFeatures            (BOOLEAN fSetFeature, BYTE bFeature, BYTE bParam);
    BOOLEAN   mf_ExecDriveDiag          ();
    void      mf_ExecAtaDriveCmd        ();
#endif                                      // #if defined(_ATA_CMDS)

public:  // Information Services
    void      mf_OutputDriveInformation   ();
protected:
    void      mf_OutputIdentifyData       ();
    void      mf_OutputInquiryData        ();
    void      mf_OutputModePagesData      ();
    void      mf_OutputCapabilitiesPage   (pCapabilitiesPage pPageBuf);
    void      mf_OutputAudioControlPage   (pAudioCtrlPage pPageBuf);
    void      mf_OutputDeviceParamsPage   (pDeviceParametersPage pPageBuf);
    void      mf_OutputErrorRecoveryPage  (pReadErrorRecoveryPage pPageBuf);
};
