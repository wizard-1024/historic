/*****************************************************************************
 *                             File LISTDIR.C
 *
 *            List files in directory  (multi-platform version)
 *
 *   Copyright (c) Dmitry V. Stefankov, 1998-2000. All rights reserved.
 *
 *       This software is distributed under GPL agreement
 *       (See copying file for details).
 *
 *****************************************************************************/
/*
 *   $Source: d:/projects/freeware/c/listdir/RCS/listdir.c $
 *  $RCSfile: listdir.c $
 *   $Author: dstef $
 *     $Date: 2000/01/22 03:06:18 $
 * $Revision: 1.24 $
 *   $Locker: dstef $
 *
 *      $Log: listdir.c $
 *      Revision 1.24  2000/01/22 03:06:18  dstef
 *      Removed _BEOS target
 *
 *      Revision 1.23  2000/01/21 22:53:09  dstef
 *      Added support for new targets
 *
 *      Revision 1.22  2000/01/06 22:48:30  dstef
 *      Added new safe functions strncpy and strncat
 *      Updated version and copyright notice
 *
 *      Revision 1.21  1999/12/31 20:17:40  dstef
 *      Increased buffer size for string operations
 *
 *      Revision 1.20  1999/12/31 18:04:25  dstef
 *      Switched to safe coding style (strncat,strncpy)
 *
 *      Revision 1.19  1999/12/30 22:38:57  dstef
 *      Minor changes
 *
 *      Revision 1.18  1999/12/30 22:37:33  dstef
 *      Added DJGPP compiler support
 *      Added target platform checking
 *
 *      Revision 1.17  1999/03/28 17:43:23  dstef
 *      Changed MASKS_MAX to FMASKS_MAX
 *
 *      Revision 1.16  1999/03/28 15:27:23  dstef
 *      Fixed Y2K problem
 *      Improve filemasks array additions
 *
 *      Revision 1.15  1999/03/28 14:48:00  dstef
 *      More simple code for filemasks
 *
 *      Revision 1.14  1999/03/28 04:31:12  dstef
 *      Added filemasks array instead single filemask
 *
 *      Revision 1.13  1999/03/09 12:44:53  dstef
 *      Added ignorecase in filenames switch
 *
 *      Revision 1.11  1998/11/17 12:36:37  dstef
 *      Minor changes of program header and help
 *
 *      Revision 1.10  1998/11/17 12:05:00  dstef
 *      Updated program description
 *
 *      Revision 1.9  1998/11/17 11:59:26  dstef
 *      Changed order of arguments processing
 *      Updated compile instructions for MS-DOS
 *
 *      Revision 1.8  1998/11/17 11:38:16  dstef
 *      Put under GPL agreement
 *      Updated program help
 *      Changed program version
 *      Updated compile instructions
 *
 *      Revision 1.7  1998/11/04 12:48:28  dstef
 *      Fixed UNIX command line parsing
 *
 *      Revision 1.6  1998/11/02 00:23:47  dstef
 *      Fixed MSVC 1.5 compile bug
 *
 *      Revision 1.5  1998/11/01 01:04:00  dstef
 *      Added RCS marker
 *
 *      Revision 1.4  1998/10/25 02:17:53  dstef
 *      Added support for Microsoft Visual C 1.5
 *      Added compile instructions
 *
 *      Revision 1.3  1998/10/09 22:04:56  dstef
 *      Added POSIX support for Win32 platform
 *      Removed straightforward Win32 implementation
 *
 *      Revision 1.2  1998/10/03 11:33:09  dstef
 *      Added exclude files mask for search
 *
 *      Revision 1.1  1998/10/03 02:19:06  dstef
 *      Initial revision
 *
 *****************************************************************************/



/*-------------------------- Check for platforms ---------------------------*/
#ifndef _MSDOS
#ifndef _WIN32
#ifndef _UNIX
#error Select platform: _MSDOS, _WIN32, _UNIX
#endif                                      /* #ifndef _UNIX */
#endif                                      /* #ifndef _WIN32 */
#endif                                      /* #ifndef _MSDOS */



