{****************************************************************************
//                            File MAP2EXE.PAS
//
//              Debugging information executable file utility
//
//      Copyright (c) 1995, 1998 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/MAP2EXE/RCS/map2exe.pas $
//  $RCSfile: map2exe.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/17 22:11:24 $ 
// $Revision: 1.2 $ 
//   $Locker: dstef $ 
//
//      $Log: map2exe.pas $
//      Revision 1.2  1998/10/17 22:11:24  dstef
//      Fixed file access denied bug
//
//      Revision 1.1  1998/10/03 14:38:05  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                PUT_DEBUGMAP_TO_EXEFILE                         }
{ FILE NAME             MAP2EXE.PAS                                     }
{ PURPOSE               Put the debug map into executable file          }
{ VERSION               1.16                                            }
{ DATE                  17-Oct-1998                                     }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Telephone: +007 (095) 944-6304                  }
{ INTERNET              wizard@radio-msu.net, dima@mccbn.ru             }
{ COPYRIGHT NOTICE      Copyright (C) 1995, 1998  Dmitry Stefankov      }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,           }
{                       NOT FOR COMMERCIAL PURPOSE                      }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 6.0                        }
{                       (Borland International Inc.) or compatible      }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             <mapfile>     -  input  stream                  }
{                       <exefile>     -  output stream                  }
{                       <pm>          -  process PM application         }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               Must work for Turbo Pascal 6.0;                 }
{                       Must work for Turbo Pascal 7.0;                 }
{                       Must work for Borland Pascal 7.0 with Objects   }
{                         (real-mode applications)                      }
{                       Must work for Borland Pascal 7.0 with Objects   }
{                         (protected-mode applications)                 }
{ DESCRIPTION           1. Process mapfile                              }
{                        Extract segment definitions                    }
{                        Build segment description table                }
{                          for each segment with class 'CODE'           }
{                        Skip public addresses if found                 }
{                        Extract line numbers and offset addresses      }
{                         if present                                    }
{                       Build map of all debug map on the heap.         }
{                       Add also some map info for binary libraries.    }
{                       2. Proccess exefile                             }
{                        Check for validity of internal structure of    }
{                          exefile (very simple tests!)                 }
{                          For old executable file:                     }
{                             unit_offset :=  header_size +             }
{                               + starting_mem_address_of_unit          }
{                          For new executable file:                     }
{                             unit_offset :=  segment_offset_in_file +  }
{                               + unit_offset_in_segment                }
{                        Read a unit in memory buffer                   }
{                        Search 'INFMAP' string in buffer               }
{                          if not found then no debugmap space in unit  }
{                          (This string from unit SHOWTERR)             }
{                          (The following word after string contains    }
{                            size of debugmap in unit)                  }
{                        Compare sizes of heap and map-in-unit          }
{                        Copy new debugmap in unit                      }
{                        Write back unit in file                        }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   10-Mar-95  DS  initilal release          }
{                       1.10   11-Mar-95  DS  added support for PM apps }
{                       1.11   20-Apr-95  DS  fixed bug of calculation  }
{                                             of tables offsets         }
{                       1.12   09-May-95  DS  added support of binary   }
{                                             compiled files            }
{                       1.13   26-Jul-97  DS  updated documentation     }
{                       1.14   02-Aug-97  DS  removed tabs              }
{                       1.15   02-Sep-97  DS  fixed open r/o file bug   }
{                       1.16   17-Oct-98  DS  fixed access denied bug   }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   PutMapToExeFile;


{*** other modules ***}
USES
     Dos,
     ShowTErr;


{** switches for compilation **}
{$S-}                     {*  stack checking     *}
{$R-}                     {*  range checking     *}
{$M 16384,131072,131072}  {*  memory allocation  *}


{** Debugging Version; doing sample output instead real work **}
{***$DEFINE DebugVersion}

{** Adds some information about compiled units without sources. **}
{$DEFINE AddInfoForTPU}


{*========================== CONSTANTS PART ============================*}

