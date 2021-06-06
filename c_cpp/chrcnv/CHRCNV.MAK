# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=chrcnv - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to chrcnv - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "chrcnv - Win32 Release" && "$(CFG)" != "chrcnv - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "CHRCNV.MAK" CFG="chrcnv - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "chrcnv - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "chrcnv - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "chrcnv - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "chrcnv - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
OUTDIR=.\Release
INTDIR=.\Release

ALL : "$(OUTDIR)\CHRCNV.exe"

CLEAN : 
	-@erase "$(INTDIR)\CHRCNV.OBJ"
	-@erase "$(OUTDIR)\CHRCNV.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /WX /GX /O2 /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /FAcs /YX /c
# SUBTRACT CPP /Fr
CPP_PROJ=/nologo /ML /W3 /WX /GX /O2 /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /FAcs\
 /Fa"$(INTDIR)/" /Fp"$(INTDIR)/CHRCNV.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/CHRCNV.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/CHRCNV.pdb" /machine:I386 /out:"$(OUTDIR)/CHRCNV.exe" 
LINK32_OBJS= \
	"$(INTDIR)\CHRCNV.OBJ"

"$(OUTDIR)\CHRCNV.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "chrcnv - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "$(OUTDIR)\CHRCNV.exe"

CLEAN : 
	-@erase "$(INTDIR)\CHRCNV.OBJ"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\CHRCNV.exe"
	-@erase "$(OUTDIR)\CHRCNV.ilk"
	-@erase "$(OUTDIR)\CHRCNV.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /WX /Gm /GX /Zi /Od /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /FAcs /YX /c
# SUBTRACT CPP /Fr
CPP_PROJ=/nologo /MLd /W3 /WX /Gm /GX /Zi /Od /D "_DEBUG" /D "WIN32" /D\
 "_CONSOLE" /FAcs /Fa"$(INTDIR)/" /Fp"$(INTDIR)/CHRCNV.pch" /YX /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/CHRCNV.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/CHRCNV.pdb" /debug /machine:I386 /out:"$(OUTDIR)/CHRCNV.exe" 
LINK32_OBJS= \
	"$(INTDIR)\CHRCNV.OBJ"

"$(OUTDIR)\CHRCNV.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "chrcnv - Win32 Release"
# Name "chrcnv - Win32 Debug"

!IF  "$(CFG)" == "chrcnv - Win32 Release"

!ELSEIF  "$(CFG)" == "chrcnv - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\CHRCNV.C
DEP_CPP_CHRCN=\
	{$(INCLUDE)}"\sys\stat.h"\
	{$(INCLUDE)}"\sys\types.h"\
	{$(INCLUDE)}"\sys\utime.h"\
	

"$(INTDIR)\CHRCNV.OBJ" : $(SOURCE) $(DEP_CPP_CHRCN) "$(INTDIR)"


# End Source File
# End Target
# End Project
################################################################################
