function Get-RoundedTicks {
    <#
    .SYNOPSIS
    Rounds a DateTime value to a specified time unit.

    .DESCRIPTION
    Rounds the supplied DateTime value up, down, or to the nearest boundary
    of the specified unit.

    Fixed-duration units (Second, Minute, Hour, Day, Week) are rounded using
    ticks-based arithmetic.

    Calendar-based units (Month, Year) are rounded using calendar-aware logic
    to correctly account for varying month lengths and leap years.

    If neither -Up nor -Dn is specified, rounding is performed to the nearest
    midpoint of the selected unit.

    .PARAMETER Date
    The DateTime value to round. Defaults to the current date and time.

    .PARAMETER Up
    Forces rounding upward to the next unit boundary.
    If the value is already aligned, it is returned unchanged.

    .PARAMETER Dn
    Forces rounding downward to the current unit boundary.

    .PARAMETER RoundTo
    The unit to round to.

    Fixed-duration units:
      - Second
      - Minute
      - Hour
      - Day
      - Week

    Calendar-based units:
      - Month
      - Year

    Defaults to Hour.

    .PARAMETER Format
    Optional output formatting.
    If specified, the function returns a formatted string instead of a DateTime.

    .OUTPUTS
    System.DateTime
    System.String (if -Format is specified)

    .EXAMPLE
    PS> Get-RoundedTicks -Up
    Rounds the current time up to the next hour.

    .EXAMPLE
    PS> Get-RoundedTicks -RoundTo Minute
    Rounds the current time to the nearest minute.

    .EXAMPLE
    PS> Get-RoundedTicks -RoundTo Month -Dn
    Rounds down to the first day of the current month.

    .EXAMPLE
    PS> Get-RoundedTicks -RoundTo Year
    Rounds to the nearest year boundary.

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
            'Second','Minute','Hour','Day','Week',
            'Month','Year'
        )]
        [string]$RoundTo = 'Hour',

        [ValidateSet(
            'Y','y','M','D','d','H','h','m','S','s','F','f',
            IgnoreCase = $false
        )]
        [string]$Format
    )

    # ============================================================
    # Calendar-aware units (Month / Year)
    # ============================================================
    if ($RoundTo -in 'Month','Year') {

        switch ($RoundTo) {

            'Month' {
                $Start = Get-Date -Year $Date.Year -Month $Date.Month -Day 1 `
                                   -Hour 0 -Minute 0 -Second 0 -Millisecond 0

                $DaysInMonth = [DateTime]::DaysInMonth($Date.Year, $Date.Month)
                $Midpoint    = [int]($DaysInMonth / 2)

                if ($Up) {
                    $RoundedDate = $Start.AddMonths(1)
                }
                elseif ($Dn) {
                    $RoundedDate = $Start
                }
                elseif ($Date.Day -gt $Midpoint) {
                    $RoundedDate = $Start.AddMonths(1)
                }
                else {
                    $RoundedDate = $Start
                }
            }

            'Year' {
                $Start = Get-Date -Year $Date.Year -Month 1 -Day 1 `
                                -Hour 0 -Minute 0 -Second 0 -Millisecond 0

                $DaysInYear = if ([DateTime]::IsLeapYear($Date.Year)) { 366 } else { 365 }
                $Midpoint   = [int]($DaysInYear / 2)

                if ($Up) {
                    $RoundedDate = $Start.AddYears(1)
                }
                elseif ($Dn) {
                    $RoundedDate = $Start
                }
                elseif ($Date.DayOfYear -gt $Midpoint) {
                    $RoundedDate = $Start.AddYears(1)
                }
                else {
                    $RoundedDate = $Start
                }
            }
        }
    }
    else {
        # ============================================================
        # Fixed-duration units (ticks-based rounding)
        # ============================================================

        switch ($RoundTo) {
            'Second' { $UnitTicks = [TimeSpan]::TicksPerSecond }
            'Minute' { $UnitTicks = [TimeSpan]::TicksPerMinute }
            'Hour'   { $UnitTicks = [TimeSpan]::TicksPerHour }
            'Day'    { $UnitTicks = [TimeSpan]::TicksPerDay }
            'Week'   { $UnitTicks = [TimeSpan]::TicksPerDay * 7 }
        }

        $Ticks     = $Date.Ticks
        $Remainder = $Ticks % $UnitTicks
        $Midpoint  = $UnitTicks / 2

        if ($Up) {
            if ($Remainder -eq 0) {
                $RoundedTicks = $Ticks
            } else {
                $RoundedTicks = $Ticks + ($UnitTicks - $Remainder)
            }
        }
        elseif ($Dn) {
            $RoundedTicks = $Ticks - $Remainder
        }
        elseif ($Remainder -ge $Midpoint) {
            $RoundedTicks = $Ticks + ($UnitTicks - $Remainder)
        }
        else {
            $RoundedTicks = $Ticks - $Remainder
        }

        $RoundedDate = [datetime]$RoundedTicks
    }

    # ============================================================
    # Optional formatting
    # ============================================================
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
