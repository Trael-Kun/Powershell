function Get-RoundedHour {
    <#
    .DESCRIPTION
        Round time up or down
    .EXAMPLE
        Get-RoundedHour -Up
    .EXAMPLE
        Get-RoundedHour -Down
    .EXAMPLE
        Get-RoundedHour -RoundTo Min
    .EXAMPLE
        Get-RoundedHour -Dn -RoundTo Day -Format M
    .EXAMPLE
        Get-RoundedHour -Dn -RoundTo Day -Format m
    .NOTES
        Written by Bill 24/03/26
    #>
    param(
        [datetime]$Date = (Get-Date),
        [switch]$Up,
        [Alias('Down,Dow')]
        [switch]$Dn,
        [ValidateSet(
            'Year',         #Year
            'Yr',           #Year
            'Month',        #Month
            'Mon',          #Month
            'Mth',          #Month
            'Day',          #Day
            'Hour',         #Hour
            'Hr',           #Hour
            'Minute',       #Minute
            'Min',          #Minute
            'Second',       #Second
            'Sec',          #Second
            'Millisecond',  #Millisecond
            'Mil'           #Millisecond
            )]
        [string]$RoundTo = "Hr",
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

    #Round the time
    $RoundedDate = if ($Date.Minute -ge 30 -or $Up) {
        if ($RoundTo -match "Y*") {                                  #Round Up: add a month & set day/hr/min/sec/millisec to 0
            $Date.AddYears(1).AddMonths(-$Date.Month).AddDays(-$Date.Day).AddHours(-$Date.Hour).AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -match "Mon*" -or $RoundTo -match 'Mth'){ #Round Up: add a day & set hr/min/sec/millisec to 0
            $Date.AddMonths(1).AddDays(-$Date.Day).AddHours(-$Date.Hour).AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -match "D*") {                            #Round Up: add a day & set hr/min/sec/millisec to 0
            $Date.AddDays(1).AddHours(-$Date.Hour).AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -match "H*") {                            #Round Up: add an hour & set min/sec/millisec to 0
            $Date.AddHours(1).AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "Min*") {                          #Round Up: add a minute & set sec/millisec to 0
            $Date.AddMinutes(1).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "S*") {                            #Round Up: add a second & set millisec to 0
            $Date.AddSeconds(1).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -match "Mil*") {                          #Round Up: add a millisec
            $Date.AddMilliseconds(1)
        }
    } elseif ($Date.Minute -lt 30 -or $Dn) {    
        if ($RoundTo -match "Y*") {                                     #Round Dn: set month/day/hour/min/sec/millisec to 0
            $Date.AddMonths(-$Date.Month).AddDays(-$Date.Day).AddHours(-$Date.Hour).AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -match "Mon*" -or $RoundTo -match 'Mth'){    #Round Dn: set day/hour/min/sec/millisec to 0
            $Date.AddDays(-$Date.Day).AddHours(-$Date.Hour).AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -match "D*") {                               #Round Dn: set hour/min/sec/millisec to 0
            $Date.AddHours(-$Date.Hour).AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -match "H*") {                               #Round Dn: set min/sec/millisec to 0
            $Date.AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "Min*") {                             #Round Dn: set sec/millisec to 0
            $Date.AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "S*" -or $RoundTo -match "Mil*") {    #Round Dn: set millisec to 0
            $Date.AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -match "Mil*") {                             #Round Dn: do nothing 
        }
    }

    #Format
    if ($null -eq $Format) {
        return $RoundedDate
    } elseif ($Format -eq 'Y') {
        return "{0:d, MMM, YYYY HH:mm}" -f $RoundedDate
    } elseif ($Format -ceq "M") {
        return "{0:d, MMM HH:mm}" -f $RoundedDate
    } elseif ($Format -eq "D") {
        return "{0:dd HH:mm}" -f $RoundedDate
    } elseif ($Format -ceq "H") {
        return "{0:HH:mm}" -f $RoundedDate
    } elseif ($Format -ceq "h") {
        return "{0:hh:mm}" -f $RoundedDate
    } elseif ($Format -eq "m") {
        return "{0:hh:mm}" -f $RoundedDate
    } elseif ($Format -eq "s") {
        return "{0:hh:mm:ss}" -f $RoundedDate
    } elseif ($Format -eq "f") {
        return "{0:hh:mm:ss:fff}" -f $RoundedDate
    }
}
