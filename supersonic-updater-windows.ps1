# Supersonic Update/Install Script for Windows.
# Created by Gavin Liddell
# https://github.com/GavinL2001/supersonic-update-script

Write-Output "Supersonic Update Script for Windows`nCreated by Gavin Liddell`nRepo: https://github.com/GavinL2001/supersonic-update-script`n"
Write-Output "Checking for update..."
Start-Sleep -Seconds 1

Function Find-Path {
    $timeoutSeconds = 2
    $pathSearch = {Get-ChildItem -Path C:\ -Filter 'Supersonic.exe' -Exclude '*.pf' -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1}
    $j = Start-Job -ScriptBlock $pathSearch
    If (Wait-Job $j -Timeout $timeoutSeconds) {
        $result = Receive-Job $j
        Remove-Job -force $j
        If ($result.Name -eq 'Supersonic.exe') {Return $result.DirectoryName}
        Else {Return $null}
    } Else {
        Remove-Job -force $j
        Return $null
    }
}

$filePath = Find-Path

Function Pull-Local {
    If ($filePath -ne $null) {
        $fileLocation = Join-Path -Path $filePath -ChildPath 'Supersonic.exe'
        $versionInfo = (Get-Item $fileLocation).VersionInfo
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

Function Run-Process {
    $url = "https://github.com/dweymouth/supersonic/releases/latest/download/Supersonic-$latest-windows-x64.zip"
    $location = "$env:temp\Supersonic-$latest-windows-x64.zip"
    $checkLoc = Test-Path "$env:ProgramFiles\Supersonic"
    Invoke-WebRequest -Uri $url -OutFile "$location"
    If ($filePath -eq $null -and $checkLoc -eq $false) {
        New-Item -Path "$env:ProgramFiles" -Name "Supersonic" -ItemType "directory"
        $installpath = "$env:ProgramFiles\Supersonic"
    } Else {$installpath = "$env:ProgramFiles\Supersonic"}
    Expand-Archive -Path "$location" -DestinationPath "$installPath" -Force
    Remove-Item -Path "$env:temp\Supersonic-$latest-windows-x64.zip"
    Return
}

Function Update-Shortcut {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Supersonic.lnk")
    $shortcut.TargetPath = "$installPath\Supersonic.exe"
    $shortcut.Save()
}

If ($local -eq $latest) {Write-Output "You are up-to-date!"}
ElseIf ($local -ne $null) {Write-Output "Detected version: $local`nLatest version: $latest"}
ElseIf ($local -eq $null) {
    Write-Output "Supersonic not installed!`nInstalling..."
    Run-Process
    Update-Shortcut
} Else {
    Write-Output "Your Supersonic version is out-of-date!`nInstalling the latest update..."
    Run-Process
    Update-Shortcut
}