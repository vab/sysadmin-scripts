#!/bin/bash

# Shell script to import a Postgres SQL export.

# This script will reload a postgres database from an sql dump file.

# Author:       V. Alex Brennen <vab@cryptnet.net>
# Copyright:    None
# License:      Public domain
# Created:      2024.02.25

# Locations of the programs we'll be using.
# Postgres
PSQL="/usr/bin/psql"
# General
BZIP2="/usr/bin/bzip2"
CHOWN="/usr/bin/chown"
CHMOD="/usr/bin/chmod"
NICE="/bin/nice"

# The argument to specify a compression level to Bzip2 if required.
CLVL="-9"

# Use nice.
BE_NICE=1

# Nice level.
NLVL=19

# Backup permissions.
BACKUP_PERMS=640

# Set database sever address.
DBSRVR="127.0.0.1"

# Name of the DSpace database.
DB="dbname"

# Set the login username.
# Note: This script needs to connect as postgres (a superuser) rather than
# dspace because if it connects as dspace it will only be able to connect to 
# the dspace database. It will then not be able to drop the dspace database 
# due to the active connection. It will also fail to run all permissions 
# related commands in the SQL export file of the old database.
USER="postgres"

# Set password.
# Note:  This variable is exported so that Postgres can pull it from the
#        environment. Leave this variable commented out (unset) if you
#        set the PGPASSWORD environment variable somewhere else on your
#        system.
#
#        To make this script more secure, you can leave this variable unset
#        and use a credentials file located at ~/.pgpass with the format
#        "hostname:port:database:username:password". For additional
#        information see:
#        https://www.postgresql.org/docs/current/libpq-pgpass.html
#
#        This script passes Postgres programs the "--no-password" argument to
#        prevent the program from prompting for a password. If the password is
#        not available the script will fail cleanly.
#
# Note:  You will need to retrieve the RDS postgresql user password from AWS
#        SecretsManager because it is generated and rotated automatically.
#export PGPASSWORD=""

# Directory that the exports are stored in.
EXPORTDIR="/mnt/exports"

# The name of the export file to restore before the database name has been
# changed.
#
# Note: This name should not include the compression suffix.
# Example: EXPORT_FILE="db.prod-dbsrvr.20240225.sql"
EXPORT_FILE=""

# The name of the compressed export file.
COMPRESSED_EXPORT_FILE="$UNPROCESSED_EXPORT_FILE.bz2"

# Go to the export directory
cd $EXPORTDIR
if [ $? -ne 0 ]; then
    echo "Failed change to export directory: $EXPORTDIR." >&2
    exit 1
fi

# Decompress the export file.
$BZIP2 -d $COMPRESSED_EXPORT_FILE
if [ $? -ne 0 ]; then
    echo "Failed to decompress $COMPRESSED_EXPORT_FILE." >&2
    exit 1
fi

# Load the database dump.
# psql
$PSQL -h $DBSRVR -U $USER -f $EXPORT_FILE
if [ $? -ne 0 ]; then
    echo "Failed to load $EXPORT_FILE." >&2
    exit 1
fi

# Recompress the dump file.
if [ $BE_NICE -eq 1 ]; then
    $NICE -$NLVL $BZIP2 $CLVL $EXPORT_FILE
    if [ $? -ne 0 ]; then
        echo "Failed to compress: $EXPORT_FILE" >&2
        exit 1
    fi
    else
    $BZIP2 $CLVL $FILE
    if [ $? -ne 0 ]; then
        echo "Failed to compress: $EXPORT_FILE" >&2
        exit 1
    fi
fi

# Set the file permissions on the backup file.
$CHMOD $BACKUP_PERMS $BACKUP_FILE
if [ $? -ne 0 ]; then
    echo "Failed to change permissions on the backup file: $BACKFILE." >&2
    exit 1
fi
