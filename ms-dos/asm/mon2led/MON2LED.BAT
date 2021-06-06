@echo off
masm mon2led.asm;
if errorlevel 1 goto :end
link mon2led.obj;
:end