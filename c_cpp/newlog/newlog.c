/*
   Logfile rotation
   Copyright (c) 2003 Dmitry Stefankov
   
   $Id: newlog.c,v 1.3 2003-07-27 15:43:05+04 dstef Exp root $
*/


#if defined(_WIN32)
#include <windows.h>
#include "getopt.h"
#else
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <sys/stat.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


#if defined(_WIN32)
#define  snprintf _snprintf
#endif


#define  FILEPATH            256
#define  DIR_BUF_SIZ         1024 
#define  WAIT_RUN_MS         1000

char    g_compression_ext[] = "gz";
#if defined(_WIN32)
char   g_compression_program[] = "gzip.exe";
char   g_sep_char[] = "\\";
#else
char   g_compression_program[] = "gzip";
char   g_sep_char[] = "/";
#endif
int     g_compression = 0;                  /* Use external GZIP */
int     g_verbose = 0;                      /* Display progress */
int     g_copyfile = 0;                     /* Preserve open file handles */

extern  int        optind;
extern  int        opterr;
extern  char     * optarg;

char *  version = "1.0.0";
char *  program_name;


/*
 * Real compression process
 */
#if defined(_WIN32)
int   RunCompressProgram( char * szProgramFile, char * szDataFile )
{
  int             retcode = -1;             /* Return function result */
  char          szProcessName[DIR_BUF_SIZ]; /* PGP program pathname   */
  STARTUPINFO             si;               /* Window information     */
  PROCESS_INFORMATION     pi;               /* Process information    */
  BOOL                    fSuccess;         /* Boolean switch         */
  DWORD                   dwExitCode;       /* Process exit code      */
  BOOL                    bRunRes;          /* Function result        */
  DWORD                   dwRetVal;         /* Event object status    */
  DWORD                   fRun = 1;         /* Wait to PGP finish     */

  if ((szProgramFile == NULL) || (szDataFile == NULL))
    return(retcode);

    /* Build command line */
    strncpy( szProcessName, szProgramFile, sizeof(szProcessName) );

    strncat( szProcessName, " ", sizeof(szProcessName)-strlen(szProcessName) );
    strncat( szProcessName, szDataFile, sizeof(szProcessName)-strlen(szProcessName) );

    /* Run process with redirected input/output */
    ZeroMemory( &si, sizeof(si) );
    si.cb = sizeof(si);
    ZeroMemory( &pi, sizeof(pi) );

    bRunRes = CreateProcess( NULL, szProcessName, NULL, NULL, FALSE,
                             CREATE_NO_WINDOW, NULL, NULL, &si, &pi );

    if (bRunRes == FALSE) {
      retcode = 2;
      return(retcode);
    }

    /* Waiting loop */
    while( fRun ) {
      dwRetVal = WaitForSingleObject( pi.hProcess, WAIT_RUN_MS );
      switch( dwRetVal ) {
        case WAIT_OBJECT_0:
           fRun = 0;
           break;
        case WAIT_TIMEOUT:
           break;
        case WAIT_FAILED:
           fRun = 0;
           break;
        default:
           break;
      }
    }

    dwExitCode = 99;
    fSuccess = GetExitCodeProcess ( pi.hProcess, &dwExitCode);
    retcode = dwExitCode;

    CloseHandle( pi.hProcess );
    CloseHandle( pi.hThread );

  return(retcode);
}
#else
int   RunCompressProgram( char * program, char * datafile )
{
  int      res = 1;
  pid_t    pid;
  int      status = -1;
  char     cmdstr[128];
  
  if ((program == NULL) || (datafile == NULL))
    return(res);
  
  strncpy( cmdstr, program, sizeof(cmdstr) );
  strncat( cmdstr, " ", sizeof(cmdstr) );  
  strncat( cmdstr, datafile, sizeof(cmdstr) );
  
  switch( pid = fork()) {
    case -1: 
           res = 2;
           break;
    case 0:
          /* child */
          execl( "/bin/sh", "sh","-c", cmdstr, NULL,NULL );
          res = 3;
          break;
    default:
          wait(&status);
          res = status;
          break;
  }

  return(res);
}

#endif


/*
 * Run file through compression utility
 */
