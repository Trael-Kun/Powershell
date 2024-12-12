<#
 .SYNOPSIS
    Scrape for links on a page & download each linked file
 .DESCRIPTION
    Scrapes Webpage at $Url for links that match $Filter, then downloads them via BITS transfer.
 .EXAMPLE
    PS C:\Windows\System32> .\LinkScraperDownload.ps1 -URL https://archive.org/download/dracula_ks_1608_librivox -Filter *128kb.mp3 -Destination C:\Downloads\Drac
 .EXAMPLE
    PS C:\Windows\System32> .\LinkScraperDownload.ps1 -URL https://archive.org/download/hitchhikers-guide-to-the-galaxy-bbcr4 -Filter *.mp3 -Destination C:\Downloads\Hitchhickers -Raw
 .EXAMPLE
    PS C:\Windows\System32> .\LinkScraperDownload.ps1 -URL https://archive.org/download/the-lord-of-the-rings-bbc-radio-drama -Filter "*Fellowship*.flac" -Destination C:\Downloads\LotrBook1 -Exclude *Oliver*
 .NOTES
    Author: Bill Wilson (https://github.com/Trael-Kun)
    Date:   12/12/2024

    Testing in PWSH 7 failing
    $Exclude variable not working? Removed for the time being.
#>

param(
    [Parameter(Mandatory)]
    [string]$Url,           #URL of the page for the download links
    [Parameter(Mandatory)]
    [string]$Destination,   #where the files will be saved to
    [Parameter(Mandatory)]
    [string]$Filter,         #which files to download. Accepts wildcards
    #[Parameter(Mandatory=$false)]
    #[string]$Exclude,       #if file name has this, don't download it
    [Parameter(Mandatory=$false)]
    [switch]$Raw           #disables filename conversion (UTF-8 to plaintext, see $CharMap)
)

$CharMap = @(
    [pscustomobject]@{Character=' ';    Windows='%20';  UTF='%20'       }
    [pscustomobject]@{Character='	';  Windows='%09';  UTF='%09%C3%BC' }
    [pscustomobject]@{Character='!';    Windows='%21';  UTF='%21'       }
    [pscustomobject]@{Character='"';    Windows='%22';  UTF='%22'       }
    [pscustomobject]@{Character='#';    Windows='%23';  UTF='%23'       }
    [pscustomobject]@{Character='$';    Windows='%24';  UTF='%24'       }
    [pscustomobject]@{Character='%';    Windows='%25';  UTF='%25'       }
    [pscustomobject]@{Character='&';    Windows='%26';  UTF='%26'       }
    [pscustomobject]@{Character="'";    Windows='%27';  UTF='%27'       }
    [pscustomobject]@{Character='(';    Windows='%28';  UTF='%28'       }
    [pscustomobject]@{Character=')';    Windows='%29';  UTF='%29'       }
    [pscustomobject]@{Character='*';    Windows='%2A';  UTF='%2A'       }
    [pscustomobject]@{Character='+';    Windows='%2B';  UTF='%2B'       }
    [pscustomobject]@{Character=',';    Windows='%2C';  UTF='%2C'       }
    [pscustomobject]@{Character='-';    Windows='%2D';  UTF='%2D'       }
    [pscustomobject]@{Character='.';    Windows='%2E';  UTF='%2E'       }
    [pscustomobject]@{Character='/';    Windows='%2F';  UTF='%2F'       }
    [pscustomobject]@{Character='0';    Windows='%30';  UTF='%30'       }
    [pscustomobject]@{Character='1';    Windows='%31';  UTF='%31'       }
    [pscustomobject]@{Character='2';    Windows='%32';  UTF='%32'       }
    [pscustomobject]@{Character='3';    Windows='%33';  UTF='%33'       }
    [pscustomobject]@{Character='4';    Windows='%34';  UTF='%34'       }
    [pscustomobject]@{Character='5';    Windows='%35';  UTF='%35'       }
    [pscustomobject]@{Character='6';    Windows='%36';  UTF='%36'       }
    [pscustomobject]@{Character='7';    Windows='%37';  UTF='%37'       }
    [pscustomobject]@{Character='8';    Windows='%38';  UTF='%38'       }
    [pscustomobject]@{Character='9';    Windows='%39';  UTF='%39'       }
    [pscustomobject]@{Character=':';    Windows='%3A';  UTF='%3A'       }
    [pscustomobject]@{Character=';';    Windows='%3B';  UTF='%3B'       }
    [pscustomobject]@{Character='<';    Windows='%3C';  UTF='%3C'       }
    [pscustomobject]@{Character='=';    Windows='%3D';  UTF='%3D'       }
    [pscustomobject]@{Character='>';    Windows='%3E';  UTF='%3E'       }
    [pscustomobject]@{Character='?';    Windows='%3F';  UTF='%3F'       }
    [pscustomobject]@{Character='@';    Windows='%40';  UTF='%40'       }
    [pscustomobject]@{Character='[';    Windows='%5B';  UTF='%5B'       }
    [pscustomobject]@{Character='\';    Windows='%5C';  UTF='%5C'       }
    [pscustomobject]@{Character=']';    Windows='%5D';  UTF='%5D'       }
    [pscustomobject]@{Character='^';    Windows='%5E';  UTF='%5E'       }
    [pscustomobject]@{Character='_';    Windows='%5F';  UTF='%5F'       }
    [pscustomobject]@{Character='`';    Windows='%60';  UTF='%60'       }
    [pscustomobject]@{Character='{';    Windows='%7B';  UTF='%7B'       }
    [pscustomobject]@{Character='|';    Windows='%7C';  UTF='%7C'       }
    [pscustomobject]@{Character='}';    Windows='%7D';  UTF='%7D'       }
    [pscustomobject]@{Character='~';    Windows='%7E';  UTF='%7E'       }
    [pscustomobject]@{Character='€';    Windows='%80';  UTF='%E2%82%AC' }
    [pscustomobject]@{Character='';    Windows='%81';  UTF='%81'       }
    [pscustomobject]@{Character="‚";    Windows='%82';  UTF='%E2%80%9A' }
    [pscustomobject]@{Character='ƒ';    Windows='%83';  UTF='%C6%92'    }
    [pscustomobject]@{Character='„';    Windows='%84';  UTF='%E2%80%9E' }
    [pscustomobject]@{Character='…';    Windows='%85';  UTF='%E2%80%A6' }
    [pscustomobject]@{Character='†';    Windows='%86';  UTF='%E2%80%A0' }
    [pscustomobject]@{Character='‡';    Windows='%87';  UTF='%E2%80%A1' }
    [pscustomobject]@{Character='ˆ';    Windows='%88';  UTF='%CB%86'    }
    [pscustomobject]@{Character='‰';    Windows='%89';  UTF='%E2%80%B0' }
    [pscustomobject]@{Character='Š';    Windows='%8A';  UTF='%C5%A0'    }
    [pscustomobject]@{Character='‹';    Windows='%8B';  UTF='%E2%80%B9' }
    [pscustomobject]@{Character='Œ';    Windows='%8C';  UTF='%C5%92'    }
    [pscustomobject]@{Character='';    Windows='%8D';  UTF='%C5%8D'    }
    [pscustomobject]@{Character='Ž';    Windows='%8E';  UTF='%C5%BD'    }
    [pscustomobject]@{Character='';    Windows='%8F';  UTF='%8F'       }
    [pscustomobject]@{Character='';    Windows='%90';  UTF='%C2%90'    }
    [pscustomobject]@{Character="‘";    Windows='%91';  UTF='%E2%80%98' }
    [pscustomobject]@{Character="’";    Windows='%92';  UTF='%E2%80%99' }
    [pscustomobject]@{Character='“';    Windows='%93';  UTF='%E2%80%9C' }
    [pscustomobject]@{Character='”';    Windows='%94';  UTF='%E2%80%9D' }
    [pscustomobject]@{Character='•';    Windows='%95';  UTF='%E2%80%A2' }
    [pscustomobject]@{Character='–';    Windows='%96';  UTF='%E2%80%93' }
    [pscustomobject]@{Character='—';    Windows='%97';  UTF='%E2%80%94' }
    [pscustomobject]@{Character='˜';    Windows='%98';  UTF='%CB%9C'    }
    [pscustomobject]@{Character='™';    Windows='%99';  UTF='%E2%84'    }
    [pscustomobject]@{Character='š';    Windows='%9A';  UTF='%C5%A1'    }
    [pscustomobject]@{Character='›';    Windows='%9B';  UTF='%E2%80'    }
    [pscustomobject]@{Character='œ';    Windows='%9C';  UTF='%C5%93'    }
    [pscustomobject]@{Character='';    Windows='%9D';  UTF='%9D'       }
    [pscustomobject]@{Character='ž';    Windows='%9E';  UTF='%C5%BE'    }
    [pscustomobject]@{Character='Ÿ';    Windows='%9F';  UTF='%C5%B8'    }
    [pscustomobject]@{Character='¡';    Windows='%A1';  UTF='%C2%A1'    }
    [pscustomobject]@{Character='¢';    Windows='%A2';  UTF='%C2%A2'    }
    [pscustomobject]@{Character='£';    Windows='%A3';  UTF='%C2%A3'    }
    [pscustomobject]@{Character='¤';    Windows='%A4';  UTF='%C2%A4'    }
    [pscustomobject]@{Character='¥';    Windows='%A5';  UTF='%C2%A5'    }
    [pscustomobject]@{Character='¦';    Windows='%A6';  UTF='%C2%A6'    }
    [pscustomobject]@{Character='§';    Windows='%A7';  UTF='%C2%A7'    }
    [pscustomobject]@{Character='¨';    Windows='%A8';  UTF='%C2%A8'    }
    [pscustomobject]@{Character='©';    Windows='%A9';  UTF='%C2%A9'    }
    [pscustomobject]@{Character='ª';    Windows='%AA';  UTF='%C2%AA'    }
    [pscustomobject]@{Character='«';    Windows='%AB';  UTF='%C2%AB'    }
    [pscustomobject]@{Character='¬';    Windows='%AC';  UTF='%C2%AC'    }
    [pscustomobject]@{Character='­';     Windows='%AD';  UTF='%C2%AD'    }
    [pscustomobject]@{Character='®';    Windows='%AE';  UTF='%C2%AE'    }
    [pscustomobject]@{Character='¯';    Windows='%AF';  UTF='%C2%AF'    }
    [pscustomobject]@{Character='°';    Windows='%B0';  UTF='%C2%B0'    }
    [pscustomobject]@{Character='±';    Windows='%B1';  UTF='%C2%B1'    }
    [pscustomobject]@{Character='²';    Windows='%B2';  UTF='%C2%B2'    }
    [pscustomobject]@{Character='³';    Windows='%B3';  UTF='%C2%B3'    }
    [pscustomobject]@{Character='´';    Windows='%B4';  UTF='%C2%B4'    }
    [pscustomobject]@{Character='µ';    Windows='%B5';  UTF='%C2%B5'    }
    [pscustomobject]@{Character='¶';    Windows='%B6';  UTF='%C2%B6'    }
    [pscustomobject]@{Character='·';    Windows='%B7';  UTF='%C2%B7'    }
    [pscustomobject]@{Character='¸';    Windows='%B8';  UTF='%C2%B8'    }
    [pscustomobject]@{Character='¹';    Windows='%B9';  UTF='%C2%B9'    }
    [pscustomobject]@{Character='º';    Windows='%BA';  UTF='%C2%BA'    }
    [pscustomobject]@{Character='»';    Windows='%BB';  UTF='%C2%BB'    }
    [pscustomobject]@{Character='¼';    Windows='%BC';  UTF='%C2%BC'    }
    [pscustomobject]@{Character='½';    Windows='%BD';  UTF='%C2%BD'    }
    [pscustomobject]@{Character='¾';    Windows='%BE';  UTF='%C2%BE'    }
    [pscustomobject]@{Character='¿';    Windows='%BF';  UTF='%C2%BF'    }
    [pscustomobject]@{Character='À';    Windows='%C0';  UTF='%C3%80'    }
    [pscustomobject]@{Character='Á';    Windows='%C1';  UTF='%C3%81'    }
    [pscustomobject]@{Character='Â';    Windows='%C2';  UTF='%C3%82'    }
    [pscustomobject]@{Character='Ã';    Windows='%C3';  UTF='%C3%83'    }
    [pscustomobject]@{Character='Ä';    Windows='%C4';  UTF='%C3%84'    }
    [pscustomobject]@{Character='Å';    Windows='%C5';  UTF='%C3%85'    }
    [pscustomobject]@{Character='Æ';    Windows='%C6';  UTF='%C3%86'    }
    [pscustomobject]@{Character='Ç';    Windows='%C7';  UTF='%C3%87'    }
    [pscustomobject]@{Character='È';    Windows='%C8';  UTF='%C3%88'    }
    [pscustomobject]@{Character='É';    Windows='%C9';  UTF='%C3%89'    }
    [pscustomobject]@{Character='Ê';    Windows='%CA';  UTF='%C3%8A'    }
    [pscustomobject]@{Character='Ë';    Windows='%CB';  UTF='%C3%8B'    }
    [pscustomobject]@{Character='Ì';    Windows='%CC';  UTF='%C3%8C'    }
    [pscustomobject]@{Character='Í';    Windows='%CD';  UTF='%C3%8D'    }
    [pscustomobject]@{Character='Î';    Windows='%CE';  UTF='%C3%8E'    }
    [pscustomobject]@{Character='Ï';    Windows='%CF';  UTF='%C3%8F'    }
    [pscustomobject]@{Character='Ð';    Windows='%D0';  UTF='%C3%90'    }
    [pscustomobject]@{Character='Ñ';    Windows='%D1';  UTF='%C3%91'    }
    [pscustomobject]@{Character='Ò';    Windows='%D2';  UTF='%C3%92'    }
    [pscustomobject]@{Character='Ó';    Windows='%D3';  UTF='%C3%93'    }
    [pscustomobject]@{Character='Ô';    Windows='%D4';  UTF='%C3%94'    }
    [pscustomobject]@{Character='Õ';    Windows='%D5';  UTF='%C3%95'    }
    [pscustomobject]@{Character='Ö';    Windows='%D6';  UTF='%C3%96'    }
    [pscustomobject]@{Character='×';    Windows='%D7';  UTF='%C3%97'    }
    [pscustomobject]@{Character='Ø';    Windows='%D8';  UTF='%C3%98'    }
    [pscustomobject]@{Character='Ù';    Windows='%D9';  UTF='%C3%99'    }
    [pscustomobject]@{Character='Ú';    Windows='%DA';  UTF='%C3%9A'    }
    [pscustomobject]@{Character='Û';    Windows='%DB';  UTF='%C3%9B'    }
    [pscustomobject]@{Character='Ü';    Windows='%DC';  UTF='%C3%9C'    }
    [pscustomobject]@{Character='Ý';    Windows='%DD';  UTF='%C3%9D'    }
    [pscustomobject]@{Character='Þ';    Windows='%DE';  UTF='%C3%9E'    }
    [pscustomobject]@{Character='ß';    Windows='%DF';  UTF='%C3%9F'    }
    [pscustomobject]@{Character='à';    Windows='%E0';  UTF='%C3%A0'    }
    [pscustomobject]@{Character='á';    Windows='%E1';  UTF='%C3%A1'    }
    [pscustomobject]@{Character='â';    Windows='%E2';  UTF='%C3%A2'    }
    [pscustomobject]@{Character='ã';    Windows='%E3';  UTF='%C3%A3'    }
    [pscustomobject]@{Character='ä';    Windows='%E4';  UTF='%C3%A4'    }
    [pscustomobject]@{Character='å';    Windows='%E5';  UTF='%C3%A5'    }
    [pscustomobject]@{Character='æ';    Windows='%E6';  UTF='%C3%A6'    }
    [pscustomobject]@{Character='ç';    Windows='%E7';  UTF='%C3%A7'    }
    [pscustomobject]@{Character='è';    Windows='%E8';  UTF='%C3%A8'    }
    [pscustomobject]@{Character='é';    Windows='%E9';  UTF='%C3%A9'    }
    [pscustomobject]@{Character='ê';    Windows='%EA';  UTF='%C3%AA'    }
    [pscustomobject]@{Character='ë';    Windows='%EB';  UTF='%C3%AB'    }
    [pscustomobject]@{Character='ì';    Windows='%EC';  UTF='%C3%AC'    }
    [pscustomobject]@{Character='í';    Windows='%ED';  UTF='%C3%AD'    }
    [pscustomobject]@{Character='î';    Windows='%EE';  UTF='%C3%AE'    }
    [pscustomobject]@{Character='ï';    Windows='%EF';  UTF='%C3%AF'    }
    [pscustomobject]@{Character='ð';    Windows='%F0';  UTF='%C3%B0'    }
    [pscustomobject]@{Character='ñ';    Windows='%F1';  UTF='%C3%B1'    }
    [pscustomobject]@{Character='ò';    Windows='%F2';  UTF='%C3%B2'    }
    [pscustomobject]@{Character='ó';    Windows='%F3';  UTF='%C3%B3'    }
    [pscustomobject]@{Character='ô';    Windows='%F4';  UTF='%C3%B4'    }
    [pscustomobject]@{Character='õ';    Windows='%F5';  UTF='%C3%B5'    }
    [pscustomobject]@{Character='ö';    Windows='%F6';  UTF='%C3%B6'    }
    [pscustomobject]@{Character='÷';    Windows='%F7';  UTF='%C3%B7'    }
    [pscustomobject]@{Character='ø';    Windows='%F8';  UTF='%C3%B8'    }
    [pscustomobject]@{Character='ù';    Windows='%F9';  UTF='%C3%B9'    }
    [pscustomobject]@{Character='ú';    Windows='%FA';  UTF='%C3%BA'    }
    [pscustomobject]@{Character='û';    Windows='%FB';  UTF='%C3%BB'    }
    [pscustomobject]@{Character='ü';    Windows='%FC';  UTF='%C3%BC'    }
    [pscustomobject]@{Character='ý';    Windows='%FD';  UTF='%C3%BD'    }
    [pscustomobject]@{Character='þ';    Windows='%FE';  UTF='%C3%BE'    }
    [pscustomobject]@{Character='ÿ';    Windows='%FF';  UTF='%C3%BF'    }
)

#get all of the relevant links
Write-Host 'Fetching list of links from '   -ForegroundColor Magenta -NoNewline
Write-Host $URL                             -ForegroundColor Yellow
$Files = ((Invoke-WebRequest -Uri $Url).Links | Where-Object innerHTML -like $Filter).href
Write-Host ''

#set progress variables
$FileCount  = $Files.Count
$FileProg   = 0
$DloadCount = 0

Write-Host 'Start Process' -ForegroundColor Magenta
Write-Host ''

foreach ($File in $Files) {
    $DloadCount = $DloadCount+1
    Write-Progress -Activity "Downloading Files" -PercentComplete (($DloadCount/$FileCount)*100) -Id 0
    #set FileName for output file
    $FileName = $File
    if ($Raw) {
        #no processing required
    } else {
        $FileProg = $FileProg+1
        Write-Progress -Activity 'Processing Filenames' -PercentComplete (($FileProg/$FileCount)*100) -Id 1 -ParentId 0
        $CharProg = 0
        $CharCount = $CharMap.Count
        foreach ($Char in $CharMap) {
            #if the name contains UTF-8 or Windows-1252 character mapping, replace with corresponding character
            $Utf8       = $Char.UTF
            $Win1252    = $Char.Windows
            $Character  = $Char.Character
            #increase progress counter
            $CharProg   = $CharProg+1
            Write-Progress -Activity 'Formatting Filename' -PercentComplete (($CharProg/$CharCount)*100) -Id 2 -ParentId 1
            if ($File -like "*$($Char.UTF)*") {
                Write-Progress -Activity "Replacing `"$Utf8`" with `"$Character`"" -Id 3 -ParentId 2
                $FileName = $Filename.replace($Utf8,$Character)
            } elseif ($File -like "*$($Char.Windows)*") {
                Write-Progress -Activity "Replacing `"$Win1252`" with `"$($Char.Character)`"" -Id 3 -ParentId 2
                $FileName = $Filename.replace($Win1252,$Character)
            }
        }      
    }
    #set variable for output file path
    $Dest = "$Destination\$FileName"
#    if ($FileName -notmatch $Exclude) {
        #no exclude?, pull it down
        $Excl = $false
        Write-Progress -Activity "Downloading $FileName" -Id 4 -ParentId 0
        Write-Host 'Downloading '   -ForegroundColor Magenta -NoNewline
        Write-Host $FileName        -ForegroundColor Green   -NoNewline
        Write-Host ' to '           -ForegroundColor Magenta -NoNewline
        Write-Host $Destination     -ForegroundColor Yellow
        Start-BitsTransfer -Source "$URL/$File" -Destination "$Dest"
<#
    } else {
        #if it has an exclude, don't grab it
        $Excl = $true
        Write-Host 'Excluding ' -ForegroundColor Magenta -NoNewline
        Write-Host $FileName    -ForegroundColor Red
        Write-Host ''
    }
#>
    if (!($Excl)) {
        if (Test-Path $Dest) {
            Write-Host $FileName            -ForegroundColor Green   -NoNewline
            Write-Host ' downloaded to '    -ForegroundColor Magenta -NoNewline
            Write-Host $Destination         -ForegroundColor Yellow
            Write-Host ''
        } else {
            Write-Host $Dest -ForegroundColor Red -NoNewline
            Write-Host ' not detected - please check download' -ForegroundColor Magenta
            Write-Host ''
        }
    }
}
Write-Host 'Finished' -ForegroundColor Magenta
