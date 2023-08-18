<# Get Dirsize
A script to get the size of a folder in Gb
Adapted from https://community.spiceworks.com/topic/2223014-getting-folder-sizes-on-remote-computers
 Written by Bill Wilson 27/01/2023

 Modified by Bill 05/08/2021; Typo correction
#>
#Script Info
$ScriptVer = "0.1.0"
# Show where script is stored & file name
$ScriptPath = $PSScriptRoot
$ScriptName = $MyInvocation.MyCommand.Name
# Log file path
$LogFile = 'C:\temp\logs\folder_size.csv'
# TitleBox
Write-Host ' ' -NoNewline
Write-Host "`r`n Script Path: $ScriptPath\$ScriptName  " -ForegroundColor Green
Write-Host ' ' -NoNewline
Write-Host ' I----------------------------------------------------I ' -ForegroundColor Black -BackgroundColor White
Write-Host ' ' -NoNewline
Write-Host ' |' -NoNewline -ForegroundColor Black -BackgroundColor White
Write-Host '                 Get Dir Size                      ' -NoNewLine -ForegroundColor DarkRed -BackgroundColor White
Write-Host '| ' -ForegroundColor Black -BackgroundColor White
Write-Host ' ' -NoNewline
Write-Host ' |         A script to measure directory size         | ' -ForegroundColor Black -BackgroundColor White
Write-Host ' ' -NoNewline
Write-Host " |                  Version $ScriptVer                     | " -ForegroundColor Black -BackgroundColor White
Write-Host ' ' -NoNewline
Write-Host ' I----------------------------------------------------I ' -ForegroundColor Black -BackgroundColor White
Write-Host ' '

#StartScript

DO {
    # Enter directory to measure
    Write-Host ' Enter target directory:' -NoNewline
    Write-Host ' '
    $TargetFolder = Read-Host 

    # Measure Directory in Gb
    #$DirSize = (Get-ChildItem "$TargetFolder" -recurse | Measure-Object -Property Length -sum).sum /1Gb
    #Write-Host "$DirSize"

    $dataColl = @()
    Get-ChildItem -force $targetfolder -ErrorAction SilentlyContinue | ? { $_ -is [io.directoryinfo] } | % {
    $len = 0
    Get-ChildItem -recurse -force $_.fullname -ErrorAction SilentlyContinue | % { $len += $_.length }
    $foldername = $_.fullname
    $foldersizeGb= '{0:N2}' -f ($len / 1Gb)
    $foldersizeMb= '{0:N2}' -f ($len / 1Mb)
    $dataObject = New-Object PSObject
    Add-Member -inputObject $dataObject -memberType NoteProperty -name 'folderName' -value $foldername
    Add-Member -inputObject $dataObject -memberType NoteProperty -name 'folderSizeGb' -value $foldersizeGb
    Add-Member -inputObject $dataObject -memberType NoteProperty -name 'folderSizeMb' -value $foldersizeMb
    Add-Member -inputObject $dataObject -memberType NoteProperty -name 'folderSizeB' -value $len
    Add-Member -inputObject $dataObject -memberType NoteProperty -name 'BytesPerGig' -value '1073741824'
    $dataColl += $dataObject
    }
    $dataColl | Out-GridView -Title 'Size of Subdirectories'
    
    $LogTest = Test-Path $Logfile
    if (-not $LogTest){
        $dataColl | Export-CSV -Path "$LogFile"
        }
    else {
        $dataColl | Add-Content -Path "$LogFile"
    }
} while ($true -eq $true)

#EndScript
