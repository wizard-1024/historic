/*****************************************************************************
 *                             File SHUTDOWN.C
 *
 *              Shutdown a computer (power off) using APM BIOS
 *
 *    Copyright (c) Dmitry V. Stefankov, 1999-2000. All rights reserved.
 *
 *****************************************************************************/
/*
 *   $Source: d:/projects/hardware/shutdown/RCS/SHUTDOWN.C $
 *  $RCSfile: SHUTDOWN.C $
 *   $Author: dstef $
 *     $Date: 2001/12/02 13:26:56 $
 * $Revision: 1.7 $
 *   $Locker: dstef $
 *
 *      $Log: SHUTDOWN.C $
 *      Revision 1.7  2001/12/02 13:26:56  dstef
 *      Changed driver version to get from 1.2 to 1.1
 *
 *      Revision 1.6  2001/12/02 13:06:02  dstef
 *      Added check error on get version compilation conditional directive
 *      Added compile conditionals into source directly
 *
 *      Revision 1.5  2000/01/06 02:14:10  dstef
 *      Added user countdown optional parameter
 *      Added descriptions for program error codes
 *
 *      Revision 1.4  1999/12/30 18:49:32  dstef
 *      Added text description of error codes.
 *      Changed minor version.
 *
 *      Revision 1.3  1999/12/21 23:18:58  dstef
 *      Keystroke waiting from user moved to internal 10-sec time loop
 *
 *      Revision 1.2  1999/12/20 17:51:11  dstef
 *      Added compilation directive _PM_ENABLE
 *
 *      Revision 1.1  1999/12/20 05:33:13  dstef
 *      Initial revision
 *
 *****************************************************************************/



/*-------------------------- Compilation instructions ----------------------*/
/*
  The following platforms were used and tested:
  1.  MS-DOS environment, Borland C/C++ v3.1
         bcc -D_BCC shutdown.c
      MS-DOS environment, Microsoft Visual C/C++ v1.52
         cl -D_MSVC shutdown.c
*/



/*-------------------------- Check for platforms ---------------------------*/
#ifndef _BCC
#ifndef _MSVC
#error Select complier/platform: _MSVC, _BCC
#endif                                      /* #ifndef _MSVC */
#endif                                      /* #ifndef _BCC */



/*-------------------------- Standard definitions --------------------------*/
#include <stdlib.h>                         /* Standard library           */
#include <stdio.h>                          /* I/O standard streams       */
#include <conio.h>                          /* DOS I/O console functions  */
#include <dos.h>                            /* DOS and x86 specific calls */
#include <bios.h>                           /* BIOS calls                 */




//-------------------------- Conditional compilation --------------------------
#define     _CHECK_ERROR_ON_GET_VERSION     0
#define     _PM_ENABLE                      0



/*------------------------------- Description ------------------------------*/
const char  g_ProgramName[]       =   "ShutDown";
const char  g_ProgramVersion[]    =   "v1.03b";
const char  g_CopyrightNotice[]   =   "Copyright (c) 1999, 2001";
const char  g_Author[]            =   "Dmitry V. Stefankov";



/*------------------------------- Return Codes -----------------------------*/
#define   ERROR_DONE                 0      /* Running is successful        */
#define   ERROR_BAD_PARAMETER        1      /* Bad user supplied parameter  */
#define   ERROR_APM_BIOS_NOT_FOUND   2      /* APM BIOS not present         */
#define   ERROR_PM_SETSTATE_FAIL     3      /* Set PM state failed          */
#define   ERROR_PM_DRIVER_VER_FAIL   4      /* Cannot detect APM ver. 1.1+  */
#define   ERROR_RM_CONNECT_FAIL      5      /* Bad connection to RM interface */
#define   ERROR_POWER_OFF_FAIL       6      /* Cannot turn off power        */
#define   ERROR_ABORTED_BY_USER    254      /* User stopped our process     */
#define   ERROR_USER_HELP_OUTPUT   255      /* Output user help message     */



/*-------------------------------- APM BIOS --------------------------------*/
#define   APM_BIOS_INT             0x15
#define   APM_BIOS                 0x53
#define   APM_INST_CHECK           0x00
#define   APM_RM_INTRF_CONNECT     0x01
#define   APM_INTRF_DISCONNECT     0x04
#define   APM_TURN_OFF_SYSTEM      0x07
#define   APM_MANAGEMENT           0x08
#define   APM_DRIVER_VER           0x0E
#define   SYSTEM_BIOS_DEV          0x00
#define   ALL_DEV                  0x01
#define   APM_ENABLE               0x01
#define   APM_DISABLE              0x00



