<#
https://ss64.com/nt/icacls.html
#>
# Set PS variables for each of the icacls options
$Path = "C:\SCANNER"   #The path must be the first thing passed to icacls
$Grant = "/grant:r"
$Remove = "/remove"
$replaceInherit = "/inheritance:r"
$permission = ":(OI)(CI)(F)"
$useraccount1 = "NT AUTHORITY\Authenticated Users"

# Run icacls using invoke Expression
Invoke-Expression -Command ('icacls $Path $replaceInherit $Grant "${useraccount1}${permission }"')
<#
cmd /c "icacls 'C:\SCANNER' /T /E /R 
cmd /c "icacls 'C:\SCANNER' /T /E /G 'NT AUTHORITY\Authenticated Users':M"
#>