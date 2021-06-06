//****************************************************************************
//                             File REGINI.C
//
//              Registry and initialization file access
//
//      Copyright (c) Dmitry V. Stefankov, 1997. All rights reserved.
//
//****************************************************************************
//
//   $Source: F:/MSVC20/SOURCE/RASKEEPD/RCS/regini.c $
//  $RCSfile: regini.c $
//   $Author: dstef $
//     $Date: 1998/10/03 13:51:31 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: regini.c $
//      Revision 1.1  1998/10/03 13:51:31  dstef
//      Initial revision
//
//
//****************************************************************************



//---------------------------- Standard files --------------------------------

#include "compile.h"                        // Compilation switches

#include <windows.h>                        // Windows definitions
#include <stdio.h>                          // I/O library
#include <stdlib.h>                         // Default library
#include <tchar.h>                          // Unicode


//------------------------- Remote Access Service ----------------------------

#include <ras.h>                            // Remote Access Service
#include <raserror.h>                       // RAS error definitions


//------------------------ Project specific files ----------------------------

#include "rasdefs.h"                        // Project definitions
#include "rasproto.h"                       // Data declarations
#include "fproto.h"                         // Function prototypes
#include "debug.h"                          // Debugging definitions



//****************************************************************************
//                        --- GetLastErrorText ---
//
// Purpose: Return last error description text
//   Input: LPTSTR lpszBuf - buffer to store text
//          DWORD  dwSize  - size of buffer
//  Output: LPTSTR         - pointer to buffer with text
//                             NULL if no space or no text
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
LPTSTR GetLastErrorText( LPTSTR lpszBuf, DWORD dwSize )
{
    DWORD       dwRet;                      // Function result
    LPTSTR      lpszTemp = NULL;            // Temporary storage pointer

//------------------- Allocate space and format message ----------------------

    dwRet = FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER |
                           FORMAT_MESSAGE_FROM_SYSTEM |
                           FORMAT_MESSAGE_ARGUMENT_ARRAY,
                           NULL,
                           GetLastError(),
                           LANG_NEUTRAL,
                           (LPTSTR)&lpszTemp,
                           0,
                           NULL );

//--------------- Check is supplied buffer not long enough -------------------

    if ( !dwRet || ( (long)dwSize < (long)dwRet+14 ) )
        lpszBuf[0] = TEXT('\0');
    else
    {
        lpszTemp[lstrlen(lpszTemp)-2] = TEXT('\0');
                                            // Remove cr and lf character
        _stprintf( lpszBuf, TEXT("%s (0x%x)"), lpszTemp, GetLastError() );
    }

//-------------------- Return allocated space to system -----------------------

    if ( lpszTemp )
        LocalFree((HLOCAL) lpszTemp );

    return lpszBuf;
}



//****************************************************************************
//                           --- ReadRegKey ---
//
// Purpose: Read registry key value
//   Input: LPCTSTR szSectionName - subkey name
//          LPCTSTR szValueName   - value name
//          LPBYTE  lpbDataBuf    - buffer to return data
//          DWORD   dwDataBufSize - size of buffer
//  Output: DWORD                 -
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
DWORD  ReadRegKey( LPCTSTR szSectionName, LPCTSTR szValueName, LPBYTE lpbDataBuf,
                   DWORD dwDataBufSize)
{
   TCHAR  szValueKey[512] = TEXT("");       // Value key name
   DWORD  dwValueType;                      // Return value type
   DWORD  dwReadResult;                     // Function result
   HKEY   hkSubKey;                         // Subkey

//--------------------------- Make subkey name -------------------------------

   _tcscpy( szValueKey, g_szServicesKey );
   _tcscat( szValueKey, g_szServiceName );
   _tcscat( szValueKey, TEXT("\\") );
   _tcscat( szValueKey, g_szParametersKey );
   _tcscat( szValueKey, TEXT("\\") );
   _tcscat( szValueKey, szSectionName );

//------------------------------ Open subkey ---------------------------------

   dwReadResult = RegOpenKeyEx(
                        HKEY_LOCAL_MACHINE, // handle of open key
                        szValueKey,         // address of name of subkey to open
                        0,                  // reserved
                        KEY_READ,           // security access mask
                        &hkSubKey );        // address of handle of open key

//--------------------------- Get subkey value -------------------------------

   if ( dwReadResult == ERROR_SUCCESS )
   {

       dwReadResult = RegQueryValueEx(
                        hkSubKey,           // handle of key to query
                        szValueName,        // address of name of value to query
                        0,                  // reserved
                        &dwValueType,       // address of buffer for value type
                        lpbDataBuf,         // address of data buffer
                        &dwDataBufSize);    // address of data buffer size

        RegCloseKey( hkSubKey );

    }
    return( dwReadResult );
}



