/*****************************************************************************
 *                             File CHRCNV.C
 *
 *        Smart cyrillic converter for files using probabilistics
 *        (multi-platfrom version for MS-DOS, Win32, UNIX)
 *
 *   Copyright (c) Dmitry V. Stefankov, 1998-2000. All rights reserved.
 *
 *       This software is distributed under GPL agreement
 *       (See copying file for details).
 *
 *****************************************************************************/
/*
 *   $Source: d:/projects/freeware/c/chrcnv/RCS/chrcnv.c $
 *  $RCSfile: chrcnv.c $
 *   $Author: dstef $
 *     $Date: 2000/01/22 05:26:00 $
 * $Revision: 1.27 $
 *   $Locker: dstef $
 *
 *      $Log: chrcnv.c $
 *      Revision 1.27  2000/01/22 05:26:00  dstef
 *      Fixed output directory problem for UNIX
 *
 *      Revision 1.26  2000/01/22 03:21:27  dstef
 *      Minor changes for all targets to make fully portable version
 *
 *      Revision 1.25  2000/01/06 23:22:18  dstef
 *      Updated program header
 *
 *      Revision 1.24  2000/01/06 23:20:38  dstef
 *      Minor changes
 *
 *      Revision 1.23  2000/01/06 23:17:10  dstef
 *      Added new safe functions strncpy and strncat
 *
 *      Revision 1.22  1999/12/31 17:24:04  dstef
 *      Switched to safe coding style (strncat,strncpy)
 *
 *      Revision 1.21  1999/12/30 20:22:45  dstef
 *      Added target platfrom checking
 *
 *      Revision 1.20  1999/12/30 20:10:51  dstef
 *      Added DJGPP compiler support
 *
 *      Revision 1.19  1999/03/28 18:52:05  dstef
 *      Fixed Y2k problem
 *      Added filemasks array removing single mask limitation
 *
 *      Revision 1.18  1999/02/23 00:54:47  dstef
 *      Added ignore case in filenames switch
 *      Fixed some erratas in user help
 *
 *      Revision 1.17  1998/11/17 12:33:00  dstef
 *      Some minor changes for program help
 *
 *      Revision 1.16  1998/11/17 12:02:47  dstef
 *      Updated compile instructions for MS-DOS
 *
 *      Revision 1.15  1998/11/16 14:48:28  dstef
 *      Changed MS-DOS charset description
 *      Added internal flag to disable bad messages about wrong translation
 *      Added UNIX man
 *
 *      Revision 1.14  1998/11/15 02:18:58  dstef
 *      Fixed backslash bug for user's help
 *
 *      Revision 1.13  1998/11/15 02:03:09  dstef
 *      Updated user's help
 *      Added case-insensitive BM search
 *      Added detection of HTML document
 *      Changed encoding names
 *      Added description about additions of new encodings
 *      Added russian encoding KOI-7 as true example
 *      Added option -p (add charset field for HTML file)
 *
 *      Revision 1.12  1998/11/14 01:57:41  dstef
 *      Changed auto detection for input encoding
 *      Changed program help to UNIX man style
 *
 *      Revision 1.11  1998/11/13 03:29:58  dstef
 *      Minor corrections
 *
 *      Revision 1.10  1998/11/13 03:27:18  dstef
 *      Added auto detection of encoding for input file
 *
 *      Revision 1.9  1998/11/04 12:47:31  dstef
 *      Fixed UNIX command line parsing
 *
 *      Revision 1.8  1998/11/01 01:00:12  dstef
 *      Added RCS marker
 *
 *      Revision 1.7  1998/10/27 22:29:30  dstef
 *      Fixed Win32 opendir bug with wildcards
 *      Added replace option for charset in HTML files
 *      Changed pointer arithmetic for MS-DOS
 *
 *      Revision 1.6  1998/10/25 01:51:24  dstef
 *      Added support for Microsoft Visual C v1.5x
 *
 *      Revision 1.5  1998/10/24 21:22:45  dstef
 *      Updated BM search functions
 *      Added compile instructions
 *
 *      Revision 1.4  1998/10/23 04:25:41  dstef
 *      Broot-force search replaced by Boyer-Moore search algorithm
 *      Updated program description
 *
 *      Revision 1.3  1998/10/21 21:25:58  dstef
 *      Added conversion tables (win,koi8,alt)
 *
 *      Revision 1.2  1998/10/21 00:42:07  dstef
 *      Revised file copy implementation
 *      Added very simple code to replace 'charset='
 *
 *      Revision 1.1  1998/10/19 01:39:41  dstef
 *      Initial revision
 *
 *****************************************************************************/



/*-------------------------- Notes and Warnings ----------------------------*/
/*

 WARNINGS:
  1. MS-DOS has a limitation in 64K for replace operations
     due of pointer arithmetic.

 NOTES:
  1. Use additional switch _DEBUGOUT to print out statistics tables.

  STEPS TO ADD NEXT ENCODING:
  1. Define constant <cpXXXX>.
  2. Change constant <cpMAXCOUNT> to new value of <cpXXX> because
     <cpMAXCOUNT> must be an upper boundary in the arrays or structures.
  3. Add next item to structure <g_EncodeNameTypes>.
  4. Add items to structure <g_CodeChrTable> as defined in source.
  5. Define your static conversion tables like <g_Mac2AltCharTable>.
  6. Add wanted translations to structure <g_ConvertTables>.
  7. Update program help about new available encoding.
  8. Now recompile and run.
  See as example russian encoding <KOI7>.
*/



/*-------------------------- Check for platforms ---------------------------*/
#ifndef _MSDOS
#ifndef _WIN32
#ifndef _UNIX
#error Select complier/platform: _MSDOS, _WIN32, _UNIX
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
#include <direct.h>                         /* Compatibilty */
#endif                                      /* #if defined(_WIN32) */
#include <stdio.h>                          /* I/O standard streams */
#include <stdlib.h>                         /* Miscellaneous common functions */
#include <ctype.h>                          /* Character conversion */
#if ( (defined(_MSDOS) && !defined(_MSVC)) || defined(_UNIX) )
#include <dirent.h>                         /* Posix directory operations */
#endif                                      /* #if ( defined(_MSDOS) || defined(_UNIX) ) */
#if defined(_MSDOS)
#include <dos.h>                            /* MS-DOS specific functions */
#if defined(_MSVC)
#include <direct.h>                         /* Compatibilty */
#include <malloc.h>                         /* Memory control */
#else
#include <dir.h>                            /* Directory access */
#include <alloc.h>                          /* Memory control */
#endif                                      /* #if defined(_MSVC) */
#endif                                      /* #if defined(_MSDOS) */
#include <string.h>                         /* String and memory operations */
#if defined(_UNIX)
#include <sys/stat.h>                       /* File status info */
#else
#include <sys\stat.h>
#endif                                      /* #if defined(_UNIX) */
#if defined(_WIN32)
#include <sys\utime.h>                      /* Universal time */
#else
#if defined(_MSVC)
#include <sys/utime.h>
#else
#include <utime.h>
#endif                                      /* #if defined(_MSVC) */
#endif                                      /* #if defined(_WIN32) */



/*------------------------------- Description ------------------------------*/
const char  g_ProgramName[]       =   "ChrCnv";
const char  g_ProgramVersion[]    =   "v1.55";
const char  g_CopyrightNotice[]   =   "Copyright (c) 1998,2000";
const char  g_Author[]            =   "Dmitry Stefankov";



/*------------------------------- Return Codes -----------------------------*/
#define   ERROR_DONE                 0     /* Running is successful        */
#define   ERROR_BAD_PARAMETER        1     /* Bad user supplied parameter  */
#define   ERROR_NO_OUTDIR            2     /* No output directory          */
#define   ERROR_NO_ENCTYPE           3     /* No encoding type             */
#define   ERROR_BAD_MEMSIZ           4     /* Wrong reserve memory size    */
#define   ERROR_NO_CHARSET           5     /* No charset to replace        */
#define   ERROR_FAIL_MAKE_CNVTBL     6     /* Cannot make conversion table */
#define   ERROR_SAME_ENCODING_IN_OUT 7     /* Same encoding for input and output */
#define   ERROR_USER_HELP_OUTPUT   255     /* Output user help message     */



/*----------------------------- Miscellaneous ------------------------------*/
#define   QUOTA                    0x22     /* Quatation mark */
#define   BACKSLASH                0x5C     /* Backslash */

#define   FMASKS_MAX                30       /* Available masks */
#if defined(_MSDOS)
#define   MAX_FILENAME_SIZE        80+1     /* UNIX compatibility */
#define   FILE_SIZE_LIMIT          62000L   /* Add/replace options */
#else
#define   MAX_FILENAME_SIZE        255+1    /* UNIX compatibility */
#endif                                      /* #if defined(_MSDOS) */
#define   MAX_RW_SIZE              16384    /* 16K */

#define   INTEL_SMALLSEG_SIZE      65536L   /* 64K */
#define   INTEL_PARA_SIZE          16       /* 16 bytes */
#define   INTEL_SEG_ADD            4096     /* 65536 / 16 */

#define   MAX_TEXTLINE_SIZE        4096     /* Upper limit */
#define   DEF_WORKLINE_SIZE        80       /* Text line buffer */

#define   MIN_RESERVE_MEMSIZ       1        /* Lower limit */
#define   DEF_RESERVE_MEMSIZ       1024     /* Default values */
#define   MAX_RESERVE_MEMSIZ       8192     /* Lower limit */

#define   cpNone                   0        /* None encoding */
#define   cpWindows1251            1        /* Windows-1251 code page */
#define   cpKoi8R                  2        /* UNIX KOI8-r code page */
#define   cpMsdos866               3        /* MS-DOS 866 code page */
#define   cpIso8859                4        /* ISO 8850-5 code page */
#define   cpMacR                   5        /* Macintosh (PPC) code page */
#if defined(_KOI7)
#define   cpKoi7R                  6        /* Primary russian encoding */
#define   cpMAXCOUNT               cpKoi7R
#else
#define   cpMAXCOUNT               cpMacR   /* Upper bound */
#endif                                      /* #if defined(_KOI7) */

#define   RUS_ALPHABET_SIZE        33*2+2   /* Russian letters and symbols */
#define   MAX_CTABLE_SIZE          256      /* Character set table */

#if (defined(_WIN32) || defined(_MSVC))
#define   DIRMAGIC                  0xDD    /* Borland C compatibilty */
#define   EBADF                     6       /* Bad file number */
#define   ENOMEM                    8       /* Not enough core */
#define   ENOENT                    2       /* No such file or directory*/
#endif                                      /* #if (defined(_WIN32) || defined(_MSVC)) */



/*------------------------- Character constants ----------------------------*/
const char  g_szHTML[]                 =  "<html>";
const char  g_szHtmlHeadBeg[]          =  "<head>";
const char  g_szHtmlHeadEnd[]          =  "</head>";
const char  g_szCharSet[]              =  "charset=";



/*----------------------------- Structures ---------------------------------*/
struct  tnode
{
  int   tinenc;                             /* Input encoding */
  int   toutenc;                            /* Output encoding */
  unsigned char  *ptable;                   /* Conversion table */
};

struct  bmtable                             /* Boyer-Moore table */
{
   unsigned char  chrtbl[MAX_CTABLE_SIZE];
};
typedef  struct bmtable *  pbmtable;

struct  encsym                              /* Element of vector */
{
   unsigned char  encodetype;               /* Encoding type */
   unsigned char  symcode;                  /* Symbol for letter */
};

struct  encvec                              /* Encoding vector */
{
   struct encsym    symvec[cpMAXCOUNT];    /* Vector for encodings */
};

struct encmatrix                            /* Encoding matrix */
{
     struct encvec  symbolmatrix[RUS_ALPHABET_SIZE];
};

struct  cnvtable                            /* Conversion table */
{
  unsigned char  convtable[MAX_CTABLE_SIZE];
};
typedef struct cnvtable *  pctable;

struct  freqtable                            /* Symbol frequency table */
{
  unsigned long int  frqtbl[MAX_CTABLE_SIZE];
};
typedef struct freqtable * pfreqtable;

struct  encfreq
{
  unsigned char      encodetype;            /* Encoding type */
  unsigned long int  encodefreqcount;       /* Frequency count */
  double             encratio;              /* Estimated ratio */
  double             encfinal;              /* Estimated ratio */
};

struct  encfreqvec
{
  struct encfreq  encfvec[cpMAXCOUNT];      /* Vector of encodings */
};
typedef struct encfreqvec *  pencfreqvec;

struct  encdef
{
  unsigned char   encodetype;               /* Encoding type */
  unsigned char   encodepresence;           /* Flag of encoding presence */
  int             encodeindex;              /* Index of symbol in alphabet */
};

struct  codevec
{
  unsigned char   charcode;                 /* Character code */
  unsigned char   encnum;                   /* Encodings for this char */
  struct encdef   encenum[cpMAXCOUNT];      /* List of encodings */
};

struct  codematrix                          /* Encodings matrix for charcodes */
{
  struct codevec  codetable[MAX_CTABLE_SIZE];
};
typedef struct codematrix *  pcodematrix;

struct  encdesc
{
  unsigned char   encodetype;               /* Encoding type */
  char *          encodename;               /* Description */
};

struct  encodevector
{
  struct encdesc  encodings[cpMAXCOUNT];    /* Vector of encodings */
};

struct  encrefsym                           /* Element of vector */
{
   unsigned char      encodetype;          /* Encoding type */
   unsigned long int  refsym[cpMAXCOUNT];  /* Frequency of combinations */
};

struct  encrefmatrix
{
  struct encrefsym   encreftbl[cpMAXCOUNT];
};
typedef  struct encrefmatrix *  pencrefmatrix;

struct  MaskNode
{
    char *   pFilesMask;                    /* Filemask */
};

struct  FileSearchMasks
{
  struct MaskNode    sFileMasks[FMASKS_MAX];
};
typedef  struct FileSearchMasks  * pFileSearchMasks;

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
    struct dirent  d_dirent;                /* Filename part */
#endif                                      /* #if defined(_MSVC) */
    char           d_first;                 /* First file flag */
    unsigned char  d_magic;                 /* Magic cookie for verifying handle */
#if !defined(_MSVC)
    HANDLE        fileHandle;               /* Win32 classic object */
    WIN32_FIND_DATA  findData;              /* Win32 search structire */
#endif                                      /* #if !defined(_MSVC) */
} DIR;
#endif                                      /* #if defined(_WIN32) || defined(_MSVC)) */



/*----------------------------- RCS marker ---------------------------------*/
static char  rcsid[] = "$Id: chrcnv.c 1.27 2000/01/22 05:26:00 dstef Exp dstef $";



