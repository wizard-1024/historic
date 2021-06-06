{****************************************************************************
//                            File USRPARAM.PAS
//
//                User program parameters processing module
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/usrparam.pas $
//  $RCSfile: usrparam.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:58:15 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: usrparam.pas $
//      Revision 1.1  1999/01/03 17:58:15  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             USRPARAM.PAS                                    }
{ PURPOSE               User parameters processing library              }
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
{                       STRINGS.TPU    (Turbo Strings unit)             }
{                       GLOBALS.TPU    (global public definitions)      }
{                       MESSAGES.TPU   (text user messages)             }
{                       VIDEO.TPU      (user screen interface)          }
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
    UsrParam;


INTERFACE

USES
     Strings,
     Globals,
     Messages,
     StrLib,
     Video;


PROCEDURE   _ScanProgramParameterLine(dwNumOfAvailParms : System.Word);


IMPLEMENTATION


PROCEDURE
         _ScanProgramParameterLine(dwNumOfAvailParms : System.Word);
{*
Description.
      General-purpose parameter processing routine.
*}
VAR
  dwNumOfParams   :    System.Word;
  dwParamIndex    :    System.Word;
  dwTempIndex     :    System.Word;
  bParmFound      :    System.Boolean;
  dbStrPos        :    System.Byte;
  sTemp           :    STRING;
  sOption         :    STRING;

FUNCTION
         _fnbIsSwitchPresent(sParam : STRING) : System.Boolean;
{*
Description.
     Checks the presence in the string a switch.
*}
VAR
   bResult  :  System.Boolean;
BEGIN
  bResult := System.False;
  IF  (sParam <> Globals.asBlank)
    THEN BEGIN
      IF  ((sParam[1] = Globals.achDosSwitch) OR
           (sParam[1] = Globals.achUnixSwitch))
        THEN  bResult := System.True;
      {if-then}
         END;
  {if-then}
  _fnbIsSwitchPresent := bResult;
END;
{ _fnbIsSwitchPresent }

FUNCTION
        _fndbSkipDelimiterInParamStrPresent(sParam : STRING;
                               dbValueIndex : System.Byte) : System.Byte;
{*
Description.
      Detects and skips a delimiter in the parameter string.
*}
VAR
  chTemp        :   System.Char;
  dbSkipCount   :   System.Byte;
BEGIN
  IF  (dbValueIndex <> 0)
    THEN  chTemp := sParam[dbValueIndex]
    ELSE  chTemp := Globals.achNull;
  {if-then-else}
  CASE  (chTemp)  OF
      Globals.achColon,
      Globals.achEqual    :   dbSkipCount := 1;
  ELSE
     dbSkipCount := 0;
  END;
  {case-of}
  _fndbSkipDelimiterInParamStrPresent := dbSkipCount;
END;
{ _fndbSkipDelimiterInParamStrPresent }

PROCEDURE
         _GetBooleanParam(sParamTemp : STRING;
                          dwTableIndex : System.Word;
                          dbPosOfValue : System.Byte);
{*
Description.
     Extracts a parameter of a boolean type.
*}
VAR
  recBooleanParamValues :  Globals.recBooleanParameter;
  pTemp                 :  System.Pointer;
  bNewValue             :  System.Boolean;
  chTemp                :  System.Char;

BEGIN
   chTemp := sParamTemp[dbPosOfValue];
   CASE  (chTemp)  OF
       Globals.achPlus  : bNewValue := System.True;
       Globals.achMinus : bNewValue := System.False;
   ELSE
     Video._HaltProgram(Messages._fnsTextMessageByIndex(27)+
                        ' <'+sParamTemp+'>.',
                        Globals.errBadBooleanParam);
   END;
   {case-of}
   pTemp := Globals.gachProgramOptions[dwTableIndex].lpParamDesc;
   System.Move(System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)],
               recBooleanParamValues,
               System.SizeOf(Globals.recBooleanParameter));
   pTemp := recBooleanParamValues.lpVarAddr;
   IF  ((bNewValue <> recBooleanParamValues.bMinValue) AND
       (bNewValue <> recBooleanParamValues.bMaxValue))
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(446)+
                                 ' <'+sParamTemp+'>.',
                                 Globals.errBadBooleanParamRange);
   {if-then}
   System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)] := System.Byte(bNewValue);
