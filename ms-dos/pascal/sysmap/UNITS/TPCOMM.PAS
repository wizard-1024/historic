  {$D-,I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0   COMM   Unit           *
        *  Provides access to ROM-BIOS RS232 functions     *
	*          Version  2.10      01/09/91             *
        *         written  by  Dmitry  Stefankov           *
        *                                                  *
        ****************************************************
  }

   unit   TpComm;

   interface                 { public part }

      const
        COM1         =    0;
        COM2         =    1;
        COM3         =    2;
        COM4         =    3;
        Word7        =    $2;
        Word8        =    $3;
        StopBits1    =    $0;
        StopBits2    =    $4;
        NoneParity   =    $10;
        EvenParity   =    $18;
        Baud110      =    0;
        Baud150      =    $20;
        Baud300      =    $40;
        Baud600      =    $60;
        Baud1200     =    $80;
        Baud2400     =    $90;
        Baud4800     =    $C0;
        Baud9600     =    $E0;

      var
        LineStatus, ModemStatus  :  byte;

      procedure  InitCommPort(Port, BaudRate,Parity, StopBits, WordLength : byte);
      procedure  SendChar(Port, Ch : byte);
      function   ReceiveChar(Port : byte) : byte;
      function   GetCommPortStatus(Port : byte) : word;

   implementation                { private part }

      {$L  TPCOMM.OBJ }

      procedure  InitCommPort(Port, BaudRate,Parity, StopBits, WordLength : byte); external;
      { initializes a communication port. }

      procedure  SendChar(Port, Ch : byte); external;
      { send a char to communication port. }

      function   ReceiveChar(Port : byte) : byte; external;
      { receives a char from the communication port. }

      function   GetCommPortStatus(Port : byte) : word; external;
      { get a status of the communaction port, or modem. }

   {begin}    { initialization }
   end.
