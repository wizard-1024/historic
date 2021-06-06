{ Test programs for TYPIST }

PROGRAM  Test1;

VAR
 sTempInput, sSrchPattern : string;
 dwStrLen : word;

PROCEDURE   _FindMatchEntryInDictionary(sSearchWord : STRING;
                                        dwSearchWordLen :  System.Word;
                                        VAR  sFoundEntry : STRING;
                                        VAR  dwFoundEntryLen : System.Word);
{* Search dictionaries for match user input. *}
VAR
  dwFoundEntryBufSeg,
  dwFoundEntryBufOfs,
  dwFoundEntryBufSize   :   System.Word;
  dbCount               :   System.Byte;
  bResultOk             :   System.Boolean;

BEGIN
     bResultOk := System.False;
     sFoundEntry := '';
     dwFoundEntryLen := 0;
     dwFoundEntryBufSeg := System.Seg(sSearchWord[1]);
     dwFoundEntryBufOfs := System.Ofs(sSearchWord[1]);
     ASM
            mov     es, dwFoundEntryBufSeg
            mov     bx, dwFoundEntryBufOfs
            mov     cx, dwSearchWordLen
            mov     ah, $C0
            mov     al, 8
            int	    $2F
            cmp     al, 0
            jne    @Done
            mov     bResultOk, System.True
            mov     dwFoundEntryBufSize, cx
            mov     dwFoundEntryBufOfs, bx
            mov     dwFoundEntryBufSeg, es
       @Done:
     END;
     IF  (bResultOk)
         THEN  BEGIN
            dbCount := System.Lo(dwFoundEntryBufSize);
            dwFoundEntryLen := dwFoundEntryBufSize;
            System.Move(System.Mem[dwFoundEntryBufSeg:dwFoundEntryBufOfs],sFoundEntry[1],dbCount);
            sFoundEntry[0] := System.Char(dbCount);
               END
         ELSE  BEGIN
	               Halt(1);
               END;
     {if-then-else}
END;  { _FindMatchEntryInDictionary }

BEGIN
    sSrchPattern := '_u' {'al^$#' '#*/%!eLl' '#*/!fan'};
    writeln('User input pattern: '+sSrchPattern);
    _FindMatchEntryInDictionary(sSrchPattern,System.Length(sSrchPattern),
                                sTempInput,dwStrLen);
   writeln('Found string:   ',sTempInput);
END.