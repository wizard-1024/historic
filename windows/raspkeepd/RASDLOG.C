//****************************************************************************
//                            File RASDLOG.C
//
//   Read eventlog for Remote Access Service (RAS) Connection Keep Service
//
//      Copyright (c) Dmitry V. Stefankov, 1997. All rights reserved.
//
//****************************************************************************
//
//   $Source: F:/MSVC20/SOURCE/RASKEEPD/RCS/rasdlog.c $
//  $RCSfile: rasdlog.c $
//   $Author: dstef $
//     $Date: 1998/10/03 13:50:00 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: rasdlog.c $
//      Revision 1.1  1998/10/03 13:50:00  dstef
//      Initial revision
//
//
//****************************************************************************



//---------------------------- Standard files --------------------------------

#include "compile.h"                        // Compilation switches

#include <windows.h>                        // Windows definitions
#include <stdio.h>                          // I/O library
#include <stdlib.h>                         // Default library
#include <time.h>                           // Time/date
#include <tchar.h>                          // Unicode


//--------------------------- Private definitions ---------------------------

#define   QUOTA             0x22
#define   BUFFER_SIZE       1024*64*16*2     // 2 Megabytes


//---------------------- Author, Copyright, Version --------------------------

const  TCHAR  g_szVersion[]           =  TEXT("v1.0");
const  TCHAR  g_szCopyright[]         =  TEXT("Copyright (c) 1997");
const  TCHAR  g_szAuthor[]            =  TEXT("Dmitry Stefankov");


//---------------------------- Private data ---------------------------------

const  TCHAR  g_szAppName[]          =  TEXT("RasDLog");
const  TCHAR  g_szKeyPath[]          =  TEXT("Application");
//TEXT("HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\EventLog\\Application");
const  TCHAR  g_szServiceName[]      =  TEXT("RasKeepService");
const  TCHAR  g_szComputerName[]     =  TEXT("computer:");
TCHAR  g_szRemoteComputerName[256]   =  TEXT("");



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
    HINSTANCE           hMessageFile;       // Resource file
    HANDLE              hEventLog;          // Application eventlog file
    EVENTLOGRECORD      *pevlr;             // Eventlog structure
    //BYTE              bBuffer[BUFFER_SIZE];// Data buffer
    PVOID               pBuffer;            // Buffer pointer
    TCHAR               bFormatBuffer[512]; // Message format buffer
    DWORD               dwRead = 0;         // Bytes read from eventlog
    DWORD               dwNeeded = 0;       // Bytes need at next reading
    DWORD               cRecords = 0;       // Number of records in eventlog
    DWORD               dwThisRecord = 0;   // Number record
    DWORD               cStrings;           // Number of strings in one record
    DWORD               cStringSize;        // String length
    TCHAR               *pString;           // Temporary pointer
    TCHAR               *pTempChar;         // Temporary pointer
    time_t              tTime;              // Time written in record
    DWORD               dwFormatChars;      // Format
    DWORD               dwArgc;             // Arguments number
    LPTSTR              *lpszArgv;          // Arguments array


//----------------------- Look parameters ----------------------------------

#ifdef UNICODE
    lpszArgv = (LPTSTR *)CommandLineToArgvW( GetCommandLineW(), &dwArgc );
#else
    dwArgc   = (DWORD) argc;
    lpszArgv = argv;
#endif

    if ( (dwArgc > 1) &&
         ((*lpszArgv[1] == '-') || (*lpszArgv[1] == '/')) )
    {
            if ( (_tcsstr(lpszArgv[1],g_szComputerName) != NULL) )
            {     
               _tcscpy( g_szRemoteComputerName, lpszArgv[1]+_tcslen(g_szComputerName)+1 );
            }
        else if ( _tcsicmp( TEXT("?"), lpszArgv[1]+1 ) == 0 )
        {
          _tprintf( TEXT("Ras Daemon EventLog Dump %s, %s %s\n"),
                   g_szVersion, g_szCopyright, g_szAuthor );
         _tprintf( TEXT("Release date:  %s\n"), TEXT(__DATE__) );
         _tprintf( TEXT("Release time:  %s\n"), TEXT(__TIME__) );
         _tprintf( TEXT("USAGE:\n") );
         _tprintf( TEXT("%s  [-%sUNC_computername]\n"),
                   g_szAppName, g_szComputerName );
        exit(0);
        }
        else
        {
          // Nothing.
        }
    }

//----------------------- Allocate buufer ----------------------------------

    pBuffer = malloc(BUFFER_SIZE);
    if ( pBuffer == NULL )
    {
      _tprintf( TEXT("ERROR: cannot allocate memory!") );
      goto Done;
    }

//----------------------- Load message file --------------------------------

    hMessageFile = LoadLibraryEx( TEXT("RasKeepD.exe"),     // Module name
                                  NULL,                     // Reserved
                                  DONT_RESOLVE_DLL_REFERENCES || 
                                  LOAD_LIBRARY_AS_DATAFILE);// How to load
    if ( hMessageFile == NULL )
    {
      _tprintf( TEXT("ERROR: cannot load message file!") );
      goto Done;
    }

