//****************************************************************************
//                             File RASPROTO.H
//
//                      Data external declarations
//
//      Copyright (c) Dmitry V. Stefankov, 1997. All rights reserved.
//
//****************************************************************************
//
//   $Source: F:/MSVC20/SOURCE/RASKEEPD/RCS/rasproto.h $
//  $RCSfile: rasproto.h $
//   $Author: dstef $
//     $Date: 1998/10/03 13:49:07 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: rasproto.h $
//      Revision 1.1  1998/10/03 13:49:07  dstef
//      Initial revision
//
//
//****************************************************************************

#ifndef _RASPROTO_H_
#define _RASPROTO_H_

extern  const  TCHAR  g_szVersion[];
extern  const  TCHAR  g_szCopyright[];
extern  const  TCHAR  g_szAuthor[];


//----------------------------- Service Name ---------------------------------

extern  const  TCHAR  g_szAppName[];
extern  const  TCHAR  g_szServiceName[];
extern  const  TCHAR  g_szServiceDisplayName[];
extern  const  TCHAR  g_szDependencies[];


//------------------------- Service Registry Key -----------------------------

extern  const  TCHAR  g_szServicesKey[];
extern  const  TCHAR  g_szParametersKey[];


//----------------------- Initialization file sections ------------------------

extern  const  TCHAR  g_szIniFileName[];
extern  const  TCHAR  g_szDefault[];

extern  const  TCHAR  g_szParamSection[];
extern  const  TCHAR  g_szKeyUserEntry[];
extern  const  TCHAR  g_szKeyUserName[];
extern  const  TCHAR  g_szKeyUserPass[];
extern  const  TCHAR  g_szKeyUserDomain[];

extern  const  TCHAR  g_szOptionSection[];
extern  const  TCHAR  g_szKeyTestIcmp[];
extern  const  TCHAR  g_szKeyPingTimeout[];
extern  const  TCHAR  g_szKeyDataSize[];

extern  const  TCHAR  g_szGeneralSection[];
extern  const  TCHAR  g_szKeyRetry[];
extern  const  TCHAR  g_szKeyRetryTime[];
extern  const  TCHAR  g_szKeyTestTime[];
extern  const  TCHAR  g_szKeyErrorLogging[];
extern  const  TCHAR  g_szKeyCloseRas[];
extern  const  TCHAR  g_szKeyHardRetry[];
extern  const  TCHAR  g_szKeyAliveTime[];
extern  const  TCHAR  g_szKeyShutDown[];


//----------------- Registry keys or INI-file parameters ---------------------

extern  TCHAR   g_szUserEntryName[RAS_MaxEntryName + 1];
extern  TCHAR   g_szUserName[UNLEN + 1];
extern  TCHAR   g_szUserPass[PWLEN + 1];
extern  TCHAR   g_szUserDomain[DNLEN + 1];

extern  TCHAR   g_szRemoteIpNode[IP_ADDRESS_SIZE];
extern  DWORD   g_dwPingTimeout;
extern  WORD    g_wDataSize;
extern  DWORD   g_dwRetry;
extern  DWORD   g_dwRetryTime;
extern  DWORD   g_dwTestTime;
extern  DWORD   g_dwErrorLogging;
extern  DWORD   g_dwCloseRas;
extern  DWORD   g_dwAliveTime;
extern	DWORD	g_dwDialUpLine;
extern  DWORD   g_dwHardRetry;
extern  DWORD   g_dwShutDown;


#endif                                      // #ifndef _RASPROTO_H_
