

## Script info
$VERSION = "0.1.0"
# Show where script is stored & file name
$ScriptPath = $PSScriptRoot
$ScriptName = $MyInvocation.MyCommand.Name

<#
WinVer_Get.ps1

.DESCRIPTION
Shows Windows ProductName, DisplayVersion & Build No. of remote PC

.NOTES
 Adapted from https://theitbros.com/get-windows-version-using-powershell/
 Written by Bill Wilson 18/08/2023

 Modified by Bill 18/08/2023; Adjusted $PCname input
#>

# Opening Descriptive with box
Write-Host " " -NoNewline
Write-Host "`r`n Script Path: $ScriptPath\$ScriptName  " -ForegroundColor Green
Write-Host " " -NoNewline
Write-Host " I–––––––––––––––––––––––––––––––––––––––––––––––––––I " -ForegroundColor Black -BackgroundColor White
Write-Host " " -NoNewline
Write-Host " |" -NoNewline -ForegroundColor Black -BackgroundColor White
Write-Host "             Remote Powershell WinVer              " -NoNewLine -ForegroundColor DarkRed -BackgroundColor White
Write-Host "| " -ForegroundColor Black -BackgroundColor White
Write-Host " " -NoNewline
Write-Host " |    A script to fetch Windows Version & Build No.  | " -ForegroundColor Black -BackgroundColor White
Write-Host " " -NoNewline
Write-Host " |                 Version $VERSION                     | " -ForegroundColor Black -BackgroundColor White
Write-Host " " -NoNewline
Write-Host " I–––––––––––––––––––––––––––––––––––––––––––––––––––I " -ForegroundColor Black -BackgroundColor White
Write-Host ""

## Start Script
DO {
        ## Set Variables
        #################
        # Asset No. Input
        Write-Host " " -NoNewline
        Write-Host ' input target PC Name or WKS Asset No. (or' -NoNewline -ForegroundColor DarkYellow -BackgroundColor Black
        Write-Host ' EXIT' -NoNewline -ForegroundColor Yellow -BackgroundColor Black
        Write-Host ' to stop) :' -NoNewline -ForegroundColor DarkYellow -BackgroundColor Black
        Write-Host ' ' -NoNewline
        $Asset = Read-Host

        ## Set Computer Name
        ####################
        # Add prefix to asset no.
        if ($Asset -eq "") {
            Write-Host ""
            Write-Host " " -NoNewline
            Write-Host " No name or asset entered " -ForegroundColor White -BackgroundColor Red
            Write-Host ""
        }
        else {
            if ($Asset -match 'exit') {
                EXIT
            }
            elseif ($Asset -eq 'o') {
                Write-Host " " -NoNewline
                Write-Host ' OVERRIDE MODE ' -ForegroundColor Red -BackgroundColor Yellow
                Write-Host " " -NoNewline
                Write-Host ' input target PC Name :' -NoNewline -ForegroundColor DarkYellow -BackgroundColor Black
                Write-Host ' ' -NoNewline
                $PCname = Read-Host
            }
            elseif ($Asset -match '^WKS') {
                $PCname = "$Asset"
            }
            elseif ($Asset -notmatch '^WKS') {
                $PCname = "WKS$Asset"
            }
        }
            ######################
            ## Check user's credentials
            if ($env:USERNAME -notmatch '_admin') {
                $Cred = $env:USERNAME + "_admin"
            }
            else {
                $Cred = $env:USERNAME
            }
            ######################
            ## Check if PC is online
            $PCping = Test-Connection -ComputerName $PCname -Count 1 -Quiet
        
            if ($PCping -eq $true) {
                Invoke-Command -ComputerName $PCname -Credential $Cred -ScriptBlock { Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | Format-List ProductName,DisplayVersion,CurrentBuildNumber '.\NTUSER.DAT{6fdd028c-d966-11ed-b32b-005056bf8ef9}.TM.blf'}
            }
    } while ($true -eq $true)
    ## End Script
