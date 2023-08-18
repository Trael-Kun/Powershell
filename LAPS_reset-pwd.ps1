<####################################################
Name:          Reset_LAPS_Pwd.ps1
Author:        Bill Wilson
Creation Date: 11/11/2022
Description:  Resets LAPS Password on Remote PC
####################################################
 Edit Log
 Name          Date          Notes
---------------------------------------------------
 Bill          11/11/2022    Typo Correction
                             Changed Title Bar colours for better visibility
                             Tidied Formatting
####################################################>

## Script info
# Show where script is stored & file name
$ScriptPath = $PSScriptRoot
$ScriptName = $MyInvocation.MyCommand.Name
$VERSION = "0.1.0"

#StartScript

## Start Title Bar
Write-Host "  " -NoNewline
Write-Host "`r`n Script Path: $ScriptPath\$ScriptName  " -ForegroundColor Green -BackgroundColor Black
Write-Host ""
Write-Host "  " -NoNewline
Write-Host "                                   " -BackgroundColor Yellow
Write-Host "  " -NoNewline
Write-Host "        Reset LAPS Password        " -ForegroundColor DarkRed -BackgroundColor Yellow
Write-Host "  " -NoNewline
Write-Host "                                   " -BackgroundColor Yellow
Write-Host "  " -NoNewline
Write-Host "                                   " -BackgroundColor DarkGreen
Write-Host "  " -NoNewline
Write-Host "   A script to force reset LAPS    " -ForegroundColor Yellow -BackgroundColor DarkGreen
Write-Host "  " -NoNewline
Write-Host "          Version $VERSION            " -ForegroundColor Yellow -BackgroundColor DarkGreen
Write-Host "  " -NoNewline
Write-Host "                                   " -BackgroundColor DarkGreen
Write-Host ""
## End Title Bar

## Set Variables
################
# Asset No. Input
    Write-Host "  " -NoNewline
    Write-Host 'input target PC Name or WKS Asset No. (or' -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
    Write-Host ' EXIT' -NoNewline -ForegroundColor Red -BackgroundColor DarkYellow
    Write-Host ' to stop):' -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
    Write-Host ' ' -NoNewline
    $Asset = Read-Host

## Set Remote Computer
####################
# Add prefix to asset no.
    if ($Asset -match '^WKS') {
        $PCname = "$Asset"
        }
    elseif ($Asset -match 'exit') {
        exit
        }
    elseif ($Asset -notmatch '^WKS') {
        $PCname = "WKS$Asset"
        }

## Retreive old Admin Password
$OldPass = Get-AdmPwdPassword $PCname
$OldPass
## Reset the Admin Password
$ResetPwd = Reset-AdmPwdPassword $PCname
$ResetPwd

## GP Sync to push the new password
Write-Host ""
Invoke-GPUpdate -Computer $PCname -RandomDelayInMinutes 0
Start-Sleep -Seconds 5
## Wait for GP Update to finish
Write-Host "Waiting for Group Policy Update..."
Start-Sleep -Seconds 45
Write-Host ""

## Retreive new LAPS password
$NewPass = Get-AdmPwdPassword $PCname

    if ($OldPass -ne $NewPass) {
        $Password = $NewPass.Password
        Write-Host 'Password Change successful' -ForegroundColor Green
        Write-Host ""
        Write-Host 'New LAPS Password: ' -NoNewline
        Write-Host "$Password" -ForegroundColor Green -BackgroundColor Black
        Write-Host ""
        }
    elseif ($OldPass -eq $NewPass) {
        Write-Host 'Password Change unsuccessful' -ForegroundColor Red
        }
#EndScript
