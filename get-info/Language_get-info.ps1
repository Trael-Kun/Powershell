<#
Just messin' around
Bill
24/07/23
#>

$LangList = get-winuserlanguagelist
$Locale = get-winsystemlocale
$HomeLoc = get-winhomelocation
$Culture = get-culture
$PrefLang = get-systempreferreduilanguage

Write-Host ""

if ($LangList.LanguageTag -eq $Locale.Name) {
    if ($LangList.LanguageTag -eq $Culture.Name) {
        if ($LangList.LanguageTag -eq $PrefLang) {
            Write-Host "Languages set to $LangList.LanguageTag"
            Write-Host "Home Location set to $HomeLoc.HomeLocation"
        }
    }
}
