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
 30/10/2024 Bill Wilson     Added HKU hive for user-based installs
 31/10/2024 Bill Wilson     Added User & Architecture functions
                            Changed final formatting
#>

Write-Host "`r`n$ScriptPath\$ScriptName" -ForegroundColor Yellow
Write-Host " Script to find Uninstall strings from Registry " -BackgroundColor DarkYellow
Write-Host " Version $VERSION " -BackgroundColor DarkYellow
Write-Host ""

## Set Variables
###################
$PCName = $env:computername                                             #Name of PC
$LogDir = "c:\temp\logs"                                                #where output file is stored
$LogFile  = "$PCname-uninstalls_$(get-date -format yymmdd_hhmmtt).csv"  # Name output file

$Uninst = @()   #empty array for final output
$StdPath = 'Microsoft\Windows\CurrentVersion\Uninstall' #common reg path
$RegPaths = @( "HKLM:\SOFTWARE\$StdPath",
"HKLM:\SOFTWARE\Wow6432Node\$StdPath",
"Registry::HKU\*\Software\$StdPath",
"Registry::HKU\*\Software\Wow6432Node\$StdPath"
)

# create log directory
if (Test-Path -Path $LogDir){
    Write-Host "Logging to $LogDir"
} else {
    New-Item -ItemType "directory" -Path $LogDir -Force
    Write-Host "$LogDir created"
}

# Get list of users & corresponding SIDs
$SidList = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | Get-ItemProperty | Select-Object PSChildNamename,ProfileImagePath
foreach ($Sid in $SidList) {
    if ($Sid.ProfileImagePath -like "$env:Systemdrive\Users\*") {   
        $SidUser = ((Split-Path -Path $Sid -Leaf).Replace('; username=}',''))
        $Object = @(
            [pscustomobject]@{PSChildname = $Sid.PSChildName; Username = $SidUser}
        )
        $Users += $Object
    }
}

## Get Uninstall Strings
$Apps = Get-ChildItem -Path $RegPaths -ErrorAction SilentlyContinue| Get-ItemProperty | Select-Object -Property DisplayName, Publisher, DisplayVersion, UninstallString, PSPath
foreach ($App in $Apps) {
    if (($null -ne $App.UninstallString) -or ($App.UninstallString -ne "")) {
        if ($App.PSPath -like "*\Wow6432Node\*") { #32 or 64-bit?
            $Arch = 'x86'
        } else {
            $Arch = 'x64'
        }
        #Is it a machine-wide install, or only for user?
        if ($App.PSPath -like "*HKEY_LOCAL_MACHINE\*") {
            $User = 'HKLM'
        } else {
            foreach ($Sid in $Users) {  #check SIDs against usernames
                if ($App.PSPath -like $Sid.PSChildName) {
                    $User = $Sid.UserName
                }
            }
        }
    }
    $Collation = @(                 #format for table
        [pscustomobject]@{DisplayName=$App.DisplayName; Publisher=$App.Publisher; Version=$App.DisplayVersion; Architecture=$Arch; User=$User; Uninstall=$App.UninstallString}
        )
    if ($Collation.Uninstall) {     #only gather info that's useful
        $Uninst += $Collation       #add info to final output
    }
}

## Summary
#count
$installed = $Uninst.Count
Write-Host "Found $installed Uninstall Strings"

# Export info
Write-Host "Logging to $LogDir"
$Uninst | Export-Csv (Join-Path -Path $LogDir -ChildPath $LogFile)

# Tell User where log is
if (Test-Path -Path (Join-Path -Path $LogDir -ChildPath $LogFile)) {
    Write-Host "Logged to " -NoNewline
    Write-Host "$LogDir\$LogFile`r`n" -ForegroundColor Green
} else {
    Write-Host "Failed to write .csv file`r`n" -ForegroundColor Red
}
# End Script