CONST

     { general information }

     asPurpose                  =       'Put DebugMap to ExeFile';
     asVersion                  =       '1.16';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1995,1998';
     asProgram                  =       'Map2exe';
     asProgramPrompt            =       asProgram+': ';
     asProgramU                 =       'MAP2EXE';


     { exit codes }

     errTerminateOK                     =     0;
     errBadParmsNumber                  =     1;
     errSourceNotFound                  =     2;
     errDestNotFound                    =     3;
     errSameNames                       =     4;
     errSrcOpenFailed                   =     5;
     errDestOpenFailed                  =     6;
     errBadSectionSwitch                =     7;
     errMaxSegNumReached                =     8;
     errNoneSegStartAddr                =     9;
     errNoneSegStopAddr                 =     10;
     errNoneSegLength                   =     11;
     errBadSegStartAddr                 =     12;
     errBadSegStopAddr                  =     13;
     errBadSegLength                    =     14;
     errNoSpaceOnAllocatedHeap          =     15;
     errNoOpeningParenthesis            =     16;
     errNoClosingParenthesis            =     17;
     errBadSegmentDescriptor            =     18;
     errBadLineNumber                   =     19;
     errBadSegNum                       =     20;
     errBadOfsNum                       =     21;
     errMismatchSegNum                  =     22;
     errBadExeFile                      =     23;
     errBadMapUnit                      =     24;
     errBadSeekOfUnitInFile             =     25;
     errBadInfoMapForUnit               =     26;
     errTooLargeNewMap                  =     27;
     errBadSeekOfUnitInFileToWrite      =     28;
     errBadSeekOfNewExeHeader           =     29;
     errBadNewExeFile                   =     30;
     errBadSeekOfSegmentTable           =     31;
     errMismatchSegmentTableEntry       =     32;
     errCannotFindSegName               =     33;
     errCannotSegmentNameInTable        =     34;


     { ASCII definitions }

     achHexPrefix               =     '$';
     achDosExtMark              =     '.';
     asBlank                    =     '';
     achNULL                    =     #0;
     achHTAB                    =     #9;
     achSPACE                   =     #32;
     achCR                      =     #13;


     { defaults }

     asInDefExt                 =     'MAP';
     asOutDefExt                =     'EXE';
     asProtModeParm             =     'PM';

     aHexRadix                  =     16;
     aPercent100                =     100;
     aMaxOnHeap                 =     65520;


     { file parts }

     aEmptyPart                 =     0;
     aSegmentsPart              =     1;
     aPublicAddressPart         =     2;
     aLineNumbersPart           =     3;
     aEntryPointPart            =     4;


     { segments }

     aMaxSegNum                 =     256;


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE

  { strings types }

    STR2        =       STRING[2];
    STR3        =       STRING[3];
    STR4        =       STRING[4];
    STR8        =       STRING[8];
    STR16       =       STRING[16];
    STR64       =       STRING[64];
    STR80       =       STRING[80];


    {* old executable file; partial information *}

    recExeFileHeader    =       RECORD
         dwExeSignature            :      System.Word;
         dwRemOfLastPage           :      System.Word;
         dwImageSizeInPages512     :      System.Word;
         dwRelocItemCount          :      System.Word;
         dwHeaderSizeInParas       :      System.Word;
   {recExeFileHeade}            END;


    {* new executable file; partial information *}

    recNewExeFileHeader    =    RECORD
         dwNewExeSignature          :           System.Word;
         dwLinkerVersion            :           System.Word;
         dwEntryTableOfs            :           System.Word;
         dwEntryTableSize           :           System.Word;
         ddFileLoadCRC              :           System.Longint;
         dbProgramFlags             :           System.Byte;
         dbApplicationFlags         :           System.Byte;
         dwAutoDataSegmentIndex     :           System.Word;
         dwInitLocalHeapSize        :           System.Word;
         dwInitStackSize            :           System.Word;
         ddInitCS_IP                :           System.Longint;
         ddInitSS_SP                :           System.Longint;
         dwSegmentCount             :           System.Word;
         dwModuleRefCount           :           System.Word;
         dwNonResNamesTableSize     :           System.Word;
         dwSegmentTableOfs          :           System.Word;  {relative}
         dwResourceTableOfs         :           System.Word;
         dwResNamesTableOfs         :           System.Word;
         dwModuleRefTableOfs        :           System.Word;
         dwImportNamesTableOfs      :           System.Word;
         ddNonResNamesTableAbs      :           System.Longint; {absolute}
         dwMoveableEntriesCount     :           System.Word;
         dwFileAlignSizeShift       :           System.Word; {0=512 bytes}
   {recNewExeFileHeader}        END;



    {* segment definition in NE format *}

    recSegmentTableEntry        =       RECORD
        dwFileOfsAbs               :      System.Word;  {use alignment shift}
        dwFileImageSize            :      System.Word;  {0=64K}
        dwSegmentAttributes        :      System.Word;
        dwMemoryImageSize          :      System.Word;  {0=64K}
   {recSegmentTableEntry}               END;



    {* segment description from mapfile *}

    recSegDesc  =       RECORD
            bDescPresent    :   System.Boolean;
            bLinesInfoFound :   System.Boolean;
            liStartAddr     :   System.Longint;
            liEndAddr       :   System.Longint;
            liSegSize       :   System.Longint;
            sSegName64      :   STR64;
            sFileName14     :   array[1..14]  OF  System.Char;
   {recSegDesc}         END;


 {** IMPORTANT!!! Just the same structures must be in SHOWTERR.PAS!! **}
     {* map info structures *}

        recLocOfLineNum         =       RECORD
                  dwLineNum   :   System.Word; {0=end}
                  dwLoc       :   System.Word;
       {recLocOfLineNum}                END;


        arrFileName14           =       ARRAY[1..14]  OF System.Char;
        recSrcFileName          =       RECORD
                  dwNextRecLink       :   System.Word;   {0=end}
                  dwThisCodeSeg       :   System.Word;   {relative offset}
                  dwLinesTableLink    :   System.Word;   {relative offset}
                  szFileName          :   arrFileName14; {ASCIIZ string}
       {recSrcFileName}                 END;


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

   { sets }
    setHexChars          :    SET  OF  System.Char  =  ['0'..'9','A'..'F','a'..'f'];
    setDecimalChars      :    SET  OF  System.Char  =  ['0'..'9'];
    setIdentifierChars   :    SET  OF  System.Char  =  ['_','0'..'9','A'..'Z','a'..'z'];
    setUnusedLeadChars   :    SET  OF  System.Char  =  [achHTAB,achSPACE];

   { work variables }
    gliLineNum           :    System.Longint =  0;
    gdwCurSegNum         :    System.Word = 0;
    gdwWorkSegNum        :    System.Word = 0;
    gdwHeapOfs           :    System.Word = 0;
    gdwLinesTableLinkOfs :    System.Word = 0;
    gdwNextRecordLinkOfs :    System.Word = 0;
    gdwProtModeSegNum    :    System.Word = 0;
    gbInputStreamOk      :    System.Boolean =  System.False;
    gbProtModeAppOk      :    System.Boolean =  System.False;
    gdbSectionNum        :    System.Byte  =  aEmptyPart;


{*=========================== VARIABLES PART ===========================*}

VAR

   gfInputTextStream    :   System.Text;
   gfInputStream        :   FILE ABSOLUTE gfInputTextStream;
   gsInFileName         :   STR80;

   gfOutputStream   :   FILE;
   gsOutFileName    :   STR80;
   gddOffsetOutFile :   System.Longint;
   gddOutFileTime   :   System.Longint;

   gdwMemBlockSize  :   System.Word;
   gdwTemp          :   System.Word;
   gdwMapSize       :   System.Word;
   gdwIndex         :   System.Word;

   gliTemp          :   System.Longint;
   gliSeekOfs       :   System.Longint;
   gliNewHdrOfs     :   System.Longint;

   glpMemoryBlock   :   System.Pointer;
   glpUnitCode      :   System.Pointer;

   gliCurStarAddr   :   System.Longint;
   gliCurStopAddr   :   System.Longint;
   gliCurSegLength  :   System.Longint;
   gsCurSegName64   :   STR64;
   gsCurSegClass16  :   STR16;

   giErrorCode      :   System.Integer;

   gsTempInput      :   STRING;
   gsTemp2          :   STRING;

   gdbTemp          :   System.Byte;
   gchInUser        :   System.Char;

   grecExeFileHdr    :   recExeFileHeader;
   grecNewExeFileHdr :   recNewExeFileHeader;
   grecSegmentInfo   :   recSegmentTableEntry;
   arrSegDesc256     :   ARRAY[1..aMaxSegNum]  OF  recSegDesc;
   arrTextBuf8KB     :   ARRAY[1..32768]  OF  System.Byte;



{*=========================== FUNCTIONAL PART ==========================*}


FUNCTION  _fndbHexCharToBin(chIn: System.Char) : System.Byte; assembler;
{* Converts the hexadecimal char to binary value. *}
ASM
        mov   al,chIn        { AL = chIn }
        sub   al,'0'         { AL <- AL - '0' }

        cmp   al,9           { test for digit 0-9 }
        jbe   @Done

        and   al,11011111b   { make uppercase }
        sub   al,'A'-'9'-1   { AL = 'A'..'F' }

      @Done:
                             { AL = function result }
END;  { _fndbHexCharToBin }
{asm-end}



FUNCTION  _fnsForceFileNameExt(sFileName, sDefExt : STRING) : STRING;
{* Adds the extension for filename if not present. *}
BEGIN
   IF (System.Pos(achDosExtMark,sFileName) = 0)
     THEN sFileName := sFileName + achDosExtMark + sDefExt;
   {if-then}
  _fnsForceFileNameExt := sFileName;
END;  { _fnsForceFileNameExt }



FUNCTION  _fnliHexStrToBin(sHexInput : STRING; VAR iErrCode : System.Integer) : System.Longint;
{* Converts hexadecimal string to binary number. *}
VAR
  ddNumber               :       System.Longint;
  dbStrIndex, dbStrLen   :       System.Byte;

BEGIN
  iErrCode   := 0;
  ddNumber   := 0;
  dbStrIndex := 1;
  dbStrLen := System.Length(sHexInput);

  WHILE (iErrCode = 0) and (dbStrLen > 0) DO
  BEGIN
    IF  (sHexInput[dbStrIndex] IN setHexChars)
    THEN  BEGIN
               ddNumber := ddNumber * aHexRadix +
                           _fndbHexCharToBin(sHexInput[dbStrIndex]);
               System.Inc(dbStrIndex);
               System.Dec(dbStrLen);
          END
    ELSE
        iErrCode  := -1;
    {if-then-else}
  END;
  {while-do}

  _fnliHexStrToBin := ddNumber;
END;  { _fnliHexStrToBin }