/*----------------------------- Miscellaneous ------------------------------*/
#define   SHUTDOWN_TIME           10        /* Default = 10 seconds */
#define   BIOS_TICKS_PER_SEC      18        /* BIOS timer           */



/*------------------------------- Messages --------------------------------*/
const char  g_chMSG_pm_enabled[]    =   "APM: power management enabled.\n";
const char  g_chMSG_system_down[]   =   "APM: now system down\n";
const char  g_chMSG_intrf_disc[]    =   "APM: Disconnected from interface.\n";
const char  g_chMSG_intrf_conn[]    =   "APM: Connected to real-mode interface.\n";
const char  g_chMSG_abort[]         =   "\nAPM: aborted by user.\n";

const char	g_chMSG_01[]     =  "power management functionality disabled";
const char	g_chMSG_02[]     =  "interface connection already in effect";
const char	g_chMSG_03[]     =  "interface not connected";
const char	g_chMSG_04[]     =  "real-mode interface not connected";
const char	g_chMSG_05[]     =  "16-bit protected-mode interface already connected";
const char	g_chMSG_06[]     =  "16-bit protected-mode interface not supported";
const char	g_chMSG_07[]     =  "32-bit protected-mode interface already connected";
const char	g_chMSG_08[]     =  "32-bit protected-mode interface not supported";
const char	g_chMSG_09[]     =  "unrecognized device ID";
const char	g_chMSG_0A[]     =  "invalid parameter value in CX";
const char	g_chMSG_0B[]     =  "(APM v1.1) interface not engaged";
const char	g_chMSG_0C[]     =  "(APM v1.2) function not supported";
const char	g_chMSG_0D[]     =  "(APM v1.2) Resume Timer disabled";
const char	g_chMSG_0E_1F[]  =  "reserved for other interface and general errors";
const char	g_chMSG_20_3F[]  =  "reserved for CPU errors";
const char	g_chMSG_40_5F[]  =  "reserved for device errors";
const char	g_chMSG_60[]     =  "can't enter requested state";
const char	g_chMSG_61_7F[]  =  "reserved for other system errors";
const char	g_chMSG_80[]     =  "no power management events pending";
const char	g_chMSG_81_85[]  =  "reserved for other power management event errors";
const char	g_chMSG_86[]     =  "APM not present";
const char	g_chMSG_87_9F[]  =  "reserved for other power management event errors";
const char	g_chMSG_A0_FE[]  =  "reserved";
const char	g_chMSG_FF[]     =  "undefined";



/*----------------------------- Structures --------------------------------*/



/*----------------------------- Global data --------------------------------*/
static char  rcsid[] = "$Id: SHUTDOWN.C 1.7 2001/12/02 13:26:56 dstef Exp dstef $";



/*------------------------- Function Prototype -----------------------------*/
const char *  errstr( int errorcode );



/*****************************************************************************
 *                              --- main ---
 *
 * Purpose: Main program function
 *   Input: int   argc    - argument count
 *          char **argv[] - argument list
 *  Output: int           - exit code (see above)
 * Written: by Dmitry V.Stefankov 05-31-1998
 *****************************************************************************/
