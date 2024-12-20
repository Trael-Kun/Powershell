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
        [parameter(mandatory=$true)]
        [string]$Text,
        [parameter(mandatory=$false)]
        [int]$Speed = 200,
        [string]$ForegroundColor
    )

    try {
        $Random = New-Object System.Random
        if ($ForegroundColor) {
            $Text -Split '' | ForEach-Object {
                Write-Host $_ -NoNewline -ForegroundColor $ForegroundColor
                Start-Sleep -Milliseconds $Random.Next($Speed)
            }
        } else {
            $Text -Split '' | ForEach-Object {
                Write-Host $_ -NoNewline
                Start-Sleep -Milliseconds $Random.Next($Speed)
            }
        }
    } catch {
        "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    }
}
