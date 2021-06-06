//****************************************************************************
//                            File WSPING32.C
//
//                 Windows Sockets PING 32-bit implementation
//
//      Copyright (c) Dmitry V. Stefankov, 1997-1999. All rights reserved.
//       This software is distributed under GPL agreement
//       (See copying file for details).
//
//****************************************************************************
//
//   $Source: G:/msvc4/source/wsping32/RCS/wsping32.c $
//  $RCSfile: wsping32.c $
//   $Author: dstef $
//     $Date: 1999/12/06 05:32:52 $
// $Revision: 1.9 $
//   $Locker: dstef $
//
//      $Log: wsping32.c $
//      Revision 1.9  1999/12/06 05:32:52  dstef
//      Added more if-endif compilation conditions
//      Minor changes
//
//      Revision 1.8  1998/12/02 14:18:41  dstef
//      Added IP raw sockets support, but because
//      Win32 implementation not have its support
//      now this code not works.
//
//      Revision 1.7  1998/11/29 22:37:26  dstef
//      Removed waiting thread
//      Added semaphores for wait and sleep states
//      Time counting now done using GetSystemTime()
//      Fixed bug with undetected bad results for Winsock 2
//
//      Revision 1.6  1998/11/27 05:00:46  dstef
//      Added Winsock 2 files searching
//      Fixed a bug with loopback address for WS2
//
//      Revision 1.5  1998/11/27 02:24:27  dstef
//      Fixed minor bugs
//
//      Revision 1.4  1998/11/27 02:17:05  dstef
//      Added raw sockets support for Winsock v2+
//      Moved ping code to thread
//      Changed algorithm to avoid complex test conditions
//      Print information about detected Winsock version
//      Added more debugging code
//
//      Revision 1.3  1998/11/17 13:18:49  dstef
//      Replaced tabs to spaces
//
//      Revision 1.2  1998/11/17 13:17:09  dstef
//      Add compile instructions
//      Put under GPL agreement
//      Updated program help
//
//      Revision 1.1  1998/10/03 13:28:38  dstef
//      Initial revision
//
//
//****************************************************************************



/*-------------------------- Compile instructions --------------------------*/
/*
  The following platforms were used and tested:
  1.  Win32 environment, Microsoft Visual C++ v2.2, v4.2
       Use supplied project or follow these directions:
       1. Create new project wsping32.mak or wsping32.mdp;
       2. Add wsping32.c as source file
       3. Add ipexport.h as source file
       3. Add icmpapi.h  as source file 
       4. Add icmp.lib as library file
       5. Compile as release version

  NOTES:
    1. If you need UNICODE version then enable switches UNICODE 
       and _UNICODE.
    2. If you want raw sockets support then enable switch _WINSOCK2,
       but you got the corresponding problems with Winsock v2
       implementations on Microsoft Windows platforms.
 */



//---------------------------- Compilation conditionals ----------------------
#if 0
#define  _WINSOCK2                          // WinSock v2 support
#endif
#if 0
#define  _IPRAW                             // Use IP raw socket instead ICMP socket 
#endif
#if 0
#define  _IPRAW_TEST                        // Additionally: use IP raw socket testing data
#endif
#if 0
#define  _UNICODE                           // UniCode for C runtime library
#endif
#if 0
#define   UNICODE                           // UniCode for WIN32 API
#endif
#if 0
#define  _DEBUGOUT                          // Print debug dump of packets
#endif


//---------------------------- Standard files --------------------------------
#if defined(_WINSOCK2)
#include <winsock2.h>                       // Windows Sockets v2
#endif                                      // #if defined(_WINSOCK2)
#include <windows.h>                        // Windows definitions
#include <stdio.h>                          // I/O library
#include <stdlib.h>                         // Default library
#include <process.h>                        // Processes and threads
#include <tchar.h>                          // Unicode
#include <shellapi.h>                       // SHELL.DLL defintions



//---------------------- Microsoft proprietary files -------------------------
#include "ipexport.h"                       // IP network layer
#include "icmpapi.h"                        // Internet Control Message Protocol



//------------------------------- Return Codes --------------------------------
#define   RETCODE_DONE                  0   // Ping is successful
#define   RETCODE_BAD_IP_ADDR           1   // Bad IP (symbolic) address
#define   RETCODE_NO_WINSOCK            2   // No WinSock
#define   RETCODE_NO_WINSOCK_V11        3   // Wrong WinSock version
#define   RETCODE_NO_CREATE_ICMP        4   // Fail to create ICMP packet
#define   RETURN_BAD_PARAMETER          5   // Bad user supplied parameter
#define   RETURN_BAD_HOSTNAME           6   // Bad user specified hostname
#define   RETURN_NO_ECHO_REPLY          7   // No reply received
#define   RETCODE_WRONG_IP_ADDR         8   // Wrong IP reply address
#define   RETCODE_FAIL_CREAT_OBJECT     9   // Cannot create waiting object
#define   RETCODE_FAIL_CREAT_THREAD     10  // Cannot create waiting thread
#define   RETCODE_NO_CREATE_RAW_SOCKET  11  // Fail to create raw socket
#define   RETCODE_FAIL_TO_SET_TIMEOUT   12  // Fail to set timeout on send or receive
#define   RETCODE_FAIL_TO_SET_NON_BLOCK 13  // Fail to set non-blocking mode
#define   RETCODE_ABORT_BY_USER         254 // Terminate process by Control-C
#define   RETCODE_USER_HELP_OUTPUT      255 // Output user help message



//------------------------------ Definitions --------------------------------
#define   ICMP_SENT_BUF_SIZE        16384    // ICMP echo packet (OUT)
#define   ICMP_RECV_BUF_SIZE        16384+512// ICMP echo packet (IN)

#define   DECIMAL_BASE              10
#define   HEXADECIMAL_BASE          16
#define   MS_PER_SEC                1000

#define   PING_DEF_TIMEOUT          1*MS_PER_SEC
#define   PING_DEF_DATASIZE         56
#define   PING_DEF_TTL              64
#define   ICMP_DATA_FILL_CHAR       0x55
#define   NROUTES                   9
#define   LOOPBACK_ADDR             127     // Internal loopback 

#ifdef _UNICODE
#define   IP_ADDRESS_SIZE           24
#endif                                      // #ifdef _UNICODE

#if defined(_WINSOCK2)
#define   IP_HDR_UNIT               4       // Each octet is 4 bytes
#define   ICMP_ECHO                 8       // Echo Request
#define   ICMP_ECHOREPLY            0       // Echo Reply
#define   ICMP_MIN                  8       // Minimum icmp packet (only header)
#endif                                      // #if defined(_WINSOCK2)



//----------------------------- Structures -----------------------------------
#if defined(_WINSOCK2)
#pragma pack(push)
#pragma pack(1)

typedef struct  ip                  // The IP header
{
    BYTE        ip_hlen:4;          // Length of the header
    BYTE        ip_version:4;       // Version of IP
    BYTE        ip_tos;             // Type of service
    USHORT      ip_tlen;            // Total length of the packet
    USHORT      ip_ident;           // Unique identifier
    USHORT      ip_fragoff;         // Fragmentation offset and flags
    BYTE        ip_ttl;             // Time-to-live
    BYTE        ip_proto;           // Protocol (TCP, UDP etc)
    USHORT      ip_checksum;        // IP checksum
    ULONG       ip_source;          // IP source address
    ULONG       ip_dest;            // IP destination address
} IpHeader;
typedef  struct ip *  pip;

typedef struct  icmp                        // ICMP header
{
    BYTE                icmp_type;          // Type of message
    BYTE                icmp_code;          // Type subcode
    USHORT              icmp_chksum;        // Checksum of hdr+date
    USHORT              icmp_id;            // Message identifier
    USHORT              icmp_seq;           // Sequence number
    ULONG               icmp_timestamp_ext; // Non-standard extension (really data space)
} IcmpHeader;
typedef  struct icmp *  picmp;

