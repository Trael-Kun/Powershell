param (
    [switch]$LocalONLY,     #only reports on local drives
    [switch]$NetworkONLY    #only reports on network drives
)

#set empty array
$Drives = @()
#Get info on mounted drives
$Drvs = Get-PSDrive -PSProvider FileSystem | Select-Object Name,DisplayRoot,Free,Used
foreach ($Drv in $Drvs) {
    if ($LocalONLY -and $Drv.DisplayRoot -notlike "\\*") {
        #get local drive info
        $Drives += $Drv
        $DriveType = 3
    } elseif ($NetworkONLY -and $Drv.DisplayRoot -like "\\*") {
        #get network drive info
        $Drives += $Drv
        $DriveType = 4
    } else {
        #get add drive info
        $Drives += $Drv
    }
}

#get drive capacity. DriveType 3 is local, 4 is network
if ($DriveType) {
    $Max = (Get-WmiObject -Class Win32_LogicalDisk -ComputerName LOCALHOST | Where-Object {$_. DriveType -eq $DriveType} | Select-Object DeviceID, {[int]($_.Size /1GB)} | Sort-Object -Property {[int]($_.Size /1GB)})
} else {
    #get all drive capacity
    $Max = (Get-WmiObject -Class Win32_LogicalDisk -ComputerName LOCALHOST | Select-Object DeviceID, {[int]($_.Size /1GB)} | Sort-Object -Property {[int]($_.Size /1GB)})
}

#FreeSpace
$TotFree = ($Drives.Free | Measure-Object -Sum).Sum
$MinFree = ($Drives | Sort-Object -Property $_.Free)[0]
$MaxFree = ($Drives | Sort-Object -Property $_.Free -Descending)[0]
Write-Host 'Maximum Free space is '             -NoNewline
Write-Host "$([int]($MaxFree.Free  / 1GB))GB"   -NoNewline -ForegroundColor Green
Write-Host ' on drive "'                        -NoNewline
Write-Host $($MaxFree.Name)                     -NoNewline -ForegroundColor Green
Write-Host ':"'
Write-Host 'Minimum Free space is '             -NoNewline
Write-Host "$([int]($MinFree.Free / 1GB))GB"    -NoNewline -ForegroundColor Red
Write-Host ' on drive "'                        -NoNewline
Write-Host $($MinFree.Name)                     -NoNewline -ForegroundColor Red
Write-Host ':"'
Write-Host 'Total Free space is '               -NoNewline
Write-Host "$([int]($TotFree /1GB))GB"          -ForegroundColor Yellow
Write-Host ''

#UsedSpace
$TotUsed = ($Drives.Used | Measure-Object -Sum).Sum
$MinUsed = ($Drives | Sort-Object -Property $_.Used)[0]
$MaxUsed = ($Drives | Sort-Object -Property $_.Used -Descending)[0]
Write-Host 'Maximum Used space is '         -NoNewline
Write-Host "$([int]($MaxUsed.Used /1GB))GB" -NoNewline -ForegroundColor Red
Write-Host ' on drive "'                    -NoNewline
Write-Host $($MaxUsed.Name)                 -NoNewline -ForegroundColor Red
Write-Host ':"'
Write-Host 'Minimum Used space is '         -NoNewline
Write-Host "$([int]($MinUsed.Used /1GB))GB" -NoNewline -ForegroundColor Green
Write-Host ' on drive "'                    -NoNewline
Write-Host $($MinUsed.Name)                 -NoNewline -ForegroundColor Green
Write-Host ':"'
Write-Host 'Total Used space is '           -NoNewline
Write-Host "$([int]($TotUsed /1GB))GB"      -ForegroundColor Yellow
Write-Host ''

#MaxSpace

Write-Host 'Largest drive capacity is '                                     -NoNewline
Write-Host $($Max[0].'[int]($_.Size /1GB)')                                 -NoNewline -ForegroundColor Green
Write-Host 'GB on drive "'                                                  -NoNewline
Write-Host $($Max[0].DeviceID)                                              -NoNewline -ForegroundColor Green
Write-Host ':"'
Write-Host 'Total drive capacity is '                                       -NoNewline
Write-Host "$(($Max[0].'[int]($_.Size /1GB)' | Measure-Object -Sum).Sum)GB" -ForegroundColor Yellow
Write-Host ''
