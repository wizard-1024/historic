  {$D-,I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0  PRINT  Unit            *
        *    Provides access to ROM-BIOS print functions   *
        *          Version  2.10      01/09/91             *
        *        written  by  Dima  Stefankov              *
        *                                                  *
        ****************************************************
  }

   unit   TpPrint;

   interface

      const
         TimeOut          =       $1;          { bits for error }
         IoError          =       $8;
         OnLine           =       $10;
         OutPaper         =       $20;
         NotAcknowLedge   =       $40;
         NotBuzy          =       $80;

         LPT1             =       0;           { LPTi ports }
         LPT2             =       1;
         LPT3             =       2;
         LPT4             =       3;

      var
        PrinterStatus    :   byte;

      function    GetPrinterStatus(Port : byte) : byte;
      procedure   PrintChar(Ch : char; Port : byte);
      procedure   InitPrinterPort(Port : byte);
      procedure   PrintBuffer(var P; Count : word; Port : byte; var Result : word);

implementation                { private part }

      {$L TPPRINT.OBJ }

      function    GetPrinterStatus(Port : byte) : byte; external;
      { return the printer status flags. }

      procedure   PrintChar(Ch : char; Port : byte); external;
      { print a character. }

      procedure   InitPrinterPort(Port : byte); external;
      { initialize a printer port. }

      procedure   PrintBuffer(var P; Count : word; Port : byte; var Result : word); external;
      { prints a contents of buffer. }


  {begin}    { initializtion }
  end.
