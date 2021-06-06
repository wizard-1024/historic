//****************************************************************************
//                             File RASKEEP.C
//
//            Control Panel Applet for RAS Connection Keep Service
//
//      Copyright (c) Dmitry V. Stefankov, 1997. All rights reserved.
//
//****************************************************************************
//
//   $Source: F:/MSVC20/SOURCE/RASKEEPD/RCS/raskeep.c $
//  $RCSfile: raskeep.c $
//   $Author: dstef $
//     $Date: 1998/10/03 13:50:36 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: raskeep.c $
//      Revision 1.1  1998/10/03 13:50:36  dstef
//      Initial revision
//
//
//****************************************************************************



//----------------------------- Standard Files -------------------------------

#include "compile.h"                        // Compilation switches

#include <windows.h>                        // Windows standard defs
#include <stdio.h>                          // Standard I/O library
#include <cpl.h>                            // Control Panel Applet
#include <tchar.h>                          // Unicode


//------------------------- Remote Access Service ----------------------------

#include <ras.h>                            // Remote Access Service
#include <raserror.h>                       // RAS error definitions


//--------------------------- Project specific -------------------------------

#include "rasdefs.h"                        // Project definitions
#include "rasproto.h"                       // Data declarations
#include "rasdata.h"                        // Data definitions
#include "fproto.h"                         // Function prototypes
#include "debug.h"                          // Debugging definitions

#include "raskeep.h"                        // Private definitions


//----------------------------- Private data ---------------------------------

APPLETS g_RasKeepApplets[] =                // CPL
{
    PHONE_ICON,
    RASKEEP_NAME,
    RASKEEP_DESC,
    RASKEEP_DLG,
    (DLGPROC)RasKeepDlgProc
};

#define NUM_APPLETS (sizeof(g_RasKeepApplets)/sizeof(g_RasKeepApplets[0]))


HANDLE          g_hModule     =   NULL;     // DLL handle
TCHAR           g_szCtlPanel[30];           // Caption bar
OSVERSIONINFO   g_osvi;                     // OS version
TCHAR           g_szNtVersion[512];         // NT platform
TCHAR           g_szDaemonVersion[512];     // Service (daemon) version



//****************************************************************************
//                             --- DllMain ---
//
// Purpose: Win32 Initialization DLL
//   Input: IN PVOID         hmod     - DLL module window handle
//          IN ULONG         ulReason - system call code
//          IN PCONTEXT pctx OPTIONAL - process context
//  Output: BOOL WINAPI               - function result
// Written: by Dmitry V. Stefankov 1/21/97
//****************************************************************************
BOOL WINAPI DllMain( IN PVOID hmod, IN ULONG ulReason, IN PCONTEXT pctx OPTIONAL)
{
    if (ulReason != DLL_PROCESS_ATTACH)
    {
        return TRUE;
    }
    else
    {
        g_hModule = hmod;
    }

    return TRUE;

    UNREFERENCED_PARAMETER(pctx);
}



//****************************************************************************
//                        --- InitRasKeepApplet ---
//
// Purpose: Load the caption string for the Control Panel
//   Input: HWND hwndParent - parent window handle
//  Output: BOOL            - function result
// Written: by Dmitry V. Stefankov 1/21/97
//****************************************************************************
BOOL InitRasKeepApplet (HWND hwndParent)
{
    TCHAR   chTemp[512];                    // Temporary storage

    LoadString (g_hModule, CPCAPTION, g_szCtlPanel, sizeof(g_szCtlPanel));

//------------ Display Windows Platform type and version ---------------------
                
    g_osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
    GetVersionEx( &g_osvi );
    g_szNtVersion[0] = TEXT('\0');
    _tcscat( g_szNtVersion, TEXT("Microsoft (R) Windows ") );
    switch ( g_osvi.dwPlatformId )
    {
        case VER_PLATFORM_WIN32s:
                _tcscat( g_szNtVersion, TEXT("Win32s") );
                break; 
        case VER_PLATFORM_WIN32_WINDOWS:
                _tcscat( g_szNtVersion, TEXT("95") );
                break;
        case VER_PLATFORM_WIN32_NT:
                _tcscat( g_szNtVersion, TEXT("NT (TM)") );
                break;
        default:
                break;
    }
    _tcscat( g_szNtVersion, TEXT(" Platform\n") );
    _stprintf( chTemp, TEXT("Version %u.%02u ( build %u"), 
               g_osvi.dwMajorVersion, 
               g_osvi.dwMinorVersion, 
               g_osvi.dwBuildNumber & 0xFFFF);
    _tcscat( g_szNtVersion, chTemp );
    if ( g_osvi.szCSDVersion[0] != TEXT('\0') )
    {
       _tcscat( g_szNtVersion, TEXT(": ") );
       _tcscat( g_szNtVersion, g_osvi.szCSDVersion );
    }
    _tcscat( g_szNtVersion, TEXT(" )\n") );
    _stprintf( chTemp, TEXT("Copyright %c 1985-1997 Microsoft Corp."), COPYRIGHT_CHAR );
    _tcscat( g_szNtVersion, chTemp );

//------------ Display Program version and timestamp  ------------------------

    _stprintf( g_szDaemonVersion, 
               TEXT("RAS Connection Keep Daemon (%s)\n"), 
               g_szVersion );
    _stprintf( chTemp, TEXT("Release date:  %s\n"), TEXT(__DATE__) );
    _tcscat( g_szDaemonVersion, chTemp );
    _stprintf( chTemp, TEXT("Release time:  %s\n"), TEXT(__TIME__) );
    _tcscat( g_szDaemonVersion, chTemp );
    _stprintf( chTemp, TEXT("Copyright %c 1997 Dmitry V. Stefankov"), COPYRIGHT_CHAR );
    _tcscat( g_szDaemonVersion, chTemp );

    return TRUE;

    UNREFERENCED_PARAMETER(hwndParent);
}



