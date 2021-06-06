/*
   Simple memory stress test
   
   Copyright (c) 2002 Dmitry Stefankov
*/

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

int main(int argc, char ** argv)
{
  void * p;
  unsigned long int msize = 1024 * 1024;
  int  sleep_time_set;
  int  sleep_time_run;
  int  debug_print=0;
  
  if (argc < 4) {
    fprintf( stderr, "Usage: %s MB-size sleep-set sleep-active\n", argv[0] );
    return 1;
  }
  
  sleep_time_set=atoi(argv[2]);
  sleep_time_run=atoi(argv[3]);
  msize *= atol( argv[1] );
  if (debug_print)  
    printf( "Request for %s MB\n", argv[1] );
  p = malloc( msize );
  if (p == NULL) {
    fprintf( stderr, "ERROR: Cannot allocate memory! Code = %d", errno );
    return 1;
  }
  if (debug_print)  
    printf( "Memory allocated.\n" );

  sleep(sleep_time_set); 
  if (debug_print)  
    printf( "Init memory.\n" );
  memset( p, 1, msize );

  if (debug_print)
    printf( "Sleep now.\n" );
  sleep(sleep_time_run);

  if (debug_print)
    printf( "Free memory.\n" );
  free(p);


  return 0;
}
