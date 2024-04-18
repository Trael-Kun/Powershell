
<#
.SYNOPSIS
PStream Uninstall

.DESCRIPTION
Removes Paper Stream & other dependencies.

.EXAMPLE
PS> .\remove.ps1

.NOTES
Author: Bill Wilson
Created: 18/04/2024
#>

#Variables
$PsApp = 'PaperStream Capture'
$SopApp = 'Software Operation Panel'
$TwainApp = 'TWAIN Drivers'
#Paths
$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$MsiExe= "$env:WinDir\System32\msiexec.exe"
$Regpaths = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
$StMenu = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
$PStream = "$ScriptPath\PSCapture"
$Panel= "$ScriptPath\SOPSetup"
$ChooChoo= "$ScriptPath\TwainDwiver"
$Log = "$env:WinDir\Logs\PStream.log"

#Arguments
$PsArgs =@(
    "/NoRestart",
    "/QN"
    "/l*v $Log"
)
$SopArgs = @(
    "/x",
    "`"$Panel\SOPSetup.msi`"",
    "/NoRestart",
    "/QN"
    "/l*v $Log"
)
$TwainArgs = @(
    "/x",
    "`"$ChooChoo\PSIP_TWAIN.msi`"",
    "/NoRestart",
    "/QN"
    "/l*v $Log"
)

# Remove Software Operation Panel
Write-Host "Removing $SopApp"
Start-Process -FilePath $MsiExe -ArgumentList $SopArgs -Wait -NoNewWindow

# Remove Twain Drivers
Write-Host "Removing $TwainApp"
Start-Process -FilePath $MsiExe -ArgumentList $TwainArgs -Wait -NoNewWindow

# Remove Pstream
Write-Host "Removing $PsApp"
Get-ChildItem $Regpaths | Where-Object{
    $_.GetValue('DisplayName') -match $psapp -and $_.GetValue('UninstallString') -match "msiexec*"
} | ForEach-Object {
    $MsiString = $_.GetValue('UninstallString')
    cmd /c "Start /Wait `"`" $MsiString.UninstallString $PsArgs"
}
cmd /c "Start /Wait `"`" $env:WinDir\PaperStreamCaptureUninstall.exe -q"

# Remove SOP shortcut
if (Test-Path "$StMenu\PaperStream Capture\") {
    Write-Host 'Removing shortcuts'
    Remove-Item "$StMenu\PaperStream Capture\" -Recurse -Force
}
#End Script
