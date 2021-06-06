{****************************************************************************
//                            File SHOWTERR.PAS
//
//               Extended Borland Pascal runtime error handler
//
//      Copyright (c) 1994, 1998 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/SHOWTERR/RCS/showterr.pas $
//  $RCSfile: showterr.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/18 11:17:16 $ 
// $Revision: 1.2 $ 
//   $Locker: dstef $ 
//
//      $Log: showterr.pas $
//      Revision 1.2  1998/10/18 11:17:16  dstef
//      Updated some comments
//
//      Revision 1.1  1998/10/03 14:34:03  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                PASCAL_SUPPLEMENTAL                             }
{ FILE NAME             SHOWTERR.PAS                                    }
{ PURPOSE               Display TPascal run-time error message          }
{ VERSION               1.17                                            }
{ DATE                  18-Oct-1998                                     }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Telephone: +007 (095) 944-6304                  }
{ INTERNET              wizard@radio-msu.net, dima@mccbn.ru             }
{ COPYRIGHT NOTICE      Copyright (C) 1994, 1998  Dmitry Stefankov      }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,           }
{                       NOT FOR COMMERCIAL PURPOSE                      }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 6.0                        }
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             None                                            }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       NONE                                            }
{                       External Object Files                           }
{                       NONE                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               Requires the knowledge of internal structure of }
{                       Borland Pascal RunTime Library;                 }
{                       Code must work for Turbo Pascal 6.0;            }
{                       Code must work for Turbo Pascal 7.0;            }
{                       Code must work for Borland Pascal 7.0 with      }
{                          Objects (real-mode applications);            }
{                       Code must work for Borland Pascal 7.0 with      }
{                          Objects (protected-mode applications).       }
{ DESCRIPTION           1. Installs the own runtime error handler and   }
{                          replaces the Turbo own handler.              }
{                       2. Turbo/Borland code gives to this handler if  }
{                          some error occurred.                         }
{                       3. Print message about this error before return }
{                          to Turbo code.                               }
{                          Messages includes also type of code and error}
{                          location as Turbo will reported to a handler.}
{                       4. This handler is maybe deinstalled also at    }
{                          anytime.                                     }
{                       5. New feature!                                 }
{                          Handler may also display source file name for}
{                          program or unit, and line number if it finds }
{                          the matching code location.                  }
{                          This feature requires the generation of the  }
{                          symbol map file (switch -GD for compiler) and}
{                          correctly using of external program MAP2EXE. }
{                          And now you can distribute your own programs }
{                          with more appropriate support for end users. }
{                       6. More new feature!                            }
{                          Error trapping was added in current release. }
{                          Therefore you can add the own program error  }
{                          recovery mechanism using the error trap hand-}
{                          lung.                                        }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00  20-Jul-94  DS  initilal release           }
{                       1.01  10-Mar-95  DS  added search of error place}
{                                            to find matching line      }
{                                            numbers and the source     }
{                                            filenames                  }
{                       1.10  11-Mar-95  DS  added support for PM apps  }
{                       1.11  13-Mar-95  DS  added MS LAN error codes   }
{                       1.12  20-Apr-95  DS  corrected calculations of  }
{                                            tables offsets             }
{                       1.13  09-May-95  DS  fixed bug for searching of }
{                                            matching error location    }
{                       1.14  26-Jul-97  DS  updated documentation      }
{                       1.15  02-Aug-97  DS  removed tabs               }
{                       1.16  05-Aug-97  DS  added error trapping       }
{                       1.17  18-Oct-98  DS  updated comments           }
{-----------------------------------------------------------------------}


{*======================= UNIT HEADER PART ==========================*}

UNIT  ShowTErr;


{*** other modules ***}
{USES}


{** switches for compilation **}
{$S-}             {*  stack checking               *}
{$R-}             {*  range checking               *}
{$X+}             {*  extended syntax              *}
{$D-}             {*  disable debug information    *}


{** Debugging version. **}
{** Uses built-in infomap in unit to test of work. **}
{***$DEFINE DebugVersion}


{** Error mapping scheme. **}
{***$DEFINE AddMapErr}

{** Reserve space for map information. **}
{** Uncomment each following line upto **}
{** wanted line. For example, to make  **}
{** 16 Kbytes map, you must uncomment  **}
{** Map2KB, Map4KB,Map8KB, and Map16KB **}
{** directives.                        **}
{$IFDEF   AddMapErr}
   {*$DEFINE   Map2KB}
   {*$DEFINE   Map4KB}
   {*$DEFINE   Map8KB}
   {*$DEFINE   Map16KB}
   {*$DEFINE   Map24KB}
   {*$DEFINE   Map32KB}
   {*$DEFINE   Map40KB}
   {*$DEFINE   Map48KB}
{$ENDIF} {AddMapErr}


INTERFACE
CONST
        TrapProc  :   System.Pointer = NIL;    {Error trap procedure address}

        PROCEDURE       _InstallErrorHandler;
        PROCEDURE       _UnInstallErrorHandler;

