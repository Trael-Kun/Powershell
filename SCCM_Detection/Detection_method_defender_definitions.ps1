# Check for Defender Definitions Version
# Created by Bill 15/09/20

# Set variables:
$DefVersion = "1.349.xxx.0"

# Get Update list
$Definition = Get-MpComputerStatus

# Check for $DefVersion
if ($Definition.AntivirusSignatureVersion -eq $DefVersion) {
    Write-Host "True"
    }
Else {
    Write-Host "False"
    }