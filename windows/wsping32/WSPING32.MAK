# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=wsping32 - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to wsping32 - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "wsping32 - Win32 Release" && "$(CFG)" !=\
 "wsping32 - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "wsping32.mak" CFG="wsping32 - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "wsping32 - Win32 Release" (based on\
 "Win32 (x86) Console Application")
!MESSAGE "wsping32 - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "wsping32 - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "wsping32 - Win32 Release"

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

ALL : "$(OUTDIR)\wsping32.exe"

CLEAN : 
	-@erase "$(INTDIR)\WSPING32.OBJ"
	-@erase "$(OUTDIR)\wsping32.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /c
CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D\
 "_MBCS" /Fp"$(INTDIR)/wsping32.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/wsping32.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 wsock32.lib ws2_32.lib kernel32.lib shell32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=wsock32.lib ws2_32.lib kernel32.lib shell32.lib /nologo\
 /subsystem:console /incremental:no /pdb:"$(OUTDIR)/wsping32.pdb" /machine:I386\
 /out:"$(OUTDIR)/wsping32.exe" 
LINK32_OBJS= \
	"$(INTDIR)\WSPING32.OBJ" \
	".\ICMP.LIB"

"$(OUTDIR)\wsping32.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "wsping32 - Win32 Debug"

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

ALL : "$(OUTDIR)\wsping32.exe"

CLEAN : 
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(INTDIR)\WSPING32.OBJ"
	-@erase "$(OUTDIR)\wsping32.exe"
	-@erase "$(OUTDIR)\wsping32.ilk"
	-@erase "$(OUTDIR)\wsping32.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /c
CPP_PROJ=/nologo /MLd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE"\
 /D "_MBCS" /Fp"$(INTDIR)/wsping32.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/wsping32.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 wsock32.lib ws2_32.lib kernel32.lib shell32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=wsock32.lib ws2_32.lib kernel32.lib shell32.lib /nologo\
 /subsystem:console /incremental:yes /pdb:"$(OUTDIR)/wsping32.pdb" /debug\
 /machine:I386 /out:"$(OUTDIR)/wsping32.exe" 
LINK32_OBJS= \
	"$(INTDIR)\WSPING32.OBJ" \
	".\ICMP.LIB"

"$(OUTDIR)\wsping32.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "wsping32 - Win32 Release"
# Name "wsping32 - Win32 Debug"

!IF  "$(CFG)" == "wsping32 - Win32 Release"

!ELSEIF  "$(CFG)" == "wsping32 - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\WSPING32.C
DEP_CPP_WSPIN=\
	".\ICMPAPI.H"\
	".\IPEXPORT.H"\
	

"$(INTDIR)\WSPING32.OBJ" : $(SOURCE) $(DEP_CPP_WSPIN) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\IPEXPORT.H

!IF  "$(CFG)" == "wsping32 - Win32 Release"

!ELSEIF  "$(CFG)" == "wsping32 - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ICMPAPI.H

!IF  "$(CFG)" == "wsping32 - Win32 Release"

!ELSEIF  "$(CFG)" == "wsping32 - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ICMP.LIB

!IF  "$(CFG)" == "wsping32 - Win32 Release"

!ELSEIF  "$(CFG)" == "wsping32 - Win32 Debug"

!ENDIF 

# End Source File
# End Target
# End Project
################################################################################