/*----------------------------- Global data --------------------------------*/
int   g_fVerbose                =   0;      /* Verbose output           */
int   g_iDebugLevel             =   0;      /* Debugging level          */
int   g_iRecursiveSearch        =   0;      /* Scan all subdirectories  */
int   g_iPrintFullName          =   0;      /* Print full filename      */
int   g_fWipeCharsetHTML        =   0;      /* Wipe charset encoding    */
int   g_iReplaceCharsetHTML     =   0;      /* Replace charset encoding */
int   g_iAddCharsetHTML         =   0;      /* Add charset encoding     */
int   g_iReserveMem             =   DEF_RESERVE_MEMSIZ;/* Reserve memory to replace */
int   g_iInputEncType           =   cpNone; /* Input encoding */
int   g_iOutputEncType          =   cpNone; /* Output encoding */
int   g_fAutoDetInEncType       =   0;      /* Auto detection of input encoding */
int   g_fSkipConversion         =   0;      /* Only detection of input encoding */
int   g_fCaseInSensitiveSrch    =   1;      /* Ignore character case */
int   g_fNoTranslationReqd      =   0;      /* No perform translation */
int   g_fIgnoreCaseInFilenames  =   0;      /* Ignore case in filenames */
int   g_iIncFilesMask           =   0;      /* Include to search        */
int   g_iExcFilesMask           =   0;      /* Include to search        */


/*
    Most popular russian letters (ibm866 encoding):
   "† ° ¢ £ § • ® © ™ ´ ¨ ≠ Æ Ø ‡ · ‚ „ Á Î Ï Ô"
    Very important!! Order must be same as g_CodeChrTable !!
*/
unsigned char   g_StdFrqRusAlphabet[RUS_ALPHABET_SIZE]  =  {
                     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                     1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1,
                     1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1,
                     0, 0                                  };
