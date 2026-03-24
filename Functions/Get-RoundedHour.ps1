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
            'Hour',         #Hour
            'Hr',           #Hour
            'Minute',       #Minute
            'Min',          #Minute
            'Second',       #Second
            'Sec'           #Second
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

    function Set-RoundingUp {
        if ($RoundTo -match "H*") {             #Round Up: add an hour & set min/sec/millisec to 0
            $Date.AddHours(1).AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "Min*") {     #Round Up: add a minute & set sec/millisec to 0
            $Date.AddMinutes(1).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "S*") {       #Round Up: add a second & set millisec to 0
            $Date.AddSeconds(1).AddMilliseconds(-$Date.Millisecond)
        }
    }

    function Set-RoundingDn {
        if ($RoundTo -match "H*") {                                     #Round Dn: set min/sec/millisec to 0
            $Date.AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "Min*") {                             #Round Dn: set sec/millisec to 0
            $Date.AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "S*" -or $RoundTo -match "Mil*") {    #Round Dn: set millisec to 0
            $Date.AddMilliseconds(-$Date.Millisecond)
        }
    }

   ##Round the time
    #Set units
    if ($RoundTo -match "H*") {
        $Rounding = $Date.Minute
        $Unit     = 30
    } elseif ($RoundTo -Match "Min*") {
        $Rounding = $Date.Second
        $Unit     = 30
    } elseif ($RoundTo -Match "S*") {
        $Rounding = $Date.Millisecond
        $Unit     = 500
    }

    $RoundedDate = if ($Up) {
        Set-RoundingUp
    } elseif ($Dn) {
        Set-RoundingDn
    } elseif ($Rounding -ge $Unit) {
        Set-RoundingUp
    } elseif ($Rounding -lt $Unit) {
        Set-RoundingDn
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

    return $RoundedDate
}
