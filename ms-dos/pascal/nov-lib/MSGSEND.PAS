{ Sample written by Dmitry Stefankov, 20-May-94 }

PROGRAM   SendMessageToUser;

USES
  Novell;


CONST
  giStation          :    System.Integer    =  1;
  giNumOfStations    :    System.Integer    =  0;


VAR
   gsUserID,
   gsUserName,
   gsMessageToUser,
   gsHexID,
   gsConnectionDateTime            :    STRING;
   giRetcode,
   giOwnStation,
   giConnectionType                :    System.Integer;



BEGIN
   Novell.GetServerInfo;
   System.WriteLn('Send personal message to user.');
   System.Write('Enter username: ');
   System.ReadLn(gsUserName);
   IF (gsUserName = '')
     THEN  BEGIN
        System.WriteLn('No user name specified.');
        System.Halt(1);
           END;
   {if-then}
   System.Write('Enter message: ');
   System.ReadLn(gsMessageToUser);
   IF  (gsMessageToUser = '')
     THEN  BEGIN
        System.WriteLn('No message specified.');
        System.Halt(2);
           END;
   {if-then}
   Novell.Send_Message_To_Username(gsUserName,gsMessageToUser,giRetcode);
   IF (giRetcode = 0)
          THEN  System.WriteLn('Message successful.')
          ELSE  System.WriteLn('Message unsuccessful .');
   {if-then-else}
END.
