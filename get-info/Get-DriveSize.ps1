param (
    [switch]$LocalONLY,
    [switch]$NetworkONLY
)

$Drvs = Get-PSDrive -PSProvider FileSystem | Select-Object Name,DisplayRoot,Free,Used
$Drives = @()
foreach ($Drv in $Drvs) {
    if ($LocalONLY -and $Drv.DisplayRoot -notlike "\\*") {
        $Drives += $Drv
        $DriveType = 3
    } elseif ($NetworkONLY -and $Drv.DisplayRoot -like "\\*") {
        $Drives += $Drv
        $DriveType = 4
    } else {
       $Drives += $Drv
    }
}

if ($DriveType) {
    $Max = (Get-WmiObject -Class Win32_LogicalDisk -ComputerName LOCALHOST | Where-Object {$_. DriveType -eq 3} | Select-Object DeviceID, {[int]($_.Size /1GB)} | Sort-Object -Property {[int]($_.Size /1GB)})[0]
} else {
    $Max = (Get-WmiObject -Class Win32_LogicalDisk -ComputerName LOCALHOST | Select-Object DeviceID, {[int]($_.Size /1GB)} | Sort-Object -Property {[int]($_.Size /1GB)})[0]
}

#FreeSpace
$TotFree = ($Drives.Free | Measure-Object -Sum).Sum
$MinFree = ($Drives | Sort-Object -Property $_.Free)[0]
$MaxFree = ($Drives | Sort-Object -Property $_.Free -Descending)[0]
Write-Host 'Maximum Free space is '         -NoNewline
Write-Host "$([int]($MaxFree.Free  / 1GB))" -NoNewline -ForegroundColor Green
Write-Host 'GB on drive "'                  -NoNewline
Write-Host $($MaxFree.Name)                 -NoNewline -ForegroundColor Green
Write-Host ':"'
Write-Host 'Minimum Free space is '         -NoNewline
Write-Host $([int]($MinFree.Free / 1GB))    -NoNewline -ForegroundColor Red
Write-Host 'GB on drive "'                  -NoNewline
Write-Host $($MinFree.Name)                 -NoNewline -ForegroundColor Red
Write-Host ':"'
Write-Host 'Total Free space is '           -NoNewline
Write-Host $([int]($TotFree /1GB))          -NoNewline -ForegroundColor Yellow
Write-Host 'GB'
Write-Host ''

#UsedSpace
$TotUsed = ($Drives.Used | Measure-Object -Sum).Sum
$MinUsed = ($Drives | Sort-Object -Property $_.Used)[0]
$MaxUsed = ($Drives | Sort-Object -Property $_.Used -Descending)[0]
Write-Host 'Maximum Used space is '     -NoNewline
Write-Host $([int]($MaxUsed.Used /1GB)) -NoNewline -ForegroundColor Red
Write-Host 'GB on drive "'              -NoNewline
Write-Host $($MaxUsed)                  -NoNewline -ForegroundColor Red
Write-Host ':"'                         -NoNewline
Write-Host 'Minimum Used space is '     -NoNewline
Write-Host $([int]($MinUsed.Used /1GB)) -NoNewline -ForegroundColor Green
Write-Host 'GB on drive "'              -NoNewline
Write-Host $($MinUsed)                  -NoNewline -ForegroundColor Green
Write-Host ':"'                         -NoNewline
Write-Host 'Total Used space is '       -NoNewline
Write-Host $([int]($TotUsed /1GB))      -NoNewline -ForegroundColor Yellow
Write-Host 'GB'
Write-Host ''                       

#MaxSpace

Write-Host 'Largest drive is '              -NoNewline
Write-Host $($Max.'[int]($_.Size /1GB)')    -NoNewline -ForegroundColor Green
Write-Host 'GB on drive "'                  -NoNewline
Write-Host $($Max.DeviceID)                 -NoNewline -ForegroundColor Green
Write-Host ':"'
Write-Host ''
