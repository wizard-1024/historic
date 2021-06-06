#
# "$Id: typist.mak 1.1 1999/01/03 17:19:06 dstef Exp dstef $"
#

#-----------------------------------------------------------------------#
# PROJECT		MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES	#
#			(COMMERCIAL PURPOSE)				#
# LIBRARY		TEXT_PROCESSING                                 #
# MODULE		INTELLECTUAL_TYPIST                             #
# FILE NAME		TYPIST.MAK					#
# PURPOSE		Decrease greatly the time to type               #
#                       any regular text      				#
# VERSION		0.01						#
# DATE			13-Mar-95					#
# DESIGN		Dmitry Stefankov				#
# IMPLEMENTATION	Dmitry Stefankov 				#
# COMPANY		Freelance Software Engineer                     #
# ADDRESS		Isakowskogo str, 4-2-30				#
#			Moscow, 123181					#
#			USSR						#
#			Tel. 007 (095) 944-6304				#
# COPYRIGHT NOTICE	Copyright (C) 1994-1995, Dmitry Stefankov	#
# RESTRICTED RIGHTS	FOR INTERNAL USE ONLY.				#
#                       THIS FILE CONTAINS PROPRIETARY AND CONFIDENTIAL #
#                       INFORMATION. COPYING AND REPRODUCTION WITHOUT   #
#                       PRIOR WRITTEN PERMISSION IS PROHIBITED.         #
# COMPUTER		IBM PC or compatible				#
# OPERATING SYSTEM	MS/PC-DOS Version 3.30 or higher		#
# COMPILER		Turbo Pascal Version 7.0			#
#                       (Borland International Inc.) or compatible      #
# ASSEMBLY LANGUAGE	Microsoft MASM 5.10 or compatible               #
# LINKER		Turbo Pascal internal                           #
# ARGUMENTS		None                                            #
# RETURN		See description	below    			#
# REQUIRES              Source Code Files                               #
#                       GLOBALS	.PAS	(constants & variables)         #
#			MESSAGES.PAS	(international text messages)	#
#			STRLIB	.PAS	(enhanced strings library)	#
#			VIDEO	.PAS	(standard output for messages)	#
#			DOSCTL	.PAS	(DOS functions manager)		#
#			USRPARM .PAS	(user parameters processing)	#
#			CALLBACK.PAS	(interface with resident part)	#
#			DICTMEM	.PAS	(dump dictionary in memory)	#
#			DEMOMODE.PAS	(demo or simulation mode)	#
#			USERDICT.PAS	(user dictionary)		#
#			CONFIG	.PAS	(user environment file)		#
#			THISVER	.PAS	(info about compiled version)	#
#			External Object Files				#
#			SYSTEM	.TPU	(std TP defs & code)		#
#			DOS	.TPU	(MSDOS support library)		#
#			STRINGS	.TPU	(null-terminated strings funcs)	#
#			SHOWTERR.TPU	(Turbo runtime errors handler)	#
# NATURAL LANGUAGE      English Language                             	#
# SPECIAL		All source files must be contain *together* in  #
#			the same directory. Example = \TP\TYPIST\	#
# DESCRIPTION		Includes all the needed commands to build 	#
#			the commercial or evaluation version of		#
#			the program 'TYPIST'.				#
#			To build a executable program ready to run, 	#
#			type 'nmake typist' w/<enter> for MS NMAKE, or 	#
#			type 'make -f typist.mak' for Borland MAKE.	#
# REVISION HISTORY	Dima Stefankov (DS)				#
#   			0.01   13-Mar-95  DS  initial pre-release	#
#-----------------------------------------------------------------------#


#       Definitions to build targets
PROJ	=TYPIST

#  Build  modules/libraries w/switches (N=no, Y=yes)
BuildAll		=	N
BuildSymbolMap		=	N
BuildCommercialVersion	=	N
BuildEvaluationVersion	=	Y
BuildDebugVersion	=	Y
BuildTestVersion	=	Y
BuildDemoVersion	=	N
BuildStatVersion	=	Y
BuildEnglishVersion	=	Y
BuildRussianVersion	=	Y
AddSpace8KB             =	Y
AddSpace16KB		=	N
UseBorlandPascal	=       Y

#       Miscellaneous


#	Definitions for Assembler

ASM	=masm
AFLAGS	=/V /W2 /Z /N
AINC	=/I.\INC
ASRC	=.\ASM
AOBJ	=.\OBJ

#	Definitions for Compiler

