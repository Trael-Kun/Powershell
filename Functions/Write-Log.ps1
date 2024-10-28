function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,  #What you want the log to say
        [Parameter(Mandatory=$false)]
        [string]$LogFile,  #Can be set earlier in script
        [switch]$NoDate    #Can be set earlier in script
    )
    $DateTime   = [DateTime]::UtcNow.ToString('yyyy-MM-dd HH:mm:ss UTC')
    if ($LogFile) {
        if ($NoDate) {
            Write-Output $Message
            Add-Content -Path $LogFile -Value "$Message" -Force
        
        } else {
            Write-Output $Message
            Add-Content -Path $LogFile -Value "$DateTime	|	$Message"  -Force
        }
    } else {
        Write-Host "Log File Not Set" -ForegroundColor Red -BackgroundColor Black
        Write-Output "$DateTime	|	$Message"
    }
}
