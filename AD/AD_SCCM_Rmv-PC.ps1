<#####################################################################################################################################
### Name:        Remove-Comp_AD_SCCM.ps1                                                                                          ###
### Author:      Callan Halls-Palmer                                                                                              ###
### Version:     1.0                                                                                                              ###
### Description: This script will take input parameters which will then delete the specified computers from AD and SCCM. The      ###
###              SendTo parameter specifies which email address the alert will be sent to.                                        ###
###                                                                                                                               ###
### Example:     Remove-Comp_AD_SCCM.ps1 -Computers "LONCOMP01","LONCOMP02" -SendTo "ITAdministrators@contoso.com                 ###
#####################################################################################################################################
 Date         Engineer        Notes
 ---------------------------------------------------------------------------------------------------------------------------------
 11/11/2022   Bill            Added company-Specific variables
                              Removed emailing function
                              Removed "$Computers" list functions
                              Added Logging
                              
#####################################################################################################################################>
# Set Parameters #
Param(
  [Parameter(Mandatory=$true)]
  [string[]]$Computers,
#  [string]$SendTo
)
# Set Date in variable #
$Date = Get-Date -Format dd-MM-yyyy
# Set SMTP Server in variable #
#$SMTP = "0.0.0.0"
# Set Logging
$logdir = "\\FileShare\LOGS\AD_Rmv"
$logfile = "$env:COMPUTERNAME-$Date.csv"

## Active Directory Section
# Set Current $ErrorActionPreference so that it can be put back to normal #
$old_ErrorActionPreference = $ErrorActionPreference
# Set $ErrorActionPreference to SilentlyContinue to bypass Get-ADComputer Errors #
$ErrorActionPreference = "SilentlyContinue"
# Check for each PC in AD, Delete if there #
$Computer = $env:COMPUTERNAME
#foreach ($Computer in $Computers){
    if (@(Get-ADComputer $Computer -ErrorAction SilentlyContinue).Count) {
        $ADCOMPLOG = Get-ADComputer $Computer
        Export-Csv $logdir\$logfile
        Write-Host "$Computer is in AD, Delete"
        Get-ADComputer $Computer | Remove-ADComputer -Confirm:$false -ErrorAction SilentlyContinue  
        }
    else{
        Write-Host "$Computer isn't in AD" 
        }
#}
## SCCM Section
# Set Site Server and Site Name #
$SCCMServer = "SCCM01" 
$sitename = "S01"
# Delete PC from SCCM #
#ForEach ($Computer in $Computers){
    $comp = Get-WmiObject -ComputerName $SCCMServer -Namespace root\sms\site_$($sitename) -class sms_r_system -filter "Name='$($Computer)'"
    # Output 
    Write-Host -ForegroundColor Green "$Computer with resourceID $($comp.ResourceID) will be deleted from SCCM" 
    # Delete the computer account 
    $comp.delete()
#}
# Set Original $ErrorActionPreference back to normal #
$ErrorActionPreference = $old_ErrorActionPreference
# Build Email #
<#
$PCNames = $Computers | Format-List | Out-String
$Body ="
To Administrator,
The following PC's have been deleted from AD & SCCM:
 
$PCNames
     
PLEASE DO NOT REPLY TO THIS EMAIL.
    
Regards,
CC Engineering"
# Send E-Mail to the relevant team confirming the VM's that have been built 
Send-MailMessage -From CCReporting@contoso.com -To $SendTo -Subject "PC's deleted on $Date" -Body $body -SmtpServer $SMTP
#>
# End Script
