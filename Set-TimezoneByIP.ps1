<#
.SYNOPSIS
    Create Set-TimeZoneByIP.ps1, and add a scheduled task to run it

.DESCRIPTION
    Creates a .ps1 file in C:\ProgrmData that detects a wired ethernet
    connection, then checks for IP address on that connector. The IP is
    compared to ther values in an array to set the timezone accordingly.
    The script then sets a scheduled task to run the .ps1 file.

.NOTES
    Author:     Bill Wilson (https://github.com/Trael-Kun)
    Created:    22/05/2024

References;
    https://devblogs.microsoft.com/scripting/using-powershell-to-find-connected-network-adapters/
    https://learn.microsoft.com/en-us/powershell/module/nettcpip/get-netipaddress
    https://www.reddit.com/r/PowerShell/comments/da6bwg/if_statement_iteration_with_arrays/
    https://stackoverflow.com/questions/20108886/powershell-scheduled-task-with-daily-trigger-and-repetition-interval
#>

#Path to save the .ps1 file to
$ps1Dir = "$env:ProgramData\intune-timezonebyIP-generator"
$ps1Path = "$ps1Dir\Set-TimeZoneByIP.ps1"
New-Item -Path $ps1Dir -ItemType Directory -Force
Set-Content -Path "$ps1Path" -Force -Value '
#Start .ps1 content
<#
.SYNOPSIS
    Set Timezone by IP for NAA Wired Networks

.DESCRIPTION
    Checks for a wired ethernet connection, then checks for IP address 
    on that connector. The IP is compared to the values in an array to 
    set the timezone accordingly.
    
.NOTES
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date: 26/04/2024

References:
    https://devblogs.microsoft.com/scripting/using-powershell-to-find-connected-network-adapters/
    https://learn.microsoft.com/en-us/powershell/module/nettcpip/get-netipaddress
    https://www.reddit.com/r/PowerShell/comments/da6bwg/if_statement_iteration_with_arrays/
#>

###VARIABLES
$AdapterName = "Ethernet"

##Set tzutil variables
$AEST = "AUS Eastern Standard Time"
$TAS = "Tasmania Standard Time"
$DAR = "AUS Central Standard Time"
$ADE = "Cen. Australia Standard Time"
$PER = "W. Australia Standard Time"
$BRIS = "E. Australia Standard Time"
$UTC = "UTC"

##Set WAN IP variables
# zScaler IP
$zScalIP = 200.1.1.1
# Ethernet IP
$EtherIP = 101.1.1.10

##Set LAN IP variables
$IpList = @(
    [pscustomobject]@{Office="AU_WA";  TimeZone="$PER";   IP="10.1.*"}
    [pscustomobject]@{Office="AU_NSW"; TimeZone="$AEST";  IP="10.2.*"}
    [pscustomobject]@{Office="AU_TAS"; TimeZone="$TAS";   IP="10.3.*"}
    [pscustomobject]@{Office="AU_NT";  TimeZone="$DAR";   IP="10.4.*"}
    [pscustomobject]@{Office="AU_QLD"; TimeZone="$BRIS";  IP="10.5.*"}
    [pscustomobject]@{Office="AU_ACT"; TimeZone="$AEST";  IP="10.6.*"}
    [pscustomobject]@{Office="AU_VIC"; TimeZone="$AEST";  IP="10.7.*"}
    [pscustomobject]@{Office="AU_SA";  TimeZone="$ADE";   IP="10.8.*"}
    [pscustomobject]@{Office="UK_LON"; TimeZone="$UTC";   IP="10.9.*"}
)

#check adapter is running
if ($(Get-NetAdapter -Physical | Where-Object status -eq "Up").name -like "$AdapterName*") {
    #find web IP
    if (((Invoke-WebRequest -uri "http://ifconfig.me/ip").Content) -eq $EtherIP) {
        #Local IP
        $IPv4 = (Get-NetAdapter -Physical -Name "$AdapterName*" | Get-NetIPAddress).IPv4Address
        foreach ($IP in $IpList){
            if ($IPv4 -like $IP.IP) {
                Set-TimeZone -Name $IP.TimeZone
                break
            }
        }
    }
}
#End .ps1 content
'

##SchedTask
#SchedTask Variables
$Action = New-ScheduledTaskAction `
    -Execute 'Powershell.exe' `
    -Argument "-NoProfile -WindowStyle Hidden -File $ps1Path"
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries
$Principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest
<#The trigger was a pain to work out - to get it working 
on startup & ALSO repeating I had to break it into 2, 
then stick them together.#>
#Set the initial trigger
$Trigger = New-ScheduledTaskTrigger `
    -AtStartup
#set the repeat
$Repetition = (New-ScheduledTaskTrigger `
    -once `
    -at (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes 1) )
#Glue it!
$Trigger.Repetition = $Repetition.Repetition

#Create SchedTask
Register-ScheduledTask `
    -Action $Action `
    -Trigger $Trigger `
    -TaskName "SetTimezoneByIP" `
    -Description "Sets the timezone based on IP address when LAN is connected" `
    -Principal $principal `
    -Settings $settings

#endscript
