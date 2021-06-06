{****************************************************************************
//                            File CONFIG.PAS
//
//                     Configuration of program options
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/config.pas $
//  $RCSfile: config.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:51:03 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: config.pas $
//      Revision 1.1  1999/01/03 17:51:03  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             CONFIG.PAS                                      }
{ PURPOSE               Configuration of program options                }
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
{                       STRLIB.TPU     (string support library)         }
{                       USERDICT.TPU   (user dictionary processing)     }
{                       Project Maintence Files                         }
{                       TYPIST.MAK        (auto compiling & linking)    }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       0.01   13-Sep-94  DS  initial release           }
{-----------------------------------------------------------------------}



UNIT
    Config;


INTERFACE

USES
    Globals,
    Messages,
    StrLib,
    Video,
    UserDict;


PROCEDURE   _ParseConfigFile(sConfigName : STRING;
                             bStopOnError: System.Boolean);


IMPLEMENTATION

{*CONFIG.INC*}
{*=========================== PROCEDURAL PART ==========================*}

FUNCTION
        _fndwGetSearchFlags(sInitFlags : STRING) : System.Word;
{*
Description.
  Gets the value of the search flags based on the symbol string.
*}
VAR
  dwFoundFlags  :  System.Word;
  dbStrLen,
  dbIndex       :  System.Byte;
  chSym         :  System.Char;

BEGIN
   dwFoundFlags := $00;
   dbStrLen := System.Length(sInitFlags);
   FOR  dbIndex := 1  TO  dbStrLen  DO
   BEGIN
      chSym := sInitFlags[dbIndex];
      IF  (chSym = Globals.gchCurForwardSearchSymbol)
        THEN  dwFoundFlags := dwFoundFlags + Globals.btForwardSearch;
      {if-then}
      IF  (chSym = Globals.gchCurBackwardSearchSymbol)
        THEN  dwFoundFlags := dwFoundFlags + Globals.btBackwardSearch;
      {if-then}
      IF  (chSym = Globals.gchCurSearchAbbrevSymbol)
        THEN  dwFoundFlags := dwFoundFlags + Globals.btSearchAbbreviation;
      {if-then}
      IF  (chSym = Globals.gchCurSearchExpressionSymbol)
        THEN  dwFoundFlags := dwFoundFlags + Globals.btSearchExpression;
      {if-then}
      IF  (chSym = Globals.gchCurDirectionSearchOrderSym)
        THEN  dwFoundFlags := dwFoundFlags + Globals.btSearchFirstForward;
      {if-then}
      IF  (chSym = Globals.gchCurDictSearchOrderSym)
        THEN  dwFoundFlags := dwFoundFlags + Globals.btSearchFirstAbbreviation;
      {if-then}
      IF  (chSym = Globals.gchCurCaseSearchSym)
        THEN  dwFoundFlags := dwFoundFlags + Globals.btSearchCaseSensitive;
      {if-then}
   END;
   {for-to-do}
   IF  (dwFoundFlags = 0)
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(53),
                        Globals.errBadInitSearchFlags);
   {if-then}

   _fndwGetSearchFlags := dwFoundFlags;
END;
{ _fndwGetSearchFlags }


PROCEDURE
         _AddEntryToDictionary(sAbbreviation,
                               sDicEntry : STRING;
                               dbSearchTypeInDictionary : System.Byte);
{*
Description.
    Adds an user entry to the corresponding pre-scan dictionary entry;
    uses Turbo heap manager to allocate the needed string space.
*}
VAR
  lpDicEntryDesc,
  lpDicEntryTempPrev,
  lpDicEntryTemp          :   lprecDicEntryDesc;
  lpDicEntry,
  lpDicAbbrv              :   System.Pointer;
  sTestDictEntry          :   STRING;
  dwSumSize               :   System.Word;
  dbAbbreviationSize,
  dbDicEntrySize,
  dbCharIndex             :   System.Byte;

BEGIN
    System.Inc(Globals.gliWordsPerDictRead);
    IF  (Globals.gliWordsPerDictRead > Globals.aWords_For_Dict_Max)
      THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(439),
                               Globals.errTooLargeUserDictionary);
    {if-then}
    dbAbbreviationSize := System.Length(sAbbreviation);
    dbDicEntrySize := System.Length(sDicEntry);
    dwSumSize := dbAbbreviationSize + dbDicEntrySize;
    IF  (((Globals.gdwCurUserEnvOptions AND Globals.btAddPaddingZero) <> 0)
            AND  (System.Odd(dwSumSize)))
      THEN  System.Inc(dwSumSize);
    {if-then}
    System.Inc(Globals.gdwEstimatedDictSize,dwSumSize);
    System.Inc(Globals.gdwEstimatedDictSize,System.SizeOf(Globals.recDictEntryHeaderDesc));
    dbCharIndex := System.Byte(sAbbreviation[1]);
    IF  (dbAbbreviationSize <> 0)
      THEN  BEGIN
         System.Inc(Globals.gSymFrequencyNodesArrayFA[dbCharIndex]);
         System.Inc(Globals.gSymFrequencyNodesArrayBA[System.Byte(sAbbreviation[dbAbbreviationSize])]);
         System.Inc(Globals.gAbbrevSizesFrequencyNodesArray[dbAbbreviationSize]);
         IF  (System.MaxAvail > dbAbbreviationSize)
           THEN  System. GetMem(lpDicAbbrv,dbAbbreviationSize)
           ELSE  Video._HaltProgram(Messages._fnsTextMessageByIndex(438),
                                    Globals.errNoMoreFreeMemOnHeap);
         {if-then-else}
         System.Move(sAbbreviation[1],
                     System.Mem[System.Seg(lpDicAbbrv^):System.Ofs(lpDicAbbrv^)],
                     dbAbbreviationSize);
            END
      ELSE  BEGIN
         lpDicAbbrv := NIL;
            END;
    {if-then-else}
    IF  (dbDicEntrySize <> 0)
      THEN  BEGIN
         System.Inc(Globals.gSymFrequencyNodesArrayFE[System.Byte(sDicEntry[1])]);
         System.Inc(Globals.gSymFrequencyNodesArrayBE[System.Byte(sDicEntry[dbDicEntrySize])]);
         System.Inc(Globals.gExprSizesFrequencyNodesArray[dbDicEntrySize]);
         IF  (System.MaxAvail > dbDicEntrySize)
           THEN  System. GetMem(lpDicEntry,dbDicEntrySize)
           ELSE  Video._HaltProgram(Messages._fnsTextMessageByIndex(438),
                                    Globals.errNoMoreFreeMemOnHeap);
         {if-then-else}
         System.Move(sDicEntry[1],
                     System.Mem[System.Seg(lpDicEntry^):System.Ofs(lpDicEntry^)],
                     dbDicEntrySize);
            END
      ELSE  BEGIN
         lpDicEntry := NIL;
            END;
    {if-then-else}
    System.New(lpDicEntryDesc);
    WITH  (lpDicEntryDesc^)  DO
    BEGIN
        dbDicAbbrvSize  := dbAbbreviationSize;
        dbEntrySize  := dbDicEntrySize;
        lpDicAbbrvStore  := lpDicAbbrv;
        lpDicEntryStore  := lpDicEntry;
        lpNextDicEntryDesc := NIL;
        lpPrevDicEntryDesc := NIL;
    END;
    {with-do}
    lpDicEntryTempPrev := NIL;
    CASE  (dbSearchTypeInDictionary)  OF
       Globals.aSearchForwardFromStart     :  BEGIN
                         lpDicEntryTemp := Globals.gDirectSearchArray[dbCharIndex];
                         sTestDictEntry := Globals.asBlank;
                         WHILE (lpDicEntryTemp <> NIL)  DO
                         BEGIN
                            sTestDictEntry := UserDict._fnsGetAbbreviationStr(lpDicEntryTemp);
                            IF  (sTestDictEntry = sAbbreviation)
                              THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(54)+
                                                 ' <'+sAbbreviation+'>.',
                                                 Globals.errDuplicateAbbreviation);
                            {if-then}
                            lpDicEntryTempPrev := lpDicEntryTemp;
                            lpDicEntryTemp := lpDicEntryTemp^.lpNextDicEntryDesc;
                         END;
                         {while-do}
                         IF  (lpDicEntryTempPrev <> NIL)
                           THEN  BEGIN
                             lpDicEntryTempPrev^.lpNextDicEntryDesc := lpDicEntryDesc;
                             lpDicEntryDesc^.lpPrevDicEntryDesc := lpDicEntryTempPrev;
                                 END
                           ELSE  BEGIN
                             Globals.gDirectSearchArray[dbCharIndex] := lpDicEntryDesc;
                                 END;
                         {if-then-else}
                                      END;
    ELSE
           Video._HaltProgram(Messages._fnsTextMessageByIndex(55)+
                              '<'+sAbbreviation+'>',
                        Globals.errBadSearchType);
    END;
    {case-of}
