  {$I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0   CLOCK  Unit           *
        *     Provides access to ROM-BIOS clock functions  *
	*          Version  2.11      04/30/91             *
        *         written  by  Dmitry  Stefankov           *
        *                                                  *
        ****************************************************
  }

   unit   TpClock;

   interface                 { public part }

     uses
        TpSystem,TpCrt,TpDos;           { other units }

     const
       FrequencyTablePtr  :  pointer  =  nil;          { internal music pointers }
       DurationTablePtr   :  pointer  =  nil;


      procedure  ReadSystemTimer(var Counter : longint; var Rolled : boolean);
      procedure  SetSystemTimer(Counter : longint);
      procedure  ReadRTCtime(var HourBCD,MinBCD,SecBCD : byte; var Valid : boolean;
                             var DayLight : boolean);
      procedure  SetRTCtime(HourBCD, MinBCD, SecBCD : byte; DayLight : boolean);
      procedure  ReadRTCdate(var Valid : boolean; var CenturyBCD, YearBCD, MonthBCD, DayBCD : byte);
      procedure  SetRTCdate(CenturyBCD, YearBCD, MonthBCD, DayBCD : byte);
      procedure  SetRTCalarm(HourBCD, MinBCD, SecBCD : byte; var Valid : boolean);
      procedure  ResetRTCalarm;
      procedure  ProcessClock(var Hour,Min,Sec,Sec100 : byte);
      procedure  PlayOn;
      procedure  PlayOff;
      function   MusicInBackGround : boolean;
      procedure  Tone(Freq : integer; Duration : word);
      procedure  RestoreInt08;

   implementation                { private part }

   const
     Speaker      :  boolean   =  false;          { speaker toggle }

   var
     PrevInt08    :  pointer;                     { old int $08 handler address }
     ProcessTics  :  longint;
     OurRolled    :  boolean;
     NoteCounter  :  word;

      {$L TPCLOCK.OBJ }

      {$F+}
      procedure  MusicInt; external;
      { internal music subroutine. }
      {$F-}

      procedure  ReadSystemTimer(var Counter : longint; var Rolled : boolean); external;
      { reads a system timer counter. }

      procedure  SetSystemTimer(Counter : longint); external;
      { set a system timer counter. }

      procedure  ReadRTCtime(var HourBCD,MinBCD,SecBCD : byte; var Valid : boolean;
                             var DayLight : boolean); external;
      { read a AT-RTC time. }

      procedure  SetRTCtime(HourBCD, MinBCD, SecBCD : byte; DayLight : boolean); external;
      { set a AT-RTC time. }

      procedure  ReadRTCdate(var Valid : boolean; var CenturyBCD, YearBCD, MonthBCD, DayBCD : byte); external;
      { read a AT-RTC date. }

      procedure  SetRTCdate(CenturyBCD, YearBCD, MonthBCD, DayBCD : byte); external;
      { set a AT-RTC date. }

      procedure  SetRTCalarm(HourBCD, MinBCD, SecBCD : byte; var Valid : boolean); external;
      { set a alarm clock time. }

      procedure  ResetRTCalarm; external;
      { resets a alarm clock time. }

      procedure  ProcessClock(var Hour,Min,Sec,Sec100 : byte);
      { returns the process about time info. }
      var
        TempL  :  longint;
        TempW  :  word;
        Rolled : boolean;
      begin
        ReadSystemTimer(TempL,Rolled);
        Dec(TempL,ProcessTics);
        Hour  := TempL div 65543;
        TempW := TempL mod 65543;
        Min   := TempW div 1092;
        TempW := TempW mod 1092;
        Sec   := TempW div 18;
        Sec100   := ((TempW mod 18) * 100) div 18;
      end;  { ProcessClock }

      procedure  PlayOn; external;
      { sets the user pointers to internal tables. }

      procedure  PlayOff; external;
      { stop music playing }

      function   MusicInBackGround : boolean; external;
      { returns the state of the music player. }

      procedure  Tone(Freq : integer; Duration : word);
      { emulates the Quick Basic 'SOUND' statement. }
      const
        FTempArray  :  array[0..1] of word = ($0,$FFFF);
      var
        DTemp       :  word;
      begin
        FTempArray[0] := Freq;
        DTemp := Duration;
        FrequencyTablePtr := @FTempArray;
        DurationTablePtr := @DTemp;
        PlayOn;
        while  MusicInBackGround do;
        PlayOff;
      end;  { Tone }

      procedure  RestoreInt08;
      { restores the saved INT $08 handler address. }
      begin
        SetIntVec($08,PrevInt08);
      end;  { RestoreInt08 }


   begin    { initialization }
     PrevInt08 := GetIntVec($08);
     SetIntVec($08,@MusicInt);
     ReadSystemTimer(ProcessTics,OurRolled);
   end.
