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
    .PARAMETER Basic
     Do not format for CCM-format (format like .txt file)
    .PARAMETER Component
     Fill to Component field in CCM-format
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
        [switch]$NoLog,                                     #don't save a log
        [switch]$NoDate,                                    #don't add the date
        [switch]$Basic,                                     #don't format CCM-format
        [string]$Component = $MyInvocation.MyCommand.Name,  #for CMTrace logging (fills "Component" field)
        [string]$Source    = '',                            #for CMTrace logging (fills "Source" field)
        [switch]$UTC,                                       #time in UTC
        [string]$LogFile   = "$env:SystemDrive\Temp\Log.log", #where the log is stored
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
        $null                   {[int]$Type = 0}
        {$MsgType -match "Inf"} {[int]$Type = 1}
        {$MsgType -match "War"} {[int]$Type = 2}
        {$MsgType -match "Err"} {[int]$Type = 3}
    }

    #set message type & colour
    if ($null -eq $MsgType) {
        $strMessage = $Message
        $Colour  = 'White'
    }elseif ($Type -eq 1) {
        $strMessage = "Info:    $Message"
        $Colour  = 'Green'
    } elseif ($Type -eq 2) {
        $strMessage = "Warning: $Message"
        $Colour  = 'Yellow'
    } elseif ($Type -eq 3) {
        $strMessage = "Error:   $Message"
        $Colour  = 'Red'
    }

    if (!($NoDate)) {
        if ($UTC) {
            $Time       = [DateTime]::UtcNow.ToString('HH:mm:ss.ff UTC')
            $Date       = [DateTime]::UtcNow.ToString('yyyy-MM-dd')
        } else {
            $Time       = Get-Date -Format 'HH:mm:ss.ff'
            $Date       = Get-Date -Format 'yyyy-MM-dd'
        }
    $Message        = "$Date $Time    | $strMessage" 
    }
    
    #write the message
    Write-Host $Message -ForegroundColor $Colour
    if ($NoLog) {
        #you're done
    } elseif (!($Basic)) {
        $Log =  "<![LOG[$strMessage]LOG]!>" +`
                "<time=`"$(Get-Date -Format "HH:mm:ss.ffffff")`" " +`
                "date=`"$(Get-Date -Format "M-d-yyyy")`" " +`
                "component=`"$Component`" " +`
                "context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
                "type=`"$Type`" " +`
                "thread=`"$([Threading.Thread]::CurrentThread.ManagedThreadId)`" " +`
                "file=`"$Source`">"
        Add-Content -Path $LogFile -Value $Log -Force
    } else {
        Add-Content -Path $LogFile -Value $Message -Force
    }
}