#pragma pack(pop)
#endif                                      // #if defined(_WINSOCK2)



//---------------------- Function Prototypes --------------------------------
DWORD      TestRemoteSite( LPCTSTR szRemoteSite, LPCTSTR szHostName );
BOOL       ControlHandler( DWORD dwCtrlType );
VOID       AppCleanUp( VOID );
VOID       PrintTotalResults( VOID );
#if defined(_WINSOCK2)
int     iDetectWS2Files( VOID );
USHORT  CheckSum( USHORT *buffer, int size );
#endif                                      // #if defined(_WINSOCK2)



//---------------------- Global static variables ----------------------------
TCHAR      g_szTestIpAddr[MAX_PATH] = TEXT("\0"); // IP address
TCHAR      g_szHostName[MAX_PATH]   = TEXT("\0"); // Host name
DWORD      g_dwPingRetryCount   =   1;      // Default based on non-stop value
DWORD      g_dwPingTimeout      =   PING_DEF_TIMEOUT;    // Waiting time
WORD       g_wPingDataSize      =   PING_DEF_DATASIZE;   // Data portion size
int        g_iPingFillChar      =   ICMP_DATA_FILL_CHAR; // Fill byte
BYTE       g_bPingTTL           =   PING_DEF_TTL;        // Time-To-Live
BOOLEAN    g_fPingAudible       =   FALSE;  // Beeps when packet received
BOOLEAN    g_fPingRecordRoute   =   FALSE;  // Record routes
BOOLEAN    g_fPingVerboseOut    =   FALSE;  // Verbose
BOOLEAN    g_fPingDontFragment  =   FALSE;  // Don' fragment IP packet
BOOLEAN    g_fPingDontResolve   =   FALSE;  // Don't resolve DNS hostname
BOOLEAN    g_fPingNonStop       =   TRUE;   // Send no stoppa
BOOLEAN    g_fStopOnSuccess     =   FALSE;  // Stop on first success rcv pkt
DWORD      g_dwTransmittedPkts  =   0;      // Total transmitted
DWORD      g_dwReceivedPkts     =   0;      // Total received
DWORD      g_dwIcmpSeq          =   0;      // ICMP sequence number
double     g_dblTMin = 999999999.0;         // minimum round trip time
double     g_dblTMax = 0.0;                 // maximum round trip time */
double     g_dblTSum = 0.0;                 // sum of all times, for doing average
BYTE       g_bOptionSpace[3+4*NROUTES+1];   // Record route space
BOOLEAN    g_fUseWinsock2       =   FALSE;  // Use Winsock v2 
BOOLEAN    g_fWaitPacket        =   FALSE;  // Semaphore to wait
BOOLEAN    g_fSleepTime         =   FALSE;  // Semaphore to sleep
#if defined(_WINSOCK2)
BOOLEAN    g_fAutoDetWinsock2   =   TRUE;   // Enable Winsock2 auto detection
SOCKET     g_sockRaw;                       // Winsock v2 raw socket
#endif                                      // #if defined(_WINSOCK2)



