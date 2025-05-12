function Write-Log {
    par
    
}

function Write-Log {
    param (
        [Parameter(Mandatory,HelpMessage='The message to be output to file & displayed onscreen')]
        [string]$Message,
        [Parameter(Mandatory=$false)] #these can be set earlier in script by commenting out this parameter and declaring as a variable, e.g. $LogFile = 'C:\Temp\Log.txt', $NoDate = $true, $UTC = $false, etc.
        [switch]$NoLog,                                     #don't save a log
        [switch]$NoDate,                                    #don't add the date
        [switch]$CM,                                        #format log for CMTrace.exe
        [switch]$UTC,                                       #time in UTC
        [string]$LogFile = "$env:SystemDrive\Temp\Log.log", #where the log is stored
        [ValidateSet(
            'Information',
            'Info',
            'Warning',
            'Warn',
            'Error',
            'Err',
            $null
        )]$MsgType
    ) 

    #set message type & colour
    if ($MsgType -match 'Info') {
        $strMessage = "Info:    $Message"
        $Colour  = 'Green'
    } elseif ($MsgType -match  'Warn') {
        $strMessage = "Warning: $Message"
        $Colour  = 'Yellow'
    } elseif ($MsgType -like 'Err') {
        $strMessage = "Error:   $Message"
        $Colour  = 'Red'
    } elseif ($null -eq $MsgType) {
        $strMessage = $Message
        $Colour  = 'White'
    }

    if (!($NoDate)) {
        if ($UTC) {
            $Time       = [DateTime]::UtcNow.ToString('HH:mm:ss.ff UTC')
            $Date       = [DateTime]::UtcNow.ToString('yyyy-MM-dd')
            $DateTime   = "$Date " + "$Time"
        } else {
            $Time       = Get-Date -Format 'HH:mm:ss.ff'
            $Date       = Get-Date -Format 'yyyy-MM-dd'
            $DateTime   = "$Date " + "$Time"
        }
        $Message        = "$DateTime    | $strMessage" 
        $Log            = "<![LOG[$Message]LOG]!><time=`"$Time`" date=`"$Date`" file=`"$File`">"
    }

    if ($NoLog) {
        Write-Host $Message -ForegroundColor $Colour
    } elseif ($CM) {
        Write-Host $Message -ForegroundColor $Colour
        Add-Content -Path $LogFile -Value $Log -Force
    } else {
        Write-Host $Message -ForegroundColor $Colour
        Add-Content -Path $LogFile -Value $Message -Force
    }
    }
}
