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
     Write-Log -Message "This is information" -LogFile C:\temp\ActualLog.log -MsgType Info
     Write-Log -Message "This is a warning" -LogFile C:\temp\ActualLog.log -MsgType Warn -UTC 
     Write-Log -Message "This is a message"
    
    .NOTES
     Author:           Bill Wilson (https://github.com/Trael-Kun/Powershell)
     Date:             28/10/24
     Last Modified:    27/05/25
     References;
        https://janikvonrotz.ch/2017/10/26/powershell-logging-in-cmtrace-format

    #########################>
    param (
        [Parameter(Mandatory,HelpMessage='The message to be output to file & displayed onscreen')]
        [string]$Message,
        [Parameter(Mandatory=$false)] #these can be set earlier in script by commenting out the parameter and declaring as a variable, e.g. $LogFile = 'C:\Temp\Log.txt', $NoDate = $true, $UTC = $false, etc.
        [switch]$NoLog,                                      #don't save a log
        [switch]$NoDate,                                     #don't add the date
        [switch]$Basic,                                      #don't format for CMTrace.exe
        [switch]$UTC,                                        #time in UTC
        [switch]$Speak,                                      #speaks the message. Don't use this.
        [string]$LogFile   = "$env:SystemDrive\Temp\Log.log",#where the log is stored
        [string]$Component = $MyInvocation.MyCommand.Name,   #for CmFormat logging (fills "Component" field)
        [string]$Source    = "$env:SystemDrive\Temp\Log.log" #for CmFormat logging (fills "Source" field)
        [ValidateSet(
            'Information',
            'Informatio',
            'Informati',
            'Informat',
            'Informa',
            'Inform',
            'Infor',
            'Info',
            'Inf',
            'In',
            'I',
            'Warning',
            'Warnin',
            'Warni',
            'Warn',
            'War',
            'Wa',
            'W',
            'Error',
            'Erro',
            'Err',
            'Er',
            'E',
            $null
            )]$MsgType,
        [ValidateSet(
            'Black',
            'DarkBlue',
            'DarkGreen',
            'DarkCyan',
            'DarkRed',
            'DarkMagenta',
            'DarkYellow',
            'Gray',
            'DarkGray',
            'Blue',
            'Green',
            'Cyan',
            'Red',
            'Magenta',
            'Yellow',
            'White'
            )]$ColorOverride
    )

    if ($Speak) {
        Add-Type -AssemblyName System.Speech
        $Speech = New-Object System.Speech.Synthesis.SpeechSynthesizer
    }

    switch ($MsgType) {
    $null {
        [int]$Type          = 0;`
        [string]$Colour     = 'White';`
        [string]$strMessage = $Message}
    {$_ -like "I"}    {
        [int]$Type          = 1;`
        [string]$Colour     = 'Green';`
        [string]$strMessage = 'Info:    ' + $Message}
    {$_ -like "W*"}    {
        [int]$Type          = 2;`
        [string]$Colour     = 'Yellow';`
        [string]$strMessage = 'Warning: ' + $Message}
    {$_ -like "E*"}    {
        [int]$Type          = 3;`
        [string]$Colour     = 'Red';`
        [string]$strMessage = 'Error:   ' + $Message}
    }
    
    #force color
    if ($null -ne $ColorOverride) {
        $Color = $ColorOverride
    }

    #do the writing
    if ($NoDate) {
        $Message        = $strMessage
    } else {
        if ($UTC) {
            $Time       = [DateTime]::UtcNow.ToString('HH:mm:ss UTC')
            $Date       = [DateTime]::UtcNow.ToString('yyyy-MM-dd')
        } else {
            $Time       = Get-Date -Format 'HH:mm:ss'
            $Date       = Get-Date -Format 'yyyy-MM-dd'
        }
        $Message        = "$Date $Time    | $strMessage"         
    }
    
    #write the message
    Write-Host $Message -ForegroundColor $Colour
    if (-not ($NoLog)) {
        if ($Basic) {
            $Log = $Message
        } else {
            $Log = "<![LOG[$StrMessage]LOG]!>" +`
                   "<time=`"$(Get-Date -Format "HH:mm:ss.ffffff")`" " +`
                   "date=`"$(Get-Date -Format "M-d-yyyy")`" " +`
                   "component=`"$Component`" " +`
                   "context=`"$user`" " +`
                   "type=`"$type`" " +`
                   "thread=`"$([Threading.Thread]::CurrentThread.ManagedThreadID)`" " +`
                   "file=`"$Source`">"
       }
       Out-File -FilePath $LogFile -InputObject $Log -Encoding utf8 -Append -Force
    } else {
        #display output but don't write to log
    }

    if ($Speak) {
        $Speech.SpeakAsync($StrMessage)
    }
}
