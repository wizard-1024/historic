{****************************************************************************
//                            File OPTEXE.PAS
//
//                 Simplest DOS executables optimizer
//
//      Copyright (c) 1993, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/OPTEXE/RCS/optexe.pas $
//  $RCSfile: optexe.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:56:09 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: optexe.pas $
//      Revision 1.1  1998/10/03 14:56:09  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                OPTIMIZE_EXE_FILE                               }
{ FILE NAME             OPTEXE.PAS                                      }
{ PURPOSE               Optimize the time execution for the DOS execu-  }
{                       table files.                                    }
{ VERSION               1.13                                            }
{ DATE                  02-Sep-1997                                     }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Telephone: +007 (095) 944-6304                  }
{ INTERNET              wizard@radio-msu.net, dima@mccbn.ru             }
{ COPYRIGHT NOTICE      Copyright (C) 1993, 1997  Dmitry Stefankov      }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,           }
{                       NOT FOR COMMERCIAL PURPOSE                      }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 6.0                        }
{                       (Borland International Inc.) or compatible      }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             <infile>   -  input  stream                     }
{                       <outfile>  -  output stream                     }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               This program uses simple optimization method:   }
{                       If image size < 64K then all intersegment calls }
{                       are replaced to intrasegment calls.             }
{                       The following table is displayed the time execu-}
{                       tion taken from the standard INTEL data sheets: }
{                             <Instr/Clocks/Processor>                  }
{                                        8086 80186 80286 80386 80486   }
{                            NOP          3     3     3     3     1     }
{                            PUSH CS     10     9     3     2     3     }
{                            NEAR CALL   19    15     7    7+m    3     }
{                              TOTAL     32    27    13   12+m    7     }
{                            FAR CALL    28    23    13   17+m    18+   }
{                         optimization   bad    bad   none good   good  }
{           WARNING!! Most files, compiled under Turbo Pascal,    !!    }
{           WARNING!! Microsoft-C, Borland-C, etc may be not work !!    }
{           WARNING!! after this optimization. Why? Don't ask me. !!    }
{ DESCRIPTION           1. Read input stream                            }
{                       2. Search relocation and memory image to opti-  }
{                       mize code                                       }
{                       3. Write output stream                          }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   02-Jul-93  DS  initilal release          }
{                       1.01   04-Jul-93  DS  fixed a bug with EXE-file }
{                                             detection                 }
{                       1.10   20-Sep-93  DS  some style updates        }
{                       1.11   26-Jul-97  DS  updated documentation     }
{                       1.12   02-Aug-97  DS  removed tabs              }
{                       1.13   02-Sep-97  DS  fixed open r/o file bug   }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   OptimizeProgramTime;


{*** other modules ***}
USES
  ShowTErr;


{** switches for compilation **}
{$S-}                   {*  stack checking        *}
{$R-}                   {*  range checking        *}
{$M 2048,0,0}           {*  stack/heapmin/heapmax *}


{*========================== CONSTANTS PART ============================*}

CONST
     asPurpose                  =       'EXE-File Optimizer';
     asVersion                  =       '1.13';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1993, 1997';
     asProgram                  =       'OptExe';
     asProgramPrompt            =       'OptExe'+': ';
     asProgramU                 =       'OPTEXE';

     { exit codes }
     errTerminateOK             =     0;
     errBadParmsNumber          =     1;
     errSourceNotFound          =     2;
     errDestDontWrite           =     3;
     errSrcOpenFailed           =     4;
     errDestCreateFailed        =     5;
     errSrcTooBig               =     6;
     errSrcRead                 =     7;
     errDestWrite               =     8;
     errNotEnoughMemory         =     9;
     errSrcNotValidEXE          =    10;
     errEmptyRelocTable         =    11;
     errBadRelocTableOfs        =    12;
     errBadElementTableOfs      =    13;
     errBadNearCallOfs          =    14;
     errNoOptimizedElements     =    15;
     errBadMemoryDealloc        =    16;


     achNULL                    =     #0;

     achYes                     =     'Y';
     achNo                      =     'N';

     achHexPrefix               =     '$';
     achDosExtMark              =     '.';
     asInDefExt                 =     'exe';
     asOutDefExt                =     'exe';

     aHexRadix                  =     16;
     aBytesPer64K               =     65536;
     aBytesPerPara              =     16;
     aParasPer64K               =     aBytesPer64K div aBytesPerPara;

     adwExeDosFileID_1          =     $4D5A;            { 'MZ' }
     adwExeDosFileID_2          =     $5A4D;            { 'ZM' }
     adwOptimizedFileID         =     $5344;            { 'DS' }

     adwExeFileID_Ofs           =     $00;
     adwExeFileRelCount_Ofs     =     $06;
     adwExeFileHeaderSize_Ofs   =     $08;
     adwExeFileRelTable_Ofs     =     $18;
     adwExeFileRelTableStart_Ofs=     $1C;
     adwExeFileCheckSum_Ofs     =     $12;


     adbFarCallOpcode           =     $9A;
     adbNopOpcode               =     $90;
     adbPushCSOpcode            =     $0E;
     adbNearCallOpcode          =     $E8;


