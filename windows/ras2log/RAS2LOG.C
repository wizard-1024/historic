//****************************************************************************
//                            File RAS2LOG.C
//
//            Read eventlog for Remote Access Service (RAS) 
//
//      Copyright (c) Dmitry V. Stefankov, 1997. All rights reserved.
//
//****************************************************************************
//
//   $Source: F:/MSVC20/SOURCE/RAS2LOG/RCS/ras2log.c $
//  $RCSfile: ras2log.c $
//   $Author: dstef $
//     $Date: 1998/10/03 13:24:30 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: ras2log.c $
//      Revision 1.1  1998/10/03 13:24:30  dstef
//      Initial revision
//
//
//****************************************************************************



//---------------------------- Compilation defines --------------------------------

#define  _UNICODE                           // UniCode for C runtime library
#define   UNICODE                           // UniCode for WIN32 API


//---------------------------- Standard files --------------------------------

#include <windows.h>                        // Windows definitions
#include <stdio.h>                          // I/O library
#include <stdlib.h>                         // Default library
#include <time.h>                           // Time/date
#include <tchar.h>                          // Unicode


//--------------------------- Private definitions ---------------------------

#define   QUOTA             0x22
#define   BUFFER_SIZE       1024*64*16*2    // 2 Megabytes
#define   DECIMAL_RADIX     10
#define   SECS_PER_MIN      60
#define   MINS_PER_HOUR     60
#define   MAX_USERS         1000
#define   MAX_USERNAME_LEN  20


typedef struct  UserStatInfo
{
   TCHAR    szUserName[MAX_USERNAME_LEN];
   DWORD    dwUserSecs;
   DWORD    dwUserMins;
   DWORD    dwUserHrs;
   DWORD    dwUserSentBytes;
   DWORD    dwUserRcvdBytes;
};


//---------------------- Author, Copyright, Version --------------------------

const  TCHAR  g_szVersion[]           =  TEXT("v1.0");
const  TCHAR  g_szCopyright[]         =  TEXT("Copyright (c) 1997");
const  TCHAR  g_szAuthor[]            =  TEXT("Dmitry Stefankov");


//---------------------------- Private data ---------------------------------

const  TCHAR  g_szAppName[]          =  TEXT("Ras2Log");
const  TCHAR  g_szKeyPath[]          =  TEXT("System");
const  TCHAR  g_szServiceName[]      =  TEXT("RemoteAccess");
const  TCHAR  g_szComputerName[]     =  TEXT("computer:");
const  TCHAR  g_szUserName[]         =  TEXT("user:");
TCHAR  g_szRemoteComputerName[256]   =  TEXT("");
BOOL   g_fAddNewUser = TRUE;                // Enable to add new users
struct UserStatInfo g_UserStatInfo[MAX_USERS];// Global statistics (CIA or KGB)



