//****************************************************************************
//                            File RASKEEPD.C
//
//             Remote Access Service (RAS) Connection Keep Service
//
//      Copyright (c) Dmitry V. Stefankov, 1997. All rights reserved.
//
//****************************************************************************
//
//   $Source: F:/MSVC20/SOURCE/RASKEEPD/RCS/raskeepd.c $
//  $RCSfile: raskeepd.c $
//   $Author: dstef $
//     $Date: 1998/10/03 13:50:59 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: raskeepd.c $
//      Revision 1.1  1998/10/03 13:50:59  dstef
//      Initial revision
//
//
//****************************************************************************



//---------------------------- Standard files --------------------------------

#include "compile.h"                        // Compilation switches

#include <windows.h>                        // Windows definitions
#include <stdio.h>                          // I/O library
#include <stdlib.h>                         // Default library
#include <process.h>                        // Processes and threads
#include <tchar.h>                          // Unicode
#include <shellapi.h>                       // SHELL.DLL defintions

#if defined(WINSOCK_NT95)
#include <winsock.h>                        // Windows Socket interface
#endif                                      // #if defined(WINSOCK_NT95)

//---------------------- Microsoft proprietary files -------------------------

#include "ipexport.h"                       // IP transport layer
#include "icmpapi.h"                        // Internet Control Message Protocol

//------------------------- Remote Access Service ----------------------------

#include <ras.h>                            // Remote Access Service
#include <raserror.h>                       // RAS error definitions

//------------------------ Project specific files ----------------------------

#include "rasdefs.h"                        // Project definitions
#include "rasproto.h"                       // Data declarations
#include "rasdata.h"                        // Data definitions
#include "fproto.h"                         // Function prototypes
#include "debug.h"                          // Debugging definitions
#include "messages.h"                       // Eventlog messages



//------------------------------ Private data ---------------------------------

CRITICAL_SECTION  g_GlobalCriticalSection;  // Used by threads in single process

HANDLE  g_hServerStopEvent     = NULL;      // Service stop event object
HANDLE  g_hRasThreadStopEvent  = NULL;      // Thread stop event object
HANDLE  g_hRasThreadAliveEvent  = NULL;     // Thread stop event object
HANDLE  g_hHardRetryEvent = NULL;           // 20 sec waiting event object

DWORD   g_dwThreadIdAlive;                  // Start thread ID
DWORD   g_dwThreadParamAlive;               // Start thread parameter
HANDLE  g_hThreadAlive;                     // Start thread handle

DWORD   g_dwThreadIdStop;                   // Stop thread ID
DWORD   g_dwThreadParamStop;                // Stop thread parameter
HANDLE  g_hThreadStop;                      // Stop thread handle

DWORD   g_dwThreadIdStart;                  // Start thread ID
DWORD   g_dwThreadParamStart;               // Start thread parameter
HANDLE  g_hThreadStart;                     // Start thread handle

SERVICE_STATUS          g_ssStatus;         // Current status of the service
SERVICE_STATUS_HANDLE   g_sshStatusHandle;  // Service status handle
BOOL    g_fDebug       = FALSE;             // Debugging in progress
BOOL    g_fPaused      = FALSE;             // Pause state
BOOL    g_fWinsock     = FALSE;             // Winsock presence
BOOL    g_fFailMessage = FALSE;             // First failed ping message
BOOL    g_fBrokenMessage = FALSE;           // Broken message

TCHAR   g_szUserAccountName[256]  = TEXT(""); // Service user account
TCHAR   g_szUserAccountPass[256]  = TEXT(""); // Service user password

DWORD   g_dwSentPings     = 0;              // Total sent pings
DWORD   g_dwAckdPings     = 0;              // Acknowledged pings
DWORD   g_dwNoAckdPings   = 0;              // No acknowledged pings
DWORD   g_dwRestoreDone   = 0;              // Total of successful line recovery
DWORD   g_dwBrokenFound   = 0;              // Detected broken line counter



//--------------------------- Service commands -------------------------------

const  TCHAR  g_szCmdInstall[]  =   TEXT("install");
const  TCHAR  g_szCmdRemove[]   =   TEXT("remove");
const  TCHAR  g_szCmdVersion[]  =   TEXT("version");
const  TCHAR  g_szCmdDebug[]    =   TEXT("debug");
const  TCHAR  g_szCmdUser[]     =   TEXT("user:");
const  TCHAR  g_szCmdPass[]     =   TEXT("pass:");



//****************************************************************************
//                              --- main ---
//
// Purpose: Main program function
//   Input: int      argc -  number of arguments in command (shell) line
//          char   **argv -  array of pointers to argument-strings
//          char   * envp -  pointer to environment block
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
void main( int argc, char **argv, char *envp )
{
    DWORD        dwArgc;                    // Arguments number
    LPTSTR      *lpszArgv;                  // Arguments array
#if defined(_DEBUG)
    DWORD  dwErrorCode;                     // Error code
    TCHAR  chErrBuf[512];                   // Temporary storage
#endif                                      #if defined(_DEBUG)

//--------------------- Service Table for SC manager -------------------------

    SERVICE_TABLE_ENTRY dispatchTable[] =
    {
        { (LPTSTR)g_szServiceName, (LPSERVICE_MAIN_FUNCTION)MainService },
        { NULL, NULL }
    };

//------------------- Command line arguments processing ----------------------

#ifdef UNICODE
    lpszArgv = (LPTSTR *)CommandLineToArgvW( GetCommandLineW(), &dwArgc );
#else
    dwArgc   = (DWORD) argc;
    lpszArgv = argv;
#endif

    if ( (dwArgc > 1) &&
         ((*lpszArgv[1] == '-') || (*lpszArgv[1] == '/')) )
    {
        if ( _tcsicmp( g_szCmdInstall, lpszArgv[1]+1 ) == 0 )
        {
            if ( (dwArgc > 2) && (_tcsstr(lpszArgv[2],g_szCmdUser) != NULL) )
            {
               _tcscpy( g_szUserAccountName, lpszArgv[2]+_tcslen(g_szCmdUser)+1 );
            }
            if ( (dwArgc > 3) && (_tcsstr(lpszArgv[3],g_szCmdPass) != NULL) )
            {
               _tcscpy( g_szUserAccountPass, lpszArgv[3]+_tcslen(g_szCmdPass)+1 );
            }
            CmdInstallService();
        }
        else if ( _tcsicmp( g_szCmdRemove, lpszArgv[1]+1 ) == 0 )
        {
            CmdRemoveService();
        }
        else if ( _tcsicmp( g_szCmdVersion, lpszArgv[1]+1 ) == 0 )
        {
            CmdVersionService();
        }
        else if ( _tcsicmp( TEXT("?"), lpszArgv[1]+1 ) == 0 )
        {
        _tprintf( TEXT("USAGE:\n") );
        _tprintf( TEXT("%s -%s [-%susername -%suserpass]   to install the service\n"),
                  g_szAppName, g_szCmdInstall, g_szCmdUser, g_szCmdPass );
        _tprintf( TEXT("%s -%s          to display the service version\n"),
                  g_szAppName, g_szCmdVersion );
        _tprintf( TEXT("%s -%s           to remove the service\n"),
                  g_szAppName, g_szCmdRemove );
        _tprintf( TEXT("%s -%s <params>   to run as a console app for debugging\n"),
                  g_szAppName, g_szCmdDebug );
        }
        else if ( _tcsicmp( g_szCmdDebug, lpszArgv[1]+1 ) == 0 )
        {
            g_fDebug = TRUE;
            InitState();
            CmdDebugService(argc, argv, envp);
        }
        else
        {
            goto dispatch;
        }
        exit(0);
    }
//------------------- Start the Service Control manager ----------------------

    dispatch:
        InitState();
        _tprintf( TEXT("\nStartServiceCtrlDispatcher being called.\n") );
        _tprintf( TEXT("This may take some time.  Please wait.\n") );

        if ( !StartServiceCtrlDispatcher(dispatchTable) )
        {
#if defined(_DEBUG)
           dwErrorCode = GetLastError();
           _stprintf( chErrBuf,
                    TEXT("ERROR: StartServiceCtrlDispatcher failed. Error code = %u\n"),
                     dwErrorCode );
           OutputDebugString( chErrBuf );
#endif                                      // #if defined(_DEBUG)
        }
}



//****************************************************************************
//                            --- InitState ---
//
// Purpose: Initializes a finite state machine
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
void  InitState(void)
{
  DWORD   dwRetCode = RETCODE_DONE;         // Function return code
  TCHAR   chFileNameBuf[512];               // Initialization file name
  TCHAR   *pchTemp;                         // Temporary pointer

//---------------------------- Extract a path --------------------------------

  if ( GetModuleFileName( NULL, chFileNameBuf, sizeof(chFileNameBuf)) != 0 )
  {
     pchTemp = _tcschr( chFileNameBuf, TEXT('\\'));
     if  (pchTemp != NULL)
     {
        *(++pchTemp) = TEXT('\0');
     }
  }
  else
  {
     chFileNameBuf[0] = TEXT('\0');
     pchTemp = chFileNameBuf;
  }
  _tcscpy( pchTemp, g_szIniFileName);

//----------------------------- Read INI-file --------------------------------

  dwRetCode = ReadIniFile( chFileNameBuf );

  if ( dwRetCode != RETCODE_DONE )
  {
#if defined(_DEBUG)
     OutputDebugString( TEXT("ERROR: Wrong settings are in initialization file.\n\r") );
#endif                                      // #if defined(_DEBUG)
     exit( RETCODE_NO_RAS_ENTRY );
  }

#if defined(_DEBUG)
      OutputDebugString( TEXT("[RASKEEPD] Initialization file OK.\n\r") );
#endif                                      // #if defined(_DEBUG)

    if ( g_dwShutDown )
    {
        g_dwShutDown = AdjustRights();
    }
}



//****************************************************************************
//                        --- CmdVersionService ---
//
// Purpose: Display service version
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
VOID CmdVersionService()
{
  _tprintf( TEXT("Ras Connection Keep Service %s, %s %s\n"),
            g_szVersion, g_szCopyright, g_szAuthor );
  _tprintf( TEXT("Release date:  %s\n"), TEXT(__DATE__) );
  _tprintf( TEXT("Release time:  %s\n"), TEXT(__TIME__) );
}