//****************************************************************************
//                        --- TermRasKeepApplet ---
//
// Purpose: Termination procedure for the applet
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/21/97
//****************************************************************************
void TermRasKeepApplet()
{
    return;
}



//****************************************************************************
//                            --- CPlApplet ---
//
// Purpose: Processes messages for control panel applet
//   Input: HWND  hwndCPL  -  handle of Control Panel window
//          UINT  uMsg     -  message
//          LONG  lParam1  -  first message parameter
//          LONG  Param2   -  second message parameter
//  Output: LONG CALLBACK  -  result of processing (0 = OK)
// Written: by Dmitry V. Stefankov 1/21/97
//****************************************************************************
LONG CALLBACK CPlApplet ( HWND hwndCPL, UINT uMsg, LONG lParam1, LONG lParam2 )
{
    int           iFuncRes;                 // Function result
    int           iApplet;                  // Number of supported applets
    LPNEWCPLINFO  lpNewCPlInfo;             // CPL info
    static        iInitCount = 0;           // Access counter

    switch ( uMsg )
    {
        case CPL_INIT:                      // first message, sent once
            if ( !iInitCount )
            {
                if (!InitRasKeepApplet(hwndCPL))
                    return FALSE;
            }
            iInitCount++;
            return TRUE;

        case CPL_GETCOUNT:                  // second message, sent once
            return (LONG)NUM_APPLETS;
            break;

        case CPL_NEWINQUIRE:                // third message, sent once per app
            lpNewCPlInfo = (LPNEWCPLINFO) lParam2;

            iApplet = (int)lParam1;
            lpNewCPlInfo->dwSize = (DWORD) sizeof(NEWCPLINFO);
            lpNewCPlInfo->dwFlags = 0;
            lpNewCPlInfo->dwHelpContext = 0;
            lpNewCPlInfo->lData = 0;
            lpNewCPlInfo->hIcon = LoadIcon (g_hModule,
                (LPCTSTR) MAKEINTRESOURCE(g_RasKeepApplets[iApplet].icon));
            lpNewCPlInfo->szHelpFile[0] = TEXT('\0');

            LoadString (g_hModule, g_RasKeepApplets[iApplet].namestring,
                        lpNewCPlInfo->szName, 32);

            LoadString (g_hModule, g_RasKeepApplets[iApplet].descstring,
                        lpNewCPlInfo->szInfo, 64);
            break;

        case CPL_SELECT:                    // application icon selected
            break;


        case CPL_DBLCLK:                    // application icon double-clicked
            iApplet = (int)(LONG)lParam1;
            iFuncRes = DialogBox (
                         g_hModule,
                         MAKEINTRESOURCE(g_RasKeepApplets[iApplet].dlgtemplate),
                         hwndCPL,
                         g_RasKeepApplets[iApplet].dlgfn);
#if defined(_DEBUG)
            if (iFuncRes == -1)
            {
               MessageBox( hwndCPL, TEXT("Failed!"), 
                           TEXT("Dialog"), MB_OK|MB_ICONSTOP );
            }
#endif                                      // #if defined(_DEBUG)
            break;

         case CPL_STOP:                     // sent once per app. before CPL_EXIT
            break;

         case CPL_EXIT:                     // sent once before FreeLibrary called
            iInitCount--;
            if ( !iInitCount )
                TermRasKeepApplet();
            break;

         default:                           // otherwise ignore
            break;
    }
    return 0;
}



