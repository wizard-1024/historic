{****************************************************************************
//                            File VIDEO.PAS
//
//                      User screen interface library
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/video.pas $
//  $RCSfile: video.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:58:36 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: video.pas $
//      Revision 1.1  1999/01/03 17:58:36  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             VIDEO.PAS                                       }
{ PURPOSE               User screen interface                           }
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
{                       STRLIB.TPU     (string support library)         }
{                       Project Maintence Files                         }
{                       TYPIST.MAK        (auto compiling & linking)    }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       0.01   13-Sep-94  DS  initial release           }
{-----------------------------------------------------------------------}



UNIT
     Video;


INTERFACE

USES
    Globals,
    Messages,
    StrLib;


FUNCTION     _fnsUserNeedMoreHelp : STRING;
PROCEDURE    _HaltProgram(sHaltMessage : STRING;
                          dbHaltCode : System.Byte);
PROCEDURE    _OutputMessageNoLF(sMessage : STRING;
                                bAddPrompt : System.Boolean);
PROCEDURE    _OutputMessage(sMessage : STRING;
                            bAddPrompt : System.Boolean);
PROCEDURE    _OutputDebugMessage(sMessage : STRING;
                                 dbDebugModule : System.Byte);
PROCEDURE    _MoreHelpMessageDisplay;
PROCEDURE    _CopyrightDisplay;
PROCEDURE    _DisplayProgramHelp;
PROCEDURE    _DisplayHelpFile(sHelpFileName : STRING;
                              bHaltOnError : System.Boolean);


IMPLEMENTATION


{*=========================== FUNCTIONAL PART ==========================*}


FUNCTION
        _fnsUserNeedMoreHelp : STRING;
{*
Description.
    Returns a string about available on-line help for user.
*}
BEGIN
   _fnsUserNeedMoreHelp := Messages._fnsTextMessageByIndex(13)+
                           Messages._fnsTextMessageByIndex(16)+
                           '  ' +
                           Globals.gsName +
                           Globals.achSPACE +
                           Globals.achDosSwitch +
                           Globals.asAltHelpOnScreen +
                           ' '+
                           Messages._fnsTextMessageByIndex(17)+
                           ' '+
                           Globals.gsName +
                           Globals.achSPACE +
                           Globals.achUnixSwitch +
                           Globals.asHelpOnScreen;
END;
{ _fnsUserNeedMoreHelp }



{*=========================== PROCEDURAL PART ==========================*}


PROCEDURE    _HaltProgram(sHaltMessage : STRING;
                          dbHaltCode : System.Byte);
{*
Description.
      Stops a program running;
      for some halt codes outputs message about more help.
*}
VAR
  sTempText : STRING;

BEGIN
    sTempText  :=  Messages._fnsTextMessageByIndex(13)+
                   Messages._fnsTextMessageByIndex(14)+
                   Globals.achSPACE+
                   '('+
                   StrLib._fnsNumToStr(dbHaltCode,3)+
                   ')'+
                   Globals.achSPACE+
                   sHaltMessage;
{$IFDEF   DebVer}
       IF  (Globals.gbJournalFileOk)
             THEN  BEGIN
               System.WriteLn(Globals.gfDebugOutputStream,sTempText);
                   END;
       {if-then}
{$ENDIF} {DebVer}
    System.WriteLn(sTempText);
    CASE  (dbHaltCode)  OF
       Globals.errNoPrefixSwitch,
       Globals.errBadBooleanParam,
       Globals.errBadWordParam,
       Globals.errBadWordParamRange,
       Globals.errBadPasStrParam,
       Globals.errBadPasStrParamRange,
       Globals.errUnsupportedSwitch     :
             System.WriteLn(_fnsUserNeedMoreHelp);
    ELSE
       {nothing}
    END;
    {case-of}
    System.Halt(dbHaltCode);
END;
{ _HaltProgram }



PROCEDURE
         _OutputMessageNoLF(sMessage : STRING;
                            bAddPrompt : System.Boolean);
{*
Description.
     Writes a screen message without the linefeed;
     program prompt is optional.
*}
BEGIN
  IF  (bAddPrompt)
    THEN  System.Write(Messages._fnsTextMessageByIndex(13)+sMessage)
    ELSE  System.Write(sMessage);
  {if-then-else}
END;
{ _OutputMessageNoLF }



PROCEDURE
         _OutputMessage(sMessage : STRING;
                        bAddPrompt : System.Boolean);
{*
Description.
      Writes a message through the pages of the stream output;
      program prompt is optional.
*}
VAR
  sTemp   :   STRING;