//****************************************************************************
//                        --- CmdInstallService ---
//
// Purpose: Add a service to SC manager's databasse
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
void CmdInstallService()
{
    SC_HANDLE   schService;                 // Service handle
    SC_HANDLE   schSCManager;               // Service manager handle
    TCHAR       szPath[512];                // Service file path
    TCHAR       szErr[256];                 // Error text buffer
#if defined(WIN32_REGISTRY)
    TCHAR       szMsgPath[MAX_PATH];        // Messages file pathname
    DWORD       dwFuncRes;                  // Function result
#endif                                      // #if defined(WIN32_REGISTRY)

//--------------------- Extract pathname and filename ------------------------

    if ( GetModuleFileName( NULL, szPath, 512 ) == 0 )
    {
        _tprintf( TEXT( "Unable to install %s - %s\n"),
                        g_szServiceDisplayName,
                        GetLastErrorText(szErr, 256) );
        return;
    }

//------------------------- Attach to SC manager -----------------------------

    schSCManager = OpenSCManager(
                        NULL,               // machine (NULL == local)
                        NULL,               // database (NULL == default)
                        SC_MANAGER_ALL_ACCESS
                                            // access required
                        );

//---------------------------- Install service -------------------------------

    if ( schSCManager )
    {
        if ( g_szUserAccountName[0] == TEXT('\0') )
        {
           schService = CreateService(
                schSCManager,               // SCManager database
                g_szServiceName,            // name of service
                g_szServiceDisplayName,     // name to display
                SERVICE_ALL_ACCESS,         // desired access
                SERVICE_WIN32_OWN_PROCESS,  // service type                                         
                SERVICE_DEMAND_START,       // start type
                SERVICE_ERROR_NORMAL,       // error control type
                szPath,                     // service's binary
                NULL,                       // no load ordering group
                NULL,                       // no tag identifier
                g_szDependencies,           // dependencies
                NULL,                       // LocalSystem account
                NULL);                      // no password
        }
        else
        {
           schService = CreateService(
                schSCManager,               // SCManager database
                g_szServiceName,            // name of service
                g_szServiceDisplayName,     // name to display
                SERVICE_ALL_ACCESS,         // desired access
                SERVICE_WIN32_OWN_PROCESS,  // service type                                         
                SERVICE_DEMAND_START,       // start type
                SERVICE_ERROR_NORMAL,       // error control type
                szPath,                     // service's binary
                NULL,                       // no load ordering group
                NULL,                       // no tag identifier
                g_szDependencies,           // dependencies
                g_szUserAccountName,        // LocalSystem account
                g_szUserAccountPass);       // no password
        }

        if ( schService )
        {
            _tprintf( TEXT("%s installed.\n"), g_szServiceDisplayName );
            CloseServiceHandle(schService);

#if defined(WIN32_REGISTRY)
            dwFuncRes = CreateDefaultRegKeys();
            GetCurrentDirectory( sizeof(szMsgPath), szMsgPath );
            _tcscat( szMsgPath, TEXT("\\") );
            _tcscat( szMsgPath, g_szAppName );
            _tcscat( szMsgPath, TEXT(".exe") );
            AddSourceToRegistry( (LPTSTR)&g_szServiceName, szMsgPath );
#endif                                      // #if defined(WIN32_REGISTRY)
        }
        else
        {
            _tprintf( TEXT("CreateService failed - %s\n"),
                      GetLastErrorText(szErr, 256) );
        }

        CloseServiceHandle(schSCManager);
    }
    else
        _tprintf( TEXT("OpenSCManager failed - %s\n"),
                  GetLastErrorText(szErr,256) );

}



//****************************************************************************
//                        --- CmdRemoveService ---
//
// Purpose: Remove a service from a SC manager's database
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
void CmdRemoveService()
{
    SC_HANDLE   schService;                 // Service handle
    SC_HANDLE   schSCManager;               // Service manager handle
    TCHAR       szErr[256];                 // Error text buffer
    TCHAR       szKeyName[512];             // Key name
    DWORD       dwFuncRes;                  // Function result

//------------------------- Attach to SC manager -----------------------------

    schSCManager = OpenSCManager(
                        NULL,               // machine (NULL == local)
                        NULL,               // database (NULL == default)
                     SC_MANAGER_ALL_ACCESS	// access required
                        );

    if ( schSCManager )
    {

//------------------ Open service to check installation ----------------------

        schService = OpenService(schSCManager, // SC manager handle
                              g_szServiceName, // Service name
                           SERVICE_ALL_ACCESS);// Acccess required

        if ( schService )
        {

//------------------------ Try to stop the service ---------------------------

            if ( ControlService( schService, SERVICE_CONTROL_STOP, &g_ssStatus ) )
            {
                _tprintf( TEXT("Stopping %s."), g_szServiceDisplayName );
                Sleep( 1 * MS_PER_SEC );

                while( QueryServiceStatus( schService, &g_ssStatus ) )
                {
                    if ( g_ssStatus.dwCurrentState == SERVICE_STOP_PENDING )
                    {
                        _tprintf( TEXT(".") );
                        Sleep( 1 * MS_PER_SEC );
                    }
                    else
                        break;
                }

                if ( g_ssStatus.dwCurrentState == SERVICE_STOPPED )
                    _tprintf( TEXT("\n%s stopped.\n"), g_szServiceDisplayName );
                else
                    _tprintf( TEXT("\n%s failed to stop.\n"),
                              g_szServiceDisplayName );

            }

//-------------------------- Remove the service ------------------------------

            if( DeleteService(schService) )
                _tprintf( TEXT("%s removed.\n"), g_szServiceDisplayName );
            else
                _tprintf( TEXT("DeleteService failed - %s\n"),
                          GetLastErrorText(szErr,256) );

            CloseServiceHandle(schService);
                                            // Remove a eventlog key for our app
            _tcscpy( szKeyName, g_szServicesKey );
            _tcscat( szKeyName, g_szEventLogKeyApp );
            _tcscat( szKeyName, g_szServiceName );
            dwFuncRes = RegDeleteKey( HKEY_LOCAL_MACHINE, szKeyName );
            if ( dwFuncRes != ERROR_SUCCESS )
                _tprintf( TEXT("Eventlog key deletion failed - %s.\n"),
                          GetLastErrorText(szErr,256) );

        }
        else
            _tprintf( TEXT("OpenService failed - %s\n"),
                      GetLastErrorText(szErr,256) );

        CloseServiceHandle(schSCManager);
    }
    else
        _tprintf( TEXT("OpenSCManager failed - %s\n"),
                  GetLastErrorText(szErr,256) );
}



//****************************************************************************
//                           --- MainService ---
//
// Purpose: Main entry point for service.
//          It must be used as connection point to service.
//   Input: DWORD     dwArgc   - number of arguments
//          LPTSTR  * lpszArgv - pointer to array of pointers (arguments)
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
void MainService(DWORD dwArgc, LPTSTR *lpszArgv)
{

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] MainService(...)\n\r") );
#endif                                      // #if defined(_DEBUG)

//-------------------- Build service status structure ------------------------

    g_ssStatus.dwServiceType      = SERVICE_WIN32;
    g_ssStatus.dwCurrentState     = SERVICE_START_PENDING;
    g_ssStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP |
                                    SERVICE_ACCEPT_PAUSE_CONTINUE;
    g_ssStatus.dwWin32ExitCode    = 0;
    g_ssStatus.dwServiceSpecificExitCode = 0;
    g_ssStatus.dwCheckPoint       = 0;
    g_ssStatus.dwWaitHint         = 0;

//----------------- Register service control handler --------------------------

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] Register SC handler.\n\r") );
#endif                                      // #if defined(_DEBUG)

    g_sshStatusHandle = RegisterServiceCtrlHandler( g_szServiceName,
                                           (LPHANDLER_FUNCTION)ServiceControl);

//--------------------------- Error processing -------------------------------

    if ( g_sshStatusHandle == (SERVICE_STATUS_HANDLE)0 )
    {
#if defined(_DEBUG)
        OutputDebugString( TEXT("[RASKEEPD] SC handler registration failed.\n\r") );
#endif                                      // #if defined(_DEBUG)
        return;
    }

//----------------------------- Start service --------------------------------
// Please note that we call our own service.

    ServiceStart( dwArgc, lpszArgv );

    return;

}


//****************************************************************************
//                         --- ServiceControl ---
//
// Purpose: Service Control Dispatcher
//   Input: DWORD dwCtrlCode - service control code sent by SC manager
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
VOID ServiceControl(DWORD dwCtrlCode)
{

//------------------- Handle the requested control code ----------------------

    switch( dwCtrlCode )
    {

//------------------ Do whatever it takes to pause here ----------------------

    case SERVICE_CONTROL_PAUSE:
        ServicePause();
        break;

//----------------- Do whatever it takes to continue here --------------------

        case SERVICE_CONTROL_CONTINUE:
        ServiceContinue();
        break;

//--------------------------- Stop the service -------------------------------

        case SERVICE_CONTROL_STOP:
            ServiceStop();
            break;

//----------------------- Update the service status --------------------------

        case SERVICE_CONTROL_INTERROGATE:
            ServiceInterrogate();
            break;

//------------------------- Invalid control code -----------------------------

        default:
            break;

    }

}



//****************************************************************************
//                       --- ServiceStatusUpdate ---
//
// Purpose: Send a current service state to SC manager
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
VOID ServiceStatusUpdate()
{
  if ( !g_fDebug )
  {
    if (!SetServiceStatus (g_sshStatusHandle,  &g_ssStatus))
    {
#if defined(_DEBUG)
       OutputDebugString( TEXT("[RASKEEPD] Set Service Status failed.\n\r") );
#endif                                      // #if defined(_DEBUG)
        // Error processing follows
    }
  }
}



//****************************************************************************
//                          --- ServiceStart ---
//
// Purpose: Start a service
//   Input: DWORD     dwArgc   - number of arguments
//          LPTSTR  * lpszArgv - pointer to array of pointers (arguments)
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
void ServiceStart(DWORD dwArgc, LPTSTR *lpszArgv)
{
    DWORD  dwWaitStopChkPoint = 1;          // Checkpoint for SC maanger
    DWORD  dwWaitMain;                      // Function result

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] ServiceStart()\n\r") );
#endif                                      // #if defined(_DEBUG)

