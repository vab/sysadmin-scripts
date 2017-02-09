#!/bin/bash

# This script is used to download a database export backup from a remote 
# machine with sftp. An SSH keypair is used for authentication. The script
# will copy a file with a date based naming convention. It will report success
# or failure, determined by a basic file existence check, via e-mail. This 
# script was designed to be called daily or weekly from cron.

# Author:	V. Alex Brennen <vab@mit.edu>
# Copyright:	None
# License:	Public Domain
# Version:	1.0.1
# Created:	2016.12.03
# Last Updated:	2017.02.09
# Dependencies:	Expect and SFTP


# Programs that will be used
SFTP=/usr/bin/sftp
EXPECT=/usr/bin/expect

# Settings specific to this task
HOST=192.168.1.100
PORT=22
USERNAME=remotebu
DIR=/home/remotebu
ID_FILE=/home/localbu/.ssh/id_backup

# Settings specific to notificatios
MAIL=/bin/mail
NOTIFY=notify@example.edu
FAILNOTIFY=failnotify@example.edu

# Get the date information that we'll use for the backup file name
YEAR="$(date +"%Y")"
MONTH="$(date +"%m")"
DAY="$(date +"%d")"

BACKUP_NAME="dbexport_$YEAR-$MONTH-$DAY.sql.gz"
BACKUP_DIR="/mnt/backups/remote"
BACKUP="$BACKUP_DIR/$BACKUP_NAME"

cd $BACKUP_DIR

$EXPECT<<EOD
spawn $SFTP -oIdentityFile=$ID_FILE -oPort=$PORT $USERNAME@$HOST:$DIR
expect "sftp>"
send "get $BACKUP_NAME\r"
expect "sftp>"
send "bye\r"
EOD

if [ ! -f $BACKUP ]; then
	echo "Failed to transfer backup $BACKUP_NAME." |$MAIL -s "Backup Transfer Failed" $FAILNOTIFY
	exit -1
fi

echo "Successfully transferred backup $BACKUP_NAME." |$MAIL -s "Backup Transfer Complete" $NOTIFY

