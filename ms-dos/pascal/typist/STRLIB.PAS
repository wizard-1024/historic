{****************************************************************************
//                            File STRLIB.PAS
//
//                        Strings support library
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/strlib.pas $
//  $RCSfile: strlib.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:56:32 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: strlib.pas $
//      Revision 1.1  1999/01/03 17:56:32  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             STRLIB.PAS                                      }
{ PURPOSE               Strings support library                         }
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
{                       Project Maintence Files                         }
{                       TYPIST.MAK        (auto compiling & linking)    }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       0.01   13-Sep-94  DS  initial release           }
{-----------------------------------------------------------------------}



UNIT
    StrLib;


INTERFACE

USES
    Globals,
    Messages;


FUNCTION   _fnsByteToHexFmt(dbInput : System.Byte) : Globals.STR2;
FUNCTION   _fnsByteToTurboHexFmt(dbInput : System.Byte) : Globals.STR3;
FUNCTION   _fnsWordToHexFmt(dwInput : System.Word) : Globals.STR4;
FUNCTION   _fnsWordToTurboHexFmt(dwInput : System.Word) : Globals.STR5;
FUNCTION   _fnsPointerToTurboHexFmt(pMem : System.Pointer) : Globals.STR11;
FUNCTION   _fnsNumToStr(liNum : System.Longint;
                        dwWidth : System.Word) : STRING;
FUNCTION   _fnsNumToStrNoAdj(liNum : System.Longint;
                             dwWidth : System.Word) : STRING;
FUNCTION   _fnsNumToRealStr(rNum : System.Real;
                            dwWidth,
                            dwDecimals : System.Word) : STRING;
FUNCTION   _fnsNumToRealStrNoAdj(rNum : System.Real;
                                 dwWidth,
                                 dwDecimals : System.Word) : STRING;
FUNCTION   _fndwGetValue(VAR iErrorCode : System.Integer;
                         sInput : STRING)  : System.Word;
FUNCTION   _fnsUpCase(sInput : STRING) : STRING;
FUNCTION   _fnsAddPrefixChars(sInput : STRING;
                              chAdd : System.Char;
                              dwCount,
                              dwMaxStrLen : System.Word) : STRING;
FUNCTION   _fnsReplaceChars(sInput : STRING;
                            chOld,
                            chNew : System.Char) : STRING;
FUNCTION   _fnchGetFirstChar(sInput : STRING) : System.Char;
FUNCTION   _fnsTrailingAddSpacesToMax(sInput : STRING;
                                      dwMaxStrLen : System.Word ) : STRING;
FUNCTION   _fnsLeadingAddSpacesToMax(sInput : STRING;
                                     dwMaxStrLen : System.Word ) : STRING;
FUNCTION   _fnsRemoveLeadingWhiteSpaces(sInput : STRING) : STRING;
FUNCTION   _fnsDisplayStrAsHexDecAndAscii(sInput : STRING;
                                          bDecimal : System.Boolean) : STRING;
FUNCTION   _fnsCharCodeDesc(chIndex : System.Char) : STRING;
FUNCTION   _fnsForceFileExtension(sFileName,
                                  sDefExt : STRING) : STRING;
FUNCTION   _fnsAddBackSlash(sInput : STRING) : STRING;
FUNCTION   _fnsGetNewFileName(VAR dwFileExt : System.Word;
                              sFileNameNoExt : STRING) : STRING;
FUNCTION   _fnsRemoveAllComments(sInput : STRING) : STRING;
FUNCTION   _fnsSkipDelimiter(sInput : STRING) : STRING;
FUNCTION   _fnsBooleanStateOfVarDesc(bVar : System.Boolean) : Globals.STR3;
FUNCTION   _fnsBooleanStateOfVar(bVar : System.Boolean) : Globals.STR3;



IMPLEMENTATION


{*HEX2STR.INC*}
{*=========================== FUNCTIONAL PART ==========================*}



FUNCTION
        _fnsByteToHexFmt(dbInput : System.Byte) : Globals.STR2;
{*
Description.
   Converts a byte to the hexadecimal format number representation.
*}
CONST
    dbHexCharTable : ARRAY[0..15] OF System.Char = '0123456789ABCDEF';
BEGIN
  _fnsByteToHexFmt := dbHexCharTable[dbInput SHR 4] +
                      dbHexCharTable[dbInput AND $0F];