/*
   Russian alphabet is defined as follows (ibm866 encoding):
   "Ä Å Ç É Ñ Ö  Ü á à â ä ã å ç é è ê ë í ì î ï ñ ó ò ô ö õ ú ù û ü"
   "† ° ¢ £ § • Ò ¶ ß ® © ™ ´ ¨ ≠ Æ Ø ‡ · ‚ „ ‰ Á Ê Á Ë È Í Î Ï Ì Ó Ô"
   and last two symbols are: <number sign N%> and <hard space>
*/
struct  encmatrix  g_CodeChrTable = {{
#if !defined(_KOI7)
     {{ {cpWindows1251,0xC0}, {cpKoi8R,0xE1},{cpMsdos866,0x80}, {cpIso8859,0xB0}, {cpMacR,0x80} }},
     {{ {cpWindows1251,0xC1}, {cpKoi8R,0xE2},{cpMsdos866,0x81}, {cpIso8859,0xB1}, {cpMacR,0x81} }},
     {{ {cpWindows1251,0xC2}, {cpKoi8R,0xF7},{cpMsdos866,0x82}, {cpIso8859,0xB2}, {cpMacR,0x82} }},
     {{ {cpWindows1251,0xC3}, {cpKoi8R,0xE7},{cpMsdos866,0x83}, {cpIso8859,0xB3}, {cpMacR,0x83} }},
     {{ {cpWindows1251,0xC4}, {cpKoi8R,0xE4},{cpMsdos866,0x84}, {cpIso8859,0xB4}, {cpMacR,0x84} }},
     {{ {cpWindows1251,0xC5}, {cpKoi8R,0xE5},{cpMsdos866,0x85}, {cpIso8859,0xB5}, {cpMacR,0x85} }},
     {{ {cpWindows1251,0xA8}, {cpKoi8R,0xB3},{cpMsdos866,0xF0}, {cpIso8859,0xA1}, {cpMacR,0xDD} }},
     {{ {cpWindows1251,0xC6}, {cpKoi8R,0xF6},{cpMsdos866,0x86}, {cpIso8859,0xB6}, {cpMacR,0x86} }},
     {{ {cpWindows1251,0xC7}, {cpKoi8R,0xFA},{cpMsdos866,0x87}, {cpIso8859,0xB7}, {cpMacR,0x87} }},
     {{ {cpWindows1251,0xC8}, {cpKoi8R,0xE9},{cpMsdos866,0x88}, {cpIso8859,0xB8}, {cpMacR,0x88} }},
     {{ {cpWindows1251,0xC9}, {cpKoi8R,0xEA},{cpMsdos866,0x89}, {cpIso8859,0xB9}, {cpMacR,0x89} }},
     {{ {cpWindows1251,0xCA}, {cpKoi8R,0xEB},{cpMsdos866,0x8A}, {cpIso8859,0xBA}, {cpMacR,0x8A} }},
     {{ {cpWindows1251,0xCB}, {cpKoi8R,0xEC},{cpMsdos866,0x8B}, {cpIso8859,0xBB}, {cpMacR,0x8B} }},
     {{ {cpWindows1251,0xCC}, {cpKoi8R,0xED},{cpMsdos866,0x8C}, {cpIso8859,0xBC}, {cpMacR,0x8C} }},
     {{ {cpWindows1251,0xCD}, {cpKoi8R,0xEE},{cpMsdos866,0x8D}, {cpIso8859,0xBD}, {cpMacR,0x8D} }},
     {{ {cpWindows1251,0xCE}, {cpKoi8R,0xEF},{cpMsdos866,0x8E}, {cpIso8859,0xBE}, {cpMacR,0x8E} }},
     {{ {cpWindows1251,0xCF}, {cpKoi8R,0xF0},{cpMsdos866,0x8F}, {cpIso8859,0xBF}, {cpMacR,0x8F} }},
     {{ {cpWindows1251,0xD0}, {cpKoi8R,0xF2},{cpMsdos866,0x90}, {cpIso8859,0xC0}, {cpMacR,0x90} }},
     {{ {cpWindows1251,0xD1}, {cpKoi8R,0xF3},{cpMsdos866,0x91}, {cpIso8859,0xC1}, {cpMacR,0x91} }},
     {{ {cpWindows1251,0xD2}, {cpKoi8R,0xF4},{cpMsdos866,0x92}, {cpIso8859,0xC2}, {cpMacR,0x92} }},
     {{ {cpWindows1251,0xD3}, {cpKoi8R,0xF5},{cpMsdos866,0x93}, {cpIso8859,0xC3}, {cpMacR,0x93} }},
     {{ {cpWindows1251,0xD4}, {cpKoi8R,0xE6},{cpMsdos866,0x94}, {cpIso8859,0xC4}, {cpMacR,0x94} }},
     {{ {cpWindows1251,0xD5}, {cpKoi8R,0xE8},{cpMsdos866,0x95}, {cpIso8859,0xC5}, {cpMacR,0x95} }},
     {{ {cpWindows1251,0xD6}, {cpKoi8R,0xE3},{cpMsdos866,0x96}, {cpIso8859,0xC6}, {cpMacR,0x96} }},
     {{ {cpWindows1251,0xD7}, {cpKoi8R,0xFE},{cpMsdos866,0x97}, {cpIso8859,0xC7}, {cpMacR,0x97} }},
     {{ {cpWindows1251,0xD8}, {cpKoi8R,0xFB},{cpMsdos866,0x98}, {cpIso8859,0xC8}, {cpMacR,0x98} }},
     {{ {cpWindows1251,0xD9}, {cpKoi8R,0xFD},{cpMsdos866,0x99}, {cpIso8859,0xC9}, {cpMacR,0x99} }},
     {{ {cpWindows1251,0xDA}, {cpKoi8R,0xFF},{cpMsdos866,0x9A}, {cpIso8859,0xCA}, {cpMacR,0x9A} }},
     {{ {cpWindows1251,0xDB}, {cpKoi8R,0xF9},{cpMsdos866,0x9B}, {cpIso8859,0xCB}, {cpMacR,0x9B} }},
     {{ {cpWindows1251,0xDC}, {cpKoi8R,0xF8},{cpMsdos866,0x9C}, {cpIso8859,0xCC}, {cpMacR,0x9C} }},
     {{ {cpWindows1251,0xDD}, {cpKoi8R,0xFC},{cpMsdos866,0x9D}, {cpIso8859,0xCD}, {cpMacR,0x9D} }},
     {{ {cpWindows1251,0xDE}, {cpKoi8R,0xE0},{cpMsdos866,0x9E}, {cpIso8859,0xCE}, {cpMacR,0x9E} }},
     {{ {cpWindows1251,0xDF}, {cpKoi8R,0xF1},{cpMsdos866,0x9F}, {cpIso8859,0xCF}, {cpMacR,0x9F} }},
     {{ {cpWindows1251,0xE0}, {cpKoi8R,0xC1},{cpMsdos866,0xA0}, {cpIso8859,0xD0}, {cpMacR,0xE0} }},
     {{ {cpWindows1251,0xE1}, {cpKoi8R,0xC2},{cpMsdos866,0xA1}, {cpIso8859,0xD1}, {cpMacR,0xE1} }},
     {{ {cpWindows1251,0xE2}, {cpKoi8R,0xD7},{cpMsdos866,0xA2}, {cpIso8859,0xD2}, {cpMacR,0xE2} }},
     {{ {cpWindows1251,0xE3}, {cpKoi8R,0xC7},{cpMsdos866,0xA3}, {cpIso8859,0xD3}, {cpMacR,0xE3} }},
     {{ {cpWindows1251,0xE4}, {cpKoi8R,0xC4},{cpMsdos866,0xA4}, {cpIso8859,0xD4}, {cpMacR,0xE4} }},
     {{ {cpWindows1251,0xE5}, {cpKoi8R,0xC5},{cpMsdos866,0xA5}, {cpIso8859,0xD5}, {cpMacR,0xE5} }},
     {{ {cpWindows1251,0xB8}, {cpKoi8R,0xA3},{cpMsdos866,0xF1}, {cpIso8859,0xF1}, {cpMacR,0xDE} }},
     {{ {cpWindows1251,0xE6}, {cpKoi8R,0xD6},{cpMsdos866,0xA6}, {cpIso8859,0xD6}, {cpMacR,0xE6} }},
     {{ {cpWindows1251,0xE7}, {cpKoi8R,0xDA},{cpMsdos866,0xA7}, {cpIso8859,0xD7}, {cpMacR,0xE7} }},
     {{ {cpWindows1251,0xE8}, {cpKoi8R,0xC9},{cpMsdos866,0xA8}, {cpIso8859,0xD8}, {cpMacR,0xE8} }},
     {{ {cpWindows1251,0xE9}, {cpKoi8R,0xCA},{cpMsdos866,0xA9}, {cpIso8859,0xD9}, {cpMacR,0xE9} }},
     {{ {cpWindows1251,0xEA}, {cpKoi8R,0xCB},{cpMsdos866,0xAA}, {cpIso8859,0xDA}, {cpMacR,0xEA} }},
     {{ {cpWindows1251,0xEB}, {cpKoi8R,0xCC},{cpMsdos866,0xAB}, {cpIso8859,0xDB}, {cpMacR,0xEB} }},
     {{ {cpWindows1251,0xEC}, {cpKoi8R,0xCD},{cpMsdos866,0xAC}, {cpIso8859,0xDC}, {cpMacR,0xEC} }},
     {{ {cpWindows1251,0xED}, {cpKoi8R,0xCE},{cpMsdos866,0xAD}, {cpIso8859,0xDD}, {cpMacR,0xED} }},
     {{ {cpWindows1251,0xEE}, {cpKoi8R,0xCF},{cpMsdos866,0xAE}, {cpIso8859,0xDE}, {cpMacR,0xEE} }},
     {{ {cpWindows1251,0xEF}, {cpKoi8R,0xD0},{cpMsdos866,0xAF}, {cpIso8859,0xDF}, {cpMacR,0xEF} }},
     {{ {cpWindows1251,0xF0}, {cpKoi8R,0xD2},{cpMsdos866,0xE0}, {cpIso8859,0xE0}, {cpMacR,0xF0} }},
     {{ {cpWindows1251,0xF1}, {cpKoi8R,0xD3},{cpMsdos866,0xE1}, {cpIso8859,0xE1}, {cpMacR,0xF1} }},
     {{ {cpWindows1251,0xF2}, {cpKoi8R,0xD4},{cpMsdos866,0xE2}, {cpIso8859,0xE2}, {cpMacR,0xF2} }},
     {{ {cpWindows1251,0xF3}, {cpKoi8R,0xD5},{cpMsdos866,0xE3}, {cpIso8859,0xE3}, {cpMacR,0xF3} }},
     {{ {cpWindows1251,0xF4}, {cpKoi8R,0xC6},{cpMsdos866,0xE4}, {cpIso8859,0xE4}, {cpMacR,0xF4} }},
     {{ {cpWindows1251,0xF5}, {cpKoi8R,0xC8},{cpMsdos866,0xE5}, {cpIso8859,0xE5}, {cpMacR,0xF5} }},
     {{ {cpWindows1251,0xF6}, {cpKoi8R,0xC3},{cpMsdos866,0xE6}, {cpIso8859,0xE6}, {cpMacR,0xF6} }},
     {{ {cpWindows1251,0xF7}, {cpKoi8R,0xDE},{cpMsdos866,0xE7}, {cpIso8859,0xE7}, {cpMacR,0xF7} }},
     {{ {cpWindows1251,0xF8}, {cpKoi8R,0xDB},{cpMsdos866,0xE8}, {cpIso8859,0xE8}, {cpMacR,0xF8} }},
     {{ {cpWindows1251,0xF9}, {cpKoi8R,0xDD},{cpMsdos866,0xE9}, {cpIso8859,0xE9}, {cpMacR,0xF9} }},
     {{ {cpWindows1251,0xFA}, {cpKoi8R,0xDF},{cpMsdos866,0xEA}, {cpIso8859,0xEA}, {cpMacR,0xFA} }},
     {{ {cpWindows1251,0xFB}, {cpKoi8R,0xD9},{cpMsdos866,0xEB}, {cpIso8859,0xEB}, {cpMacR,0xFB} }},
     {{ {cpWindows1251,0xFC}, {cpKoi8R,0xD8},{cpMsdos866,0xEC}, {cpIso8859,0xEC}, {cpMacR,0xFC} }},
     {{ {cpWindows1251,0xFD}, {cpKoi8R,0xDC},{cpMsdos866,0xED}, {cpIso8859,0xED}, {cpMacR,0xFD} }},
     {{ {cpWindows1251,0xFE}, {cpKoi8R,0xC0},{cpMsdos866,0xEE}, {cpIso8859,0xEE}, {cpMacR,0xFE} }},
     {{ {cpWindows1251,0xFF}, {cpKoi8R,0xD1},{cpMsdos866,0xEF}, {cpIso8859,0xEF}, {cpMacR,0xDF} }},
     {{ {cpWindows1251,0xB9}, {cpKoi8R,0xBE},{cpMsdos866,0xFC}, {cpIso8859,0xF0}, {cpMacR,0xDC} }},
     {{ {cpWindows1251,0xA0}, {cpKoi8R,0xA0},{cpMsdos866,0xFF}, {cpIso8859,0xA0}, {cpMacR,0xCA} }}
#else
     {{ {cpWindows1251,0xC0}, {cpKoi8R,0xE1},{cpMsdos866,0x80}, {cpIso8859,0xB0}, {cpMacR,0x80}, {cpKoi7R,0x61} }},
     {{ {cpWindows1251,0xC1}, {cpKoi8R,0xE2},{cpMsdos866,0x81}, {cpIso8859,0xB1}, {cpMacR,0x81}, {cpKoi7R,0x62} }},
     {{ {cpWindows1251,0xC2}, {cpKoi8R,0xF7},{cpMsdos866,0x82}, {cpIso8859,0xB2}, {cpMacR,0x82}, {cpKoi7R,0x77} }},
     {{ {cpWindows1251,0xC3}, {cpKoi8R,0xE7},{cpMsdos866,0x83}, {cpIso8859,0xB3}, {cpMacR,0x83}, {cpKoi7R,0x67} }},
     {{ {cpWindows1251,0xC4}, {cpKoi8R,0xE4},{cpMsdos866,0x84}, {cpIso8859,0xB4}, {cpMacR,0x84}, {cpKoi7R,0x64} }},
     {{ {cpWindows1251,0xC5}, {cpKoi8R,0xE5},{cpMsdos866,0x85}, {cpIso8859,0xB5}, {cpMacR,0x85}, {cpKoi7R,0x65} }},
     {{ {cpWindows1251,0xA8}, {cpKoi8R,0xB3},{cpMsdos866,0xF0}, {cpIso8859,0xA1}, {cpMacR,0xDD}, {cpKoi7R,0x33} }},
     {{ {cpWindows1251,0xC6}, {cpKoi8R,0xF6},{cpMsdos866,0x86}, {cpIso8859,0xB6}, {cpMacR,0x86}, {cpKoi7R,0x76} }},
     {{ {cpWindows1251,0xC7}, {cpKoi8R,0xFA},{cpMsdos866,0x87}, {cpIso8859,0xB7}, {cpMacR,0x87}, {cpKoi7R,0x7A} }},
     {{ {cpWindows1251,0xC8}, {cpKoi8R,0xE9},{cpMsdos866,0x88}, {cpIso8859,0xB8}, {cpMacR,0x88}, {cpKoi7R,0x69} }},
     {{ {cpWindows1251,0xC9}, {cpKoi8R,0xEA},{cpMsdos866,0x89}, {cpIso8859,0xB9}, {cpMacR,0x89}, {cpKoi7R,0x6A} }},
     {{ {cpWindows1251,0xCA}, {cpKoi8R,0xEB},{cpMsdos866,0x8A}, {cpIso8859,0xBA}, {cpMacR,0x8A}, {cpKoi7R,0x6B} }},
     {{ {cpWindows1251,0xCB}, {cpKoi8R,0xEC},{cpMsdos866,0x8B}, {cpIso8859,0xBB}, {cpMacR,0x8B}, {cpKoi7R,0x6C} }},
     {{ {cpWindows1251,0xCC}, {cpKoi8R,0xED},{cpMsdos866,0x8C}, {cpIso8859,0xBC}, {cpMacR,0x8C}, {cpKoi7R,0x6D} }},
     {{ {cpWindows1251,0xCD}, {cpKoi8R,0xEE},{cpMsdos866,0x8D}, {cpIso8859,0xBD}, {cpMacR,0x8D}, {cpKoi7R,0x6E} }},
     {{ {cpWindows1251,0xCE}, {cpKoi8R,0xEF},{cpMsdos866,0x8E}, {cpIso8859,0xBE}, {cpMacR,0x8E}, {cpKoi7R,0x6F} }},
     {{ {cpWindows1251,0xCF}, {cpKoi8R,0xF0},{cpMsdos866,0x8F}, {cpIso8859,0xBF}, {cpMacR,0x8F}, {cpKoi7R,0x70} }},
     {{ {cpWindows1251,0xD0}, {cpKoi8R,0xF2},{cpMsdos866,0x90}, {cpIso8859,0xC0}, {cpMacR,0x90}, {cpKoi7R,0x72} }},
     {{ {cpWindows1251,0xD1}, {cpKoi8R,0xF3},{cpMsdos866,0x91}, {cpIso8859,0xC1}, {cpMacR,0x91}, {cpKoi7R,0x73} }},
     {{ {cpWindows1251,0xD2}, {cpKoi8R,0xF4},{cpMsdos866,0x92}, {cpIso8859,0xC2}, {cpMacR,0x92}, {cpKoi7R,0x74} }},
     {{ {cpWindows1251,0xD3}, {cpKoi8R,0xF5},{cpMsdos866,0x93}, {cpIso8859,0xC3}, {cpMacR,0x93}, {cpKoi7R,0x75} }},
     {{ {cpWindows1251,0xD4}, {cpKoi8R,0xE6},{cpMsdos866,0x94}, {cpIso8859,0xC4}, {cpMacR,0x94}, {cpKoi7R,0x66} }},
     {{ {cpWindows1251,0xD5}, {cpKoi8R,0xE8},{cpMsdos866,0x95}, {cpIso8859,0xC5}, {cpMacR,0x95}, {cpKoi7R,0x68} }},
     {{ {cpWindows1251,0xD6}, {cpKoi8R,0xE3},{cpMsdos866,0x96}, {cpIso8859,0xC6}, {cpMacR,0x96}, {cpKoi7R,0x63} }},
     {{ {cpWindows1251,0xD7}, {cpKoi8R,0xFE},{cpMsdos866,0x97}, {cpIso8859,0xC7}, {cpMacR,0x97}, {cpKoi7R,0x7E} }},
     {{ {cpWindows1251,0xD8}, {cpKoi8R,0xFB},{cpMsdos866,0x98}, {cpIso8859,0xC8}, {cpMacR,0x98}, {cpKoi7R,0x7B} }},
     {{ {cpWindows1251,0xD9}, {cpKoi8R,0xFD},{cpMsdos866,0x99}, {cpIso8859,0xC9}, {cpMacR,0x99}, {cpKoi7R,0x7D} }},
     {{ {cpWindows1251,0xDA}, {cpKoi8R,0xFF},{cpMsdos866,0x9A}, {cpIso8859,0xCA}, {cpMacR,0x9A}, {cpKoi7R,0x7F} }},
     {{ {cpWindows1251,0xDB}, {cpKoi8R,0xF9},{cpMsdos866,0x9B}, {cpIso8859,0xCB}, {cpMacR,0x9B}, {cpKoi7R,0x79} }},
     {{ {cpWindows1251,0xDC}, {cpKoi8R,0xF8},{cpMsdos866,0x9C}, {cpIso8859,0xCC}, {cpMacR,0x9C}, {cpKoi7R,0x78} }},
     {{ {cpWindows1251,0xDD}, {cpKoi8R,0xFC},{cpMsdos866,0x9D}, {cpIso8859,0xCD}, {cpMacR,0x9D}, {cpKoi7R,0x7C} }},
     {{ {cpWindows1251,0xDE}, {cpKoi8R,0xE0},{cpMsdos866,0x9E}, {cpIso8859,0xCE}, {cpMacR,0x9E}, {cpKoi7R,0x60} }},
     {{ {cpWindows1251,0xDF}, {cpKoi8R,0xF1},{cpMsdos866,0x9F}, {cpIso8859,0xCF}, {cpMacR,0x9F}, {cpKoi7R,0x71} }},
     {{ {cpWindows1251,0xE0}, {cpKoi8R,0xC1},{cpMsdos866,0xA0}, {cpIso8859,0xD0}, {cpMacR,0xE0}, {cpKoi7R,0x41} }},
     {{ {cpWindows1251,0xE1}, {cpKoi8R,0xC2},{cpMsdos866,0xA1}, {cpIso8859,0xD1}, {cpMacR,0xE1}, {cpKoi7R,0x42} }},
     {{ {cpWindows1251,0xE2}, {cpKoi8R,0xD7},{cpMsdos866,0xA2}, {cpIso8859,0xD2}, {cpMacR,0xE2}, {cpKoi7R,0x57} }},
     {{ {cpWindows1251,0xE3}, {cpKoi8R,0xC7},{cpMsdos866,0xA3}, {cpIso8859,0xD3}, {cpMacR,0xE3}, {cpKoi7R,0x47} }},
     {{ {cpWindows1251,0xE4}, {cpKoi8R,0xC4},{cpMsdos866,0xA4}, {cpIso8859,0xD4}, {cpMacR,0xE4}, {cpKoi7R,0x44} }},
     {{ {cpWindows1251,0xE5}, {cpKoi8R,0xC5},{cpMsdos866,0xA5}, {cpIso8859,0xD5}, {cpMacR,0xE5}, {cpKoi7R,0x45} }},
     {{ {cpWindows1251,0xB8}, {cpKoi8R,0xA3},{cpMsdos866,0xF1}, {cpIso8859,0xF1}, {cpMacR,0xDE}, {cpKoi7R,0x23} }},
     {{ {cpWindows1251,0xE6}, {cpKoi8R,0xD6},{cpMsdos866,0xA6}, {cpIso8859,0xD6}, {cpMacR,0xE6}, {cpKoi7R,0x56} }},
     {{ {cpWindows1251,0xE7}, {cpKoi8R,0xDA},{cpMsdos866,0xA7}, {cpIso8859,0xD7}, {cpMacR,0xE7}, {cpKoi7R,0x5A} }},
     {{ {cpWindows1251,0xE8}, {cpKoi8R,0xC9},{cpMsdos866,0xA8}, {cpIso8859,0xD8}, {cpMacR,0xE8}, {cpKoi7R,0x49} }},
     {{ {cpWindows1251,0xE9}, {cpKoi8R,0xCA},{cpMsdos866,0xA9}, {cpIso8859,0xD9}, {cpMacR,0xE9}, {cpKoi7R,0x4A} }},
     {{ {cpWindows1251,0xEA}, {cpKoi8R,0xCB},{cpMsdos866,0xAA}, {cpIso8859,0xDA}, {cpMacR,0xEA}, {cpKoi7R,0x4B} }},
     {{ {cpWindows1251,0xEB}, {cpKoi8R,0xCC},{cpMsdos866,0xAB}, {cpIso8859,0xDB}, {cpMacR,0xEB}, {cpKoi7R,0x4C} }},
     {{ {cpWindows1251,0xEC}, {cpKoi8R,0xCD},{cpMsdos866,0xAC}, {cpIso8859,0xDC}, {cpMacR,0xEC}, {cpKoi7R,0x4D} }},
     {{ {cpWindows1251,0xED}, {cpKoi8R,0xCE},{cpMsdos866,0xAD}, {cpIso8859,0xDD}, {cpMacR,0xED}, {cpKoi7R,0x4E} }},
     {{ {cpWindows1251,0xEE}, {cpKoi8R,0xCF},{cpMsdos866,0xAE}, {cpIso8859,0xDE}, {cpMacR,0xEE}, {cpKoi7R,0x4F} }},
     {{ {cpWindows1251,0xEF}, {cpKoi8R,0xD0},{cpMsdos866,0xAF}, {cpIso8859,0xDF}, {cpMacR,0xEF}, {cpKoi7R,0x50} }},
     {{ {cpWindows1251,0xF0}, {cpKoi8R,0xD2},{cpMsdos866,0xE0}, {cpIso8859,0xE0}, {cpMacR,0xF0}, {cpKoi7R,0x52} }},
     {{ {cpWindows1251,0xF1}, {cpKoi8R,0xD3},{cpMsdos866,0xE1}, {cpIso8859,0xE1}, {cpMacR,0xF1}, {cpKoi7R,0x53} }},
     {{ {cpWindows1251,0xF2}, {cpKoi8R,0xD4},{cpMsdos866,0xE2}, {cpIso8859,0xE2}, {cpMacR,0xF2}, {cpKoi7R,0x54} }},
     {{ {cpWindows1251,0xF3}, {cpKoi8R,0xD5},{cpMsdos866,0xE3}, {cpIso8859,0xE3}, {cpMacR,0xF3}, {cpKoi7R,0x55} }},
     {{ {cpWindows1251,0xF4}, {cpKoi8R,0xC6},{cpMsdos866,0xE4}, {cpIso8859,0xE4}, {cpMacR,0xF4}, {cpKoi7R,0x46} }},
     {{ {cpWindows1251,0xF5}, {cpKoi8R,0xC8},{cpMsdos866,0xE5}, {cpIso8859,0xE5}, {cpMacR,0xF5}, {cpKoi7R,0x48} }},
     {{ {cpWindows1251,0xF6}, {cpKoi8R,0xC3},{cpMsdos866,0xE6}, {cpIso8859,0xE6}, {cpMacR,0xF6}, {cpKoi7R,0x43} }},
     {{ {cpWindows1251,0xF7}, {cpKoi8R,0xDE},{cpMsdos866,0xE7}, {cpIso8859,0xE7}, {cpMacR,0xF7}, {cpKoi7R,0x5E} }},
     {{ {cpWindows1251,0xF8}, {cpKoi8R,0xDB},{cpMsdos866,0xE8}, {cpIso8859,0xE8}, {cpMacR,0xF8}, {cpKoi7R,0x5B} }},
     {{ {cpWindows1251,0xF9}, {cpKoi8R,0xDD},{cpMsdos866,0xE9}, {cpIso8859,0xE9}, {cpMacR,0xF9}, {cpKoi7R,0x5D} }},
     {{ {cpWindows1251,0xFA}, {cpKoi8R,0xDF},{cpMsdos866,0xEA}, {cpIso8859,0xEA}, {cpMacR,0xFA}, {cpKoi7R,0x5F} }},
     {{ {cpWindows1251,0xFB}, {cpKoi8R,0xD9},{cpMsdos866,0xEB}, {cpIso8859,0xEB}, {cpMacR,0xFB}, {cpKoi7R,0x59} }},
     {{ {cpWindows1251,0xFC}, {cpKoi8R,0xD8},{cpMsdos866,0xEC}, {cpIso8859,0xEC}, {cpMacR,0xFC}, {cpKoi7R,0x58} }},
     {{ {cpWindows1251,0xFD}, {cpKoi8R,0xDC},{cpMsdos866,0xED}, {cpIso8859,0xED}, {cpMacR,0xFD}, {cpKoi7R,0x5C} }},
     {{ {cpWindows1251,0xFE}, {cpKoi8R,0xC0},{cpMsdos866,0xEE}, {cpIso8859,0xEE}, {cpMacR,0xFE}, {cpKoi7R,0x40} }},
     {{ {cpWindows1251,0xFF}, {cpKoi8R,0xD1},{cpMsdos866,0xEF}, {cpIso8859,0xEF}, {cpMacR,0xDF}, {cpKoi7R,0x51} }},
     {{ {cpWindows1251,0xB9}, {cpKoi8R,0xBE},{cpMsdos866,0xFC}, {cpIso8859,0xF0}, {cpMacR,0xDC}, {cpKoi7R,0x3E} }},
     {{ {cpWindows1251,0xA0}, {cpKoi8R,0xA0},{cpMsdos866,0xFF}, {cpIso8859,0xA0}, {cpMacR,0xCA}, {cpKoi7R,0x20} }}
#endif                                      /* #if defined(_KOI7) */
                                    }};

