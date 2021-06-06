  {$D-,I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0   MOUSE  Unit           *
        *   Provides access to MicroSoft Mouse functions   *
        *          Version  2.10      01/09/91             *
        *         written  by  Dima  Stefankov             *
        *                                                  *
        ****************************************************
  }

   unit   TpMouse;

   interface                 { public part }

        uses
          TpDos;             { others units }

        const
           LeftButton       =    0;
           RightButton      =    1;
           MiddleButton     =    2;
        type
          MouseGraphBlock   =  array[0..31]  of  word;
                                 {  0..15  =>  screen mask  }
                                 {  16..31 =>  cursor mask  }
        var
          MouseState  :  boolean;

        function   MouseInstalled(var Buttons : word) : boolean;
        procedure  ShowCursor;
        procedure  HideCursor;
        procedure  GetMouseStatus(var Buttons, PosX, PosY : word);
        procedure  SetMousePos(X,Y : word);
        procedure  GetButtonPressed(Button : word; var ButtonStatus, Count, LastPressX, LastPressY : word);
        procedure  GetButtonRelease(Button : word; var ButtonStatus, Count, LastReleaseX, LastReleaseY : word);
        procedure  SetMinMaxX(MinX, MaxX : word);
        procedure  SetMinMaxY(MinY, MaxY : word);
        procedure  SetGraphCursor(HotSpotX, HotSpotY : word; var GraphBlock : MouseGraphBlock);
        procedure  SetTextSoftCursor(ScreenMask, CursorMask : word);
        procedure  SetTextHardCursor(StartScanLine, EndScanCursor : byte);
        procedure  GetMotionCount(var CountX, CountY : word);
        procedure  SetUserMaskCall(Mask : word; UserSubroutine : pointer);
        procedure  LightPenEmulationOn;
        procedure  LightPenEmulationOff;
        procedure  SetSensitivity(MiskeyX, MiskeyY : word);
        procedure  DisableCursorDisplay(UpperX, UpperY, LowerX, LowerY : word);
        procedure  SetDoubleSpeedThreshold(DoubleSpeed : word);
        function   GetMouseDriverSeg : word;

   implementation                { private part }

      var
        MouseRegs : Registers;

      {$L TPMOUSE.OBJ }

      function   MouseInstalled(var Buttons : word) : boolean; external;
      { return the mouse installation info. }

      procedure  ShowCursor; external;
      { shows the mouse cursor. }

      procedure  HideCursor; external;
      { hides the mouse cursor. }

      procedure  GetMouseStatus(var Buttons, PosX, PosY : word); external;
      { returns the current mouse info. }

      procedure  SetMousePos(X,Y : word); external;
      { sets the mouse cursor at a specified position. }

      procedure  GetButtonPressed(Button : word; var ButtonStatus, Count, LastPressX, LastPressY : word); external;
      { returns the mouse button and counts since the last button press. }

      procedure  GetButtonRelease(Button : word; var ButtonStatus, Count, LastReleaseX, LastReleaseY : word); external;
      { returns the mouse button and counts since the last button release. }

      procedure  SetMinMaxX(MinX, MaxX : word); external;
      { sets the minimum and maximum horizontal position to move. }

      procedure  SetMinMaxY(MinY, MaxY : word); external;
      { sets the minimum and maximum vertical position to move. }

      procedure  SetGraphCursor(HotSpotX, HotSpotY : word; var GraphBlock : MouseGraphBlock); external;
      { sets the graphic cursor for the mouse. }

      procedure  SetTextSoftCursor(ScreenMask, CursorMask : word); external;
      { sets the mouse text software cursor. }

      procedure  SetTextHardCursor(StartScanLine, EndScanCursor : byte); external;
      { sets the mouse text hardware cursor. }

      procedure  GetMotionCount(var CountX, CountY : word); external;
      { retuns the mouse motion count. }

      procedure  SetUserMaskCall(Mask : word; UserSubroutine : pointer); external;
      { sets the user-defined subroutine call mask. }

      procedure  LightPenEmulationOn; external;
      { enable the light pen emulation mode. }

      procedure  LightpenEmulationOff; external;
      { disable the light pen emulation mode. }

      procedure  SetSensitivity(MiskeyX, MiskeyY : word); external;
      { set miskey/pixel ratio. }

      procedure  DisableCursorDisplay(UpperX, UpperY, LowerX, LowerY : word); external;
      { disables the mouse cursor display in specified region. }

      procedure  SetDoubleSpeedThreshold(DoubleSpeed : word); external;
      { sets the double speed threshold. }

      function   GetMouseDriverSeg : word;
      { returns the mouse code & data segment. }
      var
         W : word;
      begin
        W := $0;
        if (GetIntVec($33) <> nil) then begin
          MouseRegs.AX := $004D; Intr($33,MouseRegs);
          W := MouseRegs.ES;
        end; { if }
        GetMouseDriverSeg := W;
      end; { GetMouseDriverSeg }

   {begin}    { initializtion }
   end.
