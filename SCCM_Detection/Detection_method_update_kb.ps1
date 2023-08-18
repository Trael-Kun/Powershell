# Check for installed updates
# Created by Bill 15/09/20

# Set variables:
$KBNumber = "KB5005260"

# Get Update list
$Hotfix = Get-HotFix

# Check for $KBnumber
if ($Hotfix.HotFixID -eq $KBNumber) {
    Write-Host "True"
    }
Else {
    Write-Host "False"
    }