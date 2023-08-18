### Lists the members of the specified Active Directory group and outputs it as a CSV file

## Script info
$VERSION = "0.0.1"
# Show where script is stored & file name
$ScriptPath = $PSScriptRoot
$ScriptName = $MyInvocation.MyCommand.Name

##########################################################################
# Adapted from https://activedirectorypro.com/powershell-export-active-directory-group-members/
# Written by Bill Wilson 02/12/2021

##########################################################################

Write-Host "`r`n$ScriptPath\$ScriptName" -ForegroundColor Yellow
Write-Host " Script to fetch members of Active Directory groups " -BackgroundColor Blue
Write-Host " Version $VERSION " -BackgroundColor Blue
Write-Host ""

# Set Variables
$ADGroup = Read-Host -Prompt "Enter AD group Name"
$LogDir = "C:\Temp\Logs\"
$LogFile = "$ADGROUP_$(get-date -format yymmdd_hhmmtt).csv"

$MemberList = Get-ADGroupmember -identity $ADGroup | select name,SamAccountName,objectClass 
$MemberList | Sort-Object -Property Name | Format-table name, SamAccountName, objectClass

$MemberList | Export-csv -path c:\temp\logs\$ADGROUP_$(get-date -format yymmdd_hhmmtt).csv -Notypeinformation

# Tell User where log is
    if (Test-Path -Path $logdir){
        Write-Host "Logged to " -NoNewline
        Write-Host "$logdir$logfile`r`n" -ForegroundColor Green
        }
    else {
        Write-Host "Failed to write .csv file`r`n" -ForegroundColor Red
        }
