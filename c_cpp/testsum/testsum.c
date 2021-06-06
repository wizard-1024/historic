/*****************************************************************************
 *                             File TESTSUM.C
 *
 *       Generate and test checksums (CRC-16,CRC-32,MD5,SHA-1) for files 
 *              (multi-platform version)
 *
 *      Copyright (c) Dmitry V. Stefankov, 1998-2003. All rights reserved.
 *
 *       This software is distributed under GPL agreement
 *       (See copying file for details).
 *
 *****************************************************************************/
/*
 *   $Source: d:/projects/freeware/c/testsum/RCS/testsum.c $
 *  $RCSfile: testsum.c $
 *   $Author: dstef $
 *     $Date: 2003/02/05 21:03:20 $
 * $Revision: 1.35 $
 *   $Locker: dstef $
 *
 *      $Log: testsum.c $
 *      Revision 1.35  2003/02/05 21:03:20  dstef
 *      Changed version of program
 *
 *      Revision 1.34  2003/02/05 21:00:43  dstef
 *      No more default algorithm
 *      Added test checksum file for MD5 and SHA-1
 *      Added notes about SHA-1 code authors
 *      Some minor fixes
 *
 *      Revision 1.33  2003/02/05 04:29:57  dstef
 *      Added SHA-1 hash algorithm support
 *      Minor fixes for text, definitions and other
 *
 *      Revision 1.32  2000/01/21 20:48:09  dstef
 *      Added RedHat Linux target
 *
 *      Revision 1.31  2000/01/21 20:21:48  dstef
 *      Removed checking for arguments
 *
 *      Revision 1.30  2000/01/19 22:33:22  dstef
 *      Fixed unsigned int size for 32-bit platforms (Win32,UNIX)
 *
 *      Revision 1.29  2000/01/19 19:56:34  dstef
 *      Added switch -4 to use CRC-16 and CRC-32 together
 *      Changed program help and version
 *
 *      Revision 1.28  2000/01/19 18:25:36  dstef
 *      Moved compile instructions into file <build.txt>
 *      Fixed selection of target platform/compiler
 *
 *      Revision 1.27  2000/01/17 07:58:49  dstef
 *      Fixed minor bugs for most platforms.
 *      Added support for MINGW32 compiler (WIN32 platform).
 *
 *      Revision 1.26  2000/01/06 22:07:23  dstef
 *      Minor changes
 *
 *      Revision 1.25  2000/01/06 21:58:54  dstef
 *      Minor changes
 *
 *      Revision 1.24  2000/01/06 18:34:53  dstef
 *      Added FreeBSD 3.3 as tested platform
 *
 *      Revision 1.23  2000/01/06 18:26:42  dstef
 *      Added new safe functions strncpy and strncat
 *
 *      Revision 1.22  1999/12/31 20:16:27  dstef
 *      Increased buffer size by 1 for string operations
 *
 *      Revision 1.21  1999/12/31 17:26:48  dstef
 *      Removed usable code like null string assignment
 *
 *      Revision 1.20  1999/12/31 16:43:04  dstef
 *      Minor changes
 *
 *      Revision 1.19  1999/12/31 14:33:02  dstef
 *      Changed file description (minor)
 *
 *      Revision 1.18  1999/12/31 14:23:44  dstef
 *      Safe coding (strcat,strcpy chaged to strncat,strncpy)
 *
 *      Revision 1.17  1999/12/30 23:27:27  dstef
 *      Added DJGPP compiler support
 *      Added target platform checking
 *
 *      Revision 1.16  1999/11/17 02:00:57  dstef
 *      Added BeOS support by Sergej Sagalovich
 *      Fixed typecast problems
 *
 *      Revision 1.15  1999/04/06 02:21:37  dstef
 *      Set default action to generate CRC sums
 *      Added default logfile name to both actions (create and test)
 *      Some minor fixes
 *
 *      Revision 1.14  1999/03/28 17:27:54  dstef
 *      Fixed Y2K problem
 *      Added filemasks array instead single filemask
 *
 *      Revision 1.13  1999/03/09 12:31:31  dstef
 *      Added ignore case in filename switch
 *
 *      Revision 1.12  1998/11/17 12:39:14  dstef
 *      Minor changes of program help
 *
 *      Revision 1.11  1998/11/17 12:07:17  dstef
 *      Changed program description in header
 *
 *      Revision 1.10  1998/11/17 11:56:18  dstef
 *      Updated compile instructions
 *      Put under GPL agreement
 *      Updated program help
 *      Changed program version
 *
 *      Revision 1.9  1998/11/03 23:55:49  dstef
 *      Changed algorithm of output
 *
 *      Revision 1.8  1998/11/02 00:38:55  dstef
 *      Fixed MSVC 1.5 compile bug
 *
 *      Revision 1.7  1998/11/01 01:04:52  dstef
 *      Added RCS marker
 *
 *      Revision 1.6  1998/10/25 02:05:32  dstef
 *      Added support for Microsoft Visual C v1.5
 *
 *      Revision 1.5  1998/10/11 15:25:01  dstef
 *      Added compile instructions
 *      Changed program version
 *
 *      Revision 1.4  1998/10/11 15:14:11  dstef
 *      Updated verbose output
 *      Added calculations retry
 *      Added file existing check
 *      Removed unneccessary warnings
 *
 *      Revision 1.3  1998/10/09 22:09:44  dstef
 *      Minor changes
 *
 *      Revision 1.2  1998/10/08 01:29:58  dstef
 *      Added POSIX support for Win32 platform
 *
 *      Revision 1.1  1998/10/07 15:09:47  dstef
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
#error Select complier: _BCC,_MSVC,_DJGPP,_MSVC4,_MINGW32,_BEOS,_FREEBSD,_REDHAT,_WATCOM
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
#if ( (defined(_MSDOS) && !defined(_MSVC)) || defined(_UNIX) )
#include <dirent.h>                         /* Posix directory operations */
#endif                                      /* #if ( defined(_MSDOS) || defined(_UNIX) ) */
#include <string.h>                         /* String and memory operations */
#include <ctype.h>                          /* Character macros */
#if defined(_MSVC)
#include <dos.h>
#endif                                      /* #if defined(_MSVC) */




/*------------------------------- Description ------------------------------*/
const char  g_ProgramName[]       =   "TestSum";
const char  g_ProgramVersion[]    =   "v1.35";
const char  g_CopyrightNotice[]   =   "Copyright (c) 1998,2003";
const char  g_Author[]            =   "Dmitry Stefankov";



/*------------------------------- Return Codes -----------------------------*/
#define   ERROR_DONE                 0     /* Running is successful        */
#define   ERROR_BAD_PARAMETER        1     /* Bad user supplied parameter  */
#define   ERROR_CANNOT_USE_THEM      2     /* Cannot used together         */
#define   ERROR_LOGFILE_NOT_FOUND    3     /* Missed logfile               */
#define   ERROR_LOGFILE_CREAT_FAIL   4     /* Failed logfile creating      */
#define   ERROR_NO_CRC_METHOD        5     /* Missed CRC method to sum     */
#define   ERROR_LOGFILE_OPEN_FAIL    6     /* Failed logfile open          */
#define   ERROR_NO_ACTION            7     /* No option to act             */
#define   ERROR_RESFILE_CREAT_FAIL   8     /* Failed results file creatine */
#define   ERROR_USER_HELP_OUTPUT   255     /* Output user help message     */



/*----------------------------- Miscellaneous ------------------------------*/
#define   QUOTA                    0x22     /* Quatation mark */
#define   FMASKS_MAX               30       /* Available masks */
#if defined(_MSDOS)
#define   MAX_FILENAME_SIZE        80+1     /* UNIX compatibility */
#else
#define   MAX_FILENAME_SIZE        255+1    /* UNIX compatibility */
#endif                                      /* #if defined(_MSDOS) */
#define   MAX_CRC_TABLE_SIZE       256      /* 8*32 */
#define   CRC32_POLYNOMIAL      0xEDB88320L /* PKZIP compatible */
#define   CRC16_POLYNOMIAL         0x1021   /* XMODEM compatible */
#define   BITS_PER_BYTE            8        /* One byte has eight bits */
#if defined(_BCC)
#define   MAX_FILEBUF_SIZE         3072     /* Workaround for ml,mh,mc */
#else
#define   MAX_FILEBUF_SIZE         16384    /* File operations buffer */
#endif                                      /* #if defined(_BCC) */
#define   MAX_LINE_SIZE            1024     /* Working buffer */
#define   HEX_RADIX                16       /* Hexadecimal */
#define   MAX_OUT_LINE_SIZE        512      /* Working buffer */
#define   WORK_LINE_SIZE           256      /* Working buffer */
#define   MAX_CRC_TIMES            1024     /* Calculation factor */
#define   DIGEST_BUF_SIZE          16       /* Digest buffer size */
#if (defined(_WIN32) || defined(_MSVC))
#define   DIRMAGIC                  0xDD    /* Borland C compatibilty */
#define   EBADF                     6       /* Bad file number */
#define   ENOMEM                    8       /* Not enough core */
#define   ENOENT                    2       /* No such file or directory*/
#endif                                      /* #if (defined(_WIN32) || defined(_MSVC)) */



/*--------------------------- MD5 definitions ------------------------------*/
#define _MD5STRSAVE_WORKAROUND	1

typedef unsigned long int   uint32;
typedef struct { unsigned char  md5sig[DIGEST_BUF_SIZE]; }  md5buf;
typedef md5buf * pmd5buf;

struct MD5Context {
        uint32 buf[4];
        uint32 bits[2];
        unsigned char in[64];
};

typedef struct MD5Context MD5_CTX;

/* The four core functions - F1 is optimized somewhat */

/* #define F1(x, y, z) (x & y | ~x & z) */
#define F1(x, y, z) (z ^ (x & (y ^ z)))
#define F2(x, y, z) F1(z, x, y)
#define F3(x, y, z) (x ^ y ^ z)
#define F4(x, y, z) (y ^ (x | ~z))

