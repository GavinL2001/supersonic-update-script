# Supersonic Update Script for macOS.
# Created by Gavin Liddell
# https://github.com/GavinL2001/supersonic-update-script

#!/bin/zsh

# Functions

get_local_version() {
	defaults read /Applications/Supersonic.app/Contents/Info.plist CFBundleShortVersionString                                                # Fetch current version installed.
}

get_latest_version() {                                                                                                                           # Credit to @lukechilds on Github for the function.
	curl --silent "https://api.github.com/repos/dweymouth/supersonic/releases/latest" |                                                      # Get latest release from GitHub api.
	grep '"tag_name":' |                                                                                                                     # Get tag line.
	sed -E 's/.*"v([^"]+)".*/\1/'                                                                                                            # Pluck JSON value.
}

get_platform() {
	uname -m | sed 's/86_//'                                                                                                                 # Get the processor type of the user's machine.
}

get_kernel() {
	uname -r | sed 's/\..*//'                                                                                                                # Get macOS version number.
}

install() {
		curl -sL $download_url -o $location                                                                                              # Grab the latest .zip file from GitHub and move to the user's tmp folder.
		unzip -o -qq $location -d /Applications/                                                                                         # Unzip file into the Applications folder.
		rm $location                                                                                                                     # Remove the downloaded zip file after unzipping.
		[ "$(get_local_version)" == "$latest" ] && echo "Update completed!" || echo "Update failed."                                     # Check that the update worked as intended.
		exit 0
}

# Variables

local=$(get_local_version)                                                                                                                       # Sets the local version function as a variable.
latest=$(get_latest_version)                                                                                                                     # Sets the latest version as a variable.
platform=$(get_platform)                                                                                                                         # Set the platform version as a variable.
kernel=$(get_kernel)                                                                                                                             # Set the kernel version as a variable.
location=$HOME/tmp/Supersonic.zip                                                                                                                # Set the download directory as a variable.

# The Update Process

printf "Supersonic Update Scrip for macOS\nCreated by Gavin Liddell\nRepo: https://github.com/GavinL2001/supersonic-update-script\n"             # Show source and creator of the project.
sleep 1
printf "\nChecking for update.\nYour Supersonic Version: $local\nLatest Supersonic Version: $latest\n"                                           # Output current and latest version.

[ "$local" == "$latest" ] && echo "You are up-to-date!"	&& exit 0 ||                                                                             # Compare the installed and latest version from GitHub.

if [[ $kernel < 18 ]]                                                                                                                            # Checks if OS version is legacy.
	then                                                                                                                                     # Installs legacy version if the statement is true.
		download_url="https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$latest-mac-legacy-HighSierra-x64.zip" # Set the download_url variable.
		printf "Your Supersonic version is out-of-date!\nInstalling the latest legacy update.\n"                                         # Explain that the application is out-of-date and that the update is being downloaded.
		install                                                                                                                          # Calls the install function.
	else
		download_url="https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$latest-mac-$platform.zip"             # Set the download_url variable.		
		printf "Your Supersonic version is out-of-date!\nInstalling the latest update.\n"                                                # Explain that the application is out-of-date and that the update is being downloaded.
		install                                                                                                                          # Calls the install function.
fi
