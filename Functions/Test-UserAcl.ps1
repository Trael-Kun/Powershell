function Test-UserAcl {
    param (
        [Parameter(Mandatory,
        HelpMessage='Enter the target file or directory to be checked.')]
        [string]$Target,
        [string]$User,
        [int]$Rights
    )
    <#
    .SYNOPSIS
    Verifies ACL permissions for a specific user

    .DESCRIPTION


    .PARAMETER Target
    Specifies the target path of the ACL check

    .PARAMETER User
    Specifies the username

    .PARAMETER Rights
    Specifies permissions to look for. Enter in the form of an integer;

    0 - FullControl
    1 - Modify
    2 - ReadAndExecute
    3 - ListDirectory
    4 - Read
    5 - Write
    6 - Synchronize

    For further info, see 
    https://learn.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemrights?view=net-8.0#fields

    .OUTPUTS
    Check-Acl returns a true\false value in the varaible $AclCheck

    .EXAMPLE
    PS> Check-Acl -Target "C:\Temp" -User "NT AUTHORITY\Authenticated Users" -Rights 0
    C:\Temp ACL:
    NT AUTHORITY\Authenticated Users FullControl

    .EXAMPLE
    PS> Check-Acl -Target "C:\Temp" -User "NT AUTHORITY\Authenticated Users" -Rights 4
    C:\Temp not found

    #>

    $SysRights = @(
        'FullControl',      #0
        'Modify',           #1
        'ReadAndExecute',   #2
        'ListDirectory',    #3
        'Read',             #4
        'Write',            #5
        'Synchronize'       #6
    )
    $Loop = $true
    if (Test-path $Target) { #is the Dir there?
        # Check folder permissions
        $ACL = Get-Acl -Path $Target | Select-Object -Property Access
        $LoopCount = $ACL.count
        while ($true -eq $Loop) {
            foreach ($Access in $ACL.Access) {
                if ($Access.Identityreference -Match $User) {
                    if (($Access.FileSystemRights -match "\b$($SysRights[$Rights])\b")) { #all the \b stuff ensures an exact match for the string, so if we're searching for 'Read' it doesn't give a false positive for 'ReadAndExecute'
                        $AclCheck = $true    
                        Write-Host "$Target ACL:"
                        Write-Host "$User $($Access.FileSystemRights)"
                        $Loop = $false
                    }
                }
                $LoopCount = $LoopCount -1
                if ($LoopCount -lt 0) {
                    $Loop = $false
                }
            }
        }
    }
    else {
        $AclCheck = $false
        Write-Error -Message "$Target not found" -Category ObjectNotFound
    }
}