//****************************************************************************
//                         --- main ---
//
// Purpose: Send ICMP ECHO REQUESTS packets to network hosts
//   Input: int      argc   -  number of arguments in command (shell) line
//          char   **argv   -  array of pointers to argument-strings
//          char   * envp   -  pointer to environment block
//  Output: int             -  return codes (see above)
// Written: by Dmitry V. Stefankov 12.11.97
//****************************************************************************
int main(int argc, char **argv, char *envp )
{
    DWORD       dwArgc;                     // Arguments number
    LPTSTR      *lpszArgv;                  // Arguments array
    DWORD       wRetCode = 0;               // Return code
    WORD        wVersionRequested;          // Winsock version
    WSADATA     wsaData;                    // Winsock private data
    int         iErr;                       // Return error code
#ifdef _UNICODE
    CHAR        szTempBuf[512];             // ANSI verison of string buffer
    TCHAR       szTempBufWide[256];         // Unicode version of string buffer
    int         iFuncSRes;                  // Function test result
#endif                                      // #ifdef _UNICODE
    DWORD       dwTestSiteRes;              // Function result
    DWORD       dwIndex;                    // Temporary index
    BOOLEAN     fIpSymAddrFound = FALSE;    // IP address in symbolic form

//--------------------------- Banner message ---------------------------------
  _tprintf( TEXT("Windows Sockets PING (32-bit) v1.12,  Copyright (c) 1997,1999 Dmitry Stefankov\n") );


//--------------------------- Process comand parameters ----------------------

#ifdef UNICODE
    lpszArgv = (LPTSTR *)CommandLineToArgvW( GetCommandLineW(), &dwArgc );
#else
    dwArgc   = (DWORD) argc;
    lpszArgv = argv;
#endif

  if ( dwArgc == 1)
  {
     _tprintf( TEXT("NAME\n") );
     _tprintf( TEXT("  wsping32 - send ICMP ECHO REQUESTS packets to network hosts\n") );
     _tprintf( TEXT("\n") );
     _tprintf( TEXT("SYNOPSIS\n") );
     _tprintf( TEXT("  wsping32 [-afnrvw] [-c count] [-i wait] [-p pattern] [-s packetsize]\n") );
     _tprintf( TEXT("           [-t ttl] host\n") );
     _tprintf( TEXT("\n") );
     _tprintf( TEXT("DESCRIPTION\n") );
     _tprintf( TEXT("  Ping uses the ICMP protocol's mandatory ECHO REQUEST datagram to elicit\n") );
     _tprintf( TEXT("  an ICMP ECHO_RESPONSE from a host or gateway. ECHO_REQUEST datagrams\n") );
     _tprintf( TEXT("  (\"pings\") have an IP and ICMP header, followed by a \"strict timeval\"\n") );
     _tprintf( TEXT("  and then an arbitrary number of \"pad\" bytes to used to fill out the\n") );
     _tprintf( TEXT("  packet. The options are as follows:\n") );
     _tprintf( TEXT("  -a   Audible. Include a bell (ASCII 0x07) character in the output when\n") );
     _tprintf( TEXT("       any packet is received. This option is ignored if other format\n") );
     _tprintf( TEXT("       options are present.\n") );
     _tprintf( TEXT("  -c count\n") );
     _tprintf( TEXT("       Stop after sending (and receiving) count ECHO_RESPONSE packets.\n") );
     _tprintf( TEXT("  -f   Sends a \"Do not Fragment\" flag in the packet. The packet will\n") );
     _tprintf( TEXT("       not be fragmented by gateways on the route.\n") );
     _tprintf( TEXT("  -g   Stops a work after the first good received the echo reply packet.\n") );
     _tprintf( TEXT("       Useful for diagnostic purposes.\n") );
     _tprintf( TEXT("  -i wait\n") );
     _tprintf( TEXT("       Wait \"wait\" seconds between sending each packet. The default is\n") );
     _tprintf( TEXT("       to wait for one second between each packet.\n") );
     _tprintf( TEXT("  -n   Numeric output only.  No attempt will be made to lookup symbolic\n") );
     _tprintf( TEXT("       names for host addresses.\n") );
     _tprintf( TEXT("  -p pattern\n") );
     _tprintf( TEXT("       You may specify only one ``pad'' bytes to fill out the packet you\n") );
     _tprintf( TEXT("       send. This is useful for diagnosing data-dependent problems in a\n") );
     _tprintf( TEXT("       network. For example, ``-p ff'' will cause the sent packet to be\n") );
     _tprintf( TEXT("       filled with all ones.\n") );
     _tprintf( TEXT("  -r   Record route.  Includes the RECORD_ROUTE option in the\n") );
     _tprintf( TEXT("       ECHO_REQUEST packet and displays the route buffer on returned\n") );
     _tprintf( TEXT("       packets.  Note that the IP header is only large enough for nine\n") );
     _tprintf( TEXT("       such routes.  Many hosts ignore or discard this option.\n") );
	 _tprintf( TEXT("       (*** Not implemented. ***)\n") );
     _tprintf( TEXT("  -s packetsize\n") );
     _tprintf( TEXT("       Specifies the number of data bytes to be sent.  The default is\n") );
     _tprintf( TEXT("       56, which translates into 64 ICMP data bytes when combined with\n") );
     _tprintf( TEXT("       the 8 bytes of ICMP header data.\n") );
     _tprintf( TEXT("  -t ttl\n") );
     _tprintf( TEXT("       Set the IP Time To Live for multicasted packets.  This flag only\n") );
     _tprintf( TEXT("       applies if the ping destination is a multicast address.\n") );
     _tprintf( TEXT("  -v   Verbose output.  ICMP packets other than ECHO_RESPONSE that are\n") );
     _tprintf( TEXT("       received are listed.\n") );
#if defined(_WINSOCK2)
     _tprintf( TEXT("  -w   Disable Winsock version 2 detection. Otherwise WSPING32 autodetects\n") );
     _tprintf( TEXT("       the Winsock version trying to use raw socket technique for version 2,\n") );
     _tprintf( TEXT("       or to use ICMP.DLL undocumented calls for version 1.\n") );
#endif                                      // #if defined(_WINSOCK2)
     _tprintf( TEXT("\n") );
     _tprintf( TEXT("HISTORY\n") );
     _tprintf( TEXT("  WSPING32 command appeared in December 1997\n") );
     _tprintf( TEXT("\n") );
     _tprintf( TEXT("AUTHOR\n") );
     _tprintf( TEXT("  Dmitry V. Stefankov (dstef@nsl.ru, dima@mccbn.ru)\n") );

     return( RETCODE_USER_HELP_OUTPUT );
  }
  else
  {
     dwArgc--;                              // Remove program name
     while ( dwArgc )
     {
       TCHAR   chTemp;                      // Temporary

       chTemp = **(++lpszArgv);
       dwArgc--;                            // Skip program name
       if ( (chTemp == '-') || (chTemp == '/') )
       {
          chTemp = *(++*lpszArgv);          // Look options
          switch( chTemp )
          {
                case 'a':                   // Nice bell
                    g_fPingAudible = TRUE;
                    break;
                case 'c':                   // Count
                    if ( dwArgc )
                    {
                        dwArgc--;
#ifdef _UNICODE
                        lpszArgv++;
  iFuncSRes = WideCharToMultiByte( CP_ACP,  // code page 
                                       0,   // performance and mapping flags 
                                 *lpszArgv, // address of wide-character string 
                                      -1,   // number of characters in string 
                          &szTempBuf[0],    // address of buffer for new string 
                      sizeof(szTempBuf),    // size of buffer 
                                    NULL,   // address of default for unmappable characters  
                                    NULL);  // address of flag set when default char. used 
                        g_dwPingRetryCount = atol( szTempBuf );
#else
                        g_dwPingRetryCount = atol( *(++lpszArgv) );
#endif                                      // #ifdef _UNICODE
                        g_fPingNonStop = FALSE;
                    }
                    break;
                case 'f':                   // Prevent fragmentation
                    g_fPingDontFragment = TRUE;
                    break;
                case 'g':                   // Good news
                    g_fStopOnSuccess = TRUE;
                    break;
                case 'i':                   // Timeout
                    if ( dwArgc )
                    {
                        dwArgc--;
#ifdef _UNICODE
                        lpszArgv++;
  iFuncSRes = WideCharToMultiByte( CP_ACP,  // code page 
                                       0,   // performance and mapping flags 
                                 *lpszArgv, // address of wide-character string 
                                      -1,   // number of characters in string 
                          &szTempBuf[0],    // address of buffer for new string 
                      sizeof(szTempBuf),    // size of buffer 
                                    NULL,   // address of default for unmappable characters  
                                    NULL);  // address of flag set when default char. used 
                        g_dwPingTimeout = atol( szTempBuf ) * MS_PER_SEC;
#else
                        g_dwPingTimeout = atol( *(++lpszArgv) ) * MS_PER_SEC;
#endif                                      // #ifdef _UNICODE
                    }
                    break;
                case 'n':
                    g_fPingDontResolve = TRUE;
                    break;
                case 'p':                   // Data pattern
                    if ( dwArgc )
                    {
                        dwArgc--;
#ifdef _UNICODE
                        lpszArgv++;
  iFuncSRes = WideCharToMultiByte( CP_ACP,  // code page 
                                       0,   // performance and mapping flags 
                                 *lpszArgv, // address of wide-character string 
                                      -1,   // number of characters in string 
                          &szTempBuf[0],    // address of buffer for new string 
                      sizeof(szTempBuf),    // size of buffer 
                                    NULL,   // address of default for unmappable characters  
                                    NULL);  // address of flag set when default char. used 
                        g_iPingFillChar = (int) strtol( szTempBuf, 
                                                        NULL,
                                                        HEXADECIMAL_BASE);
#else
                        g_iPingFillChar = (int) strtol( *(++lpszArgv), 
                                                        NULL,
                                                        HEXADECIMAL_BASE);
#endif                                      // #ifdef _UNICODE
                    }
                    break;
                case 'r':                   // Record route
                    g_fPingRecordRoute = TRUE;
                    break;
                case 's':                   // Data size
                    if ( dwArgc )
                    {
                        dwArgc--;
#ifdef _UNICODE
                        lpszArgv++;
  iFuncSRes = WideCharToMultiByte( CP_ACP,  // code page 
                                       0,   // performance and mapping flags 
                                 *lpszArgv, // address of wide-character string 
                                      -1,   // number of characters in string 
                          &szTempBuf[0],    // address of buffer for new string 
                      sizeof(szTempBuf),    // size of buffer 
                                    NULL,   // address of default for unmappable characters  
                                    NULL);  // address of flag set when default char. used 
                        g_wPingDataSize = (WORD) atol( szTempBuf );
#else
                        g_wPingDataSize = (WORD) atol( *(++lpszArgv) );
#endif                                      // #ifdef _UNICODE
                        if ( g_wPingDataSize > ICMP_SENT_BUF_SIZE )
                        {
                            _tprintf( TEXT("ERROR: too large packet size.\n") );
                            return( RETURN_BAD_PARAMETER );
                        }
                    }
                    break;
                case 't':                   // TTL
                    if ( dwArgc )
                    {
                        dwArgc--;
#ifdef _UNICODE
                        lpszArgv++;
  iFuncSRes = WideCharToMultiByte( CP_ACP,  // code page 
                                       0,   // performance and mapping flags 
                                 *lpszArgv, // address of wide-character string 
                                      -1,   // number of characters in string 
                          &szTempBuf[0],    // address of buffer for new string 
                      sizeof(szTempBuf),    // size of buffer 
                                    NULL,   // address of default for unmappable characters  
                                    NULL);  // address of flag set when default char. used 
                        g_bPingTTL = (BYTE) atoi( szTempBuf );
#else
                        g_bPingTTL = (BYTE) atoi( *(++lpszArgv) );
#endif                                      // #ifdef _UNICODE
                    }
                    break;
                case 'v':                   // Verbose
                    g_fPingVerboseOut = TRUE;
                    break;
#if defined(_WINSOCK2)
                case 'w':                   // Disable Winsock v2
                    g_fAutoDetWinsock2 = FALSE;
                    break;
#endif                                      // #if defined(_WINSOCK2)
                default:
                    _tprintf( TEXT("ERROR: unknown option: -%s\n"), *lpszArgv );
                    return( RETURN_BAD_PARAMETER );
                    break;
          }
       }
       else
       {
          _tcscpy( g_szHostName, *lpszArgv ); // Just copy name
       }
     }
  }

//---------------------- Test user supplied data -----------------------------
  if ( g_szHostName[0] == TEXT('\0') )
  {
        _tprintf( TEXT("ERROR: no host specified\n") );
        return( RETURN_BAD_PARAMETER );
  }


//--------------------- Detect Windows Sockets DLL ---------------------------
#if defined(_DEBUG)
    OutputDebugString( TEXT("[WSPING32] Detect Windows Sockets presence and version.\n\r") );
#endif                                      // #if defined(_DEBUG)

#if defined(_WINSOCK2)
    if ((g_fAutoDetWinsock2 == TRUE) && (iDetectWS2Files() == 0))
    {
       if (WSAStartup(MAKEWORD(2,0),&wsaData) != 0)
       {
         _tprintf( TEXT("WARNING: No Windows Sockests version 2.0 present.\n") );
         _tprintf( TEXT("ERROR: WSAStartup failed. ErrorCode = %d.\n"), GetLastError() );
       }
       else
       {
           ULONG  ulForceNoBlockingMode = 1;
#if defined(_DEBUG)
          OutputDebugString( TEXT("[WSPING32] Windows Sockests version 2 detected.\n\r") );
#endif                                      // #if defined(_DEBUG)
          g_fUseWinsock2 = TRUE;
          if (g_fPingVerboseOut)
             _tprintf( TEXT("Windows Sockets version 2 or higher detected.\n") );

#if defined(_DEBUG)
          OutputDebugString( TEXT("[WSPING32] Create send raw socket.\n\r") );
#endif                                      // #if defined(_DEBUG)
#if defined(_IPRAW)
          g_sockRaw = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
#else
#if 0
          g_sockRaw = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
#endif
          g_sockRaw = WSASocket(AF_INET, SOCK_RAW, IPPROTO_ICMP, NULL, 0,0);
#endif                                      // #if defined(_IPRAW)
          if (g_sockRaw == INVALID_SOCKET) 
          {
            _tprintf( TEXT("ERROR: WSASocket() failed to create. ErrorCode = %d.\n"), WSAGetLastError() );
            wRetCode = RETCODE_NO_CREATE_RAW_SOCKET;
            goto Done;
          }
                                            // These BSD options are really absent in Win32!
#if defined(_DEBUG)
          OutputDebugString( TEXT("[WSPING32] Set timeout for send.\n\r") );
#endif                                      // #if defined(_DEBUG)
          iErr = setsockopt( g_sockRaw, SOL_SOCKET, SO_SNDTIMEO,
                            (char*)&g_dwPingTimeout, sizeof(g_dwPingTimeout) );
          if (iErr == SOCKET_ERROR) 
          {
             _tprintf( TEXT("ERROR: Failed to set send timeout. ErrCode = %d.\n"),
                       WSAGetLastError() );
             wRetCode = RETCODE_FAIL_TO_SET_TIMEOUT;
             goto Done;
          }

#if defined(_DEBUG)
          OutputDebugString( TEXT("[WSPING32] Set timeout for receive.\n\r") );
#endif                                      // #if defined(_DEBUG)
          iErr = setsockopt( g_sockRaw,SOL_SOCKET,SO_RCVTIMEO,
                             (char*)&g_dwPingTimeout, sizeof(g_dwPingTimeout) );
          if (iErr == SOCKET_ERROR)                               
          {
            _tprintf( TEXT("ERROR: Failed to set receive timeout. ErrCode = %d\n"),
                      WSAGetLastError() );
            wRetCode = RETCODE_FAIL_TO_SET_TIMEOUT;
            goto Done;   
          }

       } /*if-else*/
    } /*if*/
#endif                                      // #if defined(_WINSOCK2)

  if (g_fUseWinsock2 == FALSE)
  {
    wVersionRequested = MAKEWORD( 1, 1 );
    iErr = WSAStartup( wVersionRequested, &wsaData );
    if ( iErr != 0 ) 
    {
      _tprintf( TEXT("ERROR: No Windows Sockests found.\n") );
      return( RETCODE_NO_WINSOCK );
    }

    if ( LOBYTE( wsaData.wVersion ) != 1 ||
         HIBYTE( wsaData.wVersion ) != 1 ) 
    {
       _tprintf( TEXT("ERROR: No Windows Sockests version 1 present.\n") );
       wRetCode = RETCODE_NO_WINSOCK_V11;
       goto Done; 
    }
    if (g_fPingVerboseOut)
       _tprintf( TEXT("Windows Sockets version 1.1 detected.\n") );

#if defined(_DEBUG)
          OutputDebugString( TEXT("[WSPING32] Windows Sockests version 1.1 detected.\n\r") );
#endif                                      // #if defined(_DEBUG)
  }
  

//------------------ Resolve hostname ----------------------------------------
  for (dwIndex=0; dwIndex<_tcslen(g_szHostName); dwIndex++)
  {
    TCHAR chScanTemp = g_szHostName[dwIndex];
    if ( chScanTemp == TEXT('.') )          // Skip point
        continue;
    if ( !_istdigit(chScanTemp) )           // Digit or other?
    {
        fIpSymAddrFound = TRUE;
        break;
    }
  }
  
  if ( (g_fPingDontResolve == FALSE) && (fIpSymAddrFound == TRUE) )
  {
    LPHOSTENT   phe;                        // Host name/aliases/addresses
#ifdef _UNICODE
  iFuncSRes = WideCharToMultiByte( CP_ACP,  // code page 
                                       0,   // performance and mapping flags 
                        &g_szHostName[0],   // address of wide-character string 
                                      -1,   // number of characters in string 
                          &szTempBuf[0],    // address of buffer for new string 
                      sizeof(szTempBuf),    // size of buffer 
                                    NULL,   // address of default for unmappable characters  
                                    NULL);  // address of flag set when default char. used
    phe = gethostbyname( szTempBuf );
#else
    phe = gethostbyname( g_szHostName );
#endif                                      // #ifdef _UNICODE
    if ( phe == NULL ) 
    {
        _tprintf( TEXT("ERROR: Cannot resolve hostname.\n") );
        wRetCode = RETURN_BAD_HOSTNAME;
        goto Done;
    }
#ifdef _UNICODE
  iFuncSRes = MultiByteToWideChar( CP_ACP,  // code page 
                                        0,  // character-type options 
     inet_ntoa(*((LPIN_ADDR)phe->h_addr)),  // address of string to map 
                                       -1,  // number of characters in string 
                        &szTempBufWide[0],  // address of wide-character buffer 
                    sizeof(szTempBufWide) );// size of buffer 
    _tcscpy( g_szTestIpAddr, szTempBufWide );
#else
    _tcscpy( g_szTestIpAddr, inet_ntoa(*((LPIN_ADDR)phe->h_addr)) );
#endif                                      // #ifdef _UNICODE
  }
  else
  {
    _tcscpy( g_szTestIpAddr, g_szHostName );
  }


//---------------- Take control under console --------------------------------
    SetConsoleCtrlHandler( (PHANDLER_ROUTINE)ControlHandler, TRUE );


//----------------------------- Print header ---------------------------------
    _tprintf( TEXT("WSPING32 %s [%s]: %u data bytes\n"), g_szHostName, 
             g_szTestIpAddr, g_wPingDataSize );


//----------------------------- Run pinging ----------------------------------
   while ( g_dwPingRetryCount ) 
   {
       dwTestSiteRes = TestRemoteSite( g_szTestIpAddr, g_szHostName );
       if  ( dwTestSiteRes != RETCODE_DONE )
       {
            wRetCode = RETURN_NO_ECHO_REPLY;
       }
       else
       {
            wRetCode = RETCODE_DONE;
            if  ( g_fStopOnSuccess == TRUE )
            {
               g_dwPingRetryCount = 0;      // Effectively terminate loop
               continue;
            }
       }
       if ( g_fPingNonStop == FALSE )
       {
            if ( g_dwPingRetryCount ) 
               g_dwPingRetryCount--;
       }
       if ( (g_dwPingRetryCount != 0) && (g_dwPingTimeout != 0) )
       {
           g_fSleepTime = TRUE;             // Set semaphore
           Sleep(g_dwPingTimeout);
           g_fSleepTime = FALSE;            // Reset semaphore
       }
   }


//---------------------------- Command statistics ----------------------------
   PrintTotalResults();


//-------------------------- Command completion ------------------------------
Done:
  AppCleanUp();

  return( wRetCode );
}