/*-------------------------- Check for compiler ----------------------------*/
#ifndef _BCC
#ifndef _MSVC
#ifndef _DJGPP
#ifndef _MSVC4
#ifndef _MINGW32
#ifndef _FREEBSD
#ifndef _REDHAT
#error Select complier: _BCC,_MSVC,_DJGPP,_MSVC4,_MINGW32,_BEOS,_FREEBSD,_REDHAT
#endif                                      /* #ifndef _REDHAT */
#endif                                      /* #ifndef _FREEBSD */
#endif                                      /* #ifndef _MINGW32 */
#endif                                      /* #ifndef _MSVC4 */
#endif                                      /* #ifndef _DJGPP */
#endif                                      /* #ifndef _MSVC */
#endif                                      /* #ifndef _BCC */



/*-------------------------- Standard definitions --------------------------*/
#if defined(_WIN32)
#include <windows.h>                        /* WIN32 base definitions */
#endif                                      /* #if defined(_WIN32) */
#include <stdio.h>                          /* I/O standard streams */
#include <stdlib.h>                         /* Miscellaneous common functions */
#if ( (defined(_MSDOS) && !defined(_MSVC)) || defined(_UNIX))
#include <dirent.h>                         /* Posix directory operations */
#endif                                      /* #if ( defined(_MSDOS) || defined(_UNIX)) */
#include <string.h>                         /* String and memory operations */
#include <ctype.h>                          /* Character macros */
#if defined(_MSVC)
#include <dos.h>
#endif                                      /* #if defined(_MSVC) */



/*------------------------------- Description ------------------------------*/
const char  g_ProgramName[]       =   "ListDir";
const char  g_ProgramVersion[]    =   "v1.05";
const char  g_CopyrightNotice[]   =   "Copyright (c) 1998,2000";
const char  g_Author[]            =   "Dmitry Stefankov";



/*------------------------------- Return Codes -----------------------------*/
#define   ERROR_DONE                 0     /* Running is successful        */
#define   ERROR_BAD_PARAMETER        1     /* Bad user supplied parameter  */
#define   ERROR_USER_HELP_OUTPUT   255     /* Output user help message     */



/*----------------------------- Miscellaneous ------------------------------*/
#define   QUOTA                    0x22     /* Quatation mark */
#define   FMASKS_MAX                30       /* Available masks */
#if defined(_MSDOS)
#define   MAX_FILENAME_SIZE        80+1     /* UNIX compatibility */
#else
#define   MAX_FILENAME_SIZE        255+1    /* UNIX compatibility */
#endif                                      /* #if defined(_MSDOS) */
#if (defined(_WIN32) || defined(_MSVC))
#define   DIRMAGIC                  0xDD    /* Borland C compatibilty */
#define   EBADF                     6       /* Bad file number */
#define   ENOMEM                    8       /* Not enough core */
#define   ENOENT                    2       /* No such file or directory*/
#endif                                      /* #if (defined(_WIN32) || defined(_MSVC)) */



/*----------------------------- Structures ---------------------------------*/
#if (defined(_WIN32) || defined(_MSVC))     /* Definitions for POSIX directory operations. */
struct dirent                               /* dirent structure returned by readdir() */
{
#if defined(_MSVC)
    char        d_name[13];                 /* MS-DOS FAT 8+3 name */
#else
    char        d_name[MAX_FILENAME_SIZE];  /* Full filename */
#endif                                      /* #if defined(_MSVC) */
};

typedef struct                              /* DIR type returned by opendir() */
{
/* DIR type returned by opendir().  The first two members cannot
 * be separated, because they make up the DOS DTA structure used
 * by findfirst() and findnext().
 */
#if defined(_MSVC)
    char          _d_reserved[30];          /* reserved part of DTA */
    struct dirent  d_dirent;                /* filename part of DTA */
    char         * d_dirname;               /* Directory name */
#else
    char         * d_dirname;               /* Directory name */
    struct dirent  d_dirent;                /* Copy of filename */
#endif                                      /* #if defined(_MSVC) */
    char           d_first;                 /* First file flag */
    unsigned char  d_magic;                 /* Magic cookie for verifying handle */
#if !defined(_MSVC)
    HANDLE        fileHandle;               /* Win32 classic object */
    WIN32_FIND_DATA  findData;              /* Win32 search structire */
#endif                                      /* #if !defined(_MSVC) */
} DIR;
#endif                                      /* #if defined(_WIN32) || defined(_MSVC)) */

struct  MaskNode
{
    char *   pFilesMask;                    /* Filemask */
};

