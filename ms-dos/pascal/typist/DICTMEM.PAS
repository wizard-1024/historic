{****************************************************************************
//                            File DICTMEM.PAS
//
//                  Memory dictionary processing module
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/dictmem.pas $
//  $RCSfile: dictmem.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:53:36 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: dictmem.pas $
//      Revision 1.1  1999/01/03 17:53:36  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             DICTMEM.PAS                                     }
{ PURPOSE               Build and dump dictionary into memory.          }
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
{                       DOS.TPU        (DOS functions and procedures)   }
{                       GLOBALS.TPU    (global public definitions)      }
{                       STRLIB.TPU     (strings support library)        }
{                       VIDEO.TPU      (user screen interface)          }
{                       CALLBACK.TPU   (multiplex interface)            }
{                       Project Maintence Files                         }
{                       TYPIST.MAK        (auto compiling & linking)    }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       0.01   13-Sep-94  DS  initial release           }
{-----------------------------------------------------------------------}



UNIT
     DictMem;


INTERFACE

USES
    Dos,
    Globals,
    StrLib,
    Video,
    CallBack;


PROCEDURE   _DoStatDiagDump;
PROCEDURE   _DoEnvDiagDump;



IMPLEMENTATION


PROCEDURE
         _DoFarCallBack; near; ASSEMBLER;
{*
Description.
     Does call of stored routine offset.
     Enter:  SI = index to call
*}
ASM
      call      DWORD PTR  ds:[Globals.glpFarCallManager]
END; {asm-end}
{ _DoFarCallBack }



{*STATDUMP.INC*}

PROCEDURE
         _DoStatDiagDump;
{*
Description.
      Dumps all the available statistics to a disk in the current directory.
*}
CONST
  dwDumpStatFileExt  :  System.Word = 0;
VAR
  fTextStream        :  System.Text;
  pCurEnv            :  Globals.lprecEnvironmentDesc;
  dwEntriesCount,
  dwCurEnvHandleNum  :  System.Word;
  pSearchLinkTable   :  Globals.lpDWTable256;
  sTemp              :  STRING;
  lpNode             :  Globals.lprecDictEntryHeaderDesc;
  dwLinkOfs,
  dwCurTableSpaceSeg,
  dwTempCount,
  dwTempOfs,
  dwMaxStrLen,
  dwCurEnvOptions    :  System.Word;
  dbCharIndex,
  dbStrIndex,
  dbCount,
  dbTemp,
  dbTempCount        :  System.Byte;
  chTemp             :  System.Char;