BEGIN
  IF  (bAddPrompt)
    THEN  sTemp := Messages._fnsTextMessageByIndex(13)+sMessage
    ELSE  sTemp := sMessage;
  {if-then-else}
  System.Writeln(sTemp);
{$IFDEF   DebVer}
       IF  (Globals.gbJournalFileOk)
             THEN  BEGIN
               System.WriteLn(Globals.gfDebugOutputStream,sTemp);
                   END;
       {if-then}
{$ENDIF} {DebVer}
   IF  (gdwTextLineNum <> Globals.aDisableScreenPage)
     THEN  BEGIN
      System.Inc(Globals.gdwTextLineNum);
      IF  (Globals.gdwTextLineNum > Globals.gdwMaxScreenLines)
        THEN  BEGIN
           Globals.gdwTextLineNum := Globals.aMinOutLineOnScreen;
           _OutputMessageNoLF(Messages._fnsTextMessageByIndex(18),
                              System.True);
           System.ReadLn(sTemp);
           IF  (sTemp <> Globals.asBlank)
             THEN  BEGIN
                _HaltProgram(Messages._fnsTextMessageByIndex(19),
                             Globals.errUserAbort);
                   END;
           {if-then}
              END;
      {if-then}
            END;
   {if-then}
END;
{ _OutputMessage }


PROCEDURE
        _OutputDebugMessage(sMessage : STRING;
                            dbDebugModule : System.Byte);
{*
Description.
     Writes a debugging message with indication of the debug module.
*}
VAR
  sDebugModule : STRING;

BEGIN
   sDebugModule := Messages._fnsTextMessageByIndex(15);
   IF  (dbDebugModule = Globals.aModuleVideo)
     THEN  sDebugModule := Messages._fnsTextMessageByIndex(447);
   {if-then}
   IF  (dbDebugModule = Globals.aModuleDosCtl)
     THEN  sDebugModule := Messages._fnsTextMessageByIndex(448);
   {if-then}
   IF  (dbDebugModule = Globals.aModuleCallBack)
     THEN  sDebugModule := Messages._fnsTextMessageByIndex(449);
   {if-then}
   IF  (dbDebugModule = Globals.aModuleConfig)
     THEN  sDebugModule := Messages._fnsTextMessageByIndex(450);
   {if-then}
   IF  (dbDebugModule = Globals.aModuleTypist)
     THEN  sDebugModule := Messages._fnsTextMessageByIndex(451);
   {if-then}
  _OutputMessage(sDebugModule+' '+sMessage,
                 System.True);
END;
{ _OutputDebugMessage }



PROCEDURE
         _MoreHelpMessageDisplay;
{*
Description.
      Displays the text about the available on-line help for user.
*}
BEGIN
    _OutputMessage(_fnsUserNeedMoreHelp,
                   System.False);
END;
{ _MoreHelpMessageDisplay }



PROCEDURE
         _CopyrightDisplay;
{*
Description.
      Outputs a copyright notice.
*}
BEGIN
     _OutputMessage(Messages._fnsTextMessageByIndex(8)+
                    '  '+
                    Messages._fnsTextMessageByIndex(12)+
                    ' '+
                    Globals.asVersion+
                    ',  '+
                    Messages._fnsTextMessageByIndex(10)+
                    ' '+
                    Globals.asYears+
                    '  '+
                    Messages._fnsTextMessageByIndex(9),
                    System.False);
END;
{ _CopyrightDisplay }



PROCEDURE
         _DisplayProgramHelp;
{*
Description.
       Displays a humble user help about program switches.
*}
CONST
  aMaxAddCharCount    =   5 + aMaxParamStrLen;