//------------------- Initialize the critical section ------------------------

    InitializeCriticalSection(&g_GlobalCriticalSection);


//----------- Create general waiting event for starting thread ---------------

    g_hHardRetryEvent = CreateEvent( NULL, // no security attributes
                                     FALSE,// manual reset event
                                     FALSE,// not-signalled
                                     NULL);// no name

//----------- Create stop service event object for main thread ---------------

    g_ssStatus.dwWin32ExitCode  = 0;
    g_ssStatus.dwCurrentState   = SERVICE_START_PENDING;
    g_ssStatus.dwCheckPoint     = dwWaitStopChkPoint++;
    g_ssStatus.dwWaitHint       = STD_SRVC_WAIT_TIME * MS_PER_SEC;
    ServiceStatusUpdate();

    g_hServerStopEvent = CreateEvent( NULL, // no security attributes
                                      TRUE, // manual reset event
                                      FALSE,// not-signalled
                                      NULL);// no name

    if ( g_hServerStopEvent == NULL)
    {
      AppCleanUp();
      g_ssStatus.dwWin32ExitCode             = ERROR_SERVICE_SPECIFIC_ERROR;
      g_ssStatus.dwServiceSpecificExitCode   = 1;
      g_ssStatus.dwCurrentState              = SERVICE_STOPPED;
      ServiceStatusUpdate();
      return;
    }

//--------- Create stop service event object for starting thread -------------

    g_ssStatus.dwWin32ExitCode  = 0;
    g_ssStatus.dwCurrentState   = SERVICE_START_PENDING;
    g_ssStatus.dwCheckPoint     = dwWaitStopChkPoint++;
    g_ssStatus.dwWaitHint       = STD_SRVC_WAIT_TIME * MS_PER_SEC;
    ServiceStatusUpdate();

    g_hRasThreadStopEvent = CreateEvent(NULL, // no security attributes
                                      TRUE,   // manual reset event
                                      FALSE,  // not-signalled
                                      NULL);  // no name

    if ( g_hRasThreadStopEvent == NULL )
    {
      AppCleanUp();
      g_ssStatus.dwWin32ExitCode            = ERROR_SERVICE_SPECIFIC_ERROR;
      g_ssStatus.dwServiceSpecificExitCode  = 2;
      g_ssStatus.dwCurrentState             = SERVICE_STOPPED;
      ServiceStatusUpdate();
      return;
    }

//--------- Create stop service event object for alive thread -------------

    g_ssStatus.dwWin32ExitCode  = 0;
    g_ssStatus.dwCurrentState   = SERVICE_START_PENDING;
    g_ssStatus.dwCheckPoint     = dwWaitStopChkPoint++;
    g_ssStatus.dwWaitHint       = STD_SRVC_WAIT_TIME * MS_PER_SEC;
    ServiceStatusUpdate();

    g_hRasThreadAliveEvent = CreateEvent(
                                    NULL,   // no security attributes
                                    TRUE,   // manual reset event
                                    FALSE,  // not-signalled
                                    NULL);  // no name

    if ( g_hRasThreadAliveEvent == NULL)
    {
#if defined(_DEBUG)
        OutputDebugString(
              TEXT("ERROR: Stop event object for akive thread not created.\n\r")
                         );
#endif                                      // #if defined(_DEBUG)
    }

//-------------------------- Run starting thread -----------------------------

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] Run starting thread.\n\r") );
#endif                                      // #if defined(_DEBUG)

    g_ssStatus.dwCurrentState  = SERVICE_START_PENDING;
    g_ssStatus.dwCheckPoint    = dwWaitStopChkPoint;
    g_ssStatus.dwWaitHint      = STD_SRVC_WAIT_TIME * MS_PER_SEC;
    ServiceStatusUpdate();

  g_hThreadStart = CreateThread(NULL,       // address of thread security attributes
                             0,             // initial thread stack size, in bytes
    (LPTHREAD_START_ROUTINE)ThreadFuncStart,// address of thread function
                      &g_dwThreadParamStart,// argument for new thread
                             0,             // creation flags
                          &g_dwThreadIdStart// address of returned thread identifier
                            );

  if ( g_hThreadStart == NULL )
  {
      AppCleanUp();
      g_ssStatus.dwWin32ExitCode              = ERROR_SERVICE_SPECIFIC_ERROR;
      g_ssStatus.dwServiceSpecificExitCode    = 3;
      g_ssStatus.dwCurrentState               = SERVICE_STOPPED;
      ServiceStatusUpdate();
      return;
  }

//-------------------------- Run alive thread --------------------------------

    if ( g_hRasThreadAliveEvent != NULL )
    {
#if defined(_DEBUG)
        OutputDebugString( TEXT("[RASKEEPD] Run alive thread.\n\r") );
#endif                                      // #if defined(_DEBUG)

        g_ssStatus.dwCurrentState  = SERVICE_START_PENDING;
        g_ssStatus.dwCheckPoint    = dwWaitStopChkPoint;
        g_ssStatus.dwWaitHint      = STD_SRVC_WAIT_TIME * MS_PER_SEC;
        ServiceStatusUpdate();

        g_hThreadAlive = CreateThread(NULL, // address of thread security attributes
                             0,             // initial thread stack size, in bytes
    (LPTHREAD_START_ROUTINE)ThreadFuncAlive,// address of thread function
                      &g_dwThreadParamAlive,// argument for new thread
                             0,             // creation flags
                          &g_dwThreadIdAlive// address of returned thread identifier
                            );

        if ( g_hThreadAlive == NULL )
        {
#if defined(_DEBUG)
            OutputDebugString( TEXT("ERROR: Alive thread not started.\n\r") );
#endif                                      // #if defined(_DEBUG)
        }
  }

//-------------------------- Service is running ------------------------------

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] Service is running.\n\r") );
#endif                                      // #if defined(_DEBUG)

    g_ssStatus.dwCurrentState  = SERVICE_RUNNING;
    ServiceStatusUpdate();

    if ( g_dwErrorLogging )
    {
        ReportAnEvent( MSG_SERVICE_RUNNING,
                       EVENTLOG_INFORMATION_TYPE,
                       0,
                       NULL );
    }

//----------- Sleep in main thread until stop signal receiving ----------------

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] I'm sleeping in main thread\n\r") );
#endif                                      // #if defined(_DEBUG)
    while ( 1 )
    {
        dwWaitMain = WaitForSingleObject( g_hServerStopEvent, INFINITE  );
        if ( dwWaitMain == WAIT_OBJECT_0 )  // Service stop signal receiving?
        {
                break;                      // Exit from endless loop
        }
    }

//------------------------- Terminate main thread ----------------------------

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] I'm raising in main thread\n\r") );
#endif                                      // #if defined(_DEBUG)

    if (g_hServerStopEvent != NULL)
    {
        ResetEvent( g_hServerStopEvent );
    }

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] Wait some time in main thread\n\r") );
#endif                                      // #if defined(_DEBUG)

    if ( g_hHardRetryEvent != NULL )
    {
        dwWaitMain = WaitForSingleObject( g_hHardRetryEvent,
                                          WAIT_BEFORE_EXIT * MS_PER_SEC  );
    }
    else
    {
        Sleep( WAIT_BEFORE_EXIT * MS_PER_SEC );
                                            // Empirical time
    }

    if ( g_dwErrorLogging )
    {
        WriteStatToEventLog();
        ReportAnEvent( MSG_SERVICE_STOPPED,
                       EVENTLOG_INFORMATION_TYPE,
                       0,
                       NULL );
    }

    g_ssStatus.dwWin32ExitCode  = 0;
    g_ssStatus.dwCurrentState   = SERVICE_STOPPED;
    g_ssStatus.dwCheckPoint     = 0;
    g_ssStatus.dwWaitHint       = 0;
    ServiceStatusUpdate();

    AppCleanUp();
#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] Return from main thread\n\r") );
#endif                                      // #if defined(_DEBUG)
}



