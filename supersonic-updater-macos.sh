# Supersonic Update Script for macOS.
# Created by @GavinL2001

#!/bin/bash

get_local_version() {
	defaults read /Applications/Supersonic.app/Contents/Info.plist CFBundleShortVersionString # Fetch current version installed.
}

get_latest_release() {
	# Credit to @lukechilds on Github for the script.
	curl --silent "https://api.github.com/repos/dweymouth/supersonic/releases/latest" | # Get latest release from GitHub api
	grep '"tag_name":' |                                              		    # Get tag line
	sed -E 's/.*"v([^"]+)".*/\1/'                              			    # Pluck JSON value
}

get_platform() {
	uname -m | sed 's/86_//' # Get the processor type of the user's machine
}

get_kernel() {
	uname -r | sed 's/\..*//' # Get macOS version number.
}

echo "Your Supersonic Version: $(get_local_version)" ; # Output current version installed.
echo "Latest Supersonic Version: $(get_latest_release)" # Output latest release on GitHub.

if [[ "$(get_local_version)" == "$(get_latest_release)" ]] # Compare the installed and latest version from GitHub.

	then
		echo "You are up-to-date!" # Explains that the user's version is already up-to-date.
		exit 0

	elif [[ $(get_kernel) < 18 ]] # Checks if OS version is legacy.

	then # Installs legacy version if the statement is true
		echo "Your Supersonic version is out-of-date!" ; echo "Downloading the latest legacy update." && # Explain that the application is out-of-date and that the update is being downloaded.
		curl -sL https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$(get_latest_release)-mac-legacy-HighSierra-x64.zip -o $HOME/tmp/Supersonic.zip && # Grab the latest .zip file from GitHub and move to the user's tmp folder.
		unzip -o -qq $HOME/tmp/Supersonic.zip -d /Applications/ && # Unzip file into the Applications folder.
		rm $HOME/tmp/Supersonic.zip && # Remove the downloaded zip file after unzipping.
		echo "Update completed!" ;
		exit 0
	else
		echo "Your Supersonic version is out-of-date!" ; echo "Downloading the latest update." && # Explain that the application is out-of-date and that the update is being downloaded.
		curl -sL https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$(get_latest_release)-mac-$(get_platform).zip -o $HOME/tmp/Supersonic.zip && # Grab the latest .zip file from GitHub and move to the user's tmp folder.
		unzip -o -qq $HOME/tmp/Supersonic.zip -d /Applications/ && # Unzip file into the Applications folder.
		rm $HOME/tmp/Supersonic.zip && # Remove the downloaded zip file after unzipping.
		echo "Update completed!" ;
		exit 0
fi