END;
{ _fnsByteToHexFmt }



FUNCTION
        _fnsByteToTurboHexFmt(dbInput : System.Byte) : Globals.STR3;
{*
Description.
   Converts a byte to the Turbo hexadecimal format number representation.
*}
BEGIN
   _fnsByteToTurboHexFmt:= Globals.achHexPrefix + _fnsByteToHexFmt(dbInput);
END;
{ _fnsByteToTurboHexFmt }



FUNCTION
        _fnsWordToHexFmt(dwInput : System.Word) : Globals.STR4;
{*
Description.
     Converts a word to the hexadecimal format number representation.
*}
BEGIN
  _fnsWordToHexFmt := _fnsByteToHexFmt(System.Hi(dwInput)) +
                      _fnsByteToHexFmt(System.Lo(dwInput));
END;
{ _fnsWordToHexFmt }



FUNCTION
       _fnsWordToTurboHexFmt(dwInput : System.Word) : Globals.STR5;
{*
Description.
   Converts a word to the Turbo hexadecimal format number representation.
*}
BEGIN
  _fnsWordToTurboHexFmt := Globals.achHexPrefix + _fnsWordToHexFmt(dwInput);
END;
{ _fnsWordToTurboHexFmt }



FUNCTION
        _fnsPointerToTurboHexFmt(pMem : System.Pointer) : Globals.STR11;
{*
Description.
    Converts a pointer to the hexadecimal format number representation.
*}
BEGIN
  _fnsPointerToTurboHexFmt := Globals.achHexPrefix +
                              _fnsWordToHexFmt(System.Seg(pMem^)) +
                              Globals.achColon +
                              _fnsWordToHexFmt(System.Ofs(pMem^));
END;
{ _fnsPointerToTurboHexFmt }



{*NUM2STR.INC*}
{*=========================== FUNCTIONAL PART ==========================*}


FUNCTION
        _fnsNumToStr(liNum : System.Longint;
                     dwWidth : System.Word) : STRING;
{*
Description.
     Converts a numeric value to its string representation;
     after conversion removes the leading spaces.
*}
VAR
  sTemp : STRING;

BEGIN
  IF  (dwWidth <> 0)
    THEN  System.Str(liNum:dwWidth,sTemp)
    ELSE  System.Str(liNum,sTemp);
  {if-then-else}

  WHILE  ((System.Length(sTemp) <> 0)  AND
          (sTemp[1] = Globals.achSpace))
  DO  System.Delete(sTemp,1,1);
  {while-do}

  _fnsNumToStr := sTemp;
END;
{ _fnsNumToStr }



FUNCTION
        _fnsNumToStrNoAdj(liNum : System.Longint;
                          dwWidth : System.Word) : STRING;
{*
Description.
     Converts a numeric value to its string representation.
*}
VAR
  sTemp : STRING;

BEGIN
  IF  (dwWidth <> 0)
    THEN  System.Str(liNum:dwWidth,sTemp)
    ELSE  System.Str(liNum,sTemp);
  {if-then-else}

  _fnsNumToStrNoAdj := sTemp;
END;
{ _fnsNumToStrNoAdj }



FUNCTION
        _fnsNumToRealStr(rNum : System.Real;
                         dwWidth,
                         dwDecimals : System.Word) : STRING;
{*
Description.
    Converts a real numeric value to its string representation;
    after conversion removes the leading spaces.
*}
VAR
  sTemp : STRING;

BEGIN
  System.Str(rNum:dwWidth:dwDecimals,sTemp);

  WHILE  ((System.Length(sTemp) <> 0)  AND
          (sTemp[1] = Globals.achSpace))
  DO  System.Delete(sTemp,1,1);
  {while-do}

  _fnsNumToRealStr := sTemp;
END;
{ _fnsNumToRealStr }



FUNCTION
        _fnsNumToRealStrNoAdj(rNum : System.Real;
                              dwWidth,
                              dwDecimals : System.Word) : STRING;
{*
Description.
    Converts a real numeric value to its string representation.
*}
VAR
  sTemp : STRING;

BEGIN
  System.Str(rNum:dwWidth:dwDecimals,sTemp);
  _fnsNumToRealStrNoAdj := sTemp;
END;
{ _fnsNumToRealStrNoAdj }



