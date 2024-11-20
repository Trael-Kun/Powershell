function Convert-Hours {
    <#
    .SYNOPSIS
     Converts hours into months, weeks, days, hours, minutes 
     and seconds.
    
    .DESCRIPTION
     Converts decimal hours into months, weeks, days, hours, 
     minutes and seconds.
     Useful for translating Annual Leave and similar, which 
     is often expressed in decimals.

     Default settings are set to calculate a 7.5 hour workday, 
     and a 5-day work week.
    
    .NOTES
     Author:    Bill Wilson
     Date:      20/11/2024
     References;
      https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/new-timespan?view=powershell-7.4
      https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arithmetic_operators?view=powershell-7.4
      https://stackoverflow.com/questions/68142796/convert-date-time-decimal
    #>
    param (
        [Parameter(Mandatory)]
        [double]$Hours  #hours in decimal format
    )

    #time constants
    $1Second        = New-TimeSpan -Seconds 1
    $MinInSec       = $1Second.TotalMinutes
    $HrInSec        = $1Second.TotalHours

    $1Minute        = New-TimeSpan -Minutes 1
    $SecInMin       = $1Minute.TotalMinutes
    $HrInMin        = $1Minute.TotalHours
    
    $1Hour          = New-TimeSpan -Hours 1
    $SecInHr        = $1Hour.TotalSeconds
    $MinInHr        = $1Hour.TotalMinutes
    
    $1Day           = New-TimeSpan -Days 1
    $SecInDay       = $1Day.TotalSeconds
    $MinInDay       = $1Day.TotalMinutes
    
    #corp time
    $HrsInDay       = 7.5
    $DaysInWk       = 5
    $DaysInMonth    = 21    # approx length for general calculation
    $WeeksInMonth   = 4.2   # approx length for general calculation

    #number of months
    $Months             = [System.Math]::Floor($Hours / ($HrsInDay * $DaysInMonth))
    #remaining hrs after months
    $HrsAfterMonths     = $Hours - ($Months * $HrsInDay * $DaysInMonth)

    #number of weeks
    $Weeks              = [System.Math]::Floor($HrsAfterMonths / ($HrsInDay * $DaysInWk))
    #remaining hrs after weeks
    $HrsAfterWeeks      = $HrsAfterMonths - ($Weeks * $HrsInDay * $DaysInWk)

    #number of days
    $Days               = [System.Math]::Floor($HrsAfterWeeks / $HrsInDay)
    #remaining hrs after days
    $HrsAfterDays       = $HrsAfterWeeks - ($Days * $HrsInDay)

    #calculate hrs
    $TotalHours         = [System.Math]::Floor($HrsAfterDays)

    #calculate min
    $RemainingMinutes   = ($HrsAfterDays - $TotalHours) * 60
    $Minutes            = [System.Math]::Floor($RemainingMinutes)

    #calculate sec
    $RemainingSeconds   = ($RemainingMinutes - $Minutes) * 60
    $Seconds            = [System.Math]::Floor($RemainingSeconds)

    # Output the result
    $Times = [PSCustomObject]@{
        Months  = $Months
        Weeks   = $Weeks
        Days    = $Days
        Hours   = $TotalHours
        Minutes = $Minutes
        Seconds = $Seconds
    }
    return $Times
}
