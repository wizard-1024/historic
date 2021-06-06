  {$I-,S-}

  {     ****************************************************
        *                                                  *
        *        Turbo Pascal 6.0    Execution   Unit      *
        *        Utility    Routines  and  Utilites        *
	*          Version  1.00      07/26/89             *
        *         written  by  Dima  Stefankoff            *
        *                                                  *
        ****************************************************
  }

   unit   TpExe;


   interface                             { public part }

   uses
     TpString;

      function ExeFileHide(FileName : AnyString) : boolean;
      function ExeFileUnHide(FileName : AnyString) : boolean;

   implementation                { private part }

      {$L OVL1.OBJ }
      function ExeFileHide(FileName : AnyString) : boolean; external;
      { external procedure that protects a file. }

      {$L OVL2.OBJ }
      function ExeFileUnHide(FileName : AnyString) : boolean; external;
      { external procedure that protects a file. }

   {begin}  {initialization part }
   end.
