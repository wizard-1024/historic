//****************************************************************************
//                             File CDROM.HPP
//
//               ATAPI CD-ROM drive hardware definitions
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: d:/projects/hardware/atapicd/RCS/CDROM.HPP $
//  $RCSfile: CDROM.HPP $
//   $Author: dstef $
//     $Date: 2003/01/27 20:09:36 $
// $Revision: 1.2 $
//   $Locker: dstef $
//
//      $Log: CDROM.HPP $
//      Revision 1.2  2003/01/27 20:09:36  dstef
//      Fixed for DJGPP
//
//      Revision 1.1  1999/01/02 00:53:53  dstef
//      Initial revision
//
//
//****************************************************************************



//---------------------------Hardware Ports------------------------------------
const  WORD    ioPRIMARY_MAIN_CTRLR_IO_BASE    =  0x1F0;
const  WORD    ioPRIMARY_ALT_CTRLR_IO_BASE     =  0x3F0;    // 0x3F6
const  WORD    ioSECONDARY_MAIN_CTRLR_IO_BASE  =  0x170;
const  WORD    ioSECONDARY_ALT_CTRLR_IO_BASE   =  0x370;    // 0x376
const  WORD    ioTERTIARY_MAIN_CTRLR_IO_BASE   =  0x1E8;
const  WORD    ioTERTIARY_ALT_CTRLR_IO_BASE    =  0x3E8;    // 0x3EE
const  WORD    ioQUATERNARY_MAIN_CTRLR_IO_BASE =  0x168;
const  WORD    ioQUATERNARY_ALT_CTRLR_IO_BASE  =  0x368;    // 0x36E

const  BYTE    bPhysDrive0  = 0;            // Physical drive number 0
const  BYTE    bPhysDrive1  = 1;            // Physical drive number 1



//---------------------------ATAPI Generic Commands----------------------------
const  BYTE    bATAPI_cmd_Soft_Reset    =  0x08; // (M)andatory command
const  BYTE    bATAPI_cmd_Pkt_Command   =  0xA0; // (M)andatory command
const  BYTE    bATAPI_cmd_Identify_Dev  =  0xA1; // (M)andatory command
const  BYTE    bATAPI_cmd_Service       =  0xA2; // (O)ptional  command



//---------------------------Registers State after any Reset-------------------
const  BYTE    bReset_Reg_Error   =  0x01;  // Error
const  BYTE    bReset_Reg_SC      =  0x01;  // Sector count
const  BYTE    bReset_Reg_SN      =  0x01;  // Sector number
const  BYTE    bReset_Reg_Cyl_Lo  =  0x14;  // Cylinder low
const  BYTE    bReset_Reg_Cyl_Hi  =  0xEB;  // Cylinder high
const  BYTE    bReset_Reg_Drv_Hd  =  0x00;  // Drive/head
const  BYTE    bReset_Reg_Status  =  0x00;  // Status



//---------------------------ATAPI Register Map (Packet Command)---------------
#pragma pack(1)
struct  ATAPI_Ctrl_Block_Map_RD             // ATAPI Control Block Registers (READ)
{
    WORD  bFDC_A_Stat;                      // Floppy A status
    WORD  bFDC_B_Stat;                      // Floppy B status
    WORD  bUnused_1;                        // Unused
    union
    {
         WORD  bFDC_ID;                     // Floppy ID
         WORD  bTape_Ctrl;                  // Tape Control
    }  FloppyTape;
    WORD  bFDC_Stat;                        // Floppy Controller Status
    WORD  bFDC_DATA;                        // Floppy Data Register
    WORD  bATAPI_Stat_ALt;                  // Alternate ATAPI Status
    WORD  bUnused_2;                        // Unused
};

struct  ATAPI_Ctrl_Block_Map_WR             // ATAPI Control Block Registers (WRITE)
{
    WORD  bUnused_1;                        // Unused
    WORD  bUnused_2;                        // Unused
    WORD  bFDC_DOR;                         // Floppy Digital Output Register
    WORD  bReserved_1;                      // RESERVED
    WORD  bReserved_2;                      // RESERVED
    WORD  bFDC_DATA;                        // Floppy Data Register
    WORD  bDev_Ctrl;                        // Device Control
    WORD  bUnused_3;                        // Unused
};

struct  ATAPI_Cmd_Block_Map_RD              // ATAPI Command Block Registers (READ)
{
    WORD  wData;                            // Data
    WORD  bATAPI_Err;                       // ATAPI Error Register
    WORD  bATAPI_Intr_Reason;               // ATAPI Interrupt Reason Register
    WORD  bSAM_TAG;                         // Reserved for SAM TAG Byte
    WORD  bATAPI_Byte_Cnt_Lo;               // ATAPI Byte Count Register (bits 0-7)
    WORD  bATAPI_Byte_Cnt_Hi;               // ATAPI Byte Count Register (bits 8-15)
    WORD  bDrv_Sel;                         // Drive Select
    WORD  bATAPI_Stat;                      // ATAPI Status
};

struct  ATAPI_Cmd_Block_Map_WR              // ATAPI Command Block Registers (WRITE)
{
    WORD  wData;                            // Data
    WORD  bATAPI_Features;                  // ATAPI Features
    WORD  bATAPI_Unused;                    // Unused
    WORD  bSAM_TAG;                         // Reserved for SAM TAG Byte
    WORD  bATAPI_Byte_Cnt_Lo;               // ATAPI Byte Count Register (bits 0-7)
    WORD  bATAPI_Byte_Cnt_Hi;               // ATAPI Byte Count Register (bits 8-15)
    WORD  bDrv_Sel;                         // Drive Select
    WORD  bATA_Cmd;                         // ATA Command
};
#pragma pack()



//---------------------------ATAPI Registers BitMap----------------------------
#pragma pack(1)
struct  tagATAPI_Stat_Reg_RD                // ATAPI/ATA Status Register (READ)
{
    BYTE  CHECK      : 1;                   // Error occurred
    BYTE  RESERVED   : 1;                   // Not Used
    BYTE  CORR       : 1;                   // Correctable error occurred
    BYTE  DRQ        : 1;                   // Data request
    BYTE  SRVC_DSC   : 1;                   // Request service or interrupt
    BYTE  DMARDY_DF  : 1;                   // DMA ready to start or drive fault
    BYTE  DRDY       : 1;                   // ATA drive ready
    BYTE  BSY        : 1;                   // Busy if cmd block accessed by drive
};

typedef  tagATAPI_Stat_Reg_RD *  pATAPI_Stat_Reg_RD;
                                            //Pointer to bit structure

struct tagATAPI_Err_Reg_RD                  // ATAPI/ATA Error Register (READ)
{
    BYTE  ILI        : 1;                   // Illegal length indication
    BYTE  EOM        : 1;                   // End of media detected
    BYTE  ABRT       : 1;                   // Aborted command
    BYTE  MCR        : 1;                   // Media change requested
    BYTE  SENSE_KEY  : 4;                   // Defined is below!
};

typedef  tagATAPI_Err_Reg_RD *  pATAPI_Err_Reg_RD;
                                            //Pointer to bit structure