END;
{ _GetBooleanParam }

PROCEDURE  _GetWordParam(sParamTemp : STRING;
                         dwTableIndex : System.Word;
                         dbPosOfValue : System.Byte);
{*
Description.
   Extracts a parameter of a word type.
*}
VAR
  recWordParamValues    :  Globals.recWordParameter;
  pTemp                 :  System.Pointer;
  dwNewValue            :  System.Word;
  iErrorCode            :  System.Integer;
  sNumTemp              :  STRING;

BEGIN
   sNumTemp := System.Copy(sParamTemp,dbPosOfValue,(System.Length(sParamTemp)-dbPosOfValue+1));
   dwNewValue := StrLib._fndwGetValue(iErrorCode,sNumTemp);
   IF  (iErrorCode <> Globals.errOK)
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(28)+
                              ' <'+sParamTemp+'>.',
                              Globals.errBadWordParam);
   {if-then}
   pTemp := Globals.gachProgramOptions[dwTableIndex].lpParamDesc;
   System.Move(System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)],
               recWordParamValues,
               System.SizeOf(Globals.recWordParameter));
   WITH  (recWordParamValues)  DO
   BEGIN
      IF  ((dwMinValue <= dwNewValue) AND
           (dwNewValue <= dwMaxValue))
        THEN  pTemp := lpVarAddr
        ELSE  Video._HaltProgram(Messages._fnsTextMessageByIndex(29)+
                                 ' <'+sParamTemp+'>.',
                                 Globals.errBadWordParamRange);
      {if-then-else}
   END;
   {with-do}
   System.MemW[System.Seg(pTemp^):System.Ofs(pTemp^)] := dwNewValue;
END;
{ _GetWordParam }

PROCEDURE
         _GetByteParam(sParamTemp : STRING;
                       dwTableIndex : System.Word;
                       dbPosOfValue : System.Byte);
{*
Description.
     Extracts a parameter of a byte type.
*}
VAR
  recByteParamValues    :  Globals.recByteParameter;
  pTemp                 :  System.Pointer;
  dbNewValue            :  System.Byte;
  iErrorCode            :  System.Integer;
  sNumTemp              :  STRING;

BEGIN
   sNumTemp := System.Copy(sParamTemp,dbPosOfValue,(System.Length(sParamTemp)-dbPosOfValue+1));
   dbNewValue := System.Lo(StrLib._fndwGetValue(iErrorCode,sNumTemp));
   IF  (iErrorCode <> Globals.errOK)
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(30)+
                              ' <'+sParamTemp+'>.',
                              Globals.errBadByteParam);
   {if-then}
   pTemp := gachProgramOptions[dwTableIndex].lpParamDesc;
   System.Move(System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)],
               recByteParamValues,
               System.SizeOf(Globals.recByteParameter));
   WITH  (recByteParamValues)  DO
   BEGIN
      IF ((dbMinValue <= dbNewValue) AND
          (dbNewValue <= dbMaxValue))
        THEN  pTemp := lpVarAddr
        ELSE  Video._HaltProgram(Messages._fnsTextMessageByIndex(31)+
                                 ' <'+sParamTemp+'>.',
                                 Globals.errBadByteParamRange);
      {if-then-else}
   END;
   {with-do}
   System.MemW[System.Seg(pTemp^):System.Ofs(pTemp^)] := dbNewValue;
END;
{ _GetByteParam }

