# $Id: readme.txt,v 1.1 2003-07-27 16:11:25+04 dstef Exp root $

NEWLOG.

This is very simple but very effective logfile rotate program.

For full switches and defaults help just type: 
./newlog for UNIX
./newlog.exe for Windows

0 - feature is off
1 - feature is on

Main idea is the logfile rotation thru predefined loop.
Switch explanations:
-m value     minimal value of backup logfile (for example, test.txt.0)
-M value     maximal value of backup logfile (for example, test.txt.10)
-d basedir   catalog, where logfile must be present
-o outdir    catalog, where backup logfile can be stored 
             (this is optional, default is store backups in basedir)
-l logfile   name of logfile to rotate
-c           use compression (use gzip)
-v           verbose output
-p           preserve open logfile handle using copy method,
             not rename method (default is rename)

The GZIP program must be located in the catalog of NEWLOG or in
the searchable path of executables.

Examples:
1.  newlog -b /var/log -l http-access.log -m 0 -M 10 -c -p
2.  newlog.exe -b c:\log -l test.log -m 0 -M 6 -c -p -o c:\baklog


Dmitry Stefankov
27 July 2003
  