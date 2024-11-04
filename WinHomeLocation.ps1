<#
.SYNOPSIS
Sets home location
.NOTES
Written by Bill, 19/02/2024

References:
https://www.elevenforum.com/t/change-country-or-region-geographic-location-geoid-in-windows-11.4034/
https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations

Location id (decimal) |	Location (Short Name)
----------------------|----------------------
		2		Antigua and Barbuda
		3		Afghanistan
		4		Algeria
		5		Azerbaijan
		6		Albania
		7		Armenia
		8		Andorra
		9		Angola
		10		American Samoa
		11		Argentina
		12		Australia
		14		Austria
		17		Bahrain
		18		Barbados
		19		Botswana
		20		Bermuda
		21		Belgium
		22		Bahamas, The
		23		Bangladesh
		24		Belize
		25		Bosnia and Herzegovina
		26		Bolivia
		27		Myanmar
		28		Benin
		29		Belarus
		30		Solomon Islands
		32		Brazil
		34		Bhutan
		35		Bulgaria
		37		Brunei
		38		Burundi
		39		Canada
		40		Cambodia
		41		Chad
		42		Sri Lanka
		43		Congo
		44		Congo (DRC)
		45		China
		46		Chile
		49		Cameroon
		50		Comoros
		51		Colombia
		54		Costa Rica
		55		Central African Republic
		56		Cuba
		57		Cabo Verde
		59		Cyprus
		61		Denmark
		62		Djibouti
		63		Dominica
		65		Dominican Republic
		66		Ecuador
		67		Egypt
		68		Ireland
		69		Equatorial Guinea
		70		Estonia
		71		Eritrea
		72		El Salvador
		73		Ethiopia
		75		Czech Republic
		77		Finland
		78		Fiji
		80		Micronesia
		81		Faroe Islands
		84		France
		86		Gambia
		87		Gabon
		88		Georgia
		89		Ghana
		90		Gibraltar
		91		Grenada
		93		Greenland
		94		Germany
		98		Greece
		99		Guatemala
		100		Guinea
		101		Guyana
		103		Haiti
		104		Hong Kong SAR
		106		Honduras
		108		Croatia
		109		Hungary
		110		Iceland
		111		Indonesia
		113		India
		114		British Indian Ocean Territory
		116		Iran
		117		Israel
		118		Italy
		119		Côte d'Ivoire
		121		Iraq
		122		Japan
		124		Jamaica
		125		Jan Mayen
		126		Jordan
		127		Johnston Atoll
		129		Kenya
		130		Kyrgyzstan
		131		North Korea
		133		Kiribati
		134		Korea
		136		Kuwait
		137		Kazakhstan
		138		Laos
		139		Lebanon
		140		Latvia
		141		Lithuania
		142		Liberia
		143		Slovakia
		145		Liechtenstein
		146		Lesotho
		147		Luxembourg
		148		Libya
		149		Madagascar
		151		Macao SAR
		152		Moldova
		154		Mongolia
		156		Malawi
		157		Mali
		158		Monaco
		159		Morocco
		160		Mauritius
		162		Mauritania
		163		Malta
		164		Oman
		165		Maldives
		166		Mexico
		167		Malaysia
		168		Mozambique
		173		Niger
		174		Vanuatu
		175		Nigeria
		176		Netherlands
		177		Norway
		178		Nepal
		180		Nauru
		181		Suriname
		182		Nicaragua
		183		New Zealand
		184		Palestinian Authority
		185		Paraguay
		187		Peru
		190		Pakistan
		191		Poland
		192		Panama
		193		Portugal
		194		Papua New Guinea
		195		Palau
		196		Guinea-Bissau
		197		Qatar
		198		Réunion
		199		Marshall Islands
		200		Romania
		201		Philippines
		202		Puerto Rico
		203		Russia
		204		Rwanda
		205		Saudi Arabia
		206		Saint Pierre and Miquelon
		207		Saint Kitts and Nevis
		208		Seychelles
		209		South Africa
		210		Senegal
		212		Slovenia
		213		Sierra Leone
		214		San Marino
		215		Singapore
		216		Somalia
		217		Spain
		218		Saint Lucia
		219		Sudan
		220		Svalbard
		221		Sweden
		222		Syria
		223		Switzerland
		224		United Arab Emirates
		225		Trinidad and Tobago
		227		Thailand
		228		Tajikistan
		231		Tonga
		232		Togo
		233		São Tomé and Príncipe
		234		Tunisia
		235		Türkiye
		236		Tuvalu
		237		Taiwan
		238		Turkmenistan
		239		Tanzania
		240		Uganda
		241		Ukraine
		242		United Kingdom
		244		United States
		245		Burkina Faso
		246		Uruguay
		247		Uzbekistan
		248		Saint Vincent and the Grenadines
		249		Venezuela
		251		Vietnam
		252		U.S. Virgin Islands
		253		Vatican City
		254		Namibia
		258		Wake Island
		259		Samoa
		260		Swaziland
		261		Yemen
		263		Zambia
		264		Zimbabwe
		269		Serbia
		270		Montenegro
		271		Serbia
		273		Curaçao
		300		Anguilla
		276		South Sudan
		301		Antarctica
		302		Aruba
		303		Ascension Island
		304		Ashmore and Cartier Islands
		305		Baker Island
		306		Bouvet Island
		307		Cayman Islands
		308		Channel Islands
		309		Christmas Island
		310		Clipperton Island
		311		Cocos (Keeling) Islands
		312		Cook Islands
		313		Coral Sea Islands
		314		Diego Garcia
		315		Falkland Islands
		317		French Guiana
		318		French Polynesia
		319		French Southern Territories
		321		Guadeloupe
		322		Guam
		323		Guantanamo Bay
		324		Guernsey
		325		Heard Island and McDonald Islands
		326		Howland Island
		327		Jarvis Island
		328		Jersey
		329		Kingman Reef
		330		Martinique
		331		Mayotte
		332		Montserrat
		333		Netherlands Antilles (Former)
		334		New Caledonia
		335		Niue	
		336		Norfolk Island
		337		Northern Mariana Islands
		338		Palmyra Atoll
		339		Pitcairn Islands
		340		Rota Island
		341		Saipan
		342		South Georgia and the South Sandwich Islands
		343		St Helena, Ascension and Tristan da Cunha
		346		Tinian Island
		347		Tokelau
		348		Tristan da Cunha
		349		Turks and Caicos Islands
		351		British Virgin Islands
		352		Wallis and Futuna
		742		Africa
		2129		Asia
		10541		Europe
		15126		Isle of Man
		19618		North Macedonia
		20900		Melanesia
		21206		Micronesia
		21242		Midway Islands
		23581		Northern America
		26286		Polynesia
		27082		Central America
		27114		Oceania
		30967		Sint Maarten
		31396		South America
		31706		Saint Martin
		39070		World
		42483		Western Africa
		42484		Middle Africa
		42487		Northern Africa
		47590		Central Asia
		47599		South-Eastern Asia
		47600		Eastern Asia
		47603		Eastern Africa
		47609		Eastern Europe
		47610		Southern Europe
		47611		Middle East
		47614		Southern Asia
		7299303		Timor-Leste
		9914689		Kosovo
		10026358	Americas
		10028789	Åland Islands
		10039880	Caribbean
		10039882	Northern Europe
		10039883	Southern Africa
		10210824	Western Europe
		10210825	Australia and New Zealand
		161832015	Saint Barthélemy
		161832256	U.S. Minor Outlying Islands
		161832257	Latin America and the Caribbean
		161832258	Bonaire, Sint Eustatius and Saba
#>

# Set WinHome to desired location as listed above
$WinHome = 12

# Check if it's right
if ($(Get-WinHomeLocation).GeoId -eq $WinHome) {
		exit 0
} else { # If it isn't right, fix it
		exit 1
}