struct  FileSearchMasks
{
  struct MaskNode    sFileMasks[FMASKS_MAX];
};
typedef  struct FileSearchMasks  * pFileSearchMasks;



/*----------------------------- RCS marker ---------------------------------*/
static char  rcsid[] = "$Id: listdir.c 1.24 2000/01/22 03:06:18 dstef Exp dstef $";



/*----------------------------- Global data --------------------------------*/
int   g_fVerbose                =   0;      /* Verbose output           */
int   g_iDebugLevel             =   0;      /* Debugging level          */
int   g_iRecursiveSearch        =   0;      /* Scan all subdirectories  */
int   g_iPrintFullName          =   0;      /* Print full filename      */
int   g_fIgnoreCaseInFilenames  =   0;      /* Ignore case in filenames */
int   g_iIncFilesMask           =   0;      /* Include to search        */
int   g_iExcFilesMask           =   0;      /* Include to search        */

struct FileSearchMasks    g_sIncFileMasks;
struct FileSearchMasks    g_sExcFileMasks;



/*---------------------------- Error Messages ------------------------------*/
const char  g_szNoMemForExcFMask[]  =
                     "WARNING: insufficient memory for excluding filemask.";
const char  g_szNoMemForIncFMask[]  =
                     "WARNING: insufficient memory for including filemask.";



/*------------------------- Function Prototype -----------------------------*/
unsigned long int ulListDir( char *dirname, int maxdirlen,
                             pFileSearchMasks pIncFMasks,
                             pFileSearchMasks pExcFMasks, int iSearchDirs );
int  iTestDir( char *dirname );
int  iTestPattern( const char * szName, const char * szPattern );
int  iTestForFileMask( char *filename, pFileSearchMasks pFMasks,
                       int iFMasksCount );
int  AddFileMask( const char * pszAddMask, pFileSearchMasks pFMasks,
                  int * piFMasksCount, const char * pszErrMsg );
char *  safe_strncpy ( char *dest, const char *src, size_t maxlen );
char *  safe_strncat( char *dest, const char *src, size_t n );
#if (defined(_WIN32) || defined(_MSVC))
DIR *  opendir( char *dirname );
struct dirent *  readdir( DIR  *dir );
int   closedir( DIR  *dir );
#endif                                      /* #if (defined(_WIN32) || defined(_MSVC)) */



/*****************************************************************************
 *                              --- main ---
 *
 * Purpose: Main program function
 *   Input: int   argc    - argument count
 *          char **argv   - argument list
 *  Output: int           - exit code (see above)
 * Written: by Dmitry V.Stefankov 09-29-1998
 *****************************************************************************/
