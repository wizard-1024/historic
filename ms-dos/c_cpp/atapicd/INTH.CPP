//****************************************************************************
//                              File INTH.CPP
//
//                      Interrupt handlung functions
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: d:/projects/hardware/atapicd/RCS/INTH.CPP $
//  $RCSfile: INTH.CPP $
//   $Author: dstef $
//     $Date: 2003/01/27 20:11:03 $
// $Revision: 1.2 $
//   $Locker: dstef $
//
//      $Log: INTH.CPP $
//      Revision 1.2  2003/01/27 20:11:03  dstef
//      Fixed for DJGPP
//
//      Revision 1.1  1999/01/02 01:20:02  dstef
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
#include <dos.h>		                    // Std DOS functions

#include  "compile.hpp"                     // Compilation switches
#include  "atapicd.hpp"                     // General definitions
#include  "cdrom.hpp"                       // ATAPI CD-ROM definitions
#include  "inth.hpp"                        // Interrupt handlung
#include  "fproto.hpp"                      // Function prototypes
#include  "extern.hpp"                      // External data declarations
#include  "atapi.hpp"                       // ATAPI hardware class



//---------------------------Compilation Information--------------------------
static char  rcsid[] = "$Id: INTH.CPP 1.2 2003/01/27 20:11:03 dstef Exp dstef $";              // RCS marker



//****************************************************************************
//           --- AtapiHardwareAccess::mf_LinkInterruptHandler ---
//
// Purpose: Adds interrupt handler
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 12-Sep-97
//****************************************************************************
void  AtapiHardwareAccess::mf_LinkInterruptHandler()
{
    if (m_bSoftIntNum)
    {
        g_fIntComplete = BOOL_FALSE;        // Reset complete flag
#ifdef _DEBUG
        if (g_fDebug)
            OutputMessageLF("--- Link interrupt logic ---");
#endif                                      // #ifdef _DEBUG
#if defined(__DJGPP__)
#pragma message("(13) Link interrupt logic temporarily disabled for DJGPP.")
#else
        g_lpPrevAtapiInt = _dos_getvect(m_bSoftIntNum);   // Save original interrupt vectors
        _dos_setvect(m_bSoftIntNum, NewAtapiIntHandler);  // Setup our interrupt vectors
        EnableIRQ(m_bHardIrqNum);           // Unmask hardware activity
#endif                                      // #if defined(__DJGPP__)
    }
}



//****************************************************************************
//          --- AtapiHardwareAccess::mf_UnLinkInterruptHandler ---
//
// Purpose: Removes interrupt handler
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 12-Sep-97
//****************************************************************************
void  AtapiHardwareAccess::mf_UnLinkInterruptHandler()
{
    if (m_bSoftIntNum)
    {
#ifdef _DEBUG
      if (g_fDebug)
          OutputMessageLF("--- Unlink interrupt logic ---");
#endif                                      // #ifdef _DEBUG
#if defined(__DJGPP__)
#pragma message("(14) Unlink interrupt logic temporarily disabled for DJGPP.")
#else
      DisableIRQ(m_bHardIrqNum);            // Mask hardware activity
      _dos_setvect(m_bSoftIntNum, g_lpPrevAtapiInt);
#endif                                      // #if defined(__DJGPP__)
      g_fIntComplete = BOOL_FALSE;          // Reset complete flag
      g_lpPrevAtapiInt = NULL;              // Reset pointer
    }
}



//****************************************************************************
//                        --- NewAtapiIntHandler ---
//
// Purpose: Interrupt hanlder
//   Input: none
//  Output: none
// Written: by Dmitry V.Stefankov 04-08-96
//****************************************************************************
#if defined(_WIN32)
#pragma message ("(8) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
#if defined(__BCPLUSPLUS__)
void interrupt NewAtapiIntHandler(__CPPARGS)
{
    g_fIntComplete = BOOL_TRUE;             // Indicate completion status
    g_lpPrevAtapiInt();                     // Call the old routine
}
#elif defined(_MSC_VER)                     // #if defined(__BCPLUSPLUS__)
void __interrupt __far NewAtapiIntHandler()
{
    g_fIntComplete = BOOL_TRUE;             // Indicate completion status
    (*g_lpPrevAtapiInt)();                  // Call the old routine
}
#elif defined(__WATCOMC__)                  // #if defined(__BCPLUSPLUS__)
void __interrupt __far NewAtapiIntHandler()
{
    g_fIntComplete = BOOL_TRUE;             // Indicate completion status
    (*g_lpPrevAtapiInt)();                  // Call the old routine
}
#elif defined(__DJGPP__)                    // #if defined(__BCPLUSPLUS__)
void NewAtapiIntHandler()
{
    g_fIntComplete = BOOL_TRUE;             // Indicate completion status
    (*g_lpPrevAtapiInt)();                  // Call the old routine
}
#else                                       // #if defined(__BCPLUSPLUS__)
#error Interrupt handlers no defined!
#endif                                      // #if defined(__BCPLUSPLUS_)
#endif                                      // #if defined(_WIN32)



//****************************************************************************
//                         --- EnableIRQ ---
//
// Purpose: Unmask the IR bit in IMR for PIC
//   Input: const BYTE bIrqNum - IRQ number (3-15)
//  Output: none
// Written: by Dmitry V.Stefankov 30/7/97
//****************************************************************************
void  EnableIRQ(const BYTE bIrqNum)
{
#if defined(_WIN32)
#pragma message ("(10) PIC direct programming disabled in WIN32 environment." )
#else                                       // #if defined(_WIN32)
  BYTE    bIRQ      = bIrqNum;              // IRQ number
  BYTE    bMaskPort = g_bIMR_Master;        // PIC mask register
  BYTE    bMaskVal;                         // Current mask value

  if ( bIRQ )
  {
    if ( bIRQ > 7)
    {
       bIRQ -= 8;
       bMaskPort = g_bIMR_Slave;
    }
    g_bCurImrValue = inp(bMaskPort);  // Preserve current bitmask
    bMaskVal = 1 << bIRQ;
    bMaskVal = g_bCurImrValue & (0xFF - bMaskVal);
    outp(bMaskPort,bMaskVal);         // Write new mask
  }
#endif                                      // #if defined(_WIN32)
}



//****************************************************************************
//                         --- DisableIRQ ---
//
// Purpose: Unmask the IR bit in IMR for PIC
//   Input: const BYTE bIrqNum - IRQ number (3-15)
//  Output: none
// Written: by Dmitry V.Stefankov 30/7/97
//****************************************************************************
void  DisableIRQ(const BYTE bIrqNum)
{
#if defined(_WIN32)
#pragma message ("(11) PIC direct programming disabled in WIN32 environment." )
#else                                       // #if defined(_WIN32)
  BYTE    bIRQ      = bIrqNum;              // IRQ number
  BYTE    bMaskPort = g_bIMR_Master;        // PIC mask register

  if ( bIRQ )
  {
    if ( bIRQ > 7)
    {
       bMaskPort = g_bIMR_Slave;
    }
    outp(bMaskPort,g_bCurImrValue);         // Write new mask
  }
#endif                                      // #if defined(_WIN32)
}