struct  ATAPI_Feature_Reg_WR                // ATAPI/ATA Feature Register (WRITE)
{
    BYTE  DMA       : 1;                    // DMA data transfer
    BYTE  OVERLAP   : 1;                    // May release ATA bus before cmd completion
    BYTE  RESERVED  : 6;                    // Future enhancements
};

struct  ATAPI_Intr_Reason_Reg_RD            // ATAPI Interrupt Reason Register (READ)
{                                           // (ATA Sector Count Register)
    BYTE  CoD       : 1;                    // Transfer type (0=user data, 1=cmd)
    BYTE  IO        : 1;                    // Direction of transfer (1=to host, 0=from host)
    BYTE  RELEASE   : 1;                    // ATA bus has released
    BYTE  RESERVED  : 5;                    // Reserved
};

// Use the following table to understand a data transfer:
//   IO   DRQ  CoD    Meaning
//    0    1    1     Command (ready to accept cmd pkt bytes)
//    1    1    1     Message (in future - ready to send message data to host)
//    1    1    0     Read Data (send cmd parameter data to host)
//    0    1    0     Write Data (receive cmd parameter data from host)
//    1    0    1     Status (same register contains completion status)


struct  ATAPI_Drv_Sel_Reg_RD_WR             // ATAPI Drive Select Register (READ/WRITE)
{                                           // (ATA Drive/Head Select Register)
    BYTE  SAM_LUN       : 4;                // Reserved
    BYTE  DRV           : 1;                // Select device (0=drive 0, 1=drive 1)
    BYTE  SET_ONE_1     : 1;                // Always 1 (ATA sector size = 512 bytes)
    BYTE  RESERVED      : 1;                // Reserved
    BYTE  SET_ONE_2     : 1;                // Always 1 (ATA CRC mode)
};

struct  ATAPI_Dev_Ctrl_Reg_WR               // ATAPI/ATA Device Control Register (WRITE)
{
    BYTE  SET_ZERO  : 1;                    // Always must be 0
    BYTE  nIEN      : 1;                    // 0=enable interrupts to host, 1=disable
    BYTE  SRST      : 1;                    // Software reset
    BYTE  SET_ONE   : 1;                    // Always must be 1 (ATA more 8 heads)
    BYTE  RESERVED  : 4;                    // Reserved
};
#pragma pack()



//---------------------------ATAPI Identify Data-------------------------------
#pragma pack(1)
struct  ATAPI_Identify_Dev_Data             // Identify Data return by same command
{                                           // Offset, Meaning
    WORD   wGeneralConfiguration;           // 0,  mandatory/fixed
    WORD   wCylinders;                      // 1,  ATA compatibility
    WORD   wReserved_1;                     // 2,  ATA compatibility
    WORD   wHeads;                          // 3,  ATA compatibility
    WORD   wUnfmtBytesPerTrack;             // 4,  ATA compatibility
    WORD   wUnfmtBytesPerSector;            // 5,  ATA compatibility
    WORD   wSectorPerTrack;                 // 6,  ATA compatibility
    WORD   wReserved_7;                     // 7,  ATA compatibility
    WORD   wReserved_8;                     // 8,  ATA compatibility
    WORD   wReserved_9;                     // 9,  ATA compatibility
    char   chSerialNumber[20];              // 10, optional/fixed
    WORD   wVendorSpecific_20;              // 20, ATA compatibility
    WORD   wVendorSpecific_21;              // 21, ATA compatibility
    WORD   wBytesECC;                       // 22, ATA compatibility
    char   chFirmwareRevision[8];           // 23, mandatory/fixed
    char   chModelNumber[40];               // 27, mandatory
    WORD   wMultSectorCount;                // 47, ATA compatibility
    WORD   wReserved_48;                    // 48, ATA compatibility
    WORD   wCapabilities;                   // 49, mandatory
    WORD   wReserved_50;                    // 50, ATA compatibility
    WORD   wPIO_Cycle_Timing;               // 51, mandatory/fixed
    WORD   wDMA_Cycle_Timing;               // 52, mandatory/fixed
    WORD   wValidity_53;                    // 53, mandatory
    WORD   wCurrentCyls;                    // 54, ATA compatibility
    WORD   wCurrentHeads;                   // 55, ATA compatibility
    WORD   wCurrentSectors;                 // 56, ATA compatibility
    DWORD  dwCurrentCapacity;               // 57, ATA compatibility
    WORD   Reserved_59;                     // 59, ATA compatibility
    DWORD  dwUserAddressableSectors;        // 60, ATA compatibility
    WORD   wSingleDMA_Modes;                // 62, mandatory
    WORD   wMultiDMA_Modes;                 // 63, mandatory
    WORD   wAdv_PIO_Modes;                  // 64, mandatory
    WORD   wMin_Mult_DMA_Xfr_Cycle_Time_Per_Word;   // 65, mandatory (ns)
    WORD   wManuf_Mult_DMA_Xfr_Time;                // 66, mandatory (ns)
    WORD   wMin_PIO_Xfr_Cycle_Time_No_Flow_Ctrl;    // 67, optional (ns)
    WORD   wMin_PIO_Xfr_Cycle_Time_IORDY_Flow_Ctrl; // 68, optional (ns)
    WORD   wAdv_PIO_Sup_69;                         // 69, ATA compatibility
    WORD   wAdv_PIO_Sup_70;                         // 70, ATA compatibility
    WORD   wTypTimeToReleaseAfterCmdReceived;       // 71, optional
    WORD   wTypTimeToReleaseAfterServiceCmd;        // 72, optional
    WORD   wMajorVersionNumber;             // 73, optional
    WORD   wMinorVersionNumber;             // 74, optional
    BYTE   bReserved_75[106];               // 75, ATA compatibility
    BYTE   bVendorUnique_128[64];           // 128, ATA compatibility
    BYTE   bReserved_160[192];              // 160, ATA compatibility
};

struct GeneralConfigFlags                   // General Configuration Word (0)
{
    WORD  CMD_PKT_SIZE      : 2;            // CMD Packet Size
    WORD  RESERVED_2_4      : 3;            // Reserved (unique for each protocol)
    WORD  CMD_DRQ_TYPE      : 2;            // Command Packet DRQ Type
    WORD  REMOVABLE_DEV     : 1;            // Device has removable media
    WORD  DEVICE_TYPE       : 5;            // Device Type
    WORD  RESERVED_13       : 1;            // Reserved for future enhancements
    WORD  PROTOCOL_TYPE     : 2;            // Protocol type in use by device
};

struct CapabilitiesFlags                    // Capabilities Word (Word 49)
{
    WORD  VENDOR_UNIQUE   : 8;              // Vendor Unique
    WORD  DMA_SUP         : 1;              // DMA mode of data transfer (optional)
    WORD  LBA_SUP         : 1;              // LBA form addressing (mandatory)
    WORD  IORDY_CAN_DIS   : 1;              // Disable/Enable use of IORDY (optional)
    WORD  IORDY_SUP       : 1;              // Supports IORDY (optional)
    WORD  RESERVED_12     : 1;              // Reserved
    WORD  OVLAP_SUP       : 1;              // Overlapped operations (optional)
    WORD  PROXY_INTR      : 1;              // Shared interrupts (reserved for future)
    WORD  INTLVD_DMA      : 1;              // Interleaved DMA (reserved for future)
};

