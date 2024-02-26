#!/bin/bash

# Shell script to backup Postges databases
#
# This script will create a list of all databases that exist on a
# Postgres database server and dump the databases one by one each
# to its own sql file.

# Author:       V. Alex Brennen <vab@cryptnet.net>
# Copyright:    None
# License:      Public domain
# Created:      2006.10.20


# Locations of the programs we'll be using.
# Postgres
PG_DUMP="/usr/bin/pg_dump"
PSQL="/usr/bin/psql"
# General
BZIP2="/usr/bin/bzip2"
CHOWN="/usr/bin/chown"
CHMOD="/usr/bin/chmod"
DATE="/usr/bin/date"
EGREP="/usr/bin/egrep"
HEAD="/usr/bin/head"
NICE="/bin/nice"
MKDIR="/usr/bin/mkdir"
TAIL="/usr/bin/tail"

# The argument to specify a compression level to Bzip2 if required.
CLVL="-9"

# Use nice.
BE_NICE=1

# Nice level.
NLVL=19

# Set database sever address.
DBSRVR="127.0.0.1"

# Set username
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
#export PGPASSWORD=""

# Pipe delimited list of databases to exclude from backups.
# Note: If you're using AWS RDS you'll likely want to add the database
#       "rdsadmin" to the exclude list.
EXCLUDE="template0|template1|postgres"

# Directory to store the backups in.
BACKDIR="/var/backups/postgres"

# Backup directory permissions and ownership.
BACKDIR_PERMS=755
BACKDIR_GROUP="postgres"
BACKDIR_USER="postgres"

# Backup permissions.
BACKUP_PERMS=640

# Should the probem exit on an error dumping a database or continue to
# attempt to dump any other databases? This is a binary flag.
CONTINUE_DUMP_ERROR=1

# Get the date information that we'll use for the backup directories and
# to construct the backup file names.
YEAR="$($DATE +"%Y")"
MONTH="$($DATE +"%m")"
DAY="$($DATE +"%d")"

# Make Sure the back-up directory for the current year exists and is
# writable by the back-up script.
BACKDIR="$BACKDIR/$YEAR"

if [ ! -d "$BACKDIR" ]; then
  $MKDIR $BACKDIR
  if [ $? -ne 0 ]; then
    echo "Failed to create to backup directory: $BACKDIR." >&2
    exit 1
  fi
fi

if [ ! -w "$BACKDIR" ]; then
  $CHOWN $BACKDIR_USER:$BACKDIR_GROUP $BACKDIR
  if [ $? -ne 0 ]; then
    echo "Failed to change ownership on backup directory: $BACKDIR." >&2
    exit 1
  fi
  $CHMOD $BACKDIR_PERMS $BACKDIR
  if [ $? -ne 0 ]; then
    echo "Failed to change permissions on backup directory: $BACKDIR." >&2
    exit 1
  fi
fi

# Make sure the back-up directory for the current month exists and is
# writable by the back-up script.
BACKDIR="$BACKDIR/$MONTH"

if [ ! -d "$BACKDIR" ]; then
  $MKDIR $BACKDIR
  if [ $? -ne 0 ]; then
    echo "Failed to create to backup directory: $BACKDIR." >&2
    exit 1
  fi
fi

if [ ! -w "$BACKDIR" ]; then
  $CHOWN $BACKDIR_USER:$BACKDIR_GROUP $BACKDIR
  if [ $? -ne 0 ]; then
    echo "Failed to change ownership on backup directory: $BACKDIR." >&2
    exit 1
  fi
  $CHMOD $BACKDIR_PERMS $BACKDIR
  if [ $? -ne 0 ]; then
    echo "Failed to change permissions on backup directory: $BACKDIR." >&2
    exit 1
  fi
fi

# Construct the date to be used in the backup filename.
DATE="$YEAR$MONTH$DAY"

# Go to the backup directory.
cd $BACKDIR
if [ $? -ne 0 ]; then
  echo "Failed change to backup directory: $BACKDIR." >&2
  exit 1
fi

# Get a list of all the dbs that are not included in the EXCLUDE variable.
DBS="$($PSQL -h $DBSRVR -U $USER --no-password -c "SELECT datname FROM pg_database;" postgres | $TAIL -n +3 | $HEAD -n -2 | $EGREP -v $EXCLUDE)"
if [ $? -ne 0 ]; then
  echo "Failed to get a list of databases." >&2
  exit 1
fi

# Iterate through the database list.
for DB in $DBS
do
  # Set the filename.
  FILE="$DB.$DBSRVR.$DATE.sql"
  BACKUP_FILE="$DB.$DBSRVR.$DATE.sql.bz2"

  # Dump the data.
  $PG_DUMP -h $DBSRVR -U $USER --no-password --create --oids -U $USER -f $FILE $DB
  if [ $? -ne 0 ]; then
    echo "Failed to dump $DB." >&2
    if [ $CONTINUE_DUMP_ERROR -eq 0 ]; then
      exit 1
    fi
  fi

  # Compress the dump file.
  if [ $BE_NICE -eq 1 ]; then
    $NICE -$NLVL $BZIP2 $CLVL $FILE
    if [ $? -ne 0 ]; then
      echo "Failed to compress $DB." >&2
      if [ $CONTINUE_DUMP_ERROR -eq 0 ]; then
        exit 1
      fi
    fi
  else
    $BZIP2 $CLVL $FILE
    if [ $? -ne 0 ]; then
      echo "Failed to compress $DB." >&2
      if [ $CONTINUE_DUMP_ERROR -eq 0 ]; then
        exit 1
      fi
    fi
  fi

  # Set the file permissions on the backup file.
  $CHMOD $BACKUP_PERMS $BACKUP_FILE
  if [ $? -ne 0 ]; then
    echo "Failed to change permissions on the backup file: $BACKFILE." >&2
    if [ $CONTINUE_DUMP_ERROR -eq 0 ]; then
      exit 1
    fi
  fi
done