int main( int argc, char *argv[] )
{
    union REGS         inregs;              /* Input for BIOS call    */
    union REGS         outregs;             /* Output for BIOS call   */
    long int           old_bios_time;       /* Bios time counter      */
    long int           new_bios_time;       /* Bios time counter      */
    int                i;                   /* Temporary              */
    int          CountDown = SHUTDOWN_TIME; /* Counter down           */
#if _PM_ENABLE
    int                pm_enabled = 1;      /* Power management flag  */
#endif                                      /* #if _PM_ENABLE         */


/*-------------------------- Compiler test phase ---------------------------*/
#ifdef  _TEST
#if __STDC__ == 0 && !defined(__cplusplus)
  printf("cc is not ANSI C compliant\n");
  return 0;
#else
  if (g_iDebugLevel > 0)
    printf( "%s compiled at %s %s. This statement is at line %d.\n",
            __FILE__, __DATE__, __TIME__, __LINE__);
#endif                                      /* __STDC__ == 0 && !defined(__cplusplus) */
#endif                                      /* #ifdef  _TEST */

/*-------------------------- Process comand parameters ---------------------*/
  if (argc == 2) {
     CountDown = atoi( argv[1] );
  }
  else {
    if (argc > 2) {
      printf( "Usage:  shutdown [seconds_before_turn_off],  default=10sec\n" );
      return( ERROR_USER_HELP_OUTPUT );
    }
  }

/*----------------------------- Initial logo -------------------------------*/
  printf( "System shutdown %s, %s %s\n",
          g_ProgramVersion, g_CopyrightNotice, g_Author
        );

/*------------------------------ Detect APM BIOS----------------------------*/
  inregs.x.ax = (APM_BIOS << 8) | APM_INST_CHECK;
  inregs.x.bx = SYSTEM_BIOS_DEV;
  int86( APM_BIOS_INT, &inregs, &outregs);
  if ( outregs.x.cflag)
  {
     printf( "ERROR: APM BIOS not found, errcode = 0x%02X\n", outregs.h.ah );
     return( ERROR_APM_BIOS_NOT_FOUND );
  }
  printf( "APM BIOS version = %d.%d\n", outregs.h.ah, outregs.h.al );
  printf( "APM BIOS id = 0x%04X (%c%c)\n", outregs.x.bx,
                                         outregs.h.bh, outregs.h.bl );
  printf( "APM BIOS flags = 0x%04X (see meaning below)\n", outregs.x.cx );
  if (outregs.x.cx & 1)
     printf( "APM Flags: 16-bit protected mode interface supported\n" );
  else
     printf( "APM Flags: 16-bit protected mode interface not supported\n" );

  if (outregs.x.cx & 2)
     printf( "APM Flags: 32-bit protected mode interface supported\n" );
  else
     printf( "APM Flags: 32-bit protected mode interface not supported\n" );

  if (outregs.x.cx & 4)
     printf( "APM Flags: CPU idle call reduces processor speed\n" );
  else
     printf( "APM Flags: CPU idle call not reduces processor speed\n" );

  if (outregs.x.cx & 8) {
#if _PM_ENABLE
     pm_enabled = 0;
#endif                                      /* #if _PM_ENABLE */
     printf( "APM Flags: BIOS power management disabled\n" );
  }
  else
     printf( "APM Flags: BIOS power management enabled\n" );

  if (outregs.x.cx & 16)
     printf( "APM Flags: BIOS power management disengaged (APM v1.1)\n" );
  else
     printf( "APM Flags: BIOS power management engaged (APM v1.1)\n" );

/*----------------------- Disconnect from interface-------------------------*/
  inregs.x.ax = (APM_BIOS << 8) | APM_INTRF_DISCONNECT;
  inregs.x.bx = SYSTEM_BIOS_DEV;
  int86( APM_BIOS_INT, &inregs, &outregs);
  if ( outregs.x.cflag) {
      printf( "ERROR: APM BIOS call to disconnect interface failed.\n" );
      printf( "ERROR: errcode = 0x%02X (%s)\n", outregs.h.ah, errstr(outregs.h.ah) );
  }
  else
      printf( g_chMSG_intrf_disc );

  inregs.x.ax = (APM_BIOS << 8) | APM_RM_INTRF_CONNECT;
  inregs.x.bx = SYSTEM_BIOS_DEV;
  int86( APM_BIOS_INT, &inregs, &outregs);
#if 0
  outregs.x.cflag = 1;
  outregs.h.ah = 0x60;
#endif
  if ( outregs.x.cflag) {
     printf( "ERROR: APM BIOS call to connect real-mode interface failed.\n" );
     printf( "ERROR: errcode = 0x%02X (%s)\n", outregs.h.ah, errstr(outregs.h.ah) );
     return( ERROR_RM_CONNECT_FAIL );
  }
  printf( g_chMSG_intrf_conn );

/*----------------- Check for APM BIOS version 1.1+ ------------------------*/
  inregs.x.ax = (APM_BIOS << 8) | APM_DRIVER_VER;
  inregs.x.bx = SYSTEM_BIOS_DEV;
  inregs.x.cx = (0x01 << 8) | 0x01;
  int86( APM_BIOS_INT, &inregs, &outregs);
  if ( outregs.x.cflag) {
     printf( "ERROR: APM BIOS call to get driver version failed\n" );
     printf( "ERROR: errcode = 0x%02X (%s)\n", outregs.h.ah, errstr(outregs.h.ah) );
#if _CHECK_ERROR_ON_GET_VERSION
     return( ERROR_PM_DRIVER_VER_FAIL );
#endif                                      /* #if _CHECK_ERROR_ON_GET_VERSION */
  }
  else {
     printf( "APM BIOS connection version = %d.%d\n", outregs.h.ah, outregs.h.al );
  }

/*---------------------- Enable power management ---------------------------*/
#if _PM_ENABLE
  if (!pm_enabled) {
    inregs.x.ax = (APM_BIOS << 8) | APM_MANAGEMENT;
    inregs.x.bx = ALL_DEV;                    /* APM v1.1+ */
    inregs.x.cx = APM_ENABLE;
    int86( APM_BIOS_INT, &inregs, &outregs);
    if ( outregs.x.cflag) {
       printf( "ERROR: APM BIOS call to set PM state failed.\n" );
       printf( "ERROR: errcode = 0x%02X (%s)\n", outregs.h.ah, errstr(outregs.h.ah) );
       return( ERROR_PM_SETSTATE_FAIL );
    }
    printf( g_chMSG_pm_enabled );
  }
#endif                                      /* #if _PM_ENABLE */

/*----------------- Give a user a chance before shutdown -------------------*/
  printf( "APM: system will be down during %d seconds. Press any key to stop it.\n",
           CountDown );
  for(i=0; i < CountDown; i++) {
     printf( "." );
     _bios_timeofday(_TIME_GETCLOCK, &old_bios_time);
     do {
       if ( kbhit() ) {
         i = getch();
         printf( g_chMSG_abort );
         return( ERROR_ABORTED_BY_USER );
       }
       _bios_timeofday(_TIME_GETCLOCK, &new_bios_time);
     } while( (new_bios_time-old_bios_time) < BIOS_TICKS_PER_SEC);
  }
  printf( "\n" );

/*---------------------- Turn off power of system --------------------------*/
  inregs.x.ax = (APM_BIOS << 8) | APM_TURN_OFF_SYSTEM;
  inregs.x.cx = 0x003;
  inregs.x.bx = ALL_DEV;
#if 1
  int86( APM_BIOS_INT, &inregs, &outregs);
#endif
  if ( outregs.x.cflag) {
     printf( "ERROR: APM BIOS call to turn off system failed.\n" );
     printf( "ERROR: errcode = 0x%02X (%s)\n", outregs.h.ah, errstr(outregs.h.ah) );
     return( ERROR_POWER_OFF_FAIL );
  }
  printf( g_chMSG_system_down );

/*--------------------------- Terminate program  ---------------------------*/
  return( ERROR_DONE );
}



