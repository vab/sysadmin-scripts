#!/bin/bash

# Shell script to install security updates with yum via cron
# Author:       V. Alex Brennen <vab@cryptnet.net>
# Copyright:    None
# License:      Public domain
# Date:         2014.03.23
# Dependencies:	yum

# Description:  This script will call yum to download and install any relevant
#               security updates for a RedHat Enterprise Linux, or similar,
#               system.


# The location of yum
YUM=/usr/bin/yum

# Log Location
LOG=/var/log/security-updates.log

# Perform the updates
$YUM -y --security update 2>&1 > $LOG
