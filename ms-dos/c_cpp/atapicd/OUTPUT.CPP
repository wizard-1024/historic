//****************************************************************************
//                             File OUTPUT.CPP
//
//                Console output and formatting functions
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: d:/projects/hardware/atapicd/RCS/OUTPUT.CPP $
//  $RCSfile: OUTPUT.CPP $
//   $Author: dstef $
//     $Date: 2003/01/27 20:12:29 $
// $Revision: 1.2 $
//   $Locker: dstef $
//
//      $Log: OUTPUT.CPP $
//      Revision 1.2  2003/01/27 20:12:29  dstef
//      Fixed for DJGPP
//
//      Revision 1.1  1999/01/02 01:30:15  dstef
//      Initial revision
//
//****************************************************************************



//--------------------------- Standard library modules -------------------------
#if defined(_WIN32)
#include <windows.h>                        // Windows definitions
#endif                                      // #if defined(_WIN32)
#include <stdlib.h>                         // Std system functions
#include <math.h>                           // Std math functions
#include <conio.h>                          // Direct console DOS functions
#include <dos.h>		            // Std DOS functions
#include <string.h>                         // String manipulation
#include <iostream.h>                       // I/O basic streams

#include  "compile.hpp"                     // Compilation switches
#include  "atapicd.hpp"                     // General definitions
#include  "cdrom.hpp"                       // ATAPI CD-ROM definitions
#include  "fproto.hpp"                      // Function prototypes
#include  "extern.hpp"                      // External data declarations



//---------------------------Compilation Information--------------------------
static char  rcsid[] = "$Id: OUTPUT.CPP 1.2 2003/01/27 20:12:29 dstef Exp dstef $";              // RCS marker



//****************************************************************************
//                          --- OutputMessage ---
//
// Purpose: Outputs a message to standard output device (usually console)
//   Input: const char * chMsg - Message string
//  Output: none
// Written: by Dmitry V. Stefankov 2/12/96
//****************************************************************************
void  OutputMessage(const char * chMsg)
{
    char    chUserIn;                       // Character to input

    if ( (g_wCurLinesOnPageMax != g_wDisablePaging) &&
         (g_wCurLinesOnPage >= g_wCurLinesOnPageMax) )
    {
        cout << "Press 'ENTER' to continue or any other key to exit:";
        cin.get(chUserIn);                  // Read user keystroke
        if ( chUserIn != '\n' )
        {
#if defined(_WIN32)
#pragma message ("(12) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
            if (g_lpPrevAtapiInt != NULL)
            {
#ifdef _DEBUG
                if (g_fDebug)
                    cout << "--- Remove interrupt logic ---\n";
#endif                                      // #ifdef _DEBUG
#if defined(__DJGPP__)
#pragma message ("(12A) Interrupt code temporarily disabled in DJGPP environment." )
#else
                DisableIRQ(g_bCurIrqNum);   // Mask hardware activity
                _dos_setvect(g_bCurIntNum, g_lpPrevAtapiInt);
#endif
            }
#endif                                      // #if defined(_WIN32)
            cout << "Aborted by user.\n";
            exit(g_errUserAbort);
        }
        g_wCurLinesOnPage = g_wLinesOnPageMin+1; // Must be one!
    }

    cout << chMsg;
    if ( !strcmp(chMsg, g_chEOLN) )
        g_wCurLinesOnPage++;
}



//****************************************************************************
//                         --- OutputMessageLF ---
//
// Purpose: Output message and then output linefeed
//   Input: const char * chMsg - Message to output
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputMessageLF(const char * chMsg)
{
    OutputMessage(chMsg);
    OutputMessage(g_chEOLN);
}



//****************************************************************************
//                          --- OutputHexByte ---
//
// Purpose: Output byte in hexadecimal format
//   Input: BYTE    bNum       - Value to output
//          BOOLEAN fAddPrefix - Use hexadecimal prefix (C-style)
//          BOOLEAN fAddLF     - Add linefeed switch
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputHexByte(BYTE bNum, BOOLEAN fAddPrefix, BOOLEAN fAddLF)
{
    char    chTemp[40];                     // Storage for output string

#if defined(__DJGPP__)
    itoa(bNum, chTemp, g_wHexRadix);        // Convert number to hexstring
#else
    ultoa(bNum, chTemp, g_wHexRadix);       // Convert number to hexstring
#endif                                      // #if defined(__DJGPP__)
    strupr(chTemp);                         // Make uppercase

    if (fAddPrefix)
        OutputMessage(g_chHexPrefix);
    OutputMessage(chTemp);
    if (fAddLF)
        OutputMessage(g_chEOLN);
}



