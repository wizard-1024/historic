  {$I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0   PACK  Unit            *
        *       Provides access to locking functions       *
	*          Version  2.10      01/09/91             *
        *         written   by  Dima  Stefankov            *
        *                                                  *
        ****************************************************
  }

   unit   TpPack;

   interface                 { public part }

      uses
        TpString;           { other units }


         function   BytesCheckSum(Buf : pointer; Count : longint) : byte;
         function   WordsCheckSum(Buf : pointer; Count : longint) : word;
         procedure  EncryptA(Buf : pointer; Count : word; var PassWord);
         procedure  DecryptA(Buf : pointer; Count : word; var PassWord);
         procedure  EncryptB(Buf : pointer; Count : word; var PassWord);
         procedure  DecryptB(Buf : pointer; Count : word; var PassWord);
         procedure  EncryptC(Buffer : pointer; Count : word);
         procedure  DecryptC(Buffer : pointer; Count : word);
         procedure  EncryptD(Buffer : pointer; Count : word);
         procedure  DecryptD(Buffer : pointer; Count : word);
         procedure  Pack(Source,Dest : pointer; Count : word);
         procedure  UnPack(Source,Dest : pointer);
         procedure  EncryptE(Buffer : pointer; Count : word);
         procedure  DecryptE(Buffer : pointer; Count : word);
         function   CheckROMcard(MemSeg : word) : boolean;
         function   TestOneMemPara(MemSeg : word) : boolean;

         procedure  FastEncrypt(Src : pointer; Count : word);
         { uses the standard 'XOR' algorithm. }
         inline($59                {   pop  cx            ;CX = Count     }
               /$E3/$0D            {   jcxz  Done         ;exit if zero   }
               /$8C/$DA            {   mov   dx,ds        ;save DS        }
               /$5E                {   pop   si           ;SI = ofs       }
               /$1F                {   pop   ds           ;DS = seg       }
               /$FC                {   cld                ;forward        }
                                   { NextByte:                            }
               /$80/$34/$5F        {   xor bptr [si],5Fh  ;xor op         }
               /$46                {   inc si             ;advance index  }
               /$E2/$FA            {   loop   NextByte    ;till done      }
               /$8E/$DA);          {   mov    ds,dx       ;restore DS     }
                                   { Done:                                }

         procedure  FastDecrypt(Src : pointer; Count : word);
         { uses the standard 'XOR' algorithm. }
         inline($59                {   pop  cx            ;CX = Count     }
               /$E3/$0D            {   jcxz  Done         ;exit if zero   }
               /$8C/$DA            {   mov   dx,ds        ;save DS        }
               /$5E                {   pop   si           ;SI = ofs       }
               /$1F                {   pop   ds           ;DS = seg       }
               /$FC                {   cld                ;forward        }
                                   { NextByte:                            }
               /$80/$34/$5F        {   xor bptr [si],5Fh  ;xor op         }
               /$46                {   inc si             ;advance index  }
               /$E2/$FA            {   loop   NextByte    ;till done      }
               /$8E/$DA);          {   mov    ds,dx       ;restore DS     }
                                   { Done:                                }

   implementation                { private part }

      {$L BCHKSUM.OBJ }
      function  BytesCheckSum(Buf : pointer; Count : longint) : byte; external;
      { returns the checksum of bytes in buffer. }

      {$L WCHKSUM.OBJ }
      function  WordsCheckSum(Buf : pointer; Count : longint) : word; external;
      { returns the checksum of words in buffer. }

      {$L ENCRYPTA.OBJ }
      procedure  EncryptA(Buf : pointer; Count : word; var PassWord); external;
      { encrypts the contents of the buffer using the password. }

      {$L DECRYPTA.OBJ }
      procedure  DecryptA(Buf : pointer; Count : word; var PassWord); external;
      { decrypts the contents of the buffer using the password. }

      {$L ENCRYPTB.OBJ }
      procedure  EncryptB(Buf : pointer; Count : word; var PassWord); external;
      { encrypts the contents of the buffer using the password. }

      {$L DECRYPTB.OBJ }
      procedure  DecryptB(Buf : pointer; Count : word; var PassWord); external;
      { decrypts the contents of the buffer using the password. }

      procedure  EncryptC(Buffer : pointer; Count : word);
      { encrypts the contents of the buffer using the algorithm 'BitsToBytes'. }
      var
        Temp  :  array[0..7]  of  byte;
        i,j  :  byte;
        Offset : word;

      function  GetByte(LocOfs : byte) : byte;
      begin
       GetByte := Mem[Seg(Buffer^):(Ofs(Buffer^)+Offset+LocOfs)]
      end;  {  GetByte }

      begin
        Count := Count shr 3;
        Offset := 0;
        while  (Count <> 0)  do
        begin
          for i := 0  to  7  do
          begin
            Temp[i] := 0;
            for j := 0  to  7  do
            begin
              Temp[i] := Temp[i] + (((GetByte(j) and (1 shl i)) shr i) shl j);
            end;
          end;  { for }
          for j := 0  to  7  do
             Mem[Seg(Buffer^):(Ofs(Buffer^)+Offset+j)] := Temp[j];
          Dec(Count);
          Inc(Offset,8);
        end;  { while }
      end;  { EncryptC }

      procedure  DecryptC(Buffer : pointer; Count : word);
      { decrypts the contents of the buffer using the algorithm 'BitsToBytes'. }
      begin
        EncryptC(Buffer,Count);
      end;  { DecryptC }

      procedure  EncryptD(Buffer : pointer; Count : word);
      { encrypts the contents of a buffer using 'ODD-EVEN' algorithm. }
      var
        Offset  :  word;
        Ch1, Ch2, TempCh1, TempCh2 : byte;
      begin
        Offset := 0;
        Count := Count shr 1;
        while  (Count <> 0)  do
        begin
          Ch1 := Mem[Seg(Buffer^):(Ofs(Buffer^)+Offset)];
          Ch2 := Mem[Seg(Buffer^):(Ofs(Buffer^)+Offset+1)];
          TempCh2 := (Ch2 shl 1) and 170 ;
          TempCh1 := (Ch1 shr 1) and 85;
          Ch1 := (Ch1 and 85) or TempCh2;
          Ch2 := (Ch2 and 170) or TempCh1;
          Mem[Seg(Buffer^):(Ofs(Buffer^)+Offset)] := Ch1;
          Mem[Seg(Buffer^):(Ofs(Buffer^)+Offset+1)] := Ch2;
          Inc(Offset,2);
          Dec(Count);
        end;  { while }
      end;  { DecryptD }

      procedure  DecryptD(Buffer : pointer; Count : word);
      { decrypts the contents of a buffer using 'ODD-EVEN' algorithm. }
      begin
        EncryptD(Buffer,Count);
      end;  { DecryptD }

      {$L PACK.OBJ }
      procedure  Pack(Source,Dest : pointer; Count : word); external;
      { packing the contents of buffer. }

      {$L UNPACK.OBJ }
      procedure  UnPack(Source,Dest : pointer); external;
      { unpacking a contents of buffer. }

      {$L ENCRYPTE.OBJ }
      procedure  EncryptE(Buffer : pointer; Count : word); external;
      { encrypts the contents of the buffer using the rotation algorithm. }

      {$L DECRYPTE.OBJ }
      procedure  DecryptE(Buffer : pointer; Count : word); external;
      { decrypts the contents of the buffer using the rotation algorithm. }

      {$L ROMCHK.OBJ }
      function   CheckROMcard(MemSeg : word) : boolean; external;
      { returns the true if valid ROM space. }

      {$L TESTPARA.OBJ }
      function   TestOneMemPara(MemSeg : word) : boolean; external;
      { read/write test for 1 paragraph. }

   {begin}    { initializtion }
   end.
