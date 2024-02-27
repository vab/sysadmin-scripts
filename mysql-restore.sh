#!/bin/bash

# Shell Script To Restore A MySQL (MariaDB) Database From Backup

# Author:       V. Alex Brennen <vab@cryptnet.net>
# Copyright:    None
# License:      Public Domain
# Date:         2024.02.25
# Dependencies: MySQL or MariaDB; bzip2

# Description:  This script will take a MySQL (MariaDB) SQL dump file and
#               reload it into a MySQL (MariaDB) server.


# Locations of Programs we'll be using
MYSQL="/usr/bin/mysql"
BZIP2="/usr/bin/bzip2"
NICE="/bin/nice"

# The argument to specify a compression level to Bzip2 if required.
CLVL="-9"

# Use nice.
BE_NICE=1

# Nice level.
NLVL=19

# Set Database Sever Address
DB_SRVR="127.0.0.1"

# Set Username
USER="root"

# Set Password
PASS=""

# The name of the database to restore into.
DB_NAME=""

# Directory to store the backups in
BACKUPDIR="/var/backup/mysql"

# The name of the uncompressed backup file to restore.
# Example: BACKUP_FILE="db.prod-dbsrvr.20240225.sql"
BACKUP_FILE=""

# The name of the compressed backup file.
COMPRESSED_BACKUP_FILE="$BACKUP_FILE.bz2"

# Go to the backup directory
cd $BACKUPDIR
if [ $? -ne 0 ]; then
    echo "Failed change to backup directory: $BACKUPDIR." >&2
    exit 1
fi

# Decompress the backup file.
$BZIP2 -d $COMPRESSED_BACKUP_FILE
if [ $? -ne 0 ]; then
    echo "Failed to decompress $COMPRESSED_BACKUP_FILE." >&2
    exit 1
fi

# Load the backup file into the database.
$MYSQL -h $DB_SRVR --user=$USER --password=$PASS $DB_NAME < $BACKUP_FILE
if [ $? -ne 0 ]; then
    echo "Failed to load $BACKUP_FILE." >&2
    exit 1
fi

# Recompress the backup file.
if [ $BE_NICE -eq 1 ]; then
    $NICE -$NLVL $BZIP2 $CLVL $BACKUP_FILE
    if [ $? -ne 0 ]; then
        echo "Failed to compress: $BACKUP_FILE" >&2
        exit 1
    fi
    else
    $BZIP2 $CLVL $BACKUP_FILE
    if [ $? -ne 0 ]; then
        echo "Failed to compress: $BACKUP_FILE" >&2
        exit 1
    fi
fi
