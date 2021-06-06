//****************************************************************************
//                             File RASKEEP.H
//
//                  RAS Connection Keep CPL definitions
//
//      Copyright (c) Dmitry V. Stefankov, 1997. All rights reserved.
//
//****************************************************************************
//
//   $Source: F:/MSVC20/SOURCE/RASKEEPD/RCS/raskeep.h $
//  $RCSfile: raskeep.h $
//   $Author: dstef $
//     $Date: 1998/10/03 13:48:31 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: raskeep.h $
//      Revision 1.1  1998/10/03 13:48:31  dstef
//      Initial revision
//
//
//****************************************************************************


#ifndef _RASKEEP_H_
#define _RASKEEP_H_


#define CPCAPTION      1

//------------------------------- Resources ----------------------------------

#define RASKEEP_ICON     100
#define RASKEEP_NAME     101
#define RASKEEP_DESC     102
#define RASKEEP_DLG      103
#define CONNECT_ICON     104
#define HELP_DLG         105
#define HELP_ICON        106
#define ABOUT_DLG        107
#define ABOUT_ICON       108
#define AUTHOR_BMP       109
#define CANADA_ICON      110
#define PHONE_ICON       111

//----------------------------- Control items --------------------------------

#define ID_TEST_TIME     1000
#define ID_RETRY_TIME    1001
#define ID_RETRY         1002
#define ID_ERR_LOG       1003
#define ID_CLOSE_RAS     1004
#define ID_ALIVE_TIME    1005
#define ID_HARD_RETRY    1006
#define ID_SHUTDOWN      1007

#define ID_ICMP_TIMOUT   1010
#define ID_ICMP_DATSIZ   1011
#define ID_REMOTE_IP     1012

#define ID_RAS_ENTRY     1020
#define ID_RAS_USER      1021
#define ID_RAS_PASS      1022
#define ID_RAS_DOMAIN    1023

#define ID_SERVICE_STAT  1030

#define ID_HELP          1040

#define ID_ABOUT         1050
#define ID_AUTHOR_BMP    1051
#define ID_NT_VERSION    1052
#define ID_DAEMON_VER    1053


//--------------------------- Type definitions -------------------------------

typedef struct tagApplets
{
    int      icon;                          // icon resource identifier
    int      namestring;                    // name-string resource identifier
    int      descstring;                    // description-string resource identifier
    int      dlgtemplate;                   // dialog box template resource identifier
    DLGPROC  dlgfn;                         // dialog box procedure
} APPLETS;


//--------------------------- Miscellaneous -----------------------------------

#define     BST_UNCHECKED_NT    0
#define     BST_CHECKED_NT      1


#endif                                      // #ifndef _RASKEEP_H_

