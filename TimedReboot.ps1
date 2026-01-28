<#Force timed reboot
    Written by Bill 28/01/2026
#>
While ($true) {
    $wshell   = New-Object -ComObject Wscript.Shell
    $Min      = 5 #Number of minutes before reboot
    $MaxHrs   = 1 #Maximum run hours
    $Lastboot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime #time of boot-up
    $Uptime   = ((Get-Date) – $Lastboot).Hours #hours since boot-up
    if ($Uptime -gt $MaxHrs) {
        $wshell.Popup("Bloop Bloop this is a message, it's been $Uptime Hours!!!",0,"OK")
        $wshell.Popup("Rebooting in $Min minutes, save what you're doing",0,"Restart")
        Restart-Computer -Delay (60 * $Min) -Wait -WhatIf
    } else {
        Write-Output "Ignore this message, it's only been $Uptime hours."
    }
    Start-Sleep -Seconds (60 * 60) #sleep for 1 hr
}
