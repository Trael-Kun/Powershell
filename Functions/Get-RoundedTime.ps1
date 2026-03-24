function Get-RoundedTime {
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
    PS> Get-RoundedTime -Up
    Tuesday, 24 March 2026 3:00:00 PM

    .EXAMPLE
    PS> Get-RoundedTime -Down
    Tuesday, 24 March 2026 2:00:00 PM

    .EXAMPLE
    PS> Get-RoundedTime -RoundTo Min
    Tuesday, 24 March 2026 2:52:00 PM

    .EXAMPLE
    PS> Get-RoundedTime -Dn -RoundTo Sec -Format m
    02:52

    .LINK
    https://github.com/Trael-Kun/Powershell/blob/main/Functions/Get-RoundedTime.ps1

    .NOTES
        Written by Bill 24/03/26
    #>
    [CmdletBinding()]
    param(
        [datetime]$Date = (Get-Date),

        [switch]$Up,

        [Alias('Down')]
        [switch]$Dn,

        [ValidateSet(
            'Hour',     #Hour
            'Hr',       #Hour
            'Minute',   #Minute
            'Min',      #Minute
            'Second',   #Second
            'Sec'       #Second
        )]
        [string]$RoundTo = 'Hour',

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
            IgnoreCase = $false
        )]
        [string]$Format
    )

    #Set units
    switch ($RoundTo) {
        'Hour'   { $UnitType = 'Hour' }
        'Hr'     { $UnitType = 'Hour' }
        'Minute' { $UnitType = 'Minute' }
        'Min'    { $UnitType = 'Minute' }
        'Second' { $UnitType = 'Second' }
        'Sec'    { $UnitType = 'Second' }
    }

    #Midpoint lookup
    $MidpointTable = @{
        Hour = @{
            Rounding = $Date.Minute
            Midpoint = 30
        }
        Minute = @{
            Rounding = $Date.Second
            Midpoint = 30
        }
        Second = @{
            Rounding = $Date.Millisecond
            Midpoint = 500
        }
    }

    $Rounding = $MidpointTable[$UnitType].Rounding
    $Unit     = $MidpointTable[$UnitType].Midpoint

    function Set-RoundingUp {
        switch ($UnitType) {
            'Hour' {
                if ($Date.Minute -eq 0 -and $Date.Second -eq 0 -and $Date.Millisecond -eq 0) {
                    return $Date
                }
                $Date.AddHours(1).
                      AddMinutes(-$Date.Minute).
                      AddSeconds(-$Date.Second).
                      AddMilliseconds(-$Date.Millisecond)
            }

            'Minute' {
                if ($Date.Second -eq 0 -and $Date.Millisecond -eq 0) {
                    return $Date
                }
                $Date.AddMinutes(1).
                      AddSeconds(-$Date.Second).
                      AddMilliseconds(-$Date.Millisecond)
            }

            'Second' {
                if ($Date.Millisecond -eq 0) {
                    return $Date
                }
                $Date.AddSeconds(1).
                      AddMilliseconds(-$Date.Millisecond)
            }
        }
    }

    function Set-RoundingDn {
        switch ($UnitType) {
            'Hour' {
                $Date.AddMinutes(-$Date.Minute).
                      AddSeconds(-$Date.Second).
                      AddMilliseconds(-$Date.Millisecond)
            }

            'Minute' {
                $Date.AddSeconds(-$Date.Second).
                      AddMilliseconds(-$Date.Millisecond)
            }

            'Second' {
                $Date.AddMilliseconds(-$Date.Millisecond)
            }
        }
    }

    ##Round the time
    $RoundedDate = if ($Up) {
        Set-RoundingUp
    } elseif ($Dn) {
        Set-RoundingDn
    } elseif ($Rounding -ge $Unit) {
        Set-RoundingUp
    } else {
        Set-RoundingDn
    }

    #Format
    if ($Format) {
        switch ($Format) {
            'Y' { return "{0:d MMM, yyyy HH:mm}" -f $RoundedDate }
            'y' { return "{0:d MMM, yyyy HH:mm}" -f $RoundedDate }
            'M' { return "{0:d MMM HH:mm}"       -f $RoundedDate }
            'D' { return "{0:d HH:mm}"           -f $RoundedDate }
            'd' { return "{0:d HH:mm}"           -f $RoundedDate }
            'H' { return "{0:HH:mm}"             -f $RoundedDate }
            'h' { return "{0:hh:mm}"             -f $RoundedDate }
            'm' { return "{0:hh:mm}"             -f $RoundedDate }
            'S' { return "{0:hh:mm:ss}"          -f $RoundedDate }
            's' { return "{0:hh:mm:ss}"          -f $RoundedDate }
            'F' { return "{0:hh:mm:ss:fff}"      -f $RoundedDate }
            'f' { return "{0:hh:mm:ss:fff}"      -f $RoundedDate }
        }
    }

    return $RoundedDate
}
