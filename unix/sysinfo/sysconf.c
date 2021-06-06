//****************************************************************************
//                           File sysconf.c
//
//                  Get configurable system variables      
//           Posix.1 (IEEE Std 1003.1-1988), Posix.2, Posix.4, Libc
//
//      Copyright (c) Dmitry V. Stefankov, 2002. All rights reserved.
//
//****************************************************************************
//
//   $Source: /root/unix_systems/sysinfo/RCS/sysconf.c,v $
//  $RCSfile: sysconf.c,v $
//   $Author: dstef $
//     $Date: 2002-09-21 13:17:09+04 $
// $Revision: 1.2 $
//   $Locker: root $
//
//      $Log: sysconf.c,v $
//      Revision 1.2  2002-09-21 13:17:09+04  dstef
//      Added rcs_id
//
//      Revision 1.1  2002-09-21 13:16:00+04  dstef
//      Initial revision
//
//****************************************************************************


#include <unistd.h>
#include <stdio.h>
#include <errno.h>

#define    _POSIX_12_SYSCONF    1
#define    _POSIX_4_SYSCONF     1
#define    _LIBC_PATHCONF       1

#define    SC_MAX_NUM           27
#define    SC_RT_MAX_NUM        25
#define    SC_PC_MAX_NUM	9

const char rcs_id[] = "$Id: sysconf.c,v 1.2 2002-09-21 13:17:09+04 dstef Exp root $";

struct sysconf_var {
   int    sc_value;
   char * sc_name;
};


#if _POSIX_12_SYSCONF
struct sysconf_var  sc_var_array[SC_MAX_NUM] = { 
   { _SC_ARG_MAX,      "Max bytes of argument of execve(2)" },
   { _SC_CHILD_MAX,    "Max number of simultaneous processes per user" },
   { _SC_CLK_TCK,      "Frequency of statistics clock in ticks per second" },
   { _SC_NGROUPS_MAX,  "Max number of supplemental groups" },
   { _SC_OPEN_MAX,     "Max number of open files per user" },
   { _SC_JOB_CONTROL,  "Job control is available on this system" },
   { _SC_SAVED_IDS,    "Saved set-group and set-user ID available" },
   { _SC_VERSION,      "Version of IEEE Std 1003.1 (POSIX.1) to comply" },
   { _SC_BC_BASE_MAX,  "Max ibase/obase values in the bc(1)" },
   { _SC_BC_DIM_MAX,   "Max array size in the bc(1)" },
   { _SC_BC_SCALE_MAX, "Max scale value in the bc(1)" },
   { _SC_BC_STRING_MAX, "Max string length in the bc(1)" },	
   { _SC_COLL_WEIGHTS_MAX, "Max weights for LC_COLLATE in localedef(1M)" },
   { _SC_EXPR_NEST_MAX, "Max parenthesis nesting level for expr(1)" },
   { _SC_LINE_MAX,     "Max length in bytes of a text input line" },
   { _SC_RE_DUP_MAX,   "Max repeated occurrences of RegExp in regcmp(3)" },
   { _SC_STREAM_MAX,   "Max number of stdio streams per process" },
   { _SC_TZNAME_MAX,   "Max number of supported types for name of timezone" },
   { _SC_2_VERSION,    "Version of IEEE Std 1003.2 (POSIX.2) to comply" },
   { _SC_2_C_BIND,     "System has C-Language Bindings Option" },
   { _SC_2_C_DEV,      "System has C-Language Development Utilities Option" },
   { _SC_2_CHAR_TERM,  "System has at least one terminal type capability" },
   { _SC_2_FORT_DEV,   "System has FORTRAN Development Utilities Option" },
   { _SC_2_FORT_RUN,   "System has FORTRAN Runtime Utilities Option" },
   { _SC_2_LOCALEDEF,  "System supports locales creation" },
   { _SC_2_SW_DEV,     "System has Software Development Utilities Option" },
   { _SC_2_UPE,        "System has User Portability Utilities Option" }
                                               };
#endif