//---------------------------- Open the Application log ---------------------

    hEventLog = OpenEventLog( 
                    g_szRemoteComputerName, // Computer (local or remote)
                    (LPCTSTR)g_szKeyPath);  // Source name

    if ( hEventLog == NULL )
    {
       _tprintf( TEXT("ERROR: could not open Application event log") );
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

   _tprintf( TEXT("<HTML><HEAD><TITLE>RAS Connection Keep Daemon</TITLE></HEAD>\n") );
   _tprintf( TEXT("<BODY><H1>RAS Connection Keep Daemon</H1><P>\n"));
   _tprintf( TEXT("<UL><LI><A HREF=%c#Total%c>Total Statistics</A></LI>\n"),QUOTA,QUOTA );
   _tprintf( TEXT("</UL><P><H2><A NAME=%cTOTAL%c>Total Statistics</A></H2>\n"),QUOTA,QUOTA );

//----------------- Write HTML table beginning ------------------------------

   _tprintf( TEXT("<TABLE BORDER>") );
   _tprintf( TEXT("<TR><TD ALIGN=LEFT><B>Event time</B>") );
   _tprintf( TEXT("<TD ALIGN=LEFT><B>Type</B>") );
   _tprintf( TEXT("<TD ALIGN=LEFT><B>Text description</B></TR>\n") );

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

             if ( pevlr->EventID == 0x00020005 )
             {
                goto Skip;                  // Skip dial record
             }
        
            tTime = pevlr->TimeWritten;     // Convert time
#ifdef _UNICODE
            pString = _wctime( &tTime );
#else
            pString = ctime( &tTime );
#endif                                      // #ifdef _UNICODE

            pTempChar = _tcschr( pString, TEXT('\n') );
            if (pTempChar != NULL)
            {
              *pTempChar = TEXT('\0');      // Replace CR
            }

//---------------------- Write event type -----------------------------------

            _tprintf( TEXT("<TR><TD ALIGN=RIGHT SIZE=45><I> %s </I>"),pString );
            _tprintf( TEXT("<TD ALIGN=RIGHT>") );
            switch ( pevlr->EventType)
            {
               case EVENTLOG_AUDIT_SUCCESS  :
                       _tcscpy( &bFormatBuffer[0], TEXT("succ") );
                       break;
               case EVENTLOG_INFORMATION_TYPE   :
                       _tcscpy( &bFormatBuffer[0], TEXT("info") );
                       break;
               case EVENTLOG_WARNING_TYPE:
                       _tcscpy( &bFormatBuffer[0], TEXT("WARN") );
                       break;
               case EVENTLOG_ERROR_TYPE:
                       _tcscpy( &bFormatBuffer[0], TEXT("ERR") );
                       break;
               default:         
                       _tcscpy( &bFormatBuffer[0], TEXT("UNKW") );
                       break;
            }
            _tprintf( TEXT("<B>%s <B>"),bFormatBuffer );

//------------------------ Write event text ---------------------------------

            _tprintf( TEXT("<TD ALIGN=LEFT>") );
            dwFormatChars = FormatMessage(
                FORMAT_MESSAGE_FROM_HMODULE, // source and processing options 
                               hMessageFile, // address of  message source 
                             pevlr->EventID, // requested message identifier 
                                          0, // language identifier for requested message
                          &bFormatBuffer[0], // address of message buffer 
                      sizeof(bFormatBuffer), // maximum size of message buffer 
                                        NULL // address of array of message inserts 
                    );
            if ( dwFormatChars > 0 )
            {
               pTempChar = _tcschr( pString, TEXT('\n') );
               if (pTempChar != NULL)
               {
                  *pTempChar = TEXT('\0');  // Replace CR
               }
              _tprintf( TEXT("%s "),bFormatBuffer);
            }
                                            // Add all user strings from record
            pString = (LPTSTR) ( (LPBYTE) pevlr + pevlr->StringOffset );
            cStrings = pevlr->NumStrings;
            while ( cStrings > 0 )
            {
              _tprintf( TEXT("%s "),pString);
              cStringSize = _tcslen( pString );
              pString += cStringSize+1;
              cStrings--;
            }
            _tprintf(TEXT("</TR>"));        // Terminate table entry
        
        Skip:                               // Advance pointers
            dwRead -= pevlr->Length;
            pevlr = (EVENTLOGRECORD *) ((LPBYTE) pevlr + pevlr->Length);
      }                                     // while
    }                                       // if

//------------------------------ Write table end ----------------------------

   _tprintf( TEXT("</TABLE>") );
   _tprintf( TEXT("<P><HR><H4>LogRasKeepD  v1.0   (c) 1997 Dmitry Stefankov</H4></BODY></HTML>") );

//------------------------------ Free resources ------------------------------

    CloseEventLog( hEventLog );
    FreeLibrary( hMessageFile );
    free( pBuffer );

//------------------------------ Exit point ---------------------------------
  Done: 
    ;
}
