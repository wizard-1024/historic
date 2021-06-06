mousekey.exe: mousekey.obj
    f:\tools\link501 /map /Li /inf mousekey;

mousekey.obj: mousekey.asm
    f:\masm51\bin\masm /v /w2 /z mousekey,,;
