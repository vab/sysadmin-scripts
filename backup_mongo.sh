#!/bin/bash

# This script to used to create a bson dump of all dbs on a MonogoDB 
# installation. 

# Author:	V. Alex Brennen <vab@mit.edu>
# Copyright:	None
# License:	Public Domain
# Version:	1.0.1
# Created:	2017.02.08
# Last Updated:	2017.02.10
# Dependencies:	Mongodump (MongoDB) and bzip2 (for optional compression)


# Programs that will be used
MONGODUMP=/usr/bin/mongodump
BZIP2=/usr/bin/bzip2
NICE=/bin/nice

# File locations
BACKDIR=/mnt/backups/database_exports/mongo

# Other settings
## Shell User
SHUSER=mongoback
## Compression level
CLVL="-9"
## Use nice
BE_NICE=1
## Nice level 
NLVL=19

# Get the date information that we'll use for the backup directories and 
# to construct the backup file names
YEAR="$(date +"%Y")"
MONTH="$(date +"%m")"
DAY="$(date +"%d")"

# Make Sure the back-up directory for the current year exists and is 
# writable by the back-up script.
BACKDIR="$BACKDIR/$YEAR"

if [ ! -d "$BACKDIR" ]; then
        /bin/mkdir $BACKDIR
fi

if [ ! -w "$BACKDIR" ]; then
        /bin/chown $SHUSER:$SHUSER $BACKDIR
        /bin/chmod 775 $BACKDIR
fi

# Make sure the back-up directory for the current month exists and is
# writable by the back-up script.
BACKDIR="$BACKDIR/$MONTH"

if [ ! -d "$BACKDIR" ]; then
        /bin/mkdir $BACKDIR
fi

if [ ! -w "$BACKDIR" ]; then
        /bin/chown $SHUSER:$SHUSER $BACKDIR
        /bin/chmod 775 $BACKDIR
fi

# Dump The databases and un/pw metadata
## note need date code here
$MONGODUMP --out $BACKDIR/mongodump-$YEAR-$MONTH-$DAY

# This is the function that does the actual compression and 
# directory transversal.
function compress_files
{
	for i in $( ls );
	do
		if [ -f $i ]; then
		    if [ $BE_NICE -eq 1 ]; then
		    	$NICE -$NLVL $BZIP2 $CLVL $i
		    else
			    $BZIP2 $CLVL $i
			fi
		elif [ -d $i ]; then
			cd $i
			compress_files
			cd ..
		fi
	done
}

# Compress the bson export files
cd $BACKDIR/mongodump-$YEAR-$MONTH-$DAY
compress_files

