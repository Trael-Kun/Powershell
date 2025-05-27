function Write-Alphabet {
    [char]$Letter = 'A'
    do {
        write-host $Letter
        start-sleep -Seconds 1
        $Letter = [byte]$Letter + 1
    } until ($Letter -gt 'Z')
}
