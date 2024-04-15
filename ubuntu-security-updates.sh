#!/bin/bash

# Shell Script To Install Security Updates on Ubuntu Based Systems

# Author:       V. Alex Brennen <vab@cryptnet.net>
# Copyright:    None
# License:      Public domain
# Date:         2024.02.28
# Dependencies:	apt-get; awk; grep; xargs


## Script configuration

# Locations of programs we'll be using
APT_GET=/usr/bin/apt-get
AWK=/usr/bin/awk
GREP=/usr/bin/grep
XARGS=/usr/bin/xargs

# Perform a dist-upgrade rather than just an upgrade
DIST_UPGRADE=1

# Perform an autoremove after upgrade
AUTOREMOVE=1


# Update the apt package index files to make sure we get all the security
# updates
$APT_GET update

## Perform the updates

# 'dist-upgrade' is used here to be sure all package dependencies are also
# updated. If we were to base our updates on 'upgrade' in the hopes of a more
# stable upgrade, the opposite may be found due to issues like ABI/API changes
# between dependencies or issues with package conflict resolutions.
if [ $DIST_UPGRADE -eq 1 ]; then
    $APT_GET -s dist-upgrade | $GREP "^Inst" | $GREP -i "securi" | $AWK -F " " '{print $2}' | $XARGS $APT_GET install
else
    $APT_GET -s upgrade | $GREP "^Inst" | $GREP -i "securi" | $AWK -F " " '{print $2}' | $XARGS $APT_GET install
fi

## If AUTOREMOVE is set, remove old, potentially vulnerable, packages
# This will prevent, for example, the inadvertent booting of an older vulnerable
# Linux kernel.
if [ $AUTOREMOVE -eq 1 ]; then
	$APT_GET autoremove
fi
