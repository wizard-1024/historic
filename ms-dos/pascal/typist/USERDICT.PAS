{****************************************************************************
//                            File USERDICT.PAS
//
//                  Diskc user dictionary processing library
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/userdict.pas $
//  $RCSfile: userdict.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:57:54 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: userdict.pas $
//      Revision 1.1  1999/01/03 17:57:54  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             USERDICT.PAS                                    }
{ PURPOSE               User dictionary preprocessor                    }
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
{                       STRLIB.TPU     (strings support library)        }
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
     UserDict;


INTERFACE

USES
    Globals,
    Messages,
    StrLib,
    Video;


FUNCTION    _fnsGetAbbreviationStr(lpNode : Globals.lprecDicEntryDesc) : STRING;
FUNCTION    _fnsGetExpressionStr(lpNode : Globals.lprecDicEntryDesc) : STRING;
PROCEDURE   _SortUserDictionaryOfAbbreviations;
PROCEDURE   _DoDictDiagDump(bFirstCall : System.Boolean);



IMPLEMENTATION

VAR

    gdbCharIndex  :  System.Word;


{*=========================== FUNCTIONAL PART ==========================*}


FUNCTION
        _fnsGetAbbreviationStr(lpNode : Globals.lprecDicEntryDesc) : STRING;
{*
Description.
    Extracts the abbreviation string from a node on the heap.
*}
VAR
 sTemp : STRING;

BEGIN
  WITH  (lpNode^)  DO
  BEGIN
    sTemp[0] := System.Char(dbDicAbbrvSize);
    System.Move(System.Mem[System.Seg(lpDicAbbrvStore^):System.Ofs(lpDicAbbrvStore^)],
                sTemp[1],
                dbDicAbbrvSize);
  END;
  {with-do}

  _fnsGetAbbreviationStr := sTemp;
END;
{ _fnsGetAbbreviationStr }



FUNCTION
        _fnsGetExpressionStr(lpNode : Globals.lprecDicEntryDesc) : STRING;
{*
Description.
       Extracts the expression string from a node on the heap.
*}
VAR
 sTemp : STRING;

BEGIN
  WITH  (lpNode^)  DO
  BEGIN
    sTemp[0] := System.Char(dbEntrySize);
    System.Move(System.Mem[System.Seg(lpDicEntryStore^):System.Ofs(lpDicEntryStore^)],
                sTemp[1],
                dbEntrySize);
  END;
  {with-do}

  _fnsGetExpressionStr := sTemp;
END;
{ _fnsGetExpressionStr }



{*=========================== PROCEDURAL PART ==========================*}


PROCEDURE
         _SortUserDictionaryOfAbbreviations;
{*
Description.
      Sorts the abbreviations dictionary.
*}
CONST
   aLeftLessRight          =       0;
   aLeftEqualRight         =       1;
   aLeftGreaterRight       =       2;

VAR
  lpFirstEntryNode,
  lpTempEntryDesc,
  lpTempEntryDescPrev,
  lpTempNode            :   Globals.lprecDicEntryDesc;
  sLeftAbbreviation,
  sRightAbbreviation    :   STRING;
  dwNodesCount          :   System.Word;
  dbCharIndex,
  dbCompareRes          :   System.Byte;

FUNCTION
        _fndbCompareCharactersByAlphabet(chLeft,
                                         chRight : System.Char) : System.Byte;
{*
Description.
    Compares two characters.
*}
VAR
  dwLeftValue,
  dwRightValue  :  System.Word;
  dbTestRes     :   System.Byte;
BEGIN
   IF  (Globals.gbSortCaseIgnore)
     THEN  BEGIN
        dwLeftValue  := gdwSortingArrayCaseIgnore[System.Byte(chLeft)];
        dwRightValue := gdwSortingArrayCaseIgnore[System.Byte(chRight)];
           END
     ELSE  BEGIN
        dwLeftValue  := gdwSortingArrayCaseMatch[System.Byte(chLeft)];
        dwRightValue := gdwSortingArrayCaseMatch[System.Byte(chRight)];
           END;
   {if-then-else}
   IF  (dwLeftValue = dwRightValue)
     THEN  dbTestRes := aLeftEqualRight;
    {if-then}
   IF  (dwLeftValue < dwRightValue)
     THEN  dbTestRes := aLeftLessRight;
    {if-then}
   IF  (dwLeftValue > dwRightValue)
     THEN  dbTestRes := aLeftGreaterRight;
    {if-then}

   _fndbCompareCharactersByAlphabet := dbTestRes;
END;
{ _fndbCompareCharactersByAlphabet }

FUNCTION
        _fndbCompareNodesByAlphabet(sLeft,
                                    sRight : STRING) : System.Byte;
{*
Description.
     Compares two strings.
*}
VAR
  dbTestRes,
  dbCharIndex,
  dbMinStrLen,
  dbLeftStrLen,
  dbRightStrLen   :   System.Byte;
BEGIN
   dbLeftStrLen := System.Length(sLeft);
   dbRightStrLen := System.Length(sRight);
   dbMinStrLen := dbLeftStrLen;
   IF  (dbLeftStrLen > dbRightStrLen)
     THEN  BEGIN
       dbMinStrLen := dbRightStrLen;
           END;
   {if-then}
   dbCharIndex := 1;
   dbTestRes := aLeftEqualRight;

   WHILE  ((dbCharIndex <= dbMinStrLen)  AND
          (dbTestRes = aLeftEqualRight))
   DO  BEGIN
     dbTestRes  := _fndbCompareCharactersByAlphabet(sLeft[dbCharIndex],
                                                    sRight[dbCharIndex]);
     System.Inc(dbCharIndex);
       END;
   {while-do}
   IF  (dbTestRes = aLeftEqualRight)
     THEN  BEGIN
       CASE  (gdbSortBySize)  OF
          Globals.aNoneSortingOrder        :   BEGIN
                                         {nothing}
                                       END;
          Globals.aAscendingSortingOrder   :   BEGIN
                                        IF  (dbLeftStrLen > dbRightStrLen)
                                          THEN  dbTestRes := aLeftGreaterRight
                                          ELSE  dbTestRes := aLeftLessRight;
                                        {if-then-else}
                                       END;
          Globals.aDescendingSortingOrder  :   BEGIN
                                        IF  (dbLeftStrLen > dbRightStrLen)
                                          THEN  dbTestRes := aLeftLessRight
                                          ELSE  dbTestRes := aLeftGreaterRight;
                                        {if-then-else}
                                       END;
       END;
       {case-of}
           END
     ELSE  BEGIN
       CASE  (gdbSortByAlphabet)  OF
          Globals.aNoneSortingOrder        :   BEGIN
                                         {nothing}
                                       END;
          Globals.aAscendingSortingOrder   :   BEGIN
                                         {nothing}
                                       END;
          Globals.aDescendingSortingOrder  :   BEGIN
                                          IF  (dbTestRes = aLeftGreaterRight)
                                            THEN  dbTestRes := aLeftLessRight
                                            ELSE  dbTestRes := aLeftGreaterRight;
                                          {if-then}
                                       END;
       END;
       {case-of}
           END;
   {if-then-else}

   _fndbCompareNodesByAlphabet := dbTestRes;
END;
{ _fndbCompareNodesByAlphabet }

BEGIN
    Video._OutputMessage(Messages._fnsTextMessageByIndex(36),
                         System.True);
    FOR  dbCharIndex :=  Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
    BEGIN
      dwNodesCount := Globals.gSymFrequencyNodesArrayFA[dbCharIndex];
      IF  (dwNodesCount > 1)
         THEN  BEGIN
           lpTempEntryDesc := Globals.gDirectSearchArray[dbCharIndex];
           lpTempEntryDesc := lpTempEntryDesc^.lpNextDicEntryDesc;
           lpTempEntryDescPrev := lpTempEntryDesc^.lpPrevDicEntryDesc;

           WHILE  (lpTempEntryDesc <> NIL)  DO
           BEGIN
              sLeftAbbreviation := _fnsGetAbbreviationStr(lpTempEntryDescPrev);
              sRightAbbreviation := _fnsGetAbbreviationStr(lpTempEntryDesc);
              dbCompareRes := _fndbCompareNodesByAlphabet(sLeftAbbreviation,sRightAbbreviation);
              IF  (dbCompareRes = aLeftGreaterRight)
                THEN  BEGIN
                  lpTempNode := lpTempEntryDesc^.lpNextDicEntryDesc;
                  lpTempEntryDesc^.lpPrevDicEntryDesc := lpTempEntryDescPrev^.lpPrevDicEntryDesc;
                  lpTempEntryDesc^.lpNextDicEntryDesc := lpTempEntryDescPrev;
                  lpTempEntryDescPrev^.lpPrevDicEntryDesc := lpTempEntryDesc;
                  lpTempEntryDescPrev^.lpNextDicEntryDesc := lpTempNode;
                  IF (lpTempNode <> NIL)
                    THEN  lpTempNode^.lpPrevDicEntryDesc := lpTempEntryDescPrev;
                  {if-then}
                  IF  (lpTempEntryDesc^.lpPrevDicEntryDesc = NIL)
                    THEN  Globals.gDirectSearchArray[dbCharIndex] := lpTempEntryDesc
                    ELSE  (lpTempEntryDesc^.lpPrevDicEntryDesc)^.lpNextDicEntryDesc := lpTempEntryDesc;
                  {if-then-else}
                  lpTempEntryDesc := Globals.gDirectSearchArray[dbCharIndex];
                      END;
              {if-then}
              lpTempEntryDesc := lpTempEntryDesc^.lpNextDicEntryDesc;
              lpTempEntryDescPrev := lpTempEntryDesc^.lpPrevDicEntryDesc;
           END;
           {while-do}
               END;
      {if-then}
    END;
    {for-to-do}
END;
{ _SortUserDictionaryOfAbbreviations }



PROCEDURE
         _DoDictDiagDump(bFirstCall : System.Boolean);
{*
Description.
       Dumps all the dictionaries to the disk in the current directory.
*}
CONST
  dwDumpDictFileExt  :  System.Word = 0;

VAR
  fTextStream        :  Text;
  sTempIndex         :  STRING;
  dbCharIndex        :  System.Byte;
  lpTempEntryDesc    :  Globals.lprecDicEntryDesc;
  dwEntriesCount,
  dwTableTotal       :  System.Word;

FUNCTION
        _fnsSortingOrderTypeDesc(dbSortOrderType : System.Byte) : STRING;
{*
Description.
     Returns the sorting order description.
*}
VAR
  sOrderTypeDesc  :  STRING;
BEGIN
  sOrderTypeDesc := Globals.asBlank;
  CASE  (dbSortOrderType)  OF
      Globals.aNoneSortingOrder       :  sOrderTypeDesc := Globals.asNoneOrder;
      Globals.aAscendingSortingOrder  :  sOrderTypeDesc := Globals.asAscendingOrder;
      Globals.aDescendingSortingOrder :  sOrderTypeDesc := Globals.asDescendingOrder;
  END;
  {case-of}
  _fnsSortingOrderTypeDesc := sOrderTypeDesc;
END;
{ _fnsSortingOrderTypeDesc }


PROCEDURE  _DumpAllNodes(VAR dwDicEntryCount : System.Word;
                         lpFirstNode : lprecDicEntryDesc);
{*
Description.
      Dumps all nodes for a given character.
*}
VAR
  lpDictNode      :  Globals.lprecDicEntryDesc;
  dbCount,
  dbStrIndex      :  System.Byte;
  sTemp           :  STRING;
  chTemp          :  System.Char;
BEGIN
    lpDictNode :=  lpFirstNode;
    WHILE  (lpDictNode <> NIL)  DO
      WITH  (lpDictNode^)  DO
      BEGIN
         System.Inc(dwDicEntryCount);
         sTemp := _fnsGetAbbreviationStr(lpDictNode);
         dbCount := dbDicAbbrvSize;
         sTemp[0] := System.Char(dbCount);
         System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(37)+
                                    ' := '+
                                    Globals.achDoubleQuota+
                                    StrLib._fnsDisplayStrAsHexDecAndAscii(sTemp,System.True)+
                                    Globals.achDoubleQuota);
         dbCount := dbEntrySize;
         System.Move(System.Mem[System.Seg(lpDicEntryStore^):System.Ofs(lpDicEntryStore^)],
                     sTemp[1],
                     dbCount);
         sTemp[0] := System.Char(dbCount);
         System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(38)+
                                    ' := '+
                                    Globals.achDoubleQuota+
                                    StrLib._fnsDisplayStrAsHexDecAndAscii(sTemp,System.True)+
                                    Globals.achDoubleQuota);
         System.WriteLn(fTextStream);
         lpDictNode := lpNextDicEntryDesc;
         IF (lpDictNode = NIL)
            THEN  System.WriteLn(fTextStream);
         {if-then}
      END;
      {with-do}
    {while-do}
