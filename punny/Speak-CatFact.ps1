#https://www.reddit.com/r/PowerShell/comments/hsq84q/comment/fycz6ex
while ($true) {
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
    } else {
    }
    
    #set up to grab cat fact
    $Browser = New-Object System.Net.WebClient
    $Browser.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    #get a fact
    $CatFact = (ConvertFrom-Json (Invoke-WebRequest -Verbose -Uri https://catfact.ninja/fact -UseBasicParsing))
    $CatFact.fact
    
    #say it
    $SpeechSynth.Speak('Did you know ?')
    $SpeechSynth.Speak($CatFact.fact)
    Start-Sleep -Seconds 3600 
}
