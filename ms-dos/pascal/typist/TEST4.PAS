{ Test programs for TYPIST }

PROGRAM  Test1;

VAR
 sTempInput, sSrchPattern : string;
 dwStrLen : word;
 dbStatus : byte;


PROCEDURE
         _AddNewEntryInDictionary(sAddEntry : STRING;
			          dwAddWordLen :  System.Word;
				  VAR  dbStatusCode : System.Byte);
{*
Description.
     Adds the new entry for the current resident dictionary.
*}
VAR
  dwAddEntryBufSeg,
  dwAddEntryBufOfs,
  dwAddEntryBufSize     :   System.Word;
  dbResultCode          :   System.Byte;
  bResultOk             :   System.Boolean;

BEGIN
     bResultOk := System.False;
     dwAddEntryBufSeg := System.Seg(sAddEntry[1]);
     dwAddEntryBufOfs := System.Ofs(sAddEntry[1]);
     ASM
            mov     es, dwAddEntryBufSeg
            mov     bx, dwAddEntryBufOfs
            mov     cx, dwAddWordLen
            mov     ah, $C0
            mov     al, $02
	    stc
	    int     $2F
            jc     @Done
            mov     bResultOk, System.True
            mov     dbResultCode, al
       @Done:
     END;
     IF  (bResultOk)
         THEN  BEGIN
            dbStatusCode := dbResultCode;
               END
         ELSE  BEGIN
          writeln('call failed');
	  halt(1);               
               END;
     {if-then-else}
END;
{ _AddNewEntryInDictionary }


BEGIN
    sSrchPattern := '~asm1~ ~MASM6~';
    writeln('User input pattern: '+sSrchPattern);
    _AddNewEntryInDictionary(sSrchPattern,System.Length(sSrchPattern),dbStatus);
   writeln('result code = ',dbStatus);
END.