/* This is the central step in the MD5 algorithm. */
#define MD5STEP(f, w, x, y, z, data, s) \
	( w += f(x, y, z) + data,  w = w<<s | w>>(32-s),  w += x )



/*-------------------------- SHA-1 definitions ------------------------------*/
#define _SHA1HANDSOFF	1

typedef struct {
    unsigned long state[5];
    unsigned long count[2];
    unsigned char buffer[64];
#if  _SHA1HANDSOFF	
	unsigned char workspace[64];
#endif						
} SHA1_CTX;

#define	SHA1_RESULTLEN	(160/8)

#define rol(value, bits) (((value) << (bits)) | ((value) >> (32 - (bits))))

/* blk0() and blk() perform the initial expand. */
#define blk0(i) (block->l[i] = (rol(block->l[i],24)&0xFF00FF00) \
    |(rol(block->l[i],8)&0x00FF00FF))
#define blk(i) (block->l[i&15] = rol(block->l[(i+13)&15]^block->l[(i+8)&15] \
    ^block->l[(i+2)&15]^block->l[i&15],1))

/* (R0+R1), R2, R3, R4 are the different operations used in SHA1 */
#define R0(v,w,x,y,z,i) z+=((w&(x^y))^y)+blk0(i)+0x5A827999+rol(v,5);w=rol(w,30);
#define R1(v,w,x,y,z,i) z+=((w&(x^y))^y)+blk(i)+0x5A827999+rol(v,5);w=rol(w,30);
#define R2(v,w,x,y,z,i) z+=(w^x^y)+blk(i)+0x6ED9EBA1+rol(v,5);w=rol(w,30);
#define R3(v,w,x,y,z,i) z+=(((w|x)&y)|(w&x))+blk(i)+0x8F1BBCDC+rol(v,5);w=rol(w,30);
#define R4(v,w,x,y,z,i) z+=(w^x^y)+blk(i)+0xCA62C1D6+rol(v,5);w=rol(w,30);



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
#endif                                      /* #if defined(_WIN32) */

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
static char  rcsid[] = "$Id: testsum.c 1.35 2003/02/05 21:03:20 dstef Exp dstef $";



/*----------------------------- Global data --------------------------------*/
unsigned long  int g_TableCRC32[MAX_CRC_TABLE_SIZE];
unsigned int       g_TableCRC16[MAX_CRC_TABLE_SIZE];

int   g_fVerbose                =   0;      /* Verbose output             */
int   g_iDebugLevel             =   0;      /* Debugging level            */
int   g_fRecursiveSearch        =   0;      /* Scan all subdirectories    */
int   g_fCreateCrcLog           =   1;      /* Add CRC sums to logfile    */
int   g_fTestCrcLog             =   0;      /* Test CRC sums from logfile */
int   g_fCRC16                  =   0;      /* Use CRC-16 algorithm       */
int   g_fCRC32                  =   0;      /* Use CRC-32 algorithm       */
int   g_fMD5                    =   0;      /* Use MD5 algorithm          */
int   g_fSHA1                   =   0;      /* Use SHA-1 algorithm        */
int   g_fPrintBadCRC            =   0;      /* Print only failed CRC files*/
int   g_iRetryCountCRC          =   1;      /* How many times count CRC   */
int   g_fIgnoreCaseInFilenames  =   0;      /* Ignore case in filenames */
int   g_iIncFilesMask           =   0;      /* Include to search        */
int   g_iExcFilesMask           =   0;      /* Include to search        */

struct FileSearchMasks    g_sIncFileMasks;
struct FileSearchMasks    g_sExcFileMasks;

const  char  g_szCRC32[]        =   { "CRC32="};
const  char  g_szCRC16[]        =   { "CRC16="};
const  char  g_szMD5[]          =   { "MD5="};
const  char  g_szSHA1[]         =   { "SHA1="};
const  char  g_szOK[]           =   { "OK"};
const  char  g_szBAD[]          =   { "(bad)"};
const  char  g_szNOFILE[]       =   { "(file not found)"};
const  char  g_szWrongCRC[]     =   { "(unreliable results)"};

const  char  g_szDefLogFile[]   =   { "crc.log"};



/*---------------------------- Error Messages ------------------------------*/
const char  g_szNoMemForExcFMask[]  =
                     "WARNING: insufficient memory for excluding filemask.";
const char  g_szNoMemForIncFMask[]  =
                     "WARNING: insufficient memory for including filemask.";



/*------------------------- Function Prototype -----------------------------*/
unsigned long int ulScanDir( char *dirname, int maxdirlen,
                             pFileSearchMasks pIncFMasks,
                             pFileSearchMasks pExcFMasks, int iSearchDirs,
                             const char *resfile );
int   iTestDir( char *dirname );
int   iTestPattern( const char * szName, const char * szPattern );
int  iTestForFileMask( char *filename, pFileSearchMasks pFMasks,
                       int iFMasksCount );
int  AddFileMask( const char * pszAddMask, pFileSearchMasks pFMasks,
                  int * piFMasksCount, const char * pszErrMsg );
char  *StrUpper( char *pstr);
void  BuildTableCRC32( void );
void  BuildTableCRC16( void );
unsigned long int ulGetFileCRC32( char *szFileName );
unsigned int iGetFileCRC16( char *szFileName );
unsigned long int ulCalcBufCRC32( unsigned int count, unsigned long int crc,
                                  unsigned char *pbuf );
unsigned int iCalcBufCRC16( unsigned int count, unsigned int crc,
                            unsigned char *pbuf );
int   iFileExists( const char * szName );
char *  safe_strncpy ( char *dest, const char *src, size_t maxlen );
char *  safe_strncat( char *dest, const char *src, size_t n );
#if (defined(_WIN32) || defined(_MSVC))
DIR *  opendir( char *dirname );
struct dirent *  readdir( DIR  *dir );
int   closedir( DIR  *dir );
#endif                                      /* #if (defined(_WIN32) || defined(_MSVC)) */

unsigned char *  GetFileSHA1( char *szFileName );
void SHA1Transform(SHA1_CTX* context, unsigned char buffer[64]);
void SHA1Init(SHA1_CTX* context);
void SHA1Update(SHA1_CTX* context, unsigned char* data, uint32 len);
void SHA1Final(unsigned char digest[20], SHA1_CTX* context);

pmd5buf GetFileMD5( char *szFileName );
void MD5Init(struct MD5Context *ctx);
void MD5Update(struct MD5Context *ctx, unsigned char *buf, unsigned len);
void MD5Final( pmd5buf digest, struct MD5Context *ctx);
#if 0
void MD5Final( unsigned char digest[DIGEST_BUF_SIZE], 
               struct MD5Context *ctx);
#endif               
void MD5Transform(uint32 buf[4], uint32 in[16]);



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
    char  szOutResFile[MAX_FILENAME_SIZE+1]    = { "\0" };
    char  szLogFile[MAX_FILENAME_SIZE+1]       = { "\0" };
    char  szCurDir[MAX_FILENAME_SIZE+1]        = { "\0" };
    char  szChkFileName[MAX_FILENAME_SIZE+1];
    char  szTempBuf[MAX_OUT_LINE_SIZE];     /* Working buffer */
#if _MD5STRSAVE_WORKAROUND
    char  szTempBuf_save[MAX_OUT_LINE_SIZE];/* Working buffer */
    char        StrBuf_save[MAX_LINE_SIZE]; /* Working string */
#endif                                      /* #if _MD5STRSAVE_WORKAROUND */
    char  szTempStr[WORK_LINE_SIZE];        /* Working string */
    int         iTemp;                      /* Temporary */
    char        chTemp;                     /* Temporary storage */
    unsigned long int ulFoundFiles = 0;     /* Counter */
    FILE       *LogFile;                    /* Output logfile */
    FILE       *ResFile;                    /* Output resfile */
    char        StrBuf[MAX_LINE_SIZE];      /* Working string */
    unsigned long int  ulLinesCount = 0;    /* Count processing lines */
    char       *pchs;                       /* Temporary pointer */
    char       *pche;                       /* Temporary pointer */
    unsigned long int  ulTestCRC32;         /* Test CRC-32 sum */
    unsigned long int  ulCalcCRC32;         /* Computed CRC-32 sum */
#if defined(_WIN32) || defined(_UNIX)
    unsigned short int   iTestCRC16;        /* Test CRC-16 sum */
    unsigned short int   iCalcCRC16;        /* Computed CRC-16 sum */
#else
    unsigned int       iTestCRC16;          /* Test CRC-16 sum */
    unsigned int       iCalcCRC16;          /* Computed CRC-16 sum */
#endif                                      /* #if defined(_WIN32) || defined(_UNIX) */
    int         fBadCRC;                    /* Flag for failed CRC */
    int         iIndex;                     /* Index loop */
    int         fWrongCRC;                  /* Wrong CRC found */
    void *      pTemp;                      /* Temporary */
    md5buf      md5sig_test;                /* MD5 hash sum (from file) */
    md5buf      md5sig_calc;                /* MD5 hash sum (calc on file) */
    pmd5buf     psignature;                 /* MD5 hash sum pointer */
    int         i;                          /* Temporary */
    unsigned char  sha1_hash_test[SHA1_RESULTLEN]; /* SHA-1 hash buffer */
    unsigned char  sha1_hash_calc[SHA1_RESULTLEN]; /* SHA-1 hash buffer */
    unsigned char * p_sha1_hash;            /* Temporary */
    

