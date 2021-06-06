//****************************************************************************
//                              File INTH.HPP
//
//                   Interrupt handling definitions
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: d:/projects/hardware/atapicd/RCS/INTH.HPP $
//  $RCSfile: INTH.HPP $
//   $Author: dstef $
//     $Date: 2003/01/27 20:11:14 $
// $Revision: 1.2 $
//   $Locker: dstef $
//
//      $Log: INTH.HPP $
//      Revision 1.2  2003/01/27 20:11:14  dstef
//      Fixed for DJGPP
//
//      Revision 1.1  1999/01/02 01:20:19  dstef
//      Initial revision
//
//
//****************************************************************************



//---------------------------- Interrupt handlers ----------------------------

#if defined(_WIN32)
#pragma message ("(1) Interrupt code disabled in Win32 environment." )
#else                                       // #if defined(_WIN32)
#if defined(__BCPLUSPLUS__)
#ifdef __cplusplus
    #define __CPPARGS ...
#else
    #define __CPPARGS
#endif                                      // #ifdef __cplusplus
void interrupt NewAtapiIntHandler(__CPPARGS);// Our interrupt procedure
#elif defined(_MSC_VER)                     // #if defined(__BCPLUSPLUS__)
void __interrupt __far NewAtapiIntHandler();// Our interrupt procedure
#elif defined(__WATCOMC__)                  // #if defined(__BCPLUSPLUS__)
void __interrupt __far NewAtapiIntHandler();// Our interrupt procedure
#elif defined(__DJGPP__)                    // #if defined(__BCPLUSPLUS__)
void NewAtapiIntHandler();                  // Our interrupt procedure
#else                                       // #if defined(__BCPLUSPLUS__)
#error Interrupt handlers no declared!
#endif                                      // #if defined(__BCPLUSPLUS_)
#endif                                      // #if defined(_WIN32)