//****************************************************************************
//                          --- OutputHexWord ---
//
// Purpose: Output word in hexadecimal format
//   Input: WORD    wNum       -  Value to output
//          BOOLEAN fAddPrefix -  Use hexadecimal prefix (C-style)
//          BOOLEAN fAddLF     -  Add linefeed switch
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputHexWord(WORD wNum, BOOLEAN fAddPrefix, BOOLEAN fAddLF)
{
    OutputHexByte(BYTE(wNum >> 8), fAddPrefix, g_fNoAddNewLine);   // High byte
    OutputHexByte(BYTE(wNum & 0x00FF), g_fNoAddHexPrefix, fAddLF); // Low byte
}



//****************************************************************************
//                         --- OutputHexDWord ---
//
// Purpose: Output double word in hexadecimal format
//   Input: DWORD   dwNum      -  Value to output
//          BOOLEAN fAddPrefix -  Use hexadecimal prefix (C-style)
//          BOOLEAN fAddLF     -  Add linefeed switch
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputHexDWord(DWORD dwNum, BOOLEAN fAddPrefix, BOOLEAN fAddLF)
{
    OutputHexWord( (WORD)(dwNum >> 16), fAddPrefix, g_fNoAddNewLine);      // High word
    OutputHexWord( (WORD)(dwNum & 0x0000FFFF), g_fNoAddHexPrefix, fAddLF); // Low word

}



//****************************************************************************
//                          --- OutputBoolean ---
//
// Purpose: Output boolean value in text form
//   Input: WORD    wValue -  Any value
//          BOOLEAN fAddLF -  Add line feed switch
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputBoolean(WORD wValue, BOOLEAN fAddLF)
{
    if (wValue)
        OutputMessage("yes");
    else
        OutputMessage("no");
    if (fAddLF)
        OutputMessage(g_chEOLN);
}



//****************************************************************************
//                           --- OutputByte ---
//
// Purpose: Output byte in decimal form to standard output device (console)
//   Input: BYTE bNum - Value to output
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputByte(BYTE bNum)
{
    char    chTemp[40];                     // Storage for output string

#if defined(__DJGPP__)
    itoa(bNum, chTemp, g_wDecRadix);        // Transform to decimal form
#else
    ultoa(bNum, chTemp, g_wDecRadix);       // Transform to decimal form
#endif                                      // #if defined(__DJGPP__)
    OutputMessage(chTemp);
}

//****************************************************************************
//                          --- OutputByteLF ---
//
// Purpose: Output byte in decimal form and then output linefeed
//   Input: BYTE bNum - Value to output
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputByteLF(BYTE bNum)
{
    OutputByte(bNum);
    OutputMessage(g_chEOLN);
}



//****************************************************************************
//                           --- OutputWord ---
//
// Purpose: Output word in decimal form to standard output device (console)
//   Input: WORD wNum - Value to output
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputWord(WORD wNum)
{
    char    chTemp[40];                     // Storage for output string

#if defined(__DJGPP__)
    itoa(wNum, chTemp, g_wDecRadix);        // Transform to decimal form
#else
    ultoa(wNum, chTemp, g_wDecRadix);       // Transform to decimal form
#endif                                      // #if defined(__DJGPP__)
    OutputMessage(chTemp);
}

//****************************************************************************
//                          --- OutputWordLF ---
//
// Purpose: Output word in decimal form and then output linefeed
//   Input: WORD wNum -  Value to output
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputWordLF(WORD wNum)
{
    OutputWord(wNum);
    OutputMessage(g_chEOLN);
}



//****************************************************************************
//                           --- OutputDoubleWord ---
//
// Purpose: Output doubleword in decimal form to standard output device (console)
//   Input: DWORD dwNum - Value to output
//  Output: none
// Written: by Dmitry V.Stefankov 31/08/97
//****************************************************************************
void  OutputDoubleWord(DWORD dwNum)
{
    char    chTemp[40];                     // Storage for output string

#if defined(__DJGPP__)
    itoa(dwNum, chTemp, g_wDecRadix);       // Transform to decimal form
#else
    ultoa(dwNum, chTemp, g_wDecRadix);      // Transform to decimal form
#endif                                      // #if defined(__DJGPP__)
    OutputMessage(chTemp);
}

