/*****************************************************************************
 *                             File PWDGEN.C
 *
 *      Simple effective password generator (multiplatform version)
 *
 *   Copyright (c) Dmitry V. Stefankov, 1998-2003. All rights reserved.
 *
 *****************************************************************************/
/*
 *   $Source: d:/projects/misc/pwdgen/RCS/pwdgen.c $
 *  $RCSfile: pwdgen.c $
 *   $Author: dstef $
 *     $Date: 2003/02/07 16:06:54 $
 * $Revision: 1.6 $
 *   $Locker: dstef $
 *
 *      $Log: pwdgen.c $
 *      Revision 1.6  2003/02/07 16:06:54  dstef
 *      Added zone spacing checking
 *      Added minimum chars/digits checking
 *
 *      Revision 1.5  2000/10/07 19:12:48  dstef
 *      Switched to multi-platform code development
 *      Added srandom() and random() functions
 *      Added switch -a to generate 8 passwords at once
 *
 *      Revision 1.4  1999/12/31 00:14:51  dstef
 *      Updated copyright notice
 *
 *      Revision 1.3  1999/12/31 00:11:19  dstef
 *      Added DJGPP compiler support
 *
 *      Revision 1.2  1998/12/23 13:31:42  dstef
 *      Add command-line parameters parsing
 *      Replace absolute values to symbolic constants
 *      Make strict ANSI version
 *      Tested for all target platforms
 *      Set new password available lengths
 *
 *      Revision 1.1  1998/12/21 15:00:47  dstef
 *      Initial revision
 *
 *****************************************************************************/





/*-------------------------- Check for platforms ---------------------------*/
#ifndef _MSDOS
#ifndef _WIN32
#ifndef _UNIX
#error Select complier/platform: _MSDOS, _WIN32, _UNIX
#endif                                      /* #ifndef _UNIX */
#endif                                      /* #ifndef _WIN32 */
#endif                                      /* #ifndef _MSDOS */



/*-------------------------- Standard definitions --------------------------*/
#include <stdio.h>                          /* I/O standard streams     */
#include <stdlib.h>                         /* Miscellaneous            */
#include <string.h>                         /* String manipulations     */
#include <ctype.h>                          /* Character manipulations  */
#include <time.h>                           /* Time/date accounting     */



/*------------------------------- Description ------------------------------*/
const char  g_ProgramName[]       =   "Password Generator";
const char  g_ProgramVersion[]    =   "v1.6";
const char  g_CopyrightNotice[]   =   "Copyright (c) 1998,2003";
const char  g_Author[]            =   "Dmitry Stefankov";
const char  g_CopyrightHTML[]     =   "  v1.6   (c) 1998,2003";



/*------------------------------- Return Codes -----------------------------*/
#define   ERROR_DONE                 0     /* Running is successful        */
#define   ERROR_BAD_PARAMETER        1     /* Bad user supplied parameter  */
#define   ERROR_BAD_PASS_LEN         2     /* Wrong password length        */
#define   ERROR_ATTEMPTS_EXCEED      3     /* Too much attempts            */
#define   ERROR_USER_HELP_OUTPUT   255     /* Output user help message     */



/*----------------------------- Miscellaneous ------------------------------*/
#define   MATRIX_HLEN              10       /* Password alphabet space */
#define   MATRIX_VLEN              4
#define   MIN_PWD_LEN              4        /* Accepted Password length */
#define   DEF_PWD_LEN              8
#define   MAX_PWD_LEN              16
#define   MAX_CHAR_ATTEMPTS        200      /* No try more */
#define   STD_DIFF_X               3        /* Difference in X */
#define   STD_DIFF_Y               1        /* Difference in Y */
#define   MIN_DIGITS               2        /* Minimum digits per password */
#define   MIN_UPCAS                2        /* Minimum upper-case letters per password */
#define   MIN_LOWCAS               2        /* Minimum lower-case letters per password */
#define   MIN_ZONE_COUNT           2        /* Minimum chars per zone */
#define   MAX_ZONE_COUNT           3        /* Maximum chars per zone */


/*----------------------------- Global data --------------------------------*/
static char  rcsid[] = "$Id: pwdgen.c 1.6 2003/02/07 16:06:54 dstef Exp dstef $";

