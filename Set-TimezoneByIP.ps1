<#
.SYNOPSIS
    Create Set-TimeZoneByIP.ps1, and add a scheduled task to run it

.DESCRIPTION
    Creates a .ps1 file in C:\ProgramData that detects a wired ethernet
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

##Variables
$ScriptsDir = "$env:ProgramData\Scripts\intune-timezonebyIP-generator"   #Path to save .ps1 file to
$ps1Path = "$ScriptsDir\Set-TimeZoneByIP.ps1"                            #Path including .ps1 file
$TaskName = 'SetTimezoneByIP'                                            #Name of SchedTask
$TaskPath = '\Trael\'                                                    #SchedTask path
$TaskAuthor = 'Trael-Kun'                                                #SchedTask author

Write-Verbose -Message "Creating $ps1Path"
New-Item -Path $ScriptsDir -ItemType Directory -Force

###########################################################################################
## Create the script
###########################################################################################
Set-Content -Path "$ps1Path" -Force -Value '
#Start .ps1 content
<#
.SYNOPSIS
    Set Timezone by IP for Wired Networks

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

Function Write-Log {
    param(
        [Parameter(Mandatory=$true)][String]$msg
    )
    Add-Content "$env:ProgramData\Scripts\Logs\Set-TimeZoneByIP.log" $msg
}

###VARIABLES
$AdapterName = "Ethernet"
$DnsSuffix = "DNS.int"
$Uri = "https://ident.me/json"

##Set tzutil variables
$CurrentTz = (Get-TimeZone).Id
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
    <# Offices - hashes at the end to help identify line no.
        The AU offices are behind a firewall that does not allow Invoke-RestMethod,
        so we have to keep the script local #>
    [pscustomobject]@{Office="AU_WA";  TimeZone="$PER";   IP="10.1.*"}    #0
    [pscustomobject]@{Office="AU_NSW"; TimeZone="$AEST";  IP="10.2.*"}    #1
    [pscustomobject]@{Office="AU_TAS"; TimeZone="$TAS";   IP="10.3.*"}    #2
    [pscustomobject]@{Office="AU_NT";  TimeZone="$DAR";   IP="10.4.*"}    #3
    [pscustomobject]@{Office="AU_QLD"; TimeZone="$BRIS";  IP="10.5.*"}    #4
    [pscustomobject]@{Office="AU_ACT"; TimeZone="$AEST";  IP="10.6.*"}    #5
    [pscustomobject]@{Office="AU_VIC"; TimeZone="$AEST";  IP="10.7.*"}    #6
    [pscustomobject]@{Office="AU_SA";  TimeZone="$ADE";   IP="10.8.*"}    #7
    #The London office connects via zScaler, so we need to do something a bit different
    #but we can but the details here for uniformity
    [pscustomobject]@{Office="UK_LON"; TimeZone="$UTC";   IP="10.9.*"}    #
)

#check adapter is running
if ($(Get-NetAdapter -Physical | Where-Object status -eq "Up").name -like "$AdapterName*") { #Is it on Ethernet?
    #find local IP (v4 only)
    $IPv4 = (Get-NetAdapter -Physical -Name "$AdapterName*" | Get-NetIPAddress).IPv4Address
    #Is it on the right DNS?
    if ((Get-DnsClient | Where-Object InterfaceAlias -like "$AdapterName*").ConnectionSpecificSuffix -eq $DnsSuffix) {
        Write-Verbose -Message "Comparing $($IP.Office)"
        foreach ($IP in $IpList){
            if ($IPv4 -like $IP.IP) { #check timezone match value in array
                if ($CurrentTz -ne $IP.TimeZone) { #Is that already the timezone?
                    Write-Verbose -Message "Setting TimeZone to $($IP.TimeZone)"
                    Set-TimeZone -Name $IP.TimeZone
                    break #if found, stop
                }
                else {
                    Write-Verbose -Message "TimeZone already set to $CurrentTz"
                    exit 0
                }
            }
        }
    }
    elseif (((Invoke-RestMethod -Uri $Uri).ip) -eq $zScalIP) { #Wired connecion on zScaler? Check WAN IP
        Write-Verbose -Message "Comparing $($IpList.Office[8])"
        if ($IpList.IP[8] -like $IPv4) { #check timezone match value in array
            if ($CurrentTz -ne $IPList.TimeZone[8]) { #Is that already the timezone?
            Write-Verbose -Message "Setting TimeZone to $($IpList.TimeZone[8])"
            Set-TimeZone -Name $IpList.TimeZone[8]
            break
            }
            else {
                Write-Verbose -Message "TimeZone already set to $CurrentTz"
                exit 0
            }
        }
        else {
            Write-Verbose -Message "$Adaptername connected, but not on Corporate"
            Write-Verbose -Message "Script will not run."
            exit 0
        }
    }
    else {
        Write-Verbose -Message "Not on Corporate"
        Write-Verbose -Message "Script will not run."
        exit 0
    }
}
else {
    Write-Verbose -Message "$AdapterName not connected"
    Write-Verbose -Message "Script will not run."
    exit 0
}
#Only want to log when it has to change, otherwise the log will balloon
Write-Log -Msg "$(Get-Date) | TimeZone was $CurrentTz, now set to $((Get-TimeZone).ID)"
exit 0
#End .ps1 content
'

###########################################################################################
## Create the Sched Task
###########################################################################################
Write-Verbose -Message 'Creating Scheduled Task'

#Variables
$TaskDescription = 'Sets the timezone based on IP address when ethernet is connected to corporate network'
#set action
$TaskAction = New-ScheduledTaskAction `
    -Execute 'Powershell.exe' `
    -Argument "-NoProfile -WindowStyle Hidden -File $ps1Path"
#set settings
$TaskSettings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -Compatibility Win8 `
    -DontStopOnIdleEnd `
    -StartWhenAvailable
#set task user (Principal)
$TaskPrincipal = New-ScheduledTaskPrincipal `
    -UserId 'SYSTEM' `
    -LogonType ServiceAccount `
    -RunLevel Highest
#set trigger
    <#   The trigger was a pain to work out - to get it working 
    on startup & ALSO repeating I had to break it into 2, 
    then stick them together.
    # set inital trigger #>
    $TaskTrigger = New-ScheduledTaskTrigger `
        -AtStartup
    # set trigger repeat
    $TaskRepetition = (New-ScheduledTaskTrigger `
        -Once `
        -At (Get-Date) `
        -RepetitionInterval (New-TimeSpan -Minutes 1) `
        -RepetitionDuration (New-TimeSpan -days 9999 -hours 23 -Minutes 59 -Seconds 59)) # won't accept more days than 9999
    # glue it!
    $TaskTrigger.Repetition = $TaskRepetition.Repetition

##Register SchedTask
Register-ScheduledTask `
    -TaskName $TaskName `
    -Description $TaskDescription `
    -TaskPath $TaskPath `
    -Action $TaskAction `
    -Trigger $TaskTrigger `
    -Principal $TaskPrincipal `
    -Settings $TaskSettings
    -Force

# Add Author
$Task = Get-ScheduledTask $TaskName
$Task.Author = $TaskAuthor
$Task | Set-ScheduledTask

Start-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName
#endscript
