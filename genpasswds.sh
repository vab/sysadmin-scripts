#!/bin/bash

# Server Pseudo-random Password Generation Script

# Author:		V. Alex Brennen <vab@cryptnet.net>
# Copyright:	None
# License:		Public Domain
# Date:			2012-02-26
# Dependencies:	passgen (https://github.com/vab/passgen)

# Description:	This script will use the passgen password candidate generator
#				to generate password candidates for a list of servers passed
#				to it. The list server should be in a new line separated text
#				file.


PASSGEN=/usr/bin/passgen
PASSGEN_ARGS="-C -n 1 -u"
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
	CANDIDATE=$($PASSGEN "$PASSGEN_ARGS")
	echo "	root:	$CANDIDATE"
}

# Test for a server list file argument
if [ -z "$1" ]; then
	echo "Usage: $0 <server_list.txt>"
	exit
fi

# Make sure the server list file is valid and readable
if [ ! -r "$1" ]; then
	echo "Error: Could not open and read server list file: $1."
	exit
fi

# Step through the list of servers, generating a new password for each one
for SERVER in $(cat "$1");
do
	echo "$SERVER"
	genpass
done

exit