BEGIN
   _OutputMessage(Messages._fnsTextMessageByIndex(454),
                  System.True);
   _OutputMessage(Messages._fnsTextMessageByIndex(455),
                  System.False);
   _OutputMessage(Messages._fnsTextMessageByIndex(456)+gsName+Messages._fnsTextMessageByIndex(457),
                  System.False);
   _OutputMessage(Messages._fnsTextMessageByIndex(458)+Globals.achHexPrefix+Messages._fnsTextMessageByIndex(459),
                  System.False);
   _OutputMessage(Messages._fnsTextMessageByIndex(460)+Globals.achColon+
                  Messages._fnsTextMessageByIndex(461)+Globals.achEqual+'''.',
                  System.False);
   _OutputMessage(Messages._fnsTextMessageByIndex(462)+Globals.achDosSwitch+
                  Messages._fnsTextMessageByIndex(461)+Globals.achUnixSwitch+'''.',
                  System.False);
   _OutputMessage(Messages._fnsTextMessageByIndex(463),
                  System.False);
   _OutputMessage(Messages._fnsTextMessageByIndex(464),
                  System.False);
   _OutputMessage('   --------------+----------------------------------+---------------------',
                  System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asScreenLines+Messages._fnsTextMessageByIndex(497),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(466)+StrLib._fnsNumToStr(Globals.aDefMaxOutLineForScreen,2)+
            ', '+Messages._fnsTextMessageByIndex(494)+StrLib._fnsNumToStr(aBigOutLinesForScreenNum,4)+','+
            StrLib._fnsNumToStr(Globals.aDisableScreenPage,1)+Messages._fnsTextMessageByIndex(467),
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asConfigFileName+Messages._fnsTextMessageByIndex(499),
                  aMaxAddCharCount)+Messages._fnsTextMessageByIndex(468),
                  System.False);
{$IFDEF   DebVer}
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asEnableDebugInfo+Messages._fnsTextMessageByIndex(498),
                 aMaxAddCharCount)+Messages._fnsTextMessageByIndex(469),
                 System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asJournalFile+Messages._fnsTextMessageByIndex(499),
                  aMaxAddCharCount)+Messages._fnsTextMessageByIndex(565),
                  System.False);
{$ENDIF} {DebVer}
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asLoadTSR+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(470)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asMemType+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(471)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asUnLoadTSR+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(472)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asAddDict+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(473)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asSetDict+Messages._fnsTextMessageByIndex(499),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(474),
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asRemoveDict+Messages._fnsTextMessageByIndex(499),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(475),
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asListAll+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(476)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asFreeSpaceSize+Messages._fnsTextMessageByIndex(497),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(477)+StrLib._fnsNumToStr(Globals.aReserveMemoryDef,2)+', '+
            Messages._fnsTextMessageByIndex(494)+StrLib._fnsNumToStr(Globals.aReserveMemoryMax,5)+
            Messages._fnsTextMessageByIndex(254),
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asHumanLanguage+Messages._fnsTextMessageByIndex(497),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(478),
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asCallBackInt+Messages._fnsTextMessageByIndex(497),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(479)+
            StrLib._fnsByteToTurboHexFmt(Globals.grecCallBackIntParm.dbDefaultValue)+
            ', '+Messages._fnsTextMessageByIndex(496)+
            StrLib._fnsByteToTurboHexFmt(Globals.grecCallBackIntParm.dbMinValue)+
            Messages._fnsTextMessageByIndex(495)+
            StrLib._fnsByteToTurboHexFmt(Globals.grecCallBackIntParm.dbMaxValue),
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asUserChannel+Messages._fnsTextMessageByIndex(497),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(480)+
            StrLib._fnsByteToTurboHexFmt(Globals.grecUserMultChannelParm.dbDefaultValue)+
            ', '+Messages._fnsTextMessageByIndex(496)+
            StrLib._fnsByteToTurboHexFmt(Globals.grecUserMultChannelParm.dbMinValue)+
            Messages._fnsTextMessageByIndex(495)+
            StrLib._fnsByteToTurboHexFmt(Globals.grecUserMultChannelParm.dbMaxValue),
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asRunTimer+Messages._fnsTextMessageByIndex(497),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(481)+
            StrLib._fnsNumToStr(Globals.grecRunTimerValParm.dbDefaultValue,1)+
            ', '+Messages._fnsTextMessageByIndex(496)+
            StrLib._fnsNumToStr(Globals.grecRunTimerValParm.dbMinValue,1)+
            Messages._fnsTextMessageByIndex(495)+
            StrLib._fnsNumToStr(Globals.grecRunTimerValParm.dbMaxValue,1),
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asDispVerInfo+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(482)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asDispTsrInfo+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(483)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asLoadHelpFile+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(484)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asEnableDictDiagDump+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(485)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asEnableEnvDiagDump+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(486)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asEnableStatDiagDump+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(487)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asSetTestMode+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(488)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
{$IFDEF   StaVer}
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asDispStat+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(507)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asResetStat+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(508)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asTimeStat+Messages._fnsTextMessageByIndex(497),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(509)+
            StrLib._fnsNumToStr(Globals.grecStatTimeParm.dwDefaultValue,2)+
            ', '+Messages._fnsTextMessageByIndex(496)+
            StrLib._fnsNumToStr(Globals.grecStatTimeParm.dwMinValue,2)+
            Messages._fnsTextMessageByIndex(495)+
            StrLib._fnsNumToStr(Globals.grecStatTimeParm.dwMaxValue,4),
            System.False);
{$ENDIF} {StaVer}
{$IFDEF   DemVer}
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asSetDemoMode+'[+|-]',aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(489)+Messages._fnsTextMessageByIndex(382)+')',
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asTimeFactor+Messages._fnsTextMessageByIndex(497),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(490)+
            StrLib._fnsNumToStr(Globals.grecUserTimeFactorParm.dbDefaultValue,2)+
            ', '+Messages._fnsTextMessageByIndex(496)+
            StrLib._fnsNumToStr(Globals.grecUserTimeFactorParm.dbMinValue,3)+
            Messages._fnsTextMessageByIndex(495)+
            StrLib._fnsNumToStr(Globals.grecUserTimeFactorParm.dbMaxValue,2),
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asPauseDelay+Messages._fnsTextMessageByIndex(497),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(491)+
            StrLib._fnsNumToStr(Globals.grecPauseDelayInSecParm.dbDefaultValue,2)+
            ', '+Messages._fnsTextMessageByIndex(496)+
            StrLib._fnsNumToStr(Globals.grecPauseDelayInSecParm.dbMinValue,2)+
            Messages._fnsTextMessageByIndex(495)+
            StrLib._fnsNumToStr(Globals.grecPauseDelayInSecParm.dbMaxValue,2),
            System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asWaitTimeTicks+Messages._fnsTextMessageByIndex(497),
            aMaxAddCharCount)+Messages._fnsTextMessageByIndex(492)+
            StrLib._fnsNumToStr(Globals.grecUserTimeTicksParm.dbDefaultValue,2)+', '+
            Messages._fnsTextMessageByIndex(496)+
            StrLib._fnsNumToStr(Globals.grecUserTimeTicksParm.dbMinValue,2)+
            Messages._fnsTextMessageByIndex(495)+
            StrLib._fnsNumToStr(Globals.grecUserTimeTicksParm.dbMaxValue,2),
            System.False);
{$ENDIF} {DemVer}
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asDosEnvVar+Messages._fnsTextMessageByIndex(499),
                  aMaxAddCharCount)+Messages._fnsTextMessageByIndex(564)+Globals.asDosEnvVarDef,
                  System.False);
   _OutputMessage('    '+StrLib._fnsTrailingAddSpacesToMax(Globals.asHelpOnScreen+','+asAltHelpOnScreen,aMaxAddCharCount)+
            Messages._fnsTextMessageByIndex(493),
            System.False);
   _OutputMessage('   --------------+----------------------------------+---------------------',System.False);
   _OutputMessage(Messages._fnsTextMessageByIndex(465)+Globals.gsName+'  '+
{$IFDEF   DebVer}
                  Globals.achUnixSwitch+Globals.asEnableDebugInfo+'=$8000'+Globals.achSPACE+
{$ENDIF} {DebVer}
                  Globals.achDosSwitch+Globals.asScreenLines+Globals.achEqual+'43',
                  System.False);
   _HaltProgram(Messages._fnsTextMessageByIndex(23),
                Globals.errUserHelp);
