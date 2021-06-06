# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

!IF "$(CFG)" == ""
CFG=RASKEEP - Win32 (80x86) Debug
!MESSAGE No configuration specified.  Defaulting to RASKEEP - Win32 (80x86)\
 Debug.
!ENDIF 

!IF "$(CFG)" != "RASKEEP - Win32 (80x86) Release" && "$(CFG)" !=\
 "RASKEEP - Win32 (80x86) Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "RASKEEP.MAK" CFG="RASKEEP - Win32 (80x86) Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "RASKEEP - Win32 (80x86) Release" (based on\
 "Win32 (x86) Dynamic-Link Library")
!MESSAGE "RASKEEP - Win32 (80x86) Debug" (based on\
 "Win32 (x86) Dynamic-Link Library")
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
# PROP Target_Last_Scanned "RASKEEP - Win32 (80x86) Debug"
CPP=cl.exe
RSC=rc.exe
MTL=mktyplib.exe

!IF  "$(CFG)" == "RASKEEP - Win32 (80x86) Release"

# PROP BASE Use_MFC 2
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "WinRel"
# PROP BASE Intermediate_Dir "WinRel"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "WinRel"
# PROP Intermediate_Dir "WinRel"
OUTDIR=.\WinRel
INTDIR=.\WinRel

ALL : "$(OUTDIR)\RASKEEP.cpl"

CLEAN : 
	-@erase "$(INTDIR)\RASKEEP.OBJ"
	-@erase "$(INTDIR)\RASKEEP.res"
	-@erase "$(INTDIR)\REGINI.OBJ"
	-@erase "$(OUTDIR)\RASKEEP.cpl"
	-@erase "$(OUTDIR)\RASKEEP.exp"
	-@erase "$(OUTDIR)\RASKEEP.lib"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MD /W3 /GX /O2 /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /FR /YX /c
# ADD CPP /nologo /MT /W3 /WX /GX /O2 /D "NDEBUG" /D "WIN32" /YX /c
# SUBTRACT CPP /Fr
CPP_PROJ=/nologo /MT /W3 /WX /GX /O2 /D "NDEBUG" /D "WIN32"\
 /Fp"$(INTDIR)/RASKEEP.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\WinRel/
CPP_SBRS=.\.
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
RSC_PROJ=/l 0x409 /fo"$(INTDIR)/RASKEEP.res" /d "NDEBUG" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# SUBTRACT BASE BSC32 /Iu
# ADD BSC32 /nologo
# SUBTRACT BSC32 /Iu
BSC32_FLAGS=/nologo /o"$(OUTDIR)/RASKEEP.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib mfc30.lib mfco30.lib mfcd30.lib mfcuia32.lib mfcans32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib gdi32.lib comdlg32.lib advapi32.lib shell32.lib user32.lib /nologo /subsystem:windows /dll /machine:I386 /out:"WinRel/RASKEEP.cpl" /VERSION:3,51
# SUBTRACT LINK32 /verbose
LINK32_FLAGS=kernel32.lib gdi32.lib comdlg32.lib advapi32.lib shell32.lib\
 user32.lib /nologo /subsystem:windows /dll /incremental:no\
 /pdb:"$(OUTDIR)/RASKEEP.pdb" /machine:I386 /def:".\RASKEEP.DEF"\
 /out:"$(OUTDIR)/RASKEEP.cpl" /implib:"$(OUTDIR)/RASKEEP.lib" /VERSION:3,51 
DEF_FILE= \
	".\RASKEEP.DEF"
LINK32_OBJS= \
	"$(INTDIR)\RASKEEP.OBJ" \
	"$(INTDIR)\RASKEEP.res" \
	"$(INTDIR)\REGINI.OBJ"

"$(OUTDIR)\RASKEEP.cpl" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "RASKEEP - Win32 (80x86) Debug"

# PROP BASE Use_MFC 2
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "WinDebug"
# PROP BASE Intermediate_Dir "WinDebug"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "WinDebug"
# PROP Intermediate_Dir "WinDebug"
OUTDIR=.\WinDebug
INTDIR=.\WinDebug

ALL : "$(OUTDIR)\RASKEEP.cpl"

