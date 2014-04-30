#!/bin/bash

# Shell script to backup MySQL databases
# 
# This script will create a list of all databases that exist on a 
# MySQL database server and dump the databases one by one each to 
# its own compressed, named, and dated, SQL file.

# Author:        V. Alex Brennen <vab@MIT.EDU>
# Copyright:	 None
# License:       Public Domain
# Date:          2006.10.20


# Locations of Programs we'll be using
MYSQL="/usr/bin/mysql"
MYSQLDUMP="/usr/bin/mysqldump"
BZIP2="/usr/bin/bzip2"
NICE="/bin/nice"

# The argument to specify a compression level if required
CLVL="-9"

# Use nice
BE_NICE=1

# Nice level
NLVL=19

# Directory to store the backups in
BACKDIR="/home/backup/mysql"

# Set Database Sever Address
DB_SRVR="127.0.0.1"
DB_SRVR_NAME="$(hostname)"

# Set Username
USER="root"

# Set Password
PASS=""

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
        /bin/chown mysql:mysql $BACKDIR
        /bin/chmod 755 $BACKDIR
fi


# Make sure the back-up directory for the current month exists and is
# writable by the back-up script.
BACKDIR="$BACKDIR/$MONTH"

if [ ! -d "$BACKDIR" ]; then
        /bin/mkdir $BACKDIR
fi

if [ ! -w "$BACKDIR" ]; then
        /bin/chown mysql:mysql $BACKDIR
        /bin/chmod 755 $BACKDIR
fi

# Go to the back up directory
cd $BACKDIR

# Construct the date information to be used in the backup filename.
DATE="$YEAR$MONTH$DAY"

# Get a list of all the dbs
DBS="$($MYSQL -h $DB_SRVR --user=$USER  --password=$PASS --silent --batch --execute='show databases')"

# Iterate through the database list
for db in $DBS
do
	# Set the filename
	FILE="$db.$DB_SRVR_NAME.$DATE.sql"

	# Dump the data
	$MYSQLDUMP --opt -h $DB_SRVR --user=$USER --password=$PASS $db > $FILE
	
	# Compress the dump file
	if [ $BE_NICE -eq 1 ]; then
		$NICE -$NLVL $BZIP2 $CLVL $FILE
	else
		$BZIP2 $CLVL $FILE
	fi
done