struct ValidityFlags_53                     // Field Validity (Word 53)
{
    WORD  VALID_FLAGS_54_58     : 1;        // Valid fields 54-58
    WORD  VALID_FLAGS_64_70     : 1;        // Valid fields 64-70
    WORD  RESERVED              : 14;       // Reserved (0)
};

struct SingleDMA_Flags_62                   // Single Word DMA Transfer (Word 62)
{
    WORD  SGL_DMA_XFR_MODE_SUP_0    : 1;    // Supported modes 0-7
    WORD  SGL_DMA_XFR_MODE_SUP_1    : 1;
    WORD  SGL_DMA_XFR_MODE_SUP_2    : 1;
    WORD  SGL_DMA_XFR_MODE_SUP_3    : 1;
    WORD  SGL_DMA_XFR_MODE_SUP_4    : 1;
    WORD  SGL_DMA_XFR_MODE_SUP_5    : 1;
    WORD  SGL_DMA_XFR_MODE_SUP_6    : 1;
    WORD  SGL_DMA_XFR_MODE_SUP_7    : 1;
    WORD  SGL_DMA_XFR_MODE_ACT_0    : 1;    // Active modes 0-7
    WORD  SGL_DMA_XFR_MODE_ACT_1    : 1;
    WORD  SGL_DMA_XFR_MODE_ACT_2    : 1;
    WORD  SGL_DMA_XFR_MODE_ACT_3    : 1;
    WORD  SGL_DMA_XFR_MODE_ACT_4    : 1;
    WORD  SGL_DMA_XFR_MODE_ACT_5    : 1;
    WORD  SGL_DMA_XFR_MODE_ACT_6    : 1;
    WORD  SGL_DMA_XFR_MODE_ACT_7    : 1;
};

struct MultiDMA_Flags_63                    // Multi Word DMA Transfer (Word 63)
{
    WORD  MULT_DMA_XFR_MODE_SUP_0   : 1;    // Supported modes 0-7
    WORD  MULT_DMA_XFR_MODE_SUP_1   : 1;
    WORD  MULT_DMA_XFR_MODE_SUP_2   : 1;
    WORD  MULT_DMA_XFR_MODE_SUP_3   : 1;
    WORD  MULT_DMA_XFR_MODE_SUP_4   : 1;
    WORD  MULT_DMA_XFR_MODE_SUP_5   : 1;
    WORD  MULT_DMA_XFR_MODE_SUP_6   : 1;
    WORD  MULT_DMA_XFR_MODE_SUP_7   : 1;
    WORD  MULT_DMA_XFR_MODE_ACT_0   : 1;    // Active modes 0-7
    WORD  MULT_DMA_XFR_MODE_ACT_1   : 1;
    WORD  MULT_DMA_XFR_MODE_ACT_2   : 1;
    WORD  MULT_DMA_XFR_MODE_ACT_3   : 1;
    WORD  MULT_DMA_XFR_MODE_ACT_4   : 1;
    WORD  MULT_DMA_XFR_MODE_ACT_5   : 1;
    WORD  MULT_DMA_XFR_MODE_ACT_6   : 1;
    WORD  MULT_DMA_XFR_MODE_ACT_7   : 1;
};

struct Adv_PIO_Modes_Flags                  // Enhanced PIO Mode (Word 64)
{
    WORD  PIO_MODE_3_SUP    : 1;            // Supported modes 3-10
    WORD  PIO_MODE_4_SUP    : 1;
    WORD  PIO_MODE_5_SUP    : 1;
    WORD  PIO_MODE_6_SUP    : 1;
    WORD  PIO_MODE_7_SUP    : 1;
    WORD  PIO_MODE_8_SUP    : 1;
    WORD  PIO_MODE_9_SUP    : 1;
    WORD  PIO_MODE_10_SUP   : 1;
    WORD  RESERVED          : 8;            // Reserved
};
#pragma pack()



//---------------------------ATAPI/ATA miscellaneous---------------------------
const  WORD    wStdSecSize  =  512;         // IBM sector is 512 bytes



//---------------------------- Protocol type field ----------------------------
enum  ProtocolType
{
    wProtType_ATA_0      =  0x00,
    wProtType_ATA_1      =  0x01,
    wProtType_ATAPI      =  0x02,
    wProtType_Reserved   =  0x03
};



//----------------------- Peripheral device type field -----------------------
enum  PeripheralDeviceType
{
    wDevType_DASD       =  0x00,
    wDevType_CDROM      =  0x05,
    wDevType_OptMemDev  =  0x07,
    wDevType_Unknown    =  0x1F
};


//-------------------------- Command Packet DRQ Type --------------------------
enum  CmdPktDRQType
{
    wCmd_DRQ_Type_MicroProccessor_DRQ  =  0x00,
    wCmd_DRQ_Type_Interrupt_DRQ        =  0x01,
    wCmd_DRQ_Type_Accelerated_DRQ      =  0x02,
    wCmd_DRQ_Type_Reserved             =  0x03
};



//---------------------- Command Packet Size for Device ----------------------
enum  DevCmdPktSize
{
    wCmd_Pkt_Size_CDROM       =  0x00,
    wCmd_Pkt_Size_SAM         =  0x01,
    wCmd_Pkt_Size_Reserved_2  =  0x02,
    wCmd_Pkt_Size_Reserved_3  =  0x03
};



//-------------------- Programmed input/output (PIO) modes --------------------
enum  PIO_Modes                             // order number
{
    wPIO_Mode_0  =  0,
    wPIO_Mode_1  =  1,
    wPIO_Mode_2  =  2,
    wPIO_Mode_3  =  3,
    wPIO_Mode_4  =  4
};

enum  PIO_Xfr_Cycles                        // transfer cycles (ns)
{
    wPIO_Cycle_0  =  600,
    wPIO_Cycle_1  =  383,
    wPIO_Cycle_2  =  240,
    wPIO_Cycle_3  =  180,
    wPIO_Cycle_4  =  120
};



//---------------------- Single-word DMA transfer modes ----------------------
enum  SW_DMA_Modes                             // order number
{
    wSW_DMA_Mode_0  =  0,
    wSW_DMA_Mode_1  =  1,
    wSW_DMA_Mode_2  =  2
};

enum  SW_DMA_Xfr_Cycles                     // transfer cycles (ns)
{
    wSW_DMA_Cycle_0  =  960,
    wSW_DMA_Cycle_1  =  480,
    wSW_DMA_Cycle_2  =  240
};



//----------------------- Multi-word DMA transfer modes -----------------------
enum  MW_DMA_Modes                             // order number
{
    wMW_DMA_Mode_0  =  0,
    wMW_DMA_Mode_1  =  1,
    wMW_DMA_Mode_2  =  2
};

enum  MW_DMA_Xfr_Cycles                     // transfer cycles (ns)
{
    wMW_DMA_Cycle_0  =  480,
    wMW_DMA_Cycle_1  =  150,
    wMW_DMA_Cycle_2  =  120
};



//---------------------------- Page control field ----------------------------
enum  PageControlField
{
    bCurrentValuesPC     =  0x00,
    bChangeableValuesPC  =  0x01,
    bDefaultValuesPC     =  0x02,
    bSavedValuesPC       =  0x03
};



