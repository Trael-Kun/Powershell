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
        [int]$Speed = 200,
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
function Knock-Knock {
    param (
        [Parameter(Mandatory)]
        [string]$Setup,
        [string]$Punchline
    )
    Clear-Host
    ##Knock Knock
    while ($UserReply -notin $Answers ){
        Write-Type "Knock Knock!" -ForegroundColor Magenta
        $UserReply = Read-Host ' '
    }
    ##Setup
    while ("$Setup who","$Setup who?" -notcontains $UserReply){
        Write-Type $Setup -ForegroundColor Magenta
        $UserReply = Read-Host ' '
    }   
    ##Punchline
    Write-Type $Punchline -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    Clear-Host
}
#Variables
$Answers = ('Who is there?','Who is there',"Who's there","Who's there?",'Whos there?','Whos there')
$Jokes = @(
    [pscustomobject]@{Setup='Cash';                 Punchline="No thanks, but I would like a peanut instead!"}
    [pscustomobject]@{Setup='Doris';                Punchline="Doris locked, that's why I'm knocking!"}
    [pscustomobject]@{Setup='Madam';                Punchline="Madam foot got caught in the door!"}
    [pscustomobject]@{Setup='Cows go';              Punchline="No, cows go moo!"}
    [pscustomobject]@{Setup='Oink oink';            Punchline="Make up your mind, are you a pig or an owl?!"}
    [pscustomobject]@{Setup='Honey bee';            Punchline="Honey bee a dear and get me a soda!"}
    [pscustomobject]@{Setup='Me';                   Punchline="No, seriously, it's just me. I am telling a knock knock joke!"}
    [pscustomobject]@{Setup='Arch';                 Punchline="Gesundheit!"}
    [pscustomobject]@{Setup='Nobel';                Punchline="Nobel...that's why I knocked!"}
    [pscustomobject]@{Setup='Figs';                 Punchline="Figs the doorbell, it's not working!"}
    [pscustomobject]@{Setup='Annie';                Punchline="Annie thing you can do, I can do too!"}
    [pscustomobject]@{Setup='Cow says';             Punchline="No, a cow says mooooo!"}
    [pscustomobject]@{Setup='Hal';                  Punchline="Hal will you know if you don't open the door?"}
    [pscustomobject]@{Setup='Alice';                Punchline="Alice fair in love and war."}
    [pscustomobject]@{Setup='Says';                 Punchline="Says me!"}
    [pscustomobject]@{Setup='Honey bee';            Punchline="Honey bee a dear and get that for me, please!"}
    [pscustomobject]@{Setup='Euripides';            Punchline="Euripides clothes, you pay for them!"}
    [pscustomobject]@{Setup='Snow';                 Punchline="Snow use. The joke is over."}
    [pscustomobject]@{Setup='Hawaii';               Punchline="I'm good. Hawaii you?"}
    [pscustomobject]@{Setup='Woo';                  Punchline="Glad you're excited, too!"}
    [pscustomobject]@{Setup='Orange';               Punchline="Orange you going to let me in?"}
    [pscustomobject]@{Setup='Who?';                 Punchline="I didn't know you were an owl!"}
    [pscustomobject]@{Setup='Anita';                Punchline="Let me in! Anita borrow something."}
    [pscustomobject]@{Setup='Water';                Punchline="Water you doing telling jokes right now? Don't you have things to do?"}
    [pscustomobject]@{Setup='Leaf';                 Punchline="Leaf me alone!"}
    [pscustomobject]@{Setup='Nana';                 Punchline="Nana your business!"}
    [pscustomobject]@{Setup='Needle';               Punchline="Needle little help right now!"}
    [pscustomobject]@{Setup='Canoe';                Punchline="Canoe come out now?"}
    [pscustomobject]@{Setup='Iran';                 Punchline="Iran here. I'm tired!"}
    [pscustomobject]@{Setup='Amos';                 Punchline="A mosquito. Look, right there!"}
    [pscustomobject]@{Setup='Some';                 Punchline="Maybe some day you'll recognize me!"}
    [pscustomobject]@{Setup='Dozen';                Punchline="Dozen anyone want to let me in?"}
    [pscustomobject]@{Setup='Dwayne';               Punchline="Dwayne the sink. I need to use it!"}
    [pscustomobject]@{Setup='Ira';                  Punchline="Ira member you!"}
    [pscustomobject]@{Setup='Yvonne';               Punchline="Yvonne so many jokes already!"}
    [pscustomobject]@{Setup='Lemon';                Punchline="Lemon introduce myself!"}
    [pscustomobject]@{Setup='Juicy';                Punchline="Juicy who's knocking?"}
    [pscustomobject]@{Setup='Luke';                 Punchline="Luke through the peep hole and find out!"}
    [pscustomobject]@{Setup='Thermos';              Punchline="Thermos be a better way to get to you."}
    [pscustomobject]@{Setup='To';                   Punchline="Actually, it's to whom."}
    [pscustomobject]@{Setup='Lettuce';              Punchline="Lettuce in, it's cold out here!"}
    [pscustomobject]@{Setup='Razor';                Punchline="Razor hands, this is a stick-up!"}
    [pscustomobject]@{Setup='Alec';                 Punchline="Alectricity. BUZZ!"}
    [pscustomobject]@{Setup='Europe';               Punchline="No I'm not!"}
    [pscustomobject]@{Setup='Olive';                Punchline="Olive you"}
    [pscustomobject]@{Setup='Amarillo';             Punchline="Amarillo nice person."}
    [pscustomobject]@{Setup='Candice';              Punchline="Candice snack be eaten?"}
    [pscustomobject]@{Setup='Police';               Punchline="Police let me in, it's chilly out!"}
    [pscustomobject]@{Setup='Ice cream';            Punchline="Ice cream if you don't give me some candy!"}
    [pscustomobject]@{Setup='Etch';                 Punchline="Bless you!"}
    [pscustomobject]@{Setup='Boo';                  Punchline="Don't cry, it's just a joke."}
    [pscustomobject]@{Setup='Cher';                 Punchline="Cher would be nice if you opened the door!"}
    [pscustomobject]@{Setup='Theodore';             Punchline="Theodore is stuck. Open up!"}
    [pscustomobject]@{Setup='Stopwatch';            Punchline="Stopwatch you're doing and let me in!"}
    [pscustomobject]@{Setup='Spell';                Punchline="W. H. O."}
    [pscustomobject]@{Setup='Otis';                 Punchline="Otis a nice day for a walk!"}
    [pscustomobject]@{Setup='Wanda';                Punchline="Wanda hang out later?"}
    [pscustomobject]@{Setup='Carrie';               Punchline="Carrie my books for me, please!"}
    [pscustomobject]@{Setup='Winnie the';           Punchline="Winnie the Pooh!"}
    [pscustomobject]@{Setup='Wendy';                Punchline="Wendy you plan to let me in?"}
    [pscustomobject]@{Setup='Abbot';                Punchline="Abbot time you opened the door!"}
    [pscustomobject]@{Setup='Juan';                 Punchline="Juan more joke and I'm done!"}
    [pscustomobject]@{Setup='Yule';                 Punchline="Yule never guess who it is!"}
    [pscustomobject]@{Setup='Fanny';                Punchline="Fanny more knock-knock jokes?"}
    [pscustomobject]@{Setup='Jules';                Punchline="Jules you believe in magic?"}
    [pscustomobject]@{Setup='Archer';               Punchline="Archer going to let me in?"}
    [pscustomobject]@{Setup='Otto';                 Punchline="Otto be a law against bad jokes!"}
    [pscustomobject]@{Setup='A little old lady';    Punchline="Hey, you can yodel!"}
    [pscustomobject]@{Setup='Robin';                Punchline="Robin you. Give me your money!"}
    [pscustomobject]@{Setup='Icy';                  Punchline="Icy you looking at me!"}
    [pscustomobject]@{Setup='Voodoo';               Punchline="Voodoo you think you are?"}
    [pscustomobject]@{Setup='Mustache';             Punchline="I mustache you a question."}
    [pscustomobject]@{Setup='Mary';                 Punchline="Mary Christmas!"}
    [pscustomobject]@{Setup='Alex';                 Punchline="Alex-plain later!"}
    [pscustomobject]@{Setup='Iva';                  Punchline="I've a sore hand from knocking!"}
    [pscustomobject]@{Setup='Ketchup';              Punchline="Ketchup with me and I'll tell you!"}
    [pscustomobject]@{Setup='Canoe';                Punchline="Canoe help me get inside?"}
    [pscustomobject]@{Setup='Needle';               Punchline="Needle little money please."}
    [pscustomobject]@{Setup='Watson';               Punchline="Watson TV right now?"}
    [pscustomobject]@{Setup='Anee';                 Punchline="Anee one you like!"}
    [pscustomobject]@{Setup='Dozen';                Punchline="Dozen anybody want to let me in?"}
    [pscustomobject]@{Setup='Dishes';               Punchline="Dish is a nice place!"}
    [pscustomobject]@{Setup='A herd';               Punchline="A herd you were home, so here I am!"}
    [pscustomobject]@{Setup='Avenue';               Punchline="Avenue knocked on this door before?"}
    [pscustomobject]@{Setup='Althea';               Punchline="Althea later alligator!"}
    [pscustomobject]@{Setup='Arfur';                Punchline="Arfur got!"}
    [pscustomobject]@{Setup='Otto';                 Punchline="Otto know. I forgot."}
    [pscustomobject]@{Setup='Norma Lee';            Punchline="Norma Lee I don't knock on random doors, but I had to meet you!"}
    [pscustomobject]@{Setup='Imma';                 Punchline="Imma getting older waiting for you to open up!"}
    [pscustomobject]@{Setup='Yukon';                Punchline="Yukon say that again!"}
    [pscustomobject]@{Setup='Viper';                Punchline="Viper nose, it's running!"}
    [pscustomobject]@{Setup='CD';                   Punchline="CD person on your doorstep?"}
    [pscustomobject]@{Setup='Claire';               Punchline="Claire a path, I'm coming through!"}
    [pscustomobject]@{Setup='Roach';                Punchline="Roach you a text. Did you get it?"}
    [pscustomobject]@{Setup='Warren';               Punchline="Warren out your welcome yet?"}
    [pscustomobject]@{Setup='Annie';                Punchline="Annie way you can let me in?"}
    [pscustomobject]@{Setup='Harry';                Punchline="Harry up, it's cold outside!"}
    [pscustomobject]@{Setup='Ivor';                 Punchline="Ivor you let me in or I'll climb through the window!"}
    [pscustomobject]@{Setup='Abbot';                Punchline="Abbot you don't know who this is!"}
    [pscustomobject]@{Setup='Adore';                Punchline="Adore is between us, so open it!"}
    [pscustomobject]@{Setup='Noah';                 Punchline="Noah good place we can go hang out?"}
    [pscustomobject]@{Setup='Kirtch';               Punchline="God bless you!"}
    [pscustomobject]@{Setup='Justin';               Punchline="Justin time for dinner!"}
    [pscustomobject]@{Setup='Sadie';                Punchline="Sadie magic word and I'll come in!"}
    [pscustomobject]@{Setup='Iona';                 Punchline="Iona new toy!"}
    [pscustomobject]@{Setup='Two knee';             Punchline="Two-knee fish!"}
    [pscustomobject]@{Setup='Abby';                 Punchline="Abby birthday to you!"}
    [pscustomobject]@{Setup='Cows go';              Punchline="Cows don't go who, they go moo!"}
    [pscustomobject]@{Setup='Ben';                  Punchline="Ben knocking for 10 minutes!"}
    [pscustomobject]@{Setup='Isabel';               Punchline="Isabel working?"}
    [pscustomobject]@{Setup='Aida';                 Punchline="Aida sandwich for lunch today!"}
    [pscustomobject]@{Setup='Scold';                Punchline="Scold enough out here to go ice skating!"}
    [pscustomobject]@{Setup='I am';                 Punchline="Wait, you don't know who you are?"}
    [pscustomobject]@{Setup='Amanda';               Punchline="A man da fix your door!"}
    [pscustomobject]@{Setup='Al';                   Punchline="Al give you a hug if you open this door!"}
    [pscustomobject]@{Setup='Amish';                Punchline="You're not a shoe!"}
    [pscustomobject]@{Setup='Alfie';                Punchline="Alfie terrible if you don't let me in!"}
    [pscustomobject]@{Setup='Alien';                Punchline="Um, how many aliens do you know?"}
    [pscustomobject]@{Setup='Andrew';               Punchline="Andrew a picture!"}
    [pscustomobject]@{Setup='Dwayne';               Punchline="Dwayne the tub, I'm dwowning!"}
    [pscustomobject]@{Setup='Eugene';               Punchline="Eugene a great friend to me!"}
    [pscustomobject]@{Setup='Rory';                 Punchline="Rory about it later, open up!"}
    [pscustomobject]@{Setup='Boyd';                 Punchline="Boyd, am I hungry!"}
    [pscustomobject]@{Setup='Tank';                 Punchline="You're welcome!"}
    [pscustomobject]@{Setup='Armageddon';           Punchline="Armageddon a little bored. Let's go out!"}
    [pscustomobject]@{Setup='Butter';               Punchline="Butter let me in, it's cold out here!"}
    [pscustomobject]@{Setup='Ice cream';            Punchline="Ice cream every time I see a scary movie!"}
    [pscustomobject]@{Setup='Quack';                Punchline="Quack open the door, it's me!"}
    [pscustomobject]@{Setup='Honeydew';             Punchline="Honeydew you know how much I miss you?"}
    [pscustomobject]@{Setup='Peas';                 Punchline="Peas open the door!"}
    [pscustomobject]@{Setup='Howard';               Punchline="Howard you like a big hug?"}
    [pscustomobject]@{Setup='Harry';                Punchline="Harry up, I've got places to be!"}
    [pscustomobject]@{Setup='Radio';                Punchline="Radio not, here I come!"}
    [pscustomobject]@{Setup='Wooden shoe';          Punchline="Wooden shoe like to know!"}
    [pscustomobject]@{Setup='Owls';                 Punchline="Yes, they do!"}
    [pscustomobject]@{Setup='Leon';                 Punchline="Leon me, when you're not strong!"}
    [pscustomobject]@{Setup='Turnip';               Punchline="Turnip the volume, I love this song!"}
    [pscustomobject]@{Setup='Yeti';                 Punchline="Yeti another knock-knock joke!"}
    [pscustomobject]@{Setup='Yoda';                 Punchline="Yoda one I've been looking for!"}
    [pscustomobject]@{Setup='Arthur';               Punchline="Arthur any leftovers?"}
    [pscustomobject]@{Setup='Sherwood';             Punchline="Sherwood like to be your friend!"}
    [pscustomobject]@{Setup='Tish';                 Punchline="Tish is a very bad joke!"}
    [pscustomobject]@{Setup='Cargo';                Punchline="Cargo beep beep and vroom vroom!"}
    [pscustomobject]@{Setup='Gorilla';              Punchline="Gorilla me a burger, will you?"}
    [pscustomobject]@{Setup='Sheila';               Punchline="Sheila be coming around the mountain!"}
    [pscustomobject]@{Setup='Dewey';                Punchline="Dewey have to keep doing this?"}
    [pscustomobject]@{Setup='Sue';                  Punchline="Sue much to do, so little time!"}
    [pscustomobject]@{Setup='Penny';                Punchline="Penny for your thoughts?"}
    [pscustomobject]@{Setup='Tabby';                Punchline="Tabby or not tabby, that is the question!"}
    [pscustomobject]@{Setup='Finn';                 Punchline="Finn-ish your joke before I laugh!"}
    [pscustomobject]@{Setup='Kent';                 Punchline="Kent you tell by my voice?"}
    [pscustomobject]@{Setup='Quiche';               Punchline="Can I quiche you goodnight?"}
    [pscustomobject]@{Setup='Ash';                  Punchline="Ash me another question!"}
    [pscustomobject]@{Setup='Police';               Punchline="Police stop telling these jokes!"}
)
Clear-Host
Write-Output 'Start humour'
Start-Sleep -Seconds 3
Clear-Host
while ($true) {
    $UserReply = $null
    $Rando = Get-Random -Minimum 0 -Maximum (($Jokes.Count)-1)
    Knock-Knock -Setup $Jokes[$Rando].Setup -Punchline $Jokes[$Rando].Punchline
}
Write-Output 'End humour'
Start-Sleep -Seconds 3
Clear-Host