int main( int argc, char **argv )
{
    int         iArgc;                      /* Arguments number  */
    char       **lpszArgv;                  /* Arguments array   */
    char  szIncSearchDir[MAX_FILENAME_SIZE+1]  = { "\0" };
    char  szIncSearchMask[MAX_FILENAME_SIZE+1] = { "\0" };
    char  szExcSearchMask[MAX_FILENAME_SIZE+1] = { "\0" };
    int         iTemp;                      /* Temporary */
    char        chTemp;                     /* Temporary storage */
    unsigned long int ulFoundFiles = 0;     /* Counter */
    void *      pTemp;                      /* Temporary */

/*-------------------------- Compiler test phase ---------------------------*/
#ifdef  _TEST
#if __STDC__ == 0 && !defined(__cplusplus)
  printf("cc is not ANSI C compliant\n");
  return 0
#else
  if (g_iDebugLevel > 0)
    printf( "%s compiled at %s %s. This statement is at line %d.\n",
            __FILE__, __DATE__, __TIME__, __LINE__);
#endif                                      /* __STDC__ == 0 && !defined(__cplusplus) */
#endif                                      /* #ifdef  _TEST */

/*-------------------------- Pre-initialization ----------------------------*/
  pTemp = (void *)rcsid;                    /* Just to avoid warning */
  for(iTemp=0; iTemp<FMASKS_MAX; iTemp++)
  {
    g_sIncFileMasks.sFileMasks[iTemp].pFilesMask = NULL;
    g_sExcFileMasks.sFileMasks[iTemp].pFilesMask = NULL;
  }

/*-------------------------- Process comand parameters ---------------------*/
    iArgc   = argc;                         /* Copy argument indices */
    lpszArgv = (char **)argv;

  if (iArgc == 1)
  {                                         /* Print on-line help */
     printf( "NAME\n" );
     printf( "  listdir - list directory contents\n" );
     printf( "\n" );
     printf( "SYNOPSIS\n" );
     printf( "   listdir [-d] [[-e mask]..] [-f] [-g] [[-i mask]..] [-s] [-v] [dirname]\n" );
     printf( "\n" );
     printf( "DESCRIPTION\n" );
     printf( "  LISTDIR is used the standard POSIX functions to list the directory contents.\n" );
     printf( "  The options are as follows:\n" );
     printf( "  -d   Debugging level.\n" );
     printf( "  -e mask\n" );
     printf( "       Exclude file(s) for search, wildcards are allowed (upto %d masks).\n", FMASKS_MAX );
     printf( "  -f   Print full filename.\n" );
     printf( "  -g   Ignore case in filename(s).\n" );
     printf( "  -i mask\n" );
     printf( "       Include file(s) for search, wildcards are allowed (upto %d masks).\n", FMASKS_MAX );
     printf( "  -s   Search also subdirectories.\n" );
     printf( "  -v   Verbose output.\n" );
     printf( "  dirname\n" );
     printf( "       Directory name to list.\n" );
     printf( "\n" );
     printf( "HISTORY\n" );
     printf( "  LISTDIR command appeared in October 1998\n" );
     printf( "\n" );
     printf( "AUTHOR\n" );
     printf( "  Dmitry V. Stefankov  (dstef@nsl.ru, dima@mccbn.ru)" );
     return( ERROR_USER_HELP_OUTPUT );
  }
  else
  {
     --iArgc;                               /* Remove program name */
     while (iArgc)
     {
       chTemp = **(++lpszArgv);
       iArgc--;                             /* Remove this argument */
#if defined(_UNIX)
       if ( chTemp == '-' )
#else
       if ( (chTemp == '-') || (chTemp == '/') )
#endif                                      /* #if defined(_UNIX) */
       {
          chTemp = *(++*lpszArgv);          /* Look options */
          switch( chTemp )
          {
                case 'd':
                    g_iDebugLevel = 1;      /* Some debugging */
                    break;
                case 'e':
                    if (iArgc)              /* Exclude files mask */
                    {
                        --iArgc;
                        safe_strncpy( szExcSearchMask, *(++lpszArgv),
                                      sizeof(szExcSearchMask) );
#if defined(_MSDOS)
                        strupr( szExcSearchMask );
#endif                                      /* #if defined(_MSDOS) */
                        iTemp = AddFileMask( szExcSearchMask,
                                             &g_sExcFileMasks,
                                             &g_iExcFilesMask,
                                             g_szNoMemForExcFMask );
                    }
                    break;
                case 'f':
                    g_iPrintFullName = 1;   /* Full filename */
                    break;
                case 'g':                   /* Case-insensitive search for filenames */
                    g_fIgnoreCaseInFilenames = 1;
                    break;
                case 'i':
                    if (iArgc)              /* Include files mask */
                    {
                        --iArgc;
                        safe_strncpy( szIncSearchMask, *(++lpszArgv),
                                      sizeof(szIncSearchMask) );
#if defined(_MSDOS)
                           strupr( szIncSearchMask );
#endif                                      /* #if defined(_MSDOS) */
                           iTemp = AddFileMask( szIncSearchMask,
                                                &g_sIncFileMasks,
                                                &g_iIncFilesMask,
                                                g_szNoMemForIncFMask );
                    }
                    break;
                case 's':                   /* Search subdirectories */
                    g_iRecursiveSearch = 1;
                    break;
                case 'v':
                    g_fVerbose = 1;         /* Verbose output */
                    break;
                default:
                    printf( "ERROR: unknown option: -%s\n", *lpszArgv );
                    return( ERROR_BAD_PARAMETER );
                    /* break; */
          } /*switch*/
       }
       else
       {
           safe_strncpy( szIncSearchDir, *lpszArgv, sizeof(szIncSearchDir) );
       } /*if-else*/
     } /*while*/
  } /*if-else*/

/*--------------------------- Banner message -------------------------------*/
  if (g_fVerbose)
    printf( "%s %s, %s %s\n", g_ProgramName, g_ProgramVersion,
             g_CopyrightNotice,  g_Author );

/*--------------------------- Searches directory ---------------------------*/
   if ( szIncSearchDir[0] == '\0' )
     safe_strncpy( szIncSearchDir, ".", sizeof(szIncSearchDir) );
   if ( szIncSearchMask[0] == '\0' )
   {
     safe_strncpy( szIncSearchMask, "*", sizeof(szIncSearchMask) );
     iTemp = AddFileMask( szIncSearchMask, &g_sIncFileMasks,
                          &g_iIncFilesMask, g_szNoMemForIncFMask );
   }
#if defined(_MSDOS)
   strupr( szIncSearchDir );                /* Convert all to uppercase */
#endif                                      /* #if defined(_MSDOS) */

   if (g_iDebugLevel > 0)
   {
     printf( "Search catalog: %s\n", &szIncSearchDir[0] );
     printf( "Include masks:  " );
     for(iTemp=0; iTemp < g_iIncFilesMask; iTemp++)
     {
       pTemp = g_sIncFileMasks.sFileMasks[iTemp].pFilesMask;
       if (pTemp != NULL)
         printf( "%s ", (char *)pTemp );
     }/*for*/
     printf( "\nExclude masks:  " );
     for(iTemp=0; iTemp < g_iExcFilesMask; iTemp++)
     {
       pTemp = g_sExcFileMasks.sFileMasks[iTemp].pFilesMask;
       if (pTemp != NULL)
         printf( "%s ", (char *)pTemp );
     }/*for*/
     printf( "\n" );
   }

   ulFoundFiles = ulListDir( szIncSearchDir, MAX_FILENAME_SIZE+1,
                             &g_sIncFileMasks, &g_sExcFileMasks,
                             g_iRecursiveSearch);

   printf( "Total found %lu item", ulFoundFiles );
   if (ulFoundFiles != 1)
     printf("s");
   printf("\n");

/*--------------------------- Terminate program  ---------------------------*/
  return 0;
}



