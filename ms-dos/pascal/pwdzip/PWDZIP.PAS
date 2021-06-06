{-----------------------------------------------------------------------}
{ PROJECT		MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES	}
{			(COMMERCIAL PURPOSE)				}
{ LIBRARY		SYSTEM UTILITIES                                }
{ MODULE		PASSWORD_FOR_ZIP_FILE                           }
{ FILE NAME		PWDZIP.PAS					}
{ PURPOSE		Find the password for encrypted ZIP-files       }
{ VERSION		1.04						}
{ DATE			08-Nov-93					}
{ DESIGN		Dmitry Stefankov				}
{ IMPLEMENTATION	Dmitry Stefankov 				}
{ COMPANY		Freelance Software Engineer                     }
{ ADDRESS		Isakowskogo str, 4-2-30				}
{			Moscow, 123181					}
{			USSR						}
{			Tel. 007 (095) 944-6304				}
{ COPYRIGHT NOTICE	Copyright (C) 1987-1993, Dmitry Stefankov	}
{ RESTRICTED RIGHTS	FOR INTERNAL USE ONLY.				}
{                       THIS FILE CONTAINS PROPRIETARY AND CONFIDENTIAL }
{                       INFORMATION. COPYING AND REPRODUCTION WITHOUT   }
{                       PRIOR WRITTEN PERMISSION IS PROHIBITED.         }
{ COMPUTER		IBM PC or compatible				}
{ OPERATING SYSTEM	MS/PC-DOS Version 3.30 or higher		}
{ COMPILER		Turbo Pascal Version 6.0			}
{                       (Borland International Inc.) or compatible      }
{ ASSEMBLY LANGUAGE	Microsoft MASM 5.10 or compatible               }
{ LINKER		Turbo Pascal internal                           }
{ ARGUMENTS		<arcfile>    -  archive file                    }
{                       <userfile>   -  user encrypted file in archive  }
{                       <tablefile>  -  user table file for char space  }
{                       <pwdfile>    -  user password file (binary)     }
{                       <pwdminlen>  -  minimal password length         }
{                       <pwdmaxlen>  -  maximal password length         }
{                       <pwdmore>    -  describe password in detail     }
{                       <batchmode>  -  use batch mode to answer        }
{                       <foundpwd>   -  user file to write found pwd(s) }
{ RETURN		See description	below    			}
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{			External Object Files				}
{			None                                            }
{                       Project Maintence Files                         }
{                       PWDZIP.MAK        (auto compiling & linking)    }
{ NATURAL LANGUAGE      English Language                             	}
{ SPECIAL		The "broot-force" is no effective to total scan }
{                       but it is matching if the password can be       }
{                       described as possible as exactly.               }
{                       The assembly code is specially optimized for    }
{                       80386 or higher INTEL series processor.         }
{ DESCRIPTION		1. Set up defaults                              }
{                       2. Read ZIP-file                                }
{                       3. Find the user file in archive                }
{                       4. Read user character map file if present      }
{                       5. Read user password file if present           }
{                       6. Ask min- and max. password length            }
{                       7. Ask about batch, auto-detect, and statistics }
{                          modes                                        }
{                       8. Ask also about writing of found password(s)  }
{                          to file                                      }
{                       9. More description for the password if user    }
{                          wants this                                   }
{                      10. Build the static table for the encryption    }
{                          keys (one and two symbol password)           }
{                      11. Broot-force algorithm:                       }
{                         a. We search for the possible password from   }
{                            the last character and use always the res- }
{                            sults of the previous calculations         }
{                         b. We use the possible string if all chars in }
{                            this string are enabled to scan            }
{                         c. User can stop this process at any moment   }
{                            by the key pressing                        }
{                      12. Exit:                                        }
{                         a. We write the last string to file if need   }
{                         b. Try to find the true password from all     }
{                            found if user wanted it                    }
{ REVISION HISTORY	Dima Stefankov (DS)				}
{   			0.10   07-Oct-92  DS  initial pre-release	}
{			1.00   14-Jun-93  DS  added 32-bit code,        }
{                                             added parms processing,   }
{                                             fixed many bugs           }
{                       1.01   22-Jun-93  DS  optimized code (286,486)  }
{			1.02   28-Sep-93  DS  fixed a problem with new  }
{					      PKWARE 2.04g version	}
{                       1.03   11-Oct-93  DS  fixed bug with 1-2 sympwd,}
{                                             added file options/buffers}
{			1.04   22-Oct-93  DS  fixed with static keys co-}
{					      pying			}
{		        1.05   08-Nov-93  DS  fixed DOS EXEC problem	}
{-----------------------------------------------------------------------}

{*** program body ***}
{* NOTE:
   This following program statement is a true name for the program but
   the Microsoft utility MAPSYM.EXE don't like  the long segment names and
   therefore we must use the shortest name for our program.
   Welcome to the MS-Problems-World!
   PROGRAM   CRACK_PASSWORD_FOR_ENCRYPTED_ZIP_FILE;
*}
PROGRAM   CRACK_PWDZIPFILE;


{** switches for compilation **}
{$M 32768,32768,32768}   {*  program memory requirements  *}
{$S-}		         {*  stack checking               *}
{$R-}                    {*  range checking               *}

{* generate miscellaneous versions *}
{$DEFINE  DebugVersion}                       {*  source code debugging  *}
{$IFDEF DebugVersion}
  {***$DEFINE  DebugTrace}                    {* display current pwd     *}
{$ENDIF}
{$DEFINE Use386code}                       {* use 386-processor code  *}
{$IFDEF  Use386code}
    {$DEFINE  OptimizeCodeFor386}             {* fastest code for 386+   *}
    {$IFNDEF  OptimizeCodeFor386}
       {***$DEFINE  OptimizeCodeFor486}       {* fastest code for 486+   *}
    {$ENDIF}
{$ENDIF}
{$DEFINE HeavenCalculations}               {* use calculations always *}
{$DEFINE  OptimizeCodeInAssembly}             {* use more fast code      *}
{$IFDEF  OptimizeCodeInAssembly}
   {$DEFINE  UseFastestCode}                  {* max. optimized code     *}
   {$DEFINE  OptimizeCodeFor186}              {* fastest code for 186+   *}
   {$IFDEF  OptimizeCodeFor186}
      {$G+}                                   {* Turbo support for 286+  *}
   {$ENDIF}
{$ENDIF}
{$DEFINE  UseStackForTemporaryStore}          {* stack more fast?        *}
{$DEFINE  UseMoreStaticKeysForSecondSymbol}   {* pwd[2] for n..n+127     *}
{$DEFINE  AutomaticSearchTruePassword}        {* search true pwd at end  *}
                                              {* do test batch file      *}
{$DEFINE  AutomaticGenerationTestsForTruePassword}
{$DEFINE  MakeStatistic}                      {* output calc. statistics *}
  {$IFDEF  MakeStatistic}
      {$DEFINE  EncryptionKeysDump}           {* dump for all phases     *}
  {$ENDIF}
{$DEFINE  MakeDiagnosticDump}                 {* dump for diag. purpose  *}
{$DEFINE  PKWARE204G}			      {* changes in crypt-scheme *}


{*** other modules ***}
uses
  Dos;


{*** constants part ***}
CONST
     asPurpose                  =       'Crack ZIP-Password';
     asVersion                  =       '1.05';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1987, 1993';
     asProgram                  =       'PwdZip';
     asProgramPrompt            =       asProgram+': ';
     asProgramU                 =       'PWDZIP';

     { exit codes }
       errTerminateOK           =     0;
       errNoParms               =     1;
       errBadNameForZipFile     =     2;
       errBadNameForUserFile    =     3;
       errReadTableFile         =     4;
       errReadPwdFile           =     5;
       errReadArchiveFile       =     6;
       errBadArchiveFileName    =     7;
       errNotEncryptedFile      =     8;
       errEndOfArchiveFile      =     9;
       errBadArchiveFile        =     10;
       errInsufficientMemory    =     11;
       errBadTableFilename      =     12;
       errBadPasswordFilename   =     13;
       errBadCreatePasswordFile =     14;
       errWritePwdFile          =     15;
       errBadFoundPwdFilename   =     16;
       errBadStatFileName       =     17;
       errEmptyFoundPwdFilename =     18;
       errBadTestBatchFilename  =     19;

    { miscellaneous }
      aHexRadix                 =     16;
      achHexPrefix              =     '$';
      achPoint                  =     '.';
      achZero                   =     '0';
      achOne                    =     '1';
      achColon                  =     ':';
      aYes                      =     'Y';
      asYes                     =     'yes';
      aNo                       =     'N';
      asNo                      =     'no';
      aDosDirDelim              =     '\';
      aDosExtMark               =     '.';
      asDefZipExt               =     'zip';
      asDefSrchExt              =     'exe';
      asDefPwdExt               =     'pwd';
      asDefTblExt               =     'tbl';
      asDefFoundPwdExt          =     'fnd';
      asDefStatPwdExt           =     'sta';
      asDefBatchFileExt         =     'bat';
      asPkUnzipName             =     'PKUNZIP.EXE';
      achReDirectedOutput       =     '>';
      asNulDevice               =     'NUL';
      asDefPwdFileName          =     'lasthere';

    { PKWARE hard-coded values }
      aLocZipSign               =     $04034B50;
      aCentralZipSign           =     $02014B50;
      aEndOfCentralZipSign      =     $06054B50;
      btFileIsEncrypted         =     $01;
      aRandomDataLen            =     12;
      aCRC32MaigicNumber        =     $DEBB20E3;
      aPkInitKeyZero            =     305419896;     { $12345678 }
      aPkInitKeyOne             =     591751049;     { $23456789 }
      aPkInitKeyTwo             =     878082192;     { $34567890 }

    { password }
      aMinPswdVal               =     1;
      aMaxPswdVal               =     80;
      aBlock63                  =     63;
      aBlock127                 =     127;

    { ASCII codes }
      achNULL                   =     #00;
      achLF                     =     #10;
      achCR                     =     #13;
      achBlank                  =     #32;

    { string equates }
      asBlank                   =     '';
      asSpace                   =     achBlank;
      asSpace2                  =     asSpace + asSpace;
      asSpace4                  =     asSpace2 + asSpace2;
      asSpace8                  =     asSpace4 + asSpace4;

    { memory values }
      aBytesPerParagraph        =     16;
      aParasIn64K               =     $1000;
      aParasIn192K              =     aParasIn64K * 3;
  {$IFDEF   UseMoreStaticKeysForSecondSymbol}
      aProgramMemory            =     580;
  {$ELSE}
      aProgramMemory            =     380;
  {$ENDIF} {UseMoreStaticKeysForSecondSymbol}

    { time constants }
      aHundrenthsPerSec         =     100;
      aSecondsPerMin            =     60;
      aMinutesPerHour           =     60;
      aHundrenthsPerSecHalf     =     aHundrenthsPerSec DIV 2;

    { DOS streams }
      adwDosStdOutStream        =     $01;

    { size of encryption keys record }
      aEncryptionKeysSize       =     12;
      aEncryptionKeysSizeDiv2   =     6;
      aEncryptionKeysSizeDiv4   =     3;

    { input buffer sizes }
      aMaxFoundPwdBufSize       =     2048;
      aMaxStatPwdBufSize        =     16384;


{*** type declaration ***}
TYPE
  {* strings *}
       STR2                     =     STRING[2];
       STR3                     =     STRING[3];
       STR4                     =     STRING[4];
       STR5                     =     STRING[5];
       STR8                     =     STRING[8];
       STR80                    =     STRING[80];


    {* Information about password for search *}
       recSymInPassword  =  RECORD
                        dbCurValue                :      System.Byte;
                        dbMinSymValue             :      System.Byte;
                        dbMaxSymValue             :      System.Byte;
                           END;
    {* recSymInPassword *}


    {****************************************************************
       Overall zipfile format:
           [local file header + file data] . . .
           [central directory] . . . end of central directory record
      Note: Files stored in arbitrary order.  Large zipfiles can span
            multiple diskette media.
     ****************************************************************}


    {* Local header in ZIP file *}
       recLocZipHeader  =  RECORD
                        ddLocHeaderSignature      :      System.Longint; {00}
                        dwSoftwareVersion         :      System.Word;    {04}
                        dwGeneralFlags            :      System.Word;    {06}
                        dwCompressionMethod       :      System.Word;    {08}
                        dwLastModFileTime         :      System.Word;    {0A}
                        dwLastModFileDate         :      System.Word;    {0C}
                        ddCRC32                   :      System.Longint; {0E}
                        ddCompressedSize          :      System.Longint; {12}
                        ddUncompressedSize        :      System.Longint; {16}
                        dwFileNameLength          :      System.Word;    {1A}
                        dwExtraFieldLength        :      System.Word;    {1C}
                           END;
    {* recLocZipHeader *}


    {* Central directory structure in ZIP file *}
       recZipCentralDir  =  RECORD
                        ddCentralDirSignature     :      System.Longint; {00}
                        dwSoftwareVersion         :      System.Word;    {04}
                        dwVersionToExtract        :      System.Word;    {06}
                        dwGeneralFlags            :      System.Word;    {08}
                        dwCompressionMethod       :      System.Word;    {0A}
                        dwLastModFileTime         :      System.Word;    {0C}
                        dwLastModFileDate         :      System.Word;    {0E}
                        ddCRC32                   :      System.Longint; {10}
                        ddCompressedSize          :      System.Longint; {14}
                        ddUncompressedSize        :      System.Longint; {18}
                        dwFileNameLength          :      System.Word;    {1C}
                        dwExtraFieldLength        :      System.Word;    {1E}
                        dwFileCommentLength       :      System.Word;    {20}
                        dwDiskNumberStart         :      System.Word;    {22}
                        dwInternalFileAttr        :      System.Word;    {24}
                        dwExternalFileAttr        :      System.Longint; {26}
                        ddLocalHeaderRelOfs       :      System.Longint; {2A}
                           END;
    {* recZipCentralDir *}


    {* Central directory structure in ZIP file *}
       recEndOfZipCentralDir  =  RECORD
                ddCentralDirEndSignature          :      System.Longint; {00}
                dwThisDiskNumber                  :      System.Word;    {04}
                dwStartCentralDirDiskNum          :      System.Word;    {06}
                dwThisDiskCentralDirTotalEntries  :      System.Word;    {08}
                dwCentralDirTotalEntries          :      System.Word;    {0A}
                ddCentralDirSize                  :      System.Longint; {0C}
                ddCentralDirStartOfsToStartDisk   :      System.Longint; {10}
                dwZipFileCommentLength            :      System.Word;    {14}
                           END;
    {* recEndOfZipCentralDir *}


    {* Time Save feature *}
       recSaveTime      =  RECORD
                     dwHour              :   System.Word;
                     dwMinute            :   System.Word;
                     dwSecond            :   System.Word;
                     dwSec100            :   System.Word;
                           END;
    {* recSaveTime *}


    {* PKWARE encryption keys *}
       recEncryptedKeys      =  RECORD
                     ddKeyZero        :   System.Longint;
                     ddKeyOne         :   System.Longint;
                     ddKeyTwo         :   System.Longint;
                           END;
    {* recEncryptedKeys *}


