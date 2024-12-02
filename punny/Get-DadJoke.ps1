function Get-DadJoke {
     #Adapted from https://community.spiceworks.com/t/get-dadjoke/975466
     Write-Output ''
     $DadJoke = (Invoke-WebRequest -Uri "https://icanhazdadjoke.com" -Headers @{accept="application/json"} | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty Joke).tostring()
     if ($DadJoke -contains '?') {
          $SplitJoke = $DadJoke.split('?')
          Write-Host "$($SplitJoke[0])?" -ForegroundColor Magenta
          Write-Host "$($SplitJoke[1].Trim())" -ForegroundColor Yellow
          Write-Output ''
     } else {
          Write-Host $DadJoke -ForegroundColor Yellow
          Write-Output ''
     }
}