END;
{ _AddEntryToDictionary }


FUNCTION
        _fndwCalcHeadLinkTableSize(bTablePresent : System.Boolean;
                                   btScanTable : System.Byte) : System.Word;
{*
Description.
   Extracts a table size.
*}
VAR
  dwLinkTableSize : System.Word;
  dbIndexChar     : System.Byte;

BEGIN
  dwLinkTableSize := 0;
  IF  (bTablePresent)
    THEN  BEGIN
      IF  ((Globals.gdwCurUserEnvOptions AND Globals.btUseTableCompression) = 0)
        THEN  BEGIN
           dwLinkTableSize := System.SizeOf(Globals.arrayDWTable256)
              END
        ELSE  BEGIN
          System.Inc(dwLinkTableSize,Globals.aBytesForSet256);
          CASE  (btScanTable)  OF
            btForwardSearchAbbreviation      :      BEGIN
                        FOR  dbIndexChar := Globals.aMinCharBit8  TO Globals.aMaxCharBit8  DO
                        IF  (Globals.gSymFrequencyNodesArrayFA[dbIndexChar] <> 0)
                          THEN  System.Inc(dwLinkTableSize,Globals.aWord);
                        {if-then}
                        {for-to-do}
                                                    END;
            btBackwardSearchAbbreviation     :      BEGIN
                        FOR  dbIndexChar := Globals.aMinCharBit8  TO Globals.aMaxCharBit8  DO
                        IF  (Globals.gSymFrequencyNodesArrayBA[dbIndexChar] <> 0)
                          THEN  System.Inc(dwLinkTableSize,Globals.aWord);
                        {if-then}
                        {for-to-do}
                                                    END;
            btForwardSearchExpression        :      BEGIN
                        FOR  dbIndexChar := Globals.aMinCharBit8  TO Globals.aMaxCharBit8  DO
                        IF  (Globals.gSymFrequencyNodesArrayFE[dbIndexChar] <> 0)
                          THEN  System.Inc(dwLinkTableSize,Globals.aWord);
                        {if-then}
                        {for-to-do}
                                                    END;
            btBackwardSearchExpression       :      BEGIN
                        FOR  dbIndexChar := Globals.aMinCharBit8  TO Globals.aMaxCharBit8  DO
                        IF  (Globals.gSymFrequencyNodesArrayBE[dbIndexChar] <> 0)
                          THEN  System.Inc(dwLinkTableSize,Globals.aWord);
                        {if-then}
                        {for-to-do}
                                                    END;
            btSearchAbbreviationSizes        :      BEGIN
                        FOR  dbIndexChar := Globals.aMinCharBit8  TO Globals.aMaxCharBit8  DO
                        IF  (Globals.gAbbrevSizesFrequencyNodesArray[dbIndexChar] <> 0)
                          THEN  System.Inc(dwLinkTableSize,Globals.aWord);
                        {if-then}
                        {for-to-do}
                                                    END;
            btSearchExpressionSizes          :      BEGIN
                        FOR  dbIndexChar := Globals.aMinCharBit8  TO Globals.aMaxCharBit8  DO
                        IF  (Globals.gExprSizesFrequencyNodesArray[dbIndexChar] <> 0)
                          THEN  System.Inc(dwLinkTableSize,Globals.aWord);
                        {if-then}
                        {for-to-do}
                                                    END;
          ELSE
             {nothing}
          END;
          {case-of}
              END;
      {if-then-else}
          END;
  {if-then}
   _fndwCalcHeadLinkTableSize := dwLinkTableSize;
END;
{ _fndwCalcHeadLinkTableSize }


PROCEDURE
         _ParseConfigFile(sConfigName : STRING;
                          bStopOnError: System.Boolean);
{*
Description.
    Processes the configuration file with the initial user settings;
    includes the processing of the environment and the dictionary.
*}
VAR
  fStruc           :          System.Text;
  sInputLine,
  sParameter,
  sUserAbbreviation,
  sLastUserAbbreviation,
  sUserEntry,
  sLastUserEntry,
  sKeywordEntry    :          STRING;
  dwTempNum,
  dwCurFileLine,
  dwCurSection,
  dwPassedSections,
  dwOptionsFlags   :          System.Word;
  dbTempPos,
  dbSearchType,
  dbLastSearchType,
  dbTempStrLen,
  dbAsciiCode,
  dbScanCode,
  dbKbdMode,
  dbBoolTemp       :          System.Byte;
  bReadOk,
  bScanOK,
  bKeywordEntryOk,
  bContinueEntry   :          System.Boolean;
  chTranslateTo,
  chTranslateFrom,
  chClosingDelim,
  chOpeningDelim   :          System.Char;

FUNCTION
        _fnsExtractParameter(sParmLine,
                             sKeyword : STRING) : STRING;
{*
Description.
    Extracts the parameter value from the statement.
*}
BEGIN
  System.Delete(sParmLine,1,System.Length(sKeyword));
  _fnsExtractParameter := Strlib._fnsSkipDelimiter(sParmLine);
END;
{ _fnsExtractParameter }

FUNCTION
        _fnsGetNextItemInStr(sInput : STRING) : STRING;
{*
Description.
     Extracts a next item from statement.
*}
VAR
  dbStrLen,dbCount          :  System.Byte;
  bNoEndOfInput,
  bCopyAll                  :  System.Boolean;
  chTempSym                 :  System.Char;
BEGIN
   bNoEndOfInput := System.True;
   bCopyAll := System.False;
   dbCount := 0;
   dbStrLen := System.Length(sInput);
   WHILE  ((dbCount < dbStrLen) AND
           (bNoEndOfInput))
   DO BEGIN
      chTempSym := sInput[dbCount+1];
      IF  ((chTempSym = chClosingDelim) AND
           (bCopyAll))
        THEN  bCopyAll := System.False
        ELSE  BEGIN
           IF  ((chTempSym = chOpeningDelim) AND
                NOT(bCopyAll))
             THEN  bCopyAll := System.True;
           {if-then}
              END;
      {if-then-else}
      IF  (NOT(bCopyAll) AND
           (chTempSym IN Globals.setDelimiters))
        THEN  bNoEndOfInput := System.False
        ELSE  System.Inc(dbCount);
      {if-then-else}
   END;
   {while-do}
  _fnsGetNextItemInStr := System.Copy(sInput,1,dbCount);
END;
{ _fnsGetNextItemInStr }

FUNCTION
        _fnsGetNextNumbericItemInStr(sInput : STRING) : STRING;
{*
Description.
   Extracts a numeric next item from the statement.
*}
VAR
  dbIndex,
  dbCount   :   System.Byte;
BEGIN
   dbCount := System.Length(sInput);
   dbIndex  := 0;
   WHILE  ((dbIndex <= dbCount)  AND
           NOT(sInput[dbIndex+1] IN Globals.setDelimiters))
   DO  System.Inc(dbIndex);
   {while-do}
  _fnsGetNextNumbericItemInStr := System.Copy(sInput,1,dbIndex);
END;
{ _fnsGetNextNumbericItemInStr }

FUNCTION
        _fndbGetNumericParm(sNumParm : STRING;
                            chOpeningDelimiter,
                            chClosingDelimiter : System.Char) : System.Byte;
{*
Description.
    Translates a string to its numeric value (byte-value).
*}
VAR
  iErrCode   :  System.Integer;
  dbValue,
  dbStrLen   :  System.Byte;
