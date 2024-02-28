#!/bin/bash

# Shell Script To Install Security Updates on Ubuntu Based Systems

# Author:       V. Alex Brennen <vab@cryptnet.net>
# Copyright:    None
# License:      Public domain
# Date:         2024.02.28
# Dependencies:	apt-get; awk; grep; xargs


# Locations of programs we'll be using
APT_GET=/usr/bin/apt-get
AWK=/usr/bin/awk
GREP=/usr/bin/grep
XARGS=/usr/bin/xargs


# Update the apt package index files to make sure we get all the security
# updates
$APT_GET update

## Perform the updates

# 'dist-upgrade' is used here to be sure all package dependencies are also
# updated. If we were to base our updates on 'upgrade' in the hopes of a more
# stable upgrade, the opposite may be found due to issues like ABI/API changes
# between dependencies or issues with package conflict resolutions.
$APT_GET -s dist-upgrade | $GREP "^Inst" | $GREP -i securi | $AWK -F " " {'print $2'} | $XARGS $APT_GET install

## Remove old, potentially vulnerable, packages
# This will prevent, for example, the inadvertent booting of an older vulnerable
# Linux kernel.

$APT_GET autoremove
