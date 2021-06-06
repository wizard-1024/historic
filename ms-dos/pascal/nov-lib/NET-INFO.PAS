{ Examples }
{ Wriiten by Dmitry Stefankov, 20-May-94 }

PROGRAM   GetServerVersion;

USES
  Novell;

{
***** Use for reference ****
      ServerInfo    : Record
                     ReturnLength    : Integer;
                     Server          : Packed Array [1..48] of Byte;
                     NetwareVers     : Byte;
                     NetwareSubV     : Byte;
                     ConnectionMax   : array [1..2] of byte;
                     ConnectionUse   : array [1..2] of byte;
                     MaxConVol       : array [1..2] of byte;
                     OS_revision     : byte;
                     SFT_level       : byte;
                     TTS_level       : byte;
                     peak_used       : array [1..2] of byte;
                  accounting_version : byte;
                     vap_version     : byte;
                     queuing_version : byte;
                print_server_version : byte;
             virtual_console_version : byte;
       security_restrictions_version : byte;
        Internetwork_version_version : byte;
                        Undefined    : Packed Array [1..60] of Byte;
               peak_connections_used : integer;
                     Connections_max : integer;
                  Connections_in_use : integer;
               Max_connected_volumes : integer;
                                name : string;
                   End;
}

CONST
  gsVersion          :    STRING  =  '';
  gsVolumeName       :    STRING  =  '';
  gsUserName         :    STRING  =  '';
  gsRealName         :    STRING  =  '';
  gsUserID           :    STRING  =  '';
  giVolumeNumber     :    System.Integer    =  0;
  giRetcode          :    System.Integer    =  0;
  giStation          :    System.Integer    =  1;
  giConnectionsInUse :    System.Integer    =  0;
  giNumOfStations    :    System.Integer    =  0;
  gchDriveLetter     :    System.Char       =  'F';

BEGIN
   Novell.GetServerInfo;

   giConnectionsInUse := Novell.ServerInfo.Connections_in_use;
   System.WriteLn('# of connections in use: ',giConnectionsInUse);

   Novell.Get_Server_Version(gsVersion);
   System.WriteLn('ServerVersion: '+gsVersion);

   System.Write('Enter drive name (F,G,H,etc): ');
   System.ReadLn(gchDriveLetter);
   gchDriveLetter := System.Upcase(gchDriveLetter);
   giVolumeNumber := System.Ord(gchDriveLetter)-System.Ord('F');
   Novell.Get_Volume_Name(gsVolumeName,giVolumeNumber,giRetcode);
   IF (giRetcode = 0)
     THEN  BEGIN
        System.WriteLn('Volume name of drive '+gchDriveLetter+' is : '+
                        gsVolumeName);
           END
     ELSE  BEGIN
        System.WriteLn('Error of access to volume name of drive '+gchDriveLetter);
           END;
   {if-then-else}

   System.WriteLn('Scan logged-in network users.');
   giNumOfStations := giConnectionsInUse;
   WHILE  (giNumOfStations <> 0) DO
   BEGIN
      Novell.GetUser(giStation,gsUserName,giRetcode);
      IF (giRetcode = 0) AND (gsUserName <> '')
        THEN  BEGIN
            gsUserID := gsUserName;
            Novell.Get_RealName(gsUserID,gsRealName,giRetcode);
            IF (giRetcode <> 0)
               THEN  gsRealName := '';
            {if-then}
            System.WriteLn('Station:  ',giStation,',  UserID: '+gsUserName,',  RealUserName: ',gsRealName);
            System.Dec(giNumOfStations);
              END;
      {if-then}
      System.Inc(giStation);
   END;
   {while-do}

END.