//****************************************************************************
//                         --- ThreadFuncStart ---
//
// Purpose: Starting thread (main loop for service tasks)
//   Input: LPDWORD lpdwParam - thread parameter
//  Output: DWORD             - thread exit code
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
DWORD ThreadFuncStart(LPDWORD lpdwParam)
{
#if defined(WINSOCK_NT95)
    WSADATA       wsaData;                  // Winsock data
    int           iErr;                     // Error code for Winsock init
#endif                                      // #if defined(WINSOCK_NT95)
    DWORD       dwWait;                     // Function result
    DWORD       dwRetCode = RETCODE_DONE;   // Function return code
    DWORD       dwAttempts;                 // Attempts to restore RAS link
    DWORD       dwResult = 0;               // Function result
    BOOL        fCountRetry;                // Use retry counter
#if defined(_DEBUG)
    TCHAR       chTempBuf[512];             // Temporary buffer
#endif                                      // #if defined(_DEBUG)

//-------------------------- Some initailization -----------------------------

    fCountRetry = ( g_dwRetry != 0 );
    dwAttempts = g_dwRetry;

//-------------------- Windows Sockets initialization ------------------------

#if defined(_DEBUG)
  OutputDebugString( TEXT("[RASKEEPD] Initialize Windows Sockets interface.\n\r") );
#endif                                      // #if defined(_DEBUG)

#if defined(WINSOCK_NT95)
  iErr = WSAStartup( 0x0101, &wsaData );
  if ( iErr != 0 )
  {
#if defined(_DEBUG)
    OutputDebugString( TEXT("ERROR: No Windows Sockets found.\n\r") );
#endif                                      // #if defined(_DEBUG)
    dwResult = RETCODE_NO_WINSOCK;
    return( dwResult );
  }

  if ( LOBYTE( wsaData.wVersion ) != 1 ||
       HIBYTE( wsaData.wVersion ) != 1 )
  {
#if defined(_DEBUG)
     OutputDebugString( TEXT("ERROR: No Windows Sockets version 1.1 present.\n\r") );
#endif                                      // #if defined(_DEBUG)
     dwResult = RETCODE_NO_WINSOCK_V11;
     goto Done;
  }
#endif                                      // #if defined(WINSOCK_NT95)
  g_fWinsock = TRUE;						// Yes, WinSock interface found

//-------------------- Main loop to ping a remote site -----------------------

    while ( 1 )
    {

//-------------------------- RAS link check loop -----------------------------

         while ( 1 )
         {
            dwRetCode = TestRemoteSiteRetry( g_szRemoteIpNode, g_dwHardRetry );
            if ( dwRetCode == RETCODE_DONE )
            {
                break;
            }
            dwRetCode = ReInitRasConnection( g_szUserEntryName );
            if ( dwRetCode == RETCODE_DONE )
            {
                break;
            }
            if ( fCountRetry == TRUE )
            {
               if ( --dwAttempts == 0 )
               {
#if defined(_DEBUG)
        OutputDebugString(
            TEXT("[RASKEEPD] It was the last attempt. I'm forcing an exit.\n\r")
                      );
#endif                                      // #if defined(_DEBUG)
                    if ( g_dwShutDown )
                    {
                        SystemShutdown();
                    }
                    break;
               }
               else
               {
                  if ( g_dwRetryTime != 0 )
                  {
#if defined(_DEBUG)
                    _stprintf( chTempBuf,
                             TEXT("[RASKEEPD] I'm going to wait for %d second(s).\n"),
                             g_dwRetryTime );
                    OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
                    dwWait = WaitForSingleObject( g_hRasThreadStopEvent,
                                                   g_dwRetryTime * MS_PER_SEC );
                    if ( dwWait == WAIT_OBJECT_0 )
                    {
                         goto finish;       // Prepare to leave daemon
                    }
                  }                         // if
               }                            // else
            }                               // if
         }                                  // while ( 1 )

#if defined(_DEBUG)
         _stprintf(chTempBuf, TEXT("[RASKEEPD] I'm sleeping for %d second(s).\n"),
                 g_dwTestTime );
         OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)

        dwWait = WaitForSingleObject( g_hRasThreadStopEvent,
                                      g_dwTestTime * MS_PER_SEC  );
        if ( dwWait == WAIT_OBJECT_0 )      // Service stop signal receiving?
        {
                break;
        }
     }                                      // while ( 1 )

//----------------------- Terminate starting thread --------------------------

finish:
#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] I'm raising in RAS thread\n\r") );
#endif                                      // #if defined(_DEBUG)
      if ( g_hRasThreadStopEvent != NULL )
      {
        ResetEvent( g_hRasThreadStopEvent );
      }

Done:
#if defined(_DEBUG)
  OutputDebugString( TEXT("{RASKEEPD] Clean-up before exit.\n\r") );
#endif                                      // #if defined(_DEBUG)
  if  ( g_dwCloseRas )
  {
     if ( !g_dwDialUpLine )
       dwWait = TestRemoteSite( g_szRemoteIpNode );
     else
       dwWait = TestRasConnection( g_szUserEntryName );
     if ( dwWait != RETCODE_DONE)
     {
#if defined(_DEBUG)
        OutputDebugString( TEXT("{RASKEEPD] Close failed connection.\n\r") );
#endif                                      // #if defined(_DEBUG)
        CloseRasConnection( g_szUserEntryName );
     }
  }
#if defined(WINSOCK_NT95)
  WSACleanup();
#endif                                      // #if defined(WINSOCK_NT95)

    return( dwResult );
}



//****************************************************************************
//                         --- ThreadFuncAlive ---
//
// Purpose: Thread to send alive message (diagnostic purpose)
//   Input: LPDWORD lpdwParam - thread paarameter
//  Output: DWORD             - thread exit code
// Written: by Dmitry V. Stefankov 1/22/97
//****************************************************************************
DWORD ThreadFuncAlive( LPDWORD lpdwParam )
{
    DWORD       dwWait;                     // Waiting interval
    DWORD       dwFuncRes;                  // Function result
    DWORD       dwRetCode = RETCODE_DONE;   // Function return code
#if defined(_DEBUG)
    TCHAR       chTempBuf[512];             // Temporary buffer
#endif                                      // #if defined(_DEBUG)

    if ( g_dwAliveTime )
      dwWait = g_dwAliveTime * MS_PER_SEC * SEC_PER_MIN;
    else
      dwWait = INFINITE;

//-------------------- Main loop to send messages -----------------------

    while ( 1 )
    {

#if defined(_DEBUG)
         _stprintf(chTempBuf,
                 TEXT("[RASKEEPD] I'm sleeping for %d minute(s) in alive thread.\n"),
                 g_dwAliveTime );
         OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)

        dwFuncRes = WaitForSingleObject( g_hRasThreadAliveEvent, dwWait );
        if ( dwFuncRes == WAIT_OBJECT_0 )   // Service stop signal receiving?
        {
                break;
        }

        if ( g_dwAliveTime )
        {
#if defined(_DEBUG)
            OutputDebugString( TEXT("[RASKEEPD] I send alive message.\n\r") );
#endif                                      // #if defined(_DEBUG)
            if ( g_dwErrorLogging )
            {
                WriteStatToEventLog();
            }
        }
     }                                      // while ( 1 )

//----------------------- Terminate alive thread --------------------------

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] I'm raising in alive thread\n\r") );
#endif                                      // #if defined(_DEBUG)
      if (g_hRasThreadAliveEvent != NULL)
      {
        ResetEvent( g_hRasThreadAliveEvent );
      }

    return( dwRetCode );
}



//****************************************************************************
//                           --- WriteStatToEventLog ---
//
// Purpose: Write a collected statistics to eventlog
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
void   WriteStatToEventLog()
{
    TCHAR       chTempBuf[512];             // Temporary buffer
    TCHAR  *pTemp = (TCHAR *)&chTempBuf;    // Temporary pointer

    _stprintf( chTempBuf, 
TEXT("sent pings = %lu, ackd pings = %lu, noackd pings = %lu, restored = %lu, broken = %lu"),
         g_dwSentPings, g_dwAckdPings, g_dwNoAckdPings, g_dwRestoreDone, g_dwBrokenFound );
    ReportAnEvent( MSG_DAEMON_ALIVE,
                   EVENTLOG_INFORMATION_TYPE,
                   1,
                   &pTemp );

//------------------- Here is critical section ------------------------

    EnterCriticalSection(&g_GlobalCriticalSection);

    g_dwSentPings     = 0;                    // Reset statistics
    g_dwAckdPings     = 0;                
    g_dwNoAckdPings   = 0;                
    g_dwRestoreDone   = 0;
    g_dwBrokenFound   = 0;

	LeaveCriticalSection(&g_GlobalCriticalSection);
}



//****************************************************************************
//                           --- ServiceStop ---
//
// Purpose: Stop a service
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
void ServiceStop()
{

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] ServiceStop()\n\r") );
#endif                                      // #if defined(_DEBUG)

//--------------------- Run service if we are paused -------------------------

    if ( g_fPaused )
    {
       ServiceContinue();
    }

//------ Create a stop thread because Microsoft timing restrictions ----------

    g_ssStatus.dwWin32ExitCode  = 0;
    g_ssStatus.dwCurrentState   = SERVICE_STOP_PENDING;
    g_ssStatus.dwCheckPoint     = 1;
    g_ssStatus.dwWaitHint       = 1 * MS_PER_SEC;
    ServiceStatusUpdate();

    g_hThreadStop = CreateThread(NULL,      // address of thread security attributes
                               0,           // initial thread stack size, in bytes
    (LPTHREAD_START_ROUTINE) ThreadFuncStop,// address of thread function
                       &g_dwThreadParamStop,// argument for new thread
                              0,            // creation flags
                           &g_dwThreadIdStop// address of returned thread identifier
                                );

}



//****************************************************************************
//                         --- ThreadFuncStop ---
//
// Purpose: Service stop thread
//   Input: LPDWORD lpdwParam - thread parameter
//  Output: DWORD             - thread exit code
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
DWORD ThreadFuncStop(LPDWORD lpdwParam)
{
    DWORD  dwWaitStopChkPoint = 2;          // Checkpoint for SC manager

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] I'm raising in stop thread\n\r") );
#endif                                      // #if defined(_DEBUG)

//----------------- Send stop signal to alive thread ----------------------

    if ( g_hRasThreadAliveEvent != NULL )
        SetEvent( g_hRasThreadAliveEvent );

    g_ssStatus.dwWin32ExitCode  = 0;
    g_ssStatus.dwCurrentState   = SERVICE_STOP_PENDING;
    g_ssStatus.dwCheckPoint     = dwWaitStopChkPoint++;
    g_ssStatus.dwWaitHint       = STD_SRVC_WAIT_TIME * MS_PER_SEC;
    ServiceStatusUpdate();

//----------------- Send stop signal to starting thread ----------------------

    if ( g_hRasThreadStopEvent != NULL)
        SetEvent( g_hRasThreadStopEvent );

    g_ssStatus.dwWin32ExitCode  = 0;
    g_ssStatus.dwCurrentState   = SERVICE_STOP_PENDING;
    g_ssStatus.dwCheckPoint     = dwWaitStopChkPoint++;
    g_ssStatus.dwWaitHint       = STD_SRVC_WAIT_TIME * MS_PER_SEC;
    ServiceStatusUpdate();

//-------------------- Send stop signal to main thread -----------------------

    if ( g_hServerStopEvent != NULL )
        SetEvent( g_hServerStopEvent );

    g_ssStatus.dwWin32ExitCode  = 0;
    g_ssStatus.dwCurrentState   = SERVICE_STOP_PENDING;
    g_ssStatus.dwCheckPoint     = dwWaitStopChkPoint++;
    g_ssStatus.dwWaitHint       = STD_SRVC_WAIT_TIME * MS_PER_SEC;
    ServiceStatusUpdate();

    return ( 0 );
}