//****************************************************************************
//                         --- RasKeepDlgProc ---
//
// Purpose: Processes messages sent to the applet (dialog)
//   Input: HWND    hDlg    - parent window
//          UINT    message - message command
//          UINT    wParam  - parameter 1
//          LONG    lParam  - parameter 2
//  Output: BOOL APIENTRY   - TRUE  if processed
//                            FALSE if skipped
// Written: by Dmitry V. Stefankov 1/21/97
//****************************************************************************
BOOL APIENTRY RasKeepDlgProc (HWND hDlg, UINT message, UINT wParam, LONG lParam)
{
    int           iFuncRes;                 // Function result
    WORD          wMSG_ID;                  // Parameter

    switch ( message )
    {
        case WM_INITDIALOG:
                SetDefaultDialogItems( hDlg );
                return (TRUE);              // Read current user settings

        case WM_COMMAND:
            wMSG_ID = LOWORD(wParam);
            if ( wMSG_ID == IDOK )
            {
                GetUserDialogItems( hDlg ); // Save current user settings
                EndDialog( hDlg, TRUE );        
                return ( TRUE );
            }
            else if ( wMSG_ID == IDCANCEL )
            {
                EndDialog( hDlg, TRUE );
                return ( TRUE );
            }
            else if ( wMSG_ID == ID_HELP )
            {
               iFuncRes = DialogBox (
                         g_hModule,
                         MAKEINTRESOURCE( HELP_DLG ),
                         hDlg,
                         HelpDlgProc);
                return ( TRUE );
            }
            break;
    }
    return ( FALSE );
}