/*-------------------------- Compiler test phase ---------------------------*/
#ifdef  _TEST
#if __STDC__ == 0 && !defined(__cplusplus)
  printf("cc is not ANSI C compliant!\n");
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
     printf( "TESTSUM(1)                                             TESTSUM(1)\n" );
     printf( "\n" );
     printf( "NAME\n" );
     printf( "  testsum - test file(s) integrity using CRC-16/CRC-32/MD5/SHA-1 sums\n" );
     printf( "\n" );
     printf( "SYNOPSIS\n" );
     printf( "   testsum [-1] [-3] [-5] [-7] [-b] [-d] [[-e filemask]..] [-f logfile]\n" );
     printf( "           [-g] [[-i filemask]..] [-l] [-o resfile] [-r times] [-s] [-t]\n" );
     printf( "           [-v] [dirname]\n" );
     printf( "\n" );
     printf( "DESCRIPTION\n" );
     printf( "  TESTSUM uses the standard CRC math to check the file contents integrity.\n" );
     printf( "  Defaults: generate CRC sums for file(s) in current directory, and a name of\n" );
     printf( "  a logfile to test CRC sums is the '%s' filename.\n", g_szDefLogFile );
     printf( "\n" );
     printf( "OPTIONS\n" );
     printf( "  -1   Use CRC-16 algorithm.\n" );
     printf( "  -3   Use CRC-32 algorithm (default).\n" );
     printf( "  -5   Use MD5 algorithm.\n" );
     printf( "  -7   Use SHA-1 algorithm.\n" );
     printf( "  -b   Print only filenames with failed CRC.\n" );
     printf( "  -d   Debugging level.\n" );
     printf( "  -e filemask\n" );
     printf( "       Exclude file(s) for search, wildcards are allowed (upto %d masks).\n", FMASKS_MAX );
     printf( "  -f   Input logfile.\n" );
     printf( "  -g   Ignore case in filename(s).\n" );
     printf( "  -i filemask\n" );
     printf( "       Include file(s) for search, wildcards are allowed (upto %d masks).\n", FMASKS_MAX );
     printf( "  -l   Use default logfile name to write output results.\n" );
     printf( "  -o   Output results filename.\n" );
     printf( "  -r times\n" );
     printf( "       Repeat a CRC calculations many times. Maximum is %d.\n", MAX_CRC_TIMES );
     printf( "  -s   Search subdirectories.\n" );
     printf( "  -t   Test (check) CRC sum for each file(s) listed in logfile.\n" );
     printf( "  -v   Verbose output.\n" );
     printf( "  dirname\n" );
     printf( "       Directory name to start. If absent then current in use.\n" );
     printf( "\n" );
     printf( "HISTORY\n" );
     printf( "  TESTSUM command appeared in October 1998\n" );
     printf( "\n" );
     printf( "AUTHOR\n" );
     printf( "  Dmitry V. Stefankov  (dstef@wizards.pp.ru, dstef@radiomayak.ru)" );
     printf( "\n" );
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
       if (chTemp == '-')
#else
       if ( (chTemp == '-') || (chTemp == '/') )
