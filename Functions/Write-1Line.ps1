Function Write-1Line {
  <#
  .DESCRIPTION
  Quicker one-line outputs - stop writing "-NoNewLine" multiple times
  
  .EXAMPLE
  Write-1Line -Message "Hello " -Colour Blue
  Write-1Line -Message "World"  -Colour Red -End
  
  .NOTES
  Written by Bill, 03/03/2026
  #>
    param ( 
        [Parameter(Mandatory)]
            [Alias('Message',"Msg")]
            [string]$Msg,
            [ValidateSet(
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
                'White')]
             [Alias('Colour','Color','Col')]
             [string]$Colour,
            [switch]$End
    )

    if ($Colour -and $End) {
        Write-Host $Msg -ForegroundColor $Colour
    } elseif ($End) {
        Write-Host $Msg
    } elseif ($Colour) {
        Write-Host $Msg -ForegroundColor $Colour -NoNewline 
    } else {
        Write-Host $Msg -NoNewline
    }
}
