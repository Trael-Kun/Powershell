Function Invoke-PressAnyKey {
  <#
  .SYNOPSIS
   Pauses script for user interaction
  .NOTES
   Thief:  Bill Wilson (github.com/Trael-Kun)
   Date:   05/11/2024
   
   stolen wholesale from;
   https://stackoverflow.com/questions/20886243/press-any-key-to-continue
  #>
  param (
    [string]$Message
    # Check if running Powershell ISE
    if ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    } else {
        Write-Host "$Message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}