END;
{ _DumpAllNodes }

PROCEDURE
         _CreateDumpFile(sFileName,
                         sHeader : STRING);
{*
Description.
    Creates and writse a header to the dumpfile.
*}
VAR
  dbSortDictBySize,
  dbSortDictByAlphabet   :  System.Byte;
BEGIN
    IF  (bFirstCall)
      THEN  BEGIN
        dbSortDictBySize := Globals.aNoneSortingOrder;
        dbSortDictByAlphabet := Globals.aNoneSortingOrder;
            END
      ELSE  BEGIN
        dbSortDictBySize := Globals.gdbSortBySize;
        dbSortDictByAlphabet := Globals.gdbSortByAlphabet;
            END;
    {if-then-else}
    System.Assign(fTextStream,sFileName);
    System.Rewrite(fTextStream);
    System.WriteLn(fTextStream,sHeader);
    System.WriteLn(fTextStream,'<<< '+Messages._fnsTextMessageByIndex(39)+': '+gsConfigFileName+' >>>');
    System.WriteLn(fTextStream,'<<< ('+Messages._fnsTextMessageByIndex(40)+') >>>');
    System.WriteLn(fTextStream,'<<< '+Globals.asSortByAlphabet+'='+
                              _fnsSortingOrderTypeDesc(dbSortDictByAlphabet)+
                              ' >>>');
    System.WriteLn(fTextStream,'<<< '+Globals.asSortBySize+'='+
                              _fnsSortingOrderTypeDesc(dbSortDictBySize)+
                              ' >>>');
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream);
    dwEntriesCount := 0;