/*****************************************************************************
 *                             --- ulListDir ---
 *
 * Purpose: List files in directory
 *   Input: char       *dirname    - directory name
 *          int        maxdirlen   - directory name buffer size (max.)
 *          pFileSearchMasks pIncFMasks - include filemasks array
 *          pFileSearchMasks pExcFMasks - exclude filemasks array
 *          int        iSearchDirs - search subdirectories
 *  Output: unsigned long int      - number of matching found files
 * Written: by Dmitry V.Stefankov 10-03-1998
 *****************************************************************************/
unsigned long int  ulListDir( char *dirname, int maxdirlen,
                              pFileSearchMasks pIncFMasks,
                              pFileSearchMasks pExcFMasks, int iSearchDirs )
{
  unsigned long int  ulFilesCount = 0;      /* Counter */
  char  szTestFName[MAX_FILENAME_SIZE+1];   /* Filename */
  DIR  *dir;                                /* Directory structure */
  struct dirent  *ent;                      /* Directory entry */
  int   fExcThisFile;                       /* Boolean flag */
  int   fIncThisFile;                       /* Boolean flag */
  int   maxlen;                             /* Space size */

/*------------------------ Process directory name --------------------------*/
  if ( g_iPrintFullName == 0 )
     printf( "%s\n", dirname );
  maxlen = strlen(dirname);
#if defined(_UNIX)
  if ( dirname[maxlen-1] != '/' )
    safe_strncat( dirname, "/", maxdirlen );
#else
  if ( dirname[maxlen-1] != '\\' )
    safe_strncat( dirname, "\\", maxdirlen );
#endif                                      /* #if defined(_UNIX) */

/*---------------------------- Open directory  -----------------------------*/
  if ((dir = opendir(dirname)) == NULL)
  {
    printf( "ERROR: Unable to open directory!\n" );
    return 0;                               /* Emergency exit */
  }

/*---------------------- Process directory entries -------------------------*/
  while ((ent = readdir(dir)) != NULL)
  {
    if ( strcmp(ent->d_name,".") && strcmp(ent->d_name,"..") )
    {
      safe_strncpy( szTestFName, dirname, sizeof(szTestFName) );
      safe_strncat( szTestFName, ent->d_name, sizeof(szTestFName) );
      if (g_iDebugLevel > 0)
      {
        printf( "Test Item: %s\n", szTestFName );
      }
      if ( iTestDir(szTestFName) == 1 )
      {
        fExcThisFile = iTestForFileMask( ent->d_name, pExcFMasks,
                                         g_iExcFilesMask );
        if (!fExcThisFile)
        {
          fIncThisFile = iTestForFileMask( ent->d_name, pIncFMasks,
                                           g_iIncFilesMask );
          if ( fIncThisFile )
          {
            if ( g_iPrintFullName )           /* Now print name */
               printf( "%s\n", szTestFName );
            else
               printf( "%s\n", ent->d_name );
            ++ulFilesCount;
          }
        }/*if*/
      }
      else
      {
         if (iSearchDirs)                   /* Have we look more? */
            ulFilesCount += ulListDir( szTestFName, maxdirlen, pIncFMasks,
                                       pExcFMasks, iSearchDirs);
      }/*if-else*/
    }/*if*/
  }/*while*/

/*------------------------ Close a directory --------------------------------*/
  if ( closedir(dir) != 0 )
      printf( "ERROR: Unable to close directory!\n" );

  return( ulFilesCount );
}



