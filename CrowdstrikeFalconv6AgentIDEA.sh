#!/bin/bash

# Last Edit: 20201114 - jkb

# Report the Crowdstrike agentID of the client if the Crowdstrike Agent if installed
# Location for Crowdstrike Falcon Sensor v3, v4 and v5 installs is /Library/CS/
# Location for v6.10+ installs is /Applications/Falcon.app and /Library/Application Support/CrowdStrike/Falcon
# If Crowdstrike is installed, package receipts for com.crowdstrike.falcon.license, com.crowdstrike.falcon.config
# and com.crowdstrike.falcon.sensor should be installed
# Version 5.36.11708 and higher should have agentID reported in stats output

pkgCount=$(pkgutil --pkgs | grep crowdstrike | wc -l)

if [ $pkgCount -lt 1 ]; 
	# Check to see if packages are even installed
	then 
		idCheck="Agent Not Installed"
	elif [ -e /Applications/Falcon.app/Contents/MacOS/Falcon ];
		# New Falcon install location
		then
			idCheck=$(/Applications/Falcon.app/Contents/Resources/falconctl stats | awk '/agentID/ {print $2}' | tr '[:upper:]' '[:lower:]' | sed 's/\-//g')
	elif [ -e /Library/CS/ ];
		# Old Falcon Location
		then
			verCheck=$(/Library/CS/falconctl stats | awk '/version/ {print $2}' | sed 's/\.//g' | cut -c 1-3)
			# versions older than 15.36 will report via sysctl
			if [ $verCheck -ge 536 ];
			then
			idCheck=$(/Library/CS/falconctl stats | awk '/agentID/ {print $2}' | tr '[:upper:]' '[:lower:]' | sed 's/\-//g' )
			else
			idCheck=$(sysctl cs.sensorid | awk '{print $2}' | sed s/\-//g)
			fi
	else
		idCheck="Agent Likely Installed But Not Running"
fi
# Report the result to the JSS.
echo "<result>$idCheck</result>"