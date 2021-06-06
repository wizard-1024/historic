//****************************************************************************
//                              File MISC.CPP
//
//                   Miscellaneous support functions
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: d:/projects/hardware/atapicd/RCS/MISC.CPP $
//  $RCSfile: MISC.CPP $
//   $Author: dstef $
//     $Date: 2003/02/04 16:20:01 $
// $Revision: 1.3 $
//   $Locker: dstef $
//
//      $Log: MISC.CPP $
//      Revision 1.3  2003/02/04 16:20:01  dstef
//      Changed waiting routine for DJGPP
//
//      Revision 1.2  2003/01/27 20:12:11  dstef
//      Fixed for DJGPP
//
//      Revision 1.1  1999/01/02 01:21:09  dstef
//      Initial revision
//
//
//****************************************************************************



//--------------------------- Standard library modules -------------------------
#if defined(_WIN32)
#include <windows.h>                        // Windows definitions
#endif                                      // #if defined(_WIN32)
#include <dos.h>                            // Std DOS functions
#include <fstream.h>                        // File i/o stream classes
#if defined(__DJGPP__)
#include <go32.h>                           // PC machine specific definitions
#include <sys/farptr.h>                     // Far ptr simulation classes
#include <iostream.h>                       // Std i/o stream classes
#endif                                      // #if defined(__DJGPP__)

#include  "compile.hpp"                     // Compilation switches
#include  "atapicd.hpp"                     // General definitions
#include  "fproto.hpp"                      // Function prototypes
#include  "extern.hpp"                      // External data declarations



//---------------------------Compilation Information--------------------------
static char  rcsid[] =  "$Id: MISC.CPP 1.3 2003/02/04 16:20:01 dstef Exp dstef $";             // RCS marker



//****************************************************************************
//                         --- WaitBiosTicksSec18 ---
//
// Purpose: Wait 1/18 of second using BIOS timer ticks
//   Input: const DWORD wUserTicks - ticks to wait
//  Output: none
// Written: by Dmitry V.Stefankov 30/7/97
//****************************************************************************
void  WaitBiosTicksSec18(const DWORD dwUserTicks)
{
#if defined(_WIN32)
#pragma message ("(9) Waiting function must be tested in WIN32 environment." )
  Sleep( g_wBiosStdTicksPerSec*dwUserTicks );
#elif defined(__DJGPP__)
  DWORD   dwInitialValue;                   // Temporary storage
  DWORD   dwCurrentValue;
  dwInitialValue = _farpeekl(_dos_ds, 0x46c);
  if ( dwUserTicks )
  {
     do
     {
       dwCurrentValue = _farpeekl(_dos_ds, 0x46c);
     } while (dwCurrentValue <= (dwInitialValue+dwUserTicks) );
  }
#else                                       // #if defined(_WIN32)
  PDWORD  pdwBiosTimer = (PDWORD)MK_FP(0x40,0x6C);
                                            // BIOS timer ticks location
  DWORD   dwInitialValue;                   // Temporary storage
  dwInitialValue = *pdwBiosTimer;
  if ( dwUserTicks )
  {
     do
     {
       // empty
     } while (*pdwBiosTimer <= (dwInitialValue+dwUserTicks) );
  }
#endif                                      // #if defined(_WIN32)
}



//****************************************************************************
//                         --- WriteBinaryFile ---
//
// Purpose: Write a binary data buffer to a disk file
//   Input: const char* chFileName - User supplied filename
//          PBYTE       pbBuf      - Pointer to binary data buffer
//          WORD        wBufSize   - Size of buffer to write
//  Output: none
// Written: by Dmitry V.Stefankov 04-03-96
//****************************************************************************
void  WriteBinaryFile(const char * chFileName, PBYTE pbBuf, WORD wBufSize)
{
    ofstream outstream(chFileName,ios::out|ios::binary);
    while (wBufSize--) { outstream.put(*pbBuf++); }
    outstream.close();
}



//****************************************************************************
//                         --- Hsg2Red---
//
// Purpose: Converts HSG (LBA) address to Read Book address (MSF)
//   Input: const DWORD dwLBA     - HSG address
//          PBYTE       pbMinutes - Pointer to minutes
//          PBYTE       pbSeconds - Pointer to seconds
//          PBYTE       pbFrames  - Pointer to frames
//  Output: none
// Written: by Dmitry V.Stefankov 02-09-97
//****************************************************************************
void  Hsg2Red(const DWORD dwLBA, PBYTE pbMinutes, PBYTE pbSeconds, PBYTE pbFrames)
{
    DWORD       dwTempLBA   =   dwLBA;      // Temporary

    dwTempLBA = ( dwTempLBA + g_wLeadInAreaBack );
    *pbMinutes = (BYTE)( dwTempLBA / (g_bSecsPerMinStd*g_wBlocksPerFrameStd) );
    dwTempLBA -= ((DWORD)*pbMinutes*g_bSecsPerMinStd*g_wBlocksPerFrameStd);
    *pbSeconds = (BYTE)( dwTempLBA / g_wBlocksPerFrameStd );
    *pbFrames = (BYTE)( dwTempLBA - ((DWORD)*pbSeconds*g_wBlocksPerFrameStd) );
}



//****************************************************************************
//                         --- Red2HSG---
//
// Purpose: Converts Read Book address (MSF) to HSG (LBA) address
//   Input: BYTE   pbMinutes - minutes
//          BYTE   pbSeconds - seconds
//          BYTE   pbFrames  - frames
//  Output: DWORD  dwLBA     - HSG address
// Written: by Dmitry V.Stefankov 02-09-97
//****************************************************************************
DWORD  Red2Hsg(const BYTE bMinutes, const BYTE bSeconds, const BYTE bFrames)
{
  DWORD     dwLBA;                          // HSG address

  dwLBA = ( (DWORD)bMinutes * g_bSecsPerMinStd + bSeconds) * g_wBlocksPerFrameStd + bFrames - g_wLeadInAreaBack;
  return( dwLBA );
}