//****************************************************************************
//                          --- OutputDoubleWordLF ---
//
// Purpose: Output doubleword in decimal form and then output linefeed
//   Input: DWORD dwNum -  Value to output
//  Output: none
// Written: by Dmitry V.Stefankov 31/08/97
//****************************************************************************
void  OutputDoubleWordLF(DWORD dwNum)
{
    OutputDoubleWord(dwNum);
    OutputMessage(g_chEOLN);
}



//****************************************************************************
//                         --- OutputDataRate ---
//
// Purpose: Output data rate based on timing cycle
//   Input: WORD wTimingCycle - ATAPI timing cycle of one word transfer
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputDataRate(WORD wTimingCycle)
{
    char      chTemp[40];                   // Buffer for conversion
    char *    pchFloatStr;                  // Output string
    double    TempVal = 2*(1.0E+9)/1.0E+6;  // (wordsize * 1ns / 1MB)

    TempVal /= wTimingCycle;
    pchFloatStr = gcvt(TempVal, 3, chTemp); // 3 digits to output
    if ( pchFloatStr )
        OutputMessage(pchFloatStr);         // Display if not NULL
}



//****************************************************************************
//                       --- OutputTransferMode ---
//
// Purpose: Output transfer mode, timing cycle and data rate
//   Input: WORD    wTransferMode -  ATAPI transfer mode
//          WORD    wTimingCycle  -  ATAPI timing cycle of one word transfer
//          BOOLEAN fAddLF        -  Add linefeed switch
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputTransferMode(WORD wTransferMode, WORD wTimingCycle, BOOLEAN fAddLF)
{
    OutputMessage("mode ");
    OutputByte(BYTE(wTransferMode));

    if (wTimingCycle)
    {
        OutputMessage(" (");
        OutputWord(wTimingCycle);
        OutputMessage(" ns, i.e. ");
        OutputDataRate(wTimingCycle);
        OutputMessage(" MB/sec)");
    }

    if (fAddLF)
        OutputMessage(g_chEOLN);
}



//****************************************************************************
//                     --- OutputModeSingleWordDMA ---
//
// Purpose: Output transfer mode, timing cycle and data rate
//          for DMA single word transfer mode
//   Input: const char* chMsg            -  Description message
//          WORD        wDmaTransferMode -  ATAPI DMA transfer mode
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputModeSingleWordDMA(const char * chMsg, WORD wDmaTransferMode)
{
    WORD    wWordTimingCycle;               // Timing for one word transfer

    if ( chMsg != NULL )
        OutputMessage(chMsg);

//------------------- Detect timing based on transfer mode -------------------

    switch (wDmaTransferMode)
    {

        case  wSW_DMA_Mode_0:
                wWordTimingCycle = wSW_DMA_Cycle_0;
                break;

        case  wSW_DMA_Mode_1:
                wWordTimingCycle = wSW_DMA_Cycle_1;
                break;

        case  wSW_DMA_Mode_2:
                wWordTimingCycle = wSW_DMA_Cycle_2;
                break;

        default:
                wWordTimingCycle = 0;
                break;

    }

    OutputTransferMode(wDmaTransferMode, wWordTimingCycle, BOOL_TRUE);
}



//****************************************************************************
//                     --- OutputModeMultiWordDMA ---
//
// Purpose: Output transfer mode, timing cycle and data rate
//          for DMA multi-word transfer mode
//   Input: const char* chMsg            -  Description message
//          WORD        wDmaTransferMode -  ATAPI DMA transfer mode
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputModeMultiWordDMA(const char * chMsg, WORD wDmaTransferMode)
{
    WORD    wWordTimingCycle;               // Timing for one word transfer

    if ( chMsg != NULL )
        OutputMessage(chMsg);

//------------------- Detect timing based on transfer mode -------------------

    switch (wDmaTransferMode)
    {

        case  wMW_DMA_Mode_0:
                wWordTimingCycle = wMW_DMA_Cycle_0;
                break;

        case  wMW_DMA_Mode_1:
                wWordTimingCycle = wMW_DMA_Cycle_1;
                break;

        case  wMW_DMA_Mode_2:
                wWordTimingCycle = wMW_DMA_Cycle_2;
                break;

        default:
                wWordTimingCycle = 0;
                break;

    }

    OutputTransferMode(wDmaTransferMode, wWordTimingCycle, BOOL_TRUE);
}



