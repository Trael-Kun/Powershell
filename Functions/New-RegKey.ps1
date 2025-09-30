Function New-RegKey {
    <#
     .SYNOPSIS
        Automatically checks for the existence of a file, and if file is present will append a 
        number to the end of a new filename.
    .DESCRIPTION
        Scans destination folder for existing files with the same base name, and if found will create 
        a new name appended with leading zeros (default value is 5). For example, if File.txt is found, 
        the newly generated filename will be "File00001.txt", and if "File00001".txt is found the new name 
        will be "File00002.txt", etc.
        This will also occur with files with ANY numbers before the file extension, for example "File2.txt" 
        would output a new filename of "File00003.txt"
    .PARAMETER ValueOn
        Specifies a value to activate the feature used by the Registry key.
    .PARAMETER ValueOff
        Specifies a value to deactivate the feature used by the Registry key.
    .PARAMETER Hive
        Specifies the registry hive to access/create. Accepts format HKLM:\ or Registry::HKEY_LOCAL_MACHINE
    .PARAMETER Name
        Specifies the name of the registry key to be created.
    .PARAMETER PropertyType
        Specifies the type of registry key. Accepts only the following inputs; 'String','ExpandString','Binary','DWord','MultiString','Qword','Unknown'
    .EXAMPLE
        C:\PS> New-RegKey -Hive 'HKLM:\SOFTWARE\RealSoftwareCo' -Name 'RealRegKey' -PropertyType String -ValueOn 'true'
        Tests for a reg key in HKLM:\SOFTWARE\RealSoftwareCo named RealRegKey with a value of true. Creates it if it does not exist, or changes the value if it does not match.
    .EXAMPLE
        C:\PS> New-RegKey -Hive 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\RealSoftwareCo' -Name 'RealRegKey' -PropertyType String -ValueOn 'true' -ValueOff 'false'
        Tests for a reg key in HKLM:\SOFTWARE\RealSoftwareCo named RealRegKey with a value of true. Creates it if it does not exist, or changes the value if it does not match.
    .EXAMPLE
        C:\PS> New-RegKey -Hive 'HKLM:\SOFTWARE\RealSoftwareCo' -Name 'RealRegKey' -PropertyType String -ValueOn 'true' -ValueOff 'false' -Off
        Tests for a reg key in HKLM:\SOFTWARE\RealSoftwareCo named RealRegKey with a value of false. Creates it if it does not exist, or changes the value if it does not match.
    .NOTES
        Author: Bill Wilson
        Date:   30/09/2025
    #>
    param (
        [Parameter(HelpMessage='Value that makes the Registry Key active')]
        [string]$ValueOn,
        [Parameter(HelpMessage='Value that makes the Registry Key inactive')]
        [string]$ValueOff,
        [Parameter(HelpMessage='Use switch Off to specify whether to use VauleOn or ValueOff. Default is On')]
        [switch]$Off,
        [Parameter(Mandatory=$true,HelpMessage='Registry Hive. Accepts format HKLM:\ or Registry::HKEY_LOCAL_MACHINE')]
            [string]$Hive,
        [Parameter(Mandatory=$true,HelpMessage='Registry Key name.')]
            [string]$Name,
        [Parameter(Mandatory=$true,HelpMessage='Registry Key type.')]
        [ValidateSet('String','ExpandString','Binary','DWord','MultiString','Qword','Unknown')]
            [string]$PropertyType
    )

    $HiveStart = Split-Path -Path $Hive -Parent #starting part of hive path
    $HiveEnd   = Split-Path -Path $Hive -Leaf   #last part of hive path
    
    #Unless we're turning it off
    if ($Off) {
        $Value = $ValueOff
    } else {
        $Value = $ValueOn
    }
    
    #Test for existing value
    $GetVal = Get-ItemPropertyValue -Path $Hive -Name $Name
    if (!($GetVal)) {
        New-Item -Path $PathStart -Name $HiveEnd -Force
        New-ItemProperty -Path $Hive -Name $Name -PropertyType $PropertyType -Value $Value
    } elseif ($GetVal -ne $Value) {
        Set-ItemProperty -Name $Name -Path $Hive -Value $Value
    }
}