END;
{ _CreateDumpFile }

PROCEDURE
         _WriteDumpStatistics;
{*
Description.
     Writes entries per dictionary count.
*}
BEGIN
    IF (dwEntriesCount =  0)
      THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(41))
      ELSE  System.WriteLn(fTextStream,
                           Messages._fnsTextMessageByIndex(42)+
                           ' = ',
                           dwEntriesCount);
    {if-then-else}
END;
{ _WriteDumpStatistics }

PROCEDURE
         _WriteDumpTableHeader(sHeader : STRING);
{*
Description.
     Writes the frequency table text header.
*}
BEGIN
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream,'<<<  '+sHeader+'  >>>');
END;
{ _WriteDumpTableHeader }

PROCEDURE  _DumpNodeFrequency(chSym : System.Char;
                              dwFreqCount : System.Word;
                              bDisplayAsNumeric : System.Boolean);
{*
Description.
     Writes the frequency count for a given character.
*}
VAR
  sTemp5  :  STR5;
BEGIN
   IF  (bDisplayAsNumeric)
     THEN  sTemp5 := _fnsNumToStr(System.Ord(chSym),5)
     ELSE  sTemp5 := StrLib._fnsCharCodeDesc(chSym);
   {if-then-else}
   System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(43)+
                              '  =  ',sTemp5,
                              ';  '+
                              Messages._fnsTextMessageByIndex(44)+
                              '  =  ',dwFreqCount);
