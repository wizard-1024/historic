  {I-,S-}

  {     ****************************************************
        *                                                  *
        *        Turbo Pascal 6.0    HEAP   Unit           *
        *        Heap    Routines  and  Utilites           *
	*          Version  2.10      01/09/91             *
        *         written  by  Dima  Stefankoff            *
        *                                                  *
        ****************************************************
  }

   unit   TpHeap;

   interface                             { public part }


      function  GetMemCheck(var P; Bytes : word) : boolean;
      procedure  FreeMemCheck(var P; Bytes : word);

   implementation                { private part }

      {$F+}
      function  HeapFunc(Size : word) : integer;
      { return nil pointer if insufficient memory. }
      begin
        HeapFunc := 1;
      end;  { HeapFunc }
      {$F-}

      function  GetMemCheck(var P; Bytes : word) : boolean;
      { allocate heap space, returning true if succesful. }
      var
        SaveHeapError  :  pointer;
        Pt             :  pointer   absolute  P;
      begin
        SaveHeapError := HeapError;     { take over heap error control }
        HeapError := @HeapFunc;
        GetMem(Pt,Bytes);
        GetMemCheck := (Pt <> nil);
        HeapError := SaveHeapError;     { restore heap error control }
      end;  { GetMemCheck }

      procedure  FreeMemCheck(var P; Bytes : word);
      { deallocates heap space }
      var
        Pt  :  pointer  absolute P;
      begin
        if  (Pt <> nil)  then  FreeMem(Pt,Bytes);
      end;  { FreeMemCheck }

   {begin}  { initialization part }
   end.