//****************************************************************************
//                          --- ServicePause ---
//
// Purpose: Pause a service
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
void ServicePause()
{

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] ServicePause()\n\r") );
#endif                                      // #if defined(_DEBUG)

   g_fPaused = TRUE;
   g_ssStatus.dwCurrentState = SERVICE_PAUSED;
   ServiceStatusUpdate();
   SuspendThread( g_hThreadStart );
   if ( g_hThreadAlive != NULL )
          SuspendThread( g_hThreadAlive );

   if ( g_dwErrorLogging )
   {
        ReportAnEvent( MSG_SERVICE_PAUSED,
                       EVENTLOG_INFORMATION_TYPE,
                       0,
                       NULL );
   }

}



//****************************************************************************
//                         --- ServiceContinue ---
//
// Purpose: Continue a service
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
void ServiceContinue()
{

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] ServiceContinue()\n\r") );
#endif                                      // #if defined(_DEBUG)

   g_fPaused = FALSE;
   g_ssStatus.dwCurrentState = SERVICE_RUNNING;
   ServiceStatusUpdate();
   ResumeThread( g_hThreadStart );
   if ( g_hThreadAlive != NULL )
            ResumeThread( g_hThreadAlive );

   if ( g_dwErrorLogging )
   {
        ReportAnEvent( MSG_SERVICE_CONTINUED,
                       EVENTLOG_INFORMATION_TYPE,
                       0,
                       NULL );
    }

}



//****************************************************************************
//                       --- ServiceInterrogate ---
//
// Purpose: Updata service status for SC manager
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
VOID ServiceInterrogate()
{

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] ServiceInterrogate()\n\r") );
#endif                                      // #if defined(_DEBUG)

   ServiceStatusUpdate();
}



//****************************************************************************
//                         --- CmdDebugService ---
//
// Purpose: Debug a service as console application
//   Input: int      argc - number of arguments
//          char   **argv - pointer to array of pointers (arguments)
//          char   * envp - pointer to environment
//  Output: none
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
void CmdDebugService(int argc, char **argv, char *envp )
{
    DWORD        dwArgc;                    // Arguments number
    LPTSTR      *lpszArgv;                  // Arguments array

#ifdef UNICODE
    lpszArgv = (LPTSTR *)CommandLineToArgvW( GetCommandLineW(), &dwArgc );
#else
    dwArgc   = (DWORD) argc;
    lpszArgv = argv;
#endif

    _tprintf( TEXT("Debugging %s.\n"), g_szServiceDisplayName );

    SetConsoleCtrlHandler( (PHANDLER_ROUTINE)ControlHandler, TRUE );

    ServiceStart( dwArgc, lpszArgv );
}



//****************************************************************************
//                         --- ControlHandler ---
//
// Purpose: Console break handler
//   Input: DWORD dwCtrlType - Control type code
//  Output: BOOL             - TRUE   if processed
//                             FALSE  if ignored
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
BOOL ControlHandler ( DWORD dwCtrlType )
{
    switch( dwCtrlType )
    {
        case CTRL_BREAK_EVENT:              // Use Ctrl+C or Ctrl+Break to simulate
        case CTRL_C_EVENT:                  // SERVICE_CONTROL_STOP in debug mode
            _tprintf( TEXT("Stopping %s.\n"), g_szServiceDisplayName );
            ServiceStop();
            return TRUE;
            break;

    }
    return FALSE;
}



//****************************************************************************
//                        --- ReInitRasConnection ---
//
// Purpose: Tests a remote site and tests RAS connection state
//   Input: LPTSTR szEntryName - RAS entry name
//  Output: DWORD              - RETCODE_DONE if successful
//                               any other value is error
// Written: by Dmitry V.Stefankov 01-09-97
//****************************************************************************
DWORD  ReInitRasConnection  ( LPTSTR szEntryName )
{
  DWORD       dwResult = RETCODE_DONE;      // Function result code

//----------------------- Test RAS connection state --------------------------

  dwResult = TestRasConnection( szEntryName );
  if ( dwResult == RETCODE_DONE )
  {

//--------------- Check first special case -----------------------------------
     if ( g_dwDialUpLine )
     {
#if defined(_DEBUG)
        OutputDebugString( 
                TEXT("[RASKEEPD] RAS connection is alive (DUP line).\n\r")
                         );
#endif                                      // #if defined(_DEBUG)
        return( dwResult );
     }
#if defined(_DEBUG)
     OutputDebugString(
         TEXT("[RASKEEPD] Remote site is dead, but RAS connection is alive.\n\r")
                      );
#endif                                      // #if defined(_DEBUG)
  }
  else
  {
#if defined(_DEBUG)
          OutputDebugString(
           TEXT("[RASKEEPD] RAS connection had broken. Check your RAS line.\n\r")
                           );
#endif                                      // #if defined(_DEBUG)
  }

//--------------- Close RAS connection before open it again ------------------

     InterlockedIncrement(&g_dwBrokenFound); // Collect statistics
	 if ( g_dwErrorLogging )
	 {
        if ( g_fBrokenMessage == FALSE )
        {
               g_fBrokenMessage = TRUE;
               ReportAnEvent( MSG_CONNECTION_BROKEN,
                              EVENTLOG_ERROR_TYPE,
                              0,
                              NULL );
        }
	 }
     dwResult = CloseRasConnection( szEntryName );
     if ( dwResult != RETCODE_DONE )
     {
#if defined(_DEBUG)
          OutputDebugString(
           TEXT("[RASKEEPD] RAS connection closing failed. Check your RAS line.\n\r")
                           );
#endif                                      // #if defined(_DEBUG)
     }

//-------------------------- Open RAS connection -----------------------------

  dwResult = OpenRasConnection( szEntryName );
  if ( dwResult != RETCODE_DONE )
  {
#if defined(_DEBUG)
      OutputDebugString(
         TEXT("[RASKEEPD] I cannot open RAS connection. Check RAS line/settings.\n\r")
                       );
#endif                                      // #if defined(_DEBUG)
      return( dwResult );
  }

//----------------- Test a remote site again using a ping --------------------

  if ( !g_dwDialUpLine )
  {
      dwResult = TestRemoteSite( g_szRemoteIpNode );
      if ( dwResult == RETCODE_DONE )
      {
         InterlockedIncrement(&g_dwRestoreDone); // Collect statistics
         if ( g_dwErrorLogging )
         {
            ReportAnEvent( MSG_CONNECTION_RESTORED,
                           EVENTLOG_WARNING_TYPE,
                           0,
                           NULL );
         }
      }
  }

  return( dwResult );
}



//****************************************************************************
//                         --- TestRemoteSiteRetry ---
//
// Purpose: Checks is remote site alive
//   Input: LPCTSTR szRemoteSite - IP address in string form
//  Output: DWORD                - RETCODE_DONE if successful
//                                       any other value is error
// Written: by Dmitry V. Stefankov 09.01.97
//****************************************************************************
DWORD  TestRemoteSiteRetry( LPCTSTR szRemoteSite, DWORD dwUseHardRetry)
{
    DWORD       dwResult = RETCODE_DONE;    // Function return code
    DWORD       dwFuncRes;
    WORD        wCount;                     // Attempts

    if ( dwUseHardRetry )
    {

        for ( wCount = 1; wCount <= RAS_HARD_RETRY_TIMES; wCount++ )
        {
#if defined(_DEBUG)
            OutputDebugString( TEXT("[RASKEEPD] I'm waiting before try again.\n\r") );
#endif                                      // #if defined(_DEBUG)
            if ( g_hHardRetryEvent != NULL )
            {
                dwFuncRes = WaitForSingleObject( g_hHardRetryEvent,
                                          RAS_HARD_RETRY_TIMEOUT * MS_PER_SEC );
            }
            else
            {
                Sleep( RAS_HARD_RETRY_TIMEOUT * MS_PER_SEC );
            }
            dwResult = TestRemoteSite( g_szRemoteIpNode );
            if ( dwResult == RETCODE_DONE )
            {
                goto Done;
            }
        }
    }
    else                                    // One times
    {
        dwResult = TestRemoteSite( g_szRemoteIpNode );
    }

Done:
    return (dwResult);
}


//****************************************************************************
//                         --- TestRemoteSite ---
//
// Purpose: Checks is remote site alive
//   Input: LPCTSTR szRemoteSite - IP address in string form
//  Output: DWORD                - RETCODE_DONE if successful
//                                       any other value is error
// Written: by Dmitry V. Stefankov 09.01.97
//****************************************************************************
DWORD  TestRemoteSite( LPCTSTR szRemoteSite )
{
  DWORD         dwResult = RETCODE_DONE;    // Function return code
  HANDLE        hFile;                      // ICMP object handle
  DWORD         dwFuncRetCode;              // Function result code
  DWORD         dwDestIpAddr;               // IP destinantion address (packed)
  DWORD         dwRemoteIpAddr;             // IP reply address (packed)
  PICMP_ECHO_REPLY   RecvIcmpReply;         // ICMP reply datagran
  BYTE        chSentBuf[ICMP_SENT_BUF_SIZE];// ICMP optional data (to send)
  BYTE        chRecvBuf[ICMP_RECV_BUF_SIZE];// ICMP  receive buffer
  TCHAR       chTempBuf[512];               // Temporary storage
#ifdef _UNICODE
  CHAR        szIpAddrSite[IP_ADDRESS_SIZE];// ANSI verison of IP address
  int         iFuncRes;                     // Function result
#endif                                      // #ifdef _UNICODE

//------------------------- Check Dial-Up case ----------------------------

#if defined(_DEBUG)
     OutputDebugString( TEXT("[RASKEEPD] Test remote site.\n\r") );
#endif                                      // #if defined(_DEBUG)

 if ( g_dwDialUpLine )
 {
#if defined(_DEBUG)
     OutputDebugString( TEXT("[RASKEEPD]: We skip a ping phase.\n\r") );
#endif                                      // #if defined(_DEBUG)
    dwResult = RETCODE_SKIP_PING_PHASE;
    return( dwResult );
 }

//------------------------- Check Windows Sockets ----------------------------

  if ( g_fWinsock == FALSE )
  {
#if defined(_DEBUG)
     OutputDebugString( TEXT("ERROR: No Windows Sockets to make a ping.\n\r") );
#endif                                      // #if defined(_DEBUG)
     dwResult = RETCODE_NO_WINSOCK;
     return( dwResult );
  }

//------------------- Convert IP address to binary form ----------------------

#ifdef _UNICODE
  iFuncRes = WideCharToMultiByte( CP_ACP,   // code page 
                                       0,   // performance and mapping flags 
                        &szRemoteSite[0],   // address of wide-character string 
                                      -1,   // number of characters in string 
                          &szIpAddrSite[0], // address of buffer for new string 
                      sizeof(szIpAddrSite), // size of buffer 
                                    NULL,   // address of default for unmappable characters  
                                    NULL);  // address of flag set when default char. used 
  dwDestIpAddr = inet_addr( szIpAddrSite );
#else
  dwDestIpAddr = inet_addr( szRemoteSite );
#endif                                      // #ifdef _UNICODE
#if defined(_DEBUG)
  _stprintf( chTempBuf, TEXT("[RASKEEPD] Destination IP address: 0x%X (%s)\n"),
           dwDestIpAddr, szRemoteSite );
  OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)