//****************************************************************************
//                          --- OutputModePIO ---
//
// Purpose: Output transfer mode, timing cycle and data rate
//          for PIO (single word) transfer mode
//   Input: const char* chMsg            -  Description message
//          WORD        wPioTransferMode -  ATAPI PIO transfer mode
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputModePIO(const char * chMsg, WORD wPioTransferMode)
{
    WORD    wWordTimingCycle;               // Timing for one word transfer

    if ( chMsg != NULL )
        OutputMessage(chMsg);

//------------------- Detect timing based on transfer mode -------------------

    switch (wPioTransferMode)
    {

    case  wPIO_Mode_0:
                wWordTimingCycle = wPIO_Cycle_0;
                break;

        case  wPIO_Mode_1:
                wWordTimingCycle = wPIO_Cycle_1;
                break;

        case  wPIO_Mode_2:
                wWordTimingCycle = wPIO_Cycle_2;
                break;

        case  wPIO_Mode_3:
                wWordTimingCycle = wPIO_Cycle_3;
                break;

        case  wPIO_Mode_4:
                wWordTimingCycle = wPIO_Cycle_4;
                break;

        default:
                wWordTimingCycle = 0;
                break;

    }

    OutputTransferMode(wPioTransferMode, wWordTimingCycle, BOOL_TRUE);
}



//****************************************************************************
//                       --- OutputTransferTime ---
//
// Purpose: Output transfer mode time (ns)
//   Input: const char* chMsg         -   Description message
//          WORD        wTransferTime -   Transfer time (ns)
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputTransferTime(const char * chMsg, WORD wTransferTime)
{
    if ( chMsg != NULL )
        OutputMessage(chMsg);
    OutputWord(wTransferTime);
    OutputMessage(" ns ");
    OutputMessage(g_chEOLN);
}



//****************************************************************************
//                        --- OutputDeviceType ---
//
// Purpose: Output ATAPI device type
//   Input: WORD wDevType - Device type
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputDeviceType(WORD wDevType)
{

    switch (wDevType)
    {

        case wDevType_DASD:
                OutputMessageLF("direct access device (DASD)");
                break;

        case wDevType_CDROM:
                OutputMessageLF("CD-ROM");
                break;

        case wDevType_OptMemDev:
                OutputMessageLF("optical memory device");
                break;

        case wDevType_Unknown:
                OutputMessageLF("unknown or no device");
                break;

        default:
                OutputMessageLF("reserved");
                break;

    }

}



//****************************************************************************
//                            --- OutputBit ---
//
// Purpose: Output logical state of one bit following a colon
//   Input: BYTE bValue - Bit value
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputBit(BYTE bValue)
{
    if (bValue)
        OutputMessage(":1");
    else
        OutputMessage(":0");
}



//****************************************************************************
//                         --- OutputBitStatus ---
//
// Purpose: Output bit state of ATAPI status register
//   Input: BYTE    bStatus -  ATAPI status register value
//          BOOLEAN fAddLF  -  Add linefeed switch
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputBitStatus(BYTE bStatus, BOOLEAN fAddLF)
{
    pATAPI_Stat_Reg_RD    pStatusReg;       // Pointer to status bit structure
    BYTE  bBitValue;                        // Temporary value

    pStatusReg = (pATAPI_Stat_Reg_RD)&bStatus;  // Initialize

//----------------------------- Output bit state -----------------------------

    OutputMessage(" (BSY");
    bBitValue = pStatusReg->BSY;
    OutputBit(bBitValue);
    OutputMessage(",DRDY");
    bBitValue = pStatusReg->DRDY;
    OutputBit(bBitValue);
    OutputMessage(",DF");
    bBitValue = pStatusReg->DMARDY_DF;
    OutputBit(bBitValue);
    OutputMessage(",DSC");
    bBitValue = pStatusReg->SRVC_DSC;
    OutputBit(bBitValue);
    OutputMessage(",DRQ");
    bBitValue = pStatusReg->DRQ;
    OutputBit(bBitValue);
    OutputMessage(",CORR");
    bBitValue = pStatusReg->CORR;
    OutputBit(bBitValue);
    OutputMessage(",D1");
    bBitValue = pStatusReg->RESERVED;
    OutputBit(bBitValue);
    OutputMessage(",CHK");
    bBitValue = pStatusReg->CHECK;
    OutputBit(bBitValue);
    OutputMessage(")");

    if (fAddLF)
        OutputMessage(g_chEOLN);
}