//****************************************************************************
//                      --- SetDefaultDialogItems ---
//
// Purpose: Read initial settings for user dialog
//   Input: HWND hDialog - parent window
//  Output: none
// Written: by Dmitry V. Stefankov 1/21/97
//****************************************************************************
VOID  SetDefaultDialogItems(HWND hDialog)
{
   TCHAR          chServiceStates[8][10] =  // Service status description
   {
     TEXT("undefined"), TEXT("stopped"), TEXT("stopping"), TEXT("starting"),
     TEXT("running"), TEXT("continued"), TEXT("pausing"), TEXT("paused")
   };
   BOOL             fFuncRes;               // Function result
   DWORD            dwFuncRetCode;          // Function return code
   SC_HANDLE        schService;             // Service handle
   SC_HANDLE        schSCManager;           // Service manager handle
   SERVICE_STATUS   ssServiceStatus;        // Service status
   int              iMsg = 0;               // Index of message

//------------ Try to get our service status from SC manager -----------------

   schSCManager = OpenSCManager(NULL,       // machine (NULL == local)
                                NULL,       // database (NULL == default)
                              GENERIC_READ);// access required


   if ( schSCManager != NULL )
   {
       schService = OpenService(
                           schSCManager,    // SC manager handle
                           g_szServiceName, // Service name
                           GENERIC_READ);   // Acccess required

       if ( schService != NULL )
       {
          fFuncRes = QueryServiceStatus(
                           schService,      // handle of service
                          &ssServiceStatus);// address of service status structure
          if ( fFuncRes == TRUE )
          {
             switch ( ssServiceStatus.dwCurrentState )
             {
                    case SERVICE_STOPPED:
                        iMsg = 1;
                        break;
                    case SERVICE_STOP_PENDING:
                        iMsg = 2;
                        break;
                    case SERVICE_START_PENDING:
                        iMsg = 3;
                        break;
                    case SERVICE_RUNNING:
                        iMsg = 4;
                        break;
                    case SERVICE_CONTINUE_PENDING:
                        iMsg = 5;
                        break;
                    case SERVICE_PAUSE_PENDING:
                        iMsg = 6;
                        break;
                    case SERVICE_PAUSED:
                        iMsg = 7;
                        break;
                    default:
                        iMsg = 0;
                        break;
             }
          }
       }

       CloseServiceHandle(schSCManager);
   }

   fFuncRes = SetDlgItemText(
                  hDialog,                  // handle of dialog box
                  ID_SERVICE_STAT,          // identifier of control
                  chServiceStates[iMsg]);   // text to set


//----------------------- Read registry or INI-file --------------------------

   dwFuncRetCode = ReadIniFile( NULL );

//--------------------------- [GENERAL] section ------------------------------

   fFuncRes = SetDlgItemInt(hDialog,        // handle of dialog box
                            ID_TEST_TIME,   // identifier of control
                            g_dwTestTime,   // value to set
                            FALSE);         // signed or unsigned indicator

   fFuncRes = SetDlgItemInt(hDialog,        // handle of dialog box
                            ID_RETRY_TIME,  // identifier of control
                            g_dwRetryTime,  // value to set
                            FALSE);         // signed or unsigned indicator

   fFuncRes = SetDlgItemInt(hDialog,        // handle of dialog box
                            ID_RETRY,       // identifier of control
                            g_dwRetry,      // value to set
                            FALSE);         // signed or unsigned indicator

   fFuncRes = CheckDlgButton(hDialog,       // handle of dialog box
                             ID_ERR_LOG,    // button-control identifier
                          g_dwErrorLogging);// check state

   fFuncRes = CheckDlgButton(hDialog,       // handle of dialog box
                             ID_CLOSE_RAS,  // button-control identifier
                           g_dwCloseRas);   // check state

   fFuncRes = CheckDlgButton(hDialog,       // handle of dialog box
                             ID_HARD_RETRY, // button-control identifier
                           g_dwHardRetry);  // check state

   fFuncRes = CheckDlgButton(hDialog,       // handle of dialog box
                             ID_SHUTDOWN,   // button-control identifier
                           g_dwShutDown);   // check state

   fFuncRes = SetDlgItemInt(hDialog,        // handle of dialog box
                            ID_ALIVE_TIME,  // identifier of control
                          g_dwAliveTime,    // value to set
                            FALSE);         // signed or unsigned indicator

//----------------------------- [RAS] section --------------------------------

   fFuncRes = SetDlgItemText(hDialog,       // handle of dialog box
                             ID_RAS_ENTRY,  // identifier of control
                         g_szUserEntryName);// text to set

   fFuncRes = SetDlgItemText(hDialog,       // handle of dialog box
                             ID_RAS_USER,   // identifier of control
                           g_szUserName);   // text to set

   fFuncRes = SetDlgItemText(hDialog,       // handle of dialog box
                             ID_RAS_PASS,   // identifier of control
                           g_szUserPass);   // text to set

   fFuncRes = SetDlgItemText(hDialog,       // handle of dialog box
                             ID_RAS_DOMAIN, // identifier of control
                           g_szUserDomain); // text to set

//---------------------------- [ICMP] section --------------------------------

   fFuncRes = SetDlgItemText(hDialog,       // handle of dialog box
                             ID_REMOTE_IP,  // identifier of control
                          g_szRemoteIpNode);// text to set

   fFuncRes = SetDlgItemInt(hDialog,        // handle of dialog box
                            ID_ICMP_TIMOUT, // identifier of control
                          g_dwPingTimeout,  // value to set
                            FALSE);         // signed or unsigned indicator

   fFuncRes = SetDlgItemInt(hDialog,        // handle of dialog box
                            ID_ICMP_DATSIZ, // identifier of control
                          g_wDataSize,      // value to set
                            FALSE);         // signed or unsigned indicator

}



