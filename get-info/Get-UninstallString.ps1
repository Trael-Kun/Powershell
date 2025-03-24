<#
.SYNOPSIS
 Script to fetch uninstall strings from the registry

.DESCRIPTION
 Searches common reg hives to find uninstall strings & output them to a .csv file.
 Data gathered includes;
    - Application Name
    - Application Publisher
    - Application Version;
    - Application Architecture (x32/x64)
    - Whether the application is installed for the machine or a single user 
    - The application uninstall string

 

.NOTES
 Written by Bill Wilson 
 22/06/2022

 References;
 https://community.spiceworks.com/how_to/126700-how-to-get-the-uninstall-string-for-a-program-from-the-windows-registry-via-powershell

 CHANGELOG
 --------------------------------------------------------------
 | 02/03/2023 Bill Wilson   Added WOW6432Node reg key to list
 | 30/10/2024 Bill Wilson   Added HKU hive for user-based installs
 | 31/10/2024 Bill Wilson   Added User & Architecture functions
 |                          Changed output formatting
 | 01/11/2024 Bill Wilson   added on-screen output if no log file found
 |                          changed logging details to parameter
 |                          added header info
 |                          improved comments throughout
#>

## Script info
###################
$VERSION = "0.1.3"
# Show where script is stored & file name
$ScriptPath = $PSScriptRoot
$ScriptName = $MyInvocation.MyCommand.Name

param (
    [Parameter(HelpMessage='Full path to log file')]
    [string]$LogPath = "$env:SystemDrive\Temp\Logs\$PCname-uninstalls_$(get-date -format yymmdd_hhmmtt).csv"
)

## Header
###################
Write-Host "`r`n$ScriptPath\$ScriptName" -ForegroundColor Yellow
Write-Host " Script to find Uninstall strings from Registry " -BackgroundColor DarkYellow
Write-Host " Version $VERSION " -BackgroundColor DarkYellow
Write-Host ""

## Set Variables
###################
$PCName     = $env:computername                             #Name of PC
$LogDir     = Split-Path $LogPath -Parent                   #where output file is stored
$LogFile    = Split-Path $LogPath -Leaf                     #Name output file

$Uninst = @()                                               #empty array for final output
$StdPath = 'Microsoft\Windows\CurrentVersion\Uninstall'     #common reg path
$RegPaths = @( "HKLM:\SOFTWARE\$StdPath",                   #list of reg hives
"HKLM:\SOFTWARE\Wow6432Node\$StdPath",
"Registry::HKU\*\Software\$StdPath",
"Registry::HKU\*\Software\Wow6432Node\$StdPath"
)

## Start
###################

# create log directory
if (Test-Path -Path $LogDir){                               
    Write-Host "Logging to $LogDir"
} else {                                                    #if path doesn't exist, create it
    New-Item -ItemType Directory -Path $LogDir -Force
    Write-Host "$LogDir created"
}
# Get list of users & corresponding SIDs
$SidList = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | Get-ItemProperty | Select-Object PSChildNamename,ProfileImagePath
foreach ($Sid in $SidList) {                            
    if ($Sid.ProfileImagePath -like "$env:Systemdrive\Users\*") {   #if there is a folder in C:\Users, collate info for later use
        $SidUser = ((Split-Path -Path $Sid -Leaf).Replace('; username=}',''))
        $Object = @(
            [pscustomobject]@{PSChildname = $Sid.PSChildName; Username = $SidUser}
        )
        $Users += $Object
    }
}

# Get Uninstall Strings
$Apps = Get-ChildItem -Path $RegPaths -ErrorAction SilentlyContinue| Get-ItemProperty | Select-Object -Property DisplayName, Publisher, DisplayVersion, UninstallString, PSPath
foreach ($App in $Apps) {
    if (($null -ne $App.UninstallString) -or ($App.UninstallString -ne "")) {   #if an uninstall string exists
        if ($App.PSPath -like "*\Wow6432Node\*") {                              #32 or 64-bit?
            $Arch = 'x86'
        } else {
            $Arch = 'x64'
        }
        if ($App.PSPath -like "*HKEY_LOCAL_MACHINE\*") {                        #machine-wide install, or user-based?
            $User = 'HKLM'
        } else {                                                                #if it's a user install
            foreach ($Sid in $Users) {                                          #check SIDs against usernames
                if ($App.PSPath -like $Sid.PSChildName) {                       #get the username
                    $User = $Sid.UserName
                }
            }
        }
    }
    $Collate = @(                                                               #format for table
        [pscustomobject]@{
            DisplayName=$App.DisplayName; 
            Publisher=$App.Publisher; 
            Version=$App.DisplayVersion; 
            Architecture=$Arch; 
            User=$User; 
            Uninstall=$App.UninstallString
        }
        )
    if ($Collate.Uninstall) {                                                   #only gather info that's useful
        $Uninst += $Collate                                                     #add info to final output
    }
}

## Summary
###################

# Count
Write-Host "Found $($Uninst.Count) uninstall strings"

# Export info
Write-Host "Logging to $LogDir"
$Uninst | Export-Csv $LogPath

# Tell user where log is
if (Test-Path -Path $LogPath) {                                                 #if the log file exists, we good
    Write-Host "Logged to " -NoNewline
    Write-Host "$LogPath`r`n" -ForegroundColor Green
} else {                                                                        #if the logfile doesn't exist, not so much
    Write-Host "Failed to write $LogFile file`r`n" -ForegroundColor Red -BackgroundColor Black
    Write-Host -NoNewLine 'Press any key to display results on-screen.';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    $Uninst
}
## End
###################
