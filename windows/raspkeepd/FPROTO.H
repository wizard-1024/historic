//****************************************************************************
//                              File FPROTO.H
//
//                    Function prototypes declarations
//
//      Copyright (c) Dmitry V. Stefankov, 1997. All rights reserved.
//
//****************************************************************************
//
//   $Source: F:/MSVC20/SOURCE/RASKEEPD/RCS/fproto.h $
//  $RCSfile: fproto.h $
//   $Author: dstef $
//     $Date: 1998/10/03 13:44:35 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: fproto.h $
//      Revision 1.1  1998/10/03 13:44:35  dstef
//      Initial revision
//
//
//****************************************************************************

#ifndef _FPROTO_H_
#define _FPROTO_H_

//------------------------- Registry and INI-file ----------------------------

DWORD       ReadRegKey              ( LPCTSTR szSectionName,
                                      LPCTSTR szValueName,
                                      LPBYTE lpbDataBuf,
                                      DWORD dwDataBufSize );
DWORD       WriteRegKey             ( LPCTSTR szSectionName,
                                      LPCTSTR szValueName,
                                      LPBYTE lpbDataBuf,
                                      DWORD dwDataBufSize,
                                      DWORD dwValueType );
DWORD       CreateDefaultRegKeys    ();
DWORD       ReadIniFile             ( LPCTSTR szFilename );
VOID        WriteSectionGeneral     ();
VOID        WriteSectionRas         ();
VOID        WriteSectionIcmp        ();


//------------------------ RAS connection control ----------------------------

DWORD       TestRemoteSiteRetry  ( LPCTSTR szRemoteSite, DWORD dwUseHardRetry );
DWORD       TestRemoteSite       ( LPCTSTR szRemoteSite );
DWORD       ReInitRasConnection  ( LPTSTR szEntryName );
DWORD       OpenRasConnection    ( LPTSTR szEntryName );
DWORD       CloseRasConnection   ( LPTSTR szEntryName );
DWORD       TestRasConnection    ( LPTSTR szEntryName );
HRASCONN    FindRasConnection    ( LPTSTR szEntryName );


//----------------------------- WIN32 Service --------------------------------

VOID  CmdInstallService     ();
VOID  CmdRemoveService      ();
VOID  CmdVersionService     ();
VOID  CmdDebugService       ( int argc, char **argv, char *envp );

VOID  MainService           ( DWORD dwArgc, LPTSTR *lpszArgv );
VOID  ServiceControl        ( DWORD dwCtrlCode );
VOID  ServiceStart          ( DWORD dwArgc, LPTSTR *lpszArgv );
VOID  ServiceStop           ();
VOID  ServicePause          ();
VOID  ServiceContinue       ();
VOID  ServiceInterrogate    ();
VOID  ServiceStatusUpdate   ();

VOID   InitState            ();
VOID   AppCleanUp           ();
VOID   SystemShutdown       ();
DWORD  AdjustRights         ();
VOID   WriteStatToEventLog  ();

LPTSTR  GetLastErrorText    ( LPTSTR lpszBuf, DWORD dwSize );
BOOL    ControlHandler      ( DWORD dwCtrlType );
void    AddSourceToRegistry ( LPTSTR pszAppname, LPTSTR pszMsgDLL );
void    ReportAnEvent       ( DWORD dwIdEvent, WORD wEventType, WORD cStrings, 
                              LPTSTR *pszStrings );

DWORD  ThreadFuncStart      ( LPDWORD lpdwParam );
DWORD  ThreadFuncStop       ( LPDWORD lpdwParam );
DWORD  ThreadFuncAlive      ( LPDWORD lpdwParam );


//------------------------- Control Panel Applet -----------------------------

LONG  CALLBACK CPlApplet        ( HWND, UINT, LONG, LONG );
BOOL  APIENTRY RasKeepDlgProc   ( HWND, UINT, UINT, LONG );
BOOL  APIENTRY HelpDlgProc      ( HWND, UINT, UINT, LONG );
BOOL  APIENTRY AboutDlgProc     ( HWND, UINT, UINT, LONG );
VOID  SetDefaultDialogItems     ( HWND );
VOID  GetUserDialogItems        ( HWND );
VOID  DrawImage                 ( HWND );


#endif                                      // #ifndef _FPROTO_H_
