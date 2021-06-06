  {$I-,S-}

  {      ****************************************************
         *                                                  *
         *         Turbo Pascal 6.0  STRING  Unit           *
         *    Provides the access to the string functions   *
         *          Version  2.10      01/01/91             *
         *          written  by  Dima  Stefankov            *
         *                                                  *
         ****************************************************
  }

   unit   TpString;

   interface                  { public part }

     uses
       TpSystem;   { other  units }

      const
         DigitSet   :  set of char = ['0'..'9'];
         HexSet     :  set of char = ['0'..'9','A'..'F'];

      type
        AnyString      =     string[255];
	Str2	       =     string[2];
        Str3           =     string[3];
	Str4	       =     string[4];
        Str5           =     string[5];
        Str6           =     string[6];
        Str7           =     string[7];
        Str8           =     string[8];
        Str9           =     string[9];
        Str10          =     string[10];
        Str11          =     string[11];
        Str12          =     string[12];
        Str14          =     string[14];
        Str16          =     string[16];
        Str17          =     string[17];
        Str40          =     string[40];
        Str52          =     string[52];
        Str76          =     string[76];
        Str78          =     string[78];
        Str80          =     string[80];

      var
        TempStr1   :   AnyString  absolute  Input;
        TempStr2   :   AnyString  absolute  Output;

      { functions and procedures }

      function   HexNibble(Number : byte) : char;
      { return the hexadecimal representation of the lower nibble. }
      inline($58         {  pop  ax       ; AL = Number }
            /$24/$0F     {  and  al,15    ; mask 4 lower bits }
            /$04/$90     {  add  al,90h   ; this code supposed }
            /$27         {  daa           ; by Time Paterson }
            /$14/$40     {  adc  al,40h   ; }
            /$27);       {  daa           ; AL = Result }

      function   HexByte(Number : byte) : Str2;
      function   HexWord(Number : word) : Str4;
      function   LoCase(Ch : Char) : char;
      function   LenAsciiz(var S) : word;
      function   SearchPtr(Buffer : pointer; BufferLen : word;Match : pointer; MatchLen : word) : word;
      function   Search(var Buffer ; BufferLen : word;var Match ; MatchLen : word) : word;
      function   SearchString(Buffer : pointer; BufferLen : word;Match : AnyString) : word;
      procedure  AsciizString(var S);
      procedure  AscString(var S);
      procedure  UpCaseString(var S);
      procedure  LoCaseString(var S);
      function   StrFromAsciiz(var A) : AnyString;
      function   ByteToString(Num : byte) : Str3;
      function   IntegerToString(Num : integer; Width : byte) : Str5;
      function   WordToString(Num : word; Width : byte) : Str5;
      function   LongIntegerToString(Num : longint; Width : byte) : Str10;
      function   RealToString(R : real; Width, DecimalPlaces : byte) : AnyString;
      function   Decimal(I, Width : word; DoZero : boolean) : Str8;
      function   DeleteLeft(S : AnyString; Ch : char) : AnyString;
      function   DeleteRight(S : AnyString; Ch : char) : AnyString;
      function   LeftStr(S : AnyString; Count : integer) : AnyString;
      function   RightStr(S : AnyString; Count : integer) : AnyString;
      function   MidStr(S : AnyString; LeftPos,RightPos : integer) : AnyString;
      procedure  StringReverse(var S);
      procedure  StringDup(var S; StringSize : byte);
      procedure  ReplaceInBuffer(Buf : pointer; Count : word; Match : pointer; MatchLen : word;
              ReplaceStr : pointer; ReplaceLen : word; var ReplaceCount : word);
      function   HexPtr(P : pointer) : AnyString;
      function   CharStr(Ch : char; Len : byte) : AnyString;
      function   AsciizFromBuffer(P : pointer) : AnyString;
      procedure  OverWriteStr(Source : string; var S; Index : byte);
      function   BCDtoByte(Number : byte) : byte;
      function   PackedBCDtoByte(Number : byte) : byte;
      function   FilterAsciiString(S : AnyString; AsciiType : boolean) : AnyString;
      function   SearchFirstNoMatchStr(A : string; Count : word; Match : char) : word;
      function   HexCharToByte(Ch : char) : byte;
      function   HexStrToByte(S : Str2) : byte;
      function   HexStrToWord(S : Str4) : word;
      function   HexStrToCharStr(S : AnyString) : AnyString;

   function   GetHexStr(S : AnyString) : AnyString;
   { get only the hexadecimal string. }

      function   SearchFirstMatch(Buffer : pointer; Count : word; Match : char) : word;
      { search through Buffer for first matching char. }
      inline($58              {  pop  ax     ; AX = Match }
            /$59              {  pop  cx     ; CX = Count }
            /$5F              {  pop  di     ; DI = Ofs(Buffer) }
            /$07              {  pop  es     ; ES = Seg(Buffer) }
            /$8B/$DF          {  mov  bx,di  ; BX = Ofs(Buffer) }
            /$FC              {  cld         ; go forward }
            /$F2/$AE          {  repne scasb ; scan not equal }
            /$B8/$FF/$FF      {  mov  ax,-1  ; assume that not found }
            /$75/$05          {  jne  Done   ; yes, then done }
            /$4F              {  dec  di     ; back to char }
            /$8B/$C7          {  mov ax,di   ; prepare to subtract }
            /$2B/$C3);        {  sub ax,bx   ; - start. ofs }
                              { Done: }

      function   SearchLastMatch(Buffer : pointer; Count : word; Match : char) : word;
      { search through Buffer for last matching char. }
      inline($58              {  pop  ax     ; AL = Match }
            /$59              {  pop  cx     ; CX = count }
            /$5F              {  pop  di     ; DI = Ofs(Buffer) }
            /$07              {  pop  es     ; ES = Seg(Buffer) }
            /$8B/$DF          {  mov  bx,di  ; BX = starting offset }
            /$01/$CF          {  add  di,cx  ; DI = starting offset + count }
            /$4F              {  dec  di     ; DI points to last char }
            /$FD              {  std         ; go backward }
            /$F2/$AE          {  repne scasb ; scan not equal }
            /$B8/$FF/$FF      {  mov ax,-1   ; assume that fails }
            /$75/$05          {  jne Done    ; exit if not found }
            /$47              {  inc  di     ; back to char }
            /$8B/$C7          {  mov  ax,di  ; prepare to subtract }
            /$2B/$C3);        {  sub  ax,bx  ; - starting offset }
                              { Done: }

      function   SearchFirstNoMatch(Buffer : pointer; Count : word; Match : char) : word;
      { search through Buffer for first no matching char. }
      inline($58              {  pop  ax     ; AL = Match }
            /$59              {  pop  cx     ; CX = count }
            /$5F              {  pop  di     ; DI = Ofs(Buffer) }
            /$07              {  pop  es     ; ES = Seg(Buffer) }
            /$8B/$DF          {  mov  bx,di  ; BX = starting offset }
            /$FC              {  cld         ; go forward }
            /$F3/$AE          {  repe scasb  ; scan while equal }
            /$B8/$FF/$FF      {  mov ax,-1   ; assume that fails }
            /$74/$05          {  je Done     ; yes, then done }
            /$4F              {  dec  di     ; back to char }
            /$8B/$C7          {  mov  ax,di  ; prepare to subtract }
            /$2B/$C3);        {  sub  ax,bx  ; - starting offset }
                              { Done: }

      function   SearchLastNoMatch(Buffer : pointer; Count : word; Match : char) : word;
      { search through Buffer for last no matching char. }
      inline($58              {  pop  ax     ; AL = Match }
            /$59              {  pop  cx     ; CX = count }
            /$5F              {  pop  di     ; DI = Ofs(Buffer) }
            /$07              {  pop  es     ; ES = Seg(Buffer) }
            /$8B/$DF          {  mov  bx,di  ; BX = starting offset }
            /$01/$CF          {  add  di,cx  ; DI = starting offset + count }
            /$4F              {  dec  di     ; DI points to last char }
            /$FD              {  std         ; go backward }
            /$F3/$AE          {  repe scasb  ; scan while equal }
            /$B8/$FF/$FF      {  mov ax,0FFFFh ; assume that fails }
            /$74/$05          {  je Done     ; yes, then done }
            /$47              {  inc  di     ; back to char }
            /$8B/$C7          {  mov  ax,di  ; prepare to subtract }
            /$2B/$C3);        {  sub  ax,bx  ; - starting offset }
                              { Done: }

      function   BitByte(Number : byte;Zero,One : char) : Str8;
      { return the bit representation of the byte. }
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
            /$AA	         {    stosb		; put a char         }
            /$E2/$F5);           {    loop  NextBit     ; repeat till done   }

      function   BitNibble(Number : byte;Zero,One : char) : Str4;
      { return the bit representation of the lower nibble. }
      inline($5A                 {    pop   dx          ; DL = One           }
            /$5B                 {    pop   bx          ; BL = Zero          }
            /$58                 {    pop   ax          ; AX = Number        }
            /$88/$C7             {    mov   bh,al	; BH = Number        }
            /$89/$E7             {    mov   di,sp       ; make stack frame   }
            /$36/$C4/$3D         {    les   di,ss:[di]  ; ES:DI -> string    }
            /$B9/$04/$00         {    mov   cx,4        ; repeat count       }
	    /$FC		 {    cld		; forward direction  }
            /$88/$C8             {    mov   al,cl       ; AL = string length }
	    /$AA		 {    stosb		; store it           }
            /$D2/$E7             {    shl   bh,cl       ; shift 4 places     }
                                 { NextBit:                                  }
            /$88/$D8             {    mov   al,bl       ; AL = Zero          }
            /$D0/$E7             {    shl   bh,1        ; transfer bit in CF }
            /$73/$02             {    jnc   BitDone     ; if not (CY), zero  }
            /$88/$D0             {    mov   al,dl        ; AL = One          }
                                 { BitDone:                                  }
            /$AA	         {    stosb		; put a char         }
            /$E2/$F5);           {    loop  NextBit     ; repeat till done   }

      function   BitWord(Number : word;Zero,One : char) : Str16;
      { return the bit representation of the word. }
      inline($5A                 {    pop   dx          ; DL = One           }
            /$5B                 {    pop   bx          ; BL = Zero          }
            /$88/$DE             {    mov   dh,bl       ; DH = Zero          }
            /$58                 {    pop   ax          ; AX = Number        }
            /$89/$C3             {    mov   bx,ax	; BX = Number        }
            /$89/$E7             {    mov   di,sp       ; make stack frame   }
            /$36/$C4/$3D         {    les   di,ss:[di]  ; ES:DI -> string    }
            /$B9/$10/$00         {    mov   cx,16        ; repeat count       }
	    /$FC		 {    cld		; forward direction  }
            /$88/$C8             {    mov   al,cl       ; AL = string length }
	    /$AA		 {    stosb		; store it           }
                                 { NextBit:                                  }
            /$88/$F0             {    mov   al,dh       ; AL = Zero          }
            /$D1/$E3             {    shl   bx,1        ; transfer bit in CF }
            /$73/$02             {    jnc   BitDone     ; if not (CY), zero  }
            /$88/$D0             {    mov   al,dl        ; AL = One          }
                                 { BitDone:                                  }
            /$AA	         {    stosb		; put a char         }
            /$E2/$F5);           {    loop  NextBit     ; repeat till done   }


   implementation

      {$L  LOCASE.OBJ }
      function   LoCase(Ch : Char) : char; external;
      { return lowercase of char. }

      {$L  ASCIZLEN.OBJ }
      function   LenAsciiz(var S) : word; external;
      { return the length of an ASCIIZ string. }

      {$L  SEARCH.OBJ }
      function   SearchPtr(Buffer : pointer; BufferLen : word;Match : pointer; MatchLen : word) : word; external;
      { search through Buffer for Match, returns the number bytes searched to find Match,
        0FFFFh(-1) if not found. }

      function   Search(var Buffer ; BufferLen : word;var Match ; MatchLen : word) : word; external;
      { search through Buffer for Match, returns the number bytes searched to find Match,
        0FFFFh(-1) if not found. }

      {$L  ASCIZSTR.OBJ }
      procedure  AsciizString(var S);  external;
      { converts the Ascii string to the Asciiz string (requires by Dos). }

      {$L  ASCSTR.OBJ }
      procedure  AscString(var S); external;
      { converts from the Asciiz string to the TP string. }

      {$L  UPCASSTR.OBJ }
      procedure  UpCaseString(var S); external;
      { converts a string to uppercase. }

      {$L  LOCASSTR.OBJ }
      procedure  LoCaseString(var S); external;
      { converts a string to lowercase. }

      function   HexByte(Number : byte) : Str2;
      { return the hexadecimal representation of the byte. }
      begin
        HexByte := HexNibble(Number shr 4) + HexNibble(Number);
      end;  { HexByte }

      function   HexWord(Number : word) : Str4;
      { return the hexadecimal representation of the word. }
      begin
        HexWord := HexByte(HiByte(Number)) + HexByte(LoByte(Number));
      end;  { HexWord }

      function   StrFromAsciiz(var A) : AnyString;
      { extracts and converts an ASCIIZ string to a TP string. }
      var
        S  :  AnyString;
      begin
        S[0] := char(Lo(LenAsciiz(A)));
        Move(A,S[1],Length(S));
        StrFromAsciiz := S;
      end;  { StrFromAsciiz }

      function   ByteToString(Num : byte) : Str3;
      { return Num as a string. }
      var
        S : Str3;
      begin
        Str(Num : 3,S);
        ByteToString := S;
      end;  { ByteToString }

      function   IntegerToString(Num : integer; Width : byte) : Str5;
      { return Num as a string. }
      var
        S : Str5;
      begin
        Str(Num : Width , S);
        IntegerToString := S;
      end;  { IntegerToString }

      function   WordToString(Num : word; Width : byte) : Str5;
      { return Num as a string. }
      var
        S : Str5;
      begin
        Str(Num : Width, S);
        WordToString := S;
      end;  { WordToString }

      function   LongIntegerToString(Num : longint; Width : byte) : Str10;
      { return Num as a string. }
      var
        S : Str10;
      begin
        Str(Num : Width, S);
        LongIntegerToString := S;
      end;  { LongIntegerToString }

      function   RealToString(R : real; Width, DecimalPlaces : byte) : AnyString;
      { return R as a string. }
      var
       S : Str40;
      begin
        Str(R : Width:DecimalPlaces, S);
        RealToString := S;
      end;  { RealToString }

      function DeleteLeft(S : AnyString; Ch : char) : AnyString;
      { deletes all chars left that equal a specified char. }
      var
        SLen  :  byte  absolute  S;
      begin
        while  (SLen <> 0) and (S[1] = Ch)  do  Delete(S,1,1);
        DeleteLeft := S;
      end;  { DeleteLeft }

      function   DeleteRight(S : AnyString; Ch : char) : AnyString;
      { deletes all chars right that equal a specified char. }
      var
        SLen  :  byte  absolute  S;
      begin
        while  (SLen <> 0) and (S[SLen] = Ch)  do  Delete(S,SLen,1);
        DeleteRight := S;
      end;  { DeleteRight }

      function   Decimal(I, Width : word; DoZero : boolean) : Str8;
      { return a string representing a decimal member. }
      var
        S : Str8;
        SLen  : byte  absolute S;
      begin
        Str(I : Width,S);
        if  (DoZero)  then
             for I := 1 to SLen do
               begin if  (S[I] = ' ') then  S[I] := '0' end
        else   S := DeleteLeft(S,' ');
        Decimal := S;
      end;  { Decimal }

      function   LeftStr(S : AnyString; Count : integer) : AnyString;
      { returns the substring from left. }
      begin
        LeftStr := Copy(S,1,Count);
      end;  { LeftStr }

      function   RightStr(S : AnyString; Count : integer) : AnyString;
      { returns the substring from the right. }
      begin
        RightStr := Copy(S,Length(S)-Count,Count);
      end;  { RightStr }

      function   MidStr(S : AnyString; LeftPos,RightPos : integer) : AnyString;
      { returns the substring from Nth pos to Mth pos. }
      var
        Temp : integer;
      begin
        MidStr := Copy(S,LeftPos,abs(RightPos-LeftPos+1));
      end;  { MidStr }

      {$L  STRREV.OBJ }
      procedure  StringReverse(var S); external;
      { reverses a string. }

      {$L  STRDUP.OBJ }
      procedure  StringDup(var S; StringSize : byte); external;
      { duplicates a string. }

      procedure  ReplaceInBuffer(Buf : pointer; Count : word; Match : pointer; MatchLen : word;
              ReplaceStr : pointer; ReplaceLen : word; var ReplaceCount : word);
      { searches the buffer for match pattern and replaces it to specified pattern. }
      var
        Offset  :  word;
        P : pointer;
      begin
        ReplaceCount := 0;   { assume false }
        if  (MatchLen < ReplaceLen)
               or (Count = 0)
                  or (MatchLen = 0)  then  Exit;
        Offset := Search(Buf,Count,Match,MatchLen);  { first occur }
        while  (Count <> 0)
                   and  (Offset <> $FFFF)  do  begin
          Buf := AddPtr(Buf,Offset);
          Dec(Count,Offset+MatchLen);
          TpMove(ReplaceStr,Buf,ReplaceLen);          { replacing }
          P := AddPtr(Buf,MatchLen);
          Buf := AddPtr(Buf,ReplaceLen);
          TpMove(P,Buf,Count);                        { copy remainder }
          Offset := Search(Buf,Count,Match,MatchLen);
          Inc(ReplaceCount);
        end;  { while }
      end;  { ReplaceInBuffer }

      function   HexPtr(P : pointer) : AnyString;
      { return hex string for pointer. }
      begin
        HexPtr := HexWord(Seg(P^)) + ':' + HexWord(Ofs(P^));
      end;  { HexPtr }

      function   CharStr(Ch : char; Len : byte) : AnyString;
      { return a string of length Len filled with Ch. }
      var
        S : AnyString;
      begin
        S[0] := Char(Len);
        FillChar(S[1],Len,Ch);
        CharStr := S;
      end;  { CharStr }

      function   AsciizFromBuffer(P : pointer) : AnyString;
      { returns the TP string from ASCIIZ format started at P. }
      var
        S  :  AnyString;
        Sptr  :  pointer;
      begin
        S[0] := char(LoByte(SearchFirstMatch(P,255,#0)));
        Sptr := Ptr(Seg(S[1]),Ofs(S[1]));
        TpMove(P,Sptr,word(S[0]));
        AsciizFromBuffer := S;
      end;  { AsciizFromBuffer }

   function   SearchString(Buffer : pointer; BufferLen : word;Match : AnyString) : word;
   { search through Buffer for Match, returns the number bytes searched to find Match,
        0FFFFh(-1) if not found. }
   var
     P  :  pointer;
   begin
      P := Ptr(Seg(Match[1]),Ofs(Match[1]));
      SearchString := SearchPtr(Buffer,BufferLen,P,Length(Match));
   end;  { SearchString }

   procedure  OverWriteStr(Source : string; var S; Index : byte);
   { overwrites the string with substring. }
   var
     I,J : byte;
     TempStr : AnyString  absolute S;
   begin
     J := Length(Source);
     I := Length(TempStr) - Index + 1;
     if  (I >= J)  then  begin
           Delete(TempStr,Index,J);
           Insert(Source,TempStr,Index);
     end;
   end; { OverWriteStr }

   function   BCDtoByte(Number : byte) : byte;
   { convert a BCD number to binary form. }
   begin
     BCDtoByte := LoNibble(Number);
   end;  { BCDtoByte }

   function   PackedBCDtoByte(Number : byte) : byte;
   { convert a BCD number to binary form. }
   begin
     PackedBCDtoByte := HiNibble(Number) * 10 + LoNibble(Number);
   end;  { PackedBCDtoByte }

   function   FilterAsciiString(S : AnyString; AsciiType : boolean) : AnyString;
   { extracts the control chars and if specified filter #128-#255. }
   const
     MaskSym  =  '.';
   var
     NewS : AnyString;
     i : byte;  Ch : char;
   begin
     NewS := '';
     if  (Length(S) <> 0) then  begin
       for i := 1 to  Length(S) do  begin
         Ch := S[i];
         if  AsciiType then  begin
              if  (Ch in [#32..#127]) then  NewS := NewS + Ch
              else  NewS := NewS + MaskSym;
           end
         else
            if  (Ch in [#32..#255]) then  NewS := NewS + Ch
            else  NewS := NewS + MaskSym;
       end; { for }
     end; { if }
     FilterAsciiString := NewS;
   end;  { FilterAsciiString }

   function   SearchFirstNoMatchStr(A : string; Count : word; Match : char) : word;
   { search through string A for first no matching char. }
   var
     StrPtr : pointer;
   begin
     StrPtr := Ptr(Seg(A[1]),Ofs(A[1]));
     SearchFirstNoMatchStr := SearchFirstNoMatch(StrPtr,Count,Match)+1;
   end;  { SearchFirstNoMatchStr }

   function  HexCharToByte(Ch : char) : byte;
   { convert the hexadecimal char to byte. }
   begin
     asm
        mov   al,[bp+6]      { AL = Ch }
        sub   al,'0'         { AL <- AL - '0' }
        cmp   al,9           { test for digit }
        jbe   @Done
        and   al,11011111b   { bit 5 off }
        sub   al,'A'-'9'-1   { AL = 'A'..'F' }
      @Done:
        mov  [bp-1],al       { save the function result }
     end;
   end; { HexCharToByte }

   function   HexStrToByte(S : Str2) : byte;
   { convert the hexadecimal string to byte. }
   var
     Slen : byte absolute S;
   begin
     if (Slen < 2) then S := CharStr('0',2-Slen) + S;
     HexStrToByte := (HexCharToByte(S[1]) shl 4) + HexCharToByte(S[2]);
   end; { HexStrToByte }

   function   HexStrToWord(S : Str4) : word;
   { convert the hexadecimal string to word. }
   var
     Slen : byte absolute S;
   begin
     if (Slen < 4) then S := CharStr('0',4-Slen) + S;
     HexStrToWord:= (word(HexStrToByte(Copy(S,1,2))) shl 8) + HexStrToByte(Copy(S,3,2));
   end; { HexStrToWord }

   function   GetHexStr(S : AnyString) : AnyString;
   { get only the hexadecimal string. }
   var
      i,j : byte; SLen : byte absolute S;
   begin
     j := 0;
     UpCaseString(S);
     { first retain only hex digits }
     for i := 1 to SLen do
        if (S[i] in HexSet) then begin Inc(j); S[j] := S[i]; end;
     { put the new string length }
     SLen := j;
     GetHexStr := S;
   end; { GetHexStr }

   function   HexStrToCharStr(S : AnyString) : AnyString;
   { convert the hexadecimal string to its char equivalent. }
   var
      i,j : byte; SLen : byte absolute S;
      NewStr : AnyString;
   begin
     j := 0;
     UpCaseString(S);
     NewStr := '';
     { first retain only hex digits }
     for i := 1 to SLen do
        if (S[i] in HexSet) then begin Inc(j); S[j] := S[i]; end;
     { put the new string length }
     SLen := j;
     { paars of digits for use }
     if  Odd(SLen) then Delete(S,SLen,1);
     for i := 1 to (SLen shr 1) do NewStr := NewStr + char(HexStrToByte(Copy(S,(i-1)*2 + 1,2)));
     HexStrToCharStr := NewStr;
   end; { HexStrToCharStr }

   {begin}          { initialization part }
   end.
