  {$D-,I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 5.5   EXTEND  Unit          *
        * Provides access to ROM-BIOS AT general functions *
        *          Version  2.00      04/22/90             *
        *         written  by   Dima  Stefankov            *
        *                                                  *
        ****************************************************
  }

   unit   TpExtend;

   interface                 { public part }

      type
        SysDescrTable    =   record
                               Length        :   word;
                               SysModel      :   byte;
                               SubModel      :   byte;
                               BiosRevision  :   byte;
                               FeatureInfo   :   byte;
                               Reserved      :   longint;
                             end;


      var
        MachineID   :  byte   absolute  $F000:$FFFE;

      procedure  TimeDelay(Delay : longint; var Error : boolean);

      function   ExtendedMemSize : word;
      { reports amount of memory above 1024K. }
      inline($B4/$88/      {  mov  ah,88h    ;get extended memory size }
             $CD/$15/      {  int  15h       ;general services }
             $73/$02/      {  jnc  NoError   ;check for support }
             $29/$C0);     {  sub  ax,ax     ;AX = 0 }
                           {  NoError:       ;AX = result }

      procedure  SystemConfiguration(var P : SysDescrTable; var Valid : boolean);

      function   ReadEquipment  :  word;
      { returns a list of installed equipment on the system. }
      inline($CD/$11);

      function   GetMemorySize  :  word;
      { reports the number of contiquons 1K memory blocks in the system (up to 640K).}
      inline($CD/$12);

   implementation                { private part }

      {$L TIMDELAY.OBJ }
      procedure  TimeDelay(Delay : longint; var Error : boolean); external;
      { waits a specified # of microseconds before returning control. }

      {$L SYSCONFG.OBJ }
      procedure  SystemConfiguration(var P : SysDescrTable; var Valid : boolean); external;
      { reports the hardware-specific attributes. }


   {begin}    { initialization }
   end.
