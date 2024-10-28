param (
    [switch]$Off
)

$ValueOn         = 'VoiceAccess'
$ValueOff        = ''
$Path            = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility'
$Name            = 'Configuration'
$PropertyType    = 'String'
$PathStart       = Split-Path -Path $Path -Parent
$PathEnd         = Split-Path -Path $Path -Leaf

#Unless we're turning it off
if ($Off) {
    $Value       = $ValueOff
} else {
    $Value       = $ValueOn
}

$GetVal          = Get-ItemPropertyValue -Path $Path -Name $Name

if (!($GetVal)) {
    New-Item -Path $PathStart -Name $PathEnd -Force
    New-ItemProperty -Path $Path -Name $Name -PropertyType $PropertyType -Value $Value
} elseif ($GetVal -ne $Value) {
    Set-ItemProperty -Name $Name -Path $Path -Value $Value
} else {
    exit 0
}
