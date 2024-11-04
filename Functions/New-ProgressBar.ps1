function New-ProgressBar {
  param (
    [Parameter(Mandatory=$true)]
    [int]$Seconds,     # number of seconds to run script
    [Parameter(Mandatory=$false)]
    [switch]$CountDown
  )     
    function Write-Time {
      Write-Host "$('{0:d2}' -f +$sec) Seconds"
    }
  if ($CountDown) {
    $Sec    = $Seconds  # set initial countdown
    $EndSec = $Seconds  # Set end result
    do {
      Write-Progress -Activity Waiting -Status Loitering -PercentComplete (($Sec / $EndSec) * 100)
      Write-Time "$Sec Seconds"
      $sec--
      Start-Sleep 1
    } until ($Sec -lt 0)
  } else {
    $Sec    = 0         # set initial countdown
    $EndSec = $Seconds  # Set end result
    do {
      Write-Progress -Activity Waiting -Status Loitering -PercentComplete (($Sec / $EndSec) * 100)
      Write-Time "$('{0:d2}' -f +$sec) Seconds"
      $sec++
      Start-Sleep 1
    } until ($Sec -gt $EndSec)
  }
}
