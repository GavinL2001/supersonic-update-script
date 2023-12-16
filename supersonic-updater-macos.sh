# Supersonic Update Script for macOS.
# Created by @GavinL2001

#!/bin/bash

get_local_version() {
	defaults read /Applications/Supersonic.app/Contents/Info.plist CFBundleShortVersionString # Fetch current version installed.
}

echo "Your Supersonic Version: $(get_local_version)" # Output current version installed.

get_latest_release() {
	# Credit to @lukechilds on Github for the script.
	curl --silent "https://api.github.com/repos/dweymouth/supersonic/releases/latest" | # Get latest release from GitHub api
	grep '"tag_name":' |                                              		    # Get tag line
	sed -E 's/.*"v([^"]+)".*/\1/'                              			    # Pluck JSON value
}

echo "Latest Supersonic Version: $(get_latest_release)" # Output latest release on GitHub.

get_platform() {
	uname -m # Get the processor type of the user's machine
}

get_kernel() {
	uname -r | sed 's/\..*//' # Get macOS version number.
}

if [[ "$(get_local_version)" == "$(get_latest_release)" ]] # Compare the installed and latest version from GitHub.

	then
		echo "You are up-to-date!" # Explains that the user's version is already up-to-date.

	elif [[ "$(get_platform)" == "x86_64" && $(get_kernel) < 18 ]] # Checks if platform is x86_64 and legacy.

	then # Installs x64 legacy version if the statement is true
		echo "Your processor type is x64 and running legacy version of macOS.\nDownloading the latest legacy update." && # Display's the user's processor type, the fact it's running a legacy version of macOS, and that the update is being downloaded.
		wget -q https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$(get_latest_release)-mac-legacy-HighSierra-x64.zip --output-document=$HOME/Downloads/Supersonic-$(get_latest_release).zip && # Grab the latest .zip file from GitHub and move to the user's Downloads folder.
		unzip -o -qq $HOME/Downloads/Supersonic-$(get_latest_release).zip -d /Applications/ && # Unzip file into the Applications folder.
		rm $HOME/Downloads/Supersonic-$(get_latest_release).zip # Remove the downloaded zip file after unzipping.
		echo "Update completed!"

	elif [[ "$(get_platform)" == "x86_64" && $(get_kernel) > 17 ]] # Checks if platform is x86_64 and non-legacy.
	
	then # Installs x64 non-legacy version if the statement is true
		echo "Your processor type is x64.\nDownloading the latest update." && # Display's the user's processor type and that the update is being downloaded.
		wget -q https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$(get_latest_release)-mac-x64.zip --output-document=$HOME/Downloads/Supersonic-$(get_latest_release).zip && # Grab the latest .zip file from GitHub and move to the user's Downloads folder.
		unzip -o -qq $HOME/Downloads/Supersonic-$(get_latest_release).zip -d /Applications/ && # Unzip file into the Applications folder.
		rm $HOME/Downloads/Supersonic-$(get_latest_release).zip # Remove the downloaded zip file after unzipping.
		echo "Update completed!"

	else  # Installs arm64 version if the statement is false
		echo "Your processor type is arm64.\nDownloading the latest update." # Display's the user's processor type and that the update is being downloaded.
		wget -q https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$(get_latest_release)-mac-arm64.zip --output-document=$HOME/Downloads/Supersonic-$(get_latest_release).zip && # Grab the latest .zip file from GitHub and move to the user's Downloads folder.
		unzip -o -qq $HOME/Downloads/Supersonic-$(get_latest_release).zip -d /Applications/ && # Unzip file into the Applications folder.
		rm $HOME/Downloads/Supersonic-$(get_latest_release).zip && # Remove the downloaded zip file after unzipping.
		echo "Update completed!"
fi
