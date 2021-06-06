  {$D-,I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0   8087  Unit            *
        *       Provides access to 80x87-CoProcessor       *
	*          Version  2.10      01/09/91             *
        *         written   by  Dima Stefankov             *
        *    (My thanks to TURBO PROFESSIONAL PACKAGE!)    *
        *                                                  *
        ****************************************************
  }

   unit   TpMath;

   interface                 { public part }

     type
       SaveBuffer8087 = array[1..94] of Byte;


     procedure Save8087(var SaveBuf : SaveBuffer8087);
     procedure Restore8087(var SaveBuf : SaveBuffer8087);
     function Installed8087 : Boolean;
     procedure Exceptions8087(On : Boolean);
     function Error8087 : Word;

   implementation                { private part }

      {$L TPMATH.OBJ}

      procedure Save8087(var SaveBuf : SaveBuffer8087); external;
        {-Saves the 80x87 registers in the save buffer.}

      procedure Restore8087(var SaveBuf : SaveBuffer8087); external;
        {-Restores the 80x87 registers from the save buffer.}

      function Installed8087 : Boolean; external;
        {-Returns true if an 80x87 coprocessor is installed}

      procedure Exceptions8087(On : Boolean); external;
        {-Turn exception interrupts on or off}

      function Error8087 : Word; external;
        {-Return the error status of the 80x87}

   {begin}    { initializtion }
   end.
