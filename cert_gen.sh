#!/bin/bash

# This script will take a FQDN as an argument and generate an RSA key and
# x509 certificate for it using OpenSSL.

# Author:		V. Alex Brennen <vab@mit.edu>
# Copyright:	None
# License:		Public Domain
# Version:		1.0.0
# Created:		2017-02-11
# Last Updated:	2017-02-11
# Dependencies:	OpenSSL

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
	KEYFILE=$domainname.key
	CSRFILE=$domainname.csr
	CERTFILE=$domainname.crt

	# Generate the Key
	$($OPENSSL genrsa -out $KEYFILE  $KEYSIZE)

	# Generate the CSR
	$($OPENSSL req -new -sha256 -nodes -key $KEYFILE -out $CSRFILE)

	if [ $SELFSIGN -eq 1 ]
	then
		# Self-sign the CSR
		$($OPENSSL x509 -in $CSRFILE -out $CERTFILE -req -signkey $KEYFILE -days $VALID_DAYS)
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

