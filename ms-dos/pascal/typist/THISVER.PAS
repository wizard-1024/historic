{****************************************************************************
//                            File THISVER.PAS
//
//                      Program information module
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/thisver.pas $
//  $RCSfile: thisver.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:57:26 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: thisver.pas $
//      Revision 1.1  1999/01/03 17:57:26  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             THISVER.PAS                                     }
{ PURPOSE               Information about version of compiled program   }
{ VERSION               0.01                                            }
{ DATE                  13-Sep-94                                       }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Tel. 007 (095) 944-6304                         }
{ COPYRIGHT NOTICE      Copyright (C) 1987-1994, Dmitry Stefankov       }
{ RESTRICTED RIGHTS     FOR INTERNAL USE ONLY.                          }
{                       THIS FILE CONTAINS PROPRIETARY AND CONFIDENTIAL }
{                       INFORMATION. COPYING AND REPRODUCTION WITHOUT   }
{                       PRIOR WRITTEN PERMISSION IS PROHIBITED.         }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 7.0                        }
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             None                                            }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       GLOBALS.TPU    (global public definitions)      }
{                       MESSAGES.TPU   (text user messages)             }
{                       VIDEO.TPU      (user screen interface)          }
{                       Project Maintence Files                         }
{                       TYPIST.MAK        (auto compiling & linking)    }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       0.01   13-Sep-94  DS  initial release           }
{-----------------------------------------------------------------------}



UNIT
    ThisVer;


INTERFACE

USES
    Globals,
    Messages,
    Video;


PROCEDURE   _DisplayMoreInfoAboutThisVersion;


IMPLEMENTATION



PROCEDURE
         _DisplayMoreInfoAboutThisVersion;
{*
Description.
   Outputs internal diagnostic message about this version of
   compiled program.
*}
BEGIN
   Video._OutputMessage(Messages._fnsTextMessageByIndex(339),
                        System.True);
   IF  (Globals.gsSerialNumber <> Globals.asBlank)
     THEN  BEGIN
       Video._OutputMessage(Messages._fnsTextMessageByIndex(436)+
                            Globals.gsCountryCode+
                            '-'+
                            Globals.gsUserCode,
                            System.True);
           END
     ELSE  BEGIN
       Video._OutputMessage(Messages._fnsTextMessageByIndex(436)+
                            Messages._fnsTextMessageByIndex(437),
                            System.True);
           END;
   {if-them-else}
   Video._OutputMessage(Messages._fnsTextMessageByIndex(352)+
                        StrLib._fnsNumToStr(Globals.gdbCurExternalRelease,3),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(353)+
                        StrLib._fnsNumToStr(Globals.gdbCurExternalVersion,3),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(354)+
                        StrLib._fnsNumToStr(Globals.gdbCurExternalRevision,3),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(342)+
                        StrLib._fnsBooleanStateOfVarDesc(Globals.gbCommercialVerOk),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(343)+
                        StrLib._fnsBooleanStateOfVarDesc(Globals.gbEvaluationVerOk),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(344)+
                        StrLib._fnsBooleanStateOfVarDesc(Globals.gbEnglishVerOk),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(345)+
                        StrLib._fnsBooleanStateOfVarDesc(Globals.gbRussianVerOk),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(346)+
                        StrLib._fnsBooleanStateOfVarDesc(Globals.gbDebugVerOk),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(445)+
                        StrLib._fnsBooleanStateOfVarDesc(Globals.gbTestVerOk),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(453)+
                        StrLib._fnsBooleanStateOfVarDesc(Globals.gbDemoVerOk),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(506)+
                        StrLib._fnsBooleanStateOfVarDesc(Globals.gbStatVerOk),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(347)+
                        StrLib._fnsBooleanStateOfVarDesc(Globals.gbAddSpace8K_Ok),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(348)+
                        StrLib._fnsBooleanStateOfVarDesc(Globals.gbAddSpace16K_Ok),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(442)+
                        StrLib._fnsNumToStr(Globals.aEnviron_Avail_Max,2),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(440)+
                        StrLib._fnsNumToStr(Globals.aWords_For_Dict_Max,5),
                        System.True);
   Video._OutputMessage(Messages._fnsTextMessageByIndex(441)+
                        StrLib._fnsNumToStr(Globals.aReserveMemoryMax,5)+
                        Messages._fnsTextMessageByIndex(254),
                        System.True);
{$IFDEF   StaVer}
   Video._OutputMessage(Messages._fnsTextMessageByIndex(510)+
                        StrLib._fnsNumToStr(Globals.aStatMinutesMax,5)+
                        Messages._fnsTextMessageByIndex(511),
                        System.True);
{$ENDIF} {StaVer}
END;
{ _DisplayMoreInfoAboutThisVersion }



{BEGIN}
END.
