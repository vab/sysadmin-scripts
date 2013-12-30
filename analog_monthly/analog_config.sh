#!/bin/bash

# Shell script to create an analog config file and stats directories
# 
# This script will create a configuration file from a template with 
# the current date (year and month) for a stats run. It will also
# create the directories where the output will be stored. A cron job
# running the actual analog log file processing should be launched
# after this script has been run. Currently, that script is run nightly.
# But, it could be run only monthly depending on the size of the web 
# server logs. We currently use cronolog to rotate the webserver logs.

# Author:       V. Alex Brennen <vab@MIT.EDU>
# Copyright:    None
# License:      Public Domain
# Version:      1.0.0
# Created:      2006.11.17
# Last Updated: 2006.11.17


# Directory to store the statistics in
STATSDIR="/var/www/localhost/htdocs/stats"

# Get the date information that we'll use to create the configuration file
YEAR="$(/bin/date +"%Y")"
MONTH="$(/bin/date +"%m")"

# Make sure the directory that we plan to put the stats for the current year
# exists
STATSDIR="$STATSDIR/$YEAR"

if [ ! -d "$STATSDIR" ]; then
        /bin/mkdir $STATSDIR
fi

# Make sure the directory that we plan to put the stats for the current month
# exists
BACKDIR="$STATSDIR/$MONTH"

if [ ! -d "$STATSDIR" ]; then
        /bin/mkdir $STATSDIR
fi

# Use sed and the date information to create the configuration file from the
# template file
/bin/cat /etc/analog/analog.cfg.template | /bin/sed -e "s/YYYY/$YEAR/" | /bin/sed -e "s/MM/$MONTH/" > /etc/analog/analog.cfg

