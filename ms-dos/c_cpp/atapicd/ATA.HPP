//****************************************************************************
//                              File ATA.HPP
//
//           ATA commands definitions for CD-ROM drive hardware
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: d:/projects/hardware/atapicd/RCS/ATA.HPP $
//  $RCSfile: ATA.HPP $
//   $Author: dstef $
//     $Date: 2003/01/27 20:09:01 $
// $Revision: 1.2 $
//   $Locker: dstef $
//
//      $Log: ATA.HPP $
//      Revision 1.2  2003/01/27 20:09:01  dstef
//      Fixed for DJGPP
//
//      Revision 1.1  1999/01/02 00:18:28  dstef
//      Initial revision
//
//
//****************************************************************************



//---------------------------CD-ROM ATA Commands-------------------------------
#if defined(_ATA_CMDS)
const  BYTE    bATA_cmd_NOP             =  0x00; // (M)andatory command
const  BYTE    bATA_cmd_Exec_Drv_Diag   =  0x90; // (M)andatory command
const  BYTE    bATA_cmd_Standby_Imm     =  0xE0; // (M)andatory command
const  BYTE    bATA_cmd_Standby         =  0xE2; // (O)ptional  command
const  BYTE    bATA_cmd_Idle_Imm        =  0xE1; // (M)andatory command
const  BYTE    bATA_cmd_Idle            =  0xE3; // (O)ptional  command
const  BYTE    bATA_cmd_Chk_Pwr_Mode    =  0xE5; // (M)andatory command
const  BYTE    bATA_cmd_Sleep           =  0xE6; // (M)andatory command
const  BYTE    bATA_cmd_Set_Features    =  0xEF; // (M)andatory command
#endif                                      // #if defined(_ATA_CMDS)
