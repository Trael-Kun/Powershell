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

param (
    [switch] $Log
)

function Write-Log {
    param (
        [string] $Msg
    )
    Write-Output "$Msg"
    if ($Log) {
        Add-Content -Path $LogFile -Value "$(Get-Date) |    $Msg"
        Start-Sleep -Seconds 1
    }
}

##Variables
$MainDir =                          "$env:ProgramData\Scripts"                                  #Primary scripts dir
$LogFile =                          "$MainDir\Logs\ScriptDebug.log"                             #Debog log for sched script
$ScriptsDir =                       "$MainDir\intune-timezonebyIP-generator"                    #Path to save the .ps1 file to
$ps1Path =                          "$ScriptsDir\Set-TimeZoneByIP.ps1"                          #the .ps1 path
$TaskName =                         'SetTimezoneByIP'                                           #name of the sched task
$TaskPath =                         '\Pwsh\'                                                    #path for sched task
$TaskAuthor =                       'Bill'                                                      #author of sched task

#Has this already run? 
if (Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction SilentlyContinue) {
    if (Test-Path -Path $ps1Path) {
        Write-Log -Msg "Scheduled task already exists. Skipping creation."
        Start-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName
        exit 0
    }
}

##Start Script
Write-Log -Msg "Creating $ps1Path"
New-Item -Path $ScriptsDir -ItemType Directory -Force

###########################################################################################
## Create the .ps1
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
param (
    [switch] $Log
)

$TzLogFile = "$env:ProgramData\Scripts\Logs\Set-TimeZoneByIP.log"
Function Write-TzLog {
    param(
        [Parameter(Mandatory=$true)][String]$Msg
    )
    if (((Get-Date).AddDays(-30)) -gt ($TzLogFile).LastWriteTime) { #if log older than 30 days, wipe it to save disk space
        Remove-Item $TzLogFile -Force
    }
    elseif ($TzLogFile.Length -gt 1gb) {                            #if log bigger than 1gb, wipe it to save disk space
        Remove-Item $TzLogFile -Force
    }
    Add-Content $TzLogFile $Msg -Force
}

$LogFile = "$env:ProgramData\Scripts\Logs\ScriptDebug.log"
function Write-Log {
    param (
        [string] $Msg
    )
    Write-Output "$Msg"
    if ($Log) {
        Add-Content -Path $LogFile -Value "$(Get-Date) |    $Msg"
        Start-Sleep -Seconds 1
    }
}

###VARIABLES
$AdapterName =  "Ethernet"                     #Name of the adapter to check against
$DnsSuffix =    "network.int"                  #DNS suffix to check against
$Uri =          "https://ident.me/json"        #URI for external IP check
$zScalIP =      "200.0.0.2"                    #WAN public IP
#$EtherIP =     "100.0.0.1"                    #Other WAN IP

##Set tzutil variables
$CurrentTz =    (Get-TimeZone).Id               #Grab the current timezone
$AEST =         "AUS Eastern Standard Time"     #Syd/Mel/Cbr time
$TAS =          "Tasmania Standard Time"        #Hob time
$DAR =          "AUS Central Standard Time"     #Dar time
$ADE =          "Cen. Australia Standard Time"  #Ade Time
$PER =          "W. Australia Standard Time"    #Per time
$BRIS =         "E. Australia Standard Time"    #Bri time
$UTC =          "UTC"                           #Universal Co-Ordinated Time

##Set LAN IP variables
$IpList = @(
    @{Office="ACT";     TimeZone=$AEST;   IP="10.1.*"}          
    @{Office="NSW";     TimeZone=$AEST;   IP="10.2.*"}
    @{Office="WA";      TimeZone=$PER;    IP="10.3.*"}
    @{Office="VIC";     TimeZone=$AEST;   IP="10.4.*"}
    @{Office="QLD";     TimeZone=$BRIS;   IP="10.5.*"}
    @{Office="NT";      TimeZone=$DAR;    IP="10.6.*"}
    @{Office="TAS";     TimeZone=$TAS;    IP="10.7.*"}
    @{Office="SA";      TimeZone=$ADE;    IP="10.8.*"}  
    #London is a special case - a shared site with no Corporate connection.
    #We can put the IP in here anyway to keep the values in one place
    @{Office="LON";      TimeZone=$UTC;    IP="100.1.*"}
)

