<#
.SYNOPSIS
   Written to amuse my 4-year old daughter
.DESCRIPTION
   Sets up a voice-synth through Windows' built-in speech-synth, and says "Daddy is smelly" evert 10 seconds

 .NOTES
    Author:  Bill Wilson
    Date:    21/03/2025
#>

#set up voice
Add-Type -AssemblyName System.Speech
$SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    
#get voices
$Voices = $SpeechSynth.GetInstalledVoices().VoiceInfo
$PreferredVoice = 'Microsoft Catherine Desktop'
    
#select Voice
if ($PreferredVoice -in $Voices.Name) {
    $SpeechSynth.SelectVoice($PreferredVoice)
} elseif ($Voices.Count -eq 1) {
        $SpeechSynth.SelectVoice($Voices.Name)
} elseif ('Microsoft Zira Desktop' -in $Voices.Name) {
    $SpeechSynth.SelectVoice("Microsoft Zira Desktop")
}

while ($true) {
    $SpeechSynth.Speak('Daddy is smelly')
    Start-Sleep -Seconds 10
}