#endif                                      /* #if defined(_UNIX) */
       {
          chTemp = *(++*lpszArgv);          /* Look options */
          switch( chTemp )
          {
                case '7':
                    g_fSHA1  = 1;           /* SHA1 */
                    break;
                case '5':
                    g_fMD5   = 1;           /* MD5 */     
                    break;
                case '1':
                    g_fCRC16 = 1;           /* CRC-16 */
                    break;
                case '3':
                    g_fCRC32 = 1;           /* CRC-32 */
                    break;
                case 'b':
                    g_fPrintBadCRC = 1;     /* Print only bad CRC */
                    break;
                case 'd':
                    g_iDebugLevel = 1;      /* Some debugging */
                    break;
                case 'e':
                    if (iArgc)              /* Exclude files mask */
                    {
                        --iArgc;
                        safe_strncpy( szExcSearchMask, *(++lpszArgv), sizeof(szExcSearchMask) );
#if defined(_MSDOS)
                        StrUpper( szExcSearchMask );
#endif                                      /* #if defined(_MSDOS) */
                        iTemp = AddFileMask( szExcSearchMask,
                                             &g_sExcFileMasks,
                                             &g_iExcFilesMask,
                                             g_szNoMemForExcFMask );
                    }
                    break;
                case 'f':
                    if (iArgc)              /* Logfile */
                    {
                        --iArgc;
                        safe_strncpy( szLogFile, *(++lpszArgv), sizeof(szLogFile) );
                    }
                    break;
                case 'g':                   /* Case-insensitive search for filenames */
                    g_fIgnoreCaseInFilenames = 1;
                    break;
                case 'i':
                    if (iArgc)              /* Include files mask */
                    {
                        --iArgc;
                        /*iTemp = strlen(*(++lpszArgv) );*/
                        safe_strncpy( szIncSearchMask, *(++lpszArgv), sizeof(szIncSearchMask) );
#if defined(_MSDOS)
                        StrUpper( szIncSearchMask );
#endif                                      /* #if defined(_MSDOS) */
                        iTemp = AddFileMask( szIncSearchMask,
                                             &g_sIncFileMasks,
                                             &g_iIncFilesMask,
                                             g_szNoMemForIncFMask );
                    }
                    break;
                case 'l':                   /* Default output logfile name */
                    if ( g_fCreateCrcLog && (!g_fTestCrcLog) )
                    {
                      safe_strncpy( szOutResFile, g_szDefLogFile, sizeof(szOutResFile) );
                    }
                    break;
                case 'o':
                    if (iArgc)              /* Output results file */
                    {
                        --iArgc;
                        safe_strncpy( szOutResFile, *(++lpszArgv), sizeof(szOutResFile) );
                    }
                    break;
                case 'r':                   /* How many times */
                    if (iArgc)
                    {
                      --iArgc;
                      iTemp = atoi( *(++lpszArgv) );
                      if ( (iTemp >= 0 ) && (iTemp <= MAX_CRC_TIMES) )
                      {
                         g_iRetryCountCRC = iTemp;
                      }
                    }
                    break;
                case 's':                   /* Search subdirectories */
                    g_fRecursiveSearch = 1;
                    break;
                case 't':                   /* Test CRC logfile */
                    g_fCreateCrcLog = 0;
                    g_fTestCrcLog = 1;
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

/*--------------------------- Initial checks -------------------------------*/
#if defined(_WIN32)
    if( !GetCurrentDirectory( MAX_FILENAME_SIZE, szCurDir) )
    {
        printf( "ERROR: Unable to get current directory.\n" );
        return 0;                           /* Emergency exit */
    }
#endif                                      /* #if defined(_WIN32) */
  if ( !( g_fCreateCrcLog || g_fTestCrcLog ) )
  {
      printf( "ERROR: create or test option must be used.\n" );
      return( ERROR_NO_ACTION );
  }

  if ( g_fCreateCrcLog && g_fTestCrcLog )
  {
      printf( "ERROR: create and test options cannot be used together.\n" );
      return( ERROR_CANNOT_USE_THEM );
  }

  if ( g_fTestCrcLog && (szLogFile[0] == '\0') )
  {
    safe_strncpy( szLogFile, g_szDefLogFile, sizeof(szLogFile) );
  }

  if ( szIncSearchDir[0] == '\0' )
    safe_strncpy( szIncSearchDir, ".", sizeof(szIncSearchDir) );
  if ( szIncSearchMask[0] == '\0' )
  {
     safe_strncpy( szIncSearchMask, "*", sizeof(szIncSearchMask) );
     iTemp = AddFileMask( szIncSearchMask, &g_sIncFileMasks,
                          &g_iIncFilesMask, g_szNoMemForIncFMask );
  }

#if defined(_MSDOS)
  StrUpper( szIncSearchDir );               /* Convert all to uppercase */
  StrUpper( szLogFile );
  StrUpper( szOutResFile );
  StrUpper( szCurDir );
#endif                                      /* #if defined(_MSDOS) */

  if (g_iDebugLevel > 0)
  {
    printf( "Search catalog:  %s\n", &szIncSearchDir[0] );
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
    printf( "Input file:      %s\n", &szLogFile[0] );
    printf( "Output file:     %s\n", &szOutResFile[0] );
    printf( "Current catalog: %s\n", &szCurDir[0] );
  }

  BuildTableCRC16();                        /* Initialize tables */
  BuildTableCRC32();

/*--------------------------- Searches directory ---------------------------*/

  if ( g_fCreateCrcLog )
  {
    if (!g_fCRC16 && !g_fCRC32 && !g_fMD5 &&!g_fSHA1)
    {
      printf( "ERROR: you must specify CRC method(s).\n" );
      return( ERROR_NO_CRC_METHOD );
    }

    if (szOutResFile[0] != '\0' )
    {
      LogFile = fopen( szOutResFile, "wt" );
      if (LogFile == NULL )
      {
        printf( "ERROR: cannot create logfile.\n" );
        return( ERROR_LOGFILE_CREAT_FAIL );
      }
      fclose( LogFile );
    }

    ulFoundFiles = ulScanDir( szIncSearchDir, MAX_FILENAME_SIZE+1,
                              &g_sIncFileMasks, &g_sExcFileMasks,
                              g_fRecursiveSearch, szOutResFile );

    if (g_iDebugLevel > 0)
    {
      printf( "Total found %lu item", ulFoundFiles );
      if (ulFoundFiles != 1)
        printf("s");
      printf("\n");
    }
  }/*if*/

/*--------------------------- Process logfile ------------------------------*/
  if ( g_fTestCrcLog )
  {
    if ( szLogFile[0] == '\0' )
    {
      printf( "ERROR: user logfile name missed.\n" );
      return( ERROR_LOGFILE_NOT_FOUND );
    }

    LogFile = fopen( szLogFile, "rt" );
    if ( LogFile == NULL )
    {
      printf( "ERROR: cannot open logfile.\n" );
      return( ERROR_LOGFILE_OPEN_FAIL );
    }

    if ( szOutResFile[0] != '\0' )
    {
      ResFile = fopen( szOutResFile, "wt" );
      if (ResFile == NULL )
      {
        printf( "ERROR: cannot create output results file.\n" );
        return( ERROR_RESFILE_CREAT_FAIL );
      }
    }
    else
    {
      ResFile = stdout;
    }

    while ( fgets(StrBuf,sizeof(StrBuf), LogFile ) != NULL )
    {
       ulLinesCount++;
       pchs = strchr(StrBuf,QUOTA);
       if (pchs == NULL)
       {
         continue;                          /* Skip this line */
       }
       else
       {
         pchs++;                            /* Skip first delimiter */
         pche = strchr(pchs,QUOTA);         /* Now search second delimiter */
         if (pche == NULL)
         {
           printf( "WARNING: line %ld has wrong format\n", ulLinesCount );
           continue;
         }
         iTemp = (int)(pche-pchs);          /* We got a filename */
         if (iTemp > (int)sizeof(szChkFileName) )
            iTemp = sizeof(szChkFileName) - 1;
         safe_strncpy( szChkFileName, pchs, iTemp+1 );
         szChkFileName[iTemp] = '\0';

         fBadCRC = 0;                       /* Save a filename */
         memset( szTempBuf, 0, sizeof(szTempBuf) );
         safe_strncat( szTempBuf, "\"", sizeof(szTempBuf) );
         safe_strncat( szTempBuf, szChkFileName, sizeof(szTempBuf) );
         safe_strncat( szTempBuf, "\"", sizeof(szTempBuf) );

         if ( iFileExists(szChkFileName) != 0 )
         {
           sprintf( szTempStr, "  %s", g_szNOFILE );
           safe_strncat( szTempBuf, szTempStr, sizeof(szTempBuf) );
           fBadCRC = 1;
         }
         else
         {
           pchs = strstr( StrBuf, g_szCRC16 );/* Extract CRC-16 value */
           if (pchs != NULL)
           {
             pchs += strlen( g_szCRC16 );
             iTestCRC16 = (unsigned int)strtoul( pchs, &pche, HEX_RADIX);
             iCalcCRC16 = iGetFileCRC16( szChkFileName );
             fWrongCRC = 0;
             if ( g_iRetryCountCRC > 1 )
             {
                for(iIndex=1; iIndex < g_iRetryCountCRC; iIndex++)
                    if ( iCalcCRC16 !=  iGetFileCRC16(szChkFileName) )
                        fWrongCRC++;
             }
             if (fWrongCRC)
             {
                 safe_strncat( szTempBuf, "  ", sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szWrongCRC, sizeof(szTempBuf) );
             }
             else
             {
               if (iCalcCRC16 == iTestCRC16)
               {
                 safe_strncat( szTempBuf, "  ", sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szCRC16, sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szOK, sizeof(szTempBuf) );
               }
               else
               {
                 fBadCRC = 1;
                 sprintf( szTempStr, "  %s0x%04X %s", g_szCRC16, iCalcCRC16, g_szBAD );
                 safe_strncat( szTempBuf, szTempStr, sizeof(szTempBuf) );
               }
             }
           }

           pchs = strstr( StrBuf, g_szCRC32 );/* Extract CRC-32 value */
           if (pchs != NULL)
           {
             pchs += strlen( g_szCRC32 );
             ulTestCRC32 = strtoul( pchs, &pche, HEX_RADIX);
             ulCalcCRC32 = ulGetFileCRC32( szChkFileName );
             fWrongCRC = 0;
             if ( g_iRetryCountCRC > 1 )
             {
                for(iIndex=1; iIndex < g_iRetryCountCRC; iIndex++)
                    if ( ulCalcCRC32 !=  ulGetFileCRC32(szChkFileName) )
                        fWrongCRC++;
             }
             if (fWrongCRC)
             {
                 safe_strncat( szTempBuf, "  ", sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szWrongCRC, sizeof(szTempBuf) );
             }
             else
             {
               if ( ulCalcCRC32 == ulTestCRC32 )
               {
                 safe_strncat( szTempBuf, "  ", sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szCRC32, sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szOK, sizeof(szTempBuf) );
               }
               else
               {
                 fBadCRC = 1;
                 sprintf( szTempStr, "  %s0x%08lX %s", g_szCRC32, ulCalcCRC32,
                          g_szBAD );
                 safe_strncat( szTempBuf, szTempStr, sizeof(szTempBuf) );
               }
             }/*if-else*/
           }

           pchs = strstr( StrBuf, g_szMD5 );/* Extract MD5 value */
           if (pchs != NULL)
           {
             memset( &md5sig_test, 0, sizeof(md5sig_test) );
             pchs += strlen( g_szMD5 );
             pchs += strlen( "0x" );
#if _MD5STRSAVE_WORKAROUND
             strncpy( szTempBuf_save, szTempBuf, sizeof(szTempBuf_save) );
	     strncpy( StrBuf_save, StrBuf, sizeof(StrBuf_save) );
#endif                                      /* #if _MD5STRSAVE_WORKAROUND */
             for( i=0; i<DIGEST_BUF_SIZE; i++ ) {
               sscanf( pchs, "%02X", &md5sig_test.md5sig[i] );
               pchs += 2;                   /* Next 2 chars */
             }
#if _MD5STRSAVE_WORKAROUND
             strncpy( szTempBuf, szTempBuf_save, sizeof(szTempBuf) );
	     strncpy( StrBuf, StrBuf_save, sizeof(StrBuf) );
#endif                                      /* #if _MD5STRSAVE_WORKAROUND */
             psignature = GetFileMD5( szChkFileName );
             if (psignature != NULL)
               memcpy( &md5sig_calc, psignature, sizeof(md5sig_calc) );
             fWrongCRC = 0;
             if ( g_iRetryCountCRC > 1 )
             {
                for(iIndex=1; iIndex < g_iRetryCountCRC; iIndex++) {
                  psignature = GetFileMD5( szChkFileName );
                  if (memcmp(psignature, &md5sig_calc, DIGEST_BUF_SIZE) != 0)
                        fWrongCRC++;
                }
             }
             if (fWrongCRC)
             {
                 safe_strncat( szTempBuf, "  ", sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szWrongCRC, sizeof(szTempBuf) );
             }
             else
             {
               if ( memcmp(&md5sig_test, &md5sig_calc, DIGEST_BUF_SIZE) == 0)
               {
                 safe_strncat( szTempBuf, "  ", sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szMD5, sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szOK, sizeof(szTempBuf) );
               }
               else
               {
                 fBadCRC = 1;
                 sprintf( szTempStr, "  %s0x", g_szMD5 );
                 safe_strncat( szTempBuf, szTempStr, sizeof(szTempBuf) );
                 for( i=0; i<DIGEST_BUF_SIZE; i++ ) {
                   sprintf( szTempStr, "%02X", md5sig_calc.md5sig[i] );
                   safe_strncat( szTempBuf, szTempStr, sizeof(szTempBuf) );
                 }
                 sprintf( szTempStr, " %s", g_szBAD );
                 safe_strncat( szTempBuf, szTempStr, sizeof(szTempBuf) );
               }
             }
           }/*if-else*/

           pchs = strstr( StrBuf, g_szSHA1 );/* Extract SHA1 value */
           if (pchs != NULL)
           {
             memset( &sha1_hash_test, 0, sizeof(sha1_hash_test) );
             pchs += strlen( g_szSHA1 );
             pchs += strlen( "0x" );
             for( i=0; i<SHA1_RESULTLEN; i++ ) {
               sscanf( pchs, "%02X", &sha1_hash_test[i] );
               pchs += 2;                   /* Next 2 chars */
             }
             p_sha1_hash = GetFileSHA1( szChkFileName );
             if (p_sha1_hash != NULL)
               memcpy( &sha1_hash_calc, p_sha1_hash, sizeof(sha1_hash_calc) );
             fWrongCRC = 0;
             if ( g_iRetryCountCRC > 1 )
             {
                for(iIndex=1; iIndex < g_iRetryCountCRC; iIndex++) {
                  p_sha1_hash = GetFileSHA1( szChkFileName );
                  if (memcmp(p_sha1_hash, &sha1_hash_calc, DIGEST_BUF_SIZE) != 0)
                        fWrongCRC++;
                }
             }
             if (fWrongCRC)
             {
                 safe_strncat( szTempBuf, "  ", sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szWrongCRC, sizeof(szTempBuf) );
             }
             else
             {
               if ( memcmp(&sha1_hash_test, &sha1_hash_calc, SHA1_RESULTLEN) == 0)
               {
                 safe_strncat( szTempBuf, "  ", sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szSHA1, sizeof(szTempBuf) );
                 safe_strncat( szTempBuf, g_szOK, sizeof(szTempBuf) );
               }
               else
               {
                 fBadCRC = 1;
                 sprintf( szTempStr, "  %s0x", g_szSHA1 );
                 safe_strncat( szTempBuf, szTempStr, sizeof(szTempBuf) );
                 for( i=0; i<SHA1_RESULTLEN; i++ ) {
                   sprintf( szTempStr, "%02X", sha1_hash_calc[i] );
                   safe_strncat( szTempBuf, szTempStr, sizeof(szTempBuf) );
                 }
                 sprintf( szTempStr, " %s", g_szBAD );
                 safe_strncat( szTempBuf, szTempStr, sizeof(szTempBuf) );
               }
             }
           }/*if-else*/

         }/*if-else*/

         if ( (szOutResFile[0] != '\0') && (g_fVerbose) )
         {
           printf( "%s\n", szChkFileName );
         }
         if ( !( (g_fPrintBadCRC == 1) && (fBadCRC == 0) ) )
         {
           fprintf( ResFile, "%s\n", szTempBuf );
         }

       }/*if-else*/
    }/*while*/
    fclose( LogFile );
    if ( szOutResFile[0] != '\0' )
      fclose( ResFile );

    if (g_iDebugLevel > 0)
    {
      printf( "Total found %lu line", ulLinesCount );
      if (ulLinesCount != 1)
        printf("s");
      printf("\n");
    }
  }/*if*/

/*--------------------------- Terminate program  ---------------------------*/

  return 0;
}



/*****************************************************************************
 *                             --- ulScanDir ---
 *
 * Purpose: Scan files in directory
 *   Input: char       *dirname    - directory name
 *          int        maxdirlen   - directory name buffer size (max.)
 *          pFileSearchMasks pIncFMasks - include filemasks array
 *          pFileSearchMasks pExcFMasks - exclude filemasks array
 *          int        iSearchDirs - search subdirectories
 *          const char *resfile    - output results file
 *  Output: unsigned long int      - number of matching found files
 * Written: by Dmitry V.Stefankov 10-03-1998
 *****************************************************************************/
unsigned long int  ulScanDir( char *dirname, int maxdirlen,
                              pFileSearchMasks pIncFMasks,
                              pFileSearchMasks pExcFMasks, int iSearchDirs,
                              const char *resfile )
{
  unsigned long int  ulFilesCount = 0;      /* Counter */
  char  szTestFName[MAX_FILENAME_SIZE+1];   /* Filename */
  DIR  *dir;                                /* Directory structure */
  struct dirent  *ent;                      /* Directory entry */
  int   fExcThisFile;                       /* Boolean flag */
  int   fIncThisFile;                       /* Boolean flag */
  FILE   *OutputStream;                     /* Output stream */
  unsigned long  int   ulTempCRC32;         /* Temporary value */
#if ( defined(_WIN32) || defined(_UNIX) )
  unsigned short int   iTempCRC16;          /* Temporary value */
#else
  unsigned       int   iTempCRC16;          /* Temporary value */
#endif                                      /* #if ( defined(_WIN32) || defined(_UNIX) ) */
  int   iIndex;                             /* Index loop */
  int   fWrongCRC;                          /* Wrong CRC found */
  int   maxlen;                             /* Space size */
  md5buf  md5sig;
  pmd5buf  psignature;
  unsigned char * pch;
  unsigned char  sha1_hash[SHA1_RESULTLEN]; /* SHA-1 hash buffer */
  unsigned char * p_sha1_hash;

/*------------------------ Process directory name --------------------------*/
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
    printf( "ERROR: Unable to open directory.\n" );
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
      if ( iTestDir(szTestFName) == 1 )     /* Catalog or file? */
      {
        fExcThisFile = iTestForFileMask( ent->d_name, pExcFMasks,
                                         g_iExcFilesMask );
        if ( !fExcThisFile )
        {
          fIncThisFile = iTestForFileMask( ent->d_name, pIncFMasks,
                                           g_iIncFilesMask );
          if ( fIncThisFile )
          {
            if ( iFileExists(szTestFName) != 0 )
            {
              continue;                     /* File not found */
            }
            if (strcmp(resfile, ent->d_name) != 0)
            {                               /* Write to logfile */
              if ( *resfile == '\0' )
                OutputStream = stdout;
              else
                OutputStream = fopen( resfile, "at" );
              if (OutputStream != NULL )
              {
                fprintf( OutputStream, "%c%s%c", '"', szTestFName, '"' );
                
                if (g_fCRC16)
                {
                  fWrongCRC = 0;
                  iTempCRC16 = iGetFileCRC16( szTestFName );
                  if ( g_iRetryCountCRC > 1 )
                  {
                     for(iIndex=1; iIndex < g_iRetryCountCRC; iIndex++)
                       if ( iTempCRC16 != iGetFileCRC16(szTestFName) )
                         fWrongCRC++;
                  }
                  if (fWrongCRC)
                    fprintf( OutputStream, "  %s", g_szWrongCRC );
                  else
                    fprintf( OutputStream, "  %s0x%04X", g_szCRC16, iTempCRC16 );
                }

                if (g_fCRC32)
                {
                  fWrongCRC = 0; 
                  ulTempCRC32 = ulGetFileCRC32( szTestFName );
                  if ( g_iRetryCountCRC > 1 )
                  {
                    for(iIndex=1; iIndex < g_iRetryCountCRC; iIndex++)
                      if ( ulTempCRC32 != ulGetFileCRC32(szTestFName) )
                        fWrongCRC++;
                  }
                  if (fWrongCRC)
                    fprintf(OutputStream, " %s", g_szWrongCRC );
                  else
                    fprintf( OutputStream, "  %s0x%08lX", g_szCRC32, ulTempCRC32 );
                }

                if (g_fMD5)  {
                  fWrongCRC = 0; 
                  psignature = GetFileMD5( szTestFName );
                  if (psignature != NULL)
                    memcpy( &md5sig, psignature, sizeof(md5sig) );
                  if ( g_iRetryCountCRC > 1 )
                  {
                    for(iIndex=1; iIndex < g_iRetryCountCRC; iIndex++)
                      if ( memcmp( psignature, GetFileMD5(szTestFName),
                           sizeof(md5sig)) != 0 )
                        fWrongCRC++;
                  }                   
                  if (fWrongCRC) {
                     fprintf(OutputStream, " %s", g_szWrongCRC );
                  }
                  else {
                     fprintf( OutputStream, "  %s0x", g_szMD5 );
                     pch = (unsigned char *)psignature;     
                     for(iIndex = 0; iIndex < DIGEST_BUF_SIZE; iIndex++) {
                       fprintf( OutputStream, "%02X", *pch++ );
                     }
                  }
                }

                if (g_fSHA1)  {
                  fWrongCRC = 0; 
                  p_sha1_hash = GetFileSHA1( szTestFName );
                  if (p_sha1_hash != NULL)
                    memcpy( &sha1_hash, p_sha1_hash, sizeof(sha1_hash) );
                  if ( g_iRetryCountCRC > 1 )
                  {
                    for(iIndex=1; iIndex < g_iRetryCountCRC; iIndex++)
                      if ( memcmp( p_sha1_hash, GetFileSHA1(szTestFName),
                           SHA1_RESULTLEN) != 0 )
                        fWrongCRC++;
                  }                   
                  if (fWrongCRC) {
                     fprintf(OutputStream, " %s", g_szWrongCRC );
                  }
                  else {
                     fprintf( OutputStream, "  %s0x", g_szSHA1 );
                     pch = (unsigned char *)sha1_hash;
                     for(iIndex = 0; iIndex < SHA1_RESULTLEN; iIndex++) {
                       fprintf( OutputStream, "%02X", *pch++ );
                     }
                  }
                }
                
                fprintf( OutputStream, "\n" );
                   if ( *resfile != '\0' )
                      fclose( OutputStream );
                if ( (g_fVerbose) && (*resfile != '\0') )
                    printf( "%s\n", szTestFName );
              }/*if*/
            }/*if*/
            ++ulFilesCount;
          }
        }
      }
      else {
        if (iSearchDirs) /* Have we look more? */
                 ulFilesCount += ulScanDir( szTestFName, maxdirlen,
                            pIncFMasks, pExcFMasks, iSearchDirs, resfile );
      }/*if-else*/
    }/*if*/
  }/*while*/