PROCEDURE
         _GetPascalStrParameter(sParamTemp : STRING;
                                dwTableIndex : System.Word;
                                dbPosOfValue : System.Byte);
{*
Description.
  Extracts a parameter of a Pascal string type.
*}
VAR
  recPasStrParamValues    :  Globals.recPascalStrParameter;
  pTemp                   :  System.Pointer;
  iErrorCode              :  System.Integer;
  sTempPas                :  STRING;

BEGIN
   sTempPas := System.Copy(sParamTemp,dbPosOfValue,(System.Length(sParamTemp)-dbPosOfValue+1));
   IF  (sTempPas = Globals.asBlank)
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(32)+
                              ' <'+sParamTemp+'>.',
                              Globals.errBadPasStrParam);
   {if-then}
   pTemp := Globals.gachProgramOptions[dwTableIndex].lpParamDesc;
   System.Move(System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)],
               recPasStrParamValues,
               System.SizeOf(Globals.recPascalStrParameter));
   WITH  (recPasStrParamValues)  DO
   BEGIN
      IF (System.Length(sTempPas) <= dwMaxStrLen)
        THEN  pTemp := lpVarAddr
        ELSE  Video._HaltProgram(Messages._fnsTextMessageByIndex(33)+
                                 ' <'+sParamTemp+'>.',
                                 Globals.errBadPasStrParamRange);
      {if-then-else}
   END;
   {with-do}
   System.Move(sTempPas[0],
               System.Mem[System.Seg(pTemp^):System.Ofs(pTemp^)],
               (System.Length(sTempPas)+1));
END;  { _GetPascalStrParameter }

BEGIN
   dwNumOfParams := System.ParamCount;
   IF  (dwNumOfParams <> 0)
     THEN   BEGIN
        FOR  dwParamIndex := 1  TO  dwNumOfParams  DO
        BEGIN
             sTemp := System.ParamStr(dwParamIndex);
             IF  NOT(_fnbIsSwitchPresent(sTemp))
               THEN  BEGIN
                 Video._HaltProgram(Messages._fnsTextMessageByIndex(34)+
                                    ' <'+sTemp+'>.',
                                    Globals.errNoPrefixSwitch);
                     END;
             {if-then}
             bParmFound := System.False;
             dwTempIndex := 1;
             WHILE  (NOT(bParmFound) AND
                     (dwTempIndex <= dwNumOfAvailParms))
             DO BEGIN
                 sOption := Strings.StrPas(Globals.gachProgramOptions[dwTempIndex].sParamName);
                 dbStrPos := System.Pos(sOption,sTemp);
                 IF  (dbStrPos = 2)
                   THEN  BEGIN
                      bParmFound := System.True;
                      System.Inc(dbStrPos,System.Length(sOption));
                      System.Inc(dbStrPos,_fndbSkipDelimiterInParamStrPresent(sTemp,dbStrPos));
                      CASE  (Globals.gachProgramOptions[dwTempIndex].dwParamType)  OF
                           Globals.aParmIsIndefinite  :
                                                BEGIN
                                       Globals.gdbUserHelpRequest := System.True;
                                                END;
                           Globals.aParmIsPascalStr   :
                                                BEGIN
                               _GetPascalStrParameter(sTemp,dwTempIndex,dbStrPos);
                                                END;
                           Globals.aParmIsBoolean     :
                                                BEGIN
                               _GetBooleanParam(sTemp,dwTempIndex,dbStrPos);
                                                END;
                           Globals.aParmIsWord        :
                                                BEGIN
                               _GetWordParam(sTemp,dwTempIndex,dbStrPos);
                                                END;
                           Globals.aParmIsByte        :
                                                BEGIN
                               _GetByteParam(sTemp,dwTempIndex,dbStrPos);
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
                 Video._HaltProgram(Messages._fnsTextMessageByIndex(35)+
                                    ' <'+sTemp+'>.',
                                    Globals.errUnsupportedSwitch);
                     END;
             {if-then}
        END;
        {for-to-do}
            END;
   {if-then}
END;
{ _ScanProgramParameterLine }



{BEGIN}
END.
