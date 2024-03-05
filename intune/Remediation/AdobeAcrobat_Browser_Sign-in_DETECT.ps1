<#
Detects reg keys relating to CEF-based sign in for Adobe Acrobat
https://helpx.adobe.com/nz/acrobat/kb/cef-based-sign-in-not-working-with-azure-ad-conditional-access.html
Also removes forced sign-in
#>
$RegKey = 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown'
$iAcroLoginType = Get-ItemProperty -Path $RegKey -Name iAcroLoginType -ErrorAction SilentlyContinue
$bIsSCReducedModeEnforcedEx = Get-ItemProperty -Path $RegKey -Name bIsSCReducedModeEnforcedEx -ErrorAction SilentlyContinue
$bDontShowMsgWhenViewingDoc = Get-ItemProperty -Path $RegKey -Name bDontShowMsgWhenViewingDoc -ErrorAction SilentlyContinue
if ($null -eq $iAcroLoginType -or $iAcroLoginType.iAcroLoginType -ne 5) { 
    exit 1
} elseif ($null -eq $bIsSCReducedModeEnforcedEx -or $bIsSCReducedModeEnforcedEx.bIsSCReducedModeEnforcedEx -ne 1) {
    exit 1
} elseif ($null -eq $bDontShowMsgWhenViewingDoc -or $bDontShowMsgWhenViewingDoc.bDontShowMsgWhenViewingDoc -ne 0) {
    exit 1
} else { 
    Write-Host "No issues detected"
    exit 0
}
