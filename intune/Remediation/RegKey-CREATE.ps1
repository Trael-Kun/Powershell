#Variables
$Value         = 'VoiceAccess'
$Path            = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility'
$Name            = 'Configuration'
$PropertyType    = 'String'
$PathStart       = Split-Path -Path $Path -Parent
$PathEnd         = Split-Path -Path $Path -Leaf

#Test for existing value
$GetVal          = Get-ItemPropertyValue -Path $Path -Name $Name
if (!($GetVal)) {
    New-Item -Path $PathStart -Name $PathEnd -Force
    New-ItemProperty -Path $Path -Name $Name -PropertyType $PropertyType -Value $Value
} elseif ($GetVal -ne $Value) {
    Set-ItemProperty -Name $Name -Path $Path -Value $Value
} else {
    exit 0
}
