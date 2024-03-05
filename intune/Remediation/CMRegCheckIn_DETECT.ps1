<#
Content Manager 10 Check-in Registry Detection
.SYNOPSIS
Detects missing reg keys for CM10 relating to document checkin
.NOTES
Author: Bill Wilson
Ticket: INC0060570
Created: 10/07/2023
Last Edit: 11/07/2023

References:
https://learn.microsoft.com/en-us/powershell/scripting/samples/working-with-registry-entries?view=powershell-7.3#getting-a-single-registry-entry
#>

$Name = Get-ItemProperty -Path "HKCU:\SOFTWARE\Micro Focus\Content Manager\OpenDocuments" -Name *

if ($Name.ConfirmWhenProcessOpen -eq "1") {
    Write-Host "ConfirmWhenProcessOpen Confirmed"
    }
    else {
    Exit 1
    }
if ($Name.ReminderInterval -eq "0") {
    Write-Host "ReminderInterval Confirmed"
    }
    else {
    Exit 1
    }
if ($Name.RefreshInterval -eq "20")  {
    Write-Host "RefreshInterval Confirmed"
    }
    else {
    Exit 1
    }
if ($Name.MinimumDelay -eq "20") {
    Write-Host "MinimumDelay Confirmed"
    }
    else {
    Exit 1
    }
if ($Name.MinimumDelayDiscard -eq "20") {
    Write-Host "MinimumDelayDiscard Confirmed"
    }
    else {
    Exit 1
    }
if ($Name.LogFile -eq "") {
    Write-Host "LogFile Confirmed"
    }
    else {
    Exit 1
    }
Exit 0
