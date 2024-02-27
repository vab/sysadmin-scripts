#!/bin/bash

# Monthly Log File Compression Script

# Author:		V. Alex Brennen <vab@cryptnet.net>
# Copyright:	None
# License:		Public Domain
# Date:			2014-03-20
# Dependencies:	bzip2

# Description:	This script will take a directory as an argument. It will then
#				compress all log files from the previous month (with an ISO
#				standard date (YYYY-MM-DD) as part of their name) from the
#				directory. This script was meant to be called by cron monthly.
#				Here is an example crontab entry that runs the script on the
#				first day of the month:
# 0 0 1 * * /usr/local/scripts/log_compress.sh /var/log/svc 2>&1 >> /dev/null


# The location of bzip2 (or other compression program)
BZIP2=/usr/bin/bzip2

# The location of nice
NICE=/bin/nice

# The argument to specify a compression level if required
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

# Get the date information that we'll use to determine which log
# files to compress
YEAR="$(/bin/date +"%Y")"
MONTH="$(/bin/date +"%m")"

# To compress log files from one month ago we subtract one from 
# the current month. If the month is January, we set it to 
# December and roll the year back.
if [ $MONTH -eq 1 ]; then
	MONTH = 12;
	YEAR =$(( $YEAR-- ))
else
	MONTH=$(( $MONTH-1 ))
fi

# This code adds a leading zero to the month to comply with ISO
# date format standard.
if [ $MONTH -lt 10 ]; then
	MONTH="0$MONTH";
fi

# Compress the old log files
if [ $BE_NICE -eq 1 ]; then
	$NICE -$NLVL $BZIP2 $CLVL $1/*$YEAR-$MONTH*
else
	$BZIP2 $CLVL $1/*$YEAR-$MONTH*
fi