FUNCTION  _fnbFileExist(VAR fStruc : FILE; sFileName : STRING) : System.Boolean;
{* Checks that file exits. *}
VAR
  bResult        :  System.Boolean;
  dbOldFileMode  :  System.Byte;

BEGIN
  {Use safe mode to open}
  dbOldFileMode := System.FileMode;
  System.FileMode := $20;   {read, deny write on share}

  {** try to open the file **}
  System.Assign(fStruc,sFileName);
  {$I-}
  System.Reset(fStruc);
  {$I+}

  {** copy the result of last I/O operation **}
  bResult := (System.IOResult = 0);

  IF (bResult)
    THEN  System.Close(fStruc);
  {if-then}

   {Restore defaults}
   dbOldFileMode := System.FileMode;

  _fnbFileExist := bResult;
END;  { _fnbFileExist }



FUNCTION  _fnsUpcaseStr(sInput : STRING) : STRING;
{* Makes all the uppercase. *}
VAR
  dbIndex  :  System.BYTE;
  dbCount  :  System.BYTE;

BEGIN
  dbCount := System.Length(sInput);

  IF (dbCount <> 0) THEN
    FOR dbIndex :=  1  TO  dbCount DO
      sInput[dbIndex] := System.Upcase(sInput[dbIndex]);
    {for-to-do}
  {if-then}

   _fnsUpcaseStr := sInput;
END;  { _fnsUpcaseStr }



FUNCTION  _fnddGetNum(sInput : STRING; VAR iErrorCode : System.Integer)  :  System.Longint;
{* Reads a numeric string. *}
VAR
  ddTemp      :   System.Longint;

BEGIN
  IF  (sInput[1] <> achHexPrefix)
     THEN  System.Val(sInput,ddTemp,iErrorCode)
     ELSE  ddTemp := _fnliHexStrToBin(Copy(sInput,2,System.Length(sInput)-1),iErrorCode);
  {if-then-else}
  _fnddGetNum := ddTemp;
END;  { _fnddGetNum }



FUNCTION  _fnsNumToStr3(dwNum : System.Word) : STR3;
{* Convert a numeric value to its string representation. *}
VAR
  sTemp : STR3;

BEGIN
   System.Str(dwNum:3,sTemp);
   _fnsNumToStr3 := sTemp;
END;  { _fnsNumToStr3 }



FUNCTION  _fnsRemoveLeadChars(sInput : STRING) : STRING;
{* Removes all the occurrences of a leading whitespace from the left side. *}
BEGIN
   WHILE ((sInput <> asBlank) AND (sInput[1] IN setUnusedLeadChars))
   DO  System.Delete(sInput,1,1);
   {while-do}
   _fnsRemoveLeadChars := sInput;
END; { _fnsRemoveLeadChars }



FUNCTION  _fnsExtractIdentifierName(sInput : STRING) : STRING;
{* Copy all the matching symbols from the left side. *}
VAR
  sIdentifier  :  STRING;

BEGIN
   sIdentifier := asBlank;
   WHILE ((sInput <> asBlank) AND (sInput[1] IN setIdentifierChars))
   DO  BEGIN
     sIdentifier := sIdentifier + sInput[1];
     System.Delete(sInput,1,1);
       END;
   {while-do}
   _fnsExtractIdentifierName := sIdentifier;
END;  { _fnsExtractIdentifierName }



FUNCTION  _fnsExtractDecNum(sInput : STRING) : STRING;
{* Copy all the matching symbols from the left side. *}
VAR
  sIdentifier  :  STRING;

BEGIN
   sIdentifier := asBlank;
   WHILE ((sInput <> asBlank) AND (sInput[1] IN setDecimalChars))
   DO  BEGIN
     sIdentifier := sIdentifier + sInput[1];
     System.Delete(sInput,1,1);
       END;
   {while-do}
   _fnsExtractDecNum := sIdentifier;
END;  { _fnsExtractDecNum }



FUNCTION  _fnsExtractHexNum(sInput : STRING) : STRING;
{* Copy all the matching symbols from the left side. *}
VAR
  sIdentifier  :  STRING;

BEGIN
   sIdentifier := asBlank;
   WHILE ((sInput <> asBlank) AND (sInput[1] IN setHexChars))
   DO  BEGIN
     sIdentifier := sIdentifier + sInput[1];
     System.Delete(sInput,1,1);
       END;
   {while-do}
   _fnsExtractHexNum := sIdentifier;
END;  { _fnsExtractHexNum }



FUNCTION   _fnsByteToHexFmt(dbInput : System.Byte) : STR2;
{* Converts a byte to the hexadecimal format number representation. *}
CONST
    dbHexCharTable : ARRAY[0..15] OF System.Char = '0123456789ABCDEF';

BEGIN
  _fnsByteToHexFmt := dbHexCharTable[dbInput SHR 4] +
                      dbHexCharTable[dbInput AND $0F];
END;  { _fnsByteToHexFmt }



FUNCTION   _fnsWordToHexFmt(dwInput : System.Word) : STR4;
{* Converts a word to the hexadecimal format number representation. *}
BEGIN
  _fnsWordToHexFmt := _fnsByteToHexFmt(System.Hi(dwInput)) +
                      _fnsByteToHexFmt(System.Lo(dwInput));
END;  { _fnsWordToHexFmt }



FUNCTION   _fnsDoubleWordToHexFmt(ddInput : System.Longint) : STR8;
{* Converts a double word to the hexadecimal format number representation. *}
BEGIN
  _fnsDoubleWordToHexFmt := _fnsWordToHexFmt(System.Word(ddInput SHR 16)) +
                      _fnsWordToHexFmt(System.Word(ddInput and $0000FFFF));
END;  { _fnsDoubleWordToHexFmt }



FUNCTION  _fndwCurHeapOfs : System.Word;
{* Returns a current offset on the heap. *}
BEGIN
   _fndwCurHeapOfs := gdwHeapOfs;
END;  { _fndwCurHeapOfs }



FUNCTION  _fnsGetSourceFileName(sWorkInput : STRING) : STRING;
{* Extracts a source file for a current segment. *}
VAR
  dbSubPos  :  System.Byte;