//****************************************************************************
//                              --- main ---
//
// Purpose: Main program function
//   Input: int      argc -  number of arguments in command (shell) line
//          char   **argv -  array of pointers to argument-strings
//          char   * envp -  pointer to environment block
//  Output: none
// Written: by Dmitry V. Stefankov 6/25/97
//****************************************************************************
void main( int argc, char **argv, char *envp )
{
    HANDLE              hEventLog;          // Application eventlog file
    EVENTLOGRECORD      *pevlr;             // Eventlog structure
    PVOID               pBuffer;            // Buffer pointer
    DWORD               dwRead = 0;         // Bytes read from eventlog
    DWORD               dwNeeded = 0;       // Bytes need at next reading
    DWORD               cRecords = 0;       // Number of records in eventlog
    DWORD               dwThisRecord = 0;   // Number record
    DWORD               cStrings;           // Number of strings in one record
    DWORD               cStringSize;        // String length
    DWORD               dwSentBytesAll = 0; // Total sent bytes
    DWORD               dwRecvdBytesAll = 0;// Total received bytes
    DWORD               dwTotalSecs = 0;    // Total spent seconds
    DWORD               dwTotalMins = 0;    // Total spent minutes
    DWORD               dwTotalHrs = 0;     // Total spent hours
    TCHAR               *pString;           // Temporary pointer
    TCHAR               *pTemp;             // Temporary pointer
    DWORD               dwArgc;             // Arguments number
    DWORD               dwTempValue;        // Temporary value
    LPTSTR              *lpszArgv;          // Arguments array
    int                 iTemp;              // Temporary value
    int                 iIndex;             // Array index
    int                 iCurIndex;          // Current array index
    int                 g_iLastIndex = 0;   // Last array index
    DWORD               g_dwArgIndex = 1;   // Command parameter


//----------------------- Initialize ----------------------------------------

    for (iIndex = 0; iIndex < MAX_USERS; iIndex++)
    {
      g_UserStatInfo[iIndex].szUserName[0] = TEXT('\0');
      g_UserStatInfo[iIndex].dwUserSecs = 0;
      g_UserStatInfo[iIndex].dwUserMins = 0;
      g_UserStatInfo[iIndex].dwUserHrs = 0;
      g_UserStatInfo[iIndex].dwUserSentBytes = 0;
      g_UserStatInfo[iIndex].dwUserRcvdBytes = 0;
    }

//----------------------- Look parameters ----------------------------------

#ifdef UNICODE
    lpszArgv = (LPTSTR *)CommandLineToArgvW( GetCommandLineW(), &dwArgc );
#else
    dwArgc   = (DWORD) argc;
    lpszArgv = argv;
#endif

    while ( dwArgc > 1 )
    {
       if ( (*lpszArgv[g_dwArgIndex] != '-') && (*lpszArgv[g_dwArgIndex] && '/') )
       {
          _tprintf( TEXT("RAS2LOG: No parameter specified. Use -? for help.") );
          exit(1);
       }
       dwArgc--;  
       if ( (_tcsstr(lpszArgv[g_dwArgIndex],g_szComputerName) != NULL) )
       {      
               _tcscpy( g_szRemoteComputerName, lpszArgv[g_dwArgIndex]+_tcslen(g_szComputerName)+1 );
       }
       else if ( (_tcsstr(lpszArgv[g_dwArgIndex],g_szUserName) != NULL) )
       {
               _tcscpy( g_UserStatInfo[g_iLastIndex].szUserName, 
                        lpszArgv[g_dwArgIndex]+_tcslen(g_szUserName)+1 );
               pString = g_UserStatInfo[g_iLastIndex].szUserName;
               iTemp = pString[0];
               if ( _istlower((short int)iTemp) ) 
                 pString[0] = _toupper(iTemp);
               for (iIndex = 1; iIndex < MAX_USERNAME_LEN; iIndex++)
               {
                  iTemp = pString[iIndex];
                  if ( _istupper((short int)iTemp) )
                    pString[iIndex] = _tolower(iTemp);
               };
               g_iLastIndex++;
               g_fAddNewUser = FALSE;
       }
       else if ( _tcsicmp( TEXT("?"), lpszArgv[g_dwArgIndex]+1 ) == 0 )
       {
          _tprintf( TEXT("RAS EventLog Dump %s, %s %s\n"),
                    g_szVersion, g_szCopyright, g_szAuthor );
          _tprintf( TEXT("Release date:  %s\n"), TEXT(__DATE__) );
          _tprintf( TEXT("Release time:  %s\n"), TEXT(__TIME__) );
          _tprintf( TEXT("USAGE:\n") );
          _tprintf( TEXT("%s  [-%sUNC_computername] [[-%sNameOfUser]...]\n"),
                    g_szAppName, g_szComputerName, g_szUserName );
          _tprintf( TEXT("Sample:  RAS2LOG -user:dstef -computer:\\\\FREEDOM -user:IJMK1701\n") );
          exit(0);
       }
       else
       {
          _tprintf( TEXT("RAS2LOG: Wrong parameter. Use -? for help.") );
          exit(1);
       }
       g_dwArgIndex++;
    }

//----------------------- Allocate bufer ------------------------------------

    pBuffer = malloc(BUFFER_SIZE);
    if ( pBuffer == NULL )
    {
      _tprintf( TEXT("ERROR: cannot allocate memory!") );
      goto Done;
    }

//---------------------------- Open the System log --------------------------

    hEventLog = OpenEventLog( 
                    g_szRemoteComputerName, // Computer (local or remote)
                    (LPCTSTR)g_szKeyPath);  // Source name

    if ( hEventLog == NULL )
    {
       _tprintf( TEXT("ERROR: could not open System event log") );
       goto Done;
    };

//----------- Get the number of records in the Application event log --------

    if ( !GetNumberOfEventLogRecords(hEventLog, &cRecords) )
    {
       _tprintf( TEXT("ERROR: could not get number of records") );
       goto Done;
    };

    pevlr = (EVENTLOGRECORD *) pBuffer;

//----------------- Write HTML header ---------------------------------------

   _tprintf( TEXT("Content-type: text/html") );
   _tprintf( TEXT("\n") );
   _tprintf( TEXT("\n") );

   _tprintf( TEXT("<HTML><HEAD><TITLE>Remote Access Service</TITLE></HEAD>\n") );
   _tprintf( TEXT("<BODY><H1>Remote Access Service (RAS) connections</H1><P>\n"));
   _tprintf( TEXT("<UL><LI><A HREF=%c#TOTAL%c>Total Connections</A></LI>\n"),QUOTA,QUOTA );
   _tprintf( TEXT("<LI><A HREF=%c#DETAIL%c>Detail per user</A></LI>\n"),QUOTA,QUOTA );
   _tprintf( TEXT("</UL><P><H2><A NAME=%cTOTAL%c>Total Connections</A></H2>\n"),QUOTA,QUOTA );

//----------------- Write HTML table beginning ------------------------------

   _tprintf( TEXT("<TABLE BORDER>") );
   _tprintf( TEXT("<TR><TD ALIGN=LEFT><B>User</B>") );
   _tprintf( TEXT("<TD ALIGN=LEFT><B>From</B>") );
   _tprintf( TEXT("<TD ALIGN=LEFT><B>To</B>") );
   _tprintf( TEXT("<TD ALIGN=LEFT><B>Duration</B>") );
   _tprintf( TEXT("<TD ALIGN=LEFT><B>Sent</B>") );
   _tprintf( TEXT("<TD ALIGN=LEFT><B>Received</B>") );
   _tprintf( TEXT("<TD ALIGN=LEFT><B>Connection speed</B></TR>\n") );

//----------------- Read event log and process it ---------------------------

    if (ReadEventLog( hEventLog,            // event log handle
                EVENTLOG_FORWARDS_READ |    // reads forward   
                EVENTLOG_SEQUENTIAL_READ,   // sequential read
                0,                          // ignored for sequential reads
                pevlr,                      // address of buffer
                BUFFER_SIZE,                // size of buffer 
                &dwRead,                    // count of bytes read 
                &dwNeeded))                 // bytes in next record 
    {
        while ( dwRead > 0 ) 
        {                           
                                             
             if ( _tcscmp( (LPTSTR) ((LPBYTE) pevlr + sizeof(EVENTLOGRECORD) ),
                            g_szServiceName ) != 0 )
             {
                goto Skip;                  // Skip not our record
             }
                                            // Add all user strings from record
            pString = (LPTSTR) ( (LPBYTE) pevlr + pevlr->StringOffset );
            cStrings = pevlr->NumStrings;
            if (cStrings != 13 )            // Empiric value!
              goto Skip;

            cStringSize = _tcslen( pString );// Skip first element
            pString += cStringSize+1;

            iTemp = pString[0];             // Translate first char to uppercase
            if ( _istlower((short int)iTemp) )
              pString[0] = _toupper(iTemp);
            for (iIndex = 1; iIndex < MAX_USERNAME_LEN; iIndex++)
            {
               iTemp = pString[iIndex];
               if ( _istupper((short int)iTemp) )
                 pString[iIndex] = _tolower(iTemp);
            };

            if (g_iLastIndex == MAX_USERS)   // Prevent overflow
              goto Skip;
                                            // Find matching element
            iCurIndex = 0;
            while ( (iCurIndex < g_iLastIndex) &&
                    (_tcscmp(pString,g_UserStatInfo[iCurIndex].szUserName)) )
            {
               iCurIndex++;
            };

            if ( (iCurIndex == g_iLastIndex) )
            {
              if ( g_fAddNewUser == FALSE )
                goto Skip;                  // Disallow to add new user
              g_iLastIndex++;               // Add new element
              _tcscpy(g_UserStatInfo[iCurIndex].szUserName, pString);
            }   

            _tprintf( TEXT("<TR>") );       // Open table entry 
                                            // User
            _tprintf( TEXT("<TD ALIGN=RIGHT SIZE=20><B> %s </B>"),pString );
                                            // Skip device name
            cStringSize = _tcslen( pString );
            pString += cStringSize+1;
                                            // From (date,time)
            cStringSize = _tcslen( pString );
            pString += cStringSize+1;       
            _tprintf( TEXT("<TD ALIGN=LEFT>%s"),pString );
            cStringSize = _tcslen( pString );
            pString += cStringSize+1;
            _tprintf( TEXT(" %s"),pString );
                                            // To   (date,time)
            cStringSize = _tcslen( pString );
            pString += cStringSize+1;
            _tprintf( TEXT("<TD ALIGN=LEFT>%s"),pString );
            cStringSize = _tcslen( pString );
            pString += cStringSize+1;
            _tprintf( TEXT(" %s"),pString );
                                            // Duration (min,sec)
            cStringSize = _tcslen( pString );
            pString += cStringSize+1;
            _tprintf( TEXT("<TD ALIGN=RIGHT><I>%smin. "),pString );
            dwTempValue = _tcstol(pString,&pTemp,DECIMAL_RADIX); 
            dwTotalMins += dwTempValue;
            g_UserStatInfo[iCurIndex].dwUserMins += dwTempValue;
            cStringSize = _tcslen( pString );
            pString += cStringSize+1;
            dwTempValue = _tcstol(pString,&pTemp,DECIMAL_RADIX); 
            dwTotalSecs += dwTempValue;
            g_UserStatInfo[iCurIndex].dwUserSecs += dwTempValue;
            if ( dwTempValue < DECIMAL_RADIX )
              _tprintf( TEXT("0") );
            _tprintf( TEXT("%ssec.<I>"),pString );
                                            // Sent (bytes)
            cStringSize = _tcslen( pString );
            pString += cStringSize+1;
            _tprintf( TEXT("<TD ALIGN=RIGHT>%s"),pString );
            dwTempValue = _tcstol(pString,&pTemp,DECIMAL_RADIX); 
            dwSentBytesAll += dwTempValue;
            g_UserStatInfo[iCurIndex].dwUserSentBytes += dwTempValue;
                                            // Received (bytes)
            cStringSize = _tcslen( pString );
            pString += cStringSize+1;
            _tprintf( TEXT("<TD ALIGN=RIGHT>%s"),pString );
            dwTempValue = _tcstol(pString,&pTemp,DECIMAL_RADIX); 
            dwRecvdBytesAll += dwTempValue;
            g_UserStatInfo[iCurIndex].dwUserRcvdBytes += dwTempValue;
                                            // Connection (bauds)
            cStringSize = _tcslen( pString );
            pString += cStringSize+1;
            _tprintf( TEXT("<TD ALIGN=RIGHT>%s"),pString );

            _tprintf(TEXT("</TR>\n"));      // Terminate table entry
    
        Skip:                               // Advance pointers
            dwRead -= pevlr->Length;
            pevlr = (EVENTLOGRECORD *) ((LPBYTE) pevlr + pevlr->Length);
        }                                       // while
    }                                       // if

//------------------------------ Write table end ----------------------------

   _tprintf( TEXT("</TABLE>") );

//------------------------------ Write total statistics ---------------------

   _tprintf( TEXT("<P><P><B>Total: ") );
   if ( dwTotalSecs >= SECS_PER_MIN )
   {
      dwTempValue = dwTotalSecs / SECS_PER_MIN;
      dwTotalMins += dwTempValue;
      dwTotalSecs -= (dwTempValue * SECS_PER_MIN);
   }  
   if ( dwTotalMins >= MINS_PER_HOUR )
   {
      dwTempValue = dwTotalMins / MINS_PER_HOUR;
      dwTotalHrs += dwTempValue;
      dwTotalMins -= (dwTempValue * MINS_PER_HOUR);
   }  
   _tprintf( TEXT("%d hr. %02d min. %02d sec."),dwTotalHrs,dwTotalMins,dwTotalSecs );
   _tprintf( TEXT("</B> - <I>%d bytes sent,"),dwSentBytesAll );
   _tprintf( TEXT(" %d bytes received</I><P>\n"),dwRecvdBytesAll );

//------------------------------ Statistics for user  -----------------------

   _tprintf( TEXT("<P><H2><A NAME=%cDETAIL%c>"), QUOTA, QUOTA );
   _tprintf( TEXT("Detail per user:</A></H2><P>\n") );

   _tprintf( TEXT("<TABLE BORDER>") );
   _tprintf( TEXT("<TR>") );
   _tprintf( TEXT("<TR><TD ALIGN=LEFT><B>User</B>") );
   _tprintf( TEXT("<TD ALIGN=LEFT><B>Duration</B>") );
   _tprintf( TEXT("<TD ALIGN=LEFT><B>Sent</B>") );
   _tprintf( TEXT("<TD ALIGN=LEFT><B>Received</B>") );
   _tprintf( TEXT("</TR>\n") );

    for (iIndex = 0; iIndex < g_iLastIndex; iIndex++)
    if  ( _tcslen(g_UserStatInfo[iIndex].szUserName)  &&
          g_UserStatInfo[iIndex].dwUserSentBytes )
    {                                       // Process only good records
       if ( g_UserStatInfo[iIndex].dwUserSecs >= SECS_PER_MIN )
       {
          dwTempValue = g_UserStatInfo[iIndex].dwUserSecs / SECS_PER_MIN;
          g_UserStatInfo[iIndex].dwUserMins += dwTempValue;
          g_UserStatInfo[iIndex].dwUserSecs -= (dwTempValue * SECS_PER_MIN);
       }  
       if ( g_UserStatInfo[iIndex].dwUserMins >= MINS_PER_HOUR )
       {
          dwTempValue = g_UserStatInfo[iIndex].dwUserMins / MINS_PER_HOUR;
          g_UserStatInfo[iIndex].dwUserHrs += dwTempValue;
          g_UserStatInfo[iIndex].dwUserMins -= (dwTempValue * MINS_PER_HOUR);
       }  
       _tprintf( TEXT("<TR>") );
       _tprintf( TEXT("<TD ALIGN=LEFT><B>%s</B>"), g_UserStatInfo[iIndex].szUserName );
       _tprintf( TEXT("<TD ALIGN=RIGHT>") );
       _tprintf( TEXT(" %dhr."), g_UserStatInfo[iIndex].dwUserHrs );
       _tprintf( TEXT(" %dmin."), g_UserStatInfo[iIndex].dwUserMins );
       _tprintf( TEXT(" %dsec"), g_UserStatInfo[iIndex].dwUserSecs );
       _tprintf( TEXT("<TD ALIGN=RIGHT>%d"), g_UserStatInfo[iIndex].dwUserSentBytes );
       _tprintf( TEXT("<TD ALIGN=RIGHT>%d"), g_UserStatInfo[iIndex].dwUserRcvdBytes );
       _tprintf( TEXT("</TR>\n") );
    }

   _tprintf( TEXT("</TABLE>") );


//------------------------------ Write author's copyright  ------------------

   _tprintf( TEXT("<P><HR><H4>Ras2Log  v1.0   (c) 1997 Dmitry Stefankov</H4></BODY></HTML>") );

//------------------------------ Free resources ------------------------------

    CloseEventLog( hEventLog );
    free( pBuffer );

//------------------------------ Exit point ---------------------------------
  Done: 
    ;
}