Write-Log -Msg "Current TimeZone is $($CurrentTz)"

#check adapter is running
if ($(Get-NetAdapter -Physical | Where-Object status -eq "Up").name -like "$AdapterName*") {                            #Is it on Ethernet?
    $IPv4 = (Get-NetAdapter -Physical -Name "$AdapterName*" | Get-NetIPAddress).IPv4Address                             #find local IP (v4 only)
    if ((Get-DnsClient | Where-Object InterfaceAlias -like "$AdapterName*").ConnectionSpecificSuffix -eq $DnsSuffix) {  #Is it on the right DNS?
        Write-Log -Msg "Comparing $($IP.Office)"
        foreach ($IP in $IpList){
            if ($IPv4 -like $IP.IP) {                                                                                   #check timezone match value in array
                if ($CurrentTz -ne $IP.TimeZone) {                                                                      #Is that already the timezone?
                    Write-TzLog -Message "Setting TimeZone to $($IP.TimeZone)"
                    Set-TimeZone -Name $IP.TimeZone
                    break                                                                                               #if found, stop
                }
                else {                                                                                                  #TZ already correct
                    Write-Log -Msg "TimeZone already set to $CurrentTz" 
                    exit 0
                }
            }
        }
    }
    elseif (((Invoke-RestMethod -Uri $Uri).ip) -eq $zScalIP) {                                                          #Wired connecion on zScaler? That might be Adelaide. Check WAN IP
        Write-Log -Msg "Comparing $($IpList.Office[10])"
        if ($IPv4 -like $IpList.IP[10]) {                                                                               #check timezone match value in array
            if ($CurrentTz -ne $IPList.TimeZone[10]) {                                                                  #Is that already the timezone?
                Write-Log -Msg "Setting TimeZone to $($IpList.TimeZone[10])"
                Set-TimeZone -Name $IpList.TimeZone[10]
                break
            }
            else {                                                                                                      #TZ already correct
                Write-Log -Msg "TimeZone already set to $CurrentTz"
                exit 0
            }
        }
        else {                                                                                                          #on ethernet, but not correct dns
            Write-Log -Msg "$Adaptername connected, but not on Corporate."
            Write-Log -Msg "Script will not run."
            exit 0
        }
    }
    else {                                                                                                              #not correct dns
        Write-Log -Msg "Not on Corporate."
        Write-Log -Msg "Script will not run."
        exit 0
    }
}
else {                                                                                                                  #not on ethernet
    Write-Log -Msg "$AdapterName not connected"
    Write-Log -Msg "Script will not run."
    exit 0
}
Write-Log -Msg "TimeZone was $CurrentTz, now set to $((Get-TimeZone).ID)"                                               #TZ was changed
exit 0

#End .ps1 content
'

###########################################################################################
## Create the Sched Task
###########################################################################################
Write-Log -Msg 'Creating Scheduled Task'

#Variables
$TaskDescription =                  'Sets the timezone based on IP address when ethernet is connected to corporate network'
#set action
$TaskAction =                       New-ScheduledTaskAction `
                                    -Execute 'Powershell.exe' `
                                    -Argument "-NoProfile -WindowStyle Hidden -File $ps1Path"
#set settings
$TaskSettings =                     New-ScheduledTaskSettingsSet `
                                    -AllowStartIfOnBatteries `
                                    -DontStopIfGoingOnBatteries `
                                    -Compatibility Win8 `
                                    -DontStopOnIdleEnd `
                                    -StartWhenAvailable
#set task user (Principal)
$TaskPrincipal =                    New-ScheduledTaskPrincipal `
                                    -UserId 'SYSTEM' `
                                    -LogonType ServiceAccount `
                                    -RunLevel Highest