//****************************************************************************
//                           --- WriteRegKey ---
//
// Purpose: Read registry key value
//   Input: LPCTSTR szSectionName - subkey name
//          LPCTSTR szValueName   - value name
//          LPBYTE  lpbDataBuf    - buffer to return data
//          DWORD   dwDataBufSize - size of buffer
//          DWORD   dwValueType;  - value type
//  Output: DWORD                 -
// Written: by Dmitry V. Stefankov 1/17/97
//****************************************************************************
DWORD  WriteRegKey( LPCTSTR szSectionName, LPCTSTR szValueName, LPBYTE lpbDataBuf,
                    DWORD dwDataBufSize, DWORD dwValueType)
{
   TCHAR  szValueKey[512] = TEXT("");       // Value key name
   DWORD  dwWritResult;                     // Function result
   HKEY   hkSubKey;                         // Subkey

//--------------------------- Make subkey name -------------------------------

   _tcscpy( szValueKey, g_szServicesKey);
   _tcscat( szValueKey, g_szServiceName );
   _tcscat( szValueKey, TEXT("\\") );
   _tcscat( szValueKey, g_szParametersKey );
   _tcscat( szValueKey, TEXT("\\") );
   _tcscat( szValueKey, szSectionName );

//------------------------------ Open subkey ---------------------------------

   dwWritResult = RegOpenKeyEx(
                        HKEY_LOCAL_MACHINE, // handle of open key
                        szValueKey,         // address of name of subkey to open
                        0,                  // reserved
                        KEY_WRITE,          // security access mask
                        &hkSubKey );        // address of handle of open key

//--------------------------- Set subkey value -------------------------------

   if ( dwWritResult == ERROR_SUCCESS )
   {

       dwWritResult = RegSetValueEx(
                        hkSubKey,           // handle of key to query
                        szValueName,        // address of name of value to query
                        0,                  // reserved
                        dwValueType,        // address of buffer for value type
                        lpbDataBuf,         // address of data buffer
                        dwDataBufSize);     // address of data buffer size

        RegCloseKey( hkSubKey );

    }
    return( dwWritResult );
}



