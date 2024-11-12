### Removes Content Manager 9.4 and installs Content Manager 10.1


<#######################################################################################################################################
 Written by Bill Wilson 21/11/2022

 Modified by Bill 21/11/2022; Tidied $CMInstall variable
                            ; FINALLY managed to get ccmcache variable working
 Modified by Bill 22/11/2022; Added title box
 Modified by Bill 23/11/2022; Added Test-Path to check un\install
 Modified by Bill 12/11/2024; BIG tidy-up,
                            ; made the foreach work if given a .txt file of pcs
                            ; better variables names
                             
######################################################################################################################################>
function Write-TitleBox {
    param (
        [Parameter(Mandatory)]
        [String]$ScriptPath,
        [string]$ScriptName
    )
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
}

## Set Variables
###################
## Script info
$VERSION = "0.1.3"
# Show where script is stored & file name
$ScriptPath = $PSScriptRoot
$ScriptName = $MyInvocation.MyCommand.Name
$Cm     = 'Content Manager'
$Cm9    = $Cm + ' 9.4'
$Cm10   = $Cm + ' 10'

#Start
Write-TitleBox

# Asset No. Input
$PcName  = $null
$PcNames = $null
do {
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
        $PcName = "$Asset"
    } elseif ($Asset -match "*.txt") {
        $PcNames = Get-Content -Path $Asset
    } elseif ($Asset -match '^LAP') {
        $PcName = "$Asset"
    } elseif ($Asset -match '^VM') {
        $PcName = "$Asset"
    } elseif ($Asset -match '^CAF') {
        $PcName = "$Asset"
    } elseif ($Asset -match 'exit') {
        exit
    } elseif ($Asset -notmatch '^WKS') {
        $PcName = "WKS$Asset"
    } else {
        Write-Host "ERROR" -ForegroundColor Red -BackgroundColor DarkRed
    }
} until ($PcName -or $PcNames)

function Test-CM {
    ## Get data
    ###################
    # Get Install Info
    Write-Host " Removing $Cm9 from " -NoNewline
    Write-Host "$PcName...`r`n" -ForegroundColor Green
    # Find Content Manager 10 Installer Path
    # This is messy, but it works
    $Installbat = "install.bat"
    $CmMsi      = Get-ChildItem -Path "\\$PcName\c$\Windows\ccmcache" -Filter "CM_Client_x64.msi" -recurse -force -ea 0
    $CmInstall  = Join-Path -Path $CmMsi.DirectoryName -ChildPath $Installbat
    $ccmcache   = Join-Path -Path "$env:WinDir\ccmcache" -ChildPath (($CMInstall.Split("\\"))[6])
    $CmInstall  = Join-Path -Path $ccmcache -ChildPath $Installbat
    # Remove CM 9.4
    ###################
    $Cm9Dir     = Test-Path -Path "\\$PcName\c$\Program Files (x86)\Micro Focus"
    Invoke-Command -ComputerName $PcName -ScriptBlock {
        Start-Process "$env:SystemDrive\Windows\System32\msiexec.exe" `
        -ArgumentList "/x {28132A7F-9941-487C-86FA-295F88D74560} /qn" -wait
    }

    # Check CM9.4 Uninstall
    ########################
    if (-not $Cm9Dir) {
       Write-Host " " -NoNewline
       Write-Host "$Cm9 Successfully Uninstalled"  -ForegroundColor Green -BackgroundColor Black
    } else {
       Write-Host " " -NoNewline
       Write-Host "$Cm9 Uninstall Failed" -ForegroundColor Red -BackgroundColor Black
    }

    # Install CM10
    ###################
    $Cm10Dir = Test-Path -Path "\\$PcName\c$\Program Files\Micro Focus"
    Write-Host " "
    Write-Host " Installing $Cm10 to " -NoNewline
    Write-Host "$PcName...`r`n" -ForegroundColor Green
    Invoke-Command -ComputerName $PcName -ScriptBlock {
        Start-Process -FilePath $using:CMInstall -Wait -WindowStyle Hidden
    }

    # Check CM10 Install
    ######################
    if (-not $Cm10Dir) {
       Write-Host " " -NoNewline
       Write-Host "$Cm10 Install Failed"  -ForegroundColor Red -BackgroundColor Black
    } else {
       Write-Host " " -NoNewline
       Write-Host "$Cm10 Successfully Installed"  -ForegroundColor Green -BackgroundColor Black
    }
    Write-Host " "
}

if ($PcNames) {
    $PcNames.ForEach( {
        $PcName = $_
        Test-CM
    })
} else {
    Test-CM
}