BEGIN
   dbStrLen := System.Length(sNumParm);
   IF  ((sNumParm[1] = chOpeningDelimiter) AND
        (sNumParm[dbStrLen] = chClosingDelimiter))
     THEN  BEGIN
       IF  (dbStrLen >= 3)
         THEN  dbValue := System.Ord(sNumParm[2])
         ELSE  dbValue := System.Byte(Globals.achNULL)
       {if-then-else}
           END
     ELSE  BEGIN
       dbValue := StrLib._fndwGetValue(iErrCode,System.Copy(sNumParm,2,dbStrLen-2));
       IF (iErrCode <> 0)
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(56)+
                            ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                            Globals.errBadNumericEntry);
       {if-then}
       IF  ((sNumParm[1] <> Globals.achLess)  OR
            (sNumParm[dbStrLen] <> Globals.achGreater))
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(57)+
                            ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                            Globals.errBadSyntaxNumericEntry);
       {if-then}
           END;
   {if-then}
   _fndbGetNumericParm := dbValue;
END;
{ _fndbGetNumericParm }

FUNCTION
        _fndwGetNumericParm(sNumParm : STRING;
                            chOpeningDelimiter,
                            chClosingDelimiter : System.Char) : System.Word;
{*
Description.
    Translates a string to its numeric value (word-value).
*}
VAR
  iErrCode   :  System.Integer;
  dwValue    :  System.Word;
  dbStrLen   :  System.Byte;
BEGIN
   dbStrLen := System.Length(sNumParm);
   IF  ((sNumParm[1] = chOpeningDelimiter) AND
        (sNumParm[dbStrLen] = chClosingDelimiter))
     THEN  BEGIN
       IF  (dbStrLen >= 3)
         THEN  dwValue := System.Ord(sNumParm[2])
         ELSE  dwValue := System.Byte(Globals.achNULL)
       {if-then-else}
           END
     ELSE  BEGIN
       dwValue := StrLib._fndwGetValue(iErrCode,System.Copy(sNumParm,2,dbStrLen-2));
       IF (iErrCode <> 0)
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(56)+
                            ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                            Globals.errBadNumericEntry);
       {if-then}
       IF  ((sNumParm[1] <> Globals.achLess)  OR
            (sNumParm[dbStrLen] <> Globals.achGreater))
         THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(57)+
                            ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                            Globals.errBadSyntaxNumericEntry);
       {if-then}
           END;
   {if-then}
   _fndwGetNumericParm := dwValue;
END;
{ _fndwGetNumericParm }

FUNCTION
        _fnchGetSymbolParm(sNumParm,
                           sKeywordDef : STRING;
                           chOpeningDelimiter,
                           chClosingDelimiter : System.Char) : System.Char;
{*
Description.
      Translates a string to its character equivalent.
*}
BEGIN
   sNumParm := _fnsExtractParameter(sNumParm,sKeywordDef);
   _fnchGetSymbolParm := System.Char(_fndbGetNumericParm(_fnsGetNextNumbericItemInStr(sNumParm),
                                     chOpeningDelimiter,chClosingDelimiter));
END;
{ _fnchGetSymbolParm }

FUNCTION
        _fnsGetUserSubEntryString(sInput : STRING) : STRING;
{*
Description.
      Extracts the user entry from string with the delimiters.
*}
BEGIN
   IF  ((sInput[1] <> chOpeningDelim)  OR
        (sInput[System.Length(sInput)] <> chClosingDelim))
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(58)+
                        ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                        Globals.errBadSyntaxUserSubString);
   {if-then}
  _fnsGetUserSubEntryString := System.Copy(sInput,2,System.Length(sInput)-2);
END;
{ _fnsGetUserSubEntryString }

PROCEDURE
         _ProcessKeyboardHotKeyBitDefinition(sParamDef    : STRING;
                                             dbHotKeyMode : System.Byte);
{*
Description.
    Translates the string definitions to the keyboard bit definitions.
*}
VAR
   dwTempBitFlags  :   System.Word;
   iErrCode        :   System.Integer;
   dbTempCode      :   System.Byte;
BEGIN
   dwTempBitFlags := 0;
   dbTempCode := 0;
   IF  (sParamDef = Globals.asLeftShiftKey)
     THEN  dwTempBitFlags := Globals.btLeftShiftHotKey;
   {if-then}
   IF  (sParamDef = Globals.asRightShiftKey)
     THEN  dwTempBitFlags := Globals.btRightShiftHotKey;
   {if-then}
   IF  (sParamDef = Globals.asLeftControlKey)
     THEN  dwTempBitFlags := Globals.btLeftControlHotKey;
   {if-then}
   IF  (sParamDef = Globals.asRightControlKey)
     THEN  dwTempBitFlags := Globals.btRightControlHotKey;
   {if-then}
   IF  (sParamDef = Globals.asLeftAltKey)
     THEN  dwTempBitFlags := Globals.btLeftAltHotKey;
   {if-then}
   IF  (sParamDef = Globals.asRightAltKey)
     THEN  dwTempBitFlags := Globals.btRightAltHotKey;
   {if-then}
   IF  (sParamDef = Globals.asScrollLockKey)
     THEN  dwTempBitFlags := Globals.btScrollLockHotKey;
   {if-then}
   IF  (sParamDef = Globals.asNumLockKey)
     THEN  dwTempBitFlags := Globals.btNumLockHotKey;
   {if-then}
   IF  (sParamDef = Globals.asCapsLockKey)
     THEN  dwTempBitFlags := Globals.btCapsLockHotKey;
   {if-then}
   dbTempCode := _fndwGetValue(iErrCode,System.Copy(sParamDef,2,System.Length(sParamDef)-2));
   IF  (iErrCode <> 0)
      THEN  dbTempCode := 0;
   IF  (dwTempBitFlags <> 0)
      THEN  BEGIN
        CASE  (dbHotKeyMode)   OF
            Globals.aStateIsIdleMode        :      BEGIN
                     gdwCurIdleModeHotkey := gdwCurIdleModeHotkey + dwTempBitFlags;
                                           END;
            Globals.aStateIsManualMode      :      BEGIN
                     gdwCurManualModeHotkey := gdwCurManualModeHotkey + dwTempBitFlags;
                                           END;
            Globals.aStateIsAddMode        :      BEGIN
                     gdwCurAddModeHotkey := gdwCurAddModeHotkey + dwTempBitFlags;
                                           END;
            Globals.aStateIsSearchMode      :      BEGIN
                     gdwCurSearchModeHotkey := gdwCurSearchModeHotkey + dwTempBitFlags;
                                           END;
            Globals.aStateIsEnvMode         :      BEGIN
                     gdwCurEnvironmentHotKey := gdwCurEnvironmentHotKey + dwTempBitFlags;
                                           END;
             Globals.aStateIsVidMode        :      BEGIN
                     gdwCurVideoIndicationHotKey := gdwCurVideoIndicationHotKey + dwTempBitFlags;
                                           END;
        ELSE
          Video._HaltProgram(Messages._fnsTextMessageByIndex(59)+
                       ' '+Strlib._fnsNumToStr(dwCurFileLine,5)+'.',
                       Globals.errBadKeyboardHotKeyDefinitionStatement);
        END;
        {case-of}
            END
      ELSE  BEGIN
        IF  (dbTempCode <> 0)
          THEN  BEGIN
             CASE  (dbHotKeyMode)   OF
                 Globals.aStateIsIdleMode        :      BEGIN
                          gdbCurIdleModeScanCode := dbTempCode;
                                                END;
                 Globals.aStateIsManualMode      :      BEGIN
                          gdbCurManualModeScanCode := dbTempCode;
                                                END;
                 Globals.aStateIsAddMode        :      BEGIN
                          gdbCurAddModeScanCode := dbTempCode;
                                                END;
                 Globals.aStateIsSearchMode      :      BEGIN
                          gdbCurSearchModeScanCode := dbTempCode;
                                                END;
                 Globals.aStateIsEnvMode         :      BEGIN
                          gdbCurEnvironmentScanCode := dbTempCode;
                                                END;
                  Globals.aStateIsVidMode        :      BEGIN
                          gdbCurVideoIndicationScanCode := dbTempCode;
                                                END;
             ELSE
               Video._HaltProgram(Messages._fnsTextMessageByIndex(60)+
                            ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                            Globals.errBadScanCodeForHotKeyDefinition);
             END;
             {case-of}
                END
          ELSE Video._HaltProgram(Messages._fnsTextMessageByIndex(61)+
                            ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                            Globals.errBadKeyboardHotKeyDefinition);
        {if-then-else}
            END;
   {if-then-else}