BEGIN
   dbSubPos := System. Pos('(',sWorkInput);
   IF  (dbSubPos = 0)
     THEN  BEGIN
       System.WriteLn(asProgramPrompt+'Cannot find opening parenthesis for filename.');
       System.Halt(errNoOpeningParenthesis);
           END;
   {if-then}
   System.Delete(sWorkInput,1,dbSubPos);
   dbSubPos := System. Pos(')',sWorkInput);
   IF  (dbSubPos = 0)
     THEN  BEGIN
       System.WriteLn(asProgramPrompt+'Cannot find closing parenthesis for filename.');
       System.Halt(errNoClosingParenthesis);
           END;
   {if-then}
   System.Delete(sWorkInput,dbSubPos,(System.Length(sWorkInput)-dbSubPos+1));
   {remove a drive letter}
   dbSubPos := System. Pos(':',sWorkInput);
   IF  (dbSubPos <> 0)
     THEN  BEGIN
       System.Delete(sWorkInput,1,dbSubPos);
           END;
   {if-then}
   {remove a path}
   dbSubPos := System.Pos('\',sWorkInput);
   WHILE  ((dbSubPos <> 0) AND (System.Length(sWorkInput) <> 0))  DO
   BEGIN
      System.Delete(sWorkInput,1,dbSubPos);
      dbSubPos := System.Pos('\',sWorkInput);
   END;
   {while-do}
   _fnsGetSourceFileName := sWorkInput;
END;  { _fnsGetSourceFileName }



FUNCTION  _fndwSearchPatternInBuf(lpBuf : System.Pointer;
                                  dwBufSize : System.Word;
                                  sPattern : STRING) : System.Word;
{* Searches a pattern in memory block; result = -1 if not found *}
VAR
   dbPatternSize  :  System.Byte ABSOLUTE sPattern;
   dbStrIndex,
   dbTestChar     :  System.Byte;
   dwPatternOfs,
   dwTempBufOfs,
   dwBufOfs       :   System.Word;
   bMatchFound    :   System.Boolean;

BEGIN
    dwPatternOfs := $FFFF;
    IF  (dbPatternSize <> 0) AND (dwBufSize >= dbPatternSize)
      THEN  BEGIN
        dwBufOfs := 0;
        bMatchFound := System.False;
        dbStrIndex := 1;
        WHILE  (dwBufSize <> 0) AND NOT(bMatchFound)  DO
        BEGIN
           dbTestChar := System.Mem[System.Seg(lpBuf^):(System.Ofs(lpBuf^)+dwBufOfs)];
           System.Dec(dwBufSize);
           System.Inc(dwBufOfs);
           IF (dbTestChar = System.Byte(sPattern[dbStrIndex]))
             THEN  BEGIN
               IF (dbStrIndex = 1)
                 THEN  dwTempBufOfs := dwBufOfs-1;
               {if-then}
               System.Inc(dbStrIndex);
               IF (dbStrIndex > dbPatternSize)
                 THEN  bMatchFound := System.True;
               {if-then}
                   END
             ELSE  BEGIN
               dbStrIndex := 1;
                   END;
           {if-then-else}
        END;
        {while-do}
            END;
    {if-then}
    IF (bMatchFound)
      THEN  dwPatternOfs := dwTempBufOfs;
    {if-then}
   _fndwSearchPatternInBuf := dwPatternOfs;
END;   { _fndwSearchPatternInBuf }



{*=========================== PROCEDURAL PART ==========================*}


PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+'  Version '+asVersion+',  '+asCopyright+'  '+asAuthor);
END;  { _CopyrightDisplay }



PROCEDURE  _StoreByteOnHeap(dbStoreThis : System.Byte);
{* Stores a given byte on the allocated heap. *}
BEGIN
   System.Mem[System.Seg(glpMemoryBlock^):(System.Ofs(glpMemoryBlock^)+gdwHeapOfs)] := dbStoreThis;
   System.Inc(gdwHeapOfs);
   IF  (gdwHeapOfs >= gdwMemBlockSize)
     THEN  BEGIN
       System.WriteLn(asProgramPrompt+'No more space on allocated heap.');
       System.Halt(errNoSpaceOnAllocatedHeap);
           END;
   {if-then}
END;  { _StoreByteOnHeap }



PROCEDURE  _StoreByteOnHeapByOffset(dbStoreThis : System.Byte; dwThisHeapOfs : System.Word);
{* Stores a given byte by a given offset on the allocated heap. *}
BEGIN
   System.Mem[System.Seg(glpMemoryBlock^):(System.Ofs(glpMemoryBlock^)+dwThisHeapOfs)] := dbStoreThis;
END;  { _StoreByteOnHeapByOffset }



PROCEDURE  _StoreWordOnHeapByOffset(dwStoreThis : System.Word; dwThisOfs : System.Word);
{* Stores a given word by a given offset on the allocated heap. *}
BEGIN
   _StoreByteOnHeapByOffset(System.Lo(dwStoreThis),dwThisOfs);
   _StoreByteOnHeapByOffset(System.Hi(dwStoreThis),dwThisOfs+1);
END;  { _StoreWordOnHeapByOffset }



PROCEDURE  _StoreWordOnHeap(dwStoreThis : System.Word);
{* Stores a given word on the allocated heap. *}
BEGIN
   _StoreByteOnHeap(System.Lo(dwStoreThis));
   _StoreByteOnHeap(System.Hi(dwStoreThis));
END;  { _StoreWordOnHeap }


PROCEDURE  _RunProcessForLineNumbers;
{* Prepare for processing of line numbers information. *}
CONST
  asSegSrch   =   ' segment ';

VAR
  dwIndex : System.Word;
  sTempSegName,
  sTempName : STRING;
  dbTempPos : System.Byte;

BEGIN
   {store link offsets for previous segment}
   IF  (gdwWorkSegNum <> 0)
     THEN  BEGIN
        {last entry for lines table}
        _StoreWordOnHeap(0);
        _StoreWordOnHeap(0);
        {update link offsets}
        _StoreWordOnHeapByOffset(_fndwCurHeapOfs,gdwNextRecordLinkOfs);
        _StoreWordOnHeapByOffset(System.SizeOf(recSrcFileName){+gdwNextRecordLinkOfs},
                                 gdwLinesTableLinkOfs);
           END;
   {if-then}

   {get a segment name}
   dbTempPos := System.Pos(asSegSrch,gsTempInput);
   IF  (dbTempPos = 0)
      THEN  BEGIN
        System.Writeln;
        System.WriteLn(asProgramPrompt+'Cannot find the segment name.');
        System.Halt(errCannotFindSegName);
            END;
   {if-then}
   dbTempPos := dbTempPos + System.Length(asSegSrch);
   sTempSegName := System.Copy(gsTempInput,dbTempPos,(System.Length(gsTempInput)-dbTempPos+1));

   {searches the matching entry in segment description table}
   gdwWorkSegNum := 0;
   REPEAT
     System.Inc(gdwWorkSegNum);
     WITH  (arrSegDesc256[gdwWorkSegNum])  DO
        IF  (bDescPresent)
          THEN  sTempName := sSegName64;
        {if-then}
     {with-do}
   UNTIL  ((sTempName = sTempSegName) OR (gdwWorkSegNum > aMaxSegNum));
   {repeat-until}
   IF  (gdwWorkSegNum > aMaxSegNum)
     THEN  BEGIN
        System.Writeln;
        System.WriteLn(asProgramPrompt+'Cannot find segment name in description table.');
        System.Halt(errCannotSegmentNameInTable);
           END;
   {if-then}

   gdbSectionNum := aLineNumbersPart;
   gsTemp2 := _fnsGetSourceFileName(gsTempInput);
   System.Move(gsTemp2[1],arrSegDesc256[gdwWorkSegNum].sFileName14,System.Length(gsTemp2));

   System.Writeln;
   System.Writeln(asProgramPrompt+'Extract line numbers info for source '+gsTemp2);
   WITH  (arrSegDesc256[gdwWorkSegNum])  DO
   BEGIN
      IF  NOT(bDescPresent)
        THEN  BEGIN
           System.WriteLn(asProgramPrompt+'Invalid descriptior for segment found.');
           System.Halt(errBadSegmentDescriptor);
              END;
      {if-then}
      {store link to next record}
      gdwNextRecordLinkOfs := _fndwCurHeapOfs;
      _StoreWordOnHeap(0);
      {store relative segment}
      IF  (gbProtModeAppOk)
        THEN  _StoreWordOnHeap(System.Word(liStartAddr))       {segment selector}
        ELSE  _StoreWordOnHeap(System.Word(liStartAddr SHR 4));{offset address}
      {if-then-else}
      {store link to lines table}
      gdwLinesTableLinkOfs := _fndwCurHeapOfs;
      _StoreWordOnHeap(0);
      {store filename}
      FOR  dwIndex := 1  TO  14  DO
      BEGIN
         _StoreByteOnHeap(System.Byte(sFileName14[dwIndex]));
      END;
      {for-to-do}
      bLinesInfoFound := System.True;
   END;
   {with-do}

END;  { _RunProcessForLineNumbers }



PROCEDURE  _ProcessLineNumbersMap(sLineNumInput : STRING);
{* Extract line numbers and offsets for them. *}
VAR
  iErrConvCode  :  System.Integer;
  sTemp8        :  STR8;
  dwLineNum,
  dwSegVal,
  dwOfsVal,
  dwTemp        :  System.Word;

BEGIN
  { all lines in format ddddd ssss:oooo, where }
  {   ddddd - decimal line number              }
  {   ssss  - hexadecimal segment value        }
  {   oooo  - hexadecimal offset value         }

  sLineNumInput := _fnsRemoveLeadChars(sLineNumInput);
  WHILE  (sLineNumInput <> asBlank)  DO
  BEGIN
    sTemp8 := _fnsExtractDecNum(sLineNumInput);
    System.Delete(sLineNumInput,1,System.Length(sTemp8));
    dwLineNum := System.Word(_fnddGetNum(sTemp8,iErrConvCode));
    IF  (iErrConvCode <> 0)
      THEN  BEGIN
         System.Writeln;
         System.WriteLn(asProgramPrompt+'Bad decimal line number found.');
         System.Halt(errBadLineNumber);
            END;
    {if-then}

    sLineNumInput := _fnsRemoveLeadChars(sLineNumInput);
    sTemp8 := _fnsExtractHexNum(sLineNumInput);
    System.Delete(sLineNumInput,1,System.Length(sTemp8));
    dwSegVal := System.Word(_fnliHexStrToBin(sTemp8,iErrConvCode));
    IF  (iErrConvCode <> 0)
      THEN  BEGIN
         System.Writeln;
         System.WriteLn(asProgramPrompt+'Bad hexadecimal segment number found.');
         System.Halt(errBadSegNum);
            END;
    {if-then}

    {check segment value}
    IF  (gbProtModeAppOk)
      THEN  dwTemp := System.Word(arrSegDesc256[gdwWorkSegNum].liStartAddr) {segment selector}
      ELSE  dwTemp := System.Word(arrSegDesc256[gdwWorkSegNum].liStartAddr SHR 4); {offset address}
    {if-then}
    IF  (dwTemp <> dwSegVal)
      THEN  BEGIN
         System.Writeln;
         System.WriteLn(asProgramPrompt+'Mismatch segment number found for this unit.');
         System.Halt(errMismatchSegNum);
            END;
    {if-then}

    {remove a colon}
    System.Delete(sLineNumInput,1,1);

    sTemp8 := _fnsExtractHexNum(sLineNumInput);
    System.Delete(sLineNumInput,1,System.Length(sTemp8));
    dwOfsVal := System.Word(_fnliHexStrToBin(sTemp8,iErrConvCode));
    IF  (iErrConvCode <> 0)
      THEN  BEGIN
         System.Writeln;
         System.WriteLn(asProgramPrompt+'Bad hexadecimal offset number found.');
         System.Halt(errBadOfsNum);
            END;
    {if-then}

    _StoreWordOnHeap(dwLineNum);
    _StoreWordOnHeap(dwOfsVal);
    sLineNumInput := _fnsRemoveLeadChars(sLineNumInput);
  END;
  {while-do}
END;  { _ProcessLineNumbersMap }



{$IFDEF    AddInfoForTPU}
PROCEDURE  _AddInfoAboutUnitsWithoutSources;
{* Adds some information about only compiled units. *}
VAR
  dwIndex,
  dwTempIndex  :  System.Word;
  sTempName   : STRING;

BEGIN
   System.WriteLn(asProgramPrompt+'Add debug information for binary files.');

   FOR  dwIndex := 1  TO  aMaxSegNum  DO
    WITH  (arrSegDesc256[dwIndex])  DO
      IF  ((bDescPresent) AND  NOT(bLinesInfoFound))
        THEN  BEGIN
        sTempName := _fnsUpcaseStr(sSegName64);
        System.Move(sTempName[1],
                    arrSegDesc256[dwIndex].sFileName14,
                    System.Length(sTempName));
        System.WriteLn(asProgramPrompt+'Add entry for segment '+sTempName);
       {store link offsets for previous segment}
       IF  (gdwWorkSegNum <> 0)
         THEN  BEGIN
            {last entry for lines table}
            _StoreWordOnHeap(0);
            _StoreWordOnHeap(0);
            {update link offsets}
            _StoreWordOnHeapByOffset(_fndwCurHeapOfs,gdwNextRecordLinkOfs);
            _StoreWordOnHeapByOffset(System.SizeOf(recSrcFileName){+gdwNextRecordLinkOfs},
                                     gdwLinesTableLinkOfs);
            gdwWorkSegNum := dwIndex;  {current index}
               END;
       {if-then}

      {store link to next record}
      gdwNextRecordLinkOfs := _fndwCurHeapOfs;
      _StoreWordOnHeap(0);
      {store relative segment}
      IF  (gbProtModeAppOk)
        THEN  _StoreWordOnHeap(System.Word(liStartAddr))       {segment selector}
        ELSE  _StoreWordOnHeap(System.Word(liStartAddr SHR 4));{offset address}
      {if-then-else}
      {store link to lines table}
      gdwLinesTableLinkOfs := _fndwCurHeapOfs;
      _StoreWordOnHeap(0);
      {store filename}
      FOR  dwTempIndex := 1  TO  14  DO
      BEGIN
         _StoreByteOnHeap(System.Byte(sFileName14[dwTempIndex]));
      END;
      {for-to-do}
              END;
      {if-then}
    {with-do}
   {for-to-do}
END;  { _AddInfoAboutUnitsWithoutSources }
{$ENDIF}  {AddInfoForTPU}



{*============================== MAIN PART =============================*}


BEGIN
  _CopyrightDisplay;

     gdwIndex := System.ParamCount;
     IF  (gdwIndex <> 2) AND (gdwIndex <> 3)
        THEN  BEGIN
          System.WriteLn(asProgramPrompt+'  help screen for you.');
          System.WriteLn('Usage: mapfile exefile [pm]');
          System.WriteLn('  mapfile    -  source filename      (def. ext. = '+asInDefExt+')');
          System.WriteLn('  exefile    -  destination filename (def. ext. = '+asOutDefExt+')');
          System.WriteLn('  pm         -  application in protected mode (BP7+)');
          System.Halt(errBadParmsNumber);
              END;
     {if-then}

     IF  ((gdwIndex = 3) AND
          (_fnsUpcaseStr(System.ParamStr(3)) = asProtModeParm))
        THEN  BEGIN
           gbProtModeAppOk := System.True;
           System.WriteLn(asProgramPrompt+
                         'Application in protected mode.');
              END;
     {if-then}


  {* init internal variables *}
  FOR  gdwIndex := 1  TO  aMaxSegNum  DO
  WITH  (arrSegDesc256[gdwIndex])  DO
  BEGIN
    bDescPresent := System.False;
    bLinesInfoFound := System.False;
  END;
  {with-do}
  {for-to-do}


  {** copy the parameters from command line **}
  gsInFileName  := _fnsUpcaseStr(System.ParamStr(1));
  gsInFileName := _fnsForceFileNameExt(gsInFileName,asInDefExt);

  gsOutFileName := _fnsUpcaseStr(System.ParamStr(2));
  gsOutFileName := _fnsForceFileNameExt(gsOutFileName,asOutDefExt);


  {* may be same names? *}
  IF (gsInFileName = gsOutFileName)  THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to use same file as input and as output');
    System.Halt(errSameNames);
  END;
  {if-then}


  {** source file exists? **}
  IF  NOT(_fnbFileExist(gfInputStream,gsInFileName)) THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to open file '+gsInFileName);
    System.Halt(errSourceNotFound);
  END;
  {if-then}


  {** destination file exists? **}
  IF  NOT(_fnbFileExist(gfOutputStream,gsOutFileName)) THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to open file '+gsOutFileName);
    System.Halt(errDestNotFound);
  END;
  {if-then}


  {** get memory on heap **}
  System.WriteLn(asProgramPrompt+'Allocate memory on heap.');
  IF  (System.MaxAvail < aMaxOnHeap)
    THEN  gdwMemBlockSize := System.MaxAvail
    ELSE  gdwMemBlockSize := aMaxOnHeap;
  {if-then-else}
  System.GetMem(glpMemoryBlock,gdwMemBlockSize);


  {** open the source file **}
  System.WriteLn(asProgramPrompt+'Open mapfile '+gsInFileName);
  System.FileMode := $20;   {read, deny write on share}
  System.Assign(gfInputTextStream,gsInFileName);
  SetTextBuf(gfInputTextStream,arrTextBuf8KB);
  {$I-}
  System.Reset(gfInputTextStream);
  {$I+}

  IF  (System.IoResult <> 0) THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to open '+gsInFileName);
    System.Halt(errSrcOpenFailed);
  END;
  {if-then}


  {* main processing algorithm for mapfile *}
  WHILE  NOT(System.Eof(gfInputTextStream))  DO
  BEGIN
     System.Readln(gfInputTextStream,gsTempInput);
     System.Inc(gliLineNum);
     System.Write(achCR+asProgramPrompt+'Processing line ',gliLineNum);

     gsTempInput := _fnsRemoveLeadChars(gsTempInput);
     IF  (gsTempInput <> asBlank)
       THEN  BEGIN
         CASE  (gdbSectionNum)  OF
            aEmptyPart          :  BEGIN
                    IF  (gbProtModeAppOk)
                       THEN  BEGIN
                         IF  (System.Pos('Start        Length  Name',gsTempInput) <> 0)
                            THEN  BEGIN
                               System.Writeln;
                               System.Writeln(asProgramPrompt+'Extract segments information.');
                               gdbSectionNum := aSegmentsPart;
                                  END;
                         {if-then}
                             END
                       ELSE  BEGIN
                          IF  (System.Pos('Start  Stop   Length Name',gsTempInput) <> 0)
                             THEN  BEGIN
                                System.Writeln;
                                System.Writeln(asProgramPrompt+'Extract segments information.');
                                gdbSectionNum := aSegmentsPart;
                                   END;
                          {if-then}
                             END;
                    {if-then-else}
                                   END;
            aSegmentsPart       :  BEGIN
                    IF  (System.Pos('Line numbers for',gsTempInput) <> 0)
                       THEN  BEGIN
                         _RunProcessForLineNumbers;
                             END
                       ELSE  BEGIN
                         IF  (System.Pos('Address ',gsTempInput) <> 0)
                            THEN  BEGIN
                               System.Writeln;
                               System.Writeln(asProgramPrompt+'Extract public address information.');
                               gdbSectionNum := aPublicAddressPart;
                                  END
                            ELSE  BEGIN
                              System.Inc(gdwCurSegNum);
                              IF  (gdwCurSegNum > aMaxSegNum)
                                THEN  BEGIN
                                  System.Writeln;
                                  System.WriteLn(asProgramPrompt+
                                                 'Maximum segment number reached.');
                                  System.Halt(errMaxSegNumReached);
                                      END;
                              {if-then}

                              IF  (gbProtModeAppOk)
                                 THEN  gdbTemp := System.Pos(':',gsTempInput)
                                 ELSE  gdbTemp := System.Pos('H',gsTempInput);
                              {if-then-else}
                              IF  (gdbTemp = 0)
                                THEN  BEGIN
                                 System.Writeln;
                                 System.WriteLn(asProgramPrompt+
                                                'Starting address not found.');
                                 System.Halt(errNoneSegStartAddr);
                                      END;
                              gsTemp2 := System.Copy(gsTempInput,1,gdbTemp-1);
                              gliCurStarAddr := _fnliHexStrToBin(gsTemp2,giErrorCode);
                              IF  (giErrorCode <> 0)
                                THEN  BEGIN
                                 System.Writeln;
                                 System.WriteLn(asProgramPrompt+
                                                'Bad number for starting address found.');
                                 System.Halt(errBadSegStartAddr);
                                      END;
                              {if-then}
                              System.Delete(gsTempInput,1,gdbTemp);
                              gsTempInput := _fnsRemoveLeadChars(gsTempInput);

                              IF  (gbProtModeAppOk)
                                THEN  gdbTemp := System.Pos(' ',gsTempInput)
                                ELSE  gdbTemp := System.Pos('H',gsTempInput);
                              {if-then-else}
                              IF  (gdbTemp = 0)
                                THEN  BEGIN
                                 System.Writeln;
                                 System.WriteLn(asProgramPrompt+
                                                'Ending address not found.');
                                 System.Halt(errNoneSegStopAddr);
                                      END;
                              gsTemp2 := System.Copy(gsTempInput,1,gdbTemp-1);
                              gliCurStopAddr := _fnliHexStrToBin(gsTemp2,giErrorCode);
                              IF  (giErrorCode <> 0)
                                THEN  BEGIN
                                 System.Writeln;
                                 System.WriteLn(asProgramPrompt+
                                                'Bad number for ending address found.');
                                 System.Halt(errBadSegStopAddr);
                                      END;
                              {if-then}
                              System.Delete(gsTempInput,1,gdbTemp);
                              gsTempInput := _fnsRemoveLeadChars(gsTempInput);

                              gdbTemp := System.Pos('H',gsTempInput);
                              IF  (gdbTemp = 0)
                                THEN  BEGIN
                                 System.Writeln;
                                 System.WriteLn(asProgramPrompt+
                                                'Segment length not found.');
                                 System.Halt(errNoneSegStopAddr);
                                      END;
                              gsTemp2 := System.Copy(gsTempInput,1,gdbTemp-1);
                              gliCurSegLength := _fnliHexStrToBin(gsTemp2,giErrorCode);
                              IF  (giErrorCode <> 0)
                                THEN  BEGIN
                                 System.Writeln;
                                 System.WriteLn(asProgramPrompt+
                                                'Bad number for segment length found.');
                                 System.Halt(errBadSegStopAddr);
                                      END;
                              {if-then}
                              System.Delete(gsTempInput,1,gdbTemp);
                              gsTempInput := _fnsRemoveLeadChars(gsTempInput);

                              gsCurSegName64 := _fnsExtractIdentifierName(gsTempInput);
                              System.Delete(gsTempInput,1,System.Length(gsCurSegName64));
                              gsTempInput := _fnsRemoveLeadChars(gsTempInput);

                              gsCurSegClass16 := _fnsExtractIdentifierName(gsTempInput);

                              IF  ((gsCurSegClass16 = 'CODE'))
                                THEN  BEGIN
                                   WITH  (arrSegDesc256[gdwCurSegNum])  DO
                                   BEGIN
                                     bDescPresent := System.True;
                                     liStartAddr := gliCurStarAddr;
                                     liEndAddr := gliCurStopAddr;
                                     liSegSize := gliCurSegLength;
                                     sSegName64 := gsCurSegName64;
                                     System.FillChar(sFileName14[1],14,achNULL);
                                   END;
                                   {with-do}
                                   System.WriteLn;
                                   System.WriteLn(asProgramPrompt+
                                                  'Code segment = '+
                                                   gsCurSegName64+
                                                   ', startaddr = '+achHexPrefix+
                                                   _fnsDoubleWordToHexFmt(gliCurStarAddr));
                                      END;
                              {if-them}
                                  END;
                         {if-then}
                             END;
                    {if-then-else}
                                   END;
            aPublicAddressPart  :  BEGIN
                    IF  (System.Pos('Line numbers for',gsTempInput) <> 0)
                       THEN  BEGIN
                          _RunProcessForLineNumbers;
                             END;
                    {if-then}
                                   END;
            aLineNumbersPart    :  BEGIN
                    IF  (System.Pos('Program entry point at',gsTempInput) <> 0)
                       THEN  BEGIN
                          System.Writeln;
                          System.Writeln(asProgramPrompt+'Program entry point found.');
                          gdbSectionNum := aEntryPointPart;
                             END
                       ELSE  BEGIN
                    IF  (System.Pos('Line numbers for',gsTempInput) <> 0)
                       THEN  BEGIN
                          _RunProcessForLineNumbers;
                             END
                       ELSE  BEGIN
                          _ProcessLineNumbersMap(gsTempInput);
                             END;
                    {if-then-else}
                             END;
                    {if-then-else}
                                   END;
            aEntryPointPart     :  BEGIN
                                   END;
         ELSE  BEGIN
            System.WriteLn(asProgramPrompt+'Bad section switch found.');
            System.Halt(errBadSectionSwitch);
               END;
         END;
         {case-of}
             END;
     {if-then}
  END;
  {while-do}


  {** close input stream **}
  IF  (gdbSectionNum <> aEntryPointPart)
    THEN  System.WriteLn;
  {if-then}
  System.WriteLn(asProgramPrompt+'Close mapfile '+gsInFileName);
  System.Close(gfInputTextStream);


  {* adds some *}
{$IFDEF    AddInfoForTPU}
  _AddInfoAboutUnitsWithoutSources;
{$ENDIF}  {AddInfoForTPU}

  {* write output stream *}
  IF  ((gdbSectionNum = aEntryPointPart) AND (gdwWorkSegNum <> 0))
    THEN  BEGIN
       gbInputStreamOk := System.True;
       {store link offsets for previous segment}
       IF  (gdwWorkSegNum <> 0)
         THEN  BEGIN
            {last entry for lines table}
            _StoreWordOnHeap(0);
            _StoreWordOnHeap(0);
            {update link offsets}
            _StoreWordOnHeapByOffset(System.SizeOf(recSrcFileName){+gdwNextRecordLinkOfs},
                                     gdwLinesTableLinkOfs);
               END;
       {if-then}
          END;
  {if-then}


  IF  (gbInputStreamOk)
    THEN BEGIN

{$IFDEF  DebugVersion}
       System.WriteLn(asProgramPrompt+
                      'Write sample output to file MAP2EXE.BIN');
       System.Assign(gfOutputStream,'MAP2EXE.BIN');
       System.FileMode := 2; {read/write, compatibilty mode}
       System.Rewrite(gfOutputStream,1);
       System.BlockWrite(gfOutputStream,
          System.Mem[System.Seg(glpMemoryBlock^):System.Ofs(glpMemoryBlock^)],
          gdwHeapOfs);
       System.Close(gfOutputStream);
{$ELSE}

       {** open the destination file **}
       System.WriteLn(asProgramPrompt+'Open exefile '+gsOutFileName);
       System.FileMode := $02;   {read/write}
       System.Assign(gfOutputStream,gsOutFileName);
       {$I-}
       System.Reset(gfOutputStream,1);
       {$I+}

       IF  (System.IoResult <> 0) THEN
       BEGIN
         System.Close(gfInputStream);
         System.WriteLn(asProgramPrompt+'Unable to open '+gsOutFileName);
         System.Halt(errDestOpenFailed);
       END;
       {if-then}

       {* get date/time for output file *}
       Dos.GetFTime(gfOutputStream,gddOutFileTime);

       {* read a header *}
       IF  (gbProtModeAppOk)
         THEN  BEGIN
           System.WriteLn(asProgramPrompt+'Read a header of old executable file.');
           System.BlockRead(gfOutputStream,grecExeFileHdr,System.SizeOf(grecExeFileHdr));
           WITH  (grecExeFileHdr)  DO
           BEGIN
              IF  (dwExeSignature <> $5A4D) AND (dwExeSignature <> $4D5A)
                THEN  BEGIN
                   System.WriteLn(asProgramPrompt+'Not valid executable file.');
                   System.Halt(errBadExeFile);
                      END;
              {if-then}
              System.WriteLn(asProgramPrompt+'Calculate offset for new header in exefile.');
              IF  (dwRemOfLastPage <> 0)
                THEN  System.Dec(dwImageSizeInPages512);
              {if-then}
              gliNewHdrOfs := System.Longint(dwImageSizeInPages512) * 512 +
                              dwRemOfLastPage;
           END;
           {with-do}

           System.WriteLn(asProgramPrompt+'Seek offset for new header in exefile.');
           System.Seek(gfOutputStream,gliNewHdrOfs);
           IF  (System.FilePos(gfOutputStream) <> gliNewHdrOfs)
             THEN  BEGIN
               System.WriteLn(asProgramPrompt+'Cannot locate new header in exefile.');
               System.Halt(errBadSeekOfNewExeHeader);
                   END;
           {if-then}

           System.WriteLn(asProgramPrompt+'Read a header of new executable file.');
           System.BlockRead(gfOutputStream,grecNewExeFileHdr,System.SizeOf(grecNewExeFileHdr));
           WITH  (grecNewExeFileHdr)  DO
           BEGIN
              IF  (dwNewExeSignature <> $454E)
                THEN  BEGIN
                   System.WriteLn(asProgramPrompt+'Not valid newexecutable file.');
                   System.Halt(errBadNewExeFile);
                      END;
              {if-then}
           END;
           {with-do}

           System.WriteLn(asProgramPrompt+'Get segment number for unit.');
           gdwIndex := 0;
           gsTempInput := asBlank;
           REPEAT
             System.Inc(gdwIndex);
             WITH  (arrSegDesc256[gdwIndex])  DO
                IF  (bDescPresent)
                  THEN  gsTempInput := _fnsUpcaseStr(sSegName64);
                {if-then}
             {with-do}
           UNTIL  ((gsTempInput = 'SHOWTERR') OR (gdwIndex > aMaxSegNum));
           {repeat-until}
           IF  (gdwIndex > aMaxSegNum)
             THEN  BEGIN
                System.WriteLn(asProgramPrompt+'Cannot find SHOWTERR unit.');
                System.Halt(errBadMapUnit);
                   END;
           {if-then}
           gdwWorkSegNum := gdwIndex;
           gdwProtModeSegNum := arrSegDesc256[gdwIndex].liStartAddr;

           System.WriteLn(asProgramPrompt+'Seek offset for segment table in exefile.');
           gliSeekOfs := gliNewHdrOfs + grecNewExeFileHdr.dwSegmentTableOfs;
           System.Seek(gfOutputStream,gliSeekOfs);
           IF  (System.FilePos(gfOutputStream) <> gliSeekOfs)
             THEN  BEGIN
               System.WriteLn(asProgramPrompt+'Cannot locate segment table in exefile.');
               System.Halt(errBadSeekOfSegmentTable);
                   END;
           {if-then}

           gdwIndex := 0;
           REPEAT
              System.Inc(gdwIndex);
              System.WriteLn(asProgramPrompt+'Read a segment table entry #',gdwIndex);
              System.BlockRead(gfOutputStream,grecSegmentInfo,System.SizeOf(grecSegmentInfo));
           UNTIL ((gdwIndex = gdwProtModeSegNum) OR
                  (gdwIndex > grecNewExeFileHdr.dwSegmentCount));
           {repeat-until}

           IF  (gdwIndex > grecNewExeFileHdr.dwSegmentCount)
             THEN  BEGIN
               System.WriteLn(asProgramPrompt+'Mismatch entry in segment table.');
               System.Halt(errMismatchSegmentTableEntry);
                   END;
           {if-then}
           System.WriteLn(asProgramPrompt+'Calculate offset of unit in exefile.');
           gdwTemp := grecNewExeFileHdr.dwFileAlignSizeShift;
           IF  (gdwTemp = 0)
             THEN  gdwTemp := 9;  {512-byte page}
           {if-then}
           gliSeekOfs := (System.Longint(grecSegmentInfo.dwFileOfsAbs) SHL gdwTemp);
           gliSeekOfs := gliSeekOfs + arrSegDesc256[gdwWorkSegNum].liEndAddr;
               END
         ELSE  BEGIN
           System.WriteLn(asProgramPrompt+'Read a header of executable file.');
           System.BlockRead(gfOutputStream,grecExeFileHdr,System.SizeOf(grecExeFileHdr));

           WITH  (grecExeFileHdr)  DO
           BEGIN
              IF  (dwExeSignature <> $5A4D) AND (dwExeSignature <> $4D5A)
                THEN  BEGIN
                   System.WriteLn(asProgramPrompt+'Not valid executable file.');
                   System.Halt(errBadExeFile);
                      END;
              {if-then}
              System.WriteLn(asProgramPrompt+'Calculate offset for unit in file.');
              gdwIndex := 0;
              gsTempInput := asBlank;
              REPEAT
                System.Inc(gdwIndex);
                WITH  (arrSegDesc256[gdwIndex])  DO
                   IF  (bDescPresent)
                     THEN  gsTempInput := _fnsUpcaseStr(sSegName64);
                   {if-then}
                {with-do}
              UNTIL  ((gsTempInput = 'SHOWTERR') OR (gdwIndex > aMaxSegNum));
              {repeat-until}
              IF  (gdwIndex > aMaxSegNum)
                THEN  BEGIN
                   System.WriteLn(asProgramPrompt+'Cannot find SHOWTERR unit.');
                   System.Halt(errBadMapUnit);
                      END;
              {if-then}
              gliSeekOfs := System.Longint(dwHeaderSizeInParas) * 16 +
                            arrSegDesc256[gdwIndex].liStartAddr;
           END;
           {with-do}
                   END;
        {if-then-else}

       {* seek file position *}
       System.WriteLn(asProgramPrompt+'Seek offset for unit in file.');
       System.Seek(gfOutputStream,gliSeekOfs);
       IF  (System.FilePos(gfOutputStream) <> gliSeekOfs)
         THEN  BEGIN
           System.WriteLn(asProgramPrompt+'Cannot locate unit in file.');
           System.Halt(errBadSeekOfUnitInFile);
               END;
       {if-then}

       {* read a unit into memory *}
       IF  (gbProtModeAppOk)
         THEN  gdwIndex := gdwWorkSegNum;
       {if-then}
       gdwTemp := arrSegDesc256[gdwIndex].liSegSize;

       System.WriteLn(asProgramPrompt+'Allocate space for unit on heap.');
       System.GetMem(glpUnitCode,gdwTemp);

       System.WriteLn(asProgramPrompt+'Read unit from file into memory.');
       System.BlockRead(gfOutputStream,
                        System.Mem[System.Seg(glpUnitCode^):System.Ofs(glpUnitCode^)],
                        gdwTemp);

       {* now update the reserved map info in unit *}
       System.WriteLn(asProgramPrompt+'Search for map space in unit.');
       gsTempInput := 'INFMAP';
       gdwIndex := _fndwSearchPatternInBuf(glpUnitCode,gdwTemp,gsTempInput);
       IF  (gdwIndex = $FFFF)
         THEN  BEGIN
           System.WriteLn(asProgramPrompt+'Cannot locate info map in unit.');
           System.Halt(errBadInfoMapForUnit);
               END;
       {if-then}
       gdwIndex := gdwIndex+System.Length(gsTempInput);
       gdwMapSize := System.MemW[System.Seg(glpUnitCode^):
               (System.Ofs(glpUnitCode^)+gdwIndex)];
       IF (gdwMapSize < gdwHeapOfs)
         THEN  BEGIN
           System.WriteLn(asProgramPrompt+'No space in unit for map; need = ',
                          gdwHeapOfs,' bytes.');
           System.Halt(errTooLargeNewMap);
               END;
       {if-then}
       System.WriteLn(asProgramPrompt+'Copy new map into unit.');
       System.Inc(gdwIndex,3);  {skip dwMapInfo and dbRETF}
       System.Move(System.Mem[System.Seg(glpMemoryBlock^):System.Ofs(glpMemoryBlock^)],
                   System.Mem[System.Seg(glpUnitCode^):(System.Ofs(glpUnitCode^)+gdwIndex)],
                   gdwHeapOfs);

       {* seek file position *}
       System.WriteLn(asProgramPrompt+'Seek offset for unit in file to write.');
       System.Seek(gfOutputStream,gliSeekOfs);
       IF  (System.FilePos(gfOutputStream) <> gliSeekOfs)
         THEN  BEGIN
           System.WriteLn(asProgramPrompt+'Cannot locate unit in file to write.');
           System.Halt(errBadSeekOfUnitInFileToWrite);
               END;
       {if-then}

       {* write a updated unit back into file *}
       System.WriteLn(asProgramPrompt+'Write back unit with debuginfo into file.');
       System.BlockWrite(gfOutputStream,
                        System.Mem[System.Seg(glpUnitCode^):System.Ofs(glpUnitCode^)],
                        gdwTemp);
       System.WriteLn(asProgramPrompt+'Deallocate space for unit on heap.');
       System.FreeMem(glpUnitCode,gdwTemp);

       {* restore old date/time for output file *}
       Dos.SetFTime(gfOutputStream,gddOutFileTime);

       {* close output stream *}
       System.WriteLn(asProgramPrompt+'Close exefile '+gsOutFileName);
       System.Close(gfOutputStream);

{$ENDIF} {DebugVersion}

         END;
  {if-then}

  {** free memory on heap **}
  System.WriteLn(asProgramPrompt+'Deallocate memory on heap.');
  System.FreeMem(glpMemoryBlock,gdwMemBlockSize);

  {** report all done **}
  System.WriteLn(asProgramPrompt+'Done.');

  {* System.Halt(errTerminateOk); *}
END.

