#!/bin/sh

# Report the version of the Crowdstrike kernel extension or system extension
# Versions older than 6.11 only have the kernel extension. Version 6.11+ have both, but it depends on the OS
# macOS 10.15.4 and higher can use the system extension. As of 20201102, 10.15.4 - 10.15.7 are likely still using kext
# macOS 11.0 will only use the system extension

# Last edit 20201102 - jkb 

osVers=$(sw_vers -productVersion | awk -F. '{print $2$3}')
osBuild=$(sw_vers -buildVersion | cut -c 1-2)

# Target: Old version of falcon which only has kext as an option
if  [ -e /Library/CS/ ];
	then
		kextNUM=$(/usr/sbin/kextstat -kl | awk '/crowdstrike/ {print $6}' | wc -l)
		kextVERSION=$(kextstat -kl | awk '/crowd/ {print $7}' | sed s/[\(\)]//g)
		if [ $kextNUM -gt 0 ];
		then
			echo "<result>$kextVERSION</result>"
		else 
			echo "<result>Crowdstrike kext is likely not running</result>"
		fi
elif [ -e /Applications/Falcon.app/Contents/MacOS/Falcon ];
	then 
		if  [ $osBuild -ge 20 ]; 
			# Calling macOS 11.0 first else it fails
		then
		sysextNUM=$(systemextensionsctl list | awk '/com.crowdstrike.falcon.Agent/ {print $7,$8}' | wc -l)
		sysextVERSION=$(systemextensionsctl list | awk '/com.crowdstrike.falcon.Agent/ {print $5}' | sed 's/[()]//g')
			if [ $sysextNUM -gt 0 ]; 
			then
				echo "<result>$sysextVERSION</result>"
			else 
				echo "<result>Crowdstrike kext is likely not running</result>"
			fi
		elif [ $osVers -lt 154 ];
			# Target macOS 10.15.4 and lower that have 6.11 installed
		then 
			kextNUM=$(/usr/sbin/kextstat -kl | awk '/crowdstrike/ {print $6}' | wc -l)
			kextVERSION=$(kextstat -kl | awk '/crowd/ {print $7}' | sed s/[\(\)]//g)
			if [ $kextNUM -gt 0 ]; 
			then
				echo "<result>$kextVERSION</result>"
			else 
				echo "<result>Crowdstrike kext is likely not running</result>"
			fi
		elif [ $osVers -gt 154 ];
				# Target macOS 10.15.4 through 10.15.7/not 11.0 with v6.11
			then
			kextNUM=$(/usr/sbin/kextstat -kl | awk '/crowdstrike/ {print $6}' | wc -l)
			kextVERSION=$(kextstat -kl | awk '/crowd/ {print $7}' | sed s/[\(\)]//g)
			if [ $kextNUM -gt 0 ]; 
			then
				echo "<result>$kextVERSION</result>"
			else 
				echo "<result>Crowdstrike kext is likely not running</result>"
			fi
		fi
else
		echo "<result>Crowdstrike not installed and/or running</result>"
fi