unsigned char   g_DefCharTable[MAX_CTABLE_SIZE]   =
{
    0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,    /*  ........  */
    0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,    /*  ........  */
    0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,    /*  ........  */
    0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F,    /*  ........  */
    0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,    /*   !"#$%&'  */
    0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F,    /*  ()*+,-./  */
    0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,    /*  01234567  */
    0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F,    /*  89:;<=>?  */
    0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,    /*  @ABCDEFG  */
    0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F,    /*  HIJKLMNO  */
    0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,    /*  PQRSTUVW  */
    0x58,0x59,0x5A,0x5B,0x5C,0x5D,0x5E,0x5F,    /*  XYZ[\]^_  */
    0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,    /*  `abcdefg  */
    0x68,0x69,0x6A,0x6B,0x6C,0x6D,0x6E,0x6F,    /*  hijklmno  */
    0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,    /*  pqrstuvw  */
    0x78,0x79,0x7A,0x7B,0x7C,0x7D,0x7E,0x7F,    /*  xyz{|}~.  */
    0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,    /*  ÄÅÇÉÑÖÜá  */
    0x88,0x89,0x8A,0x8B,0x8C,0x8D,0x8E,0x8F,    /*  àâäãåçéè  */
    0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97,    /*  êëíìîïñó  */
    0x98,0x99,0x9A,0x9B,0x9C,0x9D,0x9E,0x9F,    /*  òôöõúùûü  */
    0xA0,0xA1,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,    /*  †°¢£§•¶ß  */
    0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,    /*  ®©™´¨≠ÆØ  */
    0xB0,0xB1,0xB2,0xB3,0xB4,0xB5,0xB6,0xB7,    /*  ∞±≤≥¥µ∂∑  */
    0xB8,0xB9,0xBA,0xBB,0xBC,0xBD,0xBE,0xBF,    /*  ∏π∫ªºΩæø  */
    0xC0,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,    /*  ¿¡¬√ƒ≈∆«  */
    0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,    /*  »… ÀÃÕŒœ  */
    0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0xD7,    /*  –—“”‘’÷◊  */
    0xD8,0xD9,0xDA,0xDB,0xDC,0xDD,0xDE,0xDF,    /*  ÿŸ⁄€‹›ﬁﬂ  */
    0xE0,0xE1,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,    /*  ‡·‚„‰ÂÊÁ  */
    0xE8,0xE9,0xEA,0xEB,0xEC,0xED,0xEE,0xEF,    /*  ËÈÍÎÏÌÓÔ  */
    0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,    /*  ÒÚÛÙıˆ˜  */
    0xF8,0xF9,0xFA,0xFB,0xFC,0xFD,0xFE,0xFF     /*  ¯˘˙˚¸˝˛ˇ  */
};
                                            /* Enc-to-enc tables */
unsigned char   g_Win2Koi8CharTable[MAX_CTABLE_SIZE];
unsigned char   g_Win2AltCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Win2IsoCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Win2MacCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Alt2WinCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Alt2Koi8CharTable[MAX_CTABLE_SIZE];
unsigned char   g_Alt2IsoCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Alt2MacCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Koi82AltCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Koi82WinCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Koi82IsoCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Koi82MacCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Mac2WinCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Mac2Koi8CharTable[MAX_CTABLE_SIZE];
unsigned char   g_Mac2IsoCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Mac2AltCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Iso2WinCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Iso2Koi8CharTable[MAX_CTABLE_SIZE];
unsigned char   g_Iso2AltCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Iso2MacCharTable[MAX_CTABLE_SIZE];
#if defined(_KOI7)
unsigned char   g_Koi72AltCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Koi72WinCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Koi72IsoCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Koi72MacCharTable[MAX_CTABLE_SIZE];
unsigned char   g_Koi72Koi8CharTable[MAX_CTABLE_SIZE];
#endif                                      /* #if defined(_KOI7) */
                                            /* Translation matrix */
struct tnode  g_ConvertTables[] = {
          { cpNone,        cpNone,          g_DefCharTable      },
          { cpWindows1251, cpKoi8R,         g_Win2Koi8CharTable },
          { cpWindows1251, cpMsdos866,      g_Win2AltCharTable  },
          { cpWindows1251, cpIso8859,       g_Win2IsoCharTable  },
          { cpWindows1251, cpMacR,          g_Win2MacCharTable  },
          { cpKoi8R,       cpWindows1251,   g_Koi82WinCharTable },
          { cpKoi8R,       cpMsdos866,      g_Koi82AltCharTable },
          { cpKoi8R,       cpIso8859,       g_Koi82IsoCharTable },
          { cpKoi8R,       cpMacR,          g_Koi82MacCharTable },
          { cpMsdos866,    cpWindows1251,   g_Alt2WinCharTable  },
          { cpMsdos866,    cpKoi8R,         g_Alt2Koi8CharTable },
          { cpMsdos866,    cpIso8859,       g_Alt2IsoCharTable  },
          { cpMsdos866,    cpMacR,          g_Alt2MacCharTable  },
          { cpIso8859,    cpWindows1251,    g_Iso2WinCharTable  },
          { cpIso8859,    cpKoi8R,          g_Iso2Koi8CharTable },
          { cpIso8859,    cpMsdos866,       g_Iso2AltCharTable  },
          { cpIso8859,    cpMacR,           g_Iso2MacCharTable  },
          { cpMacR,       cpWindows1251,    g_Mac2WinCharTable  },
          { cpMacR,       cpKoi8R,          g_Mac2Koi8CharTable },
          { cpMacR,       cpMsdos866,       g_Mac2AltCharTable  },
          { cpMacR,       cpIso8859,        g_Mac2IsoCharTable  },
#if defined(_KOI7)
          { cpKoi7R,       cpWindows1251,   g_Koi72WinCharTable },
          { cpKoi7R,       cpMsdos866,      g_Koi72AltCharTable },
          { cpKoi7R,       cpIso8859,       g_Koi72IsoCharTable },
          { cpKoi7R,       cpMacR,          g_Koi72MacCharTable },
          { cpKoi7R,       cpKoi8R,         g_Koi72Koi8CharTable},
#endif                                      /* #if defined(_KOI7) */
          { -1,            -1,              NULL                }
                                                   };

struct  encodevector  g_EncodeNameTypes = { {
                            { cpWindows1251, "windows-1251" },
                            { cpKoi8R,       "koi8-r"},
                            { cpMsdos866,    "cp-866"},
                            { cpIso8859,     "iso-8859-5"},
                            { cpMacR,        "x-mac-russian"}
#if defined(_KOI7)
                           ,{ cpKoi7R,       "koi7-r"}
#endif                                      /* #if defined(_KOI7) */
                                          } };

struct  codematrix  g_CodesVectorTable;     /* Encodings for char */

struct FileSearchMasks    g_sIncFileMasks;  /* Inclusion filemasks */
struct FileSearchMasks    g_sExcFileMasks;  /* Exclusion filemasks */



/*---------------------------- Error Messages ------------------------------*/
const char  g_szNoMemForExcFMask[]  =
                     "WARNING: insufficient memory for excluding filemask.";
const char  g_szNoMemForIncFMask[]  =
                     "WARNING: insufficient memory for including filemask.";



/*------------------------- Function Prototype -----------------------------*/
unsigned long int ulParseDir( char *indirname, int maxdirlen,
                              pFileSearchMasks pIncFMasks,
                              pFileSearchMasks pExcFMasks, int iSearchDirs,
                              char *outdirname );
int  iTestDir( char *dirname );
int  iTestPattern( const char * szName, const char * szPattern );
int  iTestForFileMask( char *filename, pFileSearchMasks pFMasks,
                       int iFMasksCount );
int  AddFileMask( const char * pszAddMask, pFileSearchMasks pFMasks,
                  int * piFMasksCount, const char * pszErrMsg );
int  iTranslateFile( const char *szSrcFile, const char *szDstFile );
int  iTranslateBuf( unsigned char *buf, unsigned long int bufsize,
                    pctable ptbl );
void  initBMtable( unsigned char *buf, unsigned int bufsize, pbmtable ptbl,
                   int  ci );
unsigned char  *searchBufBM( unsigned char *sbuf, unsigned long int sbuflen,
                             pbmtable ptbl, unsigned char *patbuf,
                             unsigned int patlen, int  ci );
char *  safe_strncpy ( char *dest, const char *src, size_t maxlen );
char *  safe_strncat( char *dest, const char *src, size_t n );
#if (defined(_WIN32) || defined(_MSVC))
DIR *  opendir( char *dirname );
struct dirent *  readdir( DIR  *dir );
int   closedir( DIR  *dir );
#endif                                      /* #if (defined(_WIN32) || defined(_MSVC)) */
#if defined(_MSDOS)
void *  DosPtrInc( void *pmem, unsigned long int incsiz );
#endif                                      /* #if defined(_MSDOS) */
int  MakeConversionTable(int encIn, int encOut, pctable ptbl);
int  AutoDetBufEncoding( unsigned char *buf, unsigned long int bufsize );
unsigned char *  pDetectHTMLdoc( unsigned char * pbuf,
                                 unsigned long int buflen,
                                 pbmtable pbm, int icase );



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
    char  szOutDir[MAX_FILENAME_SIZE+1] = { "\0" };
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
  pTemp = (char *)rcsid;                    /* Just to avoid warnings */
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
#if defined(_UNIX)
     printf( "USAGE:\n" );
#endif                                      /* #if defined(_UNIX) */
#if !defined(_UNIX)
     printf( "\n" );
     printf( "CHRCNV(1)              General Commands Manual                        (1)\n" );
     printf( "\n" );
     printf( "NAME\n" );
     printf( "  chrcnv - smart cyrillic converter for file(s)\n" );
     printf( "\n" );
     printf( "SYNOPSIS\n" );
#endif                                      /* #if !defined(_UNIX) */
     printf( "   chrcnv  [-a] [-c] [-d] [[-e mask]..] [-f] [-g] [[-i mask]..] [-k]\n" );
     printf( "           [-l inenc] [-m resmemsiz] [-o outdir] [p] [-r outenc] [-s]\n" );
     printf( "            [-v] [-w] [-z] [dirname]\n" );
#if !defined(_UNIX)
     printf( "\n" );
     printf( "DESCRIPTION\n" );
     printf( "  CHRCNV converts the file(s) from one encoding to other encoding.\n" );
     printf( "  A primary purpose is to support the various russian encodings.\n" );
     printf( "  All conversions are made on a char-to-char translation basis.\n" );
     printf( "  Program is also automatically detected an encoding of input text\n" );
     printf( "  in most cases. It also recursively traverses through directories.\n" );
     printf( "  Manipulations with <charset> field for HTML-documents are provided\n" );
     printf( "  additional possibilities for Web-administrators.\n" );
     printf( "  The program works the following way: reads input, translates it,\n" );
     printf( "  processes HTML document (charset field operations), and writes output.\n" );
     printf( "\n" );
     printf( "OPTIONS\n" );
     printf( "  The options are as follows:\n" );
     printf( "  -a   Auto detection of input encoding for file.\n" );
     printf( "  -c   Replace charset according output encoding type.\n" );
     printf( "  -d   Debugging level.\n" );
     printf( "  -e mask\n" );
     printf( "       Exclude file(s) for search, wildcards are allowed (upto %d masks).\n", FMASKS_MAX );
     printf( "  -f   Print full filename.\n" );
     printf( "  -g   Ignore case in filename(s).\n" );
     printf( "  -i mask\n" );
     printf( "       Include file(s) for search, wildcards are allowed (upto %d masks).\n", FMASKS_MAX );
     printf( "  -k   Only detection of input encoding for file (no translation).\n" );
     printf( "  -l inenc\n" );
     printf( "       %d=no translation (default)\n", cpNone );
     printf( "       %d=windows-1251 (russian)\n", cpWindows1251 );
     printf( "       %d=koi8-r (russian).\n", cpKoi8R );
     printf( "       %d=cp-866 (russian).\n", cpMsdos866 );
     printf( "       %d=iso-8859-5 (russian).\n", cpIso8859 );
     printf( "       %d=mac (russian).\n", cpMacR );
#if defined(_KOI7)
     printf( "       %d=koi7-r (russian).\n", cpKoi7R );
#endif                                      /* #if defined(_KOI7) */
     printf( "  -m resmemsiz\n" );
     printf( "       Reserve memory to replace operations in bytes. Min=%d, max=%d.\n",
             MIN_RESERVE_MEMSIZ, MAX_RESERVE_MEMSIZ );
     printf( "  -o outdir\n" );
     printf( "       Directory to store the output file(s).\n" );
     printf( "  -p   Add charset according output encoding type.\n" );
     printf( "  -r outenc\n" );
     printf( "       Same as for input encoding type.\n" );
     printf( "  -s   Search also subdirectories.\n" );
     printf( "  -v   Verbose output.\n" );
     printf( "  -w   Wipe charset field in HTML headers.\n" );
     printf( "  -z   Disable case-insensitive search in file(s).\n ");
     printf( "  dirname\n" );
     printf( "       Directory name to search.\n" );
     printf( "\n" );
     printf( "NOTES\n" );
     printf("   Program processes switches for charset in the following order:\n" );
     printf("   first switch <-w>, then switch <-c>, and last is switch <-p>.\n" );
     printf("   This is a defined order by design and it cannot be changed.\n" );
     printf( "\n" );
     printf( "EXAMPLES\n" );
     printf( "  In the following example program will be converted HTML files,\n" );
     printf( "  automatically detecting input text encoding, to russian encoding\n" );
     printf( "  KOI8. For all checked HTML documents charset field will be\n" );
     printf( "  replaced or added to KOI8-r charset. Output catalog will be\n" );
     printf( "  contain just the same tree of subdirectories as input catalog.\n" );
     printf( "\n" );
     printf( "    chrcnv -s -a -r 2 -w -p -i *.html -o d:%ctemp g:%cwww%cmyserver\n",
              BACKSLASH, BACKSLASH, BACKSLASH );
     printf( "\n" );
     printf( "  In the short following example program will be only detected\n" );
     printf( "  the input encoding for all matching files in current directory.\n" );
     printf( "\n" );
     printf( "    chrcnv -a -k -i *.txt\n" );
     printf( "\n" );
#if defined(_MSDOS)
     printf( "KNOWN PROBLEMS\n" );
     printf( "  MS-DOS implementation has a limitations for add and replace options\n" );
     printf( "  in 64 KBytes for file operations.\n" );
     printf( "  MS-DOS implementation has a limitations for long filenames, and,\n" );
     printf( "  of course, UNIX and Win32 have no such problems.\n" );
     printf( "\n" );
#endif                                      /* #if defined(_MSDOS) */
     printf( "HISTORY\n" );
     printf( "  CHRCNV command appeared in November 1998\n" );
     printf( "\n" );
     printf( "AUTHOR\n" );
     printf( "  Dmitry V. Stefankov (dstef@nsl.ru, dima@mccbn.ru)\n" );
#endif                                      /* #if !defined(_UNIX) */
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
                case 'a':
                    g_fAutoDetInEncType = 1; /* Auto detect input encoding */
                    if (g_iDebugLevel > 0) {
                      printf( "Auto detection selected.\n" );
                    }
                    break;
                case 'c':                   /* Replace charset field */
                    g_iReplaceCharsetHTML = 1;
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
                        safe_strncpy( szIncSearchMask, *(++lpszArgv), sizeof(szIncSearchMask) );
#if defined(_MSDOS)
                        strupr( szIncSearchMask );