//****************************************************************************
//                           --- ReadIniFile ---
//
// Purpose: Read initialization file
//   Input: LPCTSTR szFilename - filename
//  Output: DWORD              - RETCODE_DONE if processing successful
//                                     any other value indicates error
// Written: by Dmitry V. Stefankov 09.01.97
//****************************************************************************
DWORD  ReadIniFile( LPCTSTR szFilename )
{
  TCHAR  szReturnKeyBuf[512];               // Temporary storage
  DWORD  dwFuncRetCode;                     // Function result code
  DWORD  dwResult = RETCODE_DONE;           // Function result code

#if defined(_DEBUG)
#if defined(WIN32_REGISTRY)
  OutputDebugString(TEXT("[REGINI] Read initialization parameters from registry.\n\r"));
#else
  OutputDebugString(TEXT("[REGINI] Read initialization file.\n\r"));
#endif                                      // #if defined(WIN32_REGISTRY)
#endif                                      // #if defined(_DEBUG)

//----------------------------- Section [RAS] --------------------------------

#if defined(WIN32_REGISTRY)
  szReturnKeyBuf[0] = TEXT('\0');
  dwFuncRetCode = ReadRegKey( g_szParamSection, g_szKeyUserEntry,
                              (PBYTE)szReturnKeyBuf, sizeof(szReturnKeyBuf) );
#else
  dwFuncRetCode = GetPrivateProfileString(
                        &g_szParamSection[0], // address of section name
                        &g_szKeyUserEntry[0], // address of key name
                        &g_szDefault[0],      // address of default string
                        &szReturnKeyBuf[0],   // address of destination buffer
                    sizeof(szReturnKeyBuf),   // size of destination buffer
                        szFilename            // address of initialization filename
                                         );
#endif                                      // #if defined(WIN32_REGISTRY)

  _tcscpy( g_szUserEntryName, szReturnKeyBuf );
#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] UserEntry: '%s'\n"), g_szUserEntryName );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

  if ( g_szUserEntryName[0] == TEXT('\0') )
  {
#if defined(_DEBUG)
    OutputDebugString( TEXT("ERROR: RAS connection entry not found.\n") );
#endif                                      // #if defined(_DEBUG)
    dwResult = RETCODE_NO_RAS_ENTRY;
    return( dwResult );
  }

#if defined(WIN32_REGISTRY)
  szReturnKeyBuf[0] = TEXT('\0');
  dwFuncRetCode = ReadRegKey( g_szParamSection, g_szKeyUserName,
                              (PBYTE)szReturnKeyBuf, sizeof(szReturnKeyBuf) );
#else
  dwFuncRetCode = GetPrivateProfileString(
                        &g_szParamSection[0],// address of section name
                        &g_szKeyUserName[0], // address of key name
                        &g_szDefault[0],     // address of default string
                        &szReturnKeyBuf[0],  // address of destination buffer
                    sizeof(szReturnKeyBuf),  // size of destination buffer
                        szFilename           // address of initialization filename
                                         );
#endif                                      // #if defined(WIN32_REGISTRY)

  _tcscpy( g_szUserName, szReturnKeyBuf );
#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] UserName: '%s'\n"), g_szUserName );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

#if defined(WIN32_REGISTRY)
  szReturnKeyBuf[0] = TEXT('\0');
  dwFuncRetCode = ReadRegKey( g_szParamSection, g_szKeyUserPass,
                              (PBYTE)szReturnKeyBuf, sizeof(szReturnKeyBuf) );
#else
  dwFuncRetCode = GetPrivateProfileString(
                        &g_szParamSection[0], // address of section name
                        &g_szKeyUserPass[0],  // address of key name
                        &g_szDefault[0],      // address of default string
                        &szReturnKeyBuf[0],   // address of destination buffer
                    sizeof(szReturnKeyBuf),   // size of destination buffer
                        szFilename            // address of initialization filename
                                         );
#endif                                      // #if defined(WIN32_REGISTRY)

  _tcscpy( g_szUserPass, szReturnKeyBuf );
#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] UserPass: '%s'\n"), g_szUserPass );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

#if defined(WIN32_REGISTRY)
  szReturnKeyBuf[0] = TEXT('\0');
  dwFuncRetCode = ReadRegKey( g_szParamSection, g_szKeyUserDomain,
                              (PBYTE)szReturnKeyBuf, sizeof(szReturnKeyBuf) );
#else
  dwFuncRetCode = GetPrivateProfileString(
                        &g_szParamSection[0], // address of section name
                        &g_szKeyUserDomain[0],// address of key name
                        &g_szDefault[0],      // address of default string
                        &szReturnKeyBuf[0],   // address of destination buffer
                    sizeof(szReturnKeyBuf),   // size of destination buffer
                        szFilename            // address of initialization filename
                                         );
#endif                                      // #if defined(WIN32_REGISTRY)

  _tcscpy( g_szUserDomain, szReturnKeyBuf );
#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] UserDomain: '%s'\n"), g_szUserDomain );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

//---------------------------- Section [ICMP] --------------------------------

#if defined(WIN32_REGISTRY)
  szReturnKeyBuf[0] = TEXT('\0');
  dwFuncRetCode = ReadRegKey( g_szOptionSection, g_szKeyTestIcmp,
                              (PBYTE)szReturnKeyBuf, sizeof(szReturnKeyBuf) );
#else
  dwFuncRetCode = GetPrivateProfileString(
                        &g_szOptionSection[0],// address of section name
                        &g_szKeyTestIcmp[0],  // address of key name
                        &g_szDefault[0],      // address of default string
                        &szReturnKeyBuf[0],   // address of destination buffer
                    sizeof(szReturnKeyBuf),   // size of destination buffer
                        szFilename            // address of initialization filename
                                         );
#endif                                      // #if defined(WIN32_REGISTRY)

  _tcscpy( g_szRemoteIpNode, szReturnKeyBuf );
#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] Remote IP node: '%s'\n"), g_szRemoteIpNode );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

  if ( ( g_szRemoteIpNode[0] == TEXT('\0') ) || 
       (_tcscmp(g_szRemoteIpNode,TEXT("0.0.0.0")) == 0)  )
  {
#if defined(_DEBUG)
    OutputDebugString( 
   TEXT("[REGINI]: Remote site IP address not found. Treat as special case!\n\r") );
#endif                                      // #if defined(_DEBUG)
    g_dwDialUpLine = 1;                     // We like telephones
  }
#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] DialUp Line: %lu\n"), g_dwDialUpLine );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

#if defined(WIN32_REGISTRY)
  dwFuncRetCode = ReadRegKey( g_szOptionSection, g_szKeyPingTimeout,
                              (PBYTE)&g_dwPingTimeout, sizeof(szReturnKeyBuf) );
#else
  dwFuncRetCode = GetPrivateProfileInt(
                    &g_szOptionSection[0],  // address of section name
                    &g_szKeyPingTimeout[0], // address of key name
                    PING_DEF_TIMEOUT,       // return value if key name is not found
                    szFilename              // address of initialization filename
                                      );
  g_dwPingTimeout = dwFuncRetCode;
#endif                                      // #if defined(WIN32_REGISTRY)

  if ( g_dwPingTimeout == 0 )
    g_dwPingTimeout = PING_DEF_TIMEOUT;       // Set to default
#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] Ping timeout (ms): %lu\n"), g_dwPingTimeout );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

#if defined(WIN32_REGISTRY)
  dwFuncRetCode = ReadRegKey( g_szOptionSection, g_szKeyDataSize,
                              (PBYTE)&g_wDataSize, sizeof(g_wDataSize) );
#else
  dwFuncRetCode = GetPrivateProfileInt(
                    &g_szOptionSection[0],  // address of section name
                    &g_szKeyDataSize[0],    // address of key name
                    PING_DEF_DATASIZE,      // return value if key name is not found
                    szFilename              // address of initialization filename
                                      );
  g_wDataSize = (WORD)dwFuncRetCode;
#endif                                      // #if defined(WIN32_REGISTRY)

  if  ( g_wDataSize> ICMP_SENT_BUF_SIZE )
     g_wDataSize = ICMP_SENT_BUF_SIZE;
#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] Data size (bytes): %lu\n"), g_wDataSize );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

//--------------------------- Section [GENERAL] ------------------------------

#if defined(WIN32_REGISTRY)
  dwFuncRetCode = ReadRegKey( g_szGeneralSection, g_szKeyRetry,
                              (PBYTE)&g_dwRetry, sizeof(g_dwRetry) );
#else
  dwFuncRetCode = GetPrivateProfileInt(
                    &g_szGeneralSection[0], // address of section name
                    &g_szKeyRetry[0],       // address of key name
                    RAS_RETRY_COUNT_DF,     // return value if key name is not found
                    szFilename              // address of initialization filename
                                      );
  g_dwRetry = dwFuncRetCode;
#endif                                      // #if defined(WIN32_REGISTRY)

#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] Retry number: %lu\n"), g_dwRetry );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

#if defined(WIN32_REGISTRY)
  dwFuncRetCode = ReadRegKey( g_szGeneralSection, g_szKeyRetryTime,
                              (PBYTE)&g_dwRetryTime, sizeof(g_dwRetryTime) );
#else
  dwFuncRetCode = GetPrivateProfileInt(
                    &g_szGeneralSection[0], // address of section name
                    &g_szKeyRetryTime[0],   // address of key name
                    RAS_TEST_TIME_DF,       // return value if key name is not found
                    szFilename              // address of initialization filename
                                      );
  g_dwRetryTime = dwFuncRetCode;
#endif                                      // #if defined(WIN32_REGISTRY)

#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] Retry time interval (sec): %lu\n"), g_dwRetryTime );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

#if defined(WIN32_REGISTRY)
  dwFuncRetCode = ReadRegKey( g_szGeneralSection, g_szKeyTestTime,
                              (PBYTE)&g_dwTestTime, sizeof(g_dwTestTime) );
#else
  dwFuncRetCode = GetPrivateProfileInt(
                    &g_szGeneralSection[0], // address of section name
                    &g_szKeyTestTime[0],    // address of key name
                    RAS_TEST_TIME_DF,       // return value if key name is not found
                    szFilename              // address of initialization filename
                                      );
  g_dwTestTime = dwFuncRetCode;
#endif                                      // #if defined(WIN32_REGISTRY)

#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] Test time interval (sec): %lu\n"), g_dwTestTime );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

#if defined(WIN32_REGISTRY)
  dwFuncRetCode = ReadRegKey( g_szGeneralSection, g_szKeyErrorLogging,
                              (PBYTE)&g_dwErrorLogging, sizeof(g_dwErrorLogging) );
#else
  dwFuncRetCode = GetPrivateProfileInt(
                    &g_szGeneralSection[0], // address of section name
                    &g_szKeyErrorLogging[0],// address of key name
                    0,                      // return value if key name is not found
                    szFilename              // address of initialization filename
                                      );
  g_dwErrorLogging = dwFuncRetCode;
#endif                                      // #if defined(WIN32_REGISTRY)

#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] Error logging: %u\n"), g_dwErrorLogging );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

#if defined(WIN32_REGISTRY)
  dwFuncRetCode = ReadRegKey( g_szGeneralSection, g_szKeyCloseRas,
                              (PBYTE)&g_dwCloseRas, sizeof(g_dwCloseRas) );
#else
  dwFuncRetCode = GetPrivateProfileInt(
                    &g_szGeneralSection[0], // address of section name
                    &g_szKeyCloseRas[0],    // address of key name
                    0,                      // return value if key name is not found
                    szFilename              // address of initialization filename
                                      );
  g_dwCloseRas = dwFuncRetCode;
#endif                                      // #if defined(WIN32_REGISTRY)

#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] Close failed connection: %u\n"), 
             g_dwCloseRas );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