int  run_compress_prog( char * filename )
{
  int   retcode = -1;

  retcode = RunCompressProgram( g_compression_program , filename );
  if (g_verbose) printf( "compression_result = %d\n", retcode );

  return(retcode);
}


#if !defined(_WIN32)
int  copyfile( char * src, char * dst )
{
    int      sf;
    int      df;
    int      bytes;
    int      res;
    size_t   file_size;
    struct stat   filestat;
    unsigned char  buf[16384];
    
    if ((src == NULL) || (dst == NULL)) return(-1);

    if (stat(src,&filestat) == -1) return(-2);     
    file_size = filestat.st_size;
     
    sf = open( src, O_RDONLY );
    if (sf == -1) return(-3);
    
    df = open( dst, O_WRONLY|O_CREAT|O_TRUNC );
    if (df == -1) return(-4);

    while( file_size ) {
      if (file_size < sizeof(buf)) bytes = file_size;
      else bytes = sizeof(buf);
      res = read(sf,buf,bytes);
      if (res != -1) res = write(df,buf,bytes);
      file_size -= bytes;
    };
        
    close(sf);
    close(df);
    
    
    return(0);
}
#endif


/*
 * Help.
 */
void usage(void)
{
  fprintf( stderr, "\n" );
  fprintf( stderr, "LOG_FILE_ROTATE program\n" );
  fprintf( stderr, "Copyright (C) 2003 Dmitry Stefankov. All rights reserved.\n" );
  fprintf( stderr, "\n" );
  fprintf( stderr, "%s version %s\n", program_name, version );
  fprintf( stderr, "Usage: %s [-chvp] [-d basedir] [-l logfile ] [-o outdir]\n", program_name ); 
  fprintf( stderr, "\t\t[-m minvalue] [-M maxvalue]\n" );
  fprintf( stderr, "Defaults:\n" );
  fprintf( stderr, "  verbose level           --  %d [-v]\n", g_verbose );
  fprintf( stderr, "  compression             --  %d [-c]\n", g_compression );  
  fprintf( stderr, "  compression program     --  %s\n", g_compression_program );
  fprintf( stderr, "  preserve open logfile   --  %d [-p]\n", g_copyfile );
  exit(1);
}


/*
 * Main program
 */