//****************************************************************************
//                         --- ControlHandler ---
//
// Purpose: Console break handler
//   Input: DWORD dwCtrlType - Control type code
//  Output: BOOL             - TRUE   if processed
//                             FALSE  if ignored
// Written: by Dmitry V. Stefankov 12/31/97
//****************************************************************************
BOOL ControlHandler ( DWORD dwCtrlType )
{
    switch( dwCtrlType )
    {
        case CTRL_BREAK_EVENT:              // Use Ctrl+C or Ctrl+Break to simulate
        case CTRL_C_EVENT:                  // stop process
            g_dwPingRetryCount = 0;
            if ( (g_fWaitPacket == TRUE) || (g_fSleepTime == TRUE) )
            {                               // Emergency exit
              PrintTotalResults();          
              ExitProcess( RETCODE_ABORT_BY_USER );
            }
            return TRUE;
            break;

    }
    return FALSE;
}



//****************************************************************************
//                         --- TestRemoteSite ---
//
// Purpose: Checks is remote site alive
//   Input: LPCTSTR szRemoteSite - IP  address in string form
//          LPCTSTR szHostName   - DNS address in string form
//  Output: DWORD                - RETCODE_DONE if successful
//                                       any other value is error
// Written: by Dmitry V. Stefankov 09.01.97
//****************************************************************************
DWORD  TestRemoteSite( LPCTSTR szRemoteSite, LPCTSTR szHostName )
{
  DWORD         dwResult = RETCODE_DONE;    // Function return code
  HANDLE        hFile;                      // ICMP object handle
  DWORD         dwFuncRetCode;              // Function result code
  DWORD         dwDestIpAddr;               // IP destinantion address (packed)
  DWORD         dwRemoteIpAddr;             // IP reply address (packed)
  PICMP_ECHO_REPLY   RecvIcmpReply;         // ICMP reply datagran
  BYTE        chSentBuf[ICMP_SENT_BUF_SIZE];// ICMP optional data (to send)
  BYTE        chRecvBuf[ICMP_RECV_BUF_SIZE];// ICMP  receive buffer
#if defined(_DEBUG)
  TCHAR       chTempBuf[512];               // Temporary storage
#endif                                      // #if defined(_DEBUG)
#ifdef _UNICODE
  CHAR        szIpAddrSite[IP_ADDRESS_SIZE];// ANSI verison of IP address
#endif                                      // #ifdef _UNICODE
  double        dblTripTime = 0.0;          // Round-Trip-Time (RTT)
  BYTE          bReceivedTTL;               // TTL of received ECHO packet
  WORD          wRecvDataSize;              // Received data portion
  DWORD         dwStatus;                   // IP status (API result code)
  IP_OPTION_INFORMATION  RequestOptions;    // IP packet options
  BYTE          bPaddingChar;               // ICMP fill char
#if defined(_WINSOCK2)
  int           iFuncRes;                   // Function result
  pip           pIpHdr;                     // IP datagram
  USHORT        wIpHLen;                    // IP header size
  char          *pDataPart;                 // ICMP data
  picmp         pIcmpHdr;                   // ICMP header
  USHORT        wIcmpSize;                  // ICMP header+data size
  int           iFromLen;                   // Socket address size
  int           iReadBytes;                 // Received packet size
  struct sockaddr_in    saDest;             // Socket Address 
  struct sockaddr_in    saFrom;             // Socket Address 
  SYSTEMTIME     stSendSysTime;
  SYSTEMTIME     stRecvSysTime;
  WORD           wPacketSize;               // IP or ICMP packet size
#if defined(_IPRAW)
  WORD          wIpDataSize;                // IP datagram size
#endif                                      // #if defined(_IPRAW)
#endif                                      // #if defined(_WINSOCK2)


//------------------------- Just debug message -------------------------------
#if defined(_DEBUG)
     OutputDebugString( TEXT("[WSPING32] Test remote site.\n\r") );
#endif                                      // #if defined(_DEBUG)


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
  _stprintf( chTempBuf, TEXT("[WSPING32] Destination IP address: 0x%X (%s)\n"),
           dwDestIpAddr, szRemoteSite );
  OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)