//------------------------------ Mode page codes ------------------------------
enum  ModePageCode
{
    bVendorSpecificNoPageMPC     =  0x00,
    bReadErrRecoveryMPC          =  0x01,
    bCDROM_MPC                   =  0x0D,
    bCDROM_AudioCtrl_MPC         =  0x0E,
    bCDROM_Capable_MechStat_MPC  =  0x2A,
    bAllPagesMPC                 =  0x3F,
};



//--------------------------------- Sense key ---------------------------------
enum  SenseKey
{
    bNO_SENSE_SKEY         =  0,
    bRECOVERED_ERROR_SKEY  =  1,
    bNOT_READY_SKEY        =  2,
    bMEDIUM_ERROR_SKEY     =  3,
    bHARDWARE_ERROR_SKEY   =  4,
    bILLEGAL_REQUEST_SKEY  =  5,
    bUNIT_ATTENTION_SKEY   =  6,
    bDATA_PROTECT_SKEY     =  7,
    bABORTED_COMMAND_SKEY  =  11,
    bMISCOMPARE_SKEY       =  14
};



//-------------------------- Data Rate and Speed (X) --------------------------
enum  DataRateX
{
    wSpeedMPC  =   150,                     // (X1) as MPC value
    wSpeedX1   =   176,                     // (X1) KBytes/second
    wSpeedX2   =   353,                     // (X2)
    wSpeedX2p2 =   387,                     // (X2.2)
    wSpeedX3   =   528,                     // (X3)
    wSpeedX4   =   706,                     // (X4)
    wSpeedX8   =  1408,                     // (X8)  ~1.4 MBytes/second
    wSpeedX16  =  2816                      // (X16) ~2.8 MBytes/second
};



//---------------------- Expected Sector Type (PLAY CD) -----------------------
enum  ExpSectorType
{
    bAnyType        =  0,                   // mandatory
    bCDDA           =  1,                   // mandatory
    bMode1          =  2,                   // mandatory
    bMode2          =  3,                   // mandatory
    bMode2Form1     =  4,                   // mandatory
    bMode2Form2     =  5                    // mandatory
};


//---------------------- Start/Stop/Eject Operations --------------------------
enum  StartStopEjectOps
{
    bStopDisc             =  0,             // mandatory
    bStartDiscReadTOC     =  1,             // mandatory
    bEjectDisc            =  2,             // mandatory
    bLoadDisc             =  3              // mandatory
};



//-------------------------- Read TOC data format -----------------------------
enum  ReadTOCDataFormat
{
    bBackwardCompMode     =  0,             // mandatory
    bMultisessionMode     =  1,             // mandatory
    bSubchannelQdata      =  2              // mandatory
};



//---------------------------ATAPI CDROM Packet Commands-----------------------
enum  ATAPI_CDROM_Cmd
{
    bTestUnitReady         =  0x00,         // (M)andatory command
    bRequestSense          =  0x03,         // (M)andatory command
    bInquiry               =  0x12,         // (M)andatory command
    bStartStopUnit         =  0x1B,         // (M)andatory command
    bPreventAllowMediumRemoval =  0x1E,     // (M)andatory command
    bSeek                  =  0x2B,         // (M)andatory command
    bReadSubChannel        =  0x42,         // (M)andatory command
    bReadTOC               =  0x43,         // (M)andatory command
    bReadHeader            =  0x44,         // (M)andatory command
    bPlayAudio             =  0x45,         // (O)ptional  command
    bPlayAudioMSF          =  0x47,         // (O)ptional  command
    bPauseResume           =  0x4B,         // (O)ptional  command
    bStopPlay              =  0x4E,         // (O)ptional  command
    bModeSelect            =  0x55,         // (M)andatory command
    bModeSense             =  0x5A,         // (M)andatory command
    bLoadCD                =  0xA6,         // (O)ptional  command
    bRead                  =  0xA8,         // (M)andatory command
    bUnloadCD              =  0xA6,         // (O)ptional  command
    bPlayCDMSF             =  0xB4,         // (O)ptional  command
    bReadCDMSF             =  0xB9,         // (M)andatory command
    bScan                  =  0xBA,         // (O)ptional  command
    bSetCDSpeed            =  0xBB,         // (O)ptional  command
    bPlayCDLBA             =  0xBC,         // (O)ptional  command
    bMechanismStatus       =  0xBD,         // (M)andatory command
    bReadCD                =  0xBE          // (M)andatory command
};



//------------------------Set Feature Register Definitions---------------------
#if defined(_ATA_CMDS)
enum  SetFeatureRegisterDefinitions
{
    SetTransferModeBasedOnSCR                =   0x03,
    EnableIntrForReleaseOnReceiptOverlapCmd  =   0x5D,
    EnableIntrAfterProcessingServiceCmd      =   0x5E,
    DisableRevertingToPowerOnDefaults        =   0x66,
    EnableRevertingToPowerOnDefaults         =   0xCC,
    DisableIntrForReleaseOnReceiptOverlapCmd =   0xDD,
    DisableIntrAfterProcessingServiceCmd     =   0xDE
};

enum    TransferModeTypeSCR
{
    PIODefaultTransferModeX         =   0,
    PIOFlowControlTransferModeX     =   1,
    SingleWordDMAModeX              =   2,
    MultiwordDMAModeX               =   4
};

enum    TransferModeValueSCR
{
    PIODefaultTransferMode              =   0,
    PIODefaultTransferModeDisableIORDY  =   1   // Device must support disabling IORDY
};

#pragma pack(1)
struct   tagSetFeatReg
{
    BYTE    FeatureNumber   : 7;            // Feature
    BYTE    SetClearFeature : 1;            // Cmd bit
};

struct  tagXfrModeForSCR
{
    BYTE    TransferModeValue   :   3;      // Speed of transfer
    BYTE    TransferModeType    :   5;      // Type of transfer
};
#pragma pack()
#endif                                      // #if defined(_ATA_CMDS)



//---------------------------ATAPI command packet------------------------------
#pragma pack(1)
struct  ATAPI_CDROM_Std_Cmd_Pkt             // ATAPI Command Packet for CD-ROM drive
{
    BYTE    bOpCode;                        // Operation Code
    BYTE    bReserved_1;                    // Reserved
    BYTE    LBA_MSB_Hi;                     // Logical Block Address
    BYTE    LBA_MSB_Lo;                     // (started from 0)
    BYTE    LBA_LSB_Hi;
    BYTE    LBA_LSB_Lo;
    BYTE    bReserved_6;                    // Reserved
    WORD    wParameterLen;                  // Length of parameter
    BYTE    bReserved_9;                    // Reserved
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};
#pragma pack()



//--------------------------- ATAPI INQUIRY Command ---------------------------
#pragma pack(1)
struct  Inquiry_Cmd_Pkt_Out                 // ATAPI INQUIRY Command Packet
{
    BYTE    bOpCode;                        // Operation Code
    BYTE    bReserved_1;                    // Reserved
    BYTE    bPageCode;                      // Page Code of Vital Information
    BYTE    bReserved_3;                    // Reserved
    BYTE    bAllocLength;                   // Allocation Length
    BYTE    bReserved_5;                    // Reserved
    BYTE    bReserved_6;                    // Reserved
    BYTE    bReserved_7;                    // Reserved
    BYTE    bReserved_8;                    // Reserved
    BYTE    bReserved_9;                    // Reserved
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};

