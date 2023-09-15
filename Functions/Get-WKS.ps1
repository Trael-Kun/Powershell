function Get-WKS {  
	<#
	Allows user to enter just asset number and auto-fills WKS prefix
	Written by Bill Wilson
	#>
    # Asset No. Input
    Write-Host " " -NoNewline
    Write-Host ' input target PC Name or WKS Asset No. (or' -NoNewline -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host ' EXIT' -NoNewline -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ' to stop) :' -NoNewline -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host ' ' -NoNewline
    $Asset = Read-Host

    ## Set Computer Name
    ####################
    # Add prefix to asset no.
    if ($Asset -eq "") {
        Write-Host ""
        Write-Host " " -NoNewline
        Write-Host " No name or asset entered " -ForegroundColor White -BackgroundColor Red
        Write-Host ""
    }
    else {
        if ($Asset -match 'exit') {
            EXIT
        }
        elseif ($Asset -eq 'o') {
            Write-Host " " -NoNewline
            Write-Host ' OVERRIDE MODE ' -ForegroundColor Red -BackgroundColor Yellow
            Write-Host " " -NoNewline
            Write-Host ' input target PC Name :' -NoNewline -ForegroundColor DarkYellow -BackgroundColor Black
            Write-Host ' ' -NoNewline
            $PCname = Read-Host
        }
        elseif ($Asset -match '^VM') {
            $PCname = "$Asset"
        }
        elseif ($Asset -match '^LAP') {
            $PCname = "$Asset"
        }
        elseif ($Asset -match '^CAF') {
            $PCname = "$Asset"
        }
        elseif ($Asset -match '^WKS') {
            $PCname = "$Asset"
        }
        elseif ($Asset -notmatch '^WKS') {
            $PCname = "WKS$Asset"
        }
        # Define where output file is stored
        $locallogdir = "$env:SystemDrive\temp\logs\"
        $targlogdir = "\\$PCname\c$\temp\logs\"
    }
}