//****************************************************************************
//                         --- OutputBitError ---
//
// Purpose: Output bit state of ATAPI error register
//   Input: BYTE    bError -  ATAPI error register value
//          BOOLEAN fAddLF -  Add linefeed switch
//  Output: none
// Written: by Dmitry V.Stefankov 2/12/96
//****************************************************************************
void  OutputBitError(BYTE bError, BOOLEAN fAddLF)
{
    pATAPI_Err_Reg_RD    pErrorReg;         // Pointer to error bit structure
    BYTE  bBitValue;                        // Temporary value

    pErrorReg = (pATAPI_Err_Reg_RD)&bError; // Initialize


//----------------------------- Output bit state -----------------------------

    OutputMessage(" (MCR");
    bBitValue = BYTE(pErrorReg->MCR);
    OutputBit(bBitValue);
    OutputMessage(",ABRT");
    bBitValue = BYTE(pErrorReg->ABRT);
    OutputBit(bBitValue);
    OutputMessage(",EOM");
    bBitValue = BYTE(pErrorReg->EOM);
    OutputBit(bBitValue);
    OutputMessage(",ILI");
    bBitValue = BYTE(pErrorReg->ILI);
    OutputBit(bBitValue);
    OutputMessage(";sense key->");

//----------------------- Output sense key description -----------------------

    switch (pErrorReg->SENSE_KEY)
    {

            case  bNO_SENSE_SKEY:
                                OutputMessage("successful command");
                                break;

            case  bRECOVERED_ERROR_SKEY:
                                OutputMessage("lucky w/recovery");
                                break;

            case  bNOT_READY_SKEY:
                                OutputMessage("device not ready");
                                break;

            case  bMEDIUM_ERROR_SKEY:
                                OutputMessage("meduim error");
                                break;

            case  bHARDWARE_ERROR_SKEY:
                                OutputMessage("hardware failure");
                                break;

            case  bILLEGAL_REQUEST_SKEY:
                                OutputMessage("illegal parameter");
                                break;

            case  bUNIT_ATTENTION_SKEY:
                                OutputMessage("unit attention");
                                break;

            case  bDATA_PROTECT_SKEY:
                                OutputMessage("data protect");
                                break;

            case  bMISCOMPARE_SKEY:
                                OutputMessage("data miscompare");
                                break;

            case  bABORTED_COMMAND_SKEY:
                                OutputMessage("aborted command");
                                break;

            default:
                                OutputMessage("unknown/reserved");
                                break;

    }

//---------------------------- Termination output ----------------------------

    OutputMessage(")");
    if (fAddLF)
        OutputMessage(g_chEOLN);
}



//****************************************************************************
//                       --- OutputFieldasASCII ---
//
// Purpose: Output specified Motorola format field in ASCII form
//   Input: const char* chField    -  Buffer
//          WORD        wFieldSize -  Length of buffer
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  OutputFieldasASCII(const char * chField, WORD wFieldSize)
{
    WORD    wIndex;                         // Temporary counter
    char    chTemp[3];                      // Storage for string

    chTemp[2] = g_chNULL;                   // Ending zero
    wIndex    = wFieldSize/2;               // Count as words

//----------------------- Dump memory as word character -----------------------

    while ( wIndex-- )
    {
       chTemp[1] = *chField++;              // Swap bytes to display
       chTemp[0] = *chField++;              //  and advance to next char
       OutputMessage(chTemp);
    }
    OutputMessage(g_chEOLN);
}