//--------------------------- Open ICMP handle -------------------------------
  if (g_fUseWinsock2 == FALSE)
  {
#if defined(_DEBUG)
    OutputDebugString( TEXT("[WSPING32] Create ICMP handle.\n\r") );
#endif                                      // #if defined(_DEBUG)

    hFile = IcmpCreateFile();
    if ( hFile == NULL )
    {
       _tprintf( TEXT("ERROR: Cannot create ICMP handle.\n") );
       dwResult = RETCODE_NO_CREATE_ICMP;
       goto Done;
    }
  } 


//------------------------- Send ICMP echo packet ----------------------------
#if defined(_DEBUG)
  _stprintf( chTempBuf, TEXT("[WSPING32] Padding data byte:  0x%2X\n"), g_iPingFillChar );
  OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)

  memset( chRecvBuf, 0, sizeof(chRecvBuf) );
  memset( chSentBuf, 0, sizeof(chSentBuf) );

  if (g_fUseWinsock2 == FALSE)
  {
    memset( chSentBuf, g_iPingFillChar, sizeof(chSentBuf) );
#if defined(_DEBUG)
    OutputDebugString( TEXT("[WSPING32] Add IP packet options.\n\r") );
#endif                                      // #if defined(_DEBUG)
    RequestOptions.Ttl = g_bPingTTL;        // Time To Live
    RequestOptions.Tos = 0x7;               // Type Of Service (7=network control)
    RequestOptions.Flags = 0;               // IP header flags
    RequestOptions.OptionsSize = 0;         // Size in bytes of options data
    RequestOptions.OptionsData = NULL;      // Pointer to options data
    if  ( g_fPingDontFragment == TRUE )
      RequestOptions.Flags |= IP_FLAG_DF;
    if  ( g_fPingRecordRoute == TRUE )
    {
      RequestOptions.Flags |= IP_OPT_RR;
      RequestOptions.OptionsSize = sizeof(g_bOptionSpace)-1;
      RequestOptions.OptionsData = &g_bOptionSpace[0];
    }
  }
