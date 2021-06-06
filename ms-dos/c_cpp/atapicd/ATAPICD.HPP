//****************************************************************************
//                            File ATAPICD.HPP
//
//                          General definitions
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BC31/SOURCE/ATAPICD/RCS/atapicd.hpp $
//  $RCSfile: atapicd.hpp $
//   $Author: dstef $
//     $Date: 1999/12/31 19:57:29 $
// $Revision: 1.2 $
//   $Locker: dstef $
//
//      $Log: atapicd.hpp $
//      Revision 1.2  1999/12/31 19:57:29  dstef
//      Minor changes
//
//      Revision 1.1  1999/01/02 00:23:28  dstef
//      Initial revision
//
//
//****************************************************************************



//---------------------------User types----------------------------------------
#ifndef  BYTE
typedef   unsigned char       BYTE;
typedef   BYTE                BOOLEAN;
#if !defined(_WIN32)
typedef   unsigned int        WORD;
#endif                                      // #if !defined(_WIN32)
typedef   unsigned long int   DWORD;
typedef   char *              PCHAR;
typedef   BOOLEAN *           PBOOLEAN;
typedef   BYTE *              PBYTE;
typedef   WORD *              PWORD;
typedef   DWORD *             PDWORD;

#define   BOOL_FALSE   0
#define   BOOL_TRUE    1
#endif                                      // #ifndef BYTE


#define     g_wMsgTableIdx          7
#define     g_wLangTableIdx         2
#define     g_wMsgTableIdxMin       0
#define     g_wMsgTableIdxMax       g_wMsgTableIdx-1
#define     g_wLangTableIdxMin      0
#define     g_wLangTableIdxMax      g_wLangTableIdx-1

#define      g_wMsgTableCopyright             g_wMsgTableIdxMin
#define  g_wMsgTableAuthor                    g_wMsgTableCopyright+1
#define  g_wMsgTablePurpose                   g_wMsgTableAuthor+1
#define  g_wMsgTableDone                      g_wMsgTablePurpose+1
#define  g_wMsgTableModuleName                g_wMsgTableDone+1
#define  g_wMsgTableCompilationDate           g_wMsgTableModuleName+1
#define  g_wMsgTableEvaluationVersion         g_wMsgTableCompilationDate+1



//---------------------------ASCII definitions---------------------------------
const   char  g_chBlank[]        =  " ";
const   char  g_chComma[]        =  ",";
const   char  g_chPoint[]        =  ".";
const   char  g_chEqual[]        =  "=";
const   char  g_chColon[]        =  ":";
const   char  g_chEOLN[]         =  "\n";
const   char  g_chHexPrefix[]    =  "0x";
const   char  g_chNULL           =  '\0';



//---------------------------International support-----------------------------
#define  g_wLangEnglish      0
#define  g_wLangRussian      1
#define  g_wLangMin          g_wLangEnglish
#define  g_wLangDef          g_wLangEnglish
#define  g_wLangMax          g_wLangRussian



//---------------------------Paged output--------------------------------------
#define g_wDisablePaging          0         // Turn off paged output
#define g_wLinesOnPageMin           0       // Minimum value
#define     g_wLinesOnPageDef       24      // Default value
#define     g_wLinesOnPageMax      4096     // Maximum value



//---------------------------Exit codes----------------------------------------
#define  g_errTerminateOk          0        // Successful complete
#define  g_errUserAbort            1        // Aborted by user request
#define  g_errUserHelpScreen       2        // User asked help screen
#define  g_errBadUserParam         3        // Bad parameter in command line



//---------------------------Miscellaneous-------------------------------------
const   WORD  g_wDecRadix             =  10;  // Decimal base
const   WORD  g_wHexRadix             =  16;  // Hexadecimal base

