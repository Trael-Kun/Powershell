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
$Directories = Get-ChildItem $TargetDirectory -Directory -Recurse
#set empty
$Levels = @()
#process data
ForEach ($Directory in $Directories) {
    #count directories in path
    [int]$DirCount = ($Directory.FullName.Replace('\\','')).Split('\').Count
    if ($Report) { #tell us what you're doing
        if ($FromPath) {
            $DirCount = ($DirCount - $PathCount)
        }
        Write-Output "Path $($Directory.FullName) is $DirCount deep"
    }
    #build hash table
    try {
        $Levels += [pscustomobject]@{Path=$Directory.FullName; Levels=$DirCount}
    }
    catch { #at least we'll get something if constrained language is on
        $Levels += $DirCount
    }
}
Write-Output ''
#sort data
if ($Levels.Path) { #with hashtable
    $Deepest = $Levels | Sort-Object -Property Levels | Select-Object -Last 1
    #write results
    Write-Host 'Deepest path is ' -NoNewline
    Write-Host $Deepest.Path -ForegroundColor Green -NoNewline
    Write-Host ' at ' -NoNewline
    Write-Host $Deepest.Levels -ForegroundColor Green -NoNewline
    Write-Host ' levels'
    Write-Output ''
} else {    #without hashtable
    $Deepest = $Levels | Sort-Object | Select-Object -Last 1
    Write-Host 'Deepest path is ' -NoNewline
    Write-Host $Deepest.Levels -ForegroundColor Green -NoNewline
    Write-Host ' levels'
    Write-Output ''
}
#end