/*------------------------ Close a directory--------------------------------*/
  if ( closedir(dir) != 0 )
      printf( "ERROR: Unable to close directory.\n" );

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
      printf( "ERROR: Unable to close directory during testing.\n" );
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
       safe_strncpy( pTemp, pszAddMask, strlen(pszAddMask)+1 );
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



#if defined(_MSDOS)
/*****************************************************************************
 *                            --- StrUpper ---
 *
 * Purpose: Converts string to uppercase
 *   Input: char  *pstr - input string (pointer)
 *  Output: char *      - output string (pointer)
 * Written: by Dmitry V.Stefankov 10-03-1998
 *****************************************************************************/
char *StrUpper( char *pstr )
{
   char  *pTemp = pstr;                     /* Temporary */

   if ( pTemp != NULL )
   {
       do {
           *pTemp = toupper( (int)*pTemp );
           pTemp++;
       } while ( *pTemp != '\0' );
   }
   return( pstr );
}
#endif                                      /* #if defined(_MSDOS) */



/*****************************************************************************
 *                         --- BuildTableCRC32 ---
 *
 * Purpose: Builds a global CRC-32 table
 *   Input: none
 *  Output: none
 * Written: by Dmitry V.Stefankov 10-05-1998
 *   Note:  CRC-32 computation is used a polynomial
 *(forward) X^31+X^30+X^29+X^27+X^26+X^24+X^23+X^21+X^20+X^19+X^15+X^9+X^8+X^5+X^0
 *(backward)X^32+X^26+X^23+X^22+X^16+X^12+X^11+X^10+X^8+X^7+X^5+X^4+X^2+X^1+X^0
 *****************************************************************************/
void  BuildTableCRC32( void )
{
   int  i;                                  /* Byte index */
   int  j;                                  /* Bit index */
   unsigned long int crc;                   /* Temporary */

   for(i = 0; i < MAX_CRC_TABLE_SIZE; i++)
   {
      crc = i;
      for(j = BITS_PER_BYTE; j > 0; j--)
      {
          if ( crc & 1 )
             crc = (crc >> 1)^CRC32_POLYNOMIAL;
           else
             crc >>=1;
       }
     g_TableCRC32[i]  = crc;
   }
}



/*****************************************************************************
 *                         --- ulGetFileCRC32 ---
 *
 * Purpose: Calculate the CRC-32 value for specified file
 *   Input: char    *szFileName - filename
 *  Output: unsigned long int   - calculated CRC-32 value for file
 * Written: by Dmitry V.Stefankov 10-05-1998
 *****************************************************************************/
unsigned long int ulGetFileCRC32( char *szFileName )
{
   FILE                *crcfile;            /* File stream */
   unsigned long int   crc = 0xFFFFFFFFL;   /* CRC sum */
   unsigned long int   filelen;             /* File size */
   unsigned long int   readbytes = 0;       /* Read bytes count */
   int                 count = 0;           /* Byte count */
   unsigned char       buffer[MAX_FILEBUF_SIZE]; /* Working buffer */

   if ( (crcfile = fopen(szFileName,"rb") ) == NULL )
   {
     return 0;
   }
   else
   {
     fseek( crcfile, 0L, SEEK_END );
     filelen = ftell( crcfile );
     fseek( crcfile, 0L, SEEK_SET );
     while ( (count = fread(buffer, 1, MAX_FILEBUF_SIZE, crcfile)) != 0)
     {
         crc = ulCalcBufCRC32( count, crc, buffer );
         readbytes += count;
     }
     if (readbytes != filelen)
     {
        printf("ERROR: cannot read file %s\n", szFileName );
        crc = 0;
     }
     fclose( crcfile );
   }/*if-else*/
   return( crc ^= 0xFFFFFFFFL );
}