#set triggers
    <# The trigger was a pain to work out - to get it working 
    on startup & ALSO repeating I had to break it into several 
    parts, then stick them together.
    # set inital trigger #>
    $TaskTrigger =                  New-ScheduledTaskTrigger `
                                    -AtStartup
    $TaskTrigger.Id =               Startup
    # set trigger repeat
    $TaskRepetition =               (New-ScheduledTaskTrigger `
                                    -Once `
                                    -At (Get-Date) `
                                    -RepetitionInterval (New-TimeSpan -Minutes 1) `
                                    -RepetitionDuration (New-TimeSpan -days 9999 -hours 23 -Minutes 59 -Seconds 59) # won't accept more days than 9999
                                    ) 
    # glue it!
    $TaskTrigger.Repetition =       $TaskRepetition.Repetition

    # set trigger event template (to be set after initial registration)
    $TriggerTemplate =              Get-CimClass MSFT_TaskEventTrigger root/Microsoft/Windows/TaskScheduler | New-CimInstance -ClientOnly
    $TriggerTemplate.Enabled =      $true
    $TriggerTemplate.Repetition =   $TaskRepetition.Repetition

##Register SchedTask
try {
    Register-ScheduledTask `
                                    -TaskName $TaskName `
                                    -Description $TaskDescription `
                                    -TaskPath $TaskPath `
                                    -Action $TaskAction `
                                    -Trigger $TaskTrigger `
                                    -Principal $TaskPrincipal `
                                    -Settings $TaskSettings `
                                    -Force
} catch {
    Write-Log -Msg "Failed to register scheduled task: $_"
    exit 1
}

##Add extra triggers
$Task =                             Get-ScheduledTask $TaskName
# set Netjoin trigger
<# These have to be done seperately, otherwise 
the triggers both look for the same event ¯\_(ツ)_/¯#>
$TriggerNetJoin =                   $TriggerTemplate
$TriggerNetJoin.Id =                'NetJoin'
$TriggerNetJoin.Subscription =      '<QueryList><Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"><Select Path="Microsoft-Windows-NetworkProfile/Operational">*[System[Provider[@Name=''Microsoft-Windows-NetworkProfile''] and EventID=10000]]</Select></Query></QueryList>'
$Task =                             Get-ScheduledTask $TaskName
$TriggerAdd =                       @()
$TriggerAdd =                       $Task.Triggers
$TriggerAdd +=                      $TriggerNetJoin
$Task.Triggers =                    $TriggerAdd
$Task | Set-ScheduledTask

# set netleave trigger
$TriggerNetLeave =                  $TriggerTemplate
$TriggerNetLeave.Id =               'NetLeave'
$TriggerNetLeave.Subscription =     '<QueryList><Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"><Select Path="Microsoft-Windows-NetworkProfile/Operational">*[System[Provider[@Name=''Microsoft-Windows-NetworkProfile''] and EventID=10001]]</Select></Query></QueryList>'
$Task =                             Get-ScheduledTask $TaskName
$TriggerAdd =                       @()
$TriggerAdd =                       $Task.Triggers
$TriggerAdd +=                      $TriggerNetLeave
$Task.Triggers =                    $TriggerAdd
$Task | Set-ScheduledTask

# Add Author
Write-Log -Msg "Setting author $TaskAuthor"
$Task.Author =                      $TaskAuthor

# Commit SchedTask
Write-Log -Msg "Setting $TaskName"
$Task | Set-ScheduledTask

# Start your engines
Write-Log -Msg "Enabling task"
Enable-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName
Write-Log -Msg "Starting task"
Start-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName
Write-Log -Msg 'Script finished'

#endscript
