# Supersonic Update Script for macOS.
# Created by Gavin Liddell

#!/bin/bash

get_local_version() {
	defaults read /Applications/Supersonic.app/Contents/Info.plist CFBundleShortVersionString # Fetch current version installed.
}

get_latest_version() {
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

install() {
		curl -sL $download_url -o $tmp # Grab the latest .zip file from GitHub and move to the user's tmp folder.
		unzip -o -qq $tmp -d /Applications/ # Unzip file into the Applications folder.
		rm $tmp # Remove the downloaded zip file after unzipping.
		echo "Update completed!"
		exit 0
}

local=$(get_local_version) # Sets the local version function as a variable.
latest=$(get_latest_version) # Sets the latest version as a variable.
platform=$(get_platform) # Set the platform version as a variable.
kernel=$(get_kernel) # Set the kernel version as a variable.
tmp=$HOME/tmp/Supersonic.zip # Set the download directory as a variable.

printf "Your Supersonic Version: $local\nLatest Supersonic Version: $latest\n" ; # Output current and latest version.

if [[ "$local" == "$latest" ]] # Compare the installed and latest version from GitHub.

	then
		echo "You are up-to-date!" # Explains that the user's version is already up-to-date.
		exit 0

	elif [[ $kernel < 18 ]] # Checks if OS version is legacy.

	then # Installs legacy version if the statement is true
		printf "Your Supersonic version is out-of-date!\nDownloading the latest legacy update.\n" && # Explain that the application is out-of-date and that the update is being downloaded.
		download_url="https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$latest-mac-legacy-HighSierra-x64.zip" # Set the download_url variable.
		install # Run the install function.
	else
		printf "Your Supersonic version is out-of-date!\nDownloading the latest update.\n" && # Explain that the application is out-of-date and that the update is being downloaded.
		download_url="https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$latest-mac-$platform.zip" # Set the download_url variable.
		install # Run the install function.
fi