BEGIN
    Video._OutputMessage(Messages._fnsTextMessageByIndex(202),
                         System.True);
    dwCurEnvHandleNum := CallBack._fndwGetCurEnv;
    IF  (dwCurEnvHandleNum = 0)
      THEN  BEGIN
           Video._HaltProgram(Messages._fnsTextMessageByIndex(297),
                              Globals.errCurrentEnviromentNotFound);
            END;
    {if-then}
    System.Assign(fTextStream,StrLib._fnsGetNewFileName(dwDumpStatFileExt,'USERSTAT'));
    System.Rewrite(fTextStream);
    System.WriteLn(fTextStream,'<<< '+Messages._fnsTextMessageByIndex(203)+' >>>');
    System.WriteLn(fTextStream,'<<< ('+Messages._fnsTextMessageByIndex(40)+') >>>');
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(94)+' = ',dwCurEnvHandleNum);
    System.WriteLn(fTextStream);
    pCurEnv := CallBack._fnlpGetCurEnvSettings;
{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(204),
                                        aModuleTypist);
    {if-then}
{$ENDIF} {DebVer}
    WITH  (pCurEnv^)  DO
    BEGIN
      System.WriteLn(fTextStream,'------ '+Messages._fnsTextMessageByIndex(184)+' ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(185),'"',sDictName16,'"');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(186),'"',sDictComment32,'"');
      System.WriteLn(fTextStream);
    END;
    {with-do}
{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(160),
                                        aModuleTypist);
    {if-then}
{$ENDIF} {DebVer}
    System.WriteLn(fTextStream,'------ '+Messages._fnsTextMessageByIndex(205)+' ------');
    dwEntriesCount := 0;
    pSearchLinkTable := pCurEnv^.pForwardSearchAbbrevTable;
    dwCurEnvOptions := pCurEnv^.dwUserEnvOptions;
    dwCurTableSpaceSeg := System.Seg(pSearchLinkTable^);
    dwMaxStrLen := System.Length(Messages._fnsTextMessageByIndex(132)+'  =  ');
    FOR  dbCharIndex :=  Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
    BEGIN
       ASM
           les      bx, pSearchLinkTable
           mov      al, dbCharIndex
           mov      dx, dwCurEnvOptions
           mov      si, Globals.aGetTableOffsetByIndex
           call     _DoFarCallBack
           mov      dwLinkOfs, bx
       END;
       {asm-end}
       WHILE  (dwLinkOfs <> 0)  DO
       BEGIN
           lpNode := System.Ptr(dwCurTableSpaceSeg,dwLinkOfs);
           WITH  (lpNode^)  DO
           BEGIN
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeAccessCount
                      call      _DoFarCallBack
                      mov       dwTempCount, ax
              END;
              {asm-end}
              IF  (dwTempCount <> 0)
                THEN  BEGIN
                   System.Inc(dwEntriesCount);
                   System.WriteLn(fTextStream,'<<<<');
                   System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(151)+
                                                  '  =  ',dwMaxStrLen),
                                              StrLib._fnsWordToTurboHexFmt(dwTempCount));
                   ASM
                           les       bx, lpNode
                           mov       si, Globals.aGetNodeHitCount
                           call      _DoFarCallBack
                           mov       dwTempCount, ax
                   END;
                   {asm-end}
                   System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(152)+
                                                  '  =  ',dwMaxStrLen),
                                              StrLib._fnsWordToTurboHexFmt(dwTempCount));
                   ASM
                           les       bx, lpNode
                           mov       si, Globals.aGetNodeHitCount
                           call      _DoFarCallBack
                           mov       dwTempCount, ax
                   END;
                   {asm-end}
                   ASM
                           les       bx, lpNode
                           mov       si, Globals.aGetNodeAbbreviationSize
                           call      _DoFarCallBack
                           mov       dbTempCount, al
                   END;
                   {asm-end}
                   ASM
                           les       bx, lpNode
                           mov       si, Globals.aGetNodeExpressionSize
                           call      _DoFarCallBack
                           mov       dbCount, al
                   END;
                   {asm-end}
                   System.Write(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(132)+
                                                '  =  ',dwMaxStrLen)+
                                            Globals.achDoubleQuota);
                   ASM
                           les       bx, lpNode
                           mov       si, Globals.aGetNodeAbbreviationOfs
                           call      _DoFarCallBack
                           mov       dwTempOfs, ax
                   END;
                   {asm-end}
                   System.Move(System.Mem[dwCurTableSpaceSeg:dwTempOfs],
                               sTemp[1],
                               dbTempCount);
                   sTemp[0] := System.Char(dbTempCount);
                   FOR  dbStrIndex :=  1  TO  dbTempCount  DO
                   BEGIN
                       chTemp := sTemp[dbStrIndex];
                       IF  (chTemp  IN  Globals.setAscii8_NoCtrl)
                         THEN  System.Write(fTextStream,chTemp)
                         ELSE  System.Write(fTextStream,Globals.achLess,
                                                        System.Ord(chTemp),
                                                        Globals.achGreater);
                       {if-then-else}
                   END;
                   {for-to-do}
                   System.WriteLn(fTextStream,Globals.achDoubleQuota);
                   System.Write(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(155)+
                                               '  =  ',dwMaxStrLen)+
                                            Globals.achDoubleQuota);
                   ASM
                           les       bx, lpNode
                           mov       si, Globals.aGetNodeExpressionOfs
                           call      _DoFarCallBack
                           mov       dwTempOfs, ax
                   END;
                   {asm-end}
                   System.Move(System.Mem[dwCurTableSpaceSeg:dwTempOfs],
                               sTemp[1],
                               dbCount);
                   sTemp[0] := System.Char(dbCount);
                   FOR  dbStrIndex :=  1  TO  dbCount  DO
                   BEGIN
                       chTemp := sTemp[dbStrIndex];
                       IF  (chTemp  IN  Globals.setAscii8_NoCtrl)
                         THEN  System.Write(fTextStream,chTemp)
                         ELSE  System.Write(fTextStream,Globals.achLess,
                                                        System.Ord(chTemp),
                                                        Globals.achGreater);
                       {if-then-else}
                   END;
                   {for-to-do}
                   System.WriteLn(fTextStream,Globals.achDoubleQuota);
                   System.WriteLn(fTextStream,'>>>>');
                      END;
              {if-then}
           END;
           {with-do}
            ASM
                les       bx, lpNode
                mov       si, Globals.aGetNodeLinkOffsetForFA
                call      _DoFarCallBack
                mov       dwLinkOfs, bx
            END;
            {asm-end}
       END;
       {while-do}
    END;
    {for-to-do}
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(156),
                               ' =  ',dwEntriesCount);
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream);
    System.Close(fTextStream);
END;
{ _DoStatDiagDump }



{*ENVDUMP.INC*}

PROCEDURE
         _DoEnvDiagDump;
{*
Description.
    Dumps the current environment/dictionary to a disk
    in the current directory.
*}
CONST
  dwDumpEnvFileExt   :  System.Word = 0;
VAR
  fTextStream        :  System.Text;
  lpTempEntryDesc    :  Globals.lprecDicEntryDesc;
  pCurEnv            :  Globals.lprecEnvironmentDesc;
  dwMaxStaticSize,
  dwCaseCharIndex,
  dwEntriesCount,
  dwCurEnvHandleNum  :  System.Word;
  sTempOut           :  STRING;

PROCEDURE
          _DumpTableOfNodes(pSearchLinkTable : Globals.lpDWTable256;
                            dbSearchTableType : System.Byte);
{*
Description.
    Dumps all the nodes for a given character.
*}
VAR
  sTemp                  :  STRING;
  lpNode                 :  Globals.lprecDictEntryHeaderDesc;
  lprecHeadLinkTable     :  Globals.lprecCompressedHeadLinkTable;
  liBytesPerUserText,
  liNotCompressedText    :  System.Longint;
  dwTableEntriesCount,
  dwLinkOfs,
  dwNodesForSymFound,
  dwCurTableSpaceSeg,
  dwTempCount,
  dwTempOfs,
  dwCurEnvOptions,
  dwMaxStrLen            :  System.Word;
  dbCharIndex,
  dbStrIndex,
  dbCount,
  dbTemp,
  dbTempCount            :  System.Byte;
  chTemp                 :  System.Char;