END;
{ _DisplayProgramHelp }



PROCEDURE
         _DisplayHelpFile(sHelpFileName : STRING;
                          bHaltOnError : System.Boolean);
{*
Description.
      Displays the help file if it is available.
*}
VAR
  fHelpStream    :  System.Text;
  sFromHelpFile  :  STRING;
  bFileNotFound  :  System.Boolean;

BEGIN
{$IFDEF   DebVer}
   IF  ((Globals.gdwDebugLevel AND Globals.btTraceVideo) <> 0)
      THEN  _OutputDebugMessage(Messages._fnsTextMessageByIndex(20)+
                               ' '+
                               sHelpFileName,
                               aModuleVideo);
   {if-then}
{$ENDIF} {DebVer}

   System.Assign(fHelpStream,sHelpFileName);
{$IFDEF   ComVer}
   System.SetTextBuf(fHelpStream,Globals.gdbLargeTextInBuf);
{$ENDIF} {ComVer}
   {$I-}
   System.Reset(fHelpStream);
   {$I+}

   bFileNotFound := (System.IoResult <> Globals.errOK);
   IF  (bFileNotFound)
     THEN  BEGIN
       IF  (bHaltOnError)
         THEN  _HaltProgram(Messages._fnsTextMessageByIndex(21),
                            Globals.errHelpFileNotFound)
         ELSE  System.Exit;
      {if-then-else}
           END;
   {if-then}
   _OutputMessage(Messages._fnsTextMessageByIndex(452),
                  System.True);

   WHILE  NOT(System.Eof(fHelpStream)) DO
   BEGIN
      System.ReadLn(fHelpStream,sFromHelpFile);
      _OutputMessage(sFromHelpFile,
                     System.False);
   END;
   {while-do}

   System.Close(fHelpStream);
   _HaltProgram(Messages._fnsTextMessageByIndex(22),
                Globals.errHelpFileDisplayed)
END;
{ _DisplayHelpFile }



{BEGIN}
END.
