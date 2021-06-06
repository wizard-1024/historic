#!/bin/sh

#
# Make stress loading on VM
#
# Copyright (c) 2002 Dmitry Stefankov
#

if [ $# -lt 3 ]; then
  echo "Usage: $0 MB-alloc MB-inactive MB-adjust"
  exit 1
fi

# Programs
AWK=/usr/bin/awk
EXPR=/bin/expr
SYSCTL=/sbin/sysctl
ECHO=/bin/echo
FREEMEM=/usr/local/sbin/freemem
LOGGER=/usr/bin/logger

# Variables
mb_run_size=$1
mb_inactive_mem=$2
adjust_mb_size=$3
debug_out=0
syslog_notice=1
run_stress_mem=0
run_stress_wait="5 15"

# Get counters
if [ $syslog_notice -eq 1 ]; then
  $LOGGER -t FREEMEM -i "freemem started"
  $LOGGER -t FREEMEM -i "run_size: $mb_run_size"
  $LOGGER -t FREEMEM -i "inactv_size: $mb_inactive_mem"
  $LOGGER -t FREEMEM -i "adj_size: $adjust_mb_size"
fi
free_pages=`$SYSCTL vm.stats.vm.v_free_count|$AWK '{print $2}'`
active_pages=`$SYSCTL vm.stats.vm.v_active_count|$AWK '{print $2}'`
inactive_pages=`$SYSCTL vm.stats.vm.v_inactive_count|$AWK '{print $2}'`

free_mem=`$EXPR $free_pages \* 4096`
free_mem=`$EXPR $free_mem / 1048576`
active_mem=`$EXPR $active_pages \* 4096`
active_mem=`$EXPR $active_mem / 1048576`
inactive_mem=`$EXPR $inactive_pages \* 4096`
inactive_mem=`$EXPR $inactive_mem / 1048576`

if [ $debug_out -ne 0 ]; then
  $ECHO "free: $free_pages pages, $free_mem MB"
  $ECHO "active: $active_pages pages, $active_mem MB"
  $ECHO "inactive: $inactive_pages pages, $inactive_mem MB"
fi
if [ $syslog_notice -eq 1 ]; then
  $LOGGER -t FREEMEM -i "free: $free_pages pages, $free_mem MB"
  $LOGGER -t FREEMEM -i "active: $active_pages pages, $active_mem MB"
  $LOGGER -t FREEMEM -i "inactive: $inactive_pages pages, $inactive_mem MB"
fi

# Condition 1
if [ $inactive_mem -gt $mb_inactive_mem ]; then
  run_mb_size=`$EXPR $inactive_mem + $free_mem`
  if [ $run_mb_size -gt $adjust_mb_size ]; then
    run_mb_size=`$EXPR $run_mb_size - $adjust_mb_size`
    run_stress_mem=1
  fi
  if [ $debug_out -ne 0 ]; then 
    $ECHO "Run_size: $run_mb_size"
  fi
  if [ $syslog_notice -eq 1 ]; then
    $LOGGER -t FREEMEM -i "Run_size: $run_mb_size"
  fi
fi

# Run stress memory
if [ $run_stress_mem -eq 1 ]; then

  run_mb_count=`$EXPR $run_mb_size / $mb_run_size`
  run_mb_rem=`$EXPR $run_mb_size % $mb_run_size`

  if [ $debug_out -ne 0 ]; then
    $ECHO "divisor=$run_mb_count, remainder=$run_mb_rem"
  fi
  if [ $syslog_notice -eq 1 ]; then
    $LOGGER -t FREEMEM -i "divisor=$run_mb_count, remainder=$run_mb_rem"
  fi

  while [ $run_mb_count -ne 0 ]; 
  do
     if [ $debug_out -ne 0 ]; then
          $ECHO "Loop: $run_mb_count"  
     fi
     if [ $syslog_notice -eq 1 ]; then
       $LOGGER -t FREEMEM -i "Loop: $run_mb_count"  
     fi
     if [ -x $FREEMEM ]; then
       $FREEMEM $mb_run_size $run_stress_wait &
     fi
     run_mb_count=`$EXPR $run_mb_count - 1`
  done

  if [ $run_mb_rem -ne 0 ]; then
    if [ $debug_out -ne 0 ]; then
          $ECHO "Remainder."  
    fi
     if [ $syslog_notice -eq 1 ]; then
       $LOGGER -t FREEMEM -i "Remainder."  
     fi
     if [ -x $FREEMEM ]; then
       $FREEMEM $run_mb_rem $run_stress_wait &
     fi
  fi

fi

if [ $syslog_notice -eq 1 ]; then
  $LOGGER -t FREEMEM -i "freemem finished"
fi