/*****************************************************************************
 *                         --- ulCalcBufCRC32 ---
 *
 * Purpose: Calculate CRC-32 value for memory buffer
 *   Input: unsigned int    count  -  size of buffer
 *          unsigned long int crc  -  initial CRC-32 value
 *          unsigned char *pbuf    -  pointer to buffer
 *  Output: unsigned long int      -  calculated CRC-32 value
 * Written: by Dmitry V.Stefankov 10-05-1998
 *****************************************************************************/
unsigned long int  ulCalcBufCRC32( unsigned int count,
                                   unsigned long int crc,
                                   unsigned char *pbuf )
{
   if ( (pbuf == NULL) || (count == 0) )  /* Check for empty buffer */
     return 0;

   while( count-- )
     crc = ( (crc >> 8) & 0x00FFFFFFL) ^
           g_TableCRC32[ ( (int) crc ^ *pbuf++) & 0xFF];

   return crc;
}



/*****************************************************************************
 *                         --- BuildTableCRC16 ---
 *
 * Purpose: Builds a global CRC-16 table
 *   Input: none
 *  Output: none
 * Written: by Dmitry V.Stefankov 10-05-1998
 *   Note:  CRC-16 computation is used a polynomial X**16+X**15+X**2+1
 *****************************************************************************/
void  BuildTableCRC16( void )
{
   int  i;                                  /* Byte index */
   int  j;                                  /* Bit index */
   unsigned int crc;                        /* Temporary */
   unsigned int val;                        /* Temporary */

   for(i = 0; i < MAX_CRC_TABLE_SIZE; i++)
   {
     crc = 0;
     val = (i << 8);
     for(j=BITS_PER_BYTE; j > 0; j--)
     {
        if ( (val ^ crc) & 0x8000)
           crc = (crc << 1) ^ CRC16_POLYNOMIAL;
        else
           crc <<= 1;
        val <<= 1;
     }
     g_TableCRC16[i]  = crc;
   }
}



/*****************************************************************************
 *                         --- iGetFileCRC16 ---
 *
 * Purpose: Calculate the CRC-16 value for specified file
 *   Input: char    *szFileName - filename
 *  Output: unsigned long int   - calculated CRC-16 value for file
 * Written: by Dmitry V.Stefankov 10-05-1998
 *****************************************************************************/
unsigned int iGetFileCRC16( char *szFileName )
{
   FILE                *crcfile;            /* File stream */
   unsigned int        crc = 0;             /* CRC sum */
   unsigned long int   filelen;             /* File size */
   unsigned long int   readbytes = 0;       /* Read bytes count */
   int                 count = 0;           /* Byte count for one reading */
   unsigned char       buffer[MAX_FILEBUF_SIZE]; /* Working buffer */

   if ( (crcfile = fopen(szFileName,"rb") ) == NULL )
   {
     return 0;
   }
   else
   {
     fseek( crcfile, 0L, SEEK_END );
     filelen = ftell( crcfile );
     fseek( crcfile, 0L, SEEK_SET );
     while ( (count = fread(buffer, 1, MAX_FILEBUF_SIZE, crcfile)) != 0)
     {
         crc = iCalcBufCRC16( count, crc, buffer );
         readbytes += count;
     }
     if (readbytes != filelen)
     {
        printf("ERROR: cannot read file %s\n", szFileName );
        crc = 0;
     }
     fclose( crcfile );
   }/*if-else*/
   return( crc );
}



/*****************************************************************************
 *                         --- iCalcBufCRC16 ---
 *
 * Purpose: Calculate CRC-16 value for memory buffer
 *   Input: unsigned int    count  -  size of buffer
 *          unsigned int      crc  -  initial CRC-16 value
 *          unsigned char *buffer  -  pointer to buffer
 *  Output: unsigned int           -  calculated CRC-16 value
 * Written: by Dmitry V.Stefankov 10-05-1998
 *****************************************************************************/
unsigned int iCalcBufCRC16( unsigned int count, unsigned int crc,
                            unsigned char *pbuf )
{
   if ( (pbuf == NULL) || (count == 0) )  /* Check for empty buffer */
     return 0;

   while( count-- != 0)
      crc = (crc << 8) ^ g_TableCRC16[ ( (crc >> 8)^ *pbuf++) & 0xFF ];

   return crc;
}



/*****************************************************************************
 *                         --- iFileExists ---
 *
 * Purpose: Check that file exists
 *   Input: char  * szName    - filename
 *  Output: int               - 0 file found
 *                              any other indicates error
 * Written: by Dmitry V.Stefankov 10-11-1998
 *****************************************************************************/
