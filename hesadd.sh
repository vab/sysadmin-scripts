#!/bin/bash

# User Account Creation From Hesiod Data Script

# Author:       V. Alex Brennen <vab@cryptnet.net>
# Copyright:	None
# License:		Public Domain
# Date:         2014-03-24
# Dependencies: hesinfo; Hesiod database service available/populated

# Description: This script will take a list of user accounts to create
# as arguments. It will then iterate through the list calling hesinfo
# to get passwd file information. It then uses that information as 
# arguments for a call to the useradd program. This script has a flag 
# that specifies whether an AFS cluster home area should be used for 
# the account of if the higher speed local disks should be used. The 
# flag is set by editing the code on each server that the script is 
# installed on.


# The location of the hesinfo command.
HESINFO=/usr/bin/hesinfo

# The location of the useradd command.
USERADD=/usr/sbin/useradd

# Should the script use the users AFS cluster home directory or create
# one on the local machine?
AFS_HOME=0

# Flag for the occurrence of any errors while creating accounts
ERRORS=0

# Does the user have the Hesiod software installed?
if [ ! -f $HESINFO ]
then
    echo "Error: You must have the Hesiod package installed to use this "
    echo "       program."
    exit 1
fi

# Check for the correct number of arguments
if [ $# -lt 1 ]
then
    echo "You must provide the script with at least one username."
    echo "Usage: $0 username username"
    exit 1
fi

# Finally, we add the users
echo "Adding users..."

# Iterate through the array of userids (command line arguments) given to 
# the script
for user in "$@"
do
    DATA=$($HESINFO "$user" passwd)
    uid=$(echo "$DATA"|awk 'BEGIN{FS=":"}{print $3}')
    gid=$(echo "$DATA"|awk 'BEGIN{FS=":"}{print $4}')
    gecos=$(echo "$DATA"|awk 'BEGIN{FS=":"}{print $5}')
    home=$(echo "$DATA"|awk 'BEGIN{FS=":"}{print $6}')
    shell=$(echo "$DATA"|awk 'BEGIN{FS=":"}{print $7}')
    if [ $AFS_HOME -eq 0 ]
    then
        eval "$("$USERADD -d /home/$user -m -c \"$gecos\" -s $shell -u $uid -g $gid $user")"
    else
        eval "$("$USERADD -d $home -m -c \"$gecos\" -s $shell -u $uid -g $gid $user")"
    fi
    if [ $? -eq 0 ]
    then
        echo "    $user added."
    else
        ERRORS=1
    fi
done

# If there were any errors, exit with an error state
if [ $ERRORS -eq 1 ]
then
    exit 1
fi

exit 0
