//****************************************************************************
//                               File SB.CPP
//
//                Sound Blaster card hardware functions
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BC31/SOURCE/ATAPICD/RCS/sb.cpp $
//  $RCSfile: sb.cpp $
//   $Author: dstef $
//     $Date: 1999/01/02 01:30:37 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: sb.cpp $
//      Revision 1.1  1999/01/02 01:30:37  dstef
//      Initial revision
//
//
//****************************************************************************


//--------------------------- Standard library modules -------------------------
#if defined(_WIN32)
#include <windows.h>                        // Windows definitions
#endif                                      // #if defined(_WIN32)
#include <conio.h>                          // Direct console DOS functions

#include  "compile.hpp"                     // Compilation switches
#include  "atapicd.hpp"                     // General definitions
#include  "sb.hpp"                          // Sound Blaster
#include  "fproto.hpp"                      // Function prototypes
#include  "extern.hpp"                      // External data declarations



#if defined(_SOUNDBLASTER)
//---------------------------Compilation Information--------------------------
static char  rcsid[] = "$Id: sb.cpp 1.1 1999/01/02 01:30:37 dstef Exp dstef $";              // RCS marker



//****************************************************************************
//                    --- WriteByteSB ---
//
// Purpose: Output a byte to hardware port
//   Input: WORD  wPort   -  hardware port
//          BYTE bValue   -  data value
//  Output: none
// Written: by Dmitry V.Stefankov 6-Sep-97
//****************************************************************************
void  WriteByteSB(WORD wPort, BYTE bValue)
{
#if defined(_WIN32)
#pragma message ("(15) Direct I/O ports access must be updated in Win32 environment." )
   {/*empty*/ };
#else                                       // #if defined(_WIN32)
   outp(wPort, bValue);
#endif                                      // #if defined(_WIN32)
}



//****************************************************************************
//                    --- ReadByteSB ---
//
// Purpose: Read a byte from hardware port
//   Input: WORD  wPort   -  hardware port
//  Output: BYTE  -  data value
// Written: by Dmitry V.Stefankov 6-Sep-97
//****************************************************************************
BYTE  ReadByteSB(WORD wPort)
{
#if defined(_WIN32)
#pragma message ("(16) Direct I/O ports access must be updated in Win32 environment." )
   return( 0xFF );
#else                                       // #if defined(_WIN32)
   return( inp(wPort) );
#endif                                      // #if defined(_WIN32)
}



//****************************************************************************
//                    --- WriteIndexByteSB ---
//
// Purpose: Output a data byte to hardware port
//   Input: WORD  wRegPort   -  hardware index port
//          BYTE  bIndex     -  index value
//          WORD  wDatPort   -  hardware data port
//          BYTE  bData      -  data value
//  Output: none
// Written: by Dmitry V.Stefankov 6-Sep-97
//****************************************************************************
void  WriteIndexByteSB(WORD wRegPort, BYTE bIndex,
                       WORD wDatPort, BYTE bData)
{
   WriteByteSB(wRegPort, bIndex);           // Write index register
   WriteByteSB(wDatPort, bData);            // Write data  register
}



