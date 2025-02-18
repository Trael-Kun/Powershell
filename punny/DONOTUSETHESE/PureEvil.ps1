function Clear-Clipboard {  #https://www.reddit.com/r/PowerShell/comments/1dlo6hx/comment/l9tqb6t
    while ($true) {
        if ($null -ne (Get-clipboard)) {
            Set-Clipboard $null
        }
    } 
}
