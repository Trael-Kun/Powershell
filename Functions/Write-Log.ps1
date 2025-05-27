function Write-Log {
    <#########################
    .SYNOPSIS
     Writes to a log file
    .DESCRIPTION
     Writes to a log file. That's about it. Now with added formatting options for your favorite log reader (CMTrace.exe, obvs)
    
    .PARAMETER Message
     The Log Message
    .PARAMETER NoLog
     Do not write to log, display in shell only
    .PARAMETER NoDate
     Do not display the date
    .PARAMETER UTC
     Format time in UTC
    .PARAMETER LogFile
     Log file path
    .PARAMETER MsgType
     Parameter description
    
    .EXAMPLE
     Write-Log -Message "This is information" -LogFile C:\temp\ActualLog.log -MsgType Info -Basic
     Write-Log -Message "This is a warning" -LogFile C:\temp\ActualLog.log -MsgType Warn -UTC -Basic
     Write-Log -Message "This is an error" -LogFile C:\temp\ActualLog.log -MsgType Err -Component 'PWSH' -Source 'PowerShell.exe'
     Write-Log -Message "This is a message"
    
    .NOTES
     Author:           Bill Wilson (https://github.com/Trael-Kun/Powershell)
     Date:             28/10/24
     Last Modified:    12/05/25
     References;
        https://janikvonrotz.ch/2017/10/26/powershell-logging-in-cmtrace-format

    #########################>
    param (
        [Parameter(Mandatory,HelpMessage='The message to be output to file & displayed onscreen')]
        [string]$Message,
        [Parameter(Mandatory=$false)] #these can be set earlier in script by commenting out the parameter and declaring as a variable, e.g. $LogFile = 'C:\Temp\Log.txt', $NoDate = $true, $UTC = $false, etc.
        [switch]$NoLog,                                      #don't save a log
        [switch]$NoDate,                                     #don't add the date
        [switch]$UTC,                                        #time in UTC
        [string]$LogFile   = "$env:SystemDrive\Temp\Log.log",#where the log is stored
        [ValidateSet(
            'Information',
            'Info',
            'Inf',
            'Warning',
            'Warn',
            'War',
            'Error',
            'Err',
            $null
        )]$MsgType
    ) 

    switch ($MsgType) {
    $null {
        [string]$Colour     = 'White';`
        [string]$strMessage = $Message}
    {$_ -match "Inf"}    {
        [string]$Colour     = 'Green';`
        [string]$strMessage = "Info:    $Message"}
    {$_ -match "War"}    {
        [string]$Colour     = 'Yellow';`
        [string]$strMessage = "Warning: $Message"}
    {$_ -match "Err"}    {
        [string]$Colour     = 'Red';`
        [string]$strMessage = "Error:   $Message"}
}

    if (!($NoDate)) {
        if ($UTC) {
            $Time       = [DateTime]::UtcNow.ToString('HH:mm:ss.ff UTC')
            $Date       = [DateTime]::UtcNow.ToString('yyyy-MM-dd')
        } else {
            $Time       = Get-Date -Format 'HH:mm:ss.ff'
            $Date       = Get-Date -Format 'yyyy-MM-dd'
        }
    $Message            = "$Date $Time    | $strMessage" 
    } else {
        $Message        = $strMessage
    }
    
    #write the message
    Write-Host $Message -ForegroundColor $Colour
    if ($NoLog) {
        #you're done
    } else {
        Add-Content -Path $LogFile -Value $Message -Force
    }
}