//****************************************************************************
//                       --- GetUserDialogItems ---
//
// Purpose: Write new user settings
//   Input: HWND hDialog - parent window
//  Output: none
// Written: by Dmitry V. Stefankov 1/21/97
//****************************************************************************
VOID  GetUserDialogItems(HWND hDialog)
{

   UINT     dwFuncRes;                      // Function result
   BOOL     fSuccess;                       // Boolean switch

//--------------------------- [GENERAL] section ------------------------------

   dwFuncRes = GetDlgItemInt(hDialog,       // handle of dialog box
                             ID_TEST_TIME,  // identifier of control
                             &fSuccess,     // points to variable to receive
                                            // success/failure indicator
                             FALSE);        // signed or unsigned indicator
  if  ( fSuccess == TRUE )
       g_dwTestTime = dwFuncRes;

   dwFuncRes = GetDlgItemInt(hDialog,       // handle of dialog box
                             ID_RETRY_TIME, // identifier of control
                             &fSuccess,     // points to variable to receive
                                            // success/failure indicator
                             FALSE);        // signed or unsigned indicator
  if  ( fSuccess == TRUE )
       g_dwRetryTime = dwFuncRes;

   dwFuncRes = GetDlgItemInt(hDialog,       // handle of dialog box
                             ID_RETRY,      // identifier of control
                             &fSuccess,     // points to variable to receive
                                            // success/failure indicator
                             FALSE);        // signed or unsigned indicator
  if  ( fSuccess == TRUE )
       g_dwRetry = dwFuncRes;

  g_dwErrorLogging = IsDlgButtonChecked(
                                hDialog,    // handle of dialog box
                                ID_ERR_LOG  // button identifier
                                     );

  g_dwCloseRas = IsDlgButtonChecked(
                            hDialog,        // handle of dialog box
                            ID_CLOSE_RAS    // button identifier
                                 );

  g_dwHardRetry = IsDlgButtonChecked(
                            hDialog,        // handle of dialog box
                            ID_HARD_RETRY   // button identifier
                                 );

  g_dwShutDown = IsDlgButtonChecked(
                            hDialog,        // handle of dialog box
                            ID_SHUTDOWN     // button identifier
                                 );

  dwFuncRes = GetDlgItemInt(hDialog,        // handle of dialog box
                            ID_ALIVE_TIME,  // identifier of control
                            &fSuccess,      // points to variable to receive
                                            // success/failure indicator
                             FALSE);        // signed or unsigned indicator
  if  ( fSuccess == TRUE )
       g_dwAliveTime = dwFuncRes;

//----------------------------- [RAS] section --------------------------------

   dwFuncRes = GetDlgItemText(hDialog,      // handle of dialog box
                             ID_RAS_ENTRY,  // identifier of control
                         g_szUserEntryName, // address of buffer for text
             sizeof(g_szUserEntryName)-1 ); // address of buffer for text
                                            
   dwFuncRes = GetDlgItemText(hDialog,      // handle of dialog box
                             ID_RAS_USER,   // identifier of control
                           g_szUserName,    // address of buffer for text
                  sizeof(g_szUserName)-1 ); // address of buffer for text
                                            

   dwFuncRes = GetDlgItemText(hDialog,      // handle of dialog box
                             ID_RAS_PASS,   // identifier of control
                           g_szUserPass,    // address of buffer for text
                  sizeof(g_szUserPass)-1 ); // address of buffer for text
                                            

   dwFuncRes = GetDlgItemText(hDialog,      // handle of dialog box
                             ID_RAS_DOMAIN, // identifier of control
                           g_szUserDomain,  // address of buffer for text
                sizeof(g_szUserDomain)-1 ); // address of buffer for text
                                            

//---------------------------- [ICMP] section --------------------------------

   dwFuncRes = GetDlgItemText(hDialog,      // handle of dialog box
                             ID_REMOTE_IP,  // identifier of control
                          g_szRemoteIpNode, // address of buffer for text
              sizeof(g_szRemoteIpNode)-1 ); // address of buffer for text

   dwFuncRes = GetDlgItemInt(hDialog,       // handle of dialog box
                             ID_ICMP_TIMOUT,// identifier of control
                             &fSuccess,     // points to variable to receive
                                            // success/failure indicator
                             FALSE);        // signed or unsigned indicator
  if  ( fSuccess == TRUE )
       g_dwPingTimeout = dwFuncRes;

   dwFuncRes = GetDlgItemInt(hDialog,       // handle of dialog box
                             ID_ICMP_DATSIZ,// identifier of control
                             &fSuccess,     // points to variable to receive
                                            // success/failure indicator
                             FALSE);        // signed or unsigned indicator
  if  ( fSuccess == TRUE )
       g_wDataSize = (WORD)dwFuncRes;

//---------------------- Write registry or INI-file --------------------------

#if defined(WIN32_REGISTRY)
  WriteSectionGeneral();
  WriteSectionRas();
  WriteSectionIcmp();
#else
  // Not implemented yet.
#endif                                      // #if defined(WIN32_REGISTRY)

}