PROCEDURE
         _DisplayBitFlagsForNode(dwNodeFlags,
                                 btOption : System.Word;
                                 sMessage : STRING);
{*
Description.
   Displays bit-mapped flags for node.
*}
BEGIN
    IF  ((dwNodeFlags AND btOption) <> 0)
      THEN  BEGIN
        System.WriteLn(fTextStream,'  ('+
                                   Messages._fnsTextMessageByIndex(126)+
                                   ': '+sMessage+'.)');
            END;
    {if-then}
END; { _DisplayBitFlagsForNode }

BEGIN
   dwTableEntriesCount := 0;
   IF  (pSearchLinkTable = NIL)
     THEN  System.Exit;
   {if-then}
   liBytesPerUserText := 0;
   liNotCompressedText := 0;
   dwCurEnvOptions := pCurEnv^.dwUserEnvOptions;
   IF  ((dwCurEnvOptions AND Globals.btUseTableCompression) <> 0)
     THEN  BEGIN
       lprecHeadLinkTable := System.Pointer(pSearchLinkTable);
       System.WriteLn(fTextStream,'<<<<');
       System.WriteLn(fTextStream,'--  '+
                                  Messages._fnsTextMessageByIndex(127)+
                                  '  --');
       System.WriteLn(fTextStream,'>>>>');
       dbCount := 0;
       dbCharIndex := 0;
       dwTempCount := 0;
       REPEAT
         dbTemp := lprecHeadLinkTable^.dbBitMapAsciiSet32[dbCount];
         System.Write(fTextStream,Messages._fnsTextMessageByIndex(128)+
                                  ' ',
                                  StrLib._fnsNumToStrNoAdj(dbCount,2),
                                  ' (',
                                  Messages._fnsTextMessageByIndex(129),
                                  ' ',
                                  StrLib._fnsNumToStrNoAdj(dbCount*Globals.aBitsPerByte,3),'-',
                                  StrLib._fnsNumToStrNoAdj((dbCount*Globals.aBitsPerByte+7),3),
                                    ')  =  ',StrLib._fnsByteToTurboHexFmt(dbTemp));
         dbTemp := lprecHeadLinkTable^.dbCharBitCounters16[dbCharIndex];
         IF  (System.Odd(dbCount))
           THEN  BEGIN
             dbTemp := dbTemp SHR 4;
             System.Inc(dbCharIndex);
                 END
           ELSE  dbTemp := dbTemp AND Globals.aFullLowNibble;
         {if-then-else}
         System.WriteLn(fTextStream,';   ',
                                    Messages._fnsTextMessageByIndex(130),
                                    '  =  ',
                                    StrLib._fnsByteToTurboHexFmt(dbTemp));
         System.Inc(dwTempCount,dbTemp);
         System.Inc(dbCount);
       UNTIL  (dbCount > (Globals.aBytesForSet256-1));
       {repeat-until}
       System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(131),
                                  '  =  ',dwTempCount);
           END;
   {if-then}
    dwCurTableSpaceSeg := System.Seg(pSearchLinkTable^);
    dwMaxStrLen := System.Length(Messages._fnsTextMessageByIndex(132)+'  =  ');
    FOR  dbCharIndex := Globals.aMinCharBit8  TO  Globals.aMaxCharBit8  DO
    BEGIN
       dwNodesForSymFound := 0;
       ASM
           les      bx, pSearchLinkTable
           mov      al, dbCharIndex
           mov      dx, dwCurEnvOptions
           mov      si, Globals.aGetTableOffsetByIndex
           call     _DoFarCallBack
           mov      dwLinkOfs, bx
       END;
       {asm-end}
       WHILE  (dwLinkOfs <> 0)  DO
       BEGIN
           System.Inc(dwNodesForSymFound);
           lpNode := System.Ptr(dwCurTableSpaceSeg,dwLinkOfs);
           System.WriteLn(fTextStream,'<<<<');
           System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(133),
                     '  =  ',StrLib._fnsPointerToTurboHexFmt(lpNode),
                     ';  ',
                     Messages._fnsTextMessageByIndex(134),
                     '  =  ',StrLib._fnsCharCodeDesc(System.Char(dbCharIndex)));
           ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeSizeTotal
                      call      _DoFarCallBack
                      mov       dwTempCount, ax
           END;
           {asm-end}
           System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(135),
                                      '  =  ',dwTempCount);
           System.Inc(liBytesPerUserText,dwTempCount);
           WITH  (lpNode^)  DO
           BEGIN
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeOptions
                      call      _DoFarCallBack
                      mov       dwTempCount, ax
              END;
              {asm-end}
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(136)+
                                                     '  =  ',dwMaxStrLen),
                                         StrLib._fnsWordToTurboHexFmt(dwTempCount));
              _DisplayBitFlagsForNode(dwTempCount,Globals.btNodeHasPaddingZero,
                                      Messages._fnsTextMessageByIndex(137));
              _DisplayBitFlagsForNode(dwTempCount,Globals.btNodeIsCompressed,
                                      Messages._fnsTextMessageByIndex(138));
              _DisplayBitFlagsForNode(dwTempCount,Globals.btNodeLinkOffsetPresentFA,
                                      Messages._fnsTextMessageByIndex(139));
              _DisplayBitFlagsForNode(dwTempCount,Globals.btNodeLinkOffsetPresentBA,
                                      Messages._fnsTextMessageByIndex(140));
              _DisplayBitFlagsForNode(dwTempCount,Globals.btNodeLinkOffsetPresentFE,
                                      Messages._fnsTextMessageByIndex(141));
              _DisplayBitFlagsForNode(dwTempCount,Globals.btNodeLinkOffsetPresentBE,
                                      Messages._fnsTextMessageByIndex(142));
              _DisplayBitFlagsForNode(dwTempCount,Globals.btNodeLinkOffsetPresentAS,
                                      Messages._fnsTextMessageByIndex(143));
              _DisplayBitFlagsForNode(dwTempCount,Globals.btNodeLinkOffsetPresentES,
                                      Messages._fnsTextMessageByIndex(144));
              _DisplayBitFlagsForNode(dwTempCount,Globals.btNodeHasEmptyAbbreviation,
                                      Messages._fnsTextMessageByIndex(555));
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeLinkOffsetForFA
                      call      _DoFarCallBack
                      mov       dwTempOfs, bx
              END;
              {asm-end}
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(145)+
                                                 '  =  ',dwMaxStrLen),
                                         StrLib._fnsWordToTurboHexFmt(dwTempOfs));
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeLinkOffsetForBA
                      call      _DoFarCallBack
                      mov       dwTempOfs, bx
              END;
              {asm-end}
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(146)+
                                                 '  =  ',dwMaxStrLen),
                                         StrLib._fnsWordToTurboHexFmt(dwTempOfs));
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeLinkOffsetForFE
                      call      _DoFarCallBack
                      mov       dwTempOfs, bx
              END;
              {asm-end}
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(147)+
                                                 '  =  ',dwMaxStrLen),
                                         StrLib._fnsWordToTurboHexFmt(dwTempOfs));
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeLinkOffsetForBE
                      call      _DoFarCallBack
                      mov       dwTempOfs, bx
              END;
              {asm-end}
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(148)+
                                                 '  =  ',dwMaxStrLen),
                                         StrLib._fnsWordToTurboHexFmt(dwTempOfs));
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeLinkOffsetForAS
                      call      _DoFarCallBack
                      mov       dwTempOfs, bx
              END;
              {asm-end}
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(149)+
                                                 '  =  ',dwMaxStrLen),
                                         StrLib._fnsWordToTurboHexFmt(dwTempOfs));
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeLinkOffsetForES
                      call      _DoFarCallBack
                      mov       dwTempOfs, bx
              END;
              {asm-end}
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(150)+
                                                 '  =  ',dwMaxStrLen),
                                         StrLib._fnsWordToTurboHexFmt(dwTempOfs));
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeAccessCount
                      call      _DoFarCallBack
                      mov       dwTempCount, ax
              END;
              {asm-end}
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(151)+
                                              '  =  ',dwMaxStrLen),
                                         StrLib._fnsWordToTurboHexFmt(dwTempCount));
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeHitCount
                      call      _DoFarCallBack
                      mov       dwTempCount, ax
              END;
              {asm-end}
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(152)+
                                             '  =  ',dwMaxStrLen),
                                         StrLib._fnsWordToTurboHexFmt(dwTempCount));
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeAbbreviationSize
                      call      _DoFarCallBack
                      mov       dbTempCount, al
              END;
              {asm-end}
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeExpressionSize
                      call      _DoFarCallBack
                      mov       dbCount, al
              END;
              {asm-end}
              System.Inc(liNotCompressedText,System.SizeOf(Globals.recDictEntryHeaderDesc));
              dwTempCount := dbTempCount + dbCount;
              IF  ((dwCurEnvOptions AND Globals.btAddPaddingZero) <> 0) AND
                   (System.Odd(dwTempCount))
                THEN  System.Inc(dwTempCount);
              {if-then}
              System.Inc(liNotCompressedText,dwTempCount);
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(153)+
                                              '  =  ',dwMaxStrLen),
                                         StrLib._fnsByteToTurboHexFmt(dbTempCount));
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(154)+
                                             '  =  ',dwMaxStrLen),
                                         StrLib._fnsByteToTurboHexFmt(dbCount));
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeAbbreviationOfs
                      call      _DoFarCallBack
                      mov       dwTempOfs, ax
              END;
              {asm-end}
              System.Move(System.Mem[dwCurTableSpaceSeg:dwTempOfs],
                          sTemp[1],
                          dbTempCount);
              sTemp[0] := System.Char(dbTempCount);
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(132)+
                                            '  =  ',dwMaxStrLen)+
                                       Globals.achDoubleQuota+
                                       StrLib._fnsDisplayStrAsHexDecAndAscii(sTemp,System.True)+
                                       Globals.achDoubleQuota);
              ASM
                      les       bx, lpNode
                      mov       si, Globals.aGetNodeExpressionOfs
                      call      _DoFarCallBack
                      mov       dwTempOfs, ax
              END;
              {asm-end}
              System.Move(System.Mem[dwCurTableSpaceSeg:dwTempOfs],
                          sTemp[1],
                          dbCount);
              sTemp[0] := System.Char(dbCount);
              System.WriteLn(fTextStream,StrLib._fnsLeadingAddSpacesToMax(Messages._fnsTextMessageByIndex(155)+
                                            '  =  ',dwMaxStrLen)+
                                         Globals.achDoubleQuota+
                                         StrLib._fnsDisplayStrAsHexDecAndAscii(sTemp,System.True)+
                                         Globals.achDoubleQuota);
              System.WriteLn(fTextStream,'>>>>');
           END;
           {with-do}
           CASE  (dbSearchTableType)  OF
              Globals.btForwardSearchAbbreviation   :   BEGIN
                        ASM
                            les       bx, lpNode
                            mov       si, Globals.aGetNodeLinkOffsetForFA
                            call      _DoFarCallBack
                            mov       dwLinkOfs, bx
                        END;
                        {asm-end}
                                                 END;
              Globals.btBackwardSearchAbbreviation   :   BEGIN
                        ASM
                            les       bx, lpNode
                            mov       si, Globals.aGetNodeLinkOffsetForBA
                            call      _DoFarCallBack
                            mov       dwLinkOfs, bx
                        END;
                        {asm-end}
                                                 END;
              Globals.btForwardSearchExpression      :   BEGIN
                        ASM
                            les       bx, lpNode
                            mov       si, Globals.aGetNodeLinkOffsetForFE
                            call      _DoFarCallBack
                            mov       dwLinkOfs, bx
                        END;
                        {asm-end}
                                                 END;
              Globals.btBackwardSearchExpression     :   BEGIN
                        ASM
                            les       bx, lpNode
                            mov       si, Globals.aGetNodeLinkOffsetForBE
                            call      _DoFarCallBack
                            mov       dwLinkOfs, bx
                        END;
                        {asm-end}
                                                 END;
              Globals.btSearchAbbreviationSizes      :   BEGIN
                        ASM
                            les       bx, lpNode
                            mov       si, Globals.aGetNodeLinkOffsetForAS
                            call      _DoFarCallBack
                            mov       dwLinkOfs, bx
                        END;
                        {asm-end}
                                                 END;
              Globals.btSearchExpressionSizes        :   BEGIN
                        ASM
                            les       bx, lpNode
                            mov       si, Globals.aGetNodeLinkOffsetForES
                            call      _DoFarCallBack
                            mov       dwLinkOfs, bx
                        END;
                        {asm-end}
                                                 END;
           END;
           {case-of}
       END;
       {while-do}
       System.Inc(dwTableEntriesCount,dwNodesForSymFound);
    END;
    {for-to-do}
    System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(156),
                               ' =  ',dwTableEntriesCount);
    System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(157),
                               '  =  ',liBytesPerUserText,
                                 ', ('+
            StrLib._fnsNumToStr(aPercent100-System.Trunc((liBytesPerUserText/liNotCompressedText)*aPercent100),3),
                                Globals.achPercent+Globals.achSPACE,
                                 Messages._fnsTextMessageByIndex(138),
                                 ')');
    System.WriteLn(fTextStream);
