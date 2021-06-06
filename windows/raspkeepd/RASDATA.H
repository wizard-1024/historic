//****************************************************************************
//                             File RASDATA.H
//
//                    General project data definitions
//
//      Copyright (c) Dmitry V. Stefankov, 1997. All rights reserved.
//
//****************************************************************************
//
//   $Source: F:/MSVC20/SOURCE/RASKEEPD/RCS/rasdata.h $
//  $RCSfile: rasdata.h $
//   $Author: dstef $
//     $Date: 1998/10/03 13:46:17 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: rasdata.h $
//      Revision 1.1  1998/10/03 13:46:17  dstef
//      Initial revision
//
//
//****************************************************************************

#ifndef _RASDATA_H_
#define _RASDATA_H_


//---------------------- Author, Copyright, Version --------------------------

const  TCHAR  g_szVersion[]           =  TEXT("v1.0");
const  TCHAR  g_szCopyright[]         =  TEXT("Copyright (c) 1997");
const  TCHAR  g_szAuthor[]            =  TEXT("Dmitry Stefankov");


//----------------------------- Service Name ---------------------------------

const  TCHAR  g_szAppName[]            =  TEXT("RasKeepD");
                                            // name of the executable
const  TCHAR  g_szServiceName[]        =  TEXT("RasKeepService");
                                            // internal name of the service
const  TCHAR  g_szServiceDisplayName[] =  TEXT("RAS Connection Keep Service");
                                            // displayed name of the service
const  TCHAR  g_szDependencies[]      =   TEXT("rasman\0\0");
                                            // list of service dependencies like
                                            //"dep1\0dep2\0\0"


//------------------------- Service Registry Key -----------------------------

const  TCHAR  g_szServicesKey[]    =  TEXT("SYSTEM\\CurrentControlSet\\Services\\");
const  TCHAR  g_szParametersKey[]  =  TEXT("Parameters");
const  TCHAR  g_szEventLogKeyApp[] =  TEXT("EventLog\\Application\\");

//----------------------- Initialization file sections ------------------------

const  TCHAR  g_szIniFileName[]     =  TEXT("RASKEEPD.INI");
const  TCHAR  g_szDefault[]         =  TEXT("");

const  TCHAR  g_szParamSection[]    =  TEXT("RAS");
const  TCHAR  g_szKeyUserEntry[]    =  TEXT("UserEntry");
const  TCHAR  g_szKeyUserName[]     =  TEXT("UserName");
const  TCHAR  g_szKeyUserPass[]     =  TEXT("UserPass");
const  TCHAR  g_szKeyUserDomain[]   =  TEXT("UserDomain");

const  TCHAR  g_szOptionSection[]   =  TEXT("ICMP");
const  TCHAR  g_szKeyTestIcmp[]     =  TEXT("RemoteIpNode");
const  TCHAR  g_szKeyPingTimeout[]  =  TEXT("PingTimeout");
const  TCHAR  g_szKeyDataSize[]     =  TEXT("DataSize");

const  TCHAR  g_szGeneralSection[]  =  TEXT("GENERAL");
const  TCHAR  g_szKeyRetry[]        =  TEXT("Retry");
const  TCHAR  g_szKeyRetryTime[]    =  TEXT("RetryTime");
const  TCHAR  g_szKeyTestTime[]     =  TEXT("TestTime");
const  TCHAR  g_szKeyErrorLogging[] =  TEXT("ErrorLogging");
const  TCHAR  g_szKeyCloseRas[]     =  TEXT("CloseRas");
const  TCHAR  g_szKeyHardRetry[]    =  TEXT("HardRetry");
const  TCHAR  g_szKeyAliveTime[]    =  TEXT("AliveTime");
const  TCHAR  g_szKeyShutDown[]     =  TEXT("ShutDown");


//----------------- Registry keys or INI-file parameters ---------------------

TCHAR    g_szUserEntryName[RAS_MaxEntryName + 1] =  TEXT("");
TCHAR    g_szUserName[UNLEN + 1]                 =  TEXT("");
TCHAR    g_szUserPass[PWLEN + 1]                 =  TEXT("");
TCHAR    g_szUserDomain[DNLEN + 1]               =  TEXT("");

TCHAR   g_szRemoteIpNode[IP_ADDRESS_SIZE] =   TEXT("0.0.0.0");
DWORD   g_dwPingTimeout           =   PING_DEF_TIMEOUT;
WORD    g_wDataSize               =   PING_DEF_DATASIZE;
DWORD   g_dwRetry                 =   RAS_RETRY_COUNT_DF;
DWORD   g_dwRetryTime             =   RAS_TEST_TIME_DF;
DWORD   g_dwTestTime              =   PING_TEST_TIME_DF;

DWORD   g_dwErrorLogging          =   0;      // Write messages to eventlog file
DWORD   g_dwCloseRas              =   0;      // Close failed connection at exit
DWORD   g_dwAliveTime             =   0;      // Send alive message
DWORD   g_dwDialUpLine            =   0;      // Special case: DUP line
DWORD   g_dwHardRetry             =   0;      // Try before close
DWORD   g_dwShutDown              =   0;      // Shutdown system if unhappy


#endif                                      // #ifndef _RASDATA_H_