//--------------------------- Open ICMP handle -------------------------------

#if defined(_DEBUG)
  OutputDebugString( TEXT("[RASKEEPD] Create ICMP handle.\n\r") );
#endif                                      // #if defined(_DEBUG)

  hFile = IcmpCreateFile();

  if ( hFile == NULL )
  {
#if defined(_DEBUG)
     OutputDebugString( TEXT("ERROR: Cannot create ICMP handle.\n\r") );
#endif                                      // #if defined(_DEBUG)
     dwResult = RETCODE_NO_CREATE_ICMP;
     goto Done;
  }

//------------------------- Send ICMP echo packet ----------------------------

#if defined(_DEBUG)
  OutputDebugString( TEXT("[RASKEEPD] Send ICMP echo packet.\n\r") );
#endif                                      // #if defined(_DEBUG)

  memset( chSentBuf, ICMP_DATA_FILL_CHAR, sizeof(chSentBuf) );
#if defined(_DEBUG)
  _stprintf( chTempBuf, TEXT("[RASKEEPD] Sent data byte:  0x%2X\n"), chSentBuf[0] );
  OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)

  InterlockedIncrement(&g_dwSentPings);     // Collect statistics
  dwFuncRetCode = IcmpSendEcho(hFile,       // ICMP handle
                               dwDestIpAddr,// IP destination address
                               chSentBuf,   // Data buffer to sent
                               g_wDataSize, // Length of data buffer to sent
                               NULL,        // IP Options pointer
                               chRecvBuf,   // Data buffer to receive
                          sizeof(chRecvBuf),// Length of receive buffer 
                            g_dwPingTimeout // Timeout in milliseconds
                              );

  if ( dwFuncRetCode == TRUE )
  {
#if defined(_DEBUG)
     OutputDebugString( TEXT("[RASKEEPD] Ping was successful.\n\r") );
#endif                                      // #if defined(_DEBUG)
     RecvIcmpReply = (PICMP_ECHO_REPLY)chRecvBuf;
     dwRemoteIpAddr = RecvIcmpReply->Address;
#if defined(_DEBUG)
     _stprintf( chTempBuf, TEXT("[RASKEEPD] Reply IP address: 0x%X (%u.%u.%u.%u)\n"),
                      dwRemoteIpAddr,
                      dwRemoteIpAddr & 0xFF, dwRemoteIpAddr >> 8 & 0xFF,
                      dwRemoteIpAddr >> 16 & 0xFF, dwRemoteIpAddr >> 24 & 0xFF );
     OutputDebugString( chTempBuf );
     _stprintf( chTempBuf, TEXT("[RASKEEPD] Reply IP status:  0x%X\n"),
              RecvIcmpReply->Status );
     OutputDebugString( chTempBuf );
     _stprintf( chTempBuf, TEXT("[RASKEEPD] Reply RTT (ms):   0x%u\n"),
              RecvIcmpReply->RoundTripTime );
     OutputDebugString( chTempBuf );
     _stprintf( chTempBuf, TEXT("[RASKEEPD] Reply datasize:   0x%u\n"),
              RecvIcmpReply->DataSize );
     OutputDebugString( chTempBuf );
     _stprintf( chTempBuf, TEXT("[RASKEEPD] Reply data byte:  0x%2X\n"),
              *(PBYTE)(RecvIcmpReply->Data) );
     OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
     if ( dwRemoteIpAddr != dwDestIpAddr )
     {
#if defined(_DEBUG)
  OutputDebugString(
       TEXT("ERROR: Answer has wrong IP address. Please check your IP routing.\n\r")
                   );
#endif                                      // #if defined(_DEBUG)
        InterlockedIncrement(&g_dwNoAckdPings); // Collect statistics
        dwResult = RETCODE_WRONG_IP_ADDR;
     }
     else
     {
         InterlockedIncrement(&g_dwAckdPings); // Collect statistics
	     if ( g_dwErrorLogging )
	     {
			 if  (  ( g_dwAckdPings == 1 ) || 
			        ( g_dwAckdPings == (g_dwAckdPings/50)*50)  )
			 {
                 ReportAnEvent( MSG_CONNECTION_ALIVE,
                                EVENTLOG_INFORMATION_TYPE,
                                0,
                                NULL );
			 }
		 }
         g_fFailMessage   = FALSE;          // Reset failure flag
		 g_fBrokenMessage = FALSE;			// Reset broken flag
     }
  }
  else
  {
     InterlockedIncrement(&g_dwNoAckdPings); // Collect statistics
     dwFuncRetCode = GetLastError();
     _stprintf( chTempBuf, TEXT("ERROR: Ping failed. Extended error code = %lu"),
              dwFuncRetCode );
#if defined(_DEBUG)
     OutputDebugString( chTempBuf );
     OutputDebugString( TEXT("\n\r") );
#endif                                      // #if defined(_DEBUG)
     if ( g_dwErrorLogging )
     {
            if ( g_fFailMessage == FALSE )
            {
               TCHAR  *pTemp = (TCHAR *)&chTempBuf;
               g_fFailMessage = TRUE;
               ReportAnEvent( MSG_BAD_PING,
                              EVENTLOG_ERROR_TYPE,
                              1,
                              &pTemp );
            }
     }
     dwResult = dwFuncRetCode;
  }

//--------------------------- Close ICMP handle ------------------------------

#if defined(_DEBUG)
  OutputDebugString( TEXT("[RASKEEPD] Close ICMP handle.\n\r") );
#endif                                      // #if defined(_DEBUG)
  IcmpCloseHandle( hFile );

Done:
   if  (dwResult == RETCODE_DONE)
   {
#if defined(_DEBUG)
      OutputDebugString( TEXT("[RASKEEPD] Remote site is alive.\n\r") );
#endif                                      // #if defined(_DEBUG)
   }

   return( dwResult );
}



//****************************************************************************
//                        --- TestRasConnection ---
//
// Purpose: Checks a RAS connection state
//   Input: LPTSTR szEntryName - RAS phonebook entryname
//  Output: DWORD              - RETCODE_DONE if successful
//                               any other value is error
// Written: by Dmitry V. Stefankov 09.01.97
//****************************************************************************
DWORD  TestRasConnection( LPTSTR szEntryName )
{
   DWORD      dwRetCode = RETCODE_DONE;     // Function return code
   RASCONNSTATUS  RasConnStatus;            // RAS connection status buffer
   HRASCONN  hRasConn = NULL;               // RAS connection handle
   DWORD     dwErrorCode;                   // Function result code
#if defined(_DEBUG)
   TCHAR     chTempBuf[512];                // Temporary storage
#endif                                      // #if defined(_DEBUG)

//------------------- Find matching opening connection -----------------------

#if defined(_DEBUG)
   OutputDebugString( TEXT("[RASKEEPD] I'm testing RAS connection.\n\r") );
#endif                                      // #if defined(_DEBUG)

   hRasConn = FindRasConnection( szEntryName );
   if ( hRasConn == NULL )
   {
      dwRetCode = RETCODE_NO_MATCH_CONN;
      return( dwRetCode );
   }

//--------------------- Check found connection state -------------------------

#if defined(_DEBUG)
   OutputDebugString( TEXT("[RASKEEPD] test user connection.\n\r") );
#endif                                      // #if defined(_DEBUG)
   RasConnStatus.dwSize = sizeof(RasConnStatus);
   dwErrorCode = RasGetConnectStatus( hRasConn, &RasConnStatus );

   if ( dwErrorCode == 0 )
   {
#if defined(_DEBUG)
       OutputDebugString( TEXT("[RASKEEPD] User connection is active.\n\r") );
#endif                                      // #if defined(_DEBUG)
#if defined(_DEBUG)
      _stprintf( chTempBuf, TEXT("[RASKEEPD] Connection state value = '0x%X'\n"),
               RasConnStatus.rasconnstate );
      OutputDebugString( chTempBuf );
      _stprintf( chTempBuf, TEXT("[RASKEEPD] Connection device type = '%s'\n"),
               RasConnStatus.szDeviceType );
      OutputDebugString( chTempBuf );
      _stprintf( chTempBuf, TEXT("[RASKEEPD] Connection device name = '%s'\n"),
               RasConnStatus.szDeviceName );
      OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
      if ( RasConnStatus.rasconnstate != RASCS_Connected )
      {
#if defined(_DEBUG)
         OutputDebugString( TEXT("[RASKEEPD] Connection found but not established.\n\r") );
#endif                                      // #if defined(_DEBUG)
         dwRetCode = RETCODE_CONN_NOT_LINKED;
      }
   }
   else
   {
      dwRetCode = dwErrorCode;
#if defined(_DEBUG)
      _stprintf( chTempBuf,
               TEXT("ERROR: connection status failed. Error code = %lu\n"),
               dwErrorCode );
      OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
   }

   return( dwRetCode );
}



