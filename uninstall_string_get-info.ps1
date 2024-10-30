### Lists the uninstall strings software installed on the specified PC and outputs it as a CSV file

## Script info
$VERSION = "0.0.1"
# Show where script is stored & file name
$ScriptPath = $PSScriptRoot
$ScriptName = $MyInvocation.MyCommand.Name

<#
 Adapted from https://community.spiceworks.com/how_to/126700-how-to-get-the-uninstall-string-for-a-program-from-the-windows-registry-via-powershell
 Written by Bill Wilson 22/06/2022

 02/03/2023 Bill Wilson     Added WOW6432Node reg key to list
 30/10/2024 Bill Wilson     Added HKU hive
#>

Write-Host "`r`n$ScriptPath\$ScriptName" -ForegroundColor Yellow
Write-Host " Script to find Uninstall strings from Registry " -BackgroundColor DarkYellow
Write-Host " Version $VERSION " -BackgroundColor DarkYellow
Write-Host ""

## Set Variables
###################
# Name of PC
$PCName = $env:computername
# Define where output file is stored
$logdir = "c:\temp\logs"
# Name output file
$logfile  = "$PCname-uninstalls_$(get-date -format yymmdd_hhmmtt).csv"
# create log directory
if (Test-Path -Path $logdir){
    Write-Host "Logging to $logdir"
} else {
    New-Item -ItemType "directory" -Path $logdir -Force
    Write-Host "$logdir created"
}

$StdPath = 'Microsoft\Windows\CurrentVersion\Uninstall'
$RegPaths = @( "HKLM:\SOFTWARE\$StdPath",
"HKLM:\SOFTWARE\Wow6432Node\$StdPath",
"Registry::HKU\*\Software\$StdPath",
"Registry::HKU\*\Software\Wow6432Node\$StdPath"
)
## Get Uninstall Strings
$Uninst = Get-ChildItem -Path $RegPaths | Get-ItemProperty | Select-Object -Property DisplayName, Publisher, DisplayVersion, UninstallString
#$wmiproperties = Get-CimInstance -Query "SELECT ProductCode,Value FROM Win32_Property WHERE Property='UpgradeCode'"

# Set Data Table
<#$packageinfo = New-Object System.Data.Datatable
[void]$packageinfo.Columns.Add("DisplayName")
[void]$packageinfo.Columns.Add("DisplayVersion")
[void]$packageinfo.Columns.Add("Publisher")
[void]$packageinfo.Columns.Add("UninstallString")
#>

# Format Output
#$packageinfo | Sort-Object -Property DisplayName | Format-table DisplayName, DisplayVersion, Publisher, UninstallString

## Summary
#count
$installed = $Uninst.Count
Write-Host "Found $installed Uninstall Strings"

# Export info
Write-Host "Logging to $logdir"
$Uninst | Export-Csv $logdir$logfile

# Tell User where log is
if (Test-Path -Path $logdir\$logfile){
    Write-Host "Logged to " -NoNewline
    Write-Host "$logdir$logfile`r`n" -ForegroundColor Green
    }
else {
    Write-Host "Failed to write .csv file`r`n" -ForegroundColor Red
    }
# End Script
