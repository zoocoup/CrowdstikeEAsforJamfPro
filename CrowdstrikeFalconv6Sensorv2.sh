#!/bin/bash

# Last Edit: 20201102 - jkb

# Report the version of the Crowdstrike Agent if installed
# Location for Crowdstrike Falcon Sensor v3, v4 and v5 installs is /Library/CS/
# Location for v6.10+ installs is /Applications/Falcon.app and /Library/Application Support/CrowdStrike/Falcon
# If Crowdstrike is installed, package receipts for com.crowdstrike.falcon.license, com.crowdstrike.falcon.config
# and com.crowdstrike.falcon.sensor should be installed
# Version 5.36.11708 and higher should have agentID reported in stats output

pkgCount=$(pkgutil --pkgs | grep crowdstrike | wc -l)

if [ $pkgCount -lt 1 ]; 
	# Check to see if packages are even installed
	then 
		verCheck="Agent Not Installed"
	elif [ -e /Applications/Falcon.app/Contents/MacOS/Falcon ];
		# New Falcon install location
		then
			verCheck=$(/Applications/Falcon.app/Contents/Resources/falconctl stats | awk '/version/ {print $2}')
	elif [ -e /Library/CS/ ];
		# Old Falcon Location
		then
			verCheck=$(/Library/CS/falconctl stats | awk '/version/ {print $2}' | sed 's/\.//g' | cut -c 1-3)
			# versions older than 15.36 will report via sysctl
			if [ $verCheck -ge 536 ];
			then
			verCheck=$(/Library/CS/falconctl stats | awk '/version/ {print $2}')
			else
			verCheck=$(sysctl cs | awk '/cs.version/ {print $2}')
			fi
	else
		verCheck="Agent Likely Installed But Not Running"
fi
# Report the result to the JSS.
echo "<result>$verCheck</result>"