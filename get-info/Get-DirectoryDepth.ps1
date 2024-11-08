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
function Get-PathCount {
    param(
        [Parameter(Mandatory=$true)]
        [string]$CountPath
    )
    [int]($CountPath.Replace('\\','')).Split('\').Count
}
param (
    [Parameter(Mandatory=$true)]
    [string]$TargetDirectory,
    [Parameter(Mandatory=$false)]
    [switch]$FromPath,
    [switch]$Report
)
if ($FromPath) {    #caculate how many folders in the path
    $PathCount = Get-PathCount $TargetDirectory
}
#find all the child directories
$Directories = Get-ChildItem $TargetDirectory -Directory -Recurse
#set empty
$Levels = @()
#process data
ForEach ($Directory in $Directories) {
    #count directories in path
    $DirCount = Get-PathCount $Directory
    if ($Report) {          #tell us what you're doing
        if ($FromPath) {    #count from the parent path
            $DirCount = ($DirCount - $PathCount)
        }
        Write-Output "Path $($Directory.FullName) is $DirCount deep"
    }
    #store results
    if ($ExecutionContext.SessionState.LanguageMode -eq 'ConstrainedLanguage') {    #at least we'll get something if constrained language is on
        $Levels += $DirCount
    } else {                                                                        #build hash table
        $Levels += [pscustomobject]@{Path=$Directory.FullName; Levels=$DirCount}
    }
}
Write-Output ''

if (($null -ne $Levels.Path) -or ($Levels.Path -ne '')) { #with hashtable
    #sort data
    $Deepest = $Levels | Sort-Object -Property Levels | Select-Object -Last 1
    #write results
    Write-Host 'Deepest path is ' -NoNewline
    Write-Host $Deepest.Path -ForegroundColor Green -NoNewline
    Write-Host ' at ' -NoNewline
    Write-Host $Deepest.Levels -ForegroundColor Green -NoNewline
    Write-Host ' levels'
    Write-Output ''
} else {            #without hashtable
    #sort data
    $Deepest = $Levels | Sort-Object | Select-Object -Last 1
    #write results
    Write-Host 'Deepest path is ' -NoNewline
    Write-Host $Deepest -ForegroundColor Green -NoNewline
    Write-Host ' levels'
    Write-Output ''
}
#end
