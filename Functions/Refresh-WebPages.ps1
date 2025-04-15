function Refresh-WebPages {
    #https://stackoverflow.com/questions/25888915/refreshing-web-page-using-powershell
    param(
        [int]$interval = 5,
        [string]$URL
    )
    "Refreshing IE Windows every $interval seconds."
    "Press any key to stop."
    $shell = New-Object -ComObject Shell.Application
    do {
        'Refreshing ALL HTML'
        $shell.Windows() | 
            Where-Object { $_.Document.url -like $URL } | 
            ForEach-Object { $_.Refresh() }
        Start-Sleep -Seconds $interval
    } until ( [System.Console]::KeyAvailable )
    [System.Console]::ReadKey($true) | Out-Null
}