#endif                                      /* #if defined(_MSDOS) */
                        iTemp = AddFileMask( szIncSearchMask,
                                             &g_sIncFileMasks,
                                             &g_iIncFilesMask,
                                             g_szNoMemForIncFMask );
                    }
                    break;
                case 'k':
                    g_fSkipConversion  = 1; /* Auto detect input encoding */
                    if (g_iDebugLevel > 0) {
                      printf( "Skip conversion selected.\n" );
                    }                    
                    break;
                case 'l':
                    if (iArgc)              /* Input encoding type */
                    {
                      --iArgc;
                      iTemp = atoi( *(++lpszArgv) );
                      if (iTemp <= cpMAXCOUNT) {
                         g_iInputEncType = iTemp;
                      }
                      else {
                        printf( "ERROR: bad input encoding type.\n" );
                        return( ERROR_NO_ENCTYPE );
                      }
                    }
                    break;
                case 'm':
                    if (iArgc)              /* Reserve memory */
                    {
                      --iArgc;
                      iTemp = atoi( *(++lpszArgv) );
                      if ( (iTemp >= MIN_RESERVE_MEMSIZ) &&
                           (iTemp <= MAX_RESERVE_MEMSIZ) )
                      {
                         g_iReserveMem = iTemp;
                      }
                      else
                      {
                        printf( "ERROR: bad memory size specified.\n" );
                        return( ERROR_BAD_MEMSIZ );
                      }
                    }
                    break;
                case 'o':
                    if (iArgc)              /* Output directory */
                    {
                        --iArgc;
                        safe_strncpy( szOutDir, *(++lpszArgv), sizeof(szOutDir) );
                    }
                    break;
                case 'p':                   /* Add charset field */
                    g_iAddCharsetHTML = 1;
                    break;
                case 'r':
                    if (iArgc)              /* Output encoding type */
                    {
                      --iArgc;
                      iTemp = atoi( *(++lpszArgv) );
                      if (iTemp <= cpMAXCOUNT)
                      {
                         g_iOutputEncType = iTemp;
                      }
                      else
                      {
                        printf( "ERROR: bad output encoding type.\n" );
                        return( ERROR_NO_ENCTYPE );
                      }
                    }
                    break;
                case 's':                   /* Search subdirectories */
                    g_iRecursiveSearch = 1;
                    break;
                case 'v':
                    g_fVerbose = 1;         /* Verbose output */
                    break;
                case 'w':
                    g_fWipeCharsetHTML = 1; /* Wipe charset field */
                    break;
                case 'z':                   /* No case-insensitive search */
                    g_fCaseInSensitiveSrch = 0;
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

/*------------------------- Init search parameters -------------------------*/
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
   strupr( szOutDir );
#endif                                      /* #if defined(_MSDOS) */

/*----------------------- Build translation tables -------------------------*/
   iTemp = 0;
   while( (g_ConvertTables[iTemp].tinenc  != -1 ) &&
          (g_ConvertTables[iTemp].toutenc != -1 ) &&
          (g_ConvertTables[iTemp].ptable != NULL) )
   {
      if ( MakeConversionTable(g_ConvertTables[iTemp].tinenc,
                               g_ConvertTables[iTemp].toutenc,
                               (pctable)g_ConvertTables[iTemp].ptable) )
      {
        printf( "ERROR: cannot build conversion table for inenc=%d, outenc=%d.\n",
                g_ConvertTables[iTemp].tinenc, g_ConvertTables[iTemp].toutenc );
        return( ERROR_FAIL_MAKE_CNVTBL );
      }
     iTemp++;
   }

/*----------------------- Build codevector table ---------------------------*/
                                            /* Step 1: init table */
   for( iTemp=0; iTemp<MAX_CTABLE_SIZE ; iTemp++ )
   {
     int iIndex;                            /* Temporary */
     g_CodesVectorTable.codetable[iTemp].charcode = iTemp;
     for(iIndex=0; iIndex < cpMAXCOUNT; iIndex++)
     {
       g_CodesVectorTable.codetable[iTemp].encenum[iIndex].encodetype =
                               g_EncodeNameTypes.encodings[iIndex].encodetype;
       g_CodesVectorTable.codetable[iTemp].encenum[iIndex].encodepresence = 0;
       g_CodesVectorTable.codetable[iTemp].encenum[iIndex].encodeindex = -1;
     }
   }/*for*/
                                            /* Step 2: add russian encodings */
   for( iTemp=0; iTemp<RUS_ALPHABET_SIZE; iTemp++)
   {
     int  iVec = cpNone;                    /* Index for vector */
     while( iVec < cpMAXCOUNT )
     {
       int iIndex;                          /* Temporary */
       int iCode;                           /* Charcode */
       chTemp = g_CodeChrTable.symbolmatrix[iTemp].symvec[iVec].encodetype;
       iCode = g_CodeChrTable.symbolmatrix[iTemp].symvec[iVec].symcode;
       for(iIndex=0; iIndex < cpMAXCOUNT; iIndex++)
       {
         if (chTemp == g_CodesVectorTable.codetable[iCode].encenum[iIndex].encodetype)
         {
           g_CodesVectorTable.codetable[iCode].encenum[iIndex].encodepresence = 1;
           g_CodesVectorTable.codetable[iCode].encenum[iIndex].encodeindex = iTemp;
           break;
         }
       }
       iVec++;
     }/*while*/
   }/*for*/
                                            /* Step 3: count intersection */
   for( iTemp=0; iTemp<MAX_CTABLE_SIZE ; iTemp++ )
   {
     int iIndex;                            /* Temporary */
     chTemp = 0;
     for(iIndex=0; iIndex < cpMAXCOUNT; iIndex++)
     {
       if (g_CodesVectorTable.codetable[iTemp].encenum[iIndex].encodepresence)
         chTemp++;
     }
     g_CodesVectorTable.codetable[iTemp].encnum = chTemp;
   }
#if defined(_DEBUGOUT)
   if (g_iDebugLevel > 0)
   {
     printf( "(main) Codes vector table, only encnum elements.\n" );
     for( iTemp=0; iTemp<MAX_CTABLE_SIZE ; iTemp++ )
     {
       int iIndex;                            /* Temporary */
       printf( "%02X=%d ", iTemp, g_CodesVectorTable.codetable[iTemp].charcode );
       for(iIndex=0; iIndex < cpMAXCOUNT; iIndex++)
       {
         printf(" (%d=%d,%d)",
              g_CodesVectorTable.codetable[iTemp].encenum[iIndex].encodetype,
              g_CodesVectorTable.codetable[iTemp].encenum[iIndex].encodepresence,
              g_CodesVectorTable.codetable[iTemp].encenum[iIndex].encodeindex );
       }
       printf( "\n" );
     }/*for*/
   }
#endif                                      /* #if defined(_DEBUGOUT) */

/*--------------- Check user parameters for correctness --------------------*/
   if ( ((g_iInputEncType == cpNone) || (g_iOutputEncType == cpNone)) &&
        (!g_fAutoDetInEncType) )
   {
     if (g_iDebugLevel > 0)
       printf( "WARNING: User had disabled translation.\n" );
     g_fNoTranslationReqd = 1;
   }

   if ((szOutDir[0] == '\0') && (!g_fSkipConversion) )
   {
     printf( "ERROR: output directory missed.\n" );
     return( ERROR_NO_OUTDIR );
   }

   if ((g_iInputEncType == g_iOutputEncType) && (g_fAutoDetInEncType == 0) &&
        ((g_fWipeCharsetHTML == 0) || (g_iReplaceCharsetHTML) ||
        (g_iAddCharsetHTML)) )
   {
     printf( "ERROR: Not allowed same encoding for input and output.\n" );
     return( ERROR_SAME_ENCODING_IN_OUT );
   }

   if ((g_iReplaceCharsetHTML || g_iAddCharsetHTML) && (g_iReserveMem == 0) )
   {
      printf( "ERROR: no memory specified to add/replace operation.\n" );
      return( ERROR_BAD_MEMSIZ );
   }

/*--------------------------- Searches directory ---------------------------*/
   if (g_iDebugLevel > 0)
   {
     printf( "Input Catalog:  %s\n", &szIncSearchDir[0] );
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
     printf( "Output catalog: %s\n", &szOutDir[0] );
     printf( "Input enctype:  %d\n", g_iInputEncType );
     printf( "Output enctype: %d\n", g_iOutputEncType );
   }

   ulFoundFiles = ulParseDir( szIncSearchDir, MAX_FILENAME_SIZE+1,
                              &g_sIncFileMasks, &g_sExcFileMasks,
                              g_iRecursiveSearch, szOutDir );

   if (g_iDebugLevel > 0)
   {
     printf( "Total found %lu item", ulFoundFiles );
     if (ulFoundFiles != 1)
       printf("s");
     printf("\n");
   }

/*--------------------------- Terminate program  ---------------------------*/

  return 0;
}



/*****************************************************************************
 *                             --- ulParseDir ---
 *
 * Purpose: List files in directory
 *   Input: char      *indirname   - input directory name
 *          int        maxdirlen   - directory name buffer size (max.)
 *          pFileSearchMasks pIncFMasks - include filemasks array
 *          pFileSearchMasks pExcFMasks - exclude filemasks array
 *          int        iSearchDirs - search subdirectories
 *          char      *outdirname  - output directory name
 *  Output: unsigned long int      - number of matching found files
 * Written: by Dmitry V.Stefankov 10-03-1998
 *****************************************************************************/
unsigned long int  ulParseDir( char *indirname, int maxdirlen,
                               pFileSearchMasks pIncFMasks,
                               pFileSearchMasks pExcFMasks, int iSearchDirs,
                               char *outdirname )
{
  unsigned long int  ulFilesCount = 0;      /* Counter */
  char  szTestFName[MAX_FILENAME_SIZE+1];   /* Filename (in) */
  char  szOutFDir[MAX_FILENAME_SIZE+1];     /* Filename (out) */
  DIR  *dir;                                /* Directory structure */
  struct dirent  *ent;                      /* Directory entry */
  int   fExcThisFile;                       /* Boolean flag */
  int   fIncThisFile;                       /* Boolean flag */
  int   maxlen;                             /* Space size */
#if defined(_UNIX)
  mode_t  newmode = S_IRWXU|S_IRWXG|S_IRWXO;
#endif                                      /* #if defined(_UNIX) */

/*------------------------ Process directory name --------------------------*/
  if ( g_iPrintFullName == 0 )
  {
     printf( "IN:  %s\n", indirname );
     printf( "OUT: %s\n", outdirname );
  }
  maxlen = strlen(indirname);
#if defined(_UNIX)
  if ( indirname[maxlen-1] != '/' )
    safe_strncat( indirname, "/", maxdirlen );
#else
  if ( indirname[maxlen-1] != '\\' )
    safe_strncat( indirname, "\\", maxdirlen );
#endif                                      /* #if defined(_UNIX) */

/*---------------------------- Open directory  -----------------------------*/
  if ( !g_fSkipConversion && ((dir = opendir(outdirname)) == NULL) )
  {
    if (g_iDebugLevel > 0)
      printf( "WARNING: Unable to open output directory!\n" );
#if defined(_UNIX)
    if ( mkdir(outdirname,newmode) == -1)
#else
    if ( mkdir(outdirname) == -1 )
#endif                                      /* #if defined(_UNIX) */
    {
      printf( "ERROR: Unable to create output directory!\n" );
      return 0;                             /* Emergency exit */
    }
    if (g_iDebugLevel > 0) {
      printf( "Now check the created directory\n" );
    }
    if ((dir = opendir(outdirname)) == NULL)
    {
      if (g_iDebugLevel > 0)
        printf( "ERROR: Unable to open created output directory!\n" );
      return 0;                             /* Emergency exit */
    }
  }
  if ( !g_fSkipConversion && (closedir(dir) != 0) )
      printf( "ERROR: Unable to close output directory!\n" );
  maxlen = strlen(outdirname);
#if defined(_UNIX)
  if ( outdirname[maxlen-1] != '/' )
    safe_strncat( outdirname, "/", maxdirlen );
#else
  if ( outdirname[maxlen-1] != '\\' )
    safe_strncat( outdirname, "\\", maxdirlen );
#endif                                      /* #if defined(_UNIX) */

  if ((dir = opendir(indirname)) == NULL)
  {
    printf( "ERROR: Unable to open input directory!\n" );
    return 0;                               /* Emergency exit */
  }

/*---------------------- Process directory entries -------------------------*/
  while ((ent = readdir(dir)) != NULL)
  {
    if ( strcmp(ent->d_name,".") && strcmp(ent->d_name,"..") )
    {
      safe_strncpy( szTestFName,indirname,sizeof(szTestFName) );
      safe_strncat( szTestFName,ent->d_name,sizeof(szTestFName ));
      safe_strncpy( szOutFDir, outdirname, MAX_FILENAME_SIZE+1 );
      safe_strncat( szOutFDir, ent->d_name, MAX_FILENAME_SIZE+1 );
      if (g_iDebugLevel > 0)
      {
        printf( "Test Item: %s\n", szTestFName );
      }
      if ( iTestDir(szTestFName) == 1 )
      {
        fExcThisFile = iTestForFileMask( ent->d_name, pExcFMasks,
                                         g_iExcFilesMask );
        if ( !fExcThisFile )
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
            if ( iTranslateFile(szTestFName,szOutFDir) )
            {
              if (!g_fNoTranslationReqd)
                printf("ERROR: translation failed!\n" );
            }
          }
        }
      }
      else
      {
         if (iSearchDirs)                   /* Have we look more? */
         {
            ulFilesCount += ulParseDir( szTestFName, maxdirlen,
                                        pIncFMasks, pExcFMasks,
                                        iSearchDirs, szOutFDir );
         }
      }
    }/*if*/
  }/*while*/

/*------------------------ Close a directory --------------------------------*/
  if ( closedir(dir) != 0 )
      printf( "ERROR: Unable to close input directory!\n" );

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



/*****************************************************************************
 *                           --- iTranslateFile ---
 *
 * Purpose: Copy file to file using conversion table
 *   Input: const char *szSrcFile - source file
 *          const char *szDstFile - destination file
 *  Output: int                   - 0 successful
 *                                  1 source file failed to open
 *                                  2 target file failed to create
 *                                  3 no enough memory
 *                                  4 failed on file reading
 * Written: by Dmitry V.Stefankov 10-18-1998
 * Note: (1) MSVC 4.2 don't like void type pointer for fread(..);
 *****************************************************************************/