PROCEDURE  _TrapBegin;
INLINE($E8/$07/$00/                         {         call    @T1        }
       $24/$54/$52/$41/$50/$24/$00/         {DB      '$TRAP$', 0         }
       $58/                                 {@T1:     pop     ax         }
       $51/                                 {         push    cx         }
       $57/                                 {         push    di         }
       $06/                                 {         push    es         }
       $0E/                                 {         push    cs         }
       $07/                                 {         pop     es         }
       $05/$0A/$00/                         {         add     ax, 3+7    }
       $8B/$F8/                             {         mov     di, ax     }
       $B9/$00/$40/                         {         mov     cx, 16384  }
       $2B/$C0/                             {         sub     ax, ax     }
       $47/                                 {@T2:     inc     di         }
       $49/                                 {         dec     cx         }
       $0B/$C9/                             {         or      cx, cx     }
       $74/$1F/                             {         jz     @T3         }
       $26/$81/$3D/$24/$54/                 {         cmp  es:[di+0],'T$'}
       $75/$F3/                             {         jne    @T2         }
       $26/$81/$7D/$02/$52/$41/             {         cmp  es:[di+2],'AR'}
       $75/$EB/                             {         jne    @T2         }
       $26/$81/$7D/$04/$50/$24/             {         cmp  es:[di+4],'$P'}
       $75/$E3/                             {         jne    @T2         }
       $8B/$C7/                             {          mov    ax, di     }
       $83/$E8/$03/                         {          sub    ax, 3      }
       $07/                                 {          pop    es         }
       $5F/                                 {          pop     di        }
       $59/                                 {          pop    cx         }
       $0B/$C0/                             {@T3:      or     ax, ax     }
       $74/$53/                             {          je    @T4         }
       $8B/$F0/                             {          mov    si, ax     }
       $89/$36/>TrapProc+0/                 { mov WORD PTR TrapProc+0,si }
       $8C/$0E/>TrapProc+2/                 { mov WORD PTR TrapProc+2,cs }
       $83/$C6/$0A/                         {         add     si, 3      }
       $2E/$C6/$04/$00/                     {     mov BYTE PTR cs:[si],0 }
       $46/                                 {         inc     si         }
       $2E/$89/$04/                         {         mov     cs:[si],ax }
       $83/$C6/$02/                         {         add     si, 2      }
       $2E/$89/$0C/                         {         mov     cs:[si],cx }
       $83/$C6/$02/                         {         add     si, 2      }
       $2E/$89/$14/                         {         mov     cs:[si],dx }
       $83/$C6/$02/                         {         add     si, 2      }
       $2E/$89/$2C/                         {         mov     cs:[si],bp }
       $83/$C6/$02/                         {         add     si, 2      }
       $2E/$89/$04/                         {         mov     cs:[si],ax }
       $83/$C6/$02/                         {         add     si, 2      }
       $2E/$8C/$1C/                         {         mov     cs:[si],ds }
       $83/$C6/$02/                         {         add     si, 2      }
       $2E/$89/$3C/                         {         mov     cs:[si],di }
       $83/$C6/$02/                         {         add     si, 2      }
       $2E/$8C/$04/                         {         mov     cs:[si],es }
       $83/$C6/$02/                         {         add     si, 2      }
       $FA/                                 {         cli                }
       $2E/$89/$24/                         {         mov     cs:[si],sp }
       $83/$C6/$02/                         {         add     si, 2      }
       $2E/$8C/$14/                         {         mov     cs:[si],ss }
       $FB/                                 {         sti                }
       $83/$C6/$02/                         {         add     si, 2      }
       $2E/$89/$1C                          {         mov     cs:[si],bx }
                                            {@T4:                        }
);

PROCEDURE  _TrapEnd;
INLINE($E8/$1E/$00/                         {         call    @U1    }
       $24/$54/$52/$41/$50/$24/$00/         {DB      '$TRAP$',0      }
       $00/                                 {fCall   DB      0       }
       $00/$00/                             {regAX   DW      0       }
       $00/$00/                             {regCX   DW      0       }
       $00/$00/                             {regDX   DW      0       }
       $00/$00/                             {regBP   DW      0       }
       $00/$00/                             {regSI   DW      0       }
       $00/$00/                             {regDS   DW      0       }
       $00/$00/                             {regDI   DW      0       }
       $00/$00/                             {regES   DW      0       }
       $00/$00/                             {regSP   DW      0       }
       $00/$00/                             {regSS   DW      0       }
       $00/$00/                             {regBX   DW      0       }
       $58/                                 {@U1:     pop     ax     }
       $8B/$D8/                             {         mov     bx, ax }
       $81/$C3/$07/$00/                     {         add     bx, 7  }
       $2E/$80/$3F/$00/                     { cmp BYTE PTR cs:[bx],0 }
       $74/$42/                             {         je     @U2     }
       $43/                                 {         inc     bx     }
       $2E/$8B/$07/                         {         mov ax,cs:[bx] }
       $83/$C3/$02/                         {         add     bx, 2  }
       $2E/$8B/$0F/                         {         mov cx,cs:[bx] }
       $83/$C3/$02/                         {         add     bx, 2  }
       $2E/$8B/$17/                         {         mov dx,cs:[bx] }
       $83/$C3/$02/                         {         add     bx, 2  }
       $2E/$8B/$2F/                         {         mov bp,cs:[bx] }
       $83/$C3/$02/                         {         add     bx, 2  }
       $2E/$C5/$37/                         {         lds si,cs:[bx] }
       $83/$C3/$04/                         {         add     bx, 4  }
       $2E/$C4/$3F/                         {         les di,cs:[bx] }
       $83/$C3/$04/                         {         add     bx, 4  }
       $FA/                                 {         cli            }
       $2E/$8B/$27/                         {         mov sp,cs:[bx] }
       $83/$C3/$02/                         {         add     bx, 2  }
       $2E/$8E/$17/                         {         mov ss,cs:[bx] }
       $FB/                                 {         sti            }
       $83/$C3/$02/                         {         add     bx, 2  }
       $2E/$8B/$1F/                         {         mov bx,cs:[bx] }
       $C7/$06/>TrapProc+0/$00/$00/         {mov WORD PTR TrapProc+0,0}
       $C7/$06/>TrapProc+2/$00/$00          {mov WORD PTR TrapProc+2,0}
);


IMPLEMENTATION


{*========================== CONSTANTS PART ============================*}

CONST
{$IFDEF   Map2KB}
      aMap2K    =       2048;
{$ELSE}
      aMap2K    =       0;
{$ENDIF} {Map2KB}
{$IFDEF   Map4KB}
      aMap4K    =       2048;
{$ELSE}
      aMap4K    =       0;
{$ENDIF} {Map4KB}
{$IFDEF   Map8KB}
      aMap8K    =       4096;
{$ELSE}
      aMap8K    =       0;
{$ENDIF} {Map8KB}
{$IFDEF   Map16KB}
      aMap16K   =       8192;
{$ELSE}
      aMap16K   =       0;
{$ENDIF} {Map16KB}
{$IFDEF   Map24KB}
      aMap24K   =       8192;
{$ELSE}
      aMap24K   =       0;
{$ENDIF} {Map24KB}
{$IFDEF   Map32KB}
      aMap32K   =       8192;
{$ELSE}
      aMap32K   =       0;
{$ENDIF} {Map32KB}
{$IFDEF   Map40KB}
      aMap40K   =       8192;
{$ELSE}
      aMap40K   =       0;
{$ENDIF} {Map40KB}
{$IFDEF   Map48KB}
      aMap48K   =       8192;
{$ELSE}
      aMap48K   =       0;
{$ENDIF} {Map48KB}



