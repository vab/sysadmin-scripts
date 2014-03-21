#!/bin/bash

# Shell script to backup MySQL Databases
# 
# This script will create a list of all databases that exist on a 
# MySQL database server and dump the databases one by one each to 
# its own SQL file.

# Author:	V. Alex Brennen <vab@MIT.EDU>
# Copyright:	None
# License:	Public Domain
# Created:	2006.10.20
# Last Updated:	2011.03.31


# Locations of Programs we'll be using
MYSQL="/usr/bin/mysql"
MYSQLDUMP="/usr/bin/mysqldump"
BZIP2="/usr/bin/bzip2"

# The argument to specify a compression level if required
CLVL="-9"

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

# Itenerate through the database list
for db in $DBS
do
	# set the filename
	FILE="$db.$DB_SRVR_NAME.$DATE.sql"

	# dump the data
	$MYSQLDUMP --opt -h $DB_SRVR --user=$USER --password=$PASS $db > $FILE
	$BZIP2 $CLVL $FILE
done

