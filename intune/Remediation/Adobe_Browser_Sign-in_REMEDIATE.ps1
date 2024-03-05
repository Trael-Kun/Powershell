<#
fixes reg keys relating to CEF-based sign in for Adobe Acrobat
https://helpx.adobe.com/nz/acrobat/kb/cef-based-sign-in-not-working-with-azure-ad-conditional-access.html
Also removes forced sign-in
#>
$RegKey = 'HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC'
New-Item -Path "$RegKey" -Name FeatureLockDown -Force
New-ItemProperty -Path "$RegKey\FeatureLockDown" -Name iAcroLoginType -PropertyType DWord -Value 5
New-ItemProperty -Path "$RegKey\FeatureLockDown" -Name bIsSCReducedModeEnforcedEx -PropertyType DWord -Value 1
New-ItemProperty -Path "$RegKey\FeatureLockDown" -Name bDontShowMsgWhenViewingDoc -PropertyType DWord -Value 0
