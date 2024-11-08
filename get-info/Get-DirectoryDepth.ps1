<#
 .SYNOPSIS
    Digs through the target directory and tells you where it is deepest.
 .PARAMETER TargetDirectory
    The directory you're targeting.
 .PARAMETER FromPath
    Start count from TargetDirectory
 .PARAMETER Report
    Writes output for each folder tested (Path & depth)
 .NOTES
    Author:   Bill Wilson
    Date:     08/11/24
    References;
        https://www.reddit.com/r/PowerShell/comments/w990nh/subfolder_level_depth_count/
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$TargetDirectory,
    [Parameter(Mandatory=$false)]
    [switch]$FromPath,
    [switch]$Report
)
if ($FromPath) {
    [int]$PathCount = ($TargetDirectory.Replace('\\','')).Split('\').Count
}
#find all the child directories
$Fetch = Get-ChildItem $TargetDirectory -Directory -Recurse
#set empty
$Levels = @()
#process data
ForEach ($Level in $Fetch) {
    #count directories in path
    [int]$Count = ($Level.FullName.Replace('\\','')).Split('\').Count
    if ($Report) { #tell us what you're doing
        if ($FromPath) { #minus however deep we are now
            $Count = ($Count - $PathCount)
        }
        Write-Output "Path $($Level.FullName) is $Count deep"
    }
    #build hash table
    $Levels += [pscustomobject]@{Path=$Level.FullName; Levels=$Count}
}
Write-Output ''
#sort data
$Deepest = $Levels | Sort-Object -Property Levels | Select-Object -Last 1
#write results
Write-Host 'Deepest path is ' -NoNewline
Write-Host $Deepest.Path -ForegroundColor Green -NoNewline
Write-Host ' at ' -NoNewline
Write-Host $Deepest.Levels -ForegroundColor Green -NoNewline
Write-Host ' levels'
Write-Output ''