END;
{ _DumpTableOfNodes }

FUNCTION
        _fndbBitsInByte(dbNum : System.Byte) : System.Byte; assembler;
{*
Description.
   Counts "ones" bits in a given byte.
*}
ASM
        mov     cx, Globals.aBitsPerByte
        mov     al, dbNum
        sub     ah, ah
@TakeNextBut:
        shr     al, 1
        adc     ah, 0
        loop   @TakeNextBut
        mov     al, ah
END;  {asm-end}
{ _fndbBitsInByte }


FUNCTION
        _fndwDumpHeadLinkTableSize(pLinkTable : System.Pointer;
                                   sTableMsg : STRING) : System.Word;
{*
Description.
   Returns a size of head link table.
*}
VAR
  dwCount,
  dwTableIndex  :  System.Word;
BEGIN
  System.Write(fTextStream,sTableMsg);
  IF  ((pCurEnv^.dwUserEnvOptions AND Globals.btUseTableCompression) = 0)
    THEN  BEGIN
       IF  (pLinkTable <> NIL)
         THEN  dwCount := System.SizeOf(Globals.arrayDWTable256)
         ELSE  dwCount := 0;
       {if-then-else}
          END
    ELSE  BEGIN
       dwCount := 0;
       IF  (pLinkTable <> NIL)
         THEN  BEGIN
           dwCount := Globals.aBytesForSet256;
           dwTableIndex := 0;
           REPEAT
             System.Inc(dwCount,(_fndbBitsInByte(System.Mem[System.Seg(pLinkTable^):
                            (System.Ofs(pLinkTable^)+dwTableIndex)])*Globals.aWord));
             System.Inc(dwTableIndex);
           UNTIL  (dwTableIndex >= Globals.aBytesForSet256);
           {repeat-until}
               END;
       {if-then}
          END;
  {if-then}
  sTempOut := StrLib._fnsNumToStrNoAdj(dwCount,5);
  System.WriteLn(fTextStream,sTempOut,Messages._fnsTextMessageByIndex(254));
  _fndwDumpHeadLinkTableSize := dwCount;
