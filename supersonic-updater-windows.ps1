# Supersonic Update/Install Script for Windows.
# Created by Gavin Liddell
# https://github.com/GavinL2001/supersonic-update-script

Write-Output "Supersonic Update Script for Windows`nCreated by Gavin Liddell`nRepo: https://github.com/GavinL2001/supersonic-update-script`n"
Start-Sleep -Seconds 1

function Find-Path {
    $path = "$env:ProgramFiles\Supersonic"
    If (Test-Path $path) {
        return $path
    } Else {
        return $null
    }
}

$filePath = Find-Path

function Pull-Local {
    If ($filePath -ne $null) {
        $fileLocation = Join-Path -Path $filePath -ChildPath 'Supersonic.exe'
        $versionInfo = (Get-Item $fileLocation).VersionInfo
        $fileVersion = "$($versionInfo.FileMajorPart).$($versionInfo.FileMinorPart).$($versionInfo.FileBuildPart)"
        return $fileVersion
    } Else {
        return $null
    }
    
}

$local = Pull-Local -Directory $filePath

function Pull-Latest {
    $request = Invoke-RestMethod -Uri https://api.github.com/repos/dweymouth/supersonic/releases/latest | ConvertTo-Json
    $data = $request | ConvertFrom-Json
    return $data.name
}

$latest = Pull-Latest

function Run-Install {
    $url = "https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$latest-windows-x64.zip"
    $location = "$env:temp\Supersonic-$latest-windows-x64.zip"
    Invoke-WebRequest -Uri $url -OutFile "$location"
    New-Item -Path "$env:ProgramFiles" -Name "Supersonic" -ItemType "directory" -Force
    Expand-Archive -Path "$location" -DestinationPath "$env:ProgramFiles\Supersonic" -Force
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Supersonic.lnk")
    $shortcut.TargetPath = "$env:ProgramFiles\Supersonic\Supersonic.exe"
    $shortcut.Save()
    Remove-Item -Path "$env:temp\Supersonic-$latest-windows-x64.zip"
    Return
}

function Run-Update {
    $url = "https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$latest-windows-x64.zip"
    $location = "$env:temp\Supersonic-$latest-windows-x64.zip"
    Invoke-WebRequest -Uri $url -OutFile "$location"
    Expand-Archive -Path "$location" -DestinationPath "$filePath" -Force
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Supersonic.lnk")
    $shortcut.TargetPath = "$filePath\Supersonic.exe"
    $shortcut.Save()
    Remove-Item -Path "$env:temp\Supersonic-$latest-windows-x64.zip"
    Return
}

Write-Output "Checking for update..."

If ($local -ne $null) {
    Write-Output "Detected version: $local`nLatest version: $latest"
}

If ($local -eq $latest) { 
    Write-Output "You are up-to-date!"
    Exit
} ElseIf ($local -eq $null) {
    Write-Output "Supersonic not installed!`nInstalling..."
    Run-Install
    Exit
} Else {
    Write-Output "Your Supersonic version is out-of-date!`nInstalling the latest update."
    Run-Update
    Exit
}