END;
{ _ProcessKeyboardHotKeyBitDefinition }

FUNCTION
        _fnbKeywordFound(sInputTemp,
                         sKeywordDef : STRING) : System.Boolean;
{*
Description.
   Detect a presence of a keyword in the string.
*}
VAR
  bResult  :   System.Boolean;
BEGIN
  _fnbKeywordFound := (System.Pos(sKeywordDef,sInputTemp) <> 0);
END;
{ _fnbKeywordFound }

FUNCTION
        _fndbSortingOrderType(sSortOrderType : STRING) : System.Byte;
{*
Description.
     Sets the sorting order from the definition string.
*}
CONST
  aUnknownSortingOrderType  =  $FF;
VAR
  dbSortingOrderType   :   System.Byte;
BEGIN
  dbSortingOrderType := aUnknownSortingOrderType;
  IF  (sSortOrderType = Globals.asNoneOrder)
    THEN  dbSortingOrderType := Globals.aNoneSortingOrder;
  {if-then}
  IF  (sSortOrderType = Globals.asAscendingOrder)
    THEN  dbSortingOrderType := Globals.aAscendingSortingOrder;
  {if-then}
  IF  (sSortOrderType = Globals.asDescendingOrder)
    THEN  dbSortingOrderType := Globals.aDescendingSortingOrder;
  {if-then}
  IF (dbSortingOrderType = aUnknownSortingOrderType)
    THEN   Video._HaltProgram(Messages._fnsTextMessageByIndex(62)+
                        ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                        Globals.errBadSortingOrderType);
  {if-then}
  _fndbSortingOrderType := dbSortingOrderType;
END;
{ _fndbSortingOrderType }

FUNCTION
         _fndbSearchTypeForDictionary(sSearchDictType : STRING) : System.Byte;
{*
Description.
    Sets the dictionary search type from the definition string.
*}
CONST
  aUnknownSearchType  =  $FF;
VAR
  dbDictSearchType   :   System.Byte;
BEGIN
  dbDictSearchType := aUnknownSearchType;
  IF  (sSearchDictType = Globals.asFirstFitType)
    THEN  dbDictSearchType := Globals.aFirstFitType;
  {if-then}
  IF  (sSearchDictType = Globals.asBestFitType)
    THEN  dbDictSearchType := Globals.aBestFitType;
  {if-then}
  IF  (sSearchDictType = Globals.asLastFitType)
    THEN  dbDictSearchType := Globals.aLastFitType;
  {if-then}
  IF (dbDictSearchType = aUnknownSearchType)
    THEN   Video._HaltProgram(Messages._fnsTextMessageByIndex(434)+
                        ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                        Globals.errBadDictSearchType);
  {if-then}
  _fndbSearchTypeForDictionary := dbDictSearchType;
END;
{ _fndbSearchTypeForDictionary }

FUNCTION
        _fnbParameterState(sParm,
                           sVarOn,
                           sVarOff : STR8) : System.Boolean;
{*
Description.
    Returns a boolean state based on the string description.
*}
VAR
  bValue : System.Boolean;
BEGIN
  IF  (sParm = sVarOn)
    THEN  bValue := System.True
    ELSE  BEGIN
      IF  (sParm = sVarOff)
        THEN  bValue := System.False
        ELSE  Video._HaltProgram(Messages._fnsTextMessageByIndex(435)+
                        ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                        Globals.errBadBooleanParameterState);
      {if-then-else}
          END;
  {if-then-else}
  _fnbParameterState := bValue;
END;  { _fnbParameterState }

PROCEDURE
        _CheckPresenseKeyword_TO;
{*
Description.
      Halts a program with a error message displaying.
*}
BEGIN
   IF (_fnsGetNextItemInStr(sParameter) <> Globals.asTranslateTo)
     THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(71)+
                        ' '+Globals.asTranslateTo+
                        ' '+
                        Messages._fnsTextMessageByIndex(72)+
                        ' '+
                        StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                        Globals.errNoKeywordToTranslate);
   {if-then}
END;
{ _CheckPresenseKeyword_TO }


