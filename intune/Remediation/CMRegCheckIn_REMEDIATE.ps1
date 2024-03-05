<#
Content Manager 10 Check-in Registry Remediation
.SYNOPSIS
Adds missing reg keys for CM10 relating to document checkin
.NOTES
Author: Bill Wilson
Ticket: INC0060570
Created: 10/07/2023
Last Edit: 11/07/2023

References:
https://learn.microsoft.com/en-us/powershell/scripting/samples/working-with-registry-entries?view=powershell-7.3#creating-new-registry-entries
#>

# Create Entries
New-Item -Path "HKCU:\SOFTWARE\Micro Focus\Content Manager\OpenDocuments"
New-ItemProperty -Path "HKCU:\SOFTWARE\Micro Focus\Content Manager\OpenDocuments" -Name ConfirmWhenProcessOpen -PropertyType DWord -Value 1
New-ItemProperty -Path "HKCU:\SOFTWARE\Micro Focus\Content Manager\OpenDocuments" -Name ReminderInterval -PropertyType DWord -Value 0
New-ItemProperty -Path "HKCU:\SOFTWARE\Micro Focus\Content Manager\OpenDocuments" -Name RefreshInterval -PropertyType DWord -Value 20
New-ItemProperty -Path "HKCU:\SOFTWARE\Micro Focus\Content Manager\OpenDocuments" -Name MinimumDelay -PropertyType DWord -Value 20
New-ItemProperty -Path "HKCU:\SOFTWARE\Micro Focus\Content Manager\OpenDocuments" -Name MinimumDelayDiscard -PropertyType DWord -Value 20
New-ItemProperty -Path "HKCU:\SOFTWARE\Micro Focus\Content Manager\OpenDocuments" -Name LogFile -PropertyType String -Value ""