//****************************************************************************
//                      --- OutputFieldFmtASCII ---
//
// Purpose: Output a buffer contents in ASCII form
//   Input: const char* chField    -  Buffer
//          WORD        wFieldSize -  Length of buffer
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  OutputFieldFmtASCII(const char * chField, WORD wFieldSize)
{
    char    chTemp[2];                      // Storage for string

    chTemp[1] = g_chNULL;                   // Ending zero

    while ( wFieldSize-- )
    {
        chTemp[0] = *chField++;             // Display next char
        OutputMessage(chTemp);
    }
    OutputMessage(g_chEOLN);                // Put newline
}



//****************************************************************************
//                          --- OutputSpeedX ---
//
// Purpose: Output CD-ROM drive speed in multiply value
//   Input: WORD wKBytesPerSecond -  Data rate
//          WORD wUnit            -  Divisor to get true speed value
//  Output: none
// Written: by Dmitry V.Stefankov 02-12-96
//****************************************************************************
void  OutputSpeedX(WORD wKBytesPerSecond, WORD wUnit)
{
    char      chTemp[40];                   // Buffer for conversion
    char *    pchFloatStr = &chTemp[0];     // Output string
    double    TempVal = wKBytesPerSecond;   // Multiplier for speed

    OutputMessage(" (Speed is ");
    *pchFloatStr = '\0';

//--------------------------- Search matching speed ---------------------------

    switch (wKBytesPerSecond)
    {

        case  wSpeedX1:
               OutputMessage("X1");
               break;

        case  wSpeedX2:
               OutputMessage("X2");
               break;

        case  wSpeedX2p2:
               OutputMessage("X2.2");
               break;

        case  wSpeedX3:
               OutputMessage("X3");
               break;

        case  wSpeedX4:
               OutputMessage("X4");
               break;

        case  wSpeedX8:
               OutputMessage("X8");
               break;

        case  wSpeedX16:
               OutputMessage("X16");
               break;

        default:
               TempVal /= wUnit;
               OutputMessage("~X");
               pchFloatStr = gcvt(TempVal, 3, chTemp); // 3 digits to output
               if ( pchFloatStr )
               {
                    OutputMessage(pchFloatStr); // Display if not NULL
               }
               else
                    OutputMessage("?");   // Otherwise unknown
               break;

    }
    OutputMessage(")  [X=");
    OutputWord(wUnit);
    OutputMessageLF(" KB/s]");

}