/*****************************************************************************
 *                             --- errstr ---
 *
 * Purpose: Searches array of error messages
 *   Input: int         errorcode - APM error code
 *  Output: const char *          - error message (ptr)
 * Written: by Dmitry V.Stefankov 12-30-1999
 *****************************************************************************/
const char * errstr( int errorcode )
{
    const char * pcstr = NULL;              /* Message storage pointer */

    if ( (errorcode >= 0x0E) && (errorcode <= 0x1F) ) {
        pcstr = g_chMSG_0E_1F;
    }
    if ( (errorcode >= 0x20) && (errorcode <= 0x3F) ) {
          pcstr = g_chMSG_20_3F;
    }
    if ( (errorcode >= 0x40) && (errorcode <= 0x5F) ) {
          pcstr = g_chMSG_40_5F;
    }
    if ( (errorcode >= 0x61) && (errorcode <= 0x7F) ) {
          pcstr = g_chMSG_61_7F;
    }
    if ( (errorcode >= 0x81) && (errorcode <= 0x85) ) {
          pcstr = g_chMSG_81_85;
    }
    if ( (errorcode >= 0x87) && (errorcode <= 0x9F) ) {
          pcstr = g_chMSG_87_9F;
    }
    if ( (errorcode >= 0xA0) && (errorcode <= 0xFE) ) {
          pcstr = g_chMSG_A0_FE;
    }
    switch ( errorcode ) {
        case 0x01:  pcstr = g_chMSG_01;
                    break;
        case 0x02:  pcstr = g_chMSG_02;
                    break;
        case 0x03:  pcstr = g_chMSG_03;
                    break;
        case 0x04:  pcstr = g_chMSG_04;
                    break;
        case 0x05:  pcstr = g_chMSG_05;
                    break;
        case 0x06:  pcstr = g_chMSG_06;
                    break;
        case 0x07:  pcstr = g_chMSG_07;
                    break;
        case 0x08:  pcstr = g_chMSG_08;
                    break;
        case 0x09:  pcstr = g_chMSG_09;
                    break;
        case 0x0A:  pcstr = g_chMSG_0A;
                    break;
        case 0x0B:  pcstr = g_chMSG_0B;
                    break;
        case 0x0C:  pcstr = g_chMSG_0C;
                    break;
        case 0x0D:  pcstr = g_chMSG_0D;
                    break;
        case 0x60:  pcstr = g_chMSG_60;
                    break;
        case 0x80:  pcstr = g_chMSG_80;
                    break;
        case 0x86:  pcstr = g_chMSG_86;
                    break;
        case 0xFF:  pcstr = g_chMSG_FF;
                    break;
        default:    ;
                    break;
    }

    return( pcstr );
}
