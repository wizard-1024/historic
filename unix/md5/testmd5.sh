#!/bin/sh
#
# Test MD5 sums
#
# Searches catalog for CHECKSUM.MD5 file,
# extract filenames, computes MD5 sums, 
# stores in temporary file,
# and compares with original file.
# 
# Copyright (c) 2000 Dmitry Stefankov
#

# work variables
rootdir=$1
md5file=CHECKSUM.MD5
workfile=$rootdir/$md5file
tmpfile=/tmp/$$$md5tmp

# test argument
if [ "x$rootdir" = "x" ];
  then
     echo "Usage: $0 dir"
     exit 1
fi 

# test catalog
if [ ! -d $rootdir ];
  then
     echo "ERROR: $rootdir is not directory"
     exit 2
fi

# test MD5 checksum file
if [ ! -e $workfile ];
  then
     echo "ERROR: cannot find $workfile"
     exit 3
fi

# again test MD5 checksum file
if [ -z $workfile ];
  then
     echo "ERROR: $workfile has zero length"
     exit 4
fi

# build new MD5 checksum file for files listed in old checksum file
cd $rootdir
cat $workfile | awk  '{ print $2 }' | tr -d "()" | xargs md5 >$tmpfile
#cat $workfile | awk -v mydir=$rootdir '{ print mydir,"/",$2 }' \
#    | tr -d " ()" | xargs md5 >$tmpfile
cd

testres=`diff $workfile $tmpfile`
#echo $testres

rm $tmpfile >/dev/null

if [ $testres ];
  then
    echo "FAILED! $workfile"  
    exit 5
  else 
    echo "OK! $workfile"
fi
