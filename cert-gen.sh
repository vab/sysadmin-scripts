#!/bin/bash

# TLS Certificate and Key Generation Script

# Author:		V. Alex Brennen <vab@cryptnet.net>
# Copyright:	None
# License:		Public Domain
# Created:		2017-02-11
# Dependencies:	OpenSSL

# Description:	This script will take a FQDN as an argument and generate an
#				RSA key and x509 certificate for it using OpenSSL.

# Check for the correct number of arguments
if [ $# -lt 1 ]
then
    echo "You must provide the script with at least one FQDN."
    echo "Usage: $0 exampledomain1.ex exampledomain2.ex"
    exit 1
fi

# Programs that will be used
OPENSSL=/usr/bin/openssl

# Size of Key to Generate
# Note:	If you plan to use this certificate and key with AWS, you may need to
#		change this 2048.
KEYSIZE=4096

# Nubmer of Days Self-Signed Cert Should Be Valid
VALID_DAYS=365

# Self-Sign the CSR?
SELFSIGN=1

# Error Flag
ERRORS=0

# Start Generating the Certificates
echo "Generating encryption keys, CSRs, and certificates..."

for domainname in "$@"
do
	# File Names
	KEYFILE="$domainname.key"
	CSRFILE="$domainname.csr"
	CERTFILE="$domainname.crt"

	# Generate the Key
	eval "$("$OPENSSL genrsa -out $KEYFILE $KEYSIZE")"

	# Generate the CSR
	eval "$("$OPENSSL req -new -sha256 -nodes -key $KEYFILE -out $CSRFILE")"

	if [ $SELFSIGN -eq 1 ]
	then
		# Self-sign the CSR
		eval "$("$OPENSSL x509 -in $CSRFILE -out $CERTFILE -req -signkey $KEYFILE -days $VALID_DAYS")"
	fi

	if [ $? -eq 0 ]
	then
		echo "Generation for $domainname complete."
	else
		echo "Error occurred while generating for $domainname."
		ERRORS=1
	fi
done

# If there were any errors, exit with an error state
if [ $ERRORS -eq 1 ]
then
    echo "Note: Errors were encountered during generation."
    exit 1
fi

echo "Complete."
exit 0
