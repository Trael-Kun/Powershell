#https://www.reddit.com/r/sysadmin/comments/9dhm19/comment/e5jf2z6/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
$array = @"
"We're no strangers to love";
"You know the rules and so do I";
"A full commitment's what I'm thinking of";
"You wouldn't get this from any other guy";
"I just wanna tell you how I'm feeling";
"Gotta make you understand";
"Never gonna give you up";
"Never gonna let you down";
"Never gonna run around and desert you";
"Never gonna make you cry";
"Never gonna say goodbye";
"Never gonna tell a lie and hurt you";
"We've known each other for so long";
"Your heart's been aching but you're too shy to say it";
"Inside we both know what's been going on";
"We know the game and we're gonna play it";
"And if you ask me how I'm feeling";
"Don't tell me you're too blind to see";
"Never gonna give you up";
"Never gonna let you down";
"Never gonna run around and desert you";
"Never gonna make you cry";
"Never gonna say goodbye";
"Never gonna tell a lie and hurt you";
"Never gonna give you up";
"Never gonna let you down";
"Never gonna run around and desert you";
"Never gonna make you cry";
"Never gonna say goodbye";
"Never gonna tell a lie and hurt you";
"Ooh give you up";
"Ooh give you up";
"Ooh Never gonna give, never gonna give, give you up";
"Ooh Never gonna give, never gonna give, give you up";
"We've known each other for so long";
"Your heart's been aching but you're too shy to say it";
"Inside we both know what's been going on";
"We know the game and we're gonna play it";
"I just wanna tell you how I'm feeling";
"Gotta make you understand";
"Never gonna give you up";
"Never gonna let you down";
"Never gonna run around and desert you";
"Never gonna make you cry";
"Never gonna say goodbye";
"Never gonna tell a lie and hurt you";
"Never gonna give you up";
"Never gonna let you down";
"Never gonna run around and desert you";
"Never gonna make you cry";
"Never gonna say goodbye";
"Never gonna tell a lie and hurt you";
"Never gonna give you up";
"Never gonna let you down";
"Never gonna run around and desert you";
"Never gonna make you cry";
"Never gonna say goodbye";
"Never gonna tell a lie and hurt you"
"@
Start-Sleep 900
Add-Type -AssemblyName System.Speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$array | % {$speak.speak($_)}