{*====================== TYPED CONSTANTS PART ==========================*}

CONST

    setHexChars  :    SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];


{*=========================== VARIABLES PART ===========================*}

VAR

   gfInputStream    :   FILE;
   gsInFileName     :   STRING[80];

   gfOutputStream   :   FILE;
   gsOutFileName    :   STRING[80];

   gddByteCount     :   System.Longint;
   gddTemp          :   System.Longint;

   gdwMemBlockSize  :   System.Word;
   gdwBytesRead     :   System.Word;
   gdwMemoryBlock   :   System.Word;
   gdwOffsetInBuf   :   System.Word;
   gdwRelEntries    :   System.Word;
   gdwRelocTableOfs :   System.Word;
   gdwImageStart    :   System.Word;
   gdwElementOfs    :   System.Word;
   gdwElementSeg    :   System.Word;
   gdwImageOfs      :   System.Word;
   gdwFarCallOfs    :   System.Word;
   gdwFarCallSeg    :   System.Word;
   gdwNewCallOfs    :   System.Word;
   gdwTemp          :   System.Word;

   gdwOldRelCount   :   System.Word;
   gdwNewRelCount   :   System.Word;
   gdwNewRelTablOfs :   System.Word;
   gdwFirstFreeOfs  :   System.Word;

   giErrorCode      :   System.Integer;

   gsTempInput      :   STRING;
   gchInUser        :   System.Char;
   gdbOpCode        :   System.Byte;



{*=========================== FUNCTIONAL PART ==========================*}

FUNCTION  _fnbFileExist(VAR fStruc : FILE; sFileName : STRING) : System.Boolean;
{* Check that file exits. *}
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
END; { _fnbFileExist }


FUNCTION  _fnsForceFileNameExt(sFileName, sDefExt : STRING) : STRING;
{* Add extension for filename if not present. *}
BEGIN
   IF (System.Pos(achDosExtMark,sFileName) = 0)
     THEN  sFileName := sFileName + achDosExtMark + sDefExt;
   {if-then}
  _fnsForceFileNameExt := sFileName;
END;
{ _fnsForceFileNameExt }


FUNCTION  _fnsUpcaseStr(sInput : STRING) : STRING;
{* Make all uppercase. *}
VAR
  dbIndex  :  System.BYTE;
  dbCount  :  System.BYTE;

BEGIN
  dbCount := System.Length(sInput);

  IF (dbCount <> 0)  THEN
    FOR dbIndex :=  1  TO  dbCount DO
      sInput[dbIndex] := System.Upcase(sInput[dbIndex]);
    {for-to-do}
  {if-then}

   _fnsUpcaseStr := sInput;
END; { _fnsUpcaseStr }



FUNCTION   _fnchGetFirstChar(sInput : STRING) : System.Char;
{* Returns a first char from string. *}
VAR
  chTemp  :  System.Char;

BEGIN
   IF (System.Length(sInput) <> 0)
     THEN  chTemp := sInput[1]
     ELSE  chTemp := achNULL;
   {if-then-else}
  _fnchGetFirstChar := chTemp;
END;
{ _fnchGetFirstChar }