/*****************************************************************************
 *                            --- iTestDir ---
 *
 * Purpose: Tests for the valid directory name
 *   Input: char *dirname - directory name to test
 *  Output: int           - 0 this is directory
 *                          1 thie is not directory
 * Written: by Dmitry V.Stefankov 10-03-1998
 *****************************************************************************/
int  iTestDir( char *dirname )
{
  DIR   *dir;                               /* Directory structure */

  if ( (dir = opendir(dirname)) == NULL )
  {
      return(1);                            /* This is not directory */
  }
  if ( closedir(dir) != 0 )
      printf( "ERROR: Unable to close directory during testing!\n" );
  return(0);                                /* Yes, directory found. */
}



/*****************************************************************************
 *                          --- iTestPattern ---
 *
 * Purpose: Tests a string for matching pattern
 *   Input: const char * szName    - testing string
 *          const char * szPattern - testing pattern (wildcards allowed)
 *  Output: int                    - 0 mismatched string
 *                                   any other matching string
 * Written: by Dmitry V.Stefankov 10-03-1998
 *****************************************************************************/
int  iTestPattern( const char * szName, const char * szPattern )
{
    int iRetcode = 0;                       /* Default = string mismatch */
    int iMatch;                             /* Matching character */
    char chLeft;                            /* Test character from left */
    char chRight;                           /* Test character from right */

    if ( (szName == NULL) || (szPattern == NULL) )
      return iRetcode;                      /* Empty strings not allowed! */

    switch ( *szPattern )                   /* Current pattern symbol */
    {
      case '*':                             /* Any string */
        szPattern++;
        do {
            iRetcode = iTestPattern( szName, szPattern );
        } while (!iRetcode && *szName++);
        break;
      case '?':                             /* Any character */
        if ( *szName )
          iRetcode = iTestPattern( ++szName, ++szPattern );
        break;
      case '\0':                            /* End of pattern */
        iRetcode = !strlen(szName);
        break;
      default:                              /* Any other character */
        chLeft  = *szName;
        chRight = *szPattern;
        if ( (g_fIgnoreCaseInFilenames) && isalpha(chLeft)
               && isalpha(chRight) )
          iMatch = ( tolower(chLeft) == tolower(chRight) );
        else
          iMatch = (chLeft == chRight);
          if ( iMatch )
            iRetcode = iTestPattern( ++szName, ++szPattern );
        break;
    }
    return( iRetcode );
}



/*****************************************************************************
 *                         --- iTestForFileMask ---
 *
 * Purpose: Test filename for match filemasks
 *   Input: char           *filename - file name
 *          pFileSearchMasks pFMasks - filemasks array
 *          int         iFMasksCount - filemasks array dimension
 *  Output: int                      - 0 matching not found
 *                                     1 matching found
 * Written: by Dmitry V.Stefankov 03-28-1999
 *****************************************************************************/