int  iTranslateFile( const char *szSrcFile, const char *szDstFile )
{
  FILE *   fInStream = NULL;                /* Input file stream */
  FILE *   fOutStream = NULL;               /* Output file stream */
  struct  stat statbuf;                     /* File information */
  struct  utimbuf times;                    /* Time buffer */
  unsigned long int   infilelen;            /* Input file size */
  unsigned long int   readbytes = 0;        /* Read bytes count */
  unsigned long int   writebytes = 0;       /* Write bytes count */
  int                 rcount = 0;           /* Byte count for one reading */
  int                 wcount = 0;           /* Byte count for one writing */
  int                 newcount;             /* New byte counter */
  int                 iTemp;                /* Temporary */
  int          iInputEnc = g_iInputEncType; /* Input encoding type */
  int         iOutputEnc = g_iOutputEncType;/* Output encoding type */
  unsigned char       *pInbuf = NULL;       /* Memory buffer pointer */
  unsigned char       *pOutbuf = NULL;      /* Memory buffer pointer */
  unsigned char       *pOutbufTmp;          /* Memory buffer pointer */
  unsigned char       *pbufTmpS;            /* Memory buffer pointer */
  unsigned char       *pbufTmpE;            /* Memory buffer pointer */
  char                *pchTemp;             /* Temporary */
  unsigned long int   ulTemp;               /* Temporary */
  unsigned long int   readfcnt;             /* Read file bytes counter */
  unsigned long int   ulTempCount;          /* Temporary */
  struct  bmtable     stBMTable;            /* Boyer-Moore table */
  pctable             pCConvTable = NULL;   /* Code conversion table */
  int                 g_fHTML;              /* HTML document marker */
  char         szMetaBuf[DEF_WORKLINE_SIZE];/* Working buffer */

/*------------------------ Open source file --------------------------------*/
  fInStream = fopen( szSrcFile, "rb" );
  if ( fInStream == NULL )
  {
     printf( "ERROR: (transfile) cannot open file %s\n", szSrcFile );
     return(1);
  }

/*------------------------ Open target file --------------------------------*/
  if (!g_fSkipConversion)
  {
    fOutStream = fopen( szDstFile, "wb" );
    if ( fOutStream == NULL )
    {
       fclose( fInStream );
       printf( "ERROR: (transfile) cannot create file %s\n", szDstFile );
       return(2);
    }
  }

/*------------------------ Get srcfile length ------------------------------*/
  fseek( fInStream, 0L, SEEK_END );
  infilelen = ftell( fInStream );
  fseek( fInStream, 0L, SEEK_SET );
  if (g_iDebugLevel > 0)
    printf( "File size = %lu bytes\n", infilelen );
#if defined(_MSDOS)
  if ( (infilelen > FILE_SIZE_LIMIT) &&
       (g_iReplaceCharsetHTML || g_iAddCharsetHTML) )
  {
     printf( "ERROR: file too large to add/replace operations!\n" );
     fclose( fInStream );
     fclose( fOutStream );
     goto Finish;
  }
#endif                                      /* #if defined(_MSDOS) */
  if (infilelen == 0)
  {
     if (g_iDebugLevel > 0)
       printf( "Special case: nullsize file found!\n" );
     fclose( fInStream );
     fclose( fOutStream );
     goto Finish;
  }

/*--------------------------- Allocate memory ------------------------------*/
#if defined(_MSDOS)
#if defined(_MSVC)
  pInbuf = (unsigned char *)halloc(infilelen,sizeof(unsigned char));
#else
  if (g_iDebugLevel > 0)
    printf( "Free memory = %lu bytes\n", farcoreleft );
  pInbuf = (void *)farmalloc(infilelen);
#endif                                      /* #if defined(_MSVC) */
#else
  pInbuf = (unsigned char *)malloc(infilelen);
#endif                                      /* #if defined(_MSDOS) */
  if (pInbuf == NULL)
  {
     fclose( fInStream );
     if (fOutStream != NULL)
       fclose( fOutStream );
     printf( "ERROR: (transfile) cannot allocate memory buffer (input).\n" );
     return(3);
  }
  if (g_iReserveMem && (g_iReplaceCharsetHTML || g_iAddCharsetHTML))
  {
#if defined(_MSDOS)
#if defined(_MSVC)
      pOutbuf = (unsigned char *)halloc(infilelen+g_iReserveMem,sizeof(unsigned char));
#else
    if (g_iDebugLevel > 0)
      printf( "Free memory = %lu bytes\n", farcoreleft );
    pOutbuf = (void *)farmalloc(infilelen+g_iReserveMem);
#endif                                      /* #if defined(_MSVC) */
#else
    pOutbuf = (unsigned char *)malloc(infilelen+g_iReserveMem);
#endif                                      /* #if defined(_MSDOS) */
    if (pOutbuf == NULL)
    {
       fclose( fInStream );
       fclose( fOutStream );
       printf( "ERROR: (transfile) cannot allocate memory buffer (output).\n" );
       return(3);
    }
  }

/*---------------------------- read file -----------------------------------*/
  pbufTmpS = pInbuf;
  readfcnt = infilelen;
  while( readfcnt )
  {
      newcount = (int)(readfcnt / MAX_RW_SIZE);
      if (newcount)
        newcount = MAX_RW_SIZE;
      else
        newcount = (int)(readfcnt % MAX_RW_SIZE);
      readfcnt -= newcount;
      rcount = fread(pbufTmpS, sizeof(unsigned char), newcount, fInStream);
      readbytes += rcount;
#if defined(_MSDOS)
      pbufTmpS = (unsigned char*)DosPtrInc( pbufTmpS, rcount );
#else
      pbufTmpS += rcount;
#endif                                      /* #if defined(_MSDOS) */
  }/*while*/
  if (g_iDebugLevel > 0)
      printf( "On read: %lu bytes.\n", readbytes );
  if (readbytes != infilelen)
  {
     printf("ERROR: (transfile) cannot read file %s\n", szSrcFile );
     fclose( fInStream );
     fclose( fOutStream );
     return(4);
  }

/*-------------------------- Detect input encoding -------------------------*/
  if (g_fAutoDetInEncType)
  {
    iInputEnc = AutoDetBufEncoding(pInbuf,readbytes);
    if (iInputEnc == -1)
    {
      printf( "ERROR: (transfile) cannot detect input encoding. Use manual way.\n" );
      g_fSkipConversion = 1;
    }
  }
  else
  {
    if ((iInputEnc == iOutputEnc) && (!g_fAutoDetInEncType))
      g_fSkipConversion = 1;
  }

  if ((iInputEnc == iOutputEnc) && (g_fAutoDetInEncType))
  {
    printf( "WARNING: Both encodings are same for file %s. Skip translation.\n",
            szSrcFile );
  }

/*-------------------------- Find conversion table -------------------------*/
  if (!(g_fSkipConversion || g_fNoTranslationReqd))
  {
    iTemp = 0;
    while( (g_ConvertTables[iTemp].tinenc  != -1 ) &&
           (g_ConvertTables[iTemp].toutenc != -1 ) &&
           (g_ConvertTables[iTemp].ptable != NULL) )
    {
      if ( (g_ConvertTables[iTemp].tinenc  == iInputEnc) &&
           (g_ConvertTables[iTemp].toutenc == iOutputEnc) )
      {
        pCConvTable = (pctable)g_ConvertTables[iTemp].ptable;
        if (g_iDebugLevel > 0)
          printf( "Selected encodings: inenc=%d(%s), outenc=%d(%s).\n",
                    iInputEnc,
                    g_EncodeNameTypes.encodings[iInputEnc-1].encodename,
                    iOutputEnc,
                    g_EncodeNameTypes.encodings[iOutputEnc-1].encodename);
        break;
      }
      iTemp++;
    }/*while*/
  }/*if*/

/*--------------------------- translate file -------------------------------*/
  if (!(g_fSkipConversion || g_fNoTranslationReqd))
  {
    if ( iTranslateBuf(pInbuf,readbytes,pCConvTable) )
      printf("ERROR: (transfile) buffer translation failed.\n" );
  }

/*----------------------------- wipe charset -------------------------------*/
  if ( (g_fWipeCharsetHTML) && (pInbuf != NULL) )
  {
    if (g_iDebugLevel > 0)
      printf( "(transfile) wipe charset field.\n" );
    g_fSkipConversion = 0;                  /* Enable write output file */
    g_fHTML = 0;                            /* No HTML doc yet */
    pbufTmpE = pInbuf;
    ulTempCount = readbytes;
    do {
      if (g_fHTML == 0)
      {
        pbufTmpS = pDetectHTMLdoc( pbufTmpE, ulTempCount, &stBMTable,
                                   g_fCaseInSensitiveSrch );
        if (pbufTmpS == NULL)
        {
          printf( "ERROR: (transfile) not valid HTML document.\n" );
          break;
        }
        ulTempCount = (pbufTmpS - pbufTmpE);
        if (g_iDebugLevel > 0)
          printf( "(transfile) detected search length = %lu bytes.\n", ulTempCount );
        initBMtable( (unsigned char*)g_szCharSet, strlen(g_szCharSet),
                     &stBMTable, g_fCaseInSensitiveSrch );
        g_fHTML = 1;                        /* Yes, HTML file with header. */
      }
      pbufTmpS = searchBufBM( pbufTmpE, ulTempCount, &stBMTable,
                             (unsigned char*)g_szCharSet, strlen(g_szCharSet),
                              g_fCaseInSensitiveSrch );
      if (pbufTmpS != NULL)
      {
        if (g_iDebugLevel > 0)
          printf( "(transfile) pattern found.\n" );
        ulTempCount -= (pbufTmpS - pbufTmpE);
        while (ulTempCount && (*pbufTmpS != '"') )
        {
           *pbufTmpS++ = ' ';
           ulTempCount--;
        }
        pbufTmpE = pbufTmpS;
      }
    } while ((pbufTmpS != NULL) && (ulTempCount) );
    g_fSkipConversion = 0;                  /* Enable write output file */
  }/*if*/

/*--------------------------- replace charset ------------------------------*/
  if (g_iReplaceCharsetHTML && (pInbuf != NULL) && (pOutbuf != NULL) )
  {
    if (g_iDebugLevel > 0)
      printf( "(transfile) replace charset field.\n" );
    g_fSkipConversion = 0;                  /* Enable write output file */
    g_fHTML = 0;                            /* No HTML doc yet */
    pchTemp = g_EncodeNameTypes.encodings[iOutputEnc-1].encodename;
    pbufTmpE = pInbuf;
    ulTempCount = readbytes;
    pOutbufTmp = pOutbuf;
    do {
      if (g_fHTML == 0)
      {
        pbufTmpS = pDetectHTMLdoc( pbufTmpE, ulTempCount, &stBMTable,
                                   g_fCaseInSensitiveSrch );
        if (pbufTmpS == NULL)
        {
          printf( "ERROR: (transfile) not valid HTML document.\n" );
          break;
        }
        initBMtable( (unsigned char*)g_szCharSet, strlen(g_szCharSet),
                     &stBMTable, g_fCaseInSensitiveSrch );
        g_fHTML = 1;                        /* Yes, HTML file with header. */
      }
      pbufTmpS = searchBufBM( pbufTmpE, ulTempCount, &stBMTable,
                             (unsigned char*)g_szCharSet, strlen(g_szCharSet),
                              g_fCaseInSensitiveSrch );
      if (pbufTmpS != NULL)
      {
        pbufTmpS += strlen(g_szCharSet);    /* Skip 'charset=' */
        ulTemp = pbufTmpS - pbufTmpE;
#if defined(_MSDOS)                         /* 64K limit */
        memmove( pOutbufTmp, pbufTmpE, (unsigned int)ulTemp );
#else
        memmove( pOutbufTmp, pbufTmpE, ulTemp);
#endif                                      /* #if defined(_MSDOS) */
        ulTempCount -= ulTemp;
#if defined(_MSDOS)                         /* 64K limit */
        pOutbufTmp += (unsigned int)ulTemp;
#else
        pOutbufTmp += ulTemp;
#endif                                      /* #if defined(_MSDOS) */
        while (ulTempCount && (*pbufTmpS != '"') )
        {
           pbufTmpS++;
           ulTempCount--;
           readbytes--;
        }
        memmove( pOutbufTmp, pchTemp, strlen(pchTemp) );
        readbytes += strlen(pchTemp);
        pOutbufTmp += strlen(pchTemp);
        pbufTmpE = pbufTmpS;
      }/*if*/
    } while ((pbufTmpS != NULL) && (ulTempCount) );
    /*do-while*/
    if (ulTempCount)
#if defined(_MSDOS)
        memmove( pOutbufTmp, pbufTmpE, (unsigned int)ulTempCount );
#else
        memmove( pOutbufTmp, pbufTmpE, ulTempCount);
#endif                                      /* #if defined(_MSDOS) */
  }/*if*/

/*--------------------------- add charset ------------------------------*/
  if (g_iAddCharsetHTML && (pInbuf != NULL) && (pOutbuf != NULL) )
  {
    if (g_iDebugLevel > 0)
      printf( "(transfile) add charset field.\n" );
    g_fSkipConversion = 0;                  /* Enable write output file */
    g_fHTML = 0;                            /* No HTML doc yet */
    pbufTmpE = pInbuf;
    ulTempCount = readbytes;
    pOutbufTmp = pOutbuf;
    do {
      if (g_fHTML == 0)
      {
        pbufTmpS = pDetectHTMLdoc( pbufTmpE, ulTempCount, &stBMTable,
                                   g_fCaseInSensitiveSrch );
        if (pbufTmpS == NULL)
        {
          printf( "ERROR: (transfile) not valid HTML document.\n" );
          break;
        }
        initBMtable( (unsigned char*)g_szHtmlHeadBeg, strlen(g_szHtmlHeadBeg),
                     &stBMTable, g_fCaseInSensitiveSrch );
        g_fHTML = 1;                        /* Yes, HTML file with header. */
      }
      pbufTmpS = searchBufBM( pbufTmpE, ulTempCount, &stBMTable,
                             (unsigned char*)g_szHtmlHeadBeg, strlen(g_szHtmlHeadBeg),
                              g_fCaseInSensitiveSrch );
      if (pbufTmpS != NULL)
      {
        pbufTmpS += strlen(g_szHtmlHeadBeg);    /* Skip '<head>' */
        ulTemp = pbufTmpS - pbufTmpE;
#if defined(_MSDOS)                         /* 64K limit */
        memmove( pOutbufTmp, pbufTmpE, (unsigned int)ulTemp );
#else
        memmove( pOutbufTmp, pbufTmpE, ulTemp);
#endif                                      /* #if defined(_MSDOS) */
        ulTempCount -= ulTemp;
#if defined(_MSDOS)                         /* 64K limit */
        pOutbufTmp += (unsigned int)ulTemp;
#else
        pOutbufTmp += ulTemp;
#endif                                      /* #if defined(_MSDOS) */
        sprintf( szMetaBuf,
   "<META HTTP-EQUIV=%cContent-Type%c CONTENT=%ctext/html; charset=%s%c>",
                QUOTA, QUOTA, QUOTA,
                g_EncodeNameTypes.encodings[iOutputEnc-1].encodename,
                QUOTA );
        pchTemp = szMetaBuf;
        memmove( pOutbufTmp, pchTemp, strlen(pchTemp) );
        readbytes += strlen(pchTemp);
        pOutbufTmp += strlen(pchTemp);
        pbufTmpE = pbufTmpS;
      }/*if*/
    } while ((pbufTmpS != NULL) && (ulTempCount) );
    /*do-while*/
    if (ulTempCount)
#if defined(_MSDOS)
        memmove( pOutbufTmp, pbufTmpE, (unsigned int)ulTempCount );
#else
        memmove( pOutbufTmp, pbufTmpE, ulTempCount);
#endif                                      /* #if defined(_MSDOS) */
  }/*if*/

/*--------------------------- write file -----------------------------------*/
  if ( (!g_fSkipConversion) || (pOutbuf != NULL) )
  {
    if ((g_iReplaceCharsetHTML || g_iAddCharsetHTML) &&
        (pInbuf != NULL) && (pOutbuf != NULL) )
      pbufTmpS = pOutbuf;
    else
      pbufTmpS = pInbuf;

    ulTempCount = readbytes;
    while( ulTempCount )
    {
        newcount = (int)(ulTempCount / MAX_RW_SIZE);
        if (newcount)
          newcount = MAX_RW_SIZE;
        else
          newcount = (int)(ulTempCount % MAX_RW_SIZE);
        ulTempCount -= newcount;
        wcount = fwrite(pbufTmpS, sizeof(unsigned char), newcount, fOutStream);
        if (wcount == 0)
        {
          printf("ERROR: (transfile) cannot write file %s\n", szDstFile );
          break;
        }
        writebytes += wcount;
  #if defined(_MSDOS)
        pbufTmpS = (unsigned char *)DosPtrInc( pbufTmpS, wcount );
  #else
        pbufTmpS += wcount;
  #endif                                      /* #if defined(_MSDOS) */
    }/*while*/

    if (g_iDebugLevel > 0)
        printf( "On write: %lu bytes.\n", writebytes );
    if (writebytes != readbytes)
    {
       printf("ERROR: (transfile) failed writing to file %s\n", szDstFile );
    }
  }/*if*/

/*-------------------------- Free resources --------------------------------*/
  fclose( fInStream );
  if (fOutStream != NULL)
    fclose( fOutStream );
  if ((g_iReserveMem != 0) && (pOutbuf != NULL))
  {
#if defined(_MSDOS)
#if defined(_MSVC)
    hfree( pOutbuf );
#else
    farfree( pOutbuf );
#endif                                      /* #if defined(_MSVC) */
#else
    free( pOutbuf );
#endif                                      /* #if defined(_MSDOS) */
  }
  if ( pInbuf )
#if defined(_MSDOS)
#if defined(_MSVC)
    hfree( pInbuf );
#else
    farfree( pInbuf );
#endif                                      /* #if defined(_MSVC) */
#else
    free( pInbuf );
#endif                                      /* #if defined(_MSDOS) */

/*-------------------- Use original file timestamp -------------------------*/
Finish:
  if (!g_fSkipConversion)
  {
    if ( stat(szSrcFile,&statbuf) )
      printf( "ERROR: (transfile) cannot get information for file %s\n", szSrcFile );
    else
    {
       times.modtime = times.actime = statbuf.st_mtime;
       if ( utime((char *)szDstFile,&times) != 0 )
          printf( "ERROR: (transfile) cannot set modtime for file %s\n", szDstFile );
    }
  }/*if*/

  return 0;
}



