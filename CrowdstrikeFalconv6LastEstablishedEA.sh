#!/bin/sh

# falconctl stats, present in  will return a lot of diagnostic information.
# stats is only available in v4.18.8013 and higher
# Get when the cloud state was last established.
# Interval should be every 24 hours
# Location for Crowdstrike Falcon Sensor v3, v4 and v5 installs is /Library/CS/
# Location for v6.10+ installs is /Applications/Falcon.app and /Library/Application Support/CrowdStrike/Falcon

# Last Edit: 20201102 - jkb

pkgCount=$(pkgutil --pkgs | grep crowdstrike | wc -l)

if [ $pkgCount -lt 1 ]; 
	# Check to see if packages are even installed
	then 
		lastCom="Crowdstrike Not Installed"
	elif [ -e /Applications/Falcon.app/Contents/MacOS/Falcon ];
		# New Falcon install location
		then
			lastCom=$(/Applications/Falcon.app/Contents/Resources/falconctl stats | awk '/Cloud Activity | Last Established At/ {print $4,$5,$6,$8,$9}')
	elif [ -e /Library/CS/ ];
		# Old Falcon Location
		then
			verCheck=$(/Library/CS/falconctl stats | awk '/version/ {print $2}' | sed 's/\.//g' | cut -c 1-3)
			# versions older than 15.36 will report via sysctl
			if [ $verCheck -ge 418 ];
			then
			lastCom=$(/Library/CS/falconctl stats | awk '/Cloud Activity | Last Established At/ {print $4,$5,$6,$8,$9}')
			else
			lastCom="Crowdstrike version is too old to support query"
			fi
	else
		lastCom="Agent Likely Installed But Not Running"
fi

echo "<result>$lastCom</result>"