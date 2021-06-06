@echo off
f:\masm51\bin\masm /v shdump,,;
if errorlevel 1 goto done
f:\masm51\bin\link shdump;
f:\utils\exe2bin shdump.exe shdump.com
:done