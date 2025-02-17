function Stop-it {
    #Stop a process from running
    param (
        [string]$ProcessName
    )
    While ($true) {
        $Process = Get-Process $ProcessName -ErrorAction SilentlyContinue
        if (!($Process)) {
            Start-Sleep -Seconds 1
        } else {
            Write-Host "Stopping $($Process.ProcessName)"
            Stop-Process $Process.Id
            Wait-Process -Id $Process.Id
            Write-Host "$($Process.ProcessName) Stopped"
        }
    }
}