END;
{ _DumpNodeFrequency }

PROCEDURE
         _CloseDumpFile;
{*
Description.
      Closes diagnostic dumpfile.
*}
BEGIN
    System.WriteLn(fTextStream);
    System.Close(fTextStream);
END;
{  _CloseDumpFile }

PROCEDURE
         _DumpTotalCountForFrequencyTable(dwTotal : System.Word);
{*
Description.
    Writes a total value for a given frequency table.
*}
BEGIN
   System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(45)+
                              '  =  ',dwTotal);
END;
{ _DumpTotalCountForFrequencyTable }

BEGIN
    Video._OutputMessage(Messages._fnsTextMessageByIndex(162),
                         System.True);
    _CreateDumpFile(StrLib._fnsGetNewFileName(dwDumpDictFileExt,'USERDICT'),
                    '<<< '+
                    Messages._fnsTextMessageByIndex(46)+
                    ' >>>');
    FOR  dbCharIndex := Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
    BEGIN
       lpTempEntryDesc := Globals.gDirectSearchArray[dbCharIndex];
       _DumpAllNodes(dwEntriesCount,lpTempEntryDesc);
    END;
    {for-to-do}
    _WriteDumpStatistics;
    _WriteDumpTableHeader(Messages._fnsTextMessageByIndex(47));
    dwTableTotal := 0;
    FOR  dbCharIndex := Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
    BEGIN
       dwEntriesCount := Globals.gSymFrequencyNodesArrayFA[dbCharIndex];
       System.Inc(dwTableTotal,dwEntriesCount);
       IF  (dwEntriesCount <> 0)
         THEN  _DumpNodeFrequency(System.Char(dbCharIndex),dwEntriesCount,System.False);
       {if-then}
    END;
    {for-to-do}
    _DumpTotalCountForFrequencyTable(dwTableTotal);
    _WriteDumpTableHeader(Messages._fnsTextMessageByIndex(48));
    dwTableTotal := 0;
    FOR  dbCharIndex := Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
    BEGIN
       dwEntriesCount := Globals.gSymFrequencyNodesArrayBA[dbCharIndex];
       System.Inc(dwTableTotal,dwEntriesCount);
       IF  (dwEntriesCount <> 0)
         THEN  _DumpNodeFrequency(System.Char(dbCharIndex),dwEntriesCount,System.False);
       {if-then}
    END;
    {for-to-do}
    _DumpTotalCountForFrequencyTable(dwTableTotal);
    _WriteDumpTableHeader(Messages._fnsTextMessageByIndex(49));
    dwTableTotal := 0;
    FOR  dbCharIndex := Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
    BEGIN
       dwEntriesCount := Globals.gSymFrequencyNodesArrayFE[dbCharIndex];
       System.Inc(dwTableTotal,dwEntriesCount);
       IF  (dwEntriesCount <> 0)
         THEN  _DumpNodeFrequency(System.Char(dbCharIndex),dwEntriesCount,System.False);
       {if-then}
    END;
    {for-to-do}
    _DumpTotalCountForFrequencyTable(dwTableTotal);
    _WriteDumpTableHeader(Messages._fnsTextMessageByIndex(50));
    dwTableTotal := 0;
    FOR  dbCharIndex := Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
    BEGIN
       dwEntriesCount := Globals.gSymFrequencyNodesArrayBE[dbCharIndex];
       System.Inc(dwTableTotal,dwEntriesCount);
       IF  (dwEntriesCount <> 0)
         THEN  _DumpNodeFrequency(System.Char(dbCharIndex),dwEntriesCount,System.False);
       {if-then}
    END;
    _DumpTotalCountForFrequencyTable(dwTableTotal);
    _WriteDumpTableHeader(Messages._fnsTextMessageByIndex(51));
    dwTableTotal := 0;
    FOR  dbCharIndex := Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
    BEGIN
       dwEntriesCount := Globals.gAbbrevSizesFrequencyNodesArray[dbCharIndex];
       System.Inc(dwTableTotal,dwEntriesCount);
       IF  (dwEntriesCount <> 0)
         THEN  _DumpNodeFrequency(System.Char(dbCharIndex),dwEntriesCount,System.True);
       {if-then}
    END;
    _DumpTotalCountForFrequencyTable(dwTableTotal);
    _WriteDumpTableHeader(Messages._fnsTextMessageByIndex(52));
    dwTableTotal := 0;
    FOR  dbCharIndex := Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
    BEGIN
       dwEntriesCount := Globals.gExprSizesFrequencyNodesArray[dbCharIndex];
       System.Inc(dwTableTotal,dwEntriesCount);
       IF  (dwEntriesCount <> 0)
         THEN  _DumpNodeFrequency(System.Char(dbCharIndex),dwEntriesCount,System.True);
       {if-then}
    END;
    {for-to-do}
    _DumpTotalCountForFrequencyTable(dwTableTotal);
    _CloseDumpFile;
END;
{ _DoDictDiagDump }



BEGIN
  {* initialize sorting array *}
    FOR  gdbCharIndex := Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
    BEGIN
       gdwSortingArrayCaseMatch[gdbCharIndex] :=
                  System.Word(gdbCharIndex) * (Globals.aFullByte+1);
       gdwSortingArrayCaseIgnore[gdbCharIndex] :=
                  System.Byte(Globals.gchLowCaseMapArray256[gdbCharIndex]) *
                  Globals.aBitsPerWord;
    END;
    {for-to-do}
END.
