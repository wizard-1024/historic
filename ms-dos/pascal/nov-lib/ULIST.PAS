{ Sample written by Dmitry Stefankov, 20-May-94 }

PROGRAM   NovellLoggedUserInfo;

USES
  Novell;


CONST
  giStation          :    System.Integer    =  1;
  giNumOfStations    :    System.Integer    =  0;
  giActiveUsers      :    System.Integer    =  0;


VAR
   gsUserID,
   gsServerName,
   gsHexID,
   gsConnectionDateTime            :    STRING;
   giRetcode,
   giOwnStation,
   giMaxConnection,
   giConnectionType                :    System.Integer;



BEGIN
   Novell.GetServerInfo;
   
   Novell.GetStation(giOwnStation,giRetcode);
   IF (giRetcode <> 0)
     THEN  BEGIN
        System.WriteLn('Novell Network services access error occurred.');
        System.Halt(1);
           END;
   {if-then}

   System.WriteLn('Logged-In User List for Server ',Novell.ServerInfo.name);
   System.WriteLn('Connection  UserID                         Logged-In Date/Time');
   System.WriteLn('----------  -----------------------------  ---------------------');

   giNumOfStations := Novell.ServerInfo.Connections_in_use;
   giMaxConnection := Novell.ServerInfo.Connections_Max;
   WHILE  (giNumOfStations <> 0) AND (giStation <= giMaxConnection) DO
   BEGIN
      Novell.GetConnectionInfo(giStation,
                               gsUserID,
                               gsHexID,
                               giConnectionType,
                               gsConnectionDateTime,
                               giRetcode);
      IF (giRetcode = 0) AND (gsUserID <> '')
        THEN  BEGIN
            System.Dec(giNumOfStations);
            System.Inc(giActiveUsers);
            System.Write(giStation:6);
            System.Write('    ');
            IF (giStation = giOwnStation)
              THEN  System.Write('* ')
              ELSE  System.Write('  ');
            {if-then-else}
            IF  (System.Length(gsUserID) > 29)
              THEN  gsUserID := System.Copy(gsUserID,1,29)
              ELSE  BEGIN
                 WHILE  (System.Length(gsUserID) < 29) DO
                 BEGIN
                    gsUserID := gsUserID+' ';
                 END;
                 {while-do}
                    END;
            {if-then-else}
            System.Write(gsUserID);
            System.WriteLn(' ',gsConnectionDateTime);
              END;
      {if-then}
      System.Inc(giStation);
   END;
   {while-do}
   IF (giActiveUsers = 0)
     THEN  System.WriteLn('No active users in network.');
   {if-then}
END.
