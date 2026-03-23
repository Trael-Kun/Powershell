function Get-RoundedHour {
        <#
            .DESCRIPTION
             Round time up or down
            .NOTES
             Written by Bill 24/03/26
        #>
    param(
        [datetime]$Date = (Get-Date),
        [switch]$Up,
        [Alias('Down,Dow')]
        [switch]$Dn,
        [ValidateSet(
            'Hour',
            'Hr',
            'Minute',
            'Min',
            'Second',
            'Sec',
            'Millisecond',
            'Mil')]
        [string]$RoundTo = "Hr"
    )

    $RoundedDate = if ($Date.Minute -ge 30 -or $Up) {   #Round Up: add an hour & set min/sec/millisec to 0
        if ($RoundTo -match "H*") {
            $Date.AddHours(1).AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "Min*") {
            $Date.AddMinutes(1).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "S*") {
            $Date.AddSeconds(1).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -match "Mil*") {
            $Date.AddMilliseconds(1)
        }
    } elseif ($Date.Minute -lt 30 -or $Dn) {            #Round Dn: set min/sec/millisec to 0
        if ($RoundTo -match "H*") {
            $Date.AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "Min*") {
            $Date.AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
        } elseif ($RoundTo -Match "S*") {
            $Date.AddMilliseconds(-$Date.Millisecond)
        }
    }
    return $RoundedDate
}