{* initialiazed variables = TP typed const *}
CONST
   { filenames }
     gasZipFileName              :       STR80           =       asBlank;
     gasPwdFileName              :       STR80           =       asBlank;
     gasTableFileName            :       STR80           =       asBlank;
     gasEncryptedFileName        :       STR80           =       asBlank;
     gasFoundPwdFileName         :       STR80           =       asBlank;
     gasRunPkunzipCommand        :       STR5            =       '-t -s';
   {$IFDEF  AutomaticGenerationTestsForTruePassword}
     gasTestBatchFileName        :       STR80           =       asBlank;
   {$ENDIF} {AutomaticGenerationTestsForTruePassword}
   {$IFDEF   AutomaticSearchTruePassword}
     gasTruePassword             :       STR80           =       asBlank;
     gasPkUnzipPath              :       STR80           =       asBlank;
   {$ENDIF} {AutomaticSearchTruePassword}
   {$IFDEF   MakeStatistic}
     gasStatFileName             :       STR80           =       asBlank;
   {$ENDIF} {MakeStatistic}

   { password description }
      gadbMinPswdLen             :       System.Byte     =       aMinPswdVal;
      gadbMaxPswdLen             :       System.Byte     =       aMaxPswdVal;
      gadbLastCharIndex          :       System.Byte     =       0;


   { hexadecimal digits }
     setHexChars  :    SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];

   { ASCII display character set }
     setDisplayCodesOfASCII    :  SET OF System.Char  =  [#32..#126,#128..#254];

   { ASCII codes table }
     aMinCodeChar           =     0;
     aHalfTableCodeChar     =     127;
     aMaxCodeChar           =     255;
     gbCodesInUseTable      :     ARRAY[aMinCodeChar..aMaxCodeChar]  OF  System.Boolean  =
        (System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {00-07}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {08-0F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {10-17}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {18-1F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {20-27}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {28-2F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {30-37}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {38-3F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {40-47}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {48-4F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {50-57}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {58-5F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {60-67}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {68-6F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {70-77}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {78-7F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {80-87}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {88-8F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {90-97}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {98-9F}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {A0-A7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {A8-AF}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {B0-B7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {B8-BF}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {C0-C7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {C8-CF}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {D0-D7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {D8-DF}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {E0-E7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {E8-EF}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True,  {F0-F7}
         System.True,System.True,System.True,System.True,System.True,System.True,System.True,System.True); {F8-FF}

   { general purpose }
     gabCpuIs386                 :    System.Boolean     =     System.False;
     gabUseFileToWritePwd        :    System.Boolean     =     System.False;
     gabBatchModeOn              :    System.Boolean     =     System.False;
     gabKeyPressed               :    System.Boolean     =     System.False;
     gabDisplayOn                :    System.Boolean     =     System.False;
     gadbUserBreakOn             :    System.Boolean     =     System.False;
     gliFoundPwdCount            :    System.Longint     =     0;
  {$IFDEF    Use386code}
     gabInitCRCTable             :    System.Boolean     =     System.True;
   {$ENDIF} {Use386code}
   {$IFDEF   DebugTrace}
     gabCurrentPwdDisplayOn      :    System.Boolean     =     System.True;
   {$ENDIF} {DebugTrace}
   {$IFDEF   MakeStatistic}
     gabFoundPwdStatisticsON     :    System.Boolean     =     System.False;
     gliSearchPwdCount           :    System.Longint     =     0;
   {$ENDIF} {MakeStatistic}
   {$IFDEF  AutomaticGenerationTestsForTruePassword}
     gabDoTestBatchFile          :    System.Boolean     =     System.True;
   {$ENDIF} {AutomaticGenerationTestsForTruePassword}
   {$IFDEF   AutomaticSearchTruePassword}
     gabAutoSearchTruePwdON      :    System.Boolean     =     System.True;
     gadbDefaultPkUnzipInUse     :    System.Boolean     =     System.True;
   {$ENDIF} {AutomaticSearchTruePassword}



{*** variables part ***}
VAR
   gdbKeysForOneSymPswd :   ARRAY[aMinCodeChar..aMaxCodeChar]  OF  recEncryptedKeys;
   gdbLastPasswordKeys  :   ARRAY[aMinPswdVal..aMaxPswdVal]    OF  recEncryptedKeys;
   gdbSearchPassword    :   ARRAY[aMinPswdVal..aMaxPswdVal]    OF  recSymInPassword;
 {$IFDEF   UseFastestCode}
   gdbSearchPwdOfsTable :   ARRAY[aMinPswdVal..aMaxPswdVal]    OF  System.Word;
   gdbLastPwdKeysOfsTabl:   ARRAY[aMinPswdVal..aMaxPswdVal]    OF  System.Word;
   gdbOneSymKeysOfsTabl :   ARRAY[aMinCodeChar..aMaxCodeChar]  OF  System.Word;
 {$ENDIF} {UseFastestCode}

   gfZipInStream        :   FILE;
   gfUserPwdInStream    :   FILE;
   gfUserTableInStream  :   FILE;
   gfFoundPwdOutStream  :   System.Text;
 {$IFDEF   MakeStatistic}
   gfStatOutStream      :   System.Text;
 {$ENDIF} {MakeStatistic}
   {$IFDEF  AutomaticGenerationTestsForTruePassword}
   gfBatchOutStream     :   System.Text;
   {$ENDIF} {AutomaticGenerationTestsForTruePassword}
 {$IFDEF   AutomaticSearchTruePassword}
   gfNulDeviceStream    :   FILE;
   grecNulDeviceDesc    :   Dos.FileRec  ABSOLUTE  gfNulDeviceStream;
 {$ENDIF} {AutomaticSearchTruePassword}

   gdbLocFileHeader     :   recLocZipHeader;
   gdbRandomValues      :   ARRAY[1..aRandomDataLen]  OF  System.Byte;
   gdbTempRandomBuffer  :   ARRAY[1..aRandomDataLen]  OF  System.Byte;

   gsDosParmLine        :   STRING;
   gsTempInput          :   STRING;
   gsSavePwd            :   STRING;

   grecEarlyTime        :   recSaveTime;
   grecInitTime         :   recSaveTime;
   grecLastTime         :   recSaveTime;
   grecWorkTime         :   recSaveTime;
   grecStartTime        :   recSaveTime;
   grecTrueTime         :   recSaveTime;

   gliFileOfs           :   System.Longint;
   gddFileCRC32         :   System.Longint;

   gliTempVal           :   System.Longint;

   gdwCodeCRCTableSeg	:   System.Word;

   gddKeyZero           :   System.Longint;             { keep together! }
   gddKeyOne            :   System.Longint;
   gddKeyTwo            :   System.Longint;
   gdwKeyZeroSeg        :   System.Word;                { keep together! }
   gdwKeyOneSeg         :   System.Word;
   gdwKeyTwoSeg         :   System.Word;
{$IFDEF   UseMoreStaticKeysForSecondSymbol}
   gdwKeyZeroSegSym2    :   System.Word;                { keep together! }
   gdwKeyOneSegSym2     :   System.Word;
   gdwKeyTwoSegSym2     :   System.Word;
{$ENDIF} {UseMoreStaticKeysForSecondSymbol}

   gdwByteCount         :   System.Word;
   gdwFileCount         :   System.Word;
   gdwMemOfs            :   System.Word;
   gdwResCount          :   System.Word;

   gdwParamNum          :   System.Word;
   gdwProcessCode       :   System.Word;
   giErrorCode          :   System.Integer;

   gdwSaveRegBP         :   System.Word;
   gdwTempCount         :   System.Word;
   gdwTemp              :   System.Word;
   gdwNulDevHandle      :   System.Word;
   gdwConDevHandle      :   System.Word;

   gdbIndex             :   System.Byte;
   gdbSymIndex          :   System.Byte;
   gdbTemp              :   System.Byte;

   gchTemp              :   System.Char;

   gbStatusOk           :   System.Boolean;

   gdbLargeFoundPwdBuf  :   ARRAY[1..aMaxFoundPwdBufSize]  OF  System.Char;
   gdbLargeStatPwdBuf   :   ARRAY[1..aMaxStatPwdBufSize]   OF  System.Char;


{* Functions *}

FUNCTION  _fndwLowWord(liNum  :  System.Longint)  :  System.Word;
{* Returns a low-order word of argument. *}
INLINE($58/          {  pop ax   ; Lo(Arg)  }
       $5A);         {  pop dx   ; Hi(Arg)  }
{ _fndwLowWord }


FUNCTION  _fnsByteToBitString(dbInput : System.Byte; chZero,chOne : System.Char) : STR8;
{* return the bit representation of the byte. *}
      inline($5A                 {    pop   dx          ; DL = One           }
            /$5B                 {    pop   bx          ; BL = Zero          }
            /$58                 {    pop   ax          ; AL = Number        }
            /$88/$C7             {    mov   bh,al	; BH = Number        }
            /$89/$E7             {    mov   di,sp       ; make stack frame   }
            /$36/$C4/$3D         {    les   di,ss:[di]  ; ES:DI -> string    }
            /$B9/$08/$00         {    mov   cx,8        ; repeat count       }
	    /$FC		 {    cld		; forward direction  }
            /$88/$C8             {    mov   al,cl       ; AL = string length }
	    /$AA		 {    stosb		; store it           }
                                 { NextBit:                                  }
            /$88/$D8             {    mov   al,bl       ; AL = Zero          }
            /$D0/$E7             {    shl   bh,1        ; transfer bit in CF }
            /$73/$02             {    jnc   BitDone     ; if not (CY), zero  }
            /$88/$D0             {    mov   al,dl        ; AL = One          }
                                 { BitDone:                                  }
            /$AA	         {    stosb		; put a Char         }
            /$E2/$F5);           {    loop  NextBit     ; repeat till done   }
{ _fnsByteToBitString }


{* Fast assembly code *}

PROCEDURE  _DummyProc; near; assembler;
{* Contains a CRC-32 table,
   that must be start from the offset 0 in a TP code segment! *}
asm
{ SOURCE FILE:  CRC32.BIN						}
{ Created by Bin2asm utility, Copyright (c) 1987, 1993  Dima Stefankov  }
	DB	000h,000h,096h,030h,02Ch,061h,0BAh,051h
	DB	019h,0C4h,08Fh,0F4h,035h,0A5h,0A3h,095h
	DB	032h,088h,0A4h,0B8h,01Eh,0E9h,088h,0D9h
	DB	02Bh,04Ch,0BDh,07Ch,007h,02Dh,091h,01Dh
	DB	064h,010h,0F2h,020h,048h,071h,0DEh,041h
	DB	07Dh,0D4h,0EBh,0E4h,051h,0B5h,0C7h,085h
	DB	056h,098h,0C0h,0A8h,07Ah,0F9h,0ECh,0C9h
	DB	04Fh,05Ch,0D9h,06Ch,063h,03Dh,0F5h,00Dh
	DB	0C8h,020h,05Eh,010h,0E4h,041h,072h,071h
	DB	0D1h,0E4h,047h,0D4h,0FDh,085h,06Bh,0B5h
	DB	0FAh,0A8h,06Ch,098h,0D6h,0C9h,040h,0F9h
	DB	0E3h,06Ch,075h,05Ch,0CFh,00Dh,059h,03Dh
	DB	0ACh,030h,03Ah,000h,080h,051h,016h,061h
	DB	0B5h,0F4h,023h,0C4h,099h,095h,00Fh,0A5h
	DB	09Eh,0B8h,008h,088h,0B2h,0D9h,024h,0E9h
	DB	087h,07Ch,011h,04Ch,0ABh,01Dh,03Dh,02Dh
	DB	090h,041h,006h,071h,0BCh,020h,02Ah,010h
	DB	089h,085h,01Fh,0B5h,0A5h,0E4h,033h,0D4h
	DB	0A2h,0C9h,034h,0F9h,08Eh,0A8h,018h,098h
	DB	0BBh,00Dh,02Dh,03Dh,097h,06Ch,001h,05Ch
	DB	0F4h,051h,062h,061h,0D8h,030h,04Eh,000h
	DB	0EDh,095h,07Bh,0A5h,0C1h,0F4h,057h,0C4h
	DB	0C6h,0D9h,050h,0E9h,0EAh,0B8h,07Ch,088h
	DB	0DFh,01Dh,049h,02Dh,0F3h,07Ch,065h,04Ch
	DB	058h,061h,0CEh,051h,074h,000h,0E2h,030h
	DB	041h,0A5h,0D7h,095h,06Dh,0C4h,0FBh,0F4h
	DB	06Ah,0E9h,0FCh,0D9h,046h,088h,0D0h,0B8h
	DB	073h,02Dh,0E5h,01Dh,05Fh,04Ch,0C9h,07Ch
	DB	03Ch,071h,0AAh,041h,010h,010h,086h,020h
	DB	025h,0B5h,0B3h,085h,009h,0D4h,09Fh,0E4h
	DB	00Eh,0F9h,098h,0C9h,022h,098h,0B4h,0A8h
	DB	017h,03Dh,081h,00Dh,03Bh,05Ch,0ADh,06Ch
	DB	020h,083h,0B6h,0B3h,00Ch,0E2h,09Ah,0D2h
	DB	039h,047h,0AFh,077h,015h,026h,083h,016h
	DB	012h,00Bh,084h,03Bh,03Eh,06Ah,0A8h,05Ah
	DB	00Bh,0CFh,09Dh,0FFh,027h,0AEh,0B1h,09Eh
	DB	044h,093h,0D2h,0A3h,068h,0F2h,0FEh,0C2h
	DB	05Dh,057h,0CBh,067h,071h,036h,0E7h,006h
	DB	076h,01Bh,0E0h,02Bh,05Ah,07Ah,0CCh,04Ah
	DB	06Fh,0DFh,0F9h,0EFh,043h,0BEh,0D5h,08Eh
	DB	0E8h,0A3h,07Eh,093h,0C4h,0C2h,052h,0F2h
	DB	0F1h,067h,067h,057h,0DDh,006h,04Bh,036h
	DB	0DAh,02Bh,04Ch,01Bh,0F6h,04Ah,060h,07Ah
	DB	0C3h,0EFh,055h,0DFh,0EFh,08Eh,079h,0BEh
	DB	08Ch,0B3h,01Ah,083h,0A0h,0D2h,036h,0E2h
	DB	095h,077h,003h,047h,0B9h,016h,02Fh,026h
	DB	0BEh,03Bh,028h,00Bh,092h,05Ah,004h,06Ah
	DB	0A7h,0FFh,031h,0CFh,08Bh,09Eh,01Dh,0AEh
	DB	0B0h,0C2h,026h,0F2h,09Ch,0A3h,00Ah,093h
	DB	0A9h,006h,03Fh,036h,085h,067h,013h,057h
	DB	082h,04Ah,014h,07Ah,0AEh,02Bh,038h,01Bh
	DB	09Bh,08Eh,00Dh,0BEh,0B7h,0EFh,021h,0DFh
	DB	0D4h,0D2h,042h,0E2h,0F8h,0B3h,06Eh,083h
	DB	0CDh,016h,05Bh,026h,0E1h,077h,077h,047h
	DB	0E6h,05Ah,070h,06Ah,0CAh,03Bh,05Ch,00Bh
	DB	0FFh,09Eh,069h,0AEh,0D3h,0FFh,045h,0CFh
	DB	078h,0E2h,0EEh,0D2h,054h,083h,0C2h,0B3h
	DB	061h,026h,0F7h,016h,04Dh,047h,0DBh,077h
	DB	04Ah,06Ah,0DCh,05Ah,066h,00Bh,0F0h,03Bh
	DB	053h,0AEh,0C5h,09Eh,07Fh,0CFh,0E9h,0FFh
	DB	01Ch,0F2h,08Ah,0C2h,030h,093h,0A6h,0A3h
	DB	005h,036h,093h,006h,029h,057h,0BFh,067h
	DB	02Eh,07Ah,0B8h,04Ah,002h,01Bh,094h,02Bh
	DB	037h,0BEh,0A1h,08Eh,01Bh,0DFh,08Dh,0EFh
	DB	000h,000h,007h,077h,00Eh,0EEh,009h,099h
	DB	06Dh,007h,06Ah,070h,063h,0E9h,064h,09Eh
	DB	0DBh,00Eh,0DCh,079h,0D5h,0E0h,0D2h,097h
	DB	0B6h,009h,0B1h,07Eh,0B8h,0E7h,0BFh,090h
	DB	0B7h,01Dh,0B0h,06Ah,0B9h,0F3h,0BEh,084h
	DB	0DAh,01Ah,0DDh,06Dh,0D4h,0F4h,0D3h,083h
	DB	06Ch,013h,06Bh,064h,062h,0FDh,065h,08Ah
	DB	001h,014h,006h,063h,00Fh,0FAh,008h,08Dh
	DB	06Eh,03Bh,069h,04Ch,060h,0D5h,067h,0A2h
	DB	003h,03Ch,004h,04Bh,00Dh,0D2h,00Ah,0A5h
	DB	0B5h,035h,0B2h,042h,0BBh,0DBh,0BCh,0ACh
	DB	0D8h,032h,0DFh,045h,0D6h,0DCh,0D1h,0ABh
	DB	0D9h,026h,0DEh,051h,0D7h,0C8h,0D0h,0BFh
	DB	0B4h,021h,0B3h,056h,0BAh,0CFh,0BDh,0B8h
	DB	002h,028h,005h,05Fh,00Ch,0C6h,00Bh,0B1h
	DB	06Fh,02Fh,068h,058h,061h,0C1h,066h,0B6h
	DB	0DCh,076h,0DBh,001h,0D2h,098h,0D5h,0EFh
	DB	0B1h,071h,0B6h,006h,0BFh,09Fh,0B8h,0E8h
	DB	007h,078h,000h,00Fh,009h,096h,00Eh,0E1h
	DB	06Ah,07Fh,06Dh,008h,064h,091h,063h,0E6h
	DB	06Bh,06Bh,06Ch,01Ch,065h,085h,062h,0F2h
	DB	006h,06Ch,001h,01Bh,008h,082h,00Fh,0F5h
	DB	0B0h,065h,0B7h,012h,0BEh,08Bh,0B9h,0FCh
	DB	0DDh,062h,0DAh,015h,0D3h,08Ch,0D4h,0FBh
	DB	0B2h,04Dh,0B5h,03Ah,0BCh,0A3h,0BBh,0D4h
	DB	0DFh,04Ah,0D8h,03Dh,0D1h,0A4h,0D6h,0D3h
	DB	069h,043h,06Eh,034h,067h,0ADh,060h,0DAh
	DB	004h,044h,003h,033h,00Ah,0AAh,00Dh,0DDh
	DB	005h,050h,002h,027h,00Bh,0BEh,00Ch,0C9h
	DB	068h,057h,06Fh,020h,066h,0B9h,061h,0CEh
	DB	0DEh,05Eh,0D9h,029h,0D0h,0B0h,0D7h,0C7h
	DB	0B3h,059h,0B4h,02Eh,0BDh,0B7h,0BAh,0C0h
	DB	0B8h,0EDh,0BFh,09Ah,0B6h,003h,0B1h,074h
	DB	0D5h,0EAh,0D2h,09Dh,0DBh,004h,0DCh,073h
	DB	063h,0E3h,064h,094h,06Dh,00Dh,06Ah,07Ah
	DB	00Eh,0E4h,009h,093h,000h,00Ah,007h,07Dh
	DB	00Fh,0F0h,008h,087h,001h,01Eh,006h,069h
	DB	062h,0F7h,065h,080h,06Ch,019h,06Bh,06Eh
	DB	0D4h,0FEh,0D3h,089h,0DAh,010h,0DDh,067h
	DB	0B9h,0F9h,0BEh,08Eh,0B7h,017h,0B0h,060h
	DB	0D6h,0D6h,0D1h,0A1h,0D8h,038h,0DFh,04Fh
	DB	0BBh,0D1h,0BCh,0A6h,0B5h,03Fh,0B2h,048h
	DB	00Dh,0D8h,00Ah,0AFh,003h,036h,004h,041h
	DB	060h,0DFh,067h,0A8h,06Eh,031h,069h,046h
	DB	061h,0CBh,066h,0BCh,06Fh,025h,068h,052h
	DB	00Ch,0CCh,00Bh,0BBh,002h,022h,005h,055h
	DB	0BAh,0C5h,0BDh,0B2h,0B4h,02Bh,0B3h,05Ch
	DB	0D7h,0C2h,0D0h,0B5h,0D9h,02Ch,0DEh,05Bh
	DB	064h,09Bh,063h,0ECh,06Ah,075h,06Dh,002h
	DB	009h,09Ch,00Eh,0EBh,007h,072h,000h,005h
	DB	0BFh,095h,0B8h,0E2h,0B1h,07Bh,0B6h,00Ch
	DB	0D2h,092h,0D5h,0E5h,0DCh,07Ch,0DBh,00Bh
	DB	0D3h,086h,0D4h,0F1h,0DDh,068h,0DAh,01Fh
	DB	0BEh,081h,0B9h,0F6h,0B0h,06Fh,0B7h,018h
	DB	008h,088h,00Fh,0FFh,006h,066h,001h,011h
	DB	065h,08Fh,062h,0F8h,06Bh,061h,06Ch,016h
	DB	00Ah,0A0h,00Dh,0D7h,004h,04Eh,003h,039h
	DB	067h,0A7h,060h,0D0h,069h,049h,06Eh,03Eh
	DB	0D1h,0AEh,0D6h,0D9h,0DFh,040h,0D8h,037h
	DB	0BCh,0A9h,0BBh,0DEh,0B2h,047h,0B5h,030h
	DB	0BDh,0BDh,0BAh,0CAh,0B3h,053h,0B4h,024h
	DB	0D0h,0BAh,0D7h,0CDh,0DEh,054h,0D9h,023h
	DB	066h,0B3h,061h,0C4h,068h,05Dh,06Fh,02Ah
	DB	00Bh,0B4h,00Ch,0C3h,005h,05Ah,002h,02Dh
end;
{ _DummyProc }


{$IFDEF   Use386code}
PROCEDURE  _InitCRC32Table; near; assembler;
{* Builds CRC-32 table for 386+, skips this for non-386 processors *}
{* Used registers:      for 286 or below                           *}
{                       NONE                                       *}
{*                      for 386 or higher                          *}
{*                      EAX, EDI, CX, DX, ES                       *}
asm
{$IFNDEF  OptimizeCodeFor386}
			cmp	gabCpuIs386, System.True
			je	@Yes386
			ret
	@Yes386:
{$ENDIF} {OptimizeCodeFor386}
			std
			mov	ax, cs
			mov	es, ax			   { ES = TP code seg }
			mov	di, (OFFSET  _DummyProc) + (4*(256-1))
			mov	dx, 256-1		   { 256 elements }
	@1:
			mov	cx, 8
			cli
			db	066h, 0Fh, 0B7h, 0C2h     {movzx  eax, dx}
	@2:
			db	066h, 0D1h, 0E8h          {shr	eax, 1}
			jnc	@3
			db	066h, 035h, 20h, 83h, 0B8h, 0EDh  {xor	eax, 0EDB88320h	; magic value}
	@3:
			loop	@2
			db	066h, 0ABh                {stosd}
			sti
			dec	dx		{ decrement a counter }
			jns	@1
end; {asm-end}
{ _InitCRC32Table }
{$ENDIF} {Use386code}


PROCEDURE  _UpdateKeys; near; assembler;
{* Recalculate the encryption keys.                                 *}
{* Enter:   BX = char.                                              *}
{* Algorithm:  Key[0] <- crc32(key(0),char)                         *}
{*             Key[1] <- Key[1] + (Key[0] & 000000ffH)              *}
{*             Key[1] <- Key[1] * 124775813 + 1                     *}
{*             Key[2] <- crc32(Key[2],Key[1] >> 24)                 *}
{*    Where crc32(old_crc,char) is a routine that given a CRC value *}
{*    and a character, returns an updated CRC value after applying  *}
{*    the CRC-32 algorithm.                                         *}
{* Used registers:      for 286 or below                            *}
{*                      AX, BX, CX, DX, SI, ES                      *}
{*                      for 386 or higher                           *}
{*                      EAX, ECX, EDX, EDI, ES                      *}
asm
{$IFDEF   Use386code}
{$IFNDEF  OptimizeCodeFor386}
		cmp	gabCpuIs386, System.False
		je	@Non386
{$ENDIF} {OptimizeCodeFor386}
		db	066h,  033h, 0C9h          {xor	   ecx, ecx}
		db	066h, 0Fh, 0B7h, 0D3h      {movzx  edx, bx}
		mov	ax, ds
		mov	es, ax
		mov	di, OFFSET gddKeyZero
                cld
		cli
		db	066h, 08Bh, 05h                {mov    eax, [di]  ; Key[0] }
		xor	dl, al
		db	066h, 0C1h, 0E8h, 08h          {shr	eax, 8}
		db	2Eh, 67h, 66h, 33h, 04h, 91h   {xor	eax, cs:[ecx][edx*4]}
		db	66h, 0ABh                      {stosd}
		mov	dl, al
		db	66h, 8Bh, 05h                  {mov	eax, [di]  ; Key[1] }
		db	66h, 03h, 0C2h                 {add	eax, edx}
		db	66h,69h,0C0h,05h,84h,08h,08h   {imul    eax, eax, 8088405h}
		db	66h, 40h                       {inc	eax}
		db	66h, 0ABh                      {stosd}
		db	66h, 0C1h, 0E8h, 18h           {shr	eax, 18h}
		db	66h, 8Bh, 15h                  {mov	edx, [di]}
		xor	al, dl
		db	66h, 0C1h, 0EAh, 08h           {shr	edx, 8}
		db	2Eh, 67h, 66h, 33h, 14h, 81h   {xor	edx, cs:[ecx][eax*4]}
		db	66h, 89h, 15h                  {mov	[di], edx  ; Key[2] }
                sti
		ret
  @Non386:
{$ENDIF} {Use386code}
{$IFNDEF  OptimizeCodeFor386}
		mov	es, gdwCodeCRCTableSeg
                cld
		mov	si, OFFSET  gddKeyZero  { crc32(Key[0],char) }
		lodsw
		mov	dx, [si+0]
		xor	bl, al
		mov	al, ah
		mov	ah, dl
		mov	dl, dh
		sub	dh, dh
		shl	bx, 1
		xor	ax, cs:[bx]
		xor	dx, es:[bx]
		mov	[si-2], ax		{ old SI+0 }
		mov	[si+0], dx		{ old SI+2 }

		mov	si, OFFSET  gddKeyOne
		mov	cx, [si+0]
		mov	bx, [si+2]
		xor	ah, ah                  { Key[1] + (Key[0] and $FF) }
		add	cx, ax
		adc	bx, 0
		mov	dx, 8405h               { Key[1] * 124775813 }
		mov	ax, cx
		mul	dx
         {$IFDEF   OptimizeCodeFor186}
                shl     cx, 3
         {$ELSE}
		shl	cx, 1
		shl	cx, 1
		shl	cx, 1
         {$ENDIF} {OptimizeCodeFor186}
		add	ch, cl
		add	dx, cx
		add	dx, bx
		shl	bx, 1
		shl	bx, 1
		add	dx, bx
		add	dh, bl
         {$IFDEF   OptimizeCodeFor186}
                shl     bx, 5
         {$ELSE}
		mov	cl, 5
		shl	bx, cl
         {$ENDIF} {OptimizeCodeFor186}
		add	dh, bl
		add	ax, 1                   { Key[1] + 1 }
		adc	dx, 0
		mov	[si+0], ax
		mov	[si+2], dx
		xor	bx, bx
		mov	bl, dh                  { Key[1] SHR 24 }

		mov	si, OFFSET  gddKeyTwo
		lodsw
		mov	dx, [si+0]              { crc32(Key[2],char) }
		xor	bl, al
		mov	al, ah
		mov	ah, dl
		mov	dl, dh
		sub	dh, dh
		shl	bx, 1
		xor	ax, cs:[bx]
		xor	dx, es:[bx]
		mov	[si-2], ax		{ old SI+0 }
		mov	[si+0], dx		{ old SI+2 }
		ret
{$ENDIF} {OptimizeCodeFor386}
end; {asm-end}
{ _UpdateKeys }


{$IFDEF   OptimizeCodeInAssembly}
  PROCEDURE  _PreCalcKeys; near; assembler;
  {* Preliminary calculation of keys for the most chars of the password. *}
  {  Enter:  AL = dbMinIndex                                              }
  {          AH = dbMaxIndex                                              }
  asm
        {$IFDEF   UseStackForTemporaryStore}
                  push    bp
        {$ELSE}
                  mov     gdwSaveRegBP, bp
        {$ENDIF} {UseStackForTemporaryStore}
                  mov     bp, ax
                  cld

		  cmp	  al, 1
		  jne	 @SkipOneCharKeys
 
      {* Copy the static encryption keys for one-character password *}

       {$IFDEF   UseFastestCode}
                  sub     bx, bx
                  mov     bl, BYTE PTR gdbSearchPassword.[0]    {dbCurValue}
                  shl     bx, 1
                  mov     ax, [bx+OFFSET (gdbOneSymKeysOfsTabl)]
       {$ELSE}
                  sub     ax, ax
                  mov     al,  BYTE PTR gdbSearchPassword.[0]   {dbCurValue}
                  mov     bx, ax                                {multiply by 12}
                  shl     ax, 1
                  add     ax, bx
         {$IFDEF   OptimizeCodeFor186}
                  shl     ax, 2
         {$ELSE}
                  shl     ax, 1
                  shl     ax, 1
         {$ENDIF} {OptimizeCodeFor186}
                  add     ax, OFFSET gdbKeysForOneSymPswd
       {$ENDIF} {UseFastestCode}
                  mov     si, ax
                  mov     di, OFFSET gdbLastPasswordKeys
                  mov     dx, ds
                  mov     es, dx
   {$IFDEF   OptimizeCodeFor386}
                  mov     cx, aEncryptionKeysSizeDiv4
                  mov     dx, cx
                  db      66h, 0F3h, 0A5h                       { rep  movsd }
   {$ELSE}
                  mov     cx, aEncryptionKeysSizeDiv2
                  mov     dx, cx
                  rep     movsw
   {$ENDIF} {OptimizeCodeFor386}

                  mov     si, ax
                  mov     di, OFFSET gddKeyZero
                  mov     cx, dx
   {$IFDEF   OptimizeCodeFor386}
                  db      66h, 0F3h, 0A5h                       { rep  movsd }
   {$ELSE}
                  rep     movsw
   {$ENDIF} {OptimizeCodeFor386}
                 mov      ax, bp


     @SkipOneCharKeys:
                 cmp      ah, 1
                 ja      @MoreThatOneSym
                 jmp     @Done

      {* Copy the static encryption keys for two-character password *}

     @MoreThatOneSym:
		 cmp	  al, 2
     		 jbe	 @CopyStaticKeysForCharNumTwo
                 {**mov      si, OFFSET gdbLastPasswordKeys.[14h]**}
                 jmp     @SkipCopy

     @CopyStaticKeysForCharNumTwo:
                 sub      ax, ax
                 mov      al, BYTE PTR gdbSearchPassword.[0]    {dbCurValue}
              (* sub      al, aMinCodeChar *)
      {$IFDEF   UseMoreStaticKeysForSecondSymbol}
                 mov      bx, WORD PTR gdbSearchPassword.[3]    {BL=dbCurValue}
                                                                {BH=dbMinSymValue}
                 sub      bl, bh
                 cmp      bl, aBlock63+1
                 jb      @LowHalf

        @HighHalf:
                 sub      bl, aBlock63+1
                 mov      bh, bl                                {multiply by 256}
                 mov      bl, ah                                { AH = 0 }
                 add      ax, bx
         {$IFDEF   OptimizeCodeFor186}
                  shl     ax, 2
         {$ELSE}
                  shl     ax, 1
                  shl     ax, 1
         {$ENDIF} {OptimizeCodeFor186}
                 mov      di, ax                                {*Sizeof(gdbLastPasswordKeys[2].ddKeyZero)}
   {$IFDEF   UseFastestCode}
                 mov      bx, gdwKeyZeroSegSym2
                 mov      es, bx
   {$ELSE}
                 mov      es, gdwKeyZeroSegSym2
   {$ENDIF} {UseFastestCode}
   {$IFDEF   OptimizeCodeFor386}
                 db       066h, 026h, 08Bh, 005h            { mov  eax, es:[di]}
                 db       066h, 0A3h                        { mov  gdbLastPasswordKeys.[0Ch], eax }
                 dw       (OFFSET gdbLastPasswordKeys) + 0Ch
   {$ELSE}
                 mov      ax, es:[di+0]
                 mov      WORD PTR gdbLastPasswordKeys.[0Ch+0], ax
                 mov      ax, es:[di+2]
                 mov      WORD PTR gdbLastPasswordKeys.[0Ch+2], ax
   {$ENDIF} {OptimizeCodeFor386}
   {$IFDEF   UseFastestCode}
                 add       bh, (aParasIn64K SHR 8)
                 mov       es, bx
   {$ELSE}
                 mov      es, gdwKeyOneSegSym2
   {$ENDIF} {UseFastestCode}
   {$IFDEF   OptimizeCodeFor386}
                 db       066h, 026h, 08Bh, 005h            { mov  eax, es:[di]}
                 db       066h, 0A3h                        { mov  gdbLastPasswordKeys.[10h], eax }
                 dw       (OFFSET gdbLastPasswordKeys) + 10h
   {$ELSE}
                 mov      ax, es:[di+0]
                 mov      WORD PTR gdbLastPasswordKeys.[10h+0], ax
                 mov      ax, es:[di+2]
                 mov      WORD PTR gdbLastPasswordKeys.[10h+2], ax
   {$ENDIF} {OptimizeCodeFor386}
   {$IFDEF   UseFastestCode}
                 add       bh, (aParasIn64K SHR 8)
                 mov       es, bx
   {$ELSE}
                 mov      es, gdwKeyTwoSegSym2
   {$ENDIF} {UseFastestCode}
   {$IFDEF   OptimizeCodeFor386}
                 db       066h, 026h, 08Bh, 005h            { mov  eax, es:[di]}
                 db       066h, 0A3h                        { mov  gdbLastPasswordKeys.[14h], eax }
                 dw       (OFFSET gdbLastPasswordKeys) + 14h
   {$ELSE}
                 mov      ax, es:[di+0]
                 mov      WORD PTR gdbLastPasswordKeys.[14h+0], ax
                 mov      ax, es:[di+2]
                 mov      WORD PTR gdbLastPasswordKeys.[14h+2], ax
   {$ENDIF} {OptimizeCodeFor386}
		 jmp	@DoCopy

        @LowHalf:
                 mov      bh, bl                                {multiply by 256}
                 mov      bl, ah                                { AH = 0 }
                 add      ax, bx
         {$IFDEF   OptimizeCodeFor186}
                  shl     ax, 2
         {$ELSE}
                  shl     ax, 1
                  shl     ax, 1
         {$ENDIF} {OptimizeCodeFor186}
                 mov      di, ax                                {*Sizeof(gdbLastPasswordKeys[2].ddKeyZero)}
   {$IFDEF   UseFastestCode}
                 mov      bx, gdwKeyZeroSeg
                 mov      es, bx
   {$ELSE}
                 mov      es, gdwKeyZeroSeg
   {$ENDIF} {UseFastestCode}
   {$IFDEF   OptimizeCodeFor386}
                 db       066h, 026h, 08Bh, 005h            { mov  eax, es:[di]}
                 db       066h, 0A3h                        { mov  gdbLastPasswordKeys.[0Ch], eax }
                 dw       (OFFSET gdbLastPasswordKeys) + 0Ch
   {$ELSE}
                 mov      ax, es:[di+0]
                 mov      WORD PTR gdbLastPasswordKeys.[0Ch+0], ax
                 mov      ax, es:[di+2]
                 mov      WORD PTR gdbLastPasswordKeys.[0Ch+2], ax
   {$ENDIF} {OptimizeCodeFor386}
   {$IFDEF   UseFastestCode}
                 add       bh, (aParasIn64K SHR 8)
                 mov       es, bx
   {$ELSE}
                 mov      es, gdwKeyOneSeg
   {$ENDIF} {UseFastestCode}
   {$IFDEF   OptimizeCodeFor386}
                 db       066h, 026h, 08Bh, 005h            { mov  eax, es:[di]}
                 db       066h, 0A3h                        { mov  gdbLastPasswordKeys.[10h], eax }
                 dw       (OFFSET gdbLastPasswordKeys) + 10h
   {$ELSE}
                 mov      ax, es:[di+0]
                 mov      WORD PTR gdbLastPasswordKeys.[10h+0], ax
                 mov      ax, es:[di+2]
                 mov      WORD PTR gdbLastPasswordKeys.[10h+2], ax
   {$ENDIF} {OptimizeCodeFor386}
   {$IFDEF   UseFastestCode}
                 add       bh, (aParasIn64K SHR 8)
                 mov       es, bx
   {$ELSE}
                 mov      es, gdwKeyTwoSeg
   {$ENDIF} {UseFastestCode}
   {$IFDEF   OptimizeCodeFor386}
                 db       066h, 026h, 08Bh, 005h            { mov  eax, es:[di]}
                 db       066h, 0A3h                        { mov  gdbLastPasswordKeys.[14h], eax }
                 dw       (OFFSET gdbLastPasswordKeys) + 14h
   {$ELSE}
                 mov      ax, es:[di+0]
                 mov      WORD PTR gdbLastPasswordKeys.[14h+0], ax
                 mov      ax, es:[di+2]
                 mov      WORD PTR gdbLastPasswordKeys.[14h+2], ax
   {$ENDIF} {OptimizeCodeFor386}

      {$ELSE}
                 mov      bx, WORD PTR gdbSearchPassword.[3]    {BL=dbCurValue,BH=dbMinSymValue}
                 sub      bl, bh
                 mov      bh, bl                                {multiply by 256}
                 mov      bl, ah                                { AH = 0 }
                 add      ax, bx
         {$IFDEF   OptimizeCodeFor186}
                  shl     ax, 2
         {$ELSE}
                  shl     ax, 1
                  shl     ax, 1
         {$ENDIF} {OptimizeCodeFor186}
                 mov      di, ax                                {*Sizeof(gdbLastPasswordKeys[2].ddKeyZero)}
   {$IFDEF   UseFastestCode}
                 mov      bx, gdwKeyZeroSeg
                 mov      es, bx
   {$ELSE}
                 mov      es, gdwKeyZeroSeg
   {$ENDIF} {UseFastestCode}
   {$IFDEF   OptimizeCodeFor386}
                 db       066h, 026h, 08Bh, 005h            { mov  eax, es:[di]}
                 db       066h, 0A3h                        { mov  gdbLastPasswordKeys.[0Ch], eax }
                 dw       (OFFSET gdbLastPasswordKeys) + 0Ch
   {$ELSE}
                 mov      ax, es:[di+0]
                 mov      WORD PTR gdbLastPasswordKeys.[0Ch+0], ax
                 mov      ax, es:[di+2]
                 mov      WORD PTR gdbLastPasswordKeys.[0Ch+2], ax
   {$ENDIF} {OptimizeCodeFor386}
   {$IFDEF   UseFastestCode}
                 add       bh, (aParasIn64K SHR 8)
                 mov       es, bx
   {$ELSE}
                 mov      es, gdwKeyOneSeg
   {$ENDIF} {UseFastestCode}
   {$IFDEF   OptimizeCodeFor386}
                 db       066h, 026h, 08Bh, 005h            { mov  eax, es:[di]}
                 db       066h, 0A3h                        { mov  gdbLastPasswordKeys.[10h], eax }
                 dw       (OFFSET gdbLastPasswordKeys) + 10h
   {$ELSE}
                 mov      ax, es:[di+0]
                 mov      WORD PTR gdbLastPasswordKeys.[10h+0], ax
                 mov      ax, es:[di+2]
                 mov      WORD PTR gdbLastPasswordKeys.[10h+2], ax
   {$ENDIF} {OptimizeCodeFor386}
   {$IFDEF   UseFastestCode}
                 add       bh, (aParasIn64K SHR 8)
                 mov       es, bx
   {$ELSE}
                 mov      es, gdwKeyTwoSeg
   {$ENDIF} {UseFastestCode}
   {$IFDEF   OptimizeCodeFor386}
                 db       066h, 026h, 08Bh, 005h            { mov  eax, es:[di]}
                 db       066h, 0A3h                        { mov  gdbLastPasswordKeys.[14h], eax }
                 dw       (OFFSET gdbLastPasswordKeys) + 14h
   {$ELSE}
                 mov      ax, es:[di+0]
                 mov      WORD PTR gdbLastPasswordKeys.[14h+0], ax
                 mov      ax, es:[di+2]
                 mov      WORD PTR gdbLastPasswordKeys.[14h+2], ax
   {$ENDIF} {OptimizeCodeFor386}
      {$ENDIF} {UseMoreStaticKeysForSecondSymbol}

        @DoCopy:
                 mov      si, OFFSET gdbLastPasswordKeys.[0Ch]
                 mov      di, OFFSET gddKeyZero
                 mov      ax, ds
                 mov      es, ax
   {$IFDEF   OptimizeCodeFor386}
                 mov      cx, aEncryptionKeysSizeDiv4
                 db       66h, 0F3h, 0A5h                      { rep  movsd }
   {$ELSE}
                 mov      cx, aEncryptionKeysSizeDiv2
                 rep      movsw
   {$ENDIF} {OptimizeCodeFor386}


      {* Make the static encryption keys for n-character password *}

     @SkipCopy:
                 mov      ax, bp
                 cmp      ah, 2
                 ja      @MoreThatTwoSym
                 jmp     @Done

     @MoreThatTwoSym:
                 cmp      al, 2
                 jbe     @SetUpVarsForLoop

       {$IFDEF   UseFastestCode}
                 sub      bx, bx
                 mov      bl, al
                 shl      bx, 1
                 mov      si, [bx+(OFFSET gdbLastPwdKeysOfsTabl)-4]   { 4 = SizeOf(System.Word)*2 }
       {$ELSE}
                 sub      ah, ah
         {$IFDEF   OptimizeCodeFor186}
                 sub      ax, 2                                 {dbMinIndex-2}
         {$ELSE}
                 dec      ax
                 dec      ax
         {$ENDIF} {OptimizeCodeFor186}
                 mov      cx, ax                                {multiply by 12}
                 shl      ax, 1
                 add      ax, cx
         {$IFDEF   OptimizeCodeFor186}
                 shl      ax, 2
         {$ELSE}
                 shl      ax, 1
                 shl      ax, 1
         {$ENDIF} {OptimizeCodeFor186}
                 mov      si, OFFSET gdbLastPasswordKeys
                 add      si, ax
       {$ENDIF} {UseFastestCode}
                 mov      di, OFFSET gddKeyZero
                 mov      ax, ds
                 mov      es, ax
   {$IFDEF   OptimizeCodeFor386}
                 mov      cx, aEncryptionKeysSizeDiv4
                 db       66h, 0F3h, 0A5h                      { rep  movsd }
   {$ELSE}
                 mov      cx, aEncryptionKeysSizeDiv2
                 rep      movsw
   {$ENDIF} {OptimizeCodeFor386}
                 mov      ax, bp
                 dec      ax

     @SetUpVarsForLoop:
          {$IFDEF   UseStackForTemporaryStore}
                 push    si
          {$ELSE}
                 mov     gdwMemOfs, si                         {gdbLastPasswordKeys[3]}
          {$ENDIF} {UseStackForTemporaryStore}

     @CalcKeysForNextChar:
                 inc      al
                 mov      bp, ax
                 cmp      ah, al
                 jb      @Exit


          {$IFDEF   UseFastestCode}
                 sub      ah, ah
                 mov      bx, ax
                 shl      bx, 1
                 mov      bx, [bx+(OFFSET gdbSearchPwdOfsTable)-2]   { 2 = SizeOf(System.Word) }
                 mov      bl, [bx]
          {$ELSE}
                 sub      ah, ah
                 dec      ax
                 mov      bx, ax
                 shl      bx, 1
                 add      bx, ax
                 mov      bl, [bx+(OFFSET gdbSearchPassword)]
          {$ENDIF} {UseFastestCode}
                 mov      bh, ah
                 call     _UpdateKeys

          {$IFDEF   UseStackForTemporaryStore}
                 pop      di
          {$ELSE}
                 mov     di, gdwMemOfs                          {gdbLastPasswordKeys[n]}
          {$ENDIF} {UseStackForTemporaryStore}

                 mov     si, OFFSET gddKeyZero
                 mov     ax, ds
                 mov     es, ax
   {$IFDEF   OptimizeCodeFor386}
                 mov      cx, aEncryptionKeysSizeDiv4
                 db       66h, 0F3h, 0A5h                      { rep  movsd }
   {$ELSE}  
                 mov      cx, aEncryptionKeysSizeDiv2
                 rep      movsw
   {$ENDIF} {OptimizeCodeFor386}

          {$IFDEF   UseStackForTemporaryStore}
                 push    di
          {$ELSE}
                 mov     gdwMemOfs, di                          {gdbLastPasswordKeys[n+1]}
          {$ENDIF} {UseStackForTemporaryStore}

                 mov      ax, bp
                 jmp     @CalcKeysForNextChar

     @Exit:

     {$IFDEF   UseStackForTemporaryStore}
                 pop     si
     {$ENDIF} {UseStackForTemporaryStore}

     @Done:

        {$IFDEF   UseStackForTemporaryStore}
                 pop     bp
        {$ELSE}
                 mov     bp, gdwSaveRegBP
        {$ENDIF} {UseStackForTemporaryStore}
  end; {asm-end}
{$ELSE}
  PROCEDURE  _PreCalcKeys(dbMinIndex, dbMaxIndex : System.Byte);
  {* Preliminary calculation of keys for the most chars in the password. *}
  VAR
    dwMemOfs      :    System.Word;
    dbCharIndex   :    System.Byte;

  BEGIN
     { initialize keys for password(0) }
     IF  (dbMinIndex = 1)
       THEN  BEGIN
          WITH  gdbSearchPassword[1] DO
             gdbLastPasswordKeys[1] := gdbKeysForOneSymPswd[dbCurValue];
          {with-do}
          System.Move(gdbLastPasswordKeys[1],gddKeyZero,System.Sizeof(recEncryptedKeys));
              END;
     {if-then}

     IF  (dbMaxIndex > 1)
       THEN  BEGIN
         IF  (dbMinIndex <= 2)
           THEN   BEGIN
         { initialize keys for password(1) }
      {$IFDEF   UseMoreStaticKeysForSecondSymbol}
         WITH  gdbSearchPassword[2]  DO
            dbCharIndex := dbCurValue-dbMinSymValue;
         {with-do}
         IF  ((dbCharIndex - (aBlock63+1)) >= 0)
            THEN  BEGIN
              System.Dec(dbCharIndex,aBlock63+1);
              dwMemOfs := System.Sizeof(gdbLastPasswordKeys[2].ddKeyZero)*
                          ((gdbSearchPassword[1].dbCurValue-aMinCodeChar)+
                          (dbCharIndex)*(aMaxCodeChar+1));
              gdbLastPasswordKeys[2].ddKeyZero := System.MemL[gdwKeyZeroSegSym2:dwMemOfs];
              gdbLastPasswordKeys[2].ddKeyOne  := System.MemL[gdwKeyOneSegSym2:dwMemOfs];
              gdbLastPasswordKeys[2].ddKeyTwo  := System.MemL[gdwKeyTwoSegSym2:dwMemOfs];
                  END
            ELSE  BEGIN
            dwMemOfs := System.Sizeof(gdbLastPasswordKeys[2].ddKeyZero)*
                       ((gdbSearchPassword[1].dbCurValue-aMinCodeChar)+
                       (dbCharIndex)*(aMaxCodeChar+1));
             gdbLastPasswordKeys[2].ddKeyZero := System.MemL[gdwKeyZeroSeg:dwMemOfs];
             gdbLastPasswordKeys[2].ddKeyOne  := System.MemL[gdwKeyOneSeg:dwMemOfs];
             gdbLastPasswordKeys[2].ddKeyTwo  := System.MemL[gdwKeyTwoSeg:dwMemOfs];
                  END;
         {if-then-else}
      {$ELSE}
            dwMemOfs := System.Sizeof(gdbLastPasswordKeys[2].ddKeyZero)*
                       ((gdbSearchPassword[1].dbCurValue-aMinCodeChar)+
                       (gdbSearchPassword[2].dbCurValue-gdbSearchPassword[2].dbMinSymValue)*
                       (aMaxCodeChar+1));
             gdbLastPasswordKeys[2].ddKeyZero := System.MemL[gdwKeyZeroSeg:dwMemOfs];
             gdbLastPasswordKeys[2].ddKeyOne  := System.MemL[gdwKeyOneSeg:dwMemOfs];
             gdbLastPasswordKeys[2].ddKeyTwo  := System.MemL[gdwKeyTwoSeg:dwMemOfs];
      {$ENDIF} {UseMoreStaticKeysForSecondSymbol}
             System.Move(gdbLastPasswordKeys[2],gddKeyZero,System.Sizeof(recEncryptedKeys));
                  END;
         {if-then}
          IF  (dbMaxIndex > 2)
            THEN  BEGIN
               IF  (dbMinIndex <= 2)
                 THEN  dbMinIndex := 3
		 ELSE  System.Move(gdbLastPasswordKeys[dbMinIndex-1],
				   gddKeyZero,
				   System.Sizeof(recEncryptedKeys));
               {if-then-else}
               FOR  dbCharIndex := dbMinIndex  TO  dbMaxIndex  DO
               BEGIN
                  gdbTemp := gdbSearchPassword[dbCharIndex].dbCurValue;
                  asm
                        sub    bx, bx
                        mov    bl, gdbTemp
                        call   _UpdateKeys
                  end;
                  {asm-end}
                  System.Move(gddKeyZero,
                              gdbLastPasswordKeys[dbCharIndex],
                              System.Sizeof(recEncryptedKeys));
               END;
               {for-to-do}
                  END;
          {if-then}
             END;
     {if-then}
  END;
{$ENDIF} {OptimizeCodeInAssembly}
  { _PreCalcKeys }


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


FUNCTION  _fndbHexCharToBin(chIn: System.Char) : System.Byte; assembler;
{* Converts the hexadecimal char to decimal. *}
{* Used registers:  AL                       *}
asm
        mov   al, chIn       { AL = character }
        sub   al,'0'         { AL <- AL - '0' }

        cmp   al,9           { test for digit }
        jbe   @Done

        and   al,11011111b   { make uppercase }
        sub   al,'A'-'9'-1   { AL = 'A'..'F' }

      @Done:
                             { AL =  function result }
END; {asm-end}
{ HexCharToDec }


FUNCTION  _fnliHexStrToBin(sHexInput : STRING; VAR iErrCode : System.Integer) : System.Longint;
{* Converts hexadecimal string to decimal number. *}
VAR
  ddNumber               :       System.Longint;
  dbStrIndex, dbStrLen   :       System.Byte;

BEGIN
  iErrCode   := 0;
  ddNumber   := 0;
  dbStrIndex := 1;
  dbStrLen   := System.Length(sHexInput);

  WHILE (iErrCode = 0) and (dbStrLen > 0) DO
  BEGIN
    IF  (sHexInput[dbStrIndex] IN setHexChars)
    THEN  BEGIN
               ddNumber := ddNumber * aHexRadix + _fndbHexCharToBin(sHexInput[dbStrIndex]);
               System.Inc(dbStrIndex);
               System.Dec(dbStrLen);
          END
    ELSE
        iErrCode  := -1;
  END; { while }

  _fnliHexStrToBin := ddNumber;
END;  { _fnliHexStrToBin }


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


FUNCTION   _fnsDoubleWordToHexFmt(ddInput : System.Longint) : STR8;
{* Converts a double word to the hex format number representation. *}
BEGIN
  _fnsDoubleWordToHexFmt := _fnsWordToHexFmt(System.Word(ddInput SHR 16)) +
                      _fnsWordToHexFmt(System.Word(ddInput and $0000FFFF));
END;  { _fnsDoubleWordToHexFmt }


FUNCTION _fnsAddDefExt(sFileName,sDefExt : STRING) : STRING;
{* Add default extension to filename if need. *}
VAR
  sTemp  :  STRING;

BEGIN
   sTemp := sFileName;
   IF (System.Pos(aDosExtMark,sTemp) = 0)
     THEN  sTemp := sTemp + aDosExtMark + sDefExt;
   {if-then}
  _fnsAddDefExt := sTemp;
END;
{ _fnsAddDefExt }


FUNCTION  _fnsUpcaseStr(sInput : STRING) : STRING;
{* Makes all chars in uppercase. *}
VAR
  dbIndex  :  System.Byte;
  dbCount  :  System.Byte  ABSOLUTE sInput;

BEGIN
  IF  (dbCount <> 0)
    THEN  FOR dbIndex :=  1  TO  dbCount DO
            sInput[dbIndex] := System.Upcase(sInput[dbIndex]);
          {for-to-do}
  {if-then}
   _fnsUpcaseStr := sInput;
END; { _fnsUpcaseStr }


FUNCTION _fnchGetFirstChar(sInput : STRING)  :  System.Char;
{* Gets a first char from string. *}
VAR
 chFirst  :  System.Char;

BEGIN
  IF (sInput = asBlank)
    THEN  chFirst := System.Char(achNull)
    ELSE  chFirst := sInput[1];
  {if-then-else}
  _fnchGetFirstChar := chFirst;
END;
{ _fnchGetFirstChar }


FUNCTION _fndbGetValue(sInput : STRING)   :   System.Byte;
{* Converts string to numeric representation. *}
VAR
  dbTemp   :   System.Byte;

BEGIN
  IF  (sInput[1] <> achHexPrefix)
     THEN  System.Val(sInput,dbTemp,giErrorCode)
     ELSE  dbTemp :=  System.Lo(_fnliHexStrToBin(Copy(sInput,2,System.Length(sInput)-1),giErrorCode));
  {if-then-else}
  _fndbGetValue := dbTemp;
END;
{ _fndbGetValue }


FUNCTION  _fnsRunTime(recRunTime : recSaveTime)  :  STRING;
{* Returns a time in the string format. *}
VAR
  sTemp  :  STRING;

FUNCTION  _fnsMakeTimeElement(dwCount : System.Word; bAddColon : System.Boolean) : STR3;
{* Return one time element with left-padded 'zeroes'. *}
VAR
  sNum   :  STR3;
BEGIN
   System.Str(dwCount : 2,sNum);
   IF (sNum[1] = achBlank)
          THEN sNum[1] := achZero;
   {if-them}
   IF (bAddColon)
      THEN  sNum := sNum + achColon;
   {if-then}
  _fnsMakeTimeElement := sNum;
END;
{ _fnsMakeTimeElement }

BEGIN
    WITH  recRunTime  DO
    BEGIN
        sTemp := _fnsMakeTimeElement(dwHour,System.True) +
                 _fnsMakeTimeElement(dwMinute,System.True)+
                 _fnsMakeTimeElement(dwSecond,System.True)+
                 _fnsMakeTimeElement(dwSec100,System.False);
    END;
    {with-do}
    _fnsRunTime := sTemp;
END;
{ _fnsRunTime }



{* Procedures *}

PROCEDURE    _CopyrightDisplay;
{* Outputs a copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+
                    '  Version '+
                    asVersion+
                    ',  '+
                    asCopyright+
                    '  '+asAuthor);
END;  { _CopyrightDisplay }


FUNCTION  _liTotalSecTens(recCalcTime : recSaveTime) : System.LongInt;
{* Counts total time in the tens of secod *}
VAR
  liTemp    :       System.LongInt;

BEGIN

   WITH  recCalcTime  DO
   BEGIN
     liTemp := dwHour;
     liTemp := liTemp * aMinutesPerHour + dwMinute;
     liTemp := liTemp * aSecondsPerMin + dwSecond;
     liTemp := liTemp * aHundrenthsPerSec + dwSec100;
   END;
   {with-do}
   _liTotalSecTens := liTemp;
END;
{ _liTotalSecTens }


PROCEDURE  _ConvertToTime(liTotalTime : System.Longint; VAR  recTrueTime : recSaveTime);
{* Convert a longint counter to a true time format. }
BEGIN
  WITH  recTrueTime  DO
  BEGIN
     dwHour := liTotalTime  DIV  System.Longint(aMinutesPerHour*aSecondsPerMin*aHundrenthsPerSec);
     liTotalTime := liTotalTime - System.Longint(dwHour)*(aMinutesPerHour*aSecondsPerMin*aHundrenthsPerSec);
     dwMinute := liTotalTime  DIV  System.Longint(aSecondsPerMin*aHundrenthsPerSec);
     liTotalTime := liTotalTime - System.Longint(dwMinute)*(aSecondsPerMin*aHundrenthsPerSec);
     dwSecond := liTotalTime  DIV  System.Longint(aHundrenthsPerSec);
     dwSec100 := liTotalTime - System.Longint(dwSecond)*aHundrenthsPerSec;
  END;
  {with-do}
END;
{  _ConvertToTime  }


PROCEDURE  _CalcActualTime(VAR recInitTime, recLastTime, recActual : recSaveTime);
{* Counts an actual time after running. *}
VAR
  liInitTemp      :       System.LongInt;
  liLastTemp      :       System.LongInt;
  liActualTemp    :       System.LongInt;

BEGIN
  liInitTemp   := _liTotalSecTens(recInitTime);
  liLastTemp   := _liTotalSecTens(recLastTime);
  liActualTemp := liLastTemp - liInitTemp;
  _ConvertToTime(liActualTemp,recActual);
END;
{  _CalcActualTime }


PROCEDURE  _AddTimeCount(VAR recStoreTime, recAddTime : recSaveTime);
{* Add the time (cumulative counter). *}
VAR
  liActualTemp      :       System.LongInt;
  liAddTemp         :       System.LongInt;

BEGIN
  liActualTemp   := _liTotalSecTens(recStoreTime);
  liAddTemp   := _liTotalSecTens(recAddTime);
  {* WARNING!!! No check for overflow through 24 or more hours! *}
  liActualTemp := liActualTemp + liAddTemp;
  _ConvertToTime(liActualTemp,recStoreTime);
END;
{  _AddTimeCount }


PROCEDURE  _AllocDosMem(VAR dwDosMemSeg : System.Word; dwParas : System.Word);
{* Allocates a memory through DOS service. *}
VAR
  bFuncFail  :  System.Boolean;

BEGIN
   bFuncFail := System.True;
   asm
      mov    bx, dwParas                { # of memory paragraphas }
      mov    ah, 48h                    { alloc memory block of given size }
      int    21h                        { call DOS service }
      jc     @Done                      { jump if error occurred }

      mov    bFuncFail, System.False    { function ok }
      les    di, dwDosMemSeg            { get TP variable address }
      mov    es:[di], ax                { save DOS block segment }

    @Done:
   end;
   {asm-end}

   IF  (bFuncFail)
     THEN  BEGIN
       System.WriteLn(asProgramPrompt+'Insufficient memory. Program need about ',aProgramMemory,' Kbytes.');
       System.Halt(errInsufficientMemory);
           END
     ELSE  BEGIN
    {$IFDEF   DebugVersion}
       System.WriteLn(asProgramPrompt+'Allocated segment '+achHexPrefix,
                      _fnsWordToHexFmt(dwDosMemSeg),
                      ', Block size = ',
                      achHexPrefix+_fnsDoubleWordToHexFmt(System.Longint(dwParas)*aBytesPerParagraph),
                      ' bytes.');
    {$ENDIF} {DebugVersion}
           END;
   {if-then-else}
END;
{ _AllocDosMem }


PROCEDURE  _DeAllocDosMem(dwDosMemSeg : System.Word);
{* Freezes a memory through DOS service. *}
BEGIN
   asm
      mov    es, dwDosMemSeg            { memory block address }
      mov    ah, 49h                    { free memory block }
      int    21h                        { call DOS service }
   end;
   {asm-end}
   {$IFDEF   DebugVersion}
       System.WriteLn(asProgramPrompt+'Deallocated segment '+achHexPrefix,
                      _fnsWordToHexFmt(dwDosMemSeg),'.');
   {$ENDIF} {DebugVersion}
END;
{ _DeAllocDosMem }



{**** main statement part ****}
BEGIN

  {* copyright message *}
    _CopyrightDisplay;

  {* parameters present, or display help screen *}
    gdwParamNum := System.ParamCount;
    IF (gdwParamNum = 0)
      THEN  BEGIN
          System.WriteLn(asProgramPrompt+'  help screen for you.');
          System.WriteLn('Usage: [arcfile [userfile [tblfile [pwdfile [pwdmin [pwdmax [pwdmore ');
          System.WriteLn('       [batchmode [foundpwd]]]]]]]]]');
          System.WriteLn(' arcfile   -  archive filename                (default extension='+asDefZipExt+')');
          System.WriteLn(' userfile  -  user encrypted filename         (default extension='+asDefSrchExt+')');
          System.WriteLn(' tblfile   -  character map filename          (default extension='+asDefTblExt+')');
          System.WriteLn(' pwdfile   -  user password filename          (default extension='+asDefPwdExt+')');
          System.WriteLn(' pwdminlen -  user password min. length       (default =',aMinPswdVal,')');
          System.WriteLn(' pwdmaxlen -  user password max. length       (default =',aMaxPswdVal,')');
          System.WriteLn(' pwdmore   -  skip user password description  (default ='+asYes+')');
          System.WriteLn(' batchmode -  use batch mode to answer        (default ='+asNo+')');
          System.WriteLn(' foundpwd  -  user file to write found pwd(s) (default extension='+asDefFoundPwdExt+')');
          System.Halt(errNoParms);
            END;
    {if-then}

  {* initialize internal variables *}
    gdwFileCount := Ofs(_DummyProc);
  {$IFDEF   Use386code}
      gabCpuIs386 := _fnbCpuIs386;
  {$ENDIF} {Use386code}
    {$IFDEF   DebugVersion}
       IF (gabCpuIs386)
         THEN  gsTempInput := '386 or higher.'
         ELSE  gsTempInput := '286 or below.';
       {if-then-else}
       System.WriteLn(asProgramPrompt+'CPU is '+gsTempInput);
    {$ENDIF} {DebugVersion}

  {* initialize CRC table (use for 386+ processors) *}
  {$IFDEF   Use386code}
    IF  (gabInitCRCTable)
      THEN  _InitCRC32Table;
    {if-then}
  {$ENDIF} {Use386code}


  {* setup some internal variables *}
    IF  NOT(gabCpuIs386)
      THEN
    {$IFDEF   OptimizeCodeInAssembly}
             asm
                    mov	        ax, cs
		    add	        ax, ((256*4) / 2) shr 4
		    mov	        gdwCodeCRCTableSeg, ax
             end;
             {asm-end}
    {$ELSE}
        gdwCodeCRCTableSeg := CSeg+((aMaxCodeChar+1)*System.Sizeof(System.LongInt) SHR (1+4));
    {$ENDIF} {OptimizeCodeInAssembly}
    {if-then}

    FOR  gdbIndex := aMinPswdVal TO  aMaxPswdVal  DO
      WITH  gdbSearchPassword[gdbIndex] DO
      BEGIN
        dbCurValue    := aMinCodeChar;
        dbMinSymValue := aMinCodeChar;
        dbMaxSymValue := aMaxCodeChar;
      END;
      {with-do}
    {for-to-do}

    {$IFDEF   UseFastestCode}
       FOR  gdbIndex := aMinPswdVal TO  aMaxPswdVal  DO
       BEGIN
           gdbSearchPwdOfsTable[gdbIndex] := System.Ofs(gdbSearchPassword) +
                          (gdbIndex-1)*(System.SizeOf(recSymInPassword));
           gdbLastPwdKeysOfsTabl[gdbIndex] := System.Ofs(gdbLastPasswordKeys) +
                          (gdbIndex-1)*(System.SizeOf(recEncryptedKeys));
       END;
       {for-to-do}
       FOR  gdbIndex :=  aMinCodeChar  TO  aMaxCodeChar  DO
       BEGIN
           gdbOneSymKeysOfsTabl[gdbIndex] := System.Ofs(gdbKeysForOneSymPswd) +
                          (gdbIndex)*(System.SizeOf(recEncryptedKeys));
       END;
       {for-to-do}
    {$ENDIF} {UseFastestCode}

  {* ask ZIP file *}
    IF (gdwParamNum < 1)
      THEN  BEGIN
       System.Write(asProgramPrompt+'Enter ZIP-filename (def.ext.='+
                    asDefZipExt+'): ');
       System.ReadLn(gasZipFileName);
            END
      ELSE
          gasZipFileName := System.ParamStr(1);
    {if-then-else}
    IF (gasZipFileName = asBlank)
      THEN BEGIN
         System.WriteLn(asProgramPrompt+'No name for ZIP-file.');
         System.Halt(errBadNameForZipFile);
           END
      ELSE
        gasZipFileName := _fnsAddDefExt(gasZipFileName,asDefZipExt);
    {if-then-else}
    gasZipFileName := _fnsUpcaseStr(gasZipFileName);
    {$IFDEF   DebugVersion}
        System.WriteLn(asProgramPrompt+'Archive file: '+gasZipFileName);
    {$ENDIF} {DebugVersion}


  {* ask user encrypted file to search archive *}
    IF (gdwParamNum < 2)
      THEN  BEGIN
         System.Write(asProgramPrompt+'Enter encrypted filename: ');
         System.ReadLn(gasEncryptedFileName);
            END
      ELSE
         gasEncryptedFileName := System.ParamStr(2);
    {if-then-else}
    IF (gasEncryptedFileName = asBlank)
      THEN BEGIN
         System.WriteLn(asProgramPrompt+'No name for an user encrypted file.');
         System.Halt(errBadNameForUserFile);
           END
      ELSE
        gasEncryptedFileName := _fnsAddDefExt(gasEncryptedFileName,asDefSrchExt);
    {if-then-else}
    gasEncryptedFileName := _fnsUpcaseStr(gasEncryptedFileName);
    {$IFDEF   DebugVersion}
        System.WriteLn(asProgramPrompt+'Encrypted file: '+gasEncryptedFileName);
    {$ENDIF} {DebugVersion}


  {* read an archive file and find info about user file *}
    gbStatusOk   := System.False;
    gdwFileCount := 0;
    gliFileOfs   := 0;
    System.Assign(gfZipInStream,gasZipFileName);
    {$I-} System.Reset(gfZipInStream,1); {$I+}
    IF  (System.IoResult <> 0)
      THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Unable to open an archive file.');
         System.Halt(errBadArchiveFilename);
            END;
    {if-then}
    System.WriteLn(asProgramPrompt+'Search archive file for an user file.');
    REPEAT
     {* at first get a local header *}
      gdwByteCount := System.Sizeof(recLocZipHeader);
      System.BlockRead(gfZipInStream,gdbLocFileHeader,gdwByteCount,gdwResCount);
      IF (gdwResCount <> gdwByteCount)
            THEN BEGIN
              System.WriteLn(asProgramPrompt+'Unable to read the local header from the archive file.');
              System.Halt(errReadArchiveFile);
                 END;
      {if-then}

      WITH  gdbLocFileHeader  DO
      BEGIN
        {* standard PKWARE test *}
         IF (ddLocHeaderSignature <> aLocZipSign)
            THEN BEGIN
               IF (gdwFileCount = 0)
                THEN  BEGIN
                   System.WriteLn(asProgramPrompt+'Not archive file.');
                   System.Halt(errBadArchiveFile)
                      END
                ELSE  BEGIN
                   System.WriteLn(asProgramPrompt+'User file not found in this archive file.');
                   System.Halt(errEndOfArchiveFile)
                      END;
                {if-then-else}
                    END;
         {if-then}


        {* extract filename from local header *}
          gdwByteCount := dwFileNameLength;
          System.BlockRead(gfZipInStream,gsTempInput[1],gdwByteCount,gdwResCount);
          IF (gdwResCount <> gdwByteCount)
                THEN BEGIN
                  System.WriteLn(asProgramPrompt+'Unable to read filename from the archive file.');
                  System.Halt(errReadArchiveFile);
                     END;
          {if-then}
          gsTempInput[0] := System.Char(System.Lo(gdwByteCount));
          IF  (System.Pos(aDosExtMark,gsTempInput) = 0)
            THEN  gsTempInput := gsTempInput + aDosExtMark;
          {if-then}
          gliFileOfs := System.FilePos(gfZipInStream);
          System.Inc(gdwFileCount);

       {$IFDEF   DebugVersion}
           System.WriteLn(asProgramPrompt+'Found file: '+gsTempInput);
       {$ENDIF} {DebugVersion}

        {* is this a match name? *}
          IF (gasEncryptedFileName <> gsTempInput)
            THEN  BEGIN
             {* move to next local header *}
                gliFileOfs := gliFileOfs + dwExtraFieldLength + ddCompressedSize;
                System.Seek(gfZipInStream,gliFileOfs);
                  END
            ELSE  BEGIN
             {* is file encrypted? *}
              IF ((dwGeneralFlags AND btFileIsEncrypted) = 0)
                THEN     BEGIN
                      System.WriteLn(asProgramPrompt+'Sorry, file not encrypted.');
                      System.Halt(errNotEncryptedFile);
                         END;
              {if-then}
             {* get an encrypted random data from local header *}
                gliFileOfs := gliFileOfs +  dwExtraFieldLength;
                System.Seek(gfZipInStream,gliFileOfs);
                gdwByteCount := aRandomDatalen;
                System.BlockRead(gfZipInStream,gdbRandomValues,gdwByteCount,gdwResCount);
                IF (gdwResCount <> gdwByteCount)
                      THEN BEGIN
                        System.WriteLn(asProgramPrompt+'Unable to read encrypted header from the archive file.');
                        System.Halt(errReadArchiveFile);
                           END;
                {if-then}
                gddFileCRC32 := ddCRC32;
                gbStatusOk := System.True;

           {$IFDEF   DebugVersion}
              System.Write(asProgramPrompt+'Encrypted data:');
              FOR gdbIndex :=  1  TO  aRandomDatalen  DO
                 System.Write(' '+achHexPrefix+_fnsByteToHexFmt(gdbRandomValues[gdbIndex]));
              {for-to-do}
              System.WriteLn;
           {$ENDIF} {DebugVersion}

                  END;
          {if-then-else}
      END;
      {with-do}
    UNTIL (gbStatusOk);
    System.Close(gfZipInStream);
    {repeat-until}

   
  {* ask table file *}
    IF (gdwParamNum < 3)
      THEN  BEGIN
         System.Write(asProgramPrompt+'Enter table filename (def.ext.='+
                      asDefTblExt+'): ');
         System.ReadLn(gasTableFileName);
            END
      ELSE
         gasTableFileName := System.ParamStr(3);
    {if-then-else}
    IF (gasTableFileName = asBlank)
      THEN
         System.WriteLn(asProgramPrompt+'No name for table file. Default table in use.')
      ELSE
         gasTableFileName:= _fnsAddDefExt(gasTableFileName,asDefTblExt);
    {if-then-else}
    gasTableFileName := _fnsUpcaseStr(gasTableFileName);
    {$IFDEF   DebugVersion}
        System.WriteLn(asProgramPrompt+'Table file: '+gasTableFileName);
    {$ENDIF} {DebugVersion}


  {* load user suggested table *}
    IF (gasTableFileName <> asBlank)
      THEN BEGIN
        System.WriteLn(asProgramPrompt+'Read user table file.');
        System.Assign(gfUserTableInStream,gasTableFileName);
        {$I-} System.Reset(gfUserTableInStream,System.Sizeof(gbCodesInUseTable)); {$I+}
        IF  (System.IoResult <> 0)
          THEN  BEGIN
             System.WriteLn(asProgramPrompt+'Unable to open a table file.');
             System.Halt(errBadTableFilename);
               END;
        {if-then}
        {$I-} System.BlockRead(gfUserTableInStream,gbCodesInUseTable,1,gdwResCount); {$I+}
        IF (gdwResCount <> 1)
          THEN BEGIN
            System.WriteLn(asProgramPrompt+'Unable to read the table file.');
            System.Halt(errReadTableFile);
               END;
        {if-then}
        System.Close(gfUserTableInStream);
           END;
    {if-then}


  {* ask password file *}
    IF (gdwParamNum < 4)
      THEN  BEGIN
         System.Write(asProgramPrompt+'Enter password filename (def.ext.='+
                      asDefPwdExt+'): ');
         System.ReadLn(gasPwdFileName);
            END
      ELSE
         gasPwdFileName := System.ParamStr(4);
    {if-then-else}
    IF (gasPwdFileName = asBlank)
      THEN
         System.WriteLn(asProgramPrompt+'No name for password file. Null password in use as starting.')
      ELSE
         gasPwdFileName := _fnsAddDefExt(gasPwdFileName,asDefPwdExt);
    {if-then-else}
    gasPwdFileName := _fnsUpcaseStr(gasPwdFileName);
    {$IFDEF   DebugVersion}
        System.WriteLn(asProgramPrompt+'Password file: '+gasPwdFileName);
    {$ENDIF} {DebugVersion}


  {* load user password description file*}
    IF (gasPwdFileName <> asBlank)
      THEN BEGIN
        System.WriteLn(asProgramPrompt+'Read user password file.');
        System.Assign(gfUserPwdInStream,gasPwdFileName);
        {$I-} System.Reset(gfUserPwdInStream,1); {$I+}
        IF  (System.IoResult <> 0)
          THEN  BEGIN
             System.WriteLn(asProgramPrompt+'Unable to open a password file.');
             System.Halt(errBadPasswordFilename);
               END;
        {if-then}
        gdwByteCount := _fndwLowWord(System.FileSize(gfUserPwdInStream));
        {$I-} System.BlockRead(gfUserPwdInStream,gdbSearchPassword,gdwByteCount,gdwResCount); {$I+}
        IF (gdwResCount <> gdwByteCount)
          THEN BEGIN
            System.WriteLn(asProgramPrompt+'Unable to read the password file.');
            System.Halt(errReadPwdFile);
               END;
        {if-then}
        System.Close(gfUserPwdInStream);
           END;
    {if-then}


  {* ask minimal length of password for search *}
    IF (gdwParamNum < 5)
      THEN  BEGIN
         System.Write(asProgramPrompt+'Enter min. len for password (C/R=',
                      gadbMinPswdLen,'): ');
         System.ReadLn(gsTempInput);
            END
      ELSE
         gsTempInput := System.ParamStr(5);
    {if-then-else}
    IF (gsTempInput <> asBlank)
      THEN BEGIN
              System.Val(gsTempInput,gdbTemp,giErrorCode);
              IF (giErrorCode = 0)
                THEN  gadbMinPswdLen := gdbTemp;
              {if-then}
           END;
    {if-then}
    {$IFDEF   DebugVersion}
        System.WriteLn(asProgramPrompt+'Min len for password = ',gadbMinPswdLen);
    {$ENDIF} {DebugVersion}


  {* ask maximal length of password for search *}
    IF (gdwParamNum < 6)
      THEN  BEGIN
         System.Write(asProgramPrompt+'Enter max. len for password (C/R=',
                      gadbMaxPswdLen,'): ');
         System.ReadLn(gsTempInput);
            END
      ELSE
         gsTempInput := System.ParamStr(6);
    {if-then-else}
    IF (gsTempInput <> asBlank)
      THEN BEGIN
              System.Val(gsTempInput,gdbTemp,giErrorCode);
              IF (giErrorCode = 0) AND (gadbMinPswdLen <= gdbTemp)
                THEN  gadbMaxPswdLen := gdbTemp;
              {if-then}
           END;
    {if-then}
    {$IFDEF   DebugVersion}
        System.WriteLn(asProgramPrompt+'Max len for password = ',gadbMaxPswdLen);
    {$ENDIF} {DebugVersion}


  {* describe password a more in detail if possible *}
    IF (gdwParamNum < 7)
      THEN  BEGIN
         System.Write(asProgramPrompt+'Do you want to describe password? (N/Y): ');
         System.ReadLn(gsTempInput);
            END
      ELSE
         gsTempInput := System.ParamStr(7);
    {if-then-else}
    IF (gsTempInput <> asBlank) AND (System.Upcase(_fnchGetFirstChar(gsTempInput)) = aYes)
      THEN BEGIN
        {* we must know all from the first char up to the last char! *}
         FOR  gdbIndex := aMinPswdVal TO  gadbMaxPswdLen  DO
           WITH  gdbSearchPassword[gdbIndex] DO
           BEGIN
             System.WriteLn(asProgramPrompt+'Parameters for symbol ',gdbIndex);
           {* start value *}
             System.Write('Starting value = '+achHexPrefix+_fnsByteToHexFmt(dbCurValue),'. New value (C/R=no change): ');
             System.ReadLn(gsTempInput);
             IF (gsTempInput <> asBlank)
               THEN  dbCurValue := _fndbGetValue(gsTempInput);
             {if-then}
           {* min. value to search *}
             System.Write('Min search value = '+achHexPrefix+_fnsByteToHexFmt(dbMinSymValue),'. New value (C/R=no change): ');
             System.ReadLn(gsTempInput);
             IF (gsTempInput <> asBlank)
               THEN  dbMinSymValue := _fndbGetValue(gsTempInput);
             {if-then}
           {* max. value to search *}
             System.Write('Max search value = '+achHexPrefix+_fnsByteToHexFmt(dbMaxSymValue),'. New value (C/R=no change): ');
             System.ReadLn(gsTempInput);
             IF (gsTempInput <> asBlank)
               THEN  dbMaxSymValue := _fndbGetValue(gsTempInput);
             {if-then}
           {* check for impossible situation *}
             IF (dbMaxSymValue < dbMinSymValue)
               THEN dbMaxSymValue := dbMinSymValue;
             {if-then}
           END;
           {with-do}
         {for-to-do}
           END;
    {if-then}


  {$IFNDEF   HeavenCalculations}
  {* more detail info for symbol 2 in password *}
    IF (gadbMaxPswdLen > 1)
      THEN  WITH  gdbSearchPassword[2]  DO
    {$IFDEF   UseMoreStaticKeysForSecondSymbol}
           IF ((dbMaxSymValue - dbMinSymValue) > aBlock127)
    {$ELSE}
           IF ((dbMaxSymValue - dbMinSymValue) > aBlock63)
    {$ENDIF} {UseMoreStaticKeysForSecondSymbol}
             THEN BEGIN
    {$IFDEF   UseMoreStaticKeysForSecondSymbol}
             System.WriteLn(asProgramPrompt+'For symbol 2: (max-min) < 128.  (This improves process speed).');
    {$ELSE}
             System.WriteLn(asProgramPrompt+'For symbol 2: (max-min) < 64.  (This improves process speed).');
    {$ENDIF} {UseMoreStaticKeysForSecondSymbol}
           {* start value *}
             System.Write('Starting value = '+achHexPrefix+_fnsByteToHexFmt(dbCurValue),
                          '. New value (C/R=no change): ');
             System.ReadLn(gsTempInput);
             IF (gsTempInput <> asBlank)
               THEN  dbCurValue := _fndbGetValue(gsTempInput);
             {if-then}
           {* min. value to search *}
             System.Write('Min search value = '+achHexPrefix+_fnsByteToHexFmt(dbMinSymValue),
                          '. New value (C/R=no change): ');
             System.ReadLn(gsTempInput);
             IF (gsTempInput <> asBlank)
               THEN  dbMinSymValue := _fndbGetValue(gsTempInput);
             {if-then}
           {* max. value to search *}
             System.Write('Max search value = '+achHexPrefix+_fnsByteToHexFmt(dbMaxSymValue),
                          '. New value (C/R=no change): ');
             System.ReadLn(gsTempInput);
             IF (gsTempInput <> asBlank)
               THEN  dbMaxSymValue := _fndbGetValue(gsTempInput);
             {if-then}
           {* check for impossible situation *}
             IF (dbMaxSymValue < dbMinSymValue)
               THEN  dbMaxSymValue := dbMinSymValue;
             {if-then}
    {$IFDEF   UseMoreStaticKeysForSecondSymbol}
             IF ((dbMaxSymValue - dbMinSymValue) > aBlock127)
               THEN  dbMaxSymValue := (System.Word(dbMinSymValue) + aBlock127) AND $FF;
    {$ELSE}
             IF ((dbMaxSymValue - dbMinSymValue) > aBlock63)
               THEN  dbMaxSymValue := (System.Word(dbMinSymValue) + aBlock63) AND $FF;
    {$ENDIF} {UseMoreStaticKeysForSecondSymbol}
                  END;
           {if-then}
        {with-do}
    {if-then}
  {$ENDIF}  {HeavenCalculations}


    {* display current settings for password search *}
    {$IFDEF   DebugVersion}
         System.WriteLn(asProgramPrompt+'The following password parameters to search are found:');
         System.WriteLn(asProgramPrompt+' Symbol     Start     Minimum    Maximum');
         FOR  gdbIndex := aMinPswdVal TO  gadbMaxPswdLen  DO
           WITH  gdbSearchPassword[gdbIndex] DO
             System.WriteLn('            ',gdbIndex,
                            '        '+achHexPrefix+_fnsByteToHexFmt(dbCurValue),
                            '        '+achHexPrefix+_fnsByteToHexFmt(dbMinSymValue),
                            '        ',+achHexPrefix+_fnsByteToHexFmt(dbMaxSymValue));
           {with-do}
         {for-to-do}
    {$ENDIF} {DebugVersion}


  {* ask about batch mode *}
    IF (gdwParamNum < 8)
      THEN  BEGIN
         System.Write(asProgramPrompt+'Do you want to use the batch mode? (N/Y): ');
         System.ReadLn(gsTempInput);
            END
      ELSE
         gsTempInput := System.ParamStr(8);
    {if-then-else}
    IF (gsTempInput <> asBlank) AND (System.Upcase(_fnchGetFirstChar(gsTempInput)) = aYes)
      THEN BEGIN
         gabBatchModeOn := System.True;
         {$IFDEF   DebugVersion}
             System.WriteLn(asProgramPrompt+'Batch mode ON.');
         {$ENDIF} {DebugVersion}
           END
      ELSE
         {$IFDEF   DebugVersion}
             System.WriteLn(asProgramPrompt+'Batch mode OFF.');
         {$ENDIF} {DebugVersion}
         {*nothing*};
   {if-then-else}


  {* ask user found password file*}
    IF (gdwParamNum < 9)
      THEN  BEGIN
         System.Write(asProgramPrompt+'Enter found password filename (def.ext.='+
                      asDefFoundPwdExt+'): ');
         System.ReadLn(gasFoundPwdFileName);
            END
      ELSE
         gasFoundPwdFileName := System.ParamStr(9);
    {if-then-else}
    IF (gasFoundPwdFileName = asBlank)
      THEN
         System.WriteLn(asProgramPrompt+'No name for found password file. Output to screen only.')
      ELSE  BEGIN
         gasFoundPwdFileName := _fnsAddDefExt(gasFoundPwdFileName,asDefFoundPwdExt);
         gasFoundPwdFileName := _fnsUpcaseStr(gasFoundPwdFileName);
         {$IFDEF   DebugVersion}
             System.WriteLn(asProgramPrompt+'Password file: '+gasFoundPwdFileName);
         {$ENDIF} {DebugVersion}
            END;
    {if-then-else}



  {* create user found password file*}
    IF (gasFoundPwdFileName <> asBlank)
      THEN BEGIN
        System.WriteLn(asProgramPrompt+'Create user found password file.');
        System.Assign(gfFoundPwdOutStream,gasFoundPwdFileName);
        System.SetTextBuf(gfFoundPwdOutStream,gdbLargeFoundPwdBuf);
        {$I-} System.Rewrite(gfFoundPwdOutStream); {$I+}
        IF  (System.IoResult <> 0)
          THEN  BEGIN
             System.WriteLn(asProgramPrompt+'Unable to create a found password file.');
             System.Halt(errBadFoundPwdFilename);
               END
          ELSE
             gabUseFileToWritePwd := System.True;
        {if-then-else}
           END;
    {if-then}


 {$IFDEF   MakeStatistic}
   {* ask about statistics mode *}
      System.Write(asProgramPrompt+'Use statistics mode for the found pwd(s)? (N/Y): ');
      System.ReadLn(gsTempInput);
      IF (gsTempInput <> asBlank) AND (System.Upcase(_fnchGetFirstChar(gsTempInput)) = aYes)
       THEN BEGIN
          gabFoundPwdStatisticsON := System.True;
          {$IFDEF   DebugVersion}
              System.WriteLn(asProgramPrompt+'Statistics mode ON.');
          {$ENDIF} {DebugVersion}
            END
       ELSE  BEGIN
          {$IFDEF   DebugVersion}
              System.WriteLn(asProgramPrompt+'Statistics mode OFF.');
          {$ENDIF} {DebugVersion}
             END;
      {if-then-else}
      IF  (gabFoundPwdStatisticsON)
        THEN  BEGIN
           System.Write(asProgramPrompt+'Enter found pwd(s) stat. filename (def.ext.='+
                        asDefStatPwdExt+'): ');
                System.ReadLn(gasStatFileName);
           IF (gasStatFileName = asBlank)
             THEN  BEGIN
                gabFoundPwdStatisticsON := System.False;
                System.WriteLn(asProgramPrompt+'Null filename. Statistics mode OFF.');
                   END
             ELSE  BEGIN
                gasStatFileName := _fnsAddDefExt(gasStatFileName,asDefStatPwdExt);
                gasStatFileName := _fnsUpcaseStr(gasStatFileName);
                {$IFDEF   DebugVersion}
                    System.WriteLn(asProgramPrompt+'Statistics file: '+gasStatFileName);
                {$ENDIF} {DebugVersion}
                   END;
           {if-then-else}
              END;
      {if-then}
  {* create the user found password statistics file*}
    IF (gasStatFileName <> asBlank)
      THEN BEGIN
        System.WriteLn(asProgramPrompt+'Create user statistics file.');
        System.Assign(gfStatOutStream,gasStatFileName);
        System.SetTextBuf(gfStatOutStream,gdbLargeStatPwdBuf);
        {$I-} System.Rewrite(gfStatOutStream); {$I+}
        IF  (System.IoResult <> 0)
          THEN  BEGIN
             System.WriteLn(asProgramPrompt+'Unable to create a statistics file.');
             System.Halt(errBadStatFilename);
               END;
        {if-then}
        System.WriteLn(gfStatOutStream,';  Found Password(s) Statistics File');
        System.WriteLn(gfStatOutStream,';  Created by '+asProgram+' utility, '+asCopyright+'  '+asAuthor);
        System.WriteLn(gfStatOutStream);
        System.WriteLn(gfStatOutStream,'Archive File:    '+gasZipFileName);
        System.WriteLn(gfStatOutStream,'Encrypted File:  '+gasEncryptedFileName);
        System.WriteLn(gfStatOutStream,'File CRC-32:     ',achHexPrefix,_fnsDoubleWordToHexFmt(gddFileCRC32));
        System.Write(gfStatOutStream,'Random data:     ');
        FOR  gdbIndex :=  1  TO  aRandomDataLen  DO
        BEGIN
           System.Write(gfStatOutStream,achHexPrefix+
                       _fnsByteToHexFmt(gdbRandomValues[gdbIndex]));
        END;
        {for-to-do}
        System.WriteLn(gfStatOutStream);
        System.WriteLn(gfStatOutStream,'Pwd min. length: ',gadbMinPswdLen);
        System.WriteLn(gfStatOutStream,'Pwd max. length: ',gadbMaxPswdLen);
        System.WriteLn(gfStatOutStream,'Character map:   ',gasTableFileName);
        System.WriteLn(gfStatOutStream);
        System.WriteLn(gfStatOutStream);
           END;
    {if-then}
 {$ENDIF} {MakeStatistic}


{$IFDEF   AutomaticSearchTruePassword}
   {* ask about auto mode *}
      System.Write(asProgramPrompt+'Use the auto detection of the true password? (N/Y): ');
      System.ReadLn(gsTempInput);
      IF (gsTempInput <> asBlank) AND (System.Upcase(_fnchGetFirstChar(gsTempInput)) = aYes)
       THEN BEGIN
          {$IFDEF   DebugVersion}
              System.WriteLn(asProgramPrompt+'Auto detection  mode ON.');
          {$ENDIF} {DebugVersion}
         System.Write(asProgramPrompt+'Enter the path for ',asPkUnzipName,': ');
         System.ReadLn(gsTempInput);
         IF (gsTempInput <> asBlank)  THEN
         BEGIN
                IF (gsTempInput[System.Length(gsTempInput)] <> aDosDirDelim)
                  THEN  BEGIN
                    IF  (System.Pos(aDosExtMark,gsTempInput) <> 0)
                      THEN
                        gadbDefaultPkUnzipInUse := System.False
                      ELSE
                         gsTempInput := gsTempInput + aDosDirDelim;
                    {if-then-else}
                        END;
                {if-then}
                gasPkUnzipPath := _fnsUpcaseStr(gsTempInput);
                {$IFDEF   DebugVersion}
                    System.WriteLn(asProgramPrompt+'Found pathname: ',gasPkUnzipPath);
                {$ENDIF} {DebugVersion}
         END;
         {if-then}
            END
       ELSE  BEGIN
          gabAutoSearchTruePwdON := System.False;
          {$IFDEF   DebugVersion}
              System.WriteLn(asProgramPrompt+'Auto detection mode OFF.');
          {$ENDIF} {DebugVersion}
             END;
      {if-then-else}
{$ENDIF} {AutomaticSearchTruePassword}


{$IFDEF  AutomaticGenerationTestsForTruePassword}
   {* ask about auto mode *}
      System.Write(asProgramPrompt+'Generate batch file to password(s) testing? (Y/N): ');
      System.ReadLn(gsTempInput);
      IF (gsTempInput <> asBlank) AND (System.Upcase(_fnchGetFirstChar(gsTempInput)) = aNo)
       THEN BEGIN
          gabDoTestBatchFile := System.False;
          {$IFDEF   DebugVersion}
              System.WriteLn(asProgramPrompt+'Auto generation mode OFF.');
          {$ENDIF} {DebugVersion}
            END
       ELSE  BEGIN
           System.Write(asProgramPrompt+'Enter batch filename (def.ext.='+
                        asDefBatchFileExt+'): ');
                System.ReadLn(gasTestBatchFileName);
           IF (gasTestBatchFileName = asBlank)
             THEN  BEGIN
                gabDoTestBatchFile := System.False;
                System.WriteLn(asProgramPrompt+'No filename specified.');
                   END
             ELSE  BEGIN
                {$IFDEF   DebugVersion}
                    System.WriteLn(asProgramPrompt+'Auto generation mode ON.');
                {$ENDIF} {DebugVersion}
                gasTestBatchFileName:= _fnsAddDefExt(gasTestBatchFileName,asDefBatchFileExt);
                gasTestBatchFileName:= _fnsUpcaseStr(gasTestBatchFileName);
                {$IFDEF   DebugVersion}
                    System.WriteLn(asProgramPrompt+'Test batch file: '+gasTestBatchFileName);
                {$ENDIF} {DebugVersion}
                   END;
           {if-then-else}
             END;
      {if-then-else}
{$ENDIF} {AutomaticGenerationTestsForTruePassword}


  {* init keys for one-character password *}
    System.WriteLn(asProgramPrompt+'Build static table of keys for one-symbol password.');

  {* get system time *}
    WITH  grecInitTime  DO
      Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
    {with-do}

  {* make static table *}
    FOR  gdbIndex := aMinCodeChar  TO  aMaxCodeChar  DO
      WITH  gdbKeysForOneSymPswd[gdbIndex]  DO
      BEGIN
          gddKeyZero := aPkInitKeyZero;     { initial values }
          gddKeyOne  := aPkInitKeyOne;
          gddKeyTwo  := aPkInitKeyTwo;
          asm
               xor      bx, bx
               mov      bl, gdbIndex
               call     _UpdateKeys
          end;
          {asm-end}
          ddKeyZero := gddKeyZero;          { save values }
          ddKeyOne  := gddKeyOne;
          ddKeyTwo  := gddKeyTwo;
      END;
      {with-do}
    {for-to-do}

  {* get system time *}
    WITH  grecLastTime  DO
      Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
    {with-do}
    _CalcActualTime(grecInitTime,grecLastTime,grecWorkTime);
    System.WriteLn(asProgramPrompt+'Actual build time (HH:MM:SS:TT) = ',
                _fnsRunTime(grecWorkTime));


  {* get memory pool from operating system *}
    IF (gadbMaxPswdLen > 1)
      THEN  BEGIN
          System.WriteLn(asProgramPrompt+'Get the memory from the DOS.');
         {$IFDEF   UseFastestCode}
            _AllocDosMem(gdwKeyZeroSeg,aParasIn192K);
             gdwKeyOneSeg := gdwKeyZeroSeg + aParasIn64K;
             gdwKeyTwoSeg := gdwKeyZeroSeg + aParasIn64K*2;
         {$ELSE}
            _AllocDosMem(gdwKeyZeroSeg,aParasIn64K);
            _AllocDosMem(gdwKeyOneSeg, aParasIn64K);
            _AllocDosMem(gdwKeyTwoSeg, aParasIn64K);
         {$ENDIF} {UseFastestCode}
         {$IFDEF   UseMoreStaticKeysForSecondSymbol}
           {$IFDEF   UseFastestCode}
             _AllocDosMem(gdwKeyZeroSegSym2,aParasIn192K);
             gdwKeyOneSegSym2 := gdwKeyZeroSegSym2 + aParasIn64K;
             gdwKeyTwoSegSym2 := gdwKeyZeroSegSym2 + aParasIn64K*2;
           {$ELSE}
             _AllocDosMem(gdwKeyZeroSegSym2,aParasIn64K);
             _AllocDosMem(gdwKeyOneSegSym2, aParasIn64K);
             _AllocDosMem(gdwKeyTwoSegSym2, aParasIn64K);
           {$ENDIF} {UseFastestCode}
         {$ENDIF} {UseMoreStaticKeysForSecondSymbol}


      {* init keys for two-character password (block=64 codes) *}
        System.WriteLn(asProgramPrompt+'Build static table of keys for partial two-symbol password.');

      {* get system time *}
        WITH  grecInitTime  DO
          Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
        {with-do}

      {* make static table *}
        IF (gadbMaxPswdLen >= 2)
        THEN
           WITH  gdbSearchPassword[2]  DO
 {$IFDEF   UseMoreStaticKeysForSecondSymbol}
             FOR  gdbSymIndex :=  dbMinSymValue  TO  (dbMinSymValue+aBlock63)  DO
 {$ELSE}
             FOR  gdbSymIndex :=  dbMinSymValue  TO  dbMaxSymValue  DO
 {$ENDIF} {UseMoreStaticKeysForSecondSymbol}
                FOR  gdbIndex :=  aMinCodeChar  TO  aMaxCodeChar  DO
                  WITH  gdbKeysForOneSymPswd[gdbIndex]  DO
                  BEGIN
                      gddKeyZero := ddKeyZero;     { initial values }
                      gddKeyOne  := ddKeyOne;
                      gddKeyTwo  := ddKeyTwo;
                      asm
                           sub      bx, bx
                           mov      bl, gdbSymIndex
                           call     _UpdateKeys
                      end;
                      {asm-end}
                      gdwMemOfs := System.Sizeof(ddKeyZero)*
                            ((gdbIndex-aMinCodeChar)+(gdbSymIndex-dbMinSymValue)*(aMaxCodeChar+1));
                      System.MemL[gdwKeyZeroSeg:gdwMemOfs] := gddKeyZero;
                      System.MemL[gdwKeyOneSeg:gdwMemOfs]  := gddKeyOne;
                      System.MemL[gdwKeyTwoSeg:gdwMemOfs]  := gddKeyTwo;
                  END;
                  {with-do}
                {for-to-do}
             {for-to-do}
           {with-do}
        {if-then}

      {* get system time *}
        WITH  grecLastTime  DO
          Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
        {with-do}
        _CalcActualTime(grecInitTime,grecLastTime,grecWorkTime);
        System.WriteLn(asProgramPrompt+'Actual build time (HH:MM:SS:TT) = ',
                    _fnsRunTime(grecWorkTime));
            END;
    {if-then}


 {$IFDEF   UseMoreStaticKeysForSecondSymbol}
      {* init keys for two-character password (block=next 64 codes) *}
        System.WriteLn(asProgramPrompt+'Build static table of keys for partial two-symbol password.');

      {* get system time *}
        WITH  grecInitTime  DO
          Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
        {with-do}

      {* make static table *}
        IF (gadbMaxPswdLen >= 2)
        THEN
           WITH  gdbSearchPassword[2]  DO
             FOR  gdbSymIndex := (dbMinSymValue+aBlock63+1)  TO  dbMaxSymValue  DO
                FOR  gdbIndex := aMinCodeChar  TO  aMaxCodeChar  DO
                  WITH  gdbKeysForOneSymPswd[gdbIndex]  DO
                  BEGIN
                      gddKeyZero := ddKeyZero;     { initial values }
                      gddKeyOne  := ddKeyOne;
                      gddKeyTwo  := ddKeyTwo;
                      asm
                           sub      bx, bx
                           mov      bl, gdbSymIndex
                           call     _UpdateKeys
                      end;
                      {asm-end}
                      gdwMemOfs := System.Sizeof(ddKeyZero)*
                            ((gdbIndex-aMinCodeChar)+(gdbSymIndex-dbMinSymValue-(aBlock63+1))*(aMaxCodeChar+1));
                      System.MemL[gdwKeyZeroSegSym2:gdwMemOfs] := gddKeyZero;
                      System.MemL[gdwKeyOneSegSym2:gdwMemOfs]  := gddKeyOne;
                      System.MemL[gdwKeyTwoSegSym2:gdwMemOfs]  := gddKeyTwo;
                  END;
                  {with-do}
                {for-to-do}
             {for-to-do}
           {with-do}
        {if-then}

      {* get system time *}
        WITH  grecLastTime  DO
          Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
        {with-do}
        _CalcActualTime(grecInitTime,grecLastTime,grecWorkTime);
        System.WriteLn(asProgramPrompt+'Actual build time (HH:MM:SS:TT) = ',
                    _fnsRunTime(grecWorkTime));
    {if-then}
 {$ENDIF} {UseMoreStaticKeysForSecondSymbol}

  {* we run the "broot-force" algorithm now! *}
     gbStatusOk   := System.False;
     gdbSymIndex  := gadbMaxPswdLen;
  {$IFDEF   OptimizeCodeInAssembly}
       asm
           mov     al, aMinPswdVal
           mov     ah, gdbSymIndex
           dec     ah
           call   _PreCalcKeys
       end; {asm-end}
  {$ELSE}
       _PreCalcKeys(aMinPswdVal,gdbSymIndex-1);
  {$ENDIF} {OptimizeCodeInAssembly}
     System.WriteLn(asProgramPrompt+'Go!');

  {* get system time *}
    System.FillChar(grecTrueTime,System.Sizeof(recSaveTime),0);
    WITH  grecInitTime  DO
      Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
    {with-do}
    System.Move(grecInitTime,grecEarlyTime,System.Sizeof(recSaveTime));
    System.Move(grecInitTime,grecStartTime,System.Sizeof(recSaveTime));


  {* go!!!!!!! *}
     REPEAT
     {$IFDEF   MakeStatistic}
          System.Inc(gliSearchPwdCount);
     {$ENDIF} {MakeStatistic}
         {* Step 1: initialize the encryption keys *}
         {*   loop for i <- 0 to length(password)-1   *}
         {*       update_keys(password[i])            *}
         {*   end loop                                *}
     {$IFDEF   HeavenCalculations}
             gddKeyZero := aPkInitKeyZero;     { initial values }
             gddKeyOne  := aPkInitKeyOne;
             gddKeyTwo  := aPkInitKeyTwo;
       {$IFNDEF   OptimizeCodeInAssembly}
                FOR  gdbIndex :=  aMinPswdVal  TO gdbSymIndex  DO
                BEGIN
                    gdbTemp :=  gdbSearchPassword[gdbIndex].dbCurValue;
                    asm
                           xor      bx, bx
                           mov      bl, gdbTemp
                           call     _UpdateKeys
                    end;
                    {asm-end}
                END;
                {for-to-do}
       {$ELSE}
             asm
                      mov     gdwSaveRegBP, bp
                      mov     bp, aMinPswdVal
                      sub     ax, ax
                      mov     al, gdbSymIndex
                      mov     gdwTempCount, ax

                @NextIndex:
                      cmp     bp, gdwTempCount
                      ja    @LastIndexPassed

                      mov     bx, bp
                      dec     bx                      { BX = gdbSymIndex - 1 }
                      mov     ax, bx
                      shl     bx, 1
                      add     bx, ax                  { BX = (gdbSymIndex-1)*3 }
                      mov     bl, [bx+(OFFSET gdbSearchPassword)]
                      sub     bh, bh                  { BX = dbCurValue }
                      call     _UpdateKeys
                      inc     bp
		      jmp   @NextIndex

                @LastIndexPassed:
                      mov     bp, gdwSaveRegBP
              end; {asm-end}
       {$ENDIF}  {OptimizeCodeInAssembly}
     {$ELSE}
       {$IFDEF   OptimizeCodeInAssembly}
            asm
                   mov    al, gadbLastCharIndex
                   or     al, al
                   je    @UseStaticEncryptionKeys
                   mov    gadbLastCharIndex, 0
                   mov    ah, gdbSymIndex
                   dec    ah
                   call   _PreCalcKeys
              @UseStaticEncryptionKeys:
            end; {asm-end}
       {$ELSE}
           IF  (gadbLastCharIndex <> 0)
             THEN  BEGIN
                _PreCalcKeys(gadbLastCharIndex,gdbSymIndex-1);
                gadbLastCharIndex := 0;
                   END;
           {if-then}
       {$ENDIF} {OptimizeCodeInAssembly}
       {$IFNDEF   OptimizeCodeInAssembly}
           IF  (gdbSymIndex <> 1)
             THEN  BEGIN
                 System.Move(gdbLastPasswordKeys[gdbSymIndex-1],
                             gddKeyZero,
                             System.Sizeof(recEncryptedKeys));
                 asm
                      sub     bx, bx
                      mov     bl, gdbSymIndex
                      dec     bx                      { BX = gdbSymIndex - 1 }
                      mov     ax, bx
                      shl     bx, 1
                      add     bx, ax                  { BX = (gdbSymIndex-1)*3 }
                      mov     bl, [bx+(OFFSET gdbSearchPassword)]
                      sub     bh, bh                  { BX = dbCurValue }
                      call    _UpdateKeys
                 end;
                 {asm-end}
                   END;
           {if-then}
       {$ELSE}
           asm
                      cld
                      mov     ax, ds
                      mov     es, ax
       {$IFDEF   OptimizeCodeFor386}
                      mov     cx, aEncryptionKeysSizeDiv4
       {$ELSE}
                      mov     cx, aEncryptionKeysSizeDiv2
       {$ENDIF} {OptimizeCodeFor386}
                      mov     di, OFFSET gddKeyZero
       {$IFDEF   UseFastestCode}
                      mov     bx, cx                         { CH = 0 }
                      mov     bl, gdbSymIndex
                      shl     bx, 1
                      cmp     bl, 2                          { 1 * 2 }
       {$ELSE}
                      mov     ax, cx                         { CH = 0 }
                      mov     al, gdbSymIndex
                      cmp     al, 1
       {$ENDIF} {UseFastestCode}
                      jne    @IndexNotEqualOne

       {$IFDEF   UseFastestCode}
                      mov     bl, BYTE PTR gdbSearchPassword.[0]  { gdbSearchPassword[1].dbCurValue}
                      shl     bx, 1
                      mov     si, [bx+OFFSET (gdbOneSymKeysOfsTabl)]
       {$ELSE}
                      mov     al, BYTE PTR gdbSearchPassword.[0]  { gdbSearchPassword[1].dbCurValue}
                      mov     bx, ax                         { multiply by }
                      shl     ax, 1                          { Sizeof(recEncryptedKeys) }
                      add     ax, bx
         {$IFDEF   OptimizeCodeFor186}
                      shl     ax, 2
         {$ELSE}
                      shl     ax, 1
                      shl     ax, 1
         {$ENDIF} {OptimizeCodeFor186}
                      mov     si, OFFSET gdbKeysForOneSymPswd
                      add     si, ax
       {$ENDIF} {UseFastestCode}
       {$IFDEF   OptimizeCodeFor386}
                      db      66h, 0F3h, 0A5h                      { rep  movsd }
       {$ELSE}
                      rep     movsw
       {$ENDIF} {OptimizeCodeFor386}
                      jmp    @Done

                @IndexNotEqualOne:
       {$IFDEF   UseFastestCode}
                      mov     si, [bx+(OFFSET gdbLastPwdKeysOfsTabl)-4]   { 4 = SizeOf(System.Word)*2 }
                      mov     bx, [bx+(OFFSET gdbSearchPwdOfsTable)-2]
                      mov     bl, [bx]
       {$ELSE}
                      dec     ax                      { BX = gdbSymIndex - 1 }
                      mov     bx, ax                  { Multiply by 12 = }
                      shl     ax, 1                   { = Sizeof(recEncryptedKeys) }
                      add     ax, bx
                      mov     bx, ax
         {$IFDEF   OptimizeCodeFor186}
                      shl     ax, 2
         {$ELSE}
                      shl     ax, 1
                      shl     ax, 1
         {$ENDIF} {OptimizeCodeFor186}
                      sub     ax, 4*3                 { - Sizeof(recEncryptedKeys) }
                      mov     si, OFFSET gdbLastPasswordKeys
                      add     si, ax
                      mov     bl, [bx+(OFFSET gdbSearchPassword)]
       {$ENDIF} {UseFastestCode}
       {$IFDEF   OptimizeCodeFor386}
                      db      66h, 0F3h, 0A5h                      { rep  movsd }
       {$ELSE}
                      rep     movsw
       {$ENDIF} {OptimizeCodeFor386}
                      mov     bh, ch                  { BX = dbCurValue, CH = 0 }
                      call    _UpdateKeys

                @Done:
           end;
           {asm-end}
       {$ENDIF}  {OptimizeCodeInAssembly}
     {$ENDIF} {HeavenCalculations}
         {* copy an encrypted header *}
           asm
                cld
                mov     ax, ds
                mov     es, ax
                mov     si, OFFSET gdbRandomValues
                mov     di, OFFSET gdbTempRandomBuffer
                mov     dx, di
     {$IFDEF   OptimizeCodeFor386}
                mov     cx, (aRandomDataLen SHR 2)            { 12 / 4 }
                db      66h, 0F3h, 0A5h                       { rep  movsd }
     {$ELSE}
                mov     cx, (aRandomDataLen SHR 1)            { 12 / 2 }
                rep     movsw
     {$ENDIF} {OptimizeCodeFor386}
              {* Alternate code to string copy: *}
              {*    shr  cx, 1                  *}
              {*    jnc  @NotEven               *}
              {*   movsb                        *}
              {*  @NotEven:                     *}
              {*    rep  movsw                  *}
           end;
           {asm-end}

         {* step 2: decrypt 12-byte encryption header *}
         {*    loop for i <- 0 to 11                  *}
         {*        C <- buffer[i] ^ encrypt_byte()    *}
         {*        update_keys(C)                     *}
         {*        buffer[i] <- C                     *}
         {*    end loop                               *}

         asm
                mov     si, dx
     {$IFDEF   UseStackForTemporaryStore}
                push    bp
     {$ELSE}
                mov     gdwSaveRegBP, bp
     {$ENDIF} {UseStackForTemporaryStore}
                mov     bp, aRandomDataLen

         {* PROCEDURE decrypt_byte() *}
         {*   unsigned char decrypt_byte()                *}
         {*      local unsigned short temp                *}
         {*      temp <- Key[2] | 2                       *}
         {*      decrypt_byte <- (temp * temp ^ 1)) >> 8  *}
         {*   end decrypt_byte                            *}

           @NextChar:
                mov     bx, WORD PTR gddKeyTwo+0
                or      bx, 2
                mov     ax, bx
                xor     al, 1
                mul     bx

         {* decrypt a character in the buffer *}
                sub     bx, bx
                xor     [si], ah
                mov     bl, [si]
     {$IFDEF   UseStackForTemporaryStore}
                push    si
     {$ELSE}
                mov     gdwTemp, si
     {$ENDIF} {UseStackForTemporaryStore}
                call    _UpdateKeys
     {$IFDEF   UseStackForTemporaryStore}
                pop     si
     {$ELSE}
                mov     si, gdwTemp
     {$ENDIF} {UseStackForTemporaryStore}
                inc     si
                dec     bp
                jnz     @NextChar

     {$IFDEF   UseStackForTemporaryStore}
                pop     bp
     {$ELSE}
                mov     bp, gdwSaveRegBP
     {$ENDIF} {UseStackForTemporaryStore}
           end;
           {asm-end}

         {* check for match high-word/byte of CRC-32 *}
           asm
{$IFDEF  PKWARE204G}
                mov     al, [si-1]
                cmp     al, BYTE PTR gddFileCRC32+3
{$ELSE}
                mov     ax, [si-2]
                cmp     ax, WORD PTR gddFileCRC32+2
{$ENDIF  PKWARE204G}
                jne     @NotMatchWord
                mov     gbStatusOk, System.True
             @NotMatchWord:
           end;
           {asm-end}

           IF (gbStatusOk)
             THEN  BEGIN
                WITH  grecLastTime  DO
                  Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
                {with-do}
                System.Inc(gliFoundPwdCount);
                System.Write(asProgramPrompt+'Possible password: ');
                System.Write('symbols ',aMinPswdVal,'-',gdbSymIndex,' = ');
                gsTempInput := '  (';
                gsSavePwd := asBlank;
                FOR  gdbIndex :=  aMinPswdVal  TO  gdbSymIndex  DO
                    WITH  gdbSearchPassword[gdbIndex]  DO
                    BEGIN
                        gsSavePwd := gsSavePwd + System.Char(dbCurValue);
                        System.Write(achHexPrefix+_fnsByteToHexFmt(dbCurValue));
                        IF  (System.Char(dbCurValue) IN  setDisplayCodesOfASCII)
                          THEN  gsTempInput := gsTempInput + System.Char(dbCurValue)
                          ELSE  gsTempInput := gsTempInput + achPoint;
                        {if-then-else}
                    END;
                    {with-do}
                {for-to-do}
                System.WriteLn(gsTempInput+')');
                _CalcActualTime(grecInitTime,grecLastTime,grecWorkTime);
                System.WriteLn(asProgramPrompt+'Last running time (HH:MM:SS:TT) = ',
                            _fnsRunTime(grecWorkTime));
                _CalcActualTime(grecStartTime,grecLastTime,grecWorkTime);
                _AddTimeCount(grecTrueTime,grecWorkTime);
                System.Write(asProgramPrompt+'Continue? (Y/N): ');
                IF (gabBatchModeOn)
                  THEN BEGIN
                     gsTempInput := asYes;
                     System.WriteLn(aYes);
                       END
                  ELSE System.ReadLn(gsTempInput);
                {if-then-else}
                IF ((gsTempInput <> asBlank) AND
                   (System.Upcase(_fnchGetFirstChar(gsTempInput)) = aNo))
                  THEN  {* skip *}
                  ELSE  gbStatusOk := System.False;
                {if-then-else}
                IF  (gabUseFileToWritePwd)
                  THEN  BEGIN
                     {$I-} System.WriteLn(gfFoundPwdOutStream,gsSavePwd); {$I+}
                     IF  (System.IoResult <> 0)
                         THEN  BEGIN
                           System.WriteLn(asProgramPrompt+
                                          'Unable to write a found password file. Use screen output only.');
                           System.Close(gfFoundPwdOutStream);
                           gabUseFileToWritePwd := System.False;
                               END;
                     {if-then}
                        END;
                {if-then}
                {$IFDEF   MakeStatistic}
                   IF  (gabFoundPwdStatisticsON)
                       THEN  BEGIN
                    System.Write(gfStatOutStream,'*** Possible password: ');
                    gsTempInput := '  (';
                    FOR  gdbIndex :=  aMinPswdVal  TO  System.Length(gsSavePwd)  DO
                    BEGIN
                        gchTemp := gsSavePwd[gdbIndex];
                        System.Write(gfStatOutStream,achHexPrefix+
                                    _fnsByteToHexFmt(System.Byte(gchTemp)));
                        IF  (gchTemp IN setDisplayCodesOfASCII)
                           THEN  gsTempInput := gsTempInput + gchTemp
                           ELSE  gsTempInput := gsTempInput + achPoint;
                        {if-then-else}
                    END;
                    {for-to-do}
                    System.WriteLn(gfStatOutStream,gsTempInput+')');
                    System.WriteLn(gfStatOutStream,'; Bit   76543210');
                    FOR  gdbIndex :=  aMinPswdVal  TO  System.Length(gsSavePwd)  DO
                    System.WriteLn(gfStatOutStream, asSpace8+
                                   _fnsByteToBitString(System.Byte(gsSavePwd[gdbIndex]),achZero,achOne));
                    {for-to-do}
                {$IFDEF   EncryptionKeysDump}
                    System.WriteLn(gfStatOutStream);
                    System.WriteLn(gfStatOutStream, asSpace2+
                                                    'Byte'+
                                                    asSpace4+
                                                    asSpace2+
                                                    'Key[0]'+
                                                    asSpace4+
                                                    asSpace+
                                                    'Key[1]'+
                                                    asSpace4+
                                                    asSpace+
                                                    'Key[2]');
                    gddKeyZero := aPkInitKeyZero;     { initial values }
                    gddKeyOne  := aPkInitKeyOne;
                    gddKeyTwo  := aPkInitKeyTwo;
                    System.WriteLn(gfStatOutStream,
                                         asSpace2,
                                         asSpace4,
                                         asSpace4,
                                         achHexPrefix,
                                         _fnsDoubleWordToHexFmt(gddKeyZero),
                                         asSpace2,
                                         achHexPrefix,
                                         _fnsDoubleWordToHexFmt(gddKeyOne),
                                         asSpace2,
                                         achHexPrefix,
                                         _fnsDoubleWordToHexFmt(gddKeyTwo));
                    FOR  gdbIndex :=  aMinPswdVal  TO  System.Length(gsSavePwd)  DO
                    BEGIN
                      gdbTemp := System.Byte(gsSavePwd[gdbIndex]);
                      asm
                               sub      bx, bx
                               mov      bl, gdbTemp
                               call     _UpdateKeys
                      end; {asm-end}
                      System.WriteLn(gfStatOutStream,
                                          asSpace2,
                                          asSpace,
                                          achHexPrefix,
                                          _fnsByteToHexFmt(gdbTemp),
                                          asSpace4,
                                          achHexPrefix,
                                          _fnsDoubleWordToHexFmt(gddKeyZero),
                                          asSpace2,
                                          achHexPrefix,
                                          _fnsDoubleWordToHexFmt(gddKeyOne),
                                          asSpace2,
                                          achHexPrefix,
                                          _fnsDoubleWordToHexFmt(gddKeyTwo));
                    END;
                    {for-to-do}
                    System.WriteLn(gfStatOutStream);
                    System.Move(gdbRandomValues,gdbTempRandomBuffer,aRandomDataLen);
                    FOR  gdbIndex :=  1  TO  aRandomDataLen  DO
                    BEGIN
                      gdbTemp := gdbTempRandomBuffer[gdbIndex];
                      asm
                              mov     si, OFFSET gdbTempRandomBuffer
                              sub     ax, ax
                              mov     al, gdbIndex
                              dec     ax
                              add     si, ax
                              mov     bx, WORD PTR gddKeyTwo+0
                              or      bx, 2
                              mov     ax, bx
                              xor     al, 1
                              mul     bx
                              sub     bx, bx
                              xor     [si], ah
                              mov     bl, [si]
                              call    _UpdateKeys
                      end; {asm-end}
                      System.WriteLn(gfStatOutStream,
                                          asSpace2,
                                          asSpace,
                                          achHexPrefix,
                                          _fnsByteToHexFmt(gdbTemp),
                                          asSpace4,
                                          achHexPrefix,
                                          _fnsDoubleWordToHexFmt(gddKeyZero),
                                          asSpace2,
                                          achHexPrefix,
                                          _fnsDoubleWordToHexFmt(gddKeyOne),
                                          asSpace2,
                                          achHexPrefix,
                                          _fnsDoubleWordToHexFmt(gddKeyTwo));

                    END;
                    {for-to-do}
                    System.WriteLn(gfStatOutStream);
                    System.Write(gfStatOutStream,'Decrypted header:  ');
                    FOR  gdbIndex :=  1  TO  aRandomDataLen  DO
                    BEGIN
                       System.Write(gfStatOutStream,achHexPrefix+
                                   _fnsByteToHexFmt(gdbTempRandomBuffer[gdbIndex]));
                    END;
                    {for-to-do}
                    System.WriteLn(gfStatOutStream);
                    System.WriteLn(gfStatOutStream);
                {$ENDIF} {EncryptionKeysDump}
                             END;
                   {if-then}
                {$ENDIF} {MakeStatistic}

                WITH  grecStartTime  DO
                  Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
                {with-do}
                System.Move(grecStartTime,grecInitTime,System.Sizeof(recSaveTime));
                   END;
           {asm-end}

         {* check for user keystroke in the look-ahead buffer *}
           asm
                mov     ax, 40h
                mov     es, ax                  { ES = BIOS data segment }

                mov     ax, es:[1Ah]            { circular queue for keyboard handler }
                cmp     ax, es:[1Ch]
                je      @NoUserKeyPressed
                mov     gabKeyPressed, System.True

             @Flush:
                mov     ah, 0                   { read keystroke }
                int     16h
                mov     ah, 1                   { return status }
                int     16h
                jnz      @Flush
            @NoUserKeyPressed:
           end;
           {asm-end}

         {* if user pressed a key then ask him to continue or break *}
           IF (gabKeyPressed) THEN
           BEGIN
             gabKeyPressed := System.False;
             WITH  grecLastTime  DO
               Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
             {with-do}
             gabDisplayOn := System.True;
             System.Write(asProgramPrompt+'Symbols ',aMinPswdVal,'-',gdbSymIndex,' = ');
             gsTempInput := '  (';
             FOR  gdbIndex :=  aMinPswdVal  TO  gdbSymIndex  DO
             WITH  gdbSearchPassword[gdbIndex]  DO
                 BEGIN
                    System.Write(achHexPrefix+_fnsByteToHexFmt(dbCurValue));
                 IF  (System.Char(dbCurValue) IN  setDisplayCodesOfASCII)
                    THEN  gsTempInput := gsTempInput + System.Char(dbCurValue)
                    ELSE  gsTempInput := gsTempInput + achPoint;
                 {if-then-else}
                 END;
             {with-do}
             {for-downto-do}
             System.WriteLn(gsTempInput+')');
             _CalcActualTime(grecInitTime,grecLastTime,grecWorkTime);
             System.WriteLn(asProgramPrompt+'Last running time (HH:MM:SS:TT) = ',
                         _fnsRunTime(grecWorkTime));
             _CalcActualTime(grecStartTime,grecLastTime,grecWorkTime);
             _AddTimeCount(grecTrueTime,grecWorkTime);
             System.Write(asProgramPrompt+'Interrupted by user. Continue? (Y/N): ');
             System.ReadLn(gsTempInput);
             IF ((gsTempInput <> asBlank) AND
                (System.Upcase(_fnchGetFirstChar(gsTempInput)) = aNo))
               THEN  BEGIN
                 gadbUserBreakOn := System.True;
                 gbStatusOk := System.True;
                     END;
             {if-then}
            WITH  grecStartTime  DO
               Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
            {with-do}
            System.Move(grecStartTime,grecInitTime,System.Sizeof(recSaveTime));
           END;
           {if-then}

         {$IFDEF    DebugTrace}
            IF (gabCurrentPwdDisplayOn)
               THEN  BEGIN
                 System.Write({achCR+}'Debug Trace: Symbols ',gdbSymIndex,'-',aMinPswdVal,' = ');
                 FOR  gdbIndex := gdbSymIndex DOWNTO  aMinPswdVal  DO
                 BEGIN
                     WITH  gdbSearchPassword[gdbIndex]  DO
                        System.Write(achHexPrefix+_fnsByteToHexFmt(dbCurValue));
                     {with-do}
                 END;
                 {for-downto-do}
                 System.WriteLn;
                     END;
            {if-then}
         {$ENDIF}  {DebugTrace}

         {* find a next match symbol for password *}
           asm
                      cmp     gbStatusOk, System.True { check for a break signal }
                      je     @Done

            {$IFDEF   UseFastestCode}
                      mov     di, 3                   { System.Sizeof(recSymInPassword) }
                      mov     cx, di                  { CH = 0 }
                      mov     cl, gdbSymIndex         { CX = gdbSymIndex }
                      mov     bx, cx                  { BX = gdbSymIndex }
                      shl     bx, 1
                      mov     bx, [bx+(OFFSET gdbSearchPwdOfsTable)-2]  { 2 = SizeOf(Word) }
            {$ELSE}
                      mov     di, 3                   { System.Sizeof(recSymInPassword) }
                      mov     ax, di                  { AH = 0 }
                      mov     al, gdbSymIndex
                      mov     cx, ax                  { CX = gdbSymIndex }
                      mov     bx, ax                  { BX = gdbSymIndex }
                      dec     bx                      { BX = gdbSymIndex - 1 }
                      mov     ax, bx
                      shl     bx, 1
                      add     bx, ax                  { BX = (gdbSymIndex-1)*3 }
                      add     bx, OFFSET gdbSearchPassword
            {$ENDIF} {UseFastestCode}

              @IncNextChar:
                      inc     byte ptr [bx]           { add 1 to dbCurValue }
                      jnz    @NextChar                { SPECIAL CASE:       }
                                                      { OVERFLOW through 255}

                      mov     dx, [bx+1]              { DL = dbMinSymValue }
                                                      { DH = dbMaxSymValue }
                      jmp    @IncNextSym

              @NextChar:
                      mov     al, [bx]                { AL = dbCurValue }
                      mov     dx, [bx+1]              { DL = dbMinSymValue }
                                                      { DH = dbMaxSymValue }
                      cmp     al, dh                  { Compare wit dbMaxSymValue }
                      ja     @IncNextSym

                      mov     ah, ch                  { CH = 0 }
                      mov     si, ax
                      or      ah, [si+(OFFSET gbCodesInUseTable)]
                      jz     @IncNextChar
                      jmp    @Done

              @IncNextSym:
                      mov     al, dl                  { AL = dbMinSymValue }
                      mov     [bx], al
                                                      { next recSymInPassword }
                      sub     bx, di                  { System.Sizeof(recSymInPassword) }

              @DecrPwd:
                      dec     cx
                      mov     gadbLastCharIndex, cl   { store index of last changed char }
                      jnz    @IncNextChar

                      dec     gdbSymIndex             { pwdlen decr by 1 }
                      jz     @Done                    { ZF = 1 character password! }

            {$IFDEF   UseFastestCode}
                      mov     di, 3                   { System.Sizeof(recSymInPassword) }
                      mov     cx, di                  { CH = 0 }
                      mov     cl, gdbSymIndex         { CX = gdbSymIndex }
                      mov     bx, cx                  { BX = gdbSymIndex }
                      shl     bx, 1
                      mov     bx, [bx+(OFFSET gdbSearchPwdOfsTable)-2]  { 2 = SizeOf(Word) }
            {$ELSE}
                      mov     ax, cx                  { CX = 0 }
                      mov     al, gdbSymIndex
                      mov     cx, ax                  { CX = gdbSymIndex }
                      mov     bx, ax                  { BX = gdbSymIndex }
                      dec     bx                      { BX = gdbSymIndex - 1 }
                      mov     ax, bx
                      shl     bx, 1
                      add     bx, ax                  { BX = (gdbSymIndex-1)*3 }
                      add     bx, OFFSET gdbSearchPassword
            {$ENDIF} {UseFastestCode}

                      jmp    @NextChar                { set the new pwd len }

              @Done:                                  { match password to use }

           end;
           {asm-end}
      {if-then}
    UNTIL (gbStatusOk) OR (gdbSymIndex < gadbMinPswdLen);
    {repeat-until}

  {* get system time *}
    WITH  grecLastTime  DO
      Dos.GetTime(dwHour,dwMinute,dwSecond,dwSec100);
    {with-do}

 {$IFDEF   MakeStatistic}
    IF  (gabFoundPwdStatisticsON)
        THEN  BEGIN
          System.WriteLn(gfStatOutStream);
          System.WriteLn(gfStatOutStream,' Number of possible pwd(s) = ',+gliFoundPwdCount);
          System.WriteLn(gfStatOutStream,' Number of searched pwd(s) = ',+gliSearchPwdCount);
              END;
    {if-then}
 {$ENDIF} {MakeStatistic}

    _CalcActualTime(grecInitTime,grecLastTime,grecWorkTime);
    System.WriteLn(asProgramPrompt+'Last   running time (HH:MM:SS:TT) = ',
                _fnsRunTime(grecWorkTime));
    _CalcActualTime(grecStartTime,grecLastTime,grecWorkTime);
    _AddTimeCount(grecTrueTime,grecWorkTime);
    System.WriteLn(asProgramPrompt+'Actual running time (HH:MM:SS:TT) = ',
                _fnsRunTime(grecTrueTime));
 {$IFDEF   MakeStatistic}
    IF  (gabFoundPwdStatisticsON)
        THEN  BEGIN
          gliTempVal := (_liTotalSecTens(grecTrueTime)+aHundrenthsPerSecHalf) DIV aHundrenthsPerSec;
          IF (gliTempVal = 0)
            THEN  gliTempVal := 1;
          {if-then}
          System.WriteLn(gfStatOutStream,' Average searched pwds/sec = ',
                         System.Longint(gliSearchPwdCount DIV gliTempVal));
          System.WriteLn(gfStatOutStream);
          System.WriteLn(gfStatOutStream);
          System.WriteLn(gfStatOutStream,' Actual running time (HH:MM:SS:TT) = ',
                                         _fnsRunTime(grecTrueTime));
              END;
    {if-then}
 {$ENDIF} {MakeStatistic}
    _CalcActualTime(grecEarlyTime,grecLastTime,grecWorkTime);
    System.WriteLn(asProgramPrompt+'Total  running time (HH:MM:SS:TT) = ',
                _fnsRunTime(grecWorkTime));
 {$IFDEF   MakeStatistic}
    IF  (gabFoundPwdStatisticsON)
        THEN  BEGIN
          System.WriteLn(gfStatOutStream,' Total  running time (HH:MM:SS:TT) = ',
                                         _fnsRunTime(grecWorkTime));
              END;
    {if-then}
 {$ENDIF} {MakeStatistic}


  {* display current or found password *}
     IF (gadbUserBreakOn) OR (NOT(gbStatusOk))
       THEN  gsTempInput := 'Current'
       ELSE  gsTempInput := 'Possible';
     {if-then-else}
     IF  ((gdbSymIndex < gadbMinPswdLen) OR  (gdbSymIndex = 0))
       THEN  BEGIN
          gdbSymIndex := gadbMinPswdLen;
          FOR  gdbTemp := aMinPswdVal  TO  gdbSymIndex  DO
            WITH  gdbSearchPassword[gdbTemp]  DO
              FOR  gdbIndex := dbMinSymValue  TO  dbMaxSymValue  DO
                IF  (gbCodesInUseTable[gdbIndex])
                  THEN  dbCurValue := gdbIndex;
              {if-then}
              {for-to-do}
            {with-do}
          {for-to-do}
             END;
     {if-then}
     System.WriteLn(asProgramPrompt+gsTempInput+' password is the following:');
     System.Write(asProgramPrompt+'Symbols ',aMinPswdVal,'-',gdbSymIndex,' = ');
     gsTempInput := '  (';
     FOR  gdbIndex :=  aMinPswdVal  TO  gdbSymIndex  DO
         WITH  gdbSearchPassword[gdbIndex]  DO
         BEGIN
             System.Write(achHexPrefix+_fnsByteToHexFmt(dbCurValue));
             IF  (System.Char(dbCurValue) IN  setDisplayCodesOfASCII)
               THEN  gsTempInput := gsTempInput + System.Char(dbCurValue)
               ELSE  gsTempInput := gsTempInput + achPoint;
             {if-then-else}
         END;
         {with-do}
     {for-to-do}
     System.WriteLn(gsTempInput+')');

  {* write a new user password file if it's need *}
    System.Write(asProgramPrompt+'Write a current password to file? (N/Y): ');
    IF (gabBatchModeOn)
       THEN BEGIN
           gsTempInput := aYes;
           System.WriteLn(aYes);
             END
       ELSE  BEGIN 
           System.ReadLn(gsTempInput);
             END;
    {if-then-else}
    IF (gsTempInput <> asBlank) AND (System.Upcase(_fnchGetFirstChar(gsTempInput)) = aYes)
      THEN  BEGIN
        System.Write(asProgramPrompt+'Enter password filename (def.ext.='+
                      asDefPwdExt+'): ');
    IF (gabBatchModeOn)
       THEN  BEGIN
           gasPwdFileName := asDefPwdFileName;
           System.WriteLn(gasPwdFileName);
             END
       ELSE  BEGIN
           System.ReadLn(gasPwdFileName);
             END;
    {if-then-else}
        gasPwdFileName := _fnsAddDefExt(gasPwdFileName,asDefPwdExt);
        gasPwdFileName := _fnsUpcaseStr(gasPwdFileName);
        {$IFDEF   DebugVersion}
            System.WriteLn(asProgramPrompt+'Password file: '+gasPwdFileName);
        {$ENDIF} {DebugVersion}
        System.WriteLn(asProgramPrompt+'Write new user password file.');
        System.Assign(gfUserPwdInStream,gasPwdFileName);
        {$I-} System.Rewrite(gfUserPwdInStream,1); {$I+}
        IF  (System.IoResult <> 0)
          THEN  BEGIN
             System.WriteLn(asProgramPrompt+'Unable to create an exit password file.');
             System.Halt(errBadCreatePasswordFile);
               END;
        {if-then}
        gdwByteCount := _fndwLowWord(System.Sizeof(recSymInPassword)*(gdbSymIndex));
        {$I-} System.BlockWrite(gfUserPwdInStream,gdbSearchPassword,gdwByteCount,gdwResCount); {$I+}
        IF (gdwResCount <> gdwByteCount)
          THEN BEGIN
            System.WriteLn(asProgramPrompt+'Unable to write an exit password file.');
            System.Halt(errWritePwdFile);
               END;
        {if-then}
        System.Close(gfUserPwdInStream);
            END;
    {if-then}


  {* close a found password file *}
    IF  (gabUseFileToWritePwd)
      THEN  System.Close(gfFoundPwdOutStream);
    {if-then}


  {* free memory pool to operating system *}
    IF (gadbMaxPswdLen > 1)
     THEN  BEGIN
      System.WriteLn(asProgramPrompt+'Free the memory to the DOS.');
     {$IFDEF   UseFastestCode}
        _DeAllocDosMem(gdwKeyZeroSeg);
     {$ELSE}
        _DeAllocDosMem(gdwKeyZeroSeg);
        _DeAllocDosMem(gdwKeyOneSeg);
        _DeAllocDosMem(gdwKeyTwoSeg);
     {$ENDIF} {UseFastestCode}
     {$IFDEF   UseMoreStaticKeysForSecondSymbol}
       {$IFDEF   UseFastestCode}
         _DeAllocDosMem(gdwKeyZeroSegSym2);
       {$ELSE}
         _DeAllocDosMem(gdwKeyZeroSegSym2);
         _DeAllocDosMem(gdwKeyOneSegSym2);
         _DeAllocDosMem(gdwKeyTwoSegSym2);
       {$ENDIF} {UseFastestCode}
     {$ENDIF} {UseMoreStaticKeysForSecondSymbol}
           END;
    {if-then}


{$IFDEF   AutomaticSearchTruePassword}
   {* running the auto password detection process *}
      IF  (gabAutoSearchTruePwdON)
        THEN  BEGIN
          System.WriteLn(asProgramPrompt+'Find a true password from all possible found.');
          IF (gasFoundPwdFileName <> asBlank)
            THEN BEGIN
              System.WriteLn(asProgramPrompt+'Open the user found password file.');
              System.Assign(gfFoundPwdOutStream,gasFoundPwdFileName);
              {$I-} System.Reset(gfFoundPwdOutStream); {$I+}
              IF  (System.IoResult <> 0)
                THEN  BEGIN
                   System.WriteLn(asProgramPrompt+'Unable to open a found password file.');
                   System.Halt(errBadFoundPwdFilename);
                      END
                 END
            ELSE  BEGIN
                   System.WriteLn(asProgramPrompt+'Empty found password file.');
                   System.Halt(errEmptyFoundPwdFilename);
                  END;
           {if-then-else}
          System.WriteLn(asProgramPrompt+'Search for a true password.');
          gbStatusOk := System.False;

          System.Assign(gfNulDeviceStream,asNulDevice);
          System.Reset(gfNulDeviceStream);

          gdwNulDevHandle := grecNulDeviceDesc.Handle;
          asm
                 mov     bx, adwDosStdOutStream     { duplicate handle    }
                 mov     ah, 45h                    { "DUP" function      }
                 int     21h                        { MsDos service       }
                 mov     gdwConDevHandle, ax        { save a new handle   }

                 mov     cx, adwDosStdOutStream     { forced handle       }
                 mov     bx, gdwNulDevHandle        { to what handle      }
                 mov     ah, 46h                    { "ForceDup" function }
                 int     21h                        {  MsDos service      }
          end;
          {asm-end}

          gdwProcessCode := errTerminateOK;
          IF (gadbDefaultPkUnzipInUse)
             THEN  gasPkUnzipPath := gasPkUnzipPath + +asPkUnzipName;
          {if-then}

          WHILE  (NOT(System.Eof(gfFoundPwdOutStream)) AND
                  NOT(gbStatusOk)) DO
          BEGIN
              System.ReadLn(gfFoundPwdOutStream,gsTempInput);
              gsDosParmLine := gasRunPkUnzipCommand+
                               gsTempInput+
                               achBlank+
                               gasZipFileName+
                               achBlank+
                               gasEncryptedFileName;
	      Dos.SwapVectors;
              Dos.Exec(gasPkUnzipPath,gsDosParmLine);
	      Dos.SwapVectors;
              gdwProcessCode := Dos.DosExitCode;
              IF  (gdwProcessCode = errTerminateOK)
                THEN  BEGIN
                   gasTruePassword := gsTempInput;
                   gbStatusOk := System.True;
                      END;
              {if-then}
              gdwProcessCode := Dos.DosError;
              IF (Dos.DosError <>  errTerminateOK)
                THEN BEGIN
                   gbStatusOk := System.True;
                   gasTruePassword := asBlank;
                     END;
              {if-then}
          END;
          {while-do}


          System.Close(gfNulDeviceStream);
          asm
                 mov     cx, adwDosStdOutStream     { forced handle       }
                 mov     bx, gdwConDevHandle        { to what handle      }
                 mov     ah, 46h                    { "ForceDup" function }
                 int     21h                        {  MsDos service      }
          end;
          {asm-end}

          System.Close(gfFoundPwdOutStream);

          IF  (gasTruePassword <> asBlank)
            THEN  BEGIN
               System.Write(asProgramPrompt+'True password: ');
               gsTempInput := asBlank;
               gsSavePwd := '  (';
               FOR  gdbIndex :=  aMinPswdVal  TO  System.Length(gasTruePassword)  DO
               BEGIN
                   gchTemp := gasTruePassword[gdbIndex];
                   gsTempInput := gsTempInput +
                                  achHexPrefix+
                                  _fnsByteToHexFmt(System.Byte(gchTemp));
                   IF  NOT(gchTemp IN setDisplayCodesOfASCII)
                      THEN  gchTemp := achPoint;
                   {if-then}
                   gsSavePwd := gsSavePwd + gchTemp;
               END;
               {for-to-do}
               gsTempInput := gsTempInput + gsSavePwd + ')';
               System.WriteLn(gsTempInput);
               {$IFDEF   MakeStatistic}
                  IF  (gabFoundPwdStatisticsON)
                      THEN  BEGIN
                        System.WriteLn(gfStatOutStream);
                        System.WriteLn(gfStatOutStream);
                        System.WriteLn(gfStatOutStream,' '+asPkUnzipName+' reports the true password: ');
                        System.WriteLn(gfStatOutStream,'   '+gsTempInput);
                            END;
                  {if-then}
               {$ENDIF} {MakeStatistic}

                  END
            ELSE  BEGIN
              IF  (gdwProcessCode = errTerminateOK)
                THEN  BEGIN
                  IF  (gliFoundPwdCount <> 0)
                    THEN  BEGIN
                      System.WriteLn(asProgramPrompt+'Sorry, all possible found password(s) are wrong.');
                      System.WriteLn(asProgramPrompt+'Try another character map or password length.');
                          END
                    ELSE
                      System.WriteLn(asProgramPrompt+'Sorry, no found password(s).');
                  {if-then-else}
                      END
                ELSE  BEGIN
                    System.WriteLn(asProgramPrompt+'DOS error occurred. Return code: ',gdwProcessCode);
                      END;
              {if-then-else}
                  END;
          {if-then-else}
              END;
      {if-then}
{$ENDIF} {AutomaticSearchTruePassword}

 {$IFDEF   MakeStatistic}
    IF  (gabFoundPwdStatisticsON)
        THEN  BEGIN
          System.Close(gfStatOutStream);
              END;
    {if-then}
 {$ENDIF} {MakeStatistic}

{$IFDEF   AutomaticGenerationTestsForTruePassword}
    {* create the user test batch file*}
      IF (gabDoTestBatchFile)
        THEN BEGIN
          System.WriteLn(asProgramPrompt+'Create an user test batch file.');
          System.Assign(gfBatchOutStream,gasTestBatchFileName);
          System.SetTextBuf(gfBatchOutStream,gdbLargeStatPwdBuf);
          {$I-} System.Rewrite(gfBatchOutStream); {$I+}
          IF  (System.IoResult <> 0)
            THEN  BEGIN
               System.WriteLn(asProgramPrompt+'Unable to create a test batch file.');
               System.Halt(errBadTestBatchFilename);
                 END;
          {if-then}
          IF (gasFoundPwdFileName <> asBlank)
            THEN BEGIN
              System.WriteLn(asProgramPrompt+'Open an user found password file.');
              System.Assign(gfFoundPwdOutStream,gasFoundPwdFileName);
              {$I-} System.Reset(gfFoundPwdOutStream); {$I+}
              IF  (System.IoResult <> 0)
                THEN  BEGIN
                   System.WriteLn(asProgramPrompt+'Unable to open a found password file.');
                   System.Halt(errBadFoundPwdFilename);
                      END
                 END
            ELSE  BEGIN
                   System.WriteLn(asProgramPrompt+'Empty found password file.');
                   System.Halt(errEmptyFoundPwdFilename);
                  END;
           {if-then-else}
          System.WriteLn(asProgramPrompt+'Write a test batch file.');
          System.WriteLn(gfBatchOutStream,'@ECHO OFF');
          System.WriteLn(gfBatchOutStream,'@ECHO Testing of Found Pwd(s) Batch File');
          System.WriteLn(gfBatchOutStream,'@ECHO '+'Created by '+asProgram+' utility, '
                                          +asCopyright+'  '+asAuthor);
          System.WriteLn(gfBatchOutStream,'@ECHO Press any key to heavy running');
          System.WriteLn(gfBatchOutStream,'@PAUSE '+achReDirectedOutput+asNulDevice);
          System.WriteLn(gfBatchOutStream,'@ECHO ON');
          WHILE  NOT(System.Eof(gfFoundPwdOutStream)) DO
          BEGIN
              System.ReadLn(gfFoundPwdOutStream,gsTempInput);
              System.WriteLn(gfBatchOutStream,asPkUnzipName+
                                              achBlank+
                                              gasRunPkUnzipCommand+
                                              gsTempInput+
                                              achBlank+
                                              gasZipFileName+
                                              achBlank+
                                              gasEncryptedFileName+
                                              achReDirectedOutput+asNulDevice);
              System.WriteLn(gfBatchOutStream,'@IF NOT ERRORLEVEL 1 GOTO FOUND');
          END;
          {while-do}
          System.WriteLn(gfBatchOutStream,'@ECHO OFF');
          System.WriteLn(gfBatchOutStream,'ECHO *** NO MATCH password(s), try again PWDZIP with another character map ***');
          System.WriteLn(gfBatchOutStream,'GOTO DONE');
          System.WriteLn(gfBatchOutStream,':FOUND');
          System.WriteLn(gfBatchOutStream,'@ECHO OFF');
          System.WriteLn(gfBatchOutStream,'ECHO **** THIS password IS match (LOOK HERE, GUY!) ****');
          System.WriteLn(gfBatchOutStream,':DONE');
          System.WriteLn(asProgramPrompt+'Writing complete.');
          System.Close(gfBatchOutStream);
             END;
      {if-then}
{$ENDIF} {AutomaticGenerationTestsForTruePassword}


  {* final report *}
    System.WriteLn(asProgramPrompt+'Done.');

  {* System.Halt(errTerminateOk); *}
END.