/*****************************************************************************
 *                          --- iTranslateBuf ---
 *
 * Purpose: Copy  to file using conversion table
 *   Input: unsigned char        *buf - memory buffer
 *          unsigned long int bufsize - buffer size
 *          pctable              ptbl - conversion table (pointer)
 *  Output: int                       -  0 success
 *                                       1 invalid encoding type
 *                                       2 empty conversion table
 *                                       3 no buffer
 * Written: by Dmitry V.Stefankov 10-18-1998
 *****************************************************************************/
int  iTranslateBuf( unsigned char *buf, unsigned long int bufsize,
                    pctable ptbl )
{
  unsigned char chTemp;                     /* Temporary storage */

  if ( ptbl == NULL )
  {
    if (g_iDebugLevel > 0)
      printf("ERROR: (transbuf) conversion table not present.\n" );
    return 1;
  }

  if (buf == NULL)
  {
    if (g_iDebugLevel > 0)
      printf("ERROR: (transbuf) memory buffer not present.\n" );
    return 2;
  }

  if (g_iDebugLevel > 0)
    printf("(transbuf) make a translation.\n" );

  while(bufsize--)
  {
     chTemp = *buf;
     *buf = ptbl->convtable[chTemp];
     ++buf;
  }
  return 0;
}



/*****************************************************************************
 *                         --- initBMtable ---
 *
 * Purpose: Initialize Boyer-Moore table
 *   Input: unsigned char *buf    -  pattern (ptr)
 *          unsigned int bufsize  -  pattern length
 *          pbmtable     ptbl     -  Boyer-Moore table (ptr)
 *          int          ci       -  case-insensitive search
 *  Output: none
 * Written: by Dmitry V.Stefankov 10-22-1998
 *****************************************************************************/
void  initBMtable( unsigned char *buf, unsigned int bufsize, pbmtable ptbl,
                   int  ci )
{
    unsigned int    i;                      /* Index */

    if ((buf == NULL) || (ptbl == NULL))
      return;

    memset( ptbl, bufsize, sizeof(struct bmtable) );
    if (bufsize <= 1)
      return;

    for(i=0; i < bufsize; i++)
    {
      if (ci)
      {
        ptbl->chrtbl[tolower(*buf)] = bufsize - i - 1;
        ptbl->chrtbl[toupper(*buf++)] = bufsize - i - 1;
      }
      else
        ptbl->chrtbl[*buf++] = bufsize - i - 1;
    }
}



/*****************************************************************************
 *                         --- searchBufBM ---
 *
 * Purpose: Search a buffer using an initalized Boyer-Moore table
 *   Input: unsigned char *sbuf       -  buffer to search
 *          unsigned long int sbuflen -  search buffer size
 *          pbmtable ptbl             -  Boyer-Moore table (ptr)
 *          unsigned char *patbuf     -  pattern (ptr)
 *          unsigned int  patlen      -  pattern length
 *          int          ci           -  case-insensitive search
 *  Output: unsigned char *           -  NULL if match not found
 *                                       otherwise ptr to buffer position
 *                                       where matching string found
 * Written: by Dmitry V.Stefankov 10-23-1998
 *****************************************************************************/
