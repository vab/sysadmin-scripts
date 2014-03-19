#!/bin/bash

# Monthly Log File Removal Script
# Author: V. Alex Brennen <vab@mit.edu>
# License: This script is public domain
# Date: 2014-03-18

# Description: This script will take a directory as an argument.
# It will then remove all log files more than two months old (with
# an ISO standard date (YYYY-MM-DD) as part of their name) from the
# directory. This script was meant to be called by cron monthly. Here
# is an example crontab entry that runs the script on the first day 
# of the month:
# 0 0 1 * * /usr/local/scripts/log_clean.sh /var/log/svc_logs 2>&1 >> /dev/null

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
# files to remove
YEAR="$(/bin/date +"%Y")"
MONTH="$(/bin/date +"%m")"

# To remove log files from two months ago we subtract two from 
# the current month. If the month is January or February, we 
# set it and roll the year back.
if [ $MONTH -lt 3 ]; then
	if [ $MONTH -eq 2 ]; then
		MONTH = 12;
	else
		MONTH = 11;
	fi
	YEAR =$(( $YEAR-- ))
else
	MONTH=$(( $MONTH-2 ))
fi

# This code add a leading zero to the month to comply with ISO
# date format standard.
if [ $MONTH -lt 10 ]; then
	MONTH="0$MONTH";
fi

# Remove the old log files
/bin/rm $1/*$YEAR-$MONTH*