//****************************************************************************
//                       --- CloseRasConnection ---
//
// Purpose: Close a RAS connection
//   Input: LPTSTR szEntryName - RAS phonebook entryname
//  Output: DWORD              - RETCODE_DONE if successful
//                               any other value is error
// Written: by Dmitry V. Stefankov 09.01.97
//****************************************************************************
DWORD  CloseRasConnection( LPTSTR szEntryName )
{
   DWORD     dwRetCode = RETCODE_DONE;      // Function exit code
   TCHAR     szErrorString[512];            // Error string buffer
   HRASCONN  hRasConn = NULL;               // RAS connection handle
   DWORD     dwErrorCode;                   // Function result code
   DWORD     dwFuncRes;                     // Function return code
#if defined(_DEBUG)
   TCHAR     chTempBuf[512];                // Temporary storage
#endif                                      // #if defined(_DEBUG)

//------------------- Find matching opening connection -----------------------

#if defined(_DEBUG)
   OutputDebugString( TEXT("[RASKEEPD] I'm closing RAS connection.\n\r") );
#endif                                      // #if defined(_DEBUG)

   hRasConn = FindRasConnection( szEntryName );
   if ( hRasConn == NULL )
   {
      dwRetCode = RETCODE_NO_MATCH_CONN;
      return( dwRetCode );
   }

//--------------------- Try to close found connection ------------------------

#if defined(_DEBUG)
   OutputDebugString( TEXT("[RASKEEPD] Close user connection.\n\r") );
#endif                                      // #if defined(_DEBUG)
   dwErrorCode = RasHangUp( hRasConn );
#if defined(_DEBUG)
   _stprintf( chTempBuf, TEXT("ERROR: connection return code = %lu.\n"), 
              dwErrorCode );
   OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
                                            // We wait according Microsoft words
    if ( g_hHardRetryEvent != NULL )
    {
        dwFuncRes = WaitForSingleObject( g_hHardRetryEvent,
                                         STD_SRVC_WAIT_TIME * MS_PER_SEC  );
    }
    else
    {
        Sleep( STD_SRVC_WAIT_TIME * MS_PER_SEC ); // Empirical time
    }

//--------------------- Connection closed? -----------------------------------

   if ( dwErrorCode != 0 )
   {
      dwRetCode = dwErrorCode;
      if ( RasGetErrorString( dwErrorCode, szErrorString,
                                        sizeof(szErrorString)) == 0 )
      {
#if defined(_DEBUG)
         _stprintf( chTempBuf, TEXT("ERROR: Description: %s\n"), szErrorString );
         OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
      }
   }
   else
   {
#if defined(_DEBUG)
      OutputDebugString( TEXT("[RASKEEPD] Connection successfully closed.\n\r") );
#endif                                      // #if defined(_DEBUG)
   }

   return( dwRetCode );
}



//****************************************************************************
//                        --- OpenRasConnection ---
//
// Purpose: Open a RAS phonebook connection
//   Input: LPTSTR szEntryName - RAS phonebook entryname
//  Output: DWORD              - RETCODE_DONE if successful
//                               any other value is error
// Written: by Dmitry V. Stefankov 09.01.97
//****************************************************************************
DWORD  OpenRasConnection( LPTSTR szEntryName )
{
  DWORD            dwRetCode = RETCODE_DONE;// Function return code
  DWORD            dwErrorCode;             // Function error code
  HRASCONN         hRasConn;                // RAS connection handle
  RASDIALPARAMS    rdRasDialParams;         // RAS calling parameters
  TCHAR            szErrorString[512];      // Error string buffer
#if defined(_DEBUG)
  TCHAR            chTempBuf[512];          // Temporary storage
  TCHAR            *pszDialParameters[4];   // RAS entry/user/pass/domain
#endif                                      // #if defined(_DEBUG)

#if defined(_DEBUG)
   OutputDebugString( TEXT("[RASKEEPD] I'm opening RAS link connection.\n\r") );
   _stprintf( chTempBuf, TEXT("[RASKEEPD] User RAS entryname: '%s'.\n"), szEntryName );
   OutputDebugString( chTempBuf );
   OutputDebugString( TEXT("[RASKEEPD] Make connection (rasdial).\n\r") );
#endif                                      // #if defined(_DEBUG)

//------------------ Build RAS dial structure parameters ---------------------

  rdRasDialParams.dwSize  = sizeof(RASDIALPARAMS);
  _tcscpy( rdRasDialParams.szEntryName, szEntryName );
  rdRasDialParams.szPhoneNumber[0]       = TEXT('\0');
  rdRasDialParams.szPhoneNumber[1]       = TEXT('\0');
  rdRasDialParams.szCallbackNumber[0]    = TEXT('*');
  rdRasDialParams.szCallbackNumber[0]    = TEXT('\0');

  if ( g_szUserName[0] != TEXT('\0') )
  {
      _tcscpy( rdRasDialParams.szUserName, g_szUserName );
      _tcscpy( rdRasDialParams.szPassword, g_szUserPass );
      _tcscpy( rdRasDialParams.szDomain, g_szUserDomain );
  }
  else
  {
      rdRasDialParams.szUserName[0]   = TEXT('\0');
      rdRasDialParams.szPassword[0]   = TEXT('\0');
      rdRasDialParams.szDomain[0]     = TEXT('*');
      rdRasDialParams.szDomain[1]     = TEXT('\0');
  }

#if defined(_DEBUG)
  pszDialParameters[0] = rdRasDialParams.szEntryName;
  pszDialParameters[1] = rdRasDialParams.szUserName;
  pszDialParameters[2] = rdRasDialParams.szPassword;
  pszDialParameters[3] = rdRasDialParams.szDomain;
  if ( g_dwErrorLogging )
  {
      ReportAnEvent( MSG_OPEN_CONNECTION,
                     EVENTLOG_INFORMATION_TYPE,
                     4,
                     pszDialParameters );
  }
#endif                                      // #if defined(_DEBUG)

//------------------------ Call RAS dial function ----------------------------

  hRasConn = NULL;
  dwErrorCode = RasDial(
                        NULL,               // pointer to function extensions data
                        NULL,               // pointer to full path and filename of phonebook file
                        &rdRasDialParams,   // pointer to calling parameters data
                        0xFFFFFFFF,         // specifies type of RasDial event handler
                        NULL,               // specifies a handler for RasDial events
                        &hRasConn           // pointer to variable to receive connection handle
                     );

//------------------------ Processing return code ----------------------------

  switch ( dwErrorCode )
  {
     case ERROR_SUCCESS:
#if defined(_DEBUG)
             OutputDebugString( TEXT("[RASKEEPD] Connection established successful.\n\r") );
#endif                                      // #if defined(_DEBUG)
             break;

     default:
#if defined(_DEBUG)
             _stprintf( chTempBuf, TEXT("ERROR: connection not established, error code = %lu.\n"),
                      dwErrorCode );
             OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
             break;
  }

  if ( dwErrorCode != ERROR_SUCCESS )
  {
      dwRetCode = dwErrorCode;
      if ( RasGetErrorString( dwErrorCode, szErrorString,
                                      sizeof(szErrorString)) == 0 )
      {
#if defined(_DEBUG)
         _stprintf( chTempBuf, TEXT("ERROR: Description: %s\n"), szErrorString );
         OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
      }
  }

  return( dwRetCode );
}



//****************************************************************************
//                        --- FindRasConnection ---
//
// Purpose: Find a matching opening RAS connection
//   Input: LPTSTR   szEntryName - RAS phonebook entryname
//  Output: HRASCONN             - NULL if not found
//                                 otherwise handle of opened connection
// Written: by Dmitry V. Stefankov 09.01.97
//****************************************************************************
HRASCONN    FindRasConnection   ( LPTSTR szEntryName )
{
   RASCONN   rdAllRasConnStatus[RAS_MaxEntryName];
                                            // 256 elements
   DWORD     dwBufSize = sizeof(rdAllRasConnStatus);
                                            // Received buffer size
   HRASCONN  hRasConn = NULL;               // RAS connection handle
   DWORD     dwActConns = 0;                // Counter of RAS connections
   DWORD     i;                             // General counter
   DWORD     dwIndex = BAD_ENTRY_INDEX;     // Entryname index
   DWORD     dwErrorCode;                   // Function result code
#if defined(_DEBUG)
   TCHAR     chTempBuf[512];                // Temporary storage
#endif                                      // #if defined(_DEBUG)

#if defined(_DEBUG)
   OutputDebugString( TEXT("[RASKEEPD] Find matching RAS connection.\n\r") );
   _stprintf( chTempBuf, TEXT("[RASKEEPD] User RAS entryname: '%s'.\n"), szEntryName );
   OutputDebugString( chTempBuf );
   OutputDebugString( TEXT("[RASKEEPD] Build active connections list.\n\r") );
#endif                                      // #if defined(_DEBUG)
   _tcsupr( szEntryName );

//-------------------------- Some initialization -----------------------------

   for ( i=0; i<RAS_MaxEntryName; i++ )
   {
      rdAllRasConnStatus[i].dwSize = sizeof(RASCONN);
      rdAllRasConnStatus[i].szEntryName[0] = TEXT('\0');
   }

//--------------------- Return active connections list ------------------------

   dwErrorCode = RasEnumConnections( (LPRASCONN)&rdAllRasConnStatus,
                                     &dwBufSize, &dwActConns );

   if ( dwActConns == 0 )
   {
#if defined(_DEBUG)
        OutputDebugString( TEXT("ERROR: No active connections.\n\r") );
#endif                                      // #if defined(_DEBUG)
        return( hRasConn );
   }
   else
   {
#if defined(_DEBUG)
       _stprintf( chTempBuf, TEXT("[RASKEEPD] Active connections number = %lu\n"),
                dwActConns );
       OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
   }

//------- Scan active connections list to find matching connection -----------

   for ( i=0; i<dwActConns; i++ )
   {
      if ( (rdAllRasConnStatus[i].hrasconn != NULL) &&
          (rdAllRasConnStatus[i].szEntryName[0] != TEXT('\0')) )
      {
#if defined(_DEBUG)
         _stprintf( chTempBuf, TEXT("[RASKEEPD] Entry %lu = '%s'\n"), i,
                  rdAllRasConnStatus[i].szEntryName );
         OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
         if ( _tcscmp(szEntryName,rdAllRasConnStatus[i].szEntryName) == 0 )
         {
            dwIndex = i;
#if defined(_DEBUG)
            _stprintf( chTempBuf, TEXT("[RASKEEPD] Matching entry = %lu\n"), dwIndex );
            OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
         }
      }
   }

//------------------ Return found RAS connection handle ----------------------

   if  ( dwIndex != BAD_ENTRY_INDEX )
   {
      hRasConn = rdAllRasConnStatus[dwIndex].hrasconn;
   }
   else
   {
#if defined(_DEBUG)
        OutputDebugString( TEXT("ERROR: Matching connection not found.\n\r") );
#endif                                      // #if defined(_DEBUG)
   }

   return( hRasConn );
}



