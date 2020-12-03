#!/bin/sh

# Reports back the 2-minute client to server heartbeats for last 1, 4, 8, 12 and 24 hours
# See “Verify that the Sensor is Connected to the Cloud” — 
# “In the output, look for the Events Sent section and the SensorHeartbeatMacV4 event. 
# Ensure that sensor heartbeats are being sent every two minutes. 
# The verifies the connection is established and negotiated with the cloud.”
# https://falcon.crowdstrike.com/support/documentation/22/falcon-sensor-for-mac


# Last edit 20201102 - jkb 

osVers=$(sw_vers -productVersion | awk -F. '{print $2$3}')
osBuild=$(sw_vers -buildVersion | cut -c 1-2)
# Because OS version for Big Sur would equal "110" need to use buid number (20 == macOS 11.0 Big Sur) but still need version number because of kext/system extension on 10.15

# Location for Crowdstrike Falcon Sensor v3, v4 and v5 installs is /Library/CS/
# Location for v6.10+ installs is /Applications/Falcon.app and /Library/Application Support/CrowdStrike/Falcon
# v6.10 on 10.15.4+ should use System Extension. All others use kext. As of 20201102, possible even 10.15.4 - 10.15.7 systems might still be using kext

# Checking for which version of Falcon is installed first and then OS to filter machine into right path and prevent errors
# Putting the variables inline to prevent error noise

# Target: Old version of falcon and older OSes
if  [ -e /Library/CS/ ] && [ $osBuild -lt 19 ];
	then
		kextVersion=$(sysctl cs | awk '/cs.version/ {print $2}' | tr -d . | cut -c 1-5) 
		kextNum=$(/usr/sbin/kextstat -kl | awk '/crowdstrike/ {print $6}' | wc -l)
		csHeartbeats4=$(/Library/CS/falconctl stats | awk '/SensorHeartbeatMacV4/ {print $4,$5,$6,$7,$8}' | sed 's/ /\|/g')
		if [ $kextNum -gt 0 ] && [ $kextVersion -ge 41880 ];
		# If the kext is loaded and the version is compatible, check heartbeats
		# Sensor version 4.18.8013 and later have the falconctl stats option. If version is too old, don't run
		then
			echo "<result>$csHeartbeats4</result>"
		fi
# Target: Old version of falcon, which will not have system extension and 10.15
elif [ -e /Library/CS/ ] && [ $osBuild -eq 19 ]
		then
			kextVersion=$(sysctl cs | awk '/cs.version/ {print $2}' | tr -d . | cut -c 1-5) 
			kextNum=$(/usr/sbin/kextstat -kl | awk '/crowdstrike/ {print $6}' | wc -l)
			csHeartbeats4=$(/Library/CS/falconctl stats | awk '/SensorHeartbeatMacV4/ {print $4,$5,$6,$7,$8}' | sed 's/ /\|/g')
			if [ $kextNum -gt 0 ];
			# is the kext loaded
			then 
				echo "<result>$csHeartbeats4</result>"
			fi
# Target: New version of falcon and macOS 11.0+
elif [ -e /Applications/Falcon.app/Contents/MacOS/Falcon ] && [ $osBuild -ge 20 ];
	# Calling macOS 11.0 systems first to keep 10.15.4+ check from short circuiting run
	then	
		syextNum=$(systemextensionsctl list | awk '/com.crowdstrike.falcon.Agent/ {print $7,$8}' | wc -l) 
		csHeartbeats6=$(/Applications/Falcon.app/Contents/Resources/falconctl stats | awk '/SensorHeartbeatMacV4/ {print $4,$5,$6,$7,$8}' | sed 's/ /\|/g')
		if [ $syextNum -gt 0 ]; 
			# Is the system extension loaded? 
		then 
			echo "<result>$csHeartbeats6</result>"
		fi
# Target: New version of falcon and macOS 10.15.4 and lower
elif [ -e /Applications/Falcon.app/Contents/MacOS/Falcon ] && [ $osVers -lt 154 ];
		then
			kextNum=$(/usr/sbin/kextstat -kl | awk '/crowdstrike/ {print $6}' | wc -l) 
			csHeartbeats6=$(/Applications/Falcon.app/Contents/Resources/falconctl stats | awk '/SensorHeartbeatMacV4/ {print $4,$5,$6,$7,$8}' | sed 's/ /\|/g')
			if [ $kextNum -gt 0 ];
			# is the kext loaded
			then 
				echo "<result>$csHeartbeats6</result>"
			fi
# Target: New version of falcon and macOS 10.15.4 through 10.15.7/not 11.0
elif [ -e /Applications/Falcon.app/Contents/MacOS/Falcon ] && [ $osVers -gt 154 ];
	then	
		syextNum=$(systemextensionsctl list | awk '/com.crowdstrike.falcon.Agent/ {print $7,$8}' | wc -l) 
		csHeartbeats6=$(/Applications/Falcon.app/Contents/Resources/falconctl stats | awk '/SensorHeartbeatMacV4/ {print $4,$5,$6,$7,$8}' | sed 's/ /\|/g')
		if [ $syextNum -gt 0 ]; 
			# Is the system extension loaded? 
		then 
			echo "<result>$csHeartbeats6</result>"
		else 
			# As of 20201102, possible even 10.15.4 - 10.15.7 systems might still be using kext
			echo "<result>$csHeartbeats6</result>"
		fi
else
		echo "<result>Crowdstrike not installed and/or running</result>"
fi
