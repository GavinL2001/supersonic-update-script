# Supersonic Update/Install Script for Windows.
# Created by Gavin Liddell
# https://github.com/GavinL2001/supersonic-update-script

Write-Output @"
Supersonic Update Script for Windows
Created by Gavin Liddell
Repo: https://github.com/GavinL2001/supersonic-update-script
"@

Write-Output "Checking for update..."

Function Find-Path {
    $include = "${env:ProgramFiles(x86)}\", "$env:ProgramFiles\", "$env:USERPROFILE\"
    $exclude = "*.pf", "$env:USERPROFILE\AppData"
    $pathSearch = Get-ChildItem -Path $include -Exclude $exclude -Filter "Supersonic.exe" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    If ($pathSearch -and $pathSearch.Name -eq 'Supersonic.exe') {
        Return $pathSearch.DirectoryName
    } Else {
        Return $null
    }
}

Function Pull-Local {
    Param($filePath)
    If ($filePath) {
        $joinFile = Join-Path -Path $filePath -ChildPath "Supersonic.exe"
        $versionInfo = (Get-Item $joinFile).VersionInfo
        $fileVersion = "$($versionInfo.FileMajorPart).$($versionInfo.FileMinorPart).$($versionInfo.FileBuildPart)"
        Return $fileVersion
    } Else {
        Return $null
    }
}

Function Pull-Latest {
    $request = Invoke-RestMethod -Uri https://api.github.com/repos/dweymouth/supersonic/releases/latest | Select-Object -ExpandProperty name
    Return $request
}

Function Check-Path {
    $checkLoc = Test-Path "$env:ProgramFiles\Supersonic"
    If ($checkLoc) {
        Return "$env:ProgramFiles\Supersonic"
    } Else {
        New-Item "$env:ProgramFiles\Supersonic" -ItemType "directory" -ErrorAction Stop | Out-Null
        Return "$env:ProgramFiles\Supersonic"
    }
}

Function Install-Update {
    Param($appPath, $latest)
    $url = "https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$latest-windows-x64.zip"
    $location = "$env:temp\Supersonic-$latest-windows-x64.zip"
    $testLocation = Test-Path $location -ErrorAction SilentlyContinue
    If ($testLocation) {
        Expand-Archive -Path "$location" -DestinationPath "$appPath" -Force -ErrorAction Stop
    } Else {
        Invoke-WebRequest -Uri $url -OutFile "$location" -ErrorAction Stop
        Expand-Archive -Path "$location" -DestinationPath "$appPath" -Force -ErrorAction Stop
    }
}

Function Test-Install {
    Param($appPath)
    $testInstall = Test-Path "$appPath\Supersonic.exe" -ErrorAction SilentlyContinue
    If ($testInstall) {
        Write-Output "Supersonic installed successfully!"
    } Else {
        Write-Output "Supersonic failed to install."
    }
}

Function Update-Shortcut {
    Param($appPath)
    $shortcutPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Supersonic.lnk"
    If (Test-Path $shortcutPath -ErrorAction SilentlyContinue) {
        Remove-Item -Path $shortcutPath -ErrorAction SilentlyContinue
    }
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "$appPath\Supersonic.exe"
    $shortcut.Save()
}

If ($env:PROCESSOR_ARCHITECTURE -ne "AMD64") {
    Write-Error "Unsupported platform detected! This program only supports x64 processors."
    Exit
} Else {
    $filePath = Find-Path
    $local = Pull-Local -filePath $filePath
    $latest = Pull-Latest
    $appPath = Check-Path
    If ($local -eq $latest) {
        Write-Output "Detected version: $local`nLatest version: $latest"
        Write-Output "You are up-to-date!"
        Update-Shortcut -appPath $appPath
    } ElseIf (-not $local) {
        Write-Output "Supersonic not installed!`nInstalling..."
        Install-Update -appPath $appPath -latest $latest
        Update-Shortcut -appPath $appPath
        Test-Install -appPath $appPath
    } Else {
        Write-Output "Detected version: $local`nLatest version: $latest"
        Write-Output "Your Supersonic version is out-of-date!`nInstalling the latest update..."
        Install-Update -appPath $appPath -latest $latest
        Update-Shortcut -appPath $appPath
        Test-Install -appPath $appPath
    }
}
