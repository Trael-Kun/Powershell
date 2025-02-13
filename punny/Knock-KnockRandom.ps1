<#
 .SYNOPSIS
    Tells a knock-knock joke.
 .DESCRIPTION
    Generates a random number and recites a pre-filled joke along with user prompts.
 .NOTES
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date:   December 2024    
    Inspired by Joseph Preston https://github.com/jpreston86/Powershell/blob/master/Knock%20Knock%20Joke
#>

function Write-Type {
    <#
    .SYNOPSIS
        taps out text like a typewriter
    .NOTES
        Written by Markus Fleschutz (https://github.com/fleschutz)
        Adapted by Bill Wilson (https://github.com/Trael-Kun)
       References;
        https://github.com/fleschutz/PowerShell/blob/main/scripts/write-typewriter.ps1
    #>
    param(
        [parameter(mandatory=$true)]
        [string]$Text,
        [parameter(mandatory=$false)]
        [int]$Speed = 5,
        [string]$ForegroundColor
    )

    try {
        $Random = New-Object System.Random
        $Text -split '' | ForEach-Object {
            Write-Host $_ -NoNewline -ForegroundColor $ForegroundColor
            Start-Sleep -Milliseconds $Random.Next($Speed)
        }
    } catch {
        "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}
function Write-Knock {
    <#
    .SYNOPSIS
        Tells a knock-Knock joke
    .NOTES
        Written by Bill Wilson (https://github.com/Trael-Kun)
    #>
    param (
        [Parameter(Mandatory)]
        [string]$Setup,
        [string]$Punchline
    )
    Clear-Host

    #Knock Knock
    $Correct = $false
    do {
        Write-Type "Knock Knock!" -ForegroundColor $KnockColor
        $UserReply = Read-Host ' '
        if ($Answers -match $UserReply ) {
            $Correct = $true
        }
    } while ($Correct -eq $false)

    #Setup
    while ("$Setup who","$Setup who?","$($Setup)who" -notcontains $UserReply){
        Write-Type $Setup -ForegroundColor $SetupColor
        $UserReply = Read-Host ' '
    }

    #Punchline
    Write-Type $Punchline -ForegroundColor $PunchColor
    Start-Sleep -Seconds 5
    Write-Type 'Haha' -ForegroundColor White
    Clear-Host
}

#Variables
$KnockColor = 'Magenta'
$SetupColor = $KnockColor
$PunchColor = 'Yellow'

$Answers    = @((((Invoke-RestMethod -Uri https://raw.githubusercontent.com/Trael-Kun/Powershell/refs/heads/main/punny/Knock-Knock/Answers.txt).split(',')).trim()))
$Jokes      = @(Invoke-RestMethod -Uri https://raw.githubusercontent.com/Trael-Kun/Powershell/refs/heads/main/punny/Knock-Knock/knocksource.csv | ConvertFrom-Csv)

#Start Script
Clear-Host
Write-Output 'Start humour'
Start-Sleep -Seconds 2
Clear-Host
$Count = 0
$Date  = Get-Date
Do {
    $UserReply = $null
    $Rando     = Get-Random -Minimum 0 -Maximum (($Jokes.Count)-1)
    $Count++
    if ($Jokes[$Rando].Xmas -eq 0) {
        Write-Knock -Setup $Jokes[$Rando].Setup -Punchline $Jokes[$Rando].Punchline
    } elseif ($Jokes[$Rando].Xmas -eq 1 -and $Date.Month -ne 12) {
        #next joke
    } else {
        Write-Knock -Setup $Jokes[$Rando].Setup -Punchline $Jokes[$Rando].Punchline
    }
} Until ($Count -eq ($Jokes.Count))
Write-Output 'Ending humour'
Start-Sleep -Seconds 3
Clear-Host
Write-Output 'Humour complete'