int main( int argc, char ** argv )
{
  int       op;
  char    * cp;
  FILE    * fp;
  int       minval = -1;
  int       maxval = -1;
  int       res;
  int       i;
  int       create_file;
  char      valbuf[10];
  char    * basedir = NULL;
  char      basefile[FILEPATH];
  char    * mainfile = NULL;
  char    * outdir = NULL; 
  char      tempname[FILEPATH];
  char      oldname[FILEPATH];
  char      newname[FILEPATH];

/* Find program name */  
  if ((cp = strrchr(argv[0],'/')) != NULL)
     program_name = cp + 1;
  else
     program_name = argv[0];

/* Process command line  */  
  opterr = 0;
  while( (op = getopt(argc,argv,"cd:hl:m:M:o:pv")) != -1) {
    switch(op) {
      case 'c':
               g_compression++;
               break;
      case 'd':
               basedir = optarg;
               break;
      case 'm': 
               minval = atoi(optarg);
               break;
      case 'l':
               mainfile = optarg;
               break;
      case 'M':
               maxval = atoi(optarg);
               break;
      case 'o':
               outdir = optarg;
               break;
      case 'p':
               g_copyfile++;
               break;
      case 'v':
               g_verbose++;
               break;
      case 'h':
               usage();
               break;      
      default:
               usage();
               break;
    }
  }

  if (argc < 2) {
    usage();
    return(1);
  }

  if (minval == -1 ) {
    fprintf( stderr, "Min. value must be present!\n" );
    return(1);
  }

  if (maxval == -1 ) {
    fprintf( stderr, "Max. value must be present!\n" );
    return(1);
  }

  if (basedir == NULL ) {
    fprintf( stderr, "Base catalog must be present!\n" );
    return(1);
  }

  if (mainfile == NULL ) {
    fprintf( stderr, "Logfile must be present!\n" );
    return(1);
  }
    
  if (g_verbose) 
    printf( "parms: %s %s %d %d\n", basedir, mainfile, minval, maxval );

  strncpy( basefile, basedir, sizeof(basefile) );
  strncat( basefile, g_sep_char, sizeof(basefile) );
  strncat( basefile, mainfile, sizeof(basefile) );
  if (g_verbose) printf( "base=%s\n", basefile );

  if (outdir == NULL) {
    strncpy( tempname, basefile, sizeof(tempname) );
  }
  else {
    strncpy( tempname, outdir, sizeof(tempname) );
    strncat( tempname, g_sep_char, sizeof(tempname) );
    strncat( tempname, mainfile, sizeof(tempname) );
  }
  strncat( tempname, ".", sizeof(tempname) );
  snprintf( valbuf, sizeof(valbuf), "%d", maxval );
  strncat( tempname, valbuf, sizeof(tempname) );
  if (g_compression) {
    strncat( tempname, ".", sizeof(tempname) );
    strncat( tempname, g_compression_ext, sizeof(tempname) );
  }
  if (g_verbose) printf( "maxfile: %s\n", tempname );

  fp = fopen( tempname, "r" );
  if (fp != NULL) {
    fclose(fp);
    res = remove( tempname );
    if (g_verbose) printf( "delete maxfile = %d.\n", res );
  }

  if (outdir == NULL) {  
    strncpy( tempname, basefile, sizeof(tempname) );
  }
  else {
    strncpy( tempname, outdir, sizeof(tempname) );
    strncat( tempname, g_sep_char, sizeof(tempname) );
    strncat( tempname, mainfile, sizeof(tempname) );  
  }
  strncat( tempname, ".", sizeof(tempname) );

  for( i=maxval; i>minval; i-- ) {

    strncpy( oldname, tempname, sizeof(oldname) );
    snprintf( valbuf, sizeof(valbuf), "%d", i-1 );
    strncat( oldname, valbuf, sizeof(oldname) );
    if (g_compression) {
      strncat( oldname, ".", sizeof(oldname) );
      strncat( oldname, g_compression_ext, sizeof(oldname) );
    }

    strncpy( newname, tempname, sizeof(newname) );
    snprintf( valbuf, sizeof(valbuf), "%d", i );
    strncat( newname, valbuf, sizeof(newname) );
    if (g_compression) {
      strncat( newname, ".", sizeof(tempname) );
      strncat( newname, g_compression_ext, sizeof(newname) );
    }

    res = rename( oldname, newname );
    if (g_verbose) printf( "%s -> %s, res=%d\n", oldname, newname, res );

  }

  if (outdir == NULL) {  
    strncpy( tempname, basefile, sizeof(tempname) );
  }
  else {
    strncpy( tempname, outdir, sizeof(tempname) );
    strncat( tempname, g_sep_char, sizeof(tempname) );
    strncat( tempname, mainfile, sizeof(tempname) );  
  }
  strncat( tempname, ".", sizeof(tempname) );
  snprintf( valbuf, sizeof(valbuf), "%d", minval );
  strncat( tempname, valbuf, sizeof(tempname) );
  if (g_verbose)  printf( "minfile: %s\n", tempname );

  create_file = 1;
  fp = fopen( basefile, "r" );
  if (fp != NULL) {
    fclose(fp);
    if (g_copyfile) {
#if defined(_WIN32)
      BOOL   fRes;
      fRes = CopyFile( basefile, tempname, FALSE );
      if (g_verbose) printf( "WIN32: %s -> %s, res=%lu\n", basefile, tempname, fRes );
#else
      res = copyfile( basefile, tempname ); 
      if (g_verbose) printf( "UNIX: %s -> %s, res=%d\n", basefile, tempname, res );
#endif
      create_file = 0;
    }
    else {
      res = rename( basefile, tempname );
      if (g_verbose) printf( "%s -> %s, res=%d\n", basefile, tempname, res );
    }
    if (g_compression) {
      if (g_verbose) printf( "run_compression for %s\n", tempname );
      run_compress_prog( tempname );
    }
  }
  
  fp = fopen( basefile, "wb" );
  if (fp != NULL) {
      if (g_verbose) printf( "create/open file.\n" );
      if (create_file == 0) {
        if (g_verbose) printf( "truncate file.\n" );
        fwrite( valbuf, 0, 0, fp );
      }
      fclose( fp );
  }

  return(0);
}