#if defined(_WINSOCK2)
  else
  { 
    wPacketSize = 0;
#if defined(_IPRAW)
    wIpHLen = sizeof(IpHeader);
    wPacketSize += wIpHLen;
#endif                                      // #if defined(_IPRAW)
    if ( (g_wPingDataSize+wPacketSize) > sizeof(chSentBuf) )
      g_wPingDataSize = sizeof(chSentBuf) - wPacketSize;
    wIcmpSize = g_wPingDataSize+sizeof(IcmpHeader);
    wPacketSize += wIcmpSize;
#if defined(_IPRAW)   
    wIpDataSize = wPacketSize;
    pIpHdr = (pip)&chSentBuf;               // Fill IP packet
    pIpHdr->ip_version = 0x4;               // IP v4
    pIpHdr->ip_hlen = wIpHLen / IP_HDR_UNIT;
    pIpHdr->ip_tos = 0x7;
    pIpHdr->ip_ident = htons( (USHORT)GetCurrentProcessId() );
    pIpHdr->ip_tlen = htons( wPacketSize );
    pIpHdr->ip_fragoff = 0;
    pIpHdr->ip_ttl = g_bPingTTL;
    pIpHdr->ip_proto = IPPROTO_ICMP;
#if defined(_IPRAW_TEST)   
    pIpHdr->ip_source = htonl( 0xC0A80001 );
#else
#error "ERROR: no address calculations for RAW_IP!"
	pIpHdr->ip_source = htonl( 0x00000001 );
#endif                                      // #if defined(_IPRAW_TEST)
    pIpHdr->ip_dest = dwDestIpAddr;
    pIpHdr->ip_checksum = CheckSum((USHORT*)chSentBuf, wIpHLen );
    pIcmpHdr = (picmp)(chSentBuf+wIpHLen);
#else
    pIcmpHdr = (picmp)&chSentBuf;           
#endif                                      // #if defined(_IPRAW)    
    pIcmpHdr->icmp_type = ICMP_ECHO;        // Fill ICMP packet
    pIcmpHdr->icmp_code = 0;
    pIcmpHdr->icmp_id = (USHORT)GetCurrentProcessId();
    pIcmpHdr->icmp_chksum = 0;
    pIcmpHdr->icmp_seq = (USHORT)g_dwIcmpSeq;

    pDataPart = (char *)pIcmpHdr + sizeof(IcmpHeader);
    if (g_wPingDataSize)
      memset( pDataPart, g_iPingFillChar, g_wPingDataSize );

    pIcmpHdr->icmp_chksum = 0;

    GetSystemTime( &stSendSysTime );        // For use
           
    pIcmpHdr->icmp_timestamp_ext = GetTickCount();// For Windows NT
    pIcmpHdr->icmp_chksum = CheckSum((USHORT*)pIcmpHdr, wIcmpSize );

    memset( &saFrom, 0, sizeof(saFrom) );
    memset( &saDest, 0, sizeof(saDest) );

    saDest.sin_addr.s_addr = dwDestIpAddr;
    saDest.sin_family = AF_INET;

    iFromLen = sizeof(saFrom);

#if 1
    wPacketSize = 32;
    chSentBuf[0]  = 0x45;    chSentBuf[1]  = 0x00;
    chSentBuf[2]  = 0x00;    chSentBuf[3]  = 0x20;
    chSentBuf[4]  = 0x00;    chSentBuf[5]  = 0x00;
    chSentBuf[6]  = 0x00;    chSentBuf[7]  = 0x00;
    chSentBuf[8]  = 0x0E;    chSentBuf[9]  = 0x01;
    chSentBuf[10] = 0x2b;    chSentBuf[11] = 0x8a;
    chSentBuf[12] = 0xc0;    chSentBuf[13] = 0xa8;
    chSentBuf[14] = 0x00;    chSentBuf[15] = 0x01;
    chSentBuf[16] = 0xc0;    chSentBuf[17] = 0xa8;
    chSentBuf[18] = 0x00;    chSentBuf[19] = 0x02;
    chSentBuf[20] = 0x08;    chSentBuf[21] = 0x00;
    chSentBuf[22] = 0x15;    chSentBuf[23] = 0xc4;
    chSentBuf[24] = 0xff;    chSentBuf[25] = 0xff;
    chSentBuf[26] = 0x00;    chSentBuf[27] = 0x00;
    chSentBuf[28] = 0xe2;    chSentBuf[29] = 0x3b;
    chSentBuf[30] = 0x00;    chSentBuf[31] = 0x00;
#endif
/*
0000  00 80 48 e8 7b bb 00 80 48 e8 a9 76 08 00 45 00  ..Hh{;..Hh)v..E.
0010  00 20 00 00 00 00 0e 01 2b 8a c0 a8 00 01 c0 a8  . ......+.@(..@(
0020  00 02 08 00 15 c4 ff ff 00 00 e2 3b 00 00        .....D....b;..
*/

  }
#endif                                      // #if defined(_WINSOCK2)

  g_dwTransmittedPkts++;                    // Next packet
  g_dwIcmpSeq++;                            // Sequence number (only diagnostic)

#if defined(_DEBUG)
  OutputDebugString( TEXT("[WSPING32] Send ICMP echo packet.\n\r") );
#endif                                      // #if defined(_DEBUG)

  if (g_fUseWinsock2 == FALSE)
  {
    dwFuncRetCode = IcmpSendEcho( hFile,    // ICMP handle
                               dwDestIpAddr,// IP destination address
                               chSentBuf,   // Data buffer to sent
                            g_wPingDataSize,// Length of data buffer to sent
                            &RequestOptions,// IP Options pointer
                               chRecvBuf,   // Data buffer to receive
                          sizeof(chRecvBuf),// Length of receive buffer 
                            g_dwPingTimeout // Timeout in milliseconds
                              );
  }
#if defined(_WINSOCK2)
  else
  {
#if defined(_DEBUG)
#if defined(_DEBUGOUT)                      // Want to dump?
    UINT  i;
    OutputDebugString( TEXT("[WSPING32] ICMP echo request packet dump.\n\r") );
    OutputDebugString( TEXT("[WSPING32] ") );
    for(i=0; i < wPacketSize; i++)
    {
      if (i && ((i % 8) == 0) )
      {
        OutputDebugString( TEXT("\n\r") );
        OutputDebugString( TEXT("[WSPING32] ") );
      }
      _stprintf( chTempBuf, TEXT("0x%02X "), (BYTE)chSentBuf[i] );
      OutputDebugString( chTempBuf );
    }
    OutputDebugString( TEXT("\n\r") );
#endif                                      // #if defined(_DEBUGOUT)
  _stprintf( chTempBuf, TEXT("[WSPING32] ICMP packet size is %d bytes.\n"), wPacketSize );
  OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
    dwFuncRetCode = FALSE;                  // Assume failure
    iFuncRes = sendto( g_sockRaw,chSentBuf,wPacketSize,0,
                      (struct sockaddr*)&saDest, sizeof(saDest) );
#if defined(_DEBUG)
  _stprintf( chTempBuf, TEXT("[WSPING32] sendto() returns code = %d.\n"), iFuncRes );
  OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
    dwResult = WSAGetLastError();
    if (iFuncRes == SOCKET_ERROR)
    {
      goto Done;
    }

#if defined(_DEBUG)
  OutputDebugString( TEXT("[WSPING32] Receive ICMP echo packet.\n\r") );
#endif                                      // #if defined(_DEBUG)
    g_fWaitPacket = TRUE;                   // Set semaphore
    iReadBytes = recvfrom( g_sockRaw, chRecvBuf, sizeof(chRecvBuf), 0,
                           (struct sockaddr*)&saFrom, &iFromLen);
    g_fWaitPacket = FALSE;                  // Reset semaphore
    GetSystemTime( &stRecvSysTime );
#if defined(_DEBUG)
  _stprintf( chTempBuf, TEXT("[WSPING32] recvfrom() returns code = %d.\n"), iReadBytes );
  OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
    dwResult = WSAGetLastError();
    if (iReadBytes == SOCKET_ERROR)
    {
      goto Done;
    }
    else
    {
#if defined(_DEBUG)
#if defined(_DEBUGOUT)                      // Want to dump?
    INT  i;
    OutputDebugString( TEXT("[WSPING32] ICMP echo reply packet dump.\n\r") );
    OutputDebugString( TEXT("[WSPING32] ") );
    for(i=0; i < iReadBytes; i++)
    {
      if (i && ((i % 8) == 0) )
      {
        OutputDebugString( TEXT("\n\r") );
        OutputDebugString( TEXT("[WSPING32] ") );
      }
      _stprintf( chTempBuf, TEXT("0x%02X "), (BYTE)chRecvBuf[i] );
      OutputDebugString( chTempBuf );
    }
    OutputDebugString( TEXT("\n\r") );
#endif                                      // #if defined(_DEBUGOUT)
#endif                                      // #if defined(_DEBUG)
      pIpHdr = (pip) chRecvBuf;
      wIpHLen = pIpHdr->ip_hlen * IP_HDR_UNIT;
      if (iReadBytes < wIpHLen + ICMP_MIN) 
      {
        _tprintf( TEXT("[WSPING32] Too few bytes from %s\n"), 
                  inet_ntoa(saFrom.sin_addr));
        dwResult = WSAEHOSTUNREACH;
        goto Done;
      }

      pIcmpHdr = (picmp)(chRecvBuf+wIpHLen);
      pDataPart = (char*)(chRecvBuf+wIpHLen+sizeof(IcmpHeader));

      if ( pIcmpHdr->icmp_type != ICMP_ECHOREPLY ) 
      {
        _tprintf( TEXT("[WSPING32] non-echo type %d received.\n"), pIcmpHdr->icmp_type);
        dwResult = WSAEHOSTUNREACH;
        goto Done;
      }

      if ( pIcmpHdr->icmp_id != (USHORT)GetCurrentProcessId() ) 
      {
        _tprintf( TEXT("[WSPING32] Wrong ID in answer. Request = %d, reply = %d.\n"), 
                  (USHORT)GetCurrentProcessId(), pIcmpHdr->icmp_id );
        dwResult = WSAEHOSTUNREACH;
        goto Done;
      }
      dwResult = RETCODE_DONE;
      dwFuncRetCode = TRUE;
    }
  }