#if _POSIX_4_SYSCONF
struct sysconf_var  sc_rt_var_array[SC_RT_MAX_NUM] = { 
   { _SC_ASYNCHRONOUS_IO, "POSIX.4 Asynchronous I/O availability" },
   { _SC_MAPPED_FILES, "POSIX.4 memory-mapped files" },
   { _SC_MEMLOCK, "POSIX.4 process memory locking" },	
   { _SC_MEMLOCK_RANGE, "POSIX.4 process memory locking range" },
   { _SC_MEMORY_PROTECTION, "POSIX.4 memory protection" },
   { _SC_MESSAGE_PASSING, "POSIX.4 message passing" },	
   { _SC_PRIORITIZED_IO, "POSIX.4 Prioritized async I/O availability" },	
   { _SC_PRIORITY_SCHEDULING, "POSIX.4 real-time process scheduling" },
   { _SC_REALTIME_SIGNALS, "POSIX.4 real-time (queued) signals" },	
   { _SC_SEMAPHORES, "POSIX.4 semaphores" },	
   { _SC_FSYNC, "POSIX.4 file-and-disk state synchronization" },	
   { _SC_SHARED_MEMORY_OBJECTS, "POSIX.4 shared memory objects" },
   { _SC_SYNCHRONIZED_IO, "POSIX.4 synchronous I/O availability" },	
   { _SC_TIMERS, "POSIX.4 max number of clocks and timers" },	
   { _SC_AIO_LISTIO_MAX, "POSIX.4 max operations in one call" },
   { _SC_AIO_MAX, "POSIX.4 max concurrent asynchronous I/Os" },		
   { _SC_AIO_PRIO_DELTA_MAX, "POSIX.4 max amount to decrease AIO priority" },
   { _SC_DELAYTIMER_MAX, "POSIX.4 number of overrun times per timer" },
   { _SC_MQ_OPEN_MAX, "POSIX.4 max number of message queues per process" },		
   { _SC_PAGESIZE, "POSIX.4 page size per process" },		
   { _SC_RTSIG_MAX, "POSIX.4 max real-time signals" },		
   { _SC_SEM_NSEMS_MAX, "POSIX.4 max number of open semaphores per process" },
   { _SC_SEM_VALUE_MAX, "POSIX.4 max number of semaphors" },	
   { _SC_SIGQUEUE_MAX, "POSIX.4 max number of real-timer signals per process" },	
   { _SC_TIMER_MAX, "POSIX.4 max number of timers per process" }
                                                     };
#endif

#if _LIBC_PATHCONF
struct sysconf_var  sc_pc_var_array[SC_PC_MAX_NUM] = {
   { _PC_LINK_MAX,    "Max file link count" },
   { _PC_MAX_CANON,   "Max number of bytes in terminal canonical input line" },
   { _PC_MAX_INPUT,   "Max (min) in bytes space for terminal input queue" },
   { _PC_NAME_MAX,    "Max number of bytes in a file name" },
   { _PC_PATH_MAX,    "Max number of bytes in a pathname" },
   { _PC_PIPE_BUF,    "Max bytes in atomic write operation to pipe" },
   { _PC_CHOWN_RESTRICTED, "Appropriate privileges are required for the chown(2)" },
   { _PC_NO_TRUNC,    "File names longer than KERN_NAME_MAX are truncated" },
   { _PC_VDISABLE,    "Terminal character disabling value" }
						     };
#endif
						     

void print_sysconf_val( int sc_value, char * sc_name )
{
  long val;
  
  errno = 0;
  val = sysconf( sc_value );
  
  printf("%56-s", sc_name );
  if ((val == -1) && (errno)) {
      printf("not conformed\n" );
  } else if ((val == -1) && (!errno)) {
      printf("not supported\n" );
  } else {
      printf( "%ld\n", val );
  }
  
  return;
}

void print_pathconf_val( int pc_value, char * pc_name )
{
  long val;
  
  errno = 0;
  val = pathconf( "/", pc_value );
  
  printf("%56-s", pc_name );
  if ((val == -1) && (errno)) {
      printf("not conformed\n" );
  } else if ((val == -1) && (!errno)) {
      printf("not supported\n" );
  } else {
      printf( "%ld\n", val );
  }
  
  return;
}

int main( void )
{
  int   i;

#if _POSIX_12_SYSCONF  
  /* POSIX.1, POSIX.2 */
  printf( "--- POSIX.1,POSIX.2 configuration info ---\n" );  
  for( i=0; i<SC_MAX_NUM; i++ ) {
     if ((sc_var_array[i].sc_name!= NULL) && (sc_var_array[i].sc_value)) {
          print_sysconf_val( sc_var_array[i].sc_value, 
                             sc_var_array[i].sc_name );
     }
  }  
  printf( "\n" );
#endif

#if _POSIX_4_SYSCONF
  /* POSIX.4 */
  printf( "--- POSIX.4 configuration info ---\n" );  
  for( i=0; i<SC_RT_MAX_NUM; i++ ) {
     if ((sc_rt_var_array[i].sc_name!= NULL) && (sc_rt_var_array[i].sc_value)) {
          print_sysconf_val( sc_rt_var_array[i].sc_value, 
                             sc_rt_var_array[i].sc_name );
     }
  }  
  printf( "\n" );
#endif

#if _LIBC_PATHCONF
  /* libc */
  printf( "--- LIBC configuration info ---\n" );
  for( i=0; i<SC_PC_MAX_NUM; i++ ) {
     if ((sc_pc_var_array[i].sc_name!= NULL) && (sc_pc_var_array[i].sc_value)) {
          print_pathconf_val( sc_pc_var_array[i].sc_value, 
                              sc_pc_var_array[i].sc_name );
     }
  }  
#endif
  
  return 0;
}
