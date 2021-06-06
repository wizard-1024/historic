{****************************************************************************
//                            File IDE-ATA.PAS
//
//              ATA-EIDE Drive Identification Program
//
//      Copyright (c) 1992, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/IDE-ATA/RCS/ide-ata.pas $
//  $RCSfile: ide-ata.pas $
//   $Author: dstef $
//     $Date: 1999/09/14 15:18:24 $
// $Revision: 1.5 $
//   $Locker: dstef $
//
//      $Log: ide-ata.pas $
//      Revision 1.5  1999/09/14 15:18:24  dstef
//      Updated descriptions
//
//      Revision 1.4  1999/09/14 15:15:57  dstef
//      Added workaround for 8.4G BIOS barrier
//
//      Revision 1.3  1999/08/24 23:01:19  dstef
//      Updated year format according Y2K
//
//      Revision 1.2  1998/11/24 14:40:10  dstef
//      Fixed 1024-cylinder limit bug
//
//      Revision 1.1  1998/10/03 14:20:08  dstef
//      Initial revision
//: 
//
//****************************************************************************}


{-------------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,    }
{                       AVAILABLE FOR ALL WORLD                           }
{ LIBRARY               SYSTEM UTILITIES                                  }
{ MODULE                IDE_ATA_DRIVE_INFO                                }
{ FILE NAME             IDE-ATA.PAS                                       }
{ PURPOSE               Read IDE/ATA-drive internal information           }
{ VERSION               2.65                                              }
{ DATE                  13-Sep-1999                                       }
{ DESIGN                Dmitry Stefankov                                  }
{                       (Original idea of Thomas J. Newman, 1991)         }
{ IMPLEMENTATION        Dmitry Stefankov                                  }
{ COMPANY               Freelance Software Engineer                       }
{ ADDRESS               Isakowskogo str, 4-2-30                           }
{                       Moscow, 123181                                    }
{                       Russia                                            }
{                       Telephone: +007 (095) 944-6304                    }
{ INTERNET              wizard@radio-msu.net, dstef@nsl.ru, dima@mccbn.ru }
{ COPYRIGHT NOTICE      Copyright (C) 1992-1999, Dmitry Stefankov         }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,             }
{                       NOT FOR COMMERCIAL PURPOSE                        }
{ COMPUTER              IBM PC or compatible                              }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                  }
{ COMPILER              Turbo Pascal Version 7.0                          }
{                       (Borland International Inc.)  or compatible       }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible                 }
{ LINKER                Turbo Pascal internal                             }
{ ARGUMENTS             See program on-line help                          }
{ RETURN                None                                              }
{ REQUIRES              Source Code Files                                 }
{                       None                                              }
{                       Object Code Files                                 }
{                       SHOWTERR.TPU   (Turbo Errors)                     }
{                       Project Maintence Files                           }
{                       None                                              }
{ NATURAL LANGUAGE      English Language                                  }
{ SPECIAL               Please note this program can have the problem     }
{                       with some 80286 (usually older) mainboards        }
{                       because their manufacturers don't wish to cor-    }
{                       rectly implement the ATA/IDE standard interface.  }
{                       According to ATA-2 speculations we have the       }
{                       following data transfer rates for the             }
{                       drive-controller-system:                          }
{                       A.  magnetic disk to disk cache                   }
{                       B.  magnetic disk to disk controller              }
{                       C.  disk cache to disk controller                 }
{                       D.  controller to system                          }
{                       Our program reports the case C and measures       }
{                       case D.                                           }
{ DESCRIPTION           1. Test drive 0 hardware for primary controller   }
{                       2. If hardware test successful                    }
{                             then issue IDENTIFY command for IDE-drive   }
{                       3. If command not failed                          }
{                            then display lot of info about drive,        }
{                            and ask about write buffer to file,          }
{                            and display possible logical configuration   }
{                            for drive through linear translation         }
{                       4.  Repeat steps  1 - 3  for (like above step)    }
{                            drive 1 on primary controller                }
{                            drive 0 on secondary controller              }
{                            drive 1 on secondary controller              }
{                       5. Optional:                                      }
{                            Repeat steps  1 - 3                          }
{                            drive 0 on tertiary controller               }
{                            drive 1 on tertiary controller               }
{                            drive 0 on quaternary controller             }
{                            drive 1 on quaternary controller             }
{                            drive 0 on user-defined controller           }
{                            drive 1 on user-defined  controller          }
{                       6. Display ROM BIOS HDD types table               }
{                       7. Get # of hard disks from System BIOS           }
{                       8. Display # of found IDE/ATA-drives              }
{ REVISION HISTORY      Dima Stefankov (DS)                               }
{                       1.00   26-Aug-1992  DS  initial release           }
{                       1.01   27-Aug-1992  DS  some corrections          }
{                       1.02   29-Aug-1992  DS  corrected some bugs       }
{                       1.10   08-Oct-1992  DS  added buffer write to file}
{                       1.11   27-Oct-1992  DS  some corrections          }
{                       1.12   02-Nov-1992  DS  some style changes        }
{                       1.20   24-Feb-1993  DS  fixed a bug with hexflags,}
{                                               added PLO bytes parameter }
{                       1.21   04-Jul-1993  DS  updated documentation     }
{                       1.22   30-Aug-1993  DS  added paged screen output }
{                       1.23   09-Sep-1993  DS  changed parameters order  }
{                       1.24   24-Sep-1993  DS  added CMOS suggested parms}
{                                               calculations screen, also }
{                                               added display of ROM BIOS }
{                                               HDD types table for CMOS  }
{                                               disk parameters setup, and}
{                                               fixed a bug with task file}
{                                               loading                   }
{                       1.30   19-Oct-1993  DS  added more ATA parameters }
{                                               according ATA draft stand-}
{                                               dard r4a of April 1993    }
{                       1.31   25-Nov-1993  DS  fixed a timing problem for}
{                                               a buffer reading (DRQ bit }
{                                               checking)                 }
{                       1.32   24-Jan-1994  DS  disabled an automatic soft}
{                                               reset of controller to fix}
{                                               a problem of a DOS output }
{                                               stream pipe               }
{                       2.00   19-May-1994  DS  fixed a bug for disk with }
{                                               too large capacity        }
{                                               added command line syntax }
{                       2.01   07-Jul-1994  DS  added debug switch        }
{                                               added time-indepedent     }
{                                               wait loops                }
{                                               fixed some bugs           }
{                       2.02   22-Jul-1994  DS  added ShowTErr unit       }
{                                               added more help for user  }
{                                               added hardware scan option}
{                                               removed 'DebugVersion'    }
{                                               generation (replaced by   }
{                                               switch '-debug')          }
{                       2.03   28-Jul-1994  DS  minor updates for help    }
{                       2.04   06-Aug-1994  DS  added output of current   }
{                                               BIOS/DOS parameters       }
{                       2.05   16-Sep-1994  DS  added switch 'DVM' for    }
{                                               cuted screen output       }
{                                               added two various formats }
{                                               for drive capacity        }
{                       2.06   18-Sep-1994  DS  fixed a bug with 1024th   }
{                                               cylinder at calculations  }
{                       2.07   22-Sep-1994  DS  some minor updates        }
{                       2.10   21-Jan-1995  DS  added new PIO modes and   }
{                                               transfer timing measures  }
{                       2.11   28-Jan-1995  DS  added 32-bit access mode  }
{                                               added xfr time measure    }
{                       2.12   10-Feb-1995  DS  fixed bug for advanced PIO}
{                                               mode calculations (speed) }
{                                               replaced switch 'DVM'     }
{                       2.13   10-Oct-1995  DS  changed some descriptions }
{                       2.20   06-Apr-1996  DS  added changes according   }
{                                               r0948DR3 (ATA-2) and      }
{                       2.21   07-Apr-1996  DS  fixed bug of size for     }
{                                               ide-info sector and minor }
{                                               text changes              }
{                       2.22   15-Sep-1996  DS  fixed a bug of displaying }
{                                               of logical drives params  }
{                                               when they (parameters) are}
{                                               actually absent           }
{                       2.30   27-Dec-1996  DS  Removed timer 0 code      }
{                                               Fixed bug of unformatted  }
{                                               capacity calculation      }
{                                               Added hex. representation }
{                                               for debug state output    }
{                                               And also some corrections }
{                       2.31   28-Dec-1996  DS  Add time measure switch   }
{                       2.32   04-Jun-1997  DS  Fixed no CMOS parameters  }
{                                               bug before calculations   }
{                       2.33   05-Jun-1997  DS  Fixed problem for CMOS    }
{                                               disk parameters searching }
{                       2.34   08-Jun-1997  DS  Added workaround code for }
{                                               Triones PCI EIDE drivers  }
{                       2.40   10-Jun-1997  DS  Added support for a more  }
{                                               drives and controllers    }
{                                               Changed timing algorithm  }
{                       2.50   19-Jun-1997  DS  Added interrupt support   }
{                       2.51   20-Jun-1997  DS  Fixed large disk capacity }
{                                               calculation bug           }
{                       2.52   29-Jun-1997  DS  Added drive emulation and }
{                                               fixed minor bugs          }
{                       2.53   21-Jul-1997  DS  Added BIOS parameters warn}
{                       2.54   23-Jul-1997  DS  Some corrections          }
{                       2.60   02-Aug-1997  DS  added switches -IRQx      }
{                                               make RCS version          }
{                       2.61   27-Aug-1997  DS  added LBA sectors right   }
{                                               calculation for oldest    }
{                                               hardware (before 1994)    }
{                       2.62   02-Sep-1997  DS  fixed open r/o file bug   }
{                       2.63   24-Nov-1998  DS  fixed >1024 cyls bug      }
{                       2.64   24-Aug-1999  DS  changed year 9x to 199x   }
{                       2.65   13-Sep-1999  DS  added workaround for 8.4G }
{                                               BIOS barrier              }
{-------------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   READ_IDE_ATA_DRIVE_INFO;


{** switches for compilation **}
{$A-}           {*  word-alignment      *}
{$S-}           {*  stack checking      *}
{$R-}           {*  range checking      *}
{$X+}           {*  extended syntax     *}


{*** other modules ***}
USES
  Strings, Dos, ShowTErr;


{** miscellaneous version **}


{*========================== CONSTANTS PART ============================*}

CONST
     asPurpose                  =       'IDE/ATA DRIVE INFO';
     asVersion                  =       '2.65';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1992, 1999';
     asProgram                  =       'IDE/ATA-Info';
     asProgramPrompt            =       asProgram+': ';
     asReleaseDate              =       '13-Sep-1999';
     asReleaseTime              =       '15:45';

     { exit codes }
       errTerminateOK           =     0;
       errUserAbort             =     1;
       errBadNumeric            =     2;
       errBadCPU                =     3;
       errBadSecsNum            =     4;
       errUserHelp              =     5;
       errNoPrefixSwitch        =     6;
       errBadBooleanParam       =     7;
       errBadWordParam          =     8;
       errBadWordParamRange     =     9;
       errBadPasStrParam        =    10;
       errBadPasStrParamRange   =    11;
       errUnsupportedSwitch     =    12;
       errBadByteParam          =    13;
       errBadByteParamRange     =    14;
       errBadUserFileName       =    15;
       errBadFileIO             =    16;

    { miscellaneous }
      errOK                     =     0;
      achSpace                  =     ' ';
      asBlank                   =     '';
      achHexPrefix              =     '$';
      achDosDelim               =     '.';
      achDosSwitch              =     '/';
      achUnixSwitch             =     '-';
      achPlus                   =     '+';
      achMinus                  =     '-';
      achColon                  =     ':';
      achEqual                  =     '=';
      achAsterisk               =     '*';
      achNULL                   =     #0;
      aMaxStrLen                =     255;
      aYes                      =     'Y';
      asDefExt                  =     'bin';
      asPrimary                 =     'primary';
      asSecondary               =     'secondary';
      asTertiary                =     'tertiary';
      asQuaternary              =     'quaternary';
      asUserDefined             =     'user defined';
      asDefaultOFF              =     'off';
      asDefaultON               =     'on';
      aPercent90                =     90;
      aPercent100               =     100;

     { screen output }
       aDisableScreenPage       =     0;
       aMinOutLineOnScreen      =     1;
       aDefMaxOutLineForScreen  =     23;
       aBigOutLinesForScreenNum =     2048;

     { Dos equates }
       aFirstDrive              =     1;
       aTenthDrive              =     10;
       aBytesPerKByte           =     1024;
       aKBytesPerMbyte          =     1024;
       aBytesPerDosSector       =     512;
       aWordsPerDosSector       =     aBytesPerDosSector DIV 2;
       aPhysDriveNum_0          =     0;
       aPhysDriveNum_1          =     1;
       aKiloByteSI              =     1000;
       aMegaByteSI              =     aKiloByteSI*aKiloByteSI;
       aBytesPerWord            =     2;
       aOneNanoSecond           =     1000000000;

     { Bios equates }
       aMinBiosCylNum           =     0;
       aMaxBiosCylNum           =     1023;
       aMinBiosHeadNum          =     0;
       aMaxBiosHeadNum          =     255;
       aMinBiosSecNum           =     1;
       aMaxBiosSecNum           =     63;
       aDefStdDosBiosSecNum     =     17;
       aStartHeadNum            =     aMinBiosHeadNum + 1;
       aMinHDD_CMOSType         =     1;
       aMaxHDD_CMOSType         =     47;
       aRomBiosSeg              =     $F000;
       aBiosTimerTicksDef       =     18;
       aIntDef                  =     $00;  {INT00}
       aIntMin                  =     $05;  {INT05}
       aIntMax                  =     $77;  {INT77}
       aIrqDef                  =     $00;  {no IRQ}
       aIrqMin                  =     $03;  {IRQ3}
       aIrqMax                  =     $0F;  {IRQ15}
       aBigMagicCyl100          =     100;
       aBigMagicCyl10           =     10;

     { Bit-mapped flags }
       btIdeDrive_00            =     $0001;
       btIdeDrive_01            =     $0002;
       btIdeDrive_02            =     $0004;
       btIdeDrive_03            =     $0008;
       btIdeDrive_04            =     $0010;
       btIdeDrive_05            =     $0020;
       btIdeDrive_06            =     $0040;
       btIdeDrive_07            =     $0080;
       btIdeDrive_08            =     $0100;
       btIdeDrive_09            =     $0200;

     { PC hardware ports }
       aDriveCtrlrBaseReg_0     =     $1F0;       { primary controller }
       aDriveCtrlrBaseReg_1     =     $1F0;
       aAltDriveStatusReg_0     =     $3F6;
       aDriveCtrlrBaseReg_2     =     $170;       { secondary controller }
       aDriveCtrlrBaseReg_3     =     $170;
       aAltDriveStatusReg_1     =     $376;
       aDriveCtrlrBaseReg_4     =     $1E8;       { tertiary controller }
       aDriveCtrlrBaseReg_5     =     $1E8;
       aAltDriveStatusReg_2     =     $3EE;
       aDriveCtrlrBaseReg_6     =     $168;       { quaternary controller }
       aDriveCtrlrBaseReg_7     =     $168;
       aAltDriveStatusReg_3     =     $36E;
       aIRQ9                    =     $71;
       aIRQ10                   =     $72;  {quaternary controller}
       aIRQ11                   =     $73;
       aIRQ12                   =     $74;  {tertiary controller}
       aIRQ14                   =     $76;  {primary controller}
       aIRQ15                   =     $77;  {secondary controller}
       ioBase8253               =     $40;
       ioTimerCount2            =     ioBase8253+2;
       ioTimerCtrl              =     ioBase8253+3;
       ioPortB                  =     $61;
       aIMR_Master              =     $21;
       aIMR_Slave               =     $A1;

     { controller status register bits }
       btCtlrBusy               =     $80;
       btDriveReady             =     $40;
       btWriteFault             =     $20;
       btSeekComplete           =     $10;
       btDataRequest            =     $08;
       btCmdErr                 =     $01;

     { sector/drive/head info }
       btCRCmode                =     $80;
       btSecSize512             =     $20;

     { sector equates }
        aSectorCountRegVal      =     $01;
        aSectorNumberRegVal     =     $01;

     { controller commands opcodes }
       cmdIDENTIFY              =     $EC;
       cmdDisableInts           =     $04;
       cmdEnableInts            =     $00;

     { IDE info record hard-coded values }
        dbSerialNumberLen                   =      20;
        dbCntlrFirmwareRevisionLen          =      8;
        dbModelNumberLen                    =      40;
        dwReservedPartSize1                 =      $A0-$8A;
        dwReservedPartSize2                 =      $100-$A8;
        dbVendorUniqueInfoTextLen           =      $140-$102;
        dwReservedPartSize3                 =      aBytesPerDosSector-$140;

    { bit values }
       btBit_0_ON               =       $0001;
       btBit_1_ON               =       $0002;
       btBit_2_ON               =       $0004;
       btBit_3_ON               =       $0008;
       btBit_4_ON               =       $0010;
       btBit_5_ON               =       $0020;
       btBit_6_ON               =       $0040;
       btBit_7_ON               =       $0080;
       btBit_8_ON               =       $0100;
       btBit_9_ON               =       $0200;
       btBit_A_ON               =       $0400;
       btBit_B_ON               =       $0800;
       btBit_C_ON               =       $1000;
       btBit_D_ON               =       $2000;
       btBit_E_ON               =       $4000;
       btBit_F_ON               =       $8000;

    { bit values }
       aTestPattern_00          =       $00;
       aTestPattern_55          =       $55;
       aTestPattern_AA          =       $AA;
       aTestPattern_FF          =       $FF;

    { parameter types }
       aParmIsIndefinite        =       0;
       aParmIsPascalStr         =       aParmIsIndefinite+1;
       aParmIsAsciiZ            =       aParmIsPascalStr+1;
       aParmIsBoolean           =       aParmIsAsciiZ+1;
       aParmIsByte              =       aParmIsBoolean+1;
       aParmIsInteger           =       aParmIsByte+1;
       aParmIsWord              =       aParmIsInteger+1;


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
  {* strings *}
       STR2                     =     STRING[2];
       STR3                     =     STRING[3];
       STR4                     =     STRING[4];
       STR8                     =     STRING[8];

  {* hard drive controller registers read map *}
    recHDISK_READ_REGS          =       RECORD
                 dwDataReg_RD              :     System.Word;
                 dwErrorReg_RD             :     System.Word;
                 dwSectorCountReg_RD       :     System.Word;
                 dwSectorNumberReg_RD      :     System.Word;
                 dwCylinderLowReg_RD       :     System.Word;
                 dwCylinderHighReg_RD      :     System.Word;
                 dwSDH_Reg_RD              :     System.Word;
                 dwStatusReg_RD            :     System.Word;
                                        END;
    {* recHDISK_READ_REGS *}


  {* hard drive controller registers write map *}
    recHDISK_WRITE_REGS          =       RECORD
                 dwDataReg_WR              :     System.Word;
                 dwWRC_Reg_WR              :     System.Word;
                 dwSectorCountReg_WR       :     System.Word;
                 dwSectorNumberReg_WR      :     System.Word;
                 dwCylinderLowReg_WR       :     System.Word;
                 dwCylinderHighReg_WR      :     System.Word;
                 dwSDH_Reg_WR              :     System.Word;
                 dwCommand_Reg_WR          :     System.Word;
                                        END;
    {* recHDISK_WRITE_REGS *}


    {* hard disk drive controller control block *}
      recHDISK_WRITE_CMD_BLOCK    =       RECORD
                 dbData_WR                 :     System.Byte;
                 dbWRC_WR                  :     System.Byte;
                 dbSectorCount_WR          :     System.Byte;
                 dbSectorNumber_WR         :     System.Byte;
                 dbCylinderLow_WR          :     System.Byte;
                 dbCylinderHigh_WR         :     System.Byte;
                 dbSDH_WR                  :     System.Byte;
                 dbCommand_WR              :     System.Byte;
                                          END;
    {* recHDISK_WRITE_CMD_BLOCK *}


    {* Configuration Parameters of IDE disk drive *}
    recIDE_Info_Sector  =  RECORD
                 dwGeneralConfigFlags           :       System.Word;                                              {00}
                 dwFixedCylsNum                 :       System.Word;                                              {02}
                 dwRemoveableCylsNumVU          :       System.Word;                                              {04}
                 dwHeadsNum                     :       System.Word;                                              {06}
                 dwUnfmtdBytesPerPhysTrkVU      :       System.Word;                                              {08}
                 dwUnfmtdBytesPerSecVU          :       System.Word;                                              {0A}
                 dwPhysSecsPerTrk               :       System.Word;                                              {0C}
                 dwInterSecGapBytesNumVU        :       System.Word;                                              {0E}
                 dwSyncFieldsBytesNumVU         :       System.Word;                                              {10}
                 dwPLObyteNumVU                 :       System.Word;                                              {12}
                 dbSerialNumber                 :       ARRAY[1..dbSerialNumberLen]  OF System.Char;              {14}
                 dwControllerTypeVU             :       System.Word;                                              {28}
                 dwControllerBufSizeVU          :       System.Word;                                              {2A}
                 dwECCbytes                     :       System.Word;                                              {2C}
                 dbCntlrFirmwareRevision        :       ARRAY[1..dbCntlrFirmwareRevisionLen]   OF System.Byte;    {2E}
                 dbModelNumber                  :       ARRAY[1..dbModelNumberLen]   OF System.Char;              {36}
                 dwSecsPerIntr                  :       System.Word;                                              {5E}
                 dwDoubleWordTransferFlagVU     :       System.Word;                                              {60}
                 dwAssignAlternate              :       System.Word;                                              {62}
                 dwReserved_64                  :       System.Word;                                              {64}
                 dwPIODataXFRCycleTimingMode    :       System.Word;                                              {66}
                 dwDMADataXFRCycleTimingMode    :       System.Word;                                              {68}
                 dwCurrentSettingsValidFlag     :       System.Word;                                              {6A}
                 dwCurrentCylsNum               :       System.Word;                                              {6C}
                 dwCurrentHeadsNum              :       System.Word;                                              {6E}
                 dwCurrentSecsPerTrack          :       System.Word;                                              {70}
                 ddCurrentDriveCapacityInSecs   :       System.Longint;                                           {72}
                 dwMultipleSecsModeXfrSettings  :       System.Word;                                              {76}
                 ddTotalUserSecsInLBA_Mode      :       System.Longint;                                           {78}
                 dwSingleWordDMA_XfrMode        :       System.Word;                                              {7C}
                 dwMultiWordDMA_XfrMode         :       System.Word;                                              {7E}
                 dwFlowCtrlPIO_XfrMode          :       System.Word;                                              {80}
                 dwMinMultiWordDMA_XfrMode      :       System.Word;                                              {82}
                 dwRecMultWordDMA_XfrMode       :       System.Word;                                              {84}
                 dwMinPIO_CycleTimeNoFlowCtrl   :       System.Word;                                              {86}
                 dwMinPIO_CycleTimeWithIORDY    :       System.Word;                                              {88}
                 dbReserved_8A                  :       ARRAY[1..dwReservedPartSize1] OF System.Byte;             {8A}
                 dwMajorVersionNumber           :       System.Word;                                              {A0}
                 dwMinorVersionNumber           :       System.Word;                                              {A2}
                 dwNotifyCommandSet_W1          :       System.Word;                                              {A4}
                 dwNotifyCommandSet_W2          :       System.Word;                                              {A6}
                 dbReserved_A8                  :       ARRAY[1..dwReservedPartSize2] OF System.Byte;             {A8}
                 dwSecurityStatus               :       System.Word;                                              {100}
                 dbVendorUniqueInfoText         :       ARRAY[1..dbVendorUniqueInfoTextLen]  OF  System.Char;     {102}
                 dbReserved_140                 :       ARRAY[1..dwReservedPartSize3] OF System.Byte;             {140}
                           END;
    {* recIDE_Info_Sector *}


    {* Hard Disk Parameters Table *}
    recHARD_DISK_PARMS  = RECORD
                dwMAX_CYLS_NUM               :    System.Word;     {00}
                dbMAX_HEADS_NUM              :    System.Byte;     {02}
                dwSTART_WRC_XT               :    System.Word;     {03}
                dwSTART_WRC                  :    System.Word;     {05}
                dbMAX_ECC_DATA_BURST_LEN     :    System.Byte;     {07}
                dbCONTROL_BYTE               :    System.Byte;     {08}
                dbSTD_TIME_OUT_XT            :    System.Byte;     {09}
                dbFMT_TIME_OUT_XT            :    System.Byte;     {0A}
                dbCHECK_TIME_OUT_XT          :    System.Byte;     {0B}
                dwLANDING_ZONE               :    System.Word;     {0C}
                dbSECTORS_PER_TRACK          :    System.Byte;     {0E}
                dbPARM_RESERVED              :    System.Byte;     {0F}
                          END;
    {* Hard Disk Parameters Table *}


    {* word parameter description *}
    recWordParameter        =   RECORD
                                    lpVarAddr       :    System.Pointer;
                                    dwMinValue      :    System.Word;
                                    dwDefaultValue  :    System.Word;
                                    dwMaxValue      :    System.Word;
                                END;
    {* word parameter description *}

    {* byte parameter description *}
    recByteParameter        =   RECORD
                                    lpVarAddr       :    System.Pointer;
                                    dbMinValue      :    System.Byte;
                                    dbDefaultValue  :    System.Byte;
                                    dbMaxValue      :    System.Byte;
                                END;
    {* byte parameter description *}

    {* boolean parameter description *}
    recBooleanParameter        =   RECORD
                                     lpVarAddr       :    System.Pointer;
                                     bMinValue       :    System.Boolean;
                                     bDefaultValue   :    System.Boolean;
                                     bMaxValue       :    System.Boolean;
                                   END;
    {* boolean parameter description *}

    {* Pascal string parameter description *}
    recPascalStrParameter        =   RECORD
                                     lpVarAddr       :    System.Pointer;
                                     dwMaxStrLen     :    System.Word;
                                   END;
    {* Pascal string parameter description *}


    {* command line parameter description *}
     recParameterType       =   RECORD
                                    sParamName      :    System.PChar;
                                    dwParamType     :    System.Word;
                                    lpParamDesc     :    System.Pointer;
                                END;
    {* command line parameter description  *}



{*====================== TYPED CONSTANTS PART ==========================*}

CONST
    setAscii7_NoCtrl  :    SET OF System.Char  =  [#32..#127];
    setHexChars       :    SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];

    giErrorCode       :   System.Integer    =  errOK;

    gdbSearchDriveIndex   :   System.Byte  = aFirstDrive;
    gdbFoundLogSectors    :   ARRAY[aFirstDrive..aTenthDrive]  OF  System.Byte  =
                                       (0,0,0,0,0,0,0,0,0,0);
    gdbFoundLogHeads      :   ARRAY[aFirstDrive..aTenthDrive]  OF  System.Byte  =
                                       (0,0,0,0,0,0,0,0,0,0);
    gdwFoundLogCylinders  :   ARRAY[aFirstDrive..aTenthDrive]  OF  System.Word  =
                                       (0,0,0,0,0,0,0,0,0,0);

    gdbUserHelpRequest   :    System.Boolean  =  System.False;
    gbIntDone            :    System.Boolean  =  System.False;
    gdbCurIntHdc         :    System.Byte     =  aIntDef;
    gdbCurImrValue       :    System.Byte     =  $00;
    gdbCurHardIRQ        :    System.Byte     =  $00;
    glpIntVecCtlr        :    System.Pointer  =  NIL;

    gsReservedFileName   :    STRING[12]  =  'IDE-DATA.$00';

    gsFileName           :    STRING              =  asBlank;
    grecFileNameParm     :    recPascalStrParameter  =
                                     (lpVarAddr:@gsFileName;
                                      dwMaxStrLen:aMaxStrLen);

    gbFileWriteOk        :    System.Boolean      =  System.False;
    grecFileWriteOkParm  :    recBooleanParameter  =
                                     (lpVarAddr:@gbFileWriteOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbEmulModeOk         :    System.Boolean      =  System.False;
    grecFileReadOkParm   :    recBooleanParameter  =
                                     (lpVarAddr:@gbEmulModeOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gdbDisplayAll     :    System.Boolean      =  System.True;
    gbDviOk           :    System.Boolean      =  System.False;
    grecDviOkParm     :   recBooleanParameter  =
                                     (lpVarAddr:@gbDviOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbMfmOk           :    System.Boolean      =  System.False;
    grecMfmOkParm     :   recBooleanParameter  =
                                     (lpVarAddr:@gbMfmOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbTrionesOk       :    System.Boolean      =  System.False;
    grecTrionesOkParm :   recBooleanParameter  =
                                     (lpVarAddr:@gbTrionesOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbFindAllOk        :    System.Boolean       =  System.False;
    grecFindAllOkParm  :    recBooleanParameter  =
                                     (lpVarAddr:@gbFindAllOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbFindCMOSOk         :    System.Boolean       =  System.False;
    grecFindCMOSOkParm   :    recBooleanParameter  =
                                     (lpVarAddr:@gbFindCMOSOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbFindMaxOk        :    System.Boolean       =  System.True;
    grecFindMaxOkParm  :    recBooleanParameter  =
                                     (lpVarAddr:@gbFindMaxOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.True;
                                      bMaxValue:System.True);

    gbSoftResetOk        :    System.Boolean       =  System.False;
    grecSoftResetOkParm  :    recBooleanParameter  =
                                     (lpVarAddr:@gbSoftResetOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbDebugInfoOk        :    System.Boolean       =  System.False;
    grecDebugInfoOkParm  :    recBooleanParameter  =
                                     (lpVarAddr:@gbDebugInfoOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbTimeMeasureOk        :  System.Boolean       =  System.False;
    grecTimeMeasureOkParm  :  recBooleanParameter  =
                                     (lpVarAddr:@gbTimeMeasureOk;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbCPUis386           :    System.Boolean       =  System.False;
    gbDiskAccess32Ok     :    System.Boolean       =  System.False;
    grecAccess32InfoOkParm  :    recBooleanParameter  =
                                     (lpVarAddr:@gbDiskAccess32Ok;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbCheckDrive0_Ok     :    System.Boolean       =  System.True;
    grecCheckDrv0_OkParm :    recBooleanParameter  =
                                     (lpVarAddr:@gbCheckDrive0_Ok;
                                      bMinValue:System.False;
                                      bDefaultValue:System.True;
                                      bMaxValue:System.True);

    gbCheckDrive1_Ok     :    System.Boolean       =  System.True;
    grecCheckDrv1_OkParm :    recBooleanParameter  =
                                     (lpVarAddr:@gbCheckDrive1_Ok;
                                      bMinValue:System.False;
                                      bDefaultValue:System.True;
                                      bMaxValue:System.True);

    gbCheckDrive2_Ok     :    System.Boolean       =  System.True;
    grecCheckDrv2_OkParm :    recBooleanParameter  =
                                     (lpVarAddr:@gbCheckDrive2_Ok;
                                      bMinValue:System.False;
                                      bDefaultValue:System.True;
                                      bMaxValue:System.True);

    gbCheckDrive3_Ok     :    System.Boolean       =  System.True;
    grecCheckDrv3_OkParm :    recBooleanParameter  =
                                     (lpVarAddr:@gbCheckDrive3_Ok;
                                      bMinValue:System.False;
                                      bDefaultValue:System.True;
                                      bMaxValue:System.True);

    gbCheckDrive4_Ok     :    System.Boolean       =  System.False;
    grecCheckDrv4_OkParm :    recBooleanParameter  =
                                     (lpVarAddr:@gbCheckDrive4_Ok;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbCheckDrive5_Ok     :    System.Boolean       =  System.False;
    grecCheckDrv5_OkParm :    recBooleanParameter  =
                                     (lpVarAddr:@gbCheckDrive5_Ok;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbCheckDrive6_Ok     :    System.Boolean       =  System.False;
    grecCheckDrv6_OkParm :    recBooleanParameter  =
                                     (lpVarAddr:@gbCheckDrive6_Ok;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gbCheckDrive7_Ok     :    System.Boolean       =  System.False;
    grecCheckDrv7_OkParm :    recBooleanParameter  =
                                     (lpVarAddr:@gbCheckDrive7_Ok;
                                      bMinValue:System.False;
                                      bDefaultValue:System.False;
                                      bMaxValue:System.True);

    gdbUseIntHdc0_Ok      :   System.Byte          =  aIntDef;
    grecUseIntHdc0_OkParm :   recByteParameter     =
                                     (lpVarAddr:@gdbUseIntHdc0_Ok;
                                      dbMinValue:aIntMin;
                                      dbDefaultValue:aIntDef;
                                      dbMaxValue:aIntMax);

    gdbUseIntHdc1_Ok      :   System.Byte          =  aIntDef;
    grecUseIntHdc1_OkParm :   recByteParameter     =
                                     (lpVarAddr:@gdbUseIntHdc1_Ok;
                                      dbMinValue:aIntMin;
                                      dbDefaultValue:aIntDef;
                                      dbMaxValue:aIntMax);

    gdbUseIntHdc2_Ok      :   System.Byte          =  aIntDef;
    grecUseIntHdc2_OkParm :   recByteParameter     =
                                     (lpVarAddr:@gdbUseIntHdc2_Ok;
                                      dbMinValue:aIntMin;
                                      dbDefaultValue:aIntDef;
                                      dbMaxValue:aIntMax);

    gdbUseIntHdc3_Ok      :   System.Byte          =  aIntDef;
    grecUseIntHdc3_OkParm :   recByteParameter     =
                                     (lpVarAddr:@gdbUseIntHdc3_Ok;
                                      dbMinValue:aIntMin;
                                      dbDefaultValue:aIntDef;
                                      dbMaxValue:aIntMax);

    gdbUseIntHdcU_Ok      :   System.Byte          =  aIntDef;
    grecUseIntHdcU_OkParm :   recByteParameter     =
                                     (lpVarAddr:@gdbUseIntHdcU_Ok;
                                      dbMinValue:aIntMin;
                                      dbDefaultValue:aIntDef;
                                      dbMaxValue:aIntMax);

    gdbUseIrqHdc0_Ok      :   System.Byte          =  aIrqDef;
    grecUseIrqHdc0_OkParm :   recByteParameter     =
                                     (lpVarAddr:@gdbUseIrqHdc0_Ok;
                                      dbMinValue:aIrqMin;
                                      dbDefaultValue:aIrqDef;
                                      dbMaxValue:aIrqMax);

    gdbUseIrqHdc1_Ok      :   System.Byte          =  aIrqDef;
    grecUseIrqHdc1_OkParm :   recByteParameter     =
                                     (lpVarAddr:@gdbUseIrqHdc1_Ok;
                                      dbMinValue:aIrqMin;
                                      dbDefaultValue:aIrqDef;
                                      dbMaxValue:aIrqMax);

    gdbUseIrqHdc2_Ok      :   System.Byte          =  aIrqDef;
    grecUseIrqHdc2_OkParm :   recByteParameter     =
                                     (lpVarAddr:@gdbUseIrqHdc2_Ok;
                                      dbMinValue:aIrqMin;
                                      dbDefaultValue:aIrqDef;
                                      dbMaxValue:aIrqMax);

    gdbUseIrqHdc3_Ok      :   System.Byte          =  aIrqDef;
    grecUseIrqHdc3_OkParm :   recByteParameter     =
                                     (lpVarAddr:@gdbUseIrqHdc3_Ok;
                                      dbMinValue:aIrqMin;
                                      dbDefaultValue:aIrqDef;
                                      dbMaxValue:aIrqMax);

    gdbUseIrqHdcU_Ok      :   System.Byte          =  aIrqDef;
    grecUseIrqHdcU_OkParm :   recByteParameter     =
                                     (lpVarAddr:@gdbUseIrqHdcU_Ok;
                                      dbMinValue:aIrqMin;
                                      dbDefaultValue:aIrqDef;
                                      dbMaxValue:aIrqMax);

    gdwTextLineNum          :   System.Word       =  aMinOutLineOnScreen;
    gdwMaxScreenLines       :   System.Word       =  aDefMaxOutLineForScreen;
    grecMaxScreenLinesParm  :   recWordParameter  =
                                     (lpVarAddr:@gdwMaxScreenLines;
                                      dwMinValue:aDisableScreenPage;
                                      dwDefaultValue:aDefMaxOutLineForScreen;
                                      dwMaxValue:aBigOutLinesForScreenNum);

    gdwUserBaseIoReg        :   System.Word       =  0;
    grecUserBaseIoRegParm   :   recWordParameter  =
                                     (lpVarAddr:@gdwUserBaseIoReg;
                                      dwMinValue:$30;
                                      dwDefaultValue:0;
                                      dwMaxValue:$FFFF);

    gdwUserStatusReg        :   System.Word       =  0;
    grecUserStatusRegParm   :   recWordParameter  =
                                     (lpVarAddr:@gdwUserStatusReg;
                                      dwMinValue:$30;
                                      dwDefaultValue:0;
                                      dwMaxValue:$FFFF);

    gdwDelayFactor          :   System.Word       =  1;
    grecDelayFactorParm     :   recWordParameter  =
                                     (lpVarAddr:@gdwDelayFactor;
                                      dwMinValue:$1;
                                      dwDefaultValue:1;
                                      dwMaxValue:$FFFF);

   { magic words }
      asScreenLines            =    'lines';
      asFileToAsk              =    'fa';
      asFileToRead             =    'fe';
      asFileDestName           =    'fd';
      asDelayFactor            =    'delay';
      asHddTableDisplayOnly    =    'romtype';
      asMaxCapacityOnly        =    'max';
      asAllOptions             =    'all';
      asEnableHardReset        =    'reset';
      asEnableDebugInfo        =    'debug';
      asEnableTimeMeasure      =    'time';
      asDiskAccess32           =    '32bit';
      asEnableDrive0           =    'ds0';
      asEnableDrive1           =    'ds1';
      asEnableDrive2           =    'ds2';
      asEnableDrive3           =    'ds3';
      asEnableDrive4           =    'ds4';
      asEnableDrive5           =    'ds5';
      asEnableDrive6           =    'ds6';
      asEnableDrive7           =    'ds7';
      asUseIntCtlr0            =    'int0';
      asUseIntCtlr1            =    'int1';
      asUseIntCtlr2            =    'int2';
      asUseIntCtlr3            =    'int3';
      asUseIntCtlrU            =    'intu';
      asUseIrqCtlr0            =    'irq0';
      asUseIrqCtlr1            =    'irq1';
      asUseIrqCtlr2            =    'irq2';
      asUseIrqCtlr3            =    'irq3';
      asUseIrqCtlrU            =    'irqu';
      asDviOutput              =    'dvi';
      asMfmStyle               =    'mfm';
      asTrionesDrvr            =    'triones';
      asUserBaseReg            =    'base';
      asUserStatusReg          =    'status';
      asHelpOnScreen           =    '?';
      asAltHelpOnScreen        =    'help';
      aNumOfCmdParms           =     37;
      aMaxParamStrLen          =     7;

    gachProgramOptions  :  ARRAY[1..aNumOfCmdParms]  OF  recParameterType =
      ((sParamName:asScreenLines;dwParamType:aParmIsWord;lpParamDesc:@grecMaxScreenLinesParm),
       (sParamName:asFileToAsk;dwParamType:aParmIsBoolean;lpParamDesc:@grecFileWriteOkParm),
       (sParamName:asFileToRead;dwParamType:aParmIsBoolean;lpParamDesc:@grecFileReadOkParm),
       (sParamName:asFileDestName;dwParamType:aParmIsPascalStr;lpParamDesc:@grecFileNameParm),
       (sParamName:asDelayFactor;dwParamType:aParmIsWord;lpParamDesc:@grecDelayFactorParm),
       (sParamName:asHddTableDisplayOnly;dwParamType:aParmIsBoolean;lpParamDesc:@grecFindCMOSOkParm),
       (sParamName:asMaxCapacityOnly;dwParamType:aParmIsBoolean;lpParamDesc:@grecFindMaxOkParm),
       (sParamName:asAllOptions;dwParamType:aParmIsBoolean;lpParamDesc:@grecFindAllOkParm),
       (sParamName:asEnableHardReset;dwParamType:aParmIsBoolean;lpParamDesc:@grecSoftResetOkParm),
       (sParamName:asEnableDebugInfo;dwParamType:aParmIsBoolean;lpParamDesc:@grecDebugInfoOkParm),
       (sParamName:asEnableTimeMeasure;dwParamType:aParmIsBoolean;lpParamDesc:@grecTimeMeasureOkParm),
       (sParamName:asDiskAccess32;dwParamType:aParmIsBoolean;lpParamDesc:@grecAccess32InfoOkParm),
       (sParamName:asEnableDrive0;dwParamType:aParmIsBoolean;lpParamDesc:@grecCheckDrv0_OkParm),
       (sParamName:asEnableDrive1;dwParamType:aParmIsBoolean;lpParamDesc:@grecCheckDrv1_OkParm),
       (sParamName:asEnableDrive2;dwParamType:aParmIsBoolean;lpParamDesc:@grecCheckDrv2_OkParm),
       (sParamName:asEnableDrive3;dwParamType:aParmIsBoolean;lpParamDesc:@grecCheckDrv3_OkParm),
       (sParamName:asEnableDrive4;dwParamType:aParmIsBoolean;lpParamDesc:@grecCheckDrv4_OkParm),
       (sParamName:asEnableDrive5;dwParamType:aParmIsBoolean;lpParamDesc:@grecCheckDrv5_OkParm),
       (sParamName:asEnableDrive6;dwParamType:aParmIsBoolean;lpParamDesc:@grecCheckDrv6_OkParm),
       (sParamName:asEnableDrive7;dwParamType:aParmIsBoolean;lpParamDesc:@grecCheckDrv7_OkParm),
       (sParamName:asUseIntCtlr0;dwParamType:aParmIsByte;lpParamDesc:@grecUseIntHdc0_OkParm),
       (sParamName:asUseIntCtlr1;dwParamType:aParmIsByte;lpParamDesc:@grecUseIntHdc1_OkParm),
       (sParamName:asUseIntCtlr2;dwParamType:aParmIsByte;lpParamDesc:@grecUseIntHdc2_OkParm),
       (sParamName:asUseIntCtlr3;dwParamType:aParmIsByte;lpParamDesc:@grecUseIntHdc3_OkParm),
       (sParamName:asUseIntCtlrU;dwParamType:aParmIsByte;lpParamDesc:@grecUseIntHdcU_OkParm),
       (sParamName:asUseIrqCtlr0;dwParamType:aParmIsByte;lpParamDesc:@grecUseIrqHdc0_OkParm),
       (sParamName:asUseIrqCtlr1;dwParamType:aParmIsByte;lpParamDesc:@grecUseIrqHdc1_OkParm),
       (sParamName:asUseIrqCtlr2;dwParamType:aParmIsByte;lpParamDesc:@grecUseIrqHdc2_OkParm),
       (sParamName:asUseIrqCtlr3;dwParamType:aParmIsByte;lpParamDesc:@grecUseIrqHdc3_OkParm),
       (sParamName:asUseIrqCtlrU;dwParamType:aParmIsByte;lpParamDesc:@grecUseIrqHdcU_OkParm),
       (sParamName:asDviOutput;dwParamType:aParmIsBoolean;lpParamDesc:@grecDviOkParm),
       (sParamName:asMfmStyle;dwParamType:aParmIsBoolean;lpParamDesc:@grecMfmOkParm),
       (sParamName:asTrionesDrvr;dwParamType:aParmIsBoolean;lpParamDesc:@grecTrionesOkParm),
       (sParamName:asUserBaseReg;dwParamType:aParmIsWord;lpParamDesc:@grecUserBaseIoRegParm),
       (sParamName:asUserStatusReg;dwParamType:aParmIsWord;lpParamDesc:@grecUserStatusRegParm),
       (sParamName:asHelpOnScreen;dwParamType:aParmIsIndefinite;lpParamDesc:NIL),
       (sParamName:asAltHelpOnScreen;dwParamType:aParmIsIndefinite;lpParamDesc:NIL));



{*=========================== VARIABLES PART ===========================*}

VAR
   grecDriveInfoBuf      :   recIDE_Info_Sector;       {Sector buffer}
   grecRD_HDISK_Regs     :   recHDISK_READ_REGS;       {Read registers map}
   grecWRT_HDISK_Regs    :   recHDISK_WRITE_REGS;      {Write registers map}
   grecWR_CMD_BLOCK      :   recHDISK_WRITE_CMD_BLOCK; {Command controller block}
   gliTotalDiskSectors   :   System.Longint;           {Total per drive}
   gdwIndex              :   System.Word;              {Loop index}
   gdwTempIndex          :   System.Word;              {Temporary}
   gdwTemp               :   System.Word;              {Temporary}
   gdwAlternateStatus    :   System.Word;              {Control register}
   gdwTempCyls           :   System.Word;              {Temporary}
   gdwWaitDRQ_Time       :   System.Word;              {DRQ appearence time}
   gdwIDE_Disks_Count    :   System.Word;              {Found drives bit-mapped flag}
   gdbTempHeads          :   System.Byte;              {Temporary}
   gdbTempSecs           :   System.Byte;              {Temporary}
   gdbSDH_TestVal        :   System.Byte;              {Test register}
   gdbTempPos            :   System.Byte;              {Temporary}
   gbDiskStatusOK        :   System.Boolean;           {Disk status flag}
   gbParmFound           :   System.Boolean;           {Search flag}
   gsTempParm            :   STR8;                     {Temporary}
   gsTemp                :   STRING;                   {Temporary}
   gsPath                :   Dos.PathStr;              {Program path}
   gsDir                 :   Dos.DirStr;               {Program directory}
   gsName                :   Dos.NameStr;              {Program base name}
   gsExtension           :   Dos.ExtStr;               {Program name extension}


 { absolute references to memory locations}
   gdbBIOS_Drives_Num    :   System.Byte   ABSOLUTE  $40:$75;
   gdbROM_BIOS_HDD_TYPES_TABLE : ARRAY[aMinHDD_CMOSType..aMaxHDD_CMOSType]
                                 OF  recHARD_DISK_PARMS  ABSOLUTE $F000:$E401;



{*=========================== FORWARD REFERENCES PART ==================*}

PROCEDURE    _OutputDebugMessage(sMessage : STRING);  FORWARD;
PROCEDURE    _WaitMoreSecondsDiv18(dwTimes : System.Word); FORWARD;



{*=========================== PROCEDURAL PART ==========================*}


{*============================= INLINE CODE ============================*}

PROCEDURE _IO_DELAY_2;
{* Some i/o bus delay. *}
INLINE($EB/$00/     { jmp short $ + 2 }
       $EB/$00);    { jmp short $ + 2 }
{ _IO_DELAY_2 }


PROCEDURE _ReadDataSector512(VAR dbBuf; dwBaseDataReg, dwTransferCount : System.Word);
{* Transfer 512-bytes sector into memory buffer. *}
INLINE($59/           {  pop     cx           ; CX = # words to xfr }
       $5A/           {  pop     dx           ; DX = base data reg  }
       $5F/           {  pop     di           ; DI = Ofs(dbBuf)     }
       $07/           {  pop     es           ; ES = Seg(dbBuf)     }
       $FA/           {  cli                  ; intrs off           }
       $FC/           {  cld                  ; go forward          }
       $F3/$6D/       {  rep     insw         ; i/o (286+)          }
       $FB);          {  sti                  ; intrs on            }
{ _ReadDataSector512 }


PROCEDURE _ReadDataSector512_32(VAR dbBuf; dwBaseDataReg, dwTransferCount : System.Word);
{* Transfer 512-bytes sector into memory buffer. *}
INLINE($59/           {  pop     cx           ; CX = # words to xfr }
       $5A/           {  pop     dx           ; DX = base data reg  }
       $5F/           {  pop     di           ; DI = Ofs(dbBuf)     }
       $07/           {  pop     es           ; ES = Seg(dbBuf)     }
       $D1/$E9/       {  shr     cx, 1        ; counts as DWORDs    }
       $FA/           {  cli                  ; intrs off           }
       $FC/           {  cld                  ; go forward          }
       $F3/$66/$6D/   {  rep     insd         ; i/o (386+)          }
       $FB);          {  sti                  ; intrs on            }
{ _ReadDataSector512_32 }



{*=========================== FUNCTIONAL PART ==========================*}


{*========================== STRING CONVERSION =========================*}

FUNCTION   _fnsByteToHexFmt(dbInput : System.Byte) : STR2;
{* Converts a byte to the hex format number representation. *}
CONST
    dbHexCharTable : ARRAY[0..15] OF System.Char = '0123456789ABCDEF';

BEGIN
  _fnsByteToHexFmt := dbHexCharTable[dbInput SHR 4] + dbHexCharTable[dbInput AND $0F];
END;  { _fnsByteToHexFmt }


FUNCTION   _fnsWordToHexFmt(dwInput : System.Word) : STR4;
{* Converts a word to the hex format number representation. *}
BEGIN
  _fnsWordToHexFmt := _fnsByteToHexFmt(System.Hi(dwInput)) +
                      _fnsByteToHexFmt(System.Lo(dwInput));
END;  { _fnsWordToHexFmt }


{*============================ CPU DETECTION ===========================*}

FUNCTION  _fnbCpuIs386  :  System.Boolean; assembler;
{* Returns true if CPU is 80386+ processsor otherwize false. *}
{* Used registers:  AX, BL                                   *}
asm
        mov     bl, System.True         { assume that CPU is 386+}
        pushf                           { save all flags }
        mov     ax, 0F000h              { set all high flags }
        push    ax
        popf
        pushf                           { now see what flags set }
        pop     ax
        and     ax, 0F000h              { std behaviour for 386+}
        jnz     @Done
        mov     bl, System.False
  @Done:
        popf
        mov     al, bl
END; {asm-end}
{ _fnbCpuIs386 }


{*============================= MEASURE TIME ===========================*}

FUNCTION  _fndwCountTimer2  :  System.Word; ASSEMBLER;
{* Read current count from PC interval timer 2. *}
ASM
        pushf
        cli
        in      al, ioTimerCount2
        mov     ah, al
        in      al, ioTimerCount2
        popf
        xchg    ah, al
        neg     ax
END;  { _fndwCountTimer2 }


FUNCTION   _fnliCurrentBiosTimeCount : System.Longint;
{* Reads current time counters from BIOS data area. *}
BEGIN
  _fnliCurrentBiosTimeCount := System.MemL[$40:$6C];
END; { _fnliCurrentBiosTimeCount }


{*====================== HDD CONTROLLER INTERFACE ======================*}

FUNCTION  _fndbReadControllerStatus(dwStatusReg : System.Word) : System.Byte;
{* Read fixed disk drive controller status. *}
VAR
  dbStatus : System.Byte;

BEGIN
  {* assume that status ok *}
   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('Read controller status.');
           END;
   {if-then}

   gbDiskStatusOK := System.True;

  {* just read some coupled bits *}
   dbStatus  := System.Port[dwStatusReg];
   IF (((dbStatus AND (btDriveReady+btWriteFault+btSeekComplete+btCmdErr))
          XOR (btDriveReady+btSeekComplete)) <> 0)
     THEN  gbDiskStatusOK := System.False;
   {if-then}

  {* return result *}
  _fndbReadControllerStatus := dbStatus;
END; { _fndbReadControllerStatus }


FUNCTION  _fnbControllerIsReady(dwStatusReg : System.Word) : System.Boolean;
{* Test disk controller ready status. *}
VAR
  dwTimeOutCount  :   System.Word;
  dwOuterCount    :   System.Word;
  dbStatus        :   System.Byte;
  bResVal         :   System.Boolean;
  dbDelayCount    :   System.Byte;

BEGIN
  {* assume that controller ready now *}
   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('Test for ready of controller.');
           END;
   {if-then}
    dwTimeOutCount := $FFFF;
    dwOuterCount := aBiosTimerTicksDef*(3*gdwDelayFactor);
    gbDiskStatusOK := System.False;
    bResVal        := System.False;

  {* test controller status *}
  WHILE (dwOuterCount <> 0)  DO
  BEGIN
        WHILE (dwTimeOutCount <> 0) DO
        BEGIN
            {* read status port *}
            FOR dbDelayCount := 1 TO gdwDelayFactor DO _IO_DELAY_2;
            {for-to-do}
            dbStatus  := System.Port[dwStatusReg];

            {* controller busy? *}
            IF ((dbStatus AND btCtlrBusy) = 0)
              THEN  BEGIN
                      {* here we found status ok *}
                       dwTimeOutCount := 0;
                       dwOuterCount := 1;
                       gbDiskStatusOK := System.True;
                       bResVal        := System.True;
                    END
              ELSE
                System.Dec(dwTimeOutCount);
            {if-then-else}
        END;
        {while-do}
  _WaitMoreSecondsDiv18(1*gdwDelayFactor);
  System.Dec(dwOuterCount);
  END;
  {while-do}

  {* return result *}
    _fnbControllerIsReady := bResVal;
   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('Ready state: $'+_fnsByteToHexFmt(dbStatus));
           END;
   {if-then}
END; { _fnbControllerIsReady }


FUNCTION  _fnbDriveIsReady(dwStatusReg : System.Word) : System.Boolean;
{* Test disk drive ready status. *}
VAR
  liTimeOutCount  :   System.Longint;
  dbStatus        :   System.Byte;
  bResVal         :   System.Boolean;
  dbDelayCount    :   System.Byte;

BEGIN
  {* assume that controller ready now *}
   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('Test for ready of drive.');
           END;
   {if-then}

    liTimeOutCount := $FFFF*(2*gdwDelayFactor);
    gbDiskStatusOK := System.False;
    bResVal        := System.False;

  {* test controller status *}
    WHILE (liTimeOutCount <> 0) DO
    BEGIN
        {* read status port *}
        FOR dbDelayCount := 1 TO gdwDelayFactor DO _IO_DELAY_2;
        {for-to-do}
        dbStatus  := System.Port[dwStatusReg];

        {* drive busy? *}
        IF ((dbStatus AND btDriveReady) <> 0)
          THEN  BEGIN
                  {* drive ready to accept command *}
                   liTimeOutCount := 0;
                   gbDiskStatusOK := System.True;
                   bResVal        := System.True;
                END
          ELSE
            System.Dec(liTimeOutCount);
        {if-then-else}
    END;
    {while-do}

  {* return result *}
    _fnbDriveIsReady := bResVal;
END; { _fnbDriveIsReady }


FUNCTION  _fnbWaitDRQ(dwStatusReg : System.Word) : System.Boolean;
{* Wait while sector buffer not full. *}
VAR
  dwTimeOutCount  :   System.Word;
  dwOuterCount    :   System.Word;
  dbStatus        :   System.Byte;
  bResVal         :   System.Boolean;
  dbDelayCount    :   System.Byte;

BEGIN
  {* assume that controller ready now *}
   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('Wait DRQ bit high.');
           END;
   {if-then}

    dwTimeOutCount := $FFFF;                {* Hard-coded value!! *}
    dwOuterCount := aBiosTimerTicksDef*(4*gdwDelayFactor);
    gbDiskStatusOK := System.False;
    bResVal        := System.False;

  {* test controller status *}
    WHILE  (dwOuterCount <> 0)  DO
    BEGIN
        WHILE (dwTimeOutCount <> 0) DO
        BEGIN
            {* read status port *}
            FOR dbDelayCount := 1 TO gdwDelayFactor DO _IO_DELAY_2;
            {for-to-do}
            dbStatus  := System.Port[dwStatusReg];

            {* buffer full to transfer? *}
            IF (((dbStatus AND btCtlrBusy) = 0) AND
                (((dbStatus AND (btDataRequest+btDriveReady+btSeekComplete)) <> 0)))
              THEN  BEGIN
                      {* controller reports that buffer ready to read *}
                       dwTimeOutCount := 0;
                       dwOuterCount := 1;
                       gbDiskStatusOK := System.True;
                       bResVal        := System.True;
                    END
              ELSE
                System.Dec(dwTimeOutCount);
            {if-then-else}
        END;
        {while-do}
    _WaitMoreSecondsDiv18(1*gdwDelayFactor);
    System.Dec(dwOuterCount);
    END;
    {while-do}

   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('DRQ state: $'+_fnsByteToHexFmt(dbStatus));
           END;
   {if-then}

  {* return result *}
    _fnbWaitDRQ := bResVal;
END; { _fnbWaitDRQ }


{*========================= STRING MANIPULATION ========================*}

FUNCTION  _fnsAsciiInfo(pMem : System.Pointer; dwMemLen : System.Word;
                        bSwapBytes : System.Boolean) : STRING;
{* Return string only with match ASCII chars. *}
VAR
  sTemp        :    STRING;
  dwMemOfs     :    System.Word;
  dwChar2      :    System.Word;


PROCEDURE  _AddNewChar(chNew : System.Char);
{* Add match char to string. *}
BEGIN
   IF  (chNew IN setAscii7_NoCtrl)
      THEN  sTemp := sTemp + chNew;
   {if-then}
END; { _AddNewChar }

BEGIN
  {* initialize *}
   sTemp     := asBlank;
   dwMemOfs  := 0;
   dwMemLen  := dwMemLen SHR 1;    { words count }

  {* read all bytes in format HIGH-LOW (Motorola format) *}
   WHILE (dwMemLen <> 0) DO
   BEGIN
      dwChar2   := System.MemW[System.Seg(pMem^):(System.Ofs(pMem^)+dwMemOfs)];

     IF (bSwapBytes)
       THEN  BEGIN
         _AddNewChar(System.Char(System.Hi(dwChar2)));
         _AddNewChar(System.Char(System.Lo(dwChar2)));
             END
       ELSE  BEGIN
         _AddNewChar(System.Char(System.Lo(dwChar2)));
         _AddNewChar(System.Char(System.Hi(dwChar2)));
             END;
     {if-then-else}

      System.Dec(dwMemLen);
      System.Inc(dwMemOfs,2);
   END;
   {while-do}

  {* return string as result *}
   _fnsAsciiInfo := sTemp;
END; { _fnsAsciiInfo }


FUNCTION  _fnsForceFileExtension(sFileName, sDefExt : STRING) : STRING;
{* Add extension for filename if not present. *}
BEGIN
   IF (System.Pos(achDosDelim,sFileName) = 0)
     THEN  sFileName := sFileName + achDosDelim + sDefExt;
   {if-then}
  _fnsForceFileExtension := sFileName;
END;
{ _fnsForceFileExtension }


FUNCTION  _fnsNumToStr(liNum : System.Longint; dwWidth : System.Word) : STRING;
{* Convert a numeric value to its string representation. *}
CONST
  aOneThousand    =   1000;
  aDecimalPlaces  =   3;

VAR
  sTemp,
  sNumTemp      :  STRING;
  liTempVal     :  System.Longint;
  dbCount       :  System.Byte;
  bFirstOutput  :  System.Boolean;


BEGIN
  IF (dwWidth <> 0)
    THEN  System.Str(liNum:dwWidth,sTemp)
    ELSE  System.Str(liNum,sTemp);
  {if-then-else}

  WHILE (System.Length(sTemp) <> 0) AND (sTemp[1] = achSpace)
  DO  System.Delete(sTemp,1,1);
  {while-do}

  IF (liNum > aOneThousand)
    THEN  BEGIN
      dbCount := System.Length(sTemp);
      WHILE  (dbCount > aDecimalPlaces) DO
      BEGIN
        System.Dec(dbCount,aDecimalPlaces);
        System.Insert(',',sTemp,dbCount+1);
      END;
      {while-do}
          END;
  {if-then}

  _fnsNumToStr := sTemp;
END;
{ _fnsNumToStr }


FUNCTION  _fnsNumToStrNoAdj(liNum : System.Longint; dwWidth : System.Word) : STRING;
{* Convert a numeric value to its string representation. *}
VAR
  sTemp : STRING;

BEGIN
  IF (dwWidth <> 0)
    THEN  System.Str(liNum:dwWidth,sTemp)
    ELSE  System.Str(liNum,sTemp);
  {if-then-else}

  _fnsNumToStrNoAdj := sTemp;
END;
{ _fnsNumToStrNoAdj }


FUNCTION  _fnsNumToRealStr(rNum : System.Real;dwWidth,dwDecimals : System.Word) : STRING;
{* Convert a real numeric value to its string representation. *}
VAR
  sTemp : STRING;

BEGIN
  System.Str(rNum:dwWidth:dwDecimals,sTemp);

  WHILE (System.Length(sTemp) <> 0) AND (sTemp[1] = achSpace)
  DO  System.Delete(sTemp,1,1);
  {while-do}

  _fnsNumToRealStr := sTemp;
END;
{ _fnsNumToRealStr }


FUNCTION  _fnsNumToRealStrNoAdj(rNum : System.Real;dwWidth,dwDecimals : System.Word) : STRING;
{* Convert a real numeric value to its string representation. *}
VAR
  sTemp : STRING;

BEGIN
  System.Str(rNum:dwWidth:dwDecimals,sTemp);

  _fnsNumToRealStrNoAdj := sTemp;
END;
{ _fnsNumToRealStrNoAdj }


FUNCTION   _fnsUpCase(sInput : STRING) : STRING;
{* Translate characters to upper case. *}
VAR
   dbIndex  :  System.Byte;
   dbCount  :  System.Byte  ABSOLUTE  sInput;

BEGIN
  IF (dbCount <> 0)
    THEN   FOR  dbIndex := 1 TO dbCount DO
               sInput[dbIndex] := System.UpCase(sInput[dbIndex]);
           {for-to-do}
  {if-then}

   _fnsUpCase := sInput;
END;
{  _fnsUpCase }

FUNCTION  _fnsAddPrefixChars(sInput       :  STRING;
                             chAdd        :  System.Char;
                             dwCount      :  System.Word;
                             dwMaxStrLen  :  System.Word) : STRING;
{* Add prefix character before *}
BEGIN
  WHILE (System.Length(sInput) < dwMaxStrLen) AND (dwCount <> 0) DO
  BEGIN
    System.Insert(chAdd,sInput,1);
  END;
  {while-do}
  _fnsAddPrefixChars := sInput;
END;  { _fnsAddPrefixChars }


FUNCTION   _fnchGetFirstChar(sInput : STRING) : System.Char;
{* Returns a first char from string. *}
VAR
  chTemp  :  System.Char;

BEGIN
   IF (System.Length(sInput) <> 0)
     THEN  chTemp := sInput[1]
     ELSE  chTemp := System.Char(achNULL);
   {if-then-else}
  _fnchGetFirstChar := chTemp;
END;
{ _fnchGetFirstChar }


FUNCTION  _fndwGetValue(VAR iErrorCode : System.Integer;
                        sInput : STRING)  : System.Word;
{* Translates string to its numeric representation. *}
VAR
  dwTempValue  :  System.Word;

BEGIN
   System.Val(sInput,dwTempValue,iErrorCode);
  _fndwGetValue := dwTempValue;
END;
{ _fndwGetValue }


FUNCTION  _fnsAddSpacesToMax(sInput : STRING;
                             dwMaxStrLen : System.Word ) : STRING;
{* Add the trailing spaces to string if this is possible. *}
VAR
   sTemp     :   STRING;
   dwCount   :   System.Word;

BEGIN
  dwCount := System.Length(sInput);
  IF (dwCount < dwMaxStrLen)
    THEN BEGIN
       dwCount := ((dwMaxStrLen - dwCount) AND $00FF);
       System.FillChar(sTemp[1],dwMaxStrLen,achSpace);
       sTemp[0] := System.Char(dwCount);
       sInput := sInput + sTemp;
         END;
  {if-then}
  _fnsAddSpacesToMax := sInput;
END; { _fnsAddSpacesToMax }


{*========================== ATA DRIVE SUPPORT  ========================*}

FUNCTION  _fnsBool2Str(bValue: System.Boolean) : STR3;
{* Returns boolean state description. *}
VAR
  sTemp : STR3;
BEGIN
  IF (bValue)
    THEN  sTemp := asDefaultON
    ELSE  sTemp := asDefaultOFF;
  {if-then-else}
  _fnsBool2Str := sTemp;
END; { _fnsBool2Str }


FUNCTION  _fnsDmaTransferModeInfo(dwBitsInfoMode : System.Word) : STRING;
{* Returns string describing a DMA transfer modes supported by drive. *}
VAR
  dbTempValue  :  System.Byte;
  bCommaYes    :  System.Boolean;
  sTemp        :  STRING;


FUNCTION  _fnsAddThisMode(chMode : System.Char) : STR2;
VAR
  sTemp2 : STR2;
BEGIN
  IF (bCommaYes)
    THEN  BEGIN
      sTemp2 := ',';
          END
    ELSE  BEGIN
      bCommaYes := System.True;
      sTemp2 := '';
          END;
  {if-then-else}
  sTemp2 := sTemp2 + chMode;
  _fnsAddThisMode := sTemp2;
END;
{ _fnsAddThisMode }

BEGIN
      bCommaYes := System.False;
      IF (dwBitsInfoMode <> 0)
        THEN  BEGIN
             dbTempValue := System.Lo(dwBitsInfoMode);
             sTemp := asBlank;
             IF ((dbTempValue AND btBit_0_ON) <> 0)
               THEN  sTemp := sTemp + _fnsAddThisMode('0');
             {if-then}
             IF ((dbTempValue AND btBit_1_ON) <> 0)
               THEN  sTemp := sTemp + _fnsAddThisMode('1');
             {if-then}
             IF ((dbTempValue AND btBit_2_ON) <> 0)
               THEN  sTemp := sTemp + _fnsAddThisMode('2');
             {if-then}
             IF ((dbTempValue AND btBit_3_ON) <> 0)
               THEN  sTemp := sTemp + _fnsAddThisMode('3');
             {if-then}
             IF ((dbTempValue AND btBit_4_ON) <> 0)
               THEN  sTemp := sTemp + _fnsAddThisMode('4');
             {if-then}
             bCommaYes := System.False;
             sTemp := sTemp + ' (active is ';
             dbTempValue := System.Hi(dwBitsInfoMode);
             IF ((dbTempValue AND btBit_0_ON) <> 0)
               THEN  sTemp := sTemp + _fnsAddThisMode('0');
             {if-then}
             IF ((dbTempValue AND btBit_1_ON) <> 0)
               THEN  sTemp := sTemp + _fnsAddThisMode('1');
             {if-then}
             IF ((dbTempValue AND btBit_2_ON) <> 0)
               THEN  sTemp := sTemp + _fnsAddThisMode('2');
             {if-then}
             IF ((dbTempValue AND btBit_3_ON) <> 0)
               THEN  sTemp := sTemp + _fnsAddThisMode('3');
             {if-then}
             IF ((dbTempValue AND btBit_4_ON) <> 0)
               THEN  sTemp := sTemp + _fnsAddThisMode('4');
             {if-then}
             IF ( (dbTempValue AND
                  (btBit_0_ON + btBit_1_ON + btBit_2_ON +
                   +btBit_3_ON+ btBit_3_ON) )  = 0 )
               THEN sTemp := sTemp + 'none';
             {if-then}
             sTemp := sTemp + ')';
              END
        ELSE
            sTemp := 'none';
      {if-then}
      _fnsDmaTransferModeInfo := sTemp;
END;
{ _fnsDmaTransferModeInfo }


FUNCTION  _fnsTransferRateMB(dwOneCyclePerWord : System.Word) : STRING;
{* Calculates an effective transfer rate in MegaBytes/second. *}
BEGIN
   _fnsTransferRateMB :=  ', (' +
                          _fnsNumToRealStr((aBytesPerWord*aOneNanoSecond/aMegaByteSI/dwOneCyclePerWord),5,2)+
                          ' MB/sec)';
END;
{ _fnsTransferRateMB }


FUNCTION  _fnsControllerRateMB(rOneSectorTime : System.Real) : STRING;
{* Calculates an effective transfer rate in MegaBytes/second. *}
BEGIN
   _fnsControllerRateMB :=  _fnsNumToRealStr((aBytesPerDosSector/(aMegaByteSI*rOneSectorTime)),4,2)+
                          ' MB/sec';
END;
{ _fnsControllerRateMB }


FUNCTION   _fnsDriveCapacity(liDriveSizeInBytes : System.Real;
                             bUse_SI_Std : System.Boolean) : STRING;
{*  Outputs the drive capacity.  *}
VAR
  sTemp        :   STRING;
  liDivisor    :   System.Longint;
BEGIN
   IF  (bUse_SI_Std)
     THEN  liDivisor := aMegaByteSI
     ELSE  liDivisor := aBytesPerKByte*aKBytesPerMByte;
   {if-then-else}
   sTemp := _fnsNumToRealStr((liDriveSizeInBytes/liDivisor),5,2)+' MBytes   (1MB=';
   IF  (bUse_SI_Std)
     THEN  sTemp := sTemp + '10^6 bytes)'
     ELSE  sTemp := sTemp + '2^20 bytes)';
   {if-then-else}
  _fnsDriveCapacity := sTemp;
END;  { _fnsDriveCapacity }


FUNCTION  _fndbPhysDisksPerSystem(dwIDE_Disks_Count : System.Word) : System.Byte;
{* Returns # of IDE-disks in the system. *}
VAR
  dbDiskCount  :  System.Byte;
BEGIN
  {* counts the disks *}
    dbDiskCount := 0;
    IF (dwIDE_Disks_Count AND btIdeDrive_00) <> 0
      THEN  System.Inc(dbDiskCount);
    {if-then}
    IF (dwIDE_Disks_Count AND btIdeDrive_01) <> 0
      THEN  System.Inc(dbDiskCount);
    {if-then}
    IF (dwIDE_Disks_Count AND btIdeDrive_02) <> 0
      THEN  System.Inc(dbDiskCount);
    {if-then}
    IF (dwIDE_Disks_Count AND btIdeDrive_03) <> 0
      THEN  System.Inc(dbDiskCount);
    {if-then}
    IF (dwIDE_Disks_Count AND btIdeDrive_04) <> 0
      THEN  System.Inc(dbDiskCount);
    {if-then}
    IF (dwIDE_Disks_Count AND btIdeDrive_05) <> 0
      THEN  System.Inc(dbDiskCount);
    {if-then}
    IF (dwIDE_Disks_Count AND btIdeDrive_06) <> 0
      THEN  System.Inc(dbDiskCount);
    {if-then}
    IF (dwIDE_Disks_Count AND btIdeDrive_07) <> 0
      THEN  System.Inc(dbDiskCount);
    {if-then}
    IF (dwIDE_Disks_Count AND btIdeDrive_08) <> 0
      THEN  System.Inc(dbDiskCount);
    {if-then}
    IF (dwIDE_Disks_Count AND btIdeDrive_09) <> 0
      THEN  System.Inc(dbDiskCount);
    {if-then}

    _fndbPhysDisksPerSystem := dbDiskCount;
END; { _fndbPhysDisksPerSystem }


{*============================== USER HELP =============================*}

FUNCTION   _fnsUserNeedMoreHelp : STRING;
{* Display a user reminder screen about online help. *}
BEGIN
   _fnsUserNeedMoreHelp := asProgramPrompt + ' Use for more help:  ' +
                           gsName + achSPACE + achDosSwitch + asAltHelpOnScreen +
                           ' or ' +
                           gsName + achSPACE + achUnixSwitch + asHelpOnScreen;
END; { _fnsUserNeedMoreHelp }



{*=========================== PROCEDURAL PART ==========================*}


{*======================== INTERRUPT PROCESSING ========================*}

PROCEDURE    _HdcInt(Flags, CS, IP, AX, BX, CX, DX,
                     SI,DI,DS,ES,BP : System.Word); INTERRUPT;
{* Hard disk controller signals about operation termination. *}
BEGIN
     ASM
     pushf
     call  DWORD PTR  ds:[glpIntVecCtlr]
     END;
     {asm-end}
     gbIntDone := System.True;
END;
{ _HdcInt }


PROCEDURE  _EnableIRQ(dbIrqNum : System.Byte);
{* Unmask the IR bit in IMR for PIC. *}
VAR
  dbIRQ       :  System.Byte;
  dbMaskPort  :  System.Byte;
  dbMaskVal   :  System.Byte;
BEGIN
  dbMaskPort := aIMR_Master;
  dbIRQ := dbIrqNum;
  IF ( dbIRQ <> 0 )
  THEN  BEGIN
    gdbCurHardIRQ := dbIRQ;
    IF ( dbIRQ > 7)
    THEN  BEGIN
       System.Dec( dbIRQ, 8 );
       dbMaskPort := aIMR_Slave;
          END;
    {if-then}
    gdbCurImrValue := System.Port[dbMaskPort];
    dbMaskVal := 1 SHL dbIRQ;
    dbMaskVal := gdbCurImrValue AND ($FF - dbMaskVal);
    System.Port[dbMaskPort] := dbMaskVal;
        END;
  {if-then}
END;
{ _EnableIRQ }


PROCEDURE   _DisableIRQ(dbIrqNum : System.Byte);
{* Unmask the IR bit in IMR for PIC. *}
VAR
  dbIRQ       :  System.Byte;
  dbMaskPort  :  System.Byte;
BEGIN
  dbMaskPort := aIMR_Master;
  dbIRQ := dbIrqNum;
  IF ( dbIRQ <> 0 )
    THEN  BEGIN
       IF ( dbIRQ > 7)
         THEN  dbMaskPort := aIMR_Slave;
       System.Port[dbMaskPort] := gdbCurImrValue;
        END;
  {if-then}
END;
{ _DisableIRQ }


PROCEDURE    _SetupIntLink(dbIntVec, dbHardIRQ : System.Byte);
{* Init our interrupt vector link. *}
BEGIN
  IF  (dbIntVec <> aIntDef)
    THEN  BEGIN
       IF (gbDebugInfoOk)
         THEN  BEGIN
            _OutputDebugMessage('Link interrupt logic.');
               END;
       {if-then}
       _EnableIRQ(dbHardIRQ);
       gdbCurIntHdc := dbIntVec;
       Dos.GetIntVec(gdbCurIntHdc,glpIntVecCtlr);
          END;
  {if-then}
END;
{ _SetupIntLink }


PROCEDURE    _RestoreIntVect;
{* Restore old interrupt vector. *}
BEGIN
  IF  ( (gdbCurIntHdc <> aIntDef) AND (glpIntVecCtlr <> NIL) )
    THEN  BEGIN
       IF (gbDebugInfoOk)
         THEN  BEGIN
            _OutputDebugMessage('Remove interrupt logic.');
               END;
       {if-then}
      _DisableIRQ(gdbCurHardIRQ);
      Dos.SetIntVec(gdbCurIntHdc,glpIntVecCtlr);
      gdbCurIntHdc := aIntDef;
      glpIntVecCtlr := NIL;
          END;
  {if-then}
END;
{ _RestoreIntVect }


{*========================== MESSAGE OUTPUT ============================*}

PROCEDURE    _OutputMessageNoLF(sMessage : STRING);
{* Writes a message without the linefeed. *}
BEGIN
  System.Write(sMessage);
END;
{ _OutputMessageNoLF }


PROCEDURE    _HaltProgram(sHaltMessage : STRING;
                          dbHaltCode : System.Byte);
{* Stop a program running. *}
BEGIN
   _RestoreIntVect;
    System.WriteLn(asProgramPrompt+sHaltMessage);
    CASE  (dbHaltCode)  OF
       errNoPrefixSwitch,
       errBadBooleanParam,
       errBadWordParam,
       errBadWordParamRange,
       errBadPasStrParam,
       errBadPasStrParamRange,
       errUnsupportedSwitch     :  System.WriteLn(_fnsUserNeedMoreHelp);
    ELSE
       {nothing}
    END;
    {case-of}
    System.Halt(dbHaltCode);
END;  { _HaltProgram }


PROCEDURE    _OutputMessage(sMessage : STRING);
{* Writes a message through the paged stream output. *}
VAR
  sTemp   :   STRING;

BEGIN
   System.WriteLn(sMessage);
   IF (gdwTextLineNum <> aDisableScreenPage)
     THEN  BEGIN
      System.Inc(gdwTextLineNum);
      IF (gdwTextLineNum > gdwMaxScreenLines)
        THEN  BEGIN
           gdwTextLineNum := aMinOutLineOnScreen;
           System.Write(asProgramPrompt+' Press <ENTER> to continue or type any string to abort:');
           System.ReadLn(sTemp);
           IF (sTemp <> asBlank)
             THEN  BEGIN
                _HaltProgram(' Aborted by user.',errUserAbort);
                   END;
           {if-then}
              END;
      {if-then}
            END;
   {if-then}
END;  { _OutputMessage }


PROCEDURE    _OutputDebugMessage(sMessage : STRING);
BEGIN
  _OutputMessage(asProgramPrompt+' !DEBUG-INFO!  '+sMessage);
END; { _OutputDebugMessage }


PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     _OutputMessage(asPurpose+'  Version '+asVersion+',  '+asCopyright+'  '+asAuthor);
     _OutputMessage('All rights reserved. Disassembly or decompilation no prohibited.');
END;  { _CopyrightDisplay }


PROCEDURE  _MoreHelpMessageDisplay;
BEGIN
    _OutputMessage(_fnsUserNeedMoreHelp);
END;  { _MoreHelpMessageDisplay }


{*============================ WAIT EVENT ==============================*}

PROCEDURE  _WaitMoreSecondsDiv18(dwTimes : System.Word);
{* Time-independent waiting cycle. *}
VAR
  liInitValue,
  liCurrentValue   :  System.Longint;
BEGIN
  liInitValue := _fnliCurrentBiosTimeCount;
  REPEAT
     liCurrentValue := _fnliCurrentBiosTimeCount;
  UNTIL System.Word(liCurrentValue - liInitValue) >= dwTimes;
  {repeat-until}
END;  { _WaitMoreSecondsDiv18 }


PROCEDURE  _WaitMoreSeconds(dwSeconds : System.Word);
{* Time-independent waiting cycle. *}
VAR
  liInitValue,
  liCurrentValue   :  System.Longint;
BEGIN
  liInitValue := _fnliCurrentBiosTimeCount;
  REPEAT
     liCurrentValue := _fnliCurrentBiosTimeCount;
  UNTIL System.Word(liCurrentValue - liInitValue) >= (dwSeconds*aBiosTimerTicksDef);
  {repeat-until}
END;  { _WaitMoreSeconds }


PROCEDURE  _SetupTimer2; ASSEMBLER;
{* Initialize PC interval timer. *}
ASM
        in      al, ioPortB
        and     al, 0FCh                { stop counting }
        out     ioPortB, al
        jmp     @0
@0:
        mov     al, 0B8h                { set timer 2 mode }
        out     ioTimerCtrl, al
        jmp     @2
@2:
        pushf
        cli
        mov     al, 0                   { low count }
        out     ioTimerCount2, al
        jmp     @1
@1:
        out     ioTimerCount2, al       { high count }
        popf
END;  { _SetupTimer2 }


{*======================= HDD CONTROLLER TEST ==========================*}

PROCEDURE  _WriteSDH_Val(dwSDH_Reg : System.Word; dbDiskNum : System.Byte);
{* Write a value to sector/drive/head register. *}
VAR
  dbWriteVal  :  System.Byte;

BEGIN
  {* select default modes *}
    dbWriteVal := ((dbDiskNum SHL 4) OR (btCRCmode+btSecSize512)) OR (gdbSDH_TestVal AND $0F);
    gdbSDH_TestVal := dbWriteVal;

  {* output a value *}
    System.Port[dwSDH_Reg] := dbWriteVal;
END; { _WriteSDH_Val }


PROCEDURE  _TestDiskControllerHardware(recRD_HDISK_Regs  : recHDISK_READ_REGS;
                                       recWRT_HDISK_Regs : recHDISK_WRITE_REGS;
                                       dbDiskNum : System.Byte);
{* Test for disk drive controller present. *}
VAR
  dbDelayCount  :  System.Byte;

BEGIN
    {* we assume that unsuccess will occurred *}
   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('Test task file of registers.');
           END;
   {if-then}

     gbDiskStatusOK := System.False;

    {* test 1: write value (non-FF) to SDH and read it back*}
    _WriteSDH_Val(recWRT_HDISK_Regs.dwSDH_Reg_WR,dbDiskNum);
     FOR dbDelayCount := 1 TO gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
     IF (System.Port[recRD_HDISK_Regs.dwStatusReg_RD] = aTestPattern_FF)
        THEN  System.Exit;
     {if-then}

    {* test 2: controller busy? *}
     IF NOT(_fnbControllerIsReady(recRD_HDISK_Regs.dwStatusReg_RD))
        THEN  System.Exit;
     {if-then}

    {* test 3: write wanted value to SDH and read it back *}
      gbDiskStatusOK := System.False;
      System.Port[recWRT_HDISK_Regs.dwSDH_Reg_WR] := gdbSDH_TestVal;
     FOR dbDelayCount := 1 TO gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
      IF (System.Port[recRD_HDISK_Regs.dwSDH_Reg_RD] <> gdbSDH_TestVal)
        THEN  System.Exit;
      {if-then}

    {* test 4: write test pattern to SDH and read it back *}
      System.Port[recWRT_HDISK_Regs.dwCylinderLowReg_WR] := aTestPattern_AA;
     FOR dbDelayCount := 1 TO gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
      IF (System.Port[recRD_HDISK_Regs.dwCylinderLowReg_RD] <> aTestPattern_AA)
        THEN  System.Exit;
      {if-then}

    {* test 5: write test pattern to SDH and read it back *}
      System.Port[recWRT_HDISK_Regs.dwCylinderLowReg_WR] := aTestPattern_55;
     FOR dbDelayCount := 1 TO gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
      IF (System.Port[recRD_HDISK_Regs.dwCylinderLowReg_RD] <> aTestPattern_55)
        THEN  System.Exit;
      {if-then}

    {* test 6: drive ready? *}
     FOR dbDelayCount := 1 TO 2*gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
       IF ((System.Port[recRD_HDISK_Regs.dwStatusReg_RD] AND btDriveReady) <> 0)
          THEN  gbDiskStatusOK := System.True;
       {if-then}

END; { _TestDiskControllerHardware }


{*======================= HDC PROGRAM SUPPORT ==========================*}

PROCEDURE  _OutputCommandBlock(VAR recWR_CMD_BLOCK :  recHDISK_WRITE_CMD_BLOCK;
                               dwBaseReg : System.Word);
{* Write all control bytes to registers. *}
VAR
  dbDelayCount  :  System.Byte;

BEGIN
  WITH  (recWR_CMD_BLOCK)  DO
  BEGIN
     System.Port[dwBaseReg+$01] := dbWRC_WR;
     FOR dbDelayCount := 1 TO 2*gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
     System.Port[dwBaseReg+$02] := dbSectorCount_WR;
     FOR dbDelayCount := 1 TO 2*gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
     System.Port[dwBaseReg+$03] := dbSectorNumber_WR;
     FOR dbDelayCount := 1 TO 2*gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
     System.Port[dwBaseReg+$04] := dbCylinderLow_WR;
     FOR dbDelayCount := 1 TO 2*gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
     System.Port[dwBaseReg+$05] := dbCylinderHigh_WR;
     FOR dbDelayCount := 1 TO 2*gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
     System.Port[dwBaseReg+$06] := dbSDH_WR;
     FOR dbDelayCount := 1 TO 2*gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
  END;
  {with-do}
END; { _OutputCommandBlock }


PROCEDURE  _HardResetController(dwStatusPort : System.Word;
                                asController : STRING);
{* Do a hard reset of controller. *}
BEGIN
    System.WriteLn(asProgramPrompt + ' Soft Reset of a '+
                   asController + ' HDD controller.');

   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('Disable controller and wait.');
           END;
   {if-then}
    System.Port[dwStatusPort] := cmdDisableInts;
    _WaitMoreSeconds(2*gdwDelayFactor);

   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('Enable controller and wait.');
           END;
   {if-then}
    System.Port[dwStatusPort] := cmdEnableInts;
    _WaitMoreSeconds(2*gdwDelayFactor);
END;
{ _HardResetController }


PROCEDURE  _WriteControllerCommand(recRD_HDISK_Regs    :  recHDISK_READ_REGS;
                                   recWRT_HDISK_Regs   :  recHDISK_WRITE_REGS;
                                   recWR_CMD_BLOCK     :  recHDISK_WRITE_CMD_BLOCK);
{* Write a controller command bytes. *}
VAR
  dbDelayCount  :  System.Byte;

BEGIN
   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('Write command to controller.');
           END;
   {if-then}

  {* controller not buzy? *}
     IF NOT(_fnbControllerIsReady(recRD_HDISK_Regs.dwStatusReg_RD))
        THEN  System.Exit;
     {if-then}

  {* write first 6 command bytes to controller *}
    _OutputCommandBlock(recWR_CMD_BLOCK,recWRT_HDISK_Regs.dwDataReg_WR);
     FOR dbDelayCount := 1 TO 2*gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}

  {* is drive ready? *}
     IF NOT(_fnbDriveIsReady(recRD_HDISK_Regs.dwStatusReg_RD))
        THEN  System.Exit;
     {if-then}

  {* write last command byte into controller stack space *}
     FOR dbDelayCount := 1 TO 2*gdwDelayFactor DO _IO_DELAY_2;
     {for-to-do}
    System.Port[recWRT_HDISK_Regs.dwCommand_Reg_WR] :=  recWR_CMD_BLOCK.dbCommand_WR;

END; { _WriteControllerCommand }


PROCEDURE  _InitCommandBlock(VAR recWR_CMD_BLOCK :  recHDISK_WRITE_CMD_BLOCK);
{* Build command block for controller. *}
BEGIN
  WITH  (recWR_CMD_BLOCK)  DO
  BEGIN
      dbWRC_WR          := $00;             { see tech. ref. of any IDE/ATA drive }
      dbSectorCount_WR  := $00;
      dbSectorNumber_WR := $00;
      dbCylinderLow_WR  := $00;
      dbCylinderHigh_WR := $00;
      dbSDH_WR          := gdbSDH_TestVal;  { std value }
      dbCommand_WR      := cmdIDENTIFY;
  END;
  {with-do}
END; { _InitCommandBlock }


{*========================== FILE OPERATIONS ===========================*}

PROCEDURE  _WriteBufToFile(VAR  recDriveInfoBuf  :  recIDE_Info_Sector);
{* Detail info about IDE-drive parameters. *}
VAR
   recDriveInfOutputStream      :   FILE  OF  recIDE_Info_Sector;
   sFileName                    :   STRING;
   chTemp                       :   System.Char;

BEGIN
   IF (gsFileName = asBlank)
     THEN  BEGIN
       _OutputMessageNoLF(asProgramPrompt+' Enter filename (def.ext.='+asDefExt+'): ');
       System.ReadLn(sFileName);
      _OutputMessage(asBlank);
           END
     ELSE  BEGIN
       sFileName := gsFileName;
           END;
   {if-then-else}
   IF (sFileName <> asBlank)
   THEN BEGIN
     sFileName := _fnsForceFileExtension(sFileName,asDefExt);
     System.Assign(recDriveInfOutputStream,sFileName);
     {$I-}
     System.Reset(recDriveInfOutputStream);
     {$I+}
     IF (System.IOResult = errOK)
       THEN BEGIN
         {At first close original user file}
         System.Close(recDriveInfOutputStream);
         sFileName := gsReservedFileName;
         System.Assign(recDriveInfOutputStream,sFileName);
         chTemp := gsReservedFileName[System.Length(gsReservedFileName)+1];
         System.Inc(chTemp);
         IF  (chTemp > '9')
           THEN BEGIN
             gsReservedFileName[System.Length(gsReservedFileName)+1] := '0';
             System.Inc(gsReservedFileName[System.Length(gsReservedFileName)]);
                END;
         {if-then}
            END;
     {if-then}
     System.Rewrite(recDriveInfOutputStream);
     System.Write(recDriveInfOutputStream,recDriveInfoBuf);
     System.Close(recDriveInfOutputStream);
        END;
   {if-then}
END;
{ _WriteBufToFile }


PROCEDURE  _ReadFileToBuf(VAR  recDriveInfoBuf  :  recIDE_Info_Sector);
{* Get detail info about IDE-drive parameters. *}
VAR
   recDriveInfOutputStream      :   FILE  OF  recIDE_Info_Sector;
   sFileName                    :   STRING;
   chTemp                       :   System.Char;

BEGIN
   IF (gsFileName = asBlank)
     THEN  BEGIN
       _OutputMessageNoLF(asProgramPrompt+' Enter filename (def.ext.='+asDefExt+'): ');
       System.ReadLn(sFileName);
      _OutputMessage(asBlank);
           END
     ELSE  BEGIN
       sFileName := gsFileName;
           END;
   {if-then-else}
   IF (sFileName <> asBlank)
   THEN BEGIN
     sFileName := _fnsForceFileExtension(sFileName,asDefExt);
     System.FileMode := $20;   {read, deny write on share}
     System.Assign(recDriveInfOutputStream,sFileName);
     {$I-}
     System.Reset(recDriveInfOutputStream);
     {$I+}
     IF (System.IOResult <> errOK)
       THEN BEGIN
          _HaltProgram(' File I/O operation fatal error.',errBadFileIO);
            END;
     {if-then}
     System.Read(recDriveInfOutputStream,recDriveInfoBuf);
     System.Close(recDriveInfOutputStream);
        END
    ELSE BEGIN
       _HaltProgram(' No matching user filename found.',errBadUserFileName);
         END;
   {if-then-else}
END;
{ _ReadFileToBuf }


{*======================= GET DRIVE PARAMETERS =========================*}

PROCEDURE  _ReadDriveParameters(VAR  recDriveInfoBuf  :  recIDE_Info_Sector;
                                recRD_HDISK_Regs      :  recHDISK_READ_REGS;
                                recWRT_HDISK_Regs     :  recHDISK_WRITE_REGS;
                                recWR_CMD_BLOCK       :  recHDISK_WRITE_CMD_BLOCK;
                                dbDiskNum             :  System.Byte;
                                dbIntVec              :  System.Byte;
                                dbIrqNum              :  System.Byte);
{* Try to issue an IDENTIFY command for IDE/ATA drive. *}
LABEL
     Exit;
CONST
    rDiv     :     System.Real   =  1193183/1.0E+9;
              { maximum estimated time interval = ~55 ms  }
              { minimum estimated time interval = ~838 ns }
VAR
  rExecTime             :   System.Real;
  dwExecTimeCH2,
  dwIntTimeout          :   System.Word;
  dbTestVal,
  dbSavePortB           :   System.Byte;

BEGIN

  {* test message *}
    _OutputMessage(asProgramPrompt+' Issue IDENTIFY command.');

  {* make command block for controller *}
   _InitCommandBlock(recWR_CMD_BLOCK);

  {* setup our interrupt vector routine *}
  _SetupIntLink(dbIntVec,dbIrqNum);
   IF  (gdbCurIntHdc <> aIntDef)
     THEN  BEGIN
       IF (gbDebugInfoOk)
         THEN  BEGIN
            _OutputDebugMessage('Use interrupt logic.');
               END;
       {if-then}
        gbIntDone := System.False;
        Dos.SetIntVec(gdbCurIntHdc,@_HdcInt);
          END;
   {if-then}

  {* try to load this command *}
   _WriteControllerCommand(recRD_HDISK_Regs,recWRT_HDISK_Regs,recWR_CMD_BLOCK);
   IF  NOT(gbDiskStatusOK)
      THEN  BEGIN
          GOTO Exit;
            END;
   {if-then}

  {* setup our interrupt vector routine *}
   IF  (gdbCurIntHdc <> aIntDef)
     THEN  BEGIN
       gbDiskStatusOK := System.False;
       dwIntTimeout := aBiosTimerTicksDef*3*gdwDelayFactor;
       WHILE  NOT( gbIntDone AND gbDiskStatusOK)  DO
       BEGIN
         _WaitMoreSecondsDiv18(1*gdwDelayFactor);
         System.Dec(dwIntTimeout);
         IF  (dwIntTimeout = 0)
           THEN  BEGIN
              IF (gbDebugInfoOk)
                THEN  BEGIN
                   _OutputDebugMessage('Timeout on HDC interrupt occurred.');
                      END;
              {if-then}
              GOTO Exit;
                 END;
         {if-then}
         IF  (gbIntDone)
           THEN  BEGIN
              IF (gbDebugInfoOk)
                THEN  BEGIN
                   _OutputDebugMessage('HDC interrupt complete.');
                   {_OutputDebugMessage('DRQ state: $'+_fnsByteToHexFmt(recRD_HDISK_Regs.dwStatusReg_RD));}
                      END;
              {if-then}
              gbDiskStatusOK := _fnbControllerIsReady(recRD_HDISK_Regs.dwStatusReg_RD);
                 END;
         {if-then}
       END;
       {while-do}
       gbIntDone := System.False;
          END
     ELSE BEGIN
       {* wait data transfer from disk drive *}
        IF ( _fnbWaitDRQ(recRD_HDISK_Regs.dwStatusReg_RD) )
             THEN BEGIN
              {* output estimated timing *}
               IF (gbDebugInfoOk)
                 THEN  BEGIN
                       END;
               {if-then}
                  END
             ELSE BEGIN
                 GOTO Exit;
                   END;
        {if-then-else}
          END;
   {if-then-else}


  {* setup needed hardware *}
   IF (gbTimeMeasureOk)
     THEN  _SetupTimer2;

  {* get drive info buffer *}
   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('Transfer buffer contents.');
     IF  (gbDiskAccess32Ok) AND (gbCPUis386)
          THEN  _OutputDebugMessage('Use doubleword mode to transfer.')
          ELSE  _OutputDebugMessage('Use word mode to transfer.');
     {if-then-else}
           END;
   {if-then}

   IF  (gbDiskAccess32Ok) AND (gbCPUis386)
     THEN  BEGIN
       IF (gbTimeMeasureOk)
         THEN  BEGIN
           ASM
            @EnableTimer:
                    in    al, ioPortB
                    mov   dbSavePortB, al
                    or    al, 1
                    cli
                    out   ioPortB, al
                    jmp     @CodeStartHere
            @CodeStartHere:
           END;
           {asm-end}
               END;
        {if-then}
           _ReadDataSector512(recDriveInfoBuf,
                              recWRT_HDISK_Regs.dwDataReg_WR,
                              aWordsPerDosSector);
       IF (gbTimeMeasureOk)
         THEN  BEGIN
           ASM
             @CodeEndHere:
                     mov   al, dbSavePortB
                     out   ioPortB, al
           END;
           {asm-end}
           dwExecTimeCH2 := _fndwCountTimer2;
               END;
        {if-then}
           END
     ELSE  BEGIN
       IF (gbTimeMeasureOk)
         THEN  BEGIN
           ASM
             @EnableTimer:
                     in        al, ioPortB
                     mov       dbSavePortB, al
                     or        al, 1
                     cli
                     out       ioPortB, al
                     jmp     @CodeStartHere
             @CodeStartHere:
                  END;
                  {asm-end}
               END;
        {if-then}
           _ReadDataSector512(recDriveInfoBuf,
                              recWRT_HDISK_Regs.dwDataReg_WR,
                              aWordsPerDosSector);
       IF (gbTimeMeasureOk)
         THEN  BEGIN
           ASM
            @CodeEndHere:
                    mov  al, dbSavePortB
                    out  ioPortB, al
           END;
           {asm-end}
           dwExecTimeCH2 := _fndwCountTimer2;
               END;
        {if-then}
           END;
   {if-then-else}


  {* Reading of status register must be clear IRQ14 latch!!! *}
   dbTestVal := _fndbReadControllerStatus(recRD_HDISK_Regs.dwStatusReg_RD);

  {* output estimated timing *}
   IF (gbTimeMeasureOk)
     THEN  BEGIN
        rExecTime :=  dwExecTimeCH2/rDiv;
        _OutputMessage(asProgramPrompt+'Timer2-> Transfer 512-byte sector [ms] = '+
                            _fnsNumToRealStr((rExecTime/1.0E6),6,3));
        _OutputMessage(asProgramPrompt+'Controller-to-Host DTR = '+
                            _fnsControllerRateMB(rExecTime/1.0E9));
           END;
   {if-then}

Exit:
  {* restore interrupt vector}
  _RestoreIntVect;
END; { _ReadDriveParameters }



PROCEDURE  _InitDiskDriveRegsReadMap(VAR recRD_HDISK_Regs : recHDISK_READ_REGS;
                                     dwDskCtlrBaseReg : System.Word);
{* Initialize disk drive controller registers read map. *}
BEGIN
  WITH  (recRD_HDISK_Regs)  DO
   BEGIN
       dwDataReg_RD              := dwDskCtlrBaseReg + $00;
       dwErrorReg_RD             := dwDskCtlrBaseReg + $01;
       dwSectorCountReg_RD       := dwDskCtlrBaseReg + $02;
       dwSectorNumberReg_RD      := dwDskCtlrBaseReg + $03;
       dwCylinderLowReg_RD       := dwDskCtlrBaseReg + $04;
       dwCylinderHighReg_RD      := dwDskCtlrBaseReg + $05;
       dwSDH_Reg_RD              := dwDskCtlrBaseReg + $06;
       dwStatusReg_RD            := dwDskCtlrBaseReg + $07;
   END;
  {with-do}
END; { _InitDiskDriveRegsReadMap }


PROCEDURE  _InitDiskDriveRegsWriteMap(VAR recWRT_HDISK_Regs : recHDISK_WRITE_REGS;
                                     dwDskCtlrBaseReg : System.Word);
{* Initialize disk drive controller registers write map. *}
BEGIN
  WITH  (recWRT_HDISK_Regs)  DO
   BEGIN
      dwDataReg_WR              := dwDskCtlrBaseReg + $00;
      dwWRC_Reg_WR              := dwDskCtlrBaseReg + $01;
      dwSectorCountReg_WR       := dwDskCtlrBaseReg + $02;
      dwSectorNumberReg_WR      := dwDskCtlrBaseReg + $03;
      dwCylinderLowReg_WR       := dwDskCtlrBaseReg + $04;
      dwCylinderHighReg_WR      := dwDskCtlrBaseReg + $05;
      dwSDH_Reg_WR              := dwDskCtlrBaseReg + $06;
      dwCommand_Reg_WR          := dwDskCtlrBaseReg + $07;
   END;
  {with-do}
END; { _InitDiskDriveRegsWriteMap }


PROCEDURE  _DisplayDriveParameters(VAR  recDriveInfoBuf  :  recIDE_Info_Sector;
                                   dbDiskNum : System.Byte;
                                   dwDiskIncVal : System.Word);
{* Detail info about IDE-drive parameters. *}
VAR
  sTemp                 :       STRING;
  rCalcTemp             :       System.Real;
  liCalcTotalSectors,
  liCalcCylinders       :      System.Longint;
  dwTempValue,
  dwTempValueCyl,
  dwCapacityRatio,
  dwCalcParmsCount,
  dwMaxCalcHeadNum,
  dwCalcHeads,
  dwCalcSectors,
  dwLogSectors,
  dwLogHeads,
  dwLogCylinders        :       System.Word;
  dbBiosDiskOrderNum,
  dbTempValue           :       System.Byte;
  bUserNoAskExit,
  bDisplayEnable,
  bBiosReportOk         :       System.Boolean;

BEGIN

  {* header message *}
   _OutputMessage(asBlank);
   _OutputMessage(asProgramPrompt+'Screen 1 of 4 -> Disk Drive '+_fnsNumToStr(dbDiskNum,1)+' Internal Information');

  {* general parameters of drive *}
   WITH  (recDriveInfoBuf)  DO
   BEGIN
      _OutputMessage('-----> Default Translation Mode Parameters <-----');
      _OutputMessage('Fixed Cylinders ...................... '+_fnsNumToStr(dwFixedCylsNum,4));
      IF (dwRemoveableCylsNumVU <> 0) AND (gdbDisplayAll)
        THEN  _OutputMessage('Removeable Cylinders (OBSOLETE)....... '+_fnsNumToStr(dwRemoveableCylsNumVU,4));
      {if-then}
      _OutputMessage('R(ead)/W(rite) Heads ................. '+_fnsNumToStr(dwHeadsNum,3));
      IF  (gdbDisplayAll)
        THEN  BEGIN
         _OutputMessage('Unformatted Bytes Per Physical Track.. '+_fnsNumToStr(dwUnfmtdBytesPerPhysTrkVU,5));
         _OutputMessage('Unformatted Bytes Per Sector (OBS).... '+_fnsNumToStr(dwUnfmtdBytesPerSecVU,5));
              END;
      {if-then}
      _OutputMessage('Physical Sectors Per Track (OBS)...... '+_fnsNumToStr(dwPhysSecsPerTrk,5));

      gliTotalDiskSectors := System.Longint(dwPhysSecsPerTrk) * dwHeadsNum * dwFixedCylsNum;

      _OutputMessage('-----> Controller/Drive/Firmware Information <-----');
      IF  (gdbDisplayAll)
        THEN  BEGIN
           _OutputMessage('Controller/Buffer Type (OBSOLETE)..... '+'Type '+_fnsNumToStr(dwControllerTypeVU,5));
           CASE  dwControllerTypeVU OF
                   $0000   :   _OutputMessage('    (not specified)');
                   $0001   :   _OutputMessage('    (single ported single sector buffer)');
                   $0002   :   _OutputMessage('    (dual ported multiple sectors buffer)');
                   $0003   :   _OutputMessage('    (dual ported multiple sectors buffer with look-ahead read)');
            ELSE
                               _OutputMessage('    (Reserved)');
           END;
           {case-of}
              END;
      {if-then}
      _OutputMessage('Controller Buffer Size (OBSOLETE)..... '+_fnsNumToStr((dwControllerBufSizeVU DIV 2),5)+
                                                              '.'+
                                                              +_fnsNumToStr((dwControllerBufSizeVU MOD 2)*5,5)+
                                                              ' KB ('+_fnsNumToStr((dwControllerBufSizeVU),3)+' sectors)');
      IF  (gdbDisplayAll)
        THEN  BEGIN
      _OutputMessage('Controller Firmware Revision ......... '+
                     _fnsAsciiInfo(System.Ptr(Seg(dbCntlrFirmwareRevision),
                                   System.Ofs(dbCntlrFirmwareRevision)),
                                   dbCntlrFirmwareRevisionLen,System.True));
              END;
      {if-then}
      _OutputMessage('Serial Number ........................ '+
                     _fnsAsciiInfo(System.Ptr(Seg(dbSerialNumber),System.Ofs(dbSerialNumber)),dbSerialNumberLen,System.True));
      _OutputMessage('Model Number ......................... '+
                     _fnsAsciiInfo(System.Ptr(Seg(dbModelNumber),System.Ofs(dbModelNumber)),dbModelNumberLen,System.True));
      IF  (gdbDisplayAll)
        THEN  BEGIN
        IF ((dwMajorVersionNumber <> $0000) AND (dwMajorVersionNumber <> $FFFF))
          THEN BEGIN
            _OutputMessageNOLF('ATA-1 std support................. ');
            IF ((dwMajorVersionNumber AND btBit_1_ON) = 0)
              THEN  _OutputMessage('no')
              ELSE  _OutputMessage('yes');
            {if-then-else}
            _OutputMessageNOLF('ATA-2 std support................. ');
            IF ((dwMajorVersionNumber AND btBit_2_ON) = 0)
              THEN  _OutputMessage('no')
              ELSE  _OutputMessage('yes');
            {if-then-else}
            _OutputMessageNOLF('ATA-3 std support................. ');
            IF ((dwMajorVersionNumber AND btBit_3_ON) = 0)
              THEN  _OutputMessage('no')
              ELSE  _OutputMessage('yes');
            {if-then-else}
               END;
        {if-then}
        IF ((dwMinorVersionNumber <> $0000) AND (dwMinorVersionNumber <> $FFFF))
          THEN BEGIN
            _OutputMessageNOLF('Standard implementation........... ');
             CASE (dwMinorVersionNumber) OF
                 $0001:  _OutputMessage('ATA-1 X3T9.2 781D prior r4');
                 $0003:  _OutputMessage('ATA-1 X3T9.2 781D r4');
                 $0005:  _OutputMessage('ATA-2 X3T10 948D prior r2k');
                 $0007:  _OutputMessage('ATA-2 X3T10 948D r2k');
                 $0009:  _OutputMessage('ATA-2 X3T10 948D r3');
                 $0008:  _OutputMessage('ATA-3 X3T10 2008D r0');
                 $0006:  _OutputMessage('ATA-3 X3T10 2008D r1');
               ELSE
                         _OutputMessage('reserved');
             END;
             {case-of}
               END;
        {if-then}
        IF ((dwNotifyCommandSet_W1 <> $0000) AND (dwNotifyCommandSet_W1 <> $FFFF))
          THEN BEGIN
            _OutputMessageNOLF('SMART feature command set......... ');
            IF ((dwNotifyCommandSet_W1 AND btBit_0_ON) = 0)
              THEN  _OutputMessage('not supported')
              ELSE  _OutputMessage('supported');
            {if-then-else}
            _OutputMessageNOLF('Security feature command set...... ');
            IF ((dwNotifyCommandSet_W1 AND btBit_1_ON) = 0)
              THEN  _OutputMessage('not supported')
              ELSE  _OutputMessage('supported');
            {if-then-else}
            _OutputMessageNOLF('Removeable feature command set.... ');
            IF ((dwNotifyCommandSet_W1 AND btBit_2_ON) = 0)
              THEN  _OutputMessage('not supported')
              ELSE  _OutputMessage('supported');
            {if-then-else}
            _OutputMessageNOLF('Power management feature set...... ');
            IF ((dwNotifyCommandSet_W1 AND btBit_3_ON) = 0)
              THEN  _OutputMessage('not supported')
              ELSE  _OutputMessage('supported');
            {if-then-else}
               END;
        {if-then}
              END;
      {if-then}

      IF  (gdbDisplayAll)
        THEN  BEGIN
      _OutputMessage('-----> Miscellaneous Drive Transfer Information <-----');
      IF ((dwSecurityStatus AND btBit_0_ON) <> 0)
        THEN BEGIN
          _OutputMessage('Security status on this drive......... supported');
          _OutputMessageNOLF('Security enabled...................... ');
          IF ((dwSecurityStatus AND btBit_1_ON) = 0)
            THEN  _OutputMessage('no')
            ELSE  _OutputMessage('yes');
          {if-then-else}
          _OutputMessageNOLF('Security locked....................... ');
          IF ((dwSecurityStatus AND btBit_2_ON) = 0)
            THEN  _OutputMessage('no')
            ELSE  _OutputMessage('yes');
          {if-then-else}
          _OutputMessageNOLF('Security frozen....................... ');
          IF ((dwSecurityStatus AND btBit_3_ON) = 0)
            THEN  _OutputMessage('no')
            ELSE  _OutputMessage('yes');
          {if-then-else}
          _OutputMessageNOLF('Security count expired................ ');
          IF ((dwSecurityStatus AND btBit_4_ON) = 0)
            THEN  _OutputMessage('no')
            ELSE  _OutputMessage('yes');
          {if-then-else}
          _OutputMessageNOLF('Security level........................ ');
          IF ((dwSecurityStatus AND btBit_8_ON) = 0)
            THEN  _OutputMessage('high')
            ELSE  _OutputMessage('maximum');
          {if-then-else}
             END;
      {if-then}
      _OutputMessage('ECC bytes............................. '+_fnsNumToStr(dwECCbytes,5));
      _OutputMessageNOLF('Max. Secs/Interrupt for R/W MultiMode. ');
      IF (System.Hi(dwSecsPerIntr) <> 0)
        THEN
          _OutputMessage(_fnsNumToStr((System.Lo(dwSecsPerIntr)),3)+' sectors')
        ELSE
          _OutputMessage('not supported');
      {if-then-else}
      _OutputMessageNOLF('Current Secs/Int for R/W MultiMode.... ');
      IF ((dwMultipleSecsModeXfrSettings AND btBit_8_ON) = 0)
        THEN  _OutputMessage('not valid')
        ELSE  _OutputMessage('valid ('+_fnsNumToStr((System.Lo(dwMultipleSecsModeXfrSettings)),3)+' sectors/int)');
      {if-then-else}

      _OutputMessageNoLF('Double Word Transfer Flag (OBSOLETE).. ');
      CASE (dwDoubleWordTransferFlagVU) OF
               0    :    _OutputMessage('not supported');
               1    :    _OutputMessage('supported');
      ELSE
         _OutputMessage(achHexPrefix+_fnsWordToHexFmt(dwDoubleWordTransferFlagVU)+' = unknown');
      END;
      {case-of}

      _OutputMessageNoLF('Assign Alternate (OBSOLETE)........... ');
      CASE System.Lo(dwAssignAlternate) OF
               0    :    _OutputMessage('not supported');
               1    :    _OutputMessage('supported');
      ELSE
         _OutputMessage(achHexPrefix+_fnsWordToHexFmt(dwAssignAlternate)+' (unknown, VU)');
      END;
      {case-of}
      _OutputMessageNoLF('Standby timer values.................. ');
      IF  ((dwAssignAlternate AND btBit_D_ON) = 0)
        THEN  _OutputMessage('vendor specific')
        ELSE  _OutputMessage('standard');
      {if-then-else}
      _OutputMessageNoLF('IORDY operations...................... ');
      IF  ((dwAssignAlternate AND btBit_B_ON) = 0)
        THEN  _OutputMessage('may be supported')
        ELSE  _OutputMessage('supported');
      {if-then-else}
      _OutputMessageNoLF('IORDY disabling....................... ');
      IF  ((dwAssignAlternate AND btBit_A_ON) = 0)
        THEN  _OutputMessage('not supported')
        ELSE  _OutputMessage('supported');
      {if-then-else}
      _OutputMessageNoLF('DMA support (OBSOLETE)................ ');
      IF ((dwAssignAlternate AND btBit_8_ON) = 0)
        THEN  _OutputMessage('no')
        ELSE  _OutputMessage('yes');
      {if-then-else}
      _OutputMessageNoLF('LBA found (OBSOLETE).................. ');
      IF ((dwAssignAlternate AND btBit_9_ON) = 0)
        THEN  _OutputMessage('no')
        ELSE  _OutputMessage('yes');
      {if-then-else}
      _OutputMessage('Total sectors per drive (LBA mode).... '+_fnsNumToStr(ddTotalUserSecsInLBA_Mode,8));

      _OutputMessageNOLF('PIO Data Transfer Cycle Timing Mode... ');
      dbTempValue := System.Hi(dwPIODataXFRCycleTimingMode);
      IF (dbTempValue = 0)
        THEN  BEGIN
          sTemp := 'mode 0 (min=600 ns)';
          dwTempValue := 600;
              END;
      {if-then}
      IF (dbTempValue = 1)
        THEN  BEGIN
          sTemp := 'mode 1 (min=383 ns)';
          dwTempValue := 383;
              END;
      {if-then}
      IF (dbTempValue = 2)
        THEN  BEGIN
          sTemp := 'mode 2 (min=240 ns)';
          dwTempValue := 240;
              END;
      {if-then}
      IF (dbTempValue = 3)
        THEN  BEGIN
          sTemp := 'mode 3 (min=180 ns)';
          dwTempValue := 180;
              END;
      {if-then}
      IF (dbTempValue = 4)
        THEN  BEGIN
          sTemp := 'mode 4 (min=120 ns)';
          dwTempValue := 120;
              END;
      {if-then}
      IF (dbTempValue > 4)
        THEN   sTemp := 'unknown mode ' + _fnsNumToStr(dbTempValue,3)
        ELSE   sTemp := sTemp + _fnsTransferRateMB(dwTempValue);
      {if-then-else}
      _OutputMessage(sTemp);

      _OutputMessageNOLF('DMA Data Transfer Cycle Timing Mode... ');
      dbTempValue := System.Hi(dwDMADataXFRCycleTimingMode);
      IF (dbTempValue = 0)
        THEN  BEGIN
          sTemp := 'mode 0 (min=960 ns)';
          dwTempValue := 960;
              END;
      {if-then}
      IF (dbTempValue = 1)
        THEN  BEGIN
          sTemp := 'mode 1 (min=480 ns)';
          dwTempValue := 480;
              END;
      {if-then}
      IF (dbTempValue = 2)
        THEN  BEGIN
          sTemp := 'mode 2 (min=240 ns)';
          dwTempValue := 240;
              END;
      {if-then}
      IF (dbTempValue > 2)
        THEN   sTemp := 'unknown mode ' + _fnsNumToStr(dbTempValue,3)
        ELSE   sTemp := sTemp + _fnsTransferRateMB(dwTempValue);
      {if-then-else}
      _OutputMessage(sTemp);


      _OutputMessage('-----> V(endor) U(nique) Fields for Drive <-----');
      IF (dwInterSecGapBytesNumVU <> 0)
        THEN  _OutputMessage('Inter-Sector Gap Bytes................ '+_fnsNumToStr(dwInterSecGapBytesNumVU,5));
      {if-then}
      IF (dwSyncFieldsBytesNumVU <> 0)
        THEN  _OutputMessage('Bytes in Synch Fields................. '+_fnsNumToStr(dwSyncFieldsBytesNumVU,5));
      {if-then}
      IF (dwPLObyteNumVU <> 0)
        THEN  _OutputMessage('Min. PLO Bytes........................ '+_fnsNumToStr(dwPLObyteNumVU,5));
      {if-then}
      _OutputMessage('Vendor Unique Text Field..............');
      _OutputMessage('  '+
          _fnsAsciiInfo(System.Ptr(Seg(dbVendorUniqueInfoText),System.Ofs(dbVendorUniqueInfoText)),
                        dbVendorUniqueInfoTextLen,System.False));
              END;
      {if-then}

      _OutputMessage('-----> Current Translation Mode Parameters <-----');
      _OutputMessageNoLF('Settings for this mode................ ');
      IF ((dwCurrentSettingsValidFlag AND btBit_0_ON) = 0)
        THEN  _OutputMessage('may be valid')
        ELSE  _OutputMessage('valid');
      {if-then}
      _OutputMessage('Current Cylinders Number.............. '+_fnsNumToStr(dwCurrentCylsNum,4));
      _OutputMessage('Current Heads Number.................. '+_fnsNumToStr(dwCurrentHeadsNum,3));
      _OutputMessage('Current Sectors Per Track Number...... '+_fnsNumToStr(dwCurrentSecsPerTrack,5));
      IF  (gdbDisplayAll)
        THEN  BEGIN
      _OutputMessageNoLF('Current total sectors per drive ...... '+_fnsNumToStr(ddCurrentDriveCapacityInSecs,11));
      IF (ddCurrentDriveCapacityInSecs < 0)
        THEN _OutputMessage('  (!real value='+_fnsNumToStr(gliTotalDiskSectors,11)+')')
        ELSE _OutputMessage(asBlank);
      {if-then-else}
              END;
      {if-then}

      _OutputMessage('-----> Advanced Transfer Modes Parameters   <-----');
      _OutputMessageNoLF('Settings for this mode................ ');
      IF ((dwCurrentSettingsValidFlag AND btBit_1_ON) = 0)
        THEN  _OutputMessage('not valid')
        ELSE  BEGIN
          _OutputMessage('valid');
          _OutputMessage('Single Word DMA Data Transfer Modes... '+_fnsDmaTransferModeInfo(dwSingleWordDMA_XfrMode));
          _OutputMessage('Multi-Word DMA Data Transfer Modes.... '+_fnsDmaTransferModeInfo(dwMultiWordDMA_XfrMode));
          dbTempValue := System.Lo(dwFlowCtrlPIO_XfrMode);
          _OutputMessageNoLF('PIO 3 Data Transfer Mode.............. ');
          IF  ((dbTempValue AND btBit_0_ON) = 0)
            THEN  _OutputMessage('not supported')
            ELSE  BEGIN
                  _OutputMessage('supported'+
                         ' (min=180 ns)' +
                         _fnsTransferRateMB(180));
                  END;
          {if-then-else}
          _OutputMessageNoLF('PIO 4 Data Transfer Mode.............. ');
          IF  ((dbTempValue AND btBit_1_ON) = 0)
            THEN  _OutputMessage('not supported')
            ELSE  BEGIN
                  _OutputMessage('supported'+
                         ' (min=120 ns)' +
                          _fnsTransferRateMB(120));
                  END;
          {if-then-else}
          IF  (dwMinMultiWordDMA_XfrMode <> 0)
            THEN  BEGIN
              _OutputMessage('Min.MultWord DMA Transfer Cycle Time.. '+
                             _fnsNumToStr(dwMinMultiWordDMA_XfrMode,5)+' ns'+
                             _fnsTransferRateMB(dwMinMultiWordDMA_XfrMode));
                  END;
          {if-then}
          IF  (dwRecMultWordDMA_XfrMode <> 0)
            THEN  BEGIN
              _OutputMessage('Recommended MultWord DMA Cycle Time... '+
                             _fnsNumToStr(dwRecMultWordDMA_XfrMode,5)+' ns'+
                             _fnsTransferRateMB(dwRecMultWordDMA_XfrMode));
                  END;
          {if-then}
          IF  (dwMinPIO_CycleTimeNoFlowCtrl <> 0)
            THEN  BEGIN
              _OutputMessage('Min.PIO Transfer Cycle Time,w/o IORDY. '+
                             _fnsNumToStr(dwMinPIO_CycleTimeNoFlowCtrl,5)+' ns'+
                             _fnsTransferRateMB(dwMinPIO_CycleTimeNoFlowCtrl));
                  END;
          {if-then}
          IF  (dwMinPIO_CycleTimeWithIORDY <> 0)
            THEN   BEGIN
              _OutputMessage('Min.PIO Transfer Cycle Time,w/IORDY... '+
                             _fnsNumToStr(dwMinPIO_CycleTimeWithIORDY,5)+' ns'+
                             _fnsTransferRateMB(dwMinPIO_CycleTimeWithIORDY));
                  END;
          {if-then}
              END;
      {if-then-else}

      _OutputMessage('-----> Calculated Parameters for This Drive <-----');
      IF  (gdbDisplayAll)
        THEN  BEGIN
      _OutputMessage('Total sectors per phys. drive (calc).. '+_fnsNumToStr(gliTotalDiskSectors,8));
              END;
      {if-then}

      rCalcTemp := dwUnfmtdBytesPerPhysTrkVU;
      rCalcTemp := (rCalcTemp * dwHeadsNum) * dwFixedCylsNum;
      _OutputMessage('Unformatted Drive Capacity (calc)..... '+
                     +_fnsDriveCapacity(rCalcTemp,System.True));
      _OutputMessage('Unformatted Drive Capacity (calc)..... '+
                     +_fnsDriveCapacity(rCalcTemp,System.False));
      rCalcTemp := dwPhysSecsPerTrk;
      rCalcTemp := ((rCalcTemp * dwHeadsNum) * dwFixedCylsNum) * aBytesPerDosSector;
      _OutputMessage('Expected DOS Drive Capacity (calc).... '+
                     +_fnsDriveCapacity(rCalcTemp,System.True));
      _OutputMessage('Expected DOS Drive Capacity (calc).... '+
                     +_fnsDriveCapacity(rCalcTemp,System.False));

       bBiosReportOk := System.False;
       IF ( gdbBIOS_Drives_Num >= _fndbPhysDisksPerSystem(gdwIDE_Disks_Count) )
         THEN  BEGIN
           dbBiosDiskOrderNum := 0;
           dwTempValue := dwDiskIncVal;           {bit-mapped flags}
           WHILE (dwTempValue <> 0) DO
           BEGIN
              dwTempValue := dwTempValue SHR 1;
              System.Inc(dbBiosDiskOrderNum);
           END;
           {while-do}
           System.Dec(dbBiosDiskOrderNum);        {0-based value}
           ASM
                    {mov     dl, dbDiskNum}
                    mov     dl, dbBiosDiskOrderNum
                    add     dl, 80h                       { hard disk services  }
                    mov     ah, 08h                       { Get Disk Parameters }
                    int     13h                           { BIOS interface      }
                    jc     @Done
                    mov    bBiosReportOk, System.True
                    mov    ax, cx
                    and    ax, 003Fh
                    mov    dwLogSectors, ax
                    mov    al, dh
                    inc    ax
                    cmp    ax, aMaxBiosHeadNum
                    jbe   @HeadsOk
                    mov    ax, aMaxBiosHeadNum
               @HeadsOk:
                    mov    dwLogHeads, ax
                    and    cx, 0FFC0h
                    rol    cl, 1
                    rol    cl, 1
                    xchg   ch, cl
                    add    cx, 2            { Now check 1024-cyls limit }
                    mov    ax, aMaxBiosCylNum
                    inc    ax
                    cmp    cx, ax
                    jbe    @CylsOk
                    mov    cx, ax
               @CylsOk:
                    mov    dwLogCylinders, cx
               @Done:
           END;
           {asm-end}
               END;
       {if-then}

      _OutputMessage('-----> Current BIOS/DOS Parameters for This Drive <-----');
      IF (bBiosReportOk)
        THEN BEGIN
       _OutputMessage('( Warning!!! BIOS parameters detection is maybe unreliable due PC nature. )');
       gdbFoundLogSectors[gdbSearchDriveIndex] := dwLogSectors;
       gdbFoundLogHeads[gdbSearchDriveIndex] := dwLogHeads;
       gdwFoundLogCylinders[gdbSearchDriveIndex] := dwLogCylinders;
      _OutputMessage('Current BIOS cylinders number ........ '+_fnsNumToStr(dwLogCylinders,5));
      _OutputMessage('Current BIOS heads number ............ '+_fnsNumToStr(dwLogHeads,3));
      _OutputMessage('Current BIOS sectors number .......... '+_fnsNumToStr(dwLogSectors,2));
      rCalcTemp := dwLogSectors;
      rCalcTemp := ((rCalcTemp * dwLogHeads) * dwLogCylinders) * aBytesPerDosSector;
      _OutputMessage('Current DOS Drive Capacity (calc)..... '+
                     +_fnsDriveCapacity(rCalcTemp,System.True));
      _OutputMessage('Current DOS Drive Capacity (calc)..... '+
                     +_fnsDriveCapacity(rCalcTemp,System.False));
             END
        ELSE BEGIN
      _OutputMessage('No found parameters for this drive now.');
             END;
      {if-then-else}
     _OutputMessage(asBlank);

   {* configuration info for drive *}
      IF  (gdbDisplayAll)
        THEN  BEGIN
     _OutputMessage(asProgramPrompt+'Screen 2 of 4 -> Internal Configuration Flags Map for Drive '+_fnsNumToStr(dbDiskNum,1));
     _OutputMessage('Configuration Flags................... '+achHexPrefix+_fnsWordToHexFmt(dwGeneralConfigFlags));
     IF ((dwGeneralConfigFlags AND btBit_1_ON) = 0)
       THEN  _OutputMessage('... Non-hard sectored (OBSOLETE)')
       ELSE  _OutputMessage('... Hard sectored (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_2_ON) = 0)
       THEN  _OutputMessage('... Non-soft sectored (OBSOLETE)')
       ELSE  _OutputMessage('... Soft sectored (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_3_ON) = 0)
       THEN  _OutputMessage('... MFM encoded (OBSOLETE)')
       ELSE  _OutputMessage('... Non-MFM encoded (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_4_ON) = 0)
       THEN  _OutputMessage('... Head switch time <= 15 us (OBSOLETE)')
       ELSE  _OutputMessage('... Head switch time > 15 us (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_5_ON) = 0)
       THEN  _OutputMessage('... Spindle motor control option not implemented (OBSOLETE)')
       ELSE  _OutputMessage('... Spindle motor control option implemented (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_6_ON) = 0)
       THEN  _OutputMessage('... Removeable controller and/or device')
       ELSE  _OutputMessage('... Non-removeable controller and/or device');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_7_ON) = 0)
       THEN  _OutputMessage('... Non-removeable media device')
       ELSE  _OutputMessage('... Removeable media device');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_8_ON) = 0)
       THEN  _OutputMessage('... Transfer rate > 5 Mb/sec (OBSOLETE)')
       ELSE  _OutputMessage('... Transfer rate <= 5 Mb/sec (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_9_ON) = 0)
       THEN  _OutputMessage('... NOT (5 Mb/sec < Transfer rate <= 10 Mb/sec) (OBSOLETE)')
       ELSE  _OutputMessage('... 5 Mb/sec < Transfer rate <= 10 Mb/sec (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_A_ON) = 0)
       THEN  _OutputMessage('... Transfer rate < 10 Mb/sec (OBSOLETE)')
       ELSE  _OutputMessage('... Transfer rate >= 10 Mb/sec (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_B_ON) = 0)
       THEN  _OutputMessage('... Rotational speed tolerance <= 0.5% (OBSOLETE)')
       ELSE  _OutputMessage('... Rotational speed tolerance > 0.5% (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_C_ON) = 0)
       THEN  _OutputMessage('... Data strobe offset option not implemented (OBSOLETE)')
       ELSE  _OutputMessage('... Data strobe offset option implemented (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_D_ON) = 0)
       THEN  _OutputMessage('... Track offset option not implemented (OBSOLETE)')
       ELSE  _OutputMessage('... Track offset option implemented (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_E_ON) = 0)
       THEN  _OutputMessage('... Format speed tolerance gap not required (OBSOLETE)')
       ELSE  _OutputMessage('... Format speed tolerance gap required (OBSOLETE)');
     {if-then-else}
     IF ((dwGeneralConfigFlags AND btBit_F_ON) = 0)
       THEN  _OutputMessage('... ATA drive')
       ELSE  _OutputMessage('... ATAPI drive');
     {if-then-else}
     _OutputMessage(asBlank);
              END;
      {if-then}

   {* suggested CMOS parameters for drive *}
     _OutputMessage(asProgramPrompt+'Screen 3 of 4 -> Suggested CMOS parameters for Drive '+_fnsNumToStr(dbDiskNum,1));
     bUserNoAskExit := System.True;
     IF (gbFindAllOk OR (dwLogSectors = 0) )
       THEN  dwCalcSectors := aMinBiosSecNum
       ELSE  dwCalcSectors := dwLogSectors{aDefStdDosBiosSecNum};
     {if-then-else}

     WHILE  (bUserNoAskExit) DO
     BEGIN
         IF  (gbMfmOk)
           THEN  BEGIN
             dwMaxCalcHeadNum := dwHeadsNum * ((dwPhysSecsPerTrk DIV dwCalcSectors) + 1) + 1;
             IF (dwMaxCalcHeadNum > aMaxBiosHeadNum)
               THEN dwMaxCalcHeadNum := aMaxBiosHeadNum;
             {if-then}
              END
           ELSE BEGIN
             dwMaxCalcHeadNum := aMaxBiosHeadNum;
                END;
         {if-then-else}
         dwCalcHeads := aStartHeadNum;
         dwCalcParmsCount := 0;

         REPEAT
           {* calculate # of cyls at fixed # of secs/heads *}

            liCalcCylinders :=  gliTotalDiskSectors DIV (System.Longint(dwCalcSectors)*dwCalcHeads);
            liCalcTotalSectors := (System.Longint(dwCalcSectors) * dwCalcHeads) * liCalcCylinders;

            {* Check for special case: 8.4G BIOS boundary *}
            IF (liCalcCylinders > aMaxBiosCylNum)
              THEN  dwTempValueCyl := liCalcCylinders - (aMaxBiosCylNum+1)
              ELSE  dwTempValueCyl := aBigMagicCyl100;
            {if-then-else}
            IF ( (dwTempValueCyl <= aBigMagicCyl10) AND
                (dwCalcHeads = aMaxBiosHeadNum)  AND
                (dwCalcSectors = aMaxBiosSecNum))
              THEN BEGIN
                 liCalcCylinders := aMaxBiosCylNum+1;
                   END;
            {if-then}

           {* check if match parameters present before output *}
            IF ((liCalcCylinders <> 0) AND
               (liCalcCylinders <= (aMaxBiosCylNum+1)) AND
               (dwCalcHeads <= aMaxBiosHeadNum)  AND
               (dwCalcSectors <= aMaxBiosSecNum))
              THEN  BEGIN
                dwCapacityRatio := (liCalcTotalSectors*aPercent100) DIV gliTotalDiskSectors;
                bDisplayEnable := System.True;
                IF ((gbFindMaxOk) AND (dwCapacityRatio <> aPercent100) AND
                     (dwTempValueCyl = aBigMagicCyl100))
                   THEN  BEGIN
                     bDisplayEnable := System.False;
                         END;
                {if-then}

                IF (bDisplayEnable)
                   THEN  BEGIN
               System.Inc(dwCalcParmsCount);
                IF (dwCalcParmsCount = 1) AND (gdbDisplayAll OR (dwLogSectors = dwCalcSectors))
                  THEN  BEGIN
                    IF  (dwLogSectors = dwCalcSectors)
                      THEN  _OutputMessage(asProgramPrompt+' ('+achAsterisk+' = current configuration of this drive)');
                    {if-then}
                    _OutputMessage(asProgramPrompt+
                                   'Find match drive parameters if number of sectors = '+
                                  _fnsNumToStr(dwCalcSectors,5));
                    _OutputMessage(' --- Cyls --- Hds --- Secs --- Calc/Actual/Percentage (total secs) ---');
                        END;
                {if-then}
              IF  (gdbDisplayAll OR (dwLogSectors = dwCalcSectors))
                THEN BEGIN
                 IF  (dwCalcHeads = dwLogHeads) AND (liCalcCylinders = dwLogCylinders)
                   THEN  _OutputMessageNoLF('  '+achAsterisk+'  ')
                   ELSE  _OutputMessageNoLF('     ');
                 {if-then-else}
             _OutputMessage(_fnsNumToStrNoAdj(liCalcCylinders,4)+
                            '     '+_fnsNumToStrNoAdj(dwCalcHeads,3)+
                            '      '+_fnsNumToStrNoAdj(dwCalcSectors,2)+
                            '       '+_fnsNumToStrNoAdj(liCalcTotalSectors,8)+
                            ' / '+_fnsNumToStr(gliTotalDiskSectors,8)+
                            ' / '+_fnsAddPrefixChars(_fnsNumToRealStr(((liCalcTotalSectors*aPercent100) /
                                                     gliTotalDiskSectors),2,2),achSpace,1,6)+
                            '    ('+
                            +_fnsNumToRealStr( (liCalcCylinders*aBytesPerDosSector/aMegaByteSI) *
                                              (System.LongInt(dwCalcSectors)*dwCalcHeads),5,2) +
                                              +' MB)');
                      END;
              {if-then}
                         END;
                {if-then}
                    END;
            {if-then}
            System.Inc(dwCalcHeads);
         UNTIL (dwCalcHeads > dwMaxCalcHeadNum);
         {repeat-until}

       {* ask user about other possible disk types based on sector/track *}
         IF (gdwMaxScreenLines <> aDisableScreenPage) AND NOT(gbFindAllOk)
           THEN  BEGIN
             _OutputMessageNoLF(asProgramPrompt+'Enter number of sectors (CR=exit): ');

             System.ReadLn(sTemp);
                 END
           ELSE
             sTemp := asBlank;
         {if-then-else}

         IF (sTemp <> asBlank)
            THEN  BEGIN
              System.Val(sTemp,dwCalcSectors,giErrorCode);
              IF (giErrorCode <> 0) OR (dwCalcSectors = 0)
                THEN  BEGIN
                   _HaltProgram(' Bad value for sectors number.',errBadSecsNum);
                     END;
              {if-then}
                 END
            ELSE  BEGIN
               bUserNoAskExit := System.False;
                  END;
         {if-then-else}

         IF (gbFindAllOk)
           THEN BEGIN
              System.Inc(dwCalcSectors);
              IF (dwCalcSectors <= aMaxBiosSecNum)
                THEN  bUserNoAskExit := System.True;
              {if-then}
                END;
         {if-then}

     END;
     {while-do}

   END;
   {with-do}

END; { _DisplayDriveParameters }


PROCEDURE  _ScanDrive(VAR  recDriveInfoBuf  :  recIDE_Info_Sector;
                      recRD_HDISK_Regs      :  recHDISK_READ_REGS;
                      recWRT_HDISK_Regs     :  recHDISK_WRITE_REGS;
                      recWR_CMD_BLOCK       :  recHDISK_WRITE_CMD_BLOCK;
                      dwDriveCtrlrBaseReg   :  System.Word;
                      dwDiskIncVal          :  System.Word;
                      dbDiskNum             :  System.Byte;
                      dbHdcIntVec           :  System.Byte;
                      dbIrqNum              :  System.Byte;
                      sCtlr                 :  STRING);
{* Test the disk drive. *}
BEGIN
   IF (gbDebugInfoOk)
     THEN  BEGIN
        _OutputDebugMessage('I/O base=$'+_fnsWordToHexFmt(dwDriveCtrlrBaseReg)+';  '+
                            'Drive=$'+_fnsByteToHexFmt(dbDiskNum)+';  '+
                            'Channel='+sCtlr);
           END;
   {if-then}

  {* try drive/controller *}
     gdbSDH_TestVal := (btCRCmode+btSecSize512);
    _InitDiskDriveRegsReadMap(grecRD_HDISK_Regs,dwDriveCtrlrBaseReg);
    _InitDiskDriveRegsWriteMap(grecWRT_HDISK_Regs,dwDriveCtrlrBaseReg);
    IF (gbEmulModeOk)
      THEN  BEGIN
         gbDiskStatusOK := System.True;
            END
      ELSE  BEGIN
         _TestDiskControllerHardware(grecRD_HDISK_Regs,
                                     grecWRT_HDISK_Regs,
                                     dbDiskNum);
            END;
    {if-then-else}

     IF (gbDiskStatusOK)
       THEN  BEGIN
           _OutputMessage(asProgramPrompt+' AT-class drive '+_fnsNumToStr(dbDiskNum,1)+' found  ('+sCtlr+' controller)');
           IF  ( NOT(gbEmulModeOk) )
             THEN  BEGIN
                _ReadDriveParameters(grecDriveInfoBuf, grecRD_HDISK_Regs,
                                     grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
                                     dbDiskNum, dbHdcIntVec, dbIrqNum);
                   END;
           {if-then}
           IF  (gbDiskStatusOK)
             THEN  BEGIN
               System.Inc(gdwIDE_Disks_Count,dwDiskIncVal);
               _DisplayDriveParameters(grecDriveInfoBuf,dbDiskNum,dwDiskIncVal);
               IF (gbFileWriteOk)
                 THEN  _WriteBufToFile(grecDriveInfoBuf);
               {if-then}
                   END
             ELSE
                _OutputMessage(asProgramPrompt+' IDENTIFY command failed.');
          {if-then-else}
             END
       ELSE
           _OutputMessage(asProgramPrompt+' No hardware for drive '+_fnsNumToStr(dbDiskNum,1)+
                          ' ('+sCtlr+' controller)');
     {if-then-else}

END; { _ScanDrive }


{*========================== USER ONLINE HELP ==========================*}

PROCEDURE  _DisplayProgramHelp;
{* Display user help. *}
CONST
  aMaxAddCharCount    =   6 + aMaxParamStrLen;
BEGIN
    _CopyrightDisplay;
   _OutputMessage(asProgramPrompt+'  Short user help screen.');
   _OutputMessage('Program information:');
   _OutputMessage('  Freeware version. None restrictions for distribution.');
   _OutputMessage('  Release date: ' + asReleaseDate + ';   Release time: ' +
                  asReleaseTime);
   _OutputMessage('Purpose:');
   _OutputMessage('     Displays miscellaneous technical information about IDE/ATA drives,');
   _OutputMessage('     also displays same information about most ESDI drives.');
   _OutputMessage('Usage:');
   _OutputMessage('     '+gsName+' [options]  , where');
   _OutputMessage('   Decimals and hexadecimals (preceded by '''+achHexPrefix+''') are recognized as numbers.');
   _OutputMessage('   Switch and parameter may be separated by either '''+achColon+''' or '''+achEqual+'''.');
   _OutputMessage('   Options may be preceded by either '''+achDosSwitch+''' or '''+achUnixSwitch+'''.');
   _OutputMessage('   Valid options (all the case-sensitive) are as follows:');
   _OutputMessage('      switch     |             meaning  (off=-,on=+)');
   _OutputMessage('   --------------+--------------------------------------------------------');
   _OutputMessage('    '+_fnsAddSpacesToMax(asScreenLines+'[num]',aMaxAddCharCount)+
            '  number of screen lines to list    (def.='+_fnsNumToStr(grecMaxScreenLinesParm.dwDefaultValue,2)+'), '+
            'max='+_fnsNumToStr(grecMaxScreenLinesParm.dwMaxValue,4)+';');
   _OutputMessage('                                                      '+
                  _fnsNumToStr(aDisableScreenPage,1)+'=no paging');
   _OutputMessage('    '+_fnsAddSpacesToMax(asFileToAsk+'[+|-]',aMaxAddCharCount)+
            '  ask filename to write raw data    (def.='+_fnsBool2Str(grecFileWriteOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asFileToRead+'[+|-]',aMaxAddCharCount)+
            '  ask filename to read raw data     (def.='+_fnsBool2Str(grecFileReadOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asFileDestName+'[str]',aMaxAddCharCount)+
            '  destination filename              (def.=none)');
   _OutputMessage('    '+_fnsAddSpacesToMax(asDelayFactor+'[num]',aMaxAddCharCount)+
            '  delay factor multiply value       (def.='+_fnsNumToStr(grecDelayFactorParm.dwDefaultValue,2)+'), '+
            'max='+_fnsNumToStr(grecDelayFactorParm.dwMaxValue,4));
   _OutputMessage('    '+_fnsAddSpacesToMax(asHddTableDisplayOnly+'[+|-]',aMaxAddCharCount)+
            '  display ROM BIOS HDD parms table  (def.='+_fnsBool2Str(grecFindCMOSOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asMaxCapacityOnly+'[+|-]',aMaxAddCharCount)+
            '  display only max.capacity found   (def.='+_fnsBool2Str(grecFindMaxOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asAllOptions+'[+|-]',aMaxAddCharCount)+
            '  try all possible drive parms      (def.='+_fnsBool2Str(grecFindAllOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asEnableHardReset+'[+|-]',aMaxAddCharCount)+
            '  reset controller before start     (def.='+_fnsBool2Str(grecSoftResetOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asEnableDebugInfo+'[+|-]',aMaxAddCharCount)+
            '  display more debug information    (def.='+_fnsBool2Str(grecDebugInfoOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asEnableTimeMeasure+'[+|-]',aMaxAddCharCount)+
            '  display time measure results      (def.='+_fnsBool2Str(grecTimeMeasureOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asDiskAccess32+'[+|-]',aMaxAddCharCount)+
            '  transfer in 32-bit access mode    (def.='+_fnsBool2Str(grecAccess32InfoOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asEnableDrive0+'[+|-]',aMaxAddCharCount)+
            '  check hardware for drive 0        (def.='+_fnsBool2Str(grecCheckDrv0_OkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asEnableDrive1+'[+|-]',aMaxAddCharCount)+
            '  check hardware for drive 1        (def.='+_fnsBool2Str(grecCheckDrv1_OkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asEnableDrive2+'[+|-]',aMaxAddCharCount)+
            '  check hardware for drive 2        (def.='+_fnsBool2Str(grecCheckDrv2_OkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asEnableDrive3+'[+|-]',aMaxAddCharCount)+
            '  check hardware for drive 3        (def.='+_fnsBool2Str(grecCheckDrv3_OkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asEnableDrive4+'[+|-]',aMaxAddCharCount)+
            '  check hardware for drive 4        (def.='+_fnsBool2Str(grecCheckDrv4_OkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asEnableDrive5+'[+|-]',aMaxAddCharCount)+
            '  check hardware for drive 5        (def.='+_fnsBool2Str(grecCheckDrv5_OkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asEnableDrive6+'[+|-]',aMaxAddCharCount)+
            '  check hardware for drive 6        (def.='+_fnsBool2Str(grecCheckDrv6_OkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asEnableDrive7+'[+|-]',aMaxAddCharCount)+
            '  check hardware for drive 7        (def.='+_fnsBool2Str(grecCheckDrv7_OkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUseIntCtlr0+'[+|-]',aMaxAddCharCount)+
            '  use interrupt for controller 0    (def.=$'+_fnsByteToHexFmt(grecUseIntHdc0_OkParm.dbDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUseIntCtlr1+'[+|-]',aMaxAddCharCount)+
            '  use interrupt for controller 1    (def.=$'+_fnsByteToHexFmt(grecUseIntHdc1_OkParm.dbDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUseIntCtlr2+'[+|-]',aMaxAddCharCount)+
            '  use interrupt for controller 2    (def.=$'+_fnsByteToHexFmt(grecUseIntHdc2_OkParm.dbDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUseIntCtlr3+'[+|-]',aMaxAddCharCount)+
            '  use interrupt for controller 3    (def.=$'+_fnsByteToHexFmt(grecUseIntHdc3_OkParm.dbDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUseIntCtlrU+'[+|-]',aMaxAddCharCount)+
            '  use interrupt user-defined ctlr.  (def.=$'+_fnsByteToHexFmt(grecUseIntHdcU_OkParm.dbDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUseIrqCtlr0+'[+|-]',aMaxAddCharCount)+
            '  use IRQ for primary controller    (def.=$'+_fnsByteToHexFmt(grecUseIrqHdc0_OkParm.dbDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUseIrqCtlr1+'[+|-]',aMaxAddCharCount)+
            '  use IRQ for secondary controller  (def.=$'+_fnsByteToHexFmt(grecUseIrqHdc1_OkParm.dbDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUseIrqCtlr2+'[+|-]',aMaxAddCharCount)+
            '  use IRQ for tertiary controller   (def.=$'+_fnsByteToHexFmt(grecUseIrqHdc2_OkParm.dbDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUseIrqCtlr3+'[+|-]',aMaxAddCharCount)+
            '  use IRQ for quaternary controller (def.=$'+_fnsByteToHexFmt(grecUseIrqHdc3_OkParm.dbDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUseIrqCtlrU+'[+|-]',aMaxAddCharCount)+
            '  use IRQ for user-defined ctlr.    (def.=$'+_fnsByteToHexFmt(grecUseIrqHdcU_OkParm.dbDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asDviOutput+'[+|-]',aMaxAddCharCount)+
            '  display vital information only    (def.='+_fnsBool2Str(grecDviOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asMfmStyle+'[+|-]',aMaxAddCharCount)+
            '  old MFM heads algorithm in use    (def.='+_fnsBool2Str(grecMfmOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asTrionesDrvr+'[+|-]',aMaxAddCharCount)+
            '  run Triones EIDE workaround code  (def.='+_fnsBool2Str(grecTrionesOkParm.bDefaultValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUserBaseReg+'[num]',aMaxAddCharCount)+
            '  user defined I/O base address     (range=$'+_fnsWordToHexFmt(grecUserBaseIoRegParm.dwMinValue)+
            '..$'+_fnsWordToHexFmt(grecUserBaseIoRegParm.dwMaxValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asUserStatusReg+'[num]',aMaxAddCharCount)+
            '  user defined I/O ctrl/status addr (range=$'+_fnsWordToHexFmt(grecUserStatusRegParm.dwMinValue)+
            '..$'+_fnsWordToHexFmt(grecUserStatusRegParm.dwMaxValue)+')');
   _OutputMessage('    '+_fnsAddSpacesToMax(asHelpOnScreen+','+asAltHelpOnScreen,aMaxAddCharCount)+
            '  this short help screen            (def.='+asDefaultOFF+')');
   _OutputMessage('   --------------+--------------------------------------------------------');
   _OutputMessage('    Short example 1:   '+gsName+'  '+
                  achDosSwitch+asMaxCapacityOnly+achPlus+' '+
                  achDosSwitch+asAllOptions+achPlus+' '+
                  achUnixSwitch+asEnableHardReset+achColon+achMinus+' '+
                  achDosSwitch+asScreenLines+achEqual+'43');
   _OutputMessage('    Short example 2:   '+gsName+'  '+
                  achUnixSwitch+asUserBaseReg+achColon+'$168'+' '+
                  achDosSwitch+asUserStatusReg+achEqual+'$36E'+' '+
                  achUnixSwitch+asUseIntCtlrU+achEqual+'$74');
   _OutputMessage('    Short example 3:   '+gsName+'  '+
                  achUnixSwitch+asFileToRead+achPlus+' '+
                  achUnixSwitch+asFileDestName+achColon+'wd3160');
   _OutputMessage('    Note 1:   1 MegaByte = 1,000,000 bytes or 10^6 bytes');
   _OutputMessage('    Note 2:   OBSOLETE (OBS) word means not used in newer drives.');
   _OutputMessage('    Note 3:   Drives 0 and 1 are checked on primary controller,');
   _OutputMessage('              drives 2 and 3 are checked on secondary controller,');
   _OutputMessage('              drives 4 and 5 are checked on tertiary controller,');
   _OutputMessage('              drives 6 and 7 are checked on quaternary controller.');
   _HaltProgram('  Help output done.',errUserHelp);
END;  { _DisplayProgramHelp }


{*============== COMMAND LINE PARAMETERS PROCESSING ====================*}

PROCEDURE  _ScanProgramParameterLine(dwNumOfAvailParms : System.Word);
{* General-purpose scan routine. *}
VAR
  dwNumOfParams   :    System.Word;
  dwParamIndex    :    System.Word;
  dwTempIndex     :    System.Word;
  bParmFound      :    System.Boolean;
  dbStrPos        :    System.Byte;
  sTemp           :    STRING;
  sOption         :    STRING;

FUNCTION  _fnbIsSwitchPresent(sParam : STRING) : System.Boolean;
{* Simple check to string with switch. *}
VAR
   bResult  :  System.Boolean;
BEGIN
  bResult := System.False;
  IF (sParam <> asBlank)
    THEN BEGIN
      IF  ((sParam[1] = achDosSwitch) OR (sParam[1] = achUnixSwitch))
        THEN  bResult := System.True;
      {if-then}
         END;
  {if-then}
  _fnbIsSwitchPresent := bResult;
END;  { _fnbIsSwitchPresent }

FUNCTION  _fndbSkipDelimiterInParamStrPresent(sParam : STRING;
                               dbValueIndex : System.Byte) : System.Byte;
{* Detect and skip a delimiter in parameter string. *}
VAR
  chTemp        :   System.Char;
  dbSkipCount   :   System.Byte;
BEGIN
  IF (dbValueIndex <> 0)
    THEN  chTemp := sParam[dbValueIndex]
    ELSE  chTemp := achNull;
  {if-then-else}
  CASE  (chTemp)  OF
      achColon, achEqual : dbSkipCount := 1;
  ELSE
     dbSkipCount := 0;
  END;
  {case-of}
  _fndbSkipDelimiterInParamStrPresent := dbSkipCount;
END; { _fndbSkipDelimiterInParamStrPresent }

PROCEDURE  _GetBooleanParam(sParamTemp : STRING;
                            dwTableIndex : System.Word;
                            dbPosOfValue : System.Byte);
{* Do a boolean parameter. *}
VAR
  recBooleanParamValues :  recBooleanParameter;
  pTemp                 :  System.Pointer;
  bNewValue             :  System.Boolean;
  chTemp                :  System.Char;

BEGIN
   chTemp := sParamTemp[dbPosOfValue];
   CASE  (chTemp)  OF
       achPlus  : bNewValue := System.True;
       achMinus : bNewValue := System.False;
   ELSE
     _HaltProgram(' Bad boolean parameter found in string <'+sParamTemp+'>.',errBadBooleanParam);
   END;
   {case-of}
   pTemp := gachProgramOptions[dwTableIndex].lpParamDesc;
   System.Move(System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)],
               recBooleanParamValues,
               System.SizeOf(recBooleanParameter));
   pTemp := recBooleanParamValues.lpVarAddr;
   System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)] := System.Byte(bNewValue);
END;  { _GetBooleanParam }

PROCEDURE  _GetWordParam(sParamTemp : STRING;
                         dwTableIndex : System.Word;
                         dbPosOfValue : System.Byte);
{* Do a word parameter. *}
VAR
  recWordParamValues    :  recWordParameter;
  pTemp                 :  System.Pointer;
  dwNewValue            :  System.Word;
  iErrorCode            :  System.Integer;
  sNumTemp              :  STRING;

BEGIN
   sNumTemp := System.Copy(sParamTemp,dbPosOfValue,(System.Length(sParamTemp)-dbPosOfValue+1));
   dwNewValue := _fndwGetValue(iErrorCode,sNumTemp);
   IF  (iErrorCode <> errOK)
     THEN  _HaltProgram(' Bad word parameter found in string <'+sParamTemp+'>.',errBadWordParam);
   {if-then}
   pTemp := gachProgramOptions[dwTableIndex].lpParamDesc;
   System.Move(System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)],
               recWordParamValues,
               System.SizeOf(recWordParameter));
   WITH  (recWordParamValues)  DO
   BEGIN
      IF (dwMinValue <= dwNewValue) AND (dwNewValue <= dwMaxValue)
        THEN  pTemp := lpVarAddr
        ELSE  _HaltProgram(' Bad range for word parameter found in string <'+sParamTemp+'>.',errBadWordParamRange);
      {if-then-else}
   END;
   {with-do}
   System.MemW[System.Seg(pTemp^):System.Ofs(pTemp^)] := dwNewValue;
END;  { _GetWordParam }

PROCEDURE  _GetByteParam(sParamTemp : STRING;
                         dwTableIndex : System.Word;
                         dbPosOfValue : System.Byte);
{* Do a byte parameter. *}
VAR
  recByteParamValues    :  recByteParameter;
  pTemp                 :  System.Pointer;
  dbNewValue            :  System.Byte;
  iErrorCode            :  System.Integer;
  sNumTemp              :  STRING;

BEGIN
   sNumTemp := System.Copy(sParamTemp,dbPosOfValue,(System.Length(sParamTemp)-dbPosOfValue+1));
   dbNewValue := System.Lo(_fndwGetValue(iErrorCode,sNumTemp));
   IF  (iErrorCode <> errOK)
     THEN  _HaltProgram(' Bad byte parameter found in string <'+sParamTemp+'>.',errBadByteParam);
   {if-then}
   pTemp := gachProgramOptions[dwTableIndex].lpParamDesc;
   System.Move(System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)],
               recByteParamValues,
               System.SizeOf(recByteParameter));
   WITH  (recByteParamValues)  DO
   BEGIN
      IF (dbMinValue <= dbNewValue) AND (dbNewValue <= dbMaxValue)
        THEN  pTemp := lpVarAddr
        ELSE  _HaltProgram(' Bad range for byte parameter found in string <'+sParamTemp+'>.',errBadByteParamRange);
      {if-then-else}
   END;
   {with-do}
   System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)] := dbNewValue;
END;  { _GetByteParam }

PROCEDURE  _GetPascalStrParameter(sParamTemp : STRING;
                                  dwTableIndex : System.Word;
                                  dbPosOfValue : System.Byte);
{* Do a Pascal string parameter. *}
VAR
  recPasStrParamValues    :  recPascalStrParameter;
  pTemp                   :  System.Pointer;
  iErrorCode              :  System.Integer;
  sTempPas                :  STRING;

BEGIN
   sTempPas := System.Copy(sParamTemp,dbPosOfValue,(System.Length(sParamTemp)-dbPosOfValue+1));
   IF  (sTempPas = asBlank)
     THEN  _HaltProgram(' Bad string parameter found in string <'+sParamTemp+'>.',errBadPasStrParam);
   {if-then}
   pTemp := gachProgramOptions[dwTableIndex].lpParamDesc;
   System.Move(System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)],
               recPasStrParamValues,
               System.SizeOf(recPascalStrParameter));
   WITH  (recPasStrParamValues)  DO
   BEGIN
      IF (System.Length(sTempPas) <= dwMaxStrLen)
        THEN  pTemp := lpVarAddr
        ELSE  _HaltProgram(' Too large string for parameter found in string <'+sParamTemp+'>.',errBadPasStrParamRange);
      {if-then-else}
   END;
   {with-do}
   System.Move(sTempPas[0],
               System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)],
               (System.Length(sTempPas)+1));
END;  { _GetPascalStrParameter }

BEGIN
   dwNumOfParams := System.ParamCount;
   IF (dwNumOfParams <> 0)
     THEN   BEGIN
        FOR  dwParamIndex := 1  TO  dwNumOfParams  DO
        BEGIN
             sTemp := System.ParamStr(dwParamIndex);
             IF  NOT(_fnbIsSwitchPresent(sTemp))
               THEN  BEGIN
                 _HaltProgram(' No switch found in string <'+sTemp+'>.',errNoPrefixSwitch);
                     END;
             {if-then}
             bParmFound := System.False;
             dwTempIndex := 1;
             WHILE  NOT(bParmFound) AND (dwTempIndex <= dwNumOfAvailParms)  DO
             BEGIN
                 sOption := Strings.StrPas(gachProgramOptions[dwTempIndex].sParamName);
                 dbStrPos := System.Pos(sOption,sTemp);
                 IF  (dbStrPos = 2)
                   THEN  BEGIN
                      bParmFound := System.True;
                      System.Inc(dbStrPos,System.Length(sOption));
                      System.Inc(dbStrPos,_fndbSkipDelimiterInParamStrPresent(sTemp,dbStrPos));
                      CASE  (gachProgramOptions[dwTempIndex].dwParamType)  OF
                           aParmIsIndefinite  : BEGIN
                                                  gdbUserHelpRequest := System.True;
                                                END;
                           aParmIsPascalStr   : BEGIN
                               _GetPascalStrParameter(sTemp,dwTempIndex,dbStrPos);
                                                END;
                           aParmIsBoolean     : BEGIN
                               _GetBooleanParam(sTemp,dwTempIndex,dbStrPos);
                                                END;
                           aParmIsByte        : BEGIN
                               _GetByteParam(sTemp,dwTempIndex,dbStrPos);
                                                END;
                           aParmIsWord        : BEGIN
                               _GetWordParam(sTemp,dwTempIndex,dbStrPos);
                                                END;
                      ELSE
                           {* reserved *}
                      END;
                      {case-of}
                         END
                   ELSE  BEGIN
                           System.Inc(dwTempIndex);
                         END;
                 {if-then-else}
             END;
             {while-do}
             IF  NOT(bParmFound)
               THEN  BEGIN
                 _HaltProgram(' Unsupported switch found in string <'+sTemp+'>.',errUnsupportedSwitch);
                     END;
             {if-then}
        END;
        {for-to-do}
            END;
   {if-then}
END;  { _ScanProgramParameterLine }


PROCEDURE  _SetupProgramDefaultsAfterUserParametersParsing;
{* Setup all need parameters. *}
BEGIN
  {* init some variables *}
   IF  (gbDviOk)
     THEN  BEGIN
       gdbDisplayAll :=  System.False;
       gbFindAllOk := System.True;
       gbFindMaxOk := System.True;
       gdwMaxScreenLines := aDisableScreenPage;
           END;
   {if-then}

     IF (gdwMaxScreenLines = aDisableScreenPage)
        THEN  gdwTextLineNum := aDisableScreenPage;
     {if-then}

  {* display it for some active users *}
     IF (gdbUserHelpRequest)
       THEN  _DisplayProgramHelp;
     {if-then}

END;  { _SetupProgramDefaultsAfterUserParametersParsing }


{*============================== MAIN PART =============================*}

BEGIN
  {* get the true program name *}
     gsPath := System.ParamStr(0);
     Dos.FSplit(gsPath,gsDir,gsName,gsExtension);


  {* simple test for CPU type *}
    asm
          push    sp
          pop     ax

          cmp     ax, sp
          je      @CPU186

          mov     giErrorCode, -1
       @CPU186:
    end;
    {asm-end}
    IF (giErrorCode <> 0)
          THEN  BEGIN
             _HaltProgram(' Requires Intel 80186 processor or higher.',errBadCPU);
          END;
    {if-then}


  {* process a command line *}
  _ScanProgramParameterLine(aNumOfCmdParms);
  _SetupProgramDefaultsAfterUserParametersParsing;


  {* setup some variables *}
    gdwIDE_Disks_Count := 0;
    gdwAlternateStatus    := aAltDriveStatusReg_0;


   {* copyright message *}
    _CopyrightDisplay;

  {* another test for CPU *}
   gbCPUis386 := _fnbCpuIs386;

  {* display CPU info *}
   IF (gbDebugInfoOk)
     THEN  BEGIN
       IF  (gbCPUis386)
         THEN  _OutputDebugMessage('386+ processor found.')
         ELSE  _OutputDebugMessage('386- processor found.');
       {if-then-else}
           END;
   {if-then}


  {* Avoid unnecessary work in emulation mode! *}
  IF  (gbEmulModeOk)
    THEN BEGIN
      {gbFindCMOSOk     := System.False;}
      gbTrionesOk      := System.False;
      gbSoftResetOk    := System.False;
      gbCheckDrive0_Ok := System.False;
      gbCheckDrive1_Ok := System.False;
      gbCheckDrive2_Ok := System.False;
      gbCheckDrive3_Ok := System.False;
      gbCheckDrive4_Ok := System.False;
      gbCheckDrive5_Ok := System.False;
      gbCheckDrive6_Ok := System.False;
      gbCheckDrive7_Ok := System.False;

      gdwUserStatusReg   := aAltDriveStatusReg_0;
      gdwUserBaseIoReg   := aDriveCtrlrBaseReg_0;
      gdwAlternateStatus := gdwUserStatusReg;

      _ReadFileToBuf(grecDriveInfoBuf);
      _ScanDrive(grecDriveInfoBuf,
               grecRD_HDISK_Regs,
               grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
               gdwUserBaseIoReg,
               btIdeDrive_08,
               aPhysDriveNum_0,
               gdbUseIntHdcU_Ok,
               gdbUseIrqHdcU_Ok,
               asUserDefined);
      System.Inc(gdbSearchDriveIndex);

      gdwUserStatusReg   := $0;
      gdwUserBaseIoReg   := $0;
         END;
  {if-then}


  {* Special workaround code for MS-DOS Triones EIDE drivers v3.22!!!  *}
  {* Problem: if any IDE identification program including IDE-ATA is   *}
  {* running from primary/slave drive then Triones code disable access *}
  {* to primary controller at all. Very strange solution! To fix this  *}
  {* problem it was added a BIOS call to physical drive 0.             *}
  IF  (gbTrionesOk)
    THEN  BEGIN
      ASM
            push   es                       {ES:BX -> user buffer}
            mov    bx, SEG grecDriveInfoBuf
            mov    es, bx
            mov    bx, OFFSET grecDriveInfoBuf
            mov    ax, 0201h                {Read one sector}
            mov    cx, 0001h                {Cylinder 0, sector 1}
            mov    dx, 0080h                {Head 0, hard drive 0}
            int    13h                      {Direct BIOS interface}
            pop    es
      END;
      {asm-end}
          END;
  {if-then}


  {* enable/disable the controller operations *}
    IF (gbSoftResetOk AND (gbCheckDrive0_Ok OR gbCheckDrive1_Ok))
      THEN  BEGIN
        _HardResetController(gdwAlternateStatus,asPrimary);
            END;
    {if-then}

  {* try drive 0 hardware/primary controller *}
  IF (gbCheckDrive0_Ok)
    THEN  BEGIN
       _ScanDrive(grecDriveInfoBuf,
                  grecRD_HDISK_Regs,
                  grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
                  aDriveCtrlrBaseReg_0,
                  btIdeDrive_00,
                  aPhysDriveNum_0,
                  gdbUseIntHdc0_Ok,
                  gdbUseIrqHdc0_Ok,
                  asPrimary);
          END;
  {if-then}
  System.Inc(gdbSearchDriveIndex);

  {* try drive 1 hardware/primary controller *}
  IF (gbCheckDrive1_Ok)
    THEN  BEGIN
       _ScanDrive(grecDriveInfoBuf,
                  grecRD_HDISK_Regs,
                  grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
                  aDriveCtrlrBaseReg_1,
                  btIdeDrive_01,
                  aPhysDriveNum_1,
                  gdbUseIntHdc0_Ok,
                  gdbUseIrqHdc0_Ok,
                  asPrimary);
          END;
  {if-then}
  System.Inc(gdbSearchDriveIndex);


  {* init some vars *}
    gdwAlternateStatus := aAltDriveStatusReg_1;

  {* enable/disable the controller operations *}
    IF (gbSoftResetOk AND (gbCheckDrive2_Ok OR gbCheckDrive3_Ok) )
      THEN  BEGIN
        _HardResetController(gdwAlternateStatus,asSecondary);
            END;
    {if-then}


  {* try drive 0 hardware/secondary controller *}
  IF (gbCheckDrive2_Ok)
    THEN  BEGIN
        _ScanDrive(grecDriveInfoBuf,
                 grecRD_HDISK_Regs,
                 grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
                 aDriveCtrlrBaseReg_2,
                 btIdeDrive_02,
                 aPhysDriveNum_0,
                 gdbUseIntHdc1_Ok,
                 gdbUseIrqHdc1_Ok,
                 asSecondary);
          END;
  {if-then}
  System.Inc(gdbSearchDriveIndex);

  {* try drive 1 hardware/secondary controller *}
  IF (gbCheckDrive3_Ok)
    THEN  BEGIN
        _ScanDrive(grecDriveInfoBuf,
                 grecRD_HDISK_Regs,
                 grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
                 aDriveCtrlrBaseReg_3,
                 btIdeDrive_03,
                 aPhysDriveNum_1,
                 gdbUseIntHdc1_Ok,
                 gdbUseIrqHdc1_Ok,
                 asSecondary);
          END;
  {if-then}
  System.Inc(gdbSearchDriveIndex);


  {* init some vars *}
    gdwAlternateStatus := aAltDriveStatusReg_2;

  {* enable/disable the controller operations *}
    IF (gbSoftResetOk AND (gbCheckDrive4_Ok OR gbCheckDrive5_Ok) )
      THEN  BEGIN
        _HardResetController(gdwAlternateStatus,asTertiary);
            END;
    {if-then}

  {* try drive 0 hardware/tertiary controller *}
  IF (gbCheckDrive4_Ok)
    THEN  BEGIN
        _ScanDrive(grecDriveInfoBuf,
                 grecRD_HDISK_Regs,
                 grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
                 aDriveCtrlrBaseReg_4,
                 btIdeDrive_04,
                 aPhysDriveNum_0,
                 gdbUseIntHdc2_Ok,
                 gdbUseIrqHdc2_Ok,
                 asTertiary);
          END;
  {if-then}
  System.Inc(gdbSearchDriveIndex);

  {* try drive 1 hardware/tertiary controller *}
  IF (gbCheckDrive5_Ok)
    THEN  BEGIN
        _ScanDrive(grecDriveInfoBuf,
                 grecRD_HDISK_Regs,
                 grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
                 aDriveCtrlrBaseReg_5,
                 btIdeDrive_05,
                 aPhysDriveNum_1,
                 gdbUseIntHdc2_Ok,
                 gdbUseIntHdc2_Ok,
                 asTertiary);
          END;
  {if-then}
  System.Inc(gdbSearchDriveIndex);


  {* init some vars *}
    gdwAlternateStatus := aAltDriveStatusReg_3;

  {* enable/disable the controller operations *}
    IF (gbSoftResetOk AND (gbCheckDrive6_Ok OR gbCheckDrive7_Ok) )
      THEN  BEGIN
        _HardResetController(gdwAlternateStatus,asQuaternary);
            END;
    {if-then}

  {* try drive 0 hardware/quaternary controller *}
  IF (gbCheckDrive6_Ok)
    THEN  BEGIN
        _ScanDrive(grecDriveInfoBuf,
                 grecRD_HDISK_Regs,
                 grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
                 aDriveCtrlrBaseReg_6,
                 btIdeDrive_06,
                 aPhysDriveNum_0,
                 gdbUseIntHdc3_Ok,
                 gdbUseIrqHdc3_Ok,
                 asQuaternary);
          END;
  {if-then}
  System.Inc(gdbSearchDriveIndex);

  {* try drive 1 hardware/quaternary controller *}
  IF (gbCheckDrive7_Ok)
    THEN  BEGIN
        _ScanDrive(grecDriveInfoBuf,
                 grecRD_HDISK_Regs,
                 grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
                 aDriveCtrlrBaseReg_7,
                 btIdeDrive_07,
                 aPhysDriveNum_1,
                 gdbUseIntHdc3_Ok,
                 gdbUseIrqHdc3_Ok,
                 asQuaternary);
          END;
  {if-then}
  System.Inc(gdbSearchDriveIndex);


  {* try user defined ports *}
  IF  ((gdwUserBaseIoReg <> 0) AND (gdwUserStatusReg <> 0))
    THEN  BEGIN
       {init some vars}
        gdwAlternateStatus := gdwUserStatusReg;

        {enable/disable the controller operations}
        IF  (gbSoftResetOk)
          THEN  BEGIN
            _HardResetController(gdwAlternateStatus,asUserDefined);
                END;
        {if-then}

        _ScanDrive(grecDriveInfoBuf,
                 grecRD_HDISK_Regs,
                 grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
                 gdwUserBaseIoReg,
                 btIdeDrive_08,
                 aPhysDriveNum_0,
                 gdbUseIntHdcU_Ok,
                 gdbUseIrqHdcU_Ok,
                 asUserDefined);
        System.Inc(gdbSearchDriveIndex);

        _ScanDrive(grecDriveInfoBuf,
                 grecRD_HDISK_Regs,
                 grecWRT_HDISK_Regs, grecWR_CMD_BLOCK,
                 gdwUserBaseIoReg,
                 btIdeDrive_09,
                 aPhysDriveNum_1,
                 gdbUseIntHdcU_Ok,
                 gdbUseIrqHdcU_Ok,
                 asUserDefined);
          END;
  {if-then}

  {* display ROM CMOS HDD types table *}
     IF  (NOT(gbFindCMOSOk) AND
          NOT(gbFindAllOk)  AND
          (gdwMaxScreenLines <> aDisableScreenPage))
       THEN BEGIN
         _OutputMessage(asBlank);
         _OutputMessageNoLF(asProgramPrompt+'Display ROM BIOS HDD types table? (N/Y): ');
         System.ReadLn(gsTemp);
        _OutputMessage(asBlank);
         IF (System.Upcase(_fnchGetFirstChar(gsTemp)) = aYes)
            THEN  gbFindCMOSOk := System.True;
         {if-then}
            END;
     {if-then}

     IF (gbFindCMOSOk)
       THEN BEGIN
         _OutputMessage(asBlank);
         _OutputMessage(asProgramPrompt+'Screen 4 of 4 -> ROM BIOS HDD types table for CMOS drive types');
        _OutputMessage(asProgramPrompt+' ('+achAsterisk+' = current configuration of this drive)');
        _OutputMessage(' -- Type -- Cyls -- Hds -- WRC -- Secs -- Cntrl -- LZone -- TotalSecs -- MB --');
         FOR  gdwIndex := aMinHDD_CMOSType  TO  aMaxHDD_CMOSType  DO
          WITH  (recHARD_DISK_PARMS(gdbROM_BIOS_HDD_TYPES_TABLE[gdwIndex]))  DO
           BEGIN
               gdwTempCyls := dwMAX_CYLS_NUM;
               gdbTempHeads := dbMAX_HEADS_NUM;
               gdbTempSecs := dbSECTORS_PER_TRACK;
               gliTotalDiskSectors := System.Longint(dbSECTORS_PER_TRACK) * dbMAX_HEADS_NUM * dwMAX_CYLS_NUM;
               gdbTempPos := aFirstDrive;
               gbParmFound := System.False;
               REPEAT
                  IF  (gdbTempSecs <> 0)  AND
                      (gdbTempSecs = gdbFoundLogSectors[gdbTempPos]) AND
                      (gdbTempHeads = gdbFoundLogHeads[gdbTempPos]) AND
                      (gdwTempCyls = gdbFoundLogSectors[gdbTempPos])
                    THEN  gbParmFound := System.True
                    ELSE  System.Inc(gdbTempPos);
                  {if-then-else}
               UNTIL (gbParmFound) OR (gdbTempPos > aTenthDrive);
                 IF  (gbParmFound)
                   THEN  _OutputMessageNoLF('  '+achAsterisk+'  ')
                   ELSE  _OutputMessageNoLF('     ');
                 {if-then-else}
               _OutputMessage(_fnsNumToStrNoAdj(gdwIndex,2)+
                              '    '+_fnsNumToStrNoAdj(gdwTempCyls,4)+
                              '    '+_fnsNumToStrNoAdj(gdbTempHeads,3)+
                              '    '+_fnsNumToStrNoAdj(dwSTART_WRC,5)+
                              '    '+_fnsNumToStrNoAdj(gdbTempSecs,2)+
                              '     '+_fnsNumToStrNoAdj(dbCONTROL_BYTE,3)+
                              '      '+_fnsNumToStrNoAdj(dwLANDING_ZONE,4)+
                              '    '+_fnsNumToStrNoAdj(gliTotalDiskSectors,8)+
                              '    '+_fnsNumToRealStr(((gliTotalDiskSectors*aBytesPerDosSector) /
                                                       aMegaByteSI),5,2));
            END;
           {with-do}
          {for-to-do}
         _OutputMessage(asBlank);
            END;
     {if-then}

  {* find the number of hard disk drives reported by SYSTEM BIOS *}
    _OutputMessage(asProgramPrompt+' '+_fnsNumToStr(gdbBIOS_Drives_Num,1)+
                   ' hard disk drive(s) found by the System BIOS.');

  {** last report **}
    _OutputMessage(asProgramPrompt+' '+
                  _fnsNumToStr(_fndbPhysDisksPerSystem(gdwIDE_Disks_Count),1)+
                   ' IDE/ATA-drive(s) found for this computer system.');
    _MoreHelpMessageDisplay;
    _OutputMessage(asProgramPrompt+'Done.');

  {* Write a true value for Sector/Drive/Head: must be reset a micro-code logic to defaults. *}
   IF  ((gdwIDE_Disks_Count AND (btIdeDrive_06 OR btIdeDrive_07)) <> 0)
      THEN  System.Port[aDriveCtrlrBaseReg_6+$06] := (btCRCmode+btSecSize512);
   {if-then}
   IF  ((gdwIDE_Disks_Count AND (btIdeDrive_04 OR btIdeDrive_05)) <> 0)
      THEN  System.Port[aDriveCtrlrBaseReg_4+$06] := (btCRCmode+btSecSize512);
   {if-then}
   IF  ((gdwIDE_Disks_Count AND (btIdeDrive_02 OR btIdeDrive_03)) <> 0)
      THEN  System.Port[aDriveCtrlrBaseReg_2+$06] := (btCRCmode+btSecSize512);
   {if-then}
   IF  ((gdwIDE_Disks_Count AND (btIdeDrive_00 OR btIdeDrive_01)) <> 0)
      THEN  System.Port[aDriveCtrlrBaseReg_0+$06] := (btCRCmode+btSecSize512);
   {if-then}

END.