#endif                                      // #if defined(_WINSOCK2)

  if ( dwFuncRetCode == TRUE )
  {
     if ( g_fPingAudible == TRUE )
     {
       _tprintf( TEXT("\a") );
     }
#if defined(_DEBUG)
     OutputDebugString( TEXT("[WSPING32] Ping was successful.\n\r") );
#endif                                      // #if defined(_DEBUG)
     if (g_fUseWinsock2 == FALSE)
     {
       RecvIcmpReply = (PICMP_ECHO_REPLY)chRecvBuf;
       dwRemoteIpAddr = RecvIcmpReply->Address;
       bReceivedTTL = RecvIcmpReply->Options.Ttl;
       wRecvDataSize = RecvIcmpReply->DataSize;
       dblTripTime = RecvIcmpReply->RoundTripTime;
       if (wRecvDataSize)
         bPaddingChar = *(PBYTE)(RecvIcmpReply->Data);
       else
         bPaddingChar = g_iPingFillChar;
       dwStatus = RecvIcmpReply->Status;
     }
#if defined(_WINSOCK2)
     else
     {
       dwRemoteIpAddr = pIpHdr->ip_source;
       bReceivedTTL = pIpHdr->ip_ttl;
       wRecvDataSize = iReadBytes - (wIpHLen + sizeof(IcmpHeader));
       dblTripTime = (stRecvSysTime.wMinute * 60 + stRecvSysTime.wSecond) * 1000 +
                     stRecvSysTime.wMilliseconds;
       dblTripTime -= ( (stSendSysTime.wMinute * 60 + stSendSysTime.wSecond) * 1000 +
                        stSendSysTime.wMilliseconds );
       if (wRecvDataSize)
         bPaddingChar = *pDataPart;
       else
         bPaddingChar = g_iPingFillChar;
       dwStatus = 0;                        // Good completion code!
     }
#endif                                      // #if defined(_WINSOCK2)
#if defined(_DEBUG)
     _stprintf( chTempBuf, TEXT("[WSPING32] Reply IP address: 0x%X (%u.%u.%u.%u)\n"),
                      dwRemoteIpAddr,
                      dwRemoteIpAddr & 0xFF, dwRemoteIpAddr >> 8 & 0xFF,
                      dwRemoteIpAddr >> 16 & 0xFF, dwRemoteIpAddr >> 24 & 0xFF );
     OutputDebugString( chTempBuf );
     _stprintf( chTempBuf, TEXT("[WSPING32] Reply IP status:  0x%X\n"),
                dwStatus );
     OutputDebugString( chTempBuf );
     _stprintf( chTempBuf, TEXT("[WSPING32] Reply RTT (ms):   0x%u\n"),
              dblTripTime );
     OutputDebugString( chTempBuf );
     _stprintf( chTempBuf, TEXT("[WSPING32] Reply datasize:   0x%u\n"),
              wRecvDataSize );
     OutputDebugString( chTempBuf );
     _stprintf( chTempBuf, TEXT("[WSPING32] Reply data byte:  0x%02X\n"),
               bPaddingChar );
     OutputDebugString( chTempBuf );
     _stprintf( chTempBuf, TEXT("[WSPING32] Reply TTL:  0x%02X (%d)\n"),
              bReceivedTTL, bReceivedTTL);
     OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
     if ( (dwRemoteIpAddr != dwDestIpAddr) &&
          ((dwRemoteIpAddr & 0xFF) != LOOPBACK_ADDR) )
     {
        _tprintf( TEXT("ERROR: Reply packet has unexpected IP address.\n") );
        if  ( g_fPingVerboseOut == TRUE )
        {
            _tprintf( TEXT("Unexpected packet from [%u.%u.%u.%u].\n"),
                     dwRemoteIpAddr & 0xFF, dwRemoteIpAddr >> 8 & 0xFF, 
                     dwRemoteIpAddr >> 16 & 0xFF, dwRemoteIpAddr >> 24 & 0xFF);
        }
        dwResult = RETCODE_WRONG_IP_ADDR;
     }
     else
     {
        if (bPaddingChar != g_iPingFillChar)
        {
            _tprintf( TEXT("WARNING: Expected data byte is 0x%02X, but received data is 0x%02X.\n"),
                      g_iPingFillChar, bPaddingChar );
        }
        if  (wRecvDataSize != g_wPingDataSize)
        {
            _tprintf( TEXT("WARNING: Expected data size is %u bytes, but got data size is %u bytes.\n"),
                      g_wPingDataSize, wRecvDataSize  );
        }
        g_dblTSum += dblTripTime;
        if (dblTripTime < g_dblTMin)
                g_dblTMin = dblTripTime;
        if (dblTripTime > g_dblTMax)
                g_dblTMax = dblTripTime;
        _tprintf( TEXT("%d bytes from [%u.%u.%u.%u]: packet=%lu, ttl=%d, rtt=%.3f sec\n"),
                      wRecvDataSize,
                      dwRemoteIpAddr & 0xFF, dwRemoteIpAddr >> 8 & 0xFF,
                      dwRemoteIpAddr >> 16 & 0xFF, dwRemoteIpAddr >> 24 & 0xFF,
                      g_dwIcmpSeq, bReceivedTTL, dblTripTime / 1000.0);
     }
  }
  else
  {
     dwFuncRetCode = GetLastError();
#if defined(_DEBUG)
     _stprintf( chTempBuf, TEXT("[WSPING32] ERROR: Ping failed. Extended error code = %lu\n"),
              dwFuncRetCode );
     OutputDebugString( chTempBuf );
#endif                                      // #if defined(_DEBUG)
     dwResult = dwFuncRetCode;
  }


//--------------------------- Close ICMP handle ------------------------------
  if (g_fUseWinsock2 == FALSE)
  {
#if defined(_DEBUG)
    OutputDebugString( TEXT("[WSPING32] Close ICMP handle.\n\r") );
#endif                                      // #if defined(_DEBUG)
    IcmpCloseHandle( hFile );
  }

