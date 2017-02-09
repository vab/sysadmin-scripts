#!/bin/bash

# This script to used to create a bson dump of all dbs on a MonogoDB 
# installation. 

# Author:	V. Alex Brennen <vab@mit.edu>
# Copyright:	None
# License:	Public Domain
# Version:	1.0.0
# Created:	2017.02.08
# Last Updated:	2017.02.08
# Dependencies:	Mongodump (MongoDB)


# Programs that will be used
MONGODUMP=/usr/bin/mongodump

# File locations
BACKDIR=/mnt/backups/database_exports/mongo

# Other settings
SHUSER=mongoback
CLVL="-9"

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

