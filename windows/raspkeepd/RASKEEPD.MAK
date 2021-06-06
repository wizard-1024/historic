# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=RASKEEPD - Win32 Release
!MESSAGE No configuration specified.  Defaulting to RASKEEPD - Win32 Release.
!ENDIF 

!IF "$(CFG)" != "RASKEEPD - Win32 Release" && "$(CFG)" !=\
 "RASKEEPD - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "RASKEEPD.MAK" CFG="RASKEEPD - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "RASKEEPD - Win32 Release" (based on\
 "Win32 (x86) Console Application")
!MESSAGE "RASKEEPD - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 
################################################################################
# Begin Project
# PROP Target_Last_Scanned "RASKEEPD - Win32 Release"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "RASKEEPD - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "WinRel"
# PROP BASE Intermediate_Dir "WinRel"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "WinRel"
# PROP Intermediate_Dir "WinRel"
OUTDIR=.\WinRel
INTDIR=.\WinRel

ALL : "$(OUTDIR)\RASKEEPD.exe"

CLEAN : 
	-@erase "$(INTDIR)\messages.res"
	-@erase "$(INTDIR)\RASKEEPD.OBJ"
	-@erase "$(INTDIR)\REGINI.OBJ"
	-@erase "$(OUTDIR)\RASKEEPD.exe"
	-@erase "$(OUTDIR)\RASKEEPD.map"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /FR /YX /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# SUBTRACT CPP /Fr
CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE"\
 /Fp"$(INTDIR)/RASKEEPD.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\WinRel/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x419 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
RSC_PROJ=/l 0x409 /fo"$(INTDIR)/messages.res" /d "NDEBUG" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/RASKEEPD.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 wsock32.lib rasapi32.lib icmp.lib kernel32.lib advapi32.lib shell32.lib /nologo /subsystem:console /map /machine:I386
# SUBTRACT LINK32 /incremental:yes
LINK32_FLAGS=wsock32.lib rasapi32.lib icmp.lib kernel32.lib advapi32.lib\
 shell32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/RASKEEPD.pdb" /map:"$(INTDIR)/RASKEEPD.map" /machine:I386\
 /out:"$(OUTDIR)/RASKEEPD.exe" 
LINK32_OBJS= \
	"$(INTDIR)\messages.res" \
	"$(INTDIR)\RASKEEPD.OBJ" \
	"$(INTDIR)\REGINI.OBJ" \
	".\ICMP.LIB"

"$(OUTDIR)\RASKEEPD.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "RASKEEPD - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Win32_De"
# PROP BASE Intermediate_Dir "Win32_De"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "WinDebug"
# PROP Intermediate_Dir "WinDebug"
OUTDIR=.\WinDebug
INTDIR=.\WinDebug

ALL : "$(OUTDIR)\RASKEEPD.exe"

CLEAN : 
	-@erase "$(INTDIR)\messages.res"
	-@erase "$(INTDIR)\RASKEEPD.OBJ"
	-@erase "$(INTDIR)\REGINI.OBJ"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\RASKEEPD.exe"
	-@erase "$(OUTDIR)\RASKEEPD.map"
	-@erase "$(OUTDIR)\RASKEEPD.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /FR /YX /c
# ADD CPP /nologo /W3 /Gm /GX /Zi /O2 /D "WIN32" /D "_CONSOLE" /D "_DEBUG" /YX /c
# SUBTRACT CPP /Fr
CPP_PROJ=/nologo /ML /W3 /Gm /GX /Zi /O2 /D "WIN32" /D "_CONSOLE" /D "_DEBUG"\
 /Fp"$(INTDIR)/RASKEEPD.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\WinDebug/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
RSC_PROJ=/l 0x409 /fo"$(INTDIR)/messages.res" /d "NDEBUG" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/RASKEEPD.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib advapi32.lib wsock32.lib rasapi32.lib icmp.lib /nologo /subsystem:console /map /machine:I386
# SUBTRACT BASE LINK32 /incremental:yes
# ADD LINK32 wsock32.lib rasapi32.lib icmp.lib kernel32.lib advapi32.lib shell32.lib comctl32.lib /nologo /subsystem:console /map /debug /machine:I386
# SUBTRACT LINK32 /incremental:yes
LINK32_FLAGS=wsock32.lib rasapi32.lib icmp.lib kernel32.lib advapi32.lib\
 shell32.lib comctl32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/RASKEEPD.pdb" /map:"$(INTDIR)/RASKEEPD.map" /debug\
 /machine:I386 /out:"$(OUTDIR)/RASKEEPD.exe" 
LINK32_OBJS= \
	"$(INTDIR)\messages.res" \
	"$(INTDIR)\RASKEEPD.OBJ" \
	"$(INTDIR)\REGINI.OBJ" \
	".\ICMP.LIB"

"$(OUTDIR)\RASKEEPD.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

################################################################################
# Begin Target

# Name "RASKEEPD - Win32 Release"
# Name "RASKEEPD - Win32 Debug"

!IF  "$(CFG)" == "RASKEEPD - Win32 Release"

!ELSEIF  "$(CFG)" == "RASKEEPD - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\REGINI.C
DEP_CPP_REGIN=\
	".\COMPILE.H"\
	".\DEBUG.H"\
	".\FPROTO.H"\
	".\RASDEFS.H"\
	".\RASPROTO.H"\
	

"$(INTDIR)\REGINI.OBJ" : $(SOURCE) $(DEP_CPP_REGIN) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\RASKEEPD.C
DEP_CPP_RASKE=\
	".\COMPILE.H"\
	".\DEBUG.H"\
	".\FPROTO.H"\
	".\ICMPAPI.H"\
	".\IPEXPORT.H"\
	".\messages.h"\
	".\RASDATA.H"\
	".\RASDEFS.H"\
	".\RASPROTO.H"\
	

"$(INTDIR)\RASKEEPD.OBJ" : $(SOURCE) $(DEP_CPP_RASKE) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\messages.rc
DEP_RSC_MESSA=\
	".\MSG00001.bin"\
	

"$(INTDIR)\messages.res" : $(SOURCE) $(DEP_RSC_MESSA) "$(INTDIR)"
   $(RSC) $(RSC_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\MESSAGES.MC

!IF  "$(CFG)" == "RASKEEPD - Win32 Release"

!ELSEIF  "$(CFG)" == "RASKEEPD - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ICMP.LIB

!IF  "$(CFG)" == "RASKEEPD - Win32 Release"

!ELSEIF  "$(CFG)" == "RASKEEPD - Win32 Debug"

!ENDIF 

# End Source File
# End Target
# End Project
################################################################################