Done:
   if  (dwResult == RETCODE_DONE)
   {
      g_dwReceivedPkts++;                   // Good receiving packet
#if defined(_DEBUG)
      OutputDebugString( TEXT("[WSPING32] Remote site is alive.\n\r") );
#endif                                      // #if defined(_DEBUG)
   }
   else
   {
        switch( dwResult )                  // Errors processing
        {
            case IP_BUF_TOO_SMALL:
#if defined(_WINSOCK2)            
            case WSAENOBUFS:
#endif                                      // #if defined(_WINSOCK2)
                    _tprintf( TEXT("ERROR: Buffer Too Small.\n") );
                    break;
            case IP_DEST_NET_UNREACHABLE:
#if defined(_WINSOCK2)            
            case WSAENETUNREACH:
#endif                                      // #if defined(_WINSOCK2)
                    _tprintf( TEXT("ERROR: Destination Net Unreachable.\n") );
                    break;
            case IP_DEST_HOST_UNREACHABLE:
#if defined(_WINSOCK2)            
            case WSAEHOSTUNREACH:
#endif                                      // #if defined(_WINSOCK2)
                    _tprintf( TEXT("ERROR: Destination Host Unreachable.\n") );
                    break;
            case IP_DEST_PROT_UNREACHABLE:
#if defined(_WINSOCK2)            
            case WSAEAFNOSUPPORT:
#endif                                      // #if defined(_WINSOCK2)
                    _tprintf( TEXT("ERROR: Destination Protocol Unreachable.\n") );
                    break;
            case IP_DEST_PORT_UNREACHABLE:
                    _tprintf( TEXT("ERROR: Destination Port Unreachable.\n") );
                    break;
            case IP_REQ_TIMED_OUT:
#if defined(_WINSOCK2)            
            case WSAETIMEDOUT:
#endif                                      // #if defined(_WINSOCK2)
                    _tprintf( TEXT("ERROR: Request Timed Out.\n") );
                    break;
            case IP_PACKET_TOO_BIG:
#if defined(_WINSOCK2)            
            case WSAEMSGSIZE:
#endif                                      // #if defined(_WINSOCK2)
                    _tprintf( TEXT("ERROR: Packet Too Big.\n") );
                    break;
            case IP_TTL_EXPIRED_TRANSIT:
                    _tprintf( TEXT("ERROR: TTL Expired In Transit.\n") );
                    break;
            case IP_TTL_EXPIRED_REASSEM:
                    _tprintf( TEXT("ERROR: TTL Expired During Reassembly.\n") );
                    break;
            case IP_PARAM_PROBLEM:
#if defined(_WINSOCK2)            
            case WSAEINVAL:
#endif                                      // #if defined(_WINSOCK2)
                    _tprintf( TEXT("ERROR: IP Parameter Problem.\n") );
                    break;
            case IP_BAD_DESTINATION:
#if defined(_WINSOCK2)            
            case WSAEFAULT:
#endif                                      // #if defined(_WINSOCK2)
                    _tprintf( TEXT("ERROR: Bad Destination Host.\n") );
                    break;
            case IP_BAD_ROUTE:
                    _tprintf( TEXT("ERROR: Bad Source Route.\n") );
                    break;
            case IP_NO_RESOURCES:
#if defined(_WINSOCK2)            
            case WSAEWOULDBLOCK:
#endif                                      // #if defined(_WINSOCK2)
                    _tprintf( TEXT("ERROR: No Resources.\n") );
                    break;
            case IP_BAD_OPTION:
                    _tprintf( TEXT("ERROR: Bad Option Specified.\n") );
                    break;
            case IP_HW_ERROR:
                    _tprintf( TEXT("ERROR: Hardware Error.\n") );
                    break;
            case IP_BAD_REQ:
                    _tprintf( TEXT("ERROR: Bad Request Specified.\n") );
                    break;
            case IP_SOURCE_QUENCH:
                    _tprintf( TEXT("ERROR: Source Quench Received.\n") );
                    break;
            case IP_OPTION_TOO_BIG:
                    _tprintf( TEXT("ERROR: IP Option Too Big.\n") );
                    break;
            default:
                    _tprintf( TEXT("Dest Unreachable, Bad Code: %d (0x%08X)\n"), 
                            dwResult, dwResult );
                    break;
        }
   }

   return( dwResult );
}



//****************************************************************************
//                           --- AppCleanUp ---
//
// Purpose: Cleanup before exit to system
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 31.12.97
//****************************************************************************
VOID AppCleanUp( VOID )
{
#if defined(_DEBUG)
    OutputDebugString( TEXT("[WSPING32] Clean-up before exit.\n\r") );
#endif                                      // #if defined(_DEBUG)
                     
  WSACleanup();
}



//****************************************************************************
//                         --- PrintTotalResults ---
// Purpose: Print final results of statistics collection
//   Input: none
//  Output: none
// Written: by Dmitry V. Stefankov 11/29/98
//****************************************************************************
VOID  PrintTotalResults( VOID )
{
#if defined(_DEBUG)
    OutputDebugString( TEXT("[WSPING32] Print statistics.\n\r") );
#endif                                      // #if defined(_DEBUG)
   _tprintf( TEXT("\n-------- %s ping statistics --------\n"), g_szTestIpAddr );
   _tprintf( TEXT("%lu packets transmitted, %lu packets received, "), 
                   g_dwTransmittedPkts, g_dwReceivedPkts);
    if ( g_dwTransmittedPkts )
    {
        if ( g_dwReceivedPkts > g_dwTransmittedPkts )
            _tprintf( TEXT("-- somebody's printing up packets!") );
        else
            _tprintf( TEXT("%d%% loss packet"), 
            (g_dwTransmittedPkts - g_dwReceivedPkts) * 100 / g_dwTransmittedPkts );
    }
    _tprintf( TEXT("\n") );   
    if ( g_dwReceivedPkts ) 
    {
        double dblTemp = g_dblTSum / (g_dwReceivedPkts);
        _tprintf( TEXT("round-trip min/avg/max = %.3f/%.3f/%.3f sec\n"),
                g_dblTMin/1000.0, dblTemp/1000.0, g_dblTMax/1000.0);
    }
}


#if defined(_WINSOCK2)

//****************************************************************************
//                         --- iDetectWS2Files ---
// Purpose: Try to detect wanted DLL in the system
//   Input: none
//  Output: int   - 0 success
//                  1 not found
// Written: by Dmitry V. Stefankov 11/27/98
//****************************************************************************
int  iDetectWS2Files( VOID )
{
  HINSTANCE  hLib1;                         // Winsock 2 Program
  HINSTANCE  hLib2;                         // Winsock 2 Help

  hLib1 = LoadLibrary("WS2_32.DLL" );
  if (hLib1 == NULL)
  {
      if (g_fPingVerboseOut)
		  _tprintf( TEXT("WARN: Windows Sockets version 2 or higher not detected.\n") );
#if defined(_DEBUG)
            OutputDebugString( TEXT("[WSPING32] WS2_32.DLL not found!\n\r") );
#endif                                      // #if defined(_DEBUG)
    return(1);
  }
  if (FreeLibrary(hLib1) == FALSE)
  {
#if defined(_DEBUG)
            OutputDebugString( TEXT("[WSPING32] Cannot unload WS2_32.DLL!\n\r") );
#endif                                      // #if defined(_DEBUG)
  }

  hLib2 = LoadLibrary("WS2HELP.DLL" );
  if (hLib2 == NULL)
  {
#if defined(_DEBUG)
            OutputDebugString( TEXT("[WSPING32] WS2HELP.DLL not found!\n\r") );
#endif                                      // #if defined(_DEBUG)
    return(1);
  }
  if (FreeLibrary(hLib2) == FALSE)
  {
#if defined(_DEBUG)
            OutputDebugString( TEXT("[WSPING32] Cannot unload WS2HELP.DLL!\n\r") );
#endif                                      // #if defined(_DEBUG)
  }

  return(0);
}



//****************************************************************************
//                         --- CheckSum ---
// Purpose: Calculate 16-bit checksum according Internet standards
//   Input: USHORT  *buffer  - data buffer
//          int        size  - buffer size
//  Output: USHORT           - calculated checksum
// Written: by Dmitry V. Stefankov 11/26/98
//****************************************************************************
USHORT  CheckSum( USHORT *buffer, int size ) 
{
  unsigned long  chksum = 0;                // Test summa
  int  i;                                   // Index

  if ( (buffer == NULL) || (size == 0) )
    return( (USHORT)chksum );

  for(i=0; i<(size/2); i++)
    chksum+=*buffer++;
  
  if (size & 1) 
    chksum += *(UCHAR*)buffer;

  chksum = (chksum >> 16) + (chksum & 0xffff);
  chksum += (chksum >> 16);
  return( (USHORT)(~chksum) );
}
#endif                                      // #if defined(_WINSOCK2)