//****************************************************************************
//                        --- OutputMediumType ---
//
// Purpose: Output medium type detected by CD-ROM drive
//   Input: BYTE bMediumCode -  Disc medium type code
//  Output: none
// Written: by Dmitry V.Stefankov 02-18-96
//****************************************************************************
void  OutputMediumType(BYTE bMediumCode)
{
    OutputHexByte(bMediumCode, g_fAddHexPrefix, g_fNoAddNewLine);

    switch  (bMediumCode)
    {
        case 0x00:
                OutputMessageLF(" (door closed / caddy inserted, medium type unknown)");
                break;

        case 0x01:
                OutputMessageLF(" (120 mm CD-ROM data only, door closed or caddy inserted)");
                break;

        case 0x02:
                OutputMessageLF(" (120 mm CD-DA audio only, door closed or caddy inserted)");
                break;

        case 0x03:
                OutputMessageLF(" (120 mm CD-DA data and audio combined, door closed or caddy inserted)");
                break;

        case 0x04:
                OutputMessageLF(" (120 mm CD-ROM Hybrid disc (Photo CD), door closed or caddy inserted)");
                break;

        case 0x05:
                OutputMessageLF(" (80 mm CD-ROM data only, door closed or caddy inserted)");
                break;

        case 0x06:
                OutputMessageLF(" (80 mm CD-DA audio only, door closed or caddy inserted)");
                break;

        case 0x07:
                OutputMessageLF(" (80 mm CD-DA data and audio combined, door closed or caddy inserted)");
                break;

        case 0x08:
                OutputMessageLF(" (80 mm CD-ROM Hybrid disc (Photo CD), door closed or caddy inserted)");
                break;

        case 0x10:
                OutputMessageLF(" (door closed / caddy inserted, medium type (CD-R) size unknown)");
                break;

        case 0x11:
                OutputMessageLF(" (120 mm CD-ROM (CD-R) data only, door closed or caddy inserted)");
                break;

        case 0x12:
                OutputMessageLF(" (120 mm CD-DA (CD-R) audio only, door closed or caddy inserted)");
                break;

        case 0x13:
                OutputMessageLF(" (120 mm CD-DA (CD-R) data and audio combined, door closed or caddy inserted)");
                break;

        case 0x14:
                OutputMessageLF(" (120 mm CD-ROM (CD-R) Hybrid disc (Photo CD), door closed or caddy inserted)");
                break;

        case 0x15:
                OutputMessageLF(" (80 mm CD-ROM (CD-R) data only, door closed or caddy inserted)");
                break;

        case 0x16:
                OutputMessageLF(" (80 mm CD-DA (CD-R) audio only, door closed or caddy inserted)");
                break;

        case 0x17:
                OutputMessageLF(" (80 mm CD-DA (CD-R) data and audio combined, door closed or caddy inserted)");
                break;

        case 0x18:
                OutputMessageLF(" (80 mm CD-ROM (CD-R) Hybrid disc (Photo CD), door closed or caddy inserted)");
                break;

        case 0x20:
                OutputMessageLF(" (door closed / caddy inserted, medium type (CD-E) size unknown)");
                break;

        case 0x21:
                OutputMessageLF(" (120 mm CD-ROM (CD-E) data only, door closed or caddy inserted)");
                break;

        case 0x22:
                OutputMessageLF(" (120 mm CD-DA (CD-E) audio only, door closed or caddy inserted)");
                break;

        case 0x23:
                OutputMessageLF(" (120 mm CD-DA (CD-E) data and audio combined, door closed or caddy inserted)");
                break;

        case 0x24:
                OutputMessageLF(" (120 mm CD-ROM (CD-E) Hybrid disc (Photo CD), door closed or caddy inserted)");
                break;

        case 0x25:
                OutputMessageLF(" (80 mm CD-ROM (CD-E) data only, door closed or caddy inserted)");
                break;

        case 0x26:
                OutputMessageLF(" (80 mm CD-DA (CD-E) audio only, door closed or caddy inserted)");
                break;

        case 0x27:
                OutputMessageLF(" (80 mm CD-DA (CD-E) data and audio combined, door closed or caddy inserted)");
                break;

        case 0x28:
                OutputMessageLF(" (80 mm CD-ROM (CD-E) Hybrid disc (Photo CD), door closed or caddy inserted)");
                break;

        case 0x30:
                OutputMessageLF(" (door closed / caddy inserted, medium type uknown)");
                break;

        case 0x31:
                OutputMessageLF(" (120 mm (HD) door closed or caddy inserted)");
                break;

        case 0x35:
                OutputMessageLF(" (80 mm (HD) door closed or caddy inserted)");
                break;

        case 0x70:
                OutputMessageLF(" (door closed, no disc present)");
                break;

        case 0x71:
                OutputMessageLF(" (door open or no caddy inserted)");
                break;

        case 0x72:
                OutputMessageLF(" (door closed or caddy inserted, medium format error)");
                break;

        default:
                OutputMessageLF(" (reserved or vendor-specific)");
                break;

    }

}



//****************************************************************************
//                    --- OutputPageSaveableStatus ---
//
// Purpose: Output a capable of parameters saveable status
//   Input: BYTE bSaveableStatus -  Saveable capability flag
//  Output: none
// Written: by Dmitry V.Stefankov 02-22-96
//****************************************************************************
void  OutputPageSaveableStatus(BYTE bSaveableStatus)
{
    if (bSaveableStatus)
        OutputMessageLF("Drive is capable of saving the page in vendor's NVS.");
}



//****************************************************************************
//                     --- OutputPortChannelSelect ---
//
// Purpose: Output a port selection code
//   Input: BYTE bSelectCode - Channel and code connection
//  Output: none
// Written: by Dmitry V.Stefankov 02-23-96
//****************************************************************************
void  OutputPortChannelSelect(BYTE bSelectCode)
{

    switch  (bSelectCode)
    {
        case 0:
                OutputMessageLF("muted");
                break;

        case 1:
                OutputMessageLF("connected with audio channel 0");
                break;

        case 2:
                OutputMessageLF("connected with audio channel 1");
                break;

        case 3:
                OutputMessageLF("connected with audio channels 0 and 1");
                break;

        case 4:
                OutputMessageLF("connected with audio channel 2");
                break;

        case 8:
                OutputMessageLF("connected with audio channel 3");
                break;

        default:
                OutputMessageLF("unknown");
                break;

    }

}



