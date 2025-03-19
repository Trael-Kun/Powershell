function Write-Log {
    param (
        [Parameter(Mandatory,HelpMessage='The message to be output to file & displayed onscreen')]
        [string]$strMessage,
        [Parameter(Mandatory=$false)] #these can be set earlier in script by commenting out this parameter and declaring as a variable, e.g. $LogFile = 'C:\Temp\Log.txt', $NoDate = $true, $UTC = $false, etc.
        [switch]$NoLog,                                     #don't save a log
        [switch]$NoDate,                                    #don't add the date
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
        $Message = "Info:    $strMessage"
        $Colour  = 'Green'
    } elseif ($MsgType -match  'Warn') {
        $Message = "Warning: $strMessage"
        $Colour  = 'Yellow'
    } elseif ($MsgType -like 'Err') {
        $Message = "Error:   $strMessage"
        $Colour  = 'Red'
    } elseif ($null -eq $MsgType) {
        $Message = $strMessage
        $Colour  = 'White'
    }

    if (!($NoDate)) {
        if ($UTC) {
            $DateTime   = [DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss UTC')
        } else {
            $DateTime   = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        }
        $Message        = "$DateTime    | $Message" 
    }

    if ($NoLog) {
        Write-Host $Message -ForegroundColor $Colour
    } else {
        Write-Host $Message -ForegroundColor $Colour
        Add-Content -Path $LogFile -Value "$Message" -Force
    }
}