#if defined(WIN32_REGISTRY)
  dwFuncRetCode = ReadRegKey( g_szGeneralSection, g_szKeyAliveTime,
                              (PBYTE)&g_dwAliveTime, sizeof(g_dwAliveTime) );
#else
  dwFuncRetCode = GetPrivateProfileInt(
                    &g_szGeneralSection[0], // address of section name
                    &g_szKeyAliveTime[0],   // address of key name
                    0,                      // return value if key name is not found
                    szFilename              // address of initialization filename
                                      );
  g_dwAliveTime = dwFuncRetCode;
#endif                                      // #if defined(WIN32_REGISTRY)

#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] Alive message time (mins): %u\n"), 
             g_dwAliveTime );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

#if defined(WIN32_REGISTRY)
  dwFuncRetCode = ReadRegKey( g_szGeneralSection, g_szKeyHardRetry,
                              (PBYTE)&g_dwHardRetry, sizeof(g_dwHardRetry) );
#else
  dwFuncRetCode = GetPrivateProfileInt(
                    &g_szGeneralSection[0], // address of section name
                    &g_szKeyHardRetry[0],   // address of key name
                    0,                      // return value if key name is not found
                    szFilename              // address of initialization filename
                                      );
  g_dwHardRetry = dwFuncRetCode;
