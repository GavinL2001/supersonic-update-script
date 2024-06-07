# Supersonic Update/Install Script for Windows.
# Created by Gavin Liddell
# https://github.com/GavinL2001/supersonic-update-script

Write-Output "Supersonic Update Script for Windows`nCreated by Gavin Liddell`nRepo: https://github.com/GavinL2001/supersonic-update-script`n"
Write-Output "Checking for update..."

Function Find-Path {
    $include = "${env:ProgramFiles(x86)}\", "$env:ProgramFiles\", "$env:USERPROFILE\"
    $exclude = "*.pf", "$env:USERPROFILE\AppData"
    $pathSearch = Get-ChildItem -Path $include -Exclude $exclude -Filter "Supersonic.exe" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    If ($pathSearch.Name -eq 'Supersonic.exe') {Return $pathSearch.DirectoryName}
    Else {Return $null}
}

$filePath = Find-Path

Function Pull-Local {
    If ($filePath -ne $null) {
        $joinFile = Join-Path -Path $filePath -ChildPath "Supersonic.exe"
        $versionInfo = (Get-Item $joinFile).VersionInfo
        $fileVersion = "$($versionInfo.FileMajorPart).$($versionInfo.FileMinorPart).$($versionInfo.FileBuildPart)"
        Return $fileVersion
    } Else {Return $null}
}

$local = Pull-Local -Directory $filePath

Function Pull-Latest {
    $request = Invoke-RestMethod -Uri https://api.github.com/repos/dweymouth/supersonic/releases/latest | ConvertTo-Json
    $data = $request | ConvertFrom-Json
    Return $data.name
}

$latest = Pull-Latest

Function Check-Path {
    $checkLoc = Test-Path "$env:ProgramFiles\Supersonic"
    If ($filePath -ne $null) {Return $filePath}
    ElseIf ($filePath -eq $null -and $checkLoc -ne $false) {
        $installPath = "$env:ProgramFiles\Supersonic"
        Return $installPath
    } Else {
        New-Item "$env:ProgramFiles\Supersonic" -ItemType "directory" -ErrorAction Stop
        $installPath = "$env:ProgramFiles\Supersonic"
        Return $installPath
    }
}

$appPath = Check-Path

Function Install-Update {
    $url = "https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$latest-windows-x64.zip"
    $location = "$env:temp\Supersonic-$latest-windows-x64.zip"
    $testLocation = Test-Path $location -ErrorAction Stop
    If ($testLocation -eq $true) {Expand-Archive -Path "$location" -DestinationPath "$appPath" -Force -ErrorAction Stop}
    Else {
        Invoke-WebRequest -Uri $url -OutFile "$location" -ErrorAction Stop
        Expand-Archive -Path "$location" -DestinationPath "$appPath" -Force -ErrorAction Stop
    }
    Return
}

Function Test-Install {
    $testInstall = Test-Path $appPath\Supersonic.exe -ErrorAction Stop
    If ($testInstall -eq $true) {Write-Output "Supersonic installed successfully!"}
    Else {Write-Output "Supersonic failed to install."}
    Return
}

Function Update-Shortcut {
    $shortcutPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Supersonic.lnk"
    $testShortcut = Test-Path "$shortcutPath" -ErrorAction Stop
    If ($testShortcut = $true) {Remove-Item -Path "$shortcutPath"}
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Supersonic.lnk")
    $shortcut.TargetPath = "$appPath\Supersonic.exe"
    $shortcut.Save()
    Return
}

If ($env:PROCESSOR_ARCHITECTURE -ne "AMD64") {
    Write-Error "Unsupported platform detected! This program only supports x64 processors."
    Return
} ElseIf ($local -eq $latest) {
    Write-Output "Detected version: $local`nLatest version: $latest"
    Write-Output "You are up-to-date!"
    Update-Shortcut
}
ElseIf ($local -eq $null) {
    Write-Output "Supersonic not installed!`nInstalling..."
    Install-Update
    Update-Shortcut
    Test-Install
} Else {
    Write-Output "Detected version: $local`nLatest version: $latest"
    Write-Output "Your Supersonic version is out-of-date!`nInstalling the latest update..."
    Install-Update
    Update-Shortcut
    Test-Install
}