{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE

     {* map info structures *}

        recLocOfLineNum         =       RECORD
                  dwLineNum   :   System.Word; {0=end}
                  dwLoc       :   System.Word;
                                        END;
       {recLocOfLineNum}

        arrFileName14           =       ARRAY[1..14]  OF System.Char;
        recSrcFileName          =       RECORD
                  dwNextRecLink       :   System.Word;   {0=end}
                  dwThisCodeSeg       :   System.Word;   {relative offset}
                  dwLinesTableLink    :   System.Word;   {relative offset}
                  szFileName          :   arrFileName14; {ASCIIZ string}
                                        END;
       {recSrcFileName}



{*=========================== VARIABLES PART ===========================*}

VAR
        glpOldExitProc  :       System.Pointer;



{*=========================== FORWARD REFERENCES PART ==================*}

{$IFDEF   AddMapErr}

PROCEDURE  _MapTError; near; FORWARD;

{$ENDIF} {AddMapErr}



{*=========================== PROCEDURAL PART ==========================*}


PROCEDURE  RunTimeErrorHandler; far; assembler;
ASM
                jmp    @DispErrorAddress


{ Copyright notice }

@szCopyright:
                DB      'Portions Copyright (c) 1994,1997 Dmitry Stefankov',0


{ Error strings }

@szError1:
                DB      'Turbo runtime error ',0
@szError2:
                DB      ' (',0
@szError3:
                DB      ') at ',0
@szError4:
                DB      '.',13,10,0


{$IFDEF   AddMapErr}

@szMapErr1:
                DB      '**Turbo map error information**',13,10,0
@szMapErr2:
                DB      'Source filename found as ',0
@szMapErr3:
                DB      'Source line number is ',0
@szMapErr4:
                DB      '.',13,10,0

{$ENDIF} {AddMapErr}


{ Dispatch table }

@dwCodeTable:
                DW      OFFSET  @szCode000
                DW      OFFSET  @szCode001
                DW      OFFSET  @szCode002
                DW      OFFSET  @szCode003
                DW      OFFSET  @szCode004
                DW      OFFSET  @szCode005
                DW      OFFSET  @szCode006
                DW      OFFSET  @szCode007
                DW      OFFSET  @szCode008
                DW      OFFSET  @szCode009
                DW      OFFSET  @szCode010
                DW      OFFSET  @szCode011
                DW      OFFSET  @szCode012
                DW      OFFSET  @szCode013
                DW      OFFSET  @szCode014
                DW      OFFSET  @szCode015
                DW      OFFSET  @szCode016
                DW      OFFSET  @szCode017
                DW      OFFSET  @szCode018
                DW      OFFSET  @szCode019
                DW      OFFSET  @szCode020
                DW      OFFSET  @szCode021
                DW      OFFSET  @szCode022
                DW      OFFSET  @szCode023
                DW      OFFSET  @szCode024
                DW      OFFSET  @szCode025
                DW      OFFSET  @szCode026
                DW      OFFSET  @szCode027
                DW      OFFSET  @szCode028
                DW      OFFSET  @szCode029
                DW      OFFSET  @szCode030
                DW      OFFSET  @szCode031
                DW      OFFSET  @szCode032
                DW      OFFSET  @szCode033
                DW      OFFSET  @szCode034
                DW      OFFSET  @szCode035
                DW      OFFSET  @szCode036
                DW      OFFSET  @szCode037
                DW      OFFSET  @szCode038
                DW      OFFSET  @szCode039
                DW      OFFSET  @szCode040
                DW      OFFSET  @szCode041
                DW      OFFSET  @szCode042
                DW      OFFSET  @szCode043
                DW      OFFSET  @szCode044
                DW      OFFSET  @szCode045
                DW      OFFSET  @szCode046
                DW      OFFSET  @szCode047
                DW      OFFSET  @szCode048
                DW      OFFSET  @szCode049
                DW      OFFSET  @szCode050
                DW      OFFSET  @szCode051
                DW      OFFSET  @szCode052
                DW      OFFSET  @szCode053
                DW      OFFSET  @szCode054
                DW      OFFSET  @szCode055
                DW      OFFSET  @szCode056
                DW      OFFSET  @szCode057
                DW      OFFSET  @szCode058
                DW      OFFSET  @szCode059
                DW      OFFSET  @szCode060
                DW      OFFSET  @szCode061
                DW      OFFSET  @szCode062
                DW      OFFSET  @szCode063
                DW      OFFSET  @szCode064
                DW      OFFSET  @szCode065
                DW      OFFSET  @szCode066
                DW      OFFSET  @szCode067
                DW      OFFSET  @szCode068
                DW      OFFSET  @szCode069
                DW      OFFSET  @szCode070
                DW      OFFSET  @szCode071
                DW      OFFSET  @szCode072
                DW      OFFSET  @szCode073
                DW      OFFSET  @szCode074
                DW      OFFSET  @szCode075
                DW      OFFSET  @szCode076
                DW      OFFSET  @szCode077
                DW      OFFSET  @szCode078
                DW      OFFSET  @szCode079
                DW      OFFSET  @szCode080
                DW      OFFSET  @szCode081
                DW      OFFSET  @szCode082
                DW      OFFSET  @szCode083
                DW      OFFSET  @szCode084
                DW      OFFSET  @szCode085
                DW      OFFSET  @szCode086
                DW      OFFSET  @szCode087
                DW      OFFSET  @szCode088
                DW      OFFSET  @szCode089
                DW      OFFSET  @szCode090
                DW      OFFSET  @szCode091
                DW      OFFSET  @szCode092
                DW      OFFSET  @szCode093
                DW      OFFSET  @szCode094
                DW      OFFSET  @szCode095
                DW      OFFSET  @szCode096
                DW      OFFSET  @szCode097
                DW      OFFSET  @szCode098
                DW      OFFSET  @szCode099
                DW      OFFSET  @szCode100
                DW      OFFSET  @szCode101
                DW      OFFSET  @szCode102
                DW      OFFSET  @szCode103
                DW      OFFSET  @szCode104
                DW      OFFSET  @szCode105
                DW      OFFSET  @szCode106
                DW      OFFSET  @szCode107
                DW      OFFSET  @szCode108
                DW      OFFSET  @szCode109
                DW      OFFSET  @szCode110
                DW      OFFSET  @szCode111
                DW      OFFSET  @szCode112
                DW      OFFSET  @szCode113
                DW      OFFSET  @szCode114
                DW      OFFSET  @szCode115
                DW      OFFSET  @szCode116
                DW      OFFSET  @szCode117
                DW      OFFSET  @szCode118
                DW      OFFSET  @szCode119
                DW      OFFSET  @szCode120
                DW      OFFSET  @szCode121
                DW      OFFSET  @szCode122
                DW      OFFSET  @szCode123
                DW      OFFSET  @szCode124
                DW      OFFSET  @szCode125
                DW      OFFSET  @szCode126
                DW      OFFSET  @szCode127
                DW      OFFSET  @szCode128
                DW      OFFSET  @szCode129
                DW      OFFSET  @szCode130
                DW      OFFSET  @szCode131
                DW      OFFSET  @szCode132
                DW      OFFSET  @szCode133
                DW      OFFSET  @szCode134
                DW      OFFSET  @szCode135
                DW      OFFSET  @szCode136
                DW      OFFSET  @szCode137
                DW      OFFSET  @szCode138
                DW      OFFSET  @szCode139
                DW      OFFSET  @szCode140
                DW      OFFSET  @szCode141
                DW      OFFSET  @szCode142
                DW      OFFSET  @szCode143
                DW      OFFSET  @szCode144
                DW      OFFSET  @szCode145
                DW      OFFSET  @szCode146
                DW      OFFSET  @szCode147
                DW      OFFSET  @szCode148
                DW      OFFSET  @szCode149
                DW      OFFSET  @szCode150
                DW      OFFSET  @szCode151
                DW      OFFSET  @szCode152
                DW      OFFSET  @szCode153
                DW      OFFSET  @szCode154
                DW      OFFSET  @szCode155
                DW      OFFSET  @szCode156
                DW      OFFSET  @szCode157
                DW      OFFSET  @szCode158
                DW      OFFSET  @szCode159
                DW      OFFSET  @szCode160
                DW      OFFSET  @szCode161
                DW      OFFSET  @szCode162
                DW      OFFSET  @szCode163
                DW      OFFSET  @szCode164
                DW      OFFSET  @szCode165
                DW      OFFSET  @szCode166
                DW      OFFSET  @szCode167
                DW      OFFSET  @szCode168
                DW      OFFSET  @szCode169
                DW      OFFSET  @szCode170
                DW      OFFSET  @szCode171
                DW      OFFSET  @szCode172
                DW      OFFSET  @szCode173
                DW      OFFSET  @szCode174
                DW      OFFSET  @szCode175
                DW      OFFSET  @szCode176
                DW      OFFSET  @szCode177
                DW      OFFSET  @szCode178
                DW      OFFSET  @szCode179
                DW      OFFSET  @szCode180
                DW      OFFSET  @szCode181
                DW      OFFSET  @szCode182
                DW      OFFSET  @szCode183
                DW      OFFSET  @szCode184
                DW      OFFSET  @szCode185
                DW      OFFSET  @szCode186
                DW      OFFSET  @szCode187
                DW      OFFSET  @szCode188
                DW      OFFSET  @szCode189
                DW      OFFSET  @szCode190
                DW      OFFSET  @szCode191
                DW      OFFSET  @szCode192
                DW      OFFSET  @szCode193
                DW      OFFSET  @szCode194
                DW      OFFSET  @szCode195
                DW      OFFSET  @szCode196
                DW      OFFSET  @szCode197
                DW      OFFSET  @szCode198
                DW      OFFSET  @szCode199
                DW      OFFSET  @szCode200
                DW      OFFSET  @szCode201
                DW      OFFSET  @szCode202
                DW      OFFSET  @szCode203
                DW      OFFSET  @szCode204
                DW      OFFSET  @szCode205
                DW      OFFSET  @szCode206
                DW      OFFSET  @szCode207
                DW      OFFSET  @szCode208
                DW      OFFSET  @szCode209
                DW      OFFSET  @szCode210
                DW      OFFSET  @szCode211
                DW      OFFSET  @szCode212
                DW      OFFSET  @szCode213
                DW      OFFSET  @szCode214
                DW      OFFSET  @szCode215
                DW      OFFSET  @szCode216
                DW      OFFSET  @szCode217
                DW      OFFSET  @szCode218
                DW      OFFSET  @szCode219
                DW      OFFSET  @szCode220
                DW      OFFSET  @szCode221
                DW      OFFSET  @szCode222
                DW      OFFSET  @szCode223
                DW      OFFSET  @szCode224
                DW      OFFSET  @szCode225
                DW      OFFSET  @szCode226
                DW      OFFSET  @szCode227
                DW      OFFSET  @szCode228
                DW      OFFSET  @szCode229
                DW      OFFSET  @szCode230
                DW      OFFSET  @szCode231
                DW      OFFSET  @szCode232
                DW      OFFSET  @szCode233
                DW      OFFSET  @szCode234
                DW      OFFSET  @szCode235
                DW      OFFSET  @szCode236
                DW      OFFSET  @szCode237
                DW      OFFSET  @szCode238
                DW      OFFSET  @szCode239
                DW      OFFSET  @szCode240
                DW      OFFSET  @szCode241
                DW      OFFSET  @szCode242
                DW      OFFSET  @szCode243
                DW      OFFSET  @szCode244
                DW      OFFSET  @szCode245
                DW      OFFSET  @szCode246
                DW      OFFSET  @szCode247
                DW      OFFSET  @szCode248
                DW      OFFSET  @szCode249
                DW      OFFSET  @szCode250
                DW      OFFSET  @szCode251
                DW      OFFSET  @szCode252
                DW      OFFSET  @szCode253
                DW      OFFSET  @szCode254
                DW      OFFSET  @szCode255


{ Runtime error messages for specific codes }

@szCode000:
@szCode014:
@szCode040:
@szCode041:
@szCode042:
@szCode043:
@szCode044:
@szCode045:
@szCode046:
@szCode047:
@szCode048:
@szCode049:
@szCode075:
@szCode076:
@szCode077:
@szCode078:
@szCode079:
@szCode082:
@szCode094:
@szCode096:
@szCode097:
@szCode098:
@szCode099:
@szCode166:
@szCode167:
@szCode168:
@szCode169:
@szCode170:
@szCode171:
@szCode172:
@szCode173:
@szCode174:
@szCode175:
@szCode176:
@szCode177:
@szCode178:
@szCode179:
@szCode217:
@szCode218:
@szCode219:
@szCode220:
@szCode221:
@szCode222:
@szCode223:
@szCode224:
@szCode225:
@szCode226:
@szCode227:
@szCode228:
@szCode229:
@szCode235:
@szCode236:
@szCode237:
@szCode238:
@szCode239:
@szCode241:
@szCode242:
@szCode243:
@szCode244:
@szCode245:
@szCode246:
@szCode247:
@szCode248:
@szCode249:
@szCode250:
@szCode251:
@szCode252:
@szCode253:
@szCode254:
@szCode255:
                DB      'Unknown',0

{ Standard DOS/OS2/LAN errors }

@szCode001:
                DB      'Invalid function number',0
@szCode002:
                DB      'File not found',0
@szCode003:
                DB      'Path not found',0
@szCode004:
                DB      'Too many open file',0
@szCode005:
                DB      'File access denied',0
@szCode006:
                DB      'Invalid file handle',0
@szCode007:
                DB      'Memory control blocks destroyed',0
@szCode008:
                DB      'Insufficient memory',0
@szCode009:
                DB      'Invalid memory block address',0
@szCode010:
                DB      'Invalid environment',0
@szCode011:
                DB      'Invalid format',0
@szCode012:
                DB      'Invalid file access code',0
@szCode013:
                DB      'Invalid data',0
@szCode015:
                DB      'Invalid drive number',0
@szCode016:
                DB      'Cannot remove current directory',0
@szCode017:
                DB      'Not same device for action',0
@szCode018:
                DB      'No more files',0
@szCode019:
                DB      'Write protect error',0
@szCode020:
                DB      'Invalid unit',0
@szCode021:
                DB      'Not ready',0
@szCode022:
                DB      'Invalid device request',0
@szCode023:
                DB      'Data error',0
@szCode024:
                DB      'Invalid device request parameters',0
@szCode025:
                DB      'Seek error',0
@szCode026:
                DB      'Invalid media type',0
@szCode027:
                DB      'Sector not found',0
@szCode028:
                DB      'Printer out of paper error',0
@szCode029:
                DB      'Write fault error',0
@szCode030:
                DB      'Read fault error',0
@szCode031:
                DB      'General failure',0
@szCode032:
                DB      'Sharing violation',0
@szCode033:
                DB      'Lock violation',0
@szCode034:
                DB      'Invalid disk change',0
@szCode035:
                DB      'FCB unavailable',0
@szCode036:
                DB      'System resource exhausted',0
@szCode037:
                DB      'Code page mismatch',0
@szCode038:
                DB      'Out of input',0
@szCode039:
                DB      'Insufficient disk space',0
@szCode050:
                DB      'Network request not supported',0
@szCode051:
                DB      'Remote computer not listening',0
@szCode052:
                DB      'Duplicate name on network',0
@szCode053:
                DB      'Network path not found',0
@szCode054:
                DB      'Network busy',0
@szCode055:
                DB      'Network device no longer exists',0
@szCode056:
                DB      'NETBIOS command limit exceeded',0
@szCode057:
                DB      'System error; NETBIOS error',0
@szCode058:
                DB      'Incorrect response from network',0
@szCode059:
                DB      'Unexpected network error',0
@szCode060:
                DB      'Incompatible remote adapter',0
@szCode061:
                DB      'Print queue full',0
@szCode062:
                DB      'Not enough space for print file',0
@szCode063:
                DB      'Print file was canceled',0
@szCode064:
                DB      'Network name was deleted',0
@szCode065:
                DB      'Access denied',0
@szCode066:
                DB      'Network device type incorrect',0
@szCode067:
                DB      'Network name not found',0
@szCode068:
                DB      'Network name limit exceeded',0
@szCode069:
                DB      'NETBIOS session limit exceeded',0
@szCode070:
                DB      'Sharing temporarily paused',0
@szCode071:
                DB      'Network request not accepted',0
@szCode072:
                DB      'Print or disk redirection is paused',0
@szCode073:
                DB      'Netbeui not loaded',0
@szCode074:
                DB      'Unexpected adapter close',0
@szCode080:
                DB      'File exists',0
@szCode081:
                DB      'Cannot make directory entry',0
@szCode083:
                DB      'Fail on INT 24',0
@szCode084:
                DB      'Too many redirections',0
@szCode085:
                DB      'Duplicate redirection',0
@szCode086:
                DB      'Invalid password',0
@szCode087:
                DB      'Invalid parameter',0
@szCode088:
                DB      'Network data fault',0
@szCode089:
                DB      'Function not supported by network',0
@szCode090:
                DB      'Required system component not installed',0
@szCode091:
                DB      'Timer service table overflow',0
@szCode092:
                DB      'Timer service table duplicate',0
@szCode093:
                DB      'No items to operate upon',0
@szCode095:             
                DB      'Interrupted system call',0

{ Defined Turbo runtime errors }

@szCode100:
                DB      'Disk read error',0
@szCode101:
                DB      'Disk write error',0
@szCode102:
                DB      'File not assigned',0
@szCode103:
                DB      'File not open',0
@szCode104:
                DB      'File not open for input',0
@szCode105:
                DB      'File not open for output',0
@szCode106:
                DB      'Invalid numeric format',0

{ Standard DOS/OS2/LAN errors }
                
@szCode107:
                DB      'Insert disk b into drive a',0
@szCode108:
                DB      'Drive locked by another process',0
@szCode109:
                DB      'Write on pipe with no reader',0
@szCode110:
                DB      'Open or create failed due expicit fail command',0
@szCode111:
                DB      'Too small buffer on system call',0
@szCode112:
                DB      'No enough space on the disk',0
@szCode113:
                DB      'No more search handles',0
@szCode114:
                DB      'Invalid target handle',0
@szCode115:
                DB      'Bad user virtual address',0
@szCode116:
                DB      'Invalid keyboard request',0
@szCode117:
                DB      'Invalid category for DEVIOCTL',0
@szCode118:
                DB      'Invalid verify switch',0
@szCode119:
                DB      'Driver is not of four level',0
@szCode120:
                DB      'Call not implemented',0
@szCode121:
                DB      'Timeout happened from semaphore',0
@szCode122:
                DB      'Insufficient buffer',0
@szCode123:
                DB      'Invalid name',0
@szCode124:
                DB      'Invalid level',0
@szCode125:
                DB      'No volume label',0
@szCode126:
                DB      'Mode not found',0
@szCode127:
                DB      'Procedure not found',0
@szCode128:
                DB      'Wait no children',0
@szCode129:
                DB      'Child not complete',0
@szCode130:
                DB      'Invalid handle operation for direct disk access',0
@szCode131:
                DB      'Negative offset for seek',0
@szCode132:
                DB      'Seek on device or pipe',0
@szCode133:
                DB      'Target is joined',0
@szCode134:
                DB      'Object is joined',0
@szCode135:
                DB      'Object is substituted',0
@szCode136:
                DB      'Object not joined',0
@szCode137:
                DB      'Object not substituted',0
@szCode138:
                DB      'Join to join',0
@szCode139:
                DB      'Subst to subst',0
@szCode140:
                DB      'Join to subst',0
@szCode141:
                DB      'Subst to join',0
@szCode142:
                DB      'Drive busy',0
@szCode143:
                DB      'Same drive',0
@szCode144:
                DB      'Not root directory',0
@szCode145:
                DB      'Directory not empty',0
@szCode146:
                DB      'Path is substituted',0
@szCode147:
                DB      'Path is joined',0
@szCode148:
                DB      'Path busy',0
@szCode149:
                DB      'Target is substituted',0

{ Defined Turbo runtime errors }
                                
@szCode150:
                DB      'Disk is write-protected',0
@szCode151:
                DB      'Bad drive request struct length',0
@szCode152:
                DB      'Drive not ready',0

{ Standard DOS/OS2/LAN errors }

@szCode153:
                DB      'Invalid format of list',0

{ Defined Turbo runtime errors }
                
@szCode154:
                DB      'CRC error in data',0

{ Standard DOS/OS2/LAN errors }

@szCode155:
                DB      'Too many TCBs',0

{ Defined Turbo runtime errors }
                
@szCode156:
                DB      'Disk seek error',0
@szCode157:
                DB      'Unknown media type',0
@szCode158:
                DB      'Sector Not Found',0
@szCode159:
                DB      'Printer out of paper',0
@szCode160:
                DB      'Device write fault',0
@szCode161:
                DB      'Device read fault',0
@szCode162:
                DB      'Hardware failure',0

{ Standard DOS/OS2/LAN errors }

@szCode163:
                DB      'Uncertain media',0
@szCode164:
                DB      'Max THRDs reached',0
@szCode165:
                DB      'Monitors not supported',0
@szCode180:
                DB      'Invalid segment number',0
@szCode181:
                DB      'Invalid callgate',0
@szCode182:
                DB      'Invalid ordinal',0
@szCode183:
                DB      'Already exists',0
@szCode184:
                DB      'No child process',0
@szCode185:
                DB      'Child alive nowait',0
@szCode186:
                DB      'Invalid flag number',0
@szCode187:
                DB      'Semaphore not found',0
@szCode188:
                DB      'Invalid starting CODESEG',0
@szCode189:
                DB      'Invalid STACKSEG',0
@szCode190:
                DB      'Invalid module type',0
@szCode191:
                DB      'Invalid EXE-signature',0
@szCode192:
                DB      'EXE marked as invalid',0
@szCode193:
                DB      'Bad EXE format',0
@szCode194:
                DB      'Iterated data exceeds 64K',0
@szCode195:
                DB      'Invalid MINALLOCSIZE',0
@szCode196:
                DB      'Dynamic link from invalid ring',0
@szCode197:
                DB      'IOPL not enabled',0
@szCode198:
                DB      'Invalid segment DPL',0
@szCode199:
                DB      'AUTODATASEF exceeds 64K',0

{ Defined Turbo runtime errors }
                                
@szCode200:
                DB      'Division by zero',0
@szCode201:
                DB      'Range check error',0
@szCode202:
                DB      'Stack overflow error',0
@szCode203:
                DB      'Heap overflow error',0
@szCode204:
                DB      'Invalid pointer operation',0
@szCode205:
                DB      'Floating point overflow',0
@szCode206:
                DB      'Floating point underflow',0
@szCode207:
                DB      'Invalid floating point operation',0
@szCode208:
                DB      'Overlay manager not installed',0
@szCode209:
                DB      'Overlay file read error',0
@szCode210:
                DB      'Object not initialized',0
@szCode211:
                DB      'Call to abstract method',0
@szCode212:
                DB      'Stream registration error',0
@szCode213:
                DB      'Collection index out of range',0
@szCode214:
                DB      'Collection overflow error',0
@szCode215:
                DB      'Arithmetic overflow error',0
@szCode216:
                DB      'General Protection fault',0

{ Standard DOS/OS2/LAN errors }

@szCode230:
                DB      'Non-existent pipe or invalid operation',0
@szCode231:
                DB      'Specified pipe busy',0
@szCode232:
                DB      'No data on non-blocking read',0
@szCode233:
                DB      'Pipe disconnected by Server',0
@szCode234:
                DB      'More data available',0
@szCode240:
                DB      'Session was canceled',0
                

{ Purpose: Print string                    }
{ Enter:   CS:BX -> null-terminated string }

@PrintString:
                mov     al, cs:[bx]
                or      al, al
                jz      @PrintStringDone
                call    @PrintChar
                inc     bx
                jmp     @PrintString
@PrintStringDone:
                retn


{$IFDEF   AddMapErr}

{ Purpose: Print word in decimal }
{ Enter:   AX = Value to print   }

@szStoreDecNum:
        DB      0,0,0,0,0

@PrintDecValueInAX:
                mov     bx, ax                  {save line}
                mov     ax, cs
{$IFDEF DPMI}
                add     ax, SelectorInc
{$ENDIF}
                mov     es, ax
                mov     ax, bx                  {line back}
                mov     bx, (OFFSET @szStoreDecNum)
                mov     di, 5                   {range 1-65535}
                mov     cx,  10                 {base}
@MoreHighDigit:
                sub     dx, dx
                div     cx
                dec     di
                mov     es:[bx][di], dl         {no update of FLAGS}
                jnz    @MoreHighDigit
                mov     ch, 0                   {flag to skip first zeroes}
                mov     di, 5
@DispNextDecDigit:
                mov     al, es:[bx]
                mov     ah, al
                or      ah, ch                  {check this flag}
                jz     @AdvanceCounters
                inc     ch                      {print any other zeroes}
@AddDigitZero:
                add     al, '0'
                call    @PrintChar
@AdvanceCounters:
                inc     bx
                dec     di
                jnz    @DispNextDecDigit
                retn
{$ENDIF} {AddMapErr}


{ Purpose: Print byte in decimal }
{ Enter:   AL = Value to print   }

@PrintDecValueInAL:
                mov     cx, (0 SHL 8) + 100        {0=skip if zero}
                call    @DispRemainder
                mov     cl,  10                    {CH=display count}
                call    @DispRemainder
                JMP     @DispDigit
@DispRemainder:
                xor     ah, ah
                div     cl
                or      ch, al
                jz      @PrintDecDone
                inc     ch                         {display middle digit}
@DispDigit:
                add     al, '0'
                push    ax
                call    @PrintChar
                pop     ax
@PrintDecDone:
                mov     al, ah
                retn


{ Purpose: Print word in hex   }
{ Enter:   AX = Value to print }

@PrintHexWord:
                push    ax
                mov     al, ah
                call    @PrintHexByte
                pop     ax
@PrintHexByte:
                push    ax
                shr     al, 1
                shr     al, 1
                shr     al, 1
                shr     al, 1
                CALL    @PrintHexDigit
                pop     ax
                and     al, 0Fh
@PrintHexDigit:
                add     al, '0'
                cmp     al, '0'+10
                jb      @PrintChar
                add     al,'A'-'0'-10


{ Purpose:  Print character }
{ Enter:    AL = Character  }

@PrintChar:
                mov     dl, al
                mov     ah, 6                   {DOS console echo}
                int     21h
                retn


{ Runtime error handler slightly borrowed from Borland Inc. }

@DispErrorAddress:
                mov     ax, WORD PTR ErrorAddr+0     {Runtime error?}
                or      ax, WORD PTR ErrorAddr+2
                jz      @NoDispErr

{$IFDEF   AddMapErr}
                mov     bx, OFFSET @szMapErr1        {header}
                call    @PrintString

                mov     bx, OFFSET @szMapErr2        {source file}
                call    @PrintString

                mov     cx, WORD PTR ErrorAddr+0     {offset}
                mov     dx, WORD PTR ErrorAddr+2     {segment}
                call    _MapTError                   {BX<-filename;AX<-linenum}
                                                     {DX<-linemsg}
                push    ax
                push    dx
                call    @PrintString                 {filename or none}

                mov     bx, OFFSET @szMapErr4        {CR/LF}
                call    @PrintString

                mov     bx, OFFSET @szMapErr3        {source line}
                call    @PrintString

                pop     dx                           {point to exact place}
                mov     bx, dx
                call    @PrintString

                pop     ax                           {line number}
                or      ax, ax                       {skip if zero found}
                jz     @NoneLineNum
                call    @PrintDecValueInAX
@NoneLineNum:
                mov     bx, OFFSET @szMapErr4        {CR/LF}
                call    @PrintString
{$ENDIF} {AddMapErr}

                mov     bx ,OFFSET @szError1         {Print error message}
                call    @PrintString

                mov     ax, ExitCode                 {System unit}
                call    @PrintDecValueInAL

                mov     bx ,OFFSET @szError2
                call    @PrintString

                mov     bx, ExitCode                 {System Unit}
                sub     bh, bh                       {range 0-255}
                shl     bx, 1
                mov     bx, cs:[OFFSET @dwCodeTable].[bx]
                call    @PrintString

                mov     bx ,OFFSET @szError3
                call    @PrintString

                mov     ax, WORD PTR ErrorAddr+2     {System unit}
                call    @PrintHexWord                {segment value}

                mov     al,':'                       {delimiter}
                call    @PrintChar

                mov     ax, WORD PTR ErrorAddr+0     {System unit}
                CALL    @PrintHexWord                {offset value}

                mov     bx ,OFFSET @szError4
                call    @PrintString

                sub     ax, ax
                mov     WORD PTR ErrorAddr+0, ax     {Set to NIL}
                mov     WORD PTR ErrorAddr+2, ax

                push    cs                           {Recover chain of ExitCode}
                call    NEAR PTR  _UnInstallErrorHandler
@NoDispErr:
                                                     {Back to Turbo}
@CallErrorTrap:
                mov    ax, WORD PTR TrapProc+0       {Trap installed?}
                or     ax, WORD PTR TrapProc+2       {Avoid endless loop!}
                jz    @NoTrap

                push   di                   {Check for default trap handler}
                push   es
                les    di, TrapProc                  {Check signature}
                add    di, 3                         {Skip near CALL instruction}
                cmp    WORD PTR es:[di+0], 'T$'      {'$TRAP$,0}
                jne   @CheckDefaultDone
                cmp    WORD PTR es:[di+2], 'AR'
                jne   @CheckDefaultDone
                cmp    WORD PTR es:[di+4], '$P'
                jne   @CheckDefaultDone
                add    di, 7                         {Skip signature}
                mov    BYTE PTR es:[di], 1           {1=flag to call, 0=normal execution}
@CheckDefaultDone:
                pop    di
                pop    es
@RealTrapCall:
                call   DWORD Ptr [TrapProc]          {Run trap mechanism}
                jmp   @CallErrorTrap
@NoTrap:
{$IFDEF   AddMapErr}

                retf
@SearchMapID:
    DB    'INFMAP'       {DON'T TOUCH, it will be used as marker for MAP2EXE}
@MapInfoSize:
        DW      aMap2K+aMap4K+aMap8K+aMap16K+aMap24K+aMap32K+aMap40K+aMap48K

{$ENDIF} {AddMapErr}

END;  { RunTimeErrorHandler }
{asm-end}


{$IFDEF   AddMapErr}

PROCEDURE  _SrcInfoMap1; near; assembler;
{* Reserve space for program map information. *}
ASM

{$IFDEF  DebugVersion}
{$IFDEF  DPMI}
  {source file information}
        DW      0       {next record link field}
        DW      1       {PM segment of unit}
        DW      20      {table for line numbers}
        DB      'RUNERROR.PAS',0,0
  {line number, offset}
        DW       7,  $43
        DW       8,  $5C
        DW       9,  $77
        DW      10,  $92
        DW      11,  $A9
        DW      12,  $B1
        DW      0,   $00
{$ELSE}
  {source file information}
        DW      0       {next record link field}
        DW      0       {segment of unit}
        DW      20      {table for line numbers}
        DB      'RUNERROR.PAS',0,0
  {line number, offset}
        DW       7,  $41
        DW       8,  $55
        DW       9,  $71
        DW      10,  $8D
        DW      11,  $A4
        DW      12,  $AC
        DW      0,   $00
{$ENDIF} {DPMI}
{$ELSE}
        DW      -1      {no records}
{$ENDIF} {DebugVersion}

{!!must be aligned on double word boundary!!}

{$IFDEF   Map2KB}
    { 2048 DB (0); each line contains 32 DWords(128 bytes) }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
{$ENDIF} {Map2KB}

{$IFDEF   Map4KB}
    { 2048 DB (0); each line contains 32 DWords(128 bytes) }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
{$ENDIF} {Map4KB}

{$IFDEF   Map8KB}
    { 4096 DB (0); each line contains 32 DWords(128 bytes) }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
{$ENDIF} {Map8KB}

{$IFDEF   Map16KB}
    { 8192 DB (0); each line contains 32 DWords(128 bytes) }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
{$ENDIF} {Map16KB}

{$IFDEF   Map24KB}
    { 8192 DB (0); each line contains 32 DWords(128 bytes) }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
{$ENDIF} {Map24KB}

{$IFDEF   Map32KB}
{$ENDIF} {Map32KB}
{$IFDEF   Map40KB}
{$ENDIF} {Map40KB}
{$IFDEF   Map48KB}
{$ENDIF} {Map48KB}

   nop    {align on double word boundary}
   nop
   nop

END;  { _SrcInfoMap1 }
{asm-end}


PROCEDURE  _SrcInfoMap2; near; assembler;
{* Reserve space for program map information. *}
ASM

{$IFDEF   Map2KB}
{$ENDIF} {Map2KB}
{$IFDEF   Map4KB}
{$ENDIF} {Map4KB}
{$IFDEF   Map8KB}
{$ENDIF} {Map8KB}
{$IFDEF   Map16KB}
{$ENDIF} {Map16KB}
{$IFDEF   Map24KB}
{$ENDIF} {Map24KB}

{$IFDEF   Map32KB}
    { 8192 DB (0); each line contains 32 DWords(128 bytes) }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
{$ENDIF} {Map32KB}

{$IFDEF   Map40KB}
    { 8192 DB (0); each line contains 32 DWords(128 bytes) }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
{$ENDIF} {Map40KB}

{$IFDEF   Map48KB}
    { 8192 DB (0); each line contains 32 DWords(128 bytes) }
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DD   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
{$ENDIF} {Map48KB}
   nop    {align on double word boundary}
   nop
   nop

END;  { _SrcInfoMap2 }
{asm-end}


PROCEDURE  _MapTError; assembler;
{* Enter:  DX = segment value of runtime error location *}
{*         CX =  offset value of runtime error location *}
{* Description: None                                    *}
ASM
        jmp   @FindSrcErrLoc
        nop
        nop

@SrcOfs1:
        DW      OFFSET _SrcInfoMap1
@SrcOfs2:
        DW      OFFSET _SrcInfoMap2
@szNoneFile:
        DB      'none',0
@szLineNumberEqual:
        DB      'equal to ',0
@szLineNumberBelow:
        DB      'below than ',0
@szLineNumberNotFound:
        DB      'not found',0

@FindSrcErrLoc:
                mov     ax, cs
{$IFDEF DPMI}
                add     ax, SelectorInc
{$ENDIF}
                mov     es, ax
                mov     di, es:[OFFSET @SrcOfs2]
                mov     di, es:[OFFSET @SrcOfs1]

                mov     ax, es:[di][recSrcFileName.dwNextRecLink]
                cmp     ax, -1                {first check for empty records}
                je     @FileNameNotFound

                mov     si, di                {SI as base}

@LookSrcFileRecord:
                mov     ax, es:[di][recSrcFileName.dwThisCodeSeg]
                cmp     ax, dx                  {same segment?}
                jne    @TakeNextRecordLink

                mov     bx, di
                add     bx, (recSrcFileName.szFileName)

                mov     ax, es:[di][recSrcFileName.dwLinesTableLink]
                or      ax, ax                 {empty lines table}
                jz     @NoneLineMsg

@GetNextLineNum:
                add     di, ax
                mov     ax, es:[di][recLocOfLineNum.dwLineNum]
                mov     dx, es:[di][recLocOfLineNum.dwLoc]

                or      ax, ax                  {end of lines table?}
                jz     @NoneLineMsg

                cmp     cx, dx
                je     @FoundExactly            {point to exact place!}
                jb     @FoundBelow              {already passed?}

                mov     ax, 4                   {2 words}
                jmp    @GetNextLineNum

@FoundExactly:
                mov     dx, OFFSET @szLineNumberEqual
                jmp    @SearchDone

@FoundBelow:
                mov     dx, OFFSET @szLineNumberBelow
                jmp    @SearchDone

@TakeNextRecordLink:
                mov     ax, es:[di][recSrcFileName.dwNextRecLink]
                or      ax, ax                      {end of records?}
                jz     @FileNameNotFound
                mov     di, si                      {restore base}
                add     di, ax                      {add relative offset}
                jmp    @LookSrcFileRecord

@FileNameNotFound:
                mov     bx, OFFSET @szNoneFile

@LineNumNotFound:
                sub     ax, ax          {AX<-0}

@NoneLineMsg:
                mov     dx, OFFSET @szLineNumberNotFound

@SearchDone:

END;  { _MapTError }
{asm-end}

{$ENDIF} {AddMapErr}



PROCEDURE       _InstallErrorHandler;
{* Installs new error handler. *}
BEGIN
  glpOldExitProc := System.ExitProc;
  System.ExitProc := @RunTimeErrorHandler;
END; { _InstallErrorHandler }



PROCEDURE       _UnInstallErrorHandler;
{* Restores old error handler and effectively deinstalls our or any *}
{* error handler installed after us. *}
BEGIN
  System.ExitProc := glpOldExitProc;
END; { _UnInstallErrorHandler }



BEGIN
  _InstallErrorHandler;
END.
