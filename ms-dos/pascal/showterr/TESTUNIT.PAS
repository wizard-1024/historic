{ Test sample by Dmitry Stefankov, 5/9/95}

{$D+}        {- to disable debug information}
             {+ to enable debug information}
 
UNIT
     TestUnit;

INTERFACE

FUNCTION  _fndwTestFunc : System.Word;

IMPLEMENTATION


FUNCTION  _fndwTestFunc : System.Word;
VAR
  dwA, dwB : System.Word;
BEGIN
    dwA := 5; dwB := 0;
   _fndwTestFunc := dwA DIV dwB;
END;

{BEGIN}
END.
