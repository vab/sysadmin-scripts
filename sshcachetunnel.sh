#!/bin/bash

# SSH Cache Tunnel Script
# Author:       V. Alex Brennen <vab@cryptnet.net>
# Copyright:    None
# License:      Public domain
# Date:         2003-11-01
# Dependencies:	OpenSSH; Remote Squid proxy server

# Description:  This script will tunnel an HTTP cache connection over SSH so
#               that you can do off site testing of HTTP IP address access
#               control/filtering restrictions through an external system
#               while on a heavily firewalled LAN with limited exit ports
#               allowed. Note: The browser should be configured to use the
#               cache as if it was running on the localhost (loopback
#               interface).


SSH=/usr/bin/ssh
SSH_PORT=22
LOCAL_PROXY_PORT=3128
REMOTE_PROXY_PORT=3128
PROXY_ADDR=offsiteproxy.example.com


$SSH -p $SSH_PORT -L $LOCAL_PROXY_PORT:localhost:$REMOTE_PROXY_PORT $PROXY_ADDR -f -N
