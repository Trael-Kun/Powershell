<#
.SYNOPSIS
Sets home location
.NOTES
Written by Bill, 19/02/2024

References:
https://www.elevenforum.com/t/change-country-or-region-geographic-location-geoid-in-windows-11.4034/
https://stackoverflow.com/questions/35705021/powershell-dynamic-menu-from-array
#>
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
$URL = 'https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations'
Write-Host ''
Write-Host "Running Script $(Join-Path -Path $PSScriptRoot -ChildPath $MyInvocation.MyCommand.Name)" -ForegroundColor Green -BackgroundColor DarkGreen
Write-Host ''
Write-Host ''
Write-Host "A full list of GeoIds is available at $URL" -ForegroundColor Green
Write-Host ''

Function Get-Wait ($Message)
{
    # Check if running Powershell ISE
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    }
    else
    {
        Write-Host "$Message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}
function Confirm-Choice {
	Write-Host "Set WinHome to `"$($Location.HomeLocation)`" " -NoNewline
	Write-Host 'Y' -ForegroundColor Magenta -NoNewline
	Write-Host '/'-NoNewline
	Write-Host 'N' -ForegroundColor Magenta -NoNewline
	Write-Host '? ' -NoNewline
    $Confirm = Read-Host 
    if ($Confirm -eq 'y') {
        Set-WinHomeLocation -GeoId $Location.GeoId
		Start-Sleep 1
        if ((Get-WinHomeLocation).GeoId -eq $Location.GeoId) {
			Write-Host 'WinHome set to ' -NoNewline
			Write-Host "$($Location.HomeLocation)" -ForegroundColor Green 
			$Failure = $false
		}
	} else {
		Write-Host "Unable to set location." -ForegroundColor Red
		$Failure = $true
	}    
break
}

$Locations = @(
	[pscustomobject]@{GeoId=2;         HomeLocation='Antigua and Barbuda'}
	[pscustomobject]@{GeoId=3;         HomeLocation='Afghanistan'}
	[pscustomobject]@{GeoId=4;         HomeLocation='Algeria'}
	[pscustomobject]@{GeoId=5;         HomeLocation='Azerbaijan'}
	[pscustomobject]@{GeoId=6;         HomeLocation='Albania'}
	[pscustomobject]@{GeoId=7;         HomeLocation='Armenia'}
	[pscustomobject]@{GeoId=8;         HomeLocation='Andorra'}
	[pscustomobject]@{GeoId=9;         HomeLocation='Angola'}
	[pscustomobject]@{GeoId=10;        HomeLocation='American Samoa'}
	[pscustomobject]@{GeoId=11;        HomeLocation='Argentina'}
	[pscustomobject]@{GeoId=12;        HomeLocation='Australia'}
	[pscustomobject]@{GeoId=14;        HomeLocation='Austria'}
	[pscustomobject]@{GeoId=17;        HomeLocation='Bahrain'}
	[pscustomobject]@{GeoId=18;        HomeLocation='Barbados'}
	[pscustomobject]@{GeoId=19;        HomeLocation='Botswana'}
	[pscustomobject]@{GeoId=20;        HomeLocation='Bermuda'}
	[pscustomobject]@{GeoId=21;        HomeLocation='Belgium'}
	[pscustomobject]@{GeoId=22;        HomeLocation='Bahamas, The'}
	[pscustomobject]@{GeoId=23;        HomeLocation='Bangladesh'}
	[pscustomobject]@{GeoId=24;        HomeLocation='Belize'}
	[pscustomobject]@{GeoId=25;        HomeLocation='Bosnia and Herzegovina'}
	[pscustomobject]@{GeoId=26;        HomeLocation='Bolivia'}
	[pscustomobject]@{GeoId=27;        HomeLocation='Myanmar'}
	[pscustomobject]@{GeoId=28;        HomeLocation='Benin'}
	[pscustomobject]@{GeoId=29;        HomeLocation='Belarus'}
	[pscustomobject]@{GeoId=30;        HomeLocation='Solomon Islands'}
	[pscustomobject]@{GeoId=32;        HomeLocation='Brazil'}
	[pscustomobject]@{GeoId=34;        HomeLocation='Bhutan'}
	[pscustomobject]@{GeoId=35;        HomeLocation='Bulgaria'}
	[pscustomobject]@{GeoId=37;        HomeLocation='Brunei'}
	[pscustomobject]@{GeoId=38;        HomeLocation='Burundi'}
	[pscustomobject]@{GeoId=39;        HomeLocation='Canada'}
	[pscustomobject]@{GeoId=40;        HomeLocation='Cambodia'}
	[pscustomobject]@{GeoId=41;        HomeLocation='Chad'}
	[pscustomobject]@{GeoId=42;        HomeLocation='Sri Lanka'}
	[pscustomobject]@{GeoId=43;        HomeLocation='Congo'}
	[pscustomobject]@{GeoId=44;        HomeLocation='Congo (DRC)'}
	[pscustomobject]@{GeoId=45;        HomeLocation='China'}
	[pscustomobject]@{GeoId=46;        HomeLocation='Chile'}
	[pscustomobject]@{GeoId=49;        HomeLocation='Cameroon'}
	[pscustomobject]@{GeoId=50;        HomeLocation='Comoros'}
	[pscustomobject]@{GeoId=51;        HomeLocation='Colombia'}
	[pscustomobject]@{GeoId=54;        HomeLocation='Costa Rica'}
	[pscustomobject]@{GeoId=55;        HomeLocation='Central African Republic'}
	[pscustomobject]@{GeoId=56;        HomeLocation='Cuba'}
	[pscustomobject]@{GeoId=57;        HomeLocation='Cabo Verde'}
	[pscustomobject]@{GeoId=59;        HomeLocation='Cyprus'}
	[pscustomobject]@{GeoId=61;        HomeLocation='Denmark'}
	[pscustomobject]@{GeoId=62;        HomeLocation='Djibouti'}
	[pscustomobject]@{GeoId=63;        HomeLocation='Dominica'}
	[pscustomobject]@{GeoId=65;        HomeLocation='Dominican Republic'}
	[pscustomobject]@{GeoId=66;        HomeLocation='Ecuador'}
	[pscustomobject]@{GeoId=67;        HomeLocation='Egypt'}
	[pscustomobject]@{GeoId=68;        HomeLocation='Ireland'}
	[pscustomobject]@{GeoId=69;        HomeLocation='Equatorial Guinea'}
	[pscustomobject]@{GeoId=70;        HomeLocation='Estonia'}
	[pscustomobject]@{GeoId=71;        HomeLocation='Eritrea'}
	[pscustomobject]@{GeoId=72;        HomeLocation='El Salvador'}
	[pscustomobject]@{GeoId=73;        HomeLocation='Ethiopia'}
	[pscustomobject]@{GeoId=75;        HomeLocation='Czech Republic'}
	[pscustomobject]@{GeoId=77;        HomeLocation='Finland'}
	[pscustomobject]@{GeoId=78;        HomeLocation='Fiji'}
	[pscustomobject]@{GeoId=80;        HomeLocation='Micronesia'}
	[pscustomobject]@{GeoId=81;        HomeLocation='Faroe Islands'}
	[pscustomobject]@{GeoId=84;        HomeLocation='France'}
	[pscustomobject]@{GeoId=86;        HomeLocation='Gambia'}
	[pscustomobject]@{GeoId=87;        HomeLocation='Gabon'}
	[pscustomobject]@{GeoId=88;        HomeLocation='Georgia'}
	[pscustomobject]@{GeoId=89;        HomeLocation='Ghana'}
	[pscustomobject]@{GeoId=90;        HomeLocation='Gibraltar'}
	[pscustomobject]@{GeoId=91;        HomeLocation='Grenada'}
	[pscustomobject]@{GeoId=93;        HomeLocation='Greenland'}
	[pscustomobject]@{GeoId=94;        HomeLocation='Germany'}
	[pscustomobject]@{GeoId=98;        HomeLocation='Greece'}
	[pscustomobject]@{GeoId=99;        HomeLocation='Guatemala'}
	[pscustomobject]@{GeoId=100;       HomeLocation='Guinea'}
	[pscustomobject]@{GeoId=101;       HomeLocation='Guyana'}
	[pscustomobject]@{GeoId=103;       HomeLocation='Haiti'}
	[pscustomobject]@{GeoId=104;       HomeLocation='Hong Kong SAR'}
	[pscustomobject]@{GeoId=106;       HomeLocation='Honduras'}
	[pscustomobject]@{GeoId=108;       HomeLocation='Croatia'}
	[pscustomobject]@{GeoId=109;       HomeLocation='Hungary'}
	[pscustomobject]@{GeoId=110;       HomeLocation='Iceland'}
	[pscustomobject]@{GeoId=111;       HomeLocation='Indonesia'}
	[pscustomobject]@{GeoId=113;       HomeLocation='India'}
	[pscustomobject]@{GeoId=114;       HomeLocation='British Indian Ocean Territory'}
	[pscustomobject]@{GeoId=116;       HomeLocation='Iran'}
	[pscustomobject]@{GeoId=117;       HomeLocation='Israel'}
	[pscustomobject]@{GeoId=118;       HomeLocation='Italy'}
	[pscustomobject]@{GeoId=119;       HomeLocation="Côte d'Ivoire"}
	[pscustomobject]@{GeoId=121;       HomeLocation='Iraq'}
	[pscustomobject]@{GeoId=122;       HomeLocation='Japan'}
	[pscustomobject]@{GeoId=124;       HomeLocation='Jamaica'}
	[pscustomobject]@{GeoId=125;       HomeLocation='Jan Mayen'}
	[pscustomobject]@{GeoId=126;       HomeLocation='Jordan'}
	[pscustomobject]@{GeoId=127;       HomeLocation='Johnston Atoll'}
	[pscustomobject]@{GeoId=129;       HomeLocation='Kenya'}
	[pscustomobject]@{GeoId=130;       HomeLocation='Kyrgyzstan'}
	[pscustomobject]@{GeoId=131;       HomeLocation='North Korea'}
	[pscustomobject]@{GeoId=133;       HomeLocation='Kiribati'}
	[pscustomobject]@{GeoId=134;       HomeLocation='Korea'}
	[pscustomobject]@{GeoId=136;       HomeLocation='Kuwait'}
	[pscustomobject]@{GeoId=137;       HomeLocation='Kazakhstan'}
	[pscustomobject]@{GeoId=138;       HomeLocation='Laos'}
	[pscustomobject]@{GeoId=139;       HomeLocation='Lebanon'}
	[pscustomobject]@{GeoId=140;       HomeLocation='Latvia'}
	[pscustomobject]@{GeoId=141;       HomeLocation='Lithuania'}
	[pscustomobject]@{GeoId=142;       HomeLocation='Liberia'}
	[pscustomobject]@{GeoId=143;       HomeLocation='Slovakia'}
	[pscustomobject]@{GeoId=145;       HomeLocation='Liechtenstein'}
	[pscustomobject]@{GeoId=146;       HomeLocation='Lesotho'}
	[pscustomobject]@{GeoId=147;       HomeLocation='Luxembourg'}
	[pscustomobject]@{GeoId=148;       HomeLocation='Libya'}
	[pscustomobject]@{GeoId=149;       HomeLocation='Madagascar'}
	[pscustomobject]@{GeoId=151;       HomeLocation='Macao SAR'}
	[pscustomobject]@{GeoId=152;       HomeLocation='Moldova'}
	[pscustomobject]@{GeoId=154;       HomeLocation='Mongolia'}
	[pscustomobject]@{GeoId=156;       HomeLocation='Malawi'}
	[pscustomobject]@{GeoId=157;       HomeLocation='Mali'}
	[pscustomobject]@{GeoId=158;       HomeLocation='Monaco'}
	[pscustomobject]@{GeoId=159;       HomeLocation='Morocco'}
	[pscustomobject]@{GeoId=160;       HomeLocation='Mauritius'}
	[pscustomobject]@{GeoId=162;       HomeLocation='Mauritania'}
	[pscustomobject]@{GeoId=163;       HomeLocation='Malta'}
	[pscustomobject]@{GeoId=164;       HomeLocation='Oman'}
	[pscustomobject]@{GeoId=165;       HomeLocation='Maldives'}
	[pscustomobject]@{GeoId=166;       HomeLocation='Mexico'}
	[pscustomobject]@{GeoId=167;       HomeLocation='Malaysia'}
	[pscustomobject]@{GeoId=168;       HomeLocation='Mozambique'}
	[pscustomobject]@{GeoId=173;       HomeLocation='Niger'}
	[pscustomobject]@{GeoId=174;       HomeLocation='Vanuatu'}
	[pscustomobject]@{GeoId=175;       HomeLocation='Nigeria'}
	[pscustomobject]@{GeoId=176;       HomeLocation='Netherlands'}
	[pscustomobject]@{GeoId=177;       HomeLocation='Norway'}
	[pscustomobject]@{GeoId=178;       HomeLocation='Nepal'}
	[pscustomobject]@{GeoId=180;       HomeLocation='Nauru'}
	[pscustomobject]@{GeoId=181;       HomeLocation='SuriHomeLocation'}
	[pscustomobject]@{GeoId=182;       HomeLocation='Nicaragua'}
	[pscustomobject]@{GeoId=183;       HomeLocation='New Zealand'}
	[pscustomobject]@{GeoId=184;       HomeLocation='Palestinian Authority'}
	[pscustomobject]@{GeoId=185;       HomeLocation='Paraguay'}
	[pscustomobject]@{GeoId=187;       HomeLocation='Peru'}
	[pscustomobject]@{GeoId=190;       HomeLocation='Pakistan'}
	[pscustomobject]@{GeoId=191;       HomeLocation='Poland'}
	[pscustomobject]@{GeoId=192;       HomeLocation='Panama'}
	[pscustomobject]@{GeoId=193;       HomeLocation='Portugal'}
	[pscustomobject]@{GeoId=194;       HomeLocation='Papua New Guinea'}
	[pscustomobject]@{GeoId=195;       HomeLocation='Palau'}
	[pscustomobject]@{GeoId=196;       HomeLocation='Guinea-Bissau'}
	[pscustomobject]@{GeoId=197;       HomeLocation='Qatar'}
	[pscustomobject]@{GeoId=198;       HomeLocation='Réunion'}
	[pscustomobject]@{GeoId=199;       HomeLocation='Marshall Islands'}
	[pscustomobject]@{GeoId=200;       HomeLocation='Romania'}
	[pscustomobject]@{GeoId=201;       HomeLocation='Philippines'}
	[pscustomobject]@{GeoId=202;       HomeLocation='Puerto Rico'}
	[pscustomobject]@{GeoId=203;       HomeLocation='Russia'}
	[pscustomobject]@{GeoId=204;       HomeLocation='Rwanda'}
	[pscustomobject]@{GeoId=205;       HomeLocation='Saudi Arabia'}
	[pscustomobject]@{GeoId=206;       HomeLocation='Saint Pierre and Miquelon'}
	[pscustomobject]@{GeoId=207;       HomeLocation='Saint Kitts and Nevis'}
	[pscustomobject]@{GeoId=208;       HomeLocation='Seychelles'}
	[pscustomobject]@{GeoId=209;       HomeLocation='South Africa'}
	[pscustomobject]@{GeoId=210;       HomeLocation='Senegal'}
	[pscustomobject]@{GeoId=212;       HomeLocation='Slovenia'}
	[pscustomobject]@{GeoId=213;       HomeLocation='Sierra Leone'}
	[pscustomobject]@{GeoId=214;       HomeLocation='San Marino'}
	[pscustomobject]@{GeoId=215;       HomeLocation='Singapore'}
	[pscustomobject]@{GeoId=216;       HomeLocation='Somalia'}
	[pscustomobject]@{GeoId=217;       HomeLocation='Spain'}
	[pscustomobject]@{GeoId=218;       HomeLocation='Saint Lucia'}
	[pscustomobject]@{GeoId=219;       HomeLocation='Sudan'}
	[pscustomobject]@{GeoId=220;       HomeLocation='Svalbard'}
	[pscustomobject]@{GeoId=221;       HomeLocation='Sweden'}
	[pscustomobject]@{GeoId=222;       HomeLocation='Syria'}
	[pscustomobject]@{GeoId=223;       HomeLocation='Switzerland'}
	[pscustomobject]@{GeoId=224;       HomeLocation='United Arab Emirates'}
	[pscustomobject]@{GeoId=225;       HomeLocation='Trinidad and Tobago'}
	[pscustomobject]@{GeoId=227;       HomeLocation='Thailand'}
	[pscustomobject]@{GeoId=228;       HomeLocation='Tajikistan'}
	[pscustomobject]@{GeoId=231;       HomeLocation='Tonga'}
	[pscustomobject]@{GeoId=232;       HomeLocation='Togo'}
	[pscustomobject]@{GeoId=233;       HomeLocation='São Tomé and Príncipe'}
	[pscustomobject]@{GeoId=234;       HomeLocation='Tunisia'}
	[pscustomobject]@{GeoId=235;       HomeLocation='Türkiye'}
	[pscustomobject]@{GeoId=236;       HomeLocation='Tuvalu'}
	[pscustomobject]@{GeoId=237;       HomeLocation='Taiwan'}
	[pscustomobject]@{GeoId=238;       HomeLocation='Turkmenistan'}
	[pscustomobject]@{GeoId=239;       HomeLocation='Tanzania'}
	[pscustomobject]@{GeoId=240;       HomeLocation='Uganda'}
	[pscustomobject]@{GeoId=241;       HomeLocation='Ukraine'}
	[pscustomobject]@{GeoId=242;       HomeLocation='United Kingdom'}
	[pscustomobject]@{GeoId=244;       HomeLocation='United States'}
	[pscustomobject]@{GeoId=245;       HomeLocation='Burkina Faso'}
	[pscustomobject]@{GeoId=246;       HomeLocation='Uruguay'}
	[pscustomobject]@{GeoId=247;       HomeLocation='Uzbekistan'}
	[pscustomobject]@{GeoId=248;       HomeLocation='Saint Vincent and the Grenadines'}
	[pscustomobject]@{GeoId=249;       HomeLocation='Venezuela'}
	[pscustomobject]@{GeoId=251;       HomeLocation='Vietnam'}
	[pscustomobject]@{GeoId=252;       HomeLocation='U.S. Virgin Islands'}
	[pscustomobject]@{GeoId=253;       HomeLocation='Vatican City'}
	[pscustomobject]@{GeoId=254;       HomeLocation='Namibia'}
	[pscustomobject]@{GeoId=258;       HomeLocation='Wake Island'}
	[pscustomobject]@{GeoId=259;       HomeLocation='Samoa'}
	[pscustomobject]@{GeoId=260;       HomeLocation='Swaziland'}
	[pscustomobject]@{GeoId=261;       HomeLocation='Yemen'}
	[pscustomobject]@{GeoId=263;       HomeLocation='Zambia'}
	[pscustomobject]@{GeoId=264;       HomeLocation='Zimbabwe'}
	[pscustomobject]@{GeoId=269;       HomeLocation='Serbia'}
	[pscustomobject]@{GeoId=270;       HomeLocation='Montenegro'}
	[pscustomobject]@{GeoId=271;       HomeLocation='Serbia'}
	[pscustomobject]@{GeoId=273;       HomeLocation='Curaçao'}
	[pscustomobject]@{GeoId=300;       HomeLocation='Anguilla'}
	[pscustomobject]@{GeoId=276;       HomeLocation='South Sudan'}
	[pscustomobject]@{GeoId=301;       HomeLocation='Antarctica'}
	[pscustomobject]@{GeoId=302;       HomeLocation='Aruba'}
	[pscustomobject]@{GeoId=303;       HomeLocation='Ascension Island'}
	[pscustomobject]@{GeoId=304;       HomeLocation='Ashmore and Cartier Islands'}
	[pscustomobject]@{GeoId=305;       HomeLocation='Baker Island'}
	[pscustomobject]@{GeoId=306;       HomeLocation='Bouvet Island'}
	[pscustomobject]@{GeoId=307;       HomeLocation='Cayman Islands'}
	[pscustomobject]@{GeoId=308;       HomeLocation='Channel Islands'}
	[pscustomobject]@{GeoId=309;       HomeLocation='Christmas Island'}
	[pscustomobject]@{GeoId=310;       HomeLocation='Clipperton Island'}
	[pscustomobject]@{GeoId=311;       HomeLocation='Cocos (Keeling) Islands'}
	[pscustomobject]@{GeoId=312;       HomeLocation='Cook Islands'}
	[pscustomobject]@{GeoId=313;       HomeLocation='Coral Sea Islands'}
	[pscustomobject]@{GeoId=314;       HomeLocation='Diego Garcia'}
	[pscustomobject]@{GeoId=315;       HomeLocation='Falkland Islands'}
	[pscustomobject]@{GeoId=317;       HomeLocation='French Guiana'}
	[pscustomobject]@{GeoId=318;       HomeLocation='French Polynesia'}
	[pscustomobject]@{GeoId=319;       HomeLocation='French Southern Territories'}
	[pscustomobject]@{GeoId=321;       HomeLocation='Guadeloupe'}
	[pscustomobject]@{GeoId=322;       HomeLocation='Guam'}
	[pscustomobject]@{GeoId=323;       HomeLocation='Guantanamo Bay'}
	[pscustomobject]@{GeoId=324;       HomeLocation='Guernsey'}
	[pscustomobject]@{GeoId=325;       HomeLocation='Heard Island and McDonald Islands'}
	[pscustomobject]@{GeoId=326;       HomeLocation='Howland Island'}
	[pscustomobject]@{GeoId=327;       HomeLocation='Jarvis Island'}
	[pscustomobject]@{GeoId=328;       HomeLocation='Jersey'}
	[pscustomobject]@{GeoId=329;       HomeLocation='Kingman Reef'}
	[pscustomobject]@{GeoId=330;       HomeLocation='Martinique'}
	[pscustomobject]@{GeoId=331;       HomeLocation='Mayotte'}
	[pscustomobject]@{GeoId=332;       HomeLocation='Montserrat'}
	[pscustomobject]@{GeoId=333;       HomeLocation='Netherlands Antilles (Former)'}
	[pscustomobject]@{GeoId=334;       HomeLocation='New Caledonia'}
	[pscustomobject]@{GeoId=335;       HomeLocation='Niue'}
	[pscustomobject]@{GeoId=336;       HomeLocation='Norfolk Island'}
	[pscustomobject]@{GeoId=337;       HomeLocation='Northern Mariana Islands'}
	[pscustomobject]@{GeoId=338;       HomeLocation='Palmyra Atoll'}
	[pscustomobject]@{GeoId=339;       HomeLocation='Pitcairn Islands'}
	[pscustomobject]@{GeoId=340;       HomeLocation='Rota Island'}
	[pscustomobject]@{GeoId=341;       HomeLocation='Saipan'}
	[pscustomobject]@{GeoId=342;       HomeLocation='South Georgia and the South Sandwich Islands'}
	[pscustomobject]@{GeoId=343;       HomeLocation='St Helena, Ascension and Tristan da Cunha'}
	[pscustomobject]@{GeoId=346;       HomeLocation='Tinian Island'}
	[pscustomobject]@{GeoId=347;       HomeLocation='Tokelau'}
	[pscustomobject]@{GeoId=348;       HomeLocation='Tristan da Cunha'}
	[pscustomobject]@{GeoId=349;       HomeLocation='Turks and Caicos Islands'}
	[pscustomobject]@{GeoId=351;       HomeLocation='British Virgin Islands'}
	[pscustomobject]@{GeoId=352;       HomeLocation='Wallis and Futuna'}
	[pscustomobject]@{GeoId=742;       HomeLocation='Africa'}
	[pscustomobject]@{GeoId=2129;      HomeLocation='Asia'}
	[pscustomobject]@{GeoId=10541;     HomeLocation='Europe'}
	[pscustomobject]@{GeoId=15126;     HomeLocation='Isle of Man'}
	[pscustomobject]@{GeoId=19618;     HomeLocation='North Macedonia'}
	[pscustomobject]@{GeoId=20900;     HomeLocation='Melanesia'}
	[pscustomobject]@{GeoId=21206;     HomeLocation='Micronesia'}
	[pscustomobject]@{GeoId=21242;     HomeLocation='Midway Islands'}
	[pscustomobject]@{GeoId=23581;     HomeLocation='Northern America'}
	[pscustomobject]@{GeoId=26286;     HomeLocation='Polynesia'}
	[pscustomobject]@{GeoId=27082;     HomeLocation='Central America'}
	[pscustomobject]@{GeoId=27114;     HomeLocation='Oceania'}
	[pscustomobject]@{GeoId=30967;     HomeLocation='Sint Maarten'}
	[pscustomobject]@{GeoId=31396;     HomeLocation='South America'}
	[pscustomobject]@{GeoId=31706;     HomeLocation='Saint Martin'}
	[pscustomobject]@{GeoId=39070;     HomeLocation='World'}
	[pscustomobject]@{GeoId=42483;     HomeLocation='Western Africa'}
	[pscustomobject]@{GeoId=42484;     HomeLocation='Middle Africa'}
	[pscustomobject]@{GeoId=42487;     HomeLocation='Northern Africa'}
	[pscustomobject]@{GeoId=47590;     HomeLocation='Central Asia'}
	[pscustomobject]@{GeoId=47599;     HomeLocation='South-Eastern Asia'}
	[pscustomobject]@{GeoId=47600;     HomeLocation='Eastern Asia'}
	[pscustomobject]@{GeoId=47603;     HomeLocation='Eastern Africa'}
	[pscustomobject]@{GeoId=47609;     HomeLocation='Eastern Europe'}
	[pscustomobject]@{GeoId=47610;     HomeLocation='Southern Europe'}
	[pscustomobject]@{GeoId=47611;     HomeLocation='Middle East'}
	[pscustomobject]@{GeoId=47614;     HomeLocation='Southern Asia'}
	[pscustomobject]@{GeoId=7299303;   HomeLocation='Timor-Leste'}
	[pscustomobject]@{GeoId=9914689;   HomeLocation='Kosovo'}
	[pscustomobject]@{GeoId=10026358;  HomeLocation='Americas'}
	[pscustomobject]@{GeoId=10028789;  HomeLocation='Åland Islands'}
	[pscustomobject]@{GeoId=10039880;  HomeLocation='Caribbean'}
	[pscustomobject]@{GeoId=10039882;  HomeLocation='Northern Europe'}
	[pscustomobject]@{GeoId=10039883;  HomeLocation='Southern Africa'}
	[pscustomobject]@{GeoId=10210824;  HomeLocation='Western Europe'}
	[pscustomobject]@{GeoId=10210825;  HomeLocation='Australia and New Zealand'}
	[pscustomobject]@{GeoId=161832015; HomeLocation='Saint Barthélemy'}
	[pscustomobject]@{GeoId=161832256; HomeLocation='U.S. Minor Outlying Islands'}
	[pscustomobject]@{GeoId=161832257; HomeLocation='Latin America and the Caribbean'}
	[pscustomobject]@{GeoId=161832258; HomeLocation='Bonaire, Sint Eustatius and Saba'}
)

#Set Variables

$Message 		 = 'Press any key to continue...'
$CurrentLocation = (Get-WinHomeLocation)
$NewLocation 	 = '?'

#Gather info
Write-Host 'Current WinHome is ' -NoNewLine
Write-Host $CurrentLocation.HomeLocation -ForegroundColor Magenta -NoNewline
Write-Host ', (GeoId: ' -NoNewline
Write-Host $CurrentLocation.GeoId -ForegroundColor Magenta -NoNewline
Write-Host ')'
Write-Host ''

#Request desired location
do {
	Write-Host ''
	Write-Host 'Enter New Location, or enter "' -NoNewline
	Write-Host '?' -ForegroundColor Cyan -NoNewline
	Write-Host '" to see the full list: ' -NoNewline
	$NewLocation = Read-Host
	Start-Sleep 1
	if ($NewLocation -eq '?') {
		Write-Output $Locations
	}
} until ($NewLocation -ne '?')

#if it's a number, check the numbers
if ([int]$NewLocation) {
	if ($NewLocation -notin $Locations.GeoId) {
		Write-Host 'Incorrect selection. Please consult ' -ForegroundColor Red -NoNewline
		Write-Host $URL -ForegroundColor Magenta -NoNewline
		Write-Host ' to confirm GeoId.' -ForegroundColor Red
	} else {
		foreach ($Location in $Locations) {
			if ($Location.GeoId -eq $NewLocation) {
				Confirm-Choice -Message $Message
			}
		}
	}
} elseif ($Location.HomeLocation -match $NewLocation) {
	$Search = $Locations | Where-Object -Property HomeLocation -match $NewLocation
	$menu = @{}
	for ($i=1;$i -le $Search.count; $i++) { 
		Write-Host "$i. $($Search[$i-1].HomeLocation) (GeoId: $($Search[$i-1].GeoId))" -ForegroundColor Green
		$menu.Add($i,($Search[$i-1].name))
	}
	[int]$ans = Read-Host 'Enter selection'
	$Selection = $Location[$ans-1]
	Confirm-Choice -Message $Message
}
#Test if successful
if ($Failure) {
	Write-Host 'Invalid selection. Please try again' -ForegroundColor Red
} else {
}