//****************************************************************************
//                        --- OutputPortVolume ---
//
// Purpose: Output a binary and attenuation level for audio
//   Input: BYTE bBinaryLevel - Binary level for audio
//  Output: none
// Written: by Dmitry V.Stefankov 02-23-96
//****************************************************************************
void  OutputPortVolume(BYTE bBinaryLevel)
{
    char      chTemp[40];                   // Buffer for conversion
    char *    pchFloatStr;                  // Output string
    double    TempVal;                      // Attenuation Level

    OutputByte(bBinaryLevel);

    switch  (bBinaryLevel)
    {

        case 0:
                 OutputMessageLF(" (mute,off)");
                 break;

        case 0xFF:
                 OutputMessageLF(" (0db,on)");
                 break;

        default:
                 TempVal = 20 * log10((double)bBinaryLevel/256);
                 OutputMessage(" (");
                 pchFloatStr = gcvt(TempVal, 3, chTemp); // 3 digits to output
                 if ( pchFloatStr )
                     OutputMessage(pchFloatStr); // Display if not NULL
                 else
                     OutputMessage("?");    // Otherwise unknown
                 OutputMessageLF(")");
                 break;

    }

}



//****************************************************************************
//                       --- OutputHoldTrackTime ---
//
// Purpose: Ouput a minimum hold track time
//   Input: BYTE bInactiveTimerMultiplier - Inactivity timer multiplier
//  Output: none
// Written: by Dmitry V.Stefankov 02-23-96
//****************************************************************************
void  OutputHoldTrackTime(BYTE bInactiveTimerMultiplier)
{

    switch  (bInactiveTimerMultiplier)
    {

        case  0x00:
                 OutputMessageLF("vendor-specific");
                 break;

        case  0x01:
                 OutputMessageLF("125 ms");
                 break;

        case  0x02:
                 OutputMessageLF("250 ms");
                 break;

        case  0x03:
                 OutputMessageLF("500 ms");
                 break;

        case  0x04:
                 OutputMessageLF("1 s");
                 break;

        case  0x05:
                 OutputMessageLF("2 s");
                 break;

        case  0x06:
                 OutputMessageLF("4 s");
                 break;

        case  0x07:
                 OutputMessageLF("8 s");
                 break;

        case  0x08:
                 OutputMessageLF("16 s");
                 break;

        case  0x09:
                 OutputMessageLF("32 s");
                 break;

        case  0x0A:
                 OutputMessageLF("1 min");
                 break;

        case  0x0B:
                 OutputMessageLF("2 min");
                 break;

        case  0x0C:
                 OutputMessageLF("4 min");
                 break;

        case  0x0D:
                 OutputMessageLF("8 min");
                 break;

        case  0x0E:
                 OutputMessageLF("16 min");
                 break;

        case  0x0F:
                 OutputMessageLF("32 min");
                 break;

        default:
                 OutputMessageLF("unknown");
                 break;

    }

}



//****************************************************************************
//                    --- OutputWarnNonAtapiDev ---
//
// Purpose: Output a warning message about non-ATAPI device
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 4-Sep-97
//****************************************************************************
void  OutputWarnNonAtapiDev()
{
   OutputMessageLF("!!! I see your device is not ATAPI-compatible.");
}



//****************************************************************************
//                    --- OutputWarnNotReadyDev ---
//
// Purpose: Output a warning message about not ready device
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 4-Sep-97
//****************************************************************************
void  OutputWarnNotReadyDev()
{
   OutputMessageLF("-> No ready drive, exit after timeout expiration.");
}



//****************************************************************************
//                    --- OutputAudioPlayInProgress ---
//
// Purpose: Output a message about starting audio disc playing
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 6-Sep-97
//****************************************************************************
void  OutputAudioPlayInProgress()
{
   OutputMessageLF("---Audio playing must be in progress---");
}



//****************************************************************************
//                    --- OutputInputLBA ---
//
// Purpose: Dump input parameters for play audio command
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 7-Sep-97
//****************************************************************************
void  OutputInputLBA(DWORD dwStartBlock, DWORD dwEndBlock)
{
        OutputMessage("--- Starting LBA: ");
        OutputDoubleWord(dwStartBlock);
        OutputMessage(";   Ending LBA: ");
        OutputDoubleWordLF(dwEndBlock);
}