{*STR2NUM.INC*}
{*=========================== FUNCTIONAL PART ==========================*}


FUNCTION  _fndwGetValue(VAR iErrorCode : System.Integer;
                        sInput : STRING) : System.Word;
{*
Description.
     Translates string to its numeric representation. *}
VAR
  dwTempValue  :  System.Word;

BEGIN
   System.Val(sInput,dwTempValue,iErrorCode);
  _fndwGetValue := dwTempValue;
END;
{ _fndwGetValue }



{*STRCONV.INC*}
{*=========================== FUNCTIONAL PART ==========================*}

FUNCTION
        _fnsUpCase(sInput : STRING) : STRING;
{*
Description.
     Translates characters to upper case;
     checks for empty string.
*}
VAR
   dbIndex  :  System.Byte;
   dbCount  :  System.Byte  ABSOLUTE  sInput;

BEGIN
  IF  (dbCount <> 0)
    THEN   FOR  dbIndex := 1  TO  dbCount  DO
        sInput[dbIndex] := System.UpCase(sInput[dbIndex]);
           {for-to-do}
  {if-then}

   _fnsUpCase := sInput;
END;
{  _fnsUpCase }



FUNCTION  _fnsAddPrefixChars(sInput       :  STRING;
                             chAdd        :  System.Char;
                             dwCount,
                             dwMaxStrLen  :  System.Word) : STRING;
{*
Description.
     Inserts prefix character before first character in string
     until maximum length will not reached.
*}
BEGIN
  WHILE  ((System.Length(sInput) < dwMaxStrLen) AND
          (dwCount <> 0))
  DO  System.Insert(chAdd,sInput,1);
  {while-do}

  _fnsAddPrefixChars := sInput;
END;
{ _fnsAddPrefixChars }



FUNCTION
        _fnsReplaceChars(sInput : STRING;
                         chOld,
                         chNew : System.Char) : STRING;
{*
Description.
      Replaces all the occurrences of old character to new char;
      checks for empty string.
*}
VAR
  dbCharCount,
  dbCharIndex  :  System.Byte;

BEGIN
  dbCharCount := System.Length(sInput);
  dbCharIndex := 0;

  WHILE  (dbCharCount <> 0)  DO
  BEGIN
    System.Inc(dbCharIndex);
    IF  (sInput[dbCharIndex] = chOld)
      THEN  sInput[dbCharIndex] := chNew;
    {if-then}
    System.Dec(dbCharCount);
  END;
  {while-do}

  _fnsReplaceChars := sInput;
END;
{ _fnsReplaceChars }



FUNCTION
        _fnchGetFirstChar(sInput : STRING) : System.Char;
{*
Description.
      Returns a first char from string;
      if empty string then returns NULL.
*}
VAR
  chTemp  :  System.Char;

BEGIN
   IF  (System.Length(sInput) <> 0)
     THEN  chTemp := sInput[1]
     ELSE  chTemp := System.Char(Globals.achNULL);
   {if-then-else}

  _fnchGetFirstChar := chTemp;
END;
{ _fnchGetFirstChar }




FUNCTION
        _fnsTrailingAddSpacesToMax(sInput : STRING;
                                   dwMaxStrLen : System.Word ) : STRING;
{*
Description.
     Adds the trailing spaces to string until this is possible.
*}
VAR
   sTemp     :   STRING;
   dwCount   :   System.Word;

BEGIN
  dwCount := System.Length(sInput);

  IF  (dwCount < dwMaxStrLen)
    THEN BEGIN
       dwCount := ((dwMaxStrLen - dwCount) AND $00FF);
       System.FillChar(sTemp[1],dwMaxStrLen,Globals.achSpace);
       sTemp[0] := System.Char(dwCount);
       sInput := sInput + sTemp;
         END;
  {if-then}

  _fnsTrailingAddSpacesToMax := sInput;
END;
{ _fnsTrailingAddSpacesToMax }



FUNCTION
        _fnsLeadingAddSpacesToMax(sInput : STRING;
                                  dwMaxStrLen : System.Word ) : STRING;
{*
Description.
     Adds the leading spaces to string until this is possible.
*}
VAR
   sTemp     :   STRING;
   dwCount   :   System.Word;