struct  ATAPI_Inquiry_Data_Std_In           // ATAPI Standard Inquiry Data
{
    BYTE    bDevType;                       // Peripheral Device Type
    BYTE    bRemovableFlag;                 // Removable Medium Bit
    BYTE    bVersion;                       // ANSI/ECMA/ISO Version
    BYTE    bVersionFormat;                 // ATAPI Version/Response Data Format
    BYTE    bAddionalLength;                // Addional parameters length
    BYTE    bReserved_5;                    // Reserved
    BYTE    bReserved_6;                    // Reserved
    BYTE    bReserved_7;                    // Reserved
    char    chVendorIdentification[8];      // Vendor of product (ASCII codes 0x20-0x7E)
    char    chProductIdentification[16];    // Defined by vendor
    char    chProductRevisionLevel[4];      // Defined by vendor
};

struct  ATAPI_Inquiry_Data_Ext_In           // ATAPI Extended Inquiry Data
{
    ATAPI_Inquiry_Data_Std_In   Std_Inquiry_Data; // ATAPI Standard Inquiry Data
    char    bVendorSpecific[20];            // Vendor specific field
    BYTE    bReserved[40];                  // Reserved
};

struct  ATAPI_Inquiry_Flags_Dev             // ATAPI Inquiry Data (1st,2nd bytes)
{
    WORD   PERIPHERAL_DEV_TYPE  : 5;        // Peripheral Device Type
    WORD   RESERVED             : 10;       // Reserved
    WORD   RMB                  : 1;        // Removable Medium Bit
};

struct  ATAPI_Inquiry_Flags_Ver             // ATAPI Inquiry Data (3rd,4th bytes)
{
    WORD   ANSI             : 3;            // ANSI Version
    WORD   ECMA             : 3;            // ECMA Version
    WORD   ISO              : 2;            // ISO Version
    WORD   RESP_DAT_FMT     : 4;            // Response Data Format (must be 1 for ATAPI 2.5)
    WORD   ATAPI            : 4;            // ATAPI Specification Version
};
#pragma pack()



//------------------------- ATAPI MODE SENSE Command -------------------------
#pragma pack(1)
struct  Mode_Sense_Cmd_Pkt_Out              // ATAPI Mode Sense Command Packet
{
    BYTE    bOpCode;                        // Operation Code
    BYTE    bReserved_1;                    // Reserved
    BYTE    bPageCodeControl;               // Page Code / Page Control Field
    BYTE    bReserved_3;                    // Reserved
    BYTE    bReserved_4;                    // Reserved
    BYTE    bReserved_5;                    // Reserved
    BYTE    bReserved_6;                    // Reserved
    BYTE    bAllocLenMSB;                   // Allocation Length (High Byte)
    BYTE    bAllocLenLSB;                   // Allocation Length (Low Byte)
    BYTE    bReserved_9;                    // Reserved
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};

struct  PageCodeControl                     // Page Code / Page Control Field (MODE SENSE Command)
{
    BYTE  PAGE_CODE     : 6;                // Page Code
    BYTE  PAGE_CONTROL  : 2;                // Page Control Field (Values Type)
};


struct  ModePageBuf                         // Allocation buffer for Page Parameters
{
    BYTE  BufData[1024];                    // Storage
};

struct  ModeParameterListHeader             // Mode Parameter Header
{
    BYTE    bModeDataLenMSB;                // Mode Data Length (High Byte)
    BYTE    bModeDataLenLSB;                // Mode Data Length (Low Byte)
    BYTE    bMeduimType;                    // CD-ROM Medium Type Code
    BYTE    bReserved_3;                    // Reserved
    BYTE    bReserved_4;                    // Reserved
    BYTE    bReserved_5;                    // Reserved
    BYTE    bReserved_6;                    // Reserved
    BYTE    bReserved_7;                    // Reserved
};
#pragma pack()



//----------------------------- Mode Page Header -----------------------------
#pragma pack(1)
struct  PageCodeSaveable
{
    BYTE  PAGE_CODE     : 6;                // Page Code
    BYTE  RESERVED_7    : 1;                // Reserved
    BYTE  PS            : 1;                // Parameters Saveable
};

struct  ModePageFormatHeader                // Mode Page Header
{
    PageCodeSaveable PageCodePS;            // Page Code / Parameters Savable Bit
    BYTE             PageLength;            // Page Length (N-1)
};
#pragma pack()



//----------------------------- Capabilities Page -----------------------------
#pragma pack(1)

struct  DriveDigitalOutput                  // Digital output format from Drive
{
    BYTE   RESERVED_1   : 1;                // Reserved
    BYTE   BCKF         : 1;                // Data valid on rising/falling edge of BCK signal
    BYTE   RCH          : 1;                // Left/right channel
    BYTE   LSBF         : 1;                // LSB first
    BYTE   LENGTH       : 2;                // Length in BCKs
    BYTE   RESERVED_6   : 2;                // Reserved
};

struct  CapabilityBitsLo                    // Individual capabilities of drive (one half)
{
    WORD    AUDIO_PLAY                 : 1; // Audio Play operation and support of overlapping operations
    WORD    COMPOSITE                  : 1; // Deliver of composite Audio and Video data stream
    WORD    DIGITAL_PORT_1             : 1; // Digital Output (IEC958) on port 1
    WORD    DIGITAL_PORT_2             : 1; // Digital Output (IEC958) on port 2
    WORD    MODE_2_FORM_1              : 1; // Read sectors in Mode 2 Form 1 (XA) format
    WORD    MODE_2_FORM_2              : 1; // Read sectors in Mode 2 Form 2 format
    WORD    MULTI_SESSION              : 1; // Read multiple session of Photo-CD dics
    WORD    RESERVED_7                 : 1; // Reserved
    WORD    CD_DA_CMDS                 : 1; // Red Book audio can be read using READ-CD cmd
    WORD    CD_DA_STREAM_IS_ACCURATE   : 1; // Advanced feature to recover without losing place
                                            //   to continue READ CD-DA command
    WORD    R_W_SUPPORT                : 1; // Commands can return combined R-W info
    WORD    R_W_INTLVD_CORR            : 1; // R-W sub-channel data will be returned
                                            //   de-interleaved and error corrected
    WORD    C2_POINTERS_SUPPORT        : 1; // Supports the C2 Error Pointers
    WORD    ISRC                       : 1; // Can return International Standard
                                            //   Recording Code Information
    WORD    UPC                        : 1; // Can return Media Catalog Number
    WORD    RESERVED_15                : 1; // Reserved
};

