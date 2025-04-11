#https://learn.microsoft.com/en-us/windows/win32/wmisdk/wmi-tasks--dates-and-times
function Get-RemoteTimeWMI{
    <#
    Get the local time on a remote machine
    #>
    param (
        [string]$Computer = $env:COMPUTERNAME,
        [switch]$Show,
        [switch]$Fancy
    )
    #get Remote Time
    $Times       = Get-WmiObject Win32_LocalTime -Computer $Computer
    #Organise Data
    $PcName      = $Times.PSComputerName
    $Second      = $Times.Second
    $Minute      = $Times.Minute
    $Hour        = $Times.Hour
    $Day         = $Times.Day
    $Month       = $Times.Month
    $Year        = $Times.Year
    $DayOfWeek   = (Get-Date $Day/$Month/$Year).DayOfWeek
    $MonthOfYear = Get-Date -Month $Month -Format MMMM
    <# Now display the result #>
    if ($Show -and $Fancy) {
        Write-Output "Current time for $PcName; $($Hour):$Minute $DayOfWeek $Day of $MonthOfYear $Year"
    } elseif ($Show) {
        Write-Output "Current time for $PcName; $($Hour):$Minute, $Day/$Month/$Year"
    }
}