FUNCTION  _fndwGetByteFromBuf(dwBufOfs : System.Word) : System.Byte;
{* Returns a byte from the file buffer. *}
BEGIN
   _fndwGetByteFromBuf := System.Mem[gdwMemoryBlock:dwBufOfs];
END;
{ _fndwGetByteFromBuf }



FUNCTION  _fndwGetWordFromBuf(dwBufOfs : System.Word) : System.Word;
{* Returns a word from the file buffer. *}
BEGIN
   _fndwGetWordFromBuf := System.MemW[gdwMemoryBlock:dwBufOfs];
END;
{ _fndwGetWordFromBuf }


{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+'  Version '+asVersion+',  '+asCopyright+'  '+asAuthor);
END;  { _CopyrightDisplay }


PROCEDURE _PutByteToBuf(dwBufOfs : System.Word; dbNewValue : System.Byte);
{* Writes a byte to the file buffer. *}
BEGIN
   System.Mem[gdwMemoryBlock:dwBufOfs] := dbNewValue;
END;
{ _PutByteToBuf }


PROCEDURE  _PutWordToBuf(dwBufOfs, dbNewValue : System.Word);
{* Writes a word to the file buffer. *}
BEGIN
   System.MemW[gdwMemoryBlock:dwBufOfs] := dbNewValue;
END;
{ _PutWordToBuf }



PROCEDURE  _DosAllocMem(VAR dwDosMemSeg : System.Word; dwParas : System.Word);
{* Allocates a memory block through the DOS service. *}
VAR
  bFuncFail  :   System.Boolean;