int   iFileExists( const char * szName )
{
  FILE  *filestream;                        /* File stream */

  if ( (filestream = fopen(szName,"rb") ) == NULL )
    return 1;
  else
    fclose( filestream );
  return 0;
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

   len = strlen(dirname);
   maxlen = len+5-1;
   if ((name = (char *)malloc(maxlen+1)) == NULL)
   {
      errno = ENOMEM;
      return (NULL);
   }

   safe_strncpy( name, dirname, maxlen+1 );
   if (len-- && name[len] != ':' && name[len] != '\\' && name[len] != '/')
#if defined(_MSVC)
      safe_strncat( name, "\\*.*", maxlen+1 );
   else
      safe_strncat( name, "*.*", maxlen+1 );
#else
      safe_strncat( name, "\\*", maxlen+1 );
   else
      safe_strncat( name, "*", maxlen+1 ) ;
#endif                                      /* #if defined(_MSVC) */
											/* Allocate space for a DIR structure */
   if ((dir = (DIR *)malloc(sizeof(DIR))) == NULL) 
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
#else                                       /* Search for first entry */
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
#if !defined(_MSVC)
   safe_strncpy( dir->d_dirent.d_name, dir->findData.cFileName, sizeof(dir->d_dirent.d_name) );
                                            /* Make a copy */
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
      safe_strncpy( dir->d_dirent.d_name, dir->findData.cFileName, sizeof(dir->d_dirent.d_name) );
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

/*
 * This code implements the MD5 message-digest algorithm.
 * The algorithm is due to Ron Rivest.	This code was
 * written by Colin Plumb in 1993, no copyright is claimed.
 * This code is in the public domain; do with it what you wish.
 *
 * Equivalent code is available from RSA Data Security, Inc.
 * This code has been tested against that, and is equivalent,
 * except that you don't need to include two pages of legalese
 * with every copy.
 *
 * To compute the message digest of a chunk of bytes, declare an
 * MD5Context structure, pass it to MD5Init, call MD5Update as
 * needed on buffers full of bytes, and then call MD5Final, which
 * will fill a supplied 16-byte array with the digest.
 */

#ifndef HIGHFIRST
#define byteReverse(buf, len)	/* Nothing */
#else
/*
 * Note: this code is harmless on little-endian machines.
 */
void byteReverse(unsigned char *buf; unsigned longs)
{
    uint32 t;
    do {
	t = (uint32) ((unsigned) buf[3] << 8 | buf[2]) << 16 |
	    ((unsigned) buf[1] << 8 | buf[0]);
	*(uint32 *) buf = t;
	buf += 4;
    } while (--longs);
}
#endif

/*
 * Debugging print
 */
void print_md5c(MD5_CTX * md5c)
{
#if 0
  int i;
  printf( "\nbuf[4] = 0x%08X,0x%08X,0x%08X,0x%08X\n", 
           md5c->buf[0], md5c->buf[1], md5c->buf[2], md5c->buf[3] );
  printf( "bits[2] = 0x%08X, 0x%08X\n", md5c->bits[0], md5c->bits[1] );
  printf( "in[64]=0x" );
  for (i = 0; i < 64; i++)
    printf( "%02X", md5c->in[i] );
  printf( "\n\n" );  
#endif  
}

/*
 * Start MD5 accumulation.  Set bit count to 0 and buffer to mysterious
 * initialization constants.
 */
void MD5Init( struct MD5Context *ctx )
{
    ctx->buf[0] = 0x67452301;
    ctx->buf[1] = 0xefcdab89;
    ctx->buf[2] = 0x98badcfe;
    ctx->buf[3] = 0x10325476;

    ctx->bits[0] = 0;
    ctx->bits[1] = 0;
}

/*
 * Update context to reflect the concatenation of another buffer full
 * of bytes.
 */
 
void MD5Update( struct MD5Context *ctx, unsigned char *buf, unsigned len )
{
    uint32 t;

    /* Update bitcount */

    t = ctx->bits[0];
    if ((ctx->bits[0] = t + ((uint32) len << 3)) < t)
	ctx->bits[1]++; 	/* Carry from low to high */
    ctx->bits[1] += len >> 29;

    t = (t >> 3) & 0x3f;	/* Bytes already in shsInfo->data */

    /* Handle any leading odd-sized chunks */

    if (t) {
	unsigned char *p = (unsigned char *) ctx->in + t;

	t = 64 - t;
	if (len < t) {
	    memcpy(p, buf, len);
	    return;
	}
	memcpy(p, buf, t);
	byteReverse(ctx->in, 16);
	MD5Transform(ctx->buf, (uint32 *) ctx->in);
	buf += t;
	len -= t;
    }
    /* Process data in 64-byte chunks */

    while (len >= 64) {
	memcpy(ctx->in, buf, 64);
	byteReverse(ctx->in, 16);
	MD5Transform(ctx->buf, (uint32 *) ctx->in);
	buf += 64;
	len -= 64;
    }

    /* Handle any remaining bytes of data. */

    memcpy(ctx->in, buf, len);
}

/*
 * Final wrapup - pad to 64-byte boundary with the bit pattern 
 * 1 0* (64-bit count of bits processed, MSB-first)
 */
void MD5Final( pmd5buf digest,
#if 0
 unsigned char digest[DIGEST_BUF_SIZE], 
#endif 
 struct MD5Context *ctx )
{
    unsigned count;
    unsigned char *p;

    /* Compute number of bytes mod 64 */
    count = (ctx->bits[0] >> 3) & 0x3F;

    /* Set the first char of padding to 0x80.  This is safe since there is
       always at least one byte free */
    p = ctx->in + count;
    *p++ = 0x80;

    /* Bytes of padding needed to make 64 bytes */
    count = 64 - 1 - count;

    /* Pad out to 56 mod 64 */
    if (count < 8) {
	/* Two lots of padding:  Pad the first block to 64 bytes */
	memset(p, 0, count);
	byteReverse(ctx->in, 16);
	MD5Transform(ctx->buf, (uint32 *) ctx->in);

	/* Now fill the next block with 56 bytes */
	memset(ctx->in, 0, 56);
    } else {
	/* Pad block to 56 bytes */
	memset(p, 0, count - 8);
    }
    byteReverse(ctx->in, 14);

    /* Append length in bits and transform */
    ((uint32 *) ctx->in)[14] = ctx->bits[0];
    ((uint32 *) ctx->in)[15] = ctx->bits[1];

    MD5Transform(ctx->buf, (uint32 *) ctx->in);
    byteReverse((unsigned char *) ctx->buf, 4);
    memcpy( digest, ctx->buf, 16);
#if 0
    printf( "digest=0x" );
    p = (unsigned char *)digest;
    for (count = 0; count < 16; count++)
      printf( "%02X", *p++ );
    printf( "\n" );
#endif
    memset(ctx, 0, sizeof(ctx));        /* In case it's sensitive */
}


/*
 * The core of the MD5 algorithm, this alters an existing MD5 hash to
 * reflect the addition of 16 longwords of new data.  MD5Update blocks
 * the data and converts bytes into longwords for this routine.
 */
void MD5Transform( uint32 buf[4], uint32 in[DIGEST_BUF_SIZE] )
{
    register uint32 a, b, c, d;

    a = buf[0];
    b = buf[1];
    c = buf[2];
    d = buf[3];

    MD5STEP(F1, a, b, c, d, in[0] + 0xd76aa478, 7);
    MD5STEP(F1, d, a, b, c, in[1] + 0xe8c7b756, 12);
    MD5STEP(F1, c, d, a, b, in[2] + 0x242070db, 17);
    MD5STEP(F1, b, c, d, a, in[3] + 0xc1bdceee, 22);
    MD5STEP(F1, a, b, c, d, in[4] + 0xf57c0faf, 7);
    MD5STEP(F1, d, a, b, c, in[5] + 0x4787c62a, 12);
    MD5STEP(F1, c, d, a, b, in[6] + 0xa8304613, 17);
    MD5STEP(F1, b, c, d, a, in[7] + 0xfd469501, 22);
    MD5STEP(F1, a, b, c, d, in[8] + 0x698098d8, 7);
    MD5STEP(F1, d, a, b, c, in[9] + 0x8b44f7af, 12);
    MD5STEP(F1, c, d, a, b, in[10] + 0xffff5bb1, 17);
    MD5STEP(F1, b, c, d, a, in[11] + 0x895cd7be, 22);
    MD5STEP(F1, a, b, c, d, in[12] + 0x6b901122, 7);
    MD5STEP(F1, d, a, b, c, in[13] + 0xfd987193, 12);
    MD5STEP(F1, c, d, a, b, in[14] + 0xa679438e, 17);
    MD5STEP(F1, b, c, d, a, in[15] + 0x49b40821, 22);

    MD5STEP(F2, a, b, c, d, in[1] + 0xf61e2562, 5);
    MD5STEP(F2, d, a, b, c, in[6] + 0xc040b340, 9);
    MD5STEP(F2, c, d, a, b, in[11] + 0x265e5a51, 14);
    MD5STEP(F2, b, c, d, a, in[0] + 0xe9b6c7aa, 20);
    MD5STEP(F2, a, b, c, d, in[5] + 0xd62f105d, 5);
    MD5STEP(F2, d, a, b, c, in[10] + 0x02441453, 9);
    MD5STEP(F2, c, d, a, b, in[15] + 0xd8a1e681, 14);
    MD5STEP(F2, b, c, d, a, in[4] + 0xe7d3fbc8, 20);
    MD5STEP(F2, a, b, c, d, in[9] + 0x21e1cde6, 5);
    MD5STEP(F2, d, a, b, c, in[14] + 0xc33707d6, 9);
    MD5STEP(F2, c, d, a, b, in[3] + 0xf4d50d87, 14);
    MD5STEP(F2, b, c, d, a, in[8] + 0x455a14ed, 20);
    MD5STEP(F2, a, b, c, d, in[13] + 0xa9e3e905, 5);
    MD5STEP(F2, d, a, b, c, in[2] + 0xfcefa3f8, 9);
    MD5STEP(F2, c, d, a, b, in[7] + 0x676f02d9, 14);
    MD5STEP(F2, b, c, d, a, in[12] + 0x8d2a4c8a, 20);

    MD5STEP(F3, a, b, c, d, in[5] + 0xfffa3942, 4);
    MD5STEP(F3, d, a, b, c, in[8] + 0x8771f681, 11);
    MD5STEP(F3, c, d, a, b, in[11] + 0x6d9d6122, 16);
    MD5STEP(F3, b, c, d, a, in[14] + 0xfde5380c, 23);
    MD5STEP(F3, a, b, c, d, in[1] + 0xa4beea44, 4);
    MD5STEP(F3, d, a, b, c, in[4] + 0x4bdecfa9, 11);
    MD5STEP(F3, c, d, a, b, in[7] + 0xf6bb4b60, 16);
    MD5STEP(F3, b, c, d, a, in[10] + 0xbebfbc70, 23);
    MD5STEP(F3, a, b, c, d, in[13] + 0x289b7ec6, 4);
    MD5STEP(F3, d, a, b, c, in[0] + 0xeaa127fa, 11);
    MD5STEP(F3, c, d, a, b, in[3] + 0xd4ef3085, 16);
    MD5STEP(F3, b, c, d, a, in[6] + 0x04881d05, 23);
    MD5STEP(F3, a, b, c, d, in[9] + 0xd9d4d039, 4);
    MD5STEP(F3, d, a, b, c, in[12] + 0xe6db99e5, 11);
    MD5STEP(F3, c, d, a, b, in[15] + 0x1fa27cf8, 16);
    MD5STEP(F3, b, c, d, a, in[2] + 0xc4ac5665, 23);

    MD5STEP(F4, a, b, c, d, in[0] + 0xf4292244, 6);
    MD5STEP(F4, d, a, b, c, in[7] + 0x432aff97, 10);
    MD5STEP(F4, c, d, a, b, in[14] + 0xab9423a7, 15);
    MD5STEP(F4, b, c, d, a, in[5] + 0xfc93a039, 21);
    MD5STEP(F4, a, b, c, d, in[12] + 0x655b59c3, 6);
    MD5STEP(F4, d, a, b, c, in[3] + 0x8f0ccc92, 10);
    MD5STEP(F4, c, d, a, b, in[10] + 0xffeff47d, 15);
    MD5STEP(F4, b, c, d, a, in[1] + 0x85845dd1, 21);
    MD5STEP(F4, a, b, c, d, in[8] + 0x6fa87e4f, 6);
    MD5STEP(F4, d, a, b, c, in[15] + 0xfe2ce6e0, 10);
    MD5STEP(F4, c, d, a, b, in[6] + 0xa3014314, 15);
    MD5STEP(F4, b, c, d, a, in[13] + 0x4e0811a1, 21);
    MD5STEP(F4, a, b, c, d, in[4] + 0xf7537e82, 6);
    MD5STEP(F4, d, a, b, c, in[11] + 0xbd3af235, 10);
    MD5STEP(F4, c, d, a, b, in[2] + 0x2ad7d2bb, 15);
    MD5STEP(F4, b, c, d, a, in[9] + 0xeb86d391, 21);

    buf[0] += a;
    buf[1] += b;
    buf[2] += c;
    buf[3] += d;
}

/*
 * Build MD5 hash sum for file
 */
pmd5buf GetFileMD5( char *szFileName )
{
   FILE                *crcfile;            /* File stream */
   unsigned long int   filelen;             /* File size */
   unsigned long int   readbytes = 0;       /* Read bytes count */
   int                 count = 0;           /* Byte count */
   unsigned char       buffer[MAX_FILEBUF_SIZE]; /* Working buffer */
   struct MD5Context md5c;
   static md5buf  signature;
   pmd5buf psig = NULL;

   if ( (crcfile = fopen(szFileName,"rb") ) == NULL )
   {
     return( psig );
   }
   else
   {
     memset( &signature, 0, sizeof(signature) );
     memset( &md5c, 0, sizeof(md5c) );
     MD5Init(&md5c);
     print_md5c(&md5c);
     fseek( crcfile, 0L, SEEK_END );
     filelen = ftell( crcfile );
     fseek( crcfile, 0L, SEEK_SET );
     while ( (count = fread(buffer, 1, MAX_FILEBUF_SIZE, crcfile)) != 0)
     {
         MD5Update(&md5c, buffer, count);
         print_md5c(&md5c);
         readbytes += count;
     }
     if (readbytes != filelen)  {
        printf("ERROR: cannot read file %s\n", szFileName );
     }
     else {
#if 0
        unsigned char *p;
#endif
         MD5Final( &signature, &md5c);
         print_md5c(&md5c);
#if 0
    printf( "digest_md5final=0x" );
    p = (unsigned char *)&signature;
    for (count = 0; count < 16; count++)
      printf( "%02X", *p++ );
    printf( "\n" );
#endif         
         psig = &signature;
     }
     fclose( crcfile );
   }/*if-else*/
   
   return( psig );
}


/*
SHA-1 in C
By Steve Reid <sreid@sea-to-sky.net>
100% Public Domain

-----------------
Modified 2002-02 By Svante Seleborg
Code is now reentrant, i.e. thread safe. Fixed by adding
a workspace buffer to the SHA1_CTX struct if SHA1HANDSOFF
is defined, and passing the context pointer instead of
state pointer to SHA1Transform.

Modified 7/98 
By James H. Brown <jbrown@burgoyne.com>
Still 100% Public Domain

Corrected a problem which generated improper hash values on 16 bit machines
Routine SHA1Update changed from void SHA1Update(SHA1_CTX* context, unsigned char* 
data, unsigned int len) to void SHA1Update(SHA1_CTX* context, unsigned char* 
data, unsigned long len)

The 'len' parameter was declared an int which works fine on 32 bit machines.
However, on 16 bit machines an int is too small for the shifts being done
against it. This caused the hash function to generate incorrect values if len was
greater than 8191 (8K - 1) due to the 'len << 3' on line 3 of SHA1Update().

Since the file IO in main() reads 16K at a time, any file 8K or larger would
be guaranteed to generate the wrong hash (e.g. Test Vector #3, a million "a"s).

I also changed the declaration of variables i & j in SHA1Update to 
unsigned long from unsigned int for the same reason.

These changes should make no difference to any 32 bit implementations since
an int and a long are the same size in those environments.

--
I also corrected a few compiler warnings generated by Borland C.
1. Added #include <process.h> for exit() prototype
2. Removed unused variable 'j' in SHA1Final
3. Changed exit(0) to return(0) at end of main.

ALL changes I made can be located by searching for comments containing 'JHB'
-----------------
Modified 8/98
By Steve Reid <sreid@sea-to-sky.net>
Still 100% public domain

1- Removed #include <process.h> and used return() instead of exit()
2- Fixed overwriting of finalcount in SHA1Final() (discovered by Chris Hall)
3- Changed email address from steve@edmweb.com to sreid@sea-to-sky.net

-----------------
Modified 4/01
By Saul Kravitz <Saul.Kravitz@celera.com>
Still 100% PD
Modified to run on Compaq Alpha hardware.  

*/

/*
 * Debugging print
 */
void SHAPrintContext(SHA1_CTX *context, char *msg){
#if 0
  printf("%s (%d,%d) %x %x %x %x %x\n",
	 msg,
	 context->count[0], context->count[1], 
	 context->state[0],
	 context->state[1],
	 context->state[2],
	 context->state[3],
	 context->state[4]);
#endif
}

/* 
 * Hash a single 512-bit block. This is the core of the algorithm. 
 */
void SHA1Transform(SHA1_CTX *context, unsigned char buffer[64])
{
uint32 a, b, c, d, e;
typedef union {
    unsigned char c[64];
    uint32 l[16];
} CHAR64LONG16;
CHAR64LONG16* block;
unsigned long *pState = &context->state[0];

#if _SHA1HANDSOFF
    block = (CHAR64LONG16*)memcpy(context->workspace, buffer, 64);
#else
    block = (CHAR64LONG16*)buffer;
#endif
    /* Copy pState[] to working vars */
    a = pState[0];
    b = pState[1];
    c = pState[2];
    d = pState[3];
    e = pState[4];
    /* 4 rounds of 20 operations each. Loop unrolled. */
    R0(a,b,c,d,e, 0); R0(e,a,b,c,d, 1); R0(d,e,a,b,c, 2); R0(c,d,e,a,b, 3);
    R0(b,c,d,e,a, 4); R0(a,b,c,d,e, 5); R0(e,a,b,c,d, 6); R0(d,e,a,b,c, 7);
    R0(c,d,e,a,b, 8); R0(b,c,d,e,a, 9); R0(a,b,c,d,e,10); R0(e,a,b,c,d,11);
    R0(d,e,a,b,c,12); R0(c,d,e,a,b,13); R0(b,c,d,e,a,14); R0(a,b,c,d,e,15);
    R1(e,a,b,c,d,16); R1(d,e,a,b,c,17); R1(c,d,e,a,b,18); R1(b,c,d,e,a,19);
    R2(a,b,c,d,e,20); R2(e,a,b,c,d,21); R2(d,e,a,b,c,22); R2(c,d,e,a,b,23);
    R2(b,c,d,e,a,24); R2(a,b,c,d,e,25); R2(e,a,b,c,d,26); R2(d,e,a,b,c,27);
    R2(c,d,e,a,b,28); R2(b,c,d,e,a,29); R2(a,b,c,d,e,30); R2(e,a,b,c,d,31);
    R2(d,e,a,b,c,32); R2(c,d,e,a,b,33); R2(b,c,d,e,a,34); R2(a,b,c,d,e,35);
    R2(e,a,b,c,d,36); R2(d,e,a,b,c,37); R2(c,d,e,a,b,38); R2(b,c,d,e,a,39);
    R3(a,b,c,d,e,40); R3(e,a,b,c,d,41); R3(d,e,a,b,c,42); R3(c,d,e,a,b,43);
    R3(b,c,d,e,a,44); R3(a,b,c,d,e,45); R3(e,a,b,c,d,46); R3(d,e,a,b,c,47);
    R3(c,d,e,a,b,48); R3(b,c,d,e,a,49); R3(a,b,c,d,e,50); R3(e,a,b,c,d,51);
    R3(d,e,a,b,c,52); R3(c,d,e,a,b,53); R3(b,c,d,e,a,54); R3(a,b,c,d,e,55);
    R3(e,a,b,c,d,56); R3(d,e,a,b,c,57); R3(c,d,e,a,b,58); R3(b,c,d,e,a,59);
    R4(a,b,c,d,e,60); R4(e,a,b,c,d,61); R4(d,e,a,b,c,62); R4(c,d,e,a,b,63);
    R4(b,c,d,e,a,64); R4(a,b,c,d,e,65); R4(e,a,b,c,d,66); R4(d,e,a,b,c,67);
    R4(c,d,e,a,b,68); R4(b,c,d,e,a,69); R4(a,b,c,d,e,70); R4(e,a,b,c,d,71);
    R4(d,e,a,b,c,72); R4(c,d,e,a,b,73); R4(b,c,d,e,a,74); R4(a,b,c,d,e,75);
    R4(e,a,b,c,d,76); R4(d,e,a,b,c,77); R4(c,d,e,a,b,78); R4(b,c,d,e,a,79);
    /* Add the working vars back into pState[] */
    pState[0] += a;
    pState[1] += b;
    pState[2] += c;
    pState[3] += d;
    pState[4] += e;
    /* Wipe variables */
    a = b = c = d = e = 0;
}

/* 
 * SHA1Init - Initialize new context 
 */
void SHA1Init(SHA1_CTX* context)
{
    /* SHA1 initialization constants */
    context->state[0] = 0x67452301;
    context->state[1] = 0xEFCDAB89;
    context->state[2] = 0x98BADCFE;
    context->state[3] = 0x10325476;
    context->state[4] = 0xC3D2E1F0;
    context->count[0] = context->count[1] = 0;
}

/* Run your data through this. */

void SHA1Update(SHA1_CTX* context, unsigned char* data, uint32 len)	
{
    uint32 i, j;	

    SHAPrintContext(context, "before");
    j = (context->count[0] >> 3) & 63;
    if ((context->count[0] += len << 3) < (len << 3)) context->count[1]++;
    context->count[1] += (len >> 29);
    if ((j + len) > 63) {
        memcpy(&context->buffer[j], data, (i = 64-j));
        SHA1Transform(context, context->buffer);
        for ( ; i + 63 < len; i += 64) {
            SHA1Transform(context, &data[i]);
        }
        j = 0;
    }
    else i = 0;
    memcpy(&context->buffer[j], &data[i], len - i);
    SHAPrintContext(context, "after ");
}

/* 
 * Add padding and return the message digest. 
 */
void SHA1Final(unsigned char digest[20], SHA1_CTX* context)
{
    uint32 i;
    unsigned char finalcount[8];

    for (i = 0; i < 8; i++) {
        finalcount[i] = (unsigned char)((context->count[(i >= 4 ? 0 : 1)]
         >> ((3-(i & 3)) * 8) ) & 255);  /* Endian independent */
    }
    SHA1Update(context, (unsigned char *)"\200", 1);
    while ((context->count[0] & 504) != 448) {
        SHA1Update(context, (unsigned char *)"\0", 1);
    }
    SHA1Update(context, finalcount, 8);  /* Should cause a SHA1Transform() */
    for (i = 0; i < 20; i++) {
        digest[i] = (unsigned char)
         ((context->state[i>>2] >> ((3-(i & 3)) * 8) ) & 255);
    }
    /* Wipe variables */
    i = 0;
    memset(context, 0, sizeof *context);		
    memset(finalcount, 0, sizeof finalcount);
}

/*
 * Build SHA-1 hash sum for file
 */
unsigned char * GetFileSHA1( char *szFileName )
{
   FILE                *crcfile;            /* File stream */
   unsigned long int   filelen;             /* File size */
   unsigned long int   readbytes = 0;       /* Read bytes count */
   int                 count = 0;           /* Byte count */
   unsigned char       buffer[MAX_FILEBUF_SIZE]; /* Working buffer */
   SHA1_CTX            ctxt;
   static unsigned char psig[SHA1_RESULTLEN];
   unsigned char *     p;

   memset( psig, 0, sizeof(psig) );
   p = psig;
   if ( (crcfile = fopen(szFileName,"rb") ) == NULL )
   {
     return( p );
   }
   else
   {
     memset( &ctxt, 0, sizeof(ctxt) );
     SHA1Init(&ctxt);
     fseek( crcfile, 0L, SEEK_END );
     filelen = ftell( crcfile );
     fseek( crcfile, 0L, SEEK_SET );
     while ( (count = fread(buffer, 1, MAX_FILEBUF_SIZE, crcfile)) != 0)
     {
         SHA1Update( &ctxt, buffer, count );
         readbytes += count;
     }
     if (readbytes != filelen)  {
        printf("ERROR: cannot read file %s\n", szFileName );
     }
     else {
         SHA1Final( psig, &ctxt);
     }
     fclose( crcfile );
   }/*if-else*/
   
   return( p );
}