#endif                                      // #if defined(WIN32_REGISTRY)

#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] Hard retry algorithm: %u\n"), 
             g_dwHardRetry );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

#if defined(WIN32_REGISTRY)
  dwFuncRetCode = ReadRegKey( g_szGeneralSection, g_szKeyShutDown,
                              (PBYTE)&g_dwShutDown, sizeof(g_dwShutDown) );
#else
  dwFuncRetCode = GetPrivateProfileInt(
                    &g_szGeneralSection[0], // address of section name
                    &g_szKeyShutDown[0],    // address of key name
                    0,                      // return value if key name is not found
                    szFilename              // address of initialization filename
                                      );
  g_dwShutDown = dwFuncRetCode;
#endif                                      // #if defined(WIN32_REGISTRY)

#if defined(_DEBUG)
  _stprintf( szReturnKeyBuf, TEXT("[REGINI] Shutdown system: %u\n"), g_dwShutDown );
  OutputDebugString( szReturnKeyBuf );
#endif                                      // #if defined(_DEBUG)

   return( dwResult );
}



//****************************************************************************
//                      --- CreateDefaultRegKeys ---
//
// Purpose: Create registry keys for WIN32 service
//   Input: none
//  Output: DWORD  -  RETCODE_DONE  if successful
//                    any other valus indicates error
// Written: by Dmitry V. Stefankov 21.01.97
//****************************************************************************
DWORD  CreateDefaultRegKeys()
{
    DWORD       dwRegResult;                // Function result
    DWORD       dwDisposition;              // Nonvolatile type
    HKEY        hRegKey;                    // Registry key
    HKEY        hSubRegKeyParm;             // Registry subkey (PARAMETERS)
    HKEY        hSubRegKeySect;             // Registry subkey (SECTION 1..N)
    TCHAR       szSubKey[512];              // Registry subkey name
    TCHAR       szErr[256];                 // Error text buffer

//--------------------- Open registry key for service ------------------------

    _tcscpy( szSubKey, g_szServicesKey );
    _tcscat( szSubKey, g_szServiceName );

    dwRegResult = RegOpenKeyEx(
                       HKEY_LOCAL_MACHINE,  // handle of open key
                       szSubKey,            // address of name of subkey to open
                       0,                   // reserved
                       KEY_ALL_ACCESS,      // security access mask
                       &hRegKey);           // address of handle of open key

            if ( dwRegResult == ERROR_SUCCESS )
            {

//------------------ Create registry key for PARAMETERS ----------------------

               dwRegResult = RegCreateKeyEx(
                            hRegKey,        // handle of an open key
                         g_szParametersKey,	// address of subkey name
                            0,              // reserved
                            NULL,           // address of class string
                   REG_OPTION_NON_VOLATILE,	// special options flag
                            KEY_ALL_ACCESS, // desired security access
                            NULL,           // address of key security structure
                           &hSubRegKeyParm, // address of buffer for opened handle
                           &dwDisposition); // address of disposition value buffer

               if ( dwRegResult == ERROR_SUCCESS )
               {

//------------- Create registry key values for [GENERAL] section --------------

                  dwRegResult = RegCreateKeyEx(
                            hSubRegKeyParm, // handle of an open key
                        g_szGeneralSection,	// address of subkey name
                            0,              // reserved
                            NULL,           // address of class string
                   REG_OPTION_NON_VOLATILE,	// special options flag
                            KEY_ALL_ACCESS, // desired security access
                            NULL,           // address of key security structure
                            &hSubRegKeySect,// address of buffer for opened handle
                            &dwDisposition);// address of disposition value buffer

                  RegCloseKey(hSubRegKeySect);

//------------- Create registry key values for [RAS] section ------------------

                  dwRegResult = RegCreateKeyEx(
                            hSubRegKeyParm, // handle of an open key
                           g_szParamSection,// address of subkey name
                            0,              // reserved
                            NULL,           // address of class string
                    REG_OPTION_NON_VOLATILE,// special options flag
                            KEY_ALL_ACCESS, // desired security access
                            NULL,           // address of key security structure
                            &hSubRegKeySect,// address of buffer for opened handle
                            &dwDisposition);// address of disposition value buffer

                  RegCloseKey(hSubRegKeySect);

//------------- Create registry key values for [ICMP] section -----------------

                  dwRegResult = RegCreateKeyEx(
                            hSubRegKeyParm, // handle of an open key
                          g_szOptionSection,// address of subkey name
                            0,              // reserved
                            NULL,           // address of class string
                    REG_OPTION_NON_VOLATILE,// special options flag
                            KEY_ALL_ACCESS, // desired security access
                            NULL,           // address of key security structure
                            &hSubRegKeySect,// address of buffer for opened handle
                            &dwDisposition);// address of disposition value buffer

                  RegCloseKey(hSubRegKeySect);

                  RegCloseKey(hSubRegKeyParm);
               }

               RegCloseKey(hRegKey);

                WriteSectionGeneral();
                WriteSectionRas();
                WriteSectionIcmp();

               _tprintf( TEXT("Registry keys added for %s.\n"),
                         g_szServiceDisplayName );
            }
            else
            {
               _tprintf( TEXT("AddRegistryKey failed - %s\n"),
                              GetLastErrorText(szErr, 256));
            }

  return( RETCODE_DONE );
}



