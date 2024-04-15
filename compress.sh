#!/bin/bash

# Recursive File Compression Script

# Author:		V. Alex Brennen <vab@cryptnet.net>
# Copyright:	None
# License:		Public Domain
# Date:			2014-03-17
# Dependencies:	bzip2

# Description: This script will take a directory as an argument.
# It will then transverse the directory, and all sub directories,
# and compress the regular files in those directories with bzip2.
# The script just ignores any files that are not either a regular
# file or a directory (symbolic links, devices, etc).

BZIP2=/bin/bzip2
NICE=/bin/nice

# Compression level
CLVL="-9"

# Use nice
BE_NICE=1

# Nice level
NLVL=19

# Test for a server list file argument
if [ -z "$1" ]; then
echo "Usage: $0 <directory>";
exit
fi

# Make sure the directory is valid and readable
if [ ! -d "$1" ]; then
echo "Error: Argument does not appear to be a directory: $1."
exit
fi

# This is the function that does the actual compression and 
# directory transversal.
function compress_files
{
	for i in ls *
	do
		if [ -f "$i" ]; then
		    if [ $BE_NICE -eq 1 ]; then
                $NICE -$NLVL $BZIP2 $CLVL "$i"
		    else
                $BZIP2 $CLVL "$i"
			fi
		elif [ -d "$i" ]; then
			cd "$i" || continue
			compress_files
			cd ..
		fi
	done
}

# To start the script, we change the current working directory
# to the directory to compress then kick off the initial call 
# to the recursive compress_files function.
cd "$1" || exit 1
compress_files
