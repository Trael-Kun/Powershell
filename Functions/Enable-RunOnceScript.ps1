function Enable-RunOnceScript {
    <#
        Set a script to run once on next login
        Written by Bill 28/01/2026
    #>
    param(
        # Switch to delete reg key before script has successfully completed. This is default RunOnce behaviour, but not default for this function.
        # For futher info see https://learn.microsoft.com/en-gb/windows/win32/setupapi/run-and-runonce-registry-keys
        [switch]$DeferOff,
        # Allow script to run in safe mode
        [switch]$SafeMode,
        # Scope/Hive to run the script in. Accepts User or Machine (default is Machine/HKLM)
        [Parameter(Mandatory=$false)]
            [ValidateSet('Machine','HKLM','User','HKCU')]
        [string]$Scope = 'Machine',
        # Path to script to be run
        [Parameter(Mandatory)]
            [string]$Path
    )

    #Variables
    [string] $RegPath = "Software\Microsoft\Windows\CurrentVersion\RunOnce"
    $User = 'User','HKCU'
    $Machine = 'Machine','HKLM'

    if ($Scope -like "*M*") {
        $RegPath = Join-Path -Path 'HKLM:\' -ChildPath $RegPath
    } elseif ($Scope -like "*U*") {
        $RegPath = Join-Path -Path 'HKCU:\' -ChildPath $RegPath
    }

    [string] $Path = "Powershell.exe $Path"

    if (-not($DeferOff)) {
        $Path = "!$Path"
    }
    if ($SafeMode) {
        $Path = "*$Path"
    }
    
    $Name = Split-Path -Path $Path -Leaf

    New-ItemProperty -Path $RegPath -Name "Run_$Name" -PropertyType String -Value $Path
}
