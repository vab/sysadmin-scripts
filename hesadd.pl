#!/usr/bin/perl

# Hesiod Driven User Creation Script
# Author: V. Alex Brennen <vab@mit.edu>
# License: This script is public domain.
# Date: 2013-12-23

# Description: This script will accept a space delimited list
#              of usernames, query a hesiod database to get 
#              account information, and then create the 
#              account(s) locally using `useradd`. This script
#              is useful for adding MIT Athena accounts to 
#              local systems in large numbers, or for adding 
#              them to isolated systems that do not have AFS
#              file system connectivity.


# Should the script use the AFS home directory or create a 
# local home directory? This is generally system specific
# so a command line argument was not used.
# Configuration values:
#   0 = Create a local home directory
#   1 = Use the AFS cluster home directory
$afs_home=0;


unless(@ARGV)
{
	print "Format: hesadd (user name) (user name) ...\n";
	exit(0);
}
else
{
	while($acct = shift)
	{
		print "Adding Account:  $acct\n";
		if($rslt = `/usr/bin/hesinfo $acct passwd`)
		{
			chop($rslt);
			($username,$passwd,$uid,$gid,$gecos,$home,$shell) = 
				split(/:/,$rslt);

			if($afs_home == 0)
			{
				$rslt = system("/usr/sbin/useradd -d /home/$username -m -c \"$gecos\" -s $shell -u $uid $username");
			}
			else
			{
				$rslt = system("/usr/sbin/useradd -d $home -c \"$gecos\" -s $shell -u $uid $username");
			}

			unless($rslt)
			{
				print "  Account added: $acct\n";
			}
			else
			{
				print "  Fatal useradd error:  $acct\n";
			}
		}
		else
		{
			print "  Fatal Hesiod error:  $acct\n";
		}
	}
}

