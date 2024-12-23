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
$Answers = (
    "Who is there?",
    "Who is there",
    "Who is their?",
    "Who is their",
    "Who is they're?",
    "Who is they're",
    "Who is theyre?",
    "Who is theyre",
    "Who's there",
    "Who's there?",
    "Whos there?",
    "Whos there",
    "Whos their",
    "Whos their?",
    "Who's their",
    "Who's their?",
    "Whos they're",
    "whos they're?",
    "Who's they're",
    "Who's they're?",
    "Whos theyre",
    "Whos theyre?",
    "Who's theyre",
    "Who's theyre?"
)
$Jokes = @(
    [pscustomobject]@{Setup='Cash';                 Xmas=$false;  Punchline="No thanks, but I would like a peanut instead!"}
    [pscustomobject]@{Setup='Doris';                Xmas=$false;  Punchline="Doris locked, that's why I'm knocking!"}
    [pscustomobject]@{Setup='Madam';                Xmas=$false;  Punchline="Madam foot got caught in the door!"}
    [pscustomobject]@{Setup='Cows go';              Xmas=$false;  Punchline="No, cows go moo!"}
    [pscustomobject]@{Setup='Oink oink';            Xmas=$false;  Punchline="Make up your mind, are you a pig or an owl?!"}
    [pscustomobject]@{Setup='Honey bee';            Xmas=$false;  Punchline="Honey bee a dear and get me a soda!"}
    [pscustomobject]@{Setup='Me';                   Xmas=$false;  Punchline="No, seriously, it's just me. I am telling a knock knock joke!"}
    [pscustomobject]@{Setup='Arch';                 Xmas=$false;  Punchline="Gesundheit!"}
    [pscustomobject]@{Setup='Nobel';                Xmas=$false;  Punchline="Nobel...that's why I knocked!"}
    [pscustomobject]@{Setup='Figs';                 Xmas=$false;  Punchline="Figs the doorbell, it's not working!"}
    [pscustomobject]@{Setup='Annie';                Xmas=$false;  Punchline="Annie thing you can do, I can do too!"}
    [pscustomobject]@{Setup='Cow says';             Xmas=$false;  Punchline="No, a cow says mooooo!"}
    [pscustomobject]@{Setup='Hal';                  Xmas=$false;  Punchline="Hal will you know if you don't open the door?"}
    [pscustomobject]@{Setup='Alice';                Xmas=$false;  Punchline="Alice fair in love and war."}
    [pscustomobject]@{Setup='Says';                 Xmas=$false;  Punchline="Says me!"}
    [pscustomobject]@{Setup='Honey bee';            Xmas=$false;  Punchline="Honey bee a dear and get that for me, please!"}
    [pscustomobject]@{Setup='Euripides';            Xmas=$false;  Punchline="Euripides clothes, you pay for them!"}
    [pscustomobject]@{Setup='Snow';                 Xmas=$false;  Punchline="Snow use. The joke is over."}
    [pscustomobject]@{Setup='Hawaii';               Xmas=$false;  Punchline="I'm good. Hawaii you?"}
    [pscustomobject]@{Setup='Woo';                  Xmas=$false;  Punchline="Glad you're excited, too!"}
    [pscustomobject]@{Setup='Orange';               Xmas=$false;  Punchline="Orange you going to let me in?"}
    [pscustomobject]@{Setup='Who?';                 Xmas=$false;  Punchline="I didn't know you were an owl!"}
    [pscustomobject]@{Setup='Anita';                Xmas=$false;  Punchline="Let me in! Anita borrow something."}
    [pscustomobject]@{Setup='Water';                Xmas=$false;  Punchline="Water you doing telling jokes right now? Don't you have things to do?"}
    [pscustomobject]@{Setup='Leaf';                 Xmas=$false;  Punchline="Leaf me alone!"}
    [pscustomobject]@{Setup='Nana';                 Xmas=$false;  Punchline="Nana your business!"}
    [pscustomobject]@{Setup='Needle';               Xmas=$false;  Punchline="Needle little help right now!"}
    [pscustomobject]@{Setup='Canoe';                Xmas=$false;  Punchline="Canoe come out now?"}
    [pscustomobject]@{Setup='Iran';                 Xmas=$false;  Punchline="Iran here. I'm tired!"}
    [pscustomobject]@{Setup='Amos';                 Xmas=$false;  Punchline="A mosquito. Look, right there!"}
    [pscustomobject]@{Setup='Some';                 Xmas=$false;  Punchline="Maybe some day you'll recognize me!"}
    [pscustomobject]@{Setup='Dozen';                Xmas=$false;  Punchline="Dozen anyone want to let me in?"}
    [pscustomobject]@{Setup='Dwayne';               Xmas=$false;  Punchline="Dwayne the sink. I need to use it!"}
    [pscustomobject]@{Setup='Ira';                  Xmas=$false;  Punchline="Ira member you!"}
    [pscustomobject]@{Setup='Yvonne';               Xmas=$false;  Punchline="Yvonne so many jokes already!"}
    [pscustomobject]@{Setup='Lemon';                Xmas=$false;  Punchline="Lemon introduce myself!"}
    [pscustomobject]@{Setup='Juicy';                Xmas=$false;  Punchline="Juicy who's knocking?"}
    [pscustomobject]@{Setup='Luke';                 Xmas=$false;  Punchline="Luke through the peep hole and find out!"}
    [pscustomobject]@{Setup='Thermos';              Xmas=$false;  Punchline="Thermos be a better way to get to you."}
    [pscustomobject]@{Setup='To';                   Xmas=$false;  Punchline="Actually, it's to whom."}
    [pscustomobject]@{Setup='Lettuce';              Xmas=$false;  Punchline="Lettuce in, it's cold out here!"}
    [pscustomobject]@{Setup='Razor';                Xmas=$false;  Punchline="Razor hands, this is a stick-up!"}
    [pscustomobject]@{Setup='Alec';                 Xmas=$false;  Punchline="Alectricity. BUZZ!"}
    [pscustomobject]@{Setup='Europe';               Xmas=$false;  Punchline="No I'm not!"}
    [pscustomobject]@{Setup='Olive';                Xmas=$false;  Punchline="Olive you"}
    [pscustomobject]@{Setup='Amarillo';             Xmas=$false;  Punchline="Amarillo nice person."}
    [pscustomobject]@{Setup='Candice';              Xmas=$false;  Punchline="Candice snack be eaten?"}
    [pscustomobject]@{Setup='Police';               Xmas=$false;  Punchline="Police let me in, it's chilly out!"}
    [pscustomobject]@{Setup='Ice cream';            Xmas=$false;  Punchline="Ice cream if you don't give me some candy!"}
    [pscustomobject]@{Setup='Etch';                 Xmas=$false;  Punchline="Bless you!"}
    [pscustomobject]@{Setup='Boo';                  Xmas=$false;  Punchline="Don't cry, it's just a joke."}
    [pscustomobject]@{Setup='Cher';                 Xmas=$false;  Punchline="Cher would be nice if you opened the door!"}
    [pscustomobject]@{Setup='Theodore';             Xmas=$false;  Punchline="Theodore is stuck. Open up!"}
    [pscustomobject]@{Setup='Stopwatch';            Xmas=$false;  Punchline="Stopwatch you're doing and let me in!"}
    [pscustomobject]@{Setup='Spell';                Xmas=$false;  Punchline="W. H. O."}
    [pscustomobject]@{Setup='Otis';                 Xmas=$false;  Punchline="Otis a nice day for a walk!"}
    [pscustomobject]@{Setup='Wanda';                Xmas=$false;  Punchline="Wanda hang out later?"}
    [pscustomobject]@{Setup='Carrie';               Xmas=$false;  Punchline="Carrie my books for me, please!"}
    [pscustomobject]@{Setup='Winnie the';           Xmas=$false;  Punchline="Winnie the Pooh!"}
    [pscustomobject]@{Setup='Wendy';                Xmas=$false;  Punchline="Wendy you plan to let me in?"}
    [pscustomobject]@{Setup='Abbot';                Xmas=$false;  Punchline="Abbot time you opened the door!"}
    [pscustomobject]@{Setup='Juan';                 Xmas=$false;  Punchline="Juan more joke and I'm done!"}
    [pscustomobject]@{Setup='Yule';                 Xmas=$false;  Punchline="Yule never guess who it is!"}
    [pscustomobject]@{Setup='Fanny';                Xmas=$false;  Punchline="Fanny more knock-knock jokes?"}
    [pscustomobject]@{Setup='Jules';                Xmas=$false;  Punchline="Jules you believe in magic?"}
    [pscustomobject]@{Setup='Archer';               Xmas=$false;  Punchline="Archer going to let me in?"}
    [pscustomobject]@{Setup='Otto';                 Xmas=$false;  Punchline="Otto be a law against bad jokes!"}
    [pscustomobject]@{Setup='A little old lady';    Xmas=$false;  Punchline="Hey, you can yodel!"}
    [pscustomobject]@{Setup='Robin';                Xmas=$false;  Punchline="Robin you. Give me your money!"}
    [pscustomobject]@{Setup='Icy';                  Xmas=$false;  Punchline="Icy you looking at me!"}
    [pscustomobject]@{Setup='Voodoo';               Xmas=$false;  Punchline="Voodoo you think you are?"}
    [pscustomobject]@{Setup='Mustache';             Xmas=$false;  Punchline="I mustache you a question."}
    [pscustomobject]@{Setup='Mary';                 Xmas=$false;  Punchline="Mary Christmas!"}
    [pscustomobject]@{Setup='Alex';                 Xmas=$false;  Punchline="Alex-plain later!"}
    [pscustomobject]@{Setup='Iva';                  Xmas=$false;  Punchline="I've a sore hand from knocking!"}
    [pscustomobject]@{Setup='Ketchup';              Xmas=$false;  Punchline="Ketchup with me and I'll tell you!"}
    [pscustomobject]@{Setup='Canoe';                Xmas=$false;  Punchline="Canoe help me get inside?"}
    [pscustomobject]@{Setup='Needle';               Xmas=$false;  Punchline="Needle little money please."}
    [pscustomobject]@{Setup='Watson';               Xmas=$false;  Punchline="Watson TV right now?"}
    [pscustomobject]@{Setup='Anee';                 Xmas=$false;  Punchline="Anee one you like!"}
    [pscustomobject]@{Setup='Dozen';                Xmas=$false;  Punchline="Dozen anybody want to let me in?"}
    [pscustomobject]@{Setup='Dishes';               Xmas=$false;  Punchline="Dish is a nice place!"}
    [pscustomobject]@{Setup='A herd';               Xmas=$false;  Punchline="A herd you were home, so here I am!"}
    [pscustomobject]@{Setup='Avenue';               Xmas=$false;  Punchline="Avenue knocked on this door before?"}
    [pscustomobject]@{Setup='Althea';               Xmas=$false;  Punchline="Althea later alligator!"}
    [pscustomobject]@{Setup='Arfur';                Xmas=$false;  Punchline="Arfur got!"}
    [pscustomobject]@{Setup='Otto';                 Xmas=$false;  Punchline="Otto know. I forgot."}
    [pscustomobject]@{Setup='Norma Lee';            Xmas=$false;  Punchline="Norma Lee I don't knock on random doors, but I had to meet you!"}
    [pscustomobject]@{Setup='Imma';                 Xmas=$false;  Punchline="Imma getting older waiting for you to open up!"}
    [pscustomobject]@{Setup='Yukon';                Xmas=$false;  Punchline="Yukon say that again!"}
    [pscustomobject]@{Setup='Viper';                Xmas=$false;  Punchline="Viper nose, it's running!"}
    [pscustomobject]@{Setup='CD';                   Xmas=$false;  Punchline="CD person on your doorstep?"}
    [pscustomobject]@{Setup='Claire';               Xmas=$false;  Punchline="Claire a path, I'm coming through!"}
    [pscustomobject]@{Setup='Roach';                Xmas=$false;  Punchline="Roach you a text. Did you get it?"}
    [pscustomobject]@{Setup='Warren';               Xmas=$false;  Punchline="Warren out your welcome yet?"}
    [pscustomobject]@{Setup='Annie';                Xmas=$false;  Punchline="Annie way you can let me in?"}
    [pscustomobject]@{Setup='Harry';                Xmas=$false;  Punchline="Harry up, it's cold outside!"}
    [pscustomobject]@{Setup='Ivor';                 Xmas=$false;  Punchline="Ivor you let me in or I'll climb through the window!"}
    [pscustomobject]@{Setup='Abbot';                Xmas=$false;  Punchline="Abbot you don't know who this is!"}
    [pscustomobject]@{Setup='Adore';                Xmas=$false;  Punchline="Adore is between us, so open it!"}
    [pscustomobject]@{Setup='Noah';                 Xmas=$false;  Punchline="Noah good place we can go hang out?"}
    [pscustomobject]@{Setup='Kirtch';               Xmas=$false;  Punchline="God bless you!"}
    [pscustomobject]@{Setup='Justin';               Xmas=$false;  Punchline="Justin time for dinner!"}
    [pscustomobject]@{Setup='Sadie';                Xmas=$false;  Punchline="Sadie magic word and I'll come in!"}
    [pscustomobject]@{Setup='Iona';                 Xmas=$false;  Punchline="Iona new toy!"}
    [pscustomobject]@{Setup='Two knee';             Xmas=$false;  Punchline="Two-knee fish!"}
    [pscustomobject]@{Setup='Abby';                 Xmas=$false;  Punchline="Abby birthday to you!"}
    [pscustomobject]@{Setup='Cows go';              Xmas=$false;  Punchline="Cows don't go who, they go moo!"}
    [pscustomobject]@{Setup='Ben';                  Xmas=$false;  Punchline="Ben knocking for 10 minutes!"}
    [pscustomobject]@{Setup='Isabel';               Xmas=$false;  Punchline="Isabel working?"}
    [pscustomobject]@{Setup='Aida';                 Xmas=$false;  Punchline="Aida sandwich for lunch today!"}
    [pscustomobject]@{Setup='Scold';                Xmas=$false;  Punchline="Scold enough out here to go ice skating!"}
    [pscustomobject]@{Setup='I am';                 Xmas=$false;  Punchline="Wait, you don't know who you are?"}
    [pscustomobject]@{Setup='Amanda';               Xmas=$false;  Punchline="A man da fix your door!"}
    [pscustomobject]@{Setup='Al';                   Xmas=$false;  Punchline="Al give you a hug if you open this door!"}
    [pscustomobject]@{Setup='Amish';                Xmas=$false;  Punchline="You're not a shoe!"}
    [pscustomobject]@{Setup='Alfie';                Xmas=$false;  Punchline="Alfie terrible if you don't let me in!"}
    [pscustomobject]@{Setup='Alien';                Xmas=$false;  Punchline="Um, how many aliens do you know?"}
    [pscustomobject]@{Setup='Andrew';               Xmas=$false;  Punchline="Andrew a picture!"}
    [pscustomobject]@{Setup='Dwayne';               Xmas=$false;  Punchline="Dwayne the tub, I'm dwowning!"}
    [pscustomobject]@{Setup='Eugene';               Xmas=$false;  Punchline="Eugene a great friend to me!"}
    [pscustomobject]@{Setup='Rory';                 Xmas=$false;  Punchline="Rory about it later, open up!"}
    [pscustomobject]@{Setup='Boyd';                 Xmas=$false;  Punchline="Boyd, am I hungry!"}
    [pscustomobject]@{Setup='Tank';                 Xmas=$false;  Punchline="You're welcome!"}
    [pscustomobject]@{Setup='Armageddon';           Xmas=$false;  Punchline="Armageddon a little bored. Let's go out!"}
    [pscustomobject]@{Setup='Butter';               Xmas=$false;  Punchline="Butter let me in, it's cold out here!"}
    [pscustomobject]@{Setup='Ice cream';            Xmas=$false;  Punchline="Ice cream every time I see a scary movie!"}
    [pscustomobject]@{Setup='Quack';                Xmas=$false;  Punchline="Quack open the door, it's me!"}
    [pscustomobject]@{Setup='Honeydew';             Xmas=$false;  Punchline="Honeydew you know how much I miss you?"}
    [pscustomobject]@{Setup='Peas';                 Xmas=$false;  Punchline="Peas open the door!"}
    [pscustomobject]@{Setup='Howard';               Xmas=$false;  Punchline="Howard you like a big hug?"}
    [pscustomobject]@{Setup='Harry';                Xmas=$false;  Punchline="Harry up, I've got places to be!"}
    [pscustomobject]@{Setup='Radio';                Xmas=$false;  Punchline="Radio not, here I come!"}
    [pscustomobject]@{Setup='Wooden shoe';          Xmas=$false;  Punchline="Wooden shoe like to know!"}
    [pscustomobject]@{Setup='Owls';                 Xmas=$false;  Punchline="Yes, they do!"}
    [pscustomobject]@{Setup='Leon';                 Xmas=$false;  Punchline="Leon me, when you're not strong!"}
    [pscustomobject]@{Setup='Turnip';               Xmas=$false;  Punchline="Turnip the volume, I love this song!"}
    [pscustomobject]@{Setup='Yeti';                 Xmas=$false;  Punchline="Yeti another knock-knock joke!"}
    [pscustomobject]@{Setup='Yoda';                 Xmas=$false;  Punchline="Yoda one I've been looking for!"}
    [pscustomobject]@{Setup='Arthur';               Xmas=$false;  Punchline="Arthur any leftovers?"}
    [pscustomobject]@{Setup='Sherwood';             Xmas=$false;  Punchline="Sherwood like to be your friend!"}
    [pscustomobject]@{Setup='Tish';                 Xmas=$false;  Punchline="Tish is a very bad joke!"}
    [pscustomobject]@{Setup='Cargo';                Xmas=$false;  Punchline="Cargo beep beep and vroom vroom!"}
    [pscustomobject]@{Setup='Gorilla';              Xmas=$false;  Punchline="Gorilla me a burger, will you?"}
    [pscustomobject]@{Setup='Sheila';               Xmas=$false;  Punchline="Sheila be coming around the mountain!"}
    [pscustomobject]@{Setup='Dewey';                Xmas=$false;  Punchline="Dewey have to keep doing this?"}
    [pscustomobject]@{Setup='Sue';                  Xmas=$false;  Punchline="Sue much to do, so little time!"}
    [pscustomobject]@{Setup='Penny';                Xmas=$false;  Punchline="Penny for your thoughts?"}
    [pscustomobject]@{Setup='Tabby';                Xmas=$false;  Punchline="Tabby or not tabby, that is the question!"}
    [pscustomobject]@{Setup='Finn';                 Xmas=$false;  Punchline="Finn-ish your joke before I laugh!"}
    [pscustomobject]@{Setup='Kent';                 Xmas=$false;  Punchline="Kent you tell by my voice?"}
    [pscustomobject]@{Setup='Quiche';               Xmas=$false;  Punchline="Can I quiche you goodnight?"}
    [pscustomobject]@{Setup='Ash';                  Xmas=$false;  Punchline="Ash me another question!"}
    [pscustomobject]@{Setup='Police';               Xmas=$false;  Punchline="Police stop telling these jokes!"}
    [pscustomobject]@{Setup='Ho Ho';                Xmas=$true;   Punchline="You sound like a Christmas owl!"}
    [pscustomobject]@{Setup='Mary';                 Xmas=$true;   Punchline="Mary Christmas!"}
    [pscustomobject]@{Setup='Avery';                Xmas=$true;   Punchline="Avery merry Christmas to you!"}
    [pscustomobject]@{Setup='Chris';                Xmas=$true;   Punchline="Christmas is here!"}
    [pscustomobject]@{Setup='Coal';                 Xmas=$true;   Punchline="Coal me when Santa's on his way!"}
    [pscustomobject]@{Setup='Olive';                Xmas=$true;   Punchline="Olive Christmastime, don't you?"}
    [pscustomobject]@{Setup='Santa';                Xmas=$true;   Punchline="Santa Christmas card to you. Did you get it?"}
    [pscustomobject]@{Setup='Honda';                Xmas=$true;   Punchline="Honda first day of Christmas my true love sent to me…"}
    [pscustomobject]@{Setup='Anna';                 Xmas=$true;   Punchline="Anna partridge in a pear tree."}
    [pscustomobject]@{Setup='Oakham';               Xmas=$true;   Punchline="Oakham all ye faithful..."}
    [pscustomobject]@{Setup='Wayne';                Xmas=$true;   Punchline="Wayne in a manger..."}
    [pscustomobject]@{Setup='Dexter.';              Xmas=$true;   Punchline="Dexter halls with boughs of holly…"}
    [pscustomobject]@{Setup='Olive.';               Xmas=$true;   Punchline="Olive the other reindeer used to laugh and call him names…"}
    [pscustomobject]@{Setup='Oh, Chris.';           Xmas=$true;   Punchline="Oh Christmas tree, Oh Christmas tree…"}
    [pscustomobject]@{Setup='Freeze.';              Xmas=$true;   Punchline="Freeze a jolly good fellow. Freeze a jolly good fellow…"}
    [pscustomobject]@{Setup='Elf.';                 Xmas=$true;   Punchline="Elf me wrap this present!"}
    [pscustomobject]@{Setup='Holly.';               Xmas=$true;   Punchline="Holly up already and Elf me wrap this present!"}
    [pscustomobject]@{Setup='Yule.';                Xmas=$true;   Punchline="Yule be sorry if you don't Holly up and Elf me wrap this present!"}
    [pscustomobject]@{Setup='Luke.';                Xmas=$true;   Punchline="Luke at all those presents!"}
    [pscustomobject]@{Setup='Doughnut.';            Xmas=$true;   Punchline="Doughnut open until Christmas!"}
    [pscustomobject]@{Setup='Pikachu.';             Xmas=$true;   Punchline="Pikachu Christmas presents and you'll be in trouble."}
    [pscustomobject]@{Setup='Snow.';                Xmas=$true;   Punchline="Snow time to waste. It's almost Christmas!"}
    [pscustomobject]@{Setup='Claus.';               Xmas=$true;   Punchline="Claus I can't wait any longer!"}
    [pscustomobject]@{Setup='Harry.';               Xmas=$true;   Punchline="Harry up and open your gift!"}
    [pscustomobject]@{Setup='Norway.';              Xmas=$true;   Punchline="Norway am I kissing anyone under the mistletoe!"}
    [pscustomobject]@{Setup='Anita.';               Xmas=$true;   Punchline="Anita ride, Rudolph."}
    [pscustomobject]@{Setup='Hosanna.';             Xmas=$true;   Punchline="Hosanna gonna fit down the chimney on Christmas Eve?"}
    [pscustomobject]@{Setup='Alaska.';              Xmas=$true;   Punchline="Alaska again. What do you want for Christmas?"}
    [pscustomobject]@{Setup='Wanda.';               Xmas=$true;   Punchline="Wanda know what you're getting for Christmas?"}
    [pscustomobject]@{Setup='Wooden shoe.';         Xmas=$true;   Punchline="Wooden shoe like to know what I got you for Christmas!"}
    [pscustomobject]@{Setup='Tank.';                Xmas=$true;   Punchline="Tank you for my Christmas present!"}
    [pscustomobject]@{Setup='Rabbit.';              Xmas=$true;   Punchline="Rabbit up carefully please. This present is fragile."}
    [pscustomobject]@{Setup='Kanye.';               Xmas=$true;   Punchline="Kanye help me untangle my Christmas lights?"}
    [pscustomobject]@{Setup='Canoe.';               Xmas=$true;   Punchline="Canoe help me bake some Christmas cookies?"}
    [pscustomobject]@{Setup='Lettuce.';             Xmas=$true;   Punchline="Lettuce in for cocoa and Christmas cookies."}
    [pscustomobject]@{Setup='Snow.';                Xmas=$true;   Punchline="Snow one's at the door."}
    [pscustomobject]@{Setup='Yule.';                Xmas=$true;   Punchline="Yule know when you answer the door."}
    [pscustomobject]@{Setup='Elf.';                 Xmas=$true;   Punchline="Elf I knock again will you let me in?"}
    [pscustomobject]@{Setup='Centipede.';           Xmas=$true;   Punchline="Centipede on the Christmas tree!"}
    [pscustomobject]@{Setup='Irish.';               Xmas=$true;   Punchline="Irish you a Merry Christmas!"}
    [pscustomobject]@{Setup='Ho Ho.';               Xmas=$true;   Punchline="Your Santa impression needs a little work!"}
    [pscustomobject]@{Setup='Ivana.';               Xmas=$true;   Punchline="Ivana wish you a Merry Christmas."}
    [pscustomobject]@{Setup='Murray.';              Xmas=$true;   Punchline="Murray Christmas to all, and to all a good night."}
    [pscustomobject]@{Setup='Mary and Abby.';       Xmas=$true;   Punchline="Mary Christmas and Abby New Year!"}
)
Clear-Host
Write-Output 'Start humour'
Start-Sleep -Seconds 2
Clear-Host
while ($true) {
    $Date = Get-Date
    $UserReply = $null
    $Rando = Get-Random -Minimum 0 -Maximum (($Jokes.Count)-1)
    if ($Jokes[$Rando].Xmas -eq $false) {
        Knock-Knock -Setup $Jokes[$Rando].Setup -Punchline $Jokes[$Rando].Punchline
    } elseif ($Jokes[$Rando].Xmas -eq $true -and $Date.Month -ne 12) {
        #next joke
    } else {
        Knock-Knock -Setup $Jokes[$Rando].Setup -Punchline $Jokes[$Rando].Punchline
    }
}
Write-Output 'End humour'
Start-Sleep -Seconds 3
Clear-Host