!IF  "$(UseBorlandPascal)" == "Y"
TURBO   =bpc.exe
TPATH   =-Td:\bp70\bin
!ELSE
TURBO	=tpc.exe
TPATH	=-Td:\bp70\bin
!ENDIF
TINC	=/I.
TOBJ	=/O.\OBJ
TOBJ_2	=/O.\..\OBJ

# definitions for symbolic mapper

MAP2SYM  =mapsym.exe
MAPFLAGS =-l

!IF  "$(BuildAll)" == "Y"
BF1 = /B -U.
!ELSE
BF1 = /M -U.
!ENDIF

!IF  "$(BuildCommercialVersion)" == "Y"
BF2	=/DComVer
!ELSE
BF2	=
!ENDIF

!IF  "$(BuildDebugVersion)" == "Y"
BF3	=/DDebVer
!ELSE
BF3	=
!ENDIF

!IF  "$(BuildEnglishVersion)" == "Y"
BF4	=/DEngVer
!ELSE
BF4	=
!ENDIF

!IF  "$(BuildRussianVersion)" == "Y"
BF5     =/DRusVer
!ELSE
BF5     =
!ENDIF

!IF  "$(BuildEvaluationVersion)" == "Y"
BF6	=/DEvaVer
!ELSE
BF6	=
!ENDIF

!IF  "$(AddSpace8KB)" == "Y"
BF7	=/DAdd8KB
!ELSE
BF7	=
!ENDIF

!IF  "$(AddSpace16KB)" == "Y"
BF8	=/DAdd16KB
!ELSE
BF8	=
!ENDIF

!IF  "$(BuildSymbolMap)" == "Y"
BF9	=/GD /V
!ELSE
BF9	=
!ENDIF

!IF  "$(BuildTestVersion)" == "Y"
TF1	=/DTstVer
!ELSE
TF1	=
!ENDIF

!IF  "$(BuildDemoVersion)" == "Y"
TF2	=/DDemVer
!ELSE
TF2	=
!ENDIF

!IF  "$(BuildStatVersion)" == "Y"
TF3	=/DStaVer
!ELSE
TF3	=
!ENDIF



#	PseudoTargets

.SUFFIXES:	.pas  .tpu  .exe  .map .sym


#	Inference rules

.asm.obj: 
	$(ASM) $(AFLAGS) $(AINC) $(*),$(AOBJ)\$(*B);

.pas.tpu: 
	$(TURBO) $(TFLAGS) $(TINC) $(TPATH) $(BF1) $(BF2) $(BF3) $(BF4)\
	$(BF5) $(BF6) $(BF7) $(BF8) $(TF1) $(TF2) $(TF3) $*
	
.pas.exe: 
	$(TURBO) $(TFLAGS) $(TINC) $(TPATH) $(BF1) $(BF2) $(BF3) $(BF4)\
	$(BF5) $(BF6) $(BF7) $(BF8) $(BF9) $(TF1) $(TF2) $(TF3) $*
	
.pas.map:
	$(TURBO) $(TFLAGS) $(TINC) $(TPATH) $(BF1) $(BF2) $(BF3) $(BF4)\
	$(BF5) $(BF6) $(BF7) $(BF8) $(BF9) $(TF1) $(TF2) $(TF3) $*
	
.exe.sym:
	$(MAP2SYM) $(MAPFLAGS) $*


#	Dependencies

!IF  "$(BuildSymbolMap)" == "Y"
TYPIST.SYM:	GLOBALS.TPU	\
		MESSAGES.TPU	\
		STRLIB.TPU	\
		VIDEO.TPU	\
		DOSCTL.TPU	\
		USRPARAM.TPU	\
		CALLBACK.TPU	\
		DICTMEM.TPU	\
!IF  "$(BuildDemoVersion)" == "Y"
		DEMOMODE.TPU	\
!ENDIF		
		USERDICT.TPU	\
		CONFIG.TPU	\
		THISVER.TPU	\
		TYPIST.MAP
!ELSE
TYPIST.EXE:	GLOBALS.TPU	\
		MESSAGES.TPU	\
		STRLIB.TPU	\
		VIDEO.TPU	\
		DOSCTL.TPU	\
		USRPARAM.TPU	\
		CALLBACK.TPU	\
		DICTMEM.TPU	\
!IF  "$(BuildDemoVersion)" == "Y"		
		DEMOMODE.TPU	\
!ENDIF				
		USERDICT.TPU	\
		CONFIG.TPU	\
		THISVER.TPU
!ENDIF

#-------------- Compiling Processs -------------------


		

#--- These are high-level  modules

		

#---------- This is the end of the compling process -----------

clean:
    del *.tpu
    del *.exe
