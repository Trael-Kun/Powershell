function Get-RoundedHour {
    param([datetime]$Date = (Get-Date))
    $RoundedDate = if ($Date.Minute -ge 30) {   #Round Up: add an hour & set min/sec/millisec to 0
        $Date.AddHours(1).AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
    } else {                                    #Round Dn: set min/sec/millisec to 0
        $Date.AddMinutes(-$Date.Minute).AddSeconds(-$Date.Second).AddMilliseconds(-$Date.Millisecond)
    }
    return $RoundedDate
}
