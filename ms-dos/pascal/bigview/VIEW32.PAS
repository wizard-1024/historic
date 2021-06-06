{ Author: Dmitry Stefankov  }
{ Date:   17-Dec-95         }
PROGRAM  MemoryViewForSoCalledBigRealMode;

{$G+}

USES
   ShowTErr, XMSLIB;



CONST
   gliUserOfs32  :   Longint    = 0;
   gbStateOk     :   Boolean    =  false;
   gdwExtBlkSize :   Word       =  128;
   sTestBlk      :   STRING     =  'WIZARDxxx1995xxx';
   gbTurnOnA20   :   Boolean    =  false;

TYPE
  STR2      =     STRING[2];
  STR4      =     STRING[4];
  STR8      =     STRING[8];

VAR
   gsTemp,
   gsSymView     :   STRING;
   gliRow,
   gliCol        :   Longint;
   giErrorCode   :   Integer;
   gdwVersion    :   Word;
   gBlkHandle    :   THandle;
   gdbValue      :   Byte;
   gchSym        :   Char;


FUNCTION  _fndbReadByte32(liOfs32 : Longint) : byte; assembler;
ASM
   push  ds
   mov   bx, WORD PTR liOfs32+0   {low}
   mov   ax, WORD PTR liOfs32+2   {high}
   push  ax
   push  bx
   db    $66
   pop   bx
   mov   ax, 0
   mov   ds, ax
   db    $67, $8A, $03	    {mov  al, ds:[ebx]}
   pop  ds
END;


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


FUNCTION   _fnsDWordToHexFmt(liInput : System.Longint) : STR8;
{* Converts a double word to the hex format number representation. *}
BEGIN
  _fnsDWordToHexFmt := _fnsWordToHexFmt(liInput SHR 16) +
                      _fnsWordToHexFmt(liInput AND $0000FFFF);
END;  { _fnsDWordToHexFmt }


BEGIN
   WriteLn('32-bit Memory viewer (c) 1995 Dmitry Stefankov');

   ASM
       smsw  ax
       test  ax, 1
       jnz  @CheckDone
       mov   gbStateOk, true
     @CheckDone:
   END;

   IF NOT(gbStateOk)
     THEN  BEGIN
      WriteLn('Machine in V86 mode. Uninstall PM manager before use this viewer.');
      Halt(1);
           END;
   {if-then}

   IF  (XMS_Setup)
     THEN  BEGIN
        Write('XMS manager found;  ');
        gdwVersion := XMS_GetVersion(XMS);
        Write('std ver = ',Hi(gdwVersion),'.',Lo(gdwVersion),';  ');
        gdwVersion := XMS_GetVersion(XMM);
        Write('driver ver = ',Hi(gdwVersion),'.',Lo(gdwVersion),';  ');
        IF (XMS_QueryA20)
          THEN  WriteLn('A20 is on.')
          ELSE  BEGIN
            WriteLn('A20 is off.');
            gbTurnOnA20 := System.True;
            IF (XMS_LocalEnableA20 = 0)
              THEN  WriteLn('Local A20 is on.')
              ELSE  WriteLn('Local A20 is off.');
            {if-then-else}
            IF (XMS_QueryA20)
              THEN  WriteLn('A20 is on.')
              ELSE  WriteLn('A20 is off.')
            {if-then-else}
                END;
        {if-then-else}
        WriteLn('XMS free memory in KB = ',XMS_MemAvail);
        gBlkHandle := XMS_AllocEMB(gdwExtBlkSize);
        WriteLn('Alloc EMB block  (size =',gdwExtBlkSize,' KB)');
        IF (gBlkHandle = 0)
          THEN  WriteLn('Alloc call failed.')
          ELSE  BEGIN
             WriteLn('Alloc call successful. Copy block to extended memory.');
             gdbValue := XMS_MoveToEMB(gBlkHandle,
                                        sTestBlk,
                                        SizeOf(sTestBlk));
             IF (gdbValue = 0)
               THEN  WriteLn('Copy call successful.')
               ELSE  WriteLn('Copy call failed.');
             {if-then-else}
             IF (XMS_FreeEMB(gBlkHandle) <> 0)
               THEN  WriteLn('Free call failed.')
               ELSE  WriteLn('Free call successful.')
             {if-then-else}
                END;
        {if-then-else}
           END
     ELSE  WriteLn('No XMS manager found.');
   {if-then-else}
   Write('Enter offset: ');
   ReadLn(gsTemp);
   WHILE  (gsTemp <> 'q')  DO
   BEGIN
      IF (gsTemp <> '')
        THEN  Val(gsTemp,gliUserOfs32,giErrorCode)
        ELSE  giErrorCode := 0;
      IF  (giErrorCode <> 0)
        THEN  WriteLn('Wrong user input)')
        ELSE  BEGIN
          FOR  gliRow := 0 TO 15 DO
          BEGIN
            {gliUserOfs32 := gliUserOfs32 + gliRow * 16};
            gsSymView := '';
            Write(_fnsDWordToHexFmt(gliUserOfs32),'  ');
            FOR gliCol := 0 TO 15 DO
            BEGIN
               gdbValue := _fndbReadByte32(gliUserOfs32);
               Write(_fnsByteToHexFmt(gdbValue),' ');
               IF gdbValue IN [32..254]
                 THEN  gchSym := Char(gdbValue)
                 ELSE  gchSym := '.';
               {if-then-else}
               gsSymView := gsSymView + gchSym;
               System.Inc(gliUserOfs32);
            END;
            WriteLn(' ',gsSymView);
            {for-to-do}
          END;
          {for-to-do}
              END;
      {if-then-else}
      Write('Enter offset: ');
      ReadLn(gsTemp);
   END;
   {while-do}
   IF (gbTurnOnA20)
     THEN  BEGIN
       IF  (XMS_LocalDisableA20 = 0)
         THEN  WriteLn('Local A20 is off.')
         ELSE  WriteLn('Local A20 is on.');
       {if-then-else}
       IF (XMS_QueryA20)
         THEN  WriteLn('A20 is on.')
         ELSE  WriteLn('A20 is off.')
       {if-then-else}
           END;
   {if-then}
END.
