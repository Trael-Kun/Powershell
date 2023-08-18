### Removes Content Manager 9.4 and installs Content Manager 10.1

## Script info
$VERSION = "0.1.3"
# Show where script is stored & file name
$ScriptPath = $PSScriptRoot
$ScriptName = $MyInvocation.MyCommand.Name

$TxtFile = '\\fileshare\CM9.4.txt'

<#######################################################################################################################################
 Written by Bill Wilson 21/11/2022

 Modified by Bill 21/11/2022; Tidied $CMInstall variable
                            ; FINALLY managed to get ccmcache variable working
 Modified by Bill 22/11/2022; Added title box
 Modified by Bill 23/11/2022; Added Test-Path to check un\install
######################################################################################################################################>

Write-Host " "
Write-Host " " -NoNewline
Write-Host "`r`n Script Path: $ScriptPath\$ScriptName  " -ForegroundColor Green
Write-Host " "
Write-Host " " -NoNewline
Write-Host "                                               " -BackgroundColor Black
Write-Host " " -NoNewline
Write-Host "               CM10 Quickfix                   " -ForegroundColor Red -BackgroundColor Black
Write-Host " " -NoNewline
Write-Host "               Version $VERSION                   " -ForegroundColor White -BackgroundColor Black
Write-Host " " -NoNewline
Write-Host "                                               " -BackgroundColor Black
Write-Host ""

## Set Variables
###################
# Asset No. Input
Write-Host " " -NoNewline
Write-Host 'input target PC Name or WKS Asset No. (or' -NoNewline -ForegroundColor DarkYellow -BackgroundColor DarkBlue
Write-Host ' EXIT' -NoNewline -ForegroundColor Yellow -BackgroundColor DarkBlue
Write-Host ' to stop) :' -NoNewline -ForegroundColor DarkYellow -BackgroundColor DarkBlue
Write-Host ' ' -NoNewline
$Asset = Read-Host
## Set Computer Name
#####################
    # Add prefix to asset no.
    if ($Asset -match '^WKS') {
        $PCname = "$Asset"
        }
    elseif ($Asset -eq $TxtFile) {
        $PCnames = Get-Content -Path $Asset
        }
    elseif ($Asset -match '^LAP') {
        $PCname = "$Asset"
        }
    elseif ($Asset -match '^VM') {
        $PCname = "$Asset"
        }
    elseif ($Asset -match '^CAF') {
        $PCname = "$Asset"
        }
    elseif ($Asset -match 'exit') {
        exit
        }
    elseif ($Asset -notmatch '^WKS') {
        $PCname = "WKS$Asset"
        }
    else {
        Write-Host "ERROR" -ForegroundColor Red -BackgroundColor DarkRed
        }
#$PCnames.ForEach( {
#$PCname = $_

    ## Get data
    ###################
    # Get Install Info
    Write-Host " Removing CM9.4 from " -NoNewline
    Write-Host "$PCname...`r`n" -ForegroundColor Green
    # Find Content Manager 10 Installer Path
    # This is messy, but it works
    $Installbat = "install.bat"
    $CM10 = Get-ChildItem "\\$PCname\c$\Windows\ccmcache" "CM_Client_x64.msi" -recurse -force -ea 0
    $CMInstall = Join-Path -Path $CM10.DirectoryName -ChildPath $Installbat
    $CM11 = $CMInstall.Split("\\")
    $CM10 = $CM11[6]
    $ccmcache = Join-Path -Path "C:\Windows\ccmcache" -ChildPath $CM10
    $CMInstall = Join-Path -Path $ccmcache -ChildPath $Installbat
    # Remove CM 9.4
    ###################
    $CM9Dir1 = Test-Path -Path "\\$PCname\c$\Program Files (x86)\Micro Focus"
    Invoke-Command -ComputerName $PCname -ScriptBlock {
    Start-Process "C:\Windows\System32\msiexec.exe" `
    -ArgumentList "/x {28132A7F-9941-487C-86FA-295F88D74560} /qn" -wait
    }
    # Check CM9.4 Uninstall
    ########################
    if (-not $CM9Dir) {
       Write-Host " " -NoNewline
       Write-Host "Content Manager 9.4 Successfully Uninstalled"  -ForegroundColor Green -BackgroundColor Black
       }
    else {
       Write-Host " " -NoNewline
       Write-Host "Content Manager 9.4 Uninstall Failed" -ForegroundColor Red -BackgroundColor Black
       }
    # Install CM10
    ###################
    $CM10Dir = Test-Path -Path "\\$PCname\c$\Program Files\Micro Focus"
    Write-Host " "
    Write-Host " Installing CM10 to " -NoNewline
    Write-Host "$PCname...`r`n" -ForegroundColor Green
    Invoke-Command -ComputerName $PCname -ScriptBlock {
    Start-Process -FilePath $using:CMInstall -Wait -WindowStyle Hidden
    }
    # Check CM10 Install
    ######################
    if (-not $CM10Dir) {
       Write-Host " " -NoNewline
       Write-Host "Content Manager 10 Install Failed"  -ForegroundColor Red -BackgroundColor Black
       }
    else {
       Write-Host " " -NoNewline
       Write-Host "Content Manager 10 Successfully Installed"  -ForegroundColor Green -BackgroundColor Black
       }
    Write-Host " "
#    })