struct  CapabilityBitsHi                    // Individual capabilities of drive (other half)
{
    WORD    LOCK                    : 1;    // Software support to lock/unloc media
    WORD    LOCK_STATE              : 1;    // Current state of drive
    WORD    PREVENT_JUMPER          : 1;    // State of (Optional) Prevent/Allow Jumper
    WORD    EJECT_CMD               : 1;    // Individual or cartridge
    WORD    RESERVED_19             : 1;    // Reserved
    WORD    LOAD_MECH_TYPE          : 3;    // Disc loading type
    WORD    SEPARATE_VOL_LEVEL      : 1;    // Control for audio level of each channel
    WORD    SEPARATE_CHANNEL_MUTE   : 1;    // Control for mute capability of each channel
    WORD    SDP                     : 1;    // Supports disc present
    WORD    SSS                     : 1;    // Software Slot Selection
    WORD    RESERVED_28             : 4;    // Reserved
};

struct  MediaFunctionCapabilities           // Media Function Capabilities
{
    WORD    CD_R_RD         : 1;            // CD-R disc read function
    WORD    CD_E_RD         : 1;            // CD-E disc read function
    WORD    METHOD_2        : 1;            // CD-R read using addressing method 2
    WORD    RESERVED_3      : 5;            // Reserved
    WORD    CD_R_WR         : 1;            // CD-R disc write function
    WORD    CD_E_WR         : 1;            // CD-E disc write function
    WORD    RESERVED_10     : 6;            // Reserved
};

struct  CapabilitiesPage                    // CD-ROM Capabilities and Mechanical
{                                           // Status Page
    ModePageFormatHeader   PageHdr;         // Std Mode Page Header (Page Length=22 bytes)
    MediaFunctionCapabilities wMediaFunction; // Media Function Capabilities
    CapabilityBitsLo    wCapabilityLow;     // Individual Capabilities Of Drive (low word)
    CapabilityBitsHi    wCapabilityHigh;    // Individual Capabilities Of Drive (high word)
    BYTE     bMaxSpeedMSB;                  // Maximum Data Rate of Drive (High Byte)
    BYTE     bMaxSpeedLSB;                  // Maximum Data Rate of Drive (Low Byte)
    BYTE     bReserved_10;                  // Reserved
    BYTE     bVolumeLevelsNumber;           // Number of Supported Volume Levels
    BYTE     bDriveBufferSizeMSB;           // Buffer Size / 1024 (High Byte)
    BYTE     bDriveBufferSizeLSB;           // Buffer Size / 1024 (Low Byte)
    BYTE     bCurSpeedMSB;                  // Current Data Rate of Drive (High Byte)
    BYTE     bCurSpeedLSB;                  // Current Data Rate of Drive (Low Byte)
    DriveDigitalOutput     bDigOutFlags;    // Drive's digital output
    BYTE     bReserved_18;                  // Reserved
    BYTE     bReserved_17;                  // Reserved
};

typedef  CapabilitiesPage*  pCapabilitiesPage;
                                            // Pointer to Capibilities Page
#pragma pack()



//---------------------------- Audio Control Page ----------------------------
#pragma pack(1)

struct  AudioPlayFlags                      // Audio control flags
{
    BYTE    RESERVED_1  : 1;                // Reserved
    BYTE    SOTC        : 1;                // Mandatory, default 0
    BYTE    IMMED       : 1;                // Always 1 (mandatory, information purposes only)
    BYTE    RESERVED_4  : 5;                // Reserved
};

struct  ChannelSelection                    // Channel port selection
{
    BYTE    CDDA_OutputPort     : 4;        // CDDA output port channel selection
    BYTE    RESERVED_4          : 4;        // Reserved
};

struct  AudioControlPage                    // CD-ROM Audio Control
{                                           // Status Page
    ModePageFormatHeader   PageHdr;         // Std Mode Page Header (Page Length=14 bytes)
    AudioPlayFlags         AudioFlags;      // Audio Playback flags
    BYTE     bReserved_3;                   // Reserved
    BYTE     bReserved_4;                   // Reserved
    BYTE     bReserved_5;                   // Reserved
    WORD     wLogBlkPerSecAudioPlayback;    // Auido Playback speed (default 75)
    ChannelSelection   CDDA_OutputPort_0;   // Port 0 channel
    BYTE     bOutputPort_0_Volume;          // Port 0 volume (mandatory, default FFh)
    ChannelSelection   CDDA_OutputPort_1;   // Port 1 channel
    BYTE     bOutputPort_1_Volume;          // Port 1 volume (mandatory, default FFh)
    ChannelSelection   CDDA_OutputPort_2;   // Port 2 channel
    BYTE     bOutputPort_2_Volume;          // Port 2 volume (optional, default 00h)
    ChannelSelection   CDDA_OutputPort_3;   // Port 3 channel
    BYTE     bOutputPort_3_Volume;          // Port 3 volume (optional, default 00h)
};

typedef  AudioControlPage*  pAudioCtrlPage; // Pointer to Audio Control Page
#pragma pack()



//-------------------------- Device Parameters Page --------------------------
#pragma pack(1)
struct  TimeMultiply                        // Time Multiplies (Track Hold State)
{
    BYTE    INACTMULTTIME   : 4;            // Inactivity Time Multiplier
    BYTE    RESERVED_4      : 4;            // Reserved
};

struct  DeviceParametersPage                // CD-ROM Device Parameters
{                                           // Status Page
    ModePageFormatHeader   PageHdr;         // Std Mode Page Header (Page Length=6 bytes)
    BYTE     bReserved_2;                   // Reserved
    TimeMultiply     InActTimerMultValue;   // Multiple value
    BYTE     MSF_S_M_Unit_MSB;              // S Units per MSF - M Unit
    BYTE     MSF_S_M_Unit_LSB;              // (default 60, 0x3C)
    BYTE     MSF_F_S_Unit_MSB;              // F Units per MSF - S Unit
    BYTE     MSF_F_S_Unit_LSB;              // (default 75, 0x4B)
};

typedef  DeviceParametersPage*  pDeviceParametersPage;
                                            // Pointer to Device Parameters Page
#pragma pack()



//-------------------- Read Error Recovery Parameters Page --------------------
#pragma pack(1)

struct  ErrorFlags                          // Error Processing Flags
{
    BYTE    DCR         : 1;                // Disable Correction
    BYTE    DTE         : 1;                // Disable Transfer on Error
    BYTE    PER         : 1;                // Post Error
    BYTE    RESERVED_4  : 1;                // Reserved
    BYTE    RC          : 1;                // Read Continuous
    BYTE    TB          : 1;                // Transfer Block
    BYTE    RESERVED_6  : 2;                // Reserved
};

struct  ReadErrorRecoveryParamPage          // Read Error Recovery Parameters
{                                           // Status Page
    ModePageFormatHeader   PageHdr;         // Std Mode Page Header (Page Length=6 bytes)
    union
    {
        BYTE     ErrorRecoveryParameter;    // Error Recovery Parameter
        ErrorFlags    ReadErrorFlags;       // Read Error Recovery Flags
    }  ReadErrorRecovery;
    BYTE     ReadRetryCount;                // Read Retry Count
    BYTE     Reserved_4;                    // Reserved
    BYTE     Reserved_5;                    // Reserved
    BYTE     Reserved_6;                    // Reserved
    BYTE     Reserved_7;                    // Reserved
};

typedef  ReadErrorRecoveryParamPage*  pReadErrorRecoveryPage;
                                            // Pointer to Error Recovery Page
#pragma pack()



//-------------------------- Play Audio Command -------------------------------
#if defined(_AUDIO)
#pragma pack(1)

