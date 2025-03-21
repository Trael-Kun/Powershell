#Adapted from; https://powershellisfun.com/2024/05/23/keep-microsoft-teams-status-available-instead-of-away-using-powershell/

param(
    [Parameter(Mandatory)]
    $Out     = '12:30',
    $In      = '13:00',
    $Days    = ('Monday','Friday'),
    [int32]$Sec = 60,
    [Parameter(Mandatory=$false)]
    [string]$App
)

function Send-Numlock {
    $wshell = New-Object -ComObject wscript.shell
    $wshell.sendkeys("{NUMLOCK}{NUMLOCK}")
    Write-Host ("{0}	- Pressed NUMLOCK twice and waiting for $Sec seconds" -f $(get-date)) -ForegroundColor Green
    Start-Sleep -Seconds $Sec
}

$TimeOut = (Get-Date -DisplayHint Time -Format $Out)
$TimeIn  = (Get-Date -DisplayHint Time -Format $In)

while ($true) {
    $Day = Get-Date -Format dddd
    if ($Day -in $Days) {
        if ($(Get-Date) -lt [datetime]$(Get-Date -Format $TimeOut) -or $(Get-Date) -gt [datetime]$(Get-Date -Format $TimeIn)) {
            if ($App) {
                try {
                    Get-Process -Name $App -ErrorAction stop | Out-Null
                    Write-Host ("{0}	- $App is running..." -f $(get-date)) -ForegroundColor Green
                    Send-Numlock
                } catch {
                    Write-Warning ("{0}	- $App is not running, sleeping for $($Sec / 2) seconds..." -f $(get-date))
                    Start-Sleep -Seconds ($Sec / 2)
                }
            } else {        
                Send-Numlock
            }
        } else {
            Write-Host ("{0}	- Waiting for $($Sec * 2) seconds" -f $(get-date)) -ForegroundColor DarkGreen
            Start-Sleep -Seconds ($Sec * 2)
        }
    }
}