CLEAN : 
	-@erase "$(INTDIR)\RASKEEP.OBJ"
	-@erase "$(INTDIR)\RASKEEP.res"
	-@erase "$(INTDIR)\REGINI.OBJ"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\RASKEEP.cpl"
	-@erase "$(OUTDIR)\RASKEEP.exp"
	-@erase "$(OUTDIR)\RASKEEP.lib"
	-@erase "$(OUTDIR)\RASKEEP.map"
	-@erase "$(OUTDIR)\RASKEEP.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MD /W3 /GX /Zi /Od /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /FR /YX /c
# ADD CPP /nologo /MTd /W3 /WX /Gm /GX /Zi /Od /D "_DEBUG" /D "WIN32" /YX /c
# SUBTRACT CPP /Fr
CPP_PROJ=/nologo /MTd /W3 /WX /Gm /GX /Zi /Od /D "_DEBUG" /D "WIN32"\
 /Fp"$(INTDIR)/RASKEEP.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\WinDebug/
CPP_SBRS=.\.
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
RSC_PROJ=/l 0x409 /fo"$(INTDIR)/RASKEEP.res" /d "_DEBUG" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# SUBTRACT BASE BSC32 /Iu
# ADD BSC32 /nologo
# SUBTRACT BSC32 /Iu
BSC32_FLAGS=/nologo /o"$(OUTDIR)/RASKEEP.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib mfc30d.lib mfco30d.lib mfcd30d.lib mfcuia32.lib mfcans32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 kernel32.lib gdi32.lib comdlg32.lib advapi32.lib shell32.lib user32.lib /nologo /subsystem:windows /dll /incremental:no /map /debug /machine:I386 /out:"WinDebug/RASKEEP.cpl" /VERSION:3,51
# SUBTRACT LINK32 /verbose
LINK32_FLAGS=kernel32.lib gdi32.lib comdlg32.lib advapi32.lib shell32.lib\
 user32.lib /nologo /subsystem:windows /dll /incremental:no\
 /pdb:"$(OUTDIR)/RASKEEP.pdb" /map:"$(INTDIR)/RASKEEP.map" /debug /machine:I386\
 /def:".\RASKEEP.DEF" /out:"$(OUTDIR)/RASKEEP.cpl"\
 /implib:"$(OUTDIR)/RASKEEP.lib" /VERSION:3,51 
DEF_FILE= \
	".\RASKEEP.DEF"
LINK32_OBJS= \
	"$(INTDIR)\RASKEEP.OBJ" \
	"$(INTDIR)\RASKEEP.res" \
	"$(INTDIR)\REGINI.OBJ"

"$(OUTDIR)\RASKEEP.cpl" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "RASKEEP - Win32 (80x86) Release"
# Name "RASKEEP - Win32 (80x86) Debug"

!IF  "$(CFG)" == "RASKEEP - Win32 (80x86) Release"

!ELSEIF  "$(CFG)" == "RASKEEP - Win32 (80x86) Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\RASKEEP.DEF

!IF  "$(CFG)" == "RASKEEP - Win32 (80x86) Release"

!ELSEIF  "$(CFG)" == "RASKEEP - Win32 (80x86) Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\RASKEEP.RC
DEP_RSC_RASKE=\
	".\AUTHOR.BMP"\
	".\CANADA.ICO"\
	".\CONNECT.ICO"\
	".\HELP.ICO"\
	".\PHONE.ICO"\
	".\RASKEEP.H"\
	".\RASKEEP.ICO"\
	

"$(INTDIR)\RASKEEP.res" : $(SOURCE) $(DEP_RSC_RASKE) "$(INTDIR)"
   $(RSC) $(RSC_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=.\RASKEEP.C
DEP_CPP_RASKEE=\
	".\COMPILE.H"\
	".\DEBUG.H"\
	".\FPROTO.H"\
	".\RASDATA.H"\
	".\RASDEFS.H"\
	".\RASKEEP.H"\
	".\RASPROTO.H"\
	

"$(INTDIR)\RASKEEP.OBJ" : $(SOURCE) $(DEP_CPP_RASKEE) "$(INTDIR)"


# End Source File
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
# End Target
# End Project
################################################################################
