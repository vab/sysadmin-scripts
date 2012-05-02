#!/bin/bash

# Server Password Generation Script
# Author: V. Alex Brennen <vab@mit.edu>
# License: This script is public domain
# Date: 2008-02-26

# Description: This script will use the passgen password candidate generator
#              to generate a text file containing password candidates for 
#              a list of servers passed to it. The servers should be in a 
#              new line seperated text file.

PASSGEN=/usr/bin/passgen
PASSGEN_ARG="-C -n 1 -u"
# Passgen program arguments (See passgen man page for more information)
#	-a		Alpha numeric characters only.
#	-A		Alphabetic characters only.
#	-C		Suppress config file not found messages.
#	-H		Homoglyph suppression level (0-2).
#	-l		The length of the password.
#	-L		For any letters, use lowercase only.
#	-n		Number of passwords to provide.
#	-N		Numeric characters only.
#	-r		Use /dev/random for password generation.
#	-s		Exclude the space character.
#	-u		Use /dev/urandom rather than /dev/random.
#			(Will speed password generation)
#	-U		For any letters, user uppercase only.


# Function to generate and print a password candidate
function genpass
{
	CANDIDATE=`$PASSGEN $PASSGEN_ARG`
	echo "	root:	$CANDIDATE"
}

if [ -z "$1" ]; then
	echo "Usage: $0 <server_list.txt>"
	exit
fi

if [ ! -r "$1" ]; then
	echo "Error: Could not open and read server list file: $1."
	exit
fi

for SERVER in $(cat $1);
do
	echo $SERVER
	genpass
done

exit

