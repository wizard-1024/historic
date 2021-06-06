//****************************************************************************
//                            File COMPILE.HPP
//
//                         Compilation switches
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: d:/projects/hardware/atapicd/RCS/COMPILE.HPP $
//  $RCSfile: COMPILE.HPP $
//   $Author: dstef $
//     $Date: 2003/02/04 16:21:35 $
// $Revision: 1.3 $
//   $Locker: dstef $
//
//      $Log: COMPILE.HPP $
//      Revision 1.3  2003/02/04 16:21:35  dstef
//      Minor fixes for DJGPP
//
//      Revision 1.2  2003/01/27 20:10:00  dstef
//      Added support for DJGPP
//
//      Revision 1.1  1999/01/02 01:10:05  dstef
//      Initial revision
//
//
//****************************************************************************



//------------------------Compliation switches---------------------------------
#if defined(_DEBUG)
#pragma message (" (0) Debugging version already in progress." )
#else
#define   _DEBUG                            // Debugging version
#endif                                      // #if defined(_DEBUG)

#define   _EVAL                             // Evaluation release
#define   _BETA                             // Beta-version

#if defined(_AUDIO)
#pragma message (" (0a) Audio extensions already enabled." )
#else
#define   _AUDIO                            // Audio CD player version
#endif                                      // #if defined(_AUDIO)

#if defined(_SOUNDBLASTER)
#pragma message (" (0b) Audio extensions already enabled." )
#else
#define   _SOUNDBLASTER                     // Sound Blaster card support
#endif                                      // #if defined(_SOUNDBLASTER)


#if defined(_ATA_CMDS)
#pragma message (" (0c) ATA commands extensions already enabled." )
#else
#define   _ATA_CMDS                         // CD-ROM ATA Commands
#endif                                      // #if defined(_ATA_CMDS)

#if defined(__DJGPP__)
#include <unistd.h>
#include <pc.h>
#endif                                      // #if defined(__DJGPP__)