struct  Play_Audio_Cmd_Pkt_Out              // ATAPI PLAY AUDIO Command Packet
{
    BYTE    bOpCode;                        // Operation Code
    BYTE    bReserved_1;                    // Reserved
    BYTE    bStart_LBA_3;                   // Starting (MSB)
    BYTE    bStart_LBA_2;                   // Logical
    BYTE    bStart_LBA_1;                   // Block
    BYTE    bStart_LBA_0;                   // Address (LSB)
    BYTE    bReserved_6;                    // Reserved
    BYTE    bTransferLenMSB;                // Transfer Length (High Byte)
    BYTE    bTransferLenLSB;                // Transfer Length (Low  Byte)
    BYTE    bReserved_9;                    // Reserved
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};

#pragma pack()
#endif                                      // #if defined(_AUDIO)



//-------------------------- Play Audio MSF Command ---------------------------
#if defined(_AUDIO)
#pragma pack(1)

struct  Play_Audio_MSF_Cmd_Pkt_Out          // ATAPI PLAY AUDIO MSF Command Packet
{
    BYTE    bOpCode;                        // Operation Code
    BYTE    bReserved_1;                    // Reserved
    BYTE    bReserved_2;                    // Reserved
    BYTE    bStart_M_Field;                 // Starting Minutes Field
    BYTE    bStart_S_Field;                 // Starting Seconds Field
    BYTE    bStart_F_Field;                 // Starting Frames Field
    BYTE    bEnd_M_Field;                   // Ending   Minutes Field
    BYTE    bEnd_S_Field;                   // Ending   Seconds Field
    BYTE    bEnd_F_Field;                   // Ending   Frames Field
    BYTE    bReserved_9;                    // Reserved
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};

#pragma pack()
#endif                                      // #if defined(_AUDIO)



//-------------------------- Play CD Command ----------------------------------
#if defined(_AUDIO)
#pragma pack(1)

struct  Sector_Type_MSF_Flags               // Sector Type
{
    BYTE  RESERVED_0         :  1;          // Reserved
    BYTE  MSF_FORM_CMD       :  1;          // MSF form for Play CD command
    BYTE  EXP_SECTOR_TYPE    :  3;          // Expected Sector Type
    BYTE  RESERVED_5         :  3;          // Reserved
};

struct  Speed_Output_Type_Flags             // Speed/Digital/Composite/Analog
{
    BYTE    ANALOG_AUDIO      :   1;        // Analog Audio Channel
    BYTE    COMPOSITE_VIDEO   :   1;        // Composite Video Port
    BYTE    DIGITAL_PORT_1    :   1;        // Digital Port 1
    BYTE    DIGITAL_PORT_2    :   1;        // Digital Port 2
    BYTE    RESERVED_4        :   3;        // Reserved
    BYTE    SPEED             :   1;        // Playback speed
};

struct  Play_CD_Cmd_Pkt_Out                 // ATAPI PLAY CD Command Packet
{
    BYTE    bOpCode;                        // Operation Code
    Sector_Type_MSF_Flags  SectorTypeFlags; // Sector Type
    union
    {
        BYTE    bReserved_2;                // Reserved
        BYTE    bStart_LBA_3;               // Starting (MSB)
    }  StartMSBhi;
    union
    {
        BYTE    bStart_M_Field;             // Starting Minutes Field
        BYTE    bStart_LBA_2;               // Logical
    }  StartMSBlo;
    union
    {
        BYTE    bStart_S_Field;             // Starting Seconds Field
        BYTE    bStart_LBA_1;               // Block
    }  StartLSBhi;
    union
    {
        BYTE    bStart_F_Field;             // Starting Frames Field
        BYTE    bStart_LBA_0;               // Address (LSB)
    }  StartLSBlo;
    union
    {
        BYTE    bEnd_M_Field;               // Ending Minutes Field
        BYTE    TransferLen_3;              // Transfer (MSB)
    }  TransferLenMSBhi;
    union
    {
        BYTE    bEnd_S_Field;               // Ending Seconds Field
        BYTE    TransferLen_2;              // Length
    }  TransferLenMSBlo;
    union
    {
        BYTE    bEnd_F_Field;               // Ending Frames Field
        BYTE    TransferLen_1;              // in
    }  TransferLenLSBhi;
    union
    {
        BYTE    bReserved_9;                // Reserved
        BYTE    TransferLen_0;              // Blocks (LSB)
    } TransferLenLSBlo;
    Speed_Output_Type_Flags  Speed_Output_Type; // Speed/Digital/Composite/Analog
    BYTE    bReserved_11;                   // Reserved
};

#pragma pack()
#endif                                      // #if defined(_AUDIO)



//-------------------------- Test Unit Ready Command --------------------------
#pragma pack(1)

struct  Test_Unit_Ready_Cmd_Pkt_Out         // ATAPI TEST UNIT READY Command Packet
{
    BYTE    bOpCode;                        // Operation Code
    BYTE    bReserved_1;                    // Reserved
    BYTE    bReserved_2;                    // Reserved
    BYTE    bReserved_3;                    // Reserved
    BYTE    bReserved_4;                    // Reserved
    BYTE    bReserved_5;                    // Reserved
    BYTE    bReserved_6;                    // Reserved
    BYTE    bReserved_7;                    // Reserved
    BYTE    bReserved_8;                    // Reserved
    BYTE    bReserved_9;                    // Reserved
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};

#pragma pack()



//-------------------------- Stop Play Command -------------------------------
#if defined(_AUDIO)
#pragma pack(1)

struct  Stop_Play_Cmd_Pkt_Out               // ATAPI STOP PLAY Command Packet
{
    BYTE    bOpCode;                        // Operation Code
    BYTE    bReserved_1;                    // Reserved
    BYTE    bReserved_2;                    // Reserved
    BYTE    bReserved_3;                    // Reserved
    BYTE    bReserved_4;                    // Reserved
    BYTE    bReserved_5;                    // Reserved
    BYTE    bReserved_6;                    // Reserved
    BYTE    bReserved_7;                    // Reserved
    BYTE    bReserved_8;                    // Reserved
    BYTE    bReserved_9;                    // Reserved
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};

#pragma pack()
#endif                                      // #if defined(_AUDIO)



//-------------------------- Pause/Resume Command -------------------------------
#if defined(_AUDIO)
#pragma pack(1)

struct  Pause_Resume_Flags                  // Pause/Resume Operation Mask
{
    BYTE  RESUME             :  1;          // 0=hold, 1=play
    BYTE  RESERVED_1         :  7;          // Reserved
};

struct  Pause_Resume_Cmd_Pkt_Out            // ATAPI PAUSE/RESUME Command Packet
{
    BYTE    bOpCode;                        // Operation Code
    BYTE    bReserved_1;                    // Reserved
    BYTE    bReserved_2;                    // Reserved
    BYTE    bReserved_3;                    // Reserved
    BYTE    bReserved_4;                    // Reserved
    BYTE    bReserved_5;                    // Reserved
    BYTE    bReserved_6;                    // Reserved
    BYTE    bReserved_7;                    // Reserved
    Pause_Resume_Flags    PauseResumeFlags; // Operation flags
    BYTE    bReserved_9;                    // Reserved
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};