BEGIN
   _OutputMessage(Messages._fnsTextMessageByIndex(63)+' '+sConfigName,
                  System.True);

  {attempt to open the file}
    System.Assign(fStruc,sConfigName);
{$IFDEF   ComVer}
    System.SetTextBuf(fStruc,gdbLargeTextInBuf);
{$ENDIF} {ComVer}

  {turn I/O check off at file opening}
    {$I-}  System.Reset(fStruc);  {$I+}

  {check if the file successfull opened?}
    IF  (System.IoResult <> Globals.errOK)
        THEN  BEGIN
          IF (bStopOnError)
            THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(64),
                               Globals.errOpenConfigFile)
            ELSE  System.Exit;
          {if-then-else}
              END;
    {if-then}

    dwCurSection := aUndefinedSectionNum;
    dwPassedSections := 0;
    dwCurFileLine := 0;

    WHILE  NOT(System.Eof(fStruc))  DO
    BEGIN
        bReadOk := System.False;
        System.Inc(dwCurFileLine);
        {$I-} System.ReadLn(fStruc,sInputLine); {$I+}
        IF  (System.IoResult = Globals.errOK)
           THEN  bReadOk := System.True
           ELSE  BEGIN
                Video._HaltProgram(Messages._fnsTextMessageByIndex(65),
                             Globals.errReadConfigFile);
                 END;
        {if-then-else}

        sInputLine := StrLib._fnsRemoveLeadingWhiteSpaces(StrLib._fnsRemoveAllComments(sInputLine));
        IF  (sInputLine <> Globals.asBlank)
           THEN  BEGIN
             IF  (sInputLine[1] = Globals.achOpeningBracket)
               THEN  BEGIN
                 bScanOK := System.False;
                 IF  (_fnbKeywordFound(sInputLine,Globals.achOpeningBracket+
                                                  Globals.asKeyboardSection+
                                                  Globals.achClosingBracket))
                   THEN  BEGIN
                      dwCurSection := Globals.aKeyboardSectionNum;
                      bScanOK := System.True;
{$IFDEF   DebVer}
                      IF  ((Globals.gdwDebugLevel AND Globals.btTraceConfig) <> 0)
                         THEN  _OutputDebugMessage(Messages._fnsTextMessageByIndex(66)+
                                                   ' '+
                                                   Globals.achOpeningBracket+
                                                   Globals.asKeyboardSection+
                                                   Globals.achClosingBracket,
                                                   aModuleConfig);
                      {if-then}
{$ENDIF} {DebVer}
                         END;
                 {if-then}
                 IF  (_fnbKeywordFound(sInputLine,Globals.achOpeningBracket+
                                                  Globals.asOptionsSection+
                                                  Globals.achClosingBracket))
                   THEN  BEGIN
                      dwCurSection := Globals.aOptionsSectionNum;
                      bScanOK := System.True;
{$IFDEF   DebVer}
                      IF  ((Globals.gdwDebugLevel AND Globals.btTraceConfig) <> 0)
                         THEN  _OutputDebugMessage(Messages._fnsTextMessageByIndex(66)+
                                                   ' '+
                                                   Globals.achOpeningBracket+
                                                   Globals.asOptionsSection+
                                                   Globals.achClosingBracket,
                                                   aModuleConfig);
                      {if-then}
{$ENDIF} {DebVer}
                         END;
                 {if-then}
                 IF  (_fnbKeywordFound(sInputLine,Globals.achOpeningBracket+
                                                  Globals.asDictionarySection+
                                                  Globals.achClosingBracket))
                   THEN  BEGIN
                     dwCurSection := Globals.aDictionarySectionNum;
                     bScanOK := System.True;
                     sLastUserEntry := Globals.asBlank;
                     sLastUserAbbreviation := Globals.asBlank;
                     dbSearchType := Globals.aSearchUndefined;
{$IFDEF   DebVer}
                     IF  ((Globals.gdwDebugLevel AND Globals.btTraceConfig) <> 0)
                          THEN  _OutputDebugMessage(Messages._fnsTextMessageByIndex(66)+
                                                    ' '+
                                                    Globals.achOpeningBracket+
                                                    Globals.asDictionarySection+
                                                    Globals.achClosingBracket,
                                                    aModuleConfig);
                     {if-then}
{$ENDIF} {DebVer}
                         END;
                 {if-then}
                 IF  (NOT(bScanOK))
                   THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(67)+
                                   ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                      Globals.errBadSectionHeader)
                   ELSE  BEGIN
                      chOpeningDelim := Globals.achNULL;
                      chClosingDelim := Globals.achNULL;
                         END;
                 {if-then-else}
                     END
               ELSE  BEGIN
                  CASE  (dwCurSection)  OF
                      Globals.aKeyboardSectionNum :
                                        BEGIN
                           bScanOK := System.False;
                           bKeywordEntryOk := System.False;
                           dbKbdMode := $FF;
                           IF  (_fnbKeywordFound(sInputLine,Globals.asOpeningDelimiter))
                             THEN  BEGIN
                               chOpeningDelim := _fnchGetSymbolParm(sInputLine,
                                                    Globals.asOpeningDelimiter,
                                                    Globals.achNULL,
                                                    Globals.achNULL);
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asClosingDelimiter))
                             THEN  BEGIN
                               chClosingDelim := _fnchGetSymbolParm(sInputLine,
                                                    Globals.asClosingDelimiter,
                                                    Globals.achNULL,
                                                    Globals.achNULL);
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asColorVideoAttr))
                             THEN  BEGIN
                               Globals.gdbCurColorVideoAttr:=
                      System.Byte(_fnchGetSymbolParm(sInputLine,Globals.asColorVideoAttr,
                                  chOpeningDelim,chClosingDelim));
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asMonoVideoAttr))
                             THEN  BEGIN
                               Globals.gdbCurMonoVideoAttr:=
                      System.Byte(_fnchGetSymbolParm(sInputLine,Globals.asMonoVideoAttr,
                                  chOpeningDelim,chClosingDelim));
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asActiveModeBorder))
                             THEN  BEGIN
                               Globals.gdbCurActiveModeBorder  :=
                      System.Byte(_fnchGetSymbolParm(sInputLine,Globals.asActiveModeBorder,
                                  chOpeningDelim,chClosingDelim));
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asIdleModeBorder))
                             THEN  BEGIN
                               Globals.gdbCurIdleModeBorder :=
                      System.Byte(_fnchGetSymbolParm(sInputLine,Globals.asIdleModeBorder,
                                  chOpeningDelim,chClosingDelim));
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asForwardSearchSymbol))
                             THEN  BEGIN
                               Globals.gchCurForwardSearchSymbol :=
                                 _fnchGetSymbolParm(sInputLine,Globals.asForwardSearchSymbol,
                                                    chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asBackwardSearchSymbol))
                             THEN  BEGIN
                               Globals.gchCurBackwardSearchSymbol :=
                                 _fnchGetSymbolParm(sInputLine,Globals.asBackwardSearchSymbol,
                                                    chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asNonSpecialSymbol))
                             THEN  BEGIN
                               Globals.gchCurNonSpecialSymbol :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asNonSpecialSymbol,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asSearchAbbrevSymbol))
                             THEN  BEGIN
                               Globals.gchCurSearchAbbrevSymbol :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asSearchAbbrevSymbol,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asSearchExpressionSym))
                             THEN  BEGIN
                               Globals.gchCurSearchExpressionSymbol :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asSearchExpressionSym,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asDirectionSearchOrderSym))
                             THEN  BEGIN
                               Globals.gchCurDirectionSearchOrderSym :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asDirectionSearchOrderSym,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asDictSearchOrderSym))
                             THEN  BEGIN
                               Globals.gchCurDictSearchOrderSym :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asDictSearchOrderSym,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                   END;
                           {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asCaseSensitiveSearchSym))
                            THEN  BEGIN
                               Globals.gchCurCaseSearchSym :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asCaseSensitiveSearchSym,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asMiddleSearchSym))
                            THEN  BEGIN
                               Globals.gchCurMiddleSrchSym :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asMiddleSearchSym,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asBreakInputSym))
                            THEN  BEGIN
                               Globals.gchCurBreakInputSym :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asBreakInputSym,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asSingleWordSearchSym))
                            THEN  BEGIN
                               Globals.gchCurSingleWordSearchSym :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asSingleWordSearchSym,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asDelimDefinitionSym))
                            THEN  BEGIN
                               Globals.gchCurDelimDefinitionSym :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asDelimDefinitionSym,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asNonDefSym))
                            THEN  BEGIN
                               Globals.gchCurNonDefSym :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asNonDefSym,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asOpenNumericSym))
                            THEN  BEGIN
                               Globals.gchCurOpenNumericSym :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asOpenNumericSym,
                                                      chOpeningDelim,chClosingDelim);
                               bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asCloseNumericSym))
                            THEN  BEGIN
                               Globals.gchCurCloseNumericSym :=
                                   _fnchGetSymbolParm(sInputLine,Globals.asCloseNumericSym,
                                                      chClosingDelim,chClosingDelim);
                               bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asIdleModeHotkey))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asIdleModeHotkey;
                                dbKbdMode := Globals.aStateIsIdleMode;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asManualModeHotkey))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asManualModeHotkey;
                                dbKbdMode := Globals.aStateIsManualMode;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asAddModeHotkey))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asAddModeHotkey;
                                dbKbdMode := Globals.aStateIsAddMode;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asSearchModeHotkey))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asSearchModeHotkey;
                                dbKbdMode := Globals.aStateIsSearchMode;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asEnvironmentSwitch))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asEnvironmentSwitch;
                                dbKbdMode := Globals.aStateIsEnvMode;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asVideoIndicationSwitch))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asVideoIndicationSwitch;
                                dbKbdMode := Globals.aStateIsVidMode;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (bKeywordEntryOk)
                            THEN  BEGIN
                              sParameter := _fnsExtractParameter(sInputLine,sKeywordEntry);
                              sUserEntry := Globals.asBlank;
                              WHILE (System.Length(sParameter) <> 0) DO
                              BEGIN
                                  sUserEntry := _fnsGetNextItemInStr(sParameter);
                                  sUserEntry := _fnsGetUserSubEntryString(sUserEntry);
                                  _ProcessKeyboardHotKeyBitDefinition(sUserEntry,dbKbdMode);
                                  dbTempStrLen := System.Length(sUserEntry)+2;
                                  System.Delete(sParameter,1,dbTempStrLen);
                                  sParameter := Strlib._fnsSkipDelimiter(sParameter);
                              END;
                              {while-do}
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asInitSearchFlags))
                            THEN  BEGIN
                              sParameter := _fnsExtractParameter(sInputLine,Globals.asInitSearchFlags);
                              {*sUserEntry := asBlank;*}
                              sLastUserEntry := Globals.asBlank;
                              WHILE (System.Length(sParameter) <> 0) DO
                              BEGIN
                                  sUserEntry := _fnsGetNextItemInStr(sParameter);
                                  IF (sUserEntry[1] = chOpeningDelim)
                                    THEN  BEGIN
                           sUserEntry := _fnsGetUserSubEntryString(sUserEntry);
                           dbTempStrLen := System.Length(sUserEntry)+2;
                                          END
                                    ELSE  BEGIN
                           dbTempStrLen := System.Length(sUserEntry);
                           sUserEntry := System.Char(_fndbGetNumericParm(sUserEntry,chOpeningDelim,chClosingDelim));
                                          END;
                                  {if-then-else}
                                  System.Delete(sParameter,1,dbTempStrLen);
                                  sLastUserEntry := sLastUserEntry + sUserEntry;
                                  sParameter := Strlib._fnsSkipDelimiter(sParameter);
                              END;
                              {while-do}
                              Globals.gdwCurInitSearchFlags := _fndwGetSearchFlags(sLastUserEntry);
                              bScanOK := System.True;
                                  END;
                          {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asDictName))
                             THEN  BEGIN
                              sParameter := _fnsExtractParameter(sInputLine,Globals.asDictName);
                              sUserEntry := _fnsGetUserSubEntryString(_fnsGetNextItemInStr(sParameter));
                              Globals.gsCurDictName16 := System.Copy(sUserEntry,1,System.SizeOf(DictNameSTR16));
                              bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asDictComment))
                             THEN  BEGIN
                              sParameter := _fnsExtractParameter(sInputLine,Globals.asDictComment);
                              sUserEntry := _fnsGetUserSubEntryString(_fnsGetNextItemInStr(sParameter));
                              Globals.gsCurDictComment32 := System.Copy(sUserEntry,1,System.SizeOf(DictCommentSTR32));
                              bScanOK := System.True;
                                   END;
                           {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asNoMoreEntry))
                            THEN  BEGIN
                              sParameter := _fnsExtractParameter(sInputLine,Globals.asNoMoreEntry);
                              dwCurSection := Globals.aUndefinedSectionNum;
                              System.Inc(dwPassedSections);
                              bScanOK := System.True;
                                   END;
                          {if-then}
                           IF  (NOT(bScanOK))
                             THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(68)+
                                          ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                          Globals.errBadKeyboardSubSectionStatement);
                           {if-then}
                                            END;
                      Globals.aOptionsSectionNum  :
                                             BEGIN
                           bScanOK := System.False;
                           bKeywordEntryOk := System.False;
                           IF  (_fnbKeywordFound(sInputLine,Globals.asOpeningDelimiter))
                             THEN  BEGIN
                               chOpeningDelim := _fnchGetSymbolParm(sInputLine,
                                                    Globals.asOpeningDelimiter,
                                                    Globals.achNULL,
                                                    Globals.achNULL);
                               bScanOK := System.True;
                                   END;
                           {if-then}
                           IF  (_fnbKeywordFound(sInputLine,Globals.asClosingDelimiter))
                             THEN  BEGIN
                               chClosingDelim := _fnchGetSymbolParm(sInputLine,
                                                    Globals.asClosingDelimiter,
                                                    Globals.achNULL,
                                                    Globals.achNULL);
                               bScanOK := System.True;
                                   END;
                           {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asAutoAddChar))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asAutoAddChar;
                                dwOptionsFlags := Globals.btAutoAddChar;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asVideoIndicationOn))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asVideoIndicationOn;
                                dwOptionsFlags := Globals.btVideoIndicationOn;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asUseTableCompression))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asUseTableCompression;
                                dwOptionsFlags := Globals.btUseTableCompression;
                                bKeywordEntryOk := System.True;
                                  END;
                          IF  (_fnbKeywordFound(sInputLine,Globals.asUseNodeCompression))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asUseNodeCompression;
                                dwOptionsFlags := Globals.btUseNodeCompression;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asClickOnModeChange))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asClickOnModeChange;
                                dwOptionsFlags := Globals.btClickOnModeChange;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asFilterRawInput))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asFilterRawInput;
                                dwOptionsFlags := Globals.btFilterRawInput;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asAddPaddingZero))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asAddPaddingZero;
                                dwOptionsFlags := Globals.btAddPaddingZero;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asRecognizeMetaSymbols))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asRecognizeMetaSymbols;
                                dwOptionsFlags := Globals.btRecognizeMetaSymbols;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asAutoPutScanCode))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asAutoPutScanCode;
                                dwOptionsFlags := Globals.btAutoPutScanCode;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asUseForMSWord))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asUseForMSWord;
                                dwOptionsFlags := Globals.btUseForMSWord;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asUseForOldNorton1986))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asUseForOldNorton1986;
                                dwOptionsFlags := Globals.btUseForOldNorton1986;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asSetBorderColorAsMarker))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asSetBorderColorAsMarker;
                                dwOptionsFlags := Globals.btSetBorderColorAsMarker;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asUseInt154F))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asUseInt154F;
                                dwOptionsFlags := Globals.btUseInt154F;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asUseInt1601))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asUseInt1601;
                                dwOptionsFlags := Globals.btUseInt1601;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asEmptyAbbreviation))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asEmptyAbbreviation;
                                dwOptionsFlags := Globals.btEmptyAbbreviation;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asFlushInputOnCR))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asFlushInputOnCR;
                                dwOptionsFlags := Globals.btFlushInputOnCR;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (bKeywordEntryOk)
                            THEN  BEGIN
                              sParameter := _fnsExtractParameter(sInputLine,sKeywordEntry);
                              sUserEntry := _fnsGetUserSubEntryString(_fnsGetNextItemInStr(sParameter));
                              IF  (sUserEntry = Globals.asDefaultYes)
                                THEN  BEGIN
                                    Globals.gdwCurUserEnvOptions :=
                                Globals.gdwCurUserEnvOptions OR dwOptionsFlags;
                                      END
                                ELSE BEGIN
                                  IF  (sUserEntry = Globals.asDefaultNo)
                                     THEN BEGIN
                                        Globals.gdwCurUserEnvOptions :=
                Globals.gdwCurUserEnvOptions AND (Globals.aFullWord - dwOptionsFlags);
                                          END
                                     ELSE  Video._HaltProgram(Messages._fnsTextMessageByIndex(69)+
                                                ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                                Globals.errBadOptionsParameterKeyword);
                                  {if-then-else}
                                     END;
                              {if-then-else}
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asCaseTranslate))
                            THEN  BEGIN
                                  sParameter := _fnsExtractParameter(sInputLine,Globals.asCaseTranslate);
                                  sUserAbbreviation := _fnsGetNextItemInStr(sParameter);
                              IF (sUserAbbreviation = Globals.asBlank)
                                THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(70)+
                                                   ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                                   Globals.errEmptyUserTranslateCharFrom);
                              {if-then}
                              chTranslateFrom := System.Char(_fndbGetNumericParm(sUserAbbreviation,
                                                          chOpeningDelim,chClosingDelim));
                              System.Delete(sParameter,1,System.Length(sUserAbbreviation)+2);
                              sParameter := Strlib._fnsSkipDelimiter(sParameter);
                              _CheckPresenseKeyword_TO;
                              sParameter := Strlib._fnsSkipDelimiter(_fnsExtractParameter(sParameter,
                                                                                   Globals.asTranslateTo));
                              sUserEntry := _fnsGetNextItemInStr(sParameter);
                              IF  (sUserEntry <> Globals.asBlank)
                                THEN
                                   chTranslateTo := System.Char(_fndbGetNumericParm(sUserEntry,
                                                     chOpeningDelim,chClosingDelim))
                                ELSE
                                   chTranslateTo := Globals.achNULL;
                              {if-then-else}
                              Globals.gchCurCaseMapArray256[System.Byte(chTranslateFrom)] := chTranslateTo;
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asAddScanCode))
                            THEN  BEGIN
                                  sParameter := _fnsExtractParameter(sInputLine,Globals.asAddScanCode);
                                  sUserAbbreviation := _fnsGetNextItemInStr(sParameter);
                              IF (sUserAbbreviation = Globals.asBlank)
                                THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(70)+
                                                   ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                                   Globals.errEmptyUserTranslateCharFrom);
                              {if-then}
                              dbScanCode := _fndbGetNumericParm(sUserAbbreviation,chOpeningDelim,chClosingDelim);
                              System.Delete(sParameter,1,System.Length(sUserAbbreviation)+2);
                              sParameter := Strlib._fnsSkipDelimiter(sParameter);
                              _CheckPresenseKeyword_TO;
                              sParameter := Strlib._fnsSkipDelimiter(_fnsExtractParameter(sParameter,
                                                                                   Globals.asTranslateTo));
                              sUserEntry := _fnsGetNextItemInStr(sParameter);
                              IF  (sUserEntry <> Globals.asBlank)
                                THEN
                                   dbAsciiCode := _fndbGetNumericParm(sUserEntry,
                                                     chOpeningDelim,chClosingDelim)
                                ELSE
                                   dbAsciiCode := $0;
                              {if-then-else}
                              Globals.gdbCurScanCodeTable256[dbAsciiCode] := dbScanCode;
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asAddSortIgnoreCase))
                            THEN  BEGIN
                                  sParameter := _fnsExtractParameter(sInputLine,Globals.asAddSortIgnoreCase);
                                  sUserAbbreviation := _fnsGetNextItemInStr(sParameter);
                              IF (sUserAbbreviation = Globals.asBlank)
                                THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(70)+
                                                   ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                                   Globals.errEmptyUserAddIgnoreCase);
                              {if-then}
                              dbAsciiCode := _fndbGetNumericParm(sUserAbbreviation,chOpeningDelim,chClosingDelim);
                              System.Delete(sParameter,1,System.Length(sUserAbbreviation)+2);
                              sParameter := Strlib._fnsSkipDelimiter(sParameter);
                              _CheckPresenseKeyword_TO;
                              sParameter := Strlib._fnsSkipDelimiter(_fnsExtractParameter(sParameter,
                                                                                   Globals.asTranslateTo));
                              sUserEntry := _fnsGetNextItemInStr(sParameter);
                              IF  (sUserEntry <> Globals.asBlank)
                                THEN
                                   dwTempNum := _fndwGetNumericParm(sUserEntry,
                                                     chOpeningDelim,chClosingDelim)
                                ELSE
                                   dwTempNum := $0;
                              {if-then-else}
                              Globals.gdwSortingArrayCaseIgnore[dbAsciiCode] := dwTempNum;
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asAddSortMatchCase))
                            THEN  BEGIN
                                  sParameter := _fnsExtractParameter(sInputLine,Globals.asAddSortMatchCase);
                                  sUserAbbreviation := _fnsGetNextItemInStr(sParameter);
                              IF (sUserAbbreviation = Globals.asBlank)
                                THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(70)+
                                                   ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                                   Globals.errEmptyUserAddIgnoreCase);
                              {if-then}
                              dbAsciiCode := _fndbGetNumericParm(sUserAbbreviation,chOpeningDelim,chClosingDelim);
                              System.Delete(sParameter,1,System.Length(sUserAbbreviation)+2);
                              sParameter := Strlib._fnsSkipDelimiter(sParameter);
                              _CheckPresenseKeyword_TO;
                              sParameter := Strlib._fnsSkipDelimiter(_fnsExtractParameter(sParameter,
                                                                                   Globals.asTranslateTo));
                              sUserEntry := _fnsGetNextItemInStr(sParameter);
                              IF  (sUserEntry <> Globals.asBlank)
                                THEN
                                   dwTempNum := _fndwGetNumericParm(sUserEntry,
                                                     chOpeningDelim,chClosingDelim)
                                ELSE
                                   dwTempNum := $0;
                              {if-then-else}
                              Globals.gdwSortingArrayCaseMatch[dbAsciiCode] := dwTempNum;
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asCharInWord))
                            THEN  BEGIN
                                  sParameter := _fnsExtractParameter(sInputLine,Globals.asCharInWord);
                                  sUserAbbreviation := _fnsGetNextItemInStr(sParameter);
                              IF (sUserAbbreviation = Globals.asBlank)
                                THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(70)+
                                                   ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                                   Globals.errEmptyUserCharInWord);
                              {if-then}
                              dbScanCode := _fndbGetNumericParm(sUserAbbreviation,chOpeningDelim,chClosingDelim);
                              System.Delete(sParameter,1,System.Length(sUserAbbreviation)+2);
                              sParameter := Strlib._fnsSkipDelimiter(sParameter);
                              _CheckPresenseKeyword_TO;
                              sParameter := Strlib._fnsSkipDelimiter(_fnsExtractParameter(sParameter,
                                                                                   Globals.asTranslateTo));
                              sUserEntry := _fnsGetNextItemInStr(sParameter);
                              IF  (sUserEntry <> Globals.asBlank)
                                THEN
                                   dbBoolTemp := _fndbGetNumericParm(sUserEntry,
                                                     chOpeningDelim,chClosingDelim)
                                ELSE
                                   dbBoolTemp := $0;
                              {if-then-else}
                              Globals.gdbCurWordCharTable256[dbAsciiCode] := dbBoolTemp;
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asSortByAlphabet))
                            THEN  BEGIN
                              sParameter := _fnsGetNextItemInStr(_fnsExtractParameter(sInputLine,
                                                                                      Globals.asSortByAlphabet));
                              Globals.gdbSortByAlphabet := _fndbSortingOrderType(_fnsGetUserSubEntryString((sParameter)));
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asSearchType))
                            THEN  BEGIN
                              sParameter := _fnsGetNextItemInStr(_fnsExtractParameter(sInputLine,
                                                                                      Globals.asSearchType));
                              Globals.gdbCurSearchType :=
                                 _fndbSearchTypeForDictionary(_fnsGetUserSubEntryString((sParameter)));
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asBA_LinkPresent))
                            THEN  BEGIN
                              sParameter := _fnsGetNextItemInStr(_fnsExtractParameter(sInputLine,
                                                                                      Globals.asBA_LinkPresent));
                              Globals.gbLink_BA_Ok :=
                                 _fnbParameterState(_fnsGetUserSubEntryString((sParameter)),
                                                    Globals.asDefaultYes,
                                                    Globals.asDefaultNo);
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asFE_LinkPresent))
                            THEN  BEGIN
                              sParameter := _fnsGetNextItemInStr(_fnsExtractParameter(sInputLine,
                                                                                      Globals.asFE_LinkPresent));
                              Globals.gbLink_FE_Ok :=
                                 _fnbParameterState(_fnsGetUserSubEntryString((sParameter)),
                                                    Globals.asDefaultYes,
                                                    Globals.asDefaultNo);
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asBE_LinkPresent))
                            THEN  BEGIN
                              sParameter := _fnsGetNextItemInStr(_fnsExtractParameter(sInputLine,
                                                                                      Globals.asBE_LinkPresent));
                              Globals.gbLink_BE_Ok :=
                                 _fnbParameterState(_fnsGetUserSubEntryString((sParameter)),
                                                    Globals.asDefaultYes,
                                                    Globals.asDefaultNo);
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asAS_LinkPresent))
                            THEN  BEGIN
                              sParameter := _fnsGetNextItemInStr(_fnsExtractParameter(sInputLine,
                                                                                      Globals.asAS_LinkPresent));
                              Globals.gbLink_AS_Ok :=
                                 _fnbParameterState(_fnsGetUserSubEntryString((sParameter)),
                                                    Globals.asDefaultYes,
                                                    Globals.asDefaultNo);
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asES_LinkPresent))
                            THEN  BEGIN
                              sParameter := _fnsGetNextItemInStr(_fnsExtractParameter(sInputLine,
                                                                                      Globals.asES_LinkPresent));
                              Globals.gbLink_ES_Ok :=
                                 _fnbParameterState(_fnsGetUserSubEntryString((sParameter)),
                                                    Globals.asDefaultYes,
                                                    Globals.asDefaultNo);
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asSortCaseIgnore))
                            THEN  BEGIN
                              sParameter := _fnsGetNextItemInStr(_fnsExtractParameter(sInputLine,
                                                                                      Globals.asSortCaseIgnore));
                              Globals.gbSortCaseIgnore :=
                                 _fnbParameterState(_fnsGetUserSubEntryString((sParameter)),
                                                    Globals.asDefaultYes,
                                                    Globals.asDefaultNo);
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asWordDelim))
                            THEN  BEGIN
                                  sParameter := _fnsExtractParameter(sInputLine,Globals.asWordDelim);
                                  sUserAbbreviation := _fnsGetNextItemInStr(sParameter);
                              IF (sUserAbbreviation = Globals.asBlank)
                                THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(70)+
                                                   ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                                   Globals.errEmptyUserWordDelimiter);
                              {if-then}
                              dbScanCode := _fndbGetNumericParm(sUserAbbreviation,chOpeningDelim,chClosingDelim);
                              dbTempStrLen := System.Length(Globals.gsCurDelimiters16);
                              IF  (dbTempStrLen >= (System.SizeOf(gsCurDelimiters16)-1))
                                THEN  BEGIN
                                   Video._HaltProgram(Messages._fnsTextMessageByIndex(74)+
                                            ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                            Globals.errTooManyWordDelimiters);
                                      END;
                              {if-then}
                              Globals.gsCurDelimiters16 := Globals.gsCurDelimiters16 + System.Char(dbScanCode);
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asAutoLastChar))
                            THEN  BEGIN
                                  sParameter := _fnsExtractParameter(sInputLine,Globals.asAutoLastChar);
                                  sUserAbbreviation := _fnsGetNextItemInStr(sParameter);
                              IF (sUserAbbreviation = Globals.asBlank)
                                THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(70)+
                                                   ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                                   Globals.errEmptyUserAutoLastChar);
                              {if-then}
                              Globals.gchCurAutoAddChar := System.Char(_fndbGetNumericParm(sUserAbbreviation,
                                                                  chOpeningDelim,chClosingDelim));
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asSortBySize))
                            THEN  BEGIN
                              sParameter := _fnsGetNextItemInStr(_fnsExtractParameter(sInputLine,
                                                                                      Globals.asSortBySize));
                              Globals.gdbSortBySize := _fndbSortingOrderType(_fnsGetUserSubEntryString((sParameter)));
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asNoMoreEntry))
                            THEN  BEGIN
                              sParameter := _fnsExtractParameter(sInputLine,Globals.asNoMoreEntry);
                              dwCurSection := Globals.aUndefinedSectionNum;
                              System.Inc(dwPassedSections);
                              bScanOK := System.True;
                                   END;
                          {if-then}
                           IF  (NOT(bScanOK))
                             THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(68)+
                                                ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                                Globals.errBadOptionsSubSectionStatement);
                           {if-then}
                                             END;
                      Globals.aDictionarySectionNum :
                                              BEGIN
                          bScanOK := System.False;
                          bKeywordEntryOk := System.False;
                          IF  (_fnbKeywordFound(sInputLine,Globals.asOpeningDelimiter))
                            THEN  BEGIN
                              chOpeningDelim := _fnchGetSymbolParm(sInputLine,
                                                   Globals.asOpeningDelimiter,
                                                   Globals.achNULL,
                                                   Globals.achNULL);
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asClosingDelimiter))
                            THEN  BEGIN
                              chClosingDelim := _fnchGetSymbolParm(sInputLine,
                                                   Globals.asClosingDelimiter,
                                                   Globals.achNULL,
                                                   Globals.achNULL);
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asAddEntry))
                            THEN  BEGIN
                                sKeywordEntry := Globals.asAddEntry;
                                dbSearchType := Globals.aSearchForwardFromStart;
                                bKeywordEntryOk := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asContinueEntry))
                            THEN  BEGIN
                              bContinueEntry := System.True;
                              bKeywordEntryOk := System.True;
                              dbSearchType := dbLastSearchType;
                              sKeywordEntry := Globals.asContinueEntry;
                                  END
                            ELSE  BEGIN
                              bContinueEntry := System.False;
                              dbLastSearchType := dbSearchType;
                              {dbSearchType := Globals.aSearchUndefined;}
                                  END;
                          {if-then-else}
                          IF  (bKeywordEntryOk)
                            THEN  BEGIN
                              IF (sLastUserEntry <> Globals.asBlank) AND NOT(bContinueEntry)
                                THEN BEGIN
                                   _AddEntryToDictionary(sLastUserAbbreviation,
                                                         sLastUserEntry,
                                                         dbLastSearchType);
                                   sLastUserEntry := Globals.asBlank;
                                   sLastUserAbbreviation := Globals.asBlank;
                                     END;
                              {if-then}
                              sParameter := _fnsExtractParameter(sInputLine,sKeywordEntry);
                              IF  (NOT(bContinueEntry))
                                THEN  BEGIN
                          sUserAbbreviation := _fnsGetUserSubEntryString(_fnsGetNextItemInStr(sParameter));
                          IF  (sUserAbbreviation = Globals.asBlank)
                            THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(73)+
                                            ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                            Globals.errEmptyUserAbbreviation);
                          {if-then}
                          System.Delete(sParameter,1,System.Length(sUserAbbreviation)+2);
                          sParameter := Strlib._fnsSkipDelimiter(sParameter);
                          _CheckPresenseKeyword_TO;
                          sParameter := Strlib._fnsSkipDelimiter(_fnsExtractParameter(sParameter,
                                                                               Globals.asTranslateTo));
                                      END;
                              {if-then}
                              sUserEntry := Globals.asBlank;
                              WHILE  (System.Length(sParameter) <> 0)  DO
                              BEGIN
                                  sUserEntry := _fnsGetNextItemInStr(sParameter);
                                  IF (sUserEntry[1] = chOpeningDelim)
                                    THEN  BEGIN
                           sUserEntry := _fnsGetUserSubEntryString(sUserEntry);
                           dbTempStrLen := System.Length(sUserEntry)+2;
                                          END
                                    ELSE  BEGIN
                           dbTempStrLen := System.Length(sUserEntry);
                           sUserEntry := System.Char(_fndbGetNumericParm(sUserEntry,
                                                     chOpeningDelim,chClosingDelim));
                                          END;
                                  {if-then-else}
                                  System.Delete(sParameter,1,dbTempStrLen);
                                  sLastUserEntry := sLastUserEntry + sUserEntry;
                                  sParameter := Strlib._fnsSkipDelimiter(sParameter);
                              END;
                              {while-do}
                              IF  (sLastUserEntry = Globals.asBlank)
                                THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(75)+
                                                   ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                                   Globals.errEmptyUserDictionaryEntry);
                              {if-then}
                              sLastUserAbbreviation := sUserAbbreviation;
                              bScanOK := System.True;
                                  END;
                          {if-then}
                          IF  (_fnbKeywordFound(sInputLine,Globals.asNoMoreEntry))
                            THEN  BEGIN
                              sParameter := _fnsExtractParameter(sInputLine,Globals.asNoMoreEntry);
                              dwCurSection := Globals.aUndefinedSectionNum;
                              System.Inc(dwPassedSections);
                              bScanOK := System.True;
                              IF (sLastUserEntry <> Globals.asBlank)
                                 THEN    _AddEntryToDictionary(sLastUserAbbreviation,
                                                               sLastUserEntry,
                                                               dbLastSearchType);
                               {if-then}
                                   END;
                          {if-then}
                           IF  (NOT(bScanOK))
                             THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(68)+
                                                ' '+StrLib._fnsNumToStr(dwCurFileLine,5)+'.',
                                                Globals.errBadDictionarySubSectionStatement);
                           {if-then}
                                              END;
                  ELSE
                     Video._HaltProgram(Messages._fnsTextMessageByIndex(76),
                                        Globals.errBadSectionNumber);
                  END;
                  {case-of}
                     END;
        {if-then-else}
                 END;
        {if-then}
    END;
    { while-do }
  {if reading was successful then close this file}
    System.Close(fStruc);
    IF (dwPassedSections = 0)
      THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(77),
                               Globals.errEmptyConfigFile);
    gbConfigDone := System.True;
   {check some hardware limitations}
    IF  (NOT(Globals.gbFoundInt154F))  AND
       ((Globals.gdwCurUserEnvOptions AND btUseInt154F) <> 0)
      THEN  BEGIN
         Video._HaltProgram(Messages._fnsTextMessageByIndex(566),
                            Globals.errNotSupportedInt154F);
            END;
    {if-then}
  {calculate dictionary size}
    System.Inc(Globals.gdwEstimatedDictSize,
               System.SizeOf(Globals.recEnvironmentDesc));
    System.Inc(Globals.gdwEstimatedDictSize,
               _fndwCalcHeadLinkTableSize(Globals.gbLink_FA_Ok,
                                          Globals.btForwardSearchAbbreviation));
    System.Inc(Globals.gdwEstimatedDictSize,
               _fndwCalcHeadLinkTableSize(Globals.gbLink_BA_Ok,
                                          Globals.btBackwardSearchAbbreviation));
    System.Inc(Globals.gdwEstimatedDictSize,
               _fndwCalcHeadLinkTableSize(Globals.gbLink_FE_Ok,
                                          Globals.btForwardSearchExpression));
    System.Inc(Globals.gdwEstimatedDictSize,
               _fndwCalcHeadLinkTableSize(Globals.gbLink_BE_Ok,
                                          Globals.btBackwardSearchExpression));
    System.Inc(Globals.gdwEstimatedDictSize,
               _fndwCalcHeadLinkTableSize(Globals.gbLink_AS_Ok,
                                          Globals.btSearchAbbreviationSizes));
    System.Inc(Globals.gdwEstimatedDictSize,
               _fndwCalcHeadLinkTableSize(Globals.gbLink_ES_Ok,
                                          Globals.btSearchExpressionSizes));
END;
{ _ParseConfigFile }



{BEGIN}
END.
