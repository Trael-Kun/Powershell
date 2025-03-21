<#
.SYNOPSIS
 Speaks a dad joke every X minutes

.DESCRIPTION
 Fetches a dad joke from https://icanhazdadjoke.com, speaks it, then waits X minutes (default 10) and does it all again.

.NOTES
 Author:    Bill Wilson    
 Date:      21/03/2025
 Adapted from https://community.spiceworks.com/t/get-dadjoke/975466
 Speech from  https://www.reddit.com/r/PowerShell/comments/hsq84q/comment/fycz6ex
#>

$SleepTime  = 600
$WaitTime   = 5
$GetIt      = 3
$QAWait     = 1

#set up voice
Add-Type -AssemblyName System.Speech
$SpeechSynth    = New-Object System.Speech.Synthesis.SpeechSynthesizer

#get voices
$Voices         = $SpeechSynth.GetInstalledVoices().VoiceInfo
$PreferredVoice = 'Microsoft Catherine Desktop'

#select Voice
if ($PreferredVoice -in $Voices.Name) {
    $SpeechSynth.SelectVoice($PreferredVoice)
} elseif ($Voices.Count -eq 1) {
        $SpeechSynth.SelectVoice($Voices.Name)
} elseif ('Microsoft Zira Desktop' -in $Voices.Name) {
    $SpeechSynth.SelectVoice("Microsoft Zira Desktop")
} else {
}

While ($true) {
    #Get Joke
    $DadJoke = (Invoke-WebRequest -Uri "https://icanhazdadjoke.com" -Headers @{accept="application/json"} | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty Joke).tostring()
    if ($DadJoke -match "`n") {
        $JokeType = 'Anecdote'
        $JokePt1  =  $DadJoke
        Write-Output ''
    } elseif ($DadJoke -match "\?") {
        $JokeType  = 'Q&A'
        $SplitJoke = $DadJoke.split("\?")
        $JokePt1   = $($SplitJoke[0])
        $JokePt2   = $($SplitJoke[1].Trim())
    } else {
        $JokeType  = '1Liner'
        $JokePt1   =  $DadJoke
    }

    #say it
    $SpeechSynth.Speak('Here comes a DadJoke')
    Start-Sleep -Seconds $WaitTime
    if (($JokeType -eq '1Liner') -or ($JokeType -eq 'Anecdote')) {
        $SpeechSynth.Speak($JokePt1)
    } elseif ($JokeType -eq 'Q&A') {
        $SpeechSynth.Speak($JokePt1)
        Start-Sleep -Seconds $QAWait
        $SpeechSynth.Speak($JokePt2)
    }
    Start-Sleep -Seconds $GetIt
    $SpeechSynth.Speak('Ha Ha Ha')
    Start-Sleep -Seconds $WaitTime
    $SpeechSynth.Speak("Next Dad Joke in $($SleepTime / 60) minutes.")
    Start-Sleep -Seconds $SleepTime 
}