BEGIN
  dwCount := System.Length(sInput);

  IF  (dwCount < dwMaxStrLen)
    THEN BEGIN
       dwCount := ((dwMaxStrLen - dwCount) AND $00FF);
       System.FillChar(sTemp[1],dwMaxStrLen,Globals.achSpace);
       sTemp[0] := System.Char(dwCount);
       sInput := sTemp + sInput;
         END;
  {if-then}

  _fnsLeadingAddSpacesToMax := sInput;
END;
{ _fnsLeadingAddSpacesToMax }



FUNCTION
        _fnsRemoveLeadingWhiteSpaces(sInput : STRING) : STRING;
{*
Description.
     Removes all occurrences of leading whitespace from the left side;
     checks for empty string.
*}
BEGIN
   WHILE  ((sInput <> asBlank) AND
           (sInput[1] IN Globals.setUnusedLeadChars))
   DO  System.Delete(sInput,1,1);
   {while-do}

   _fnsRemoveLeadingWhiteSpaces := sInput;
END;
{ _fnsRemoveLeadingWhiteSpaces }



FUNCTION
        _fnsDisplayStrAsHexDecAndAscii(sInput : STRING;
                                       bDecimal : System.Boolean) : STRING;
{*
Description.
    Displays string as mixed hexadecimal/decimal and ASCII representation.
*}
VAR
   sTemp        :       STRING;
   dbStrLen,
   dbIndex      :       System.Byte;
   chTemp       :       System.Char;

BEGIN
   sTemp := asBlank;
   dbStrLen := System.Length(sInput);

   IF  (dbStrLen <> 0)
     THEN   BEGIN
       FOR  dbIndex := 1  TO  dbStrLen  DO
       BEGIN
          chTemp := sInput[dbIndex];
          IF  (chTemp IN Globals.setAscii8_NoCtrl)
            THEN  sTemp := sTemp + chTemp
            ELSE  BEGIN
              sTemp := sTemp + Globals.achLess;
              IF  (bDecimal)
                THEN  sTemp := sTemp + _fnsNumToStr(System.Ord(chTemp),3)
                ELSE  sTemp := sTemp + _fnsByteToHexFmt(System.Byte(chTemp));
              {if-then-else}
              sTemp := sTemp + Globals.achGreater;
                  END;
          {if-then-else}
       END;
       {for-to-do}
            END;
   {if-then}

   _fnsDisplayStrAsHexDecAndAscii := sTemp;
END;
{ _fnsDisplayStrAsHexDecAndAscii }



FUNCTION
        _fnsCharCodeDesc(chIndex : System.Char) : STRING;
{*
Description.
       Returns a character code representation;
       if non-control character then symbol in double quotas
       otherwise as decimal number closed by < and >.
*}
VAR
  sTemp  :  STRING;

BEGIN
  IF  (System.Char(chIndex) IN Globals.setAscii8_NoCtrl)
    THEN  sTemp := achDoubleQuota + chIndex + Globals.achDoubleQuota
    ELSE  sTemp := Globals.achLess + _fnsNumToStr(System.Ord(chIndex),3) +
                   Globals.achGreater;
  {if-then-else}

  _fnsCharCodeDesc := sTemp;
END;
{ _fnsCharCodeDesc }



{*STRFILE.INC*}
{*=========================== FUNCTIONAL PART ==========================*}


FUNCTION
        _fnsForceFileExtension(sFileName,
                               sDefExt : STRING) : STRING;
{*
Description.
    Adds the extension for the filename if extension not present.
*}
BEGIN
   IF  (System.Pos(Globals.achDosDelim,sFileName) = 0)
     THEN  sFileName := sFileName + Globals.achDosDelim + sDefExt;
   {if-then}
  _fnsForceFileExtension := sFileName;
END;
{ _fnsForceFileExtension }



FUNCTION
        _fnsAddBackSlash(sInput : STRING) : STRING;
{*
Description.
     Adds backslash if it not found at the end of string.
*}
BEGIN
   IF  (sInput[System.Length(sInput)] <> Globals.achDosDirSwitch)
     THEN  sInput := sInput + Globals.achDosDirSwitch;
   {if-then}

   _fnsAddBackSlash := sInput;
END;
{ _fnsAddBackSlash }