BEGIN
  asm
      mov       bFuncFail, System.False         { assume no fails   }
      mov       bx, dwParas                     { # of bytes * 16   }
      mov       ah, 48h                         { Dos func number   }
      int       21h                             { call DOS service  }
      jnc      @AllocDone                       { check for error   }
      mov       bFuncFail, System.True          { Yes: err occurred }
      jmp      @Done
   @AllocDone:
      les      di, dwDosMemSeg                  { access to TP var  }
      mov      es:[di], ax                      { store a value     }
   @Done:
  end;
  {asm-end}
  IF  (bFuncFail)
    THEN  BEGIN
        System.WriteLn(asProgramPrompt+'Insufficient memory.');
        System.Halt(errNotEnoughMemory);
          END
  {if-then}
END;
{  _DosAllocMem }


PROCEDURE  _DosDeAllocMem(dwDosMemSeg : System.Word);
{* Deallocates a memory block through the DOS service. *}
VAR
  bFuncFail  :   System.Boolean;

BEGIN
  asm
      mov       bFuncFail, System.False         { assume no fails   }
      mov       es, dwDosMemSeg                 { seg of mem block  }
      mov       ah, 49h                         { Dos func number   }
      int       21h                             { call DOS service  }
      jnc      @Done                            { check for error   }
      mov       bFuncFail, System.True          { Yes: err occurred }
   @Done:
  end;
  {asm-end}
  IF  (bFuncFail)
    THEN  BEGIN
        System.WriteLn(asProgramPrompt+'Deallocation of memory failed.');
        System.Halt(errBadMemoryDealloc);
          END
  {if-then}
END;
{  _DosDeAllocMem }



{*============================== MAIN PART =============================*}

BEGIN
  _CopyrightDisplay;

     IF (System.ParamCount <> 2) THEN
     BEGIN
          System.WriteLn(asProgramPrompt+'  screen help for you.');
          System.WriteLn('Usage: infile outfile');
          System.WriteLn('  infile   -  source filename      (def. ext. = '+asInDefExt+')');
          System.WriteLn('  outfile  -  destination filename (def. ext. = '+asOutDefExt+')');
          System.Halt(errBadParmsNumber);
     END; { if }


  {** copy the parameters from command line **}
  gsInFileName := _fnsForceFileNameExt(System.ParamStr(1),asInDefExt);
  gsInFileName  := _fnsUpcaseStr(gsInFileName);

  gsOutFileName := _fnsForceFileNameExt(System.ParamStr(2),asOutDefExt);
  gsOutFileName := _fnsUpcaseStr(gsOutFileName);


  {** source file exists? **}
  IF  NOT(_fnbFileExist(gfInputStream,gsInFileName)) THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to open file '+gsInFileName);
    System.Halt(errSourceNotFound);
  END;
  {if-then}


  {** destination file present? **}
  IF (_fnbFileExist(gfOutputStream,gsOutFileName)) THEN
  BEGIN
    System.Write(asProgramPrompt+'Output file '+gsOutFileName+
                 ' already exists. Overwrite? (n/y): ');
    System.ReadLn(gsTempInput);
    IF (System.UpCase(_fnchGetFirstChar(gsTempInput)) <> achYes)
      THEN  System.Halt(errDestDontWrite);
    {if-then}
  END;
  {if-then}


  {** open the source file **}
  System.FileMode := $20;   {read, deny write on share}
  System.Assign(gfInputStream,gsInFileName);
  {$I-}
  System.Reset(gfInputStream,1);
  {$I+}

  IF  (System.IoResult <> 0) THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to open '+gsInFileName);
    System.Halt(errSrcOpenFailed);
  END;
  {if-then}


 {** check for size < 64K }
  gddByteCount := System.FileSize(gfInputStream);
  IF (gddByteCount > aBytesPer64K)
    THEN BEGIN
      System.WriteLn(asProgramPrompt+'Input file size more than 64K.');
      System.Halt(errSrcTooBig);
         END;
  {if-then}


  {** get memory from DOS **}
  _DosAllocMem(gdwMemoryBlock,aParasPer64K);


  {** transfer input file to memory buffer (all file!) **}
   System.WriteLn(asProgramPrompt+'Source reading...');
   System. BlockRead(gfInputStream,
                    System.Mem[gdwMemoryBlock:0],
                    gddByteCount,
                    gdwBytesRead);
   IF (gddByteCount <> gdwBytesRead)
     THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Reading error.');
         System.Halt(errSrcRead);
           END;
   {if-then}


  {** close input file **}
  System.Close(gfInputStream);


  {** check for executable file **}
   gdwOffsetInBuf := adwExeFileID_Ofs;
   gdwTemp := _fndwGetWordFromBuf(gdwOffsetInBuf);
   IF  (NOT(gdwTemp = adwExeDosFileID_1) AND 
       NOT(gdwTemp = adwExeDosFileID_2))
     THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Not valid EXE-image.');
         System.Halt(errSrcNotValidEXE);
           END;
   {if-then}


  {** check for presence of relocation table **}
   gdwOffsetInBuf := adwExeFileRelCount_Ofs;
   gdwRelEntries := _fndwGetWordFromBuf(gdwOffsetInBuf);
   IF  (gdwRelEntries = 0)
     THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Empty relocation table.');
         System.Halt(errEmptyRelocTable);
           END;
   {if-then}


  {** check for presence of relocation table **}
   gdwOffsetInBuf := adwExeFileRelTable_Ofs;
   gdwRelocTableOfs := _fndwGetWordFromBuf(gdwOffsetInBuf);
   IF  (gdwRelocTableOfs < adwExeFileRelTableStart_Ofs)
     THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Invalid relocation table offset.');
         System.Halt(errBadRelocTableOfs);
           END;
   {if-then}

  
  {** main optimization loop **}
    gdwOffsetInBuf := adwExeFileHeaderSize_Ofs;
    gdwImageStart := _fndwGetWordFromBuf(gdwOffsetInBuf) * aBytesPerPara;
    gdwNewRelCount   := 0;
    gdwNewRelTablOfs := gdwRelocTableOfs;
    gdwFirstFreeOfs := gdwNewRelTablOfs;
    gdwOldRelCount := gdwRelEntries;

    System.WriteLn(asProgramPrompt+'Search relocation table to optimize.');
    WHILE (gdwRelEntries <> 0)  DO
    BEGIN
         gdwOffsetInBuf := gdwRelocTableOfs;
         gdwElementOfs := _fndwGetWordFromBuf(gdwOffsetInBuf);
         gdwElementSeg := _fndwGetWordFromBuf(gdwOffsetInBuf+2);

         gddTemp := (System.Longint(gdwElementSeg) * aBytesPerPara) + gdwElementOfs;
         IF  (gddTemp >= aBytesPer64K)
           THEN  BEGIN
              System.WriteLn(asProgramPrompt+'Relocation element offset more than 64K.');
              System.Halt(errBadElementTableOfs);
                 END;
         {if-then}

         gdwImageOfs := System.Word(gddTemp)+gdwImageStart;
         gdwTemp := gdwImageOfs - 3;
         gdbOpCode := _fndwGetWordFromBuf(gdwTemp+0);
         gdwFarCallOfs := _fndwGetWordFromBuf(gdwTemp+1);
         gdwFarCallSeg := _fndwGetWordFromBuf(gdwTemp+3);

         IF  (gdbOpCode = adbFarCallOpcode)
           THEN  BEGIN
               gddTemp := (System.Longint(gdwFarCallSeg) * aBytesPerPara) + gdwFarCallOfs;
               IF  (gddTemp >= aBytesPer64K)
                 THEN  BEGIN
                    System.WriteLn(asProgramPrompt+'Offset for NEAR CALL not within 64K.');
                    System.Halt(errBadNearCallOfs);
                       END;
               {if-then}
               gdwNewCallOfs := System.Word(gddTemp) - (gdwImageOfs + 2) + gdwImageStart;
               _PutByteToBuf(gdwTemp+0,adbNopOpcode);
               _PutByteToBuf(gdwTemp+1,adbPushCSOpcode);
               _PutByteToBuf(gdwTemp+2,adbNearCallOpcode);
               _PutWordToBuf(gdwTemp+3,gdwNewCallOfs);
               _PutWordToBuf(gdwOffsetInBuf+0,$0);      { wipe entry }
               _PutWordToBuf(gdwOffsetInBuf+2,$0);
                 END
           ELSE  BEGIN
               _PutWordToBuf(gdwFirstFreeOfs+0,gdwElementOfs);
               _PutWordToBuf(gdwFirstFreeOfs+2,gdwElementSeg);
               System.Inc(gdwNewRelCount);
               System.Inc(gdwFirstFreeOfs,4);
                 END;
         {if-then-else}

         System.Dec(gdwRelEntries);
         System.Inc(gdwRelocTableOfs,4)
    END;
    {while-do}


  {** check if optimization had occurred **}
    IF (gdwOldRelCount = gdwNewRelCount)
      THEN BEGIN
         System.WriteLn(asProgramPrompt+'No elements to optimize.');
         System.Halt(errNoOptimizedElements);
           END
      ELSE BEGIN
         _PutWordToBuf(adwExeFileRelCount_Ofs,gdwNewRelCount);
         _PutWordToBuf(adwExeFileCheckSum_Ofs,adwOptimizedFileID);
          System.WriteLn(asProgramPrompt+'Total relocation table entries = ',gdwOldRelCount);
          System.WriteLn(asProgramPrompt+'Opt.  relocation table entries = ',gdwOldRelCount-gdwNewRelCount);
           END;
    {if-then-else}


  {** create the destination file **}
  System.FileMode := 2; {read/write, compatibilty mode}
  System.Assign(gfOutputStream,gsOutFileName);
  {$I-}
  System.Rewrite(gfOutputStream,1);
  {$I+}
  IF  (System.IoResult <> 0) THEN
  BEGIN
    System.WriteLn(asProgramPrompt+'Unable to create '+gsOutFileName);
    System.Halt(errDestCreateFailed);
  END;
  {if-then}


  {** copy modified source to destination **}
   System.WriteLn(asProgramPrompt+'Target writing...');
   System.BlockWrite(gfOutputStream,
                    System.Mem[gdwMemoryBlock:0],
                     gddByteCount,
                     gdwBytesRead);
   IF (gddByteCount <> gdwBytesRead)
     THEN  BEGIN
         System.WriteLn(asProgramPrompt+'Reading error.');
         System.Halt(errDestWrite);
           END;
   {if-then}


  {** free memory back to DOS **}
  _DosDeAllocMem(gdwMemoryBlock);


  {** close output file **}
  System.Close(gfOutputStream);


  {** report all done **}
  System.WriteLn(asProgramPrompt+'Done.');

  {* System.Halt(errTerminateOk); *}
END.