//****************************************************************************
//                       --- AddSourceToRegistry ---
//
// Purpose:  Add a source name key, message DLL name value, and
//           message type supported value to the registry
//   Input:  LPTSTR pszAppname - source name
//           LPTSTR pszMsgDLL  - path of message DLL or application
//  Output: none
// Written: by Dmitry V. Stefankov 1/30/97
// Notes:
//     When an application uses the RegisterEventSource or OpenEventLog
//     function to get a handle of an event log, the event loggging service
//     searches for the specified source name in the registry. You can add a
//     new source name to the registry by opening a new registry subkey
//     under the Application key and adding registry values to the new
//     subkey.
//****************************************************************************
void  AddSourceToRegistry( LPTSTR pszAppname, LPTSTR pszMsgDLL )
{
  HKEY          hk;                         // Registry key handle
  DWORD         dwData;                     //  Types of messages
  BOOL          bSuccess;                   // Function result
  DWORD         dwDisposition;              // Result of key creation
  TCHAR         szKeyName[512];             // Keyname

//----------------- Create a new key for our application ---------------------

  _tcscpy( szKeyName, g_szServicesKey );
  _tcscat( szKeyName, g_szEventLogKeyApp );
  _tcscat( szKeyName, pszAppname );
  bSuccess = RegCreateKeyEx( HKEY_LOCAL_MACHINE,
                            szKeyName,
                            0,
                            NULL,
                            REG_OPTION_NON_VOLATILE,
                            KEY_ALL_ACCESS,
                            NULL,
                            &hk,
                            &dwDisposition );
  if ( bSuccess =! ERROR_SUCCESS )
  {
#if defined(_DEBUG)
        OutputDebugString( TEXT("ERROR: Cannot create eventlog key.\n\r") );
#endif                                      // #if defined(_DEBUG)
  }

//----------- Add the Event-ID message-file name to the subkey ---------------

  bSuccess = RegSetValueEx(hk,              // Subkey handle
                   TEXT("EventMessageFile"),// Value name
                    0,                      // Must be zero
                    REG_EXPAND_SZ,          // Value type
                    (LPBYTE) pszMsgDLL,     // Address of value data
                    (_tcslen(pszMsgDLL) + 1)*sizeof(TCHAR)); 
                                            // Length of value data
  if ( bSuccess == ERROR_SUCCESS )
  {
#if defined(_DEBUG)
     OutputDebugString( TEXT("ERROR: Cannot set value for eventlog key (file).\n\r") );
#endif                                      // #if defined(_DEBUG)
  }

//--------- Set the supported types flags and addit to the subkey ------------

  dwData = EVENTLOG_ERROR_TYPE | EVENTLOG_WARNING_TYPE |
      EVENTLOG_INFORMATION_TYPE;
  bSuccess = RegSetValueEx(hk,              // Subkey handle
                     TEXT("TypesSupported"),// Value name
                           0,               // Must be zero
                           REG_DWORD,       // Value type
                           (LPBYTE) &dwData,// Address of value data
                           sizeof(DWORD));  // Length of value data
  if ( bSuccess == ERROR_SUCCESS )
  {
#if defined(_DEBUG)
     OutputDebugString(
              TEXT("ERROR: Cannot set value for eventlog key (flags).\n\r")
                      );
#endif                                      // #if defined(_DEBUG)
  }

  RegCloseKey( hk );
  return;
}



//****************************************************************************
//                          --- ReportAnEvent ---
//
// Purpose: Add the event to the event log
//   Input: DWORD     dwIdEvent  -  the event ID to report in the log
//          WORD      wEventType -  event type for log
//          WORD      cStrings   -  the number of insert strings
//          LPTSTR  * pszStrings -  an array of null-terminated insert strings
//  Output: none
// Written: by Dmitry V. Stefankov 1/30/97
//****************************************************************************
void ReportAnEvent(DWORD dwIdEvent, WORD wEventType, WORD cStrings,
                   LPTSTR *pszStrings)
{
  HANDLE        hAppLog;                    // Event handle
  BOOL          bSuccess;                   // Function result

//--------------- Get a handle to the Application event log ------------------

  hAppLog = RegisterEventSource( NULL,      // Use local machine
                                 g_szServiceName
                                );          // Source name
  if  ( hAppLog == NULL )
  {
#if defined(_DEBUG)
     OutputDebugString( TEXT("ERROR: RegisterEventSource(...) failed .\n\r") );
#endif                                      // #if defined(_DEBUG)
      return;
  }

//-------------------- Add user event to the event log -----------------------

  bSuccess = ReportEvent( hAppLog,           // Event-log handle
                          wEventType,        // Event type
                          0,                 // Category zero
                          dwIdEvent,         // Event ID
                          NULL,              // No user SID
                          cStrings,          // Number of substitution strings
                          0,                 // No binary data
                          pszStrings,        // String array
                          NULL );            // Address of data
  if ( bSuccess == FALSE)
  {
#if defined(_DEBUG)
     OutputDebugString( TEXT("ERROR: ReportEvent(...) failed .\n\r") );
#endif                                      // #if defined(_DEBUG)
  }

  DeregisterEventSource( hAppLog );

  return;
}



//****************************************************************************
//                           --- AppCleanUp ---
//
// Purpose: Cleanup before exit to system
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 12.02.97
//****************************************************************************
VOID AppCleanUp()
{

#if defined(_DEBUG)
     OutputDebugString( TEXT("Do clean-up before termination.\n\r") );
#endif                                      // #if defined(_DEBUG)

//--------------------- Remove event objects --------------------------------

    if ( g_hServerStopEvent != NULL )
    {
        CloseHandle( g_hServerStopEvent );
    }
    if ( g_hRasThreadStopEvent != NULL )
    {
        CloseHandle( g_hRasThreadStopEvent );
      }
    if ( g_hRasThreadAliveEvent != NULL )
    {
        CloseHandle( g_hRasThreadAliveEvent );
    }
    if ( g_hHardRetryEvent != NULL )
    {
        CloseHandle( g_hHardRetryEvent );
    }

//------------------- Remove the critical section ------------------------

     DeleteCriticalSection(&g_GlobalCriticalSection);

}



//****************************************************************************
//                           --- AdjustRights ---
//
// Purpose: Adjust process privilege rights
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 24.02.97
//****************************************************************************
DWORD  AdjustRights()
{
    HANDLE              hToken;             // Process Token
    TOKEN_PRIVILEGES    tkp;                // Privilege Token

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] Adjust privilege rights.\n\r") );
#endif                                      // #if defined(_DEBUG)

//----------------- Get a token for this process -----------------------------
 
    if ( !OpenProcessToken(
                    GetCurrentProcess(),    // Handle of process
     TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, // Desired access to process
                    &hToken) )              // Address of handle of 
                                            //  open access token
    {
#if defined(_DEBUG)
        OutputDebugString( TEXT("[RASKEEPD] OpenProcessToken(...) failed.\n\r") );
#endif                                      // #if defined(_DEBUG)
        goto BadReturn;
    }

//----------------- Get the LUID for the shutdown privilege ------------------
 
    LookupPrivilegeValue( NULL,             // Address of string specifying the system
                          SE_SHUTDOWN_NAME, // Address of string specifying the privilege
                   &tkp.Privileges[0].Luid);// Address of locally unique identifier
 
    tkp.PrivilegeCount = 1;                 // One privilege to set    
    tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED; 

//------------------ Get the shutdown privilege for this process -------------
 
    AdjustTokenPrivileges(hToken,           // Handle of token that contains privileges 
                          FALSE,            // Flag for disabling all privileges
                          &tkp,             // Address of new privilege information
                          0,                // Size of previous information buffe
                    (PTOKEN_PRIVILEGES)NULL,// Address of previous information
                          0);               // Address of required buffer size

//---------------- Test the return value of AdjustTokenPrivileges ------------
 
    if ( GetLastError() != ERROR_SUCCESS ) 
    {
#if defined(_DEBUG)
        OutputDebugString( TEXT("[RASKEEPD] AdjustTokenPrivileges(...) failed.\n\r") );
#endif                                      // #if defined(_DEBUG)
        goto BadReturn;
    }

    return (1);                             // Enable shutdown

BadReturn:
	if ( g_dwErrorLogging )
	{
        ReportAnEvent( MSG_SERVICE_BAD_RIGHTS,
                       EVENTLOG_ERROR_TYPE,
                       0,
                       NULL );
	}
	return (0);
}



//****************************************************************************
//                           --- SystemShutdown ---
//
// Purpose: Closes all aplications and restarts system
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 24.02.97
//****************************************************************************
VOID  SystemShutdown()
{
    BOOL        fFuncRes;                   // Function result
#if defined(_DEBUG)
    TCHAR       chTempBuf[512];             // Temporary buffer
    TCHAR       szErrorString[512];         // Error message buffer
#endif                                      // #if defined(_DEBUG)

#if defined(_DEBUG)
    OutputDebugString( TEXT("[RASKEEPD] Make a system shutdown.\n\r") );
#endif                                      // #if defined(_DEBUG)
    fFuncRes = InitiateSystemShutdown( 
                                    NULL,   // Machine name
 TEXT("[RAS Connection Keep Daemon]\nUnable to restore a user connection!\nSystem shutdown was initiated!"),
                                            // Address of message to display 
                                            //   in dialog box 
                    SYSTEM_SHUTDOWN_TIME,   // Time to display dialog box 
                                    TRUE,   // Force applications with 
                                            //   unsaved changes flag 
                                    TRUE);  // Reboot flag 

    if ( fFuncRes == TRUE )
    {
        if ( g_dwErrorLogging )
        {
            ReportAnEvent( MSG_SHUTDOWN_SYSTEM,
                           EVENTLOG_WARNING_TYPE,
                           0,
                           NULL );
        }
    }
    else
    {
#if defined(_DEBUG)
    _stprintf( chTempBuf, TEXT("ERROR: %s\n"), GetLastErrorText( szErrorString, 256 ) );
    OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
    }
}