int  iTestForFileMask( char *filename, pFileSearchMasks pFMasks,
                       int iFMasksCount )
{
  int           iRetCode = 0;               /* Default = matching not found */
  int           iTemp;                      /* Temporary index */
  char         *pTemp;                      /* Temporary string */

  if ( (iFMasksCount) && (pFMasks != NULL) && (filename != NULL) )
  {
    for(iTemp=0; iTemp<iFMasksCount; iTemp++)
    {
      pTemp = pFMasks->sFileMasks[iTemp].pFilesMask;
      if (pTemp != NULL)
      {
        iRetCode = iTestPattern( filename, pTemp );
        if (iRetCode)
          break;                            /* Stop looking */
      }
    }/*for*/
  }/*if*/

  return( iRetCode );
}



/*****************************************************************************
 *                         --- AddFileMask ---
 *
 * Purpose: Add filemask to filemasks array
 *   Input: const char *  pszAddMask - filemask to add to array
 *          pFileSearchMasks pFMasks - filemasks array
 *          int         iFMasksCount - filemasks array dimension
 *          const char *   pszErrMsg - error message
 *  Output: int                      - 0 success
 *                                     1 failure
 * Written: by Dmitry V.Stefankov 03-28-1999
 *****************************************************************************/
int  AddFileMask( const char * pszAddMask, pFileSearchMasks pFMasks,
                  int * piFMasksCount, const char * pszErrMsg )
{
  int           iRetCode = 1;               /* Default = fail */
  char          * pTemp;                    /* Temporary string */

  if ( (*piFMasksCount < FMASKS_MAX) && (pFMasks != NULL) &&
       (pszAddMask != NULL) )
  {
     pTemp = (char *)malloc( strlen(pszAddMask)+1 );
     if (pTemp != NULL)
     {
       safe_strncpy( (char *)pTemp, pszAddMask, strlen(pszAddMask)+1 );
       pFMasks->sFileMasks[*piFMasksCount].pFilesMask = pTemp;
       (*piFMasksCount)++;
       iRetCode = 0;
     }
     else
     {
       if (pszErrMsg)
         printf( "%s\n", pszErrMsg );
     }/*if-else*/
  }/*if*/

  return( iRetCode );
}



/*****************************************************************************
 *                          --- safe_strncpy ---
 *
 * Purpose: Make a safe copy of one string to another
 *   Input: char       *dest - destination buffer (string)
 *          const char *src  - source string
 *          size_t     n     - maximum size of destination buffer (string)
 *  Output: char *           - destination string
 * Written: by Dmitry V.Stefankov 06-Jan-2000
 ****************************************************************************/
char *  safe_strncpy ( char *dest, const char *src, size_t n )
{
    char          * s;                      /* Temporary  */

    for( s = dest; 0 < (n-1) && *src!= '\0'; --n )
         *s++ = *src++;                     /* Copy at most n-1 chars */

    for( ; 0 < n; --n )
         *s++ = '\0';                       /* Padding */

    return( dest );
}



/*****************************************************************************
 *                          --- safe_strncat ---
 *
 * Purpose: Make a safe concatenation of two strings
 *   Input: char       *dest - destination buffer (string)
 *          const char *src  - source string
 *          size_t     n     - maximum size of destination buffer (string)
 *  Output: char *           - destination string
 * Written: by Dmitry V.Stefankov 06-Jan-2000
 ****************************************************************************/
char *  safe_strncat( char *dest, const char *src, size_t n )
{
    char          * s;                      /* Temporary  */

    for( s = dest; *s != '\0'; ++s)         /* Find end of dest */
        ;

    for( ; 0 < (n-1) && *src != '\0'; --n )
        *s++ = *src++;                      /* Copy at most n-1 chars */

    *s = '\0';

    return( dest );
}



#if (defined(_WIN32) || defined(_MSVC))
/*****************************************************************************
 *                         --- opendir ---
 *
 * Purpose: open a directory stream
 *   Input: char  * dirname     - directory name
 *  Output: DIR *               - directory structure (POSIX.1)
 * Written: by Dmitry V.Stefankov 10-07-1998
 *****************************************************************************/
