#!/bin/sh
# 
# Searches recursively catalog
# for MD5 sums testing
#
# Copyright (c) 2000 Dmitry Stefankov
#

startdir=$1
rundir=$PWD
testprg=$rundir/testmd5.sh

# test argument
if [ "x$startdir" = "x" ];
  then
     echo "Usage: $0 dir"
     exit 1
fi

# test catalog
if [ ! -d $startdir ];
  then
     echo "ERROR: $startdir is not directory."
     exit 2
fi

# Recursive testing
#echo $testprg

find $startdir -type d -exec $testprg {} \;
