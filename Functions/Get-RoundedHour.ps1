function Get-RoundedHour {
    <#
    .SYNOPSIS
    Round time up or down
    
    .DESCRIPTION
    Rounds the entered time to the nearest unit - defaults to Hour
    Automatically rounds time up or down, or accepts parameters to force direction

    .PARAMETER Date
    Allows entering date/time. Defaults to Now

    .PARAMETER Up
    Forces rounding up
    
    .PARAMETER Dn
    Forces rounding down

    .PARAMETER RoundTo
    Sets unit to round to, accepts 'Hour', 'Minute', 'Second'
    Defaults to hour

    .PARAMETER Format
    Optional output formatting

    .EXAMPLE
    PS> Get-RoundedHour -Up
    Tuesday, 24 March 2026 3:00:00 PM

    .EXAMPLE
    PS> Get-RoundedHour -Down
    Tuesday, 24 March 2026 2:00:00 PM

    .EXAMPLE
    PS> Get-RoundedHour -RoundTo Min
    Tuesday, 24 March 2026 2:52:00 PM

    .EXAMPLE
    PS> Get-RoundedHour -Dn -RoundTo Sec -Format m
    02:52

    .LINK
    https://github.com/Trael-Kun/Powershell/blob/main/Functions/Get-RoundedHour.ps1

    .NOTES
        Written by Bill 24/03/26
    #>
    param(
        [datetime]$Date = (Get-Date),
        [switch]$Up,
        [Alias('Down')]
        [switch]$Dn,
        [ValidateSet(
            'Hour',         #Hour
            'Hr',           #Hour
            'Minute',       #Minute
            'Min',          #Minute
            'Second',       #Second
            'Sec'           #Second
            )]
        [string]$RoundTo = "Hour",
        [ValidateSet(
            'Y',    #Year
            'y',    #Year
            'M',    #Month
            'D',    #Day
            'd',    #Day
            'H',    #24Hour
            'h',    #12Hour
            'm',    #Minute
            'S',    #Second
            's',    #Second
            'F',    #Millisecond
            'f',    #Millisecond
            IgnoreCase = $false)]
        [string]$Format
    )

    function Set-RoundingUp {
        if ($To -match "H*") {             #Round Up: add an hour & set min/sec/millisec to 0
            $Date.AddHours(1).AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($To -Match "Min*") {     #Round Up: add a minute & set sec/millisec to 0
            $Date.AddMinutes(1).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($To -Match "S*") {       #Round Up: add a second & set millisec to 0
            $Date.AddSeconds(1).AddMilliseconds(-$Date.Millisecond)
        }
    }

    function Set-RoundingDn {
        if ($To -match "H*") {                                     #Round Dn: set min/sec/millisec to 0
            $Date.AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($To -Match "Min*") {                             #Round Dn: set sec/millisec to 0
            $Date.AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($To -Match "S*" -or $To -match "Mil*") {    #Round Dn: set millisec to 0
            $Date.AddMilliseconds(-$Date.Millisecond)
        }
    }

   ##Round the time
    #Set units
    if ($RoundTo -match "H*") {
        $Rounding = $Date.Minute
        $Unit     = 30
    } elseif ($RoundTo -match "Min*") {
        $Rounding = $Date.Second
        $Unit     = 30
    } elseif ($RoundTo -Match "S*") {
        $Rounding = $Date.Millisecond
        $Unit     = 500
    }

    $RoundedDate = if ($Up) {
        Set-RoundingUp -To $RoundTo
    } elseif ($Dn) {
        Set-RoundingDn -To $RoundTo
    } elseif ($Rounding -ge $Unit) {
        Set-RoundingUp -To $RoundTo
    } elseif ($Rounding -lt $Unit) {
        Set-RoundingDn -To $RoundTo
    }

    #Format
    if ($Format -eq 'Y') {          #to year
        $RoundedDate = "{0:d MMM, yyyy HH:mm}" -f $RoundedDate
    } elseif ($Format -ceq "M") {   #to month
        $RoundedDate =  "{0:d MMM HH:mm}" -f $RoundedDate
    } elseif ($Format -eq "D") {    #to day
        $RoundedDate = "{0:d HH:mm}" -f $RoundedDate
    } elseif ($Format -ceq "H") {   #24 hour time
        $RoundedDate = "{0:HH:mm}" -f $RoundedDate
    } elseif ($Format -ceq "h") {   #12 hour time
        $RoundedDate = "{0:hh:mm}" -f $RoundedDate
    } elseif ($Format -eq "m") {    #to minute
        $RoundedDate = "{0:hh:mm}" -f $RoundedDate
    } elseif ($Format -eq "s") {    #to second
        $RoundedDate =  "{0:hh:mm:ss}" -f $RoundedDate
    } elseif ($Format -eq "f") {    #to millisecond
        $RoundedDate = "{0:hh:mm:ss:fff}" -f $RoundedDate
    }

    #Write the result
    return $RoundedDate
}

<# Example usage
$CurrentTime = Get-Date
$RoundedTime = Get-RoundedHour -Date $(Get-Date) -Up
#>

Write-Host "Current Time: $(Get-Date)"
Write-Host "Rounded Time: $RoundedTime"

while ($True) {
    if ($RoundedTime -lt $CurrentTime) {
        "Current time is $(Get-Date -Format HH:mm), Rounded is $RoundedTime"
        "Hour has passed"
        #Write-Host "$Complete packages done by $RoundedTime"
        $RoundedTime = Get-RoundedHour -Date $(Get-Date) -Up
    } else {
        "Current time is $(Get-Date -Format HH:mm), Rounded is $RoundedTime"
        "Hour has not passed"
        #dun do nuffin
    }
    Start-Sleep -Seconds 30
}

