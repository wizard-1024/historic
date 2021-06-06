@ECHO OFF
masm /DswEmulationReset=0 /DswKeybdTrick=0 restart,coldboot;
link  /tiny coldboot;
masm /DswEmulationReset=1 /DswKeybdTrick=1 restart,wkeyboot;
link /tiny wkeyboot;
masm /DswEmulationReset=1 /DswKeybdTrick=0 restart,warmboot;
link /tiny warmboot;
del *.obj