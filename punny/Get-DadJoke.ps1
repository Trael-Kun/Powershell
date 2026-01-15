function Get-DadJoke {
    #Adapted from https://community.spiceworks.com/t/get-dadjoke/975466
    param (
    [Parameter(HelpMessage="Activates retell mode - used jokes are no longer ignored")]
    [switch]$EyeRollMode,
    [Parameter(HelpMessage="Activate Debug mode (displays used joke IDs)")]
    [switch]$ShowUsed,
    [Parameter(HelpMessage="Set output colour for Anecdotes - defaults to Yellow")]
    [string]$Anecdote = 'Yellow',
    [Parameter(HelpMessage="Set output colour for Q&A Questions - defaults to Magenta")]
    [string]$QAQ      = 'Magenta',
    [Parameter(HelpMessage="Set output colour for Q&A Answers - defaults to Yellow")]
    [string]$QAA      = 'Yellow',
    [Parameter(HelpMessage="Set output colour for One-Liners - defaults to Yellow")]
    [string]$OneLiner = 'Yellow'
    )

    #create empty array if does not exist
    if ($UsedDadJokes -eq $null) {
        $Global:UsedDadJokes = @()
    }

    Write-Output ''
    
    #get joke
    $Joke = Invoke-WebRequest -Uri "https://icanhazdadjoke.com" -Headers @{accept="application/json"} -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
    #extract ID
    $JokeId = ($Joke | Select-Object -ExpandProperty id).tostring()
    #if we've already heard this one, choose another
    if ($EyeRollMode -eq $false) {
        while ($JokeId -in $UsedDadJokes) {
            if ($ShowUsed) {
                Write-Host "$JokeId already told" -ForegroundColor Red
            }
            #get a new joke
            $Joke = Invoke-WebRequest -Uri "https://icanhazdadjoke.com" -Headers @{accept="application/json"} -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json
            $JokeId = ($Joke | Select-Object -ExpandProperty id).tostring()
        }
    }
    #extract joke text
    $DadJoke = ($Joke | Select-Object -ExpandProperty Joke).tostring()
    #format joke
    if ($DadJoke -match "`n") {
        #Anecdote
        Write-Host $DadJoke -ForegroundColor $Anecdote
        Write-Output ''
    } elseif (($DadJoke -match "\?") -and ($DadJoke -notmatch "\?`"")) {
        #Question&Answer
        $SplitJoke = $DadJoke.split("\?")
        Write-Host "$($SplitJoke[0])?" -ForegroundColor $QAQ
        Write-Host "$($SplitJoke[1].Trim())" -ForegroundColor $QAA
        Write-Output ''
    } else {
        #One-Liner
        Write-Host $DadJoke -ForegroundColor $OneLiner
        Write-Output ''
    }
    $Global:UsedDadJokes += $JokeId
}