//****************************************************************************
//                         --- HelpDlgProc ---
//
// Purpose: Processes messages sent to the applet (dialog)
//   Input: HWND    hDlg    - parent window
//          UINT    message - message command
//          UINT    wParam  - parameter 1
//          LONG    lParam  - parameter 2
//  Output: BOOL APIENTRY   - TRUE  if processed
//                            FALSE if skipped
// Written: by Dmitry V. Stefankov 1/30/97
//****************************************************************************
BOOL APIENTRY HelpDlgProc (HWND hDlg, UINT message, UINT wParam, LONG lParam)
{
    WORD  wMSG_ID;                          // Window parameter
    int   iFuncRes;                         // Function result

    switch ( message )
    {
        case WM_INITDIALOG:
                return (TRUE);

        case WM_ENTERIDLE:
                break;

        case WM_COMMAND:
            wMSG_ID = LOWORD( wParam );
            if ( wMSG_ID == IDOK )
            {
                EndDialog( hDlg, TRUE );
                return (TRUE);
            }
            else if ( wMSG_ID == ID_ABOUT )
            {
                iFuncRes = DialogBox (
                                g_hModule,
                                MAKEINTRESOURCE( ABOUT_DLG ),
                                hDlg,
                                AboutDlgProc);
                return ( TRUE );
            }
            break;
    }
    return ( FALSE );
}



//****************************************************************************
//                         --- AboutDlgProc ---
//
// Purpose: Processes messages sent to the applet (dialog)
//   Input: HWND    hDlg    - parent window
//          UINT    message - message command
//          UINT    wParam  - parameter 1
//          LONG    lParam  - parameter 2
//  Output: BOOL APIENTRY   - TRUE  if processed
//                            FALSE if skipped
// Written: by Dmitry V. Stefankov 1/30/97
//          Some little help by neighbour-friend
//****************************************************************************
BOOL APIENTRY AboutDlgProc (HWND hDlg, UINT message, UINT wParam, LONG lParam)
{
    WORD  wMSG_ID;                          // Window parameter

    switch ( message )
    {
        case WM_INITDIALOG:
                SetDlgItemText( hDlg,       // handle of dialog box
                             ID_NT_VERSION, // identifier of control
                           g_szNtVersion);  // text to set
                SetDlgItemText(hDlg,        // handle of dialog box
                             ID_DAEMON_VER, // identifier of control
                        g_szDaemonVersion); // text to set 
                InvalidateRect(hDlg, NULL, TRUE);
                                            // Force to repaint
                return ( TRUE );
                break;

        case WM_PAINT:
                DrawImage( hDlg );          // Repaint in all cases
                break;          

        case WM_COMMAND:
            wMSG_ID = LOWORD( wParam );
            if ( wMSG_ID == IDOK )
            {
                EndDialog( hDlg, TRUE );
                return ( TRUE );
            }
            break;
    }
    return ( FALSE );
}



//****************************************************************************
//                         --- DrawImage ---
//
// Purpose: Draws image for specified window
//   Input: HWND    hWindow    - window handle
//  Output: NONE
// Written: by Dmitry V. Stefankov 24/2/97
//****************************************************************************
VOID  DrawImage(HWND hWindow)
{
    HBITMAP     hBMP;                       // Bitmap handle
    HBITMAP     hOldBitmap;                 // Bitmap handle
    HDC         hAboutDC;                   // Device Context handle
    HDC         hMemoryDC;                  // Device Context handle
    int         iStartX  = 19;              // Left upper corner (X-value)
    int         iStartY  = 12;              // Left upper corner (Y-value)
    int         iPhysSizeX  = 230;          // Hard-coded value from AUTHOR.BMP
    int         iPhysSizeY  = 173;          // Hard-coded value from AUTHOR.BMP

    hBMP = LoadBitmap( g_hModule, MAKEINTRESOURCE(AUTHOR_BMP) );
    if ( hBMP == NULL )
    {
        MessageBox( hWindow, TEXT("Unable to load bitmap!"), 
                    TEXT("ERROR MESSAGE BOX"), MB_OK|MB_ICONSTOP );
        return;
    }
    hAboutDC = GetDC( hWindow );
    hMemoryDC = CreateCompatibleDC( hAboutDC );
    hOldBitmap = SelectObject( hMemoryDC, hBMP );

    MoveToEx( hAboutDC, iStartX,              iStartY, NULL );
    LineTo(   hAboutDC, iStartX+iPhysSizeX+2, iStartY );
    LineTo(   hAboutDC, iStartX+iPhysSizeX+2, iStartY+iPhysSizeY+2 );
    LineTo(   hAboutDC, iStartX,              iStartY+iPhysSizeY+2 );
    LineTo(   hAboutDC, iStartX,                iStartY );
    BitBlt( hAboutDC, iStartX+1, iStartY+1, iPhysSizeX, iPhysSizeY,
            hMemoryDC, 0, 0, SRCCOPY );

    DeleteObject( hOldBitmap );
    DeleteDC( hMemoryDC );
    ReleaseDC( hWindow, hAboutDC );
    DeleteObject( hBMP );
}

