  {$D+,I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0   SYSTEM  Unit          *
        *    Provides access to extended system functions  *
	*          Version  2.10      01/01/91             *
        *         written  by   Dima  Stefankov            *
        *                                                  *
        ****************************************************
  }

   unit   TpSystem;

   interface                 { public part }

      type   SegOfs  =  record
                          O, S  :  word;
                        end;

         procedure  TpMove(Source,Destination : pointer; Count : word);
         { moves a specified range of bytes, check for the overlapping. }

         procedure  MoveBuffer(var Source,Destination; Count : word; Ch : char);
         { moves a specified range of bytes until first occuring of char,no check for the overlapping. }

         procedure  SwapBuffers(var Source,Destination; Count : word);
         { swaps the contents of the buffers. }

         function   CompareBuffers(var Source,Destination; Count : word) : word;
         { compare the contents of the buffers, returns 0FFFFh(-1) if match. }

         function   ComparePtrBuffers(Source,Destination : pointer; Count : word) : word;
         { compare the contents of the buffers, returns 0FFFFh(-1) if match. }

      { next functions used for returning the values 8086 registers. }

         function   Cseg : word;
         inline($8C/$C8);         {  mov  ax,cs  }

         function   Dseg : word;
         inline($8C/$D8);         {  mov  ax,ds  }

         function   Sseg : word;
         inline($8C/$D0);         {  mov  ax,ss  }

         function   Eseg : word;
         inline($8C/$C0);         {  mov  ax,es  }

         function   SPtr : word;
         inline($89/$E0);         {  mov  ax,sp  }

         function   BPtr : word;
         inline($89/$E8);         {  mov  ax,bp  }

         function   DIndx : word;
         inline($89/$F8);         {  mov  ax,di  }

         function   SIndx : word;
         inline($89/$F0);         {  mov  ax,si  }

         function   DxReg : word;
         inline($89/$D0);         {  mov  ax,dx  }

         function   CxReg : word;
         inline($89/$C8);         {  mov  ax,cx  }

         function   BxReg : word;
         inline($89/$D8);         {  mov  ax,bx  }

         function   AxReg : word;
         inline($89/$C0);         {  mov  ax,ax  }

      { useful  macros }

         procedure  NullJump;
         inline($EB/$00);         {  jmp short $+2  }

         function   LoNibble(B : byte) : byte;
         { returns a low-order nibble of a byte. }
         inline($58              {  pop   ax      ; AL = B               }
               /$24/$0F);        {  and   al,0Fh  ; isolate lower 4 bits }

         function   HiNibble(B : byte) : byte;
         { returns a high-order nibble of a byte(shifted right to 4 places. }
         inline($58             {  pop   ax      ; AL = B               }
               /$D0/$E8         {  shr   al,1    ; shift right 1 place  }
               /$D0/$E8         {  shr   al,1    ; shift right 1 place  }
               /$D0/$E8         {  shr   al,1    ; shift right 1 place  }
               /$D0/$E8);       {  shr   al,1    ; shift right 1 place  }

         function   LoByte(W : word) : byte;
         { returns a low-order byte of a word. }
         inline($58);         {  pop  ax    ;  AL = Lo(W)  }

         function   HiByte(W : word) : byte;
         { returns a high-order byte of a word. }
         inline($58           {  pop   ax     ;  AH = Hi(W)  }
               /$86/$E0);     {  xchg  ah,al  ;  AL = Hi(W)  }

         function   LoWord(L : longint) : word;
         { returns a low-order word of a longint number. }
         inline($58          {  pop   ax   ;  AX = result      }
               /$5B);        {  pop   bx   ;  discard on stack }

         function   HiWord(L : longint) : word;
         { returns a high-order word of a longint number. }
         inline($58          {  pop   ax     ;  AX = Lo(L)  }
               /$5B          {  pop   bx     ;  BX = Hi(L)  }
               /$93);        {  xchg  ax,bx  ;  AX = result }

         function   LoWordPtr(P : pointer) : word;
         { returns a low-order word of a pointer. }
         inline($58        {  pop   ax   ;  AX = result      }
               /$5B);      {  pop   bx   ;  discard on stack }

         function   HiWordPtr(P : pointer) : word;
         { returns a high-order word of a pointer. }
         inline($58          {  pop   ax     ;  AX = Lo(P)  }
               /$5B          {  pop   bx     ;  BX = Hi(P)  }
               /$93);        {  xchg  ax,bx  ;  AX = result }

         procedure  FillWord(var Dest; Count,Filler : word);
         { fill memory starting at Dest with Count instances of Filler. }
         inline($58          {  pop  ax      ;  AX = Filler   }
               /$59          {  pop  cx      ;  CX = Count    }
               /$5F          {  pop  di      ;  ES:DI -> Dest }
               /$07          {  pop  es  }
               /$FC          {  cld          ;  go forward    }
               /$F2/$AB);    {  rep stosw    ;  fill memory   }

         function  Normalized(P : pointer) : pointer;
         { return P as a normalized pointer. }
         inline($58           {  pop  ax      ;  AX = Offset  }
               /$5A           {  pop  dx      ;  DX = Segment }
               /$89/$C3       {  mov  bx,ax   ;  BX = Ofs(P^) }
               /$B1/$04       {  mov  cl,4    ;  CL = shift count }
               /$D3/$EB       {  shr  bx,cl   ;  BX = Ofs(P^) div 16 }
               /$01/$DA       {  add  dx,bx   ;  add to Segment }
               /$25/$0F/$00); {  and  ax,15   ;  mask out unwanted }
                                           {  ;  bits in offset }

         function  MinWord(A,B : word) : word;
         { returns the smaller of A and B. }
         inline($58            {  pop  ax     ;  AX = B   }
               /$5B            {  pop  bx     ;  BX = A   }
               /$39/$C3        {  cmp  bx,ax  ;  A > B ?  }
               /$73/$02        {  jae  Done   ; if > then done }
               /$89/$D8);      {  mov  ax,bx  ; else swap }
                               { Done: }

         function  MaxWord(A,B : word) : word;
         { returns the bigger of A and B. }
         inline($58            {  pop  ax     ;  AX = B   }
               /$5B            {  pop  bx     ;  BX = A   }
               /$39/$D8        {  cmp  ax,bx  ;  B > A ?  }
               /$73/$02        {  jae  Done   ; if > then done }
               /$89/$D8);      {  mov  ax,bx  ; else swap }
                               { Done: }

         function  MinByte(A,B : byte) : byte;
         { returns the smaller of A and B. }
         inline($58            {  pop  ax     ;  AX = B   }
               /$5B            {  pop  bx     ;  BX = A   }
               /$38/$C3        {  cmp  bl,al  ;  A > B ?  }
               /$73/$02        {  jae  Done   ; if > then done }
               /$88/$D8);      {  mov  al,bl  ; else swap }
                               { Done: }

         function  MaxByte(A,B : byte) : byte;
         { returns the bigger of A and B. }
         inline($58            {  pop  ax     ;  AX = B   }
               /$5B            {  pop  bx     ;  BX = A   }
               /$38/$D8        {  cmp  al,bl  ;  B > A ?  }
               /$73/$02        {  jae  Done   ; if > then done }
               /$88/$D8);      {  mov  al,bl  ; else swap }
                               { Done: }

         procedure  ExchangeBytes(var I,J : byte);
         { exchange bytes I and J. }
         inline($8C/$DB        {  mov  bx,ds   ;  save DS  }
               /$5E            {  pop  si  }
               /$1F            {  pop  ds      ;  DS:SI -> J }
               /$5F            {  pop  di  }
               /$07            {  pop  es      ;  ES:Di -> I }
               /$8A/$04        {  mov  al,[si] ;  AL = J }
               /$26/$86/$05    {  xchg al,es:[di] ;  I = J, AL = I }
               /$88/$04        {  mov  [si],al  ; J = I }
               /$8E/$DB);      {  mov  ds,bx   ;  restore DS  }

         procedure  ExchangeWords(var I,J : word);
         { exchange words I and J. }
         inline($8C/$DB        {  mov  bx,ds  ;  save DS  }
               /$5E            {  pop  si  }
               /$1F            {  pop  ds     ;  DS:SI -> J }
               /$5F            {  pop  di  }
               /$07            {  pop  es     ;  ES:Di -> I }
               /$8B/$04        {  mov  ax,[si] ;  AX = J }
               /$26/$87/$05    {  xchg ax,es:[di] ;  I = J, AX = I }
               /$89/$04        {  mov  [si],ax  ; J = I }
               /$8E/$DB);      {  mov  ds,bx   ;  restore DS }

         function   NextPointer(P : pointer) : pointer;
         { extracts the pointer to next link field. }
         inline($5F           {   pop  di           ; DI = Ofs(P)  }
               /$07           {   pop  es           ; ES = Seg(P)  }
               /$26/$C4/$05   {   les  ax,es:[di]  }
               /$8C/$C2);     {   mov  dx,es        ; DX:AX -> Result }

         procedure  DisableInterrupts;
         { no external events }
         inline($FA);  { cli }

         procedure  EnableInterrupts;
         { external events may be occurred }
         inline($FB);  { sti }

         procedure  FillCharPtr(P : pointer; Count : word; Ch : word);
         { fill memory starting at Contents(P) with Count instances of Filler. }
         inline($58          {  pop  ax      ;  AX = Ch  }
               /$59          {  pop  cx      ;  CX = Count    }
               /$5F          {  pop  di      ;  ES:DI -> Dest }
               /$07          {  pop  es  }
               /$FC          {  cld          ;  go forward    }
               /$F2/$AA);    {  rep stosb    ;  fill memory   }

         procedure  FillWordPtr(P : pointer; Count, Filler : word);
         { fill memory starting at Contents(P) with Count instances of Filler. }
         inline($58          {  pop  ax      ;  AX = Filler   }
               /$59          {  pop  cx      ;  CX = Count    }
               /$5F          {  pop  di      ;  ES:DI -> Dest }
               /$07          {  pop  es  }
               /$FC          {  cld          ;  go forward    }
               /$F2/$AB);    {  rep stosw    ;  fill memory   }

         function  ReadCMOS(Port : byte) : byte;
         { reads a CMOS ram data. }

         procedure WriteCMOS(Port,Value : byte);
         { writes a byte to the CMOS ram data. }

         function  AddPtr(P : pointer; Num : word) : pointer;
         { add Num to a pointer - no normalizion. }
         inline($5B       {  pop bx     ; BX = Num       }
               /$58       {  pop ax     ; AX = Ofs(P)    }
               /$5A       {  pop dx     ; DX = Seg(P)    }
               /01/$D8);  {  add ax,bx  ; DX:AX = result }

         function  SubPtr(P : pointer; Num : word) : pointer;
         { subtract Num from a pointer - no normalizion. }
         inline($5B        {  pop bx     ; BX = Num       }
               /$58        {  pop ax     ; AX = Ofs(P)    }
               /$5A        {  pop dx     ; DX = Seg(P)    }
               /29/$D8);   {  sub ax,bx  ; DX:AX = result }

      procedure  SwapInByte(var B : byte);
      { swaps the nibbles of byte-argument. }
      inline($5F            {  pop  di          ; DI = Ofs(B)        }
            /$07            {  pop  es          ; ES = Ofs(B)        }
            /$26/$8A/$05    {  mov  al,es:[di]  ; get byte into AL   }
            /$B1/$04        {  mov  cl,4        ; CL = shift count   }
            /$D2/$C0        {  ror  al,cl       ; rotate by 4 places }
            /$26/$88/$05);  {  mov  es:[di],al  ; store byte back    }

      procedure  SwapInWord(var W : word);
      { swaps the bytes of a word-argument. }
      inline($5F            {  pop  di          ; DI = Ofs(W)        }
            /$07            {  pop  es          ; ES = Ofs(W)        }
            /$26/$8B/$05    {  mov  ax,es:[di]  ; get word into AX   }
            /$86/$E0        {  xchg ah,al       ; swap the bytes     }
            /$26/$89/$05);  {  mov  es:[di],ax  ; store word back    }

      procedure  SwapInLongInt(var L : longint);
      { swaps the words of a double-word argument. }
      inline($5F              {  pop  di            ; DI = Ofs(L)        }
            /$07              {  pop  es            ; ES = Ofs(L)        }
            /$26/$8B/$05      {  mov  ax,es:[di]    ; get word into AX   }
            /$26/$87/$45/$02  {  xchg ax,es:[di].2  ; swap the bytes     }
            /$26/$89/$05);    {  mov  es:[di],ax    ; store word back    }

      function   LongIntSize(F,S : word) : longint;
      { converts the difference to longint number. }
      inline($58              {    pop ax     ; AX = S            }
            /$5B              {    pop bx     ; BX = F            }
            /$29/$D8          {    sub ax,bx  ; AX = F - S        }
            /$29/$D2          {    sub dx,dx  ; DX = 0            }
            /$B9/$04/$00      {    mov cx,4   ; load shift count  }
            /$D1/$E0          { L: shl ax,1   ; CF = MSB          }
            /$D1/$D2          {    rcl dx,1   ; DX = DX*(2 or CY) }
            /$E2/$FA);        {    loop L     ; repeat till done  }

      function  RmemB(P : Pointer) : byte;
      { read the memory byte value by a given pointer. }
      inline($5F             {   pop  di           ; DI = Ofs(P)  }
            /$07             {   pop  es           ; ES = Seg(P)  }
            /$26/$8A/$05);   {   mov  al,es:[di]   ; AL = result  }

      function  RmemW(P : Pointer) : word;
      { read the memory word value by a given pointer. }
      inline($5F             {   pop  di           ; DI = Ofs(P)  }
            /$07             {   pop  es           ; ES = Seg(P)  }
            /$26/$8B/$05);   {   mov  ax,es:[di]   ; AX = result  }

      function  RmemL(P : Pointer) : longint;
      { read the memory LongInt value by a given pointer. }
      inline($5F                 {   pop  di           ; DI = Ofs(P)  }
            /$07                 {   pop  es           ; ES = Seg(P)  }
            /$26/$C4/$05         {   les  ax,es:[di]   ; AX = loword  }
            /$8C/$C2);           {   mov  dx,es        ; DX = hiword  }

   implementation                { private part }

      {$L TPMOVE.OBJ }
      procedure  TpMove(Source,Destination : pointer; Count : word); external;
      { moves a specified range of bytes, check for the overlapping. }

      {$L MOVEBUF.OBJ }
      procedure  MoveBuffer(var Source,Destination; Count : word; Ch : char); external;
      { moves a specified range of bytes until first occuring of char,no check for the overlapping. }

      {$L SWAPBUF.OBJ }
      procedure  SwapBuffers(var Source,Destination; Count : word); external;
      { swaps the contents of the buffers. }

      {$L COMPBUF.OBJ }
      function   CompareBuffers(var Source,Destination; Count : word) : word; external;
      { compare the contents of the buffers, returns 0FFFFh(-1) if match. }

      function   ComparePtrBuffers(Source,Destination : pointer; Count : word) : word; external;
      { compare the contents of the buffers, returns 0FFFFh(-1) if match. }

      {$L READCMOS.OBJ }
      function  ReadCMOS(Port : byte) : byte; external;
      { reads a CMOS ram data. }

      {$L WRITCMOS.OBJ }
      procedure WriteCMOS(Port,Value : byte); external;
      { writes a byte to the CMOS data. }

   {begin}    { initialization }
   end.