char  g_SymbolSpace[MATRIX_VLEN][MATRIX_HLEN] = {
              { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' },
              { 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p' },
              { 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',  0  },
              { 'z', 'x', 'c', 'v', 'b', 'n', 'm',  0,   0,   0  }
                                                };
char  g_ZoneSpace[MATRIX_VLEN][MATRIX_HLEN] = {
              {  1,   1,   1,   2,   2,   2,   3,   3,   3,   3  },
              {  1,   1,   1,   2,   2,   2,   3,   3,   3,   3  },
              {  1,   1,   1,   2,   2,   2,   3,   3,   3,   0  },
              {  1,   1,   1,   2,   2,   2,   3,   0,   0,   0  }
                                                };
int  g_iDebugLevel = 0;                     /* Debugging information */
int  g_fVerbose    = 0;                     /* Verbose output */
int  g_iMaxPwdsCount = 1;                   /* Number of passwords */
int  g_TestMinCount = 1;                    /* Number digits/letters per password */
int  g_TestZoneCount = 1;                   /* Check zones presence */


/*------------------------- Function Prototype -----------------------------*/
int  iMatrixX( char chIn );
int  iMatrixY( char chIn );



/*****************************************************************************
 *                              --- main ---
 *
 * Purpose: Main program function
 *   Input: int   argc     -  argument count
 *          char **argv[]  -  argument list
 *  Output: int            -  exit code (see above)
 * Written: by Dmitry V.Stefankov 21-Dec-1998
 *****************************************************************************/
int main( int argc, char *argv[] )
{
  int          iArgc;                       /* Arguments number  */
  char       **lpszArgv;                    /* Arguments array   */
  int          iUserPwdLen = DEF_PWD_LEN;   /* Password length */
  int          iCharCount;                  /* Counter */
  char         chPrev;                      /* Previous char of password */
  char         chCur;                       /* Current char of password */
  int          fMatchChr;                   /* Flag to get good char */
  char         chUserPass[MAX_PWD_LEN+1];   /* Password string */
  int          iTemp;                       /* Temporary */
  int          iCurPosX;                    /* Matrix position on X */
  int          iCurPosY;                    /* Matrix position on Y */
  int          iPrevPosX  = -1;             /* Matrix position on X */
  int          iPrevPosY  = -1;             /* Matrix position on Y */
  int          iDiffX;                      /* Position diffence on X*/
  int          iDiffY;                      /* Position diffence on Y */
  int          iAttempts = 0;               /* Counter of try attempts */
  char         chTemp;                      /* Temporary */
  int          iDigits = 0;                 /* Digits counter */
  int          iUppers = 0;                 /* Uppercase letters counter */
  int          iLowers = 0;                 /* Lowercase letters counter */
  int          iCurZone;                    /* Char in zone */
  int          iZone1 = 0;                  /* Zone 1 counter */
  int          iZone2 = 0;                  /* Zone 2 counter */
  int          iZone3 = 0;                  /* Zone 3 counter */
  int          iAllPasses = 0;              /* All password generated */


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


/*-------------------------- Process comand parameters ---------------------*/
  iArgc   = argc;                           /* Copy argument indices */
  lpszArgv = (char **)argv;

  if (iArgc == 1)
  {                                         /* Print on-line help */
     printf( "NAME\n" );
     printf( "  pwdgen - simple effective password generator\n" );
     printf( "\n" );
     printf( "SYNOPSIS\n" );
     printf( "   pwdgen [-a] [-d] [-m] [-v] [-z] passlen\n" );
     printf( "\n" );
     printf( "DESCRIPTION\n" );
     printf( "  PWDGEN is a simple but enough effective password generator for anybody\n" );
     printf( "  who tired to invent good passwords. A password will contain a random set\n" );
     printf( "  of lowercase letters, and uppercase letters, and digits. A password will\n" );
     printf( "  not contain repeating characters and also it uses an algorithm excluding\n" );
     printf( "  usage of some neighbour characters. This algorithm will try also to select\n" );
     printf( "  on each pass a characters on QWERTY keyboard having differences in their\n" );
     printf( "  coordinates greater than %d on horizontal, and greater than %d on vertical\n",
                STD_DIFF_X, STD_DIFF_Y );
     printf( "  then previous character in absolute values, of course. In addition, we make\n" );
     printf( "  the checking that we have in password minimum %d digits, %d upper-case letters,\n",
                MIN_DIGITS, MIN_UPCAS );
     printf( "  and %d lower-case letters. You can disable this checking, but this is not\n", 
                MIN_LOWCAS );
     printf( "  recommended. It is possible to disable the zone checking.\n" );
     printf( "  The options are as follows:\n" );
     printf( "  -a   Generate 10 passwords ready to use.\n" );
     printf( "  -d   Debugging level.\n" );
     printf( "  -m   Disable minimum count checking for digits/letters.\n" );
     printf( "  -v   Verbose output.\n" );
     printf( "  -z   Disable zone checking for min/max chars presence.\n" );
     printf( "  passlen\n" );
     printf( "       Password length. Must be in range %d-%d chars.\n" ,
             MIN_PWD_LEN, MAX_PWD_LEN );
     printf( "\n" );
     printf( "HISTORY\n" );
     printf( "  PWDGEN command appeared in December 1998\n" );
     printf( "\n" );
     printf( "AUTHOR\n" );
     printf( "  Dmitry V. Stefankov  (dstef@wizards.pp.ru,dstef@radiomayak.ru)\n" );
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
                    g_iMaxPwdsCount = 10;   /* Find many passwords */
                    break;
                case 'd':
                    g_iDebugLevel = 1;      /* Some debugging */
                    break;
                case 'm':
                    g_TestMinCount = 0;     /* Disable min. checking */
                    break;
                case 'v':
                    g_fVerbose = 1;         /* Verbose output */
                    break;
                case 'z':
                    g_TestZoneCount = 0;    /* Disable zones checking */
                    break;
                default:
                    printf( "ERROR: unknown option: -%s\n", *lpszArgv );
                    return( ERROR_BAD_PARAMETER );
                    /* break; */
          } /*switch*/
       }
       else
       {
         iUserPwdLen = atoi( *lpszArgv );
         if ( (iUserPwdLen < MIN_PWD_LEN) || (iUserPwdLen> MAX_PWD_LEN) )
         {
           printf( "ERROR: password length must be in range %d-%d chars.\n",
                   MIN_PWD_LEN, MAX_PWD_LEN );
           return(ERROR_BAD_PASS_LEN);
         }/*if*/
       } /*if-else*/
     } /*while*/
  } /*if-else*/


/*--------------------------- Print hello banner ---------------------------*/
  if (g_fVerbose)
    printf( "%s %s, %s %s\n", g_ProgramName, g_ProgramVersion,
                              g_CopyrightNotice, g_Author );


/*------------------------ Try to generate password ------------------------*/
  if (g_iDebugLevel > 0)
    printf( "DEBUG: passlen=%d.\n", iUserPwdLen );

  chPrev = 0;
#if defined(_WIN32) || defined(_BCC) || defined(_MSVC)
  srand( (unsigned int) time(0) );
#else
#if defined(_UNIX) || defined(_DJGPP)
  srandom( (unsigned int) time(0) );
#else
#error  Undefined platform for function srand() or srandom()
#endif                                      /* #if defined(_UNIX) || defined(_DJGPP) */
#endif                                      /* #if defined(_WIN32) || defined(_BCC) || defined(_MSC) */
  if (g_iDebugLevel > 0)
    printf( "DEBUG: RAND_MAX = %lu\n", (long unsigned int)RAND_MAX );

  while( g_iMaxPwdsCount-- )
  {
TryThis:
      iPrevPosX  = -1; iPrevPosY  = -1;
      iAttempts = 0; chPrev = 0;
      iDigits = 0; iUppers = 0; iLowers = 0;
      iZone1 = 0; iZone2 = 0; iZone3 = 0;

      for(iCharCount=0; iCharCount<iUserPwdLen; iCharCount++)
      {
        fMatchChr = 0;
        do {
    Again:
#if defined(_WIN32) || defined(_BCC) || defined(_MSVC)
          chCur = (rand() % 128);
#else
#if defined(_UNIX) || defined(_DJGPP)
          chCur = (random() % 128);
#else
#error  Undefined platform for function rand() or random()
#endif                                      /* #if defined(_UNIX) || defined(_DJGPP) */
#endif                                      /* #if defined(_WIN32) || defined(_BCC) || defined(_MSC) */
    #if 0
          chCur = toupper(chCur);
    #endif
    #if 0
          chCur = tolower(chCur);
    #endif
          if ( isdigit(chCur) || isalpha(chCur) )
          {
            iAttempts++;
            if (iAttempts > MAX_CHAR_ATTEMPTS)
            {
              printf( "ERROR: %d attempts. Too much. Try again.\n", iAttempts);
              return(ERROR_ATTEMPTS_EXCEED);
            }
            iCurPosX = iMatrixX( (char)tolower(chCur) );
            iCurPosY = iMatrixY( (char)tolower(chCur) );
            iCurZone = g_ZoneSpace[iCurPosY][iCurPosX];
            if (g_iDebugLevel > 0)
              printf( "DEBUG: idx=%d, char=%c, x=%d, y=%d, zn=%d", 
                      iCharCount ,chCur, iCurPosX, iCurPosY, iCurZone );
            if (chPrev)
            {
              for(iTemp=0; iTemp<iCharCount; iTemp++)
              {
                chTemp = tolower(chUserPass[iTemp]);
                if ( chTemp == tolower(chCur) )
                {
                  if (g_iDebugLevel > 0)        /* Exclude duplicate chars */
                    printf( ", sametest failed, char rejected.\n" );
                  goto Again;
                }
    #if 0
                iDiffX = abs(iCurPosX - iMatrixX(chTemp));
                iDiffY = abs(iCurPosY - iMatrixY(chTemp));
                if ((iDiffX+iDiffY) < 2)
                {                               /* Reject neihgbours */
                  if (g_iDebugLevel > 0)
                    printf( ", mintest failed (diffX=%d), char rejected.\n" , iDiffX);
                  goto Again;
                }
    #endif
              }/*for*/
              if (iCharCount > (iUserPwdLen-4)) /* Test for minimal presence */
              {
                if ( !(iUppers && iLowers && iDigits) )
                {
                  if ((iUppers == 0) && isalpha(chCur) )
                  {
                    if (g_iDebugLevel > 0)
                      printf( ", up" );
                    chCur = toupper(chCur);
                  }
                  else if ((iLowers == 0) && isalpha(chCur) )
                  {
                    if (g_iDebugLevel > 0)
                      printf( ", low" );
                    chCur = tolower(chCur);
                  }
                  else if ((iDigits == 0) && isdigit(chCur) )
                  {
                    if (g_iDebugLevel > 0)
                      printf( ", digit" );
                  }
                  else {
                  if (g_iDebugLevel > 0)
                    printf(", presence failed, char rejected\n" );
                   goto Again;
                  }
                }/*if*/
              }/*if*/
                                                /* Test distance vector */
              iDiffX = abs(iCurPosX - iPrevPosX);
              iDiffY = abs(iCurPosY - iPrevPosY);
              if (g_iDebugLevel > 0)
                printf( ", diffX=%d, diffY=%d", iDiffX, iDiffY );
              if ( (iDiffY*iDiffY+iDiffX*iDiffX) <
                   (STD_DIFF_X*STD_DIFF_X+STD_DIFF_Y*STD_DIFF_Y) )
              {                                 /* Reject this char */
                 if (g_iDebugLevel > 0)
                   printf( ", prevtest failed, char rejected\n" );
                 goto Again;
              }
              if ( isdigit(chCur) )  iDigits++;
              if ( islower(chCur) )  iLowers++;
              if ( isupper(chCur) )  iUppers++;
              if (g_iDebugLevel > 0)            /* Accept this char */
                printf( ", OK, char ackd");
            }
            else
            {
              if (g_iDebugLevel > 0)
                printf( ", first accepted" );
            }/*if-else*/
            chUserPass[iCharCount] = chCur;
            if (g_iDebugLevel > 0)
            {
              printf( ", pass=" );
              for(iTemp=0; iTemp<=iCharCount; iTemp++)
                    printf( "%c", chUserPass[iTemp] );
              printf( "\n" );
            }
            chPrev = chCur;
            iPrevPosX = iMatrixX( (char)tolower(chPrev) );
            iPrevPosY = iMatrixY( (char)tolower(chPrev) );
            fMatchChr = 1;
            if (iCurZone == 1) iZone1++;
            if (iCurZone == 2) iZone2++;
            if (iCurZone == 3) iZone3++;
          };/*if*/
        } while( !fMatchChr );
        /*do-while*/
      } /*for*/

      chUserPass[iUserPwdLen] = '\0';           /* Terminate a string */
      iAllPasses++;
      if (g_iDebugLevel > 0) 
        printf( "DEBUG: attempts=%d, digits=%d, uppers=%d, lowers=%d, zn1=%d, zn2=%d, zn3=%d\n",
                iAttempts, iDigits ,iUppers, iLowers, iZone1, iZone2, iZone3 );
      if (g_TestMinCount) {
        if ((iDigits < MIN_DIGITS) || (iUppers < MIN_UPCAS) || 
            (iLowers < MIN_LOWCAS)) {
          if (g_iDebugLevel > 0) 
            printf( "DEBUG: pass NOT accepted because min_digits=%d, min_uppers=%d, min_lowers=%d\n",
                     MIN_DIGITS, MIN_UPCAS, MIN_LOWCAS );
          goto TryThis;
        }
      }
      if (g_TestZoneCount) {
        if ((iZone1 < MIN_ZONE_COUNT) || (iZone2 < MIN_ZONE_COUNT) ||
            (iZone3 < MIN_ZONE_COUNT)) {
          if (g_iDebugLevel > 0) 
            printf( "DEBUG: pass NOT accepted because MINimum chars per zone present.\n" );
          goto TryThis;
        }
      }
      if (g_TestZoneCount) {
        if ((iZone1 > MAX_ZONE_COUNT) || (iZone2 > MAX_ZONE_COUNT) ||
            (iZone3 > MAX_ZONE_COUNT)) {
          if (g_iDebugLevel > 0) 
            printf( "DEBUG: pass NOT accepted because MAXimum chars per zone present.\n" );
          goto TryThis;
        }
      }
      printf( "%s\n", chUserPass );

  }/*while*/

  if ((g_fVerbose) || (g_iDebugLevel > 0)) {
    if (g_iDebugLevel > 0) printf( "DEBUG: " );
    printf( "Total passwords probed = %d.\n", iAllPasses );
  }


/*--------------------------- Terminate program  ---------------------------*/

  return 0;
}