FUNCTION  _fnsGetNewFileName(VAR dwFileExt : System.Word;
                            sFileNameNoExt : STRING) : STRING;
{*
Description.
     Constructs the new filename based on the number for a file extension;
     range 0..999, i.e. 1000 files.
*}
VAR
  fTextStream   :  System.Text;
  sNewName      :  STRING;
  sFileExt      :  Globals.STR3;
  bFileFound    :  System.Boolean;

BEGIN
    bFileFound := System.True;

    WHILE  (bFileFound)  DO
    BEGIN
       Str(dwFileExt:3,sFileExt);
       sFileExt := _fnsReplaceChars(sFileExt,Globals.achSpace,Globals.achZero);
       sNewName := sFileNameNoExt+Globals.achDosDelim+sFileExt;
       System.Assign(fTextStream,sNewName);
       {$I-}
       System.Reset(fTextStream);
       {$I+}
       IF  (System.IOResult = errOK)
         THEN  BEGIN
           System.Close(fTextStream);
           System.Inc(dwFileExt);
               END
         ELSE  BEGIN
           bFileFound := System.False;
               END;
       {if-then-else}
    END;
    {while-do}

    _fnsGetNewFileName := sNewName;
END;
{ _fnsGetNewFileName }



{*PARSE.INC*}
{*=========================== FUNCTIONAL PART ==========================*}


FUNCTION
        _fnsRemoveAllComments(sInput : STRING) : STRING;
{*
Description.
     Removes all the occurrencs of the comment from the line;
     checks for empty string.
*}
VAR
  sTemp          :   STRING;
  chTemp         :   System.Char;
  dbCountIn,
  dbIndexIn,
  dbIndexOut     :   System.Byte;
  bInComment     :   System.Boolean;

BEGIN
    sTemp := asBlank;
    dbCountIn := System.Length(sInput);
    bInComment := System.False;
    dbIndexIn := 1;
    dbIndexOut := 0;

    WHILE  (dbCountIn <> 0)  DO
    BEGIN
       chTemp := sInput[dbIndexIn];
       IF  (chTemp = Globals.achComment)
         THEN  BEGIN
           IF  (bInComment)
             THEN  bInComment := System.False
             ELSE  bInComment := System.True;
           {if-then-else}
               END
         ELSE  BEGIN
          IF  NOT(bInComment)
            THEN  BEGIN
                System.Inc(dbIndexOut);
                sTemp[dbIndexOut] := chTemp;
                  END;
          {if-then}
               END;
       {if-then-else}
       System.Dec(dbCountIn);
       System.Inc(dbIndexIn);
    END;
    {while-do}

    sTemp[0] := System.Char(dbIndexOut);

   _fnsRemoveAllComments := sTemp;
END;
{ _fnsRemoveAllComments }



FUNCTION
        _fnsSkipDelimiter(sInput : STRING) : STRING;
{*
Description.
   Removes the delimiters from beginning of string;
   checks for empty string.
*}
BEGIN
   WHILE  ((System.Length(sInput) <> 0)  AND
           (sInput[1] IN Globals.setDelimiters))
   DO  System.Delete(sInput,1,1);
   {while-do}

  _fnsSkipDelimiter := sInput;
END;
{ _fnsSkipDelimiter }



FUNCTION
        _fnsBooleanStateOfVarDesc(bVar : System.Boolean) : Globals.STR3;
{*
Description.
    Returns a state of variable as "YES" or "NO" string.
*}
VAR
  sState3  :  Globals.STR3;

BEGIN
  IF  (bVar)
     THEN  sState3 := Messages._fnsTextMessageByIndex(340)
     ELSE  sState3 := Messages._fnsTextMessageByIndex(341);
  {if-then-else}

  _fnsBooleanStateOfVarDesc := sState3;
END;
{ _fnsBooleanStateOfVarDesc }



FUNCTION
        _fnsBooleanStateOfVar(bVar : System.Boolean) : Globals.STR3;
{*
Description.
      Returns a state of variable as "ON" or "OFF" string.
*}
VAR
  sState3  :  Globals.STR3;

BEGIN
  IF  (bVar)
     THEN  sState3 := Messages._fnsTextMessageByIndex(381)
     ELSE  sState3 := Messages._fnsTextMessageByIndex(382);
  {if-then-else}

  _fnsBooleanStateOfVar := sState3;
END;
{ _fnsBooleanStateOfVar }



{BEGIN}
END.