//****************************************************************************
//                       --- WriteSectionGeneral ---
//
// Purpose: Write [GENERAL] subkey values
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/21/97
//****************************************************************************
VOID  WriteSectionGeneral( )
{
    DWORD       dwRegResult;                // Function result

    dwRegResult = WriteRegKey( g_szGeneralSection,
                               g_szKeyTestTime,
                               (PBYTE)&g_dwTestTime,
                               sizeof(g_dwTestTime),
                               REG_DWORD);

    dwRegResult = WriteRegKey( g_szGeneralSection,
                               g_szKeyRetryTime,
                               (PBYTE)&g_dwRetryTime,
                               sizeof(g_dwRetryTime),
                               REG_DWORD);

    dwRegResult = WriteRegKey( g_szGeneralSection,
                               g_szKeyRetry,
                               (PBYTE)&g_dwRetry,
                               sizeof(g_dwRetry),
                               REG_DWORD);

    dwRegResult = WriteRegKey( g_szGeneralSection,
                               g_szKeyErrorLogging,
                               (PBYTE)&g_dwErrorLogging,
                               sizeof(g_dwErrorLogging),
                               REG_DWORD);

    dwRegResult = WriteRegKey( g_szGeneralSection,
                               g_szKeyCloseRas,
                               (PBYTE)&g_dwCloseRas,
                               sizeof(g_dwCloseRas),
                               REG_DWORD);

    dwRegResult = WriteRegKey( g_szGeneralSection,
                               g_szKeyHardRetry,
                               (PBYTE)&g_dwHardRetry,
                               sizeof(g_dwHardRetry),
                               REG_DWORD);
             
    dwRegResult = WriteRegKey( g_szGeneralSection,
                               g_szKeyAliveTime,
                               (PBYTE)&g_dwAliveTime,
                               sizeof(g_dwAliveTime),
                               REG_DWORD);

    dwRegResult = WriteRegKey( g_szGeneralSection,
                               g_szKeyShutDown,
                               (PBYTE)&g_dwShutDown,
                               sizeof(g_dwShutDown),
                               REG_DWORD);
}



