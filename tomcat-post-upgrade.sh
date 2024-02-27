#!/bin/bash

# Tomcat Post Upgrade File Permission Adjustment Script

# Author:       V. Alex Brennen <vab@cryptnet.net>
# Copyright:    None
# License:      Public domain
# Date:         2013-12-17
# Dependencies:	Apache Tomcat

# Description: 
# This is a simple script to adjust Apache Tomcat file ownership
# on RHEL after an upgrade. This script is useful if you decide
# to run Apache Tomcat as a user other than "tomcat". Because, the
# RHEL Tomcat RPM post install script resets the file ownership
# on the log files and cache directories to tomcat even if they
# were changed by the local administrator.

# I use this script to help run the MIT DSpace digital repository
# system under the a "dspace" user. Running as a user other than
# "tomcat" makes it easier to load content both from the web
# interface and command line batch jobs while still isolating
# individual user accounts from the server configuration files
# and tomcat process.


UID="dspace"
GID="dspace"

/bin/chown $UID:$GID /var/log/tomcat/catalina.out
/bin/chown -R $UID:$GID /var/cache/tomcat

# The DSpace software currently recommends installation in a webapps
# directory in the home directory of the user running the system,
# typically "dspace". The RHEL RPM post install script will remove a
# symlink in the '/var/lib/tomcat/webapps' location and replace it
# with an empty directory. These next command remove the new empty 
# directory and recreate the symlink.

WEBAPPS_LOC="/home/dspace/webapps"

/bin/rm -r /var/lib/tomcat/webapps
/bin/ln -s $WEBAPPS_LOC /var/lib/tomcat/webapps
