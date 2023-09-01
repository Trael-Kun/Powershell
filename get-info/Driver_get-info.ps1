# Lists the software installed on the specified PC and outputs it as a CSV file
## Script info
$VERSION = "0.2.1"
# Show where script is stored & file name
$ScriptPath = $PSScriptRoot
$ScriptName = $MyInvocation.MyCommand.Name

<# Adapted from https://www.codetwo.com/admins-blog/how-to-check-installed-software-version/
              https://social.technet.microsoft.com/Forums/en-US/5348ee33-ebd8-4036-9086-b2208ec4ceba/driver-query?forum=configmanagergeneral
 Adapted by Bill 09/09/2021

 Modified by Bill 10/09/2021; Added coloration to write-host
 Modified by Bill 13/09/2021; Added file check at end of script
                            ; Added counter
 Modified by Bill 22/10/2021; Adapted Software Query to Driver
 Modified by Bill 22/10/2021; Added opening descriptive
                            ; Added $VERSION
 Modified by Bill 14/11/2021; Added colouration to $installed display in Summary
 Modified by Bill 23/06/2022; Added further fields to search results
###############################################################################>

Write-Host "`r`n$ScriptPath\$ScriptName" -ForegroundColor Yellow
Write-Host " Script to fetch driver versions " -BackgroundColor Gray
Write-Host " Version $VERSION " -BackgroundColor Gray
Write-Host ""


## Set Variables
###############
# Asset No. Input
    Write-Host ' input target PC Name or WKS Asset No. ' -NoNewline -ForegroundColor Yellow -BackgroundColor DarkRed
    Write-Host ':' -NoNewline
    $Asset = Read-Host
## Set Computer Name
###################
# Add prefix to asset no.
if ($Asset -match '^WKS') {
    $PCname = "$Asset"
    }
elseif ($Asset -notmatch '^WKS') {
    $PCname = "WKS$Asset"
    }
# Define where output file is stored
$logdir = "c:\temp\logs\"
# Name output file
$logfile  = "$PCname-Installed-Drivers_$(get-date -format yymmdd_hhmmtt).csv"

# create log directory
if (Test-Path -Path $logdir){
    Write-Host "Logging to $logdir" -ForegroundColor Green
    }
else {
    New-Item -ItemType "directory" -Path $logdir -Force
    Write-Host "$logdir created"
    Write-Host "Logging to $logdir" -ForegroundColor Green
    }

## Get Data
###########
# Get Install Info
Write-Host "Getting Installed drivers for $PCname"

$wmipackages = Get-WMIObject -Class win32_PnPSignedDriver -ComputerName $PCname | select DeviceName,DriverVersion,FriendlyName,DeviceID,Description,DriverProviderName,DeviceClass,CompatID,DriverName,InfName

# Count installed
$installed = $wmipackages.count

# Show Results
$wmipackages | Sort-Object -Property DeviceName | Format-table DeviceName,DriverVersion,FriendlyName,DeviceID,Description,DriverProviderName,DeviceClass,CompatID,DriverName,InfName

# Write to log
$wmipackages | Export-Csv -Path "$logdir$logfile"

## Summary
# Count No. of drivers
Write-Host "Found " -NoNewline
Write-Host "$installed" -NoNewline -ForegroundColor Red
Write-Host " installed devices"

# Get PC Model
$cs = Get-WmiObject -ClassName Win32_ComputerSystem -ComputerName $PCname
$PCmodel = $cs.Model
Write-Host "PC Model: $PCmodel"

# Tell User where log is
if (Test-Path -Path $logdir){
    Write-Host "Logged to " -NoNewline
    Write-Host "$logdir$logfile" -ForegroundColor Green
    }
else {
    Write-Host "Failed to write .csv file" -ForegroundColor Yellow
    }
# end script
