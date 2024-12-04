#set up voice
    Add-Type -AssemblyName System.Speech
    $SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    
    #get voices
    $Voices = $SpeechSynth.GetInstalledVoices().VoiceInfo
    $PreferredVoice = 'Microsoft Catherine Desktop'
    
    #select Voice
    if ($PreferredVoice -in $Voices.Name) {
        $SpeechSynth.SelectVoice($PreferredVoice)
    } elseif ('Microsoft Zira Desktop' -in $Voices.Name) {
        $SpeechSynth.SelectVoice("Microsoft Zira Desktop")
    } else {
    }
    
    #set up to grab cat fact
    $Browser = New-Object System.Net.WebClient
    $Browser.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    #get loading text
    $SimCityLoading = ((Invoke-WebRequest -Uri 'https://gist.githubusercontent.com/erikcox/7e96d031d00d7ecb1a2f/raw/0c24948e031798aacf45fd8b7207c45d8e41a373/SimCityLoadingMessages.txt').Content).split("`n") | Get-Random
    
    #say it
    $SpeechSynth.Speak($SimCityLoading)