#pragma pack()
#endif                                      // #if defined(_AUDIO)



//-------------------------- Prevent/Allow Command ----------------------------
#if defined(_AUDIO)
#pragma pack(1)

struct  Prevent_Flags                       // Prevent/Allow Operation Mask
{
    BYTE  PREVENT            :  1;          // 0=unlock, 1=lock
    BYTE  RESERVED_1         :  7;          // Reserved
};

struct  Prevent_Allow_Cmd_Pkt_Out           // ATAPI PREVENT/ALLOW MEDIUM REMOVAL
{                                           //   Command Packet
    BYTE    bOpCode;                        // Operation Code
    BYTE    bReserved_1;                    // Reserved
    BYTE    bReserved_2;                    // Reserved
    BYTE    bReserved_3;                    // Reserved
    Prevent_Flags   PreventFlags;           // Operation flags
    BYTE    bReserved_5;                    // Reserved
    BYTE    bReserved_6;                    // Reserved
    BYTE    bReserved_7;                    // Reserved
    BYTE    bReserved_8;                    // Reserved
    BYTE    bReserved_9;                    // Reserved
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};

#pragma pack()
#endif                                      // #if defined(_AUDIO)



//-------------------------- Start/Stop Unit Command --------------------------
#if defined(_AUDIO)
#pragma pack(1)

struct  Immed_Flags                         // Status Flags
{
    BYTE  IMMED              :  1;          // 0=status after completion, 1=immediately
    BYTE  RESERVED_1         :  7;          // Reserved
};

struct  Start_Stop_Eject_Flags              // Start/Stop/Eject Operation Mask
{
    BYTE  START_LOEJ         :  2;          // Operation to perform
    BYTE  RESERVED_2         :  6;          // Reserved
};

struct  Start_Stop_Unit_Cmd_Pkt_Out         // ATAPI START/STOP UNIT Command Packet
{
    BYTE    bOpCode;                        // Operation Code
    Immed_Flags     ImmedFlags;             // Status of operation
    BYTE    bReserved_2;                    // Reserved
    BYTE    bReserved_3;                    // Reserved
    Start_Stop_Eject_Flags  StartStopEjectFlags;//
    BYTE    bReserved_5;                    // Reserved
    BYTE    bReserved_6;                    // Reserved
    BYTE    bReserved_7;                    // Reserved
    BYTE    bReserved_8;                    // Reserved
    BYTE    bReserved_9;                    // Reserved
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};

#pragma pack()
#endif                                      // #if defined(_AUDIO)



//-------------------------- Read TOC Command ---------------------------------
#if defined(_AUDIO)
#pragma pack(1)

struct  ReadTOCDataHeader                   // ReadTOC data header
{
    BYTE  bTOCDataLenMSB;                   // TOC Data Length (MSB)
    BYTE  bTOCDataLenLSB;                   // TOC Data Length (LSB)
    union                                   // Note: Must be 0Ah for format=1
    {
      BYTE  bFirstTrackNum;                 // First Track Number (1-99)
      BYTE  bFirstSessionNum;               // First Session Number
    }  FirstTrackSession;
    union
    {
      BYTE  bLastTrackNum;                  // Last Track Number (1-99)
      BYTE  bLastSessionNum;                // Last Session Number
    } LastTrackSession;
};

typedef  ReadTOCDataHeader*  pReadTOCDataHeader;
                                            // Pointer to TOC Track Descriptor

struct  AdrControlFields
{
    BYTE  bControl    :  4;                 // Control
    BYTE  bADR        :  4;                 // ADR
};

struct  TOCTrackDescriptorBkwdMode          // TOC Track Descriptor (backward compatibilty mode)
{
    BYTE  bReserved_0;                      // Reserved
    AdrControlFields    AddrControlAttr;    // ADR and Control fields
    union
    {
        BYTE  bTrackNum;                    // Track Number
        BYTE  bFirstTrackInLastSession;     // First Track in Last Session
    }  TrackInSessionNum;
    BYTE  bReserved_3;                      // Reserved
    union
    {
        BYTE    bAbsLBA_3;                  // Absolute CD-ROM Address (MSB)
        BYTE    bReserved;                  // Reserved or LBA
    }  StartLBA_MSB_HI;
    union
    {
        BYTE    bAbsLBA_2;                  // Absolute CD-ROM Address
        BYTE    bAbsField_M;                // (LBA or minutes)
    }  StartLBA_MSB_LO;
    union
    {
        BYTE    bAbsLBA_1;                  // Absolute CD-ROM Address
        BYTE    bAbsField_S;                // (LBA or seconds)
    }  StartLBA_LSB_HI;
    union
    {
        BYTE    bAbsLBA_0;                  // Absolute CD-ROM Address (LSB)
        BYTE    bAbsField_F;                // (LBA or frames)
    }  StartLBA_LSB_LO;
};

typedef  TOCTrackDescriptorBkwdMode*  pTOCTrackDescriptorBkwdMode;
                                            // Pointer to TOC Track Descriptor

struct  MSF_Form_Flags                      // MSF form command
{
    BYTE  RESERVED_0         :  1;          // Reserved
    BYTE  MSF_FORM           :  1;          // 0=LBA, 1=MSF
    BYTE  RESERVED_2         :  6;          // Reserved
};

struct  TOC_Format_Flags
{
    BYTE  RESERVED_0         :  6;          // Reserved
    BYTE  TOC_FORMAT         :  2;          // Format for table of contents
};

struct  Read_TOC_Cmd_Pkt_Out                // ATAPI READ TOC Command Packet
{
    BYTE    bOpCode;                        // Operation Code
    MSF_Form_Flags     MSFformFlags;        // Format of addressing (LBA or MSF)
    BYTE    bReserved_2;                    // Reserved
    BYTE    bReserved_3;                    // Reserved
    BYTE    bReserved_4;                    // Reserved
    BYTE    bReserved_5;                    // Reserved
    union
    {
      BYTE    bStartTrack;                  // Staring Track
      BYTE    bSessionNum;                  // Session Number
    }  TrackSession;
    BYTE    bAllocLenMSB;                   // Allocation Length (MSB)
    BYTE    bAllocLenLSB;                   // Allocation Length (LSB)
    TOC_Format_Flags   TOCFormatFlags;      // TOC data format
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};

#pragma pack()
#endif                                      // #if defined(_AUDIO)



//-------------------------- Seek Command -------------------------------------
#pragma pack(1)

struct  Seek_Cmd_Pkt_Out                    // ATAPI SEEK Command Packet
{
    BYTE    bOpCode;                        // Operation Code
    BYTE    bReserved_1;                    // Reserved
    BYTE    bStart_LBA_3;                   // Starting (MSB)
    BYTE    bStart_LBA_2;                   // Logical
    BYTE    bStart_LBA_1;                   // Block
    BYTE    bStart_LBA_0;                   // Address (LSB)
    BYTE    bReserved_6;                    // Reserved
    BYTE    bReserved_7;                    // Reserved
    BYTE    bReserved_8;                    // Reserved
    BYTE    bReserved_9;                    // Reserved
    BYTE    bReserved_10;                   // Reserved
    BYTE    bReserved_11;                   // Reserved
};

#pragma pack()
