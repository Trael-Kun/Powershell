function Stop-it {
    #Stop a process from running
    param (
        [ValidateNotNullorEmpty()]
        [string]$ProcessName = 'Notepad'
    )
    While ($true) {
        $Process = Get-Process $ProcessName -ErrorAction SilentlyContinue
        if (!($Process)) {
            Start-Sleep -Seconds 1
        } else {
            Write-Host "Stopping $($Process.ProcessName)"
            Stop-Process $Process.Id -ErrorAction SilentlyContinue
            Wait-Process -Id $Process.Id
            Write-Host "$($Process.ProcessName) Stopped"
        }
    }
}
