timepark.exe: timepark.obj
    link501 /map /Li /inf timepark;

timepark.obj: timepark.asm 
    f:\masm51\bin\masm /v /w2 /z timepark,,;