//****************************************************************************
//                         --- WriteSectionRas ---
//
// Purpose: Write [RAS] subkey values
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/21/97
//****************************************************************************
VOID  WriteSectionRas( )
{
    DWORD       dwRegResult;                // Function result

    dwRegResult = WriteRegKey( g_szParamSection,
                               g_szKeyUserEntry,
                              (PBYTE)g_szUserEntryName,
                               (_tcslen(g_szUserEntryName)+1)*sizeof(TCHAR),
                               REG_SZ);

    dwRegResult = WriteRegKey( g_szParamSection,
                               g_szKeyUserName,
                              (PBYTE)g_szUserName,
                               (_tcslen(g_szUserName)+1)*sizeof(TCHAR),
                               REG_SZ);

    dwRegResult = WriteRegKey( g_szParamSection,
                               g_szKeyUserPass,
                              (PBYTE)g_szUserPass,
                               (_tcslen(g_szUserPass)+1)*sizeof(TCHAR),
                               REG_SZ);

    dwRegResult = WriteRegKey( g_szParamSection,
                               g_szKeyUserDomain,
                              (PBYTE)g_szUserDomain,
                               (_tcslen(g_szUserDomain)+1)*sizeof(TCHAR),
                               REG_SZ);
}



//****************************************************************************
//                        --- WriteSectionIcmp ---
//
// Purpose: Write [ICMP] subkey values
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 1/21/97
//****************************************************************************
VOID  WriteSectionIcmp( )
{
    DWORD       dwRegResult;                // Function result

    dwRegResult = WriteRegKey( g_szOptionSection,
                               g_szKeyTestIcmp,
                               (PBYTE)g_szRemoteIpNode,
                               (_tcslen(g_szRemoteIpNode)+1)*sizeof(TCHAR),
                               REG_SZ);

    dwRegResult = WriteRegKey( g_szOptionSection,
                               g_szKeyPingTimeout,
                               (PBYTE)&g_dwPingTimeout,
                               sizeof(g_dwPingTimeout),
                               REG_DWORD);

    dwRegResult = WriteRegKey( g_szOptionSection,
                               g_szKeyDataSize,
                               (PBYTE)&g_wDataSize,
                               sizeof(WORD),
                               REG_BINARY);

}
