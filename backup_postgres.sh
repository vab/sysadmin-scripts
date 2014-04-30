#!/bin/bash

# Shell script to backup Postges databases
# 
# This script will create a list of all databases that exist on a 
# Postgres database server and dump the databases one by one each
# to its own sql file.

# Author:       V. Alex Brennen <vab@mit.edu>
# Copyright:    None
# License:      Public Domain
# Created:      2006.10.20


# Locations of Programs we'll be using
PSQL="/usr/bin/psql"
PG_DUMP="/usr/bin/pg_dump"
BZIP2="/usr/bin/bzip2"
NICE=/bin/nice

# The argument to specify a compression level if required
CLVL="-9"

# Use nice
BE_NICE=1

# Nice level
NLVL=19

# Set Database Sever Address
ADDR="127.0.0.1"

# Text hostname for inclusion in file name
HOST="$(hostname)"

# Set Username
USER="postgres"

# Set Password
#PASS=""

# Directory to store the backups in
BACKDIR="/home/backup/postgres"

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
        /bin/chown postgres:postgres $BACKDIR
        /bin/chmod 755 $BACKDIR
fi

# Make sure the back-up directory for the current month exists and is
# writable by the back-up script.
BACKDIR="$BACKDIR/$MONTH"

if [ ! -d "$BACKDIR" ]; then
        /bin/mkdir $BACKDIR
fi

if [ ! -w "$BACKDIR" ]; then
        /bin/chown postgres:postgres $BACKDIR
        /bin/chmod 755 $BACKDIR
fi

# Construct the date to be used in the backup filename.
DATE="$YEAR$MONTH$DAY"

# Go to the back up directory
cd $BACKDIR

# Get a list of all the dbs
DBS="$($PSQL -U $USER -l -t | awk '{ print $1}' )"

# Iterate through the database list
for db in $DBS
do
	if [ "$db" != "template0" ] && [ "$db" != "template1" ]; then
		# set the filename
		FILE="$db.$HOST.$DATE.sql"

		# dump the data
		$PG_DUMP --create --oids -U $USER -f $FILE $db
		if [ $BE_NICE -eq 1 ]; then
			$NICE -$NLVL $BZIP2 $CLVL $FILE
		else
			$BZIP2 $CLVL $FILE
		fi
	fi
done