//****************************************************************************
//                    --- DetectSoundBlaster ---
//
// Purpose: Detects Sound Blaster card
//   Input: WORD  wBaseAddr   -  Base hardware address
//  Output: BOOLEAN  -  FALSE  no SB card found
//                      TRUE   SB card found
// Written: by Dmitry V.Stefankov 6-Sep-97
//****************************************************************************
BOOLEAN  DetectSoundBlaster(WORD wBaseAddr)
{
     WORD       wResetPort;                 // SB reset port
     WORD       wTimeOut;                   // Timeout value
     BYTE       bTempValue;                 // Temporary
     BOOLEAN    fFuncResult = BOOL_FALSE;   // Function Result

     if ( !wBaseAddr )
     {
#ifdef _DEBUG
        if (g_fDebug)
          OutputMessageLF("---No detect SoundBlaster card ---");
#endif                                      // #ifdef _DEBUG
        return( fFuncResult );
     }

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Detect SoundBlaster card ---");
#endif                                      // #ifdef _DEBUG

     wResetPort = wBaseAddr + dspoffsetReset;
     WriteByteSB( wResetPort, 1 );       // Assume that reset card
     WaitBiosTicksSec18(1);
     WriteByteSB( wResetPort, 0 );       // Assume that enable card
     wTimeOut = 100;
     do
     {
       bTempValue = ReadByteSB(wBaseAddr+dspoffsetDataAvail );
     } while ( ( !(bTempValue & 0x80)) && (--wTimeOut) );
     if (wTimeOut)
     {
        bTempValue = ReadByteSB(wBaseAddr+dspoffsetReadData);
        if ( bTempValue == dspReady )
          fFuncResult = BOOL_TRUE;
     }

#ifdef _DEBUG
    if (g_fDebug)
    {
      if ( fFuncResult == BOOL_TRUE )
      {
        OutputMessage(".....SoundBlaster card found at address ");
        OutputHexWord( wBaseAddr, g_fAddHexPrefix, g_fNoAddNewLine );
        OutputMessageLF(".");
      }
      else
      {
        OutputMessageLF(".....No SoundBlaster card detected.");
      }
    }
#endif                                      // #ifdef _DEBUG

    return( fFuncResult );

}



//****************************************************************************
//                    --- InitSoundBlaster ---
//
// Purpose: Inits Sound Blaster card
//   Input: WORD wBaseAddr    -  Base hardware address
//  Output: none
// Written: by Dmitry V.Stefankov 6-Sep-97
//****************************************************************************
void  InitSoundBlaster(WORD wBaseAddr)
{
     if ( !wBaseAddr )
     {
#ifdef _DEBUG
        if (g_fDebug)
          OutputMessageLF("---No SoundBlaster card ---");
#endif                                      // #ifdef _DEBUG
        return;
     }

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Init SoundBlaster card ---");
#endif                                      // #ifdef _DEBUG
    // Input/Filter Select=CD Audio, Highpass, Filter off
    WriteIndexByteSB(wBaseAddr+dspoffsetMixerAddr, ADCSELECT,
                     wBaseAddr+dspoffsetMixerData, 0x20 + (0x1 << 1) );
    // CD Audio Level = Maximum level
    WriteIndexByteSB(wBaseAddr+dspoffsetMixerAddr, CDVOL,
                     wBaseAddr+dspoffsetMixerData, 0xFF );

    OutputMessageLF(".....SB card init done.");

    return;
}



//****************************************************************************
//                    --- DeinitSoundBlaster ---
//
// Purpose: Disable Sound Blaster card
//   Input: WORD wBaseAddr    -  Base hardware address
//  Output: none
// Written: by Dmitry V.Stefankov 6-Sep-97
//****************************************************************************
void  DeinitSoundBlaster(WORD wBaseAddr)
{
     if ( !wBaseAddr )
     {
#ifdef _DEBUG
        if (g_fDebug)
          OutputMessageLF("---No SoundBlaster card ---");
#endif                                      // #ifdef _DEBUG
        return;
     }

#ifdef _DEBUG
    if (g_fDebug)
        OutputMessageLF("---Deinit SoundBlaster card ---");
#endif                                      // #ifdef _DEBUG
    // Input/Filter Select=Microphone, Lowhpass, Filter on
    WriteIndexByteSB(wBaseAddr+dspoffsetMixerAddr, ADCSELECT,
                     wBaseAddr+dspoffsetMixerData, 0x0 );
    // CD Audio Level = Mimimum level
    WriteIndexByteSB(wBaseAddr+dspoffsetMixerAddr, CDVOL,
                     wBaseAddr+dspoffsetMixerData, 0x0 );

    OutputMessageLF(".....SB card deinit done.");

    return;
}
#endif                                      // #if defined(_SOUNDBLASTER)