/*****************************************************************************
 *                            --- iMatrixX ---
 *
 * Purpose: Detect X-position of char in symbol matrix
 *   Input: char chIn - incoming char
 *  Output: int       - X-position of char in matrix
 * Written: by Dmitry V.Stefankov 21-Dec-1998
 *****************************************************************************/
int  iMatrixX( char chIn )
{
  int   iTempX;                             /* X position */
  int   iTempY;                             /* Y position */

  for(iTempY=0; iTempY<MATRIX_VLEN; iTempY++)
    for(iTempX=0; iTempX<MATRIX_HLEN; iTempX++)
    {
       if (g_SymbolSpace[iTempY][iTempX] == chIn )
         return(iTempX);
    }/*for*/
  /*for*/

  return(-1);
}



/*****************************************************************************
 *                            --- iMatrixY ---
 *
 * Purpose: Detect Y-position of char in symbol matrix
 *   Input: char chIn - incoming char
 *  Output: int       - Y-position of char in matrix
 * Written: by Dmitry V.Stefankov 21-Dec-1998
 *****************************************************************************/
int  iMatrixY( char chIn )
{
  int   iTempX;                             /* X position */
  int   iTempY;                             /* Y position */

  for(iTempY=0; iTempY<MATRIX_VLEN; iTempY++)
    for(iTempX=0; iTempX<MATRIX_HLEN; iTempX++)
    {
       if (g_SymbolSpace[iTempY][iTempX] == chIn)
         return(iTempY);
    }/*for*/
  /*for*/

  return(-1);
}