DIR *  opendir( char  * dirname )
{
   char    *name;                           /* Copy of directory name */
   DIR     *dir;                            /* Directory structure */
   int     len;                             /* Temporary */
   int     maxlen;                          /* Space size */
   
   /*
    * Allocate space for a copy of the directory name, plus
    * room for the "*.*" we will concatenate to the end.
    */

   len = strlen( dirname );
   maxlen = len+5-1;
   if ((name = (char *)malloc(maxlen+1)) == NULL)
   {
      errno = ENOMEM;
      return (NULL);
   }

   safe_strncpy( name, dirname, maxlen );
   if (len-- && name[len] != ':' && name[len] != '\\' && name[len] != '/')
#if defined(_MSVC)
      safe_strncat( name, "\\*.*", maxlen+1 );
   else
      safe_strncat( name, "*.*", maxlen+1 );   
#else   
      safe_strncat( name, "\\*", maxlen+1 );
   else
      safe_strncat( name, "*", maxlen+1 );
#endif                                      /* #if defined(_MSVC) */
                                             
   if ((dir = (DIR *)malloc(sizeof(DIR))) == NULL) /* Allocate space for a DIR structure */
   {
       errno = ENOMEM;
       free(name);
       return (NULL);
   }
#if defined(_MSVC)
    /* Search for the first file to see if the directory exists,
     * and to set up the DTA for future _dos_findnext() calls.
     */
    if (_dos_findfirst(name, _A_HIDDEN|_A_SYSTEM|_A_RDONLY|_A_SUBDIR,
                (struct find_t *)&dir->_d_reserved) != 0)     
#else                                            /* Search for first entry */
   dir->fileHandle = FindFirstFile( name, &dir->findData );
   if ( dir->fileHandle == INVALID_HANDLE_VALUE )
#endif                                      /* #if defined(_MSVC) */   
   {
#if !defined(_MSVC)   
      errno = ENOENT;                       /* I no hope that FindFirstFile */
#endif                                      /* #if !defined(_MSVC) */      
      free(name);                           /* sets errno for us */
      free(dir);
      return (NULL);
   }
   /*
    * Everything is OK.  Save information in the DIR structure, return it.
    */
   dir->d_dirname = name;
   dir->d_first = 1;
   dir->d_magic = DIRMAGIC;
#if !defined(_MSVC)                         /* Make a copy */
   safe_strncpy( dir->d_dirent.d_name, dir->findData.cFileName, 
                 sizeof(dir->d_dirent.d_name) ); 
#endif                                      /* #if !defined(_MSVC) */

   return dir;
}



/*****************************************************************************
 *                         --- readdir ---
 *
 * Purpose: read directory entry from a directory stream
 *   Input: DIR *            - directory structure (POSIX.1)
 *  Output: struct dirent *  - pointer to directory entry (POSIX.1)   
 * Written: by Dmitry V.Stefankov 10-07-1998
 *****************************************************************************/
struct dirent *  readdir( DIR  *dir )
{

   if (dir->d_magic != DIRMAGIC)            /* Verify the handle.*/
   {
      errno = EBADF;                        /* Bad handle */
      return (NULL);
   }

   /*
    * If this isn't the first file, call findnextfile(...) to get the next
    * directory entry.  Opendir() fetches the first one.
    */
   if (!dir->d_first)
   {
#if defined(_MSVC)
      if (_dos_findnext((struct find_t *)&dir->_d_reserved) != 0) 
#else   
      if ( !FindNextFile(dir->fileHandle, &dir->findData) )
#endif                                      /* #if defined(_MSVC) */      
         return NULL;
#if !defined(_MSVC)         
      safe_strncpy( dir->d_dirent.d_name, dir->findData.cFileName, 
                    sizeof(dir->d_dirent.d_name) );
#endif                                      /* #if !defined(_MSVC) */      
   }

   dir->d_first = 0;                        /* Clear first call flag */
   
   return( &dir->d_dirent );                /* Just return a first element copy */
}



/*****************************************************************************
 *                         --- closedir ---
 *
 * Purpose: close directory stream
 *   Input: DIR *   - directory structure (POSIX.1)
 *  Output: int     - 0   successful
 *                    -1  bad directory structure
 * Written: by Dmitry V.Stefankov 10-07-1998
 *****************************************************************************/
int  closedir (DIR  *dir)
{
    if (dir == NULL || dir->d_magic != DIRMAGIC)
    {                                       /* Wrong structure on entry */
       errno = EBADF;
       return(-1);
    }

    dir->d_magic = 0;                       /* Prevent use after closing */
#if !defined(_MSVC)    
    FindClose( dir->fileHandle );           /* Clean up Win32 space */
#endif                                      /* #if !defined(_MSVC) */    
    free(dir->d_dirname);
    free(dir);
    
    return 0;
}
#endif                                      /* #if defined(_WIN32) */
