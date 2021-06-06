//****************************************************************************
//                             File RASDEFS.H
//
//                     General project definitions
//
//      Copyright (c) Dmitry V. Stefankov, 1997. All rights reserved.
//
//****************************************************************************
//
//   $Source: F:/MSVC20/SOURCE/RASKEEPD/RCS/rasdefs.h $
//  $RCSfile: rasdefs.h $
//   $Author: dstef $
//     $Date: 1998/10/03 13:47:36 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: rasdefs.h $
//      Revision 1.1  1998/10/03 13:47:36  dstef
//      Initial revision
//
//
//****************************************************************************

#ifndef _RASDEFS_H_
#define _RASDEFS_H_

//------------------------------- Defaults -----------------------------------

#define   ICMP_SENT_BUF_SIZE        1024    // ICMP echo packet (OUT)
#define   ICMP_RECV_BUF_SIZE        4096    // ICMP echo packet (IN)
#define   IP_ADDRESS_SIZE           24
#define   BAD_ENTRY_INDEX           0xFFFFFFFF
#define   DECIMAL_BASE              10
#define   WAIT_BEFORE_EXIT          3
#define   PING_DEF_TIMEOUT          1000
#define   PING_DEF_DATASIZE         1
#define   MS_PER_SEC                1000
#define   SEC_PER_MIN               60
#define   ICMP_DATA_FILL_CHAR       0x55
#define   PING_TEST_TIME_DF         180
#define   RAS_TEST_TIME_DF          60
#define   RAS_RETRY_COUNT_DF        3

#define   RAS_HARD_RETRY_TIMES      3*3
#define   RAS_HARD_RETRY_TIMEOUT    20

#define   SYSTEM_SHUTDOWN_TIME      60

#define   COPYRIGHT_CHAR            0xA9

#define   STD_SRVC_WAIT_TIME        3


//------------------------------- Return Codes --------------------------------

#define   RETCODE_DONE              0
#define   RETCODE_BAD_IP_ADDR       1
#define   RETCODE_NO_WINSOCK        2
#define   RETCODE_NO_WINSOCK_V11    3
#define   RETCODE_NO_CREATE_ICMP    4
#define   RETCODE_NO_ACTIVE_CONS    5
#define   RETCODE_NO_MATCH_CONN     6
#define   RETCODE_GENERAL_FAILURE   7
#define   RETCODE_WRONG_IP_ADDR     8
#define   RETCODE_NO_RAS_ENTRY      9
#define   RETCODE_SKIP_PING_PHASE  10
#define   RETCODE_CONN_NOT_LINKED  11


#endif                                      // #ifndef _RASDEFS_H_