const   BYTE  g_bInt0x72              =  0x72; // PC interrupt for IRQ10
const   BYTE  g_bInt0x73              =  0x73; // PC interrupt for IRQ11
const   BYTE  g_bInt0x74              =  0x74; // PC interrupt for IRQ12
const   BYTE  g_bInt0x75              =  0x75; // PC interrupt for IRQ13
const   BYTE  g_bInt0x76              =  0x76; // PC interrupt for IRQ14
const   BYTE  g_bInt0x77              =  0x77; // PC interrupt for IRQ15
const   BYTE  g_bIMR_Master           =  0x21; // PIC-1 IMR
const   BYTE  g_bIMR_Slave            =  0xA1; // PIC-2 IMR

const   DWORD g_dwTimeoutDef          =  150000L; // Default timeout software loop
const   WORD  g_wWaitCmd              =  1000; // Wait after command
const   WORD  g_dwWaitAudioCmd        =  0xFFFF;// Wait command completion
const   WORD  g_wWaitCmdBIOSticks     =  10;  // Wait 10 seconds (ticks*18)
const   BYTE  g_bRetryNumber          =  5;   // Attempts to get true data
const   BYTE  g_bRetryTestUnit        =  3;   // Attempts to test unit ready
const   WORD  g_wDosFileNameSize      =  13;  // Famous 8+3 name
const   WORD  g_wBiosStdTicksPerSec   =  18;  // 18.2 times per second
const   BYTE  g_bAudioDiskPlay        =  2;   // This cdrom drive must play
const   BYTE  g_bLeadOutAreaID        =  0xAA;// Terminator for audio tracks
const   WORD  g_wBackBlocks           =  3;   // Undo blocks to stop playback
const   WORD  g_wBlocksPerFrameStd    =  75;  // Blocks per one frame
const   BYTE  g_bSecsPerMinStd        =  60;  // Seconds per one minute
const   WORD  g_wLeadInAreaBack       =  150; // Lead-in area size (?)
const   WORD  g_wMaxMinsOnDisc        =  76+2;// Minutes to play disc (max)
const   DWORD g_dwMaxBlocksOnDisc     =  (DWORD)g_wMaxMinsOnDisc *
                                         (DWORD)g_bSecsPerMinStd *
                                         (DWORD)g_wBlocksPerFrameStd;



//------------------------------- Bit constants -------------------------------
enum
{
     BIT_0      =  0x01,
     BIT_1      =  0x02,
     BIT_2      =  0x04,
     BIT_3      =  0x08,
     BIT_4      =  0x10,
     BIT_5      =  0x20,
     BIT_6      =  0x40,
     BIT_7      =  0x80
};



//----------------------------- Boolean constants -----------------------------

const   BOOLEAN g_fAddHexPrefix     =  BOOL_TRUE;   // Add hexadecimal prefix
const   BOOLEAN g_fNoAddHexPrefix   =  BOOL_FALSE;  // No add hexadecimal prefix
const   BOOLEAN g_fAddNewLine       =  BOOL_TRUE;   // Add newline
const   BOOLEAN g_fNoAddNewLine     =  BOOL_FALSE;  // No add newline



//------------------------------ Parameter Types ------------------------------
const   char    g_chTypeIsByte     =   'b';
const   char    g_chTypeIsWord     =   'w';
const   char    g_chTypeIsString   =   's';



//---------------------------Structures Definitions----------------------------
struct sBoolParameter
{
    BOOLEAN  fMinValue;                     // Minimum
    BOOLEAN  fDefValue;                     // Default
    BOOLEAN  fMaxValue;                     // Maximum
};

struct sByteParameter
{
    BYTE  bMinValue;                        // Minimum
    BYTE  bDefValue;                        // Default
    BYTE  bMaxValue;                        // Maximum
};

struct sWordParameter
{
    WORD  wMinValue;                        // Minimum
    WORD  wDefValue;                        // Default
    WORD  wMaxValue;                        // Maximum
};

struct sStringParameter
{
    PCHAR  pchMinValue;                     // Minimum
    PCHAR  pchDefValue;                     // Default
    PCHAR  pchMaxValue;                     // Maximum
};

#pragma pack(1)
struct sParameter
{
    const char *  ParmName;                 // Parameter name
    char   ParmType;                        // Parameter type
    void * pAnyValue;                       // Any value parameter
    void * pVarAddr;                        // Variable address
};
#pragma pack()