unsigned char  *searchBufBM( unsigned char *sbuf, unsigned long int sbuflen,
                             pbmtable ptbl, unsigned char *patbuf,
                             unsigned int patlen, int ci )
{
    unsigned char  *pch;                    /* Current buffer position */
    unsigned char   chr;                    /* Current char to test */
    unsigned char   match;                  /* Matching char */
    unsigned char  *plast = sbuf;           /* End of buffer */
    unsigned char  *bufstr;                 /* Test string from buffer */
    unsigned char  *patstr;                 /* Test string from pattern */
    unsigned int   strlen;                  /* String size */
    int            iCompRes;                /* Temporary */

    if ( (sbuf == NULL) || (ptbl == NULL) ||/* Check for wrong parameters */
         (patlen == 0) || (patbuf == NULL) )
      return( NULL );

    if (patlen > sbuflen )                  /* Small buffer */
      return( NULL );

    if (patlen == 1)                        /* Trivial case */
    {
#if defined(_MSDOS)                         /* 64K limit */
      pch = (unsigned char *)memchr( sbuf, *patbuf, (unsigned int)sbuflen );
#else
      pch = (unsigned char *)memchr( sbuf, *patbuf, sbuflen );
#endif                                      /* #if defined(_MSDOS) */
      return( pch );
    }

    pch = (unsigned char *)&patbuf[patlen-1];
    if (ci)
      match = toupper(*pch);
    else
      match = *pch;

#if defined(_MSDOS)
    plast += (unsigned int)sbuflen;         /* Limit 64K */
#else
    plast += sbuflen;                       /* Searching buffer */
#endif                                      /* #if defined(_MSDOS) */

    pch = (unsigned char *)&sbuf[patlen-1];
    for( ;; )
    {
      if (pch >= plast)
        break;
      chr = *pch;
      if (ci)
        iCompRes = (toupper(chr) == match);
      else
        iCompRes = (chr == match);
      if (iCompRes)
      {
         pch -= (patlen-1);
         bufstr = pch;
         strlen = patlen - 1;
         patstr = patbuf;
         if (ci)
           while( (--strlen) && (toupper(*bufstr++) == toupper(*patstr++)) )
             ;
         else
           while( (--strlen) && (*bufstr++ == *patstr++) )
             ;
         if (strlen == 0)
            return( pch );
         pch += patlen;
      }
      else
      {
        pch = (unsigned char *)&pch[ptbl->chrtbl[chr]];
      }
    }

    return( NULL );                         /* Default */
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

   safe_strncpy( name, dirname, maxlen );
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



#if defined(_MSDOS)
/*****************************************************************************
 *                            --- DosPtrInc ---
 *
 * Purpose: Increment MS-DOS far poiinter to avoid 64K limitation
 *   Input: void              *pmem  - old value pointer
 *          unsigned long int incsiz - add size to pointer
 *  Output: void *                   - new value of pointer
 * Written: by Dmitry V.Stefankov 10-27-1998
 *****************************************************************************/
void *  DosPtrInc( void *pmem, unsigned long int incsiz )
{
  unsigned int  wBufSeg;                    /* DOS buffer segment */
  unsigned int  wBufOfs;                    /* DOS buffer offset */
  unsigned long int ulTemp;                 /* Temporary */
  void * pTemp;                             /* Temporary */

  wBufSeg = FP_SEG(pmem);                   /* Std Intel arithmetic */
  wBufOfs = FP_OFF(pmem);
  ulTemp = (unsigned long int)wBufSeg*INTEL_PARA_SIZE + wBufOfs;
  ulTemp += incsiz;
  wBufSeg = (unsigned int)(ulTemp / INTEL_PARA_SIZE);
  ulTemp -= (unsigned long int)wBufSeg*INTEL_PARA_SIZE;
  wBufOfs = (unsigned int)ulTemp;
  pTemp = MK_FP(wBufSeg,wBufOfs);

  return pTemp;
}



/*****************************************************************************
 *                            --- dosmemchr ---
 *
 * Purpose: Search character in memory buffer avoiding 64K limit
 *   Input: const void        *s     - buffer
 *          int               c      - character
 *          unsigned long int bufsiz - buffer size
 *  Output: void *                   - NULL if not found
 *                                     otherwise buffer position
 * Written: by Dmitry V.Stefankov 10-27-1998
 *****************************************************************************/
void * dosmemchr( const void *s, int c, unsigned long int bufsiz )
{
  void * pbuf = (void *)s;                  /* Temporary buffer */
  unsigned int ulen;                        /* Length to search */

  if ( (s == NULL) || (bufsiz == 0) )
    return NULL;

  do {
    if (bufsiz >= INTEL_SMALLSEG_SIZE)
#if defined(_BCC)
      ulen = (unsigned int)INTEL_SMALLSEG_SIZE-1;
#else
      ulen = INTEL_SMALLSEG_SIZE-1;
#endif                                      /* #if defined(_BCC) */
    else
      ulen = (unsigned int)bufsiz;
    bufsiz -= ulen;
    pbuf = memchr( pbuf, c, ulen);
    if ( (bufsiz) && (pbuf == NULL) )
      pbuf = DosPtrInc( pbuf, ulen );
  } while ( (bufsiz) && (pbuf == NULL) );

  return pbuf;
}



/*****************************************************************************
 *                           --- dosmemmove ---
 *
 * Purpose: Copy memory block avoiding 64K limit
 *   Input: void              *dest  - destination memory region
 *          const void        *src   - source memory region
 *          unsigned long int buflen - number of bytes to copy
 *  Output: void *                   - destination buffer
 * Written: by Dmitry V.Stefankov 10-27-1998
 *****************************************************************************/
void * dosmemmove( void *dest, const void *src, unsigned long int buflen )
{
  void * psrcbuf = (void *)src;             /* Temporary source */
  void * pdstbuf = dest;                    /* Temporary destination */
  unsigned int ulen;                        /* Length of copy block */

  if ( (src == NULL) || (dest == NULL) || (buflen == 0) )
    return NULL;

  do {
    if (buflen >= INTEL_SMALLSEG_SIZE)
#if defined(_BCC)
      ulen = (unsigned int)INTEL_SMALLSEG_SIZE-1;
#else
      ulen = INTEL_SMALLSEG_SIZE-1;
#endif                                      /* #if defined(_BCC) */
    else
      ulen = (unsigned int)buflen;
    buflen -= ulen;
    memmove( pdstbuf, psrcbuf, ulen);
    if (buflen)
    {
      psrcbuf = DosPtrInc( psrcbuf, ulen );
      pdstbuf = DosPtrInc( pdstbuf, ulen );
    }
  } while (buflen > 0 );

  return dest;
}



/*****************************************************************************
 *                           --- DosPtrDiff ---
 *
 * Purpose: Find an arithmetic difference two pointers
 *   Input: void    *p1 - fisrt pointer
 *          void    *p2 - second pointer
 *  Output: unsigned long  - difference between pointers
 * Written: by Dmitry V.Stefankov 10-27-1998
 *****************************************************************************/
unsigned long int  DosPtrDiff( void *p1, void *p2 )
{
  unsigned int  wBufSeg;                    /* DOS buffer segment */
  unsigned int  wBufOfs;                    /* DOS buffer offset */
  unsigned long int ulTemp1;                /* Temporary */
  unsigned long int ulTemp2;                /* Temporary */

  wBufSeg = FP_SEG(p1);
  wBufOfs = FP_OFF(p1);
  ulTemp1 = (unsigned long int)wBufSeg*INTEL_PARA_SIZE + wBufOfs;
  wBufSeg = FP_SEG(p2);
  wBufOfs = FP_OFF(p2);
  ulTemp2 = (unsigned long int)wBufSeg*INTEL_PARA_SIZE + wBufOfs;

  return( ulTemp1-ulTemp2 );
}
#endif                                      /* #if defined(_MSDOS) */



/*****************************************************************************
 *                       --- MakeConversionTable ---
 *
 * Purpose: Build translation (conversion) table
 *   Input: int     encIn  - input encoding type
 *          int     encOut - output encoding type
 *          pctable ptbl   - char code table
 *  Output: int            - 0 successful
 *                           1 wrong parameter
 * Written: by Dmitry V.Stefankov 11-10-1998
 *****************************************************************************/
int  MakeConversionTable(int encIn, int encOut, pctable ptbl)
{
  int  iCh;                                 /* Temporary index */
  int  iVec;                                /* Vector index */
  unsigned char  chIn = '\0';               /* Input symbol */
  unsigned char  chOut = '\0';              /* Output symbol */
  int  fDone;                               /* Both symbols found */

  if ((ptbl == NULL) || (encIn > cpMAXCOUNT) || (encOut > cpMAXCOUNT))
    return 1;

  for(iCh=0; iCh < MAX_CTABLE_SIZE; iCh++)  /* Build default table */
     ptbl->convtable[iCh] = iCh;

  for(iCh=0; iCh < RUS_ALPHABET_SIZE; iCh++)/* Now build conversion */
  {
    iVec = cpNone;                          /* Extract FROM/TO */
    fDone = 0;
    while(iVec < cpMAXCOUNT)
    {
      if (g_CodeChrTable.symbolmatrix[iCh].symvec[iVec].encodetype == encIn)
      {
        chIn  = g_CodeChrTable.symbolmatrix[iCh].symvec[iVec].symcode;
        fDone++;
      }
      if (g_CodeChrTable.symbolmatrix[iCh].symvec[iVec].encodetype == encOut)
      {
        chOut  = g_CodeChrTable.symbolmatrix[iCh].symvec[iVec].symcode;
        fDone++;
      }
      if (fDone == 2)
        break;
      iVec++;
    }
    if (iVec < cpMAXCOUNT)                  /* Make translation code */
      ptbl->convtable[chIn] = chOut;        /* only if we found matching pair */
  }

  return 0;
}



/*****************************************************************************
 *                       --- AutoDetBufEncoding ---
 *
 * Purpose: Detect encoding of buffer text based on probabilistic model
 *   Input: unsigned char     *buf    - buffer to detect
 *          unsigned long int bufsize - buffer size
 *  Output: int                       -  -1 if fail on detection
 *                                       otherwise encoding type
 * Written: by Dmitry V.Stefankov 11-12-1998
 *****************************************************************************/
int  AutoDetBufEncoding( unsigned char *buf, unsigned long int bufsize )
{
  pfreqtable          pftbl = NULL;         /* Frequency table */
  pencrefmatrix       pencreftbl = NULL;    /* Encodings frequency */
  pencfreqvec         pstdftable = NULL;    /* Use std frequency table */
  int                 iTemp;                /* Temporary */
  int                 iRetCode = -1;        /* Result code */
  int                 iSymCode;             /* Character code */
  int                 iIndex;               /* Index */
  unsigned char       chEncType;            /* Encoding type */
  int                 iComVal;              /* Combination value */
  unsigned long int   ulEncCount = 0;       /* Tested symbols per buffer */
  unsigned long int   buflen = 0;           /* Buffer length or size */
  double              rRatio;               /* Calculated ratio */
  int                 iBestEncType = -1;    /* Encode type */
  int                 iBestEncodings = 0;   /* Best encodings */

/*-------------------------- Test input ------------------------------------*/
  if (buf == NULL)
  {
    if (g_iDebugLevel > 0)
      printf("ERROR: (autodet) memory buffer not present.\n" );
    return( iRetCode );
  }

/*-------------------------- Allocate buffers ------------------------------*/
  pftbl = (pfreqtable)malloc( sizeof(struct freqtable) );
  if (pftbl == NULL)
  {
    printf("ERROR: (autodet) cannot allocate memory for frequency symtable.\n" );
    return( iRetCode );
  }

  pencreftbl = (pencrefmatrix)malloc( sizeof(struct encrefmatrix) );
  if (pencreftbl == NULL)
  {
    printf("ERROR: (autodet) cannot allocate memory for frequency enctable.\n" );
    goto Finish;
  }

  pstdftable = (pencfreqvec)malloc( sizeof(struct encfreqvec) );
  if (pstdftable == NULL)
  {
    printf("ERROR: (autodet) cannot allocate memory for frequency stdtable.\n" );
    goto Finish;
  }

/*-------------------------- Init tables -----------------------------------*/
  for( iTemp=0; iTemp<MAX_CTABLE_SIZE; iTemp++ )
    pftbl->frqtbl[iTemp] = 0L;              /* Clear each element */

  for( iTemp=0; iTemp < cpMAXCOUNT; iTemp++ )
  {
    pencreftbl->encreftbl[iTemp].encodetype =
           g_EncodeNameTypes.encodings[iTemp].encodetype;
    for( iIndex=0; iIndex < cpMAXCOUNT; iIndex++ )
       pencreftbl->encreftbl[iTemp].refsym[iIndex] = 0L;
  }

  for( iTemp=0; iTemp < cpMAXCOUNT; iTemp++ )
  {
    pstdftable->encfvec[iTemp].encodetype =
          g_EncodeNameTypes.encodings[iTemp].encodetype;
    pstdftable->encfvec[iTemp].encodefreqcount = 0;
    pstdftable->encfvec[iTemp].encratio = 0.0f;
    pstdftable->encfvec[iTemp].encfinal = 0.0f;
  }

/*---------------------- Count, count and count ----------------------------*/
  while( bufsize-- )
  {
     buflen++;
     iSymCode = *buf++;                     /* Got a next char */
     pftbl->frqtbl[iSymCode]++;
     iComVal = g_CodesVectorTable.codetable[iSymCode].encnum;
     if (iComVal)
     {
       ++ulEncCount;
       for( iIndex=0; iIndex < cpMAXCOUNT; iIndex++ )
       {
         if (g_CodesVectorTable.codetable[iSymCode].encenum[iIndex].encodepresence)
         {
           chEncType = g_CodesVectorTable.codetable[iSymCode].encenum[iIndex].encodetype;
           for( iTemp=0; iTemp < cpMAXCOUNT; iTemp++ )
             if (pencreftbl->encreftbl[iTemp].encodetype == chEncType)
             {
               if (iComVal > cpMAXCOUNT)
                 printf("ERROR: (autodet) comvalue out of range for code = %d.\n", iSymCode );
               else
                 pencreftbl->encreftbl[iTemp].refsym[iComVal-1]++;
             }/*if*/
         }/*if*/
       }/*for*/
       for( iIndex=0; iIndex < cpMAXCOUNT; iIndex++ )
       {
         chEncType = pstdftable->encfvec[iIndex].encodetype;
         if (chEncType == g_CodesVectorTable.codetable[iSymCode].encenum[iIndex].encodetype)
         {
           iTemp = g_CodesVectorTable.codetable[iSymCode].encenum[iIndex].encodeindex;
           if ((iTemp != -1) && (g_StdFrqRusAlphabet[iTemp]))
              pstdftable->encfvec[iIndex].encodefreqcount++;
         }
       }/*for*/
     }/*if*/
  }/*while*/

/*------------------------ Count final resuls ------------------------------*/
  for( iTemp=0; iTemp < cpMAXCOUNT; iTemp++ )
  {
    rRatio = 0.0f;
    chEncType = pencreftbl->encreftbl[iTemp].encodetype;
    for( iIndex=0; iIndex < cpMAXCOUNT; iIndex++ )
      rRatio +=  pencreftbl->encreftbl[iTemp].refsym[iIndex] * (cpMAXCOUNT-iIndex);
    for( iIndex=0; iIndex < cpMAXCOUNT; iIndex++ )
      if (chEncType == pstdftable->encfvec[iIndex].encodetype)
      {
        pstdftable->encfvec[iIndex].encratio = rRatio;
        pstdftable->encfvec[iIndex].encfinal = rRatio *
                             pstdftable->encfvec[iTemp].encodefreqcount;
      }
  }

/*--------------------- Print out statistics tables ------------------------*/
#if defined(_DEBUGOUT)
  if (g_iDebugLevel > 0)
  {
    printf( "(autodet) Symbol frequency table for buffer.\n" );
    for( iTemp=0; iTemp<MAX_CTABLE_SIZE; iTemp++ )
      printf( "%02X=%ld,", iTemp, pftbl->frqtbl[iTemp] );
    printf("\n");

    printf( "(autodet) Encodings frequency table for buffer.\n" );
    for( iTemp=0; iTemp < cpMAXCOUNT; iTemp++ )
    {
      printf( "Enctype = %d", pencreftbl->encreftbl[iTemp].encodetype );
      for( iIndex=0; iIndex < cpMAXCOUNT; iIndex++ )
      {
         printf(", %d=%lu", iIndex+1, pencreftbl->encreftbl[iTemp].refsym[iIndex] );
      }
      printf("\n");
    }
  }/*if*/
#endif                                      /* #if defined(_DEBUGOUT) */

/*-------------------------- Print final results ---------------------------*/
  if (g_iDebugLevel > 0)
  {
    printf( "Buftext = %lu bytes, enctext = %lu bytes.\n", buflen, ulEncCount );
    printf( "(autodet) Estimated ratio (using std freq) for all encodings.\n" );
    for( iTemp=0; iTemp < cpMAXCOUNT; iTemp++ )
    {
      printf( "Enctype = %d, count = %lu, ratio = %.0f, final = %.0f\n",
              pstdftable->encfvec[iTemp].encodetype,
              pstdftable->encfvec[iTemp].encodefreqcount,
              pstdftable->encfvec[iTemp].encratio,
              pstdftable->encfvec[iTemp].encfinal );
    }
  }

/*------------------------- Try probabilistic model ------------------------*/
  if (g_iDebugLevel > 0)
    printf( "Try probabilistic distribution model to find bestest encoding.\n" );
  rRatio = 0.0f;                            /* Second attempt */
  iBestEncodings = 0;
  for( iTemp=0; iTemp < cpMAXCOUNT; iTemp++ )
  {
    if ( pstdftable->encfvec[iTemp].encfinal > rRatio )
    {
      rRatio = pstdftable->encfvec[iTemp].encfinal;
      iBestEncType = iTemp;
      iBestEncodings = 1;
      continue;                             /* New best */
    }
    if ( pstdftable->encfvec[iTemp].encfinal == rRatio )
    {
      iBestEncodings++;
      if (iBestEncType == -1)
        iBestEncType = iTemp;
      else
        iBestEncType = -1;                  /* Again fail */
    }
  }/*for*/

/*-------------------------- Free resources --------------------------------*/
Finish:
  if ( pftbl != NULL )
    free( pftbl );
  if ( pencreftbl != NULL )
    free( pencreftbl );
  if ( pstdftable != NULL )
    free( pstdftable );

/*--------------------------- Return result --------------------------------*/
  if ( (iBestEncType != -1) && (iBestEncodings == 1) )
  {
    iRetCode = iBestEncType+1;
    if ( (g_iDebugLevel > 0) || (g_fSkipConversion) )
      printf( "SUCCESS: (autodet) assumed encoding for buffer = %d (%s).\n",
                 g_EncodeNameTypes.encodings[iBestEncType].encodetype,
                 g_EncodeNameTypes.encodings[iBestEncType].encodename );
  }
  return( iRetCode );
}



/*****************************************************************************
 *                       --- pDetectHTMLdoc ---
 *
 * Purpose: Detect HTML document in buffer
 *   Input: unsigned char *    pbuf     -  buffer to detect
 *          unsigned long int  bufsize  -  buffer size
 *          pbmtable           pbm      -  Boyer-Moore table
 *          int                icase    -  case-sensitive flag to search
 *  Output: unsigned char *             -  NULL if not HTML found
 *                                       otherwise pointer to header of HTML
 * Written: by Dmitry V.Stefankov 11-14-1998
 *****************************************************************************/
unsigned char *  pDetectHTMLdoc( unsigned char * pbuf,
                                 unsigned long int buflen,
                                 pbmtable pbm, int icase )
{
  unsigned char *   pend = pbuf;            /* Temporary */
  unsigned char *   pbegin;                 /* Temporary */

/*------------------------ Test for HTML document --------------------------*/
  initBMtable( (unsigned char*)g_szHTML, strlen(g_szHTML),
               pbm, icase );
  pbegin = searchBufBM( pend, buflen, pbm, (unsigned char*)g_szHTML,
                    strlen(g_szHTML), icase );
  if (pbegin == NULL)
  {
    printf( "ERROR: (pDetectHTMLdoc) this is not HTML document.\n" );
    return( NULL );
  }
  buflen -= (pbegin - pend);
  pend = pbegin;

/*-------------------- Test for head of HTML document ----------------------*/
  initBMtable( (unsigned char*)g_szHtmlHeadEnd, strlen(g_szHtmlHeadEnd),
               pbm, icase );
  pbegin = searchBufBM( pend, buflen, pbm, (unsigned char*)g_szHtmlHeadEnd,
                          strlen(g_szHtmlHeadEnd), icase );
  if (pbegin == NULL)
    printf( "ERROR: (pDetectHTMLdoc) no header is in HTML document.\n" );
  return( pbegin );
}

/*
  Sample of russian letters frequency for standard russian works
  like anectdos, Barkov (poems), Aspasia (history), Fedorov (Ermak),
  Koshevnikov (Shield and sword), Massi (Nik and Alex) and, classic
  of russian literature of XX century, Stefankov (I no like people).
    Letter       Freq   Percent
   --------     ------  -------
 'Ä' (0x80) =    10488 ( 0.19007)
 'Å' (0x81) =     5397 ( 0.09781)
 'Ç' (0x82) =    16708 ( 0.30280)
 'É' (0x83) =     6525 ( 0.11825)
 'Ñ' (0x84) =     7446 ( 0.13494)
 'Ö' (0x85) =     4643 ( 0.08415)
 'Ü' (0x86) =     1069 ( 0.01937)
 'á' (0x87) =     3782 ( 0.06854)
 'à' (0x88) =     9960 ( 0.18051)
 'â' (0x89) =       72 ( 0.00130)
 'ä' (0x8A) =    10292 ( 0.18652)
 'ã' (0x8B) =     2946 ( 0.05339)
 'å' (0x8C) =     6689 ( 0.12122)
 'ç' (0x8D) =    11881 ( 0.21532)
 'é' (0x8E) =     9393 ( 0.17023)
 'è' (0x8F) =    14214 ( 0.25760)
 'ê' (0x90) =     5135 ( 0.09306)
 'ë' (0x91) =    11691 ( 0.21188)
 'í' (0x92) =     6794 ( 0.12313)
 'ì' (0x93) =     2591 ( 0.04696)
 'î' (0x94) =     1943 ( 0.03521)
 'ï' (0x95) =     2060 ( 0.03733)
 'ñ' (0x96) =      797 ( 0.01444)
 'ó' (0x97) =     2767 ( 0.05015)
 'ò' (0x98) =     1920 ( 0.03480)
 'ô' (0x99) =       83 ( 0.00150)
 'ö' (0x9A) =        2 ( 0.00004)
 'õ' (0x9B) =       92 ( 0.00167)
 'ú' (0x9C) =       95 ( 0.00172)
 'ù' (0x9D) =     3054 ( 0.05535)
 'û' (0x9E) =      409 ( 0.00741)
 'ü' (0x9F) =     2906 ( 0.05267)
 '†' (0xA0) =   452259 ( 8.19630)
 '°' (0xA1) =    89764 ( 1.62679)
 '¢' (0xA2) =   233476 ( 4.23129)
 '£' (0xA3) =    97461 ( 1.76629)
 '§' (0xA4) =   161048 ( 2.91868)
 '•' (0xA5) =   448890 ( 8.13524)
 '¶' (0xA6) =    52011 ( 0.94260)
 'ß' (0xA7) =    91834 ( 1.66431)
 '®' (0xA8) =   393290 ( 7.12760)
 '©' (0xA9) =    69266 ( 1.25531)
 '™' (0xAA) =   189493 ( 3.43418)
 '´' (0xAB) =   270484 ( 4.90199)
 '¨' (0xAC) =   168562 ( 3.05485)
 '≠' (0xAD) =   335087 ( 6.07279)
 'Æ' (0xAE) =   580466 (10.51979)
 'Ø' (0xAF) =   143259 ( 2.59628)
 '‡' (0xE0) =   230573 ( 4.17868)
 '·' (0xE1) =   293533 ( 5.31970)
 '‚' (0xE2) =   312375 ( 5.66118)
 '„' (0xE3) =   153390 ( 2.77989)
 '‰' (0xE4) =    11333 ( 0.20539)
 'Â' (0xE5) =    52791 ( 0.95673)
 'Ê' (0xE6) =    28120 ( 0.50962)
 'Á' (0xE7) =    72414 ( 1.31236)
 'Ë' (0xE8) =    44445 ( 0.80548)
 'È' (0xE9) =    17745 ( 0.32159)
 'Í' (0xEA) =     1439 ( 0.02608)
 'Î' (0xEB) =   110656 ( 2.00542)
 'Ï' (0xEC) =    98547 ( 1.78597)
 'Ì' (0xED) =    11484 ( 0.20812)
 'Ó' (0xEE) =    33376 ( 0.60487)
 'Ô' (0xEF) =   105098 ( 1.90469)
 '' (0xF0) =        0 ( 0.00000)
 'Ò' (0xF1) =       33 ( 0.00060)
total = 5517846
*/
