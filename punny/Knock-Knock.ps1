<#
The Knock Knock Joke
Copyright 2014 - Joseph Preston
https://github.com/jpreston86/Powershell/blob/master/Knock%20Knock%20Joke

Optimised by Bill Wilson (https://github.com/Trael-Kun) - December 2024
#>

function Knock-Knock {
    param (
        [Parameter(Mandatory)]
        [string]$Setup,
        [string]$Punchline
    )

    Clear-Host

    #Knock Knock
    while ($userReply -notin $Answers ){
        $userReply = Read-Host "Knock Knock!"
    }

    Clear-Host

    #Setup
    while ($userReply -notcontains "$Setup who"){
        $userReply = Read-Host $Setup
    }   
    Clear-Host

    #Punchline
    Write-Output $Punchline
    Start-Sleep -second 5
    Clear-Host
}

$Answers = ('Who is there?','Who is there',"Who's there","Who's there?",'Whos there?','Whos there')

$Jokes = @(
    [pscustomobject]@{Setup='Cash';         Punchline="No thanks, but I would like a peanut instead!"                   }
    [pscustomobject]@{Setup='Doris';        Punchline="Doris locked, that's why I'm knocking!"                          }
    [pscustomobject]@{Setup='Madam';        Punchline="Madam foot got caught in the door!"                              }
    [pscustomobject]@{Setup='Cows go';      Punchline="No, cows go moo!"                                                }
    [pscustomobject]@{Setup='Oink oink';    Punchline="Make up your mind, are you a pig or an owl?!"                    }
    [pscustomobject]@{Setup='Honey bee';    Punchline="Honey bee a dear and get me a soda!"                             }
    [pscustomobject]@{Setup='Me';           Punchline="No, seriously, it's just me. I am telling a knock knock joke!"   }
    [pscustomobject]@{Setup='Arch';         Punchline="Gesundheit!"                                                     }

)

Clear-Host
$userReply = $null
Write-Output 'Start humour'
Start-Sleep -Seconds 3
Clear-Host

foreach ($Joke in $Jokes) {
    Knock-Knock -Setup $Joke.Setup -Punchline $Joke.Punchline
}

Write-Output 'End humour'
Start-Sleep -Seconds 3
Clear-Host
