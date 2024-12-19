function Write-Type {
    <#
    .SYNOPSIS
        taps out text like a typewriter
    .NOTES
        Written by Markus Fleschutz (https://github.com/fleschutz)
        Adapted by Bill Wilson (https://github.com/Trael-Kun)
       References;
        https://github.com/fleschutz/PowerShell/blob/main/scripts/write-typewriter.ps1
    #>
    param(
        [parameter(mandatory)]    
        [string]$text,
        [int]$speed = 200
    )

    try {
        $Random = New-Object System.Random
        $text -split '' | ForEach-Object {
            Write-Host $_ -noNewline
            Start-Sleep -milliseconds $Random.Next($speed)
        }
    } catch {
        "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}