END;
{ _fndwDumpHeadLinkTableSize }

FUNCTION
        _fndwAddHeadLinkTableSize(pLinkTable : System.Pointer) : System.Word;
{*
Description.
   Extracts a table size.
*}
VAR
  dwLinkTableSize : System.Word;
BEGIN
  IF  (pLinkTable <> NIL)
    THEN  dwLinkTableSize := System.SizeOf(Globals.arrayDWTable256)
    ELSE  dwLinkTableSize := 0;
  {if-then-else}
   _fndwAddHeadLinkTableSize := dwLinkTableSize;
END;
{ _fndwAddHeadLinkTableSize }

BEGIN
    Video._OutputMessage(Messages._fnsTextMessageByIndex(158),
                         System.True);
    dwCurEnvHandleNum := CallBack._fndwGetCurEnv;
    IF  (dwCurEnvHandleNum = 0)
      THEN  BEGIN
           Video._HaltProgram(Messages._fnsTextMessageByIndex(297),
                              Globals.errCurrentEnviromentNotFound);
            END;
    {if-then}
    System.Assign(fTextStream,StrLib._fnsGetNewFileName(dwDumpEnvFileExt,'USERENV'));
    System.Rewrite(fTextStream);
    System.WriteLn(fTextStream,'<<< '+Messages._fnsTextMessageByIndex(159)+' >>>');
    System.WriteLn(fTextStream,'<<< ('+Messages._fnsTextMessageByIndex(40)+') >>>');
    System.WriteLn(fTextStream);
    System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(94)+
                               ' = ',dwCurEnvHandleNum);
    System.WriteLn(fTextStream);
    pCurEnv := CallBack._fnlpGetCurEnvSettings;
{$IFDEF   DebVer}
    IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
        THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(161),
                                        aModuleTypist);
    {if-then}
{$ENDIF} {DebVer}
    WITH  (pCurEnv^)  DO
    BEGIN
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(163)+'  ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(164),
                     Strlib._fnsWordToTurboHexFmt(dwIdleModeHotkey),',',
                     Strlib._fnsByteToTurboHexFmt(dbIdleModeScanCode));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(165),
                     Strlib._fnsWordToTurboHexFmt(dwManualModeHotkey),',',
                     Strlib._fnsByteToTurboHexFmt(dbManualModeScanCode));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(166),
                     Strlib._fnsWordToTurboHexFmt(dwAddModeHotkey),',',
                     Strlib._fnsByteToTurboHexFmt(dbAddModeScanCode));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(167),
                     Strlib._fnsWordToTurboHexFmt(dwSearchModeHotkey),',',
                     Strlib._fnsByteToTurboHexFmt(dbSearchModeScanCode));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(168),
                     Strlib._fnsWordToTurboHexFmt(dwEnvironmentHotKey),',',
                     Strlib._fnsByteToTurboHexFmt(dbEnvironmentScanCode));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(169),
                     Strlib._fnsWordToTurboHexFmt(dwVideoIndicationHotKey),',',
                     Strlib._fnsByteToTurboHexFmt(dbVideoIndicationScanCode));
      System.WriteLn(fTextStream);
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(170)+'  ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(171),
                                 Strlib._fnsWordToTurboHexFmt(dwInitSearchFlags));
      IF  ((dwInitSearchFlags AND Globals.btForwardSearch) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(300));
      {if-then}
      IF  ((dwInitSearchFlags AND Globals.btBackwardSearch) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(301));
      {if-then}
      IF  ((dwInitSearchFlags AND Globals.btSearchAbbreviation) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(302));
      {if-then}
      IF  ((dwInitSearchFlags AND Globals.btSearchExpression) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(303));
      {if-then}
      IF  ((dwInitSearchFlags AND Globals.btSearchFirstForward) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(304));
      {if-then}
      IF  ((dwInitSearchFlags AND Globals.btSearchFirstAbbreviation) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(305));
      {if-then}
      IF  ((dwInitSearchFlags AND Globals.btSearchCaseSensitive) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(306));
      {if-then}
      IF  ((dwInitSearchFlags AND Globals.btMiddleSearch) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(307));
      {if-then}
      IF  ((dwInitSearchFlags AND Globals.btSingleWordSearchSym) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(308));
      {if-then}
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(172),
                                 Strlib._fnsWordToTurboHexFmt(dwUserEnvOptions));
      IF  ((dwUserEnvOptions AND Globals.btAutoAddChar) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(312));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btVideoIndicationOn) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(313));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btUseTableCompression) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(314));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btUseNodeCompression) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(315));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btClickOnModeChange) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(316));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btFilterRawInput) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(317));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btAddPaddingZero) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(318));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btRecognizeMetaSymbols) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(319));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btAutoPutScanCode) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(320));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btUseForMSWord) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(321));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btUseForOldNorton1986) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(401));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btUseInt154F) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(322));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btUseInt1601) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(567));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btSetBorderColorAsMarker) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(553));
      {if-then}
      IF  ((dwUserEnvOptions AND Globals.btEmptyAbbreviation) <> 0)
        THEN  System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(554));
      {if-then}
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(173),
                                 Strlib._fnsByteToTurboHexFmt(dbColorVideoAttr));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(174),
                                 Strlib._fnsByteToTurboHexFmt(dbMonoVideoAttr));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(552),
                                 Strlib._fnsByteToTurboHexFmt(dbIdleModeBorder));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(551),
                                 Strlib._fnsByteToTurboHexFmt(dbActiveModeBorder));
      System.WriteLn(fTextStream);
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(175)+'  ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(176),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chForwardSearchSymbol)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(177),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chBackwardSearchSymbol)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(178),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chNonSpecialSymbol)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(179),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chSearchAbbrevSymbol)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(180),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chSearchExpressionSymbol)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(181),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chDirectionSearchOrderSym)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(182),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chDictSearchOrderSym)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(183),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chCaseSearchSym)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(405),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chMiddleSrchSym)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(443),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chBreakInputSym)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(406),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chSingleWordSearchSym)));
      System.WriteLn(fTextStream);
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(184)+'  ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(185),'"',sDictName16,'"');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(186),'"',sDictComment32,'"');
      System.WriteLn(fTextStream);
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(298)+'  ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(403),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chDelimDefinitionSym)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(404),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chNonDefSym)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(428),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chOpenNumericSym)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(429),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chCloseNumericSym)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(299),
                     Strlib._fnsByteToTurboHexFmt(System.Byte(chAutoAddChar)));
      System.Write(fTextStream,Messages._fnsTextMessageByIndex(311));
      dwEntriesCount := System.Length(sDelimiters16);
      dwCaseCharIndex := 0;
      sTempOut := Globals.asBlank;
      WHILE  (dwEntriesCount <> 0)  DO
      BEGIN
          System.Dec(dwEntriesCount);
          System.Inc(dwCaseCharIndex);
          sTempOut := sTempOut + Strlib._fnsByteToTurboHexFmt(System.Byte(sDelimiters16[dwCaseCharIndex]));
          IF  (dwEntriesCount <> 0)
            THEN  sTempOut := sTempOut + ',';
          {if-then}
      END;
      {while-do}
      System.WriteLn(fTextStream,sTempOut);
      System.WriteLn(fTextStream);
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(398)+'  ------');
      System.Writeln(fTextStream,Messages._fnsTextMessageByIndex(399),
                                 Strlib._fnsPointerToTurboHexFmt(pFreePointer));
      System.Writeln(fTextStream,Messages._fnsTextMessageByIndex(400),
                                 Strlib._fnsNumToStr(dwFreeSize,5),
                                 Messages._fnsTextMessageByIndex(254));
      System.WriteLn(fTextStream);
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(187)+'  ------');
      dwCaseCharIndex := Globals.aMinCharBit8;
      REPEAT
        System.Write(fTextStream,Messages._fnsTextMessageByIndex(188)+'  (',
                                 Strlib._fnsNumToStrNoAdj(dwCaseCharIndex,3),'-',
                                 Strlib._fnsNumToStrNoAdj((dwCaseCharIndex+Globals.aBitsPerByte-1),3),
                                 ')  =  ');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(chCaseMapArray256[dwCaseCharIndex+0])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(chCaseMapArray256[dwCaseCharIndex+1])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(chCaseMapArray256[dwCaseCharIndex+2])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(chCaseMapArray256[dwCaseCharIndex+3])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(chCaseMapArray256[dwCaseCharIndex+4])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(chCaseMapArray256[dwCaseCharIndex+5])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(chCaseMapArray256[dwCaseCharIndex+6])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(chCaseMapArray256[dwCaseCharIndex+7])));
        IF (dwCaseCharIndex <> (Globals.aMaxCharBit8-Globals.aBitsPerByte+1))
          THEN  System.WriteLn(fTextStream,',')
          ELSE  System.WriteLn(fTextStream,'.');
        {if-then-else}
        System.Inc(dwCaseCharIndex,Globals.aBitsPerByte);
      UNTIL  (dwCaseCharIndex > Globals.aMaxCharBit8);
      {repeat-until}
      System.WriteLn(fTextStream);
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(309)+'  ------');
      dwCaseCharIndex := Globals.aMinCharBit8;
      REPEAT
        System.Write(fTextStream,Messages._fnsTextMessageByIndex(188)+'  (',
                                 Strlib._fnsNumToStrNoAdj(dwCaseCharIndex,3),'-',
                                 Strlib._fnsNumToStrNoAdj((dwCaseCharIndex+Globals.aBitsPerByte-1),3),
                                 ')  =  ');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbScanCodeTable256[dwCaseCharIndex+0])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbScanCodeTable256[dwCaseCharIndex+1])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbScanCodeTable256[dwCaseCharIndex+2])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbScanCodeTable256[dwCaseCharIndex+3])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbScanCodeTable256[dwCaseCharIndex+4])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbScanCodeTable256[dwCaseCharIndex+5])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbScanCodeTable256[dwCaseCharIndex+6])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbScanCodeTable256[dwCaseCharIndex+7])));
        IF (dwCaseCharIndex <> (Globals.aMaxCharBit8-Globals.aBitsPerByte+1))
          THEN  System.WriteLn(fTextStream,',')
          ELSE  System.WriteLn(fTextStream,'.');
        {if-then-else}
        System.Inc(dwCaseCharIndex,Globals.aBitsPerByte);
      UNTIL  (dwCaseCharIndex > Globals.aMaxCharBit8);
      {repeat-until}
      System.WriteLn(fTextStream);
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(310)+'  ------');
      dwCaseCharIndex := Globals.aMinCharBit8;
      REPEAT
        System.Write(fTextStream,Messages._fnsTextMessageByIndex(188)+'  (',
                                 Strlib._fnsNumToStrNoAdj(dwCaseCharIndex,3),'-',
                                 Strlib._fnsNumToStrNoAdj((dwCaseCharIndex+Globals.aBitsPerByte-1),3),
                                 ')  =  ');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbWordCharTable256[dwCaseCharIndex+0])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbWordCharTable256[dwCaseCharIndex+1])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbWordCharTable256[dwCaseCharIndex+2])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbWordCharTable256[dwCaseCharIndex+3])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbWordCharTable256[dwCaseCharIndex+4])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbWordCharTable256[dwCaseCharIndex+5])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbWordCharTable256[dwCaseCharIndex+6])),',');
        System.Write(fTextStream,Strlib._fnsByteToTurboHexFmt(System.Byte(dbWordCharTable256[dwCaseCharIndex+7])));
        IF (dwCaseCharIndex <> (Globals.aMaxCharBit8-Globals.aBitsPerByte+1))
          THEN  System.WriteLn(fTextStream,',')
          ELSE  System.WriteLn(fTextStream,'.');
        {if-then-else}
        System.Inc(dwCaseCharIndex,Globals.aBitsPerByte);
      UNTIL  (dwCaseCharIndex > Globals.aMaxCharBit8);
      {repeat-until}
      System.WriteLn(fTextStream);
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(323)+'  ------');
      dwEntriesCount := System.SizeOf(Globals.recEnvironmentDesc);
      dwMaxStaticSize := dwEntriesCount;
      System.Inc(dwMaxStaticSize,_fndwAddHeadLinkTableSize(pForwardSearchAbbrevTable));
      System.Inc(dwMaxStaticSize,_fndwAddHeadLinkTableSize(pBackwardSearchAbbrevTable));
      System.Inc(dwMaxStaticSize,_fndwAddHeadLinkTableSize(pForwardSearchDictTable));
      System.Inc(dwMaxStaticSize,_fndwAddHeadLinkTableSize(pBackwardSearchDictTable));
      System.Inc(dwMaxStaticSize,_fndwAddHeadLinkTableSize(pStrSizeSearchAbbrevTable));
      System.Inc(dwMaxStaticSize,_fndwAddHeadLinkTableSize(pStrSizeSearchDictTable));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(324),
                                 _fnsNumToStrNoAdj(dwEntriesCount,5),
                                 Messages._fnsTextMessageByIndex(254));
      System.Inc(dwEntriesCount,_fndwDumpHeadLinkTableSize(pForwardSearchAbbrevTable,
                                          Messages._fnsTextMessageByIndex(325)));
      System.Inc(dwEntriesCount,_fndwDumpHeadLinkTableSize(pBackwardSearchAbbrevTable,
                                          Messages._fnsTextMessageByIndex(326)));
      System.Inc(dwEntriesCount,_fndwDumpHeadLinkTableSize(pForwardSearchDictTable,
                                          Messages._fnsTextMessageByIndex(327)));
      System.Inc(dwEntriesCount,_fndwDumpHeadLinkTableSize(pBackwardSearchDictTable,
                                          Messages._fnsTextMessageByIndex(328)));
      System.Inc(dwEntriesCount,_fndwDumpHeadLinkTableSize(pStrSizeSearchAbbrevTable,
                                          Messages._fnsTextMessageByIndex(329)));
      System.Inc(dwEntriesCount,_fndwDumpHeadLinkTableSize(pStrSizeSearchDictTable,
                                          Messages._fnsTextMessageByIndex(330)));
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(331),
                                 _fnsNumToStrNoAdj(dwEntriesCount,5),
                                 Messages._fnsTextMessageByIndex(254),
                                 ', ('+
            StrLib._fnsNumToStr(aPercent100-System.Trunc((dwEntriesCount/dwMaxStaticSize)*aPercent100),3),
                                Globals.achPercent+Globals.achSPACE,
                                 Messages._fnsTextMessageByIndex(138),
                                 ')');
      System.WriteLn(fTextStream);
      System.WriteLn(fTextStream);
{$IFDEF   DebVer}
      IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
          THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(189),
                                          aModuleTypist);
      {if-then}
{$ENDIF} {DebVer}
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(196)+'  ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(195),
                     Strlib._fnsPointerToTurboHexFmt(pForwardSearchAbbrevTable));
      _DumpTableOfNodes(pForwardSearchAbbrevTable,Globals.btForwardSearchAbbreviation);
{$IFDEF   DebVer}
      IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
          THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(190),
                                          aModuleTypist);
      {if-then}
{$ENDIF} {DebVer}
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(197)+'  ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(195),
                     StrLib._fnsPointerToTurboHexFmt(pBackwardSearchAbbrevTable));
      _DumpTableOfNodes(pBackwardSearchAbbrevTable,Globals.btBackwardSearchAbbreviation);
{$IFDEF   DebVer}
      IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
          THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(191),
                                          aModuleTypist);
      {if-then}
{$ENDIF} {DebVer}
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(198)+'  ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(195),
                     StrLib._fnsPointerToTurboHexFmt(pForwardSearchDictTable));
      _DumpTableOfNodes(pForwardSearchDictTable,Globals.btForwardSearchExpression);
{$IFDEF   DebVer}
      IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
          THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(192),
                                          aModuleTypist);
      {if-then}
{$ENDIF} {DebVer}
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(199)+'  ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(195),
                      StrLib._fnsPointerToTurboHexFmt(pBackwardSearchDictTable));
      _DumpTableOfNodes(pBackwardSearchDictTable,Globals.btBackwardSearchExpression);
{$IFDEF   DebVer}
      IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
          THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(193),
                                          aModuleTypist);
      {if-then}
{$ENDIF} {DebVer}
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(200)+'  ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(195),
                     StrLib._fnsPointerToTurboHexFmt(pStrSizeSearchAbbrevTable));
      _DumpTableOfNodes(pStrSizeSearchAbbrevTable,Globals.btSearchAbbreviationSizes);
{$IFDEF   DebVer}
      IF  ((Globals.gdwDebugLevel AND Globals.btTraceTypist) <> 0)
          THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(194),
                                          aModuleTypist);
      {if-then}
{$ENDIF} {DebVer}
      System.WriteLn(fTextStream,'------  '+Messages._fnsTextMessageByIndex(201)+'  ------');
      System.WriteLn(fTextStream,Messages._fnsTextMessageByIndex(195),
                      StrLib._fnsPointerToTurboHexFmt(pStrSizeSearchDictTable));
      _DumpTableOfNodes(pStrSizeSearchDictTable,Globals.btSearchExpressionSizes);
    END;
    {with-do}
    System.WriteLn(fTextStream);
    System.Close(fTextStream);
END;
{ _DoEnvDiagDump }



{BEGIN}
END.
